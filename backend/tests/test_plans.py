import datetime
import uuid
import pytest
from httpx import AsyncClient
from tests.test_products import get_auth_headers


@pytest.mark.asyncio
async def test_plan_creation_and_currency_homogeneity(client: AsyncClient):
    admin_headers, staff_headers, cust_headers = await get_auth_headers(client)

    # 1. Customer cannot create or view plans
    cust_res = await client.get("/api/v1/plans", headers=cust_headers)
    assert cust_res.status_code == 403

    # 2. Create products with INR and USD
    inr_sku = f"INR-{uuid.uuid4().hex[:6].upper()}"
    p_inr = await client.post(
        "/api/v1/products",
        headers=admin_headers,
        json={
            "name": "INR Service",
            "sku": inr_sku,
            "product_type": "SOFTWARE",
            "sales_price": "1000.0000",
            "currency": "INR",
        },
    )
    inr_product_id = p_inr.json()["id"]

    usd_sku = f"USD-{uuid.uuid4().hex[:6].upper()}"
    p_usd = await client.post(
        "/api/v1/products",
        headers=admin_headers,
        json={
            "name": "USD Service",
            "sku": usd_sku,
            "product_type": "SOFTWARE",
            "sales_price": "50.0000",
            "currency": "USD",
        },
    )
    usd_product_id = p_usd.json()["id"]

    # 3. Create INR Subscription Plan
    plan_code = f"PLAN-INR-{uuid.uuid4().hex[:6].upper()}"
    create_plan_res = await client.post(
        "/api/v1/plans",
        headers=admin_headers,
        json={
            "code": plan_code,
            "name": "Enterprise INR Plan",
            "billing_interval": "MONTHLY",
            "interval_count": 1,
            "currency": "INR",
            "min_quantity": 1,
        },
    )
    assert create_plan_res.status_code == 201
    plan = create_plan_res.json()
    plan_id = plan["id"]
    assert plan["status"] == "DRAFT"

    # 4. Attempt to bundle USD product into INR plan -> FAILS (400)
    mismatch_res = await client.post(
        f"/api/v1/plans/{plan_id}/products",
        headers=admin_headers,
        json={
            "product_id": usd_product_id,
            "default_quantity": 1,
        },
    )
    assert mismatch_res.status_code == 400
    assert "currency" in mismatch_res.json()["detail"].lower()

    # 5. Bundle INR product into INR plan -> SUCCEEDS (201)
    bundle_res = await client.post(
        f"/api/v1/plans/{plan_id}/products",
        headers=admin_headers,
        json={
            "product_id": inr_product_id,
            "default_quantity": 2,
        },
    )
    assert bundle_res.status_code == 201
    assert bundle_res.json()["default_quantity"] == 2


@pytest.mark.asyncio
async def test_plan_lifecycle_and_activation_guard(client: AsyncClient):
    admin_headers, _, _ = await get_auth_headers(client)

    plan_code = f"GUARD-{uuid.uuid4().hex[:6].upper()}"
    plan_res = await client.post(
        "/api/v1/plans",
        headers=admin_headers,
        json={
            "code": plan_code,
            "name": "Empty Draft Plan",
            "billing_interval": "YEARLY",
            "interval_count": 1,
            "currency": "INR",
        },
    )
    plan = plan_res.json()
    plan_id = plan["id"]
    assert plan["status"] == "DRAFT"

    # 1. Attempt to activate empty plan -> FAILS (400)
    act_res = await client.patch(
        f"/api/v1/plans/{plan_id}/status",
        headers=admin_headers,
        json={"status": "ACTIVE"},
    )
    assert act_res.status_code == 400
    assert "at least one active bundled product" in act_res.json()["detail"]

    # 2. Add product
    prod_res = await client.post(
        "/api/v1/products",
        headers=admin_headers,
        json={
            "name": "Base Software",
            "sku": f"BASE-{uuid.uuid4().hex[:6].upper()}",
            "product_type": "SOFTWARE",
            "sales_price": "3000.0000",
            "currency": "INR",
        },
    )
    product_id = prod_res.json()["id"]

    await client.post(
        f"/api/v1/plans/{plan_id}/products",
        headers=admin_headers,
        json={"product_id": product_id, "default_quantity": 1},
    )

    # 3. Now activate -> SUCCEEDS (200)
    act_ok = await client.patch(
        f"/api/v1/plans/{plan_id}/status",
        headers=admin_headers,
        json={"status": "ACTIVE"},
    )
    assert act_ok.status_code == 200
    assert act_ok.json()["status"] == "ACTIVE"

    # 4. Transition ACTIVE -> INACTIVE
    inact = await client.patch(
        f"/api/v1/plans/{plan_id}/status",
        headers=admin_headers,
        json={"status": "INACTIVE"},
    )
    assert inact.status_code == 200
    assert inact.json()["status"] == "INACTIVE"

    # 5. Transition INACTIVE -> ARCHIVED
    arch = await client.patch(
        f"/api/v1/plans/{plan_id}/status",
        headers=admin_headers,
        json={"status": "ARCHIVED"},
    )
    assert arch.status_code == 200
    assert arch.json()["status"] == "ARCHIVED"

    # 6. Editing archived plan fails (400)
    edit_arch = await client.put(
        f"/api/v1/plans/{plan_id}",
        headers=admin_headers,
        json={"name": "New Name For Archived"},
    )
    assert edit_arch.status_code == 400


@pytest.mark.asyncio
async def test_plan_auto_close_mechanism(client: AsyncClient):
    admin_headers, _, _ = await get_auth_headers(client)

    # Product
    p_res = await client.post(
        "/api/v1/products",
        headers=admin_headers,
        json={
            "name": "Auto Close Product",
            "sku": f"AC-{uuid.uuid4().hex[:6].upper()}",
            "product_type": "SOFTWARE",
            "sales_price": "1500.0000",
            "currency": "INR",
        },
    )
    product_id = p_res.json()["id"]

    # Plan with availability_end_date in the past
    past_date = (
        datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(hours=2)
    ).isoformat()
    plan_code = f"AUTO-{uuid.uuid4().hex[:6].upper()}"

    plan_res = await client.post(
        "/api/v1/plans",
        headers=admin_headers,
        json={
            "code": plan_code,
            "name": "Limited Time Plan",
            "billing_interval": "MONTHLY",
            "currency": "INR",
            "is_auto_close": True,
            "availability_end_date": past_date,
            "bundled_products": [
                {
                    "product_id": product_id,
                    "default_quantity": 1,
                }
            ],
        },
    )
    assert plan_res.status_code == 201
    plan = plan_res.json()
    plan_id = plan["id"]

    # Activate the plan
    act_res = await client.patch(
        f"/api/v1/plans/{plan_id}/status",
        headers=admin_headers,
        json={"status": "ACTIVE"},
    )
    assert act_res.status_code == 200
    # Because past_date is in the past, _check_auto_close transitions it automatically to ARCHIVED
    assert act_res.json()["status"] == "ARCHIVED"

    # Querying the plan directly confirms ARCHIVED status
    get_res = await client.get(f"/api/v1/plans/{plan_id}", headers=admin_headers)
    assert get_res.status_code == 200
    assert get_res.json()["status"] == "ARCHIVED"


@pytest.mark.asyncio
async def test_bundled_product_management_and_price_override(client: AsyncClient):
    admin_headers, _, _ = await get_auth_headers(client)

    # Create Product with Variant
    prod_res = await client.post(
        "/api/v1/products",
        headers=admin_headers,
        json={
            "name": "CRM Software",
            "sku": f"CRM-{uuid.uuid4().hex[:6].upper()}",
            "product_type": "SOFTWARE",
            "sales_price": "2000.0000",
            "currency": "INR",
            "variants": [
                {
                    "variant_name": "Premium Support",
                    "variant_code": "SUP",
                    "adjustment_type": "FIXED_AMOUNT",
                    "adjustment_value": "500.0000",
                }
            ],
        },
    )
    prod = prod_res.json()
    product_id = prod["id"]
    variant_id = prod["variants"][0]["id"]

    # Create Plan
    plan_res = await client.post(
        "/api/v1/plans",
        headers=admin_headers,
        json={
            "code": f"CRM-PLAN-{uuid.uuid4().hex[:6].upper()}",
            "name": "CRM Standard Plan",
            "billing_interval": "MONTHLY",
            "currency": "INR",
        },
    )
    plan_id = plan_res.json()["id"]

    # Add line item with price override
    item_res = await client.post(
        f"/api/v1/plans/{plan_id}/products",
        headers=admin_headers,
        json={
            "product_id": product_id,
            "variant_id": variant_id,
            "default_quantity": 3,
            "price_override": "2200.0000",
        },
    )
    assert item_res.status_code == 201
    item = item_res.json()
    item_id = item["id"]
    assert item["price_override"] == "2200.0000"

    # Check Plan Total: 2200 * 3 = 6600
    plan_get = await client.get(f"/api/v1/plans/{plan_id}", headers=admin_headers)
    assert plan_get.json()["calculated_total_price"] == "6600.0000"

    # Update line item: change quantity to 5
    up_item = await client.put(
        f"/api/v1/plans/{plan_id}/products/{item_id}",
        headers=admin_headers,
        json={"default_quantity": 5},
    )
    assert up_item.status_code == 200
    assert up_item.json()["default_quantity"] == 5

    # Check Plan Total: 2200 * 5 = 11000
    plan_get2 = await client.get(f"/api/v1/plans/{plan_id}", headers=admin_headers)
    assert plan_get2.json()["calculated_total_price"] == "11000.0000"

    # Delete line item
    del_res = await client.delete(
        f"/api/v1/plans/{plan_id}/products/{item_id}",
        headers=admin_headers,
    )
    assert del_res.status_code == 200
    assert del_res.json()["success"] is True

    # Check Plan Total: 0
    plan_get3 = await client.get(f"/api/v1/plans/{plan_id}", headers=admin_headers)
    assert plan_get3.json()["calculated_total_price"] == "0.0000"

