import uuid
import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_rbac_and_user_management(client: AsyncClient):
    # 1. Log in as bootstrapped Admin
    admin_login = await client.post(
        "/api/v1/auth/login",
        json={"email": "admin@brightloop.com", "password": "Brightloop#Admin2026"},
    )
    assert admin_login.status_code == 200
    admin_token = admin_login.json()["access_token"]
    admin_headers = {"Authorization": f"Bearer {admin_token}"}

    # 2. Register a customer
    cust_email = f"cust_{uuid.uuid4().hex[:8]}@example.com"
    cust_reg = await client.post(
        "/api/v1/auth/register",
        json={"email": cust_email, "full_name": "Customer One", "password": "CustPassword#2026"},
    )
    assert cust_reg.status_code == 201
    cust_token = cust_reg.json()["access_token"]
    cust_headers = {"Authorization": f"Bearer {cust_token}"}

    # 3. Customer CANNOT list users (403 Forbidden)
    cust_list_res = await client.get("/api/v1/users", headers=cust_headers)
    assert cust_list_res.status_code == 403

    # 4. Admin CAN list users (200 OK)
    admin_list_res = await client.get("/api/v1/users", headers=admin_headers)
    assert admin_list_res.status_code == 200
    assert admin_list_res.json()["total"] >= 2

    # 5. Customer CANNOT create staff
    staff_email = f"staff_{uuid.uuid4().hex[:8]}@example.com"
    staff_payload = {
        "email": staff_email,
        "full_name": "Support Staff Member",
        "password": "StaffPassword#2026",
    }
    cust_create_staff = await client.post(
        "/api/v1/users/staff",
        json=staff_payload,
        headers=cust_headers,
    )
    assert cust_create_staff.status_code == 403

    # 6. Admin CAN create staff
    admin_create_staff = await client.post(
        "/api/v1/users/staff",
        json=staff_payload,
        headers=admin_headers,
    )
    assert admin_create_staff.status_code == 201
    staff_data = admin_create_staff.json()
    assert staff_data["role"] == "STAFF"
    assert staff_data["email"] == staff_email

    # 7. Staff logs in and tries to create another staff (403 Forbidden)
    staff_login = await client.post(
        "/api/v1/auth/login",
        json={"email": staff_email, "password": "StaffPassword#2026"},
    )
    assert staff_login.status_code == 200
    staff_token = staff_login.json()["access_token"]
    staff_headers = {"Authorization": f"Bearer {staff_token}"}

    staff_create_staff = await client.post(
        "/api/v1/users/staff",
        json={
            "email": f"staff2_{uuid.uuid4().hex[:8]}@example.com",
            "full_name": "Second Staff",
            "password": "StaffPassword#2026",
        },
        headers=staff_headers,
    )
    assert staff_create_staff.status_code == 403

    # 8. Staff CAN view audit logs
    staff_audit_res = await client.get("/api/v1/audit-logs", headers=staff_headers)
    assert staff_audit_res.status_code == 200

    # 9. Customer CANNOT view audit logs (403 Forbidden)
    cust_audit_res = await client.get("/api/v1/audit-logs", headers=cust_headers)
    assert cust_audit_res.status_code == 403

    # 10. Admin can deactivate a customer
    cust_id = cust_reg.json()["user"]["id"]
    deactivate_res = await client.patch(
        f"/api/v1/users/{cust_id}/status",
        json={"is_active": False},
        headers=admin_headers,
    )
    assert deactivate_res.status_code == 200
    assert deactivate_res.json()["is_active"] is False

    # 11. Deactivated customer cannot log in
    cust_login_attempt = await client.post(
        "/api/v1/auth/login",
        json={"email": cust_email, "password": "CustPassword#2026"},
    )
    assert cust_login_attempt.status_code == 403
