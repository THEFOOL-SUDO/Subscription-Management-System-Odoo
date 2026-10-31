from typing import Optional
from fastapi import APIRouter, Cookie, Depends, HTTPException, Request, Response, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.config import settings
from app.core.database import get_db
from app.core.dependencies import get_client_info, get_current_user
from app.core.rate_limiter import check_rate_limit
from app.models.user import User
from app.schemas.auth import (
    ChangePasswordRequest,
    ForgotPasswordRequest,
    LoginRequest,
    RegisterRequest,
    ResetPasswordRequest,
    TokenResponse,
)
from app.schemas.common import MessageResponse
from app.schemas.user import UserResponse, UserUpdateRequest
from app.services.auth_service import AuthService
from app.services.user_service import UserService

router = APIRouter(prefix="/auth", tags=["Authentication"])


def _set_refresh_cookie(response: Response, refresh_token: str) -> None:
    """Helper to set secure httpOnly refresh token cookie."""
    response.set_cookie(
        key="refresh_token",
        value=refresh_token,
        max_age=settings.REFRESH_TOKEN_EXPIRE_DAYS * 86400,
        httponly=True,
        secure=settings.is_production,
        samesite="lax",
        path="/api/v1/auth",
    )


def _clear_refresh_cookie(response: Response) -> None:
    """Helper to clear refresh token cookie."""
    response.delete_cookie(
        key="refresh_token",
        path="/api/v1/auth",
        httponly=True,
        samesite="lax",
    )


@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
async def register(
    payload: RegisterRequest,
    request: Request,
    response: Response,
    db: AsyncSession = Depends(get_db),
):
    """Register a new customer account."""
    ip, user_agent = get_client_info(request)
    allowed, _, retry_after = await check_rate_limit(f"register:{ip or 'unknown'}", max_requests=10, window_seconds=60)
    if not allowed:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=f"Rate limit exceeded. Try again in {retry_after} seconds.",
        )

    auth_svc = AuthService(db)
    user, access_token, refresh_token = await auth_svc.register_customer(
        data=payload,
        ip_address=ip,
        user_agent=user_agent,
    )
    _set_refresh_cookie(response, refresh_token)
    return TokenResponse(access_token=access_token, user=UserResponse.model_validate(user))


@router.post("/login", response_model=TokenResponse)
async def login(
    payload: LoginRequest,
    request: Request,
    response: Response,
    db: AsyncSession = Depends(get_db),
):
    """Authenticate with email and password."""
    ip, user_agent = get_client_info(request)
    allowed, _, retry_after = await check_rate_limit(f"login:{ip or 'unknown'}", max_requests=15, window_seconds=60)
    if not allowed:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=f"Too many login attempts. Please wait {retry_after} seconds before trying again.",
        )

    auth_svc = AuthService(db)
    user, access_token, refresh_token = await auth_svc.login(
        data=payload,
        ip_address=ip,
        user_agent=user_agent,
    )
    _set_refresh_cookie(response, refresh_token)
    return TokenResponse(access_token=access_token, user=UserResponse.model_validate(user))


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(
    request: Request,
    response: Response,
    refresh_token: Optional[str] = Cookie(None),
    db: AsyncSession = Depends(get_db),
):
    """Rotate refresh token and issue a new access token."""
    if not refresh_token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Refresh token cookie missing.",
        )

    ip, user_agent = get_client_info(request)
    auth_svc = AuthService(db)
    try:
        user, new_access_token, new_refresh_token = await auth_svc.rotate_refresh_token(
            raw_refresh_token=refresh_token,
            ip_address=ip,
            user_agent=user_agent,
        )
        _set_refresh_cookie(response, new_refresh_token)
        return TokenResponse(access_token=new_access_token, user=UserResponse.model_validate(user))
    except HTTPException:
        _clear_refresh_cookie(response)
        raise


@router.post("/logout", response_model=MessageResponse)
async def logout(
    request: Request,
    response: Response,
    refresh_token: Optional[str] = Cookie(None),
    current_user: Optional[User] = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Revoke refresh token family and clear session cookies."""
    ip, user_agent = get_client_info(request)
    auth_svc = AuthService(db)
    user_id = current_user.id if current_user else None
    await auth_svc.logout(
        raw_refresh_token=refresh_token,
        user_id=user_id,
        ip_address=ip,
        user_agent=user_agent,
    )
    _clear_refresh_cookie(response)
    return MessageResponse(message="Successfully logged out.")


@router.post("/forgot-password", response_model=MessageResponse)
async def forgot_password(
    payload: ForgotPasswordRequest,
    request: Request,
    db: AsyncSession = Depends(get_db),
):
    """Request password reset link. Returns generic message to prevent email enumeration."""
    ip, user_agent = get_client_info(request)
    allowed, _, retry_after = await check_rate_limit(f"forgot_pwd:{ip or 'unknown'}", max_requests=5, window_seconds=60)
    if not allowed:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=f"Rate limit exceeded. Try again in {retry_after} seconds.",
        )

    auth_svc = AuthService(db)
    await auth_svc.forgot_password(
        email=payload.email,
        ip_address=ip,
        user_agent=user_agent,
    )
    return MessageResponse(
        message="If that email address is registered, password reset instructions have been sent."
    )


@router.post("/reset-password", response_model=MessageResponse)
async def reset_password(
    payload: ResetPasswordRequest,
    request: Request,
    response: Response,
    db: AsyncSession = Depends(get_db),
):
    """Reset password using verified single-use reset token."""
    ip, user_agent = get_client_info(request)
    auth_svc = AuthService(db)
    await auth_svc.reset_password(
        raw_token=payload.token,
        new_password=payload.new_password,
        ip_address=ip,
        user_agent=user_agent,
    )
    _clear_refresh_cookie(response)
    return MessageResponse(
        message="Password has been successfully reset. You may now log in with your new credentials."
    )


@router.get("/me", response_model=UserResponse)
async def get_me(current_user: User = Depends(get_current_user)):
    """Retrieve current authenticated user profile."""
    return UserResponse.model_validate(current_user)


@router.patch("/me", response_model=UserResponse)
async def update_me(
    payload: UserUpdateRequest,
    request: Request,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Update profile information (e.g. full name)."""
    ip, user_agent = get_client_info(request)
    user_svc = UserService(db)
    updated = await user_svc.update_profile(
        user_id=current_user.id,
        data=payload,
        ip_address=ip,
        user_agent=user_agent,
    )
    return UserResponse.model_validate(updated)


@router.post("/change-password", response_model=MessageResponse)
async def change_password(
    payload: ChangePasswordRequest,
    request: Request,
    response: Response,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Change password with verification of current password."""
    ip, user_agent = get_client_info(request)
    user_svc = UserService(db)
    await user_svc.change_password(
        user_id=current_user.id,
        current_password=payload.current_password,
        new_password=payload.new_password,
        ip_address=ip,
        user_agent=user_agent,
    )
    _clear_refresh_cookie(response)
    return MessageResponse(message="Password changed successfully. Please log in with your new password.")
