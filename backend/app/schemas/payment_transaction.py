import datetime
import uuid
from decimal import Decimal
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, ConfigDict, Field
from app.models.invoice import InvoicePaymentStatus, InvoiceStatus


class CheckoutSessionRequest(BaseModel):
    invoice_id: uuid.UUID


class CheckoutSessionResponse(BaseModel):
    session_token: str
    invoice_id: uuid.UUID
    invoice_number: str
    customer_id: uuid.UUID
    customer_name: str
    customer_email: str
    currency: str
    total_amount: Decimal
    amount_paid: Decimal
    balance_due: Decimal
    status: InvoiceStatus
    payment_status: InvoicePaymentStatus
    allowed_methods: List[str] = ["DEMO_UPI", "DEMO_CARD", "DEMO_NETBANKING"]
    demo_disclaimer: str = "DEMO MODE — SIMULATED PAYMENT — NO REAL MONEY TRANSFERRED"


class DemoPaymentProcessRequest(BaseModel):
    session_token: str
    payment_method: str = Field(..., description="DEMO_UPI, DEMO_CARD, or DEMO_NETBANKING")
    scenario: str = Field("SUCCESS_FULL", description="SUCCESS_FULL, SUCCESS_PARTIAL, DECLINE_GENERIC, CANCEL_USER")
    amount: Optional[Decimal] = Field(None, description="Payment amount. Required if SUCCESS_PARTIAL.")
    idempotency_key: Optional[str] = None
    payer_vpa: Optional[str] = Field(None, description="Demo UPI VPA (e.g. user@okhdfcbank)")
    card_last4: Optional[str] = Field(None, description="Demo Card last 4 digits")
    bank_name: Optional[str] = Field(None, description="Demo Bank Name")


class PaymentTransactionResponse(BaseModel):
    id: uuid.UUID
    transaction_reference: str
    invoice_id: uuid.UUID
    customer_id: uuid.UUID
    amount: Decimal
    currency: str
    provider: str
    payment_method: str
    status: str
    idempotency_key: Optional[str] = None
    metadata_json: Optional[Dict[str, Any]] = None
    created_at: datetime.datetime
    updated_at: datetime.datetime

    # Invoice state summary
    invoice_number: Optional[str] = None
    invoice_status: Optional[str] = None
    invoice_payment_status: Optional[str] = None
    remaining_balance: Optional[Decimal] = None
    demo_disclaimer: str = "DEMO MODE — SIMULATED PAYMENT — NO REAL MONEY TRANSFERRED"

    model_config = ConfigDict(from_attributes=True)


class PaymentTransactionListResponse(BaseModel):
    items: List[PaymentTransactionResponse]
    total: int
    page: int
    limit: int
