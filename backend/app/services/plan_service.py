import datetime
import uuid
from decimal import Decimal
from typing import List, Optional, Tuple
from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.plan import BillingInterval, PlanProduct, PlanStatus, SubscriptionPlan
from app.repositories.plan_repo import PlanRepository
from app.repositories.product_repo import ProductRepository
from app.schemas.plan import (
    PlanProductCreate,
    PlanProductUpdate,
    SubscriptionPlanCreate,
    SubscriptionPlanStatusUpdate,
    SubscriptionPlanUpdate,
)
from app.services.audit_service import AuditService
from app.services.pricing_service import PricingService


class PlanService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.repo = PlanRepository(session)
        self.product_repo = ProductRepository(session)
        self.audit_service = AuditService(session)
        self.pricing_service = PricingService(session)

    async def _check_auto_close(self, plan: SubscriptionPlan) -> SubscriptionPlan:
        """Evaluate auto-close business rule and transition status if expired."""
        if (
            plan.is_auto_close
            and plan.status == PlanStatus.ACTIVE
            and plan.availability_end_date is not None
        ):
            now = datetime.datetime.now(datetime.timezone.utc)
            if plan.availability_end_date <= now:
                plan_id = plan.id
                await self.repo.update_status(plan, PlanStatus.ARCHIVED)
                await self.audit_service.log(
                    action="PLAN_AUTO_CLOSED",
                    resource_type="SUBSCRIPTION_PLAN",
                    user_id=None,
                    resource_id=str(plan_id),
                    details={
                        "code": plan.code,
                        "reason": f"Availability end date '{plan.availability_end_date}' reached.",
                    },
                )
                self.session.expire_all()
                refreshed = await self.repo.get_by_id(plan_id)
                return refreshed or plan
        return plan

    async def get_plan(self, plan_id: uuid.UUID) -> SubscriptionPlan:
        plan = await self.repo.get_by_id(plan_id)
        if not plan:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Subscription plan with ID '{plan_id}' not found.",
            )
        return await self._check_auto_close(plan)

    async def list_plans(
        self,
        search: Optional[str] = None,
        status_filter: Optional[PlanStatus] = None,
        billing_interval: Optional[BillingInterval] = None,
        page: int = 1,
        limit: int = 20,
    ) -> Tuple[List[SubscriptionPlan], int]:
        plans, total = await self.repo.list_plans(
            search=search,
            status=status_filter,
            billing_interval=billing_interval,
            page=page,
            limit=limit,
        )
        checked_plans = []
        for p in plans:
            checked_plans.append(await self._check_auto_close(p))
        return checked_plans, total

    async def create_plan(
        self,
        request: SubscriptionPlanCreate,
        user_id: Optional[uuid.UUID] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> SubscriptionPlan:
        existing = await self.repo.get_by_code(request.code)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Subscription plan with code '{request.code}' already exists.",
            )

        plan = await self.repo.create_plan(
            code=request.code,
            name=request.name,
            billing_interval=request.billing_interval,
            interval_count=request.interval_count,
            trial_period_days=request.trial_period_days,
            status=request.status,
            currency=request.currency,
            description=request.description,
            min_quantity=request.min_quantity,
            max_quantity=request.max_quantity,
            is_auto_close=request.is_auto_close,
            availability_start_date=request.availability_start_date,
            availability_end_date=request.availability_end_date,
            created_by_id=user_id,
        )

        # Add bundled products if provided
        for bp in request.bundled_products:
            await self._validate_and_add_bundled_product(plan, bp)

        await self.audit_service.log(
            action="PLAN_CREATED",
            resource_type="SUBSCRIPTION_PLAN",
            user_id=user_id,
            resource_id=str(plan.id),
            details={
                "code": plan.code,
                "name": plan.name,
                "billing_interval": plan.billing_interval,
                "currency": plan.currency,
                "bundled_products_count": len(request.bundled_products),
            },
            ip_address=ip_address,
            user_agent=user_agent,
        )

        plan_id = plan.id
        self.session.expire_all()
        return await self.get_plan(plan_id)

    async def update_plan(
        self,
        plan_id: uuid.UUID,
        request: SubscriptionPlanUpdate,
        user_id: Optional[uuid.UUID] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> SubscriptionPlan:
        plan = await self.get_plan(plan_id)

        if plan.status == PlanStatus.ARCHIVED:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Archived plans cannot be edited.",
            )

        if request.code is not None and request.code.upper() != plan.code.upper():
            existing = await self.repo.get_by_code(request.code)
            if existing and existing.id != plan.id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Subscription plan with code '{request.code}' already exists.",
                )

        updated_plan = await self.repo.update_plan(
            plan=plan,
            code=request.code,
            name=request.name,
            description=request.description,
            billing_interval=request.billing_interval,
            interval_count=request.interval_count,
            trial_period_days=request.trial_period_days,
            currency=request.currency,
            min_quantity=request.min_quantity,
            max_quantity=request.max_quantity,
            is_auto_close=request.is_auto_close,
            availability_start_date=request.availability_start_date,
            availability_end_date=request.availability_end_date,
            updated_by_id=user_id,
        )

        await self.audit_service.log(
            action="PLAN_UPDATED",
            resource_type="SUBSCRIPTION_PLAN",
            user_id=user_id,
            resource_id=str(plan.id),
            details={"code": updated_plan.code, "name": updated_plan.name},
            ip_address=ip_address,
            user_agent=user_agent,
        )

        self.session.expire_all()
        return await self.get_plan(plan_id)

    async def update_status(
        self,
        plan_id: uuid.UUID,
        request: SubscriptionPlanStatusUpdate,
        user_id: Optional[uuid.UUID] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> SubscriptionPlan:
        plan = await self.get_plan(plan_id)
        new_status = request.status

        if plan.status == new_status:
            return plan

        # Lifecycle validation
        if plan.status == PlanStatus.ARCHIVED:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot change status of an archived plan.",
            )

        if new_status == PlanStatus.ACTIVE:
            # Plan must contain at least 1 active bundled product
            active_items = [bp for bp in plan.bundled_products if bp.is_active]
            if not active_items:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Cannot activate plan: at least one active bundled product is required.",
                )

        updated_plan = await self.repo.update_status(plan, new_status, updated_by_id=user_id)

        await self.audit_service.log(
            action="PLAN_STATUS_CHANGED",
            resource_type="SUBSCRIPTION_PLAN",
            user_id=user_id,
            resource_id=str(plan.id),
            details={
                "code": plan.code,
                "old_status": plan.status,
                "new_status": new_status,
            },
            ip_address=ip_address,
            user_agent=user_agent,
        )

        self.session.expire_all()
        return await self.get_plan(plan_id)

    async def _validate_and_add_bundled_product(
        self, plan: SubscriptionPlan, bp_data: PlanProductCreate
    ) -> PlanProduct:
        product = await self.product_repo.get_by_id(bp_data.product_id)
        if not product:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Product with ID '{bp_data.product_id}' not found.",
            )
        if product.is_archived or not product.is_active:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Cannot add inactive or archived product '{product.name}'.",
            )

        # Enforce currency homogeneity rule
        if product.currency.upper() != plan.currency.upper():
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=(
                    f"Product '{product.name}' currency ({product.currency}) does "
                    f"not match plan currency ({plan.currency})."
                ),
            )

        if bp_data.variant_id:
            variant = await self.product_repo.get_variant_by_id(bp_data.variant_id)
            if not variant or variant.product_id != product.id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Variant does not belong to product '{product.name}'.",
                )
            if not variant.is_active:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Cannot add inactive variant '{variant.variant_name}'.",
                )

        existing = await self.repo.get_plan_product(
            plan.id, bp_data.product_id, bp_data.variant_id
        )
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="This product variant is already bundled in the plan.",
            )

        return await self.repo.add_plan_product(
            plan_id=plan.id,
            product_id=bp_data.product_id,
            variant_id=bp_data.variant_id,
            default_quantity=bp_data.default_quantity,
            is_optional=bp_data.is_optional,
            price_override=bp_data.price_override,
            is_active=bp_data.is_active,
        )

    async def add_bundled_product(
        self,
        plan_id: uuid.UUID,
        request: PlanProductCreate,
        user_id: Optional[uuid.UUID] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> PlanProduct:
        plan = await self.get_plan(plan_id)
        if plan.status == PlanStatus.ARCHIVED:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot modify bundled products of an archived plan.",
            )

        plan_product = await self._validate_and_add_bundled_product(plan, request)

        await self.audit_service.log(
            action="PLAN_PRODUCT_ADDED",
            resource_type="PLAN_PRODUCT",
            user_id=user_id,
            resource_id=str(plan_product.id),
            details={
                "plan_id": str(plan.id),
                "product_id": str(request.product_id),
                "variant_id": str(request.variant_id) if request.variant_id else None,
                "quantity": request.default_quantity,
                "price_override": str(request.price_override)
                if request.price_override is not None
                else None,
            },
            ip_address=ip_address,
            user_agent=user_agent,
        )

        return plan_product

    async def update_bundled_product(
        self,
        plan_id: uuid.UUID,
        plan_product_id: uuid.UUID,
        request: PlanProductUpdate,
        user_id: Optional[uuid.UUID] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> PlanProduct:
        plan = await self.get_plan(plan_id)
        if plan.status == PlanStatus.ARCHIVED:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot modify bundled products of an archived plan.",
            )

        plan_product = await self.repo.get_plan_product_by_id(plan_product_id)
        if not plan_product or plan_product.plan_id != plan_id:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Bundled item '{plan_product_id}' not found in plan '{plan_id}'.",
            )

        if request.variant_id is not None and request.variant_id != plan_product.variant_id:
            variant = await self.product_repo.get_variant_by_id(request.variant_id)
            if not variant or variant.product_id != plan_product.product_id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Variant does not belong to the line item product.",
                )
            if not variant.is_active:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Variant is inactive.",
                )

        updated_bp = await self.repo.update_plan_product(
            plan_product=plan_product,
            default_quantity=request.default_quantity,
            is_optional=request.is_optional,
            price_override=request.price_override,
            is_active=request.is_active,
            variant_id=request.variant_id,
        )

        await self.audit_service.log(
            action="PLAN_PRODUCT_UPDATED",
            resource_type="PLAN_PRODUCT",
            user_id=user_id,
            resource_id=str(plan_product.id),
            details={
                "plan_id": str(plan.id),
                "quantity": updated_bp.default_quantity,
                "is_active": updated_bp.is_active,
            },
            ip_address=ip_address,
            user_agent=user_agent,
        )

        return updated_bp

    async def remove_bundled_product(
        self,
        plan_id: uuid.UUID,
        plan_product_id: uuid.UUID,
        user_id: Optional[uuid.UUID] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> None:
        plan = await self.get_plan(plan_id)
        if plan.status == PlanStatus.ARCHIVED:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot modify bundled products of an archived plan.",
            )

        plan_product = await self.repo.get_plan_product_by_id(plan_product_id)
        if not plan_product or plan_product.plan_id != plan_id:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Bundled item '{plan_product_id}' not found in plan '{plan_id}'.",
            )

        await self.repo.remove_plan_product(plan_product)

        await self.audit_service.log(
            action="PLAN_PRODUCT_REMOVED",
            resource_type="PLAN_PRODUCT",
            user_id=user_id,
            resource_id=str(plan_product_id),
            details={"plan_id": str(plan.id)},
            ip_address=ip_address,
            user_agent=user_agent,
        )
