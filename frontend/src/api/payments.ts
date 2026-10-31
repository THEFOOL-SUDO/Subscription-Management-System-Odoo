import apiClient from "./client";
import { Payment, PaymentCreateRequest, PaymentListResponse } from "@/types";

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
};

