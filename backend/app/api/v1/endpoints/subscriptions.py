import math
import uuid
from typing import Optional
from fastapi import APIRouter, Depends, Query, Request, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.core.dependencies import get_client_info, get_current_user, require_roles
from app.models.subscription import SubscriptionStatus
from app.models.user import User, UserRole
from app.schemas.subscription import (
    SubscriptionCreate,
    SubscriptionListResponse,
    SubscriptionResponse,
    SubscriptionStatusTransitionRequest,
)
from app.services.subscription_service import SubscriptionService

router = APIRouter(prefix="/subscriptions", tags=["Subscription Lifecycle Management"])


@router.get("", response_model=SubscriptionListResponse)
async def list_subscriptions(
    customer_id: Optional[uuid.UUID] = Query(None, description="Filter by customer ID"),
    status_filter: Optional[SubscriptionStatus] = Query(None, alias="status", description="Filter by lifecycle status"),
    search: Optional[str] = Query(None, description="Search by subscription number"),
    page: int = Query(1, ge=1, description="Page number"),
    limit: int = Query(20, ge=1, le=100, description="Items per page"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """List subscriptions with pagination and status filtering."""
    svc = SubscriptionService(db)
    items, total = await svc.list_subscriptions(
        current_user=current_user,
        customer_id=customer_id,
        status_filter=status_filter,
        search=search,
        page=page,
        limit=limit,
    )
    pages = math.ceil(total / limit) if total > 0 else 1
    return SubscriptionListResponse(
        items=[SubscriptionResponse.model_validate(s) for s in items],
        total=total,
        page=page,
        size=limit,
        pages=pages,
    )


@router.post("", response_model=SubscriptionResponse, status_code=status.HTTP_201_CREATED)
async def create_subscription(
    data: SubscriptionCreate,
    request: Request,
    current_user: User = Depends(require_roles(UserRole.ADMIN, UserRole.STAFF)),
    db: AsyncSession = Depends(get_db),
):
    """Create a new subscription from customer and active plan. Admin & Staff only."""
    ip, user_agent = get_client_info(request)
    svc = SubscriptionService(db)
    sub = await svc.create_subscription(
        data=data,
        operator=current_user,
        ip_address=ip,
        user_agent=user_agent,
    )
    return SubscriptionResponse.model_validate(sub)


@router.get("/{id}", response_model=SubscriptionResponse)
async def get_subscription(
    id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Retrieve full subscription record with line items and status history."""
    svc = SubscriptionService(db)
    sub = await svc.get_subscription(id, current_user)
    return SubscriptionResponse.model_validate(sub)


@router.post("/{id}/status", response_model=SubscriptionResponse)
async def transition_subscription_status(
    id: uuid.UUID,
    data: SubscriptionStatusTransitionRequest,
    request: Request,
    current_user: User = Depends(require_roles(UserRole.ADMIN, UserRole.STAFF)),
    db: AsyncSession = Depends(get_db),
):
    """Execute a lifecycle state transition (DRAFT -> QUOTATION -> CONFIRMED -> ACTIVE -> CLOSED)."""
    ip, user_agent = get_client_info(request)
    svc = SubscriptionService(db)
    updated = await svc.transition_status(
        subscription_id=id,
        to_status=data.to_status,
        reason=data.reason,
        operator=current_user,
        ip_address=ip,
        user_agent=user_agent,
    )
    return SubscriptionResponse.model_validate(updated)

