import datetime
import uuid
from decimal import Decimal
from typing import List, Optional, Tuple
from sqlalchemy import func, select
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.customer import Customer
from app.models.invoice import Invoice, InvoiceStatus
from app.models.payment import Payment
from app.models.subscription import Subscription, SubscriptionStatus


class DashboardRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def count_active_subscriptions(self, customer_id: Optional[uuid.UUID] = None) -> int:
        conditions = [Subscription.status == SubscriptionStatus.ACTIVE]
        if customer_id:
            conditions.append(Subscription.customer_id == customer_id)
        query = select(func.count(Subscription.id)).where(*conditions)
        res = await self.session.execute(query)
        return res.scalar() or 0

    async def count_total_customers(self) -> int:
        query = select(func.count(Customer.id))
        res = await self.session.execute(query)
        return res.scalar() or 0

    async def total_revenue_collected(self, customer_id: Optional[uuid.UUID] = None) -> Decimal:
        conditions = []
        if customer_id:
            conditions.append(Payment.customer_id == customer_id)
        query = select(func.coalesce(func.sum(Payment.amount), Decimal("0.0000"))).where(*conditions)
        res = await self.session.execute(query)
        val = res.scalar()
        return Decimal(str(val or "0.0000"))

    async def total_outstanding_amount(self, customer_id: Optional[uuid.UUID] = None) -> Decimal:
        conditions = [
            Invoice.status != InvoiceStatus.CANCELLED,
            Invoice.balance_due > Decimal("0.0000"),
        ]
        if customer_id:
            conditions.append(Invoice.customer_id == customer_id)
        query = select(func.coalesce(func.sum(Invoice.balance_due), Decimal("0.0000"))).where(*conditions)
        res = await self.session.execute(query)
        val = res.scalar()
        return Decimal(str(val or "0.0000"))

    async def count_overdue_invoices(self, customer_id: Optional[uuid.UUID] = None) -> int:
        now = datetime.datetime.now(datetime.timezone.utc)
        conditions = [
            Invoice.status != InvoiceStatus.CANCELLED,
            Invoice.balance_due > Decimal("0.0000"),
            Invoice.due_date < now,
        ]
        if customer_id:
            conditions.append(Invoice.customer_id == customer_id)
        query = select(func.count(Invoice.id)).where(*conditions)
        res = await self.session.execute(query)
        return res.scalar() or 0

    async def get_recent_payments(self, limit: int = 5, customer_id: Optional[uuid.UUID] = None) -> List[Payment]:
        conditions = []
        if customer_id:
            conditions.append(Payment.customer_id == customer_id)
        query = (
            select(Payment)
            .options(selectinload(Payment.customer))
            .where(*conditions)
            .order_by(Payment.payment_date.desc(), Payment.created_at.desc())
            .limit(limit)
        )
        res = await self.session.execute(query)
        return list(res.scalars().all())

    async def get_recent_subscriptions(self, limit: int = 5, customer_id: Optional[uuid.UUID] = None) -> List[Subscription]:
        conditions = []
        if customer_id:
            conditions.append(Subscription.customer_id == customer_id)
        query = (
            select(Subscription)
            .options(selectinload(Subscription.customer), selectinload(Subscription.plan))
            .where(*conditions)
            .order_by(Subscription.created_at.desc())
            .limit(limit)
        )
        res = await self.session.execute(query)
        return list(res.scalars().all())

    async def get_revenue_trend(self, customer_id: Optional[uuid.UUID] = None) -> List[Tuple[str, Decimal, int]]:
        conditions = []
        if customer_id:
            conditions.append(Payment.customer_id == customer_id)

        # Date trunc by month
        month_col = func.to_char(Payment.payment_date, "YYYY-MM")
        query = (
            select(
                month_col.label("period"),
                func.coalesce(func.sum(Payment.amount), Decimal("0.0000")).label("revenue"),
                func.count(Payment.id).label("count"),
            )
            .where(*conditions)
            .group_by(month_col)
            .order_by(month_col.asc())
        )
        res = await self.session.execute(query)
        rows = res.all()
        return [(str(row.period), Decimal(str(row.revenue)), int(row.count)) for row in rows]

