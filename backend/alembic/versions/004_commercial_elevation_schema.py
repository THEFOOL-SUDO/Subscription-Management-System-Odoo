"""004_commercial_elevation_schema

Revision ID: 004_commercial_elevation_schema
Revises: 003_subscription_billing_schema
Create Date: 2026-10-31 14:25:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '004_commercial_elevation_schema'
down_revision: Union[str, None] = '003_subscription_billing_schema'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. quotation_templates table
    op.create_table(
        'quotation_templates',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column('code', sa.String(length=50), unique=True, nullable=False),
        sa.Column('name', sa.String(length=255), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('plan_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('subscription_plans.id', ondelete='CASCADE'), nullable=False),
        sa.Column('validity_days', sa.Integer(), server_default='30', nullable=False),
        sa.Column('payment_terms', sa.String(length=30), server_default='NET_30', nullable=False),
        sa.Column('tax_rate', sa.Numeric(precision=6, scale=4), server_default='18.0000', nullable=False),
        sa.Column('discount_amount', sa.Numeric(precision=14, scale=4), server_default='0.0000', nullable=False),
        sa.Column('is_active', sa.Boolean(), server_default='true', nullable=False),
        sa.Column('created_by_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='SET NULL'), nullable=True),
        sa.Column('updated_by_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='SET NULL'), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )
    op.create_index('ix_quotation_templates_code', 'quotation_templates', ['code'])
    op.create_index('ix_quotation_templates_plan_id', 'quotation_templates', ['plan_id'])

    # 2. quotation_template_items table
    op.create_table(
        'quotation_template_items',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column('template_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('quotation_templates.id', ondelete='CASCADE'), nullable=False),
        sa.Column('product_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('products.id', ondelete='CASCADE'), nullable=False),
        sa.Column('variant_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('product_variants.id', ondelete='SET NULL'), nullable=True),
        sa.Column('quantity', sa.Integer(), server_default='1', nullable=False),
        sa.Column('unit_price', sa.Numeric(precision=14, scale=4), nullable=False),
        sa.Column('notes', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )
    op.create_index('ix_quotation_template_items_template_id', 'quotation_template_items', ['template_id'])

    # 3. discount_rules table
    op.create_table(
        'discount_rules',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column('code', sa.String(length=50), unique=True, nullable=False),
        sa.Column('name', sa.String(length=255), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('discount_type', sa.String(length=20), nullable=False),
        sa.Column('discount_value', sa.Numeric(precision=14, scale=4), nullable=False),
        sa.Column('min_purchase_amount', sa.Numeric(precision=14, scale=4), nullable=True),
        sa.Column('min_quantity', sa.Integer(), nullable=True),
        sa.Column('max_uses', sa.Integer(), nullable=True),
        sa.Column('current_uses', sa.Integer(), server_default='0', nullable=False),
        sa.Column('valid_from', sa.DateTime(timezone=True), nullable=True),
        sa.Column('valid_until', sa.DateTime(timezone=True), nullable=True),
        sa.Column('is_active', sa.Boolean(), server_default='true', nullable=False),
        sa.Column('scope', sa.String(length=20), server_default='SUBSCRIPTION', nullable=False),
        sa.Column('product_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('products.id', ondelete='SET NULL'), nullable=True),
        sa.Column('created_by_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='SET NULL'), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )
    op.create_index('ix_discount_rules_code', 'discount_rules', ['code'])
    op.create_index('ix_discount_rules_is_active', 'discount_rules', ['is_active'])

    # 4. tax_rules table
    op.create_table(
        'tax_rules',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column('name', sa.String(length=100), nullable=False),
        sa.Column('tax_rate', sa.Numeric(precision=6, scale=4), nullable=False),
        sa.Column('country', sa.String(length=3), server_default='IND', nullable=False),
        sa.Column('state', sa.String(length=100), nullable=True),
        sa.Column('is_default', sa.Boolean(), server_default='false', nullable=False),
        sa.Column('is_active', sa.Boolean(), server_default='true', nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )
    op.create_index('ix_tax_rules_name', 'tax_rules', ['name'])

    # 5. payment_transactions table
    op.create_table(
        'payment_transactions',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column('transaction_reference', sa.String(length=100), unique=True, nullable=False),
        sa.Column('invoice_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('invoices.id', ondelete='RESTRICT'), nullable=False),
        sa.Column('customer_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('customers.id', ondelete='RESTRICT'), nullable=False),
        sa.Column('amount', sa.Numeric(precision=14, scale=4), nullable=False),
        sa.Column('currency', sa.String(length=3), server_default='INR', nullable=False),
        sa.Column('provider', sa.String(length=20), server_default='DEMO', nullable=False),
        sa.Column('payment_method', sa.String(length=50), nullable=False),
        sa.Column('status', sa.String(length=20), server_default='INITIATED', nullable=False),
        sa.Column('idempotency_key', sa.String(length=100), unique=True, nullable=True),
        sa.Column('metadata_json', postgresql.JSONB(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )
    op.create_index('ix_payment_transactions_ref', 'payment_transactions', ['transaction_reference'])
    op.create_index('ix_payment_transactions_invoice', 'payment_transactions', ['invoice_id'])
    op.create_index('ix_payment_transactions_idempotency', 'payment_transactions', ['idempotency_key'])

    # 6. Alter subscriptions table
    op.add_column('subscriptions', sa.Column('next_billing_date', sa.DateTime(timezone=True), nullable=True))
    op.add_column('subscriptions', sa.Column('paused_at', sa.DateTime(timezone=True), nullable=True))
    op.add_column('subscriptions', sa.Column('total_paused_days', sa.Integer(), server_default='0', nullable=False))
    op.add_column('subscriptions', sa.Column('discount_rule_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('discount_rules.id', ondelete='SET NULL'), nullable=True))
    op.add_column('subscriptions', sa.Column('quotation_template_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('quotation_templates.id', ondelete='SET NULL'), nullable=True))
    op.create_index('ix_subscriptions_next_billing_date', 'subscriptions', ['next_billing_date'])

    # 7. Alter invoices table
    op.add_column('invoices', sa.Column('discount_rule_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('discount_rules.id', ondelete='SET NULL'), nullable=True))
    op.add_column('invoices', sa.Column('tax_rule_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('tax_rules.id', ondelete='SET NULL'), nullable=True))
    op.add_column('invoices', sa.Column('email_sent_at', sa.DateTime(timezone=True), nullable=True))


def downgrade() -> None:
    op.drop_column('invoices', 'email_sent_at')
    op.drop_column('invoices', 'tax_rule_id')
    op.drop_column('invoices', 'discount_rule_id')

    op.drop_index('ix_subscriptions_next_billing_date', table_name='subscriptions')
    op.drop_column('subscriptions', 'quotation_template_id')
    op.drop_column('subscriptions', 'discount_rule_id')
    op.drop_column('subscriptions', 'total_paused_days')
    op.drop_column('subscriptions', 'paused_at')
    op.drop_column('subscriptions', 'next_billing_date')

    op.drop_table('payment_transactions')
    op.drop_table('tax_rules')
    op.drop_table('discount_rules')
    op.drop_table('quotation_template_items')
    op.drop_table('quotation_templates')
