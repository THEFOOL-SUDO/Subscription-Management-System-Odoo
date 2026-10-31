import apiClient from "./client";
import { TaxRule, TaxRuleCreateRequest, TaxRuleListResponse } from "@/types/tax";

export const taxesApi = {
  listTaxRules: async (activeOnly: boolean = false): Promise<TaxRuleListResponse> => {
    const response = await apiClient.get<TaxRuleListResponse>("/api/v1/taxes", {
      params: { active_only: activeOnly },
    });
    return response.data;
  },

  createTaxRule: async (data: TaxRuleCreateRequest): Promise<TaxRule> => {
    const response = await apiClient.post<TaxRule>("/api/v1/taxes", data);
    return response.data;
  },

  updateTaxRule: async (id: string, data: Partial<TaxRuleCreateRequest>): Promise<TaxRule> => {
    const response = await apiClient.patch<TaxRule>(`/api/v1/taxes/${id}`, data);
    return response.data;
  },
};
