import datetime
import re
import uuid
from typing import List, Optional
from pydantic import BaseModel, ConfigDict, Field, field_validator
from app.models.customer import CustomerStatus


class CustomerBase(BaseModel):
    name: str = Field(..., min_length=2, max_length=255, description="Full customer or business name")
    email: str = Field(..., min_length=5, max_length=255, description="Primary contact email")
    phone: Optional[str] = Field(None, max_length=50, description="Phone number")
    company_name: Optional[str] = Field(None, max_length=255, description="Company or organization name")
    billing_address_line1: Optional[str] = Field(None, max_length=255, description="Street address line 1")
    billing_address_line2: Optional[str] = Field(None, max_length=255, description="Street address line 2")
    billing_city: Optional[str] = Field(None, max_length=100, description="City")
    billing_state: Optional[str] = Field(None, max_length=100, description="State / Province")
    billing_postal_code: Optional[str] = Field(None, max_length=20, description="Postal / ZIP code")
    billing_country: str = Field(default="India", max_length=100, description="Country")

    @field_validator("email")
    @classmethod
    def validate_email_format(cls, v: str) -> str:
        clean = v.strip().lower()
        if not re.match(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$", clean):
            raise ValueError("Invalid email address format.")
        return clean

    @field_validator("name")
    @classmethod
    def validate_name(cls, v: str) -> str:
        clean = v.strip()
        if len(clean) < 2:
            raise ValueError("Customer name must be at least 2 characters long.")
        return clean


class CustomerCreate(CustomerBase):
    pass


class CustomerUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=2, max_length=255)
    phone: Optional[str] = Field(None, max_length=50)
    company_name: Optional[str] = Field(None, max_length=255)
    billing_address_line1: Optional[str] = Field(None, max_length=255)
    billing_address_line2: Optional[str] = Field(None, max_length=255)
    billing_city: Optional[str] = Field(None, max_length=100)
    billing_state: Optional[str] = Field(None, max_length=100)
    billing_postal_code: Optional[str] = Field(None, max_length=20)
    billing_country: Optional[str] = Field(None, max_length=100)
    status: Optional[CustomerStatus] = None

    @field_validator("name")
    @classmethod
    def validate_optional_name(cls, v: Optional[str]) -> Optional[str]:
        if v is not None:
            clean = v.strip()
            if len(clean) < 2:
                raise ValueError("Customer name must be at least 2 characters long.")
            return clean
        return None


class CustomerResponse(CustomerBase):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    user_id: Optional[uuid.UUID] = None
    customer_number: str
    status: CustomerStatus
    created_by_id: Optional[uuid.UUID] = None
    updated_by_id: Optional[uuid.UUID] = None
    created_at: datetime.datetime
    updated_at: datetime.datetime


class CustomerListResponse(BaseModel):
    items: List[CustomerResponse]
    total: int
    page: int
    size: int
    pages: int

