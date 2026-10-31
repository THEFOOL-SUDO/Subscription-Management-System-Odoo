import apiClient from "./client";

export interface BillingSchedulerResult {
  processed_count: number;
  invoices_generated_count: number;
  invoices: Array<{
    subscription_number: string;
    invoice_number: string;
    customer_name: string;
    total_amount: string;
    next_billing_date: string;
  }>;
  errors: string[];
  timestamp: string;
}

export const billingApi = {
  runBillingScheduler: async (): Promise<BillingSchedulerResult> => {
    const response = await apiClient.post<BillingSchedulerResult>("/api/v1/billing/run-scheduler");
    return response.data;
  },
};
