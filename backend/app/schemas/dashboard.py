import datetime
import uuid
from decimal import Decimal
from typing import List
from pydantic import BaseModel, ConfigDict


class RevenueTrendPoint(BaseModel):
    period: str
    revenue: Decimal
    payments_count: int


class RecentPaymentItem(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    payment_number: str
    customer_name: str
    amount: Decimal
    currency: str
    payment_method: str
    payment_date: datetime.datetime


class RecentSubscriptionItem(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    subscription_number: str
    customer_name: str
    plan_name: str
    status: str
    total_amount: Decimal
    currency: str
    created_at: datetime.datetime


class DashboardMetricsResponse(BaseModel):
    active_subscriptions: int
    total_customers: int
    revenue_collected: Decimal
    outstanding_invoice_amount: Decimal
    overdue_invoices: int
    currency: str = "INR"
    revenue_trend: List[RevenueTrendPoint] = []
    recent_payments: List[RecentPaymentItem] = []
    recent_subscriptions: List[RecentSubscriptionItem] = []

