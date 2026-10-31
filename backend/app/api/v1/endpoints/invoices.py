import math
import uuid
from typing import Optional
from fastapi import APIRouter, Depends, Query, Request, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.core.dependencies import get_client_info, get_current_user, require_roles
from app.models.invoice import InvoicePaymentStatus, InvoiceStatus
from app.models.user import User, UserRole
from app.schemas.invoice import (
    InvoiceCreateRequest,
    InvoiceListResponse,
    InvoiceResponse,
    InvoiceStatusTransitionRequest,
)
from app.services.invoice_service import InvoiceService

router = APIRouter(prefix="/invoices", tags=["Invoicing Engine"])


@router.get("", response_model=InvoiceListResponse)
async def list_invoices(
    customer_id: Optional[uuid.UUID] = Query(None, description="Filter by customer ID"),
    subscription_id: Optional[uuid.UUID] = Query(None, description="Filter by subscription ID"),
    status_filter: Optional[InvoiceStatus] = Query(None, alias="status", description="Filter by status"),
    payment_status_filter: Optional[InvoicePaymentStatus] = Query(
        None, alias="payment_status", description="Filter by payment status"
    ),
    search: Optional[str] = Query(None, description="Search by invoice number"),
    page: int = Query(1, ge=1, description="Page number"),
    limit: int = Query(20, ge=1, le=100, description="Items per page"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """List invoices with pagination and financial status filters."""
    svc = InvoiceService(db)
    items, total = await svc.list_invoices(
        current_user=current_user,
        customer_id=customer_id,
        subscription_id=subscription_id,
        status_filter=status_filter,
        payment_status_filter=payment_status_filter,
        search=search,
        page=page,
        limit=limit,
    )
    pages = math.ceil(total / limit) if total > 0 else 1
    return InvoiceListResponse(
        items=[InvoiceResponse.model_validate(inv) for inv in items],
        total=total,
        page=page,
        size=limit,
        pages=pages,
    )


@router.post("", response_model=InvoiceResponse, status_code=status.HTTP_201_CREATED)
async def create_invoice(
    data: InvoiceCreateRequest,
    request: Request,
    current_user: User = Depends(require_roles(UserRole.ADMIN, UserRole.STAFF)),
    db: AsyncSession = Depends(get_db),
):
    """Generate a new invoice from a confirmed or active subscription. Admin & Staff only."""
    ip, user_agent = get_client_info(request)
    svc = InvoiceService(db)
    inv = await svc.create_invoice_from_subscription(
        data=data,
        operator=current_user,
        ip_address=ip,
        user_agent=user_agent,
    )
    return InvoiceResponse.model_validate(inv)


@router.get("/{id}", response_model=InvoiceResponse)
async def get_invoice(
    id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Retrieve full itemized invoice details."""
    svc = InvoiceService(db)
    inv = await svc.get_invoice(id, current_user)
    return InvoiceResponse.model_validate(inv)


@router.post("/{id}/status", response_model=InvoiceResponse)
async def transition_invoice_status(
    id: uuid.UUID,
    data: InvoiceStatusTransitionRequest,
    request: Request,
    current_user: User = Depends(require_roles(UserRole.ADMIN, UserRole.STAFF)),
    db: AsyncSession = Depends(get_db),
):
    """Update invoice lifecycle status (e.g. CANCELLED or CONFIRMED). Admin & Staff only."""
    ip, user_agent = get_client_info(request)
    svc = InvoiceService(db)
    updated = await svc.transition_invoice_status(
        invoice_id=id,
        to_status=data.to_status,
        notes=data.notes,
        operator=current_user,
        ip_address=ip,
        user_agent=user_agent,
    )
    return InvoiceResponse.model_validate(updated)

