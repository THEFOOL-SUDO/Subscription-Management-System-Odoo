import uuid
from typing import List, Optional, Tuple
from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.user import User, UserRole


class UserRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_by_id(self, user_id: uuid.UUID) -> Optional[User]:
        query = select(User).where(User.id == user_id)
        result = await self.session.execute(query)
        return result.scalar_one_or_none()

    async def get_by_email(self, email: str) -> Optional[User]:
        normalized_email = email.strip().lower()
        query = select(User).where(func.lower(User.email) == normalized_email)
        result = await self.session.execute(query)
        return result.scalar_one_or_none()

    async def create(
        self,
        email: str,
        full_name: str,
        hashed_password: str,
        role: UserRole = UserRole.CUSTOMER,
        is_active: bool = True,
        is_verified: bool = True,
    ) -> User:
        user = User(
            id=uuid.uuid4(),
            email=email.strip().lower(),
            full_name=full_name.strip(),
            hashed_password=hashed_password,
            role=role,
            is_active=is_active,
            is_verified=is_verified,
        )
        self.session.add(user)
        await self.session.flush()
        await self.session.refresh(user)
        return user

    async def update(
        self,
        user: User,
        full_name: Optional[str] = None,
        hashed_password: Optional[str] = None,
        is_active: Optional[bool] = None,
        is_verified: Optional[bool] = None,
        role: Optional[UserRole] = None,
    ) -> User:
        if full_name is not None:
            user.full_name = full_name.strip()
        if hashed_password is not None:
            user.hashed_password = hashed_password
        if is_active is not None:
            user.is_active = is_active
        if is_verified is not None:
            user.is_verified = is_verified
        if role is not None:
            user.role = role
        await self.session.flush()
        await self.session.refresh(user)
        return user

    async def list_users(
        self,
        page: int = 1,
        size: int = 20,
        role: Optional[str] = None,
        is_active: Optional[bool] = None,
        search: Optional[str] = None,
    ) -> Tuple[List[User], int]:
        filters = []
        if role:
            try:
                role_enum = UserRole(role.upper())
                filters.append(User.role == role_enum)
            except ValueError:
                pass
        if is_active is not None:
            filters.append(User.is_active == is_active)
        if search:
            search_term = f"%{search.strip().lower()}%"
            filters.append(
                or_(
                    func.lower(User.email).like(search_term),
                    func.lower(User.full_name).like(search_term),
                )
            )

        # Count total
        count_stmt = select(func.count(User.id)).where(*filters)
        total_result = await self.session.execute(count_stmt)
        total = total_result.scalar_one()

        # Query paginated items
        offset = (page - 1) * size
        stmt = (
            select(User)
            .where(*filters)
            .order_by(User.created_at.desc())
            .offset(offset)
            .limit(size)
        )
        result = await self.session.execute(stmt)
        items = list(result.scalars().all())
        return items, total
