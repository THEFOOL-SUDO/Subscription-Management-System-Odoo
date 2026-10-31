import uuid
from decimal import Decimal
import pytest
from httpx import ASGITransport, AsyncClient
from app.core.database import AsyncSessionLocal
from app.main import app
from app.models.plan import PlanStatus
from app.models.user import UserRole
from app.repositories.plan_repo import PlanRepository
from app.repositories.product_repo import ProductRepository
from app.repositories.user_repo import UserRepository
from app.services.catalogue_service import CatalogueService
from app.services.pricing_service import PricingService


@pytest.mark.asyncio
async def test_catalogue_service_idempotency_and_preservation():
    """Verify default catalogue creation, price precision, and idempotency."""
    async with AsyncSessionLocal() as session:
        user_repo = UserRepository(session)
        admin = await user_repo.get_by_email("admin@brightloop.com")

        svc = CatalogueService(session)
        pricing_svc = PricingService(session)
        plan_repo = PlanRepository(session)
        prod_repo = ProductRepository(session)

        # 1. Run catalogue setup
        res1 = await svc.ensure_default_catalogue(admin_user=admin)
        assert res1["success"] is True

        # Verify software products
        starter_prod = await prod_repo.get_by_sku("BL-PROD-STARTER")
        assert starter_prod is not None
        assert starter_prod.sales_price == Decimal("999.0000")

        growth_prod = await prod_repo.get_by_sku("BL-PROD-GROWTH")
        assert growth_prod is not None
        assert growth_prod.sales_price == Decimal("2499.0000")

        biz_prod = await prod_repo.get_by_sku("BL-PROD-BUSINESS")
        assert biz_prod is not None
        assert biz_prod.sales_price == Decimal("5999.0000")

        # Verify add-on products
        ai_addon = await prod_repo.get_by_sku("BL-PROD-ADDON-AI")
        assert ai_addon is not None
        assert ai_addon.sales_price == Decimal("499.0000")

        sla_addon = await prod_repo.get_by_sku("BL-PROD-ADDON-SLA")
        assert sla_addon is not None
        assert sla_addon.sales_price == Decimal("999.0000")

        seat_addon = await prod_repo.get_by_sku("BL-PROD-ADDON-SEAT")
        assert seat_addon is not None
        assert seat_addon.sales_price == Decimal("199.0000")

        # Verify subscription plans and prices
        sm_plan = await plan_repo.get_by_code("BL-CAT-STARTER-M")
        assert sm_plan is not None
        assert sm_plan.status == PlanStatus.ACTIVE
        assert pricing_svc.calculate_plan_total(sm_plan) == Decimal("999.0000")

        sy_plan = await plan_repo.get_by_code("BL-CAT-STARTER-Y")
        assert sy_plan is not None
        assert sy_plan.status == PlanStatus.ACTIVE
        assert pricing_svc.calculate_plan_total(sy_plan) == Decimal("9990.0000")

        gm_plan = await plan_repo.get_by_code("BL-CAT-GROWTH-M")
        assert gm_plan is not None
        assert pricing_svc.calculate_plan_total(gm_plan) == Decimal("2499.0000")

        gy_plan = await plan_repo.get_by_code("BL-CAT-GROWTH-Y")
        assert gy_plan is not None
        assert pricing_svc.calculate_plan_total(gy_plan) == Decimal("24990.0000")

        bm_plan = await plan_repo.get_by_code("BL-CAT-BIZ-M")
        assert bm_plan is not None
        assert pricing_svc.calculate_plan_total(bm_plan) == Decimal("5999.0000")

        by_plan = await plan_repo.get_by_code("BL-CAT-BIZ-Y")
        assert by_plan is not None
        assert pricing_svc.calculate_plan_total(by_plan) == Decimal("59990.0000")

        # 2. Run setup again to verify 100% idempotency
        res2 = await svc.ensure_default_catalogue(admin_user=admin)
        assert len(res2["products_created"]) == 0
        assert len(res2["plans_created"]) == 0
        assert len(res2["existing_products"]) == 6
        assert len(res2["existing_plans"]) == 6

        # 3. Verify Admin Price Modifications are Preserved
        custom_price = Decimal("1099.0000")
        starter_prod.sales_price = custom_price
        await session.commit()

        # Run setup again
        res3 = await svc.ensure_default_catalogue(admin_user=admin)
        assert len(res3["products_created"]) == 0

        # Check that customized price was NOT overwritten back to 999.0000
        reloaded_prod = await prod_repo.get_by_sku("BL-PROD-STARTER")
        assert reloaded_prod.sales_price == custom_price

        # Restore price for standard demo
        reloaded_prod.sales_price = Decimal("999.0000")
        await session.commit()


@pytest.mark.asyncio
async def test_catalogue_api_rbac_and_customer_access():
    """Verify endpoint RBAC and customer read scoping."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # 1. Login as Admin
        admin_login = await client.post(
            "/api/v1/auth/login",
            json={"email": "admin@brightloop.com", "password": "Brightloop#Admin2026"},
        )
        assert admin_login.status_code == 200
        admin_token = admin_login.json()["access_token"]
        admin_headers = {"Authorization": f"Bearer {admin_token}"}

        # 2. Admin can call POST /api/v1/plans/catalogue/setup
        setup_res = await client.post("/api/v1/plans/catalogue/setup", headers=admin_headers)
        assert setup_res.status_code == 200
        assert setup_res.json()["success"] is True

        # 3. Create a Customer User for isolation testing
        cust_email = f"catalog_cust_{uuid.uuid4().hex[:6]}@example.com"
        reg_res = await client.post(
            "/api/v1/auth/register",
            json={
                "email": cust_email,
                "password": "Customer#Pass2026",
                "full_name": "Catalogue Customer",
            },
        )
        assert reg_res.status_code == 201
        cust_token = reg_res.json()["access_token"]
        cust_headers = {"Authorization": f"Bearer {cust_token}"}

        # 4. Customer CANNOT call catalogue setup (403 Forbidden)
        cust_setup = await client.post("/api/v1/plans/catalogue/setup", headers=cust_headers)
        assert cust_setup.status_code == 403

        # 5. Customer CANNOT call admin internal plan/product lists directly (403 Forbidden)
        cust_plans_forbidden = await client.get("/api/v1/plans", headers=cust_headers)
        assert cust_plans_forbidden.status_code == 403
        cust_prods_forbidden = await client.get("/api/v1/products", headers=cust_headers)
        assert cust_prods_forbidden.status_code == 403

        # 6. Customer CAN access the unified Catalogue items endpoint (200 OK)
        cat_res = await client.get("/api/v1/plans/catalogue/items", headers=cust_headers)
        assert cat_res.status_code == 200
        cat_body = cat_res.json()
        assert "plans" in cat_body
        assert "addons" in cat_body
        assert len(cat_body["plans"]) >= 6
        assert len(cat_body["addons"]) >= 3

        # All returned plans in catalogue must be ACTIVE
        for pl in cat_body["plans"]:
            assert pl["status"] == "ACTIVE"


@pytest.mark.asyncio
async def test_create_subscription_from_catalogue_plan():
    """Verify subscription creation, pricing calculation, and lifecycle using a catalogue plan."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # Admin login
        admin_login = await client.post(
            "/api/v1/auth/login",
            json={"email": "admin@brightloop.com", "password": "Brightloop#Admin2026"},
        )
        assert admin_login.status_code == 200
        admin_token = admin_login.json()["access_token"]
        admin_headers = {"Authorization": f"Bearer {admin_token}"}

        # 1. Fetch the Starter Monthly plan ID
        plans_res = await client.get("/api/v1/plans", params={"search": "BL-CAT-STARTER-M"}, headers=admin_headers)
        starter_plan = plans_res.json()["items"][0]
        starter_plan_id = starter_plan["id"]

        # 2. Create customer
        cust_email = f"starter_corp_{uuid.uuid4().hex[:6]}@example.com"
        cust_res = await client.post(
            "/api/v1/customers",
            headers=admin_headers,
            json={
                "name": "Starter Corp India",
                "email": cust_email,
                "phone": "+91 9888877777",
                "company_name": "Starter Corp Pvt Ltd",
                "billing_address_line1": "Level 4, Cyber Gateway",
                "billing_city": "Hyderabad",
                "billing_state": "Telangana",
                "billing_postal_code": "500081",
                "billing_country": "India",
            },
        )
        assert cust_res.status_code == 201
        customer_id = cust_res.json()["id"]

        # 3. Create Subscription from Starter Monthly Plan
        sub_create_res = await client.post(
            "/api/v1/subscriptions",
            headers=admin_headers,
            json={
                "customer_id": customer_id,
                "plan_id": starter_plan_id,
                "start_date": "2026-11-01T00:00:00Z",
                "payment_terms": "NET_30",
                "tax_rate": "18.00",
                "discount_amount": "0.00",
                "notes": "Starter catalogue plan subscription",
            },
        )
        assert sub_create_res.status_code == 201
        sub_data = sub_create_res.json()
        assert sub_data["status"] == "DRAFT"
        assert Decimal(sub_data["subtotal"]) == Decimal("999.0000")
        assert Decimal(sub_data["tax_amount"]) == Decimal("179.8200") # 18% of 999
        assert Decimal(sub_data["total_amount"]) == Decimal("1178.8200")

        # 4. Lifecycle transition DRAFT -> QUOTATION -> CONFIRMED
        sub_id = sub_data["id"]
        quote_res = await client.post(
            f"/api/v1/subscriptions/{sub_id}/status",
            headers=admin_headers,
            json={"to_status": "QUOTATION", "reason": "Sent commercial proposal"},
        )
        assert quote_res.status_code == 200
        assert quote_res.json()["status"] == "QUOTATION"

        confirm_res = await client.post(
            f"/api/v1/subscriptions/{sub_id}/status",
            headers=admin_headers,
            json={"to_status": "CONFIRMED", "reason": "Proposal signed by client"},
        )
        assert confirm_res.status_code == 200
        assert confirm_res.json()["status"] == "CONFIRMED"
