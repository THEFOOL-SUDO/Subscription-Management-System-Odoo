import { Customer } from "./customer";
import { BillingInterval, SubscriptionPlan } from "./plan";
import { Product, ProductVariant } from "./product";

export type SubscriptionStatus =
  | "DRAFT"
  | "QUOTATION"
  | "CONFIRMED"
  | "ACTIVE"
  | "PAUSED"
  | "CLOSED";

export type PaymentTerms = "IMMEDIATE" | "NET_15" | "NET_30" | "NET_60";

export interface SubscriptionItem {
  id: string;
  subscription_id: string;
  product_id: string;
  variant_id: string | null;
  quantity: number;
  unit_price: string;
  subtotal: string;
  notes: string | null;
  product?: Product;
  variant?: ProductVariant;
}

export interface SubscriptionStatusHistory {
  id: string;
  from_status: string | null;
  to_status: string;
  reason: string | null;
  changed_by_id: string | null;
  created_at: string;
}

export interface Subscription {
  id: string;
  subscription_number: string;
  customer_id: string;
  plan_id: string;
  status: SubscriptionStatus;
  start_date: string;
  expiry_date: string | null;
  next_billing_date?: string | null;
  paused_at?: string | null;
  total_paused_days?: number;
  billing_interval: BillingInterval;
  interval_count: number;
  currency: string;
  payment_terms: PaymentTerms;
  subtotal: string;
  tax_rate: string;
  tax_amount: string;
  discount_amount: string;
  total_amount: string;
  notes: string | null;
  created_by_id: string | null;
  updated_by_id: string | null;
  created_at: string;
  updated_at: string;
  customer?: Customer;
  plan?: SubscriptionPlan;
  items: SubscriptionItem[];
  status_history: SubscriptionStatusHistory[];
}

export interface SubscriptionItemCreate {
  product_id: string;
  variant_id?: string | null;
  quantity: number;
  notes?: string | null;
}

export interface SubscriptionCreate {
  customer_id: string;
  plan_id: string;
  start_date: string;
  payment_terms?: PaymentTerms;
  tax_rate?: string | number;
  discount_amount?: string | number;
  notes?: string | null;
  items?: SubscriptionItemCreate[];
}

export interface SubscriptionListResponse {
  items: Subscription[];
  total: number;
  page: number;
  size: number;
  pages: number;
}
