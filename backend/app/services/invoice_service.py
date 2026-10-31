import datetime
import uuid
from decimal import Decimal
from typing import List, Optional, Tuple
from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.invoice import (
    Invoice,
    InvoiceItem,
    InvoicePaymentStatus,
    InvoiceStatus,
)
from app.models.subscription import PaymentTerms, SubscriptionStatus
from app.models.user import User, UserRole
from app.repositories.customer_repo import CustomerRepository
from app.repositories.invoice_repo import InvoiceRepository
from app.repositories.subscription_repo import SubscriptionRepository
from app.schemas.invoice import InvoiceCreateRequest
from app.services.audit_service import AuditService


class InvoiceService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.repo = InvoiceRepository(session)
        self.subscription_repo = SubscriptionRepository(session)
        self.customer_repo = CustomerRepository(session)
        self.audit_service = AuditService(session)

    def _calculate_due_date(self, issue_date: datetime.datetime, terms: PaymentTerms) -> datetime.datetime:
        if terms == PaymentTerms.IMMEDIATE:
            return issue_date
        elif terms == PaymentTerms.NET_15:
            return issue_date + datetime.timedelta(days=15)
        elif terms == PaymentTerms.NET_30:
            return issue_date + datetime.timedelta(days=30)
        elif terms == PaymentTerms.NET_60:
            return issue_date + datetime.timedelta(days=60)
        return issue_date + datetime.timedelta(days=30)

    async def get_invoice(self, invoice_id: uuid.UUID, current_user: User) -> Invoice:
        invoice = await self.repo.get_by_id(invoice_id)
        if not invoice:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Invoice with ID '{invoice_id}' not found.",
            )

        # Enforce Customer Isolation
        if current_user.role == UserRole.CUSTOMER:
            if not invoice.customer or invoice.customer.user_id != current_user.id:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Access denied. You may only view your own invoices.",
                )

        return invoice

    async def list_invoices(
        self,
        current_user: User,
        customer_id: Optional[uuid.UUID] = None,
        subscription_id: Optional[uuid.UUID] = None,
        status_filter: Optional[InvoiceStatus] = None,
        payment_status_filter: Optional[InvoicePaymentStatus] = None,
        search: Optional[str] = None,
        page: int = 1,
        limit: int = 20,
    ) -> Tuple[List[Invoice], int]:
        effective_customer_id = customer_id

        if current_user.role == UserRole.CUSTOMER:
            customer = await self.customer_repo.get_by_user_id(current_user.id)
            if not customer:
                return [], 0
            effective_customer_id = customer.id

        return await self.repo.list_invoices(
            customer_id=effective_customer_id,
            subscription_id=subscription_id,
            status=status_filter,
            payment_status=payment_status_filter,
            search=search,
            page=page,
            limit=limit,
        )

    async def create_invoice_from_subscription(
        self,
        data: InvoiceCreateRequest,
        operator: Optional[User] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> Invoice:
        # Customers cannot generate invoices
        if operator and operator.role == UserRole.CUSTOMER:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Customers are not permitted to generate invoices.",
            )

        subscription = await self.subscription_repo.get_by_id(data.subscription_id)
        if not subscription:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Subscription with ID '{data.subscription_id}' not found.",
            )

        # Allow invoicing for CONFIRMED or ACTIVE subscriptions
        if subscription.status not in (SubscriptionStatus.CONFIRMED, SubscriptionStatus.ACTIVE):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Cannot generate invoice for subscription in '{subscription.status.value}' status. Subscription must be CONFIRMED or ACTIVE.",
            )

        issue_date = data.issue_date or datetime.datetime.now(datetime.timezone.utc)
        due_date = self._calculate_due_date(issue_date, subscription.payment_terms)

        period_start = data.billing_period_start or subscription.start_date
        period_end = data.billing_period_end or (
            subscription.expiry_date
            if subscription.expiry_date
            else (period_start + datetime.timedelta(days=30))
        )

        # Duplicate billing period guard
        is_overlapping = await self.repo.check_overlapping_period(
            subscription_id=subscription.id,
            period_start=period_start,
            period_end=period_end,
        )
        if is_overlapping:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"An active invoice already exists covering the billing window {period_start.date().isoformat()} to {period_end.date().isoformat()} for this subscription.",
            )

        # Financial Calculations with Decimal Precision
        tax_rate = (data.tax_rate if data.tax_rate is not None else subscription.tax_rate).quantize(Decimal("0.0001"))
        discount_amount = (
            data.discount_amount if data.discount_amount is not None else subscription.discount_amount
        ).quantize(Decimal("0.0001"))

        subtotal = subscription.subtotal.quantize(Decimal("0.0001"))
        if discount_amount > subtotal:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Discount amount cannot exceed the invoice subtotal.",
            )

        taxable_base = subtotal - discount_amount
        tax_amount = (taxable_base * (tax_rate / Decimal("100.0000"))).quantize(Decimal("0.0001"))
        total_amount = (taxable_base + tax_amount).quantize(Decimal("0.0001"))
        amount_paid = Decimal("0.0000")
        balance_due = total_amount

        invoice_number = await self.repo.get_next_invoice_number()

        invoice = Invoice(
            invoice_number=invoice_number,
            subscription_id=subscription.id,
            customer_id=subscription.customer_id,
            status=InvoiceStatus.CONFIRMED,
            payment_status=InvoicePaymentStatus.UNPAID,
            issue_date=issue_date,
            due_date=due_date,
            billing_period_start=period_start,
            billing_period_end=period_end,
            currency=subscription.currency,
            subtotal=subtotal,
            tax_rate=tax_rate,
            tax_amount=tax_amount,
            discount_amount=discount_amount,
            total_amount=total_amount,
            amount_paid=amount_paid,
            balance_due=balance_due,
            discount_rule_id=subscription.discount_rule_id,
            notes=data.notes,
            created_by_id=operator.id if operator else None,
        )

        for s_item in subscription.items:
            desc = s_item.product.name if s_item.product else "Subscription Item"
            if s_item.variant:
                desc = f"{desc} ({s_item.variant.variant_name})"

            inv_item = InvoiceItem(
                product_id=s_item.product_id,
                variant_id=s_item.variant_id,
                description=desc,
                quantity=s_item.quantity,
                unit_price=s_item.unit_price,
                subtotal=s_item.subtotal,
            )
            invoice.items.append(inv_item)

        created_inv = await self.repo.create(invoice)

        await self.audit_service.log(
            action="INVOICE_GENERATED",
            resource_type="invoice",
            user_id=operator.id,
            resource_id=str(created_inv.id),
            details={
                "invoice_number": created_inv.invoice_number,
                "subscription_id": str(subscription.id),
                "total_amount": str(created_inv.total_amount),
            },
            ip_address=ip_address,
            user_agent=user_agent,
        )

        return created_inv

    async def transition_invoice_status(
        self,
        invoice_id: uuid.UUID,
        to_status: InvoiceStatus,
        notes: Optional[str],
        operator: User,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> Invoice:
        if operator.role == UserRole.CUSTOMER:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Customers are not permitted to change invoice status.",
            )

        invoice = await self.repo.get_by_id(invoice_id)
        if not invoice:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Invoice with ID '{invoice_id}' not found.",
            )

        if to_status == InvoiceStatus.CANCELLED:
            if invoice.amount_paid > Decimal("0.0000"):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Cannot cancel an invoice with recorded payments. Balance must be refunded or cleared first.",
                )
            if invoice.status == InvoiceStatus.PAID:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Cannot cancel a fully paid invoice.",
                )

        from_status = invoice.status.value
        invoice.status = to_status
        if notes:
            invoice.notes = f"{invoice.notes or ''}\nStatus update: {notes}".strip()

        updated_inv = await self.repo.update(invoice)

        await self.audit_service.log(
            action="INVOICE_STATUS_CHANGED",
            resource_type="invoice",
            user_id=operator.id,
            resource_id=str(invoice.id),
            details={
                "from_status": from_status,
                "to_status": to_status.value,
                "notes": notes,
            },
            ip_address=ip_address,
            user_agent=user_agent,
        )

        return updated_inv

    create_invoice = create_invoice_from_subscription
