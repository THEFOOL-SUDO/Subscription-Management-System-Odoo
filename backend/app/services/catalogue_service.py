import logging
import uuid
from decimal import Decimal
from typing import Any, Dict, List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.plan import BillingInterval, PlanProduct, PlanStatus, SubscriptionPlan
from app.models.product import Product, ProductType
from app.models.user import User
from app.repositories.plan_repo import PlanRepository
from app.repositories.product_repo import ProductRepository
from app.services.audit_service import AuditService

logger = logging.getLogger("brightloop.catalogue")

DEFAULT_PRODUCTS = [
    {
        "sku": "BL-PROD-STARTER",
        "name": "Brightloop Starter Platform",
        "product_type": ProductType.SOFTWARE,
        "sales_price": Decimal("999.0000"),
        "cost_price": Decimal("200.0000"),
        "currency": "INR",
        "description": "Essential subscription management and billing foundation for emerging businesses and startups.",
    },
    {
        "sku": "BL-PROD-GROWTH",
        "name": "Brightloop Growth Platform",
        "product_type": ProductType.SOFTWARE,
        "sales_price": Decimal("2499.0000"),
        "cost_price": Decimal("500.0000"),
        "currency": "INR",
        "description": "Advanced subscription automation, customer lifecycle intelligence, and recurring invoicing.",
    },
    {
        "sku": "BL-PROD-BUSINESS",
        "name": "Brightloop Business Platform",
        "product_type": ProductType.SOFTWARE,
        "sales_price": Decimal("5999.0000"),
        "cost_price": Decimal("1200.0000"),
        "currency": "INR",
        "description": "High-volume enterprise subscription engine with multi-entity billing and audit controls.",
    },
    {
        "sku": "BL-PROD-ADDON-AI",
        "name": "AI Intelligence Module",
        "product_type": ProductType.ADDON,
        "sales_price": Decimal("499.0000"),
        "cost_price": Decimal("100.0000"),
        "currency": "INR",
        "description": "Predictive churn analytics, payment failure recovery, and automated revenue insights.",
    },
    {
        "sku": "BL-PROD-ADDON-SLA",
        "name": "Premium SLA Support",
        "product_type": ProductType.ADDON,
        "sales_price": Decimal("999.0000"),
        "cost_price": Decimal("250.0000"),
        "currency": "INR",
        "description": "24/7 dedicated engineering response with 99.99% uptime guarantee and priority ticketing.",
    },
    {
        "sku": "BL-PROD-ADDON-SEAT",
        "name": "Additional User Seat",
        "product_type": ProductType.ADDON,
        "sales_price": Decimal("199.0000"),
        "cost_price": Decimal("20.0000"),
        "currency": "INR",
        "description": "Extra operator seat for staff and finance team members with role-based access.",
    },
]

DEFAULT_PLANS = [
    {
        "code": "BL-CAT-STARTER-M",
        "name": "Starter Monthly",
        "billing_interval": BillingInterval.MONTHLY,
        "interval_count": 1,
        "status": PlanStatus.ACTIVE,
        "currency": "INR",
        "description": "Starter subscription plan with monthly billing cadence (₹999/month).",
        "bundled_sku": "BL-PROD-STARTER",
        "price_override": None,
    },
    {
        "code": "BL-CAT-STARTER-Y",
        "name": "Starter Annual",
        "billing_interval": BillingInterval.YEARLY,
        "interval_count": 1,
        "status": PlanStatus.ACTIVE,
        "currency": "INR",
        "description": "Starter subscription plan with annual billing cadence (₹9,990/year, save ~17%).",
        "bundled_sku": "BL-PROD-STARTER",
        "price_override": Decimal("9990.0000"),
    },
    {
        "code": "BL-CAT-GROWTH-M",
        "name": "Growth Monthly",
        "billing_interval": BillingInterval.MONTHLY,
        "interval_count": 1,
        "status": PlanStatus.ACTIVE,
        "currency": "INR",
        "description": "Growth subscription plan with monthly billing cadence (₹2,499/month).",
        "bundled_sku": "BL-PROD-GROWTH",
        "price_override": None,
    },
    {
        "code": "BL-CAT-GROWTH-Y",
        "name": "Growth Annual",
        "billing_interval": BillingInterval.YEARLY,
        "interval_count": 1,
        "status": PlanStatus.ACTIVE,
        "currency": "INR",
        "description": "Growth subscription plan with annual billing cadence (₹24,990/year, save ~17%).",
        "bundled_sku": "BL-PROD-GROWTH",
        "price_override": Decimal("24990.0000"),
    },
    {
        "code": "BL-CAT-BIZ-M",
        "name": "Business Monthly",
        "billing_interval": BillingInterval.MONTHLY,
        "interval_count": 1,
        "status": PlanStatus.ACTIVE,
        "currency": "INR",
        "description": "Business subscription plan with monthly billing cadence (₹5,999/month).",
        "bundled_sku": "BL-PROD-BUSINESS",
        "price_override": None,
    },
    {
        "code": "BL-CAT-BIZ-Y",
        "name": "Business Annual",
        "billing_interval": BillingInterval.YEARLY,
        "interval_count": 1,
        "status": PlanStatus.ACTIVE,
        "currency": "INR",
        "description": "Business subscription plan with annual billing cadence (₹59,990/year, save ~17%).",
        "bundled_sku": "BL-PROD-BUSINESS",
        "price_override": Decimal("59990.0000"),
    },
]


class CatalogueService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.product_repo = ProductRepository(session)
        self.plan_repo = PlanRepository(session)
        self.audit_service = AuditService(session)

    async def ensure_default_catalogue(
        self, admin_user: Optional[User] = None
    ) -> Dict[str, Any]:
        """
        Idempotently create standard default products and subscription plans.
        Preserves existing items and never overwrites customized prices/descriptions.
        """
        user_id = admin_user.id if admin_user else None

        products_created = []
        existing_products = []
        product_map: Dict[str, Product] = {}

        # 1. Process Products
        for p_def in DEFAULT_PRODUCTS:
            existing = await self.product_repo.get_by_sku(p_def["sku"])
            if existing:
                existing_products.append({"sku": existing.sku, "id": str(existing.id), "name": existing.name})
                product_map[existing.sku] = existing
                logger.info("Catalogue: product %s already exists, preserving without overwrite.", existing.sku)
            else:
                new_prod = Product(
                    id=uuid.uuid4(),
                    name=p_def["name"],
                    sku=p_def["sku"],
                    product_type=p_def["product_type"],
                    sales_price=p_def["sales_price"],
                    cost_price=p_def["cost_price"],
                    currency=p_def["currency"],
                    description=p_def["description"],
                    is_active=True,
                    is_archived=False,
                    created_by_id=user_id,
                    updated_by_id=user_id,
                )
                self.session.add(new_prod)
                await self.session.flush()
                products_created.append({"sku": new_prod.sku, "id": str(new_prod.id), "name": new_prod.name})
                product_map[new_prod.sku] = new_prod
                logger.info("Catalogue: created product %s (%s).", new_prod.sku, new_prod.name)

        # 2. Process Plans
        plans_created = []
        existing_plans = []

        for pl_def in DEFAULT_PLANS:
            existing_plan = await self.plan_repo.get_by_code(pl_def["code"])
            if existing_plan:
                existing_plans.append({"code": existing_plan.code, "id": str(existing_plan.id), "name": existing_plan.name})
                logger.info("Catalogue: plan %s already exists, preserving without overwrite.", existing_plan.code)
            else:
                bundled_prod = product_map.get(pl_def["bundled_sku"])
                if not bundled_prod:
                    # Fallback lookup from repo
                    bundled_prod = await self.product_repo.get_by_sku(pl_def["bundled_sku"])

                new_plan = SubscriptionPlan(
                    id=uuid.uuid4(),
                    code=pl_def["code"],
                    name=pl_def["name"],
                    description=pl_def["description"],
                    billing_interval=pl_def["billing_interval"],
                    interval_count=pl_def["interval_count"],
                    trial_period_days=0,
                    status=pl_def["status"],
                    currency=pl_def["currency"],
                    min_quantity=1,
                    max_quantity=None,
                    is_auto_close=False,
                    created_by_id=user_id,
                    updated_by_id=user_id,
                )
                self.session.add(new_plan)
                await self.session.flush()

                if bundled_prod:
                    bundle_entry = PlanProduct(
                        id=uuid.uuid4(),
                        plan_id=new_plan.id,
                        product_id=bundled_prod.id,
                        variant_id=None,
                        default_quantity=1,
                        is_optional=False,
                        price_override=pl_def["price_override"],
                        is_active=True,
                    )
                    self.session.add(bundle_entry)

                plans_created.append({"code": new_plan.code, "id": str(new_plan.id), "name": new_plan.name})
                logger.info("Catalogue: created plan %s (%s).", new_plan.code, new_plan.name)

        await self.session.commit()

        # Audit Trail Log
        if products_created or plans_created:
            await self.audit_service.log(
                action="SETUP_DEFAULT_CATALOGUE",
                resource_type="CATALOGUE",
                user_id=user_id,
                details={
                    "products_created_count": len(products_created),
                    "plans_created_count": len(plans_created),
                    "products_created": products_created,
                    "plans_created": plans_created,
                },
            )
            await self.session.commit()

        return {
            "success": True,
            "products_created": products_created,
            "existing_products": existing_products,
            "plans_created": plans_created,
            "existing_plans": existing_plans,
        }
