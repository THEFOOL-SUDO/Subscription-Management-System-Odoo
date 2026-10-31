import apiClient from "./client";
import {
  Invoice,
  InvoiceCreateRequest,
  InvoiceListResponse,
  InvoicePaymentStatus,
  InvoiceStatus,
} from "@/types";

export const invoicesApi = {
  listInvoices: async (params?: {
    page?: number;
    limit?: number;
    customer_id?: string;
    subscription_id?: string;
    status?: InvoiceStatus;
    payment_status?: InvoicePaymentStatus;
    search?: string;
  }): Promise<InvoiceListResponse> => {
    const response = await apiClient.get<InvoiceListResponse>("/api/v1/invoices", {
      params,
    });
    return response.data;
  },

  getInvoice: async (id: string): Promise<Invoice> => {
    const response = await apiClient.get<Invoice>(`/api/v1/invoices/${id}`);
    return response.data;
  },

  createInvoice: async (data: InvoiceCreateRequest): Promise<Invoice> => {
    const response = await apiClient.post<Invoice>("/api/v1/invoices", data);
    return response.data;
  },

  transitionStatus: async (
    id: string,
    to_status: InvoiceStatus,
    notes?: string
  ): Promise<Invoice> => {
    const response = await apiClient.post<Invoice>(`/api/v1/invoices/${id}/status`, {
      to_status,
      notes,
    });
    return response.data;
  },
};

