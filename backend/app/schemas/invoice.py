import datetime
import uuid
from decimal import Decimal
from typing import List, Optional
from pydantic import BaseModel, ConfigDict, Field, field_validator
from app.models.invoice import InvoicePaymentStatus, InvoiceStatus
from app.schemas.customer import CustomerResponse


class InvoiceItemResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    invoice_id: uuid.UUID
    product_id: uuid.UUID
    variant_id: Optional[uuid.UUID] = None
    description: str
    quantity: int
    unit_price: Decimal
    subtotal: Decimal


class InvoiceCreateRequest(BaseModel):
    subscription_id: uuid.UUID
    issue_date: Optional[datetime.datetime] = None
    billing_period_start: Optional[datetime.datetime] = None
    billing_period_end: Optional[datetime.datetime] = None
    tax_rate: Optional[Decimal] = Field(None, ge=Decimal("0.0000"), le=Decimal("100.0000"))
    discount_amount: Optional[Decimal] = Field(None, ge=Decimal("0.0000"))
    notes: Optional[str] = None

    @field_validator("tax_rate", "discount_amount")
    @classmethod
    def validate_decimals(cls, v: Optional[Decimal]) -> Optional[Decimal]:
        if v is not None:
            return Decimal(str(v)).quantize(Decimal("0.0001"))
        return None


class InvoiceStatusTransitionRequest(BaseModel):
    to_status: InvoiceStatus
    notes: Optional[str] = Field(None, max_length=255)


class InvoiceResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    invoice_number: str
    subscription_id: uuid.UUID
    customer_id: uuid.UUID
    status: InvoiceStatus
    payment_status: InvoicePaymentStatus
    issue_date: datetime.datetime
    due_date: datetime.datetime
    billing_period_start: datetime.datetime
    billing_period_end: datetime.datetime
    currency: str
    subtotal: Decimal
    tax_rate: Decimal
    tax_amount: Decimal
    discount_amount: Decimal
    total_amount: Decimal
    amount_paid: Decimal
    balance_due: Decimal
    notes: Optional[str] = None
    created_by_id: Optional[uuid.UUID] = None
    created_at: datetime.datetime
    updated_at: datetime.datetime

    customer: Optional[CustomerResponse] = None
    items: List[InvoiceItemResponse] = []


class InvoiceListResponse(BaseModel):
    items: List[InvoiceResponse]
    total: int
    page: int
    size: int
    pages: int

