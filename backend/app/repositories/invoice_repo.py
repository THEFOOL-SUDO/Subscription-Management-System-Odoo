import datetime
import uuid
from typing import List, Optional, Tuple
from sqlalchemy import and_, func, or_, select
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.invoice import Invoice, InvoiceItem, InvoicePaymentStatus, InvoiceStatus


class InvoiceRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    def _base_query(self):
        return select(Invoice).options(
            selectinload(Invoice.customer),
            selectinload(Invoice.subscription),
            selectinload(Invoice.items).selectinload(InvoiceItem.product),
            selectinload(Invoice.items).selectinload(InvoiceItem.variant),
            selectinload(Invoice.payments),
        )

    async def get_by_id(self, invoice_id: uuid.UUID) -> Optional[Invoice]:
        query = self._base_query().where(Invoice.id == invoice_id)
        result = await self.session.execute(query)
        return result.scalar_one_or_none()

    async def get_by_number(self, invoice_number: str) -> Optional[Invoice]:
        query = self._base_query().where(func.lower(Invoice.invoice_number) == invoice_number.strip().lower())
        result = await self.session.execute(query)
        return result.scalar_one_or_none()

    async def get_next_invoice_number(self) -> str:
        now = datetime.datetime.now(datetime.timezone.utc)
        prefix = f"INV-{now.strftime('%Y%m')}-"
        query = select(func.count(Invoice.id)).where(Invoice.invoice_number.like(f"{prefix}%"))
        result = await self.session.execute(query)
        count = result.scalar() or 0
        return f"{prefix}{count + 1:04d}"

    async def check_overlapping_period(
        self,
        subscription_id: uuid.UUID,
        period_start: datetime.datetime,
        period_end: datetime.datetime,
        exclude_invoice_id: Optional[uuid.UUID] = None,
    ) -> bool:
        """Check if an active (non-cancelled) invoice already covers this billing period."""
        conditions = [
            Invoice.subscription_id == subscription_id,
            Invoice.status != InvoiceStatus.CANCELLED,
            Invoice.billing_period_start < period_end,
            Invoice.billing_period_end > period_start,
        ]
        if exclude_invoice_id:
            conditions.append(Invoice.id != exclude_invoice_id)

        query = select(func.count(Invoice.id)).where(and_(*conditions))
        result = await self.session.execute(query)
        count = result.scalar() or 0
        return count > 0

    async def list_invoices(
        self,
        customer_id: Optional[uuid.UUID] = None,
        subscription_id: Optional[uuid.UUID] = None,
        status: Optional[InvoiceStatus] = None,
        payment_status: Optional[InvoicePaymentStatus] = None,
        search: Optional[str] = None,
        page: int = 1,
        limit: int = 20,
    ) -> Tuple[List[Invoice], int]:
        filters = []
        if customer_id is not None:
            filters.append(Invoice.customer_id == customer_id)
        if subscription_id is not None:
            filters.append(Invoice.subscription_id == subscription_id)
        if status is not None:
            filters.append(Invoice.status == status)
        if payment_status is not None:
            filters.append(Invoice.payment_status == payment_status)

        if search:
            pattern = f"%{search.strip().lower()}%"
            filters.append(
                or_(
                    func.lower(Invoice.invoice_number).like(pattern),
                    func.lower(Invoice.notes).like(pattern),
                )
            )

        count_query = select(func.count(Invoice.id)).where(*filters)
        total_res = await self.session.execute(count_query)
        total = total_res.scalar() or 0

        offset = (page - 1) * limit
        data_query = (
            self._base_query()
            .where(*filters)
            .order_by(Invoice.issue_date.desc(), Invoice.created_at.desc())
            .offset(offset)
            .limit(limit)
        )
        data_res = await self.session.execute(data_query)
        items = list(data_res.scalars().all())

        return items, total

    async def create(self, invoice: Invoice) -> Invoice:
        self.session.add(invoice)
        await self.session.flush()
        return await self.get_by_id(invoice.id)  # type: ignore

    async def update(self, invoice: Invoice) -> Invoice:
        await self.session.flush()
        return await self.get_by_id(invoice.id)  # type: ignore

