import React from "react";
import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { BrowserRouter } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { SubscriptionsListPage } from "@/pages/subscriptions/SubscriptionsListPage";
import { ToastProvider } from "@/components/ui/toast";

vi.mock("@/hooks/useAuth", () => ({
  useAuth: () => ({
    user: {
      id: "operator-id",
      email: "admin@brightloop.com",
      full_name: "Admin User",
      role: "ADMIN",
    },
    isAuthenticated: true,
  }),
}));

vi.mock("@/api/subscriptions", () => ({
  subscriptionsApi: {
    listSubscriptions: vi.fn().mockResolvedValue({
      items: [
        {
          id: "sub-1",
          subscription_number: "SUB-202610-0001",
          customer_id: "cust-1",
          plan_id: "plan-1",
          status: "ACTIVE",
          start_date: new Date().toISOString(),
          expiry_date: new Date().toISOString(),
          billing_interval: "MONTHLY",
          interval_count: 1,
          currency: "INR",
          payment_terms: "NET_30",
          subtotal: "5000.0000",
          tax_rate: "18.0000",
          tax_amount: "900.0000",
          discount_amount: "0.0000",
          total_amount: "5900.0000",
          notes: "Monthly contract",
          customer: {
            id: "cust-1",
            name: "Reliance Digital",
            customer_number: "CUST-2026-0002",
          },
          plan: {
            id: "plan-1",
            name: "Cloud Suite Monthly",
            code: "CLOUD-M",
          },
          items: [],
          status_history: [],
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        },
      ],
      total: 1,
      page: 1,
      size: 15,
      pages: 1,
    }),
  },
}));

describe("SubscriptionsListPage", () => {
  it("renders subscription registry with lifecycle tabs and active contract record", async () => {
    const queryClient = new QueryClient({
      defaultOptions: { queries: { retry: false } },
    });

    render(
      <QueryClientProvider client={queryClient}>
        <ToastProvider>
          <BrowserRouter>
            <SubscriptionsListPage />
          </BrowserRouter>
        </ToastProvider>
      </QueryClientProvider>
    );

    expect(screen.getByText("Subscription Registry")).toBeInTheDocument();
    expect(screen.getByText("New Subscription")).toBeInTheDocument();

    const subNumber = await screen.findByText("SUB-202610-0001");
    expect(subNumber).toBeInTheDocument();
    expect(screen.getByText("Reliance Digital")).toBeInTheDocument();
    expect(screen.getByText("Cloud Suite Monthly")).toBeInTheDocument();
  });
});

