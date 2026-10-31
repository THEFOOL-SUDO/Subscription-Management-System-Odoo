import React, { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { useAuth } from "@/hooks/useAuth";
import { dashboardApi } from "@/api/dashboard";
import { customersApi } from "@/api/customers";
import { Customer, DashboardMetrics } from "@/types";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { formatCurrency } from "@/lib/utils";
import {
  Users,
  CreditCard,
  FileText,
  IndianRupee,
  ShieldAlert,
  Plus,
  Loader2,
  AlertTriangle,
} from "lucide-react";

export const StaffDashboard: React.FC = () => {
  const { user } = useAuth();
  const [metrics, setMetrics] = useState<DashboardMetrics | null>(null);
  const [recentCustomers, setRecentCustomers] = useState<Customer[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchTelemetry = async () => {
      try {
        const [m, c] = await Promise.all([
          dashboardApi.getMetrics(),
          customersApi.listCustomers({ limit: 5 }),
        ]);
        setMetrics(m);
        setRecentCustomers(c.items);
      } catch (err) {
        console.error("Failed to load staff operations telemetry", err);
      } finally {
        setIsLoading(false);
      }
    };
    fetchTelemetry();
  }, []);

  return (
    <div className="space-y-6">
      {/* Header Banner */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4 border-b border-slate-200/80 pb-5">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">
            Operations Console
          </h1>
          <p className="text-xs text-slate-500 mt-1">
            Welcome back, {user?.full_name}. Real-time subscription lifecycle and billing management.
          </p>
        </div>
        <div className="flex items-center gap-2">
          <Link to="/customers">
            <Button size="sm" className="gap-1.5">
              <Plus className="w-4 h-4" />
              Customer Accounts
            </Button>
          </Link>
          <Link to="/audit-logs">
            <Button size="sm" variant="outline" className="gap-1.5">
              <ShieldAlert className="w-4 h-4 text-slate-600" />
              Audit Trail
            </Button>
          </Link>
        </div>
      </div>

      {/* Operational KPI Metric Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <Card>
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
                <p className="text-xs text-slate-500 mt-1">Contracts in service</p>
              </div>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <span className="text-xs font-semibold text-slate-500 uppercase tracking-wider">
              Total Customers
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
                <p className="text-xs text-slate-500 mt-1">Registered clients</p>
              </div>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <span className="text-xs font-semibold text-slate-500 uppercase tracking-wider">
              Collections Settled
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
                <p className="text-xs text-slate-500 mt-1">Cleared in bank</p>
              </div>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <span className="text-xs font-semibold text-slate-500 uppercase tracking-wider">
              Pending Invoices
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
                    {metrics.overdue_invoices} overdue
                  </p>
                ) : (
                  <p className="text-xs text-slate-400 mt-1">All dues within terms</p>
                )}
              </div>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Operations Quick Queues */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recent Customers Queue */}
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-3">
            <div>
              <CardTitle className="text-base font-semibold text-slate-800">
                Recent Customer Accounts
              </CardTitle>
              <CardDescription className="text-xs">
                Newly provisioned enterprise accounts
              </CardDescription>
            </div>
            <Link to="/customers">
              <Button variant="ghost" size="sm" className="h-7 text-xs px-2">
                All Customers
              </Button>
            </Link>
          </CardHeader>
          <CardContent>
            {isLoading ? (
              <p className="text-xs text-slate-400 py-6 text-center">Loading customers...</p>
            ) : recentCustomers.length === 0 ? (
              <p className="text-xs text-slate-400 py-6 text-center italic">
                No customer accounts found.
              </p>
            ) : (
              <div className="divide-y divide-slate-100 text-xs">
                {recentCustomers.map((c) => (
                  <div key={c.id} className="py-2.5 flex items-center justify-between">
                    <div>
                      <span className="font-semibold text-slate-900 block">{c.name}</span>
                      <span className="text-[11px] text-slate-400 font-mono">
                        {c.customer_number} • {c.email}
                      </span>
                    </div>
                    <Link to={`/customers/${c.id}`}>
                      <Button variant="ghost" size="sm" className="h-7 text-xs px-2">
                        View
                      </Button>
                    </Link>
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
                Customer lifecycle states
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
                No contracts initiated yet.
              </p>
            ) : (
              <div className="divide-y divide-slate-100 text-xs">
                {metrics?.recent_subscriptions.map((s) => (
                  <div key={s.id} className="py-2.5 flex items-center justify-between">
                    <div>
                      <span className="font-semibold text-slate-900 block">{s.customer_name}</span>
                      <span className="text-[11px] text-slate-400 font-mono">
                        {s.subscription_number} • {s.plan_name}
                      </span>
                    </div>
                    <div className="text-right flex items-center gap-3">
                      <span className="font-mono font-semibold text-slate-900">
                        {formatCurrency(s.total_amount, s.currency)}
                      </span>
                      <Link to={`/subscriptions/${s.id}`}>
                        <Button variant="ghost" size="sm" className="h-7 text-xs px-2">
                          Manage
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
