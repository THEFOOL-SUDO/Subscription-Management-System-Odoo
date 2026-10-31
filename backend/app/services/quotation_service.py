import datetime
import uuid
from decimal import Decimal
from typing import List, Optional
from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.customer import CustomerStatus
from app.models.plan import BillingInterval, PlanStatus
from app.models.quotation import QuotationTemplate, QuotationTemplateItem
from app.models.subscription import (
    PaymentTerms,
    Subscription,
    SubscriptionItem,
    SubscriptionStatus,
    SubscriptionStatusHistory,
)
from app.models.user import User
from app.repositories.customer_repo import CustomerRepository
from app.repositories.plan_repo import PlanRepository
from app.repositories.product_repo import ProductRepository
from app.repositories.quotation_repo import QuotationRepository
from app.repositories.subscription_repo import SubscriptionRepository
from app.schemas.quotation import (
    QuotationConvertToSubscriptionRequest,
    QuotationTemplateCreate,
    QuotationTemplateItemResponse,
    QuotationTemplateResponse,
    QuotationTemplateUpdate,
)
from app.services.audit_service import AuditService


class QuotationService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.repo = QuotationRepository(session)
        self.sub_repo = SubscriptionRepository(session)
        self.cust_repo = CustomerRepository(session)
        self.plan_repo = PlanRepository(session)
        self.prod_repo = ProductRepository(session)
        self.audit = AuditService(session)

    def _to_response(self, t: QuotationTemplate) -> QuotationTemplateResponse:
        items = []
        for it in t.items:
            items.append(
                QuotationTemplateItemResponse(
                    id=it.id,
                    product_id=it.product_id,
                    variant_id=it.variant_id,
                    quantity=it.quantity,
                    unit_price=it.unit_price,
                    notes=it.notes,
                    product_name=it.product.name if it.product else None,
                    variant_name=it.variant.name if it.variant else None,
                )
            )
        return QuotationTemplateResponse(
            id=t.id,
            code=t.code,
            name=t.name,
            description=t.description,
            plan_id=t.plan_id,
            plan_name=t.plan.name if t.plan else None,
            validity_days=t.validity_days,
            payment_terms=t.payment_terms,
            tax_rate=t.tax_rate,
            discount_amount=t.discount_amount,
            is_active=t.is_active,
            items=items,
            created_at=t.created_at,
            updated_at=t.updated_at,
        )

    async def list_templates(self, active_only: bool = False) -> List[QuotationTemplateResponse]:
        templates = await self.repo.list_templates(active_only=active_only)
        return [self._to_response(t) for t in templates]

    async def get_template(self, template_id: uuid.UUID) -> QuotationTemplateResponse:
        template = await self.repo.get_by_id(template_id)
        if not template:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Quotation template not found.")
        return self._to_response(template)

    async def create_template(
        self,
        data: QuotationTemplateCreate,
        operator: User,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> QuotationTemplateResponse:
        existing = await self.repo.get_by_code(data.code)
        if existing:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Quotation code '{data.code}' already exists.")

        plan = await self.plan_repo.get_by_id(data.plan_id)
        if not plan:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Plan not found.")

        template = QuotationTemplate(
            code=data.code.strip().upper(),
            name=data.name,
            description=data.description,
            plan_id=data.plan_id,
            validity_days=data.validity_days,
            payment_terms=data.payment_terms,
            tax_rate=data.tax_rate,
            discount_amount=data.discount_amount,
            is_active=data.is_active,
            created_by_id=operator.id,
        )

        for item_in in data.items:
            product = await self.prod_repo.get_by_id(item_in.product_id)
            if not product:
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Product {item_in.product_id} not found.")
            template.items.append(
                QuotationTemplateItem(
                    product_id=item_in.product_id,
                    variant_id=item_in.variant_id,
                    quantity=item_in.quantity,
                    unit_price=item_in.unit_price,
                    notes=item_in.notes,
                )
            )

        created = await self.repo.create(template)
        await self.audit.log(
            action="QUOTATION_TEMPLATE_CREATED",
            resource_type="quotation_template",
            user_id=operator.id,
            resource_id=str(created.id),
            details={"code": created.code, "name": created.name},
            ip_address=ip_address,
            user_agent=user_agent,
        )
        return self._to_response(created)

    async def update_template(
        self,
        template_id: uuid.UUID,
        data: QuotationTemplateUpdate,
        operator: User,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> QuotationTemplateResponse:
        template = await self.repo.get_by_id(template_id)
        if not template:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Quotation template not found.")

        if data.name is not None:
            template.name = data.name
        if data.description is not None:
            template.description = data.description
        if data.validity_days is not None:
            template.validity_days = data.validity_days
        if data.payment_terms is not None:
            template.payment_terms = data.payment_terms
        if data.tax_rate is not None:
            template.tax_rate = data.tax_rate
        if data.discount_amount is not None:
            template.discount_amount = data.discount_amount
        if data.is_active is not None:
            template.is_active = data.is_active

        if data.items is not None:
            template.items.clear()
            for item_in in data.items:
                product = await self.prod_repo.get_by_id(item_in.product_id)
                if not product:
                    raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Product {item_in.product_id} not found.")
                template.items.append(
                    QuotationTemplateItem(
                        product_id=item_in.product_id,
                        variant_id=item_in.variant_id,
                        quantity=item_in.quantity,
                        unit_price=item_in.unit_price,
                        notes=item_in.notes,
                    )
                )

        updated = await self.repo.update(template)
        await self.audit.log(
            action="QUOTATION_TEMPLATE_UPDATED",
            resource_type="quotation_template",
            user_id=operator.id,
            resource_id=str(updated.id),
            details={"code": updated.code},
            ip_address=ip_address,
            user_agent=user_agent,
        )
        return self._to_response(updated)

    async def delete_template(
        self,
        template_id: uuid.UUID,
        operator: User,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> None:
        template = await self.repo.get_by_id(template_id)
        if not template:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Quotation template not found.")
        await self.repo.delete(template)
        await self.audit.log(
            action="QUOTATION_TEMPLATE_DELETED",
            resource_type="quotation_template",
            user_id=operator.id,
            resource_id=str(template_id),
            details={"code": template.code},
            ip_address=ip_address,
            user_agent=user_agent,
        )

    async def convert_to_subscription(
        self,
        template_id: uuid.UUID,
        data: QuotationConvertToSubscriptionRequest,
        operator: User,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> Subscription:
        template = await self.repo.get_by_id(template_id)
        if not template or not template.is_active:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Quotation template is inactive or not found.")

        customer = await self.cust_repo.get_by_id(data.customer_id)
        if not customer or customer.status != CustomerStatus.ACTIVE:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Customer is not active.")

        plan = template.plan
        if not plan or plan.status != PlanStatus.ACTIVE:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Associated subscription plan is not active.")

        # Compute dates
        start_date = data.start_date
        expiry_date = start_date + datetime.timedelta(days=template.validity_days)
        next_billing_date = start_date + datetime.timedelta(days=30 if plan.billing_interval == BillingInterval.MONTHLY else 365)

        sub_number = await self.sub_repo.get_next_subscription_number()

        # Build items
        sub_items = []
        subtotal = Decimal("0.0000")
        for q_item in template.items:
            unit_price = Decimal(str(q_item.unit_price)).quantize(Decimal("0.0001"))
            line_subtotal = (unit_price * q_item.quantity).quantize(Decimal("0.0001"))
            subtotal += line_subtotal
            sub_items.append(
                SubscriptionItem(
                    product_id=q_item.product_id,
                    variant_id=q_item.variant_id,
                    quantity=q_item.quantity,
                    unit_price=unit_price,
                    subtotal=line_subtotal,
                    notes=q_item.notes,
                )
            )

        tax_rate = template.tax_rate
        discount_amount = min(template.discount_amount, subtotal)
        taxable_amount = max(Decimal("0.0000"), subtotal - discount_amount)
        tax_amount = (taxable_amount * (tax_rate / Decimal("100.0000"))).quantize(Decimal("0.0001"))
        total_amount = (taxable_amount + tax_amount).quantize(Decimal("0.0001"))

        # Map payment terms
        try:
            terms = PaymentTerms(template.payment_terms)
        except ValueError:
            terms = PaymentTerms.NET_30

        subscription = Subscription(
            subscription_number=sub_number,
            customer_id=customer.id,
            plan_id=plan.id,
            status=SubscriptionStatus.QUOTATION,
            start_date=start_date,
            expiry_date=expiry_date,
            next_billing_date=next_billing_date,
            billing_interval=plan.billing_interval,
            interval_count=plan.interval_count,
            currency=plan.currency,
            payment_terms=terms,
            subtotal=subtotal,
            tax_rate=tax_rate,
            tax_amount=tax_amount,
            discount_amount=discount_amount,
            total_amount=total_amount,
            notes=data.notes or f"Converted from Quotation Template: {template.name} ({template.code})",
            quotation_template_id=template.id,
            created_by_id=operator.id,
            updated_by_id=operator.id,
            items=sub_items,
        )

        created_sub = await self.sub_repo.create(subscription)

        # Status history
        history = SubscriptionStatusHistory(
            subscription_id=created_sub.id,
            from_status=SubscriptionStatus.DRAFT.value,
            to_status=SubscriptionStatus.QUOTATION.value,
            reason=f"Converted directly from Quotation Template '{template.name}' ({template.code})",
            changed_by_id=operator.id,
        )
        await self.sub_repo.add_status_history(history)

        await self.audit.log(
            action="SUBSCRIPTION_CREATED_FROM_QUOTATION",
            resource_type="subscription",
            user_id=operator.id,
            resource_id=str(created_sub.id),
            details={
                "subscription_number": created_sub.subscription_number,
                "template_code": template.code,
                "total_amount": str(created_sub.total_amount),
            },
            ip_address=ip_address,
            user_agent=user_agent,
        )

        return created_sub
