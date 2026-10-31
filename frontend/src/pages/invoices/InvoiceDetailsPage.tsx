import React, { useState } from "react";
import { useParams, Link } from "react-router-dom";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { invoicesApi } from "@/api/invoices";
import { paymentsApi } from "@/api/payments";
import { useAuth } from "@/hooks/useAuth";
import { useToast } from "@/components/ui/toast";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { RecordPaymentModal } from "./RecordPaymentModal";
import { formatDate, formatCurrency } from "@/lib/utils";
import {
  CreditCard,
  IndianRupee,
  Loader2,
  ArrowLeft,
  Printer,
  XCircle,
  Sparkles,
} from "lucide-react";

export const InvoiceDetailsPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const { user } = useAuth();
  const { success, error } = useToast();
  const queryClient = useQueryClient();
  const isOperator = user?.role === "ADMIN" || user?.role === "STAFF";

  const [isPaymentModalOpen, setIsPaymentModalOpen] = useState(false);

  const { data: invoice, isLoading } = useQuery({
    queryKey: ["invoice", id],
    queryFn: () => {
      if (!id) throw new Error("Missing ID");
      return invoicesApi.getInvoice(id);
    },
    enabled: !!id,
  });

  const { data: paymentsData, isLoading: isLoadingPayments } = useQuery({
    queryKey: ["invoice-payments", id],
    queryFn: () => paymentsApi.listPayments({ invoice_id: id }),
    enabled: !!id,
  });

  const cancelInvoiceMutation = useMutation({
    mutationFn: () => {
      if (!id) throw new Error("Missing ID");
      return invoicesApi.transitionStatus(id, "CANCELLED", "Cancelled by billing operator");
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["invoice", id] });
      queryClient.invalidateQueries({ queryKey: ["invoices"] });
      queryClient.invalidateQueries({ queryKey: ["dashboard-metrics"] });
      success("Invoice has been marked as CANCELLED.", "Invoice Cancelled");
    },
    onError: (err: any) => {
      error(err.response?.data?.detail || "Failed to cancel invoice.", "Action Failed");
    },
  });

  if (isLoading) {
    return (
      <div className="py-24 text-center">
        <Loader2 className="w-8 h-8 animate-spin mx-auto text-blue-600 mb-3" />
        <p className="text-sm text-slate-500">Loading invoice statement...</p>
      </div>
    );
  }

  if (!invoice) {
    return (
      <div className="py-12 text-center space-y-4">
        <h2 className="text-lg font-bold text-slate-800">Invoice not found</h2>
        <Link to="/invoices">
          <Button variant="outline" className="gap-2">
            <ArrowLeft className="w-4 h-4" />
            Back to Invoices
          </Button>
        </Link>
      </div>
    );
  }

  const balanceDueNum = parseFloat(invoice.balance_due) || 0;
  const isPaidInFull = invoice.status === "PAID" || balanceDueNum <= 0;

  return (
    <div className="space-y-6 max-w-4xl mx-auto">
      {/* Top Action Bar */}
      <div className="flex items-center justify-between no-print">
        <Link to="/invoices">
          <Button variant="ghost" size="sm" className="gap-1.5 text-slate-600">
            <ArrowLeft className="w-4 h-4" />
            Back to Invoices
          </Button>
        </Link>
        <div className="flex items-center gap-2">
          <Button
            variant="outline"
            size="sm"
            onClick={() => window.print()}
            className="gap-1.5"
          >
            <Printer className="w-4 h-4" />
            Print / PDF
          </Button>

          {isOperator && !isPaidInFull && invoice.status !== "CANCELLED" && (
            <Button
              size="sm"
              onClick={() => setIsPaymentModalOpen(true)}
              className="gap-1.5 bg-emerald-600 hover:bg-emerald-700"
            >
              <IndianRupee className="w-4 h-4" />
              Record Payment
            </Button>
          )}

          {isOperator && parseFloat(invoice.amount_paid) === 0 && invoice.status !== "CANCELLED" && (
            <Button
              variant="outline"
              size="sm"
              onClick={() => cancelInvoiceMutation.mutate()}
              disabled={cancelInvoiceMutation.isPending}
              className="gap-1.5 text-red-600 hover:text-red-700 hover:bg-red-50"
            >
              <XCircle className="w-4 h-4" />
              Cancel Invoice
            </Button>
          )}
        </div>
      </div>

      {/* Printable Enterprise Invoice Document */}
      <Card className="p-8 border-slate-200/90 shadow-xs bg-white text-slate-800">
        {/* Invoice Header */}
        <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center pb-8 border-b border-slate-200 gap-4">
          <div className="flex items-center gap-3">
            <div className="h-10 w-10 rounded-xl bg-slate-900 flex items-center justify-center text-white shadow-xs">
              <Sparkles className="w-5 h-5 text-blue-400" />
            </div>
            <div>
              <span className="font-bold text-lg text-slate-900 leading-none">
                Brightloop Software
              </span>
              <span className="block text-xs text-slate-400 mt-0.5">
                Subscription & Billing Platform
              </span>
            </div>
          </div>

          <div className="sm:text-right">
            <h2 className="text-xl font-mono font-bold text-slate-900">
              {invoice.invoice_number}
            </h2>
            <div className="flex items-center sm:justify-end gap-1.5 mt-1.5">
              <Badge variant={invoice.status === "PAID" ? "success" : invoice.status === "CONFIRMED" ? "info" : "destructive"}>
                {invoice.status}
              </Badge>
              <Badge variant={invoice.payment_status === "PAID" ? "success" : invoice.payment_status === "PARTIALLY_PAID" ? "warning" : "destructive"}>
                {invoice.payment_status}
              </Badge>
            </div>
          </div>
        </div>

        {/* Bill To & Invoice Info */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8 py-6 border-b border-slate-100 text-xs">
          <div>
            <h4 className="font-semibold uppercase tracking-wider text-slate-400 mb-2">
              Billed To
            </h4>
            <div className="space-y-1">
              <span className="text-sm font-bold text-slate-900 block">
                {invoice.customer?.name}
              </span>
              {invoice.customer?.company_name && (
                <span className="text-slate-600 block">{invoice.customer.company_name}</span>
              )}
              <span className="font-mono text-slate-600 block">{invoice.customer?.email}</span>
              {invoice.customer?.phone && (
                <span className="text-slate-500 block">{invoice.customer.phone}</span>
              )}
              <div className="text-slate-600 pt-1">
                {invoice.customer?.billing_address_line1 && (
                  <span>
                    {invoice.customer.billing_address_line1},{" "}
                    {invoice.customer.billing_city && `${invoice.customer.billing_city}, `}
                    {invoice.customer.billing_state && `${invoice.customer.billing_state} `}
                    {invoice.customer.billing_postal_code}
                  </span>
                )}
              </div>
            </div>
          </div>

          <div className="space-y-2 md:text-right">
            <h4 className="font-semibold uppercase tracking-wider text-slate-400 mb-2">
              Invoice Statement
            </h4>
            <div className="flex md:justify-end justify-between gap-4">
              <span className="text-slate-500">Invoice Date:</span>
              <span className="font-semibold text-slate-900">{formatDate(invoice.issue_date)}</span>
            </div>
            <div className="flex md:justify-end justify-between gap-4">
              <span className="text-slate-500">Payment Due:</span>
              <span className="font-semibold text-slate-900">{formatDate(invoice.due_date)}</span>
            </div>
            <div className="flex md:justify-end justify-between gap-4">
              <span className="text-slate-500">Billing Period:</span>
              <span className="font-semibold text-slate-900">
                {formatDate(invoice.billing_period_start)} - {formatDate(invoice.billing_period_end)}
              </span>
            </div>
            <div className="flex md:justify-end justify-between gap-4">
              <span className="text-slate-500">Contract Subscription:</span>
              <Link
                to={`/subscriptions/${invoice.subscription_id}`}
                className="font-mono font-medium text-blue-600 hover:underline"
              >
                View Contract
              </Link>
            </div>
          </div>
        </div>

        {/* Itemized Table */}
        <div className="py-6">
          <table className="w-full text-left text-xs">
            <thead className="border-b-2 border-slate-200 text-slate-400 uppercase tracking-wider font-semibold">
              <tr>
                <th className="py-2.5">Item Description</th>
                <th className="py-2.5 text-center">Qty</th>
                <th className="py-2.5 text-right">Unit Price</th>
                <th className="py-2.5 text-right">Subtotal</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {invoice.items.map((item) => (
                <tr key={item.id}>
                  <td className="py-3 font-medium text-slate-800">{item.description}</td>
                  <td className="py-3 text-center font-mono">{item.quantity}</td>
                  <td className="py-3 text-right font-mono text-slate-600">
                    {formatCurrency(item.unit_price, invoice.currency)}
                  </td>
                  <td className="py-3 text-right font-mono font-semibold text-slate-900">
                    {formatCurrency(item.subtotal, invoice.currency)}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Totals Calculation Card */}
        <div className="pt-4 border-t border-slate-200 flex flex-col md:flex-row justify-between gap-6 text-xs">
          <div className="space-y-1 text-slate-500 max-w-sm">
            <span className="font-semibold text-slate-700 block">Payment Terms & Instructions</span>
            <p className="text-[11px] leading-relaxed">
              Please remit payment in {invoice.currency} by the specified due date using Bank Transfer (NEFT/RTGS) or UPI reference.
            </p>
            {invoice.notes && (
              <p className="mt-2 text-[11px] font-mono bg-slate-50 p-2 rounded border border-slate-100 text-slate-700">
                {invoice.notes}
              </p>
            )}
          </div>

          <div className="space-y-2 min-w-[240px]">
            <div className="flex justify-between py-1 border-b border-slate-100">
              <span className="text-slate-500">Subtotal:</span>
              <span className="font-mono font-medium">{formatCurrency(invoice.subtotal, invoice.currency)}</span>
            </div>
            <div className="flex justify-between py-1 border-b border-slate-100">
              <span className="text-slate-500">Discount:</span>
              <span className="font-mono text-emerald-600 font-medium">
                -{formatCurrency(invoice.discount_amount, invoice.currency)}
              </span>
            </div>
            <div className="flex justify-between py-1 border-b border-slate-100">
              <span className="text-slate-500">GST Tax ({invoice.tax_rate}%):</span>
              <span className="font-mono font-medium">+{formatCurrency(invoice.tax_amount, invoice.currency)}</span>
            </div>
            <div className="flex justify-between py-1.5 border-b-2 border-slate-200 text-sm font-bold text-slate-900">
              <span>Total Invoice Amount:</span>
              <span className="font-mono">{formatCurrency(invoice.total_amount, invoice.currency)}</span>
            </div>
            <div className="flex justify-between py-1 text-emerald-600 font-medium">
              <span>Amount Paid:</span>
              <span className="font-mono">-{formatCurrency(invoice.amount_paid, invoice.currency)}</span>
            </div>
            <div className="flex justify-between py-2 border-t border-slate-200 text-sm font-bold">
              <span className="text-slate-900">Balance Due:</span>
              <span className={`font-mono text-base ${balanceDueNum > 0 ? "text-red-600" : "text-emerald-600"}`}>
                {formatCurrency(invoice.balance_due, invoice.currency)}
              </span>
            </div>
          </div>
        </div>
      </Card>

      {/* Recorded Payments History */}
      <Card>
        <CardHeader className="pb-3 flex flex-row items-center justify-between">
          <CardTitle className="text-base font-semibold text-slate-800">Payment Audit Trail</CardTitle>
          <CreditCard className="w-4 h-4 text-slate-400" />
        </CardHeader>
        <CardContent>
          {isLoadingPayments ? (
            <p className="text-xs text-slate-400 py-4 text-center">Loading transaction ledger...</p>
          ) : paymentsData?.items.length === 0 ? (
            <p className="text-xs text-slate-400 py-4 text-center italic">
              No payments recorded against this invoice yet.
            </p>
          ) : (
            <div className="divide-y divide-slate-100 text-xs">
              {paymentsData?.items.map((pay) => (
                <div key={pay.id} className="py-2.5 flex items-center justify-between">
                  <div className="space-y-0.5">
                    <div className="flex items-center gap-2">
                      <span className="font-mono font-bold text-slate-900">{pay.payment_number}</span>
                      <Badge variant="neutral" className="text-[10px]">
                        {pay.payment_method}
                      </Badge>
                    </div>
                    <span className="text-slate-400 font-mono text-[11px] block">
                      {formatDate(pay.payment_date)} {pay.reference_number && `• Ref: ${pay.reference_number}`}
                    </span>
                  </div>
                  <div className="text-right">
                    <span className="font-mono font-bold text-emerald-600 text-sm">
                      {formatCurrency(pay.amount, pay.currency)}
                    </span>
                    <span className="text-[10px] text-slate-400 block">Cleared</span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>

      <RecordPaymentModal
        isOpen={isPaymentModalOpen}
        onClose={() => setIsPaymentModalOpen(false)}
        invoice={invoice}
      />
    </div>
  );
};
