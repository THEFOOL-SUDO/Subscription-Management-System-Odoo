import uuid
from decimal import Decimal
import pytest
from httpx import AsyncClient
from tests.test_customers import get_test_headers


@pytest.mark.asyncio
async def test_demo_payment_full_workflow(client: AsyncClient):
    admin_hdr, staff_hdr, cust_hdr, _, _, _ = await get_test_headers()

    # 1. Create product, plan, customer, and subscription
    prod_res = await client.post(
        "/api/v1/products",
        json={
            "name": f"API Gateway {uuid.uuid4().hex[:4]}",
            "sku": f"GW-{uuid.uuid4().hex[:5]}",
            "product_type": "SOFTWARE",
            "sales_price": "1000.0000",
            "currency": "INR",
        },
        headers=admin_hdr,
    )
    prod_id = prod_res.json()["id"]

    plan_res = await client.post(
        "/api/v1/plans",
        json={
            "code": f"PLAN-GW-{uuid.uuid4().hex[:5]}",
            "name": "Gateway Monthly",
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
        json={"name": "Demo Payments Ltd", "email": f"demo_{uuid.uuid4().hex[:5]}@demopay.com"},
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

    # Transition subscription to CONFIRMED
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
    balance_due = Decimal(str(inv["balance_due"]))
    assert balance_due > Decimal("0")

    # 2. Create demo checkout session
    session_res = await client.post(
        "/api/v1/payments/demo/checkout-session",
        json={"invoice_id": inv_id},
        headers=admin_hdr,
    )
    assert session_res.status_code == 200
    session_data = session_res.json()
    assert "session_token" in session_data
    assert "DEMO MODE" in session_data["demo_disclaimer"]
    session_token = session_data["session_token"]

    # 3. Test Decline Scenario
    decline_res = await client.post(
        "/api/v1/payments/demo/process",
        json={
            "session_token": session_token,
            "payment_method": "DEMO_CARD",
            "scenario": "DECLINE_GENERIC",
            "card_last4": "4242",
        },
        headers=admin_hdr,
    )
    assert decline_res.status_code == 200
    decline_data = decline_res.json()
    assert decline_data["status"] == "FAILED"
    assert "failure_reason" in decline_data["metadata_json"]

    # 4. Test Partial Payment Scenario
    partial_amount = Decimal("500.0000")
    partial_res = await client.post(
        "/api/v1/payments/demo/process",
        json={
            "session_token": session_token,
            "payment_method": "DEMO_UPI",
            "scenario": "SUCCESS_PARTIAL",
            "amount": str(partial_amount),
            "payer_vpa": "testuser@okicici",
        },
        headers=admin_hdr,
    )
    assert partial_res.status_code == 200
    partial_data = partial_res.json()
    assert partial_data["status"] == "SUCCESS"
    assert partial_data["invoice_payment_status"] == "PARTIALLY_PAID"

    # Verify invoice balance decreased
    inv_check = await client.get(f"/api/v1/invoices/{inv_id}", headers=admin_hdr)
    assert Decimal(str(inv_check.json()["amount_paid"])) == partial_amount

    # 5. Test Overpayment Rejection
    overpay_res = await client.post(
        "/api/v1/payments/demo/process",
        json={
            "session_token": session_token,
            "payment_method": "DEMO_UPI",
            "scenario": "SUCCESS_PARTIAL",
            "amount": "999999.0000",
        },
        headers=admin_hdr,
    )
    assert overpay_res.status_code == 400
    assert "Overpayment rejected" in overpay_res.json()["detail"]

    # 6. Test Idempotency with settlement payment
    remaining = Decimal(str(inv_check.json()["balance_due"]))
    idemp_key = f"idemp-{uuid.uuid4().hex}"
    full_res = await client.post(
        "/api/v1/payments/demo/process",
        json={
            "session_token": session_token,
            "payment_method": "DEMO_NETBANKING",
            "scenario": "SUCCESS_FULL",
            "amount": str(remaining),
            "idempotency_key": idemp_key,
            "bank_name": "State Bank of India",
        },
        headers=admin_hdr,
    )
    assert full_res.status_code == 200
    full_data = full_res.json()
    assert full_data["status"] == "SUCCESS"
    assert full_data["invoice_status"] == "PAID"
    assert full_data["invoice_payment_status"] == "PAID"

    # Repeat with same idempotency key -> returns cached result
    idemp_repeat = await client.post(
        "/api/v1/payments/demo/process",
        json={
            "session_token": session_token,
            "payment_method": "DEMO_NETBANKING",
            "scenario": "SUCCESS_FULL",
            "amount": str(remaining),
            "idempotency_key": idemp_key,
        },
        headers=admin_hdr,
    )
    assert idemp_repeat.status_code == 200
    assert idemp_repeat.json()["id"] == full_data["id"]

    # 7. Verify Auto-activation of Subscription
    sub_check = await client.get(f"/api/v1/subscriptions/{sub_id}", headers=admin_hdr)
    assert sub_check.json()["status"] == "ACTIVE"

    # 8. Verify Transaction Ledger Listing
    txn_list_res = await client.get(f"/api/v1/payments/transactions?invoice_id={inv_id}", headers=admin_hdr)
    assert txn_list_res.status_code == 200
    txns = txn_list_res.json()["items"]
    assert len(txns) >= 3
