import uuid
import pytest
from httpx import AsyncClient
from sqlalchemy import select
from tests.conftest import TestSessionLocal
from app.core.security import create_access_token, hash_password
from app.models.user import User, UserRole


async def get_test_headers():
    async with TestSessionLocal() as session:
        # Admin
        res_admin = await session.execute(select(User).where(User.role == UserRole.ADMIN))
        admin = res_admin.scalars().first()
        admin_token = create_access_token(user_id=admin.id, role=admin.role.value, email=admin.email)
        admin_headers = {"Authorization": f"Bearer {admin_token}"}

        # Staff
        res_staff = await session.execute(select(User).where(User.role == UserRole.STAFF))
        staff = res_staff.scalars().first()
        if not staff:
            staff = User(
                id=uuid.uuid4(),
                email=f"staff_{uuid.uuid4().hex[:6]}@brightloop.com",
                full_name="Staff Operator",
                hashed_password=hash_password("Staff#Pass2026"),
                role=UserRole.STAFF,
                is_active=True,
                is_verified=True,
            )
            session.add(staff)
            await session.commit()
            await session.refresh(staff)
        staff_token = create_access_token(user_id=staff.id, role=staff.role.value, email=staff.email)
        staff_headers = {"Authorization": f"Bearer {staff_token}"}

        # Customer 1
        res_cust1 = await session.execute(select(User).where(User.role == UserRole.CUSTOMER))
        cust1 = res_cust1.scalars().first()
        if not cust1:
            cust1 = User(
                id=uuid.uuid4(),
                email=f"cust1_{uuid.uuid4().hex[:6]}@example.com",
                full_name="Customer One",
                hashed_password=hash_password("Cust1#Pass2026"),
                role=UserRole.CUSTOMER,
                is_active=True,
                is_verified=True,
            )
            session.add(cust1)
            await session.commit()
            await session.refresh(cust1)
        cust1_token = create_access_token(user_id=cust1.id, role=cust1.role.value, email=cust1.email)
        cust1_headers = {"Authorization": f"Bearer {cust1_token}"}

        # Customer 2 (for isolation tests)
        cust2 = User(
            id=uuid.uuid4(),
            email=f"cust2_{uuid.uuid4().hex[:6]}@example.com",
            full_name="Customer Two",
            hashed_password=hash_password("Cust2#Pass2026"),
            role=UserRole.CUSTOMER,
            is_active=True,
            is_verified=True,
        )
        session.add(cust2)
        await session.commit()
        await session.refresh(cust2)
        cust2_token = create_access_token(user_id=cust2.id, role=cust2.role.value, email=cust2.email)
        cust2_headers = {"Authorization": f"Bearer {cust2_token}"}

    return admin_headers, staff_headers, cust1_headers, cust2_headers, cust1, cust2


@pytest.mark.asyncio
async def test_customer_creation_auto_provisioning_and_rbac(client: AsyncClient):
    admin_hdr, staff_hdr, cust1_hdr, _, _, _ = await get_test_headers()

    # 1. Staff creates a new customer (auto-provisions login user)
    rand_email = f"enterprise_{uuid.uuid4().hex[:6]}@brightloop.io"
    payload = {
        "name": "Acme Global Corp",
        "email": rand_email,
        "phone": "+91 9876543210",
        "company_name": "Acme Global Technologies Pvt Ltd",
        "billing_address_line1": "100 MG Road",
        "billing_city": "Bengaluru",
        "billing_state": "Karnataka",
        "billing_postal_code": "560001",
        "billing_country": "India",
    }

    create_res = await client.post("/api/v1/customers", json=payload, headers=staff_hdr)
    assert create_res.status_code == 201, create_res.text
    data = create_res.json()
    assert data["name"] == "Acme Global Corp"
    assert data["email"] == rand_email
    assert data["customer_number"].startswith("CUST-")
    assert data["user_id"] is not None  # Auto-provisioned user account
    cust_id = data["id"]

    # 2. Duplicate email rejected
    dup_res = await client.post("/api/v1/customers", json=payload, headers=admin_hdr)
    assert dup_res.status_code == 400
    assert "already exists" in dup_res.json()["detail"].lower()

    # 3. Customer role cannot create customers
    forbidden_res = await client.post("/api/v1/customers", json={**payload, "email": "forbidden@test.com"}, headers=cust1_hdr)
    assert forbidden_res.status_code == 403

    # 4. Staff cannot create Staff or Admin accounts via user endpoint
    staff_create_staff_res = await client.post(
        "/api/v1/users/staff",
        json={"email": f"rogue_{uuid.uuid4().hex[:4]}@staff.com", "full_name": "Rogue Staff", "password": "Password#123"},
        headers=staff_hdr,
    )
    assert staff_create_staff_res.status_code == 403


@pytest.mark.asyncio
async def test_customer_data_isolation(client: AsyncClient):
    admin_hdr, _, cust1_hdr, cust2_hdr, cust1, cust2 = await get_test_headers()

    # Create customer record for Cust1
    payload1 = {
        "name": "Cust1 Organization",
        "email": cust1.email,
        "company_name": "Org 1",
    }
    c1_res = await client.post("/api/v1/customers", json=payload1, headers=admin_hdr)
    assert c1_res.status_code in (201, 400)
    if c1_res.status_code == 201:
        c1_id = c1_res.json()["id"]
    else:
        # lookup existing
        list_res = await client.get(f"/api/v1/customers?search={cust1.email}", headers=admin_hdr)
        c1_id = list_res.json()["items"][0]["id"]

    # Cust1 can view their own record
    own_res = await client.get(f"/api/v1/customers/{c1_id}", headers=cust1_hdr)
    assert own_res.status_code == 200
    assert own_res.json()["email"] == cust1.email

    # Cust2 tries to access Cust1's record -> 403 Forbidden!
    isolation_res = await client.get(f"/api/v1/customers/{c1_id}", headers=cust2_hdr)
    assert isolation_res.status_code == 403
    assert "access denied" in isolation_res.json()["detail"].lower()

