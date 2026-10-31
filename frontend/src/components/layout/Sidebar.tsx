import React from "react";
import { NavLink } from "react-router-dom";
import { useAuth } from "@/hooks/useAuth";
import { cn } from "@/lib/utils";
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
} from "lucide-react";

export const Sidebar: React.FC = () => {
  const { user } = useAuth();
  if (!user) return null;

  const role = user.role;

  const adminNav = [
    { name: "Overview", to: "/admin", icon: LayoutDashboard },
    { name: "Catalogue", to: "/catalogue", icon: Sparkles },
    { name: "Products", to: "/products", icon: Package },
    { name: "Subscription Plans", to: "/plans", icon: Layers },
    { name: "Customer Directory", to: "/customers", icon: UserCheck },
    { name: "Subscriptions", to: "/subscriptions", icon: CreditCard },
    { name: "Invoices & Billing", to: "/invoices", icon: FileText },
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
    { name: "Subscriptions", to: "/subscriptions", icon: CreditCard },
    { name: "Invoices & Billing", to: "/invoices", icon: FileText },
    { name: "Audit Trail", to: "/audit-logs", icon: ShieldAlert },
    { name: "My Profile", to: "/profile", icon: Settings },
  ];

  const customerNav = [
    { name: "My Portal", to: "/portal", icon: LayoutDashboard },
    { name: "Browse Catalogue", to: "/catalogue", icon: Sparkles },
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

      {/* Footer Info */}
      <div className="p-4 border-t border-slate-100">
        <div className="bg-slate-50 rounded-lg p-3 border border-slate-100">
          <p className="text-xs font-semibold text-slate-800">Brightloop Platform</p>
          <p className="text-[11px] text-slate-500 mt-0.5">Phase 3: Subscriptions & Billing</p>
        </div>
      </div>
    </aside>
  );
};
