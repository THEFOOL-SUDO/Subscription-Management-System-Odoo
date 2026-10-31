import datetime
import uuid
from decimal import Decimal
from typing import List, Optional
from pydantic import BaseModel, ConfigDict, Field


class DiscountRuleBase(BaseModel):
    code: str = Field(..., max_length=50)
    name: str = Field(..., max_length=255)
    description: Optional[str] = None
    discount_type: str = Field(..., description="PERCENTAGE or FIXED_AMOUNT")
    discount_value: Decimal = Field(..., gt=0)
    min_purchase_amount: Optional[Decimal] = None
    min_quantity: Optional[int] = None
    max_uses: Optional[int] = None
    valid_from: Optional[datetime.datetime] = None
    valid_until: Optional[datetime.datetime] = None
    is_active: bool = True
    scope: str = Field("SUBSCRIPTION", description="SUBSCRIPTION, INVOICE, or PRODUCT")
    product_id: Optional[uuid.UUID] = None


class DiscountRuleCreate(DiscountRuleBase):
    pass


class DiscountRuleUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    discount_value: Optional[Decimal] = None
    min_purchase_amount: Optional[Decimal] = None
    min_quantity: Optional[int] = None
    max_uses: Optional[int] = None
    valid_from: Optional[datetime.datetime] = None
    valid_until: Optional[datetime.datetime] = None
    is_active: Optional[bool] = None


class DiscountValidateRequest(BaseModel):
    code: str
    amount: Decimal
    product_ids: Optional[List[uuid.UUID]] = None


class DiscountValidateResponse(BaseModel):
    is_valid: bool
    rule_id: Optional[uuid.UUID] = None
    code: str
    discount_type: Optional[str] = None
    discount_value: Optional[Decimal] = None
    calculated_discount: Decimal = Decimal("0.0000")
    message: str


class DiscountRuleResponse(DiscountRuleBase):
    id: uuid.UUID
    current_uses: int
    created_at: datetime.datetime
    updated_at: datetime.datetime

    model_config = ConfigDict(from_attributes=True)


class DiscountRuleListResponse(BaseModel):
    items: List[DiscountRuleResponse]
    total: int
