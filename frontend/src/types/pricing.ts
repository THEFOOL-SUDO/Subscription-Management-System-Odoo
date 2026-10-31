import { AdjustmentType } from "./product";

export interface PriceCalculationItem {
  product_id: string;
  variant_id?: string | null;
  quantity: number;
  price_override?: string | null;
}

export interface PriceCalculationRequest {
  items: PriceCalculationItem[];
  currency?: string;
}

export interface PriceCalculationItemResult {
  product_id: string;
  product_name: string;
  product_sku: string;
  variant_id: string | null;
  variant_name: string | null;
  variant_code: string | null;
  base_unit_price: string;
  adjustment_type: AdjustmentType | null;
  adjustment_value: string | null;
  effective_unit_price: string;
  price_override_applied: boolean;
  quantity: number;
  subtotal: string;
}

export interface PriceCalculationResponse {
  items: PriceCalculationItemResult[];
  total_price: string;
  currency: string;
}

