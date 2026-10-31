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
    admin_data = admin_login.json()
    admin_id = admin_data["user"]["id"]
    admin_token = admin_data["access_token"]
    admin_headers = {"Authorization": f"Bearer {admin_token}"}

    # 2. Register two customers
    cust1_email = f"cust1_{uuid.uuid4().hex[:8]}@example.com"
    cust1_reg = await client.post(
        "/api/v1/auth/register",
        json={"email": cust1_email, "full_name": "Customer One", "password": "CustPassword#2026"},
    )
    assert cust1_reg.status_code == 201
    cust1_id = cust1_reg.json()["user"]["id"]
    cust1_token = cust1_reg.json()["access_token"]
    cust1_headers = {"Authorization": f"Bearer {cust1_token}"}

    cust2_email = f"cust2_{uuid.uuid4().hex[:8]}@example.com"
    cust2_reg = await client.post(
        "/api/v1/auth/register",
        json={"email": cust2_email, "full_name": "Customer Two", "password": "CustPassword#2026"},
    )
    assert cust2_reg.status_code == 201
    cust2_id = cust2_reg.json()["user"]["id"]

    # 3. Customer CANNOT list users (403 Forbidden)
    cust_list_res = await client.get("/api/v1/users", headers=cust1_headers)
    assert cust_list_res.status_code == 403

    # 4. Customer CANNOT view other customer's details (403 Forbidden)
    cust_view_other = await client.get(f"/api/v1/users/{cust2_id}", headers=cust1_headers)
    assert cust_view_other.status_code == 403

    # 5. Customer CAN view own details (200 OK)
    cust_view_self = await client.get(f"/api/v1/users/{cust1_id}", headers=cust1_headers)
    assert cust_view_self.status_code == 200
    assert cust_view_self.json()["email"] == cust1_email

    # 6. Admin CAN list users (200 OK)
    admin_list_res = await client.get("/api/v1/users", headers=admin_headers)
    assert admin_list_res.status_code == 200
    assert admin_list_res.json()["total"] >= 2

    # 7. Customer CANNOT create staff (403 Forbidden)
    staff_email = f"staff_{uuid.uuid4().hex[:8]}@example.com"
    staff_payload = {
        "email": staff_email,
        "full_name": "Support Staff Member",
        "password": "StaffPassword#2026",
    }
    cust_create_staff = await client.post(
        "/api/v1/users/staff",
        json=staff_payload,
        headers=cust1_headers,
    )
    assert cust_create_staff.status_code == 403

    # 8. Admin CAN create staff (201 Created)
    admin_create_staff = await client.post(
        "/api/v1/users/staff",
        json=staff_payload,
        headers=admin_headers,
    )
    assert admin_create_staff.status_code == 201
    staff_data = admin_create_staff.json()
    assert staff_data["role"] == "STAFF"
    assert staff_data["email"] == staff_email

    # 9. Staff logs in
    staff_login = await client.post(
        "/api/v1/auth/login",
        json={"email": staff_email, "password": "StaffPassword#2026"},
    )
    assert staff_login.status_code == 200
    staff_token = staff_login.json()["access_token"]
    staff_headers = {"Authorization": f"Bearer {staff_token}"}

    # 10. Staff CAN list customers
    staff_list_res = await client.get("/api/v1/users", headers=staff_headers)
    assert staff_list_res.status_code == 200
    # Every item returned to staff MUST be CUSTOMER
    for u in staff_list_res.json()["items"]:
        assert u["role"] == "CUSTOMER"

    # 11. Staff trying to query with ?role=ADMIN still only gets CUSTOMER accounts
    staff_filtered_res = await client.get("/api/v1/users?role=ADMIN", headers=staff_headers)
    assert staff_filtered_res.status_code == 200
    for u in staff_filtered_res.json()["items"]:
        assert u["role"] == "CUSTOMER"

    # 12. Staff CANNOT inspect Admin user profile (403 Forbidden)
    staff_view_admin = await client.get(f"/api/v1/users/{admin_id}", headers=staff_headers)
    assert staff_view_admin.status_code == 403
    assert "Staff cannot inspect administrative" in staff_view_admin.json()["detail"]

    # 13. Staff CAN inspect Customer user profile (200 OK)
    staff_view_cust = await client.get(f"/api/v1/users/{cust1_id}", headers=staff_headers)
    assert staff_view_cust.status_code == 200
    assert staff_view_cust.json()["id"] == cust1_id

    # 14. Staff cannot create another staff (403 Forbidden)
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

    # 15. Staff CAN view audit logs
    staff_audit_res = await client.get("/api/v1/audit-logs", headers=staff_headers)
    assert staff_audit_res.status_code == 200

    # 16. Customer CANNOT view audit logs (403 Forbidden)
    cust_audit_res = await client.get("/api/v1/audit-logs", headers=cust1_headers)
    assert cust_audit_res.status_code == 403

    # 17. Admin can deactivate a customer
    deactivate_res = await client.patch(
        f"/api/v1/users/{cust1_id}/status",
        json={"is_active": False},
        headers=admin_headers,
    )
    assert deactivate_res.status_code == 200
    assert deactivate_res.json()["is_active"] is False

    # 18. Deactivated customer cannot log in
    cust_login_attempt = await client.post(
        "/api/v1/auth/login",
        json={"email": cust1_email, "password": "CustPassword#2026"},
    )
    assert cust_login_attempt.status_code == 403

    # 19. Admin cannot deactivate their own account
    admin_self_deact = await client.patch(
        f"/api/v1/users/{admin_id}/status",
        json={"is_active": False},
        headers=admin_headers,
    )
    assert admin_self_deact.status_code == 400
    assert "Administrators cannot deactivate their own" in admin_self_deact.json()["detail"]
