import datetime
import uuid
from decimal import Decimal
import pytest
from httpx import AsyncClient
from tests.test_customers import get_test_headers


@pytest.mark.asyncio
async def test_subscription_creation_pricing_and_lifecycle(client: AsyncClient):
    admin_hdr, staff_hdr, cust1_hdr, _, _, _ = await get_test_headers()

    # 1. Setup Product and Plan
    sku = f"PROD-SUB-{uuid.uuid4().hex[:5]}"
    prod_res = await client.post(
        "/api/v1/products",
        json={
            "name": "Cloud CRM Platform",
            "sku": sku,
            "product_type": "SOFTWARE",
            "sales_price": "5000.0000",
            "cost_price": "1000.0000",
            "currency": "INR",
        },
        headers=admin_hdr,
    )
    assert prod_res.status_code == 201
    prod_id = prod_res.json()["id"]

    # Plan
    plan_code = f"PLAN-CRM-{uuid.uuid4().hex[:5]}"
    plan_res = await client.post(
        "/api/v1/plans",
        json={
            "code": plan_code,
            "name": "Enterprise CRM Annual",
            "billing_interval": "YEARLY",
            "interval_count": 1,
            "currency": "INR",
            "min_quantity": 1,
            "max_quantity": 10,
        },
        headers=admin_hdr,
    )
    assert plan_res.status_code == 201
    plan_id = plan_res.json()["id"]

    # Add product to plan
    add_item_res = await client.post(
        f"/api/v1/plans/{plan_id}/products",
        json={"product_id": prod_id, "default_quantity": 2, "price_override": "4500.0000"},
        headers=admin_hdr,
    )
    assert add_item_res.status_code == 201

    # Activate Plan
    act_res = await client.patch(f"/api/v1/plans/{plan_id}/status", json={"status": "ACTIVE"}, headers=admin_hdr)
    assert act_res.status_code == 200

    # 2. Create Customer
    cust_res = await client.post(
        "/api/v1/customers",
        json={"name": "Tata Tech", "email": f"tata_{uuid.uuid4().hex[:5]}@tatatech.com"},
        headers=staff_hdr,
    )
    assert cust_res.status_code == 201
    customer_id = cust_res.json()["id"]

    # 3. Create Subscription in DRAFT
    start_date = datetime.datetime.now(datetime.timezone.utc).isoformat()
    sub_res = await client.post(
        "/api/v1/subscriptions",
        json={
            "customer_id": customer_id,
            "plan_id": plan_id,
            "start_date": start_date,
            "tax_rate": "18.0000",
            "discount_amount": "500.0000",
            "notes": "Annual enterprise contract",
        },
        headers=staff_hdr,
    )
    assert sub_res.status_code == 201, sub_res.text
    sub = sub_res.json()
    assert sub["status"] == "DRAFT"
    assert sub["subscription_number"].startswith("SUB-")
    # subtotal = 4500 * 2 = 9000
    # taxable = 9000 - 500 = 8500
    # tax 18% = 1530
    # total = 8500 + 1530 = 10030
    assert Decimal(sub["subtotal"]) == Decimal("9000.0000")
    assert Decimal(sub["discount_amount"]) == Decimal("500.0000")
    assert Decimal(sub["tax_amount"]) == Decimal("1530.0000")
    assert Decimal(sub["total_amount"]) == Decimal("10030.0000")
    sub_id = sub["id"]

    # 4. Lifecycle state machine: DRAFT -> QUOTATION
    quote_res = await client.post(
        f"/api/v1/subscriptions/{sub_id}/status",
        json={"to_status": "QUOTATION", "reason": "Sent quote to client"},
        headers=staff_hdr,
    )
    assert quote_res.status_code == 200
    assert quote_res.json()["status"] == "QUOTATION"

    # QUOTATION -> CONFIRMED
    confirm_res = await client.post(
        f"/api/v1/subscriptions/{sub_id}/status",
        json={"to_status": "CONFIRMED", "reason": "Client signed contract"},
        headers=staff_hdr,
    )
    assert confirm_res.status_code == 200
    assert confirm_res.json()["status"] == "CONFIRMED"

    # Illegal Transition: Cannot jump from CONFIRMED back to DRAFT directly
    illegal_res = await client.post(
        f"/api/v1/subscriptions/{sub_id}/status",
        json={"to_status": "DRAFT"},
        headers=staff_hdr,
    )
    assert illegal_res.status_code == 400
    assert "invalid lifecycle transition" in illegal_res.json()["detail"].lower()

    # Customer forbidden from transitioning status
    cust_mod_res = await client.post(
        f"/api/v1/subscriptions/{sub_id}/status",
        json={"to_status": "ACTIVE"},
        headers=cust1_hdr,
    )
    assert cust_mod_res.status_code == 403
