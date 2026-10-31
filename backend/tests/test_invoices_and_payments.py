import datetime
import uuid
from decimal import Decimal
import pytest
from httpx import AsyncClient
from tests.test_customers import get_test_headers


@pytest.mark.asyncio
async def test_invoice_creation_partial_payment_and_auto_activation(client: AsyncClient):
    admin_hdr, staff_hdr, _, _, _, _ = await get_test_headers()

    # 1. Setup Product & Plan & Customer
    prod_res = await client.post(
        "/api/v1/products",
        json={
            "name": "Cloud Security Suite",
            "sku": f"SEC-{uuid.uuid4().hex[:5]}",
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
            "code": f"PLAN-SEC-{uuid.uuid4().hex[:5]}",
            "name": "Security Pro Monthly",
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
        json={"name": "Infosys Corp", "email": f"billing_{uuid.uuid4().hex[:5]}@infosys.com"},
        headers=staff_hdr,
    )
    cust_id = cust_res.json()["id"]

    # 2. Create and Confirm Subscription
    start_dt = datetime.datetime.now(datetime.timezone.utc)
    sub_res = await client.post(
        "/api/v1/subscriptions",
        json={
            "customer_id": cust_id,
            "plan_id": plan_id,
            "start_date": start_dt.isoformat(),
            "tax_rate": "18.0000",
            "discount_amount": "0.0000",
        },
        headers=staff_hdr,
    )
    sub_id = sub_res.json()["id"]

    # Move to QUOTATION -> CONFIRMED
    await client.post(f"/api/v1/subscriptions/{sub_id}/status", json={"to_status": "QUOTATION"}, headers=staff_hdr)
    await client.post(f"/api/v1/subscriptions/{sub_id}/status", json={"to_status": "CONFIRMED"}, headers=staff_hdr)

    # 3. Generate Invoice
    inv_res = await client.post(
        "/api/v1/invoices",
        json={"subscription_id": sub_id},
        headers=staff_hdr,
    )
    assert inv_res.status_code == 201, inv_res.text
    inv = inv_res.json()
    assert inv["invoice_number"].startswith("INV-")
    assert inv["status"] == "CONFIRMED"
    assert inv["payment_status"] == "UNPAID"
    # subtotal = 2000, tax 18% = 360, total = 2360
    assert Decimal(inv["total_amount"]) == Decimal("2360.0000")
    assert Decimal(inv["balance_due"]) == Decimal("2360.0000")
    assert Decimal(inv["amount_paid"]) == Decimal("0.0000")
    inv_id = inv["id"]

    # 4. Prevent duplicate invoice for overlapping billing period
    dup_inv_res = await client.post(
        "/api/v1/invoices",
        json={"subscription_id": sub_id},
        headers=staff_hdr,
    )
    assert dup_inv_res.status_code == 400
    assert "already exists" in dup_inv_res.json()["detail"].lower()

    # 5. Overpayment guard: paying 3000 against balance 2360 rejected
    overpay_res = await client.post(
        "/api/v1/payments",
        json={
            "invoice_id": inv_id,
            "amount": "3000.0000",
            "payment_method": "BANK_TRANSFER",
            "reference_number": "TXN-9999",
        },
        headers=staff_hdr,
    )
    assert overpay_res.status_code == 400
    assert "overpayment rejected" in overpay_res.json()["detail"].lower()

    # 6. Negative or Zero amount rejected
    neg_res = await client.post(
        "/api/v1/payments",
        json={
            "invoice_id": inv_id,
            "amount": "-100.0000",
            "payment_method": "UPI",
        },
        headers=staff_hdr,
    )
    assert neg_res.status_code == 422  # pydantic validation gt 0

    # 7. Record Partial Payment: 1000.0000
    part_res = await client.post(
        "/api/v1/payments",
        json={
            "invoice_id": inv_id,
            "amount": "1000.0000",
            "payment_method": "UPI",
            "reference_number": "UPI-PART-1",
        },
        headers=staff_hdr,
    )
    assert part_res.status_code == 201
    pay1 = part_res.json()
    assert pay1["payment_number"].startswith("PAY-")
    assert Decimal(pay1["amount"]) == Decimal("1000.0000")

    # Verify invoice status is still CONFIRMED, but payment_status is PARTIALLY_PAID
    inv_check = await client.get(f"/api/v1/invoices/{inv_id}", headers=staff_hdr)
    inv_data = inv_check.json()
    assert inv_data["status"] == "CONFIRMED"
    assert inv_data["payment_status"] == "PARTIALLY_PAID"
    assert Decimal(inv_data["amount_paid"]) == Decimal("1000.0000")
    assert Decimal(inv_data["balance_due"]) == Decimal("1360.0000")

    # Subscription is still CONFIRMED
    sub_check1 = await client.get(f"/api/v1/subscriptions/{sub_id}", headers=staff_hdr)
    assert sub_check1.json()["status"] == "CONFIRMED"

    # 8. Record Final Payment: 1360.0000
    final_res = await client.post(
        "/api/v1/payments",
        json={
            "invoice_id": inv_id,
            "amount": "1360.0000",
            "payment_method": "BANK_TRANSFER",
            "reference_number": "NEFT-FINAL-2",
        },
        headers=staff_hdr,
    )
    assert final_res.status_code == 201

    # Invoice is now fully PAID
    inv_paid_check = await client.get(f"/api/v1/invoices/{inv_id}", headers=staff_hdr)
    inv_paid_data = inv_paid_check.json()
    assert inv_paid_data["status"] == "PAID"
    assert inv_paid_data["payment_status"] == "PAID"
    assert Decimal(inv_paid_data["amount_paid"]) == Decimal("2360.0000")
    assert Decimal(inv_paid_data["balance_due"]) == Decimal("0.0000")

    # Lifecycle Hook: Subscription auto-transitioned from CONFIRMED -> ACTIVE!
    sub_check2 = await client.get(f"/api/v1/subscriptions/{sub_id}", headers=staff_hdr)
    assert sub_check2.json()["status"] == "ACTIVE"
