import uuid
from typing import List, Optional, Tuple
from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.security import hash_password, verify_password
from app.models.user import User, UserRole
from app.repositories.token_repo import TokenRepository
from app.repositories.user_repo import UserRepository
from app.schemas.user import StaffCreateRequest, UserUpdateRequest
from app.services.audit_service import AuditService


class UserService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.user_repo = UserRepository(session)
        self.token_repo = TokenRepository(session)
        self.audit_service = AuditService(session)

    async def get_user_profile(self, user_id: uuid.UUID) -> User:
        user = await self.user_repo.get_by_id(user_id)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found.",
            )
        return user

    async def update_profile(
        self,
        user_id: uuid.UUID,
        data: UserUpdateRequest,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> User:
        user = await self.user_repo.get_by_id(user_id)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found.",
            )

        updated_user = await self.user_repo.update(user, full_name=data.full_name)
        await self.audit_service.log(
            action="PROFILE_UPDATED",
            resource_type="user",
            user_id=user.id,
            resource_id=str(user.id),
            details={"updated_fields": ["full_name"]},
            ip_address=ip_address,
            user_agent=user_agent,
        )
        return updated_user

    async def change_password(
        self,
        user_id: uuid.UUID,
        current_password: str,
        new_password: str,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> None:
        user = await self.user_repo.get_by_id(user_id)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found.",
            )

        if not verify_password(current_password, user.hashed_password):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Current password verification failed.",
            )

        new_hashed = hash_password(new_password)
        await self.user_repo.update(user, hashed_password=new_hashed)
        # Invalidate active refresh tokens
        await self.token_repo.revoke_all_user_refresh_tokens(user.id)

        await self.audit_service.log(
            action="PASSWORD_CHANGED",
            resource_type="user",
            user_id=user.id,
            resource_id=str(user.id),
            details={},
            ip_address=ip_address,
            user_agent=user_agent,
        )

    async def create_staff(
        self,
        creator_admin: User,
        data: StaffCreateRequest,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> User:
        if creator_admin.role != UserRole.ADMIN:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only administrators can create staff accounts.",
            )

        existing = await self.user_repo.get_by_email(data.email)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="An account with this email address already exists.",
            )

        hashed_pwd = hash_password(data.password)
        staff_user = await self.user_repo.create(
            email=data.email,
            full_name=data.full_name,
            hashed_password=hashed_pwd,
            role=UserRole.STAFF,
            is_active=True,
            is_verified=True,
        )

        await self.audit_service.log(
            action="STAFF_CREATED",
            resource_type="user",
            user_id=creator_admin.id,
            resource_id=str(staff_user.id),
            details={"created_email": staff_user.email, "role": staff_user.role.value},
            ip_address=ip_address,
            user_agent=user_agent,
        )

        return staff_user

    async def update_user_status(
        self,
        admin_user: User,
        target_user_id: uuid.UUID,
        is_active: bool,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> User:
        if admin_user.role != UserRole.ADMIN:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only administrators can modify user status.",
            )

        if admin_user.id == target_user_id and not is_active:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Administrators cannot deactivate their own account.",
            )

        target_user = await self.user_repo.get_by_id(target_user_id)
        if not target_user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found.",
            )

        updated_user = await self.user_repo.update(target_user, is_active=is_active)
        if not is_active:
            # Terminate active sessions for deactivated user
            await self.token_repo.revoke_all_user_refresh_tokens(target_user.id)

        await self.audit_service.log(
            action="USER_STATUS_UPDATED",
            resource_type="user",
            user_id=admin_user.id,
            resource_id=str(target_user.id),
            details={"target_email": target_user.email, "is_active": is_active},
            ip_address=ip_address,
            user_agent=user_agent,
        )

        return updated_user

    async def list_users(
        self,
        page: int = 1,
        size: int = 20,
        role: Optional[str] = None,
        is_active: Optional[bool] = None,
        search: Optional[str] = None,
    ) -> Tuple[List[User], int]:
        return await self.user_repo.list_users(
            page=page,
            size=size,
            role=role,
            is_active=is_active,
            search=search,
        )
