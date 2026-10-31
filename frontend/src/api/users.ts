import apiClient from "./client";
import { PaginatedResponse, User } from "@/types";

export interface ListUsersParams {
  page?: number;
  size?: number;
  role?: string;
  is_active?: boolean;
  search?: string;
}

export const usersApi = {
  listUsers: async (params?: ListUsersParams): Promise<PaginatedResponse<User>> => {
    const response = await apiClient.get<PaginatedResponse<User>>("/api/v1/users", { params });
    return response.data;
  },

  createStaff: async (payload: { email: string; full_name: string; password: string }): Promise<User> => {
    const response = await apiClient.post<User>("/api/v1/users/staff", payload);
    return response.data;
  },

  updateStatus: async (userId: string, is_active: boolean): Promise<User> => {
    const response = await apiClient.patch<User>(`/api/v1/users/${userId}/status`, { is_active });
    return response.data;
  },

  getUser: async (userId: string): Promise<User> => {
    const response = await apiClient.get<User>(`/api/v1/users/${userId}`);
    return response.data;
  },
};
