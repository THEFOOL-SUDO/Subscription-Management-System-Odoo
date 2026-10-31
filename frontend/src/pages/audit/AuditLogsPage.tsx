import React, { useEffect, useState } from "react";
import { auditApi } from "@/api/audit";
import { useToast } from "@/components/ui/toast";
import { AuditLog } from "@/types";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Dialog } from "@/components/ui/dialog";
import { formatDate } from "@/lib/utils";
import {
  ChevronLeft,
  ChevronRight,
  Eye,
  Loader2,
  Filter,
} from "lucide-react";

export const AuditLogsPage: React.FC = () => {
  const { error: toastError } = useToast();
  const [logs, setLogs] = useState<AuditLog[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [isLoading, setIsLoading] = useState(true);
  const [actionFilter, setActionFilter] = useState<string>("");
  const [inspectLog, setInspectLog] = useState<AuditLog | null>(null);

  const loadLogs = async () => {
    setIsLoading(true);
    try {
      const data = await auditApi.listAuditLogs({
        page,
        size: 15,
        action: actionFilter || undefined,
      });
      setLogs(data.items);
      setTotal(data.total);
      setTotalPages(data.pages);
    } catch (err: any) {
      toastError(err.response?.data?.detail || "Failed to load audit logs.");
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadLogs();
  }, [page, actionFilter]);

  const getActionBadge = (action: string) => {
    if (action.includes("FAILURE") || action.includes("REUSE") || action.includes("DEACTIVATED")) {
      return <Badge variant="danger">{action}</Badge>;
    }
    if (action.includes("RESET") || action.includes("ROTATED")) {
      return <Badge variant="warning">{action}</Badge>;
    }
    if (action.includes("SUCCESS") || action.includes("REGISTERED") || action.includes("CREATED")) {
      return <Badge variant="success">{action}</Badge>;
    }
    return <Badge variant="secondary">{action}</Badge>;
  };

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 border-b border-slate-200/80 pb-5">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">Security Audit Trail</h1>
          <p className="text-xs text-slate-500 mt-1">
            Immutable log of identity authentications, role delegations, and security events.
          </p>
        </div>

        {/* Action Filter */}
        <div className="flex items-center gap-2">
          <Filter className="w-4 h-4 text-slate-400" />
          <select
            value={actionFilter}
            onChange={(e) => {
              setActionFilter(e.target.value);
              setPage(1);
            }}
            className="h-9 rounded-md border border-slate-300 bg-white px-3 py-1 text-xs text-slate-700 shadow-xs focus:outline-none focus:ring-2 focus:ring-slate-900"
          >
            <option value="">All Security Events</option>
            <option value="AUTH_LOGIN_SUCCESS">AUTH_LOGIN_SUCCESS</option>
            <option value="AUTH_LOGIN_FAILURE">AUTH_LOGIN_FAILURE</option>
            <option value="AUTH_LOGOUT">AUTH_LOGOUT</option>
            <option value="TOKEN_ROTATED">TOKEN_ROTATED</option>
            <option value="TOKEN_REUSE_DETECTED">TOKEN_REUSE_DETECTED</option>
            <option value="USER_REGISTERED">USER_REGISTERED</option>
            <option value="STAFF_CREATED">STAFF_CREATED</option>
            <option value="PASSWORD_RESET_REQUESTED">PASSWORD_RESET_REQUESTED</option>
            <option value="PASSWORD_RESET_COMPLETED">PASSWORD_RESET_COMPLETED</option>
            <option value="USER_STATUS_UPDATED">USER_STATUS_UPDATED</option>
          </select>
        </div>
      </div>

      {/* Audit Logs Table Card */}
      <Card>
        <CardHeader className="pb-3">
          <CardTitle className="text-base font-semibold">Audit Events Log</CardTitle>
          <CardDescription className="text-xs">
            Showing total {total} events recorded in PostgreSQL audit persistence.
          </CardDescription>
        </CardHeader>
        <CardContent className="p-0">
          {isLoading ? (
            <div className="flex items-center justify-center py-12">
              <Loader2 className="w-6 h-6 animate-spin text-slate-400" />
            </div>
          ) : logs.length === 0 ? (
            <div className="py-12 text-center text-xs text-slate-500">
              No audit logs found matching the filter criteria.
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse text-xs">
                <thead>
                  <tr className="border-y border-slate-200/80 bg-slate-50/75 text-slate-600 font-semibold uppercase tracking-wider text-[11px]">
                    <th className="py-3 px-4">Timestamp (UTC)</th>
                    <th className="py-3 px-4">Event Action</th>
                    <th className="py-3 px-4">Target Resource</th>
                    <th className="py-3 px-4">Actor</th>
                    <th className="py-3 px-4">IP Address</th>
                    <th className="py-3 px-4 text-right">Details</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {logs.map((log) => (
                    <tr key={log.id} className="hover:bg-slate-50/60 transition-colors">
                      <td className="py-3.5 px-4 text-slate-500 whitespace-nowrap">
                        {formatDate(log.created_at)}
                      </td>
                      <td className="py-3.5 px-4 whitespace-nowrap">
                        {getActionBadge(log.action)}
                      </td>
                      <td className="py-3.5 px-4 font-mono text-[11px] text-slate-600">
                        {log.resource_type} {log.resource_id ? `(${log.resource_id.slice(0, 8)}...)` : ""}
                      </td>
                      <td className="py-3.5 px-4 text-slate-800">
                        {log.user_email ? (
                          <span className="font-semibold">{log.user_email}</span>
                        ) : log.user_id ? (
                          <span className="font-mono text-slate-500 text-[11px]">{log.user_id.slice(0, 8)}...</span>
                        ) : (
                          <span className="text-slate-400 italic">Anonymous</span>
                        )}
                      </td>
                      <td className="py-3.5 px-4 font-mono text-slate-500 text-[11px]">
                        {log.ip_address || "—"}
                      </td>
                      <td className="py-3.5 px-4 text-right">
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => setInspectLog(log)}
                          className="h-7 px-2 gap-1 text-[11px]"
                        >
                          <Eye className="w-3.5 h-3.5" />
                          Inspect
                        </Button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}

          {/* Pagination Footer */}
          {totalPages > 1 && (
            <div className="flex items-center justify-between px-4 py-3 border-t border-slate-100 text-xs">
              <span className="text-slate-500">
                Page {page} of {totalPages}
              </span>
              <div className="flex gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  disabled={page <= 1}
                  onClick={() => setPage((p) => Math.max(1, p - 1))}
                >
                  <ChevronLeft className="w-4 h-4 mr-1" />
                  Previous
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  disabled={page >= totalPages}
                  onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                >
                  Next
                  <ChevronRight className="w-4 h-4 ml-1" />
                </Button>
              </div>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Inspect Log Details Modal */}
      <Dialog
        isOpen={inspectLog !== null}
        onClose={() => setInspectLog(null)}
        title="Audit Event Details"
        description={inspectLog ? `${inspectLog.action} recorded on ${formatDate(inspectLog.created_at)}` : ""}
      >
        {inspectLog && (
          <div className="space-y-3 text-xs">
            <div className="grid grid-cols-2 gap-2 p-3 bg-slate-50 rounded-lg border border-slate-100 font-mono text-[11px]">
              <div>
                <span className="text-slate-500 block">Event ID:</span>
                <span className="text-slate-900">{inspectLog.id}</span>
              </div>
              <div>
                <span className="text-slate-500 block">Actor ID:</span>
                <span className="text-slate-900">{inspectLog.user_id || "None"}</span>
              </div>
              <div>
                <span className="text-slate-500 block">IP Address:</span>
                <span className="text-slate-900">{inspectLog.ip_address || "None"}</span>
              </div>
              <div>
                <span className="text-slate-500 block">Resource:</span>
                <span className="text-slate-900">{inspectLog.resource_type} ({inspectLog.resource_id || "N/A"})</span>
              </div>
            </div>

            <div>
              <span className="font-semibold text-slate-700 block mb-1">Payload Details:</span>
              <pre className="p-3 bg-slate-900 text-slate-100 rounded-lg overflow-x-auto text-[11px] font-mono">
                {JSON.stringify(inspectLog.details, null, 2)}
              </pre>
            </div>

            {inspectLog.user_agent && (
              <div>
                <span className="font-semibold text-slate-700 block mb-1">User Agent:</span>
                <p className="text-[11px] text-slate-500 font-mono break-all">{inspectLog.user_agent}</p>
              </div>
            )}
          </div>
        )}
      </Dialog>
    </div>
  );
};
