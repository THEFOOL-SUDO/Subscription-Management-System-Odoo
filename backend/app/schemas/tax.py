import datetime
import uuid
from decimal import Decimal
from typing import List, Optional
from pydantic import BaseModel, ConfigDict, Field


class TaxRuleBase(BaseModel):
    name: str = Field(..., max_length=100)
    tax_rate: Decimal = Field(..., ge=0, le=100)
    country: str = Field("IND", max_length=3)
    state: Optional[str] = Field(None, max_length=100)
    is_default: bool = False
    is_active: bool = True


class TaxRuleCreate(TaxRuleBase):
    pass


class TaxRuleUpdate(BaseModel):
    name: Optional[str] = None
    tax_rate: Optional[Decimal] = None
    country: Optional[str] = None
    state: Optional[str] = None
    is_default: Optional[bool] = None
    is_active: Optional[bool] = None


class TaxRuleResponse(TaxRuleBase):
    id: uuid.UUID
    created_at: datetime.datetime
    updated_at: datetime.datetime

    model_config = ConfigDict(from_attributes=True)


class TaxRuleListResponse(BaseModel):
    items: List[TaxRuleResponse]
    total: int
