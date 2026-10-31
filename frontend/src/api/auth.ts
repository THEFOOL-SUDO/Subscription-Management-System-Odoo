import apiClient, { setAccessToken } from "./client";
import { AuthResponse, MessageResponse, User } from "@/types";

export const authApi = {
  login: async (credentials: { email: string; password: string }): Promise<AuthResponse> => {
    const response = await apiClient.post<AuthResponse>("/api/v1/auth/login", credentials);
    setAccessToken(response.data.access_token);
    return response.data;
  },

  register: async (payload: { email: string; full_name: string; password: string }): Promise<AuthResponse> => {
    const response = await apiClient.post<AuthResponse>("/api/v1/auth/register", payload);
    setAccessToken(response.data.access_token);
    return response.data;
  },

  refresh: async (): Promise<AuthResponse> => {
    const response = await apiClient.post<AuthResponse>("/api/v1/auth/refresh");
    setAccessToken(response.data.access_token);
    return response.data;
  },

  logout: async (): Promise<MessageResponse> => {
    try {
      const response = await apiClient.post<MessageResponse>("/api/v1/auth/logout");
      return response.data;
    } finally {
      setAccessToken(null);
    }
  },

  forgotPassword: async (email: string): Promise<MessageResponse> => {
    const response = await apiClient.post<MessageResponse>("/api/v1/auth/forgot-password", { email });
    return response.data;
  },

  resetPassword: async (payload: { token: string; new_password: string }): Promise<MessageResponse> => {
    const response = await apiClient.post<MessageResponse>("/api/v1/auth/reset-password", payload);
    return response.data;
  },

  getMe: async (): Promise<User> => {
    const response = await apiClient.get<User>("/api/v1/auth/me");
    return response.data;
  },

  updateMe: async (payload: { full_name?: string }): Promise<User> => {
    const response = await apiClient.patch<User>("/api/v1/auth/me", payload);
    return response.data;
  },

  changePassword: async (payload: { current_password: string; new_password: string }): Promise<MessageResponse> => {
    const response = await apiClient.post<MessageResponse>("/api/v1/auth/change-password", payload);
    return response.data;
  },
};
