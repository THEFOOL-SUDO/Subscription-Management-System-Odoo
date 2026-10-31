export * from "./product";
export * from "./plan";
export * from "./pricing";

export type UserRole = "ADMIN" | "STAFF" | "CUSTOMER";

export interface User {
  id: string;
  email: string;
  full_name: string;
  role: UserRole;
  is_active: boolean;
  is_verified: boolean;
  created_at: string;
  updated_at: string;
}

export interface AuthResponse {
  access_token: string;
  token_type: string;
  user: User;
}

export interface MessageResponse {
  message: string;
  success?: boolean;
}

export interface AuditLog {
  id: string;
  user_id: string | null;
  user_email: string | null;
  action: string;
  resource_type: string;
  resource_id: string | null;
  details: Record<string, any>;
  ip_address: string | null;
  user_agent: string | null;
  created_at: string;
}

export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  size: number;
  pages: number;
}

export interface HealthCheckResponse {
  status: "healthy" | "unhealthy";
  environment: string;
  version: string;
  services: {
    database: string;
    redis: string;
  };
  metrics: {
    database_latency_ms?: number;
    redis_latency_ms?: number;
  };
}
