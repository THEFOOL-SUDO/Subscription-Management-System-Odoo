import React, { useState } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { plansApi } from "@/api/plans";
import {
  BillingInterval,
  SubscriptionPlanCreateInput,
} from "@/types";
import { useToast } from "@/components/ui/toast";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { X, Layers, Loader2 } from "lucide-react";

interface PlanCreateModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess?: (planId: string) => void;
}

export const PlanCreateModal: React.FC<PlanCreateModalProps> = ({
  isOpen,
  onClose,
  onSuccess,
}) => {
  const { success, error: toastError } = useToast();
  const queryClient = useQueryClient();

  const [code, setCode] = useState("");
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [billingInterval, setBillingInterval] =
    useState<BillingInterval>("MONTHLY");
  const [intervalCount, setIntervalCount] = useState(1);
  const [trialDays, setTrialDays] = useState(0);
  const [currency, setCurrency] = useState("INR");
  const [minQty, setMinQty] = useState(1);
  const [maxQty, setMaxQty] = useState<string>("");
  const [isAutoClose, setIsAutoClose] = useState(false);
  const [availStart, setAvailStart] = useState("");
  const [availEnd, setAvailEnd] = useState("");

  const createMutation = useMutation({
    mutationFn: (data: SubscriptionPlanCreateInput) => plansApi.createPlan(data),
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ["plans"] });
      success(`Plan ${data.name} (${data.code}) created successfully.`, "Plan Created");
      onClose();
      if (onSuccess) onSuccess(data.id);
    },
    onError: (err: any) => {
      toastError(
        err.response?.data?.detail || "Could not create subscription plan.",
        "Creation Failed"
      );
    },
  });

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!code.trim() || !name.trim()) {
      toastError("Please enter Plan Code and Name.", "Validation Error");
      return;
    }

    const payload: SubscriptionPlanCreateInput = {
      code: code.trim().toUpperCase(),
      name: name.trim(),
      description: description.trim() || undefined,
      billing_interval: billingInterval,
      interval_count: Number(intervalCount) || 1,
      trial_period_days: Number(trialDays) || 0,
      currency: currency.trim().toUpperCase(),
      min_quantity: Number(minQty) || 1,
      max_quantity: maxQty ? Number(maxQty) : undefined,
      is_auto_close: isAutoClose,
      availability_start_date: availStart ? new Date(availStart).toISOString() : null,
      availability_end_date: availEnd ? new Date(availEnd).toISOString() : null,
    };

    createMutation.mutate(payload);
  };

  return (
    <div className="fixed inset-0 z-50 bg-slate-900/40 backdrop-blur-xs flex items-center justify-center p-4 overflow-y-auto">
      <div className="bg-white rounded-xl shadow-xl border border-slate-200/80 w-full max-w-xl my-8 overflow-hidden animate-in fade-in zoom-in-95 duration-150">
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100 bg-slate-50/50">
          <div className="flex items-center gap-2.5">
            <div className="h-8 w-8 rounded-lg bg-indigo-50 text-indigo-600 flex items-center justify-center">
              <Layers className="w-4 h-4" />
            </div>
            <div>
              <h3 className="font-semibold text-slate-900 text-base leading-tight">
                Create Subscription Plan
              </h3>
              <p className="text-xs text-slate-500">
                Define billing cycles, quantity rules, and bundled components
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-1 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="space-y-1.5">
              <Label htmlFor="plan_name">Plan Name *</Label>
              <Input
                id="plan_name"
                placeholder="e.g. Business Pro Annual"
                value={name}
                onChange={(e) => setName(e.target.value)}
                required
              />
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="plan_code">Plan Code *</Label>
              <Input
                id="plan_code"
                placeholder="e.g. BIZ-PRO-YR"
                value={code}
                onChange={(e) => setCode(e.target.value)}
                className="uppercase"
                required
              />
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div className="space-y-1.5">
              <Label htmlFor="interval">Billing Frequency *</Label>
              <select
                id="interval"
                className="w-full h-10 px-3 rounded-lg border border-slate-200 bg-white text-sm"
                value={billingInterval}
                onChange={(e) =>
                  setBillingInterval(e.target.value as BillingInterval)
                }
              >
                <option value="DAILY">Daily</option>
                <option value="WEEKLY">Weekly</option>
                <option value="MONTHLY">Monthly</option>
                <option value="YEARLY">Yearly</option>
              </select>
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="interval_count">Interval Count *</Label>
              <Input
                id="interval_count"
                type="number"
                min="1"
                value={intervalCount}
                onChange={(e) => setIntervalCount(Number(e.target.value))}
                required
              />
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="plan_currency">Currency *</Label>
              <Input
                id="plan_currency"
                value={currency}
                maxLength={3}
                onChange={(e) => setCurrency(e.target.value)}
                required
              />
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div className="space-y-1.5">
              <Label htmlFor="trial_days">Trial Period (Days)</Label>
              <Input
                id="trial_days"
                type="number"
                min="0"
                value={trialDays}
                onChange={(e) => setTrialDays(Number(e.target.value))}
              />
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="min_qty">Min Quantity *</Label>
              <Input
                id="min_qty"
                type="number"
                min="1"
                value={minQty}
                onChange={(e) => setMinQty(Number(e.target.value))}
                required
              />
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="max_qty">Max Quantity</Label>
              <Input
                id="max_qty"
                type="number"
                min="1"
                placeholder="Unlimited"
                value={maxQty}
                onChange={(e) => setMaxQty(e.target.value)}
              />
            </div>
          </div>

          <div className="space-y-1.5">
            <Label htmlFor="plan_desc">Plan Description</Label>
            <Input
              id="plan_desc"
              placeholder="Summary of services included in this tier"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
            />
          </div>

          {/* Availability & Auto-Close Section */}
          <div className="p-3.5 bg-slate-50 rounded-lg border border-slate-200/80 space-y-3">
            <div className="flex items-center gap-2">
              <input
                type="checkbox"
                id="is_auto_close"
                checked={isAutoClose}
                onChange={(e) => setIsAutoClose(e.target.checked)}
                className="rounded border-slate-300 text-blue-600 focus:ring-blue-500"
              />
              <Label htmlFor="is_auto_close" className="text-xs font-semibold cursor-pointer">
                Enable Availability-Based Auto-Close
              </Label>
            </div>
            <p className="text-[11px] text-slate-500">
              When enabled and the Availability End Date passes, the plan status automatically transitions from Active to Archived, preventing new subscriptions while grandfathering active customers.
            </p>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 pt-1">
              <div className="space-y-1">
                <Label htmlFor="start_date" className="text-xs">
                  Availability Start
                </Label>
                <Input
                  id="start_date"
                  type="datetime-local"
                  value={availStart}
                  onChange={(e) => setAvailStart(e.target.value)}
                  className="text-xs h-9 bg-white"
                />
              </div>
              <div className="space-y-1">
                <Label htmlFor="end_date" className="text-xs">
                  Availability End
                </Label>
                <Input
                  id="end_date"
                  type="datetime-local"
                  value={availEnd}
                  onChange={(e) => setAvailEnd(e.target.value)}
                  className="text-xs h-9 bg-white"
                />
              </div>
            </div>
          </div>

          <div className="flex items-center justify-end gap-3 pt-3 border-t border-slate-100">
            <Button
              type="button"
              variant="outline"
              onClick={onClose}
              disabled={createMutation.isPending}
            >
              Cancel
            </Button>
            <Button
              type="submit"
              disabled={createMutation.isPending}
              className="bg-indigo-600 hover:bg-indigo-700 text-white gap-2"
            >
              {createMutation.isPending && (
                <Loader2 className="w-4 h-4 animate-spin" />
              )}
              Create Plan
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
};
