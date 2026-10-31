import datetime
import uuid
from decimal import Decimal
from typing import List, Optional
from pydantic import BaseModel, ConfigDict, Field, field_validator
from app.models.plan import BillingInterval
from app.models.subscription import PaymentTerms, SubscriptionStatus
from app.schemas.customer import CustomerResponse
from app.schemas.plan import SubscriptionPlanResponse
from app.schemas.product import ProductResponse, ProductVariantResponse


class SubscriptionItemCreate(BaseModel):
    product_id: uuid.UUID
    variant_id: Optional[uuid.UUID] = None
    quantity: int = Field(default=1, ge=1)
    notes: Optional[str] = None


class SubscriptionItemResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    subscription_id: uuid.UUID
    product_id: uuid.UUID
    variant_id: Optional[uuid.UUID] = None
    quantity: int
    unit_price: Decimal
    subtotal: Decimal
    notes: Optional[str] = None
    product: Optional[ProductResponse] = None
    variant: Optional[ProductVariantResponse] = None


class SubscriptionStatusHistoryResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    from_status: Optional[str] = None
    to_status: str
    reason: Optional[str] = None
    changed_by_id: Optional[uuid.UUID] = None
    created_at: datetime.datetime


class SubscriptionCreate(BaseModel):
    customer_id: uuid.UUID
    plan_id: uuid.UUID
    start_date: datetime.datetime
    payment_terms: PaymentTerms = PaymentTerms.NET_30
    tax_rate: Optional[Decimal] = Field(default=Decimal("18.0000"), ge=Decimal("0.0000"), le=Decimal("100.0000"))
    discount_amount: Optional[Decimal] = Field(default=Decimal("0.0000"), ge=Decimal("0.0000"))
    notes: Optional[str] = None
    items: Optional[List[SubscriptionItemCreate]] = None

    @field_validator("tax_rate", "discount_amount")
    @classmethod
    def validate_decimals(cls, v: Optional[Decimal]) -> Optional[Decimal]:
        if v is not None:
            return Decimal(str(v)).quantize(Decimal("0.0001"))
        return None


class SubscriptionStatusTransitionRequest(BaseModel):
    to_status: SubscriptionStatus
    reason: Optional[str] = Field(None, max_length=255)


class SubscriptionResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    subscription_number: str
    customer_id: uuid.UUID
    plan_id: uuid.UUID
    status: SubscriptionStatus
    start_date: datetime.datetime
    expiry_date: Optional[datetime.datetime] = None
    billing_interval: BillingInterval
    interval_count: int
    currency: str
    payment_terms: PaymentTerms
    subtotal: Decimal
    tax_rate: Decimal
    tax_amount: Decimal
    discount_amount: Decimal
    total_amount: Decimal
    notes: Optional[str] = None
    created_by_id: Optional[uuid.UUID] = None
    updated_by_id: Optional[uuid.UUID] = None
    created_at: datetime.datetime
    updated_at: datetime.datetime

    customer: Optional[CustomerResponse] = None
    plan: Optional[SubscriptionPlanResponse] = None
    items: List[SubscriptionItemResponse] = []
    status_history: List[SubscriptionStatusHistoryResponse] = []


class SubscriptionListResponse(BaseModel):
    items: List[SubscriptionResponse]
    total: int
    page: int
    size: int
    pages: int
