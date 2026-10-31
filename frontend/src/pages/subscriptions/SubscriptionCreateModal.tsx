import React, { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { subscriptionsApi } from "@/api/subscriptions";
import { customersApi } from "@/api/customers";
import { plansApi } from "@/api/plans";
import { PaymentTerms, SubscriptionCreate } from "@/types";
import { useToast } from "@/components/ui/toast";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { formatCurrency } from "@/lib/utils";
import { X, Loader2, CreditCard } from "lucide-react";

interface SubscriptionCreateModalProps {
  isOpen: boolean;
  onClose: () => void;
  preselectedCustomerId?: string;
  onSuccess?: (subId: string) => void;
}

export const SubscriptionCreateModal: React.FC<SubscriptionCreateModalProps> = ({
  isOpen,
  onClose,
  preselectedCustomerId,
  onSuccess,
}) => {
  const { success, error } = useToast();
  const queryClient = useQueryClient();

  const [customerId, setCustomerId] = useState(preselectedCustomerId || "");
  const [planId, setPlanId] = useState("");
  const [startDate, setStartDate] = useState(
    new Date().toISOString().split("T")[0]
  );
  const [paymentTerms, setPaymentTerms] = useState<PaymentTerms>("NET_30");
  const [taxRate, setTaxRate] = useState("18.00");
  const [discountAmount, setDiscountAmount] = useState("0.00");
  const [notes, setNotes] = useState("");

  // Load Active Customers
  const { data: customersData, isLoading: isLoadingCustomers } = useQuery({
    queryKey: ["active-customers-options"],
    queryFn: () => customersApi.listCustomers({ limit: 100, status: "ACTIVE" }),
    enabled: isOpen,
  });

  // Load Active Subscription Plans
  const { data: plansData, isLoading: isLoadingPlans } = useQuery({
    queryKey: ["active-plans-options"],
    queryFn: () => plansApi.listPlans({ limit: 100, status: "ACTIVE" }),
    enabled: isOpen,
  });

  // Load Selected Plan Details
  const { data: selectedPlan } = useQuery({
    queryKey: ["plan-detail", planId],
    queryFn: () => plansApi.getPlan(planId),
    enabled: !!planId,
  });

  const createMutation = useMutation({
    mutationFn: (payload: SubscriptionCreate) => subscriptionsApi.createSubscription(payload),
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ["subscriptions"] });
      queryClient.invalidateQueries({ queryKey: ["dashboard-metrics"] });
      success(`Subscription ${data.subscription_number} initiated as DRAFT.`, "Subscription Created");
      onClose();
      if (onSuccess) onSuccess(data.id);
    },
    onError: (err: any) => {
      error(
        err.response?.data?.detail || "Failed to create subscription. Check inputs.",
        "Creation Failed"
      );
    },
  });

  if (!isOpen) return null;

  // Live price estimate
  const planBaseTotal = selectedPlan?.calculated_total_price
    ? parseFloat(selectedPlan.calculated_total_price)
    : 0;
  const discountVal = parseFloat(discountAmount) || 0;
  const taxableBase = Math.max(0, planBaseTotal - discountVal);
  const taxVal = taxableBase * ((parseFloat(taxRate) || 0) / 100);
  const estimatedTotal = taxableBase + taxVal;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!customerId) {
      error("Please select a customer.", "Validation Error");
      return;
    }
    if (!planId) {
      error("Please select a subscription plan.", "Validation Error");
      return;
    }

    createMutation.mutate({
      customer_id: customerId,
      plan_id: planId,
      start_date: new Date(startDate).toISOString(),
      payment_terms: paymentTerms,
      tax_rate: taxRate,
      discount_amount: discountAmount,
      notes: notes.trim() || null,
    });
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Backdrop */}
      <div
        className="fixed inset-0 bg-slate-900/40 backdrop-blur-xs transition-opacity"
        onClick={onClose}
      />

      {/* Modal Dialog Content */}
      <div className="relative z-50 w-full max-w-xl rounded-xl bg-white p-6 shadow-xl border border-slate-200 flex flex-col max-h-[90vh]">
        <div className="flex items-center justify-between pb-3 border-b border-slate-100">
          <div className="flex items-center gap-2">
            <div className="p-2 bg-blue-50 text-blue-700 rounded-lg">
              <CreditCard className="w-5 h-5" />
            </div>
            <div>
              <h2 className="text-lg font-bold text-slate-900">Create Subscription</h2>
              <p className="text-xs text-slate-500">
                Bind an active plan to a customer account and initiate draft lifecycle
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="rounded-lg p-1 text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="flex-1 overflow-y-auto space-y-4 pt-4 pr-1">
          {/* Customer Selection */}
          <div className="space-y-1.5">
            <Label htmlFor="customerSelect">
              Select Customer <span className="text-red-500">*</span>
            </Label>
            <select
              id="customerSelect"
              value={customerId}
              onChange={(e) => setCustomerId(e.target.value)}
              className="w-full h-9 px-3 rounded-md border border-slate-200 bg-white text-sm"
              required
            >
              <option value="">-- Choose Customer --</option>
              {customersData?.items.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.name} {c.company_name ? `(${c.company_name})` : ""} — {c.customer_number}
                </option>
              ))}
            </select>
            {isLoadingCustomers && <p className="text-xs text-slate-400">Loading customers...</p>}
          </div>

          {/* Plan Selection */}
          <div className="space-y-1.5">
            <Label htmlFor="planSelect">
              Subscription Plan <span className="text-red-500">*</span>
            </Label>
            <select
              id="planSelect"
              value={planId}
              onChange={(e) => setPlanId(e.target.value)}
              className="w-full h-9 px-3 rounded-md border border-slate-200 bg-white text-sm font-medium"
              required
            >
              <option value="">-- Choose Active Plan --</option>
              {plansData?.items.map((p) => (
                <option key={p.id} value={p.id}>
                  {p.name} ({p.code}) — {p.billing_interval} • {formatCurrency(p.calculated_total_price, p.currency)}
                </option>
              ))}
            </select>
            {isLoadingPlans && <p className="text-xs text-slate-400">Loading plans...</p>}
          </div>

          {/* Plan Bundled Items summary if selected */}
          {selectedPlan && (
            <div className="p-3 bg-slate-50 border border-slate-200/80 rounded-lg space-y-2">
              <div className="flex items-center justify-between text-xs font-semibold text-slate-700">
                <span>Bundled Line Items ({selectedPlan.bundled_products?.length || 0})</span>
                <span className="font-mono text-blue-700">
                  Cadence: {selectedPlan.billing_interval} ({selectedPlan.interval_count}x)
                </span>
              </div>
              <div className="space-y-1 text-xs text-slate-600">
                {selectedPlan.bundled_products?.map((bp) => (
                  <div key={bp.id} className="flex justify-between items-center py-0.5 border-b border-slate-100 last:border-0">
                    <span>
                      {bp.default_quantity}x {bp.product?.name || "Product"}
                      {bp.variant && <span className="text-slate-400"> ({bp.variant.variant_name})</span>}
                    </span>
                    <span className="font-mono font-medium">
                      {formatCurrency(bp.price_override || bp.product?.sales_price || "0", selectedPlan.currency)}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Dates & Payment Terms */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-1.5">
              <Label htmlFor="startDate">
                Start Date <span className="text-red-500">*</span>
              </Label>
              <Input
                id="startDate"
                type="date"
                value={startDate}
                onChange={(e) => setStartDate(e.target.value)}
                required
              />
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="paymentTerms">Payment Terms</Label>
              <select
                id="paymentTerms"
                value={paymentTerms}
                onChange={(e) => setPaymentTerms(e.target.value as any)}
                className="w-full h-9 px-3 rounded-md border border-slate-200 bg-white text-sm"
              >
                <option value="IMMEDIATE">Due Immediate</option>
                <option value="NET_15">Net 15 Days</option>
                <option value="NET_30">Net 30 Days (Standard)</option>
                <option value="NET_60">Net 60 Days</option>
              </select>
            </div>
          </div>

          {/* Tax and Discount */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-1.5">
              <Label htmlFor="taxRate">Tax Rate (%)</Label>
              <Input
                id="taxRate"
                type="number"
                step="0.01"
                min="0"
                max="100"
                value={taxRate}
                onChange={(e) => setTaxRate(e.target.value)}
              />
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="discountAmount">Discount Amount</Label>
              <Input
                id="discountAmount"
                type="number"
                step="0.01"
                min="0"
                value={discountAmount}
                onChange={(e) => setDiscountAmount(e.target.value)}
              />
            </div>
          </div>

          {/* Contract Notes */}
          <div className="space-y-1.5">
            <Label htmlFor="subNotes">Terms & Notes</Label>
            <Input
              id="subNotes"
              placeholder="e.g. Approved enterprise discount, signed MSA on file"
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
            />
          </div>

          {/* Financial Preview Card */}
          {selectedPlan && (
            <div className="p-3 bg-blue-50/50 border border-blue-200/60 rounded-lg flex items-center justify-between text-xs">
              <div>
                <span className="text-slate-500 block">Estimated Billing Total</span>
                <span className="text-slate-400 text-[11px]">
                  Subtotal: {formatCurrency(planBaseTotal.toString(), selectedPlan.currency)} • Tax ({taxRate}%): {formatCurrency(taxVal.toString(), selectedPlan.currency)}
                </span>
              </div>
              <div className="text-right">
                <span className="text-lg font-bold font-mono text-slate-900 block">
                  {formatCurrency(estimatedTotal.toFixed(2), selectedPlan.currency)}
                </span>
                <span className="text-[10px] text-blue-600 font-medium">Calculated on Backend</span>
              </div>
            </div>
          )}

          <div className="flex justify-end gap-2 pt-4 border-t border-slate-100">
            <Button type="button" variant="outline" onClick={onClose}>
              Cancel
            </Button>
            <Button type="submit" disabled={createMutation.isPending || !planId || !customerId} className="gap-1.5">
              {createMutation.isPending && <Loader2 className="w-4 h-4 animate-spin" />}
              Initiate Subscription
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
};
