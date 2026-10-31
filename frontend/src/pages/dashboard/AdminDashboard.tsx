import React, { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { healthApi } from "@/api/health";
import { dashboardApi } from "@/api/dashboard";
import { DashboardMetrics, HealthCheckResponse } from "@/types";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { formatDate, formatCurrency } from "@/lib/utils";
import {
  ResponsiveContainer,
  AreaChart,
  Area,
  XAxis,
  YAxis,
  Tooltip,
  CartesianGrid,
} from "recharts";
import {
  Users,
  CreditCard,
  FileText,
  IndianRupee,
  ArrowRight,
  TrendingUp,
  AlertTriangle,
  Loader2,
} from "lucide-react";

export const AdminDashboard: React.FC = () => {
  const [health, setHealth] = useState<HealthCheckResponse | null>(null);
  const [metrics, setMetrics] = useState<DashboardMetrics | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [h, m] = await Promise.all([
          healthApi.check(),
          dashboardApi.getMetrics(),
        ]);
        setHealth(h);
        setMetrics(m);
      } catch (err) {
        console.error("Failed to load admin dashboard telemetry", err);
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();
  }, []);

  const chartData = metrics?.revenue_trend.map((pt) => ({
    name: pt.period,
    revenue: parseFloat(pt.revenue) || 0,
    count: pt.payments_count,
  })) || [];

  return (
    <div className="space-y-6">
      {/* Header Banner */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">
            Executive Financial & Operations Overview
          </h1>
          <p className="text-sm text-slate-500 mt-1">
            Real-time business performance calculated directly from PostgreSQL ledgers.
          </p>
        </div>

        <div className="flex items-center gap-2">
          {health?.status === "healthy" ? (
            <Badge variant="success" className="gap-1.5 py-1 px-2.5">
              <span className="h-2 w-2 rounded-full bg-emerald-500 animate-pulse" />
              Engine Online • DB & Redis Connected
            </Badge>
          ) : (
            <Badge variant="destructive" className="gap-1.5 py-1 px-2.5">
              Service Degraded
            </Badge>
          )}
        </div>
      </div>

      {/* KPI Financial Metric Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Total Revenue */}
        <Card className="hover:shadow-xs transition-shadow">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <span className="text-xs font-semibold text-slate-500 uppercase tracking-wider">
              Revenue Collected
            </span>
            <div className="p-2 bg-emerald-50 text-emerald-700 rounded-lg">
              <IndianRupee className="w-4 h-4" />
            </div>
          </CardHeader>
          <CardContent>
            {isLoading ? (
              <Loader2 className="w-5 h-5 animate-spin text-slate-400" />
            ) : (
              <div>
                <span className="text-2xl font-bold font-mono text-slate-900">
                  {formatCurrency(metrics?.revenue_collected || "0", metrics?.currency || "INR")}
                </span>
                <p className="text-xs text-emerald-600 flex items-center gap-1 mt-1 font-medium">
                  <TrendingUp className="w-3.5 h-3.5" />
                  Settled into bank accounts
                </p>
              </div>
            )}
          </CardContent>
        </Card>

        {/* Active Subscriptions */}
        <Card className="hover:shadow-xs transition-shadow">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <span className="text-xs font-semibold text-slate-500 uppercase tracking-wider">
              Active Subscriptions
            </span>
            <div className="p-2 bg-blue-50 text-blue-700 rounded-lg">
              <CreditCard className="w-4 h-4" />
            </div>
          </CardHeader>
          <CardContent>
            {isLoading ? (
              <Loader2 className="w-5 h-5 animate-spin text-slate-400" />
            ) : (
              <div>
                <span className="text-2xl font-bold font-mono text-slate-900">
                  {metrics?.active_subscriptions || 0}
                </span>
                <p className="text-xs text-slate-500 mt-1">
                  Recurring active agreements
                </p>
              </div>
            )}
          </CardContent>
        </Card>

        {/* Total Customers */}
        <Card className="hover:shadow-xs transition-shadow">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <span className="text-xs font-semibold text-slate-500 uppercase tracking-wider">
              Customer Accounts
            </span>
            <div className="p-2 bg-purple-50 text-purple-700 rounded-lg">
              <Users className="w-4 h-4" />
            </div>
          </CardHeader>
          <CardContent>
            {isLoading ? (
              <Loader2 className="w-5 h-5 animate-spin text-slate-400" />
            ) : (
              <div>
                <span className="text-2xl font-bold font-mono text-slate-900">
                  {metrics?.total_customers || 0}
                </span>
                <p className="text-xs text-slate-500 mt-1">
                  Registered enterprise clients
                </p>
              </div>
            )}
          </CardContent>
        </Card>

        {/* Outstanding Receivables */}
        <Card className="hover:shadow-xs transition-shadow">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <span className="text-xs font-semibold text-slate-500 uppercase tracking-wider">
              Outstanding Invoices
            </span>
            <div className="p-2 bg-amber-50 text-amber-700 rounded-lg">
              <FileText className="w-4 h-4" />
            </div>
          </CardHeader>
          <CardContent>
            {isLoading ? (
              <Loader2 className="w-5 h-5 animate-spin text-slate-400" />
            ) : (
              <div>
                <span className="text-2xl font-bold font-mono text-slate-900">
                  {formatCurrency(metrics?.outstanding_invoice_amount || "0", metrics?.currency || "INR")}
                </span>
                {metrics && metrics.overdue_invoices > 0 ? (
                  <p className="text-xs text-red-600 flex items-center gap-1 mt-1 font-semibold">
                    <AlertTriangle className="w-3.5 h-3.5" />
                    {metrics.overdue_invoices} overdue invoices
                  </p>
                ) : (
                  <p className="text-xs text-slate-400 mt-1">Zero overdue receivables</p>
                )}
              </div>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Revenue Trend Chart */}
      <Card>
        <CardHeader className="flex flex-row items-center justify-between pb-2">
          <div>
            <CardTitle className="text-base font-bold text-slate-900">
              Monthly Revenue Trajectory
            </CardTitle>
            <CardDescription className="text-xs">
              Aggregate collection trend grouped by month from recorded payment receipts.
            </CardDescription>
          </div>
          <Link to="/invoices">
            <Button variant="ghost" size="sm" className="gap-1 text-xs">
              Billing Ledger <ArrowRight className="w-3 h-3" />
            </Button>
          </Link>
        </CardHeader>
        <CardContent>
          {chartData.length === 0 ? (
            <div className="h-64 flex flex-col items-center justify-center text-slate-400 text-xs border border-dashed border-slate-200 rounded-lg">
              <TrendingUp className="w-8 h-8 text-slate-300 mb-2" />
              <span>No revenue data points recorded yet.</span>
              <span className="text-[11px] text-slate-400 mt-0.5">
                Payments recorded against confirmed invoices will populate this trend graph.
              </span>
            </div>
          ) : (
            <div className="h-64 w-full pt-4">
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={chartData} margin={{ top: 10, right: 10, left: 0, bottom: 0 }}>
                  <defs>
                    <linearGradient id="colorRev" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#2563eb" stopOpacity={0.25} />
                      <stop offset="95%" stopColor="#2563eb" stopOpacity={0.0} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                  <XAxis dataKey="name" tick={{ fontSize: 11, fill: "#64748b" }} axisLine={false} tickLine={false} />
                  <YAxis
                    tick={{ fontSize: 11, fill: "#64748b" }}
                    axisLine={false}
                    tickLine={false}
                    tickFormatter={(v) => `₹${v}`}
                  />
                  <Tooltip
                    contentStyle={{
                      backgroundColor: "#0f172a",
                      borderRadius: "8px",
                      border: "none",
                      color: "#fff",
                      fontSize: "12px",
                    }}
                    formatter={(val: any) => [`₹${val}`, "Revenue"]}
                  />
                  <Area
                    type="monotone"
                    dataKey="revenue"
                    stroke="#2563eb"
                    strokeWidth={2.5}
                    fillOpacity={1}
                    fill="url(#colorRev)"
                  />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Two Column Grid: Recent Payments & Recent Subscriptions */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recent Payments */}
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-3">
            <div>
              <CardTitle className="text-base font-semibold text-slate-800">
                Recent Payment Settlements
              </CardTitle>
              <CardDescription className="text-xs">
                Latest cleared customer payments
              </CardDescription>
            </div>
            <Link to="/invoices">
              <Button variant="ghost" size="sm" className="h-7 text-xs px-2">
                View Invoices
              </Button>
            </Link>
          </CardHeader>
          <CardContent>
            {isLoading ? (
              <p className="text-xs text-slate-400 py-6 text-center">Loading transactions...</p>
            ) : metrics?.recent_payments.length === 0 ? (
              <p className="text-xs text-slate-400 py-6 text-center italic">
                No payments recorded yet.
              </p>
            ) : (
              <div className="divide-y divide-slate-100 text-xs">
                {metrics?.recent_payments.map((p) => (
                  <div key={p.id} className="py-2.5 flex items-center justify-between">
                    <div>
                      <span className="font-semibold text-slate-900 block">{p.customer_name}</span>
                      <span className="text-[11px] font-mono text-slate-400">
                        {p.payment_number} • {p.payment_method}
                      </span>
                    </div>
                    <div className="text-right">
                      <span className="font-mono font-bold text-emerald-600 block">
                        +{formatCurrency(p.amount, p.currency)}
                      </span>
                      <span className="text-[10px] text-slate-400">
                        {formatDate(p.payment_date)}
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>

        {/* Recent Subscriptions */}
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-3">
            <div>
              <CardTitle className="text-base font-semibold text-slate-800">
                Recent Subscriptions
              </CardTitle>
              <CardDescription className="text-xs">
                Latest customer contracts initiated
              </CardDescription>
            </div>
            <Link to="/subscriptions">
              <Button variant="ghost" size="sm" className="h-7 text-xs px-2">
                All Contracts
              </Button>
            </Link>
          </CardHeader>
          <CardContent>
            {isLoading ? (
              <p className="text-xs text-slate-400 py-6 text-center">Loading subscriptions...</p>
            ) : metrics?.recent_subscriptions.length === 0 ? (
              <p className="text-xs text-slate-400 py-6 text-center italic">
                No subscriptions created yet.
              </p>
            ) : (
              <div className="divide-y divide-slate-100 text-xs">
                {metrics?.recent_subscriptions.map((s) => (
                  <div key={s.id} className="py-2.5 flex items-center justify-between">
                    <div>
                      <span className="font-semibold text-slate-900 block">{s.customer_name}</span>
                      <span className="text-[11px] text-slate-500">
                        {s.plan_name} • <span className="font-mono">{s.subscription_number}</span>
                      </span>
                    </div>
                    <div className="text-right">
                      <span className="font-mono font-semibold text-slate-900 block">
                        {formatCurrency(s.total_amount, s.currency)}
                      </span>
                      <Badge variant={s.status === "ACTIVE" ? "success" : "info"} className="text-[9px] py-0 px-1.5">
                        {s.status}
                      </Badge>
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
