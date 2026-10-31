import React from "react";
import { Link } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { useAuth } from "@/hooks/useAuth";
import { subscriptionsApi } from "@/api/subscriptions";
import { invoicesApi } from "@/api/invoices";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { formatDate, formatCurrency } from "@/lib/utils";
import {
  CreditCard,
  FileText,
  ShieldCheck,
  CheckCircle2,
  Clock,
  ArrowRight,
  Loader2,
} from "lucide-react";

export const CustomerPortal: React.FC = () => {
  const { user } = useAuth();
  if (!user) return null;

  const { data: subsData, isLoading: isLoadingSubs } = useQuery({
    queryKey: ["customer-my-subscriptions"],
    queryFn: () => subscriptionsApi.listSubscriptions({ limit: 10 }),
  });

  const { data: invoicesData, isLoading: isLoadingInvoices } = useQuery({
    queryKey: ["customer-my-invoices"],
    queryFn: () => invoicesApi.listInvoices({ limit: 10 }),
  });

  return (
    <div className="space-y-6">
      {/* Welcome Banner */}
      <div className="rounded-xl border border-slate-200/90 bg-white p-6 shadow-xs flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <div className="flex items-center gap-2">
            <h1 className="text-xl font-bold text-slate-900">Welcome, {user.full_name}</h1>
            <Badge variant="success" className="gap-1">
              <CheckCircle2 className="w-3 h-3" />
              Verified Customer
            </Badge>
          </div>
          <p className="text-xs text-slate-500 mt-1">
            Account Email: <span className="font-mono text-slate-700">{user.email}</span> • Member since {formatDate(user.created_at)}
          </p>
        </div>
        <Link to="/profile">
          <Button variant="outline" size="sm" className="gap-1.5 self-start md:self-auto">
            <ShieldCheck className="w-4 h-4 text-slate-600" />
            Security & Profile
          </Button>
        </Link>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Active Subscriptions Card */}
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-3">
            <div>
              <CardTitle className="text-base font-semibold">Active Subscriptions</CardTitle>
              <CardDescription className="text-xs">
                Your software plans and billing cadences
              </CardDescription>
            </div>
            <CreditCard className="w-5 h-5 text-slate-400" />
          </CardHeader>
          <CardContent>
            {isLoadingSubs ? (
              <div className="py-8 text-center text-slate-400 text-xs">
                <Loader2 className="w-5 h-5 animate-spin mx-auto mb-1 text-blue-600" />
                Loading your subscriptions...
              </div>
            ) : subsData?.items.length === 0 ? (
              <div className="rounded-xl border border-dashed border-slate-200 bg-slate-50/50 p-8 text-center">
                <div className="mx-auto flex h-10 w-10 items-center justify-center rounded-full bg-slate-100 text-slate-500 mb-3">
                  <Clock className="w-5 h-5" />
                </div>
                <h4 className="text-sm font-semibold text-slate-800">No Active Subscriptions</h4>
                <p className="mt-1 text-xs text-slate-500 max-w-sm mx-auto leading-relaxed">
                  You do not have any active subscriptions yet. When a sales quotation is issued and accepted, your subscription plan and renewal details will appear here.
                </p>
              </div>
            ) : (
              <div className="divide-y divide-slate-100 text-xs">
                {subsData?.items.map((sub) => (
                  <div key={sub.id} className="py-3 flex items-center justify-between">
                    <div>
                      <span className="font-semibold text-slate-900 text-sm block">
                        {sub.plan?.name || "Subscription Plan"}
                      </span>
                      <span className="text-[11px] font-mono text-slate-400">
                        {sub.subscription_number} • {sub.billing_interval} ({sub.interval_count}x)
                      </span>
                    </div>
                    <div className="text-right flex items-center gap-3">
                      <div>
                        <span className="font-mono font-bold text-slate-900 block">
                          {formatCurrency(sub.total_amount, sub.currency)}
                        </span>
                        <Badge
                          variant={sub.status === "ACTIVE" ? "success" : "info"}
                          className="text-[9px] py-0 px-1.5"
                        >
                          {sub.status}
                        </Badge>
                      </div>
                      <Link to={`/subscriptions/${sub.id}`}>
                        <Button variant="ghost" size="sm" className="h-7 text-xs px-2">
                          <ArrowRight className="w-3.5 h-3.5" />
                        </Button>
                      </Link>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>

        {/* Invoices & Statements Card */}
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-3">
            <div>
              <CardTitle className="text-base font-semibold">Invoices & Statements</CardTitle>
              <CardDescription className="text-xs">
                Billing history and payment receipts
              </CardDescription>
            </div>
            <FileText className="w-5 h-5 text-slate-400" />
          </CardHeader>
          <CardContent>
            {isLoadingInvoices ? (
              <div className="py-8 text-center text-slate-400 text-xs">
                <Loader2 className="w-5 h-5 animate-spin mx-auto mb-1 text-blue-600" />
                Loading your invoices...
              </div>
            ) : invoicesData?.items.length === 0 ? (
              <div className="rounded-xl border border-dashed border-slate-200 bg-slate-50/50 p-8 text-center">
                <div className="mx-auto flex h-10 w-10 items-center justify-center rounded-full bg-slate-100 text-slate-500 mb-3">
                  <FileText className="w-5 h-5" />
                </div>
                <h4 className="text-sm font-semibold text-slate-800">No Invoices Issued</h4>
                <p className="mt-1 text-xs text-slate-500 max-w-sm mx-auto leading-relaxed">
                  No invoices have been billed to your account. As subscriptions renew, itemized statements with GST breakdowns will be available here.
                </p>
              </div>
            ) : (
              <div className="divide-y divide-slate-100 text-xs">
                {invoicesData?.items.map((inv) => (
                  <div key={inv.id} className="py-3 flex items-center justify-between">
                    <div>
                      <span className="font-mono font-bold text-slate-900 block">
                        {inv.invoice_number}
                      </span>
                      <span className="text-[11px] text-slate-400">
                        Due: {formatDate(inv.due_date)}
                      </span>
                    </div>
                    <div className="text-right flex items-center gap-3">
                      <div>
                        <span className="font-mono font-bold text-slate-900 block">
                          {formatCurrency(inv.total_amount, inv.currency)}
                        </span>
                        <Badge
                          variant={inv.payment_status === "PAID" ? "success" : "destructive"}
                          className="text-[9px] py-0 px-1.5"
                        >
                          {inv.payment_status}
                        </Badge>
                      </div>
                      <Link to={`/invoices/${inv.id}`}>
                        <Button variant="ghost" size="sm" className="h-7 text-xs px-2">
                          <ArrowRight className="w-3.5 h-3.5" />
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

      {/* Account Security Overview Card */}
      <Card>
        <CardHeader className="pb-3">
          <CardTitle className="text-base font-semibold">Account Protection Status</CardTitle>
          <CardDescription className="text-xs">
            Your credentials and session are protected by Brightloop Enterprise Identity standards.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-xs">
            <div className="rounded-lg border border-slate-100 bg-slate-50 p-3">
              <span className="font-semibold text-slate-800 block">Password Encryption</span>
              <span className="text-slate-500 text-[11px] mt-0.5 block">Argon2id (Memory-hard key derivation)</span>
            </div>
            <div className="rounded-lg border border-slate-100 bg-slate-50 p-3">
              <span className="font-semibold text-slate-800 block">Session Integrity</span>
              <span className="text-slate-500 text-[11px] mt-0.5 block">Rotated JWT access & refresh tokens</span>
            </div>
            <div className="rounded-lg border border-slate-100 bg-slate-50 p-3">
              <span className="font-semibold text-slate-800 block">Audit Tracking</span>
              <span className="text-slate-500 text-[11px] mt-0.5 block">All account access events are securely audited</span>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};
