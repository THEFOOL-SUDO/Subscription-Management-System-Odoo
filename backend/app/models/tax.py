import uuid
from decimal import Decimal
from typing import Optional
from sqlalchemy import (
    Boolean,
    Numeric,
    String,
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column
from app.models.base import Base, TimestampMixin


class TaxRule(Base, TimestampMixin):
    __tablename__ = "tax_rules"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        nullable=False,
    )
    name: Mapped[str] = mapped_column(
        String(100),
        index=True,
        nullable=False,
    )
    tax_rate: Mapped[Decimal] = mapped_column(
        Numeric(6, 4),
        nullable=False,
    )
    country: Mapped[str] = mapped_column(
        String(3),
        default="IND",
        nullable=False,
    )
    state: Mapped[Optional[str]] = mapped_column(
        String(100),
        nullable=True,
    )
    is_default: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        nullable=False,
    )
    is_active: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
        nullable=False,
    )
