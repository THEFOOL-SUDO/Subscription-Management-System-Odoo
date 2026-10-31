import math
import uuid
from typing import Optional, Tuple
from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.core.dependencies import get_client_info, get_current_user, require_roles
from app.models.product import ProductType
from app.models.user import User, UserRole
from app.schemas.product import (
    ProductCreate,
    ProductDetailResponse,
    ProductListResponse,
    ProductPriceHistoryResponse,
    ProductResponse,
    ProductUpdate,
    ProductVariantCreate,
    ProductVariantResponse,
    ProductVariantUpdate,
    VariantPriceHistoryResponse,
)
from app.services.product_service import ProductService

router = APIRouter(prefix="/products", tags=["Product Management"])


def _to_product_response(p) -> ProductResponse:
    resp = ProductResponse.model_validate(p)
    resp.variants_count = len([v for v in p.variants if v.is_active])
    return resp


def _to_product_detail_response(p) -> ProductDetailResponse:
    variants = []
    for v in p.variants:
        v_resp = ProductVariantResponse.model_validate(v)
        v_resp.price_history = [
            VariantPriceHistoryResponse.model_validate(h) for h in v.price_history
        ]
        variants.append(v_resp)

    price_history = [
        ProductPriceHistoryResponse.model_validate(h) for h in p.price_history
    ]

    resp = ProductDetailResponse(
        id=p.id,
        name=p.name,
        sku=p.sku,
        product_type=p.product_type,
        description=p.description,
        notes=p.notes,
        sales_price=p.sales_price,
        cost_price=p.cost_price,
        currency=p.currency,
        is_active=p.is_active,
        is_archived=p.is_archived,
        created_at=p.created_at,
        updated_at=p.updated_at,
        created_by_id=p.created_by_id,
        updated_by_id=p.updated_by_id,
        variants_count=len([v for v in p.variants if v.is_active]),
        variants=variants,
        price_history=price_history,
    )
    return resp


@router.get("", response_model=ProductListResponse)
async def list_products(
    page: int = Query(1, ge=1, description="Page number"),
    limit: int = Query(20, ge=1, le=100, description="Items per page"),
    search: Optional[str] = Query(None, description="Search by name, SKU or description"),
    product_type: Optional[ProductType] = Query(None, description="Filter by product type"),
    is_active: Optional[bool] = Query(None, description="Filter by active status"),
    is_archived: Optional[bool] = Query(False, description="Filter by archived status"),
    current_user: User = Depends(require_roles(UserRole.ADMIN, UserRole.STAFF)),
    db: AsyncSession = Depends(get_db),
):
    """List products with pagination, search and filtering. Accessible by ADMIN and STAFF."""
    svc = ProductService(db)
    items, total = await svc.list_products(
        search=search,
        product_type=product_type,
        is_active=is_active,
        is_archived=is_archived,
        page=page,
        limit=limit,
    )
    total_pages = math.ceil(total / limit) if total > 0 else 1
    return ProductListResponse(
        items=[_to_product_response(p) for p in items],
        total=total,
        page=page,
        limit=limit,
        total_pages=total_pages,
    )


@router.post("", response_model=ProductDetailResponse, status_code=status.HTTP_201_CREATED)
async def create_product(
    request_data: ProductCreate,
    current_user: User = Depends(require_roles(UserRole.ADMIN)),
    client_info: Tuple[Optional[str], Optional[str]] = Depends(get_client_info),
    db: AsyncSession = Depends(get_db),
):
    """Create a new product. Accessible only by ADMIN."""
    ip_address, user_agent = client_info
    svc = ProductService(db)
    product = await svc.create_product(
        request=request_data,
        user_id=current_user.id,
        ip_address=ip_address,
        user_agent=user_agent,
    )
    return _to_product_detail_response(product)


@router.get("/{product_id}", response_model=ProductDetailResponse)
async def get_product(
    product_id: uuid.UUID,
    current_user: User = Depends(require_roles(UserRole.ADMIN, UserRole.STAFF)),
    db: AsyncSession = Depends(get_db),
):
    """Get full product details including variants and price history."""
    svc = ProductService(db)
    product = await svc.get_product(product_id)
    return _to_product_detail_response(product)


@router.put("/{product_id}", response_model=ProductDetailResponse)
async def update_product(
    product_id: uuid.UUID,
    request_data: ProductUpdate,
    current_user: User = Depends(require_roles(UserRole.ADMIN)),
    client_info: Tuple[Optional[str], Optional[str]] = Depends(get_client_info),
    db: AsyncSession = Depends(get_db),
):
    """Update product details and pricing. Immutable price history is recorded on changes."""
    ip_address, user_agent = client_info
    svc = ProductService(db)
    product = await svc.update_product(
        product_id=product_id,
        request=request_data,
        user_id=current_user.id,
        ip_address=ip_address,
        user_agent=user_agent,
    )
    return _to_product_detail_response(product)


@router.post("/{product_id}/archive", response_model=ProductDetailResponse)
async def archive_product(
    product_id: uuid.UUID,
    current_user: User = Depends(require_roles(UserRole.ADMIN)),
    client_info: Tuple[Optional[str], Optional[str]] = Depends(get_client_info),
    db: AsyncSession = Depends(get_db),
):
    """Soft-archive a product and safely deactivate its line items in subscription plans."""
    ip_address, user_agent = client_info
    svc = ProductService(db)
    product = await svc.archive_product(
        product_id=product_id,
        user_id=current_user.id,
        ip_address=ip_address,
        user_agent=user_agent,
    )
    return _to_product_detail_response(product)


@router.post(
    "/{product_id}/variants",
    response_model=ProductVariantResponse,
    status_code=status.HTTP_201_CREATED,
)
async def create_variant(
    product_id: uuid.UUID,
    request_data: ProductVariantCreate,
    current_user: User = Depends(require_roles(UserRole.ADMIN)),
    client_info: Tuple[Optional[str], Optional[str]] = Depends(get_client_info),
    db: AsyncSession = Depends(get_db),
):
    """Create a new variant for a product."""
    ip_address, user_agent = client_info
    svc = ProductService(db)
    variant = await svc.create_variant(
        product_id=product_id,
        request=request_data,
        user_id=current_user.id,
        ip_address=ip_address,
        user_agent=user_agent,
    )
    v_resp = ProductVariantResponse.model_validate(variant)
    v_resp.price_history = [
        VariantPriceHistoryResponse.model_validate(h) for h in variant.price_history
    ]
    return v_resp


@router.put("/{product_id}/variants/{variant_id}", response_model=ProductVariantResponse)
async def update_variant(
    product_id: uuid.UUID,
    variant_id: uuid.UUID,
    request_data: ProductVariantUpdate,
    current_user: User = Depends(require_roles(UserRole.ADMIN)),
    client_info: Tuple[Optional[str], Optional[str]] = Depends(get_client_info),
    db: AsyncSession = Depends(get_db),
):
    """Update a product variant and record price adjustment changes to history."""
    ip_address, user_agent = client_info
    svc = ProductService(db)
    variant = await svc.update_variant(
        product_id=product_id,
        variant_id=variant_id,
        request=request_data,
        user_id=current_user.id,
        ip_address=ip_address,
        user_agent=user_agent,
    )
    v_resp = ProductVariantResponse.model_validate(variant)
    v_resp.price_history = [
        VariantPriceHistoryResponse.model_validate(h) for h in variant.price_history
    ]
    return v_resp


@router.post(
    "/{product_id}/variants/{variant_id}/archive",
    response_model=ProductVariantResponse,
)
async def archive_variant(
    product_id: uuid.UUID,
    variant_id: uuid.UUID,
    current_user: User = Depends(require_roles(UserRole.ADMIN)),
    client_info: Tuple[Optional[str], Optional[str]] = Depends(get_client_info),
    db: AsyncSession = Depends(get_db),
):
    """Deactivate a variant and soft-guard associated line items in active plans."""
    ip_address, user_agent = client_info
    svc = ProductService(db)
    variant = await svc.archive_variant(
        product_id=product_id,
        variant_id=variant_id,
        user_id=current_user.id,
        ip_address=ip_address,
        user_agent=user_agent,
    )
    v_resp = ProductVariantResponse.model_validate(variant)
    v_resp.price_history = [
        VariantPriceHistoryResponse.model_validate(h) for h in variant.price_history
    ]
    return v_resp
