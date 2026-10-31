import React from "react";
import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { BrowserRouter } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { PlansListPage } from "@/pages/plans/PlansListPage";
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

vi.mock("@/api/plans", () => ({
  plansApi: {
    listPlans: vi.fn().mockResolvedValue({
      items: [
        {
          id: "plan-1",
          code: "PRO-ANNUAL",
          name: "Business Pro Annual",
          billing_interval: "YEARLY",
          interval_count: 1,
          trial_period_days: 14,
          status: "ACTIVE",
          currency: "INR",
          min_quantity: 1,
          max_quantity: null,
          is_auto_close: false,
          bundled_products_count: 2,
          calculated_total_price: "24000.0000",
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

describe("PlansListPage", () => {
  it("renders subscription plans title, plan items, and create button for admin", async () => {
    const queryClient = new QueryClient({
      defaultOptions: { queries: { retry: false } },
    });

    render(
      <QueryClientProvider client={queryClient}>
        <ToastProvider>
          <BrowserRouter>
            <PlansListPage />
          </BrowserRouter>
        </ToastProvider>
      </QueryClientProvider>
    );

    expect(screen.getByText("Subscription Plans")).toBeInTheDocument();
    expect(
      screen.getByPlaceholderText(/Search plans by name, code or description/i)
    ).toBeInTheDocument();
    expect(
      screen.getByRole("button", { name: /Create Subscription Plan/i })
    ).toBeInTheDocument();
    expect(await screen.findByText("Business Pro Annual")).toBeInTheDocument();
    expect(screen.getByText("PRO-ANNUAL")).toBeInTheDocument();
  });
});

