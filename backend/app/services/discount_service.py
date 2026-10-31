import datetime
import uuid
from decimal import Decimal
from typing import List, Optional
from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.discount import DiscountRule, DiscountType
from app.models.user import User
from app.repositories.discount_repo import DiscountRepository
from app.schemas.discount import (
    DiscountRuleCreate,
    DiscountRuleUpdate,
    DiscountValidateRequest,
    DiscountValidateResponse,
)
from app.services.audit_service import AuditService


class DiscountService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.repo = DiscountRepository(session)
        self.audit = AuditService(session)

    async def list_discounts(self, active_only: bool = False) -> List[DiscountRule]:
        return await self.repo.list_discounts(active_only=active_only)

    async def get_discount(self, discount_id: uuid.UUID) -> DiscountRule:
        rule = await self.repo.get_by_id(discount_id)
        if not rule:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Discount rule not found.")
        return rule

    async def create_discount(
        self,
        data: DiscountRuleCreate,
        operator: User,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> DiscountRule:
        existing = await self.repo.get_by_code(data.code)
        if existing:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Discount code '{data.code}' already exists.")

        rule = DiscountRule(
            code=data.code.strip().upper(),
            name=data.name,
            description=data.description,
            discount_type=data.discount_type,
            discount_value=data.discount_value,
            min_purchase_amount=data.min_purchase_amount,
            min_quantity=data.min_quantity,
            max_uses=data.max_uses,
            valid_from=data.valid_from,
            valid_until=data.valid_until,
            is_active=data.is_active,
            scope=data.scope,
            product_id=data.product_id,
            created_by_id=operator.id,
        )
        created = await self.repo.create(rule)
        await self.audit.log(
            action="DISCOUNT_RULE_CREATED",
            resource_type="discount_rule",
            user_id=operator.id,
            resource_id=str(created.id),
            details={"code": created.code, "value": str(created.discount_value)},
            ip_address=ip_address,
            user_agent=user_agent,
        )
        return created

    async def update_discount(
        self,
        discount_id: uuid.UUID,
        data: DiscountRuleUpdate,
        operator: User,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> DiscountRule:
        rule = await self.get_discount(discount_id)
        if data.name is not None:
            rule.name = data.name
        if data.description is not None:
            rule.description = data.description
        if data.discount_value is not None:
            rule.discount_value = data.discount_value
        if data.min_purchase_amount is not None:
            rule.min_purchase_amount = data.min_purchase_amount
        if data.min_quantity is not None:
            rule.min_quantity = data.min_quantity
        if data.max_uses is not None:
            rule.max_uses = data.max_uses
        if data.valid_from is not None:
            rule.valid_from = data.valid_from
        if data.valid_until is not None:
            rule.valid_until = data.valid_until
        if data.is_active is not None:
            rule.is_active = data.is_active

        updated = await self.repo.update(rule)
        await self.audit.log(
            action="DISCOUNT_RULE_UPDATED",
            resource_type="discount_rule",
            user_id=operator.id,
            resource_id=str(updated.id),
            details={"code": updated.code},
            ip_address=ip_address,
            user_agent=user_agent,
        )
        return updated

    async def validate_code(self, req: DiscountValidateRequest) -> DiscountValidateResponse:
        rule = await self.repo.get_by_code(req.code)
        if not rule or not rule.is_active:
            return DiscountValidateResponse(
                is_valid=False,
                code=req.code,
                message="Invalid or inactive discount code.",
            )

        now = datetime.datetime.now(datetime.timezone.utc)
        if rule.valid_from and now < rule.valid_from:
            return DiscountValidateResponse(
                is_valid=False,
                code=req.code,
                message="This discount promotion has not started yet.",
            )
        if rule.valid_until and now > rule.valid_until:
            return DiscountValidateResponse(
                is_valid=False,
                code=req.code,
                message="This discount promotion has expired.",
            )

        if rule.max_uses and rule.current_uses >= rule.max_uses:
            return DiscountValidateResponse(
                is_valid=False,
                code=req.code,
                message="This discount code has reached its maximum usage limit.",
            )

        if rule.min_purchase_amount and req.amount < rule.min_purchase_amount:
            return DiscountValidateResponse(
                is_valid=False,
                code=req.code,
                message=f"Minimum purchase amount of ₹{rule.min_purchase_amount} required to use this code.",
            )

        # Calculate discount amount
        if rule.discount_type == DiscountType.PERCENTAGE.value:
            calc = (req.amount * (rule.discount_value / Decimal("100"))).quantize(Decimal("0.0001"))
        else:
            calc = min(rule.discount_value, req.amount).quantize(Decimal("0.0001"))

        return DiscountValidateResponse(
            is_valid=True,
            rule_id=rule.id,
            code=rule.code,
            discount_type=rule.discount_type,
            discount_value=rule.discount_value,
            calculated_discount=calc,
            message="Discount code successfully applied.",
        )
