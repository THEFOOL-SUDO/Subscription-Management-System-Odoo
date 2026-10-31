import React, { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { useAuth } from "@/hooks/useAuth";
import { usersApi } from "@/api/users";
import { User } from "@/types";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { formatDate } from "@/lib/utils";
import {
  Users,
  FileCheck,
  Receipt,
  ShieldAlert,
} from "lucide-react";

export const StaffDashboard: React.FC = () => {
  const { user } = useAuth();
  const [customers, setCustomers] = useState<User[]>([]);
  const [totalCustomers, setTotalCustomers] = useState(0);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchCustomers = async () => {
      try {
        const data = await usersApi.listUsers({ role: "CUSTOMER", size: 10 });
        setCustomers(data.items);
        setTotalCustomers(data.total);
      } catch (err) {
        console.error("Failed to load customer list for staff", err);
      } finally {
        setIsLoading(false);
      }
    };
    fetchCustomers();
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
            Welcome back, {user?.full_name}. Monitor customer accounts and operational activity.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <Link to="/audit-logs">
            <Button size="sm" variant="outline" className="gap-1.5">
              <ShieldAlert className="w-4 h-4 text-slate-600" />
              View Audit Trail
            </Button>
          </Link>
        </div>
      </div>

      {/* Operational Overview Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-xs font-semibold text-slate-500 uppercase tracking-wider">
              Assigned Customers
            </CardTitle>
            <Users className="h-4 w-4 text-blue-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-slate-900">{isLoading ? "—" : totalCustomers}</div>
            <p className="text-xs text-slate-500 mt-1">Active customer accounts in system</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-xs font-semibold text-slate-500 uppercase tracking-wider">
              Quotations Engine
            </CardTitle>
            <FileCheck className="h-4 w-4 text-slate-400" />
          </CardHeader>
          <CardContent>
            <div className="flex items-center gap-2">
              <span className="text-sm font-semibold text-slate-700">Scheduled for Phase 2</span>
              <Badge variant="secondary">Upcoming</Badge>
            </div>
            <p className="text-xs text-slate-500 mt-1">Quotation drafts and template rules</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-xs font-semibold text-slate-500 uppercase tracking-wider">
              Invoices & Billing
            </CardTitle>
            <Receipt className="h-4 w-4 text-slate-400" />
          </CardHeader>
          <CardContent>
            <div className="flex items-center gap-2">
              <span className="text-sm font-semibold text-slate-700">Scheduled for Phase 2</span>
              <Badge variant="secondary">Upcoming</Badge>
            </div>
            <p className="text-xs text-slate-500 mt-1">Recurring invoice cycles & Razorpay</p>
          </CardContent>
        </Card>
      </div>

      {/* Customer Directory Table */}
      <Card>
        <CardHeader className="pb-3">
          <CardTitle className="text-base font-semibold">Customer Accounts</CardTitle>
          <CardDescription className="text-xs">
            Review customer accounts and verify their status.
          </CardDescription>
        </CardHeader>
        <CardContent className="p-0">
          {isLoading ? (
            <div className="py-8 text-center text-xs text-slate-500">Loading customer accounts...</div>
          ) : customers.length === 0 ? (
            <div className="py-8 text-center text-xs text-slate-500">
              No customer accounts registered yet.
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse text-xs">
                <thead>
                  <tr className="border-y border-slate-200/80 bg-slate-50/75 text-slate-600 font-semibold uppercase tracking-wider text-[11px]">
                    <th className="py-3 px-4">Customer Name</th>
                    <th className="py-3 px-4">Email</th>
                    <th className="py-3 px-4">Status</th>
                    <th className="py-3 px-4">Joined Date</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {customers.map((c) => (
                    <tr key={c.id} className="hover:bg-slate-50/60 transition-colors">
                      <td className="py-3.5 px-4 font-semibold text-slate-900">{c.full_name}</td>
                      <td className="py-3.5 px-4 text-slate-600 font-mono text-[11px]">{c.email}</td>
                      <td className="py-3.5 px-4">
                        {c.is_active ? (
                          <Badge variant="success">Active</Badge>
                        ) : (
                          <Badge variant="danger">Inactive</Badge>
                        )}
                      </td>
                      <td className="py-3.5 px-4 text-slate-500">{formatDate(c.created_at)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
};
