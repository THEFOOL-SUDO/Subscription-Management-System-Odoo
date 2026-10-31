import apiClient from "./client";
import {
  Customer,
  CustomerCreate,
  CustomerListResponse,
  CustomerStatus,
  CustomerUpdate,
} from "@/types";

export const customersApi = {
  listCustomers: async (params?: {
    page?: number;
    limit?: number;
    search?: string;
    status?: CustomerStatus;
  }): Promise<CustomerListResponse> => {
    const response = await apiClient.get<CustomerListResponse>("/api/v1/customers", {
      params,
    });
    return response.data;
  },

  getCustomer: async (id: string): Promise<Customer> => {
    const response = await apiClient.get<Customer>(`/api/v1/customers/${id}`);
    return response.data;
  },

  getMyProfile: async (): Promise<Customer> => {
    const response = await apiClient.get<Customer>("/api/v1/customers/me");
    return response.data;
  },

  createCustomer: async (data: CustomerCreate): Promise<Customer> => {
    const response = await apiClient.post<Customer>("/api/v1/customers", data);
    return response.data;
  },

  updateCustomer: async (id: string, data: CustomerUpdate): Promise<Customer> => {
    const response = await apiClient.put<Customer>(`/api/v1/customers/${id}`, data);
    return response.data;
  },
};

