#!/usr/bin/env python3
"""
Brightloop — Idempotent Demonstration Dataset Seeder
Seeds realistic enterprise customer accounts, product catalog, subscription plans,
subscriptions, itemized invoices, and transactional payments for hackathon demonstration.
"""

import asyncio
import datetime
import os
import sys
from decimal import Decimal

# Ensure backend root is on Python module path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.core.database import AsyncSessionLocal
from app.models.invoice import InvoicePaymentStatus, InvoiceStatus
from app.models.payment import PaymentMethod
from app.models.plan import BillingInterval, PlanStatus
from app.models.product import AdjustmentType, ProductType
from app.models.subscription import PaymentTerms, SubscriptionStatus
from app.models.user import User, UserRole
from app.repositories.customer_repo import CustomerRepository
from app.repositories.invoice_repo import InvoiceRepository
from app.repositories.payment_repo import PaymentRepository
from app.repositories.plan_repo import PlanRepository
from app.repositories.product_repo import ProductRepository
from app.repositories.subscription_repo import SubscriptionRepository
from app.repositories.user_repo import UserRepository
from app.schemas.customer import CustomerCreate
from app.schemas.invoice import InvoiceCreateRequest
from app.schemas.payment import PaymentCreateRequest
from app.schemas.plan import PlanProductCreate, SubscriptionPlanCreate, SubscriptionPlanStatusUpdate
from app.schemas.product import ProductCreate, ProductVariantCreate
from app.schemas.subscription import SubscriptionCreate, SubscriptionStatusTransitionRequest
from app.services.customer_service import CustomerService
from app.services.dashboard_service import DashboardService
from app.services.invoice_service import InvoiceService
from app.services.payment_service import PaymentService
from app.services.plan_service import PlanService
from app.services.product_service import ProductService
from app.services.subscription_service import SubscriptionService


async def seed_demo_data() -> None:
    print("=" * 70)
    print("  BRIGHTLOOP — DEMONSTRATION DATASET GENERATOR")
    print("=" * 70)

    async with AsyncSessionLocal() as session:
        user_repo = UserRepository(session)
        product_service = ProductService(session)
        plan_service = PlanService(session)
        customer_service = CustomerService(session)
        sub_service = SubscriptionService(session)
        invoice_service = InvoiceService(session)
        payment_service = PaymentService(session)
        dash_service = DashboardService(session)

        # 1. Retrieve or verify bootstrap Admin
        admin = await user_repo.get_by_email("admin@brightloop.com")
        if not admin:
            print("[-] Error: Bootstrap admin (admin@brightloop.com) not found.")
            print("    Please run python app/cli/bootstrap_admin.py first.")
            return

        admin_id = admin.id
        print(f"[+] Authenticated Administrator: {admin.full_name} ({admin.email})")

        # 2. Seed Products
        print("\n--- [1/5] Product Catalog ---")
        product_ids = {}

        p1 = await product_service.repo.get_by_sku("BL-CORE-01")
        if p1:
            product_ids["BL-CORE-01"] = p1.id
            print(f"  [✓] Existing Product: {p1.name} (SKU: BL-CORE-01)")
        else:
            p1_obj = await product_service.create_product(
                request=ProductCreate(
                    sku="BL-CORE-01",
                    name="Brightloop Enterprise Core Platform",
                    product_type=ProductType.SOFTWARE,
                    sales_price=Decimal("49999.0000"),
                    cost_price=Decimal("15000.0000"),
                    currency="INR",
                    description="Multi-tenant subscription engine, billing automation, and webhook infrastructure.",
                    notes="Includes 99.9% uptime SLA.",
                    variants=[
                        ProductVariantCreate(
                            variant_name="High-Concurrency Cluster Add-on",
                            variant_code="BL-CORE-HIGHCONCUR",
                            adjustment_type=AdjustmentType.FIXED_AMOUNT,
                            adjustment_value=Decimal("15000.0000"),
                            description="Additional worker instances for sub-second webhook fan-out",
                        )
                    ],
                ),
                user_id=admin_id,
            )
            product_ids["BL-CORE-01"] = p1_obj.id
            print(f"  [+] Created Product: {p1_obj.name} (SKU: BL-CORE-01) — ₹{p1_obj.sales_price:,.2f}")

        p2 = await product_service.repo.get_by_sku("BL-ADDON-AI")
        if p2:
            product_ids["BL-ADDON-AI"] = p2.id
            print(f"  [✓] Existing Product: {p2.name} (SKU: BL-ADDON-AI)")
        else:
            p2_obj = await product_service.create_product(
                request=ProductCreate(
                    sku="BL-ADDON-AI",
                    name="Advanced Billing Intelligence & Churn Predictor",
                    product_type=ProductType.ADDON,
                    sales_price=Decimal("19999.0000"),
                    cost_price=Decimal("5000.0000"),
                    currency="INR",
                    description="ML-driven revenue leak detection and automated dunning workflows.",
                    notes="Integrates directly with payment gateways.",
                    variants=[],
                ),
                user_id=admin_id,
            )
            product_ids["BL-ADDON-AI"] = p2_obj.id
            print(f"  [+] Created Product: {p2_obj.name} (SKU: BL-ADDON-AI) — ₹{p2_obj.sales_price:,.2f}")

        p3 = await product_service.repo.get_by_sku("BL-SRV-SLA")
        if p3:
            product_ids["BL-SRV-SLA"] = p3.id
            print(f"  [✓] Existing Product: {p3.name} (SKU: BL-SRV-SLA)")
        else:
            p3_obj = await product_service.create_product(
                request=ProductCreate(
                    sku="BL-SRV-SLA",
                    name="24/7 Dedicated Enterprise Support & Solutions Architect",
                    product_type=ProductType.ADDON,
                    sales_price=Decimal("15000.0000"),
                    cost_price=Decimal("8000.0000"),
                    currency="INR",
                    description="Dedicated Technical Account Manager and 1-hour critical response SLA.",
                    notes="Billed annually or monthly alongside core platform.",
                    variants=[],
                ),
                user_id=admin_id,
            )
            product_ids["BL-SRV-SLA"] = p3_obj.id
            print(f"  [+] Created Product: {p3_obj.name} (SKU: BL-SRV-SLA) — ₹{p3_obj.sales_price:,.2f}")

        # 3. Seed Subscription Plans
        print("\n--- [2/5] Subscription Plans ---")
        plan_ids = {}

        pl1 = await plan_service.repo.get_by_code("BL-PLAN-ENT-Y")
        if pl1:
            plan_ids["BL-PLAN-ENT-Y"] = pl1.id
            print(f"  [✓] Existing Plan: {pl1.name} (Code: BL-PLAN-ENT-Y) [Status: {pl1.status.value}]")
        else:
            pl1_obj = await plan_service.create_plan(
                request=SubscriptionPlanCreate(
                    code="BL-PLAN-ENT-Y",
                    name="Brightloop Enterprise ERP Suite (Annual)",
                    billing_interval=BillingInterval.YEARLY,
                    interval_count=1,
                    currency="INR",
                    min_quantity=1,
                    max_quantity=50,
                    description="Comprehensive annual enterprise subscription bundling Core, AI Billing, and 24/7 Support.",
                    bundled_products=[
                        PlanProductCreate(
                            product_id=product_ids["BL-CORE-01"],
                            default_quantity=1,
                            is_optional=False,
                            price_override=Decimal("60000.0000"),
                        ),
                        PlanProductCreate(
                            product_id=product_ids["BL-ADDON-AI"],
                            default_quantity=1,
                            is_optional=False,
                            price_override=Decimal("35000.0000"),
                        ),
                        PlanProductCreate(
                            product_id=product_ids["BL-SRV-SLA"],
                            default_quantity=1,
                            is_optional=False,
                            price_override=Decimal("25000.0000"),
                        ),
                    ],
                ),
                user_id=admin_id,
            )
            await plan_service.update_status(
                plan_id=pl1_obj.id,
                request=SubscriptionPlanStatusUpdate(status=PlanStatus.ACTIVE),
                user_id=admin_id,
            )
            plan_ids["BL-PLAN-ENT-Y"] = pl1_obj.id
            print(f"  [+] Created & Activated Plan: {pl1_obj.name} (Code: BL-PLAN-ENT-Y)")

        pl2 = await plan_service.repo.get_by_code("BL-PLAN-GROWTH-M")
        if pl2:
            plan_ids["BL-PLAN-GROWTH-M"] = pl2.id
            print(f"  [✓] Existing Plan: {pl2.name} (Code: BL-PLAN-GROWTH-M) [Status: {pl2.status.value}]")
        else:
            pl2_obj = await plan_service.create_plan(
                request=SubscriptionPlanCreate(
                    code="BL-PLAN-GROWTH-M",
                    name="Brightloop Growth Operations (Monthly)",
                    billing_interval=BillingInterval.MONTHLY,
                    interval_count=1,
                    currency="INR",
                    min_quantity=1,
                    max_quantity=10,
                    description="Monthly subscription for scaling technology startups.",
                    bundled_products=[
                        PlanProductCreate(
                            product_id=product_ids["BL-CORE-01"],
                            default_quantity=1,
                            is_optional=False,
                            price_override=Decimal("15000.0000"),
                        ),
                    ],
                ),
                user_id=admin_id,
            )
            await plan_service.update_status(
                plan_id=pl2_obj.id,
                request=SubscriptionPlanStatusUpdate(status=PlanStatus.ACTIVE),
                user_id=admin_id,
            )
            plan_ids["BL-PLAN-GROWTH-M"] = pl2_obj.id
            print(f"  [+] Created & Activated Plan: {pl2_obj.name} (Code: BL-PLAN-GROWTH-M)")

        # 4. Seed Customers
        print("\n--- [3/5] Enterprise Customers ---")
        customer_ids = {}

        customers_data = [
            {
                "name": "Tata Consultancy Services Ltd",
                "email": "billing@tcs-enterprise.com",
                "phone": "+91 98765 43210",
                "company_name": "Tata Consultancy Services Ltd",
                "billing_address_line1": "TCS Olympus, Hiranandani Estate, Ghodbunder Rd",
                "billing_address_line2": "Building 5, Executive Wing",
                "billing_city": "Thane",
                "billing_state": "Maharashtra",
                "billing_postal_code": "400607",
                "billing_country": "IN",
            },
            {
                "name": "Zomato Media Private Ltd",
                "email": "finance@zomato-corp.com",
                "phone": "+91 91234 56789",
                "company_name": "Zomato Media Private Ltd",
                "billing_address_line1": "Ground Floor, 12A, 94 Meghdoot Building",
                "billing_address_line2": "Nehru Place Corporate District",
                "billing_city": "New Delhi",
                "billing_state": "Delhi",
                "billing_postal_code": "110019",
                "billing_country": "IN",
            },
            {
                "name": "Swiggy Bundl Technologies",
                "email": "accounts@swiggy.in",
                "phone": "+91 99887 76655",
                "company_name": "Bundl Technologies Pvt Ltd",
                "billing_address_line1": "Devarabisanahalli, Outer Ring Road",
                "billing_address_line2": "Tower A, 4th Floor",
                "billing_city": "Bengaluru",
                "billing_state": "Karnataka",
                "billing_postal_code": "560103",
                "billing_country": "IN",
            },
        ]

        # Re-fetch admin cleanly for operator parameter
        admin_user = await user_repo.get_by_id(admin_id)

        for c_data in customers_data:
            email = c_data["email"]
            existing = await customer_service.repo.get_by_email(email)
            if existing:
                customer_ids[email] = existing.id
                print(f"  [✓] Existing Customer: {existing.name} ({existing.email}) — Number: {existing.customer_number}")
            else:
                created_c = await customer_service.create_customer(
                    data=CustomerCreate(**c_data),
                    operator=admin_user,
                )
                customer_ids[email] = created_c.id
                print(f"  [+] Created Customer: {created_c.name} ({created_c.email}) — Number: {created_c.customer_number}")

        # 5. Seed Subscriptions, Invoices & Payments
        print("\n--- [4/5] Subscriptions, Invoices & Payments ---")

        now = datetime.datetime.now(datetime.timezone.utc)

        # Case A: TCS -> Enterprise ERP Suite (Annual) -> Fully Paid -> ACTIVE
        tcs_cust_id = customer_ids["billing@tcs-enterprise.com"]
        tcs_plan_id = plan_ids["BL-PLAN-ENT-Y"]

        tcs_subs, _ = await sub_service.repo.list_subscriptions(customer_id=tcs_cust_id)
        if tcs_subs:
            tcs_sub = tcs_subs[0]
            print(f"  [✓] Existing TCS Subscription: {tcs_sub.subscription_number} [Status: {tcs_sub.status.value}]")
        else:
            admin_user = await user_repo.get_by_id(admin_id)
            tcs_sub = await sub_service.create_subscription(
                data=SubscriptionCreate(
                    customer_id=tcs_cust_id,
                    plan_id=tcs_plan_id,
                    start_date=now - datetime.timedelta(days=30),
                    payment_terms=PaymentTerms.NET_30,
                    tax_rate=Decimal("18.0000"),
                    discount_amount=Decimal("0.0000"),
                    notes="Annual Enterprise SaaS Contract FY26-27",
                ),
                operator=admin_user,
            )
            tcs_sub_id = tcs_sub.id
            # Progress: DRAFT -> QUOTATION -> CONFIRMED
            await sub_service.transition_status(
                subscription_id=tcs_sub_id,
                to_status=SubscriptionStatus.QUOTATION,
                reason="Quotation issued to TCS procurement",
                operator=admin_user,
            )
            await sub_service.transition_status(
                subscription_id=tcs_sub_id,
                to_status=SubscriptionStatus.CONFIRMED,
                reason="PO received from TCS",
                operator=admin_user,
            )

            # Generate Invoice
            inv1 = await invoice_service.create_invoice_from_subscription(
                data=InvoiceCreateRequest(
                    subscription_id=tcs_sub_id,
                    issue_date=now - datetime.timedelta(days=15),
                    billing_period_start=tcs_sub.start_date,
                    billing_period_end=tcs_sub.expiry_date,
                    notes="Annual recurring fee + 18% GST",
                ),
                operator=admin_user,
            )
            inv1_id = inv1.id
            inv1_total = inv1.total_amount
            print(f"  [+] Generated TCS Invoice: {inv1.invoice_number} — Total: ₹{inv1_total:,.2f} [Status: {inv1.status.value}]")

            # Record Settlement Payment (Full Payment)
            pay1 = await payment_service.record_payment(
                data=PaymentCreateRequest(
                    invoice_id=inv1_id,
                    amount=inv1_total,
                    payment_method=PaymentMethod.BANK_TRANSFER,
                    payment_date=now - datetime.timedelta(days=10),
                    reference_number="HDFC-RTGS-992144-TCS",
                    notes="Settlement received via RTGS",
                ),
                operator=admin_user,
            )
            print(f"  [+] Recorded Full Payment: {pay1.payment_number} — ₹{pay1.amount:,.2f} (Method: {pay1.payment_method.value})")

            # Check subscription status (auto-activated upon payment settlement)
            refreshed_tcs_sub = await sub_service.get_subscription(tcs_sub_id, admin_user)
            print(f"  [★] TCS Subscription Status: {refreshed_tcs_sub.status.value} (Auto-activated: {refreshed_tcs_sub.status == SubscriptionStatus.ACTIVE})")

        # Case B: Zomato -> Growth Operations (Monthly) -> Partially Paid
        zomato_cust_id = customer_ids["finance@zomato-corp.com"]
        zomato_plan_id = plan_ids["BL-PLAN-GROWTH-M"]

        zomato_subs, _ = await sub_service.repo.list_subscriptions(customer_id=zomato_cust_id)
        if zomato_subs:
            zomato_sub = zomato_subs[0]
            print(f"  [✓] Existing Zomato Subscription: {zomato_sub.subscription_number} [Status: {zomato_sub.status.value}]")
        else:
            admin_user = await user_repo.get_by_id(admin_id)
            zomato_sub = await sub_service.create_subscription(
                data=SubscriptionCreate(
                    customer_id=zomato_cust_id,
                    plan_id=zomato_plan_id,
                    start_date=now - datetime.timedelta(days=5),
                    payment_terms=PaymentTerms.NET_15,
                    tax_rate=Decimal("18.0000"),
                    discount_amount=Decimal("0.0000"),
                    notes="Monthly Growth License",
                ),
                operator=admin_user,
            )
            zomato_sub_id = zomato_sub.id
            # Progress: DRAFT -> QUOTATION -> CONFIRMED -> ACTIVE
            await sub_service.transition_status(
                subscription_id=zomato_sub_id,
                to_status=SubscriptionStatus.QUOTATION,
                reason="Quotation reviewed by Zomato VP Tech",
                operator=admin_user,
            )
            await sub_service.transition_status(
                subscription_id=zomato_sub_id,
                to_status=SubscriptionStatus.CONFIRMED,
                reason="Direct authorization granted",
                operator=admin_user,
            )
            await sub_service.transition_status(
                subscription_id=zomato_sub_id,
                to_status=SubscriptionStatus.ACTIVE,
                reason="Activated on trial terms",
                operator=admin_user,
            )

            # Generate Invoice
            inv2 = await invoice_service.create_invoice_from_subscription(
                data=InvoiceCreateRequest(
                    subscription_id=zomato_sub_id,
                    issue_date=now - datetime.timedelta(days=4),
                    billing_period_start=zomato_sub.start_date,
                    billing_period_end=zomato_sub.expiry_date,
                    notes="Monthly Growth tier billing",
                ),
                operator=admin_user,
            )
            inv2_id = inv2.id
            print(f"  [+] Generated Zomato Invoice: {inv2.invoice_number} — Total: ₹{inv2.total_amount:,.2f} [Status: {inv2.status.value}]")

            # Record Partial Payment (₹10,000 of ₹17,700)
            pay2 = await payment_service.record_payment(
                data=PaymentCreateRequest(
                    invoice_id=inv2_id,
                    amount=Decimal("10000.0000"),
                    payment_method=PaymentMethod.CREDIT_CARD,
                    payment_date=now - datetime.timedelta(days=2),
                    reference_number="RZP-CC-ZOMATO-PARTIAL",
                    notes="Initial card authorization payment",
                ),
                operator=admin_user,
            )
            refreshed_inv2 = await invoice_service.get_invoice(inv2_id, admin_user)
            print(f"  [+] Recorded Partial Payment: {pay2.payment_number} — ₹{pay2.amount:,.2f} | Remaining Balance: ₹{refreshed_inv2.balance_due:,.2f} [Status: {refreshed_inv2.payment_status.value}]")

        # Case C: Swiggy -> Enterprise ERP Suite (Annual) -> Unpaid Invoice
        swiggy_cust_id = customer_ids["accounts@swiggy.in"]
        swiggy_plan_id = plan_ids["BL-PLAN-ENT-Y"]

        swiggy_subs, _ = await sub_service.repo.list_subscriptions(customer_id=swiggy_cust_id)
        if swiggy_subs:
            swiggy_sub = swiggy_subs[0]
            print(f"  [✓] Existing Swiggy Subscription: {swiggy_sub.subscription_number} [Status: {swiggy_sub.status.value}]")
        else:
            admin_user = await user_repo.get_by_id(admin_id)
            swiggy_sub = await sub_service.create_subscription(
                data=SubscriptionCreate(
                    customer_id=swiggy_cust_id,
                    plan_id=swiggy_plan_id,
                    start_date=now,
                    payment_terms=PaymentTerms.NET_30,
                    tax_rate=Decimal("18.0000"),
                    discount_amount=Decimal("0.0000"),
                    notes="Annual Enterprise Rollout",
                ),
                operator=admin_user,
            )
            swiggy_sub_id = swiggy_sub.id
            # Progress: DRAFT -> QUOTATION -> CONFIRMED
            await sub_service.transition_status(
                subscription_id=swiggy_sub_id,
                to_status=SubscriptionStatus.QUOTATION,
                reason="Quotation submitted",
                operator=admin_user,
            )
            await sub_service.transition_status(
                subscription_id=swiggy_sub_id,
                to_status=SubscriptionStatus.CONFIRMED,
                reason="PO issued by Swiggy Accounts",
                operator=admin_user,
            )

            # Generate Invoice (Unpaid)
            inv3 = await invoice_service.create_invoice_from_subscription(
                data=InvoiceCreateRequest(
                    subscription_id=swiggy_sub_id,
                    issue_date=now,
                    billing_period_start=swiggy_sub.start_date,
                    billing_period_end=swiggy_sub.expiry_date,
                    notes="Awaiting finance release under NET 30",
                ),
                operator=admin_user,
            )
            print(f"  [+] Generated Swiggy Invoice: {inv3.invoice_number} — Total: ₹{inv3.total_amount:,.2f} [Payment Status: {inv3.payment_status.value}, Balance: ₹{inv3.balance_due:,.2f}]")

        # Explicitly commit all demonstration entities to PostgreSQL
        await session.commit()

        # 6. Verify Dashboard Metrics Aggregation
        print("\n--- [5/5] Live PostgreSQL Aggregated Metrics ---")
        admin_user = await user_repo.get_by_id(admin_id)
        metrics = await dash_service.get_metrics(admin_user)

        print(f"  [•] Total Customers:           {metrics.total_customers}")
        print(f"  [•] Active Subscriptions:      {metrics.active_subscriptions}")
        print(f"  [•] Revenue Collected:         ₹{metrics.revenue_collected:,.2f}")
        print(f"  [•] Outstanding Invoices:      ₹{metrics.outstanding_invoice_amount:,.2f}")
        print(f"  [•] Overdue Invoices Count:    {metrics.overdue_invoices}")
        print(f"  [•] Recent Payments Recorded:  {len(metrics.recent_payments)}")
        print(f"  [•] Recent Subscriptions:      {len(metrics.recent_subscriptions)}")

    print("\n" + "=" * 70)
    print("  [SUCCESS] DEMONSTRATION DATASET POPULATED SUCCESSFULLY")
    print("=" * 70)


if __name__ == "__main__":
    asyncio.run(seed_demo_data())
