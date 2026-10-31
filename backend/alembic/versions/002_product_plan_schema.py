"""002_product_plan_schema

Revision ID: 002_product_plan_schema
Revises: 001_initial_auth_schema
Create Date: 2026-10-31 11:30:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '002_product_plan_schema'
down_revision: Union[str, None] = '001_initial_auth_schema'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. products table
    op.create_table(
        'products',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column('name', sa.String(length=255), nullable=False),
        sa.Column('sku', sa.String(length=100), nullable=False),
        sa.Column('product_type', sa.String(length=32), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('notes', sa.Text(), nullable=True),
        sa.Column('sales_price', sa.Numeric(precision=14, scale=4), nullable=False),
        sa.Column('cost_price', sa.Numeric(precision=14, scale=4), nullable=True),
        sa.Column('currency', sa.String(length=3), server_default='INR', nullable=False),
        sa.Column('is_active', sa.Boolean(), server_default='true', nullable=False),
        sa.Column('is_archived', sa.Boolean(), server_default='false', nullable=False),
        sa.Column('created_by_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='SET NULL'), nullable=True),
        sa.Column('updated_by_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='SET NULL'), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    )
    op.create_index('ix_products_name', 'products', ['name'], unique=False)
    op.create_index('ix_products_sku', 'products', ['sku'], unique=True)
    op.create_index('ix_products_product_type', 'products', ['product_type'], unique=False)
    op.create_index('ix_products_is_active', 'products', ['is_active'], unique=False)
    op.create_index('ix_products_is_archived', 'products', ['is_archived'], unique=False)

    # 2. product_variants table
    op.create_table(
        'product_variants',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column('product_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('products.id', ondelete='CASCADE'), nullable=False),
        sa.Column('variant_name', sa.String(length=255), nullable=False),
        sa.Column('variant_code', sa.String(length=100), nullable=False),
        sa.Column('adjustment_type', sa.String(length=32), server_default='FIXED_AMOUNT', nullable=False),
        sa.Column('adjustment_value', sa.Numeric(precision=14, scale=4), server_default='0.0000', nullable=False),
        sa.Column('is_active', sa.Boolean(), server_default='true', nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.UniqueConstraint('product_id', 'variant_code', name='uq_product_variants_product_code'),
    )
    op.create_index('ix_product_variants_product_id', 'product_variants', ['product_id'], unique=False)
    op.create_index('ix_product_variants_is_active', 'product_variants', ['is_active'], unique=False)

    # 3. product_price_history table
    op.create_table(
        'product_price_history',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column('product_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('products.id', ondelete='CASCADE'), nullable=False),
        sa.Column('price_field', sa.String(length=32), nullable=False),
        sa.Column('old_price', sa.Numeric(precision=14, scale=4), nullable=True),
        sa.Column('new_price', sa.Numeric(precision=14, scale=4), nullable=False),
        sa.Column('changed_by_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='SET NULL'), nullable=True),
        sa.Column('reason', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    )
    op.create_index('ix_product_price_history_product_id', 'product_price_history', ['product_id'], unique=False)
    op.create_index('ix_product_price_history_created_at', 'product_price_history', ['created_at'], unique=False)

    # 4. variant_price_history table
    op.create_table(
        'variant_price_history',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column('variant_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('product_variants.id', ondelete='CASCADE'), nullable=False),
        sa.Column('old_adjustment_type', sa.String(length=32), nullable=True),
        sa.Column('new_adjustment_type', sa.String(length=32), nullable=False),
        sa.Column('old_adjustment_value', sa.Numeric(precision=14, scale=4), nullable=True),
        sa.Column('new_adjustment_value', sa.Numeric(precision=14, scale=4), nullable=False),
        sa.Column('changed_by_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='SET NULL'), nullable=True),
        sa.Column('reason', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    )
    op.create_index('ix_variant_price_history_variant_id', 'variant_price_history', ['variant_id'], unique=False)
    op.create_index('ix_variant_price_history_created_at', 'variant_price_history', ['created_at'], unique=False)

    # 5. subscription_plans table
    op.create_table(
        'subscription_plans',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column('code', sa.String(length=100), nullable=False),
        sa.Column('name', sa.String(length=255), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('billing_interval', sa.String(length=32), server_default='MONTHLY', nullable=False),
        sa.Column('interval_count', sa.Integer(), server_default='1', nullable=False),
        sa.Column('trial_period_days', sa.Integer(), server_default='0', nullable=False),
        sa.Column('status', sa.String(length=32), server_default='DRAFT', nullable=False),
        sa.Column('currency', sa.String(length=3), server_default='INR', nullable=False),
        sa.Column('min_quantity', sa.Integer(), server_default='1', nullable=False),
        sa.Column('max_quantity', sa.Integer(), nullable=True),
        sa.Column('is_auto_close', sa.Boolean(), server_default='false', nullable=False),
        sa.Column('availability_start_date', sa.DateTime(timezone=True), nullable=True),
        sa.Column('availability_end_date', sa.DateTime(timezone=True), nullable=True),
        sa.Column('created_by_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='SET NULL'), nullable=True),
        sa.Column('updated_by_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='SET NULL'), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    )
    op.create_index('ix_subscription_plans_code', 'subscription_plans', ['code'], unique=True)
    op.create_index('ix_subscription_plans_name', 'subscription_plans', ['name'], unique=False)
    op.create_index('ix_subscription_plans_status', 'subscription_plans', ['status'], unique=False)

    # 6. plan_products table
    op.create_table(
        'plan_products',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column('plan_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('subscription_plans.id', ondelete='CASCADE'), nullable=False),
        sa.Column('product_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('products.id', ondelete='CASCADE'), nullable=False),
        sa.Column('variant_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('product_variants.id', ondelete='SET NULL'), nullable=True),
        sa.Column('default_quantity', sa.Integer(), server_default='1', nullable=False),
        sa.Column('is_optional', sa.Boolean(), server_default='false', nullable=False),
        sa.Column('price_override', sa.Numeric(precision=14, scale=4), nullable=True),
        sa.Column('is_active', sa.Boolean(), server_default='true', nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.UniqueConstraint('plan_id', 'product_id', 'variant_id', name='uq_plan_products_plan_product_variant'),
    )
    op.create_index('ix_plan_products_plan_id', 'plan_products', ['plan_id'], unique=False)
    op.create_index('ix_plan_products_product_id', 'plan_products', ['product_id'], unique=False)
    op.create_index('ix_plan_products_variant_id', 'plan_products', ['variant_id'], unique=False)


def downgrade() -> None:
    op.drop_table('plan_products')
    op.drop_table('subscription_plans')
    op.drop_table('variant_price_history')
    op.drop_table('product_price_history')
    op.drop_table('product_variants')
    op.drop_table('products')

