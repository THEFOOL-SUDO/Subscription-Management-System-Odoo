import datetime
import uuid
from decimal import Decimal
from typing import List, Optional
from pydantic import BaseModel, ConfigDict, Field, field_validator
from app.models.product import ProductType, AdjustmentType


# Variant Price History
class VariantPriceHistoryResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    variant_id: uuid.UUID
    old_adjustment_type: Optional[AdjustmentType]
    new_adjustment_type: AdjustmentType
    old_adjustment_value: Optional[Decimal]
    new_adjustment_value: Decimal
    changed_by_id: Optional[uuid.UUID]
    reason: Optional[str]
    created_at: datetime.datetime


# Variant Schemas
class ProductVariantBase(BaseModel):
    variant_name: str = Field(..., min_length=1, max_length=255)
    variant_code: str = Field(..., min_length=1, max_length=100)
    adjustment_type: AdjustmentType = AdjustmentType.FIXED_AMOUNT
    adjustment_value: Decimal = Field(default=Decimal("0.0000"))
    is_active: bool = True
    description: Optional[str] = None

    @field_validator("variant_name", "variant_code")
    @classmethod
    def clean_strings(cls, v: str) -> str:
        clean = v.strip()
        if not clean:
            raise ValueError("String value cannot be empty or only whitespace.")
        return clean

    @field_validator("adjustment_value")
    @classmethod
    def validate_adjustment_value(cls, v: Decimal) -> Decimal:
        return Decimal(str(v)).quantize(Decimal("0.0001"))


class ProductVariantCreate(ProductVariantBase):
    pass


class ProductVariantUpdate(BaseModel):
    variant_name: Optional[str] = Field(None, min_length=1, max_length=255)
    variant_code: Optional[str] = Field(None, min_length=1, max_length=100)
    adjustment_type: Optional[AdjustmentType] = None
    adjustment_value: Optional[Decimal] = None
    is_active: Optional[bool] = None
    description: Optional[str] = None
    reason: Optional[str] = None

    @field_validator("variant_name", "variant_code")
    @classmethod
    def clean_optional_strings(cls, v: Optional[str]) -> Optional[str]:
        if v is not None:
            clean = v.strip()
            if not clean:
                raise ValueError("String value cannot be empty.")
            return clean
        return None

    @field_validator("adjustment_value")
    @classmethod
    def validate_optional_adj_value(cls, v: Optional[Decimal]) -> Optional[Decimal]:
        if v is not None:
            return Decimal(str(v)).quantize(Decimal("0.0001"))
        return None


class ProductVariantResponse(ProductVariantBase):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    product_id: uuid.UUID
    created_at: datetime.datetime
    updated_at: datetime.datetime
    price_history: List[VariantPriceHistoryResponse] = []


# Product Price History
class ProductPriceHistoryResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    product_id: uuid.UUID
    price_field: str
    old_price: Optional[Decimal]
    new_price: Decimal
    changed_by_id: Optional[uuid.UUID]
    reason: Optional[str]
    created_at: datetime.datetime


# Product Schemas
class ProductBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    sku: str = Field(..., min_length=1, max_length=100)
    product_type: ProductType
    description: Optional[str] = None
    notes: Optional[str] = None
    sales_price: Decimal = Field(..., ge=Decimal("0.0000"))
    cost_price: Optional[Decimal] = Field(None, ge=Decimal("0.0000"))
    currency: str = Field(default="INR", min_length=3, max_length=3)
    is_active: bool = True

    @field_validator("name", "sku", "currency")
    @classmethod
    def clean_product_strings(cls, v: str) -> str:
        clean = v.strip()
        if not clean:
            raise ValueError("String cannot be empty.")
        return clean.upper() if len(clean) == 3 and clean.isalpha() else clean

    @field_validator("sales_price")
    @classmethod
    def validate_sales_price(cls, v: Decimal) -> Decimal:
        if v < Decimal("0.0000"):
            raise ValueError("Sales price cannot be negative.")
        return Decimal(str(v)).quantize(Decimal("0.0001"))

    @field_validator("cost_price")
    @classmethod
    def validate_cost_price(cls, v: Optional[Decimal]) -> Optional[Decimal]:
        if v is not None:
            if v < Decimal("0.0000"):
                raise ValueError("Cost price cannot be negative.")
            return Decimal(str(v)).quantize(Decimal("0.0001"))
        return None


class ProductCreate(ProductBase):
    variants: List[ProductVariantCreate] = []


class ProductUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    sku: Optional[str] = Field(None, min_length=1, max_length=100)
    product_type: Optional[ProductType] = None
    description: Optional[str] = None
    notes: Optional[str] = None
    sales_price: Optional[Decimal] = Field(None, ge=Decimal("0.0000"))
    cost_price: Optional[Decimal] = Field(None, ge=Decimal("0.0000"))
    currency: Optional[str] = Field(None, min_length=3, max_length=3)
    is_active: Optional[bool] = None
    is_archived: Optional[bool] = None
    price_change_reason: Optional[str] = None

    @field_validator("name", "sku", "currency")
    @classmethod
    def clean_update_strings(cls, v: Optional[str]) -> Optional[str]:
        if v is not None:
            clean = v.strip()
            if not clean:
                raise ValueError("String cannot be empty.")
            return clean.upper() if len(clean) == 3 and clean.isalpha() else clean
        return None

    @field_validator("sales_price")
    @classmethod
    def validate_update_sales_price(cls, v: Optional[Decimal]) -> Optional[Decimal]:
        if v is not None:
            if v < Decimal("0.0000"):
                raise ValueError("Sales price cannot be negative.")
            return Decimal(str(v)).quantize(Decimal("0.0001"))
        return None

    @field_validator("cost_price")
    @classmethod
    def validate_update_cost_price(cls, v: Optional[Decimal]) -> Optional[Decimal]:
        if v is not None:
            if v < Decimal("0.0000"):
                raise ValueError("Cost price cannot be negative.")
            return Decimal(str(v)).quantize(Decimal("0.0001"))
        return None


class ProductResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    name: str
    sku: str
    product_type: ProductType
    description: Optional[str]
    notes: Optional[str]
    sales_price: Decimal
    cost_price: Optional[Decimal]
    currency: str
    is_active: bool
    is_archived: bool
    created_at: datetime.datetime
    updated_at: datetime.datetime
    created_by_id: Optional[uuid.UUID]
    updated_by_id: Optional[uuid.UUID]
    variants_count: int = 0


class ProductDetailResponse(ProductResponse):
    variants: List[ProductVariantResponse] = []
    price_history: List[ProductPriceHistoryResponse] = []


class ProductListResponse(BaseModel):
    items: List[ProductResponse]
    total: int
    page: int
    limit: int
    total_pages: int

