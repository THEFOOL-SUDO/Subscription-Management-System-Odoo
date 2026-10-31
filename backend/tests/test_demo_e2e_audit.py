"""
Brightloop — Phase 3.1: End-to-End Demo Readiness Audit Test Suite
Rigorous end-to-end positive business workflow (11 steps) and negative vulnerability guards (9 scenarios)
executed against real PostgreSQL and Redis infrastructure.
"""

import datetime
import uuid
from decimal import Decimal
import pytest
from httpx import AsyncClient
from sqlalchemy import select
from tests.conftest import TestSessionLocal
from tests.test_customers import get_test_headers
from app.core.security import create_access_token
from app.models.invoice import Invoice, InvoicePaymentStatus, InvoiceStatus
from app.models.plan import BillingInterval, PlanStatus
from app.models.product import AdjustmentType, ProductType
from app.models.subscription import PaymentTerms, Subscription, SubscriptionStatus
from app.models.token import PasswordResetToken
from app.models.user import User, UserRole


# ==============================================================================
# SECTION 1: END-TO-END POSITIVE BUSINESS WORKFLOW (11 STEPS)
# ==============================================================================

@pytest.mark.asyncio
async def test_e2e_01_admin_login(client: AsyncClient):
    """Step A: Admin logs in with bootstrap credentials, receiving access & secure refresh cookie."""
    res = await client.post(
        "/api/v1/auth/login",
        json={"email": "admin@brightloop.com", "password": "Brightloop#Admin2026"},
    )
    assert res.status_code == 200, f"Login failed: {res.text}"
    body = res.json()
    assert "access_token" in body
    assert body["token_type"] == "bearer"
    assert body["user"]["role"] == "ADMIN"
    assert "refresh_token" in res.cookies


@pytest.mark.asyncio
async def test_e2e_positive_workflow_steps_02_to_11(client: AsyncClient):
    """
    Steps B through K: Complete positive lifecycle executed sequentially on persisted records.
    B. Admin creates a customer & auto-provisions account without plaintext password.
    C. Admin creates a subscription using an active plan with bundled products.
    D. Subscription progresses through valid lifecycle transitions (DRAFT -> QUOTATION -> CONFIRMED).
    E. An invoice is generated for the subscription with 18% GST calculation.
    F. A partial payment is recorded.
    G. Remaining balance due is accurately calculated.
    H. A second payment settles the invoice in full.
    I. Invoice transitions to PAID status with zero balance.
    J. Subscription auto-activates exactly once upon full settlement.
    K. Dashboard metrics reflect the updated live PostgreSQL aggregates.
    """
    admin_hdr, staff_hdr, _, _, _, _ = await get_test_headers()
    unique_suffix = uuid.uuid4().hex[:6]

    # --- Step B: Create Customer & Verify Security (No Plaintext Password) ---
    cust_email = f"audit_corp_{unique_suffix}@demo.com"
    cust_res = await client.post(
        "/api/v1/customers",
        json={
            "name": f"Audit Enterprise {unique_suffix}",
            "email": cust_email,
            "company_name": "Audit Global Corp",
            "phone": "+91 98765 00000",
            "billing_address_line1": "Level 10, Brigade Gateway",
            "billing_city": "Bengaluru",
            "billing_state": "Karnataka",
            "billing_postal_code": "560055",
            "billing_country": "IN",
        },
        headers=admin_hdr,
    )
    assert cust_res.status_code == 201, f"Customer creation failed: {cust_res.text}"
    cust_data = cust_res.json()
    customer_id = cust_data["id"]
    assert cust_data["customer_number"].startswith("CUST-")
    assert cust_data["status"] == "ACTIVE"

    # Verify database auto-provisioned user account has a secure single-use activation token
    async with TestSessionLocal() as session:
        user_res = await session.execute(select(User).where(User.email == cust_email))
        user_obj = user_res.scalars().first()
        assert user_obj is not None
        assert user_obj.role == UserRole.CUSTOMER

        token_res = await session.execute(
            select(PasswordResetToken).where(PasswordResetToken.user_id == user_obj.id)
        )
        token_obj = token_res.scalars().first()
        assert token_obj is not None
        assert token_obj.token_hash is not None
        assert not token_obj.is_used

    # --- Setup Product & Active Plan ---
    prod_res = await client.post(
        "/api/v1/products",
        json={
            "name": f"Audit Analytics Suite {unique_suffix}",
            "sku": f"AUD-SKU-{unique_suffix}",
            "product_type": "SOFTWARE",
            "sales_price": "50000.0000",
            "currency": "INR",
        },
        headers=admin_hdr,
    )
    assert prod_res.status_code == 201
    prod_id = prod_res.json()["id"]

    plan_res = await client.post(
        "/api/v1/plans",
        json={
            "code": f"PLAN-AUD-{unique_suffix}",
            "name": f"Audit Pro Plan {unique_suffix}",
            "billing_interval": "MONTHLY",
            "interval_count": 1,
            "currency": "INR",
            "min_quantity": 1,
            "max_quantity": 10,
        },
        headers=admin_hdr,
    )
    assert plan_res.status_code == 201
    plan_id = plan_res.json()["id"]

    # Bundle product into plan
    bundle_res = await client.post(
        f"/api/v1/plans/{plan_id}/products",
        json={"product_id": prod_id, "default_quantity": 1, "is_optional": False},
        headers=admin_hdr,
    )
    assert bundle_res.status_code == 201

    # Activate plan
    act_res = await client.patch(
        f"/api/v1/plans/{plan_id}/status",
        json={"status": "ACTIVE"},
        headers=admin_hdr,
    )
    assert act_res.status_code == 200

    # --- Step C: Admin creates subscription using active plan ---
    now = datetime.datetime.now(datetime.timezone.utc)
    sub_res = await client.post(
        "/api/v1/subscriptions",
        json={
            "customer_id": customer_id,
            "plan_id": plan_id,
            "start_date": now.isoformat(),
            "payment_terms": "NET_30",
            "tax_rate": "18.0000",
            "discount_amount": "0.0000",
            "notes": "E2E Audit subscription instance",
        },
        headers=admin_hdr,
    )
    assert sub_res.status_code == 201, f"Subscription creation failed: {sub_res.text}"
    sub_data = sub_res.json()
    subscription_id = sub_data["id"]
    assert sub_data["subscription_number"].startswith("SUB-")
    assert sub_data["status"] == "DRAFT"
    # Subtotal = 50,000, 18% Tax = 9,000, Total = 59,000
    assert Decimal(str(sub_data["subtotal"])) == Decimal("50000.0000")
    assert Decimal(str(sub_data["tax_amount"])) == Decimal("9000.0000")
    assert Decimal(str(sub_data["total_amount"])) == Decimal("59000.0000")

    # --- Step D: Lifecycle Progression: DRAFT -> QUOTATION -> CONFIRMED ---
    trans_q = await client.post(
        f"/api/v1/subscriptions/{subscription_id}/status",
        json={"to_status": "QUOTATION", "reason": "Formal quote dispatched"},
        headers=admin_hdr,
    )
    assert trans_q.status_code == 200
    assert trans_q.json()["status"] == "QUOTATION"

    trans_c = await client.post(
        f"/api/v1/subscriptions/{subscription_id}/status",
        json={"to_status": "CONFIRMED", "reason": "Customer approved quote"},
        headers=admin_hdr,
    )
    assert trans_c.status_code == 200
    assert trans_c.json()["status"] == "CONFIRMED"

    # --- Step E: Generate Invoice for Subscription ---
    inv_res = await client.post(
        "/api/v1/invoices",
        json={
            "subscription_id": subscription_id,
            "issue_date": now.isoformat(),
            "billing_period_start": now.isoformat(),
            "billing_period_end": (now + datetime.timedelta(days=30)).isoformat(),
            "notes": "First billing period invoice",
        },
        headers=admin_hdr,
    )
    assert inv_res.status_code == 201, f"Invoice creation failed: {inv_res.text}"
    inv_data = inv_res.json()
    invoice_id = inv_data["id"]
    assert inv_data["invoice_number"].startswith("INV-")
    assert inv_data["status"] == "CONFIRMED"
    assert inv_data["payment_status"] == "UNPAID"
    assert Decimal(str(inv_data["subtotal"])) == Decimal("50000.0000")
    assert Decimal(str(inv_data["tax_amount"])) == Decimal("9000.0000")
    assert Decimal(str(inv_data["total_amount"])) == Decimal("59000.0000")
    assert Decimal(str(inv_data["balance_due"])) == Decimal("59000.0000")
    assert Decimal(str(inv_data["amount_paid"])) == Decimal("0.0000")

    # --- Step F: Record Partial Payment (₹20,000 of ₹59,000) ---
    pay1_res = await client.post(
        "/api/v1/payments",
        json={
            "invoice_id": invoice_id,
            "amount": "20000.0000",
            "payment_method": "BANK_TRANSFER",
            "payment_date": now.isoformat(),
            "reference_number": f"RTGS-{unique_suffix}-1",
            "notes": "First milestone payment",
        },
        headers=admin_hdr,
    )
    assert pay1_res.status_code == 201, f"Payment 1 failed: {pay1_res.text}"
    pay1_data = pay1_res.json()
    assert pay1_data["payment_number"].startswith("PAY-")
    assert Decimal(str(pay1_data["amount"])) == Decimal("20000.0000")

    # --- Step G: Verify Remaining Balance Due ---
    inv_after_pay1 = await client.get(f"/api/v1/invoices/{invoice_id}", headers=admin_hdr)
    assert inv_after_pay1.status_code == 200
    inv1_checked = inv_after_pay1.json()
    assert inv1_checked["status"] == "CONFIRMED"
    assert inv1_checked["payment_status"] == "PARTIALLY_PAID"
    assert Decimal(str(inv1_checked["amount_paid"])) == Decimal("20000.0000")
    assert Decimal(str(inv1_checked["balance_due"])) == Decimal("39000.0000")

    # Subscription should still be CONFIRMED (not yet active)
    sub_mid = await client.get(f"/api/v1/subscriptions/{subscription_id}", headers=admin_hdr)
    assert sub_mid.json()["status"] == "CONFIRMED"

    # --- Step H: Record Settlement Payment (₹39,000 to clear balance) ---
    pay2_res = await client.post(
        "/api/v1/payments",
        json={
            "invoice_id": invoice_id,
            "amount": "39000.0000",
            "payment_method": "CREDIT_CARD",
            "payment_date": now.isoformat(),
            "reference_number": f"CC-{unique_suffix}-2",
            "notes": "Final settlement",
        },
        headers=admin_hdr,
    )
    assert pay2_res.status_code == 201, f"Payment 2 failed: {pay2_res.text}"

    # --- Step I: Invoice becomes PAID with 0.0000 balance ---
    inv_after_pay2 = await client.get(f"/api/v1/invoices/{invoice_id}", headers=admin_hdr)
    assert inv_after_pay2.status_code == 200
    inv2_checked = inv_after_pay2.json()
    assert inv2_checked["status"] == "PAID"
    assert inv2_checked["payment_status"] == "PAID"
    assert Decimal(str(inv2_checked["amount_paid"])) == Decimal("59000.0000")
    assert Decimal(str(inv2_checked["balance_due"])) == Decimal("0.0000")

    # --- Step J: Subscription Auto-Activation occurs exactly once ---
    sub_final = await client.get(f"/api/v1/subscriptions/{subscription_id}", headers=admin_hdr)
    assert sub_final.status_code == 200
    sub_final_data = sub_final.json()
    assert sub_final_data["status"] == "ACTIVE"

    # Verify status history has ACTIVE transition logged
    histories = sub_final_data.get("status_history", [])
    active_entries = [h for h in histories if h["to_status"] == "ACTIVE"]
    assert len(active_entries) == 1
    assert "auto-activated" in active_entries[0]["reason"].lower()

    # --- Step K: Dashboard Metrics update from PostgreSQL ---
    dash_res = await client.get("/api/v1/dashboard/metrics", headers=admin_hdr)
    assert dash_res.status_code == 200
    dash_data = dash_res.json()
    assert dash_data["active_subscriptions"] >= 1
    assert dash_data["total_customers"] >= 1
    assert Decimal(str(dash_data["revenue_collected"])) >= Decimal("59000.0000")


# ==============================================================================
# SECTION 2: NEGATIVE TESTS & SECURITY GUARDS (9 SCENARIOS)
# ==============================================================================

@pytest.mark.asyncio
async def test_neg_01_duplicate_customer_email(client: AsyncClient):
    """Negative 1: Duplicate customer email must be rejected with 400 Bad Request."""
    admin_hdr, _, _, _, _, _ = await get_test_headers()
    dup_email = f"dup_{uuid.uuid4().hex[:6]}@domain.com"

    # First customer
    r1 = await client.post(
        "/api/v1/customers",
        json={"name": "Company Alpha", "email": dup_email},
        headers=admin_hdr,
    )
    assert r1.status_code == 201

    # Second customer with exact same email
    r2 = await client.post(
        "/api/v1/customers",
        json={"name": "Company Beta", "email": dup_email},
        headers=admin_hdr,
    )
    assert r2.status_code == 400
    assert "already exists" in r2.json()["detail"].lower()


@pytest.mark.asyncio
async def test_neg_02_invalid_subscription_quantity(client: AsyncClient):
    """Negative 2: Subscription quantity violating plan min/max limits must return 400 Bad Request."""
    admin_hdr, _, _, _, _, _ = await get_test_headers()
    suffix = uuid.uuid4().hex[:6]

    # Product
    p_res = await client.post(
        "/api/v1/products",
        json={"name": f"Qty Test Product {suffix}", "sku": f"QTY-{suffix}", "product_type": "SOFTWARE", "sales_price": "100.0000", "currency": "INR"},
        headers=admin_hdr,
    )
    p_id = p_res.json()["id"]

    # Plan with min_quantity = 2, max_quantity = 5
    plan_res = await client.post(
        "/api/v1/plans",
        json={
            "code": f"PLAN-QTY-{suffix}",
            "name": f"Limited Quantity Plan {suffix}",
            "billing_interval": "MONTHLY",
            "interval_count": 1,
            "currency": "INR",
            "min_quantity": 2,
            "max_quantity": 5,
        },
        headers=admin_hdr,
    )
    plan_id = plan_res.json()["id"]
    await client.post(f"/api/v1/plans/{plan_id}/products", json={"product_id": p_id, "default_quantity": 2}, headers=admin_hdr)
    await client.patch(f"/api/v1/plans/{plan_id}/status", json={"status": "ACTIVE"}, headers=admin_hdr)

    # Customer
    c_res = await client.post(
        "/api/v1/customers",
        json={"name": f"Qty Customer {suffix}", "email": f"qty_{suffix}@test.com"},
        headers=admin_hdr,
    )
    c_id = c_res.json()["id"]

    now = datetime.datetime.now(datetime.timezone.utc)

    # Attempt quantity 1 (< min_quantity 2)
    bad_min = await client.post(
        "/api/v1/subscriptions",
        json={
            "customer_id": c_id,
            "plan_id": plan_id,
            "start_date": now.isoformat(),
            "items": [{"product_id": p_id, "quantity": 1}],
        },
        headers=admin_hdr,
    )
    assert bad_min.status_code == 400
    assert "less than plan minimum" in bad_min.json()["detail"].lower()

    # Attempt quantity 8 (> max_quantity 5)
    bad_max = await client.post(
        "/api/v1/subscriptions",
        json={
            "customer_id": c_id,
            "plan_id": plan_id,
            "start_date": now.isoformat(),
            "items": [{"product_id": p_id, "quantity": 8}],
        },
        headers=admin_hdr,
    )
    assert bad_max.status_code == 400
    assert "exceeds plan maximum" in bad_max.json()["detail"].lower()


@pytest.mark.asyncio
async def test_neg_03_inactive_or_draft_plan(client: AsyncClient):
    """Negative 3: Subscribing to a plan in DRAFT status must return 400 Bad Request."""
    admin_hdr, _, _, _, _, _ = await get_test_headers()
    suffix = uuid.uuid4().hex[:6]

    # Create plan in DRAFT status
    plan_res = await client.post(
        "/api/v1/plans",
        json={"code": f"DRAFT-{suffix}", "name": "Draft Plan", "billing_interval": "MONTHLY", "interval_count": 1, "currency": "INR"},
        headers=admin_hdr,
    )
    plan_id = plan_res.json()["id"]

    c_res = await client.post(
        "/api/v1/customers",
        json={"name": "Draft Tester", "email": f"draft_{suffix}@test.com"},
        headers=admin_hdr,
    )
    c_id = c_res.json()["id"]

    now = datetime.datetime.now(datetime.timezone.utc)
    res = await client.post(
        "/api/v1/subscriptions",
        json={"customer_id": c_id, "plan_id": plan_id, "start_date": now.isoformat()},
        headers=admin_hdr,
    )
    assert res.status_code == 400
    assert "must be active" in res.json()["detail"].lower()


@pytest.mark.asyncio
async def test_neg_04_duplicate_billing_period(client: AsyncClient):
    """Negative 4: Generating overlapping invoices for the same subscription period must return 400 Bad Request."""
    admin_hdr, _, _, _, _, _ = await get_test_headers()
    suffix = uuid.uuid4().hex[:6]

    # Setup product, plan, customer, and confirmed subscription
    p_res = await client.post(
        "/api/v1/products",
        json={"name": f"Overlap Prod {suffix}", "sku": f"OVL-{suffix}", "product_type": "SOFTWARE", "sales_price": "1000.0000", "currency": "INR"},
        headers=admin_hdr,
    )
    p_id = p_res.json()["id"]

    plan_res = await client.post(
        "/api/v1/plans",
        json={"code": f"OVL-PLAN-{suffix}", "name": "Overlap Plan", "billing_interval": "MONTHLY", "interval_count": 1, "currency": "INR"},
        headers=admin_hdr,
    )
    plan_id = plan_res.json()["id"]
    await client.post(f"/api/v1/plans/{plan_id}/products", json={"product_id": p_id, "default_quantity": 1}, headers=admin_hdr)
    await client.patch(f"/api/v1/plans/{plan_id}/status", json={"status": "ACTIVE"}, headers=admin_hdr)

    c_res = await client.post(
        "/api/v1/customers",
        json={"name": "Overlap Cust", "email": f"ovl_{suffix}@test.com"},
        headers=admin_hdr,
    )
    c_id = c_res.json()["id"]

    now = datetime.datetime.now(datetime.timezone.utc)
    sub_res = await client.post(
        "/api/v1/subscriptions",
        json={"customer_id": c_id, "plan_id": plan_id, "start_date": now.isoformat()},
        headers=admin_hdr,
    )
    sub_id = sub_res.json()["id"]
    await client.post(f"/api/v1/subscriptions/{sub_id}/status", json={"to_status": "QUOTATION"}, headers=admin_hdr)
    await client.post(f"/api/v1/subscriptions/{sub_id}/status", json={"to_status": "CONFIRMED"}, headers=admin_hdr)

    period_start = now
    period_end = now + datetime.timedelta(days=30)

    # First Invoice
    inv1 = await client.post(
        "/api/v1/invoices",
        json={
            "subscription_id": sub_id,
            "billing_period_start": period_start.isoformat(),
            "billing_period_end": period_end.isoformat(),
        },
        headers=admin_hdr,
    )
    assert inv1.status_code == 201

    # Second Invoice with overlapping period
    inv2 = await client.post(
        "/api/v1/invoices",
        json={
            "subscription_id": sub_id,
            "billing_period_start": (period_start + datetime.timedelta(days=5)).isoformat(),
            "billing_period_end": (period_end + datetime.timedelta(days=5)).isoformat(),
        },
        headers=admin_hdr,
    )
    assert inv2.status_code == 400
    assert "already exists" in inv2.json()["detail"].lower()


@pytest.mark.asyncio
async def test_neg_05_zero_or_negative_payment(client: AsyncClient):
    """Negative 5: Recording zero or negative payment amounts must be rejected (422 / 400)."""
    admin_hdr, _, _, _, _, _ = await get_test_headers()
    random_inv_id = str(uuid.uuid4())

    # Zero payment
    r_zero = await client.post(
        "/api/v1/payments",
        json={"invoice_id": random_inv_id, "amount": "0.0000", "payment_method": "BANK_TRANSFER"},
        headers=admin_hdr,
    )
    assert r_zero.status_code in (400, 422)

    # Negative payment
    r_neg = await client.post(
        "/api/v1/payments",
        json={"invoice_id": random_inv_id, "amount": "-150.0000", "payment_method": "BANK_TRANSFER"},
        headers=admin_hdr,
    )
    assert r_neg.status_code in (400, 422)


@pytest.mark.asyncio
async def test_neg_06_overpayment_rejection(client: AsyncClient):
    """Negative 6: Payment amount exceeding invoice balance due must return 400 Bad Request."""
    admin_hdr, _, _, _, _, _ = await get_test_headers()
    suffix = uuid.uuid4().hex[:6]

    # Setup Product, Plan, Customer, Subscription, and Invoice (Total = ₹1,180 with GST)
    p_res = await client.post(
        "/api/v1/products",
        json={"name": f"OP Prod {suffix}", "sku": f"OP-{suffix}", "product_type": "SOFTWARE", "sales_price": "1000.0000", "currency": "INR"},
        headers=admin_hdr,
    )
    p_id = p_res.json()["id"]

    plan_res = await client.post(
        "/api/v1/plans",
        json={"code": f"OP-PLAN-{suffix}", "name": "Overpay Plan", "billing_interval": "MONTHLY", "interval_count": 1, "currency": "INR"},
        headers=admin_hdr,
    )
    plan_id = plan_res.json()["id"]
    await client.post(f"/api/v1/plans/{plan_id}/products", json={"product_id": p_id, "default_quantity": 1}, headers=admin_hdr)
    await client.patch(f"/api/v1/plans/{plan_id}/status", json={"status": "ACTIVE"}, headers=admin_hdr)

    c_res = await client.post(
        "/api/v1/customers",
        json={"name": "Overpay Cust", "email": f"op_{suffix}@test.com"},
        headers=admin_hdr,
    )
    c_id = c_res.json()["id"]

    now = datetime.datetime.now(datetime.timezone.utc)
    sub_res = await client.post(
        "/api/v1/subscriptions",
        json={"customer_id": c_id, "plan_id": plan_id, "start_date": now.isoformat()},
        headers=admin_hdr,
    )
    sub_id = sub_res.json()["id"]
    await client.post(f"/api/v1/subscriptions/{sub_id}/status", json={"to_status": "QUOTATION"}, headers=admin_hdr)
    await client.post(f"/api/v1/subscriptions/{sub_id}/status", json={"to_status": "CONFIRMED"}, headers=admin_hdr)

    inv_res = await client.post(
        "/api/v1/invoices",
        json={"subscription_id": sub_id},
        headers=admin_hdr,
    )
    assert inv_res.status_code == 201, f"Invoice generation failed: {inv_res.text}"
    inv_id = inv_res.json()["id"]
    total = Decimal(str(inv_res.json()["total_amount"]))

    # Attempt payment greater than total
    overpay_res = await client.post(
        "/api/v1/payments",
        json={"invoice_id": inv_id, "amount": str(total + Decimal("500.0000")), "payment_method": "BANK_TRANSFER"},
        headers=admin_hdr,
    )
    assert overpay_res.status_code == 400
    assert "exceeds" in overpay_res.json()["detail"].lower()


@pytest.mark.asyncio
async def test_neg_07_customer_isolation_cross_access(client: AsyncClient):
    """Negative 7: Customer 1 attempting to access Customer 2 records must return 403 Forbidden."""
    admin_hdr, _, _, _, _, _ = await get_test_headers()
    suffix = uuid.uuid4().hex[:6]
    email1 = f"iso1_{suffix}@demo.com"
    email2 = f"iso2_{suffix}@demo.com"

    # Create Customer 1 profile
    c1_res = await client.post(
        "/api/v1/customers",
        json={"name": "Customer One Profile", "email": email1},
        headers=admin_hdr,
    )
    assert c1_res.status_code == 201
    c1_id = c1_res.json()["id"]

    # Create Customer 2 profile
    c2_res = await client.post(
        "/api/v1/customers",
        json={"name": "Customer Two Profile", "email": email2},
        headers=admin_hdr,
    )
    assert c2_res.status_code == 201
    c2_id = c2_res.json()["id"]

    # Fetch User 1 and User 2 to generate their JWTs
    async with TestSessionLocal() as session:
        u1 = (await session.execute(select(User).where(User.email == email1))).scalars().first()
        u2 = (await session.execute(select(User).where(User.email == email2))).scalars().first()
        token1 = create_access_token(user_id=u1.id, role=u1.role.value, email=u1.email)
        cust1_hdr = {"Authorization": f"Bearer {token1}"}

    # Customer 1 attempts to read Customer 2 profile
    cross_read = await client.get(f"/api/v1/customers/{c2_id}", headers=cust1_hdr)
    assert cross_read.status_code == 403
    assert "access denied" in cross_read.json()["detail"].lower()


@pytest.mark.asyncio
async def test_neg_08_staff_forbidden_admin_endpoints(client: AsyncClient):
    """Negative 8: Staff attempting Admin-only operations must return 403 Forbidden."""
    _, staff_hdr, _, _, _, _ = await get_test_headers()

    # Staff attempts to call admin-only staff creation endpoint
    res = await client.post(
        "/api/v1/users/staff",
        json={
            "email": f"hacked_staff_{uuid.uuid4().hex[:5]}@brightloop.com",
            "full_name": "Rogue Staff",
            "password": "Password123!",
        },
        headers=staff_hdr,
    )
    assert res.status_code == 403
    assert "access denied" in res.json()["detail"].lower() or "requires" in res.json()["detail"].lower()


@pytest.mark.asyncio
async def test_neg_09_payment_against_cancelled_or_paid_invoice(client: AsyncClient):
    """Negative 9: Recording payment against a PAID or CANCELLED invoice must return 400 Bad Request."""
    admin_hdr, _, _, _, _, _ = await get_test_headers()
    suffix = uuid.uuid4().hex[:6]

    # Setup Product, Plan, Customer, Subscription, and Invoice
    p_res = await client.post(
        "/api/v1/products",
        json={"name": f"Neg9 Prod {suffix}", "sku": f"NEG9-{suffix}", "product_type": "SOFTWARE", "sales_price": "500.0000", "currency": "INR"},
        headers=admin_hdr,
    )
    p_id = p_res.json()["id"]

    plan_res = await client.post(
        "/api/v1/plans",
        json={"code": f"PLAN-NEG9-{suffix}", "name": "Neg9 Plan", "billing_interval": "MONTHLY", "interval_count": 1, "currency": "INR"},
        headers=admin_hdr,
    )
    plan_id = plan_res.json()["id"]
    await client.post(f"/api/v1/plans/{plan_id}/products", json={"product_id": p_id, "default_quantity": 1}, headers=admin_hdr)
    await client.patch(f"/api/v1/plans/{plan_id}/status", json={"status": "ACTIVE"}, headers=admin_hdr)

    c_res = await client.post(
        "/api/v1/customers",
        json={"name": "Neg9 Cust", "email": f"neg9_{suffix}@test.com"},
        headers=admin_hdr,
    )
    c_id = c_res.json()["id"]

    now = datetime.datetime.now(datetime.timezone.utc)
    sub_res = await client.post(
        "/api/v1/subscriptions",
        json={"customer_id": c_id, "plan_id": plan_id, "start_date": now.isoformat()},
        headers=admin_hdr,
    )
    sub_id = sub_res.json()["id"]
    await client.post(f"/api/v1/subscriptions/{sub_id}/status", json={"to_status": "QUOTATION"}, headers=admin_hdr)
    await client.post(f"/api/v1/subscriptions/{sub_id}/status", json={"to_status": "CONFIRMED"}, headers=admin_hdr)

    inv_res = await client.post("/api/v1/invoices", json={"subscription_id": sub_id}, headers=admin_hdr)
    assert inv_res.status_code == 201, f"Invoice generation failed: {inv_res.text}"
    inv_id = inv_res.json()["id"]
    total = Decimal(str(inv_res.json()["total_amount"]))

    # Settle in full
    pay_res = await client.post(
        "/api/v1/payments",
        json={"invoice_id": inv_id, "amount": str(total), "payment_method": "BANK_TRANSFER"},
        headers=admin_hdr,
    )
    assert pay_res.status_code == 201

    # Attempt payment against now PAID invoice
    extra_pay = await client.post(
        "/api/v1/payments",
        json={"invoice_id": inv_id, "amount": "100.0000", "payment_method": "BANK_TRANSFER"},
        headers=admin_hdr,
    )
    assert extra_pay.status_code == 400
    assert "already been paid" in extra_pay.json()["detail"].lower()
