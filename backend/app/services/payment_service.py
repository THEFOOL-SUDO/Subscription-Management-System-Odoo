import datetime
import uuid
from decimal import Decimal
from typing import List, Optional, Tuple
from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.invoice import InvoicePaymentStatus, InvoiceStatus
from app.models.payment import Payment
from app.models.subscription import SubscriptionStatus, SubscriptionStatusHistory
from app.models.user import User, UserRole
from app.repositories.customer_repo import CustomerRepository
from app.repositories.invoice_repo import InvoiceRepository
from app.repositories.payment_repo import PaymentRepository
from app.repositories.subscription_repo import SubscriptionRepository
from app.schemas.payment import PaymentCreateRequest
from app.services.audit_service import AuditService


class PaymentService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.repo = PaymentRepository(session)
        self.invoice_repo = InvoiceRepository(session)
        self.subscription_repo = SubscriptionRepository(session)
        self.customer_repo = CustomerRepository(session)
        self.audit_service = AuditService(session)

    async def get_payment(self, payment_id: uuid.UUID, current_user: User) -> Payment:
        payment = await self.repo.get_by_id(payment_id)
        if not payment:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Payment with ID '{payment_id}' not found.",
            )

        if current_user.role == UserRole.CUSTOMER:
            if not payment.customer or payment.customer.user_id != current_user.id:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Access denied. You may only view your own payments.",
                )

        return payment

    async def list_payments(
        self,
        current_user: User,
        invoice_id: Optional[uuid.UUID] = None,
        customer_id: Optional[uuid.UUID] = None,
        page: int = 1,
        limit: int = 20,
    ) -> Tuple[List[Payment], int]:
        effective_customer_id = customer_id

        if current_user.role == UserRole.CUSTOMER:
            customer = await self.customer_repo.get_by_user_id(current_user.id)
            if not customer:
                return [], 0
            effective_customer_id = customer.id

        return await self.repo.list_payments(
            invoice_id=invoice_id,
            customer_id=effective_customer_id,
            page=page,
            limit=limit,
        )

    async def record_payment(
        self,
        data: PaymentCreateRequest,
        operator: User,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> Payment:
        if operator.role == UserRole.CUSTOMER:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Customers cannot record manual offline payments. Please contact billing support.",
            )

        invoice = await self.invoice_repo.get_by_id(data.invoice_id)
        if not invoice:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Invoice with ID '{data.invoice_id}' not found.",
            )

        if invoice.status == InvoiceStatus.CANCELLED:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot record payment against a cancelled invoice.",
            )

        if invoice.status == InvoiceStatus.PAID or invoice.balance_due <= Decimal("0.0000"):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="This invoice has already been paid in full.",
            )

        amount = Decimal(str(data.amount)).quantize(Decimal("0.0001"))
        if amount <= Decimal("0.0000"):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Payment amount must be greater than zero.",
            )

        # Overpayment guard
        if amount > invoice.balance_due:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Overpayment rejected: payment amount ({amount}) exceeds remaining balance due ({invoice.balance_due}).",
            )

        # Transactional update of financial balance
        new_paid = (invoice.amount_paid + amount).quantize(Decimal("0.0001"))
        new_balance = (invoice.balance_due - amount).quantize(Decimal("0.0001"))

        invoice.amount_paid = new_paid
        invoice.balance_due = new_balance

        is_full_payment = new_balance <= Decimal("0.0000")
        if is_full_payment:
            invoice.payment_status = InvoicePaymentStatus.PAID
            invoice.status = InvoiceStatus.PAID
        else:
            invoice.payment_status = InvoicePaymentStatus.PARTIALLY_PAID

        await self.invoice_repo.update(invoice)

        # Generate unique payment record
        pay_number = await self.repo.get_next_payment_number()
        payment_date = data.payment_date or datetime.datetime.now(datetime.timezone.utc)

        payment = Payment(
            payment_number=pay_number,
            invoice_id=invoice.id,
            customer_id=invoice.customer_id,
            amount=amount,
            currency=invoice.currency,
            payment_method=data.payment_method,
            payment_date=payment_date,
            reference_number=data.reference_number,
            notes=data.notes,
            recorded_by_id=operator.id,
        )
        created_payment = await self.repo.create(payment)

        # Lifecycle Hook: If initial invoice is fully paid and subscription is CONFIRMED, promote to ACTIVE
        if is_full_payment and invoice.subscription:
            subscription = await self.subscription_repo.get_by_id(invoice.subscription_id)
            if subscription and subscription.status == SubscriptionStatus.CONFIRMED:
                subscription.status = SubscriptionStatus.ACTIVE
                subscription.updated_by_id = operator.id
                history = SubscriptionStatusHistory(
                    subscription_id=subscription.id,
                    from_status=SubscriptionStatus.CONFIRMED.value,
                    to_status=SubscriptionStatus.ACTIVE.value,
                    reason=f"Auto-activated upon full payment of invoice {invoice.invoice_number}",
                    changed_by_id=operator.id,
                )
                await self.subscription_repo.add_status_history(history)
                await self.subscription_repo.update(subscription)

        await self.audit_service.log(
            action="PAYMENT_RECORDED",
            resource_type="payment",
            user_id=operator.id,
            resource_id=str(created_payment.id),
            details={
                "payment_number": created_payment.payment_number,
                "invoice_number": invoice.invoice_number,
                "amount": str(created_payment.amount),
                "is_full_payment": is_full_payment,
            },
            ip_address=ip_address,
            user_agent=user_agent,
        )

        return created_payment

