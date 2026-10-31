import React, { useState } from "react";
import { Link, useLocation, useNavigate } from "react-router-dom";
import { useAuth } from "@/hooks/useAuth";
import { RoleBadge } from "@/components/ui/badge";
import {
  User as UserIcon,
  LogOut,
  Mail,
  ChevronDown,
  ShieldCheck,
  ExternalLink,
  ChevronRight,
  Info,
} from "lucide-react";

export const Header: React.FC = () => {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const [dropdownOpen, setDropdownOpen] = useState(false);

  const handleLogout = async () => {
    setDropdownOpen(false);
    await logout();
    navigate("/login");
  };

  const getBreadcrumbTitle = (path: string) => {
    const segments = path.split("/").filter(Boolean);
    if (segments.length === 0) return "Dashboard";
    const primary = segments[0];
    const mapping: Record<string, string> = {
      admin: "Executive Overview",
      staff: "Operations Console",
      portal: "Customer Portal",
      catalogue: "Subscription Catalogue",
      products: "Product Catalog",
      plans: "Subscription Plans",
      customers: "Customer Directory",
      quotations: "Quotation Templates",
      subscriptions: "Subscription Registry",
      invoices: "Invoices & Billing",
      discounts: "Discount Rules",
      taxes: "Tax Schedules",
      profile: "Account Settings",
      "audit-logs": "Audit Trail",
    };
    const title = mapping[primary] || primary.charAt(0).toUpperCase() + primary.slice(1);
    if (segments.length > 1) {
      return `${title} / Details`;
    }
    return title;
  };

  return (
    <header className="sticky top-0 z-30 flex h-16 w-full items-center justify-between border-b border-slate-200/90 bg-white/95 px-6 backdrop-blur-xs">
      {/* Breadcrumb Path */}
      <div className="flex items-center gap-2 text-xs font-medium text-slate-500">
        <Link to="/" className="hover:text-indigo-600 transition-colors">
          Brightloop
        </Link>
        <ChevronRight className="w-3.5 h-3.5 text-slate-400" />
        <span className="font-semibold text-slate-800">
          {getBreadcrumbTitle(location.pathname)}
        </span>
      </div>

      <div className="flex items-center gap-3">
        {/* Safe Demo Warning Pill */}
        <div className="hidden sm:inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md text-[11px] font-semibold bg-amber-50 text-amber-800 border border-amber-200/80">
          <Info className="w-3.5 h-3.5 text-amber-600" />
          <span>DEMO SANDBOX</span>
        </div>

        {/* Mailpit local inbox shortcut */}
        <a
          href="http://localhost:8028"
          target="_blank"
          rel="noreferrer"
          className="hidden md:flex items-center gap-1.5 text-xs font-medium text-slate-600 bg-slate-100 hover:bg-slate-200 px-2.5 py-1 rounded-md transition-colors border border-slate-200"
          title="Open Mailpit Web UI to view customer notifications"
        >
          <Mail className="w-3.5 h-3.5 text-indigo-600" />
          <span>Mailbox</span>
          <ExternalLink className="w-3 h-3 text-slate-400" />
        </a>

        {user && (
          <div className="relative">
            <button
              onClick={() => setDropdownOpen(!dropdownOpen)}
              className="flex items-center gap-2 rounded-lg p-1.5 hover:bg-slate-100 transition-colors focus:outline-none focus:ring-2 focus:ring-indigo-400"
            >
              <div className="flex h-8 w-8 items-center justify-center rounded-full bg-slate-900 text-xs font-semibold text-white">
                {user.full_name.charAt(0).toUpperCase()}
              </div>
              <div className="hidden text-left md:block">
                <p className="text-xs font-semibold text-slate-900 leading-none">{user.full_name}</p>
                <div className="mt-0.5">
                  <RoleBadge role={user.role} />
                </div>
              </div>
              <ChevronDown className="w-4 h-4 text-slate-400" />
            </button>

            {dropdownOpen && (
              <>
                <div
                  className="fixed inset-0 z-40"
                  onClick={() => setDropdownOpen(false)}
                />
                <div className="absolute right-0 z-50 mt-2 w-56 rounded-xl border border-slate-200 bg-white p-2 shadow-lg animate-in fade-in-50 zoom-in-95">
                  <div className="px-3 py-2 border-b border-slate-100">
                    <p className="text-xs font-semibold text-slate-900">{user.full_name}</p>
                    <p className="text-xs text-slate-500 truncate">{user.email}</p>
                  </div>

                  <div className="py-1">
                    <Link
                      to="/profile"
                      onClick={() => setDropdownOpen(false)}
                      className="flex items-center gap-2 rounded-md px-3 py-2 text-xs font-medium text-slate-700 hover:bg-slate-100"
                    >
                      <UserIcon className="w-4 h-4 text-slate-500" />
                      <span>Account Settings</span>
                    </Link>

                    {user.role === "ADMIN" && (
                      <Link
                        to="/audit-logs"
                        onClick={() => setDropdownOpen(false)}
                        className="flex items-center gap-2 rounded-md px-3 py-2 text-xs font-medium text-slate-700 hover:bg-slate-100"
                      >
                        <ShieldCheck className="w-4 h-4 text-slate-500" />
                        <span>Security Audit Trail</span>
                      </Link>
                    )}
                  </div>

                  <div className="border-t border-slate-100 pt-1">
                    <button
                      onClick={handleLogout}
                      className="flex w-full items-center gap-2 rounded-md px-3 py-2 text-xs font-medium text-rose-600 hover:bg-rose-50 transition-colors"
                    >
                      <LogOut className="w-4 h-4" />
                      <span>Sign Out</span>
                    </button>
                  </div>
                </div>
              </>
            )}
          </div>
        )}
      </div>
    </header>
  );
};
