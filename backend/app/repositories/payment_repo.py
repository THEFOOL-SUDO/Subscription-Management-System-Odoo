import datetime
import uuid
from typing import List, Optional, Tuple
from sqlalchemy import func, or_, select
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.payment import Payment


class PaymentRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    def _base_query(self):
        return select(Payment).options(
            selectinload(Payment.customer),
            selectinload(Payment.invoice),
            selectinload(Payment.recorded_by),
        )

    async def get_by_id(self, payment_id: uuid.UUID) -> Optional[Payment]:
        query = self._base_query().where(Payment.id == payment_id)
        result = await self.session.execute(query)
        return result.scalar_one_or_none()

    async def get_by_number(self, payment_number: str) -> Optional[Payment]:
        query = self._base_query().where(func.lower(Payment.payment_number) == payment_number.strip().lower())
        result = await self.session.execute(query)
        return result.scalar_one_or_none()

    async def get_next_payment_number(self) -> str:
        now = datetime.datetime.now(datetime.timezone.utc)
        prefix = f"PAY-{now.strftime('%Y%m')}-"
        query = select(func.count(Payment.id)).where(Payment.payment_number.like(f"{prefix}%"))
        result = await self.session.execute(query)
        count = result.scalar() or 0
        return f"{prefix}{count + 1:04d}"

    async def list_payments(
        self,
        invoice_id: Optional[uuid.UUID] = None,
        customer_id: Optional[uuid.UUID] = None,
        page: int = 1,
        limit: int = 20,
    ) -> Tuple[List[Payment], int]:
        filters = []
        if invoice_id is not None:
            filters.append(Payment.invoice_id == invoice_id)
        if customer_id is not None:
            filters.append(Payment.customer_id == customer_id)

        count_query = select(func.count(Payment.id)).where(*filters)
        total_res = await self.session.execute(count_query)
        total = total_res.scalar() or 0

        offset = (page - 1) * limit
        data_query = (
            self._base_query()
            .where(*filters)
            .order_by(Payment.payment_date.desc(), Payment.created_at.desc())
            .offset(offset)
            .limit(limit)
        )
        data_res = await self.session.execute(data_query)
        items = list(data_res.scalars().all())

        return items, total

    async def create(self, payment: Payment) -> Payment:
        self.session.add(payment)
        await self.session.flush()
        return await self.get_by_id(payment.id)  # type: ignore

