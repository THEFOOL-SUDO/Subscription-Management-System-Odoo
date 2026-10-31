from decimal import Decimal
from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.user import User, UserRole
from app.repositories.customer_repo import CustomerRepository
from app.repositories.dashboard_repo import DashboardRepository
from app.schemas.dashboard import (
    DashboardMetricsResponse,
    RecentPaymentItem,
    RecentSubscriptionItem,
    RevenueTrendPoint,
)


class DashboardService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.repo = DashboardRepository(session)
        self.customer_repo = CustomerRepository(session)

    async def get_metrics(self, current_user: User) -> DashboardMetricsResponse:
        customer_id = None
        if current_user.role == UserRole.CUSTOMER:
            customer = await self.customer_repo.get_by_user_id(current_user.id)
            if not customer:
                return DashboardMetricsResponse(
                    active_subscriptions=0,
                    total_customers=1,
                    revenue_collected=Decimal("0.0000"),  # type: ignore
                    outstanding_invoice_amount=Decimal("0.0000"),  # type: ignore
                    overdue_invoices=0,
                    currency="INR",
                    revenue_trend=[],
                    recent_payments=[],
                    recent_subscriptions=[],
                )
            customer_id = customer.id

        active_subs = await self.repo.count_active_subscriptions(customer_id)
        total_cust = 1 if customer_id else await self.repo.count_total_customers()
        rev_collected = await self.repo.total_revenue_collected(customer_id)
        outstanding = await self.repo.total_outstanding_amount(customer_id)
        overdue = await self.repo.count_overdue_invoices(customer_id)

        recent_pays_raw = await self.repo.get_recent_payments(5, customer_id)
        recent_subs_raw = await self.repo.get_recent_subscriptions(5, customer_id)
        trend_raw = await self.repo.get_revenue_trend(customer_id)

        recent_payments = [
            RecentPaymentItem(
                id=p.id,
                payment_number=p.payment_number,
                customer_name=p.customer.name if p.customer else "Unknown",
                amount=p.amount,
                currency=p.currency,
                payment_method=p.payment_method.value,
                payment_date=p.payment_date,
            )
            for p in recent_pays_raw
        ]

        recent_subscriptions = [
            RecentSubscriptionItem(
                id=s.id,
                subscription_number=s.subscription_number,
                customer_name=s.customer.name if s.customer else "Unknown",
                plan_name=s.plan.name if s.plan else "Unknown",
                status=s.status.value,
                total_amount=s.total_amount,
                currency=s.currency,
                created_at=s.created_at,
            )
            for s in recent_subs_raw
        ]

        revenue_trend = [
            RevenueTrendPoint(
                period=period,
                revenue=rev,
                payments_count=count,
            )
            for period, rev, count in trend_raw
        ]

        return DashboardMetricsResponse(
            active_subscriptions=active_subs,
            total_customers=total_cust,
            revenue_collected=rev_collected,
            outstanding_invoice_amount=outstanding,
            overdue_invoices=overdue,
            currency="INR",
            revenue_trend=revenue_trend,
            recent_payments=recent_payments,
            recent_subscriptions=recent_subscriptions,
        )
