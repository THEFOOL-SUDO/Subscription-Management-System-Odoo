import math
import uuid
from typing import Optional
from fastapi import APIRouter, Depends, Query, Request, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.core.dependencies import get_client_info, get_current_user, require_roles
from app.models.user import User, UserRole
from app.schemas.payment import (
    PaymentCreateRequest,
    PaymentListResponse,
    PaymentResponse,
)
from app.services.payment_service import PaymentService

router = APIRouter(prefix="/payments", tags=["Payment Recording"])


@router.get("", response_model=PaymentListResponse)
async def list_payments(
    invoice_id: Optional[uuid.UUID] = Query(None, description="Filter payments by invoice ID"),
    customer_id: Optional[uuid.UUID] = Query(None, description="Filter payments by customer ID"),
    page: int = Query(1, ge=1, description="Page number"),
    limit: int = Query(20, ge=1, le=100, description="Items per page"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """List recorded payments."""
    svc = PaymentService(db)
    items, total = await svc.list_payments(
        current_user=current_user,
        invoice_id=invoice_id,
        customer_id=customer_id,
        page=page,
        limit=limit,
    )
    pages = math.ceil(total / limit) if total > 0 else 1
    return PaymentListResponse(
        items=[PaymentResponse.model_validate(p) for p in items],
        total=total,
        page=page,
        size=limit,
        pages=pages,
    )


@router.post("", response_model=PaymentResponse, status_code=status.HTTP_201_CREATED)
async def record_payment(
    data: PaymentCreateRequest,
    request: Request,
    current_user: User = Depends(require_roles(UserRole.ADMIN, UserRole.STAFF)),
    db: AsyncSession = Depends(get_db),
):
    """Record manual offline payment against an invoice. Admin & Staff only."""
    ip, user_agent = get_client_info(request)
    svc = PaymentService(db)
    payment = await svc.record_payment(
        data=data,
        operator=current_user,
        ip_address=ip,
        user_agent=user_agent,
    )
    return PaymentResponse.model_validate(payment)


@router.get("/{id}", response_model=PaymentResponse)
async def get_payment(
    id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Retrieve details of a recorded payment."""
    svc = PaymentService(db)
    payment = await svc.get_payment(id, current_user)
    return PaymentResponse.model_validate(payment)

