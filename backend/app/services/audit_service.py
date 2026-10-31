import uuid
from typing import Any, Dict, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from app.repositories.audit_repo import AuditLogRepository


class AuditService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.repo = AuditLogRepository(session)

    async def log(
        self,
        action: str,
        resource_type: str,
        user_id: Optional[uuid.UUID] = None,
        resource_id: Optional[str] = None,
        details: Optional[Dict[str, Any]] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ):
        """Record an audit trail event."""
        # Sanitize sensitive fields from details before persistence
        safe_details = {}
        if details:
            for k, v in details.items():
                if any(sensitive in k.lower() for sensitive in ["password", "token", "secret", "cookie"]):
                    safe_details[k] = "[REDACTED]"
                else:
                    safe_details[k] = v

        return await self.repo.create_audit_log(
            action=action,
            resource_type=resource_type,
            user_id=user_id,
            resource_id=resource_id,
            details=safe_details,
            ip_address=ip_address,
            user_agent=user_agent,
        )
