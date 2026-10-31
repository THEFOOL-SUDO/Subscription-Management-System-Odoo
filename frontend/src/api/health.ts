import apiClient from "./client";
import { HealthCheckResponse } from "@/types";

export const healthApi = {
  check: async (): Promise<HealthCheckResponse> => {
    const response = await apiClient.get<HealthCheckResponse>("/api/v1/health");
    return response.data;
  },
};
