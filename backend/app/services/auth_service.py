import datetime
import uuid
from typing import Optional, Tuple
from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.config import settings
from app.core.security import (
    create_access_token,
    generate_secure_token,
    hash_password,
    hash_token,
    verify_password,
)
from app.models.user import User, UserRole
from app.repositories.token_repo import TokenRepository
from app.repositories.user_repo import UserRepository
from app.schemas.auth import LoginRequest, RegisterRequest
from app.services.audit_service import AuditService
from app.services.email_service import EmailService


class AuthService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.user_repo = UserRepository(session)
        self.token_repo = TokenRepository(session)
        self.audit_service = AuditService(session)

    async def register_customer(
        self,
        data: RegisterRequest,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> Tuple[User, str, str]:
        """Register a new customer account, returning user, access token, and raw refresh token."""
        existing_user = await self.user_repo.get_by_email(data.email)
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="An account with this email address already exists.",
            )

        hashed_pwd = hash_password(data.password)
        user = await self.user_repo.create(
            email=data.email,
            full_name=data.full_name,
            hashed_password=hashed_pwd,
            role=UserRole.CUSTOMER,  # Public registration is strictly restricted to CUSTOMER
            is_active=True,
            is_verified=True,
        )

        # Issue tokens
        access_token = create_access_token(
            user_id=user.id,
            role=user.role.value,
            email=user.email,
        )
        raw_refresh_token = generate_secure_token()
        refresh_hash = hash_token(raw_refresh_token)
        family_id = uuid.uuid4()
        expires_at = datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(
            days=settings.REFRESH_TOKEN_EXPIRE_DAYS
        )

        await self.token_repo.create_refresh_token(
            user_id=user.id,
            token_hash=refresh_hash,
            family_id=family_id,
            expires_at=expires_at,
            user_agent=user_agent,
            ip_address=ip_address,
        )

        # Audit log
        await self.audit_service.log(
            action="USER_REGISTERED",
            resource_type="user",
            user_id=user.id,
            resource_id=str(user.id),
            details={"email": user.email, "role": user.role.value},
            ip_address=ip_address,
            user_agent=user_agent,
        )

        # Send welcome email asynchronously
        await EmailService.send_welcome_email(user.email, user.full_name)

        return user, access_token, raw_refresh_token

    async def login(
        self,
        data: LoginRequest,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> Tuple[User, str, str]:
        """Authenticate user, return user, access token, and raw refresh token."""
        user = await self.user_repo.get_by_email(data.email)
        if not user or not verify_password(data.password, user.hashed_password):
            await self.audit_service.log(
                action="AUTH_LOGIN_FAILURE",
                resource_type="auth",
                user_id=user.id if user else None,
                details={"attempted_email": data.email},
                ip_address=ip_address,
                user_agent=user_agent,
            )
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password.",
            )

        if not user.is_active:
            await self.audit_service.log(
                action="AUTH_LOGIN_DEACTIVATED",
                resource_type="auth",
                user_id=user.id,
                details={"email": user.email},
                ip_address=ip_address,
                user_agent=user_agent,
            )
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Account is deactivated. Please contact an administrator.",
            )

        # Issue tokens
        access_token = create_access_token(
            user_id=user.id,
            role=user.role.value,
            email=user.email,
        )
        raw_refresh_token = generate_secure_token()
        refresh_hash = hash_token(raw_refresh_token)
        family_id = uuid.uuid4()
        expires_at = datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(
            days=settings.REFRESH_TOKEN_EXPIRE_DAYS
        )

        await self.token_repo.create_refresh_token(
            user_id=user.id,
            token_hash=refresh_hash,
            family_id=family_id,
            expires_at=expires_at,
            user_agent=user_agent,
            ip_address=ip_address,
        )

        # Audit log
        await self.audit_service.log(
            action="AUTH_LOGIN_SUCCESS",
            resource_type="auth",
            user_id=user.id,
            resource_id=str(user.id),
            details={"email": user.email, "role": user.role.value},
            ip_address=ip_address,
            user_agent=user_agent,
        )

        return user, access_token, raw_refresh_token

    async def rotate_refresh_token(
        self,
        raw_refresh_token: str,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> Tuple[User, str, str]:
        """Rotate refresh token with row locking and reuse detection."""
        token_hash = hash_token(raw_refresh_token)
        token_record = await self.token_repo.get_refresh_token_by_hash(token_hash, for_update=True)

        if not token_record:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired session. Please log in again.",
            )

        # Reuse detection: If token was already revoked or used, invalidate its entire family
        if token_record.is_revoked or token_record.is_used:
            await self.token_repo.revoke_refresh_token_family(token_record.family_id)
            await self.audit_service.log(
                action="TOKEN_REUSE_DETECTED",
                resource_type="auth",
                user_id=token_record.user_id,
                resource_id=str(token_record.id),
                details={"family_id": str(token_record.family_id), "reason": "Attempted reuse of consumed token"},
                ip_address=ip_address,
                user_agent=user_agent,
            )
            await self.session.commit()
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Security alert: Session anomaly detected. All sessions in this device family have been terminated.",
            )

        now = datetime.datetime.now(datetime.timezone.utc)
        if token_record.expires_at <= now:
            token_record.is_revoked = True
            await self.session.commit()
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Session expired. Please log in again.",
            )

        # Mark current token as consumed
        await self.token_repo.mark_refresh_token_used(token_record)

        # Verify user status
        user = await self.user_repo.get_by_id(token_record.user_id)
        if not user or not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User account is inactive or not found.",
            )

        # Generate new refresh token in the same family
        new_raw_refresh_token = generate_secure_token()
        new_refresh_hash = hash_token(new_raw_refresh_token)
        expires_at = now + datetime.timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)

        await self.token_repo.create_refresh_token(
            user_id=user.id,
            token_hash=new_refresh_hash,
            family_id=token_record.family_id,
            expires_at=expires_at,
            user_agent=user_agent,
            ip_address=ip_address,
        )

        new_access_token = create_access_token(
            user_id=user.id,
            role=user.role.value,
            email=user.email,
        )

        await self.audit_service.log(
            action="TOKEN_ROTATED",
            resource_type="auth",
            user_id=user.id,
            resource_id=str(user.id),
            details={"family_id": str(token_record.family_id)},
            ip_address=ip_address,
            user_agent=user_agent,
        )

        return user, new_access_token, new_raw_refresh_token

    async def logout(
        self,
        raw_refresh_token: Optional[str],
        user_id: Optional[uuid.UUID],
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> None:
        """Revoke refresh token family upon logout."""
        if raw_refresh_token:
            token_hash = hash_token(raw_refresh_token)
            token = await self.token_repo.get_refresh_token_by_hash(token_hash)
            if token:
                await self.token_repo.revoke_refresh_token_family(token.family_id)

        if user_id:
            await self.audit_service.log(
                action="AUTH_LOGOUT",
                resource_type="auth",
                user_id=user_id,
                resource_id=str(user_id),
                details={},
                ip_address=ip_address,
                user_agent=user_agent,
            )

    async def forgot_password(
        self,
        email: str,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> None:
        """Issue password reset token and send reset email. Uniform response to prevent email enumeration."""
        user = await self.user_repo.get_by_email(email)
        if user and user.is_active:
            # Invalidate any prior unused reset tokens for this user
            await self.token_repo.invalidate_user_password_reset_tokens(user.id)

            raw_reset_token = generate_secure_token()
            token_hash = hash_token(raw_reset_token)
            expires_at = datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(
                minutes=settings.PASSWORD_RESET_TOKEN_EXPIRE_MINUTES
            )

            await self.token_repo.create_password_reset_token(
                user_id=user.id,
                token_hash=token_hash,
                expires_at=expires_at,
            )

            await self.audit_service.log(
                action="PASSWORD_RESET_REQUESTED",
                resource_type="auth",
                user_id=user.id,
                resource_id=str(user.id),
                details={"email": user.email},
                ip_address=ip_address,
                user_agent=user_agent,
            )

            # Send reset email
            await EmailService.send_password_reset_email(
                recipient_email=user.email,
                reset_token=raw_reset_token,
                full_name=user.full_name,
            )

    async def reset_password(
        self,
        raw_token: str,
        new_password: str,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> None:
        """Verify reset token, update user password, and invalidate active sessions."""
        token_hash = hash_token(raw_token)
        token_record = await self.token_repo.get_valid_password_reset_token(token_hash, for_update=True)

        if not token_record:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid or expired password reset link.",
            )

        user = await self.user_repo.get_by_id(token_record.user_id)
        if not user or not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User account is inactive or not found.",
            )

        # Update password hash
        new_hashed_password = hash_password(new_password)
        await self.user_repo.update(user, hashed_password=new_hashed_password)

        # Consume reset token
        await self.token_repo.mark_password_reset_token_used(token_record)

        # Revoke all active refresh tokens for the user
        await self.token_repo.revoke_all_user_refresh_tokens(user.id)

        # Audit log
        await self.audit_service.log(
            action="PASSWORD_RESET_COMPLETED",
            resource_type="auth",
            user_id=user.id,
            resource_id=str(user.id),
            details={"email": user.email},
            ip_address=ip_address,
            user_agent=user_agent,
        )
