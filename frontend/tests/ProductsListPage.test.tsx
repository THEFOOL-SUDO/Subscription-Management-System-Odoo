import React from "react";
import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { BrowserRouter } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ProductsListPage } from "@/pages/products/ProductsListPage";
import { ToastProvider } from "@/components/ui/toast";

vi.mock("@/hooks/useAuth", () => ({
  useAuth: () => ({
    user: {
      id: "admin-id",
      email: "admin@brightloop.com",
      full_name: "Admin User",
      role: "ADMIN",
    },
    isAuthenticated: true,
  }),
}));

vi.mock("@/api/products", () => ({
  productsApi: {
    listProducts: vi.fn().mockResolvedValue({
      items: [
        {
          id: "prod-1",
          name: "Brightloop ERP Software",
          sku: "ERP-001",
          product_type: "SOFTWARE",
          sales_price: "2000.0000",
          cost_price: "500.0000",
          currency: "INR",
          is_active: true,
          is_archived: false,
          variants_count: 2,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        },
      ],
      total: 1,
      page: 1,
      limit: 10,
      total_pages: 1,
    }),
  },
}));

describe("ProductsListPage", () => {
  it("renders catalog header, search bar, and add product action for admin", async () => {
    const queryClient = new QueryClient({
      defaultOptions: { queries: { retry: false } },
    });

    render(
      <QueryClientProvider client={queryClient}>
        <ToastProvider>
          <BrowserRouter>
            <ProductsListPage />
          </BrowserRouter>
        </ToastProvider>
      </QueryClientProvider>
    );

    expect(screen.getByText("Product Catalog")).toBeInTheDocument();
    expect(screen.getByPlaceholderText(/Search products by name/i)).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /Add New Product/i })).toBeInTheDocument();
    expect(await screen.findByText("Brightloop ERP Software")).toBeInTheDocument();
    expect(screen.getByText("ERP-001")).toBeInTheDocument();
  });
});

