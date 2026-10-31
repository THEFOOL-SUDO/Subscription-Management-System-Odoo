import uuid
from typing import List, Optional, Tuple
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.payment_transaction import PaymentTransaction


class PaymentTransactionRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_by_id(self, transaction_id: uuid.UUID) -> Optional[PaymentTransaction]:
        result = await self.session.execute(
            select(PaymentTransaction).where(PaymentTransaction.id == transaction_id)
        )
        return result.scalars().first()

    async def get_by_idempotency_key(self, idempotency_key: str) -> Optional[PaymentTransaction]:
        result = await self.session.execute(
            select(PaymentTransaction).where(PaymentTransaction.idempotency_key == idempotency_key)
        )
        return result.scalars().first()

    async def get_by_reference(self, reference: str) -> Optional[PaymentTransaction]:
        result = await self.session.execute(
            select(PaymentTransaction).where(PaymentTransaction.transaction_reference == reference)
        )
        return result.scalars().first()

    async def create(self, transaction: PaymentTransaction) -> PaymentTransaction:
        self.session.add(transaction)
        await self.session.flush()
        await self.session.refresh(transaction)
        return transaction

    async def update(self, transaction: PaymentTransaction) -> PaymentTransaction:
        await self.session.flush()
        await self.session.refresh(transaction)
        return transaction

    async def list_transactions(
        self,
        invoice_id: Optional[uuid.UUID] = None,
        customer_id: Optional[uuid.UUID] = None,
        status: Optional[str] = None,
        page: int = 1,
        limit: int = 20,
    ) -> Tuple[List[PaymentTransaction], int]:
        stmt = select(PaymentTransaction)
        if invoice_id:
            stmt = stmt.where(PaymentTransaction.invoice_id == invoice_id)
        if customer_id:
            stmt = stmt.where(PaymentTransaction.customer_id == customer_id)
        if status:
            stmt = stmt.where(PaymentTransaction.status == status)

        count_stmt = select(func.count()).select_from(stmt.subquery())
        count_res = await self.session.execute(count_stmt)
        total = count_res.scalar_one()

        offset = (page - 1) * limit
        stmt = stmt.order_by(PaymentTransaction.created_at.desc()).offset(offset).limit(limit)
        res = await self.session.execute(stmt)
        items = list(res.scalars().all())

        return items, total
