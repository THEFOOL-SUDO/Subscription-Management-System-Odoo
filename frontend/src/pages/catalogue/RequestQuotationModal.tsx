import React, { useState } from "react";
import { useAuth } from "@/hooks/useAuth";
import { SubscriptionPlan } from "@/types";
import { useToast } from "@/components/ui/toast";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { formatCurrency } from "@/lib/utils";
import { X, FileText, CheckCircle2 } from "lucide-react";

interface RequestQuotationModalProps {
  isOpen: boolean;
  onClose: () => void;
  plan: SubscriptionPlan | null;
}

export const RequestQuotationModal: React.FC<RequestQuotationModalProps> = ({
  isOpen,
  onClose,
  plan,
}) => {
  const { user } = useAuth();
  const { success } = useToast();

  const [quantity, setQuantity] = useState("1");
  const [notes, setNotes] = useState("");
  const [isSubmitted, setIsSubmitted] = useState(false);

  if (!isOpen || !plan) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitted(true);
    success(
      `Quotation request for ${plan.name} successfully logged. An enterprise specialist will contact ${user?.email || "you"} shortly.`,
      "Quotation Request Received"
    );
    setTimeout(() => {
      setIsSubmitted(false);
      onClose();
    }, 1200);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Backdrop */}
      <div
        className="fixed inset-0 bg-slate-900/40 backdrop-blur-xs transition-opacity"
        onClick={onClose}
      />

      {/* Modal Dialog Content */}
      <div className="relative z-50 w-full max-w-lg rounded-xl bg-white p-6 shadow-xl border border-slate-200 flex flex-col">
        <div className="flex items-center justify-between pb-3 border-b border-slate-100">
          <div className="flex items-center gap-2">
            <div className="p-2 bg-indigo-50 text-indigo-700 rounded-lg">
              <FileText className="w-5 h-5" />
            </div>
            <div>
              <h2 className="text-lg font-bold text-slate-900">Request Quotation</h2>
              <p className="text-xs text-slate-500">
                Receive an itemized commercial proposal for your organization
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

        {isSubmitted ? (
          <div className="py-12 text-center space-y-3">
            <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-emerald-100 text-emerald-600">
              <CheckCircle2 className="w-6 h-6" />
            </div>
            <h3 className="text-base font-bold text-slate-900">Quotation In Progress</h3>
            <p className="text-xs text-slate-500 max-w-sm mx-auto">
              We have linked this request to your verified customer account ({user?.email}).
            </p>
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="space-y-4 pt-4">
            {/* Plan Info Card */}
            <div className="p-3.5 bg-slate-50 rounded-lg border border-slate-200/80 flex items-center justify-between">
              <div>
                <span className="font-bold text-sm text-slate-900 block">{plan.name}</span>
                <span className="text-[11px] font-mono text-slate-500">
                  Code: {plan.code} • {plan.billing_interval} ({plan.interval_count}x)
                </span>
              </div>
              <div className="text-right">
                <span className="text-base font-bold font-mono text-indigo-600 block">
                  {formatCurrency(plan.calculated_total_price || "0", plan.currency)}
                </span>
                <Badge variant="outline" className="text-[10px]">
                  Base Catalog Price
                </Badge>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-1.5">
                <Label htmlFor="reqCustomer">Contact Person</Label>
                <Input
                  id="reqCustomer"
                  value={user?.full_name || ""}
                  disabled
                  className="bg-slate-100 text-slate-600 text-xs"
                />
              </div>

              <div className="space-y-1.5">
                <Label htmlFor="reqEmail">Account Email</Label>
                <Input
                  id="reqEmail"
                  value={user?.email || ""}
                  disabled
                  className="bg-slate-100 text-slate-600 text-xs"
                />
              </div>
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="reqQuantity">Target Subscribed Units / Quantity</Label>
              <Input
                id="reqQuantity"
                type="number"
                min="1"
                value={quantity}
                onChange={(e) => setQuantity(e.target.value)}
                className="text-xs"
                required
              />
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="reqNotes">Deployment Requirements / Custom Add-ons</Label>
              <textarea
                id="reqNotes"
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
                placeholder="Specify required add-ons (AI Module, SLA, additional seats), billing cycle preferences, or PO references..."
                rows={3}
                className="w-full text-xs rounded-lg border border-slate-300 p-2.5 focus:border-indigo-500 focus:outline-hidden"
              />
            </div>

            <div className="flex items-center justify-end gap-2 pt-3 border-t border-slate-100">
              <Button type="button" variant="outline" onClick={onClose} size="sm">
                Cancel
              </Button>
              <Button
                type="submit"
                size="sm"
                className="bg-indigo-600 hover:bg-indigo-700 text-white shadow-xs"
              >
                Submit Quotation Request
              </Button>
            </div>
          </form>
        )}
      </div>
    </div>
  );
};
