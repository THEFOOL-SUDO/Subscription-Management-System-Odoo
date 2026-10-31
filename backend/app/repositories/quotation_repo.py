import uuid
from typing import List, Optional
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload
from app.models.quotation import QuotationTemplate, QuotationTemplateItem


class QuotationRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_by_id(self, template_id: uuid.UUID) -> Optional[QuotationTemplate]:
        stmt = (
            select(QuotationTemplate)
            .options(
                selectinload(QuotationTemplate.items).selectinload(QuotationTemplateItem.product),
                selectinload(QuotationTemplate.items).selectinload(QuotationTemplateItem.variant),
                selectinload(QuotationTemplate.plan),
            )
            .where(QuotationTemplate.id == template_id)
        )
        res = await self.session.execute(stmt)
        return res.scalars().first()

    async def get_by_code(self, code: str) -> Optional[QuotationTemplate]:
        stmt = select(QuotationTemplate).where(
            func.lower(QuotationTemplate.code) == func.lower(code.strip())
        )
        res = await self.session.execute(stmt)
        return res.scalars().first()

    async def create(self, template: QuotationTemplate) -> QuotationTemplate:
        self.session.add(template)
        await self.session.flush()
        await self.session.refresh(template)
        return await self.get_by_id(template.id)

    async def update(self, template: QuotationTemplate) -> QuotationTemplate:
        await self.session.flush()
        await self.session.refresh(template)
        return await self.get_by_id(template.id)

    async def delete(self, template: QuotationTemplate) -> None:
        await self.session.delete(template)
        await self.session.flush()

    async def list_templates(self, active_only: bool = False) -> List[QuotationTemplate]:
        stmt = (
            select(QuotationTemplate)
            .options(
                selectinload(QuotationTemplate.items).selectinload(QuotationTemplateItem.product),
                selectinload(QuotationTemplate.items).selectinload(QuotationTemplateItem.variant),
                selectinload(QuotationTemplate.plan),
            )
        )
        if active_only:
            stmt = stmt.where(QuotationTemplate.is_active == True)
        stmt = stmt.order_by(QuotationTemplate.created_at.desc())
        res = await self.session.execute(stmt)
        return list(res.scalars().all())
