from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.core.dependencies import require_roles
from app.models.user import User, UserRole
from app.schemas.pricing import PriceCalculationRequest, PriceCalculationResponse
from app.services.pricing_service import PricingService

router = APIRouter(prefix="/pricing", tags=["Pricing Engine"])


@router.post("/calculate", response_model=PriceCalculationResponse)
async def calculate_prices(
    request: PriceCalculationRequest,
    current_user: User = Depends(require_roles(UserRole.ADMIN, UserRole.STAFF)),
    db: AsyncSession = Depends(get_db),
):
    """
    Calculate live prices for line items using authoritative backend pricing rules.
    Never trusts client-computed prices. Supports fixed and percentage variant adjustments.
    """
    svc = PricingService(db)
    return await svc.calculate_prices(request)

