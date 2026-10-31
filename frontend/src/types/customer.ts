export type CustomerStatus = "ACTIVE" | "INACTIVE";

export interface Customer {
  id: string;
  user_id: string | null;
  customer_number: string;
  name: string;
  email: string;
  phone: string | null;
  company_name: string | null;
  billing_address_line1: string | null;
  billing_address_line2: string | null;
  billing_city: string | null;
  billing_state: string | null;
  billing_postal_code: string | null;
  billing_country: string;
  status: CustomerStatus;
  created_by_id: string | null;
  updated_by_id: string | null;
  created_at: string;
  updated_at: string;
}

export interface CustomerCreate {
  name: string;
  email: string;
  phone?: string | null;
  company_name?: string | null;
  billing_address_line1?: string | null;
  billing_address_line2?: string | null;
  billing_city?: string | null;
  billing_state?: string | null;
  billing_postal_code?: string | null;
  billing_country?: string;
}

export interface CustomerUpdate {
  name?: string;
  phone?: string | null;
  company_name?: string | null;
  billing_address_line1?: string | null;
  billing_address_line2?: string | null;
  billing_city?: string | null;
  billing_state?: string | null;
  billing_postal_code?: string | null;
  billing_country?: string;
  status?: CustomerStatus;
}

export interface CustomerListResponse {
  items: Customer[];
  total: number;
  page: number;
  size: number;
  pages: number;
}

