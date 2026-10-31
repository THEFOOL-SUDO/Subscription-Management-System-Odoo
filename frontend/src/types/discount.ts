export interface DiscountRule {
  id: string;
  code: string;
  name: string;
  description?: string | null;
  discount_type: "PERCENTAGE" | "FIXED_AMOUNT";
  discount_value: number | string;
  min_purchase_amount?: number | string | null;
  min_quantity?: number | null;
  max_uses?: number | null;
  current_uses: number;
  valid_from?: string | null;
  valid_until?: string | null;
  is_active: boolean;
  scope: string;
  product_id?: string | null;
  created_at: string;
  updated_at: string;
}

export interface DiscountRuleCreateRequest {
  code: string;
  name: string;
  description?: string;
  discount_type: "PERCENTAGE" | "FIXED_AMOUNT";
  discount_value: number | string;
  min_purchase_amount?: number | string;
  min_quantity?: number;
  max_uses?: number;
  valid_from?: string;
  valid_until?: string;
  is_active?: boolean;
  scope?: string;
}

export interface DiscountValidateResponse {
  is_valid: boolean;
  rule_id?: string;
  code: string;
  discount_type?: string;
  discount_value?: number | string;
  calculated_discount: number | string;
  message: string;
}

export interface DiscountRuleListResponse {
  items: DiscountRule[];
  total: number;
}
