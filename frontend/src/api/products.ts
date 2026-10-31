import apiClient from "./client";
import {
  ProductCreateInput,
  ProductDetail,
  ProductListResponse,
  ProductType,
  ProductUpdateInput,
  ProductVariant,
  VariantCreateInput,
  VariantUpdateInput,
} from "@/types";

export const productsApi = {
  listProducts: async (params?: {
    page?: number;
    limit?: number;
    search?: string;
    product_type?: ProductType;
    is_active?: boolean;
    is_archived?: boolean;
  }): Promise<ProductListResponse> => {
    const response = await apiClient.get<ProductListResponse>("/api/v1/products", {
      params,
    });
    return response.data;
  },

  getProduct: async (id: string): Promise<ProductDetail> => {
    const response = await apiClient.get<ProductDetail>(`/api/v1/products/${id}`);
    return response.data;
  },

  createProduct: async (data: ProductCreateInput): Promise<ProductDetail> => {
    const response = await apiClient.post<ProductDetail>("/api/v1/products", data);
    return response.data;
  },

  updateProduct: async (
    id: string,
    data: ProductUpdateInput
  ): Promise<ProductDetail> => {
    const response = await apiClient.put<ProductDetail>(
      `/api/v1/products/${id}`,
      data
    );
    return response.data;
  },

  archiveProduct: async (id: string): Promise<ProductDetail> => {
    const response = await apiClient.post<ProductDetail>(
      `/api/v1/products/${id}/archive`
    );
    return response.data;
  },

  createVariant: async (
    productId: string,
    data: VariantCreateInput
  ): Promise<ProductVariant> => {
    const response = await apiClient.post<ProductVariant>(
      `/api/v1/products/${productId}/variants`,
      data
    );
    return response.data;
  },

  updateVariant: async (
    productId: string,
    variantId: string,
    data: VariantUpdateInput
  ): Promise<ProductVariant> => {
    const response = await apiClient.put<ProductVariant>(
      `/api/v1/products/${productId}/variants/${variantId}`,
      data
    );
    return response.data;
  },

  archiveVariant: async (
    productId: string,
    variantId: string
  ): Promise<ProductVariant> => {
    const response = await apiClient.post<ProductVariant>(
      `/api/v1/products/${productId}/variants/${variantId}/archive`
    );
    return response.data;
  },
};
