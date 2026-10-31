from typing import Any, Dict
from fastapi import APIRouter, Depends, Request
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.core.dependencies import get_client_info, require_roles
from app.models.user import User, UserRole
from app.services.billing_scheduler_service import BillingSchedulerService

router = APIRouter(prefix="/billing", tags=["Recurring Billing"])


@router.post("/run-scheduler", response_model=Dict[str, Any])
async def trigger_billing_scheduler(
    request: Request,
    current_user: User = Depends(require_roles(UserRole.ADMIN, UserRole.STAFF)),
    db: AsyncSession = Depends(get_db),
):
    """
    On-demand execution of the recurring billing engine.
    Scans for due subscriptions, generates recurring invoices, and sends emails.
    """
    ip, user_agent = get_client_info(request)
    svc = BillingSchedulerService(db)
    return await svc.run_billing_cycle(
        operator=current_user,
        ip_address=ip,
        user_agent=user_agent,
    )
