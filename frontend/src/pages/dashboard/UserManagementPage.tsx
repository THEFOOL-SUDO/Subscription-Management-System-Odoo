import React, { useEffect, useState } from "react";
import { useSearchParams } from "react-router-dom";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { usersApi } from "@/api/users";
import { useAuth } from "@/hooks/useAuth";
import { useToast } from "@/components/ui/toast";
import { staffCreateSchema } from "@/lib/validations";
import { User } from "@/types";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { RoleBadge, Badge } from "@/components/ui/badge";
import { Dialog } from "@/components/ui/dialog";
import { PasswordStrengthIndicator } from "@/components/auth/PasswordStrengthIndicator";
import { formatDate } from "@/lib/utils";
import {
  UserPlus,
  Search,
  CheckCircle,
  Ban,
  ChevronLeft,
  ChevronRight,
  Shield,
  Loader2,
} from "lucide-react";

type StaffFormValues = z.infer<typeof staffCreateSchema>;

export const UserManagementPage: React.FC = () => {
  const { user: currentUser } = useAuth();
  const [searchParams, setSearchParams] = useSearchParams();
  const { success: toastSuccess, error: toastError } = useToast();

  const [users, setUsers] = useState<User[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [isLoading, setIsLoading] = useState(true);

  // Filters
  const [searchTerm, setSearchTerm] = useState("");
  const [roleFilter, setRoleFilter] = useState<string>("");
  const [statusFilter, setStatusFilter] = useState<string>("");

  // Create Staff Modal State
  const [isStaffModalOpen, setIsStaffModalOpen] = useState(
    searchParams.get("newStaff") === "true"
  );
  const [isSubmittingStaff, setIsSubmittingStaff] = useState(false);

  const {
    register,
    handleSubmit,
    watch,
    reset: resetStaffForm,
    formState: { errors: staffErrors },
  } = useForm<StaffFormValues>({
    resolver: zodResolver(staffCreateSchema),
    defaultValues: {
      full_name: "",
      email: "",
      password: "",
    },
  });

  const watchedStaffPassword = watch("password");

  const loadUsers = async () => {
    setIsLoading(true);
    try {
      const data = await usersApi.listUsers({
        page,
        size: 15,
        search: searchTerm || undefined,
        role: roleFilter || undefined,
        is_active: statusFilter === "active" ? true : statusFilter === "inactive" ? false : undefined,
      });
      setUsers(data.items);
      setTotal(data.total);
      setTotalPages(data.pages);
    } catch (err: any) {
      toastError(err.response?.data?.detail || "Failed to load users list.");
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadUsers();
  }, [page, roleFilter, statusFilter]);

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setPage(1);
    loadUsers();
  };

  const handleToggleStatus = async (targetUser: User) => {
    if (targetUser.id === currentUser?.id) {
      toastError("You cannot deactivate your own administrator account.");
      return;
    }

    const newStatus = !targetUser.is_active;
    try {
      await usersApi.updateStatus(targetUser.id, newStatus);
      toastSuccess(
        `User ${targetUser.email} has been ${newStatus ? "activated" : "deactivated"}.`
      );
      setUsers((prev) =>
        prev.map((u) => (u.id === targetUser.id ? { ...u, is_active: newStatus } : u))
      );
    } catch (err: any) {
      toastError(err.response?.data?.detail || "Failed to update user status.");
    }
  };

  const onSubmitStaff = async (data: StaffFormValues) => {
    setIsSubmittingStaff(true);
    try {
      await usersApi.createStaff(data);
      toastSuccess(`Staff account provisioned for ${data.email}.`);
      setIsStaffModalOpen(false);
      resetStaffForm();
      // Remove query param if present
      searchParams.delete("newStaff");
      setSearchParams(searchParams);
      loadUsers();
    } catch (err: any) {
      toastError(err.response?.data?.detail || "Failed to create staff account.");
    } finally {
      setIsSubmittingStaff(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Page Title & Provision Button */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 border-b border-slate-200/80 pb-5">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">User Management</h1>
          <p className="text-xs text-slate-500 mt-1">
            Maintain accounts, configure role permissions, and provision operational staff.
          </p>
        </div>
        <Button onClick={() => setIsStaffModalOpen(true)} className="gap-1.5 self-start sm:self-auto">
          <UserPlus className="w-4 h-4" />
          Add Staff Member
        </Button>
      </div>

      {/* Filter and Search Bar */}
      <Card>
        <CardContent className="p-4">
          <div className="flex flex-col md:flex-row gap-3">
            <form onSubmit={handleSearchSubmit} className="flex-1 flex gap-2">
              <div className="relative flex-1">
                <Search className="w-4 h-4 absolute left-3 top-2.5 text-slate-400" />
                <Input
                  placeholder="Search by name or email address..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-9"
                />
              </div>
              <Button type="submit" variant="secondary" size="md">
                Search
              </Button>
            </form>

            <div className="flex gap-2">
              <select
                value={roleFilter}
                onChange={(e) => {
                  setRoleFilter(e.target.value);
                  setPage(1);
                }}
                className="h-9 rounded-md border border-slate-300 bg-white px-3 py-1 text-xs text-slate-700 shadow-xs focus:outline-none focus:ring-2 focus:ring-slate-900"
              >
                <option value="">All Roles</option>
                <option value="ADMIN">Admin</option>
                <option value="STAFF">Staff</option>
                <option value="CUSTOMER">Customer</option>
              </select>

              <select
                value={statusFilter}
                onChange={(e) => {
                  setStatusFilter(e.target.value);
                  setPage(1);
                }}
                className="h-9 rounded-md border border-slate-300 bg-white px-3 py-1 text-xs text-slate-700 shadow-xs focus:outline-none focus:ring-2 focus:ring-slate-900"
              >
                <option value="">All Statuses</option>
                <option value="active">Active</option>
                <option value="inactive">Deactivated</option>
              </select>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Users Table Card */}
      <Card>
        <CardHeader className="pb-3">
          <div className="flex items-center justify-between">
            <div>
              <CardTitle className="text-base font-semibold">User Accounts Directory</CardTitle>
              <CardDescription className="text-xs">
                Total {total} principal accounts registered on the platform.
              </CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent className="p-0">
          {isLoading ? (
            <div className="flex items-center justify-center py-12">
              <Loader2 className="w-6 h-6 animate-spin text-slate-400" />
            </div>
          ) : users.length === 0 ? (
            <div className="py-12 text-center text-xs text-slate-500">
              No user accounts found matching your filter parameters.
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse text-xs">
                <thead>
                  <tr className="border-y border-slate-200/80 bg-slate-50/75 text-slate-600 font-semibold uppercase tracking-wider text-[11px]">
                    <th className="py-3 px-4">User</th>
                    <th className="py-3 px-4">Role</th>
                    <th className="py-3 px-4">Status</th>
                    <th className="py-3 px-4">Created Date</th>
                    <th className="py-3 px-4 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {users.map((u) => (
                    <tr key={u.id} className="hover:bg-slate-50/60 transition-colors">
                      <td className="py-3.5 px-4">
                        <div className="font-semibold text-slate-900">{u.full_name}</div>
                        <div className="text-slate-500 text-[11px] font-mono">{u.email}</div>
                      </td>
                      <td className="py-3.5 px-4">
                        <RoleBadge role={u.role} />
                      </td>
                      <td className="py-3.5 px-4">
                        {u.is_active ? (
                          <Badge variant="success">Active</Badge>
                        ) : (
                          <Badge variant="danger">Deactivated</Badge>
                        )}
                      </td>
                      <td className="py-3.5 px-4 text-slate-500">
                        {formatDate(u.created_at)}
                      </td>
                      <td className="py-3.5 px-4 text-right">
                        {u.id === currentUser?.id ? (
                          <span className="text-[11px] text-slate-400 font-medium">You</span>
                        ) : (
                          <Button
                            variant={u.is_active ? "outline" : "secondary"}
                            size="sm"
                            onClick={() => handleToggleStatus(u)}
                            className="gap-1 text-xs"
                          >
                            {u.is_active ? (
                              <>
                                <Ban className="w-3.5 h-3.5 text-rose-500" />
                                Deactivate
                              </>
                            ) : (
                              <>
                                <CheckCircle className="w-3.5 h-3.5 text-emerald-500" />
                                Activate
                              </>
                            )}
                          </Button>
                        )}
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

      {/* Provision Staff Member Modal */}
      <Dialog
        isOpen={isStaffModalOpen}
        onClose={() => {
          setIsStaffModalOpen(false);
          resetStaffForm();
        }}
        title="Provision Staff Member"
        description="Create a staff account with operational privileges. Staff cannot create other staff."
      >
        <form onSubmit={handleSubmit(onSubmitStaff)} className="space-y-4">
          <div>
            <Label htmlFor="staff_name" required>Full Name</Label>
            <Input
              id="staff_name"
              placeholder="Operational Staff Member"
              error={staffErrors.full_name?.message}
              {...register("full_name")}
            />
          </div>

          <div>
            <Label htmlFor="staff_email" required>Work Email</Label>
            <Input
              id="staff_email"
              type="email"
              placeholder="staff@brightloop.com"
              error={staffErrors.email?.message}
              {...register("email")}
            />
          </div>

          <div>
            <Label htmlFor="staff_pwd" required>Temporary Password</Label>
            <Input
              id="staff_pwd"
              type="password"
              placeholder="••••••••••••"
              error={staffErrors.password?.message}
              {...register("password")}
            />
            {watchedStaffPassword && <PasswordStrengthIndicator password={watchedStaffPassword} />}
          </div>

          <div className="rounded-lg bg-blue-50/70 p-3 border border-blue-200/70 text-xs text-blue-900 flex items-start gap-2">
            <Shield className="w-4 h-4 text-blue-600 mt-0.5 shrink-0" />
            <p>
              This account will receive <strong>STAFF</strong> permissions. They can review customer accounts and inspect audit logs, but cannot provision administrators or other staff members.
            </p>
          </div>

          <div className="flex justify-end gap-2 pt-2 border-t border-slate-100">
            <Button
              type="button"
              variant="outline"
              onClick={() => {
                setIsStaffModalOpen(false);
                resetStaffForm();
              }}
            >
              Cancel
            </Button>
            <Button type="submit" isLoading={isSubmittingStaff}>
              Provision Staff Account
            </Button>
          </div>
        </form>
      </Dialog>
    </div>
  );
};
