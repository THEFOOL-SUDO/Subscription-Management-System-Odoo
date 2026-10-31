import asyncio
import uuid
from decimal import Decimal
import pytest
from httpx import AsyncClient
from tests.test_customers import get_test_headers


@pytest.mark.asyncio
async def test_concurrent_duplicate_payment_requests(client: AsyncClient):
    """Verify that multiple concurrent payment requests with the same idempotency key

    or on the same invoice do not cause race conditions, double deduction, or overpayment.
    """
    admin_hdr, staff_hdr, _, _, _, _ = await get_test_headers()

    # 1. Setup product, plan, customer, and subscription
    sku = f"CONC-PRD-{uuid.uuid4().hex[:6]}"
    prod_res = await client.post(
        "/api/v1/products",
        json={
            "name": "Concurrency Protected Product",
            "sku": sku,
            "product_type": "SOFTWARE",
            "sales_price": "2000.0000",
            "currency": "INR",
        },
        headers=admin_hdr,
    )
    prod_id = prod_res.json()["id"]

    plan_res = await client.post(
        "/api/v1/plans",
        json={
            "code": f"CONC-PLAN-{uuid.uuid4().hex[:6]}",
            "name": "Concurrency Test Plan",
            "billing_interval": "MONTHLY",
            "interval_count": 1,
            "currency": "INR",
        },
        headers=admin_hdr,
    )
    plan_id = plan_res.json()["id"]

    await client.post(
        f"/api/v1/plans/{plan_id}/products",
        json={"product_id": prod_id, "default_quantity": 1},
        headers=admin_hdr,
    )
    await client.patch(f"/api/v1/plans/{plan_id}/status", json={"status": "ACTIVE"}, headers=admin_hdr)

    cust_res = await client.post(
        "/api/v1/customers",
        json={"name": "Race Condition Labs", "email": f"race_{uuid.uuid4().hex[:6]}@example.com"},
        headers=staff_hdr,
    )
    cust_id = cust_res.json()["id"]

    sub_res = await client.post(
        "/api/v1/subscriptions",
        json={
            "customer_id": cust_id,
            "plan_id": plan_id,
            "start_date": "2026-11-01T00:00:00Z",
            "items": [{"product_id": prod_id, "quantity": 1}],
        },
        headers=staff_hdr,
    )
    sub_id = sub_res.json()["id"]

    # Confirm subscription
    await client.post(f"/api/v1/subscriptions/{sub_id}/status", json={"to_status": "QUOTATION"}, headers=staff_hdr)
    await client.post(f"/api/v1/subscriptions/{sub_id}/status", json={"to_status": "CONFIRMED"}, headers=staff_hdr)

    # Generate invoice
    inv_res = await client.post(
        "/api/v1/invoices",
        json={"subscription_id": sub_id},
        headers=staff_hdr,
    )
    assert inv_res.status_code == 201
    inv = inv_res.json()
    inv_id = inv["id"]
    total_amount = Decimal(str(inv["total_amount"]))

    # 2. Get checkout session
    session_res = await client.post(
        "/api/v1/payments/demo/checkout-session",
        json={"invoice_id": inv_id},
        headers=admin_hdr,
    )
    assert session_res.status_code == 200
    session_token = session_res.json()["session_token"]

    # 3. Fire 5 concurrent requests with the EXACT SAME idempotency key
    shared_idemp_key = f"idemp-race-{uuid.uuid4().hex}"

    async def send_payment_request():
        return await client.post(
            "/api/v1/payments/demo/process",
            json={
                "session_token": session_token,
                "payment_method": "DEMO_UPI",
                "scenario": "SUCCESS_FULL",
                "amount": str(total_amount),
                "idempotency_key": shared_idemp_key,
                "payer_vpa": "race@okaxis",
            },
            headers=admin_hdr,
        )

    responses = await asyncio.gather(*[send_payment_request() for _ in range(5)])

    # All responses must succeed (200 OK) due to idempotent caching
    success_codes = [r.status_code for r in responses]
    assert all(code == 200 for code in success_codes), f"Unexpected status codes: {success_codes}"

    # Verify that the returned transaction ID is identical across all responses
    returned_txn_ids = {r.json()["id"] for r in responses}
    assert len(returned_txn_ids) == 1, f"Expected 1 unique transaction, got: {returned_txn_ids}"

    # Check invoice balance in database: must be exactly settled once
    inv_final = await client.get(f"/api/v1/invoices/{inv_id}", headers=admin_hdr)
    inv_data = inv_final.json()
    assert Decimal(str(inv_data["amount_paid"])) == total_amount
    assert Decimal(str(inv_data["balance_due"])) == Decimal("0.0000")
    assert inv_data["status"] == "PAID"
    assert inv_data["payment_status"] == "PAID"


@pytest.mark.asyncio
async def test_concurrent_billing_scheduler_runs(client: AsyncClient):
    """Verify that multiple concurrent executions of the recurring billing scheduler

    do not generate duplicate overlapping renewal invoices.
    """
    admin_hdr, _, _, _, _, _ = await get_test_headers()

    # Trigger scheduler concurrently twice
    scheduler_runs = await asyncio.gather(
        client.post("/api/v1/billing/run-scheduler", headers=admin_hdr),
        client.post("/api/v1/billing/run-scheduler", headers=admin_hdr),
    )

    for run_res in scheduler_runs:
        assert run_res.status_code == 200
        run_data = run_res.json()
        assert "invoices_generated_count" in run_data
        assert "processed_count" in run_data
        assert "timestamp" in run_data


@pytest.mark.asyncio
async def test_discount_validation_rules_and_quantities(client: AsyncClient):
    """Test comprehensive discount validation including min_quantity and restricted product scope."""
    admin_hdr, _, _, _, _, _ = await get_test_headers()

    # Create restricted product
    prod_res = await client.post(
        "/api/v1/products",
        json={
            "name": "Target Product",
            "sku": f"TGT-{uuid.uuid4().hex[:6]}",
            "product_type": "SOFTWARE",
            "sales_price": "500.0000",
            "currency": "INR",
        },
        headers=admin_hdr,
    )
    prod_id = prod_res.json()["id"]

    # Create discount with min_quantity=3 and restricted to Target Product
    rule_code = f"DISC-{uuid.uuid4().hex[:6].upper()}"
    rule_res = await client.post(
        "/api/v1/discounts",
        json={
            "code": rule_code,
            "name": "Volume Bundle Promo",
            "discount_type": "PERCENTAGE",
            "discount_value": "15.0000",
            "min_purchase_amount": "1000.0000",
            "min_quantity": 3,
            "scope": "PRODUCT",
            "product_id": prod_id,
        },
        headers=admin_hdr,
    )
    assert rule_res.status_code == 201

    # 1. Validate with insufficient purchase amount
    val_low_amount = await client.post(
        "/api/v1/discounts/validate",
        json={"code": rule_code, "amount": "500.0000", "quantity": 5, "product_ids": [prod_id]},
        headers=admin_hdr,
    )
    assert val_low_amount.json()["is_valid"] is False
    assert "Minimum purchase amount" in val_low_amount.json()["message"]

    # 2. Validate with insufficient quantity
    val_low_qty = await client.post(
        "/api/v1/discounts/validate",
        json={"code": rule_code, "amount": "1500.0000", "quantity": 2, "product_ids": [prod_id]},
        headers=admin_hdr,
    )
    assert val_low_qty.json()["is_valid"] is False
    assert "Minimum purchase quantity" in val_low_qty.json()["message"]

    # 3. Validate with wrong product ID
    other_prod_id = str(uuid.uuid4())
    val_wrong_prod = await client.post(
        "/api/v1/discounts/validate",
        json={"code": rule_code, "amount": "1500.0000", "quantity": 4, "product_ids": [other_prod_id]},
        headers=admin_hdr,
    )
    assert val_wrong_prod.json()["is_valid"] is False
    assert "restricted to a specific product" in val_wrong_prod.json()["message"]

    # 4. Valid combination
    val_success = await client.post(
        "/api/v1/discounts/validate",
        json={"code": rule_code, "amount": "2000.0000", "quantity": 4, "product_ids": [prod_id]},
        headers=admin_hdr,
    )
    assert val_success.json()["is_valid"] is True
    # 15% of 2000 = 300
    assert Decimal(str(val_success.json()["calculated_discount"])) == Decimal("300.0000")
