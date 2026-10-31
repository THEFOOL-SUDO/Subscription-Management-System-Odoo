export interface RevenueTrendPoint {
  period: string;
  revenue: string;
  payments_count: number;
}

export interface RecentPaymentItem {
  id: string;
  payment_number: string;
  customer_name: string;
  amount: string;
  currency: string;
  payment_method: string;
  payment_date: string;
}

export interface RecentSubscriptionItem {
  id: string;
  subscription_number: string;
  customer_name: string;
  plan_name: string;
  status: string;
  total_amount: string;
  currency: string;
  created_at: string;
}

export interface DashboardMetrics {
  active_subscriptions: number;
  total_customers: number;
  revenue_collected: string;
  outstanding_invoice_amount: string;
  overdue_invoices: number;
  currency: string;
  revenue_trend: RevenueTrendPoint[];
  recent_payments: RecentPaymentItem[];
  recent_subscriptions: RecentSubscriptionItem[];
}

