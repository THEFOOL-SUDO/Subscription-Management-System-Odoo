import uuid
from typing import List, Optional, Tuple
from sqlalchemy import func, select, update
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.tax import TaxRule


class TaxRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_by_id(self, tax_id: uuid.UUID) -> Optional[TaxRule]:
        res = await self.session.execute(select(TaxRule).where(TaxRule.id == tax_id))
        return res.scalars().first()

    async def get_default(self) -> Optional[TaxRule]:
        res = await self.session.execute(
            select(TaxRule).where(TaxRule.is_default == True, TaxRule.is_active == True)
        )
        return res.scalars().first()

    async def create(self, tax_rule: TaxRule) -> TaxRule:
        if tax_rule.is_default:
            # Clear other defaults
            await self.session.execute(
                update(TaxRule).values(is_default=False)
            )
        self.session.add(tax_rule)
        await self.session.flush()
        await self.session.refresh(tax_rule)
        return tax_rule

    async def update(self, tax_rule: TaxRule) -> TaxRule:
        if tax_rule.is_default:
            await self.session.execute(
                update(TaxRule).where(TaxRule.id != tax_rule.id).values(is_default=False)
            )
        await self.session.flush()
        await self.session.refresh(tax_rule)
        return tax_rule

    async def list_rules(self, active_only: bool = False) -> List[TaxRule]:
        stmt = select(TaxRule)
        if active_only:
            stmt = stmt.where(TaxRule.is_active == True)
        stmt = stmt.order_by(TaxRule.is_default.desc(), TaxRule.name.asc())
        res = await self.session.execute(stmt)
        return list(res.scalars().all())
