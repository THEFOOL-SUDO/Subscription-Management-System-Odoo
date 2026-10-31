import math
import uuid
from typing import Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.core.dependencies import require_roles
from app.models.user import User, UserRole
from app.repositories.audit_repo import AuditLogRepository
from app.schemas.audit_log import AuditLogListResponse, AuditLogResponse

router = APIRouter(prefix="/audit-logs", tags=["Audit Trail"])


@router.get("", response_model=AuditLogListResponse)
async def list_audit_logs(
    page: int = Query(1, ge=1, description="Page number"),
    size: int = Query(20, ge=1, le=100, description="Items per page"),
    action: Optional[str] = Query(None, description="Filter by action name"),
    user_id: Optional[uuid.UUID] = Query(None, description="Filter by user UUID"),
    current_user: User = Depends(require_roles(UserRole.ADMIN, UserRole.STAFF)),
    db: AsyncSession = Depends(get_db),
):
    """View system audit logs (ADMIN and STAFF only)."""
    repo = AuditLogRepository(db)
    items, total = await repo.list_audit_logs(
        page=page,
        size=size,
        action=action,
        user_id=user_id,
    )
    pages = math.ceil(total / size) if total > 0 else 1

    formatted_items = []
    for log_record, user_email in items:
        resp = AuditLogResponse(
            id=log_record.id,
            user_id=log_record.user_id,
            user_email=user_email,
            action=log_record.action,
            resource_type=log_record.resource_type,
            resource_id=log_record.resource_id,
            details=log_record.details,
            ip_address=log_record.ip_address,
            user_agent=log_record.user_agent,
            created_at=log_record.created_at,
        )
        formatted_items.append(resp)

    return AuditLogListResponse(
        items=formatted_items,
        total=total,
        page=page,
        size=size,
        pages=pages,
    )
