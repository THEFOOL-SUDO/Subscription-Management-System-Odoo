import datetime
import uuid
from decimal import Decimal
from typing import List, Optional, Tuple
from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.customer import CustomerStatus
from app.models.plan import BillingInterval, PlanStatus
from app.models.product import AdjustmentType
from app.models.subscription import (
    PaymentTerms,
    Subscription,
    SubscriptionItem,
    SubscriptionStatus,
    SubscriptionStatusHistory,
)
from app.models.user import User, UserRole
from app.repositories.customer_repo import CustomerRepository
from app.repositories.plan_repo import PlanRepository
from app.repositories.product_repo import ProductRepository
from app.repositories.subscription_repo import SubscriptionRepository
from app.schemas.subscription import SubscriptionCreate
from app.services.audit_service import AuditService


class SubscriptionService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.repo = SubscriptionRepository(session)
        self.customer_repo = CustomerRepository(session)
        self.plan_repo = PlanRepository(session)
        self.product_repo = ProductRepository(session)
        self.audit_service = AuditService(session)

    def _calculate_expiry_date(
        self, start_date: datetime.datetime, interval: BillingInterval, interval_count: int
    ) -> datetime.datetime:
        """Calculate expiry date based on interval cadences."""
        if interval == BillingInterval.DAILY:
            return start_date + datetime.timedelta(days=interval_count)
        elif interval == BillingInterval.WEEKLY:
            return start_date + datetime.timedelta(weeks=interval_count)
        elif interval == BillingInterval.MONTHLY:
            # Approximate 30 days per month or advance month
            days = 30 * interval_count
            return start_date + datetime.timedelta(days=days)
        elif interval == BillingInterval.YEARLY:
            days = 365 * interval_count
            return start_date + datetime.timedelta(days=days)
        return start_date + datetime.timedelta(days=30)

    async def get_subscription(self, subscription_id: uuid.UUID, current_user: User) -> Subscription:
        subscription = await self.repo.get_by_id(subscription_id)
        if not subscription:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Subscription with ID '{subscription_id}' not found.",
            )

        # Enforce Customer Isolation
        if current_user.role == UserRole.CUSTOMER:
            if not subscription.customer or subscription.customer.user_id != current_user.id:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Access denied. You may only view your own subscriptions.",
                )

        return subscription

    async def list_subscriptions(
        self,
        current_user: User,
        customer_id: Optional[uuid.UUID] = None,
        status_filter: Optional[SubscriptionStatus] = None,
        search: Optional[str] = None,
        page: int = 1,
        limit: int = 20,
    ) -> Tuple[List[Subscription], int]:
        effective_customer_id = customer_id

        if current_user.role == UserRole.CUSTOMER:
            customer = await self.customer_repo.get_by_user_id(current_user.id)
            if not customer:
                return [], 0
            effective_customer_id = customer.id

        return await self.repo.list_subscriptions(
            customer_id=effective_customer_id,
            status=status_filter,
            search=search,
            page=page,
            limit=limit,
        )

    async def create_subscription(
        self,
        data: SubscriptionCreate,
        operator: User,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> Subscription:
        # 1. Validate Customer
        customer = await self.customer_repo.get_by_id(data.customer_id)
        if not customer:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Customer with ID '{data.customer_id}' not found.",
            )
        if customer.status != CustomerStatus.ACTIVE:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot create subscription for an inactive customer.",
            )

        # 2. Validate Plan
        plan = await self.plan_repo.get_by_id(data.plan_id)
        if not plan:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Subscription plan with ID '{data.plan_id}' not found.",
            )
        if plan.status != PlanStatus.ACTIVE:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Cannot subscribe to a plan in '{plan.status.value}' status. Plan must be ACTIVE.",
            )

        now = datetime.datetime.now(datetime.timezone.utc)
        if plan.availability_start_date and data.start_date < plan.availability_start_date:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Start date cannot precede plan availability start date ({plan.availability_start_date.isoformat()}).",
            )
        if plan.availability_end_date and now > plan.availability_end_date:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="This subscription plan has expired and is no longer available.",
            )

        # 3. Assemble Line Items with Server-Side Pricing
        subscription_items: List[SubscriptionItem] = []
        total_quantity = 0

        if data.items and len(data.items) > 0:
            for item_in in data.items:
                product = await self.product_repo.get_by_id(item_in.product_id)
                if not product or product.is_archived or not product.is_active:
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail=f"Product '{item_in.product_id}' is inactive or archived.",
                    )
                if product.currency != plan.currency:
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail=f"Currency mismatch: Product currency ({product.currency}) does not match Plan currency ({plan.currency}).",
                    )

                unit_price = product.sales_price
                variant_obj = None
                if item_in.variant_id:
                    variant_obj = await self.product_repo.get_variant_by_id(item_in.variant_id)
                    if not variant_obj or variant_obj.product_id != product.id or not variant_obj.is_active:
                        raise HTTPException(
                            status_code=status.HTTP_400_BAD_REQUEST,
                            detail=f"Variant '{item_in.variant_id}' does not belong to product '{product.name}' or is inactive.",
                        )
                    if variant_obj.adjustment_type == AdjustmentType.FIXED_AMOUNT:
                        unit_price += variant_obj.adjustment_value
                    elif variant_obj.adjustment_type == AdjustmentType.PERCENTAGE:
                        adj = product.sales_price * (variant_obj.adjustment_value / Decimal("100.0000"))
                        unit_price += adj

                # Check if plan defines a price override for this product & variant
                for bp in plan.bundled_products:
                    if bp.product_id == product.id and bp.variant_id == item_in.variant_id:
                        if bp.price_override is not None:
                            unit_price = bp.price_override
                        break

                unit_price = Decimal(str(unit_price)).quantize(Decimal("0.0001"))
                line_subtotal = (unit_price * item_in.quantity).quantize(Decimal("0.0001"))
                total_quantity += item_in.quantity

                subscription_items.append(
                    SubscriptionItem(
                        product_id=product.id,
                        variant_id=item_in.variant_id,
                        quantity=item_in.quantity,
                        unit_price=unit_price,
                        subtotal=line_subtotal,
                        notes=item_in.notes,
                    )
                )
        else:
            # Auto-populate from plan bundled products
            if not plan.bundled_products:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Plan has no bundled products configured. Please add products to the plan or supply subscription items.",
                )
            for bp in plan.bundled_products:
                if not bp.is_active or not bp.product:
                    continue
                product = bp.product
                unit_price = product.sales_price
                if bp.variant:
                    if bp.variant.adjustment_type == AdjustmentType.FIXED_AMOUNT:
                        unit_price += bp.variant.adjustment_value
                    elif bp.variant.adjustment_type == AdjustmentType.PERCENTAGE:
                        adj = product.sales_price * (bp.variant.adjustment_value / Decimal("100.0000"))
                        unit_price += adj

                if bp.price_override is not None:
                    unit_price = bp.price_override

                unit_price = Decimal(str(unit_price)).quantize(Decimal("0.0001"))
                qty = bp.default_quantity
                line_subtotal = (unit_price * qty).quantize(Decimal("0.0001"))
                total_quantity += qty

                subscription_items.append(
                    SubscriptionItem(
                        product_id=product.id,
                        variant_id=bp.variant_id,
                        quantity=qty,
                        unit_price=unit_price,
                        subtotal=line_subtotal,
                        notes=None,
                    )
                )

        # 4. Quantity validations against plan rules
        if plan.min_quantity and total_quantity < plan.min_quantity:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Total items quantity ({total_quantity}) is less than plan minimum allowed ({plan.min_quantity}).",
            )
        if plan.max_quantity and total_quantity > plan.max_quantity:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Total items quantity ({total_quantity}) exceeds plan maximum allowed ({plan.max_quantity}).",
            )

        # 5. Financial Totals (Strict Decimal Precision)
        subtotal = sum((item.subtotal for item in subscription_items), Decimal("0.0000")).quantize(Decimal("0.0001"))
        discount_amount = (data.discount_amount or Decimal("0.0000")).quantize(Decimal("0.0001"))
        if discount_amount > subtotal:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Discount amount cannot exceed the subscription subtotal.",
            )

        taxable_base = subtotal - discount_amount
        tax_rate = (data.tax_rate if data.tax_rate is not None else Decimal("18.0000")).quantize(Decimal("0.0001"))
        tax_amount = (taxable_base * (tax_rate / Decimal("100.0000"))).quantize(Decimal("0.0001"))
        total_amount = (taxable_base + tax_amount).quantize(Decimal("0.0001"))

        expiry_date = self._calculate_expiry_date(data.start_date, plan.billing_interval, plan.interval_count)
        sub_number = await self.repo.get_next_subscription_number()

        subscription = Subscription(
            subscription_number=sub_number,
            customer_id=customer.id,
            plan_id=plan.id,
            status=SubscriptionStatus.DRAFT,
            start_date=data.start_date,
            expiry_date=expiry_date,
            billing_interval=plan.billing_interval,
            interval_count=plan.interval_count,
            currency=plan.currency,
            payment_terms=data.payment_terms or PaymentTerms.NET_30,
            subtotal=subtotal,
            tax_rate=tax_rate,
            tax_amount=tax_amount,
            discount_amount=discount_amount,
            total_amount=total_amount,
            notes=data.notes,
            created_by_id=operator.id,
            updated_by_id=operator.id,
        )

        for item in subscription_items:
            subscription.items.append(item)

        initial_history = SubscriptionStatusHistory(
            from_status=None,
            to_status=SubscriptionStatus.DRAFT.value,
            reason="Subscription initiated as DRAFT",
            changed_by_id=operator.id,
        )
        subscription.status_history.append(initial_history)

        created_sub = await self.repo.create(subscription)

        await self.audit_service.log(
            action="SUBSCRIPTION_CREATED",
            resource_type="subscription",
            user_id=operator.id,
            resource_id=str(created_sub.id),
            details={
                "subscription_number": created_sub.subscription_number,
                "customer_id": str(customer.id),
                "plan_id": str(plan.id),
                "total_amount": str(created_sub.total_amount),
            },
            ip_address=ip_address,
            user_agent=user_agent,
        )

        return created_sub

    async def transition_status(
        self,
        subscription_id: uuid.UUID,
        to_status: SubscriptionStatus,
        reason: Optional[str],
        operator: User,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> Subscription:
        # Customers cannot change status
        if operator.role == UserRole.CUSTOMER:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Customers are not permitted to change subscription lifecycle status.",
            )

        subscription = await self.repo.get_by_id(subscription_id)
        if not subscription:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Subscription with ID '{subscription_id}' not found.",
            )

        # Enforce State Machine Rules:
        # DRAFT -> QUOTATION, CLOSED
        # QUOTATION -> CONFIRMED, DRAFT, CLOSED
        # CONFIRMED -> ACTIVE, CLOSED
        # ACTIVE -> PAUSED, CLOSED
        # PAUSED -> ACTIVE, CLOSED
        # CLOSED -> Terminal (or RENEWED via dedicated renew endpoint)
        valid_transitions = {
            SubscriptionStatus.DRAFT: {SubscriptionStatus.QUOTATION, SubscriptionStatus.CLOSED},
            SubscriptionStatus.QUOTATION: {
                SubscriptionStatus.CONFIRMED,
                SubscriptionStatus.DRAFT,
                SubscriptionStatus.CLOSED,
            },
            SubscriptionStatus.CONFIRMED: {SubscriptionStatus.ACTIVE, SubscriptionStatus.CLOSED},
            SubscriptionStatus.ACTIVE: {SubscriptionStatus.PAUSED, SubscriptionStatus.CLOSED},
            SubscriptionStatus.PAUSED: {SubscriptionStatus.ACTIVE, SubscriptionStatus.CLOSED},
            SubscriptionStatus.CLOSED: set(),
        }

        allowed = valid_transitions.get(subscription.status, set())
        if to_status not in allowed:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid lifecycle transition from '{subscription.status.value}' to '{to_status.value}'. Allowed transitions: {[s.value for s in allowed]}",
            )

        from_status_val = subscription.status.value
        subscription.status = to_status
        subscription.updated_by_id = operator.id

        history_item = SubscriptionStatusHistory(
            subscription_id=subscription.id,
            from_status=from_status_val,
            to_status=to_status.value,
            reason=reason or f"Transitioned to {to_status.value} by operator",
            changed_by_id=operator.id,
        )
        await self.repo.add_status_history(history_item)

        updated_sub = await self.repo.update(subscription)

        await self.audit_service.log(
            action="SUBSCRIPTION_STATUS_CHANGED",
            resource_type="subscription",
            user_id=operator.id,
            resource_id=str(subscription.id),
            details={
                "from_status": from_status_val,
                "to_status": to_status.value,
                "reason": reason,
            },
            ip_address=ip_address,
            user_agent=user_agent,
        )

        return updated_sub

    async def pause_subscription(
        self,
        subscription_id: uuid.UUID,
        reason: Optional[str],
        operator: User,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> Subscription:
        if operator.role == UserRole.CUSTOMER:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Customers cannot pause subscriptions directly.")

        subscription = await self.repo.get_by_id(subscription_id)
        if not subscription:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Subscription not found.")

        if subscription.status != SubscriptionStatus.ACTIVE:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Cannot pause subscription in status '{subscription.status.value}'. Must be ACTIVE.")

        now = datetime.datetime.now(datetime.timezone.utc)
        subscription.status = SubscriptionStatus.PAUSED
        subscription.paused_at = now
        subscription.updated_by_id = operator.id

        history_item = SubscriptionStatusHistory(
            subscription_id=subscription.id,
            from_status=SubscriptionStatus.ACTIVE.value,
            to_status=SubscriptionStatus.PAUSED.value,
            reason=reason or "Subscription paused by operator",
            changed_by_id=operator.id,
        )
        await self.repo.add_status_history(history_item)
        updated = await self.repo.update(subscription)

        await self.audit_service.log(
            action="SUBSCRIPTION_PAUSED",
            resource_type="subscription",
            user_id=operator.id,
            resource_id=str(subscription.id),
            details={"subscription_number": subscription.subscription_number, "reason": reason},
            ip_address=ip_address,
            user_agent=user_agent,
        )
        return updated

    async def resume_subscription(
        self,
        subscription_id: uuid.UUID,
        operator: User,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> Subscription:
        if operator.role == UserRole.CUSTOMER:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Customers cannot resume subscriptions directly.")

        subscription = await self.repo.get_by_id(subscription_id)
        if not subscription:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Subscription not found.")

        if subscription.status != SubscriptionStatus.PAUSED:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Cannot resume subscription in status '{subscription.status.value}'. Must be PAUSED.")

        now = datetime.datetime.now(datetime.timezone.utc)
        paused_duration = (now - subscription.paused_at) if subscription.paused_at else datetime.timedelta(days=0)
        paused_days = max(1, paused_duration.days) if paused_duration.total_seconds() > 3600 else 0

        if paused_days > 0:
            subscription.total_paused_days += paused_days
            if subscription.expiry_date:
                subscription.expiry_date = subscription.expiry_date + datetime.timedelta(days=paused_days)
            if subscription.next_billing_date:
                subscription.next_billing_date = subscription.next_billing_date + datetime.timedelta(days=paused_days)

        subscription.status = SubscriptionStatus.ACTIVE
        subscription.paused_at = None
        subscription.updated_by_id = operator.id

        history_item = SubscriptionStatusHistory(
            subscription_id=subscription.id,
            from_status=SubscriptionStatus.PAUSED.value,
            to_status=SubscriptionStatus.ACTIVE.value,
            reason=f"Subscription resumed. Shifted timeline by {paused_days} paused day(s).",
            changed_by_id=operator.id,
        )
        await self.repo.add_status_history(history_item)
        updated = await self.repo.update(subscription)

        await self.audit_service.log(
            action="SUBSCRIPTION_RESUMED",
            resource_type="subscription",
            user_id=operator.id,
            resource_id=str(subscription.id),
            details={"subscription_number": subscription.subscription_number, "paused_days": paused_days},
            ip_address=ip_address,
            user_agent=user_agent,
        )
        return updated

    async def renew_subscription(
        self,
        subscription_id: uuid.UUID,
        operator: User,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> Subscription:
        if operator.role == UserRole.CUSTOMER:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Customers cannot renew subscriptions directly.")

        subscription = await self.repo.get_by_id(subscription_id)
        if not subscription:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Subscription not found.")

        if subscription.status not in (SubscriptionStatus.ACTIVE, SubscriptionStatus.CLOSED):
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Cannot renew subscription in status '{subscription.status.value}'.")

        now = datetime.datetime.now(datetime.timezone.utc)
        base_date = subscription.expiry_date if (subscription.expiry_date and subscription.expiry_date > now) else now
        new_expiry = self._calculate_expiry_date(base_date, subscription.billing_interval, subscription.interval_count)

        prev_status = subscription.status.value
        subscription.status = SubscriptionStatus.ACTIVE
        subscription.expiry_date = new_expiry
        subscription.next_billing_date = new_expiry
        subscription.updated_by_id = operator.id

        history_item = SubscriptionStatusHistory(
            subscription_id=subscription.id,
            from_status=prev_status,
            to_status=SubscriptionStatus.ACTIVE.value,
            reason=f"Subscription manually renewed until {new_expiry.isoformat()}.",
            changed_by_id=operator.id,
        )
        await self.repo.add_status_history(history_item)
        updated = await self.repo.update(subscription)

        await self.audit_service.log(
            action="SUBSCRIPTION_RENEWED",
            resource_type="subscription",
            user_id=operator.id,
            resource_id=str(subscription.id),
            details={"subscription_number": subscription.subscription_number, "new_expiry": new_expiry.isoformat()},
            ip_address=ip_address,
            user_agent=user_agent,
        )
        return updated

    async def close_subscription(
        self,
        subscription_id: uuid.UUID,
        reason: Optional[str],
        operator: User,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> Subscription:
        return await self.transition_status(
            subscription_id=subscription_id,
            to_status=SubscriptionStatus.CLOSED,
            reason=reason or "Early subscription closure by operator",
            operator=operator,
            ip_address=ip_address,
            user_agent=user_agent,
        )
