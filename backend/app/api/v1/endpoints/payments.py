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
from app.schemas.payment_transaction import (
    CheckoutSessionRequest,
    CheckoutSessionResponse,
    DemoPaymentProcessRequest,
    PaymentTransactionListResponse,
    PaymentTransactionResponse,
)
from app.services.demo_payment_service import DemoPaymentService
from app.services.payment_service import PaymentService

router = APIRouter(prefix="/payments", tags=["Payment Recording"])


@router.post("/demo/checkout-session", response_model=CheckoutSessionResponse)
async def create_demo_checkout_session(
    data: CheckoutSessionRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Create a simulated checkout session for an invoice."""
    svc = DemoPaymentService(db)
    return await svc.create_checkout_session(data.invoice_id, current_user)


@router.post("/demo/process", response_model=PaymentTransactionResponse)
async def process_demo_payment(
    data: DemoPaymentProcessRequest,
    request: Request,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Process a demo payment with simulated gateway outcomes."""
    ip, user_agent = get_client_info(request)
    svc = DemoPaymentService(db)
    return await svc.process_demo_payment(
        data=data,
        current_user=current_user,
        ip_address=ip,
        user_agent=user_agent,
    )


@router.get("/transactions", response_model=PaymentTransactionListResponse)
async def list_transactions(
    invoice_id: Optional[uuid.UUID] = Query(None, description="Filter by invoice ID"),
    customer_id: Optional[uuid.UUID] = Query(None, description="Filter by customer ID"),
    status: Optional[str] = Query(None, description="Filter by transaction status"),
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """List payment transactions with optional filters."""
    svc = DemoPaymentService(db)
    items, total = await svc.list_transactions(
        current_user=current_user,
        invoice_id=invoice_id,
        customer_id=customer_id,
        status=status,
        page=page,
        limit=limit,
    )
    return PaymentTransactionListResponse(
        items=[
            PaymentTransactionResponse(
                id=t.id,
                transaction_reference=t.transaction_reference,
                invoice_id=t.invoice_id,
                customer_id=t.customer_id,
                amount=t.amount,
                currency=t.currency,
                provider=t.provider,
                payment_method=t.payment_method,
                status=t.status,
                idempotency_key=t.idempotency_key,
                metadata_json=t.metadata_json,
                created_at=t.created_at,
                updated_at=t.updated_at,
                invoice_number=t.invoice.invoice_number if t.invoice else None,
                invoice_status=t.invoice.status.value if t.invoice else None,
                invoice_payment_status=t.invoice.payment_status.value if t.invoice else None,
                remaining_balance=t.invoice.balance_due if t.invoice else None,
                demo_disclaimer="DEMO MODE — SIMULATED PAYMENT — NO REAL MONEY TRANSFERRED",
            )
            for t in items
        ],
        total=total,
        page=page,
        limit=limit,
    )


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
