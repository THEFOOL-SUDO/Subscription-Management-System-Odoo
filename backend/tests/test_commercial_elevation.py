import datetime
import uuid
from decimal import Decimal
import pytest
from httpx import AsyncClient
from tests.test_customers import get_test_headers


@pytest.mark.asyncio
async def test_commercial_elevation_suite(client: AsyncClient):
    admin_hdr, staff_hdr, cust_hdr, _, _, _ = await get_test_headers()

    # ========================================================
    # 1. Tax Rules Test
    # ========================================================
    tax_res = await client.post(
        "/api/v1/taxes",
        json={
            "name": f"GST 18% {uuid.uuid4().hex[:4]}",
            "tax_rate": "18.0000",
            "country": "IND",
            "state": "Karnataka",
            "is_default": True,
            "is_active": True,
        },
        headers=admin_hdr,
    )
    assert tax_res.status_code == 201
    tax_id = tax_res.json()["id"]

    list_taxes = await client.get("/api/v1/taxes", headers=admin_hdr)
    assert list_taxes.status_code == 200
    assert any(t["id"] == tax_id for t in list_taxes.json()["items"])

    # ========================================================
    # 2. Discount Rules & Validation Engine Test
    # ========================================================
    promo_code = f"LAUNCH{uuid.uuid4().hex[:4].upper()}"
    disc_res = await client.post(
        "/api/v1/discounts",
        json={
            "code": promo_code,
            "name": "Launch Special 20%",
            "discount_type": "PERCENTAGE",
            "discount_value": "20.0000",
            "min_purchase_amount": "500.0000",
            "max_uses": 100,
            "scope": "SUBSCRIPTION",
            "is_active": True,
        },
        headers=admin_hdr,
    )
    assert disc_res.status_code == 201
    disc_id = disc_res.json()["id"]

    # Validate valid code
    val_res = await client.post(
        "/api/v1/discounts/validate",
        json={"code": promo_code, "amount": "1000.0000"},
        headers=admin_hdr,
    )
    assert val_res.status_code == 200
    val_data = val_res.json()
    assert val_data["is_valid"] is True
    assert Decimal(str(val_data["calculated_discount"])) == Decimal("200.0000")

    # Validate below minimum purchase
    val_fail = await client.post(
        "/api/v1/discounts/validate",
        json={"code": promo_code, "amount": "100.0000"},
        headers=admin_hdr,
    )
    assert val_fail.status_code == 200
    assert val_fail.json()["is_valid"] is False

    # ========================================================
    # 3. Quotation Templates & Conversion Test
    # ========================================================
    prod_res = await client.post(
        "/api/v1/products",
        json={
            "name": f"Analytics Pro {uuid.uuid4().hex[:4]}",
            "sku": f"ANL-{uuid.uuid4().hex[:5]}",
            "product_type": "SOFTWARE",
            "sales_price": "2500.0000",
            "currency": "INR",
        },
        headers=admin_hdr,
    )
    prod_id = prod_res.json()["id"]

    plan_res = await client.post(
        "/api/v1/plans",
        json={
            "code": f"PLAN-ANL-{uuid.uuid4().hex[:5]}",
            "name": "Analytics Monthly",
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
        json={"name": "Tata Consultancy Services", "email": f"tcs_{uuid.uuid4().hex[:5]}@tcs.com"},
        headers=staff_hdr,
    )
    cust_id = cust_res.json()["id"]

    template_code = f"QT-{uuid.uuid4().hex[:5].upper()}"
    quote_res = await client.post(
        "/api/v1/quotation-templates",
        json={
            "code": template_code,
            "name": "Enterprise Analytics Quotation",
            "description": "Standard quotation template for enterprise accounts",
            "plan_id": plan_id,
            "validity_days": 45,
            "payment_terms": "NET_30",
            "tax_rate": "18.0000",
            "discount_amount": "500.0000",
            "items": [
                {
                    "product_id": prod_id,
                    "quantity": 2,
                    "unit_price": "2500.0000",
                    "notes": "2 user seats included",
                }
            ],
        },
        headers=staff_hdr,
    )
    assert quote_res.status_code == 201
    template_id = quote_res.json()["id"]

    # Convert Quotation Template directly to Subscription
    conv_res = await client.post(
        f"/api/v1/quotation-templates/{template_id}/convert-to-subscription",
        json={
            "customer_id": cust_id,
            "start_date": "2026-11-01T00:00:00Z",
            "notes": "Converted during demo onboarding",
        },
        headers=staff_hdr,
    )
    assert conv_res.status_code == 201
    sub = conv_res.json()
    sub_id = sub["id"]
    assert sub["status"] == "QUOTATION"
    assert Decimal(str(sub["subtotal"])) == Decimal("5000.0000")  # 2 * 2500
    assert Decimal(str(sub["discount_amount"])) == Decimal("500.0000")
    # Taxable: 4500, Tax 18% = 810, Total = 5310
    assert Decimal(str(sub["total_amount"])) == Decimal("5310.0000")

    # ========================================================
    # 4. Extended Lifecycle Controls (Pause, Resume, Renew, Close)
    # ========================================================
    # Transition to CONFIRMED -> ACTIVE
    await client.post(f"/api/v1/subscriptions/{sub_id}/status", json={"to_status": "CONFIRMED"}, headers=staff_hdr)
    await client.post(f"/api/v1/subscriptions/{sub_id}/status", json={"to_status": "ACTIVE"}, headers=staff_hdr)

    # A. Pause Subscription
    pause_res = await client.post(
        f"/api/v1/subscriptions/{sub_id}/pause",
        json={"reason": "Customer seasonal freeze request"},
        headers=staff_hdr,
    )
    assert pause_res.status_code == 200
    assert pause_res.json()["status"] == "PAUSED"
    assert pause_res.json()["paused_at"] is not None

    # B. Resume Subscription
    resume_res = await client.post(
        f"/api/v1/subscriptions/{sub_id}/resume",
        headers=staff_hdr,
    )
    assert resume_res.status_code == 200
    assert resume_res.json()["status"] == "ACTIVE"
    assert resume_res.json()["paused_at"] is None

    # C. Renew Subscription
    renew_res = await client.post(
        f"/api/v1/subscriptions/{sub_id}/renew",
        headers=staff_hdr,
    )
    assert renew_res.status_code == 200
    assert renew_res.json()["status"] == "ACTIVE"
    assert renew_res.json()["expiry_date"] is not None

    # ========================================================
    # 5. Billing Scheduler Execution & HTML Emailing Test
    # ========================================================
    # Trigger scheduler
    sched_res = await client.post("/api/v1/billing/run-scheduler", headers=admin_hdr)
    assert sched_res.status_code == 200
    sched_data = sched_res.json()
    assert "processed_count" in sched_data
    assert "invoices_generated_count" in sched_data

    # Generate an invoice for this subscription
    inv_res = await client.post(
        "/api/v1/invoices",
        json={"subscription_id": sub_id},
        headers=staff_hdr,
    )
    assert inv_res.status_code == 201
    inv_id = inv_res.json()["id"]

    # Manual invoice email dispatch to Mailpit
    email_res = await client.post(
        f"/api/v1/invoices/{inv_id}/send-email",
        headers=staff_hdr,
    )
    assert email_res.status_code == 200
    assert email_res.json()["success"] is True
    assert "tcs.com" in email_res.json()["recipient"]

    # D. Early Close Subscription
    close_res = await client.post(
        f"/api/v1/subscriptions/{sub_id}/close",
        json={"reason": "Customer contract mutual termination"},
        headers=staff_hdr,
    )
    assert close_res.status_code == 200
    assert close_res.json()["status"] == "CLOSED"
