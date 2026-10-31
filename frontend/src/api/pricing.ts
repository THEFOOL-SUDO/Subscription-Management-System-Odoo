import apiClient from "./client";
import { PriceCalculationRequest, PriceCalculationResponse } from "@/types";

export const pricingApi = {
  calculatePrices: async (
    request: PriceCalculationRequest
  ): Promise<PriceCalculationResponse> => {
    const response = await apiClient.post<PriceCalculationResponse>(
      "/api/v1/pricing/calculate",
      request
    );
    return response.data;
  },
};

