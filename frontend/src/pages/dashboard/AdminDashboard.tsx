import React, { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { healthApi } from "@/api/health";
import { usersApi } from "@/api/users";
import { auditApi } from "@/api/audit";
import { HealthCheckResponse, AuditLog } from "@/types";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { formatDate } from "@/lib/utils";
import {
  Users,
  ShieldAlert,
  Server,
  Activity,
  UserPlus,
  ArrowRight,
  Database,
  Layers,
} from "lucide-react";

export const AdminDashboard: React.FC = () => {
  const [health, setHealth] = useState<HealthCheckResponse | null>(null);
  const [userStats, setUserStats] = useState<{ total: number; staff: number; customers: number }>({
    total: 0,
    staff: 0,
    customers: 0,
  });
  const [recentLogs, setRecentLogs] = useState<AuditLog[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [h, u, a] = await Promise.all([
          healthApi.check(),
          usersApi.listUsers({ size: 100 }),
          auditApi.listAuditLogs({ size: 5 }),
        ]);
        setHealth(h);
        const allUsers = u.items;
        setUserStats({
          total: u.total,
          staff: allUsers.filter((x) => x.role === "STAFF").length,
          customers: allUsers.filter((x) => x.role === "CUSTOMER").length,
        });
        setRecentLogs(a.items);
      } catch (err) {
        console.error("Failed to load admin telemetry", err);
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();
  }, []);

  return (
    <div className="space-y-6">
      {/* Header Banner */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4 border-b border-slate-200/80 pb-5">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">
            System Administration
          </h1>
          <p className="text-xs text-slate-500 mt-1">
            Overview of platform identity, user accounts, operational health, and audit trail.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <Link to="/admin/users">
            <Button size="sm" variant="outline" className="gap-1.5">
              <Users className="w-4 h-4" />
              Manage Users
            </Button>
          </Link>
          <Link to="/admin/users?newStaff=true">
            <Button size="sm" className="gap-1.5">
              <UserPlus className="w-4 h-4" />
              Provision Staff
            </Button>
          </Link>
        </div>
      </div>

      {/* Metrics Row */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-xs font-semibold text-slate-500 uppercase tracking-wider">
              Total Accounts
            </CardTitle>
            <Users className="h-4 w-4 text-slate-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-slate-900">{isLoading ? "—" : userStats.total}</div>
            <p className="text-xs text-slate-500 mt-1">Registered identity principals</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-xs font-semibold text-slate-500 uppercase tracking-wider">
              Staff Members
            </CardTitle>
            <Layers className="h-4 w-4 text-blue-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-slate-900">{isLoading ? "—" : userStats.staff}</div>
            <p className="text-xs text-slate-500 mt-1">Operational support accounts</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-xs font-semibold text-slate-500 uppercase tracking-wider">
              Customers
            </CardTitle>
            <Users className="h-4 w-4 text-emerald-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-slate-900">{isLoading ? "—" : userStats.customers}</div>
            <p className="text-xs text-slate-500 mt-1">Self-service subscriber accounts</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-xs font-semibold text-slate-500 uppercase tracking-wider">
              System Health
            </CardTitle>
            <Activity className="h-4 w-4 text-emerald-500" />
          </CardHeader>
          <CardContent>
            <div className="flex items-center gap-2">
              <span className="text-sm font-bold text-slate-900 capitalize">
                {health?.status || "Checking..."}
              </span>
              {health?.status === "healthy" ? (
                <Badge variant="success">Operational</Badge>
              ) : (
                <Badge variant="danger">Issues</Badge>
              )}
            </div>
            <p className="text-xs text-slate-500 mt-1">PostgreSQL & Redis connected</p>
          </CardContent>
        </Card>
      </div>

      {/* Telemetry and Recent Logs Section */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left 2 Cols: Recent Audit Trail */}
        <Card className="lg:col-span-2">
          <CardHeader className="flex flex-row items-center justify-between pb-3">
            <div>
              <CardTitle className="text-base font-semibold">Recent Audit Trail</CardTitle>
              <CardDescription className="text-xs">
                Real-time security events, authentication attempts, and administrative actions.
              </CardDescription>
            </div>
            <Link to="/audit-logs">
              <Button variant="ghost" size="sm" className="gap-1 text-xs">
                View All
                <ArrowRight className="w-3.5 h-3.5" />
              </Button>
            </Link>
          </CardHeader>
          <CardContent>
            {recentLogs.length === 0 ? (
              <p className="text-xs text-slate-500 py-6 text-center">No audit records recorded yet.</p>
            ) : (
              <div className="divide-y divide-slate-100">
                {recentLogs.map((log) => (
                  <div key={log.id} className="py-2.5 flex items-center justify-between text-xs">
                    <div className="flex items-center gap-2.5">
                      <div className="h-2 w-2 rounded-full bg-slate-400" />
                      <div>
                        <span className="font-semibold text-slate-800">{log.action}</span>
                        <p className="text-slate-500 text-[11px] truncate max-w-xs">
                          {log.user_email || `User: ${log.user_id || "Anonymous"}`}
                        </p>
                      </div>
                    </div>
                    <div className="text-right text-slate-400 text-[11px]">
                      {formatDate(log.created_at)}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>

        {/* Right Col: Node Health & Services */}
        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-base font-semibold">Infrastructure Status</CardTitle>
            <CardDescription className="text-xs">Live connectivity to backend persistence</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="rounded-lg border border-slate-100 bg-slate-50 p-3 flex items-center justify-between">
              <div className="flex items-center gap-2.5">
                <Database className="w-4 h-4 text-slate-600" />
                <div>
                  <p className="text-xs font-semibold text-slate-800">PostgreSQL Database</p>
                  <p className="text-[11px] text-slate-500">
                    Latency: {health?.metrics.database_latency_ms ?? "—"} ms
                  </p>
                </div>
              </div>
              <Badge variant="success">Online</Badge>
            </div>

            <div className="rounded-lg border border-slate-100 bg-slate-50 p-3 flex items-center justify-between">
              <div className="flex items-center gap-2.5">
                <Server className="w-4 h-4 text-slate-600" />
                <div>
                  <p className="text-xs font-semibold text-slate-800">Redis Cache & Limiter</p>
                  <p className="text-[11px] text-slate-500">
                    Latency: {health?.metrics.redis_latency_ms ?? "—"} ms
                  </p>
                </div>
              </div>
              <Badge variant="success">Online</Badge>
            </div>

            <div className="rounded-lg border border-slate-100 bg-slate-50 p-3 flex items-center justify-between">
              <div className="flex items-center gap-2.5">
                <ShieldAlert className="w-4 h-4 text-slate-600" />
                <div>
                  <p className="text-xs font-semibold text-slate-800">Argon2id Hashing Engine</p>
                  <p className="text-[11px] text-slate-500">Memory: 64MB / Time: 3</p>
                </div>
              </div>
              <Badge variant="secondary">Active</Badge>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
};
