import uuid
from typing import List, Optional
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.discount import DiscountRule


class DiscountRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_by_id(self, discount_id: uuid.UUID) -> Optional[DiscountRule]:
        res = await self.session.execute(
            select(DiscountRule).where(DiscountRule.id == discount_id)
        )
        return res.scalars().first()

    async def get_by_code(self, code: str) -> Optional[DiscountRule]:
        res = await self.session.execute(
            select(DiscountRule).where(func.lower(DiscountRule.code) == func.lower(code.strip()))
        )
        return res.scalars().first()

    async def create(self, discount: DiscountRule) -> DiscountRule:
        self.session.add(discount)
        await self.session.flush()
        await self.session.refresh(discount)
        return discount

    async def update(self, discount: DiscountRule) -> DiscountRule:
        await self.session.flush()
        await self.session.refresh(discount)
        return discount

    async def increment_usage(self, discount_id: uuid.UUID) -> None:
        discount = await self.get_by_id(discount_id)
        if discount:
            discount.current_uses += 1
            await self.session.flush()

    async def list_discounts(self, active_only: bool = False) -> List[DiscountRule]:
        stmt = select(DiscountRule)
        if active_only:
            stmt = stmt.where(DiscountRule.is_active == True)
        stmt = stmt.order_by(DiscountRule.created_at.desc())
        res = await self.session.execute(stmt)
        return list(res.scalars().all())
