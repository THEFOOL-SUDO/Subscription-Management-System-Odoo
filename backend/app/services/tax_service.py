import uuid
from typing import List, Optional
from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.tax import TaxRule
from app.models.user import User
from app.repositories.tax_repo import TaxRepository
from app.schemas.tax import TaxRuleCreate, TaxRuleUpdate
from app.services.audit_service import AuditService


class TaxService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.repo = TaxRepository(session)
        self.audit = AuditService(session)

    async def list_rules(self, active_only: bool = False) -> List[TaxRule]:
        return await self.repo.list_rules(active_only=active_only)

    async def get_rule(self, rule_id: uuid.UUID) -> TaxRule:
        rule = await self.repo.get_by_id(rule_id)
        if not rule:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Tax rule not found.")
        return rule

    async def get_default_rule(self) -> Optional[TaxRule]:
        return await self.repo.get_default()

    async def create_rule(
        self,
        data: TaxRuleCreate,
        operator: User,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> TaxRule:
        rule = TaxRule(
            name=data.name,
            tax_rate=data.tax_rate,
            country=data.country,
            state=data.state,
            is_default=data.is_default,
            is_active=data.is_active,
        )
        created = await self.repo.create(rule)
        await self.audit.log(
            action="TAX_RULE_CREATED",
            resource_type="tax_rule",
            user_id=operator.id,
            resource_id=str(created.id),
            details={"name": created.name, "rate": str(created.tax_rate)},
            ip_address=ip_address,
            user_agent=user_agent,
        )
        return created

    async def update_rule(
        self,
        rule_id: uuid.UUID,
        data: TaxRuleUpdate,
        operator: User,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> TaxRule:
        rule = await self.get_rule(rule_id)
        if data.name is not None:
            rule.name = data.name
        if data.tax_rate is not None:
            rule.tax_rate = data.tax_rate
        if data.country is not None:
            rule.country = data.country
        if data.state is not None:
            rule.state = data.state
        if data.is_default is not None:
            rule.is_default = data.is_default
        if data.is_active is not None:
            rule.is_active = data.is_active

        updated = await self.repo.update(rule)
        await self.audit.log(
            action="TAX_RULE_UPDATED",
            resource_type="tax_rule",
            user_id=operator.id,
            resource_id=str(updated.id),
            details={"name": updated.name, "rate": str(updated.tax_rate)},
            ip_address=ip_address,
            user_agent=user_agent,
        )
        return updated
