import math
import uuid
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.core.dependencies import get_client_info, get_current_user, require_roles
from app.models.user import User, UserRole
from app.schemas.user import (
    StaffCreateRequest,
    UserListResponse,
    UserResponse,
    UserStatusUpdateRequest,
)
from app.services.user_service import UserService

router = APIRouter(prefix="/users", tags=["Users Management"])


@router.get("", response_model=UserListResponse)
async def list_users(
    page: int = Query(1, ge=1, description="Page number"),
    size: int = Query(20, ge=1, le=100, description="Items per page"),
    role: Optional[str] = Query(None, description="Filter by role: ADMIN, STAFF, CUSTOMER"),
    is_active: Optional[bool] = Query(None, description="Filter by active status"),
    search: Optional[str] = Query(None, description="Search by name or email"),
    current_user: User = Depends(require_roles(UserRole.ADMIN)),
    db: AsyncSession = Depends(get_db),
):
    """List users with pagination and filtering (ADMIN only)."""
    user_svc = UserService(db)
    items, total = await user_svc.list_users(
        page=page,
        size=size,
        role=role,
        is_active=is_active,
        search=search,
    )
    pages = math.ceil(total / size) if total > 0 else 1
    return UserListResponse(
        items=[UserResponse.model_validate(u) for u in items],
        total=total,
        page=page,
        size=size,
        pages=pages,
    )


@router.post("/staff", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_staff(
    payload: StaffCreateRequest,
    request: Request,
    current_user: User = Depends(require_roles(UserRole.ADMIN)),
    db: AsyncSession = Depends(get_db),
):
    """Create a staff member account (ADMIN only)."""
    ip, user_agent = get_client_info(request)
    user_svc = UserService(db)
    staff_user = await user_svc.create_staff(
        creator_admin=current_user,
        data=payload,
        ip_address=ip,
        user_agent=user_agent,
    )
    return UserResponse.model_validate(staff_user)


@router.patch("/{user_id}/status", response_model=UserResponse)
async def update_user_status(
    user_id: uuid.UUID,
    payload: UserStatusUpdateRequest,
    request: Request,
    current_user: User = Depends(require_roles(UserRole.ADMIN)),
    db: AsyncSession = Depends(get_db),
):
    """Toggle user active / deactivated status (ADMIN only)."""
    ip, user_agent = get_client_info(request)
    user_svc = UserService(db)
    updated_user = await user_svc.update_user_status(
        admin_user=current_user,
        target_user_id=user_id,
        is_active=payload.is_active,
        ip_address=ip,
        user_agent=user_agent,
    )
    return UserResponse.model_validate(updated_user)


@router.get("/{user_id}", response_model=UserResponse)
async def get_user_by_id(
    user_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get a user by ID. Customers can only view their own record."""
    if current_user.role == UserRole.CUSTOMER and current_user.id != user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied.",
        )

    user_svc = UserService(db)
    user = await user_svc.get_user_profile(user_id)
    return UserResponse.model_validate(user)
