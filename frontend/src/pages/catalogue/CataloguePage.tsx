import React, { useState } from "react";
import { Link } from "react-router-dom";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { plansApi } from "@/api/plans";
import { productsApi } from "@/api/products";
import { useAuth } from "@/hooks/useAuth";
import { useToast } from "@/components/ui/toast";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { formatCurrency } from "@/lib/utils";
import { SubscriptionPlan, BillingInterval } from "@/types";
import { SubscriptionCreateModal } from "@/pages/subscriptions/SubscriptionCreateModal";
import { RequestQuotationModal } from "./RequestQuotationModal";
import {
  Search,
  Check,
  CreditCard,
  Settings,
  Zap,
  RefreshCw,
  Layers,
  Package,
  ArrowRight,
  Loader2,
} from "lucide-react";

export const CataloguePage: React.FC = () => {
  const { user } = useAuth();
  const { success, error } = useToast();
  const queryClient = useQueryClient();

  const role = user?.role || "CUSTOMER";
  const isAdmin = role === "ADMIN";
  const isStaffOrAdmin = role === "ADMIN" || role === "STAFF";

  // State
  const [search, setSearch] = useState("");
  const [activeTab, setActiveTab] = useState<"ALL" | "PLANS" | "ADDONS">("ALL");
  const [frequencyFilter, setFrequencyFilter] = useState<"ALL" | "MONTHLY" | "YEARLY">("ALL");

  // Subscription Creation & Quote Modals
  const [selectedPlanForSub, setSelectedPlanForSub] = useState<string | null>(null);
  const [selectedPlanForQuote, setSelectedPlanForQuote] = useState<SubscriptionPlan | null>(null);

  // Single Unified Catalogue Query (Accessible to Admin, Staff, Customer)
  const {
    data: catalogueData,
    isLoading: isLoadingCatalogue,
  } = useQuery({
    queryKey: ["catalogue-items"],
    queryFn: () => plansApi.getCatalogueItems(),
  });

  // Setup Default Catalogue Mutation
  const setupMutation = useMutation({
    mutationFn: () => plansApi.setupCatalogue(),
    onSuccess: (res) => {
      queryClient.invalidateQueries({ queryKey: ["catalogue-items"] });
      queryClient.invalidateQueries({ queryKey: ["plans"] });
      queryClient.invalidateQueries({ queryKey: ["products"] });
      const createdCount =
        (res.products_created?.length || 0) + (res.plans_created?.length || 0);
      success(
        `Default catalogue synchronized. Created ${createdCount} new entries, preserved existing items.`,
        "Catalogue Up to Date"
      );
    },
    onError: (err: any) => {
      error(
        err.response?.data?.detail || "Failed to setup catalogue.",
        "Setup Error"
      );
    },
  });

  // In-memory search & filter
  const searchLower = search.trim().toLowerCase();

  const allPlans = (catalogueData?.plans || []).filter((p) => {
    if (frequencyFilter !== "ALL" && p.billing_interval !== frequencyFilter) {
      return false;
    }
    if (searchLower) {
      return (
        p.name.toLowerCase().includes(searchLower) ||
        p.code.toLowerCase().includes(searchLower) ||
        (p.description && p.description.toLowerCase().includes(searchLower))
      );
    }
    return true;
  });

  const allAddons = (catalogueData?.addons || []).filter((a) => {
    if (searchLower) {
      return (
        a.name.toLowerCase().includes(searchLower) ||
        a.sku.toLowerCase().includes(searchLower) ||
        (a.description && a.description.toLowerCase().includes(searchLower))
      );
    }
    return true;
  });

  return (
    <div className="space-y-6">
      {/* Top Banner */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-slate-200/80 pb-5">
        <div>
          <div className="flex items-center gap-2">
            <h1 className="text-2xl font-bold tracking-tight text-slate-900">
              Subscription & Product Catalogue
            </h1>
            <Badge variant="outline" className="border-indigo-200 text-indigo-700 bg-indigo-50">
              Active Offerings
            </Badge>
          </div>
          <p className="text-sm text-slate-500 mt-1">
            Standard software platforms, recurring contract cadences, and high-performance add-on modules.
          </p>
        </div>

        {isAdmin && (
          <div className="flex items-center gap-2 shrink-0">
            <Button
              variant="outline"
              size="sm"
              disabled={setupMutation.isPending}
              onClick={() => setupMutation.mutate()}
              className="gap-2 shadow-xs border-indigo-200 text-indigo-700 hover:bg-indigo-50"
            >
              {setupMutation.isPending ? (
                <Loader2 className="w-4 h-4 animate-spin text-indigo-600" />
              ) : (
                <RefreshCw className="w-4 h-4 text-indigo-600" />
              )}
              Populate Default Catalogue
            </Button>
          </div>
        )}
      </div>

      {/* Search & Filter Toolbar */}
      <div className="bg-white p-4 rounded-xl border border-slate-200/80 shadow-xs flex flex-col md:flex-row gap-3 items-stretch md:items-center justify-between">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <Input
            placeholder="Search plans, add-ons, features or SKUs..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="pl-9 text-xs"
          />
        </div>

        <div className="flex flex-wrap items-center gap-2">
          {/* Category Tabs */}
          <div className="flex bg-slate-100 p-0.5 rounded-lg border border-slate-200 text-xs font-medium">
            <button
              onClick={() => setActiveTab("ALL")}
              className={`px-3 py-1.5 rounded-md transition-colors ${
                activeTab === "ALL"
                  ? "bg-white text-slate-900 shadow-xs font-semibold"
                  : "text-slate-600 hover:text-slate-900"
              }`}
            >
              All Offerings
            </button>
            <button
              onClick={() => setActiveTab("PLANS")}
              className={`px-3 py-1.5 rounded-md transition-colors ${
                activeTab === "PLANS"
                  ? "bg-white text-slate-900 shadow-xs font-semibold"
                  : "text-slate-600 hover:text-slate-900"
              }`}
            >
              Software Plans ({allPlans.length})
            </button>
            <button
              onClick={() => setActiveTab("ADDONS")}
              className={`px-3 py-1.5 rounded-md transition-colors ${
                activeTab === "ADDONS"
                  ? "bg-white text-slate-900 shadow-xs font-semibold"
                  : "text-slate-600 hover:text-slate-900"
              }`}
            >
              Add-ons ({allAddons.length})
            </button>
          </div>

          {/* Billing Frequency Selector */}
          {(activeTab === "ALL" || activeTab === "PLANS") && (
            <div className="flex bg-slate-100 p-0.5 rounded-lg border border-slate-200 text-xs font-medium">
              <button
                onClick={() => setFrequencyFilter("ALL")}
                className={`px-2.5 py-1.5 rounded-md transition-colors ${
                  frequencyFilter === "ALL"
                    ? "bg-white text-slate-900 shadow-xs font-semibold"
                    : "text-slate-600 hover:text-slate-900"
                }`}
              >
                All Cadences
              </button>
              <button
                onClick={() => setFrequencyFilter("MONTHLY")}
                className={`px-2.5 py-1.5 rounded-md transition-colors ${
                  frequencyFilter === "MONTHLY"
                    ? "bg-white text-slate-900 shadow-xs font-semibold"
                    : "text-slate-600 hover:text-slate-900"
                }`}
              >
                Monthly
              </button>
              <button
                onClick={() => setFrequencyFilter("YEARLY")}
                className={`px-2.5 py-1.5 rounded-md transition-colors ${
                  frequencyFilter === "YEARLY"
                    ? "bg-white text-slate-900 shadow-xs font-semibold"
                    : "text-slate-600 hover:text-slate-900"
                }`}
              >
                Annual <span className="text-[10px] text-emerald-600 font-bold ml-0.5">(-17%)</span>
              </button>
            </div>
          )}
        </div>
      </div>

      {/* SECTION 1: Software Subscription Plans */}
      {(activeTab === "ALL" || activeTab === "PLANS") && (
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Layers className="w-5 h-5 text-indigo-600" />
              <h2 className="text-lg font-bold text-slate-900">Software Subscription Plans</h2>
            </div>
            <span className="text-xs text-slate-500">
              {allPlans.length} active plans configured
            </span>
          </div>

          {isLoadingCatalogue ? (
            <div className="py-12 text-center text-slate-400 text-xs">
              <Loader2 className="w-6 h-6 animate-spin mx-auto mb-2 text-indigo-600" />
              Loading subscription plans...
            </div>
          ) : allPlans.length === 0 ? (
            <div className="rounded-xl border border-dashed border-slate-200 bg-white p-8 text-center">
              <p className="text-sm font-semibold text-slate-700">No subscription plans match your filter.</p>
              <p className="text-xs text-slate-400 mt-1">
                Try clearing your search or click "Populate Default Catalogue" above.
              </p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {allPlans.map((plan) => {
                const isGrowth = plan.name.toLowerCase().includes("growth");
                const isAnnual = plan.billing_interval === "YEARLY";

                return (
                  <Card
                    key={plan.id}
                    className={`relative flex flex-col justify-between transition-all hover:shadow-md ${
                      isGrowth ? "border-indigo-400 ring-1 ring-indigo-400/40" : "border-slate-200"
                    }`}
                  >
                    {isGrowth && (
                      <div className="absolute -top-3 left-1/2 -translate-x-1/2">
                        <Badge className="bg-indigo-600 text-white font-semibold text-[10px] px-2.5 py-0.5 shadow-xs">
                          ⭐ Recommended for Scaling Teams
                        </Badge>
                      </div>
                    )}

                    <CardHeader className="pb-3">
                      <div className="flex items-center justify-between mb-1">
                        <span className="text-[11px] font-mono text-slate-400">{plan.code}</span>
                        <Badge variant="outline" className="text-[10px] uppercase">
                          {plan.billing_interval}
                        </Badge>
                      </div>
                      <CardTitle className="text-lg font-bold text-slate-900">{plan.name}</CardTitle>
                      <CardDescription className="text-xs line-clamp-2 min-h-[32px]">
                        {plan.description || "Production-grade Brightloop subscription plan with automated recurring invoicing."}
                      </CardDescription>
                    </CardHeader>

                    <CardContent className="space-y-4 flex-1 flex flex-col justify-between">
                      {/* Price Tag */}
                      <div className="p-3 bg-slate-50/80 rounded-lg border border-slate-100 flex items-baseline justify-between">
                        <div>
                          <span className="text-2xl font-bold font-mono text-slate-900">
                            {formatCurrency(plan.calculated_total_price || "0", plan.currency)}
                          </span>
                          <span className="text-xs text-slate-500 font-medium ml-1">
                            / {isAnnual ? "year" : "month"}
                          </span>
                        </div>
                        {isAnnual && (
                          <span className="text-[11px] font-semibold text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200">
                            Save ~17%
                          </span>
                        )}
                      </div>

                      {/* Included Features & Bundle Items */}
                      <div className="space-y-2 text-xs">
                        <span className="font-semibold text-slate-700 block text-[11px] uppercase tracking-wider">
                          What's Included:
                        </span>
                        <div className="space-y-1.5 text-slate-600">
                          <div className="flex items-center gap-2">
                            <Check className="w-3.5 h-3.5 text-emerald-600 shrink-0" />
                            <span>Full platform access ({plan.bundled_products_count} core bundled product)</span>
                          </div>
                          <div className="flex items-center gap-2">
                            <Check className="w-3.5 h-3.5 text-emerald-600 shrink-0" />
                            <span>18.00% GST calculated automatically</span>
                          </div>
                          <div className="flex items-center gap-2">
                            <Check className="w-3.5 h-3.5 text-emerald-600 shrink-0" />
                            <span>Recurring lifecycle & payment tracking</span>
                          </div>
                          {isAnnual && (
                            <div className="flex items-center gap-2 text-indigo-700 font-medium">
                              <Zap className="w-3.5 h-3.5 text-indigo-600 shrink-0" />
                              <span>Annual prepayment discount applied</span>
                            </div>
                          )}
                        </div>
                      </div>

                      {/* Action Buttons */}
                      <div className="pt-3 border-t border-slate-100 flex items-center gap-2">
                        {isStaffOrAdmin ? (
                          <>
                            <Button
                              onClick={() => setSelectedPlanForSub(plan.id)}
                              size="sm"
                              className="flex-1 bg-indigo-600 hover:bg-indigo-700 text-white gap-1.5 shadow-xs text-xs"
                            >
                              <CreditCard className="w-3.5 h-3.5" />
                              Create Subscription
                            </Button>
                            {isAdmin && (
                              <Link to={`/plans/${plan.id}`}>
                                <Button variant="outline" size="sm" className="h-8 px-2.5" title="Configure Plan">
                                  <Settings className="w-3.5 h-3.5 text-slate-600" />
                                </Button>
                              </Link>
                            )}
                          </>
                        ) : (
                          <Button
                            onClick={() => setSelectedPlanForQuote(plan)}
                            size="sm"
                            className="w-full bg-indigo-600 hover:bg-indigo-700 text-white gap-1.5 shadow-xs text-xs"
                          >
                            <ArrowRight className="w-3.5 h-3.5" />
                            Request Quotation
                          </Button>
                        )}
                      </div>
                    </CardContent>
                  </Card>
                );
              })}
            </div>
          )}
        </div>
      )}

      {/* SECTION 2: Add-on Modules */}
      {(activeTab === "ALL" || activeTab === "ADDONS") && (
        <div className="space-y-4 pt-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Package className="w-5 h-5 text-indigo-600" />
              <h2 className="text-lg font-bold text-slate-900">Add-on Modules & Services</h2>
            </div>
            <span className="text-xs text-slate-500">
              {allAddons.length} add-on products available
            </span>
          </div>

          {isLoadingCatalogue ? (
            <div className="py-8 text-center text-slate-400 text-xs">
              <Loader2 className="w-5 h-5 animate-spin mx-auto mb-1 text-indigo-600" />
              Loading add-on modules...
            </div>
          ) : allAddons.length === 0 ? (
            <div className="rounded-xl border border-dashed border-slate-200 bg-white p-6 text-center text-xs text-slate-500">
              No add-on modules found. Click "Populate Default Catalogue" above.
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              {allAddons.map((addon) => (
                <Card key={addon.id} className="border-slate-200/90 hover:shadow-xs transition-shadow">
                  <CardHeader className="pb-2">
                    <div className="flex items-center justify-between mb-1">
                      <span className="text-[10px] font-mono text-slate-400">{addon.sku}</span>
                      <Badge variant="outline" className="text-[9px] bg-slate-50 text-slate-600">
                        ADD-ON PRODUCT
                      </Badge>
                    </div>
                    <CardTitle className="text-base font-bold text-slate-900">{addon.name}</CardTitle>
                    <CardDescription className="text-xs line-clamp-2">
                      {addon.description || "Attachable enterprise add-on module."}
                    </CardDescription>
                  </CardHeader>
                  <CardContent className="space-y-3">
                    <div className="p-2.5 bg-slate-50 rounded-lg border border-slate-100 flex items-baseline justify-between">
                      <span className="text-xl font-bold font-mono text-slate-900">
                        {formatCurrency(addon.sales_price, addon.currency)}
                      </span>
                      <span className="text-xs text-slate-500 font-medium">/ month</span>
                    </div>

                    <p className="text-[11px] text-slate-500 italic">
                      Compatible with Starter, Growth, and Business subscription plans.
                    </p>

                    {isAdmin && (
                      <Link to={`/products/${addon.id}`}>
                        <Button variant="ghost" size="sm" className="w-full text-xs h-7 text-indigo-600">
                          Inspect Product SKU
                        </Button>
                      </Link>
                    )}
                  </CardContent>
                </Card>
              ))}
            </div>
          )}
        </div>
      )}

      {/* Subscription Creation Modal (Admin / Staff) */}
      {selectedPlanForSub && (
        <SubscriptionCreateModal
          isOpen={!!selectedPlanForSub}
          onClose={() => setSelectedPlanForSub(null)}
          preselectedPlanId={selectedPlanForSub}
          onSuccess={() => setSelectedPlanForSub(null)}
        />
      )}

      {/* Request Quotation Modal (Customer) */}
      {selectedPlanForQuote && (
        <RequestQuotationModal
          isOpen={!!selectedPlanForQuote}
          onClose={() => setSelectedPlanForQuote(null)}
          plan={selectedPlanForQuote}
        />
      )}
    </div>
  );
};
