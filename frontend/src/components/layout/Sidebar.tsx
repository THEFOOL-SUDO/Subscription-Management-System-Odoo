import React, { useState } from "react";
import { NavLink } from "react-router-dom";
import { useAuth } from "@/hooks/useAuth";
import { cn } from "@/lib/utils";
import { billingApi } from "@/api/billing";
import {
  LayoutDashboard,
  Users,
  ShieldAlert,
  UserCheck,
  CreditCard,
  FileText,
  Settings,
  Sparkles,
  Package,
  Layers,
  FileCheck,
  Tag,
  Receipt,
  PlayCircle,
  Loader2,
} from "lucide-react";

export const Sidebar: React.FC = () => {
  const { user } = useAuth();
  const [isRunningBilling, setIsRunningBilling] = useState(false);
  const [billingMessage, setBillingMessage] = useState<string | null>(null);

  if (!user) return null;

  const role = user.role;

  const handleRunBilling = async () => {
    setIsRunningBilling(true);
    setBillingMessage(null);
    try {
      const res = await billingApi.runBillingScheduler();
      setBillingMessage(`Billing run complete: ${res.invoices_generated_count} invoices generated.`);
      setTimeout(() => setBillingMessage(null), 5000);
    } catch (err: any) {
      setBillingMessage(err?.response?.data?.detail || "Scheduler execution failed.");
      setTimeout(() => setBillingMessage(null), 5000);
    } finally {
      setIsRunningBilling(false);
    }
  };

  const adminNav = [
    { name: "Overview", to: "/admin", icon: LayoutDashboard },
    { name: "Catalogue", to: "/catalogue", icon: Sparkles },
    { name: "Products", to: "/products", icon: Package },
    { name: "Subscription Plans", to: "/plans", icon: Layers },
    { name: "Customer Directory", to: "/customers", icon: UserCheck },
    { name: "Quotations", to: "/quotations", icon: FileCheck },
    { name: "Subscriptions", to: "/subscriptions", icon: CreditCard },
    { name: "Invoices & Billing", to: "/invoices", icon: FileText },
    { name: "Discounts & Promos", to: "/discounts", icon: Tag },
    { name: "Tax Schedules", to: "/taxes", icon: Receipt },
    { name: "User Management", to: "/admin/users", icon: Users },
    { name: "Audit Logs", to: "/audit-logs", icon: ShieldAlert },
    { name: "My Profile", to: "/profile", icon: Settings },
  ];

  const staffNav = [
    { name: "Staff Console", to: "/staff", icon: LayoutDashboard },
    { name: "Catalogue", to: "/catalogue", icon: Sparkles },
    { name: "Product Catalog", to: "/products", icon: Package },
    { name: "Subscription Plans", to: "/plans", icon: Layers },
    { name: "Customer Accounts", to: "/customers", icon: UserCheck },
    { name: "Quotations", to: "/quotations", icon: FileCheck },
    { name: "Subscriptions", to: "/subscriptions", icon: CreditCard },
    { name: "Invoices & Billing", to: "/invoices", icon: FileText },
    { name: "Discounts & Promos", to: "/discounts", icon: Tag },
    { name: "Tax Schedules", to: "/taxes", icon: Receipt },
    { name: "Audit Trail", to: "/audit-logs", icon: ShieldAlert },
    { name: "My Profile", to: "/profile", icon: Settings },
  ];

  const customerNav = [
    { name: "My Portal", to: "/portal", icon: LayoutDashboard },
    { name: "Browse Catalogue", to: "/catalogue", icon: Sparkles },
    { name: "My Quotations", to: "/quotations", icon: FileCheck },
    { name: "My Subscriptions", to: "/subscriptions", icon: CreditCard },
    { name: "My Invoices", to: "/invoices", icon: FileText },
    { name: "Profile & Security", to: "/profile", icon: Settings },
  ];

  const navItems = role === "ADMIN" ? adminNav : role === "STAFF" ? staffNav : customerNav;

  return (
    <aside className="w-64 border-r border-slate-200/80 bg-white flex flex-col shrink-0">
      {/* Brand Header */}
      <div className="h-16 flex items-center px-6 border-b border-slate-200/80 gap-3">
        <div className="h-9 w-9 rounded-xl bg-slate-900 flex items-center justify-center text-white shadow-xs">
          <Sparkles className="w-5 h-5 text-blue-400" />
        </div>
        <div>
          <span className="font-bold text-base tracking-tight text-slate-900 leading-none">
            Brightloop
          </span>
          <span className="block text-[10px] uppercase font-semibold tracking-wider text-slate-400 mt-0.5">
            Subscription OS
          </span>
        </div>
      </div>

      {/* Nav List */}
      <nav className="flex-1 p-4 space-y-1 overflow-y-auto">
        <div className="px-3 pb-2 pt-1 text-[11px] font-semibold text-slate-400 uppercase tracking-wider">
          {role === "ADMIN" ? "Administration" : role === "STAFF" ? "Operations" : "Account Portal"}
        </div>
        {navItems.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            end={item.to === "/admin" || item.to === "/staff" || item.to === "/portal"}
            className={({ isActive }) =>
              cn(
                "flex items-center gap-3 px-3 py-2 rounded-lg text-sm font-medium transition-colors",
                isActive
                  ? "bg-slate-900 text-white shadow-xs"
                  : "text-slate-600 hover:text-slate-900 hover:bg-slate-100/80"
              )
            }
          >
            <item.icon className="w-4 h-4 shrink-0" />
            <span>{item.name}</span>
          </NavLink>
        ))}
      </nav>

      {/* Footer Info & Scheduler Trigger */}
      <div className="p-4 border-t border-slate-100 space-y-2">
        {role !== "CUSTOMER" && (
          <div>
            <button
              onClick={handleRunBilling}
              disabled={isRunningBilling}
              className="w-full flex items-center justify-center gap-2 px-3 py-2 bg-indigo-50 hover:bg-indigo-100 text-indigo-700 border border-indigo-200 rounded-lg text-xs font-bold transition-all shadow-xs disabled:opacity-50"
            >
              {isRunningBilling ? (
                <Loader2 className="w-3.5 h-3.5 animate-spin" />
              ) : (
                <PlayCircle className="w-3.5 h-3.5" />
              )}
              <span>{isRunningBilling ? "Running Cycle..." : "Run Billing Scheduler"}</span>
            </button>
            {billingMessage && (
              <p className="text-[11px] text-indigo-700 bg-indigo-50/80 p-2 rounded border border-indigo-100 mt-1.5 font-medium leading-tight">
                {billingMessage}
              </p>
            )}
          </div>
        )}

        <div className="bg-slate-50 rounded-lg p-2.5 border border-slate-100">
          <p className="text-xs font-semibold text-slate-800">Brightloop Platform</p>
          <p className="text-[10px] text-slate-500 mt-0.5">Enterprise Subscription OS</p>
        </div>
      </div>
    </aside>
  );
};
