import apiClient from "./client";
import { Payment, PaymentCreateRequest, PaymentListResponse } from "@/types";
import {
  CheckoutSessionResponse,
  DemoPaymentProcessRequest,
  PaymentTransactionListResponse,
  PaymentTransactionResponse,
} from "@/types/payment_transaction";

export const paymentsApi = {
  listPayments: async (params?: {
    page?: number;
    limit?: number;
    invoice_id?: string;
    customer_id?: string;
  }): Promise<PaymentListResponse> => {
    const response = await apiClient.get<PaymentListResponse>("/api/v1/payments", {
      params,
    });
    return response.data;
  },

  getPayment: async (id: string): Promise<Payment> => {
    const response = await apiClient.get<Payment>(`/api/v1/payments/${id}`);
    return response.data;
  },

  recordPayment: async (data: PaymentCreateRequest): Promise<Payment> => {
    const response = await apiClient.post<Payment>("/api/v1/payments", data);
    return response.data;
  },

  createCheckoutSession: async (invoiceId: string): Promise<CheckoutSessionResponse> => {
    const response = await apiClient.post<CheckoutSessionResponse>("/api/v1/payments/demo/checkout-session", {
      invoice_id: invoiceId,
    });
    return response.data;
  },

  processDemoPayment: async (data: DemoPaymentProcessRequest): Promise<PaymentTransactionResponse> => {
    const response = await apiClient.post<PaymentTransactionResponse>("/api/v1/payments/demo/process", data);
    return response.data;
  },

  listTransactions: async (params?: {
    page?: number;
    limit?: number;
    invoice_id?: string;
    customer_id?: string;
    status?: string;
  }): Promise<PaymentTransactionListResponse> => {
    const response = await apiClient.get<PaymentTransactionListResponse>("/api/v1/payments/transactions", {
      params,
    });
    return response.data;
  },
};
