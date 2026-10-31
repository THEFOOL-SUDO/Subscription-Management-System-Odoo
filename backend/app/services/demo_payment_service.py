import datetime
import secrets
import uuid
from decimal import Decimal
from typing import Any, Dict, List, Optional, Tuple
from fastapi import HTTPException, status
import jwt
from sqlalchemy.ext.asyncio import AsyncSession
from app.config import settings
from app.models.invoice import InvoicePaymentStatus, InvoiceStatus
from app.models.payment import Payment, PaymentMethod
from app.models.payment_transaction import (
    PaymentProvider,
    PaymentTransaction,
    PaymentTransactionStatus,
)
from app.models.subscription import SubscriptionStatus, SubscriptionStatusHistory
from app.models.user import User, UserRole
from app.repositories.customer_repo import CustomerRepository
from app.repositories.invoice_repo import InvoiceRepository
from app.repositories.payment_repo import PaymentRepository
from app.repositories.payment_transaction_repo import PaymentTransactionRepository
from app.repositories.subscription_repo import SubscriptionRepository
from app.schemas.payment_transaction import (
    CheckoutSessionResponse,
    DemoPaymentProcessRequest,
    PaymentTransactionResponse,
)
from app.services.audit_service import AuditService

DEMO_DISCLAIMER = "DEMO MODE — SIMULATED PAYMENT — NO REAL MONEY TRANSFERRED"


class DemoPaymentService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.txn_repo = PaymentTransactionRepository(session)
        self.invoice_repo = InvoiceRepository(session)
        self.payment_repo = PaymentRepository(session)
        self.subscription_repo = SubscriptionRepository(session)
        self.customer_repo = CustomerRepository(session)
        self.audit_service = AuditService(session)

    async def create_checkout_session(
        self,
        invoice_id: uuid.UUID,
        current_user: User,
    ) -> CheckoutSessionResponse:
        invoice = await self.invoice_repo.get_by_id(invoice_id)
        if not invoice:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Invoice with ID '{invoice_id}' not found.",
            )

        if current_user.role == UserRole.CUSTOMER:
            if not invoice.customer or invoice.customer.user_id != current_user.id:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Access denied. You may only checkout your own invoices.",
                )

        if invoice.status == InvoiceStatus.CANCELLED:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot checkout a cancelled invoice.",
            )

        if invoice.status == InvoiceStatus.PAID or invoice.balance_due <= Decimal("0.0000"):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invoice has already been paid in full.",
            )

        # Generate a secure session token
        session_payload = {
            "sub": str(current_user.id),
            "invoice_id": str(invoice.id),
            "customer_id": str(invoice.customer_id),
            "exp": datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(hours=2),
            "type": "demo_checkout",
            "jti": secrets.token_hex(8),
        }
        session_token = jwt.encode(session_payload, settings.SECRET_KEY, algorithm=settings.ALGORITHM)

        return CheckoutSessionResponse(
            session_token=session_token,
            invoice_id=invoice.id,
            invoice_number=invoice.invoice_number,
            customer_id=invoice.customer_id,
            customer_name=invoice.customer.name if invoice.customer else "Valued Customer",
            customer_email=invoice.customer.email if invoice.customer else "",
            currency=invoice.currency,
            total_amount=invoice.total_amount,
            amount_paid=invoice.amount_paid,
            balance_due=invoice.balance_due,
            status=invoice.status,
            payment_status=invoice.payment_status,
            allowed_methods=["DEMO_UPI", "DEMO_CARD", "DEMO_NETBANKING"],
            demo_disclaimer=DEMO_DISCLAIMER,
        )

    async def process_demo_payment(
        self,
        data: DemoPaymentProcessRequest,
        current_user: User,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> PaymentTransactionResponse:
        # Decode and validate session token
        try:
            payload = jwt.decode(data.session_token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
            if payload.get("type") != "demo_checkout":
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid checkout session token.")
            invoice_id = uuid.UUID(payload.get("invoice_id"))
        except jwt.PyJWTError:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Expired or invalid checkout session token.")

        # Check idempotency first
        if data.idempotency_key:
            existing_txn = await self.txn_repo.get_by_idempotency_key(data.idempotency_key)
            if existing_txn:
                invoice = await self.invoice_repo.get_by_id(existing_txn.invoice_id)
                return PaymentTransactionResponse(
                    id=existing_txn.id,
                    transaction_reference=existing_txn.transaction_reference,
                    invoice_id=existing_txn.invoice_id,
                    customer_id=existing_txn.customer_id,
                    amount=existing_txn.amount,
                    currency=existing_txn.currency,
                    provider=existing_txn.provider,
                    payment_method=existing_txn.payment_method,
                    status=existing_txn.status,
                    idempotency_key=existing_txn.idempotency_key,
                    metadata_json=existing_txn.metadata_json,
                    created_at=existing_txn.created_at,
                    updated_at=existing_txn.updated_at,
                    invoice_number=invoice.invoice_number if invoice else None,
                    invoice_status=invoice.status.value if invoice else None,
                    invoice_payment_status=invoice.payment_status.value if invoice else None,
                    remaining_balance=invoice.balance_due if invoice else None,
                    demo_disclaimer=DEMO_DISCLAIMER,
                )

        invoice = await self.invoice_repo.get_by_id(invoice_id)
        if not invoice:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Invoice not found.")

        if current_user.role == UserRole.CUSTOMER:
            if not invoice.customer or invoice.customer.user_id != current_user.id:
                raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied.")

        if invoice.status == InvoiceStatus.CANCELLED:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invoice is cancelled.")

        if invoice.status == InvoiceStatus.PAID or invoice.balance_due <= Decimal("0.0000"):
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invoice is already fully paid.")

        # Determine payment amount
        if data.scenario == "SUCCESS_PARTIAL":
            if not data.amount:
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Amount is required for partial payment.")
            amount_to_pay = Decimal(str(data.amount)).quantize(Decimal("0.0001"))
        else:
            amount_to_pay = (Decimal(str(data.amount)) if data.amount else invoice.balance_due).quantize(Decimal("0.0001"))

        if amount_to_pay <= Decimal("0.0000"):
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Payment amount must be greater than zero.")

        if amount_to_pay > invoice.balance_due:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Overpayment rejected: payment amount ({amount_to_pay}) exceeds balance due ({invoice.balance_due}).",
            )

        # Generate unique reference
        txn_ref = f"DEMO-{secrets.token_hex(6).upper()}"

        metadata = {
            "demo_scenario": data.scenario,
            "payer_vpa": data.payer_vpa,
            "card_last4": data.card_last4,
            "bank_name": data.bank_name,
            "demo_warning": DEMO_DISCLAIMER,
        }

        # Handle failure/cancellation scenarios
        if data.scenario == "DECLINE_GENERIC":
            txn = PaymentTransaction(
                transaction_reference=txn_ref,
                invoice_id=invoice.id,
                customer_id=invoice.customer_id,
                amount=amount_to_pay,
                currency=invoice.currency,
                provider="DEMO",
                payment_method=data.payment_method,
                status=PaymentTransactionStatus.FAILED.value,
                idempotency_key=data.idempotency_key,
                metadata_json={**metadata, "failure_reason": "Simulated card decline or insufficient funds."},
            )
            created_txn = await self.txn_repo.create(txn)
            return PaymentTransactionResponse(
                id=created_txn.id,
                transaction_reference=created_txn.transaction_reference,
                invoice_id=created_txn.invoice_id,
                customer_id=created_txn.customer_id,
                amount=created_txn.amount,
                currency=created_txn.currency,
                provider=created_txn.provider,
                payment_method=created_txn.payment_method,
                status=created_txn.status,
                idempotency_key=created_txn.idempotency_key,
                metadata_json=created_txn.metadata_json,
                created_at=created_txn.created_at,
                updated_at=created_txn.updated_at,
                invoice_number=invoice.invoice_number,
                invoice_status=invoice.status.value,
                invoice_payment_status=invoice.payment_status.value,
                remaining_balance=invoice.balance_due,
                demo_disclaimer=DEMO_DISCLAIMER,
            )

        if data.scenario == "CANCEL_USER":
            txn = PaymentTransaction(
                transaction_reference=txn_ref,
                invoice_id=invoice.id,
                customer_id=invoice.customer_id,
                amount=amount_to_pay,
                currency=invoice.currency,
                provider="DEMO",
                payment_method=data.payment_method,
                status=PaymentTransactionStatus.CANCELLED.value,
                idempotency_key=data.idempotency_key,
                metadata_json={**metadata, "cancel_reason": "User cancelled payment checkout flow."},
            )
            created_txn = await self.txn_repo.create(txn)
            return PaymentTransactionResponse(
                id=created_txn.id,
                transaction_reference=created_txn.transaction_reference,
                invoice_id=created_txn.invoice_id,
                customer_id=created_txn.customer_id,
                amount=created_txn.amount,
                currency=created_txn.currency,
                provider=created_txn.provider,
                payment_method=created_txn.payment_method,
                status=created_txn.status,
                idempotency_key=created_txn.idempotency_key,
                metadata_json=created_txn.metadata_json,
                created_at=created_txn.created_at,
                updated_at=created_txn.updated_at,
                invoice_number=invoice.invoice_number,
                invoice_status=invoice.status.value,
                invoice_payment_status=invoice.payment_status.value,
                remaining_balance=invoice.balance_due,
                demo_disclaimer=DEMO_DISCLAIMER,
            )

        # SUCCESS Scenario: update balances & record in financial ledger
        new_paid = (invoice.amount_paid + amount_to_pay).quantize(Decimal("0.0001"))
        new_balance = (invoice.balance_due - amount_to_pay).quantize(Decimal("0.0001"))

        invoice.amount_paid = new_paid
        invoice.balance_due = new_balance

        is_full_payment = new_balance <= Decimal("0.0000")
        if is_full_payment:
            invoice.payment_status = InvoicePaymentStatus.PAID
            invoice.status = InvoiceStatus.PAID
        else:
            invoice.payment_status = InvoicePaymentStatus.PARTIALLY_PAID

        await self.invoice_repo.update(invoice)

        # Map demo payment method to domain PaymentMethod
        domain_method = PaymentMethod.UPI if "UPI" in data.payment_method else (
            PaymentMethod.CREDIT_CARD if "CARD" in data.payment_method else PaymentMethod.BANK_TRANSFER
        )

        pay_number = await self.payment_repo.get_next_payment_number()
        payment_record = Payment(
            payment_number=pay_number,
            invoice_id=invoice.id,
            customer_id=invoice.customer_id,
            amount=amount_to_pay,
            currency=invoice.currency,
            payment_method=domain_method,
            payment_date=datetime.datetime.now(datetime.timezone.utc),
            reference_number=txn_ref,
            notes=f"Processed via Demo Payment Gateway ({data.payment_method}). {DEMO_DISCLAIMER}",
            recorded_by_id=current_user.id,
        )
        await self.payment_repo.create(payment_record)

        # Create PaymentTransaction record
        txn = PaymentTransaction(
            transaction_reference=txn_ref,
            invoice_id=invoice.id,
            customer_id=invoice.customer_id,
            amount=amount_to_pay,
            currency=invoice.currency,
            provider="DEMO",
            payment_method=data.payment_method,
            status=PaymentTransactionStatus.SUCCESS.value,
            idempotency_key=data.idempotency_key,
            metadata_json={**metadata, "payment_number": pay_number, "is_full_payment": is_full_payment},
        )
        created_txn = await self.txn_repo.create(txn)

        # Lifecycle Hook: If initial invoice is fully paid and subscription is CONFIRMED, promote to ACTIVE
        if is_full_payment and invoice.subscription_id:
            subscription = await self.subscription_repo.get_by_id(invoice.subscription_id)
            if subscription and subscription.status == SubscriptionStatus.CONFIRMED:
                subscription.status = SubscriptionStatus.ACTIVE
                subscription.updated_by_id = current_user.id
                history = SubscriptionStatusHistory(
                    subscription_id=subscription.id,
                    from_status=SubscriptionStatus.CONFIRMED.value,
                    to_status=SubscriptionStatus.ACTIVE.value,
                    reason=f"Auto-activated upon full demo payment settlement of invoice {invoice.invoice_number}",
                    changed_by_id=current_user.id,
                )
                await self.subscription_repo.add_status_history(history)
                await self.subscription_repo.update(subscription)

        # Audit log
        await self.audit_service.log(
            action="DEMO_PAYMENT_PROCESSED",
            resource_type="payment_transaction",
            user_id=current_user.id,
            resource_id=str(created_txn.id),
            details={
                "transaction_reference": txn_ref,
                "invoice_number": invoice.invoice_number,
                "amount": str(amount_to_pay),
                "is_full_payment": is_full_payment,
                "payment_method": data.payment_method,
            },
            ip_address=ip_address,
            user_agent=user_agent,
        )

        return PaymentTransactionResponse(
            id=created_txn.id,
            transaction_reference=created_txn.transaction_reference,
            invoice_id=created_txn.invoice_id,
            customer_id=created_txn.customer_id,
            amount=created_txn.amount,
            currency=created_txn.currency,
            provider=created_txn.provider,
            payment_method=created_txn.payment_method,
            status=created_txn.status,
            idempotency_key=created_txn.idempotency_key,
            metadata_json=created_txn.metadata_json,
            created_at=created_txn.created_at,
            updated_at=created_txn.updated_at,
            invoice_number=invoice.invoice_number,
            invoice_status=invoice.status.value,
            invoice_payment_status=invoice.payment_status.value,
            remaining_balance=invoice.balance_due,
            demo_disclaimer=DEMO_DISCLAIMER,
        )

    async def list_transactions(
        self,
        current_user: User,
        invoice_id: Optional[uuid.UUID] = None,
        customer_id: Optional[uuid.UUID] = None,
        status: Optional[str] = None,
        page: int = 1,
        limit: int = 20,
    ) -> Tuple[List[PaymentTransaction], int]:
        effective_customer_id = customer_id
        if current_user.role == UserRole.CUSTOMER:
            cust = await self.customer_repo.get_by_user_id(current_user.id)
            if not cust:
                return [], 0
            effective_customer_id = cust.id

        return await self.txn_repo.list_transactions(
            invoice_id=invoice_id,
            customer_id=effective_customer_id,
            status=status,
            page=page,
            limit=limit,
        )
