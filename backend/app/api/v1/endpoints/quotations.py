import uuid
from typing import List, Optional
from fastapi import APIRouter, Depends, Query, Request, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.core.dependencies import get_client_info, get_current_user, require_roles
from app.models.user import User, UserRole
from app.schemas.quotation import (
    QuotationConvertToSubscriptionRequest,
    QuotationTemplateCreate,
    QuotationTemplateListResponse,
    QuotationTemplateResponse,
    QuotationTemplateUpdate,
)
from app.schemas.subscription import SubscriptionResponse
from app.services.quotation_service import QuotationService

router = APIRouter(prefix="/quotation-templates", tags=["Quotation Templates"])


@router.get("", response_model=QuotationTemplateListResponse)
async def list_quotation_templates(
    active_only: bool = Query(False),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    svc = QuotationService(db)
    items = await svc.list_templates(active_only=active_only)
    return QuotationTemplateListResponse(items=items, total=len(items))


@router.get("/{id}", response_model=QuotationTemplateResponse)
async def get_quotation_template(
    id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    svc = QuotationService(db)
    return await svc.get_template(id)


@router.post("", response_model=QuotationTemplateResponse, status_code=status.HTTP_201_CREATED)
async def create_quotation_template(
    data: QuotationTemplateCreate,
    request: Request,
    current_user: User = Depends(require_roles(UserRole.ADMIN, UserRole.STAFF)),
    db: AsyncSession = Depends(get_db),
):
    ip, user_agent = get_client_info(request)
    svc = QuotationService(db)
    return await svc.create_template(
        data=data,
        operator=current_user,
        ip_address=ip,
        user_agent=user_agent,
    )


@router.patch("/{id}", response_model=QuotationTemplateResponse)
async def update_quotation_template(
    id: uuid.UUID,
    data: QuotationTemplateUpdate,
    request: Request,
    current_user: User = Depends(require_roles(UserRole.ADMIN, UserRole.STAFF)),
    db: AsyncSession = Depends(get_db),
):
    ip, user_agent = get_client_info(request)
    svc = QuotationService(db)
    return await svc.update_template(
        template_id=id,
        data=data,
        operator=current_user,
        ip_address=ip,
        user_agent=user_agent,
    )


@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_quotation_template(
    id: uuid.UUID,
    request: Request,
    current_user: User = Depends(require_roles(UserRole.ADMIN)),
    db: AsyncSession = Depends(get_db),
):
    ip, user_agent = get_client_info(request)
    svc = QuotationService(db)
    await svc.delete_template(
        template_id=id,
        operator=current_user,
        ip_address=ip,
        user_agent=user_agent,
    )


@router.post("/{id}/convert-to-subscription", response_model=SubscriptionResponse, status_code=status.HTTP_201_CREATED)
async def convert_quotation_to_subscription(
    id: uuid.UUID,
    data: QuotationConvertToSubscriptionRequest,
    request: Request,
    current_user: User = Depends(require_roles(UserRole.ADMIN, UserRole.STAFF)),
    db: AsyncSession = Depends(get_db),
):
    """Convert an approved quotation template directly into a subscription in QUOTATION state."""
    ip, user_agent = get_client_info(request)
    svc = QuotationService(db)
    sub = await svc.convert_to_subscription(
        template_id=id,
        data=data,
        operator=current_user,
        ip_address=ip,
        user_agent=user_agent,
    )
    return SubscriptionResponse.model_validate(sub)
