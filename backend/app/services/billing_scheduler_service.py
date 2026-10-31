import datetime
import logging
from typing import Any, Dict, List, Optional
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.invoice import Invoice
from app.models.plan import BillingInterval
from app.models.subscription import Subscription, SubscriptionStatus
from app.models.user import User
from app.repositories.subscription_repo import SubscriptionRepository
from app.schemas.invoice import InvoiceCreateRequest
from app.services.audit_service import AuditService
from app.services.email_service import EmailService
from app.services.invoice_service import InvoiceService

logger = logging.getLogger(__name__)


class BillingSchedulerService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.sub_repo = SubscriptionRepository(session)
        self.inv_service = InvoiceService(session)
        self.audit_service = AuditService(session)

    async def run_billing_cycle(
        self,
        operator: Optional[User] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> Dict[str, Any]:
        """
        Scan for active subscriptions due for billing, generate invoices,
        advance next billing dates, and dispatch HTML invoice emails.
        """
        now = datetime.datetime.now(datetime.timezone.utc)

        # Find active subscriptions where next_billing_date is due (or expiry_date is due)
        stmt = (
            select(Subscription)
            .where(Subscription.status == SubscriptionStatus.ACTIVE)
            .where(
                (Subscription.next_billing_date != None) & (Subscription.next_billing_date <= now)
                | (Subscription.next_billing_date == None) & (Subscription.expiry_date != None) & (Subscription.expiry_date <= now)
            )
        )
        res = await self.session.execute(stmt)
        due_subscriptions = list(res.scalars().all())

        processed_count = 0
        invoices_generated: List[Dict[str, Any]] = []
        errors: List[str] = []

        for sub in due_subscriptions:
            processed_count += 1
            try:
                # Calculate billing period start & end
                period_start = sub.next_billing_date or now
                if sub.billing_interval == BillingInterval.YEARLY:
                    period_end = period_start + datetime.timedelta(days=365 * sub.interval_count)
                else:
                    period_end = period_start + datetime.timedelta(days=30 * sub.interval_count)

                # Generate invoice
                invoice = await self.inv_service.create_invoice(
                    data=InvoiceCreateRequest(
                        subscription_id=sub.id,
                        billing_period_start=period_start,
                        billing_period_end=period_end,
                    ),
                    operator=operator,
                    ip_address=ip_address,
                    user_agent=user_agent,
                )

                # Advance next billing date and expiry date
                sub.next_billing_date = period_end
                if sub.expiry_date:
                    sub.expiry_date = period_end

                await self.sub_repo.update(sub)

                # Dispatch invoice notification email if customer has email
                if sub.customer and sub.customer.email:
                    due_date_str = invoice.due_date.strftime("%d %b %Y") if invoice.due_date else "Upon Receipt"
                    email_sent = await EmailService.send_invoice_email(
                        recipient_email=sub.customer.email,
                        customer_name=sub.customer.name,
                        invoice_number=invoice.invoice_number,
                        total_amount=str(invoice.total_amount),
                        balance_due=str(invoice.balance_due),
                        currency=invoice.currency,
                        due_date=due_date_str,
                    )
                    if email_sent:
                        invoice.email_sent_at = datetime.datetime.now(datetime.timezone.utc)
                        await self.inv_service.repo.update(invoice)

                invoices_generated.append({
                    "subscription_number": sub.subscription_number,
                    "invoice_number": invoice.invoice_number,
                    "customer_name": sub.customer.name if sub.customer else "Unknown",
                    "total_amount": str(invoice.total_amount),
                    "next_billing_date": sub.next_billing_date.isoformat(),
                })

            except Exception as exc:
                logger.exception("Error processing subscription %s in billing cycle: %s", sub.subscription_number, exc)
                errors.append(f"Subscription {sub.subscription_number}: {str(exc)}")

        if operator:
            await self.audit_service.log(
                action="BILLING_SCHEDULER_RUN",
                resource_type="billing_cycle",
                user_id=operator.id,
                resource_id=None,
                details={
                    "processed_count": processed_count,
                    "invoices_generated": len(invoices_generated),
                    "errors_count": len(errors),
                },
                ip_address=ip_address,
                user_agent=user_agent,
            )

        return {
            "processed_count": processed_count,
            "invoices_generated_count": len(invoices_generated),
            "invoices": invoices_generated,
            "errors": errors,
            "timestamp": now.isoformat(),
        }
