from pydantic import BaseModel, EmailStr, field_validator
from app.core.security import validate_password_complexity
from app.schemas.user import UserResponse


class RegisterRequest(BaseModel):
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


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse


class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class ResetPasswordRequest(BaseModel):
    token: str
    new_password: str

    @field_validator("new_password")
    @classmethod
    def validate_pwd(cls, v: str) -> str:
        valid, msg = validate_password_complexity(v)
        if not valid:
            raise ValueError(msg)
        return v


class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str

    @field_validator("new_password")
    @classmethod
    def validate_pwd(cls, v: str) -> str:
        valid, msg = validate_password_complexity(v)
        if not valid:
            raise ValueError(msg)
        return v
