import datetime
import uuid
from decimal import Decimal
from typing import List, Optional
from pydantic import BaseModel, ConfigDict, Field


class QuotationTemplateItemCreate(BaseModel):
    product_id: uuid.UUID
    variant_id: Optional[uuid.UUID] = None
    quantity: int = Field(1, ge=1)
    unit_price: Decimal = Field(..., ge=0)
    notes: Optional[str] = None


class QuotationTemplateItemResponse(BaseModel):
    id: uuid.UUID
    product_id: uuid.UUID
    variant_id: Optional[uuid.UUID] = None
    quantity: int
    unit_price: Decimal
    notes: Optional[str] = None
    product_name: Optional[str] = None
    variant_name: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)


class QuotationTemplateBase(BaseModel):
    code: str = Field(..., max_length=50)
    name: str = Field(..., max_length=255)
    description: Optional[str] = None
    plan_id: uuid.UUID
    validity_days: int = Field(30, ge=1, le=365)
    payment_terms: str = Field("NET_30")
    tax_rate: Decimal = Field(Decimal("18.0000"), ge=0, le=100)
    discount_amount: Decimal = Field(Decimal("0.0000"), ge=0)
    is_active: bool = True


class QuotationTemplateCreate(QuotationTemplateBase):
    items: List[QuotationTemplateItemCreate] = []


class QuotationTemplateUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    validity_days: Optional[int] = None
    payment_terms: Optional[str] = None
    tax_rate: Optional[Decimal] = None
    discount_amount: Optional[Decimal] = None
    is_active: Optional[bool] = None
    items: Optional[List[QuotationTemplateItemCreate]] = None


class QuotationConvertToSubscriptionRequest(BaseModel):
    customer_id: uuid.UUID
    start_date: datetime.datetime
    notes: Optional[str] = None


class QuotationTemplateResponse(QuotationTemplateBase):
    id: uuid.UUID
    plan_name: Optional[str] = None
    items: List[QuotationTemplateItemResponse] = []
    created_at: datetime.datetime
    updated_at: datetime.datetime

    model_config = ConfigDict(from_attributes=True)


class QuotationTemplateListResponse(BaseModel):
    items: List[QuotationTemplateResponse]
    total: int
