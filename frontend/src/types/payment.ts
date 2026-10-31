export type PaymentMethod =
  | "BANK_TRANSFER"
  | "UPI"
  | "CREDIT_CARD"
  | "DEBIT_CARD"
  | "CASH"
  | "CHEQUE"
  | "OTHER";

export interface Payment {
  id: string;
  payment_number: string;
  invoice_id: string;
  customer_id: string;
  amount: string;
  currency: string;
  payment_method: PaymentMethod;
  payment_date: string;
  reference_number: string | null;
  notes: string | null;
  recorded_by_id: string;
  created_at: string;
}

export interface PaymentCreateRequest {
  invoice_id: string;
  amount: string | number;
  payment_method: PaymentMethod;
  payment_date?: string;
  reference_number?: string;
  notes?: string;
}

export interface PaymentListResponse {
  items: Payment[];
  total: number;
  page: number;
  size: number;
  pages: number;
}

