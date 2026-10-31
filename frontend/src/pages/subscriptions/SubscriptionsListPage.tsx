import React, { useState } from "react";
import { Link } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { subscriptionsApi } from "@/api/subscriptions";
import { useAuth } from "@/hooks/useAuth";
import { SubscriptionStatus } from "@/types";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { SubscriptionCreateModal } from "./SubscriptionCreateModal";
import { formatDate, formatCurrency } from "@/lib/utils";
import {
  CreditCard,
  Search,
  Plus,
  ArrowRight,
  Loader2,
  Calendar,
} from "lucide-react";

export const SubscriptionsListPage: React.FC = () => {
  const { user } = useAuth();
  const isOperator = user?.role === "ADMIN" || user?.role === "STAFF";

  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState<SubscriptionStatus | "ALL">("ALL");
  const [page, setPage] = useState(1);
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);

  const { data, isLoading, error } = useQuery({
    queryKey: ["subscriptions", { page, search, statusFilter }],
    queryFn: () =>
      subscriptionsApi.listSubscriptions({
        page,
        limit: 15,
        search: search.trim() || undefined,
        status: statusFilter === "ALL" ? undefined : statusFilter,
      }),
  });

  const getStatusBadgeVariant = (status: SubscriptionStatus) => {
    switch (status) {
      case "ACTIVE":
        return "success";
      case "CONFIRMED":
        return "info";
      case "PAUSED":
        return "warning";
      case "QUOTATION":
        return "warning";
      case "DRAFT":
        return "neutral";
      case "CLOSED":
        return "destructive";
      default:
        return "neutral";
    }
  };

  const statusTabs: Array<SubscriptionStatus | "ALL"> = [
    "ALL",
    "ACTIVE",
    "PAUSED",
    "CONFIRMED",
    "QUOTATION",
    "DRAFT",
    "CLOSED",
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">
            Subscription Registry
          </h1>
          <p className="text-sm text-slate-500 mt-1">
            Track customer recurring contracts, terms, billing intervals, and lifecycle states.
          </p>
        </div>
        {isOperator && (
          <Button onClick={() => setIsCreateModalOpen(true)} className="gap-2 self-start md:self-auto">
            <Plus className="w-4 h-4" />
            New Subscription
          </Button>
        )}
      </div>

      {/* Status Filter Tabs & Search */}
      <Card>
        <CardContent className="p-4 space-y-3">
          <div className="flex items-center gap-1.5 overflow-x-auto pb-1 text-xs font-semibold">
            {statusTabs.map((tab) => (
              <button
                key={tab}
                onClick={() => {
                  setStatusFilter(tab);
                  setPage(1);
                }}
                className={`px-3 py-1.5 rounded-lg transition-colors whitespace-nowrap ${
                  statusFilter === tab
                    ? "bg-slate-900 text-white shadow-xs"
                    : "text-slate-600 hover:bg-slate-100"
                }`}
              >
                {tab === "ALL" ? "All Subscriptions" : tab}
              </button>
            ))}
          </div>

          <div className="relative">
            <Search className="absolute left-3 top-2.5 h-4 w-4 text-slate-400" />
            <Input
              placeholder="Search by subscription number or notes..."
              value={search}
              onChange={(e) => {
                setSearch(e.target.value);
                setPage(1);
              }}
              className="pl-9"
            />
          </div>
        </CardContent>
      </Card>

      {/* Subscriptions Table */}
      <Card>
        <div className="overflow-x-auto max-h-[700px] overflow-y-auto">
          <table className="w-full text-left text-sm text-slate-600">
            <thead className="sticky top-0 bg-slate-50/95 backdrop-blur-xs z-10 border-b border-slate-200 text-xs uppercase font-semibold text-slate-500 tracking-wider">
              <tr>
                <th className="py-3 px-4">Subscription #</th>
                <th className="py-3 px-4">Customer</th>
                <th className="py-3 px-4">Plan</th>
                <th className="py-3 px-4">Cadence</th>
                <th className="py-3 px-4">Status</th>
                <th className="py-3 px-4">Amount</th>
                <th className="py-3 px-4">Period Dates</th>
                <th className="py-3 px-4 text-right">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {isLoading ? (
                <tr>
                  <td colSpan={8} className="py-12 text-center text-slate-400">
                    <Loader2 className="w-6 h-6 animate-spin mx-auto mb-2 text-blue-600" />
                    Loading subscriptions...
                  </td>
                </tr>
              ) : error ? (
                <tr>
                  <td colSpan={8} className="py-8 text-center text-red-500">
                    Failed to load subscription registry.
                  </td>
                </tr>
              ) : data?.items.length === 0 ? (
                <tr>
                  <td colSpan={8} className="py-12 text-center">
                    <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-slate-100 text-slate-400 mb-3">
                      <CreditCard className="w-6 h-6" />
                    </div>
                    <p className="text-sm font-semibold text-slate-700">No subscriptions found</p>
                    <p className="text-xs text-slate-400 mt-1">
                      {search ? "No matching subscription records" : "Initiate your first customer subscription above."}
                    </p>
                  </td>
                </tr>
              ) : (
                data?.items.map((sub) => (
                  <tr key={sub.id} className="hover:bg-slate-50/80 transition-colors">
                    <td className="py-3 px-4 font-mono font-medium text-slate-900">
                      {sub.subscription_number}
                    </td>
                    <td className="py-3 px-4">
                      {sub.customer ? (
                        <Link
                          to={`/customers/${sub.customer.id}`}
                          className="font-semibold text-slate-900 hover:text-blue-600 transition-colors block"
                        >
                          {sub.customer.name}
                        </Link>
                      ) : (
                        <span className="text-slate-400 italic">Unknown</span>
                      )}
                      <span className="text-xs text-slate-400 font-mono">
                        {sub.customer?.customer_number}
                      </span>
                    </td>
                    <td className="py-3 px-4 font-semibold text-slate-800">
                      {sub.plan?.name || "Standard Plan"}
                    </td>
                    <td className="py-3 px-4 text-xs text-slate-500">
                      {sub.billing_interval} ({sub.interval_count}x)
                    </td>
                    <td className="py-3 px-4">
                      <Badge variant={getStatusBadgeVariant(sub.status)}>
                        {sub.status}
                      </Badge>
                    </td>
                    <td className="py-3 px-4 font-mono font-semibold text-slate-900">
                      {formatCurrency(sub.total_amount, sub.currency)}
                    </td>
                    <td className="py-3 px-4 text-xs text-slate-500">
                      <div className="flex items-center gap-1">
                        <Calendar className="w-3 h-3 text-slate-400" />
                        <span>{formatDate(sub.start_date)}</span>
                      </div>
                      {sub.expiry_date && (
                        <span className="text-[11px] text-slate-400">
                          to {formatDate(sub.expiry_date)}
                        </span>
                      )}
                    </td>
                    <td className="py-3 px-4 text-right">
                      <Link to={`/subscriptions/${sub.id}`}>
                        <Button variant="ghost" size="sm" className="gap-1 text-xs">
                          Manage
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
              Showing {data.items.length} of {data.total} subscriptions
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

      <SubscriptionCreateModal
        isOpen={isCreateModalOpen}
        onClose={() => setIsCreateModalOpen(false)}
      />
    </div>
  );
};

