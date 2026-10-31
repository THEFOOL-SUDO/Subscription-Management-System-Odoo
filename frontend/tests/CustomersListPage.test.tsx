import React from "react";
import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { BrowserRouter } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { CustomersListPage } from "@/pages/customers/CustomersListPage";
import { ToastProvider } from "@/components/ui/toast";

vi.mock("@/hooks/useAuth", () => ({
  useAuth: () => ({
    user: {
      id: "operator-id",
      email: "staff@brightloop.com",
      full_name: "Staff Operator",
      role: "STAFF",
    },
    isAuthenticated: true,
  }),
}));

vi.mock("@/api/customers", () => ({
  customersApi: {
    listCustomers: vi.fn().mockResolvedValue({
      items: [
        {
          id: "cust-1",
          customer_number: "CUST-2026-0001",
          name: "Acme Enterprises",
          email: "billing@acme.com",
          phone: "+91 9988776655",
          company_name: "Acme Global Corp",
          billing_address_line1: "100 MG Road",
          billing_city: "Bengaluru",
          billing_state: "Karnataka",
          billing_postal_code: "560001",
          billing_country: "India",
          status: "ACTIVE",
          user_id: "user-1",
          created_by_id: "operator-id",
          updated_by_id: "operator-id",
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

describe("CustomersListPage", () => {
  it("renders customer directory header, table with loaded customer, and Add Customer trigger", async () => {
    const queryClient = new QueryClient({
      defaultOptions: { queries: { retry: false } },
    });

    render(
      <QueryClientProvider client={queryClient}>
        <ToastProvider>
          <BrowserRouter>
            <CustomersListPage />
          </BrowserRouter>
        </ToastProvider>
      </QueryClientProvider>
    );

    expect(screen.getByText("Customer Directory")).toBeInTheDocument();
    expect(screen.getByText("Add Customer")).toBeInTheDocument();

    const customerName = await screen.findByText("Acme Enterprises");
    expect(customerName).toBeInTheDocument();
    expect(screen.getByText("CUST-2026-0001")).toBeInTheDocument();
    expect(screen.getByText("Acme Global Corp")).toBeInTheDocument();
  });
});

