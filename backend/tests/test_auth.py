import uuid
import pytest
from httpx import AsyncClient
from sqlalchemy import select
from app.core.security import hash_token
from app.models.token import PasswordResetToken, RefreshToken
from app.models.user import User


@pytest.mark.asyncio
async def test_register_customer_success(client: AsyncClient):
    email = f"customer_{uuid.uuid4().hex[:8]}@example.com"
    payload = {
        "email": email,
        "full_name": "Test Customer",
        "password": "StrongPassword#2026",
    }
    response = await client.post("/api/v1/auth/register", json=payload)
    assert response.status_code == 201
    data = response.json()
    assert "access_token" in data
    assert data["user"]["email"] == email.lower()
    assert data["user"]["role"] == "CUSTOMER"
    assert "refresh_token" in response.cookies


@pytest.mark.asyncio
async def test_register_password_complexity_failure(client: AsyncClient):
    payload = {
        "email": f"weak_{uuid.uuid4().hex[:8]}@example.com",
        "full_name": "Weak Pass User",
        "password": "weak",  # too short, no uppercase, etc.
    }
    response = await client.post("/api/v1/auth/register", json=payload)
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_register_duplicate_email_failure(client: AsyncClient):
    email = f"dup_{uuid.uuid4().hex[:8]}@example.com"
    payload = {
        "email": email,
        "full_name": "First User",
        "password": "StrongPassword#2026",
    }
    res1 = await client.post("/api/v1/auth/register", json=payload)
    assert res1.status_code == 201

    res2 = await client.post("/api/v1/auth/register", json=payload)
    assert res2.status_code == 400
    assert "already exists" in res2.json()["detail"]


@pytest.mark.asyncio
async def test_login_success_and_failure(client: AsyncClient):
    email = f"login_user_{uuid.uuid4().hex[:8]}@example.com"
    pwd = "CorrectPassword#2026"
    # Register
    await client.post(
        "/api/v1/auth/register",
        json={"email": email, "full_name": "Login User", "password": pwd},
    )

    # Failed login
    res_fail = await client.post(
        "/api/v1/auth/login",
        json={"email": email, "password": "WrongPassword#2026"},
    )
    assert res_fail.status_code == 401

    # Successful login
    res_success = await client.post(
        "/api/v1/auth/login",
        json={"email": email, "password": pwd},
    )
    assert res_success.status_code == 200
    data = res_success.json()
    assert "access_token" in data
    assert data["user"]["email"] == email.lower()
    assert "refresh_token" in res_success.cookies


@pytest.mark.asyncio
async def test_refresh_token_rotation_and_reuse_detection(client: AsyncClient):
    email = f"rotation_{uuid.uuid4().hex[:8]}@example.com"
    pwd = "RotationPassword#2026"
    reg_res = await client.post(
        "/api/v1/auth/register",
        json={"email": email, "full_name": "Rotation User", "password": pwd},
    )
    initial_refresh_cookie = reg_res.cookies["refresh_token"]

    # 1. Rotate token
    client.cookies.set("refresh_token", initial_refresh_cookie)
    rotate_res = await client.post("/api/v1/auth/refresh")
    assert rotate_res.status_code == 200
    rotated_data = rotate_res.json()
    assert "access_token" in rotated_data
    new_refresh_cookie = rotate_res.cookies["refresh_token"]
    assert new_refresh_cookie != initial_refresh_cookie

    # 2. Attempt reuse of initial token -> Should trigger reuse detection and revoke family
    client.cookies.set("refresh_token", initial_refresh_cookie)
    reuse_res = await client.post("/api/v1/auth/refresh")
    assert reuse_res.status_code == 401
    assert "Session anomaly detected" in reuse_res.json()["detail"]

    # 3. Subsequent attempts with the newer token should now also fail because family was revoked
    client.cookies.set("refresh_token", new_refresh_cookie)
    subsequent_res = await client.post("/api/v1/auth/refresh")
    assert subsequent_res.status_code == 401


@pytest.mark.asyncio
async def test_forgot_and_reset_password_flow(client: AsyncClient, db_session):
    email = f"reset_{uuid.uuid4().hex[:8]}@example.com"
    pwd = "InitialPassword#2026"
    await client.post(
        "/api/v1/auth/register",
        json={"email": email, "full_name": "Reset User", "password": pwd},
    )

    # Request password reset
    forgot_res = await client.post("/api/v1/auth/forgot-password", json={"email": email})
    assert forgot_res.status_code == 200
    assert "instructions have been sent" in forgot_res.json()["message"]

    # Query reset token from database to test the reset endpoint
    stmt = (
        select(PasswordResetToken, User.email)
        .join(User, PasswordResetToken.user_id == User.id)
        .where(User.email == email)
        .order_by(PasswordResetToken.created_at.desc())
    )
    result = await db_session.execute(stmt)
    row = result.first()
    assert row is not None
    token_record = row[0]
    assert token_record is not None

    # We need a token that matches hash. Let's create an explicit known token to reset:
    raw_token = f"{uuid.uuid4().hex}{uuid.uuid4().hex}"
    known_hash = hash_token(raw_token)
    token_record.token_hash = known_hash
    await db_session.commit()

    # Reset with new password
    new_pwd = "BrandNewPassword#2026"
    reset_res = await client.post(
        "/api/v1/auth/reset-password",
        json={"token": raw_token, "new_password": new_pwd},
    )
    assert reset_res.status_code == 200
    assert "successfully reset" in reset_res.json()["message"]

    # Old password fails
    old_login = await client.post("/api/v1/auth/login", json={"email": email, "password": pwd})
    assert old_login.status_code == 401

    # New password succeeds
    new_login = await client.post("/api/v1/auth/login", json={"email": email, "password": new_pwd})
    assert new_login.status_code == 200

    # 4. Attempt to REUSE the same reset token -> MUST FAIL (Single-use enforcement)
    reused_reset = await client.post(
        "/api/v1/auth/reset-password",
        json={"token": raw_token, "new_password": "YetAnotherPassword#2026"},
    )
    assert reused_reset.status_code == 400
    assert "Invalid or expired" in reused_reset.json()["detail"]
    await db_session.close()


@pytest.mark.asyncio
async def test_forgot_password_invalidates_prior_tokens(client: AsyncClient, db_session):
    email = f"multi_reset_{uuid.uuid4().hex[:8]}@example.com"
    pwd = "InitialPassword#2026"
    await client.post(
        "/api/v1/auth/register",
        json={"email": email, "full_name": "Multi Reset User", "password": pwd},
    )

    # 1. Request first reset
    await client.post("/api/v1/auth/forgot-password", json={"email": email})

    # Retrieve first token
    stmt = (
        select(PasswordResetToken)
        .join(User, PasswordResetToken.user_id == User.id)
        .where(User.email == email)
        .order_by(PasswordResetToken.created_at.desc())
    )
    res1 = await db_session.execute(stmt)
    token1 = res1.scalars().first()
    assert token1 is not None
    assert token1.is_used is False

    # Assign known token
    raw_token1 = f"{uuid.uuid4().hex}{uuid.uuid4().hex}"
    token1.token_hash = hash_token(raw_token1)
    await db_session.commit()

    # 2. Request second reset
    await client.post("/api/v1/auth/forgot-password", json={"email": email})

    # Check that first token was marked used / invalidated
    await db_session.refresh(token1)
    assert token1.is_used is True

    # 3. Attempt to reset using first token -> MUST FAIL
    attempt_res1 = await client.post(
        "/api/v1/auth/reset-password",
        json={"token": raw_token1, "new_password": "FailedUpdate#2026"},
    )
    assert attempt_res1.status_code == 400
    await db_session.close()


@pytest.mark.asyncio
async def test_logout_without_access_token_still_revokes_refresh_token(client: AsyncClient):
    email = f"logout_no_jwt_{uuid.uuid4().hex[:8]}@example.com"
    pwd = "Password#2026"
    reg_res = await client.post(
        "/api/v1/auth/register",
        json={"email": email, "full_name": "Logout User", "password": pwd},
    )
    refresh_cookie = reg_res.cookies["refresh_token"]

    # Call logout WITHOUT Authorization header (e.g. access token expired)
    client.cookies.set("refresh_token", refresh_cookie)
    logout_res = await client.post("/api/v1/auth/logout")
    assert logout_res.status_code == 200
    assert "Successfully logged out" in logout_res.json()["message"]

    # Now verify that trying to refresh with that cookie fails because it was revoked
    client.cookies.set("refresh_token", refresh_cookie)
    subsequent_refresh = await client.post("/api/v1/auth/refresh")
    assert subsequent_refresh.status_code == 401
