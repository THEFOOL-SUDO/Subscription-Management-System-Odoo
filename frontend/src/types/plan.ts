import { Product, ProductVariant } from "./product";

export type BillingInterval = "DAILY" | "WEEKLY" | "MONTHLY" | "YEARLY";
export type PlanStatus = "DRAFT" | "ACTIVE" | "INACTIVE" | "ARCHIVED";

export interface PlanProduct {
  id: string;
  plan_id: string;
  product_id: string;
  variant_id: string | null;
  default_quantity: number;
  is_optional: boolean;
  price_override: string | null;
  is_active: boolean;
  created_at: string;
  updated_at: string;
  product?: Product;
  variant?: ProductVariant;
}

export interface SubscriptionPlan {
  id: string;
  code: string;
  name: string;
  description: string | null;
  billing_interval: BillingInterval;
  interval_count: number;
  trial_period_days: number;
  status: PlanStatus;
  currency: string;
  min_quantity: number;
  max_quantity: number | null;
  is_auto_close: boolean;
  availability_start_date: string | null;
  availability_end_date: string | null;
  created_at: string;
  updated_at: string;
  created_by_id: string | null;
  updated_by_id: string | null;
  bundled_products_count: number;
  calculated_total_price: string;
}

export interface SubscriptionPlanDetail extends SubscriptionPlan {
  bundled_products: PlanProduct[];
}

export interface SubscriptionPlanListResponse {
  items: SubscriptionPlan[];
  total: number;
  page: number;
  limit: number;
  total_pages: number;
}

export interface SubscriptionPlanCreateInput {
  code: string;
  name: string;
  description?: string;
  billing_interval: BillingInterval;
  interval_count?: number;
  trial_period_days?: number;
  status?: PlanStatus;
  currency?: string;
  min_quantity?: number;
  max_quantity?: number;
  is_auto_close?: boolean;
  availability_start_date?: string | null;
  availability_end_date?: string | null;
  bundled_products?: Array<{
    product_id: string;
    variant_id?: string | null;
    default_quantity: number;
    is_optional?: boolean;
    price_override?: string | null;
    is_active?: boolean;
  }>;
}

export interface SubscriptionPlanUpdateInput {
  code?: string;
  name?: string;
  description?: string;
  billing_interval?: BillingInterval;
  interval_count?: number;
  trial_period_days?: number;
  currency?: string;
  min_quantity?: number;
  max_quantity?: number | null;
  is_auto_close?: boolean;
  availability_start_date?: string | null;
  availability_end_date?: string | null;
}

export interface PlanProductCreateInput {
  product_id: string;
  variant_id?: string | null;
  default_quantity: number;
  is_optional?: boolean;
  price_override?: string | null;
  is_active?: boolean;
}

export interface PlanProductUpdateInput {
  variant_id?: string | null;
  default_quantity?: number;
  is_optional?: boolean;
  price_override?: string | null;
  is_active?: boolean;
}

