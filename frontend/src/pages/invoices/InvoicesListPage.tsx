import React, { useState } from "react";
import { Link } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { invoicesApi } from "@/api/invoices";
import { InvoicePaymentStatus, InvoiceStatus } from "@/types";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { formatDate, formatCurrency } from "@/lib/utils";
import {
  FileText,
  Search,
  ArrowRight,
  Loader2,
  Calendar,
} from "lucide-react";

export const InvoicesListPage: React.FC = () => {
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState<InvoiceStatus | "ALL">("ALL");
  const [paymentStatusFilter, setPaymentStatusFilter] = useState<
    InvoicePaymentStatus | "ALL"
  >("ALL");
  const [page, setPage] = useState(1);

  const { data, isLoading, error } = useQuery({
    queryKey: ["invoices", { page, search, statusFilter, paymentStatusFilter }],
    queryFn: () =>
      invoicesApi.listInvoices({
        page,
        limit: 15,
        search: search.trim() || undefined,
        status: statusFilter === "ALL" ? undefined : statusFilter,
        payment_status:
          paymentStatusFilter === "ALL" ? undefined : paymentStatusFilter,
      }),
  });

  const getLifecycleBadge = (status: InvoiceStatus) => {
    switch (status) {
      case "PAID":
        return <Badge variant="success">PAID</Badge>;
      case "CONFIRMED":
        return <Badge variant="info">CONFIRMED</Badge>;
      case "DRAFT":
        return <Badge variant="neutral">DRAFT</Badge>;
      case "CANCELLED":
        return <Badge variant="destructive">CANCELLED</Badge>;
      default:
        return <Badge variant="neutral">{status}</Badge>;
    }
  };

  const getPaymentBadge = (status: InvoicePaymentStatus) => {
    switch (status) {
      case "PAID":
        return <Badge variant="success">PAID</Badge>;
      case "PARTIALLY_PAID":
        return <Badge variant="warning">PARTIAL</Badge>;
      case "UNPAID":
        return <Badge variant="destructive">UNPAID</Badge>;
      default:
        return <Badge variant="neutral">{status}</Badge>;
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold tracking-tight text-slate-900">
          Invoices & Billing Ledger
        </h1>
        <p className="text-sm text-slate-500 mt-1">
          Monitor generated invoices, due dates, outstanding balances, and payment settlements.
        </p>
      </div>

      {/* Filter and Search Bar */}
      <Card>
        <CardContent className="p-4 flex flex-col md:flex-row gap-3">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-2.5 h-4 w-4 text-slate-400" />
            <Input
              placeholder="Search by invoice number..."
              value={search}
              onChange={(e) => {
                setSearch(e.target.value);
                setPage(1);
              }}
              className="pl-9"
            />
          </div>

          <div className="flex items-center gap-2">
            <select
              value={statusFilter}
              onChange={(e) => {
                setStatusFilter(e.target.value as any);
                setPage(1);
              }}
              className="h-9 px-3 rounded-md border border-slate-200 bg-white text-xs font-medium text-slate-700"
            >
              <option value="ALL">All Lifecycles</option>
              <option value="CONFIRMED">CONFIRMED</option>
              <option value="PAID">PAID</option>
              <option value="DRAFT">DRAFT</option>
              <option value="CANCELLED">CANCELLED</option>
            </select>

            <select
              value={paymentStatusFilter}
              onChange={(e) => {
                setPaymentStatusFilter(e.target.value as any);
                setPage(1);
              }}
              className="h-9 px-3 rounded-md border border-slate-200 bg-white text-xs font-medium text-slate-700"
            >
              <option value="ALL">All Payment States</option>
              <option value="UNPAID">UNPAID Only</option>
              <option value="PARTIALLY_PAID">PARTIALLY PAID</option>
              <option value="PAID">FULLY PAID</option>
            </select>
          </div>
        </CardContent>
      </Card>

      {/* Invoices Table */}
      <Card>
        <div className="overflow-x-auto max-h-[700px] overflow-y-auto">
          <table className="w-full text-left text-sm text-slate-600">
            <thead className="sticky top-0 bg-slate-50/95 backdrop-blur-xs z-10 border-b border-slate-200 text-xs uppercase font-semibold text-slate-500 tracking-wider">
              <tr>
                <th className="py-3 px-4">Invoice #</th>
                <th className="py-3 px-4">Customer</th>
                <th className="py-3 px-4">Issue Date</th>
                <th className="py-3 px-4">Due Date</th>
                <th className="py-3 px-4">Lifecycle</th>
                <th className="py-3 px-4">Payment</th>
                <th className="py-3 px-4">Total Amount</th>
                <th className="py-3 px-4">Balance Due</th>
                <th className="py-3 px-4 text-right">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {isLoading ? (
                <tr>
                  <td colSpan={9} className="py-12 text-center text-slate-400">
                    <Loader2 className="w-6 h-6 animate-spin mx-auto mb-2 text-blue-600" />
                    Loading invoices...
                  </td>
                </tr>
              ) : error ? (
                <tr>
                  <td colSpan={9} className="py-8 text-center text-red-500">
                    Failed to load billing ledger.
                  </td>
                </tr>
              ) : data?.items.length === 0 ? (
                <tr>
                  <td colSpan={9} className="py-12 text-center">
                    <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-slate-100 text-slate-400 mb-3">
                      <FileText className="w-6 h-6" />
                    </div>
                    <p className="text-sm font-semibold text-slate-700">No invoices found</p>
                    <p className="text-xs text-slate-400 mt-1">
                      {search ? "No matching invoices found" : "Invoices generated from subscriptions will appear here."}
                    </p>
                  </td>
                </tr>
              ) : (
                data?.items.map((inv) => (
                  <tr key={inv.id} className="hover:bg-slate-50/80 transition-colors">
                    <td className="py-3 px-4 font-mono font-medium text-slate-900">
                      {inv.invoice_number}
                    </td>
                    <td className="py-3 px-4">
                      {inv.customer ? (
                        <Link
                          to={`/customers/${inv.customer.id}`}
                          className="font-semibold text-slate-900 hover:text-blue-600 transition-colors block"
                        >
                          {inv.customer.name}
                        </Link>
                      ) : (
                        <span className="text-slate-400 italic">Unknown</span>
                      )}
                      <span className="text-xs text-slate-400 font-mono">
                        {inv.customer?.customer_number}
                      </span>
                    </td>
                    <td className="py-3 px-4 text-xs text-slate-500">
                      {formatDate(inv.issue_date)}
                    </td>
                    <td className="py-3 px-4 text-xs text-slate-500">
                      <div className="flex items-center gap-1">
                        <Calendar className="w-3 h-3 text-slate-400" />
                        <span>{formatDate(inv.due_date)}</span>
                      </div>
                    </td>
                    <td className="py-3 px-4">{getLifecycleBadge(inv.status)}</td>
                    <td className="py-3 px-4">{getPaymentBadge(inv.payment_status)}</td>
                    <td className="py-3 px-4 font-mono font-medium text-slate-900">
                      {formatCurrency(inv.total_amount, inv.currency)}
                    </td>
                    <td className="py-3 px-4 font-mono font-bold text-slate-900">
                      <span
                        className={
                          parseFloat(inv.balance_due) > 0 ? "text-red-600" : "text-emerald-600"
                        }
                      >
                        {formatCurrency(inv.balance_due, inv.currency)}
                      </span>
                    </td>
                    <td className="py-3 px-4 text-right">
                      <Link to={`/invoices/${inv.id}`}>
                        <Button variant="ghost" size="sm" className="gap-1 text-xs">
                          Details
                          <ArrowRight className="w-3 h-3" />
                        </Button>
                      </Link>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination Bar */}
        {data && data.pages > 1 && (
          <div className="flex items-center justify-between p-4 border-t border-slate-100 text-xs text-slate-500">
            <span>
              Showing {data.items.length} of {data.total} invoices
            </span>
            <div className="flex gap-2">
              <Button
                variant="outline"
                size="sm"
                disabled={page <= 1}
                onClick={() => setPage((p) => Math.max(1, p - 1))}
              >
                Previous
              </Button>
              <Button
                variant="outline"
                size="sm"
                disabled={page >= data.pages}
                onClick={() => setPage((p) => p + 1)}
              >
                Next
              </Button>
            </div>
          </div>
        )}
      </Card>
    </div>
  );
};

