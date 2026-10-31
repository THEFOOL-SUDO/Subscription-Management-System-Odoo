import React, { useState } from "react";
import { Link } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { customersApi } from "@/api/customers";
import { useAuth } from "@/hooks/useAuth";
import { CustomerStatus } from "@/types";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { CustomerCreateModal } from "./CustomerCreateModal";
import { formatDate } from "@/lib/utils";
import {
  Users,
  Search,
  Plus,
  ArrowRight,
  Loader2,
  Building2,
  Mail,
  Phone,
} from "lucide-react";

export const CustomersListPage: React.FC = () => {
  const { user } = useAuth();
  const isOperator = user?.role === "ADMIN" || user?.role === "STAFF";

  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState<CustomerStatus | "ALL">("ALL");
  const [page, setPage] = useState(1);
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);

  const { data, isLoading, error } = useQuery({
    queryKey: ["customers", { page, search, statusFilter }],
    queryFn: () =>
      customersApi.listCustomers({
        page,
        limit: 15,
        search: search.trim() || undefined,
        status: statusFilter === "ALL" ? undefined : statusFilter,
      }),
  });

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">
            Customer Directory
          </h1>
          <p className="text-sm text-slate-500 mt-1">
            Manage enterprise accounts, billing addresses, and linked subscriptions.
          </p>
        </div>
        {isOperator && (
          <Button onClick={() => setIsCreateModalOpen(true)} className="gap-2 self-start md:self-auto">
            <Plus className="w-4 h-4" />
            Add Customer
          </Button>
        )}
      </div>

      {/* Filter and Search Bar */}
      <Card>
        <CardContent className="p-4 flex flex-col sm:flex-row gap-3">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-2.5 h-4 w-4 text-slate-400" />
            <Input
              placeholder="Search by customer name, email, company, or customer #..."
              value={search}
              onChange={(e) => {
                setSearch(e.target.value);
                setPage(1);
              }}
              className="pl-9"
            />
          </div>

          <div className="flex items-center gap-2">
            <select
              value={statusFilter}
              onChange={(e) => {
                setStatusFilter(e.target.value as any);
                setPage(1);
              }}
              className="h-9 px-3 rounded-md border border-slate-200 bg-white text-xs font-medium text-slate-700 focus:outline-none focus:ring-1 focus:ring-blue-500"
            >
              <option value="ALL">All Statuses</option>
              <option value="ACTIVE">Active Only</option>
              <option value="INACTIVE">Inactive</option>
            </select>
          </div>
        </CardContent>
      </Card>

      {/* Customer Directory Table */}
      <Card>
        <div className="overflow-x-auto max-h-[700px] overflow-y-auto">
          <table className="w-full text-left text-sm text-slate-600">
            <thead className="sticky top-0 bg-slate-50/95 backdrop-blur-xs z-10 border-b border-slate-200 text-xs uppercase font-semibold text-slate-500 tracking-wider">
              <tr>
                <th className="py-3 px-4">Customer</th>
                <th className="py-3 px-4">Company</th>
                <th className="py-3 px-4">Contact</th>
                <th className="py-3 px-4">Status</th>
                <th className="py-3 px-4">Registered</th>
                <th className="py-3 px-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {isLoading ? (
                <tr>
                  <td colSpan={6} className="py-12 text-center text-slate-400">
                    <Loader2 className="w-6 h-6 animate-spin mx-auto mb-2 text-blue-600" />
                    Loading customer accounts...
                  </td>
                </tr>
              ) : error ? (
                <tr>
                  <td colSpan={6} className="py-8 text-center text-red-500">
                    Failed to load customers directory.
                  </td>
                </tr>
              ) : data?.items.length === 0 ? (
                <tr>
                  <td colSpan={6} className="py-12 text-center">
                    <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-slate-100 text-slate-400 mb-3">
                      <Users className="w-6 h-6" />
                    </div>
                    <p className="text-sm font-semibold text-slate-700">No customers found</p>
                    <p className="text-xs text-slate-400 mt-1">
                      {search ? "Try adjusting your search criteria" : "Get started by adding your first customer account."}
                    </p>
                  </td>
                </tr>
              ) : (
                data?.items.map((cust) => (
                  <tr key={cust.id} className="hover:bg-slate-50/80 transition-colors">
                    <td className="py-3 px-4">
                      <div>
                        <span className="font-semibold text-slate-900 block">{cust.name}</span>
                        <span className="text-xs font-mono text-slate-400">{cust.customer_number}</span>
                      </div>
                    </td>
                    <td className="py-3 px-4">
                      {cust.company_name ? (
                        <div className="flex items-center gap-1.5 text-slate-700">
                          <Building2 className="w-3.5 h-3.5 text-slate-400 shrink-0" />
                          <span>{cust.company_name}</span>
                        </div>
                      ) : (
                        <span className="text-slate-400 text-xs italic">Individual</span>
                      )}
                    </td>
                    <td className="py-3 px-4">
                      <div className="space-y-0.5 text-xs">
                        <div className="flex items-center gap-1 text-slate-600">
                          <Mail className="w-3 h-3 text-slate-400 shrink-0" />
                          <span>{cust.email}</span>
                        </div>
                        {cust.phone && (
                          <div className="flex items-center gap-1 text-slate-500">
                            <Phone className="w-3 h-3 text-slate-400 shrink-0" />
                            <span>{cust.phone}</span>
                          </div>
                        )}
                      </div>
                    </td>
                    <td className="py-3 px-4">
                      <Badge variant={cust.status === "ACTIVE" ? "success" : "neutral"}>
                        {cust.status}
                      </Badge>
                    </td>
                    <td className="py-3 px-4 text-xs text-slate-500">
                      {formatDate(cust.created_at)}
                    </td>
                    <td className="py-3 px-4 text-right">
                      <Link to={`/customers/${cust.id}`}>
                        <Button variant="ghost" size="sm" className="gap-1 text-xs">
                          View
                          <ArrowRight className="w-3 h-3" />
                        </Button>
                      </Link>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination Bar */}
        {data && data.pages > 1 && (
          <div className="flex items-center justify-between p-4 border-t border-slate-100 text-xs text-slate-500">
            <span>
              Showing {data.items.length} of {data.total} customers
            </span>
            <div className="flex gap-2">
              <Button
                variant="outline"
                size="sm"
                disabled={page <= 1}
                onClick={() => setPage((p) => Math.max(1, p - 1))}
              >
                Previous
              </Button>
              <Button
                variant="outline"
                size="sm"
                disabled={page >= data.pages}
                onClick={() => setPage((p) => p + 1)}
              >
                Next
              </Button>
            </div>
          </div>
        )}
      </Card>

      <CustomerCreateModal
        isOpen={isCreateModalOpen}
        onClose={() => setIsCreateModalOpen(false)}
      />
    </div>
  );
};

