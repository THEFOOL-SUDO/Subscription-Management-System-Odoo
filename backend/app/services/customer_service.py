import datetime
import secrets
import uuid
from typing import List, Optional, Tuple
from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.config import settings
from app.core.security import generate_secure_token, hash_password, hash_token
from app.models.customer import Customer, CustomerStatus
from app.models.user import User, UserRole
from app.repositories.customer_repo import CustomerRepository
from app.repositories.token_repo import TokenRepository
from app.repositories.user_repo import UserRepository
from app.schemas.customer import CustomerCreate, CustomerUpdate
from app.services.audit_service import AuditService
from app.services.email_service import EmailService


class CustomerService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.repo = CustomerRepository(session)
        self.user_repo = UserRepository(session)
        self.token_repo = TokenRepository(session)
        self.audit_service = AuditService(session)
        self.email_service = EmailService()

    async def get_customer(self, customer_id: uuid.UUID, current_user: User) -> Customer:
        customer = await self.repo.get_by_id(customer_id)
        if not customer:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Customer with ID '{customer_id}' not found.",
            )

        # Enforce Customer Data Isolation
        if current_user.role == UserRole.CUSTOMER:
            if customer.user_id != current_user.id:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Access denied. You may only view your own customer profile.",
                )

        return customer

    async def get_customer_for_user(self, user: User) -> Optional[Customer]:
        """Lookup or lazily initialize Customer record for a logged-in user."""
        customer = await self.repo.get_by_user_id(user.id)
        if not customer:
            customer = await self.repo.get_by_email(user.email)
            if customer and not customer.user_id:
                customer.user_id = user.id
                await self.repo.update(customer)
        return customer

    async def list_customers(
        self,
        current_user: User,
        search: Optional[str] = None,
        status_filter: Optional[CustomerStatus] = None,
        page: int = 1,
        limit: int = 20,
    ) -> Tuple[List[Customer], int]:
        # Enforce Customer Data Isolation: customers only see their own profile
        if current_user.role == UserRole.CUSTOMER:
            customer = await self.get_customer_for_user(current_user)
            if not customer:
                return [], 0
            return [customer], 1

        return await self.repo.list_customers(
            search=search,
            status=status_filter,
            page=page,
            limit=limit,
        )

    async def create_customer(
        self,
        data: CustomerCreate,
        operator: User,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> Customer:
        # Check if customer record exists with this email
        existing_cust = await self.repo.get_by_email(data.email)
        if existing_cust:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"A customer account with email '{data.email}' already exists.",
            )

        # Step 1: Auto-link to existing user or auto-provision CUSTOMER user
        user = await self.user_repo.get_by_email(data.email)
        if not user:
            # Auto-provision CUSTOMER user account with secure random credentials (unusable placeholder)
            placeholder_password = secrets.token_urlsafe(32)
            user = await self.user_repo.create(
                email=data.email,
                full_name=data.name,
                hashed_password=hash_password(placeholder_password),
                role=UserRole.CUSTOMER,
                is_active=True,
                is_verified=True,
            )
            # Create single-use password activation token (valid for 24 hours)
            raw_token = generate_secure_token()
            token_hash = hash_token(raw_token)
            expires_at = datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(hours=24)
            await self.token_repo.create_password_reset_token(
                user_id=user.id,
                token_hash=token_hash,
                expires_at=expires_at,
            )
            # Dispatch secure account activation email (Zero plaintext password exposure)
            await EmailService.send_customer_activation_email(
                recipient_email=user.email,
                reset_token=raw_token,
                full_name=user.full_name,
            )

        customer_number = await self.repo.get_next_customer_number()

        customer = Customer(
            user_id=user.id,
            customer_number=customer_number,
            name=data.name,
            email=data.email,
            phone=data.phone,
            company_name=data.company_name,
            billing_address_line1=data.billing_address_line1,
            billing_address_line2=data.billing_address_line2,
            billing_city=data.billing_city,
            billing_state=data.billing_state,
            billing_postal_code=data.billing_postal_code,
            billing_country=data.billing_country,
            status=CustomerStatus.ACTIVE,
            created_by_id=operator.id,
            updated_by_id=operator.id,
        )

        customer = await self.repo.create(customer)

        await self.audit_service.log(
            action="CUSTOMER_CREATED",
            resource_type="customer",
            user_id=operator.id,
            resource_id=str(customer.id),
            details={
                "customer_number": customer.customer_number,
                "email": customer.email,
                "user_id": str(user.id),
            },
            ip_address=ip_address,
            user_agent=user_agent,
        )

        return customer

    async def update_customer(
        self,
        customer_id: uuid.UUID,
        data: CustomerUpdate,
        operator: User,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> Customer:
        customer = await self.repo.get_by_id(customer_id)
        if not customer:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Customer with ID '{customer_id}' not found.",
            )

        updated_fields = []
        if data.name is not None and data.name != customer.name:
            customer.name = data.name
            updated_fields.append("name")
        if data.phone is not None and data.phone != customer.phone:
            customer.phone = data.phone
            updated_fields.append("phone")
        if data.company_name is not None and data.company_name != customer.company_name:
            customer.company_name = data.company_name
            updated_fields.append("company_name")
        if data.billing_address_line1 is not None and data.billing_address_line1 != customer.billing_address_line1:
            customer.billing_address_line1 = data.billing_address_line1
            updated_fields.append("billing_address_line1")
        if data.billing_address_line2 is not None and data.billing_address_line2 != customer.billing_address_line2:
            customer.billing_address_line2 = data.billing_address_line2
            updated_fields.append("billing_address_line2")
        if data.billing_city is not None and data.billing_city != customer.billing_city:
            customer.billing_city = data.billing_city
            updated_fields.append("billing_city")
        if data.billing_state is not None and data.billing_state != customer.billing_state:
            customer.billing_state = data.billing_state
            updated_fields.append("billing_state")
        if data.billing_postal_code is not None and data.billing_postal_code != customer.billing_postal_code:
            customer.billing_postal_code = data.billing_postal_code
            updated_fields.append("billing_postal_code")
        if data.billing_country is not None and data.billing_country != customer.billing_country:
            customer.billing_country = data.billing_country
            updated_fields.append("billing_country")
        if data.status is not None and data.status != customer.status:
            customer.status = data.status
            updated_fields.append("status")

        customer.updated_by_id = operator.id
        updated_customer = await self.repo.update(customer)

        await self.audit_service.log(
            action="CUSTOMER_UPDATED",
            resource_type="customer",
            user_id=operator.id,
            resource_id=str(customer.id),
            details={"updated_fields": updated_fields},
            ip_address=ip_address,
            user_agent=user_agent,
        )

        return updated_customer
