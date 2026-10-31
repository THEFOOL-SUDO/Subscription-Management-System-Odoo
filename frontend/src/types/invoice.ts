import { Customer } from "./customer";

export type InvoiceStatus = "DRAFT" | "CONFIRMED" | "PAID" | "CANCELLED";
export type InvoicePaymentStatus = "UNPAID" | "PARTIALLY_PAID" | "PAID";

export interface InvoiceItem {
  id: string;
  invoice_id: string;
  product_id: string;
  variant_id: string | null;
  description: string;
  quantity: number;
  unit_price: string;
  subtotal: string;
}

export interface Invoice {
  id: string;
  invoice_number: string;
  subscription_id: string;
  customer_id: string;
  status: InvoiceStatus;
  payment_status: InvoicePaymentStatus;
  issue_date: string;
  due_date: string;
  billing_period_start: string;
  billing_period_end: string;
  currency: string;
  subtotal: string;
  tax_rate: string;
  tax_amount: string;
  discount_amount: string;
  total_amount: string;
  amount_paid: string;
  balance_due: string;
  notes: string | null;
  created_by_id: string | null;
  created_at: string;
  updated_at: string;
  customer?: Customer;
  items: InvoiceItem[];
}

export interface InvoiceCreateRequest {
  subscription_id: string;
  issue_date?: string;
  billing_period_start?: string;
  billing_period_end?: string;
  tax_rate?: string | number;
  discount_amount?: string | number;
  notes?: string;
}

export interface InvoiceListResponse {
  items: Invoice[];
  total: number;
  page: number;
  size: number;
  pages: number;
}

