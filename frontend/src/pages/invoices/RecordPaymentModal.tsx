import React, { useState } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { paymentsApi } from "@/api/payments";
import { Invoice, PaymentMethod } from "@/types";
import { useToast } from "@/components/ui/toast";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { formatCurrency } from "@/lib/utils";
import { X, Loader2, IndianRupee } from "lucide-react";

interface RecordPaymentModalProps {
  isOpen: boolean;
  onClose: () => void;
  invoice: Invoice;
  onSuccess?: () => void;
}

export const RecordPaymentModal: React.FC<RecordPaymentModalProps> = ({
  isOpen,
  onClose,
  invoice,
  onSuccess,
}) => {
  const { success, error } = useToast();
  const queryClient = useQueryClient();

  const balanceDue = parseFloat(invoice.balance_due) || 0;
  const [amount, setAmount] = useState(balanceDue.toFixed(2));
  const [paymentMethod, setPaymentMethod] = useState<PaymentMethod>("BANK_TRANSFER");
  const [referenceNumber, setReferenceNumber] = useState("");
  const [paymentDate, setPaymentDate] = useState(
    new Date().toISOString().split("T")[0]
  );
  const [notes, setNotes] = useState("");

  const parsedAmount = parseFloat(amount) || 0;
  const newBalance = Math.max(0, balanceDue - parsedAmount);
  const isOverpaying = parsedAmount > balanceDue;
  const isInvalidAmount = parsedAmount <= 0;

  const paymentMutation = useMutation({
    mutationFn: () =>
      paymentsApi.recordPayment({
        invoice_id: invoice.id,
        amount: parsedAmount.toFixed(4),
        payment_method: paymentMethod,
        payment_date: new Date(paymentDate).toISOString(),
        reference_number: referenceNumber.trim() || undefined,
        notes: notes.trim() || undefined,
      }),
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ["invoice", invoice.id] });
      queryClient.invalidateQueries({ queryKey: ["invoices"] });
      queryClient.invalidateQueries({ queryKey: ["dashboard-metrics"] });
      queryClient.invalidateQueries({ queryKey: ["subscription", invoice.subscription_id] });
      success(
        `Recorded ${data.payment_number} for ${formatCurrency(data.amount, data.currency)}`,
        "Payment Recorded"
      );
      onClose();
      if (onSuccess) onSuccess();
    },
    onError: (err: any) => {
      error(
        err.response?.data?.detail || "Failed to record payment. Check amount and fields.",
        "Payment Failed"
      );
    },
  });

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (isInvalidAmount) {
      error("Payment amount must be greater than zero.", "Validation Error");
      return;
    }
    if (isOverpaying) {
      error("Payment amount cannot exceed outstanding balance due.", "Overpayment Error");
      return;
    }

    paymentMutation.mutate();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Backdrop */}
      <div
        className="fixed inset-0 bg-slate-900/40 backdrop-blur-xs transition-opacity"
        onClick={onClose}
      />

      {/* Modal Dialog Content */}
      <div className="relative z-50 w-full max-w-lg rounded-xl bg-white p-6 shadow-xl border border-slate-200">
        <div className="flex items-center justify-between pb-3 border-b border-slate-100">
          <div className="flex items-center gap-2">
            <div className="p-2 bg-emerald-50 text-emerald-700 rounded-lg">
              <IndianRupee className="w-5 h-5" />
            </div>
            <div>
              <h2 className="text-lg font-bold text-slate-900">Record Payment</h2>
              <p className="text-xs text-slate-500 font-mono">
                Invoice {invoice.invoice_number}
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

        {/* Balance Status Banner */}
        <div className="my-4 p-3 bg-slate-50 border border-slate-200/80 rounded-lg flex items-center justify-between text-xs">
          <div>
            <span className="text-slate-400 block font-medium">Invoice Total</span>
            <span className="font-mono font-bold text-slate-800 text-sm">
              {formatCurrency(invoice.total_amount, invoice.currency)}
            </span>
          </div>
          <div className="text-right">
            <span className="text-slate-400 block font-medium">Current Balance Due</span>
            <span className="font-mono font-bold text-red-600 text-sm">
              {formatCurrency(invoice.balance_due, invoice.currency)}
            </span>
          </div>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="space-y-1.5">
              <Label htmlFor="payAmount">
                Payment Amount ({invoice.currency}) <span className="text-red-500">*</span>
              </Label>
              <Input
                id="payAmount"
                type="number"
                step="0.01"
                min="0.01"
                max={balanceDue.toString()}
                value={amount}
                onChange={(e) => setAmount(e.target.value)}
                required
              />
              {isOverpaying && (
                <p className="text-[11px] text-red-600 font-medium">
                  Amount exceeds balance ({formatCurrency(invoice.balance_due, invoice.currency)})
                </p>
              )}
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="payMethod">
                Payment Method <span className="text-red-500">*</span>
              </Label>
              <select
                id="payMethod"
                value={paymentMethod}
                onChange={(e) => setPaymentMethod(e.target.value as any)}
                className="w-full h-9 px-3 rounded-md border border-slate-200 bg-white text-sm"
              >
                <option value="BANK_TRANSFER">Bank Transfer (NEFT/RTGS)</option>
                <option value="UPI">UPI / QR Code</option>
                <option value="CREDIT_CARD">Credit Card (Offline)</option>
                <option value="DEBIT_CARD">Debit Card (Offline)</option>
                <option value="CHEQUE">Cheque / Demand Draft</option>
                <option value="CASH">Cash</option>
                <option value="OTHER">Other Reference</option>
              </select>
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="space-y-1.5">
              <Label htmlFor="payDate">Payment Date</Label>
              <Input
                id="payDate"
                type="date"
                value={paymentDate}
                onChange={(e) => setPaymentDate(e.target.value)}
                required
              />
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="refNo">Reference / UTR #</Label>
              <Input
                id="refNo"
                placeholder="e.g. UTR-8729103981"
                value={referenceNumber}
                onChange={(e) => setReferenceNumber(e.target.value)}
              />
            </div>
          </div>

          <div className="space-y-1.5">
            <Label htmlFor="payNotes">Internal Notes</Label>
            <Input
              id="payNotes"
              placeholder="e.g. Verified with bank statement"
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
            />
          </div>

          {/* New Balance Preview */}
          <div className="p-3 bg-emerald-50/60 border border-emerald-200/80 rounded-lg flex items-center justify-between text-xs">
            <span className="text-slate-600">
              Remaining balance after this transaction:
            </span>
            <span className="font-mono font-bold text-slate-900 text-sm">
              {formatCurrency(newBalance.toFixed(2), invoice.currency)}
            </span>
          </div>

          <div className="flex justify-end gap-2 pt-3 border-t border-slate-100">
            <Button type="button" variant="outline" onClick={onClose}>
              Cancel
            </Button>
            <Button
              type="submit"
              disabled={paymentMutation.isPending || isOverpaying || isInvalidAmount}
              className="gap-1.5 bg-emerald-600 hover:bg-emerald-700"
            >
              {paymentMutation.isPending && <Loader2 className="w-4 h-4 animate-spin" />}
              Confirm Payment
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
};
