import apiClient from "./client";
import {
  BillingInterval,
  MessageResponse,
  PlanProduct,
  PlanProductCreateInput,
  PlanProductUpdateInput,
  PlanStatus,
  Product,
  SubscriptionPlan,
  SubscriptionPlanCreateInput,
  SubscriptionPlanDetail,
  SubscriptionPlanListResponse,
  SubscriptionPlanUpdateInput,
} from "@/types";

export const plansApi = {
  listPlans: async (params?: {
    page?: number;
    limit?: number;
    search?: string;
    status?: PlanStatus;
    billing_interval?: BillingInterval;
  }): Promise<SubscriptionPlanListResponse> => {
    const response = await apiClient.get<SubscriptionPlanListResponse>(
      "/api/v1/plans",
      { params }
    );
    return response.data;
  },

  getPlan: async (id: string): Promise<SubscriptionPlanDetail> => {
    const response = await apiClient.get<SubscriptionPlanDetail>(
      `/api/v1/plans/${id}`
    );
    return response.data;
  },

  createPlan: async (
    data: SubscriptionPlanCreateInput
  ): Promise<SubscriptionPlanDetail> => {
    const response = await apiClient.post<SubscriptionPlanDetail>(
      "/api/v1/plans",
      data
    );
    return response.data;
  },

  updatePlan: async (
    id: string,
    data: SubscriptionPlanUpdateInput
  ): Promise<SubscriptionPlanDetail> => {
    const response = await apiClient.put<SubscriptionPlanDetail>(
      `/api/v1/plans/${id}`,
      data
    );
    return response.data;
  },

  updatePlanStatus: async (
    id: string,
    status: PlanStatus
  ): Promise<SubscriptionPlanDetail> => {
    const response = await apiClient.patch<SubscriptionPlanDetail>(
      `/api/v1/plans/${id}/status`,
      { status }
    );
    return response.data;
  },

  addBundledProduct: async (
    planId: string,
    data: PlanProductCreateInput
  ): Promise<PlanProduct> => {
    const response = await apiClient.post<PlanProduct>(
      `/api/v1/plans/${planId}/products`,
      data
    );
    return response.data;
  },

  updateBundledProduct: async (
    planId: string,
    lineItemId: string,
    data: PlanProductUpdateInput
  ): Promise<PlanProduct> => {
    const response = await apiClient.put<PlanProduct>(
      `/api/v1/plans/${planId}/products/${lineItemId}`,
      data
    );
    return response.data;
  },

  removeBundledProduct: async (
    planId: string,
    lineItemId: string
  ): Promise<MessageResponse> => {
    const response = await apiClient.delete<MessageResponse>(
      `/api/v1/plans/${planId}/products/${lineItemId}`
    );
    return response.data;
  },

  setupCatalogue: async (): Promise<any> => {
    const response = await apiClient.post<any>("/api/v1/plans/catalogue/setup");
    return response.data;
  },

  getCatalogueItems: async (): Promise<{ plans: SubscriptionPlan[]; addons: Product[] }> => {
    const response = await apiClient.get<{ plans: SubscriptionPlan[]; addons: Product[] }>(
      "/api/v1/plans/catalogue/items"
    );
    return response.data;
  },
};

