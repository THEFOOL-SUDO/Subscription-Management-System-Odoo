import math
import uuid
from typing import Optional, Tuple
from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.core.dependencies import get_client_info, get_current_user, require_roles
from app.models.plan import BillingInterval, PlanStatus
from app.models.user import User, UserRole
from app.schemas.common import MessageResponse
from app.schemas.plan import (
    PlanProductCreate,
    PlanProductResponse,
    PlanProductUpdate,
    SubscriptionPlanCreate,
    SubscriptionPlanDetailResponse,
    SubscriptionPlanListResponse,
    SubscriptionPlanResponse,
    SubscriptionPlanStatusUpdate,
    SubscriptionPlanUpdate,
)
from app.schemas.product import ProductResponse, ProductVariantResponse
from app.services.plan_service import PlanService
from app.services.pricing_service import PricingService

router = APIRouter(prefix="/plans", tags=["Subscription Plan Management"])


def _to_plan_response(plan, pricing_svc: PricingService) -> SubscriptionPlanResponse:
    resp = SubscriptionPlanResponse.model_validate(plan)
    resp.bundled_products_count = len([bp for bp in plan.bundled_products if bp.is_active])
    resp.calculated_total_price = pricing_svc.calculate_plan_total(plan)
    return resp


def _to_plan_detail_response(
    plan, pricing_svc: PricingService
) -> SubscriptionPlanDetailResponse:
    bundled_items = []
    for bp in plan.bundled_products:
        item = PlanProductResponse.model_validate(bp)
        if bp.product:
            item.product = ProductResponse.model_validate(bp.product)
        if bp.variant:
            item.variant = ProductVariantResponse.model_validate(bp.variant)
        bundled_items.append(item)

    resp = SubscriptionPlanDetailResponse(
        id=plan.id,
        code=plan.code,
        name=plan.name,
        description=plan.description,
        billing_interval=plan.billing_interval,
        interval_count=plan.interval_count,
        trial_period_days=plan.trial_period_days,
        status=plan.status,
        currency=plan.currency,
        min_quantity=plan.min_quantity,
        max_quantity=plan.max_quantity,
        is_auto_close=plan.is_auto_close,
        availability_start_date=plan.availability_start_date,
        availability_end_date=plan.availability_end_date,
        created_at=plan.created_at,
        updated_at=plan.updated_at,
        created_by_id=plan.created_by_id,
        updated_by_id=plan.updated_by_id,
        bundled_products_count=len([bp for bp in plan.bundled_products if bp.is_active]),
        calculated_total_price=pricing_svc.calculate_plan_total(plan),
        bundled_products=bundled_items,
    )
    return resp


@router.get("", response_model=SubscriptionPlanListResponse)
async def list_plans(
    page: int = Query(1, ge=1, description="Page number"),
    limit: int = Query(20, ge=1, le=100, description="Items per page"),
    search: Optional[str] = Query(None, description="Search by plan name, code or description"),
    status_filter: Optional[PlanStatus] = Query(None, alias="status", description="Filter by plan status"),
    billing_interval: Optional[BillingInterval] = Query(None, description="Filter by billing interval"),
    current_user: User = Depends(require_roles(UserRole.ADMIN, UserRole.STAFF)),
    db: AsyncSession = Depends(get_db),
):
    """List subscription plans with search, filtering and dynamic price calculation."""
    svc = PlanService(db)
    pricing_svc = PricingService(db)
    items, total = await svc.list_plans(
        search=search,
        status_filter=status_filter,
        billing_interval=billing_interval,
        page=page,
        limit=limit,
    )
    total_pages = math.ceil(total / limit) if total > 0 else 1
    return SubscriptionPlanListResponse(
        items=[_to_plan_response(p, pricing_svc) for p in items],
        total=total,
        page=page,
        limit=limit,
        total_pages=total_pages,
    )


@router.post("", response_model=SubscriptionPlanDetailResponse, status_code=status.HTTP_201_CREATED)
async def create_plan(
    request_data: SubscriptionPlanCreate,
    current_user: User = Depends(require_roles(UserRole.ADMIN)),
    client_info: Tuple[Optional[str], Optional[str]] = Depends(get_client_info),
    db: AsyncSession = Depends(get_db),
):
    """Create a new subscription plan with initial bundled products."""
    ip_address, user_agent = client_info
    svc = PlanService(db)
    pricing_svc = PricingService(db)
    plan = await svc.create_plan(
        request=request_data,
        user_id=current_user.id,
        ip_address=ip_address,
        user_agent=user_agent,
    )
    return _to_plan_detail_response(plan, pricing_svc)


@router.get("/{plan_id}", response_model=SubscriptionPlanDetailResponse)
async def get_plan(
    plan_id: uuid.UUID,
    current_user: User = Depends(require_roles(UserRole.ADMIN, UserRole.STAFF)),
    db: AsyncSession = Depends(get_db),
):
    """Get complete subscription plan details including bundled items and auto-close status."""
    svc = PlanService(db)
    pricing_svc = PricingService(db)
    plan = await svc.get_plan(plan_id)
    return _to_plan_detail_response(plan, pricing_svc)


@router.put("/{plan_id}", response_model=SubscriptionPlanDetailResponse)
async def update_plan(
    plan_id: uuid.UUID,
    request_data: SubscriptionPlanUpdate,
    current_user: User = Depends(require_roles(UserRole.ADMIN)),
    client_info: Tuple[Optional[str], Optional[str]] = Depends(get_client_info),
    db: AsyncSession = Depends(get_db),
):
    """Update subscription plan configuration."""
    ip_address, user_agent = client_info
    svc = PlanService(db)
    pricing_svc = PricingService(db)
    plan = await svc.update_plan(
        plan_id=plan_id,
        request=request_data,
        user_id=current_user.id,
        ip_address=ip_address,
        user_agent=user_agent,
    )
    return _to_plan_detail_response(plan, pricing_svc)


@router.patch("/{plan_id}/status", response_model=SubscriptionPlanDetailResponse)
async def update_plan_status(
    plan_id: uuid.UUID,
    request_data: SubscriptionPlanStatusUpdate,
    current_user: User = Depends(require_roles(UserRole.ADMIN)),
    client_info: Tuple[Optional[str], Optional[str]] = Depends(get_client_info),
    db: AsyncSession = Depends(get_db),
):
    """Transition subscription plan status (e.g. DRAFT -> ACTIVE, ACTIVE -> ARCHIVED)."""
    ip_address, user_agent = client_info
    svc = PlanService(db)
    pricing_svc = PricingService(db)
    plan = await svc.update_status(
        plan_id=plan_id,
        request=request_data,
        user_id=current_user.id,
        ip_address=ip_address,
        user_agent=user_agent,
    )
    return _to_plan_detail_response(plan, pricing_svc)


@router.post(
    "/{plan_id}/products",
    response_model=PlanProductResponse,
    status_code=status.HTTP_201_CREATED,
)
async def add_bundled_product(
    plan_id: uuid.UUID,
    request_data: PlanProductCreate,
    current_user: User = Depends(require_roles(UserRole.ADMIN)),
    client_info: Tuple[Optional[str], Optional[str]] = Depends(get_client_info),
    db: AsyncSession = Depends(get_db),
):
    """Add a product/variant line item to a subscription plan."""
    ip_address, user_agent = client_info
    svc = PlanService(db)
    plan_product = await svc.add_bundled_product(
        plan_id=plan_id,
        request=request_data,
        user_id=current_user.id,
        ip_address=ip_address,
        user_agent=user_agent,
    )
    item = PlanProductResponse.model_validate(plan_product)
    if plan_product.product:
        item.product = ProductResponse.model_validate(plan_product.product)
    if plan_product.variant:
        item.variant = ProductVariantResponse.model_validate(plan_product.variant)
    return item


@router.put(
    "/{plan_id}/products/{line_item_id}",
    response_model=PlanProductResponse,
)
async def update_bundled_product(
    plan_id: uuid.UUID,
    line_item_id: uuid.UUID,
    request_data: PlanProductUpdate,
    current_user: User = Depends(require_roles(UserRole.ADMIN)),
    client_info: Tuple[Optional[str], Optional[str]] = Depends(get_client_info),
    db: AsyncSession = Depends(get_db),
):
    """Update a bundled product line item in a subscription plan."""
    ip_address, user_agent = client_info
    svc = PlanService(db)
    plan_product = await svc.update_bundled_product(
        plan_id=plan_id,
        plan_product_id=line_item_id,
        request=request_data,
        user_id=current_user.id,
        ip_address=ip_address,
        user_agent=user_agent,
    )
    item = PlanProductResponse.model_validate(plan_product)
    if plan_product.product:
        item.product = ProductResponse.model_validate(plan_product.product)
    if plan_product.variant:
        item.variant = ProductVariantResponse.model_validate(plan_product.variant)
    return item


@router.delete(
    "/{plan_id}/products/{line_item_id}",
    response_model=MessageResponse,
)
async def remove_bundled_product(
    plan_id: uuid.UUID,
    line_item_id: uuid.UUID,
    current_user: User = Depends(require_roles(UserRole.ADMIN)),
    client_info: Tuple[Optional[str], Optional[str]] = Depends(get_client_info),
    db: AsyncSession = Depends(get_db),
):
    """Remove a bundled product line item from a subscription plan."""
    ip_address, user_agent = client_info
    svc = PlanService(db)
    await svc.remove_bundled_product(
        plan_id=plan_id,
        plan_product_id=line_item_id,
        user_id=current_user.id,
        ip_address=ip_address,
        user_agent=user_agent,
    )
    return MessageResponse(message="Bundled product successfully removed from plan.")
