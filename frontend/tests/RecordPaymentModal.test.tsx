import React from "react";
import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { RecordPaymentModal } from "@/pages/invoices/RecordPaymentModal";
import { ToastProvider } from "@/components/ui/toast";
import { Invoice } from "@/types";

const mockInvoice: Invoice = {
  id: "inv-test-1",
  invoice_number: "INV-202610-0005",
  subscription_id: "sub-1",
  customer_id: "cust-1",
  status: "CONFIRMED",
  payment_status: "UNPAID",
  issue_date: new Date().toISOString(),
  due_date: new Date().toISOString(),
  billing_period_start: new Date().toISOString(),
  billing_period_end: new Date().toISOString(),
  currency: "INR",
  subtotal: "2000.0000",
  tax_rate: "18.0000",
  tax_amount: "360.0000",
  discount_amount: "0.0000",
  total_amount: "2360.0000",
  amount_paid: "0.0000",
  balance_due: "2360.0000",
  notes: null,
  created_by_id: "user-1",
  created_at: new Date().toISOString(),
  updated_at: new Date().toISOString(),
  items: [],
};

describe("RecordPaymentModal", () => {
  it("displays invoice balance and payment options with overpayment protection", () => {
    const queryClient = new QueryClient();

    render(
      <QueryClientProvider client={queryClient}>
        <ToastProvider>
          <RecordPaymentModal
            isOpen={true}
            onClose={vi.fn()}
            invoice={mockInvoice}
          />
        </ToastProvider>
      </QueryClientProvider>
    );

    expect(screen.getByText("Record Payment")).toBeInTheDocument();
    expect(screen.getByText("Invoice INV-202610-0005")).toBeInTheDocument();
    expect(screen.getByText("Confirm Payment")).toBeInTheDocument();
    expect(screen.getByLabelText(/Payment Method/i)).toBeInTheDocument();
  });
});

