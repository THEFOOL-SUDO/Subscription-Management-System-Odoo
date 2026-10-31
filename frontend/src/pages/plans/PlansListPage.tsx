import React, { useState } from "react";
import { Link } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { plansApi } from "@/api/plans";
import { BillingInterval, PlanStatus } from "@/types";
import { useAuth } from "@/hooks/useAuth";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { PlanCreateModal } from "./PlanCreateModal";
import {
  Layers,
  Plus,
  Search,
  ArrowRight,
  CheckCircle2,
  AlertCircle,
  Loader2,
  Package,
} from "lucide-react";

export const PlansListPage: React.FC = () => {
  const { user } = useAuth();
  const isAdmin = user?.role === "ADMIN";

  const [page, setPage] = useState(1);
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("ALL");
  const [intervalFilter, setIntervalFilter] = useState<string>("ALL");
  const [isCreateOpen, setIsCreateOpen] = useState(false);

  const { data, isLoading, error } = useQuery({
    queryKey: ["plans", page, search, statusFilter, intervalFilter],
    queryFn: () =>
      plansApi.listPlans({
        page,
        limit: 10,
        search: search.trim() || undefined,
        status: statusFilter !== "ALL" ? (statusFilter as PlanStatus) : undefined,
        billing_interval:
          intervalFilter !== "ALL"
            ? (intervalFilter as BillingInterval)
            : undefined,
      }),
  });

  const formatPrice = (price: string, currency: string) => {
    const num = Number(price);
    const sym = currency === "INR" ? "₹" : "$";
    return `${sym}${num.toLocaleString("en-IN", {
      minimumFractionDigits: 2,
      maximumFractionDigits: 4,
    })}`;
  };

  const getIntervalLabel = (interval: BillingInterval, count: number) => {
    const unit =
      interval === "DAILY"
        ? count === 1 ? "day" : "days"
        : interval === "WEEKLY"
        ? count === 1 ? "week" : "weeks"
        : interval === "MONTHLY"
        ? count === 1 ? "month" : "months"
        : count === 1 ? "year" : "years";
    return `Every ${count > 1 ? count + " " : ""}${unit}`;
  };

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">
            Subscription Plans
          </h1>
          <p className="text-sm text-slate-500 mt-1">
            Product bundles, recurrence intervals, and availability-based auto-close rules
          </p>
        </div>
        {isAdmin && (
          <Button
            onClick={() => setIsCreateOpen(true)}
            className="bg-indigo-600 hover:bg-indigo-700 text-white gap-2 shrink-0 shadow-xs"
          >
            <Plus className="w-4 h-4" />
            Create Subscription Plan
          </Button>
        )}
      </div>

      {/* Filter and Search Bar */}
      <div className="bg-white p-4 rounded-xl border border-slate-200/80 shadow-xs flex flex-col md:flex-row gap-3 items-stretch md:items-center justify-between">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <Input
            placeholder="Search plans by name, code or description..."
            value={search}
            onChange={(e) => {
              setSearch(e.target.value);
              setPage(1);
            }}
            className="pl-9 bg-slate-50/50 border-slate-200"
          />
        </div>

        <div className="flex flex-wrap items-center gap-2.5">
          <select
            value={statusFilter}
            onChange={(e) => {
              setStatusFilter(e.target.value);
              setPage(1);
            }}
            className="h-9 px-3 rounded-lg border border-slate-200 bg-white text-xs font-medium text-slate-700"
          >
            <option value="ALL">All Statuses</option>
            <option value="DRAFT">Draft</option>
            <option value="ACTIVE">Active</option>
            <option value="INACTIVE">Inactive</option>
            <option value="ARCHIVED">Archived</option>
          </select>

          <select
            value={intervalFilter}
            onChange={(e) => {
              setIntervalFilter(e.target.value);
              setPage(1);
            }}
            className="h-9 px-3 rounded-lg border border-slate-200 bg-white text-xs font-medium text-slate-700"
          >
            <option value="ALL">All Frequencies</option>
            <option value="DAILY">Daily</option>
            <option value="WEEKLY">Weekly</option>
            <option value="MONTHLY">Monthly</option>
            <option value="YEARLY">Yearly</option>
          </select>
        </div>
      </div>

      {/* Plans List Table Card */}
      <div className="bg-white rounded-xl border border-slate-200/80 shadow-xs overflow-hidden">
        {isLoading ? (
          <div className="p-12 text-center">
            <Loader2 className="w-6 h-6 animate-spin text-indigo-600 mx-auto mb-2" />
            <p className="text-sm text-slate-500">Loading subscription plans...</p>
          </div>
        ) : error ? (
          <div className="p-8 text-center text-rose-600">
            <AlertCircle className="w-8 h-8 mx-auto mb-2" />
            <p className="text-sm font-medium">Failed to load subscription plans.</p>
          </div>
        ) : !data || data.items.length === 0 ? (
          <div className="p-12 text-center">
            <div className="h-12 w-12 rounded-xl bg-slate-100 text-slate-400 flex items-center justify-center mx-auto mb-3">
              <Layers className="w-6 h-6" />
            </div>
            <h3 className="font-semibold text-slate-900 text-base">
              No subscription plans found
            </h3>
            <p className="text-sm text-slate-500 mt-1 max-w-sm mx-auto">
              {search || statusFilter !== "ALL"
                ? "No plans match your current search criteria."
                : "No plans defined yet. Click Create Subscription Plan to start bundling products."}
            </p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm">
              <thead className="bg-slate-50/75 border-b border-slate-200/80 text-xs font-semibold text-slate-500 uppercase tracking-wider">
                <tr>
                  <th className="py-3 px-4">Plan</th>
                  <th className="py-3 px-4">Code</th>
                  <th className="py-3 px-4">Billing Cycle</th>
                  <th className="py-3 px-4">Calculated Total Price</th>
                  <th className="py-3 px-4">Bundled Items</th>
                  <th className="py-3 px-4">Status</th>
                  <th className="py-3 px-4 text-right">Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {data.items.map((plan) => (
                  <tr
                    key={plan.id}
                    className="hover:bg-slate-50/50 transition-colors"
                  >
                    <td className="py-3.5 px-4">
                      <div className="font-semibold text-slate-900">
                        {plan.name}
                      </div>
                      {plan.description && (
                        <div className="text-xs text-slate-500 truncate max-w-xs">
                          {plan.description}
                        </div>
                      )}
                    </td>
                    <td className="py-3.5 px-4 font-mono text-xs font-medium text-slate-600">
                      {plan.code}
                    </td>
                    <td className="py-3.5 px-4">
                      <span className="font-medium text-slate-800 text-xs">
                        {getIntervalLabel(
                          plan.billing_interval,
                          plan.interval_count
                        )}
                      </span>
                      {plan.trial_period_days > 0 && (
                        <span className="block text-[11px] text-indigo-600 font-medium">
                          {plan.trial_period_days} days trial
                        </span>
                      )}
                    </td>
                    <td className="py-3.5 px-4">
                      <div className="font-bold text-slate-900">
                        {formatPrice(
                          plan.calculated_total_price,
                          plan.currency
                        )}
                      </div>
                      <span className="text-[11px] text-slate-400">
                        per {plan.billing_interval.toLowerCase()}
                      </span>
                    </td>
                    <td className="py-3.5 px-4">
                      <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-700">
                        <Package className="w-3 h-3 text-slate-500" />
                        {plan.bundled_products_count} {plan.bundled_products_count === 1 ? "product" : "products"}
                      </span>
                    </td>
                    <td className="py-3.5 px-4">
                      {plan.status === "ACTIVE" ? (
                        <span className="inline-flex items-center gap-1 text-xs font-medium text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200">
                          <CheckCircle2 className="w-3 h-3" />
                          Active
                        </span>
                      ) : plan.status === "DRAFT" ? (
                        <span className="inline-flex items-center gap-1 text-xs font-medium text-slate-600 bg-slate-100 px-2 py-0.5 rounded-full">
                          Draft
                        </span>
                      ) : plan.status === "INACTIVE" ? (
                        <span className="inline-flex items-center gap-1 text-xs font-medium text-amber-700 bg-amber-50 px-2 py-0.5 rounded-full border border-amber-200">
                          Inactive
                        </span>
                      ) : (
                        <span className="inline-flex items-center gap-1 text-xs font-medium text-slate-500 bg-slate-100 px-2 py-0.5 rounded-full">
                          Archived
                        </span>
                      )}
                      {plan.is_auto_close && (
                        <span className="block text-[10px] text-amber-600 font-semibold uppercase mt-0.5">
                          Auto-Close On
                        </span>
                      )}
                    </td>
                    <td className="py-3.5 px-4 text-right">
                      <Link to={`/plans/${plan.id}`}>
                        <Button
                          variant="ghost"
                          size="sm"
                          className="text-indigo-600 hover:text-indigo-700 hover:bg-indigo-50 text-xs gap-1"
                        >
                          Manage Plan
                          <ArrowRight className="w-3 h-3" />
                        </Button>
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {/* Pagination Footer */}
        {data && data.total_pages > 1 && (
          <div className="p-4 border-t border-slate-100 bg-slate-50/50 flex items-center justify-between">
            <span className="text-xs text-slate-500">
              Showing page {data.page} of {data.total_pages} ({data.total} total plans)
            </span>
            <div className="flex items-center gap-2">
              <Button
                variant="outline"
                size="sm"
                onClick={() => setPage((p) => Math.max(1, p - 1))}
                disabled={page <= 1}
                className="text-xs"
              >
                Previous
              </Button>
              <Button
                variant="outline"
                size="sm"
                onClick={() => setPage((p) => Math.min(data.total_pages, p + 1))}
                disabled={page >= data.total_pages}
                className="text-xs"
              >
                Next
              </Button>
            </div>
          </div>
        )}
      </div>

      <PlanCreateModal
        isOpen={isCreateOpen}
        onClose={() => setIsCreateOpen(false)}
      />
    </div>
  );
};
