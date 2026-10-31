import datetime
import uuid
from decimal import Decimal
from typing import List, Optional
from pydantic import BaseModel, ConfigDict, Field, field_validator
from app.models.payment import PaymentMethod


class PaymentCreateRequest(BaseModel):
    invoice_id: uuid.UUID
    amount: Decimal = Field(..., gt=Decimal("0.0000"), description="Positive payment amount")
    payment_method: PaymentMethod
    payment_date: Optional[datetime.datetime] = None
    reference_number: Optional[str] = Field(None, max_length=100)
    notes: Optional[str] = None

    @field_validator("amount")
    @classmethod
    def validate_amount(cls, v: Decimal) -> Decimal:
        if v <= Decimal("0.0000"):
            raise ValueError("Payment amount must be greater than zero.")
        return Decimal(str(v)).quantize(Decimal("0.0001"))


class PaymentResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    payment_number: str
    invoice_id: uuid.UUID
    customer_id: uuid.UUID
    amount: Decimal
    currency: str
    payment_method: PaymentMethod
    payment_date: datetime.datetime
    reference_number: Optional[str] = None
    notes: Optional[str] = None
    recorded_by_id: uuid.UUID
    created_at: datetime.datetime


class PaymentListResponse(BaseModel):
    items: List[PaymentResponse]
    total: int
    page: int
    size: int
    pages: int

