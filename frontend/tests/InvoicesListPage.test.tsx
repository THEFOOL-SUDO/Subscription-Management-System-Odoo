import React from "react";
import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { BrowserRouter } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { InvoicesListPage } from "@/pages/invoices/InvoicesListPage";
import { ToastProvider } from "@/components/ui/toast";

vi.mock("@/hooks/useAuth", () => ({
  useAuth: () => ({
    user: {
      id: "operator-id",
      email: "staff@brightloop.com",
      full_name: "Staff User",
      role: "STAFF",
    },
    isAuthenticated: true,
  }),
}));

vi.mock("@/api/invoices", () => ({
  invoicesApi: {
    listInvoices: vi.fn().mockResolvedValue({
      items: [
        {
          id: "inv-1",
          invoice_number: "INV-202610-0001",
          subscription_id: "sub-1",
          customer_id: "cust-1",
          status: "CONFIRMED",
          payment_status: "PARTIALLY_PAID",
          issue_date: new Date().toISOString(),
          due_date: new Date().toISOString(),
          billing_period_start: new Date().toISOString(),
          billing_period_end: new Date().toISOString(),
          currency: "INR",
          subtotal: "10000.0000",
          tax_rate: "18.0000",
          tax_amount: "1800.0000",
          discount_amount: "0.0000",
          total_amount: "11800.0000",
          amount_paid: "5000.0000",
          balance_due: "6800.0000",
          notes: null,
          created_by_id: "operator-id",
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
          customer: {
            id: "cust-1",
            name: "Wipro Technologies",
            customer_number: "CUST-2026-0003",
          },
          items: [],
        },
      ],
      total: 1,
      page: 1,
      size: 15,
      pages: 1,
    }),
  },
}));

describe("InvoicesListPage", () => {
  it("renders billing ledger with financial status badges and balance due", async () => {
    const queryClient = new QueryClient({
      defaultOptions: { queries: { retry: false } },
    });

    render(
      <QueryClientProvider client={queryClient}>
        <ToastProvider>
          <BrowserRouter>
            <InvoicesListPage />
          </BrowserRouter>
        </ToastProvider>
      </QueryClientProvider>
    );

    expect(screen.getByText("Invoices & Billing Ledger")).toBeInTheDocument();

    const invNumber = await screen.findByText("INV-202610-0001");
    expect(invNumber).toBeInTheDocument();
    expect(screen.getByText("Wipro Technologies")).toBeInTheDocument();
    expect(screen.getByText("PARTIAL")).toBeInTheDocument();
  });
});

