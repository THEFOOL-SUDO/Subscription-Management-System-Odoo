import datetime
import uuid
from typing import List, Optional
from pydantic import BaseModel, ConfigDict, EmailStr, field_validator
from app.core.security import validate_password_complexity
from app.models.user import UserRole


class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    email: EmailStr
    full_name: str
    role: UserRole
    is_active: bool
    is_verified: bool
    created_at: datetime.datetime
    updated_at: datetime.datetime


class UserUpdateRequest(BaseModel):
    full_name: Optional[str] = None

    @field_validator("full_name")
    @classmethod
    def validate_name(cls, v: Optional[str]) -> Optional[str]:
        if v is not None and len(v.strip()) < 2:
            raise ValueError("Full name must be at least 2 characters long.")
        return v.strip() if v is not None else None


class StaffCreateRequest(BaseModel):
    email: EmailStr
    full_name: str
    password: str

    @field_validator("full_name")
    @classmethod
    def validate_name(cls, v: str) -> str:
        clean = v.strip()
        if len(clean) < 2:
            raise ValueError("Full name must be at least 2 characters long.")
        return clean

    @field_validator("password")
    @classmethod
    def validate_pwd(cls, v: str) -> str:
        valid, msg = validate_password_complexity(v)
        if not valid:
            raise ValueError(msg)
        return v


class UserStatusUpdateRequest(BaseModel):
    is_active: bool


class UserListResponse(BaseModel):
    items: List[UserResponse]
    total: int
    page: int
    size: int
    pages: int
