import uuid
import pytest
from httpx import AsyncClient
from sqlalchemy import select
from tests.conftest import TestSessionLocal
from app.core.security import create_access_token, hash_password
from app.models.user import User, UserRole


async def get_auth_headers(client: AsyncClient = None):
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
                full_name="Test Staff",
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

        # Customer
        res_cust = await session.execute(select(User).where(User.role == UserRole.CUSTOMER))
        cust = res_cust.scalars().first()
        if not cust:
            cust = User(
                id=uuid.uuid4(),
                email=f"cust_{uuid.uuid4().hex[:6]}@brightloop.com",
                full_name="Test Customer",
                hashed_password=hash_password("Cust#Pass2026"),
                role=UserRole.CUSTOMER,
                is_active=True,
                is_verified=True,
            )
            session.add(cust)
            await session.commit()
            await session.refresh(cust)
        cust_token = create_access_token(user_id=cust.id, role=cust.role.value, email=cust.email)
        cust_headers = {"Authorization": f"Bearer {cust_token}"}

    return admin_headers, staff_headers, cust_headers


@pytest.mark.asyncio
async def test_product_creation_and_variant_management(client: AsyncClient):
    admin_headers, staff_headers, cust_headers = await get_auth_headers(client)

    sku = f"SKU-{uuid.uuid4().hex[:6].upper()}"

    # 1. Negative sales price fails validation (422)
    bad_res = await client.post(
        "/api/v1/products",
        headers=admin_headers,
        json={
            "name": "Invalid Price Product",
            "sku": f"BAD-{sku}",
            "product_type": "SOFTWARE",
            "sales_price": "-10.00",
        },
    )
    assert bad_res.status_code == 422

    # 2. Admin creates a valid product with initial variants
    payload = {
        "name": "Brightloop ERP Cloud",
        "sku": sku,
        "product_type": "SOFTWARE",
        "description": "Enterprise cloud accounting and subscription platform",
        "sales_price": "2000.0000",
        "cost_price": "500.0000",
        "currency": "INR",
        "variants": [
            {
                "variant_name": "Standard Edition",
                "variant_code": "STD",
                "adjustment_type": "FIXED_AMOUNT",
                "adjustment_value": "0.0000",
                "is_active": True,
            },
            {
                "variant_name": "Premium Edition",
                "variant_code": "PREM",
                "adjustment_type": "FIXED_AMOUNT",
                "adjustment_value": "1000.0000",
                "is_active": True,
            },
        ],
    }

    create_res = await client.post("/api/v1/products", headers=admin_headers, json=payload)
    assert create_res.status_code == 201
    prod = create_res.json()
    product_id = prod["id"]
    assert prod["name"] == "Brightloop ERP Cloud"
    assert prod["sku"] == sku
    assert prod["sales_price"] == "2000.0000"
    assert len(prod["variants"]) == 2
    assert len(prod["price_history"]) >= 1

    # 3. Duplicate SKU fails (400)
    dup_res = await client.post("/api/v1/products", headers=admin_headers, json=payload)
    assert dup_res.status_code == 400
    assert "already exists" in dup_res.json()["detail"]

    # 4. Add another variant
    var_res = await client.post(
        f"/api/v1/products/{product_id}/variants",
        headers=admin_headers,
        json={
            "variant_name": "Enterprise Addon",
            "variant_code": "ENT",
            "adjustment_type": "PERCENTAGE",
            "adjustment_value": "25.0000",
            "is_active": True,
        },
    )
    assert var_res.status_code == 201
    assert var_res.json()["variant_code"] == "ENT"

    # 5. Duplicate variant code under same product fails (400)
    dup_var = await client.post(
        f"/api/v1/products/{product_id}/variants",
        headers=admin_headers,
        json={
            "variant_name": "Duplicate ENT",
            "variant_code": "ENT",
            "adjustment_type": "FIXED_AMOUNT",
            "adjustment_value": "100.0000",
        },
    )
    assert dup_var.status_code == 400


@pytest.mark.asyncio
async def test_product_rbac_permissions(client: AsyncClient):
    admin_headers, staff_headers, cust_headers = await get_auth_headers(client)

    sku = f"RBAC-{uuid.uuid4().hex[:6].upper()}"

    # 1. Customer CANNOT list products (403)
    c_list = await client.get("/api/v1/products", headers=cust_headers)
    assert c_list.status_code == 403

    # 2. Staff CAN list products (200)
    s_list = await client.get("/api/v1/products", headers=staff_headers)
    assert s_list.status_code == 200

    # 3. Staff CANNOT create product (403)
    s_create = await client.post(
        "/api/v1/products",
        headers=staff_headers,
        json={
            "name": "Staff Forbidden Product",
            "sku": sku,
            "product_type": "ADDON",
            "sales_price": "500.00",
        },
    )
    assert s_create.status_code == 403

    # 4. Admin CAN create product
    a_create = await client.post(
        "/api/v1/products",
        headers=admin_headers,
        json={
            "name": "Admin Product",
            "sku": sku,
            "product_type": "ADDON",
            "sales_price": "500.00",
        },
    )
    assert a_create.status_code == 201
    product_id = a_create.json()["id"]

    # 5. Staff CANNOT update product (403)
    s_update = await client.put(
        f"/api/v1/products/{product_id}",
        headers=staff_headers,
        json={"name": "Staff Attempted Rename"},
    )
    assert s_update.status_code == 403

    # 6. Staff CANNOT archive product (403)
    s_archive = await client.post(
        f"/api/v1/products/{product_id}/archive",
        headers=staff_headers,
    )
    assert s_archive.status_code == 403


@pytest.mark.asyncio
async def test_product_price_history_and_immutability(client: AsyncClient):
    admin_headers, _, _ = await get_auth_headers(client)

    sku = f"HIST-{uuid.uuid4().hex[:6].upper()}"
    create_res = await client.post(
        "/api/v1/products",
        headers=admin_headers,
        json={
            "name": "History Test Product",
            "sku": sku,
            "product_type": "SOFTWARE",
            "sales_price": "1000.0000",
            "cost_price": "300.0000",
            "variants": [
                {
                    "variant_name": "Pro Pack",
                    "variant_code": "PRO",
                    "adjustment_type": "FIXED_AMOUNT",
                    "adjustment_value": "200.0000",
                }
            ],
        },
    )
    assert create_res.status_code == 201
    prod = create_res.json()
    product_id = prod["id"]
    variant_id = prod["variants"][0]["id"]

    # 1. Update product base sales price and cost price
    update_res = await client.put(
        f"/api/v1/products/{product_id}",
        headers=admin_headers,
        json={
            "sales_price": "1500.0000",
            "cost_price": "450.0000",
            "price_change_reason": "Annual inflation rate increase",
        },
    )
    assert update_res.status_code == 200
    updated_prod = update_res.json()
    assert updated_prod["sales_price"] == "1500.0000"
    assert updated_prod["cost_price"] == "450.0000"

    # Verify immutable price history records
    history_entries = updated_prod["price_history"]
    assert len(history_entries) >= 3  # Initial creation + sales update + cost update
    latest_sales = next(
        h for h in history_entries if h["price_field"] == "sales_price" and h["new_price"] == "1500.0000"
    )
    assert latest_sales["old_price"] == "1000.0000"
    assert latest_sales["reason"] == "Annual inflation rate increase"

    # 2. Update variant price adjustment
    var_update_res = await client.put(
        f"/api/v1/products/{product_id}/variants/{variant_id}",
        headers=admin_headers,
        json={
            "adjustment_type": "PERCENTAGE",
            "adjustment_value": "30.0000",
            "reason": "Switched to percentage based expansion",
        },
    )
    assert var_update_res.status_code == 200
    v_data = var_update_res.json()
    assert v_data["adjustment_type"] == "PERCENTAGE"
    assert v_data["adjustment_value"] == "30.0000"
    assert len(v_data["price_history"]) >= 2
    latest_v_hist = v_data["price_history"][0]
    assert latest_v_hist["old_adjustment_value"] == "200.0000"
    assert latest_v_hist["new_adjustment_value"] == "30.0000"
    assert latest_v_hist["reason"] == "Switched to percentage based expansion"


@pytest.mark.asyncio
async def test_product_archival_soft_guard(client: AsyncClient):
    admin_headers, _, _ = await get_auth_headers(client)

    sku = f"ARCH-{uuid.uuid4().hex[:6].upper()}"
    create_res = await client.post(
        "/api/v1/products",
        headers=admin_headers,
        json={
            "name": "To Archive Product",
            "sku": sku,
            "product_type": "PHYSICAL_PRODUCT",
            "sales_price": "750.0000",
            "variants": [
                {
                    "variant_name": "Variant A",
                    "variant_code": "VA",
                    "adjustment_type": "FIXED_AMOUNT",
                    "adjustment_value": "50.0000",
                }
            ],
        },
    )
    prod = create_res.json()
    product_id = prod["id"]
    variant_id = prod["variants"][0]["id"]

    # Archive product
    archive_res = await client.post(
        f"/api/v1/products/{product_id}/archive",
        headers=admin_headers,
    )
    assert archive_res.status_code == 200
    archived_prod = archive_res.json()
    assert archived_prod["is_archived"] is True
    assert archived_prod["is_active"] is False

    # Archive variant
    v_arch_res = await client.post(
        f"/api/v1/products/{product_id}/variants/{variant_id}/archive",
        headers=admin_headers,
    )
    assert v_arch_res.status_code == 200
    assert v_arch_res.json()["is_active"] is False
