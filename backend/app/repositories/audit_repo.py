import uuid
from typing import Any, Dict, List, Optional, Tuple
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload
from app.models.audit_log import AuditLog
from app.models.user import User


class AuditLogRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def create_audit_log(
        self,
        action: str,
        resource_type: str,
        user_id: Optional[uuid.UUID] = None,
        resource_id: Optional[str] = None,
        details: Optional[Dict[str, Any]] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> AuditLog:
        log = AuditLog(
            id=uuid.uuid4(),
            user_id=user_id,
            action=action,
            resource_type=resource_type,
            resource_id=resource_id,
            details=details or {},
            ip_address=ip_address,
            user_agent=user_agent,
        )
        self.session.add(log)
        await self.session.flush()
        await self.session.refresh(log)
        return log

    async def list_audit_logs(
        self,
        page: int = 1,
        size: int = 20,
        user_id: Optional[uuid.UUID] = None,
        action: Optional[str] = None,
    ) -> Tuple[List[Tuple[AuditLog, Optional[str]]], int]:
        filters = []
        if user_id is not None:
            filters.append(AuditLog.user_id == user_id)
        if action:
            filters.append(AuditLog.action == action)

        count_stmt = select(func.count(AuditLog.id)).where(*filters)
        total_result = await self.session.execute(count_stmt)
        total = total_result.scalar_one()

        offset = (page - 1) * size
        stmt = (
            select(AuditLog, User.email)
            .outerjoin(User, AuditLog.user_id == User.id)
            .where(*filters)
            .order_by(AuditLog.created_at.desc())
            .offset(offset)
            .limit(size)
        )
        result = await self.session.execute(stmt)
        items = list(result.all())
        return items, total
