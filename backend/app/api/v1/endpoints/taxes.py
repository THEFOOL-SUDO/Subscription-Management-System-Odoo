import uuid
from typing import List, Optional
from fastapi import APIRouter, Depends, Query, Request, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.core.dependencies import get_client_info, get_current_user, require_roles
from app.models.user import User, UserRole
from app.schemas.tax import (
    TaxRuleCreate,
    TaxRuleListResponse,
    TaxRuleResponse,
    TaxRuleUpdate,
)
from app.services.tax_service import TaxService

router = APIRouter(prefix="/taxes", tags=["Tax Rules"])


@router.get("", response_model=TaxRuleListResponse)
async def list_tax_rules(
    active_only: bool = Query(False),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    svc = TaxService(db)
    items = await svc.list_rules(active_only=active_only)
    return TaxRuleListResponse(
        items=[TaxRuleResponse.model_validate(r) for r in items],
        total=len(items),
    )


@router.post("", response_model=TaxRuleResponse, status_code=status.HTTP_201_CREATED)
async def create_tax_rule(
    data: TaxRuleCreate,
    request: Request,
    current_user: User = Depends(require_roles(UserRole.ADMIN, UserRole.STAFF)),
    db: AsyncSession = Depends(get_db),
):
    ip, user_agent = get_client_info(request)
    svc = TaxService(db)
    created = await svc.create_rule(
        data=data,
        operator=current_user,
        ip_address=ip,
        user_agent=user_agent,
    )
    return TaxRuleResponse.model_validate(created)


@router.patch("/{id}", response_model=TaxRuleResponse)
async def update_tax_rule(
    id: uuid.UUID,
    data: TaxRuleUpdate,
    request: Request,
    current_user: User = Depends(require_roles(UserRole.ADMIN)),
    db: AsyncSession = Depends(get_db),
):
    ip, user_agent = get_client_info(request)
    svc = TaxService(db)
    updated = await svc.update_rule(
        rule_id=id,
        data=data,
        operator=current_user,
        ip_address=ip,
        user_agent=user_agent,
    )
    return TaxRuleResponse.model_validate(updated)
