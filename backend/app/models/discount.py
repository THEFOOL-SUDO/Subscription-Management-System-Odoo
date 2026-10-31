import datetime
import enum
import uuid
from decimal import Decimal
from typing import TYPE_CHECKING, Optional
from sqlalchemy import (
    Boolean,
    DateTime,
    Enum,
    ForeignKey,
    Integer,
    Numeric,
    String,
    Text,
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.models.base import Base, TimestampMixin

if TYPE_CHECKING:
    from app.models.user import User
    from app.models.product import Product


class DiscountType(str, enum.Enum):
    PERCENTAGE = "PERCENTAGE"
    FIXED_AMOUNT = "FIXED_AMOUNT"


class DiscountScope(str, enum.Enum):
    SUBSCRIPTION = "SUBSCRIPTION"
    INVOICE = "INVOICE"
    PRODUCT = "PRODUCT"


class DiscountRule(Base, TimestampMixin):
    __tablename__ = "discount_rules"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        nullable=False,
    )
    code: Mapped[str] = mapped_column(
        String(50),
        unique=True,
        index=True,
        nullable=False,
    )
    name: Mapped[str] = mapped_column(
        String(255),
        nullable=False,
    )
    description: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True,
    )
    discount_type: Mapped[str] = mapped_column(
        String(20),
        nullable=False,
    )
    discount_value: Mapped[Decimal] = mapped_column(
        Numeric(14, 4),
        nullable=False,
    )
    min_purchase_amount: Mapped[Optional[Decimal]] = mapped_column(
        Numeric(14, 4),
        nullable=True,
    )
    min_quantity: Mapped[Optional[int]] = mapped_column(
        Integer,
        nullable=True,
    )
    max_uses: Mapped[Optional[int]] = mapped_column(
        Integer,
        nullable=True,
    )
    current_uses: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False,
    )
    valid_from: Mapped[Optional[datetime.datetime]] = mapped_column(
        DateTime(timezone=True),
        nullable=True,
    )
    valid_until: Mapped[Optional[datetime.datetime]] = mapped_column(
        DateTime(timezone=True),
        nullable=True,
    )
    is_active: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
        index=True,
        nullable=False,
    )
    scope: Mapped[str] = mapped_column(
        String(20),
        default="SUBSCRIPTION",
        nullable=False,
    )
    product_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("products.id", ondelete="SET NULL"),
        nullable=True,
    )
    created_by_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
    )

    product: Mapped[Optional["Product"]] = relationship("Product", lazy="joined")
    created_by: Mapped[Optional["User"]] = relationship("User", lazy="select")
