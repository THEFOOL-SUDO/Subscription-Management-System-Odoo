import datetime
import uuid
from decimal import Decimal
from typing import List, Optional
from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator
from app.models.plan import BillingInterval, PlanStatus
from app.schemas.product import ProductResponse, ProductVariantResponse


class PlanProductBase(BaseModel):
    product_id: uuid.UUID
    variant_id: Optional[uuid.UUID] = None
    default_quantity: int = Field(default=1, ge=1)
    is_optional: bool = False
    price_override: Optional[Decimal] = Field(None, ge=Decimal("0.0000"))
    is_active: bool = True

    @field_validator("price_override")
    @classmethod
    def validate_price_override(cls, v: Optional[Decimal]) -> Optional[Decimal]:
        if v is not None:
            if v < Decimal("0.0000"):
                raise ValueError("Price override cannot be negative.")
            return Decimal(str(v)).quantize(Decimal("0.0001"))
        return None


class PlanProductCreate(PlanProductBase):
    pass


class PlanProductUpdate(BaseModel):
    variant_id: Optional[uuid.UUID] = None
    default_quantity: Optional[int] = Field(None, ge=1)
    is_optional: Optional[bool] = None
    price_override: Optional[Decimal] = Field(None, ge=Decimal("0.0000"))
    is_active: Optional[bool] = None

    @field_validator("price_override")
    @classmethod
    def validate_optional_override(cls, v: Optional[Decimal]) -> Optional[Decimal]:
        if v is not None:
            if v < Decimal("0.0000"):
                raise ValueError("Price override cannot be negative.")
            return Decimal(str(v)).quantize(Decimal("0.0001"))
        return None


class PlanProductResponse(PlanProductBase):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    plan_id: uuid.UUID
    created_at: datetime.datetime
    updated_at: datetime.datetime
    product: Optional[ProductResponse] = None
    variant: Optional[ProductVariantResponse] = None


class SubscriptionPlanBase(BaseModel):
    code: str = Field(..., min_length=1, max_length=100)
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    billing_interval: BillingInterval = BillingInterval.MONTHLY
    interval_count: int = Field(default=1, ge=1)
    trial_period_days: int = Field(default=0, ge=0)
    currency: str = Field(default="INR", min_length=3, max_length=3)
    min_quantity: int = Field(default=1, ge=1)
    max_quantity: Optional[int] = Field(None, ge=1)
    is_auto_close: bool = False
    availability_start_date: Optional[datetime.datetime] = None
    availability_end_date: Optional[datetime.datetime] = None

    @field_validator("code", "name", "currency")
    @classmethod
    def clean_plan_strings(cls, v: str) -> str:
        clean = v.strip()
        if not clean:
            raise ValueError("String value cannot be empty.")
        return clean.upper() if len(clean) == 3 and clean.isalpha() else clean

    @model_validator(mode="after")
    def validate_plan_logic(self) -> "SubscriptionPlanBase":
        if self.max_quantity is not None and self.max_quantity < self.min_quantity:
            raise ValueError("max_quantity must be greater than or equal to min_quantity.")
        if (
            self.availability_start_date is not None
            and self.availability_end_date is not None
            and self.availability_end_date < self.availability_start_date
        ):
            raise ValueError("availability_end_date cannot be earlier than availability_start_date.")
        return self


class SubscriptionPlanCreate(SubscriptionPlanBase):
    status: PlanStatus = PlanStatus.DRAFT
    bundled_products: List[PlanProductCreate] = []


class SubscriptionPlanUpdate(BaseModel):
    code: Optional[str] = Field(None, min_length=1, max_length=100)
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    billing_interval: Optional[BillingInterval] = None
    interval_count: Optional[int] = Field(None, ge=1)
    trial_period_days: Optional[int] = Field(None, ge=0)
    currency: Optional[str] = Field(None, min_length=3, max_length=3)
    min_quantity: Optional[int] = Field(None, ge=1)
    max_quantity: Optional[int] = Field(None, ge=1)
    is_auto_close: Optional[bool] = None
    availability_start_date: Optional[datetime.datetime] = None
    availability_end_date: Optional[datetime.datetime] = None

    @field_validator("code", "name", "currency")
    @classmethod
    def clean_optional_strings(cls, v: Optional[str]) -> Optional[str]:
        if v is not None:
            clean = v.strip()
            if not clean:
                raise ValueError("String value cannot be empty.")
            return clean.upper() if len(clean) == 3 and clean.isalpha() else clean
        return None

    @model_validator(mode="after")
    def validate_plan_update_logic(self) -> "SubscriptionPlanUpdate":
        if (
            self.min_quantity is not None
            and self.max_quantity is not None
            and self.max_quantity < self.min_quantity
        ):
            raise ValueError("max_quantity must be greater than or equal to min_quantity.")
        if (
            self.availability_start_date is not None
            and self.availability_end_date is not None
            and self.availability_end_date < self.availability_start_date
        ):
            raise ValueError("availability_end_date cannot be earlier than availability_start_date.")
        return self


class SubscriptionPlanStatusUpdate(BaseModel):
    status: PlanStatus


class SubscriptionPlanResponse(SubscriptionPlanBase):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    status: PlanStatus
    created_at: datetime.datetime
    updated_at: datetime.datetime
    created_by_id: Optional[uuid.UUID]
    updated_by_id: Optional[uuid.UUID]
    bundled_products_count: int = 0
    calculated_total_price: Decimal = Decimal("0.0000")


class SubscriptionPlanDetailResponse(SubscriptionPlanResponse):
    bundled_products: List[PlanProductResponse] = []


class SubscriptionPlanListResponse(BaseModel):
    items: List[SubscriptionPlanResponse]
    total: int
    page: int
    limit: int
    total_pages: int


class CatalogueItemsResponse(BaseModel):
    plans: List[SubscriptionPlanResponse]
    addons: List[ProductResponse]

