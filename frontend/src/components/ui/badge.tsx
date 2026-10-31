import React from "react";
import { cn } from "@/lib/utils";
import { UserRole } from "@/types";

export interface BadgeProps extends React.HTMLAttributes<HTMLDivElement> {
  variant?: "default" | "secondary" | "outline" | "success" | "warning" | "danger" | "admin" | "staff" | "customer";
}

export const Badge: React.FC<BadgeProps> = ({ className, variant = "default", ...props }) => {
  const variants = {
    default: "bg-slate-900 text-white",
    secondary: "bg-slate-100 text-slate-800",
    outline: "border border-slate-300 text-slate-700 bg-white",
    success: "bg-emerald-50 text-emerald-700 border border-emerald-200",
    warning: "bg-amber-50 text-amber-700 border border-amber-200",
    danger: "bg-rose-50 text-rose-700 border border-rose-200",
    admin: "bg-purple-50 text-purple-700 border border-purple-200 font-semibold",
    staff: "bg-blue-50 text-blue-700 border border-blue-200 font-semibold",
    customer: "bg-slate-100 text-slate-700 border border-slate-200 font-semibold",
  };

  return (
    <div
      className={cn(
        "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs transition-colors tracking-wide",
        variants[variant],
        className
      )}
      {...props}
    />
  );
};

export const RoleBadge: React.FC<{ role: UserRole; className?: string }> = ({ role, className }) => {
  const roleVariants: Record<UserRole, "admin" | "staff" | "customer"> = {
    ADMIN: "admin",
    STAFF: "staff",
    CUSTOMER: "customer",
  };
  return (
    <Badge variant={roleVariants[role]} className={className}>
      {role}
    </Badge>
  );
};
