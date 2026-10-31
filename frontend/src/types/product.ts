export type ProductType = "SOFTWARE" | "ADDON" | "PHYSICAL_PRODUCT";
export type AdjustmentType = "FIXED_AMOUNT" | "PERCENTAGE";

export interface VariantPriceHistory {
  id: string;
  variant_id: string;
  old_adjustment_type: AdjustmentType | null;
  new_adjustment_type: AdjustmentType;
  old_adjustment_value: string | null;
  new_adjustment_value: string;
  changed_by_id: string | null;
  reason: string | null;
  created_at: string;
}

export interface ProductVariant {
  id: string;
  product_id: string;
  variant_name: string;
  variant_code: string;
  adjustment_type: AdjustmentType;
  adjustment_value: string;
  is_active: boolean;
  description: string | null;
  created_at: string;
  updated_at: string;
  price_history?: VariantPriceHistory[];
}

export interface ProductPriceHistory {
  id: string;
  product_id: string;
  price_field: string;
  old_price: string | null;
  new_price: string;
  changed_by_id: string | null;
  reason: string | null;
  created_at: string;
}

export interface Product {
  id: string;
  name: string;
  sku: string;
  product_type: ProductType;
  description: string | null;
  notes: string | null;
  sales_price: string;
  cost_price: string | null;
  currency: string;
  is_active: boolean;
  is_archived: boolean;
  created_at: string;
  updated_at: string;
  created_by_id: string | null;
  updated_by_id: string | null;
  variants_count: number;
}

export interface ProductDetail extends Product {
  variants: ProductVariant[];
  price_history: ProductPriceHistory[];
}

export interface ProductListResponse {
  items: Product[];
  total: number;
  page: number;
  limit: number;
  total_pages: number;
}

export interface ProductCreateInput {
  name: string;
  sku: string;
  product_type: ProductType;
  description?: string;
  notes?: string;
  sales_price: string;
  cost_price?: string;
  currency?: string;
  is_active?: boolean;
  variants?: Array<{
    variant_name: string;
    variant_code: string;
    adjustment_type: AdjustmentType;
    adjustment_value: string;
    is_active?: boolean;
    description?: string;
  }>;
}

export interface ProductUpdateInput {
  name?: string;
  sku?: string;
  product_type?: ProductType;
  description?: string;
  notes?: string;
  sales_price?: string;
  cost_price?: string;
  currency?: string;
  is_active?: boolean;
  is_archived?: boolean;
  price_change_reason?: string;
}

export interface VariantCreateInput {
  variant_name: string;
  variant_code: string;
  adjustment_type: AdjustmentType;
  adjustment_value: string;
  is_active?: boolean;
  description?: string;
}

export interface VariantUpdateInput {
  variant_name?: string;
  variant_code?: string;
  adjustment_type?: AdjustmentType;
  adjustment_value?: string;
  is_active?: boolean;
  description?: string;
  reason?: string;
}

