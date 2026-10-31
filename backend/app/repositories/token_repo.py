import datetime
import uuid
from typing import Optional
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.token import PasswordResetToken, RefreshToken


class TokenRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    # --------------------------------------------------------------------------
    # Refresh Token Operations
    # --------------------------------------------------------------------------

    async def create_refresh_token(
        self,
        user_id: uuid.UUID,
        token_hash: str,
        family_id: uuid.UUID,
        expires_at: datetime.datetime,
        user_agent: Optional[str] = None,
        ip_address: Optional[str] = None,
    ) -> RefreshToken:
        token = RefreshToken(
            id=uuid.uuid4(),
            user_id=user_id,
            token_hash=token_hash,
            family_id=family_id,
            expires_at=expires_at,
            user_agent=user_agent,
            ip_address=ip_address,
            is_revoked=False,
            is_used=False,
        )
        self.session.add(token)
        await self.session.flush()
        await self.session.refresh(token)
        return token

    async def get_refresh_token_by_hash(self, token_hash: str) -> Optional[RefreshToken]:
        stmt = select(RefreshToken).where(RefreshToken.token_hash == token_hash)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def mark_refresh_token_used(self, token: RefreshToken) -> None:
        token.is_used = True
        await self.session.flush()

    async def revoke_refresh_token_family(self, family_id: uuid.UUID) -> int:
        """Revoke all tokens in a rotation family (used upon reuse detection or explicit family logout)."""
        stmt = (
            update(RefreshToken)
            .where(RefreshToken.family_id == family_id)
            .values(is_revoked=True)
        )
        result = await self.session.execute(stmt)
        await self.session.flush()
        return result.rowcount

    async def revoke_all_user_refresh_tokens(self, user_id: uuid.UUID) -> int:
        """Revoke all refresh tokens for a user (e.g. after password reset)."""
        stmt = (
            update(RefreshToken)
            .where(RefreshToken.user_id == user_id)
            .values(is_revoked=True)
        )
        result = await self.session.execute(stmt)
        await self.session.flush()
        return result.rowcount

    # --------------------------------------------------------------------------
    # Password Reset Token Operations
    # --------------------------------------------------------------------------

    async def create_password_reset_token(
        self,
        user_id: uuid.UUID,
        token_hash: str,
        expires_at: datetime.datetime,
    ) -> PasswordResetToken:
        token = PasswordResetToken(
            id=uuid.uuid4(),
            user_id=user_id,
            token_hash=token_hash,
            expires_at=expires_at,
            is_used=False,
        )
        self.session.add(token)
        await self.session.flush()
        await self.session.refresh(token)
        return token

    async def get_valid_password_reset_token(
        self,
        token_hash: str,
    ) -> Optional[PasswordResetToken]:
        now = datetime.datetime.now(datetime.timezone.utc)
        stmt = (
            select(PasswordResetToken)
            .where(
                PasswordResetToken.token_hash == token_hash,
                PasswordResetToken.is_used.is_(False),
                PasswordResetToken.expires_at > now,
            )
        )
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def mark_password_reset_token_used(self, token: PasswordResetToken) -> None:
        token.is_used = True
        await self.session.flush()
