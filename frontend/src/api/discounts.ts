import apiClient from "./client";
import {
  DiscountRule,
  DiscountRuleCreateRequest,
  DiscountRuleListResponse,
  DiscountValidateResponse,
} from "@/types/discount";

export const discountsApi = {
  listDiscounts: async (activeOnly: boolean = false): Promise<DiscountRuleListResponse> => {
    const response = await apiClient.get<DiscountRuleListResponse>("/api/v1/discounts", {
      params: { active_only: activeOnly },
    });
    return response.data;
  },

  createDiscount: async (data: DiscountRuleCreateRequest): Promise<DiscountRule> => {
    const response = await apiClient.post<DiscountRule>("/api/v1/discounts", data);
    return response.data;
  },

  updateDiscount: async (id: string, data: Partial<DiscountRuleCreateRequest>): Promise<DiscountRule> => {
    const response = await apiClient.patch<DiscountRule>(`/api/v1/discounts/${id}`, data);
    return response.data;
  },

  validateDiscount: async (
    code: string,
    amount: number | string,
    quantity?: number,
    productIds?: string[]
  ): Promise<DiscountValidateResponse> => {
    const response = await apiClient.post<DiscountValidateResponse>("/api/v1/discounts/validate", {
      code,
      amount,
      quantity,
      product_ids: productIds,
    });
    return response.data;
  },
};
