import React from "react";
import { useParams, Link, useNavigate } from "react-router-dom";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { subscriptionsApi } from "@/api/subscriptions";
import { invoicesApi } from "@/api/invoices";
import { useAuth } from "@/hooks/useAuth";
import { SubscriptionStatus } from "@/types";
import { useToast } from "@/components/ui/toast";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { formatDate, formatCurrency } from "@/lib/utils";
import {
  FileText,
  Loader2,
  ArrowLeft,
  Send,
  Check,
  Play,
  XCircle,
  PlusCircle,
  History,
} from "lucide-react";

export const SubscriptionDetailsPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { user } = useAuth();
  const { success, error } = useToast();
  const queryClient = useQueryClient();
  const isOperator = user?.role === "ADMIN" || user?.role === "STAFF";

  const { data: subscription, isLoading } = useQuery({
    queryKey: ["subscription", id],
    queryFn: () => {
      if (!id) throw new Error("Missing ID");
      return subscriptionsApi.getSubscription(id);
    },
    enabled: !!id,
  });

  const { data: invoicesData, isLoading: isLoadingInvoices } = useQuery({
    queryKey: ["subscription-invoices", id],
    queryFn: () => invoicesApi.listInvoices({ subscription_id: id }),
    enabled: !!id,
  });

  const transitionMutation = useMutation({
    mutationFn: ({ toStatus, reason }: { toStatus: SubscriptionStatus; reason?: string }) => {
      if (!id) throw new Error("Missing ID");
      return subscriptionsApi.transitionStatus(id, toStatus, reason);
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ["subscription", id] });
      queryClient.invalidateQueries({ queryKey: ["subscriptions"] });
      queryClient.invalidateQueries({ queryKey: ["dashboard-metrics"] });
      success(`Subscription moved to ${data.status}.`, "Status Transitioned");
    },
    onError: (err: any) => {
      error(err.response?.data?.detail || "Failed to update lifecycle state.", "Transition Failed");
    },
  });

  const generateInvoiceMutation = useMutation({
    mutationFn: () => {
      if (!id) throw new Error("Missing ID");
      return invoicesApi.createInvoice({ subscription_id: id });
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ["subscription-invoices", id] });
      queryClient.invalidateQueries({ queryKey: ["invoices"] });
      queryClient.invalidateQueries({ queryKey: ["dashboard-metrics"] });
      success(`Generated invoice ${data.invoice_number}`, "Invoice Created");
      navigate(`/invoices/${data.id}`);
    },
    onError: (err: any) => {
      error(err.response?.data?.detail || "Failed to generate invoice.", "Invoicing Failed");
    },
  });

  const pauseMutation = useMutation({
    mutationFn: (reason?: string) => {
      if (!id) throw new Error("Missing ID");
      return subscriptionsApi.pauseSubscription(id, reason || "Paused by operator");
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["subscription", id] });
      queryClient.invalidateQueries({ queryKey: ["subscriptions"] });
      success("Subscription has been PAUSED. Billing suspended.", "Subscription Paused");
    },
    onError: (err: any) => {
      error(err.response?.data?.detail || "Failed to pause subscription.", "Action Failed");
    },
  });

  const resumeMutation = useMutation({
    mutationFn: () => {
      if (!id) throw new Error("Missing ID");
      return subscriptionsApi.resumeSubscription(id);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["subscription", id] });
      queryClient.invalidateQueries({ queryKey: ["subscriptions"] });
      success("Subscription RESUMED. Billing timeline forward-shifted.", "Subscription Resumed");
    },
    onError: (err: any) => {
      error(err.response?.data?.detail || "Failed to resume subscription.", "Action Failed");
    },
  });

  const renewMutation = useMutation({
    mutationFn: () => {
      if (!id) throw new Error("Missing ID");
      return subscriptionsApi.renewSubscription(id);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["subscription", id] });
      queryClient.invalidateQueries({ queryKey: ["subscriptions"] });
      success("Subscription RENEWED for next billing interval.", "Subscription Renewed");
    },
    onError: (err: any) => {
      error(err.response?.data?.detail || "Failed to renew subscription.", "Action Failed");
    },
  });

  if (isLoading) {
    return (
      <div className="py-24 text-center">
        <Loader2 className="w-8 h-8 animate-spin mx-auto text-blue-600 mb-3" />
        <p className="text-sm text-slate-500">Loading subscription details...</p>
      </div>
    );
  }

  if (!subscription) {
    return (
      <div className="py-12 text-center space-y-4">
        <h2 className="text-lg font-bold text-slate-800">Subscription not found</h2>
        <Link to="/subscriptions">
          <Button variant="outline" className="gap-2">
            <ArrowLeft className="w-4 h-4" />
            Back to Subscriptions
          </Button>
        </Link>
      </div>
    );
  }

  const getStatusBadge = (status: SubscriptionStatus) => {
    switch (status) {
      case "ACTIVE":
        return <Badge variant="success">ACTIVE</Badge>;
      case "PAUSED":
        return <Badge variant="warning">PAUSED</Badge>;
      case "CONFIRMED":
        return <Badge variant="info">CONFIRMED</Badge>;
      case "QUOTATION":
        return <Badge variant="warning">QUOTATION</Badge>;
      case "DRAFT":
        return <Badge variant="neutral">DRAFT</Badge>;
      case "CLOSED":
        return <Badge variant="destructive">CLOSED</Badge>;
      default:
        return <Badge variant="neutral">{status}</Badge>;
    }
  };

  const stages: SubscriptionStatus[] = ["DRAFT", "QUOTATION", "CONFIRMED", "ACTIVE", "PAUSED", "CLOSED"];
  const currentStageIndex = stages.indexOf(subscription.status);

  return (
    <div className="space-y-6">
      {/* Top Bar */}
      <div className="flex items-center justify-between">
        <Link to="/subscriptions">
          <Button variant="ghost" size="sm" className="gap-1.5 text-slate-600">
            <ArrowLeft className="w-4 h-4" />
            Back to Registry
          </Button>
        </Link>
        <span className="text-xs text-slate-400 font-mono">
          ID: {subscription.id}
        </span>
      </div>

      {/* Main Header Banner */}
      <Card>
        <CardContent className="p-6">
          <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
            <div>
              <div className="flex items-center gap-2.5">
                <h1 className="text-2xl font-bold tracking-tight text-slate-900">
                  {subscription.subscription_number}
                </h1>
                {getStatusBadge(subscription.status)}
              </div>
              <p className="text-sm text-slate-600 mt-1">
                Plan: <span className="font-semibold text-slate-800">{subscription.plan?.name}</span> •{" "}
                Cadence: {subscription.billing_interval} ({subscription.interval_count}x) •{" "}
                Terms: {subscription.payment_terms}
              </p>
            </div>

            {/* Operator Lifecycle Controls */}
            {isOperator && (
              <div className="flex flex-wrap items-center gap-2">
                {subscription.status === "DRAFT" && (
                  <>
                    <Button
                      size="sm"
                      onClick={() =>
                        transitionMutation.mutate({
                          toStatus: "QUOTATION",
                          reason: "Quotation generated for customer approval",
                        })
                      }
                      disabled={transitionMutation.isPending}
                      className="gap-1.5 bg-blue-600 hover:bg-blue-700"
                    >
                      <Send className="w-4 h-4" />
                      Send Quotation
                    </Button>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() =>
                        transitionMutation.mutate({
                          toStatus: "CLOSED",
                          reason: "Cancelled in draft stage",
                        })
                      }
                      disabled={transitionMutation.isPending}
                      className="text-red-600 hover:text-red-700 hover:bg-red-50"
                    >
                      <XCircle className="w-4 h-4" />
                      Cancel
                    </Button>
                  </>
                )}

                {subscription.status === "QUOTATION" && (
                  <>
                    <Button
                      size="sm"
                      onClick={() =>
                        transitionMutation.mutate({
                          toStatus: "CONFIRMED",
                          reason: "Quotation approved by customer",
                        })
                      }
                      disabled={transitionMutation.isPending}
                      className="gap-1.5 bg-emerald-600 hover:bg-emerald-700"
                    >
                      <Check className="w-4 h-4" />
                      Confirm Contract
                    </Button>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() =>
                        transitionMutation.mutate({
                          toStatus: "DRAFT",
                          reason: "Revised back to draft for renegotiation",
                        })
                      }
                      disabled={transitionMutation.isPending}
                    >
                      Revise Draft
                    </Button>
                  </>
                )}

                {subscription.status === "CONFIRMED" && (
                  <>
                    <Button
                      size="sm"
                      onClick={() =>
                        transitionMutation.mutate({
                          toStatus: "ACTIVE",
                          reason: "Service activated by operator",
                        })
                      }
                      disabled={transitionMutation.isPending}
                      className="gap-1.5 bg-blue-600 hover:bg-blue-700"
                    >
                      <Play className="w-4 h-4" />
                      Activate Now
                    </Button>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => generateInvoiceMutation.mutate()}
                      disabled={generateInvoiceMutation.isPending}
                      className="gap-1.5"
                    >
                      {generateInvoiceMutation.isPending ? (
                        <Loader2 className="w-4 h-4 animate-spin" />
                      ) : (
                        <FileText className="w-4 h-4 text-blue-600" />
                      )}
                      Generate Invoice
                    </Button>
                  </>
                )}

                {subscription.status === "ACTIVE" && (
                  <>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => generateInvoiceMutation.mutate()}
                      disabled={generateInvoiceMutation.isPending}
                      className="gap-1.5"
                    >
                      {generateInvoiceMutation.isPending ? (
                        <Loader2 className="w-4 h-4 animate-spin" />
                      ) : (
                        <PlusCircle className="w-4 h-4 text-blue-600" />
                      )}
                      Issue Invoice
                    </Button>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => pauseMutation.mutate("Paused via operator control")}
                      disabled={pauseMutation.isPending}
                      className="gap-1.5 text-amber-600 border-amber-300 hover:bg-amber-50"
                    >
                      Pause
                    </Button>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => renewMutation.mutate()}
                      disabled={renewMutation.isPending}
                      className="gap-1.5 text-indigo-600 border-indigo-300 hover:bg-indigo-50"
                    >
                      Renew Cycle
                    </Button>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() =>
                        transitionMutation.mutate({
                          toStatus: "CLOSED",
                          reason: "Contract ended or non-renewed",
                        })
                      }
                      disabled={transitionMutation.isPending}
                      className="text-red-600 hover:text-red-700 hover:bg-red-50"
                    >
                      <XCircle className="w-4 h-4" />
                      Close
                    </Button>
                  </>
                )}

                {subscription.status === "PAUSED" && (
                  <>
                    <Button
                      size="sm"
                      onClick={() => resumeMutation.mutate()}
                      disabled={resumeMutation.isPending}
                      className="gap-1.5 bg-emerald-600 hover:bg-emerald-700 font-bold"
                    >
                      <Play className="w-4 h-4" />
                      Resume Subscription
                    </Button>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() =>
                        transitionMutation.mutate({
                          toStatus: "CLOSED",
                          reason: "Terminated while paused",
                        })
                      }
                      disabled={transitionMutation.isPending}
                      className="text-red-600 hover:text-red-700 hover:bg-red-50"
                    >
                      <XCircle className="w-4 h-4" />
                      Close
                    </Button>
                  </>
                )}

                {subscription.status === "CLOSED" && (
                  <Button
                    size="sm"
                    onClick={() => renewMutation.mutate()}
                    disabled={renewMutation.isPending}
                    className="gap-1.5 bg-indigo-600 hover:bg-indigo-700 font-bold"
                  >
                    <PlusCircle className="w-4 h-4" />
                    Renew / Re-activate
                  </Button>
                )}
              </div>
            )}
          </div>

          {/* Stepper Progress Bar */}
          <div className="mt-8 pt-6 border-t border-slate-100">
            <div className="grid grid-cols-5 gap-2">
              {stages.map((stage, idx) => {
                const isPassed = idx <= currentStageIndex && subscription.status !== "CLOSED";
                const isCurrent = stage === subscription.status;
                return (
                  <div key={stage} className="text-center">
                    <div
                      className={`h-2 rounded-full mb-2 transition-all ${
                        isCurrent
                          ? "bg-blue-600 shadow-xs"
                          : isPassed
                          ? "bg-blue-400"
                          : "bg-slate-200"
                      }`}
                    />
                    <span
                      className={`text-[11px] font-semibold tracking-wider uppercase block ${
                        isCurrent ? "text-blue-700 font-bold" : "text-slate-400"
                      }`}
                    >
                      {stage}
                    </span>
                  </div>
                );
              })}
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Customer & Period Information */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card className="md:col-span-1">
          <CardHeader className="pb-3">
            <CardTitle className="text-base font-semibold text-slate-800">Customer Account</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3 text-xs">
            {subscription.customer ? (
              <>
                <div>
                  <span className="text-slate-400 block font-medium">Name</span>
                  <Link
                    to={`/customers/${subscription.customer.id}`}
                    className="font-bold text-slate-900 text-sm hover:text-blue-600 transition-colors"
                  >
                    {subscription.customer.name}
                  </Link>
                </div>
                {subscription.customer.company_name && (
                  <div>
                    <span className="text-slate-400 block font-medium">Organization</span>
                    <span className="text-slate-700">{subscription.customer.company_name}</span>
                  </div>
                )}
                <div>
                  <span className="text-slate-400 block font-medium">Email Address</span>
                  <span className="text-slate-700 font-mono">{subscription.customer.email}</span>
                </div>
                <div>
                  <span className="text-slate-400 block font-medium">Billing Location</span>
                  <span className="text-slate-700">
                    {subscription.customer.billing_city || "City not set"},{" "}
                    {subscription.customer.billing_country}
                  </span>
                </div>
              </>
            ) : (
              <p className="text-slate-400 italic">No customer attached</p>
            )}
          </CardContent>
        </Card>

        <Card className="md:col-span-2">
          <CardHeader className="pb-3">
            <CardTitle className="text-base font-semibold text-slate-800">Contract Schedule</CardTitle>
          </CardHeader>
          <CardContent className="grid grid-cols-2 sm:grid-cols-3 gap-4 text-xs">
            <div>
              <span className="text-slate-400 block font-medium">Start Date</span>
              <span className="font-semibold text-slate-900 text-sm">
                {formatDate(subscription.start_date)}
              </span>
            </div>
            <div>
              <span className="text-slate-400 block font-medium">Scheduled Expiry</span>
              <span className="font-semibold text-slate-900 text-sm">
                {subscription.expiry_date ? formatDate(subscription.expiry_date) : "Open-ended"}
              </span>
            </div>
            <div>
              <span className="text-slate-400 block font-medium">Payment Cadence</span>
              <span className="font-semibold text-slate-900 text-sm">
                Every {subscription.interval_count} {subscription.billing_interval.toLowerCase()}
              </span>
            </div>
            <div className="col-span-2 sm:col-span-3 pt-3 border-t border-slate-100">
              <span className="text-slate-400 block font-medium mb-1">Contract Notes</span>
              <p className="text-slate-700 bg-slate-50 p-2.5 rounded-lg border border-slate-100 font-mono text-[11px]">
                {subscription.notes || "No special terms or notes recorded."}
              </p>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Itemized Line Items & Financial Calculation */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2">
          <Card>
            <CardHeader className="pb-3">
              <CardTitle className="text-base font-semibold text-slate-800">
                Itemized Plan Inclusions
              </CardTitle>
            </CardHeader>
            <div className="overflow-x-auto">
              <table className="w-full text-left text-sm text-slate-600">
                <thead className="bg-slate-50 border-b border-slate-200/80 text-xs uppercase font-semibold text-slate-500">
                  <tr>
                    <th className="py-2.5 px-4">Product / Item</th>
                    <th className="py-2.5 px-4">Qty</th>
                    <th className="py-2.5 px-4">Unit Price</th>
                    <th className="py-2.5 px-4 text-right">Line Total</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {subscription.items.map((item) => (
                    <tr key={item.id} className="text-xs">
                      <td className="py-3 px-4">
                        <span className="font-semibold text-slate-900 block">
                          {item.product?.name || "Product"}
                        </span>
                        {item.variant && (
                          <span className="text-slate-400 font-mono text-[11px]">
                            Variant: {item.variant.variant_name} ({item.variant.variant_code})
                          </span>
                        )}
                      </td>
                      <td className="py-3 px-4 font-mono">{item.quantity}</td>
                      <td className="py-3 px-4 font-mono">
                        {formatCurrency(item.unit_price, subscription.currency)}
                      </td>
                      <td className="py-3 px-4 font-mono font-semibold text-slate-900 text-right">
                        {formatCurrency(item.subtotal, subscription.currency)}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </Card>
        </div>

        {/* Financial Breakdown Card */}
        <div className="lg:col-span-1">
          <Card>
            <CardHeader className="pb-3">
              <CardTitle className="text-base font-semibold text-slate-800">Financial Summary</CardTitle>
            </CardHeader>
            <CardContent className="space-y-3 text-xs">
              <div className="flex justify-between py-1 border-b border-slate-100 text-slate-600">
                <span>Subtotal</span>
                <span className="font-mono font-medium">
                  {formatCurrency(subscription.subtotal, subscription.currency)}
                </span>
              </div>
              <div className="flex justify-between py-1 border-b border-slate-100 text-slate-600">
                <span>Discount Applied</span>
                <span className="font-mono text-emerald-600 font-medium">
                  -{formatCurrency(subscription.discount_amount, subscription.currency)}
                </span>
              </div>
              <div className="flex justify-between py-1 border-b border-slate-100 text-slate-600">
                <span>GST Tax ({subscription.tax_rate}%)</span>
                <span className="font-mono font-medium">
                  +{formatCurrency(subscription.tax_amount, subscription.currency)}
                </span>
              </div>
              <div className="flex justify-between py-2 border-t-2 border-slate-200 text-sm font-bold text-slate-900">
                <span>Total Amount</span>
                <span className="font-mono text-base text-blue-700">
                  {formatCurrency(subscription.total_amount, subscription.currency)}
                </span>
              </div>
              <p className="text-[11px] text-slate-400 italic text-center pt-2">
                All calculations computed server-side with strict Decimal precision.
              </p>
            </CardContent>
          </Card>
        </div>
      </div>

      {/* Lifecycle Audit History & Invoices */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Status History Timeline */}
        <Card>
          <CardHeader className="pb-3 flex flex-row items-center justify-between">
            <CardTitle className="text-base font-semibold text-slate-800">Lifecycle Audit Ledger</CardTitle>
            <History className="w-4 h-4 text-slate-400" />
          </CardHeader>
          <CardContent className="space-y-3">
            {subscription.status_history?.length === 0 ? (
              <p className="text-xs text-slate-400 italic">No lifecycle entries recorded.</p>
            ) : (
              subscription.status_history?.map((h) => (
                <div key={h.id} className="flex items-start gap-3 text-xs border-l-2 border-blue-200 pl-3 py-1">
                  <div className="space-y-0.5">
                    <div className="flex items-center gap-2">
                      <span className="font-bold text-slate-800 uppercase tracking-wide">
                        {h.to_status}
                      </span>
                      {h.from_status && (
                        <span className="text-[10px] text-slate-400">
                          (from {h.from_status})
                        </span>
                      )}
                    </div>
                    <p className="text-slate-600">{h.reason}</p>
                    <span className="text-[10px] text-slate-400 font-mono block">
                      {formatDate(h.created_at)}
                    </span>
                  </div>
                </div>
              ))
            )}
          </CardContent>
        </Card>

        {/* Linked Invoices */}
        <Card>
          <CardHeader className="pb-3 flex flex-row items-center justify-between">
            <CardTitle className="text-base font-semibold text-slate-800">Generated Invoices</CardTitle>
            <FileText className="w-4 h-4 text-slate-400" />
          </CardHeader>
          <CardContent>
            {isLoadingInvoices ? (
              <p className="text-xs text-slate-400 py-4 text-center">Loading invoices...</p>
            ) : invoicesData?.items.length === 0 ? (
              <div className="text-center py-6 text-slate-400 text-xs">
                <FileText className="w-6 h-6 mx-auto mb-1 text-slate-300" />
                No invoices generated for this subscription yet.
              </div>
            ) : (
              <div className="space-y-2">
                {invoicesData?.items.map((inv) => (
                  <div
                    key={inv.id}
                    className="flex items-center justify-between p-3 rounded-lg border border-slate-100 bg-slate-50/50 hover:bg-slate-100/60 transition-colors text-xs"
                  >
                    <div>
                      <span className="font-mono font-bold text-slate-900 block">
                        {inv.invoice_number}
                      </span>
                      <span className="text-slate-500">
                        Due: {formatDate(inv.due_date)} • {inv.status}
                      </span>
                    </div>
                    <div className="flex items-center gap-3">
                      <div className="text-right">
                        <span className="font-mono font-bold text-slate-900 block">
                          {formatCurrency(inv.total_amount, inv.currency)}
                        </span>
                        <span className="text-[11px] font-mono text-slate-500">
                          Bal: {formatCurrency(inv.balance_due, inv.currency)}
                        </span>
                      </div>
                      <Link to={`/invoices/${inv.id}`}>
                        <Button variant="ghost" size="sm" className="h-7 text-xs px-2">
                          View
                        </Button>
                      </Link>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
};
