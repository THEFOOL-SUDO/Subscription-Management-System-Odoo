export interface QuotationTemplateItem {
  id?: string;
  product_id: string;
  variant_id?: string | null;
  quantity: number;
  unit_price: number | string;
  notes?: string | null;
  product_name?: string;
  variant_name?: string;
}

export interface QuotationTemplate {
  id: string;
  code: string;
  name: string;
  description?: string | null;
  plan_id: string;
  plan_name?: string;
  validity_days: number;
  payment_terms: string;
  tax_rate: number | string;
  discount_amount: number | string;
  is_active: boolean;
  items: QuotationTemplateItem[];
  created_at: string;
  updated_at: string;
}

export interface QuotationTemplateCreateRequest {
  code: string;
  name: string;
  description?: string;
  plan_id: string;
  validity_days: number;
  payment_terms: string;
  tax_rate: number | string;
  discount_amount: number | string;
  is_active?: boolean;
  items?: QuotationTemplateItem[];
}

export interface QuotationConvertToSubscriptionRequest {
  customer_id: string;
  start_date: string;
  notes?: string;
}

export interface QuotationTemplateListResponse {
  items: QuotationTemplate[];
  total: number;
}
