import apiClient from "./client";
import {
  Subscription,
  SubscriptionCreate,
  SubscriptionListResponse,
  SubscriptionStatus,
} from "@/types";

export const subscriptionsApi = {
  listSubscriptions: async (params?: {
    page?: number;
    limit?: number;
    customer_id?: string;
    status?: SubscriptionStatus;
    search?: string;
  }): Promise<SubscriptionListResponse> => {
    const response = await apiClient.get<SubscriptionListResponse>(
      "/api/v1/subscriptions",
      { params }
    );
    return response.data;
  },

  getSubscription: async (id: string): Promise<Subscription> => {
    const response = await apiClient.get<Subscription>(`/api/v1/subscriptions/${id}`);
    return response.data;
  },

  createSubscription: async (data: SubscriptionCreate): Promise<Subscription> => {
    const response = await apiClient.post<Subscription>("/api/v1/subscriptions", data);
    return response.data;
  },

  transitionStatus: async (
    id: string,
    to_status: SubscriptionStatus,
    reason?: string
  ): Promise<Subscription> => {
    const response = await apiClient.post<Subscription>(
      `/api/v1/subscriptions/${id}/status`,
      { to_status, reason }
    );
    return response.data;
  },

  pauseSubscription: async (id: string, reason?: string): Promise<Subscription> => {
    const response = await apiClient.post<Subscription>(
      `/api/v1/subscriptions/${id}/pause`,
      { reason }
    );
    return response.data;
  },

  resumeSubscription: async (id: string): Promise<Subscription> => {
    const response = await apiClient.post<Subscription>(
      `/api/v1/subscriptions/${id}/resume`
    );
    return response.data;
  },

  renewSubscription: async (id: string): Promise<Subscription> => {
    const response = await apiClient.post<Subscription>(
      `/api/v1/subscriptions/${id}/renew`
    );
    return response.data;
  },

  closeSubscription: async (id: string, reason?: string): Promise<Subscription> => {
    const response = await apiClient.post<Subscription>(
      `/api/v1/subscriptions/${id}/close`,
      { reason }
    );
    return response.data;
  },
};
