import math
import uuid
from typing import Optional
from fastapi import APIRouter, Depends, Query, Request, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.core.dependencies import get_client_info, get_current_user, require_roles
from app.models.customer import CustomerStatus
from app.models.user import User, UserRole
from app.schemas.customer import (
    CustomerCreate,
    CustomerListResponse,
    CustomerResponse,
    CustomerUpdate,
)
from app.services.customer_service import CustomerService

router = APIRouter(prefix="/customers", tags=["Customer Management"])


@router.get("", response_model=CustomerListResponse)
async def list_customers(
    search: Optional[str] = Query(None, description="Search by name, email, or number"),
    status_filter: Optional[CustomerStatus] = Query(None, alias="status", description="Filter by status"),
    page: int = Query(1, ge=1, description="Page number"),
    limit: int = Query(20, ge=1, le=100, description="Items per page"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """List customer records. Admin & Staff can view all, Customers only see their own profile."""
    svc = CustomerService(db)
    items, total = await svc.list_customers(
        current_user=current_user,
        search=search,
        status_filter=status_filter,
        page=page,
        limit=limit,
    )
    pages = math.ceil(total / limit) if total > 0 else 1
    return CustomerListResponse(
        items=[CustomerResponse.model_validate(c) for c in items],
        total=total,
        page=page,
        size=limit,
        pages=pages,
    )


@router.post("", response_model=CustomerResponse, status_code=status.HTTP_201_CREATED)
async def create_customer(
    data: CustomerCreate,
    request: Request,
    current_user: User = Depends(require_roles(UserRole.ADMIN, UserRole.STAFF)),
    db: AsyncSession = Depends(get_db),
):
    """Create a new customer profile. Admin & Staff only."""
    ip, user_agent = get_client_info(request)
    svc = CustomerService(db)
    customer = await svc.create_customer(
        data=data,
        operator=current_user,
        ip_address=ip,
        user_agent=user_agent,
    )
    return CustomerResponse.model_validate(customer)


@router.get("/me", response_model=CustomerResponse)
async def get_my_customer_profile(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Retrieve customer profile for current authenticated user."""
    svc = CustomerService(db)
    customer = await svc.get_customer_for_user(current_user)
    if not customer:
        from fastapi import HTTPException
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No customer profile linked to this user account.",
        )
    return CustomerResponse.model_validate(customer)


@router.get("/{id}", response_model=CustomerResponse)
async def get_customer(
    id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Retrieve customer profile by ID."""
    svc = CustomerService(db)
    customer = await svc.get_customer(id, current_user)
    return CustomerResponse.model_validate(customer)


@router.put("/{id}", response_model=CustomerResponse)
async def update_customer(
    id: uuid.UUID,
    data: CustomerUpdate,
    request: Request,
    current_user: User = Depends(require_roles(UserRole.ADMIN, UserRole.STAFF)),
    db: AsyncSession = Depends(get_db),
):
    """Update customer details. Admin & Staff only."""
    ip, user_agent = get_client_info(request)
    svc = CustomerService(db)
    updated = await svc.update_customer(
        customer_id=id,
        data=data,
        operator=current_user,
        ip_address=ip,
        user_agent=user_agent,
    )
    return CustomerResponse.model_validate(updated)

