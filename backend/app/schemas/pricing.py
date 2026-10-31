import uuid
from decimal import Decimal
from typing import List, Optional
from pydantic import BaseModel, Field
from app.models.product import AdjustmentType


class PriceCalculationItem(BaseModel):
    product_id: uuid.UUID
    variant_id: Optional[uuid.UUID] = None
    quantity: int = Field(default=1, ge=1)
    price_override: Optional[Decimal] = Field(None, ge=Decimal("0.0000"))


class PriceCalculationRequest(BaseModel):
    items: List[PriceCalculationItem] = Field(..., min_length=1)
    currency: Optional[str] = "INR"


class PriceCalculationItemResult(BaseModel):
    product_id: uuid.UUID
    product_name: str
    product_sku: str
    variant_id: Optional[uuid.UUID] = None
    variant_name: Optional[str] = None
    variant_code: Optional[str] = None
    base_unit_price: Decimal
    adjustment_type: Optional[AdjustmentType] = None
    adjustment_value: Optional[Decimal] = None
    effective_unit_price: Decimal
    price_override_applied: bool = False
    quantity: int
    subtotal: Decimal


class PriceCalculationResponse(BaseModel):
    items: List[PriceCalculationItemResult]
    total_price: Decimal
    currency: str

