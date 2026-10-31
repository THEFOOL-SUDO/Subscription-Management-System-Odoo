import apiClient from "./client";
import {
  QuotationConvertToSubscriptionRequest,
  QuotationTemplate,
  QuotationTemplateCreateRequest,
  QuotationTemplateListResponse,
} from "@/types/quotation";
import { Subscription } from "@/types";

export const quotationsApi = {
  listQuotations: async (activeOnly: boolean = false): Promise<QuotationTemplateListResponse> => {
    const response = await apiClient.get<QuotationTemplateListResponse>("/api/v1/quotation-templates", {
      params: { active_only: activeOnly },
    });
    return response.data;
  },

  getQuotation: async (id: string): Promise<QuotationTemplate> => {
    const response = await apiClient.get<QuotationTemplate>(`/api/v1/quotation-templates/${id}`);
    return response.data;
  },

  createQuotation: async (data: QuotationTemplateCreateRequest): Promise<QuotationTemplate> => {
    const response = await apiClient.post<QuotationTemplate>("/api/v1/quotation-templates", data);
    return response.data;
  },

  updateQuotation: async (id: string, data: Partial<QuotationTemplateCreateRequest>): Promise<QuotationTemplate> => {
    const response = await apiClient.patch<QuotationTemplate>(`/api/v1/quotation-templates/${id}`, data);
    return response.data;
  },

  deleteQuotation: async (id: string): Promise<void> => {
    await apiClient.delete(`/api/v1/quotation-templates/${id}`);
  },

  convertToSubscription: async (
    id: string,
    data: QuotationConvertToSubscriptionRequest
  ): Promise<Subscription> => {
    const response = await apiClient.post<Subscription>(
      `/api/v1/quotation-templates/${id}/convert-to-subscription`,
      data
    );
    return response.data;
  },
};
