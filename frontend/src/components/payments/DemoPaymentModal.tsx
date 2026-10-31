import React, { useState, useEffect } from "react";
import { paymentsApi } from "@/api/payments";
import { CheckoutSessionResponse, PaymentTransactionResponse } from "@/types/payment_transaction";
import { formatCurrency } from "@/lib/utils";
import {
  ShieldAlert,
  CreditCard,
  Smartphone,
  Building,
  CheckCircle2,
  XCircle,
  AlertTriangle,
  Loader2,
  X,
} from "lucide-react";

interface DemoPaymentModalProps {
  invoiceId: string;
  isOpen: boolean;
  onClose: () => void;
  onPaymentSuccess?: () => void;
}

export const DemoPaymentModal: React.FC<DemoPaymentModalProps> = ({
  invoiceId,
  isOpen,
  onClose,
  onPaymentSuccess,
}) => {
  const [session, setSession] = useState<CheckoutSessionResponse | null>(null);
  const [isLoadingSession, setIsLoadingSession] = useState(false);
  const [sessionError, setSessionError] = useState<string | null>(null);

  const [paymentMethod, setPaymentMethod] = useState<"DEMO_CARD" | "DEMO_UPI" | "DEMO_NETBANKING">("DEMO_UPI");
  const [scenario, setScenario] = useState<"SUCCESS_FULL" | "SUCCESS_PARTIAL" | "DECLINE_GENERIC" | "CANCEL_USER">("SUCCESS_FULL");
  const [partialAmount, setPartialAmount] = useState<string>("");
  const [payerVpa, setPayerVpa] = useState("company@okhdfcbank");
  const [cardLast4, setCardLast4] = useState("4242");
  const [bankName, setBankName] = useState("HDFC Bank");

  const [isProcessing, setIsProcessing] = useState(false);
  const [result, setResult] = useState<PaymentTransactionResponse | null>(null);
  const [processError, setProcessError] = useState<string | null>(null);

  useEffect(() => {
    if (isOpen && invoiceId) {
      loadSession();
    } else {
      setSession(null);
      setResult(null);
      setProcessError(null);
    }
  }, [isOpen, invoiceId]);

  const loadSession = async () => {
    setIsLoadingSession(true);
    setSessionError(null);
    try {
      const data = await paymentsApi.createCheckoutSession(invoiceId);
      setSession(data);
      const bal = Number(data.balance_due);
      if (bal > 0) {
        setPartialAmount((bal / 2).toFixed(2));
      }
    } catch (err: any) {
      setSessionError(err?.response?.data?.detail || "Failed to initialize demo checkout session.");
    } finally {
      setIsLoadingSession(false);
    }
  };

  const handleProcessPayment = async () => {
    if (!session) return;
    setIsProcessing(true);
    setProcessError(null);

    try {
      const reqPayload = {
        session_token: session.session_token,
        payment_method: paymentMethod,
        scenario: scenario,
        amount: scenario === "SUCCESS_PARTIAL" ? partialAmount : undefined,
        idempotency_key: `idemp-${Date.now()}-${Math.random().toString(36).substring(2, 7)}`,
        payer_vpa: paymentMethod === "DEMO_UPI" ? payerVpa : undefined,
        card_last4: paymentMethod === "DEMO_CARD" ? cardLast4 : undefined,
        bank_name: paymentMethod === "DEMO_NETBANKING" ? bankName : undefined,
      };

      const txn = await paymentsApi.processDemoPayment(reqPayload);
      setResult(txn);
      if (txn.status === "SUCCESS") {
        if (onPaymentSuccess) {
          onPaymentSuccess();
        }
      }
    } catch (err: any) {
      setProcessError(err?.response?.data?.detail || "Payment processing failed.");
    } finally {
      setIsProcessing(false);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/60 backdrop-blur-sm p-4 overflow-y-auto">
      <div className="bg-white rounded-xl shadow-2xl border border-slate-200 w-full max-w-xl overflow-hidden animate-in fade-in zoom-in-95 duration-150">
        {/* Prominent Demo Warning Banner */}
        <div className="bg-amber-500 text-slate-950 px-4 py-2.5 flex items-center justify-between text-xs sm:text-sm font-semibold tracking-wide border-b border-amber-600">
          <div className="flex items-center gap-2">
            <ShieldAlert className="h-5 w-5 text-slate-950 shrink-0" />
            <span>DEMO MODE — SIMULATED PAYMENT — NO REAL MONEY TRANSFERRED</span>
          </div>
          <button
            onClick={onClose}
            className="text-slate-950 hover:bg-amber-600/50 p-1 rounded transition-colors"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        <div className="p-6">
          {isLoadingSession ? (
            <div className="py-12 flex flex-col items-center justify-center text-slate-500 gap-3">
              <Loader2 className="h-8 w-8 animate-spin text-indigo-600" />
              <p className="text-sm font-medium">Initializing secure demo checkout session...</p>
            </div>
          ) : sessionError ? (
            <div className="p-4 bg-rose-50 border border-rose-200 rounded-lg text-rose-800 text-sm">
              <div className="flex items-center gap-2 font-semibold mb-1">
                <AlertTriangle className="h-4 w-4" />
                Unable to Open Checkout
              </div>
              <p>{sessionError}</p>
              <button
                onClick={onClose}
                className="mt-4 px-4 py-1.5 bg-slate-800 text-white rounded text-xs font-medium hover:bg-slate-700"
              >
                Close
              </button>
            </div>
          ) : result ? (
            /* Result Screen */
            <div className="space-y-4">
              <div
                className={`p-6 rounded-xl border text-center ${
                  result.status === "SUCCESS"
                    ? "bg-emerald-50/70 border-emerald-200 text-emerald-950"
                    : result.status === "CANCELLED"
                    ? "bg-slate-50 border-slate-200 text-slate-800"
                    : "bg-rose-50/70 border-rose-200 text-rose-950"
                }`}
              >
                <div className="flex justify-center mb-2">
                  {result.status === "SUCCESS" ? (
                    <CheckCircle2 className="h-12 w-12 text-emerald-600" />
                  ) : result.status === "CANCELLED" ? (
                    <AlertTriangle className="h-12 w-12 text-slate-500" />
                  ) : (
                    <XCircle className="h-12 w-12 text-rose-600" />
                  )}
                </div>
                <h3 className="text-lg font-bold">
                  {result.status === "SUCCESS"
                    ? "Simulated Payment Successful"
                    : result.status === "CANCELLED"
                    ? "Payment Flow Cancelled"
                    : "Simulated Payment Declined"}
                </h3>
                <p className="text-xs text-slate-600 mt-1">
                  Transaction Reference: <span className="font-mono font-semibold">{result.transaction_reference}</span>
                </p>

                <div className="mt-4 pt-4 border-t border-slate-200/60 grid grid-cols-2 gap-2 text-left text-xs">
                  <div>
                    <span className="text-slate-500">Amount:</span>{" "}
                    <span className="font-semibold">{formatCurrency(result.amount, result.currency)}</span>
                  </div>
                  <div>
                    <span className="text-slate-500">Method:</span>{" "}
                    <span className="font-semibold">{result.payment_method}</span>
                  </div>
                  <div>
                    <span className="text-slate-500">Invoice Status:</span>{" "}
                    <span className="font-semibold">{result.invoice_status || session?.status}</span>
                  </div>
                  <div>
                    <span className="text-slate-500">Remaining Balance:</span>{" "}
                    <span className="font-semibold">
                      {formatCurrency(result.remaining_balance || "0", result.currency)}
                    </span>
                  </div>
                </div>

                {result.metadata_json?.failure_reason && (
                  <p className="mt-3 text-xs text-rose-700 bg-rose-100/60 p-2 rounded text-left">
                    Reason: {result.metadata_json.failure_reason}
                  </p>
                )}
              </div>

              <div className="flex justify-end gap-2 pt-2">
                <button
                  type="button"
                  onClick={onClose}
                  className="px-4 py-2 bg-slate-900 text-white rounded-lg text-sm font-semibold hover:bg-slate-800 transition-colors"
                >
                  Done
                </button>
              </div>
            </div>
          ) : session ? (
            /* Checkout Form */
            <div className="space-y-5">
              {/* Invoice Summary */}
              <div className="bg-slate-50 border border-slate-200 rounded-lg p-3 text-xs flex items-center justify-between">
                <div>
                  <div className="text-slate-500">Invoice</div>
                  <div className="font-bold text-slate-900 text-sm">{session.invoice_number}</div>
                  <div className="text-slate-600">{session.customer_name}</div>
                </div>
                <div className="text-right">
                  <div className="text-slate-500">Remaining Balance</div>
                  <div className="text-base font-extrabold text-indigo-600">
                    {formatCurrency(session.balance_due, session.currency)}
                  </div>
                  <div className="text-[11px] text-slate-500">Total: {formatCurrency(session.total_amount, session.currency)}</div>
                </div>
              </div>

              {/* Payment Method Selector */}
              <div>
                <label className="block text-xs font-semibold text-slate-700 uppercase tracking-wider mb-2">
                  Select Simulated Gateway Method
                </label>
                <div className="grid grid-cols-3 gap-2">
                  <button
                    type="button"
                    onClick={() => setPaymentMethod("DEMO_UPI")}
                    className={`p-3 rounded-lg border text-left flex flex-col items-center gap-1.5 transition-all text-xs font-semibold ${
                      paymentMethod === "DEMO_UPI"
                        ? "border-indigo-600 bg-indigo-50/60 text-indigo-900 shadow-sm"
                        : "border-slate-200 hover:bg-slate-50 text-slate-700"
                    }`}
                  >
                    <Smartphone className="h-5 w-5 text-indigo-600" />
                    <span>Demo UPI</span>
                  </button>
                  <button
                    type="button"
                    onClick={() => setPaymentMethod("DEMO_CARD")}
                    className={`p-3 rounded-lg border text-left flex flex-col items-center gap-1.5 transition-all text-xs font-semibold ${
                      paymentMethod === "DEMO_CARD"
                        ? "border-indigo-600 bg-indigo-50/60 text-indigo-900 shadow-sm"
                        : "border-slate-200 hover:bg-slate-50 text-slate-700"
                    }`}
                  >
                    <CreditCard className="h-5 w-5 text-indigo-600" />
                    <span>Demo Card</span>
                  </button>
                  <button
                    type="button"
                    onClick={() => setPaymentMethod("DEMO_NETBANKING")}
                    className={`p-3 rounded-lg border text-left flex flex-col items-center gap-1.5 transition-all text-xs font-semibold ${
                      paymentMethod === "DEMO_NETBANKING"
                        ? "border-indigo-600 bg-indigo-50/60 text-indigo-900 shadow-sm"
                        : "border-slate-200 hover:bg-slate-50 text-slate-700"
                    }`}
                  >
                    <Building className="h-5 w-5 text-indigo-600" />
                    <span>NetBanking</span>
                  </button>
                </div>
              </div>

              {/* Method-Specific Inputs */}
              <div className="p-3 bg-slate-50/70 border border-slate-200 rounded-lg text-xs space-y-2">
                {paymentMethod === "DEMO_UPI" && (
                  <div>
                    <label className="block text-slate-600 mb-1 font-medium">Virtual Payment Address (VPA):</label>
                    <input
                      type="text"
                      value={payerVpa}
                      onChange={(e) => setPayerVpa(e.target.value)}
                      placeholder="e.g. yourname@okhdfcbank"
                      className="w-full px-2.5 py-1.5 border border-slate-300 rounded bg-white text-slate-900 font-mono text-xs focus:ring-1 focus:ring-indigo-500 outline-none"
                    />
                  </div>
                )}
                {paymentMethod === "DEMO_CARD" && (
                  <div className="grid grid-cols-2 gap-2">
                    <div>
                      <label className="block text-slate-600 mb-1 font-medium">Simulated Card Last 4:</label>
                      <input
                        type="text"
                        maxLength={4}
                        value={cardLast4}
                        onChange={(e) => setCardLast4(e.target.value)}
                        className="w-full px-2.5 py-1.5 border border-slate-300 rounded bg-white text-slate-900 font-mono text-xs focus:ring-1 focus:ring-indigo-500 outline-none"
                      />
                    </div>
                    <div>
                      <label className="block text-slate-600 mb-1 font-medium">Card Network:</label>
                      <span className="inline-block py-1.5 font-semibold text-slate-700">Visa Corporate Debit</span>
                    </div>
                  </div>
                )}
                {paymentMethod === "DEMO_NETBANKING" && (
                  <div>
                    <label className="block text-slate-600 mb-1 font-medium">Select Corporate Bank:</label>
                    <select
                      value={bankName}
                      onChange={(e) => setBankName(e.target.value)}
                      className="w-full px-2.5 py-1.5 border border-slate-300 rounded bg-white text-slate-900 text-xs focus:ring-1 focus:ring-indigo-500 outline-none"
                    >
                      <option value="HDFC Bank">HDFC Bank</option>
                      <option value="State Bank of India">State Bank of India</option>
                      <option value="ICICI Bank">ICICI Bank</option>
                      <option value="Axis Bank">Axis Bank</option>
                      <option value="Kotak Mahindra Bank">Kotak Mahindra Bank</option>
                    </select>
                  </div>
                )}
              </div>

              {/* Simulation Scenario Selector */}
              <div>
                <label className="block text-xs font-semibold text-slate-700 uppercase tracking-wider mb-2">
                  Demonstration Outcome Scenario
                </label>
                <div className="grid grid-cols-2 gap-2 text-xs">
                  <label
                    className={`flex items-start gap-2 p-2.5 rounded-lg border cursor-pointer transition-all ${
                      scenario === "SUCCESS_FULL"
                        ? "border-emerald-500 bg-emerald-50/50 text-emerald-950 font-semibold"
                        : "border-slate-200 text-slate-700 hover:bg-slate-50"
                    }`}
                  >
                    <input
                      type="radio"
                      name="scenario"
                      checked={scenario === "SUCCESS_FULL"}
                      onChange={() => setScenario("SUCCESS_FULL")}
                      className="mt-0.5 text-emerald-600"
                    />
                    <div>
                      <div>Full Settlement</div>
                      <div className="text-[11px] font-normal text-slate-500">Pays 100% of balance due</div>
                    </div>
                  </label>

                  <label
                    className={`flex items-start gap-2 p-2.5 rounded-lg border cursor-pointer transition-all ${
                      scenario === "SUCCESS_PARTIAL"
                        ? "border-indigo-500 bg-indigo-50/50 text-indigo-950 font-semibold"
                        : "border-slate-200 text-slate-700 hover:bg-slate-50"
                    }`}
                  >
                    <input
                      type="radio"
                      name="scenario"
                      checked={scenario === "SUCCESS_PARTIAL"}
                      onChange={() => setScenario("SUCCESS_PARTIAL")}
                      className="mt-0.5 text-indigo-600"
                    />
                    <div>
                      <div>Partial Payment</div>
                      <div className="text-[11px] font-normal text-slate-500">Pays custom portion</div>
                    </div>
                  </label>

                  <label
                    className={`flex items-start gap-2 p-2.5 rounded-lg border cursor-pointer transition-all ${
                      scenario === "DECLINE_GENERIC"
                        ? "border-rose-500 bg-rose-50/50 text-rose-950 font-semibold"
                        : "border-slate-200 text-slate-700 hover:bg-slate-50"
                    }`}
                  >
                    <input
                      type="radio"
                      name="scenario"
                      checked={scenario === "DECLINE_GENERIC"}
                      onChange={() => setScenario("DECLINE_GENERIC")}
                      className="mt-0.5 text-rose-600"
                    />
                    <div>
                      <div>Card Declined</div>
                      <div className="text-[11px] font-normal text-slate-500">Simulates failure outcome</div>
                    </div>
                  </label>

                  <label
                    className={`flex items-start gap-2 p-2.5 rounded-lg border cursor-pointer transition-all ${
                      scenario === "CANCEL_USER"
                        ? "border-slate-500 bg-slate-100 text-slate-900 font-semibold"
                        : "border-slate-200 text-slate-700 hover:bg-slate-50"
                    }`}
                  >
                    <input
                      type="radio"
                      name="scenario"
                      checked={scenario === "CANCEL_USER"}
                      onChange={() => setScenario("CANCEL_USER")}
                      className="mt-0.5 text-slate-600"
                    />
                    <div>
                      <div>Cancel Checkout</div>
                      <div className="text-[11px] font-normal text-slate-500">Simulates user dropoff</div>
                    </div>
                  </label>
                </div>
              </div>

              {/* Partial Amount Input */}
              {scenario === "SUCCESS_PARTIAL" && (
                <div className="p-3 bg-amber-50/60 border border-amber-200 rounded-lg text-xs">
                  <label className="block font-semibold text-slate-800 mb-1">
                    Enter Partial Payment Amount ({session.currency}):
                  </label>
                  <input
                    type="number"
                    step="0.01"
                    min="1"
                    max={Number(session.balance_due)}
                    value={partialAmount}
                    onChange={(e) => setPartialAmount(e.target.value)}
                    className="w-full px-3 py-1.5 border border-slate-300 rounded bg-white font-mono font-bold text-slate-900 focus:ring-2 focus:ring-indigo-500 outline-none"
                  />
                  <div className="text-[11px] text-slate-500 mt-1">
                    Max: {formatCurrency(session.balance_due, session.currency)}
                  </div>
                </div>
              )}

              {processError && (
                <div className="p-2.5 bg-rose-50 border border-rose-200 rounded text-rose-800 text-xs">
                  {processError}
                </div>
              )}

              {/* Action Buttons */}
              <div className="flex justify-end gap-2 pt-2 border-t border-slate-100">
                <button
                  type="button"
                  onClick={onClose}
                  className="px-4 py-2 border border-slate-300 rounded-lg text-xs font-semibold text-slate-700 hover:bg-slate-50 transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="button"
                  disabled={isProcessing}
                  onClick={handleProcessPayment}
                  className="px-5 py-2 bg-indigo-600 hover:bg-indigo-700 disabled:opacity-50 text-white rounded-lg text-xs font-bold shadow-sm transition-all flex items-center gap-2"
                >
                  {isProcessing && <Loader2 className="h-4 w-4 animate-spin" />}
                  {isProcessing ? "Processing Simulation..." : "Simulate Gateway Authorization"}
                </button>
              </div>
            </div>
          ) : null}
        </div>
      </div>
    </div>
  );
};
