import apiClient from "./client";
import { AuditLog, PaginatedResponse } from "@/types";

export interface ListAuditLogsParams {
  page?: number;
  size?: number;
  action?: string;
  user_id?: string;
}

export const auditApi = {
  listAuditLogs: async (params?: ListAuditLogsParams): Promise<PaginatedResponse<AuditLog>> => {
    const response = await apiClient.get<PaginatedResponse<AuditLog>>("/api/v1/audit-logs", { params });
    return response.data;
  },
};
