import uuid
from decimal import Decimal
from typing import List, Optional, Tuple
from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.product import AdjustmentType, Product, ProductType, ProductVariant
from app.repositories.plan_repo import PlanRepository
from app.repositories.product_repo import ProductRepository
from app.schemas.product import (
    ProductCreate,
    ProductUpdate,
    ProductVariantCreate,
    ProductVariantUpdate,
)
from app.services.audit_service import AuditService


class ProductService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.repo = ProductRepository(session)
        self.plan_repo = PlanRepository(session)
        self.audit_service = AuditService(session)

    async def get_product(self, product_id: uuid.UUID) -> Product:
        product = await self.repo.get_by_id(product_id)
        if not product:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Product with ID '{product_id}' not found.",
            )
        return product

    async def list_products(
        self,
        search: Optional[str] = None,
        product_type: Optional[ProductType] = None,
        is_active: Optional[bool] = None,
        is_archived: Optional[bool] = False,
        page: int = 1,
        limit: int = 20,
    ) -> Tuple[List[Product], int]:
        return await self.repo.list_products(
            search=search,
            product_type=product_type,
            is_active=is_active,
            is_archived=is_archived,
            page=page,
            limit=limit,
        )

    async def create_product(
        self,
        request: ProductCreate,
        user_id: Optional[uuid.UUID] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> Product:
        existing = await self.repo.get_by_sku(request.sku)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Product with SKU '{request.sku}' already exists.",
            )

        # Validate variant code uniqueness within the request
        if request.variants:
            codes = [v.variant_code.strip().upper() for v in request.variants]
            if len(codes) != len(set(codes)):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Duplicate variant codes found in create request.",
                )

        product = await self.repo.create_product(
            name=request.name,
            sku=request.sku,
            product_type=request.product_type,
            sales_price=request.sales_price,
            cost_price=request.cost_price,
            currency=request.currency,
            description=request.description,
            notes=request.notes,
            is_active=request.is_active,
            created_by_id=user_id,
        )

        # Initial price history record
        await self.repo.record_price_history(
            product_id=product.id,
            price_field="sales_price",
            old_price=None,
            new_price=product.sales_price,
            changed_by_id=user_id,
            reason="Initial product creation",
        )
        if product.cost_price is not None:
            await self.repo.record_price_history(
                product_id=product.id,
                price_field="cost_price",
                old_price=None,
                new_price=product.cost_price,
                changed_by_id=user_id,
                reason="Initial product creation",
            )

        # Create initial variants if any
        for v in request.variants:
            variant = await self.repo.create_variant(
                product_id=product.id,
                variant_name=v.variant_name,
                variant_code=v.variant_code,
                adjustment_type=v.adjustment_type,
                adjustment_value=v.adjustment_value,
                is_active=v.is_active,
                description=v.description,
            )
            await self.repo.record_variant_price_history(
                variant_id=variant.id,
                old_adjustment_type=None,
                new_adjustment_type=variant.adjustment_type,
                old_adjustment_value=None,
                new_adjustment_value=variant.adjustment_value,
                changed_by_id=user_id,
                reason="Initial variant creation",
            )

        await self.audit_service.log(
            action="PRODUCT_CREATED",
            resource_type="PRODUCT",
            user_id=user_id,
            resource_id=str(product.id),
            details={
                "name": product.name,
                "sku": product.sku,
                "sales_price": str(product.sales_price),
                "currency": product.currency,
                "variants_count": len(request.variants),
            },
            ip_address=ip_address,
            user_agent=user_agent,
        )

        await self.session.refresh(product, ["variants", "price_history"])
        return product

    async def update_product(
        self,
        product_id: uuid.UUID,
        request: ProductUpdate,
        user_id: Optional[uuid.UUID] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> Product:
        product = await self.get_product(product_id)

        if request.sku is not None and request.sku.upper() != product.sku.upper():
            existing = await self.repo.get_by_sku(request.sku)
            if existing and existing.id != product.id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Product with SKU '{request.sku}' already exists.",
                )

        price_changes = {}

        # Detect sales price change
        if request.sales_price is not None and request.sales_price != product.sales_price:
            price_changes["sales_price"] = {
                "old": str(product.sales_price),
                "new": str(request.sales_price),
            }
            await self.repo.record_price_history(
                product_id=product.id,
                price_field="sales_price",
                old_price=product.sales_price,
                new_price=request.sales_price,
                changed_by_id=user_id,
                reason=request.price_change_reason or "Sales price update",
            )

        # Detect cost price change
        if request.cost_price is not None and request.cost_price != product.cost_price:
            price_changes["cost_price"] = {
                "old": str(product.cost_price) if product.cost_price is not None else None,
                "new": str(request.cost_price),
            }
            await self.repo.record_price_history(
                product_id=product.id,
                price_field="cost_price",
                old_price=product.cost_price,
                new_price=request.cost_price,
                changed_by_id=user_id,
                reason=request.price_change_reason or "Cost price update",
            )

        updated_product = await self.repo.update_product(
            product=product,
            name=request.name,
            sku=request.sku,
            product_type=request.product_type,
            description=request.description,
            notes=request.notes,
            sales_price=request.sales_price,
            cost_price=request.cost_price,
            currency=request.currency,
            is_active=request.is_active,
            is_archived=request.is_archived,
            updated_by_id=user_id,
        )

        await self.audit_service.log(
            action="PRODUCT_UPDATED",
            resource_type="PRODUCT",
            user_id=user_id,
            resource_id=str(product.id),
            details={
                "name": updated_product.name,
                "sku": updated_product.sku,
                "price_changes": price_changes,
                "reason": request.price_change_reason,
            },
            ip_address=ip_address,
            user_agent=user_agent,
        )

        await self.session.refresh(updated_product, ["variants", "price_history"])
        return updated_product

    async def archive_product(
        self,
        product_id: uuid.UUID,
        user_id: Optional[uuid.UUID] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> Product:
        product = await self.get_product(product_id)
        if product.is_archived:
            return product

        # Soft-guard archival: Deactivate associated plan product line items
        deactivated_count = await self.plan_repo.deactivate_product_in_plans(product.id)

        updated_product = await self.repo.update_product(
            product=product,
            is_archived=True,
            is_active=False,
            updated_by_id=user_id,
        )

        await self.audit_service.log(
            action="PRODUCT_ARCHIVED",
            resource_type="PRODUCT",
            user_id=user_id,
            resource_id=str(product.id),
            details={
                "name": product.name,
                "sku": product.sku,
                "deactivated_plan_line_items": deactivated_count,
            },
            ip_address=ip_address,
            user_agent=user_agent,
        )

        await self.session.refresh(updated_product, ["variants", "price_history"])
        return updated_product

    async def create_variant(
        self,
        product_id: uuid.UUID,
        request: ProductVariantCreate,
        user_id: Optional[uuid.UUID] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> ProductVariant:
        product = await self.get_product(product_id)

        existing = await self.repo.get_variant_by_code(product.id, request.variant_code)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Variant code '{request.variant_code}' already exists for this product.",
            )

        variant = await self.repo.create_variant(
            product_id=product.id,
            variant_name=request.variant_name,
            variant_code=request.variant_code,
            adjustment_type=request.adjustment_type,
            adjustment_value=request.adjustment_value,
            is_active=request.is_active,
            description=request.description,
        )

        await self.repo.record_variant_price_history(
            variant_id=variant.id,
            old_adjustment_type=None,
            new_adjustment_type=variant.adjustment_type,
            old_adjustment_value=None,
            new_adjustment_value=variant.adjustment_value,
            changed_by_id=user_id,
            reason="Initial variant creation",
        )

        await self.audit_service.log(
            action="PRODUCT_VARIANT_CREATED",
            resource_type="PRODUCT_VARIANT",
            user_id=user_id,
            resource_id=str(variant.id),
            details={
                "product_id": str(product.id),
                "variant_name": variant.variant_name,
                "variant_code": variant.variant_code,
                "adjustment_type": variant.adjustment_type,
                "adjustment_value": str(variant.adjustment_value),
            },
            ip_address=ip_address,
            user_agent=user_agent,
        )

        return variant

    async def update_variant(
        self,
        product_id: uuid.UUID,
        variant_id: uuid.UUID,
        request: ProductVariantUpdate,
        user_id: Optional[uuid.UUID] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> ProductVariant:
        variant = await self.repo.get_variant_by_id(variant_id)
        if not variant or variant.product_id != product_id:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Variant '{variant_id}' not found for product '{product_id}'.",
            )

        if (
            request.variant_code is not None
            and request.variant_code.upper() != variant.variant_code.upper()
        ):
            existing = await self.repo.get_variant_by_code(product_id, request.variant_code)
            if existing and existing.id != variant.id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Variant code '{request.variant_code}' already exists for this product.",
                )

        # Detect price adjustment changes
        target_adj_type = request.adjustment_type or variant.adjustment_type
        target_adj_val = (
            request.adjustment_value
            if request.adjustment_value is not None
            else variant.adjustment_value
        )

        if (
            target_adj_type != variant.adjustment_type
            or target_adj_val != variant.adjustment_value
        ):
            await self.repo.record_variant_price_history(
                variant_id=variant.id,
                old_adjustment_type=variant.adjustment_type,
                new_adjustment_type=target_adj_type,
                old_adjustment_value=variant.adjustment_value,
                new_adjustment_value=target_adj_val,
                changed_by_id=user_id,
                reason=request.reason or "Variant price adjustment update",
            )

        updated_variant = await self.repo.update_variant(
            variant=variant,
            variant_name=request.variant_name,
            variant_code=request.variant_code,
            adjustment_type=request.adjustment_type,
            adjustment_value=request.adjustment_value,
            is_active=request.is_active,
            description=request.description,
        )

        await self.audit_service.log(
            action="PRODUCT_VARIANT_UPDATED",
            resource_type="PRODUCT_VARIANT",
            user_id=user_id,
            resource_id=str(variant.id),
            details={
                "variant_name": updated_variant.variant_name,
                "variant_code": updated_variant.variant_code,
                "adjustment_type": updated_variant.adjustment_type,
                "adjustment_value": str(updated_variant.adjustment_value),
            },
            ip_address=ip_address,
            user_agent=user_agent,
        )

        await self.session.refresh(updated_variant, ["price_history"])
        return updated_variant

    async def archive_variant(
        self,
        product_id: uuid.UUID,
        variant_id: uuid.UUID,
        user_id: Optional[uuid.UUID] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> ProductVariant:
        variant = await self.repo.get_variant_by_id(variant_id)
        if not variant or variant.product_id != product_id:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Variant '{variant_id}' not found for product '{product_id}'.",
            )

        # Soft-guard archival: Deactivate associated plan line items with this variant
        deactivated_count = await self.plan_repo.deactivate_product_in_plans(
            product_id, variant.id
        )

        updated_variant = await self.repo.update_variant(
            variant=variant,
            is_active=False,
        )

        await self.audit_service.log(
            action="PRODUCT_VARIANT_DEACTIVATED",
            resource_type="PRODUCT_VARIANT",
            user_id=user_id,
            resource_id=str(variant.id),
            details={
                "variant_name": variant.variant_name,
                "variant_code": variant.variant_code,
                "deactivated_plan_line_items": deactivated_count,
            },
            ip_address=ip_address,
            user_agent=user_agent,
        )

        await self.session.refresh(updated_variant, ["price_history"])
        return updated_variant
