export interface TaxRule {
  id: string;
  name: string;
  tax_rate: number | string;
  country: string;
  state?: string | null;
  is_default: boolean;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface TaxRuleCreateRequest {
  name: string;
  tax_rate: number | string;
  country?: string;
  state?: string;
  is_default?: boolean;
  is_active?: boolean;
}

export interface TaxRuleListResponse {
  items: TaxRule[];
  total: number;
}
