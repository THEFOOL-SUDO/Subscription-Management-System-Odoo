import uuid
from decimal import Decimal
from typing import List, Optional, Tuple
from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.product import (
    Product,
    ProductType,
    ProductVariant,
    AdjustmentType,
    ProductPriceHistory,
    VariantPriceHistory,
)


class ProductRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_by_id(self, product_id: uuid.UUID) -> Optional[Product]:
        query = select(Product).where(Product.id == product_id)
        result = await self.session.execute(query)
        return result.scalar_one_or_none()

    async def get_by_sku(self, sku: str) -> Optional[Product]:
        query = select(Product).where(func.lower(Product.sku) == sku.strip().lower())
        result = await self.session.execute(query)
        return result.scalar_one_or_none()

    async def list_products(
        self,
        search: Optional[str] = None,
        product_type: Optional[ProductType] = None,
        is_active: Optional[bool] = None,
        is_archived: Optional[bool] = False,
        page: int = 1,
        limit: int = 20,
    ) -> Tuple[List[Product], int]:
        filters = []
        if is_archived is not None:
            filters.append(Product.is_archived == is_archived)
        if is_active is not None:
            filters.append(Product.is_active == is_active)
        if product_type is not None:
            filters.append(Product.product_type == product_type)

        if search:
            pattern = f"%{search.strip().lower()}%"
            filters.append(
                or_(
                    func.lower(Product.name).like(pattern),
                    func.lower(Product.sku).like(pattern),
                    func.lower(Product.description).like(pattern),
                )
            )

        count_query = select(func.count(Product.id))
        if filters:
            count_query = count_query.where(*filters)
        total_result = await self.session.execute(count_query)
        total = total_result.scalar() or 0

        offset = (page - 1) * limit
        query = (
            select(Product)
            .where(*filters)
            .order_by(Product.name.asc())
            .offset(offset)
            .limit(limit)
        )
        result = await self.session.execute(query)
        products = list(result.scalars().all())
        return products, total

    async def create_product(
        self,
        name: str,
        sku: str,
        product_type: ProductType,
        sales_price: Decimal,
        cost_price: Optional[Decimal] = None,
        currency: str = "INR",
        description: Optional[str] = None,
        notes: Optional[str] = None,
        is_active: bool = True,
        created_by_id: Optional[uuid.UUID] = None,
    ) -> Product:
        product = Product(
            id=uuid.uuid4(),
            name=name.strip(),
            sku=sku.strip().upper(),
            product_type=product_type,
            sales_price=sales_price,
            cost_price=cost_price,
            currency=currency.strip().upper(),
            description=description,
            notes=notes,
            is_active=is_active,
            is_archived=False,
            created_by_id=created_by_id,
            updated_by_id=created_by_id,
        )
        self.session.add(product)
        await self.session.flush()
        await self.session.refresh(product)
        return product

    async def update_product(
        self,
        product: Product,
        name: Optional[str] = None,
        sku: Optional[str] = None,
        product_type: Optional[ProductType] = None,
        description: Optional[str] = None,
        notes: Optional[str] = None,
        sales_price: Optional[Decimal] = None,
        cost_price: Optional[Decimal] = None,
        currency: Optional[str] = None,
        is_active: Optional[bool] = None,
        is_archived: Optional[bool] = None,
        updated_by_id: Optional[uuid.UUID] = None,
    ) -> Product:
        if name is not None:
            product.name = name.strip()
        if sku is not None:
            product.sku = sku.strip().upper()
        if product_type is not None:
            product.product_type = product_type
        if description is not None:
            product.description = description
        if notes is not None:
            product.notes = notes
        if sales_price is not None:
            product.sales_price = sales_price
        if cost_price is not None:
            product.cost_price = cost_price
        if currency is not None:
            product.currency = currency.strip().upper()
        if is_active is not None:
            product.is_active = is_active
        if is_archived is not None:
            product.is_archived = is_archived
        if updated_by_id is not None:
            product.updated_by_id = updated_by_id

        await self.session.flush()
        await self.session.refresh(product)
        return product

    async def record_price_history(
        self,
        product_id: uuid.UUID,
        price_field: str,
        old_price: Optional[Decimal],
        new_price: Decimal,
        changed_by_id: Optional[uuid.UUID] = None,
        reason: Optional[str] = None,
    ) -> ProductPriceHistory:
        history = ProductPriceHistory(
            id=uuid.uuid4(),
            product_id=product_id,
            price_field=price_field,
            old_price=old_price,
            new_price=new_price,
            changed_by_id=changed_by_id,
            reason=reason,
        )
        self.session.add(history)
        await self.session.flush()
        return history

    async def get_variant_by_id(self, variant_id: uuid.UUID) -> Optional[ProductVariant]:
        query = select(ProductVariant).where(ProductVariant.id == variant_id)
        result = await self.session.execute(query)
        return result.scalar_one_or_none()

    async def get_variant_by_code(
        self, product_id: uuid.UUID, variant_code: str
    ) -> Optional[ProductVariant]:
        query = select(ProductVariant).where(
            ProductVariant.product_id == product_id,
            func.lower(ProductVariant.variant_code) == variant_code.strip().lower(),
        )
        result = await self.session.execute(query)
        return result.scalar_one_or_none()

    async def create_variant(
        self,
        product_id: uuid.UUID,
        variant_name: str,
        variant_code: str,
        adjustment_type: AdjustmentType = AdjustmentType.FIXED_AMOUNT,
        adjustment_value: Decimal = Decimal("0.0000"),
        is_active: bool = True,
        description: Optional[str] = None,
    ) -> ProductVariant:
        variant = ProductVariant(
            id=uuid.uuid4(),
            product_id=product_id,
            variant_name=variant_name.strip(),
            variant_code=variant_code.strip().upper(),
            adjustment_type=adjustment_type,
            adjustment_value=adjustment_value,
            is_active=is_active,
            description=description,
        )
        self.session.add(variant)
        await self.session.flush()
        await self.session.refresh(variant)
        return variant

    async def update_variant(
        self,
        variant: ProductVariant,
        variant_name: Optional[str] = None,
        variant_code: Optional[str] = None,
        adjustment_type: Optional[AdjustmentType] = None,
        adjustment_value: Optional[Decimal] = None,
        is_active: Optional[bool] = None,
        description: Optional[str] = None,
    ) -> ProductVariant:
        if variant_name is not None:
            variant.variant_name = variant_name.strip()
        if variant_code is not None:
            variant.variant_code = variant_code.strip().upper()
        if adjustment_type is not None:
            variant.adjustment_type = adjustment_type
        if adjustment_value is not None:
            variant.adjustment_value = adjustment_value
        if is_active is not None:
            variant.is_active = is_active
        if description is not None:
            variant.description = description

        await self.session.flush()
        await self.session.refresh(variant)
        return variant

    async def record_variant_price_history(
        self,
        variant_id: uuid.UUID,
        old_adjustment_type: Optional[AdjustmentType],
        new_adjustment_type: AdjustmentType,
        old_adjustment_value: Optional[Decimal],
        new_adjustment_value: Decimal,
        changed_by_id: Optional[uuid.UUID] = None,
        reason: Optional[str] = None,
    ) -> VariantPriceHistory:
        history = VariantPriceHistory(
            id=uuid.uuid4(),
            variant_id=variant_id,
            old_adjustment_type=old_adjustment_type,
            new_adjustment_type=new_adjustment_type,
            old_adjustment_value=old_adjustment_value,
            new_adjustment_value=new_adjustment_value,
            changed_by_id=changed_by_id,
            reason=reason,
        )
        self.session.add(history)
        await self.session.flush()
        return history

