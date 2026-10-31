import datetime
import uuid
from typing import List, Optional, Tuple
from sqlalchemy import func, or_, select
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.subscription import (
    Subscription,
    SubscriptionItem,
    SubscriptionStatus,
    SubscriptionStatusHistory,
)


class SubscriptionRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    def _base_query(self):
        return select(Subscription).options(
            selectinload(Subscription.customer),
            selectinload(Subscription.plan),
            selectinload(Subscription.items).selectinload(SubscriptionItem.product),
            selectinload(Subscription.items).selectinload(SubscriptionItem.variant),
            selectinload(Subscription.status_history),
        )

    async def get_by_id(self, subscription_id: uuid.UUID) -> Optional[Subscription]:
        query = self._base_query().where(Subscription.id == subscription_id)
        result = await self.session.execute(query)
        return result.scalar_one_or_none()

    async def get_by_number(self, number: str) -> Optional[Subscription]:
        query = self._base_query().where(func.lower(Subscription.subscription_number) == number.strip().lower())
        result = await self.session.execute(query)
        return result.scalar_one_or_none()

    async def get_next_subscription_number(self) -> str:
        now = datetime.datetime.now(datetime.timezone.utc)
        prefix = f"SUB-{now.strftime('%Y%m')}-"
        query = select(func.count(Subscription.id)).where(Subscription.subscription_number.like(f"{prefix}%"))
        result = await self.session.execute(query)
        count = result.scalar() or 0
        return f"{prefix}{count + 1:04d}"

    async def list_subscriptions(
        self,
        customer_id: Optional[uuid.UUID] = None,
        status: Optional[SubscriptionStatus] = None,
        search: Optional[str] = None,
        page: int = 1,
        limit: int = 20,
    ) -> Tuple[List[Subscription], int]:
        filters = []
        if customer_id is not None:
            filters.append(Subscription.customer_id == customer_id)
        if status is not None:
            filters.append(Subscription.status == status)

        if search:
            pattern = f"%{search.strip().lower()}%"
            filters.append(
                or_(
                    func.lower(Subscription.subscription_number).like(pattern),
                    func.lower(Subscription.notes).like(pattern),
                )
            )

        count_query = select(func.count(Subscription.id)).where(*filters)
        total_res = await self.session.execute(count_query)
        total = total_res.scalar() or 0

        offset = (page - 1) * limit
        data_query = (
            self._base_query()
            .where(*filters)
            .order_by(Subscription.created_at.desc())
            .offset(offset)
            .limit(limit)
        )
        data_res = await self.session.execute(data_query)
        items = list(data_res.scalars().all())

        return items, total

    async def create(self, subscription: Subscription) -> Subscription:
        self.session.add(subscription)
        await self.session.flush()
        # Fetch fresh eagerly loaded
        return await self.get_by_id(subscription.id)  # type: ignore

    async def update(self, subscription: Subscription) -> Subscription:
        await self.session.flush()
        return await self.get_by_id(subscription.id)  # type: ignore

    async def add_status_history(self, history: SubscriptionStatusHistory) -> SubscriptionStatusHistory:
        self.session.add(history)
        await self.session.flush()
        return history

