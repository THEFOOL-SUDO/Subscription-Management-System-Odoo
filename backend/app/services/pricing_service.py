import uuid
from decimal import Decimal
from typing import List, Optional, Tuple
from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.plan import SubscriptionPlan, PlanProduct
from app.models.product import AdjustmentType, Product, ProductVariant
from app.repositories.product_repo import ProductRepository
from app.schemas.pricing import (
    PriceCalculationItem,
    PriceCalculationItemResult,
    PriceCalculationRequest,
    PriceCalculationResponse,
)


class PricingService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.product_repo = ProductRepository(session)

    def calculate_variant_unit_price(
        self, base_price: Decimal, variant: Optional[ProductVariant]
    ) -> Decimal:
        """Calculate effective unit price given base price and optional variant adjustment."""
        if not variant:
            return base_price.quantize(Decimal("0.0001"))

        if variant.adjustment_type == AdjustmentType.FIXED_AMOUNT:
            effective = base_price + variant.adjustment_value
        elif variant.adjustment_type == AdjustmentType.PERCENTAGE:
            effective = base_price + (base_price * variant.adjustment_value / Decimal("100.0"))
        else:
            effective = base_price

        # Monetary price cannot fall below zero
        effective = max(Decimal("0.0000"), effective)
        return effective.quantize(Decimal("0.0001"))

    async def calculate_prices(
        self, request: PriceCalculationRequest
    ) -> PriceCalculationResponse:
        """Calculate live prices for line items with exact backend Decimal precision."""
        results: List[PriceCalculationItemResult] = []
        total_price = Decimal("0.0000")
        target_currency = (request.currency or "INR").strip().upper()

        for item in request.items:
            product = await self.product_repo.get_by_id(item.product_id)
            if not product:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail=f"Product with ID '{item.product_id}' not found.",
                )

            if product.is_archived or not product.is_active:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Product '{product.name}' ({product.sku}) is archived or inactive.",
                )

            if product.currency.upper() != target_currency:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=(
                        f"Product '{product.name}' currency ({product.currency}) does "
                        f"not match requested currency ({target_currency})."
                    ),
                )

            variant: Optional[ProductVariant] = None
            if item.variant_id:
                variant = await self.product_repo.get_variant_by_id(item.variant_id)
                if not variant or variant.product_id != product.id:
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail=f"Variant '{item.variant_id}' does not belong to product '{product.name}'.",
                    )
                if not variant.is_active:
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail=f"Variant '{variant.variant_name}' is inactive.",
                    )

            if item.price_override is not None:
                effective_unit_price = item.price_override.quantize(Decimal("0.0001"))
                price_override_applied = True
                adj_type = None
                adj_val = None
            else:
                effective_unit_price = self.calculate_variant_unit_price(
                    product.sales_price, variant
                )
                price_override_applied = False
                adj_type = variant.adjustment_type if variant else None
                adj_val = variant.adjustment_value if variant else None

            subtotal = (effective_unit_price * Decimal(item.quantity)).quantize(
                Decimal("0.0001")
            )
            total_price += subtotal

            results.append(
                PriceCalculationItemResult(
                    product_id=product.id,
                    product_name=product.name,
                    product_sku=product.sku,
                    variant_id=variant.id if variant else None,
                    variant_name=variant.variant_name if variant else None,
                    variant_code=variant.variant_code if variant else None,
                    base_unit_price=product.sales_price,
                    adjustment_type=adj_type,
                    adjustment_value=adj_val,
                    effective_unit_price=effective_unit_price,
                    price_override_applied=price_override_applied,
                    quantity=item.quantity,
                    subtotal=subtotal,
                )
            )

        return PriceCalculationResponse(
            items=results,
            total_price=total_price.quantize(Decimal("0.0001")),
            currency=target_currency,
        )

    def calculate_plan_total(self, plan: SubscriptionPlan) -> Decimal:
        """Calculate total price for a plan by summing active bundled products."""
        total = Decimal("0.0000")
        for bp in plan.bundled_products:
            if not bp.is_active:
                continue

            if bp.price_override is not None:
                unit_price = bp.price_override
            else:
                base_price = bp.product.sales_price if bp.product else Decimal("0.0000")
                unit_price = self.calculate_variant_unit_price(base_price, bp.variant)

            line_total = (unit_price * Decimal(bp.default_quantity)).quantize(Decimal("0.0001"))
            total += line_total

        return total.quantize(Decimal("0.0001"))

