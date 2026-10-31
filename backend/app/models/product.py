import enum
import uuid
from decimal import Decimal
from typing import TYPE_CHECKING, List, Optional
from sqlalchemy import (
    Boolean,
    DateTime,
    Enum,
    ForeignKey,
    Numeric,
    String,
    Text,
    UniqueConstraint,
    func,
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.models.base import Base, TimestampMixin

if TYPE_CHECKING:
    from app.models.user import User


class ProductType(str, enum.Enum):
    SOFTWARE = "SOFTWARE"
    ADDON = "ADDON"
    PHYSICAL_PRODUCT = "PHYSICAL_PRODUCT"


class AdjustmentType(str, enum.Enum):
    FIXED_AMOUNT = "FIXED_AMOUNT"
    PERCENTAGE = "PERCENTAGE"


class Product(Base, TimestampMixin):
    __tablename__ = "products"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        nullable=False,
    )
    name: Mapped[str] = mapped_column(
        String(255),
        index=True,
        nullable=False,
    )
    sku: Mapped[str] = mapped_column(
        String(100),
        unique=True,
        index=True,
        nullable=False,
    )
    product_type: Mapped[ProductType] = mapped_column(
        Enum(ProductType, name="product_type", native_enum=False),
        nullable=False,
        index=True,
    )
    description: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True,
    )
    notes: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True,
    )
    sales_price: Mapped[Decimal] = mapped_column(
        Numeric(14, 4),
        nullable=False,
    )
    cost_price: Mapped[Optional[Decimal]] = mapped_column(
        Numeric(14, 4),
        nullable=True,
    )
    currency: Mapped[str] = mapped_column(
        String(3),
        default="INR",
        nullable=False,
    )
    is_active: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
        nullable=False,
        index=True,
    )
    is_archived: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        nullable=False,
        index=True,
    )
    created_by_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
    )
    updated_by_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
    )

    # Relationships
    variants: Mapped[List["ProductVariant"]] = relationship(
        "ProductVariant",
        back_populates="product",
        cascade="all, delete-orphan",
        order_by="ProductVariant.variant_name",
        lazy="selectin",
    )
    price_history: Mapped[List["ProductPriceHistory"]] = relationship(
        "ProductPriceHistory",
        back_populates="product",
        cascade="all, delete-orphan",
        order_by="desc(ProductPriceHistory.created_at)",
        lazy="selectin",
    )
    creator: Mapped[Optional["User"]] = relationship(
        "User",
        foreign_keys=[created_by_id],
        lazy="selectin",
    )
    updater: Mapped[Optional["User"]] = relationship(
        "User",
        foreign_keys=[updated_by_id],
        lazy="selectin",
    )


class ProductVariant(Base, TimestampMixin):
    __tablename__ = "product_variants"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        nullable=False,
    )
    product_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("products.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    variant_name: Mapped[str] = mapped_column(
        String(255),
        nullable=False,
    )
    variant_code: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
    )
    adjustment_type: Mapped[AdjustmentType] = mapped_column(
        Enum(AdjustmentType, name="adjustment_type", native_enum=False),
        default=AdjustmentType.FIXED_AMOUNT,
        nullable=False,
    )
    adjustment_value: Mapped[Decimal] = mapped_column(
        Numeric(14, 4),
        default=Decimal("0.0000"),
        nullable=False,
    )
    is_active: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
        nullable=False,
        index=True,
    )
    description: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True,
    )

    __table_args__ = (
        UniqueConstraint("product_id", "variant_code", name="uq_product_variants_product_code"),
    )

    # Relationships
    product: Mapped["Product"] = relationship(
        "Product",
        back_populates="variants",
    )
    price_history: Mapped[List["VariantPriceHistory"]] = relationship(
        "VariantPriceHistory",
        back_populates="variant",
        cascade="all, delete-orphan",
        order_by="desc(VariantPriceHistory.created_at)",
        lazy="selectin",
    )


class ProductPriceHistory(Base):
    __tablename__ = "product_price_history"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        nullable=False,
    )
    product_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("products.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    price_field: Mapped[str] = mapped_column(
        String(32),
        nullable=False,  # "sales_price" or "cost_price"
    )
    old_price: Mapped[Optional[Decimal]] = mapped_column(
        Numeric(14, 4),
        nullable=True,
    )
    new_price: Mapped[Decimal] = mapped_column(
        Numeric(14, 4),
        nullable=False,
    )
    changed_by_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
    )
    reason: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True,
    )
    created_at: Mapped[DateTime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
        index=True,
    )

    # Relationships
    product: Mapped["Product"] = relationship(
        "Product",
        back_populates="price_history",
    )
    changed_by: Mapped[Optional["User"]] = relationship(
        "User",
        foreign_keys=[changed_by_id],
        lazy="selectin",
    )


class VariantPriceHistory(Base):
    __tablename__ = "variant_price_history"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        nullable=False,
    )
    variant_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("product_variants.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    old_adjustment_type: Mapped[Optional[AdjustmentType]] = mapped_column(
        Enum(AdjustmentType, name="old_adjustment_type", native_enum=False),
        nullable=True,
    )
    new_adjustment_type: Mapped[AdjustmentType] = mapped_column(
        Enum(AdjustmentType, name="new_adjustment_type", native_enum=False),
        nullable=False,
    )
    old_adjustment_value: Mapped[Optional[Decimal]] = mapped_column(
        Numeric(14, 4),
        nullable=True,
    )
    new_adjustment_value: Mapped[Decimal] = mapped_column(
        Numeric(14, 4),
        nullable=False,
    )
    changed_by_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
    )
    reason: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True,
    )
    created_at: Mapped[DateTime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
        index=True,
    )

    # Relationships
    variant: Mapped["ProductVariant"] = relationship(
        "ProductVariant",
        back_populates="price_history",
    )
    changed_by: Mapped[Optional["User"]] = relationship(
        "User",
        foreign_keys=[changed_by_id],
        lazy="selectin",
    )

