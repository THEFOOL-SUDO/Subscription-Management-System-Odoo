import React from "react";
import { Link } from "react-router-dom";
import { useAuth } from "@/hooks/useAuth";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { formatDate } from "@/lib/utils";
import {
  CreditCard,
  FileText,
  ShieldCheck,
  CheckCircle2,
  Clock,
} from "lucide-react";

export const CustomerPortal: React.FC = () => {
  const { user } = useAuth();
  if (!user) return null;

  return (
    <div className="space-y-6">
      {/* Welcome Banner */}
      <div className="rounded-xl border border-slate-200/90 bg-white p-6 shadow-xs flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <div className="flex items-center gap-2">
            <h1 className="text-xl font-bold text-slate-900">Welcome, {user.full_name}</h1>
            <Badge variant="success" className="gap-1">
              <CheckCircle2 className="w-3 h-3" />
              Verified Customer
            </Badge>
          </div>
          <p className="text-xs text-slate-500 mt-1">
            Account Email: <span className="font-mono text-slate-700">{user.email}</span> • Member since {formatDate(user.created_at)}
          </p>
        </div>
        <Link to="/profile">
          <Button variant="outline" size="sm" className="gap-1.5 self-start md:self-auto">
            <ShieldCheck className="w-4 h-4 text-slate-600" />
            Security & Profile
          </Button>
        </Link>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Subscriptions Card with Meaningful Empty State */}
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-3">
            <div>
              <CardTitle className="text-base font-semibold">Active Subscriptions</CardTitle>
              <CardDescription className="text-xs">
                Your managed software plans and billing cadences.
              </CardDescription>
            </div>
            <CreditCard className="w-5 h-5 text-slate-400" />
          </CardHeader>
          <CardContent>
            <div className="rounded-xl border border-dashed border-slate-200 bg-slate-50/50 p-8 text-center">
              <div className="mx-auto flex h-10 w-10 items-center justify-center rounded-full bg-slate-100 text-slate-500 mb-3">
                <Clock className="w-5 h-5" />
              </div>
              <h4 className="text-sm font-semibold text-slate-800">No Active Subscriptions</h4>
              <p className="mt-1 text-xs text-slate-500 max-w-sm mx-auto leading-relaxed">
                You do not have any active subscriptions yet. When a sales quotation is issued and accepted, your subscription plan, term, and renewal details will be displayed here.
              </p>
            </div>
          </CardContent>
        </Card>

        {/* Invoices Card with Meaningful Empty State */}
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-3">
            <div>
              <CardTitle className="text-base font-semibold">Invoices & Statements</CardTitle>
              <CardDescription className="text-xs">
                Billing history and automated tax invoices.
              </CardDescription>
            </div>
            <FileText className="w-5 h-5 text-slate-400" />
          </CardHeader>
          <CardContent>
            <div className="rounded-xl border border-dashed border-slate-200 bg-slate-50/50 p-8 text-center">
              <div className="mx-auto flex h-10 w-10 items-center justify-center rounded-full bg-slate-100 text-slate-500 mb-3">
                <FileText className="w-5 h-5" />
              </div>
              <h4 className="text-sm font-semibold text-slate-800">No Invoices Generated</h4>
              <p className="mt-1 text-xs text-slate-500 max-w-sm mx-auto leading-relaxed">
                No invoices have been issued for your account. Once your recurring billing cycle begins, itemized invoices with GST/VAT calculations will be downloadable here.
              </p>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Account Security Overview Card */}
      <Card>
        <CardHeader className="pb-3">
          <CardTitle className="text-base font-semibold">Account Protection Status</CardTitle>
          <CardDescription className="text-xs">
            Your credentials and session are protected by Brightloop Enterprise Identity standards.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-xs">
            <div className="rounded-lg border border-slate-100 bg-slate-50 p-3">
              <span className="font-semibold text-slate-800 block">Password Encryption</span>
              <span className="text-slate-500 text-[11px] mt-0.5 block">Argon2id (Memory-hard key derivation)</span>
            </div>
            <div className="rounded-lg border border-slate-100 bg-slate-50 p-3">
              <span className="font-semibold text-slate-800 block">Session Integrity</span>
              <span className="text-slate-500 text-[11px] mt-0.5 block">Rotated httpOnly tokens & reuse detection</span>
            </div>
            <div className="rounded-lg border border-slate-100 bg-slate-50 p-3">
              <span className="font-semibold text-slate-800 block">Audit Tracking</span>
              <span className="text-slate-500 text-[11px] mt-0.5 block">All account access events are securely audited</span>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};
