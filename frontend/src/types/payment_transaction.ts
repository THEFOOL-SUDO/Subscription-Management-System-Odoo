export interface CheckoutSessionResponse {
  session_token: string;
  invoice_id: string;
  invoice_number: string;
  customer_id: string;
  customer_name: string;
  customer_email: string;
  currency: string;
  total_amount: number | string;
  amount_paid: number | string;
  balance_due: number | string;
  status: string;
  payment_status: string;
  allowed_methods: string[];
  demo_disclaimer: string;
}

export interface DemoPaymentProcessRequest {
  session_token: string;
  payment_method: "DEMO_UPI" | "DEMO_CARD" | "DEMO_NETBANKING";
  scenario: "SUCCESS_FULL" | "SUCCESS_PARTIAL" | "DECLINE_GENERIC" | "CANCEL_USER";
  amount?: number | string;
  idempotency_key?: string;
  payer_vpa?: string;
  card_last4?: string;
  bank_name?: string;
}

export interface PaymentTransactionResponse {
  id: string;
  transaction_reference: string;
  invoice_id: string;
  customer_id: string;
  amount: number | string;
  currency: string;
  provider: string;
  payment_method: string;
  status: "INITIATED" | "SUCCESS" | "FAILED" | "CANCELLED";
  idempotency_key?: string;
  metadata_json?: Record<string, any>;
  created_at: string;
  updated_at: string;
  invoice_number?: string;
  invoice_status?: string;
  invoice_payment_status?: string;
  remaining_balance?: number | string;
  demo_disclaimer: string;
}

export interface PaymentTransactionListResponse {
  items: PaymentTransactionResponse[];
  total: number;
  page: number;
  limit: number;
}
