import apiClient from "./client";
import { DashboardMetrics } from "@/types";

export const dashboardApi = {
  getMetrics: async (): Promise<DashboardMetrics> => {
    const response = await apiClient.get<DashboardMetrics>("/api/v1/dashboard/metrics");
    return response.data;
  },
};

