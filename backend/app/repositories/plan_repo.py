import datetime
import uuid
from decimal import Decimal
from typing import List, Optional, Tuple
from sqlalchemy import func, or_, select
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.plan import SubscriptionPlan, PlanProduct, BillingInterval, PlanStatus


class PlanRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_by_id(self, plan_id: uuid.UUID) -> Optional[SubscriptionPlan]:
        query = (
            select(SubscriptionPlan)
            .where(SubscriptionPlan.id == plan_id)
            .options(
                selectinload(SubscriptionPlan.bundled_products).selectinload(
                    PlanProduct.product
                ),
                selectinload(SubscriptionPlan.bundled_products).selectinload(
                    PlanProduct.variant
                ),
            )
        )
        result = await self.session.execute(query)
        return result.scalar_one_or_none()

    async def get_by_code(self, code: str) -> Optional[SubscriptionPlan]:
        query = (
            select(SubscriptionPlan)
            .where(func.lower(SubscriptionPlan.code) == code.strip().lower())
            .options(
                selectinload(SubscriptionPlan.bundled_products).selectinload(
                    PlanProduct.product
                ),
                selectinload(SubscriptionPlan.bundled_products).selectinload(
                    PlanProduct.variant
                ),
            )
        )
        result = await self.session.execute(query)
        return result.scalar_one_or_none()

    async def list_plans(
        self,
        search: Optional[str] = None,
        status: Optional[PlanStatus] = None,
        billing_interval: Optional[BillingInterval] = None,
        page: int = 1,
        limit: int = 20,
    ) -> Tuple[List[SubscriptionPlan], int]:
        filters = []
        if status is not None:
            filters.append(SubscriptionPlan.status == status)
        if billing_interval is not None:
            filters.append(SubscriptionPlan.billing_interval == billing_interval)

        if search:
            pattern = f"%{search.strip().lower()}%"
            filters.append(
                or_(
                    func.lower(SubscriptionPlan.name).like(pattern),
                    func.lower(SubscriptionPlan.code).like(pattern),
                    func.lower(SubscriptionPlan.description).like(pattern),
                )
            )

        count_query = select(func.count(SubscriptionPlan.id))
        if filters:
            count_query = count_query.where(*filters)
        total_result = await self.session.execute(count_query)
        total = total_result.scalar() or 0

        offset = (page - 1) * limit
        query = (
            select(SubscriptionPlan)
            .where(*filters)
            .options(
                selectinload(SubscriptionPlan.bundled_products).selectinload(
                    PlanProduct.product
                ),
                selectinload(SubscriptionPlan.bundled_products).selectinload(
                    PlanProduct.variant
                ),
            )
            .order_by(SubscriptionPlan.name.asc())
            .offset(offset)
            .limit(limit)
        )
        result = await self.session.execute(query)
        plans = list(result.scalars().all())
        return plans, total

    async def create_plan(
        self,
        code: str,
        name: str,
        billing_interval: BillingInterval = BillingInterval.MONTHLY,
        interval_count: int = 1,
        trial_period_days: int = 0,
        status: PlanStatus = PlanStatus.DRAFT,
        currency: str = "INR",
        description: Optional[str] = None,
        min_quantity: int = 1,
        max_quantity: Optional[int] = None,
        is_auto_close: bool = False,
        availability_start_date: Optional[datetime.datetime] = None,
        availability_end_date: Optional[datetime.datetime] = None,
        created_by_id: Optional[uuid.UUID] = None,
    ) -> SubscriptionPlan:
        plan = SubscriptionPlan(
            id=uuid.uuid4(),
            code=code.strip().upper(),
            name=name.strip(),
            billing_interval=billing_interval,
            interval_count=interval_count,
            trial_period_days=trial_period_days,
            status=status,
            currency=currency.strip().upper(),
            description=description,
            min_quantity=min_quantity,
            max_quantity=max_quantity,
            is_auto_close=is_auto_close,
            availability_start_date=availability_start_date,
            availability_end_date=availability_end_date,
            created_by_id=created_by_id,
            updated_by_id=created_by_id,
        )
        self.session.add(plan)
        await self.session.flush()
        await self.session.refresh(plan)
        return plan

    async def update_plan(
        self,
        plan: SubscriptionPlan,
        code: Optional[str] = None,
        name: Optional[str] = None,
        description: Optional[str] = None,
        billing_interval: Optional[BillingInterval] = None,
        interval_count: Optional[int] = None,
        trial_period_days: Optional[int] = None,
        currency: Optional[str] = None,
        min_quantity: Optional[int] = None,
        max_quantity: Optional[int] = None,
        is_auto_close: Optional[bool] = None,
        availability_start_date: Optional[datetime.datetime] = None,
        availability_end_date: Optional[datetime.datetime] = None,
        updated_by_id: Optional[uuid.UUID] = None,
    ) -> SubscriptionPlan:
        if code is not None:
            plan.code = code.strip().upper()
        if name is not None:
            plan.name = name.strip()
        if description is not None:
            plan.description = description
        if billing_interval is not None:
            plan.billing_interval = billing_interval
        if interval_count is not None:
            plan.interval_count = interval_count
        if trial_period_days is not None:
            plan.trial_period_days = trial_period_days
        if currency is not None:
            plan.currency = currency.strip().upper()
        if min_quantity is not None:
            plan.min_quantity = min_quantity
        if max_quantity is not None:
            plan.max_quantity = max_quantity
        if is_auto_close is not None:
            plan.is_auto_close = is_auto_close
        if availability_start_date is not None:
            plan.availability_start_date = availability_start_date
        if availability_end_date is not None:
            plan.availability_end_date = availability_end_date
        if updated_by_id is not None:
            plan.updated_by_id = updated_by_id

        await self.session.flush()
        await self.session.refresh(plan)
        return plan

    async def update_status(
        self,
        plan: SubscriptionPlan,
        status: PlanStatus,
        updated_by_id: Optional[uuid.UUID] = None,
    ) -> SubscriptionPlan:
        plan.status = status
        if updated_by_id is not None:
            plan.updated_by_id = updated_by_id
        await self.session.flush()
        await self.session.refresh(plan)
        return plan

    async def get_plan_product(
        self,
        plan_id: uuid.UUID,
        product_id: uuid.UUID,
        variant_id: Optional[uuid.UUID] = None,
    ) -> Optional[PlanProduct]:
        query = select(PlanProduct).where(
            PlanProduct.plan_id == plan_id,
            PlanProduct.product_id == product_id,
            PlanProduct.variant_id == variant_id,
        )
        result = await self.session.execute(query)
        return result.scalar_one_or_none()

    async def get_plan_product_by_id(
        self, plan_product_id: uuid.UUID
    ) -> Optional[PlanProduct]:
        query = (
            select(PlanProduct)
            .where(PlanProduct.id == plan_product_id)
            .options(
                selectinload(PlanProduct.product),
                selectinload(PlanProduct.variant),
            )
        )
        result = await self.session.execute(query)
        return result.scalar_one_or_none()

    async def add_plan_product(
        self,
        plan_id: uuid.UUID,
        product_id: uuid.UUID,
        variant_id: Optional[uuid.UUID] = None,
        default_quantity: int = 1,
        is_optional: bool = False,
        price_override: Optional[Decimal] = None,
        is_active: bool = True,
    ) -> PlanProduct:
        plan_product = PlanProduct(
            id=uuid.uuid4(),
            plan_id=plan_id,
            product_id=product_id,
            variant_id=variant_id,
            default_quantity=default_quantity,
            is_optional=is_optional,
            price_override=price_override,
            is_active=is_active,
        )
        self.session.add(plan_product)
        await self.session.flush()
        await self.session.refresh(plan_product)
        return plan_product

    async def update_plan_product(
        self,
        plan_product: PlanProduct,
        default_quantity: Optional[int] = None,
        is_optional: Optional[bool] = None,
        price_override: Optional[Decimal] = None,
        is_active: Optional[bool] = None,
        variant_id: Optional[uuid.UUID] = None,
    ) -> PlanProduct:
        if default_quantity is not None:
            plan_product.default_quantity = default_quantity
        if is_optional is not None:
            plan_product.is_optional = is_optional
        if price_override is not None:
            plan_product.price_override = price_override
        if is_active is not None:
            plan_product.is_active = is_active
        if variant_id is not None:
            plan_product.variant_id = variant_id

        await self.session.flush()
        await self.session.refresh(plan_product)
        return plan_product

    async def remove_plan_product(self, plan_product: PlanProduct) -> None:
        await self.session.delete(plan_product)
        await self.session.flush()

    async def deactivate_product_in_plans(
        self, product_id: uuid.UUID, variant_id: Optional[uuid.UUID] = None
    ) -> int:
        filters = [PlanProduct.product_id == product_id, PlanProduct.is_active.is_(True)]
        if variant_id is not None:
            filters.append(PlanProduct.variant_id == variant_id)

        query = select(PlanProduct).where(*filters)
        result = await self.session.execute(query)
        items = list(result.scalars().all())
        count = 0
        for item in items:
            item.is_active = False
            count += 1
        if count > 0:
            await self.session.flush()
        return count
