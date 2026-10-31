import datetime
import uuid
from typing import List, Optional, Tuple
from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.customer import Customer, CustomerStatus


class CustomerRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_by_id(self, customer_id: uuid.UUID) -> Optional[Customer]:
        query = select(Customer).where(Customer.id == customer_id)
        result = await self.session.execute(query)
        return result.scalar_one_or_none()

    async def get_by_email(self, email: str) -> Optional[Customer]:
        query = select(Customer).where(func.lower(Customer.email) == email.strip().lower())
        result = await self.session.execute(query)
        return result.scalar_one_or_none()

    async def get_by_user_id(self, user_id: uuid.UUID) -> Optional[Customer]:
        query = select(Customer).where(Customer.user_id == user_id)
        result = await self.session.execute(query)
        return result.scalar_one_or_none()

    async def get_next_customer_number(self) -> str:
        year = datetime.datetime.now(datetime.timezone.utc).year
        prefix = f"CUST-{year}-"
        query = select(func.count(Customer.id)).where(Customer.customer_number.like(f"{prefix}%"))
        result = await self.session.execute(query)
        count = result.scalar() or 0
        return f"{prefix}{count + 1:04d}"

    async def list_customers(
        self,
        search: Optional[str] = None,
        status: Optional[CustomerStatus] = None,
        page: int = 1,
        limit: int = 20,
    ) -> Tuple[List[Customer], int]:
        filters = []
        if status is not None:
            filters.append(Customer.status == status)

        if search:
            pattern = f"%{search.strip().lower()}%"
            filters.append(
                or_(
                    func.lower(Customer.name).like(pattern),
                    func.lower(Customer.email).like(pattern),
                    func.lower(Customer.customer_number).like(pattern),
                    func.lower(Customer.company_name).like(pattern),
                )
            )

        count_query = select(func.count(Customer.id)).where(*filters)
        total_res = await self.session.execute(count_query)
        total = total_res.scalar() or 0

        offset = (page - 1) * limit
        data_query = (
            select(Customer)
            .where(*filters)
            .order_by(Customer.created_at.desc())
            .offset(offset)
            .limit(limit)
        )
        data_res = await self.session.execute(data_query)
        items = list(data_res.scalars().all())

        return items, total

    async def create(self, customer: Customer) -> Customer:
        self.session.add(customer)
        await self.session.flush()
        await self.session.refresh(customer)
        return customer

    async def update(self, customer: Customer) -> Customer:
        await self.session.flush()
        await self.session.refresh(customer)
        return customer

