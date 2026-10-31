import uuid
from typing import List, Optional
from fastapi import APIRouter, Depends, Query, Request, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.core.dependencies import get_client_info, get_current_user, require_roles
from app.models.user import User, UserRole
from app.schemas.discount import (
    DiscountRuleCreate,
    DiscountRuleListResponse,
    DiscountRuleResponse,
    DiscountRuleUpdate,
    DiscountValidateRequest,
    DiscountValidateResponse,
)
from app.services.discount_service import DiscountService

router = APIRouter(prefix="/discounts", tags=["Discount Rules"])


@router.get("", response_model=DiscountRuleListResponse)
async def list_discounts(
    active_only: bool = Query(False),
    current_user: User = Depends(require_roles(UserRole.ADMIN, UserRole.STAFF)),
    db: AsyncSession = Depends(get_db),
):
    svc = DiscountService(db)
    items = await svc.list_discounts(active_only=active_only)
    return DiscountRuleListResponse(
        items=[DiscountRuleResponse.model_validate(d) for d in items],
        total=len(items),
    )


@router.post("/validate", response_model=DiscountValidateResponse)
async def validate_discount_code(
    data: DiscountValidateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Validate a promo code during subscription creation or checkout."""
    svc = DiscountService(db)
    return await svc.validate_code(data)


@router.post("", response_model=DiscountRuleResponse, status_code=status.HTTP_201_CREATED)
async def create_discount(
    data: DiscountRuleCreate,
    request: Request,
    current_user: User = Depends(require_roles(UserRole.ADMIN)),
    db: AsyncSession = Depends(get_db),
):
    ip, user_agent = get_client_info(request)
    svc = DiscountService(db)
    created = await svc.create_discount(
        data=data,
        operator=current_user,
        ip_address=ip,
        user_agent=user_agent,
    )
    return DiscountRuleResponse.model_validate(created)


@router.patch("/{id}", response_model=DiscountRuleResponse)
async def update_discount(
    id: uuid.UUID,
    data: DiscountRuleUpdate,
    request: Request,
    current_user: User = Depends(require_roles(UserRole.ADMIN)),
    db: AsyncSession = Depends(get_db),
):
    ip, user_agent = get_client_info(request)
    svc = DiscountService(db)
    updated = await svc.update_discount(
        discount_id=id,
        data=data,
        operator=current_user,
        ip_address=ip,
        user_agent=user_agent,
    )
    return DiscountRuleResponse.model_validate(updated)
