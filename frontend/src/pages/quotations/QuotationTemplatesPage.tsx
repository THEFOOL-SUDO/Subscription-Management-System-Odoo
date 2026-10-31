import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { quotationsApi } from "@/api/quotations";
import { plansApi } from "@/api/plans";
import { customersApi } from "@/api/customers";
import { QuotationTemplate } from "@/types/quotation";
import { Customer, SubscriptionPlan } from "@/types";
import { useAuth } from "@/contexts/AuthContext";
import {
  FileText,
  Plus,
  ArrowRight,
  CheckCircle2,
  Loader2,
  AlertCircle,
  X,
  FileCheck,
} from "lucide-react";

export const QuotationTemplatesPage: React.FC = () => {
  const navigate = useNavigate();
  const { user } = useAuth();
  const [templates, setTemplates] = useState<QuotationTemplate[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Convert Modal State
  const [convertingTemplate, setConvertingTemplate] = useState<QuotationTemplate | null>(null);
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [selectedCustomerId, setSelectedCustomerId] = useState("");
  const [startDate, setStartDate] = useState(new Date().toISOString().split("T")[0]);
  const [convertNotes, setConvertNotes] = useState("");
  const [isConverting, setIsConverting] = useState(false);
  const [convertError, setConvertError] = useState<string | null>(null);

  // Create Modal State
  const [isCreateOpen, setIsCreateOpen] = useState(false);
  const [plans, setPlans] = useState<SubscriptionPlan[]>([]);
  const [newCode, setNewCode] = useState("");
  const [newName, setNewName] = useState("");
  const [newPlanId, setNewPlanId] = useState("");
  const [newValidityDays, setNewValidityDays] = useState(30);
  const [newTerms, setNewTerms] = useState("NET_30");
  const [newTaxRate, setNewTaxRate] = useState("18.00");
  const [newDiscount, setNewDiscount] = useState("0.00");
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    loadTemplates();
  }, []);

  const loadTemplates = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const res = await quotationsApi.listQuotations();
      setTemplates(res.items);
    } catch (err: any) {
      setError(err?.response?.data?.detail || "Failed to load quotation templates.");
    } finally {
      setIsLoading(false);
    }
  };

  const openConvertModal = async (tpl: QuotationTemplate) => {
    setConvertingTemplate(tpl);
    setConvertError(null);
    try {
      const custRes = await customersApi.listCustomers({ limit: 100 });
      setCustomers(custRes.items);
      if (custRes.items.length > 0) {
        setSelectedCustomerId(custRes.items[0].id);
      }
    } catch (err: any) {
      console.error("Failed to load customers for conversion", err);
    }
  };

  const handleConvert = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!convertingTemplate || !selectedCustomerId) return;
    setIsConverting(true);
    setConvertError(null);

    try {
      const sub = await quotationsApi.convertToSubscription(convertingTemplate.id, {
        customer_id: selectedCustomerId,
        start_date: new Date(startDate).toISOString(),
        notes: convertNotes || undefined,
      });
      setConvertingTemplate(null);
      navigate(`/subscriptions/${sub.id}`);
    } catch (err: any) {
      setConvertError(err?.response?.data?.detail || "Failed to convert quotation to subscription.");
    } finally {
      setIsConverting(false);
    }
  };

  const openCreateModal = async () => {
    setIsCreateOpen(true);
    try {
      const plansRes = await plansApi.listPlans({ status: "ACTIVE" as any });
      setPlans(plansRes.items);
      if (plansRes.items.length > 0) {
        setNewPlanId(plansRes.items[0].id);
      }
    } catch (err) {
      console.error("Failed to fetch plans", err);
    }
  };

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newCode || !newName || !newPlanId) return;
    setIsSubmitting(true);
    try {
      await quotationsApi.createQuotation({
        code: newCode.toUpperCase(),
        name: newName,
        plan_id: newPlanId,
        validity_days: newValidityDays,
        payment_terms: newTerms,
        tax_rate: newTaxRate,
        discount_amount: newDiscount,
        is_active: true,
      });
      setIsCreateOpen(false);
      setNewCode("");
      setNewName("");
      loadTemplates();
    } catch (err: any) {
      alert(err?.response?.data?.detail || "Failed to create quotation template.");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="space-y-6 animate-in fade-in duration-150">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-slate-200 pb-5">
        <div>
          <div className="flex items-center gap-2">
            <span className="p-2 bg-indigo-50 text-indigo-700 rounded-lg">
              <FileCheck className="h-6 w-6" />
            </span>
            <h1 className="text-2xl font-bold tracking-tight text-slate-900">Quotation Templates</h1>
          </div>
          <p className="text-sm text-slate-500 mt-1">
            Predefined commercial proposal structures with bundled items, terms, and direct 1-click subscription conversion.
          </p>
        </div>

        {user?.role !== "CUSTOMER" && (
          <button
            onClick={openCreateModal}
            className="inline-flex items-center gap-2 px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg text-sm font-semibold shadow-sm transition-all"
          >
            <Plus className="h-4 w-4" />
            Create Template
          </button>
        )}
      </div>

      {/* Main Content */}
      {isLoading ? (
        <div className="py-20 flex flex-col items-center justify-center text-slate-500 gap-3">
          <Loader2 className="h-8 w-8 animate-spin text-indigo-600" />
          <p className="text-sm">Loading quotation templates...</p>
        </div>
      ) : error ? (
        <div className="p-4 bg-rose-50 border border-rose-200 rounded-lg text-rose-800 text-sm flex items-center gap-2">
          <AlertCircle className="h-5 w-5" />
          {error}
        </div>
      ) : templates.length === 0 ? (
        <div className="bg-white rounded-xl border border-dashed border-slate-300 p-12 text-center">
          <FileText className="h-12 w-12 text-slate-400 mx-auto mb-3" />
          <h3 className="text-base font-semibold text-slate-900">No quotation templates configured</h3>
          <p className="text-sm text-slate-500 mt-1 max-w-sm mx-auto">
            Create standard quotation templates to expedite enterprise deal closing and quotation conversions.
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          {templates.map((tpl) => (
            <div
              key={tpl.id}
              className="bg-white rounded-xl border border-slate-200 shadow-sm hover:shadow-md transition-shadow flex flex-col justify-between overflow-hidden"
            >
              <div className="p-5">
                <div className="flex items-center justify-between mb-2">
                  <span className="font-mono text-xs font-bold text-indigo-700 bg-indigo-50 px-2 py-0.5 rounded">
                    {tpl.code}
                  </span>
                  <span
                    className={`text-[11px] font-semibold px-2 py-0.5 rounded-full ${
                      tpl.is_active ? "bg-emerald-50 text-emerald-700 border border-emerald-200" : "bg-slate-100 text-slate-600"
                    }`}
                  >
                    {tpl.is_active ? "Active" : "Archived"}
                  </span>
                </div>

                <h3 className="text-base font-bold text-slate-900">{tpl.name}</h3>
                {tpl.description && (
                  <p className="text-xs text-slate-500 mt-1 line-clamp-2">{tpl.description}</p>
                )}

                <div className="mt-4 pt-4 border-t border-slate-100 space-y-2 text-xs text-slate-600">
                  <div className="flex justify-between">
                    <span className="text-slate-500">Target Plan:</span>
                    <span className="font-semibold text-slate-800">{tpl.plan_name || "Custom Plan"}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-slate-500">Validity:</span>
                    <span className="font-semibold text-slate-800">{tpl.validity_days} Days</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-slate-500">Terms & Tax:</span>
                    <span className="font-semibold text-slate-800">{tpl.payment_terms} · {tpl.tax_rate}% Tax</span>
                  </div>
                  {Number(tpl.discount_amount) > 0 && (
                    <div className="flex justify-between text-indigo-600">
                      <span>Preset Discount:</span>
                      <span className="font-bold">₹{tpl.discount_amount}</span>
                    </div>
                  )}
                  <div className="flex justify-between text-slate-500">
                    <span>Line Items:</span>
                    <span className="font-semibold text-slate-700">{tpl.items?.length || 0} configured</span>
                  </div>
                </div>
              </div>

              {user?.role !== "CUSTOMER" && (
                <div className="bg-slate-50 px-5 py-3 border-t border-slate-100 flex items-center justify-end">
                  <button
                    onClick={() => openConvertModal(tpl)}
                    className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg text-xs font-semibold shadow-sm transition-all"
                  >
                    <span>Convert to Subscription</span>
                    <ArrowRight className="h-3.5 w-3.5" />
                  </button>
                </div>
              )}
            </div>
          ))}
        </div>
      )}

      {/* Convert to Subscription Modal */}
      {convertingTemplate && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/50 backdrop-blur-sm p-4">
          <div className="bg-white rounded-xl shadow-xl border border-slate-200 w-full max-w-md overflow-hidden">
            <div className="px-5 py-4 border-b border-slate-200 flex items-center justify-between">
              <div>
                <h3 className="text-base font-bold text-slate-900">Convert Quotation to Subscription</h3>
                <p className="text-xs text-slate-500">Template: {convertingTemplate.name} ({convertingTemplate.code})</p>
              </div>
              <button
                onClick={() => setConvertingTemplate(null)}
                className="text-slate-400 hover:text-slate-600"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            <form onSubmit={handleConvert} className="p-5 space-y-4">
              {convertError && (
                <div className="p-3 bg-rose-50 border border-rose-200 rounded text-rose-800 text-xs">
                  {convertError}
                </div>
              )}

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">Select Customer *</label>
                <select
                  required
                  value={selectedCustomerId}
                  onChange={(e) => setSelectedCustomerId(e.target.value)}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-indigo-500 outline-none"
                >
                  <option value="">-- Choose Customer --</option>
                  {customers.map((c) => (
                    <option key={c.id} value={c.id}>
                      {c.name} ({c.email})
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">Subscription Start Date *</label>
                <input
                  type="date"
                  required
                  value={startDate}
                  onChange={(e) => setStartDate(e.target.value)}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-indigo-500 outline-none"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">Custom Notes / Order Ref</label>
                <textarea
                  rows={2}
                  value={convertNotes}
                  onChange={(e) => setConvertNotes(e.target.value)}
                  placeholder="Optional internal order notes..."
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-indigo-500 outline-none"
                />
              </div>

              <div className="p-3 bg-indigo-50/60 rounded-lg text-xs text-indigo-900 border border-indigo-100 flex items-start gap-2">
                <CheckCircle2 className="h-4 w-4 text-indigo-600 shrink-0 mt-0.5" />
                <span>
                  The subscription will be created in <strong>QUOTATION</strong> state with line items, tax rate, and pricing pre-filled from this template.
                </span>
              </div>

              <div className="flex justify-end gap-2 pt-2 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setConvertingTemplate(null)}
                  className="px-4 py-2 border border-slate-300 rounded-lg text-xs font-semibold text-slate-700 hover:bg-slate-50"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isConverting}
                  className="px-4 py-2 bg-indigo-600 hover:bg-indigo-700 disabled:opacity-50 text-white rounded-lg text-xs font-bold flex items-center gap-1.5"
                >
                  {isConverting && <Loader2 className="h-4 w-4 animate-spin" />}
                  {isConverting ? "Converting..." : "Generate Subscription"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Create Template Modal */}
      {isCreateOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/50 backdrop-blur-sm p-4">
          <div className="bg-white rounded-xl shadow-xl border border-slate-200 w-full max-w-lg overflow-hidden">
            <div className="px-5 py-4 border-b border-slate-200 flex items-center justify-between">
              <h3 className="text-base font-bold text-slate-900">Create Quotation Template</h3>
              <button onClick={() => setIsCreateOpen(false)} className="text-slate-400 hover:text-slate-600">
                <X className="h-5 w-5" />
              </button>
            </div>

            <form onSubmit={handleCreate} className="p-5 space-y-4">
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">Template Code *</label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. QT-GROWTH-ANNUAL"
                    value={newCode}
                    onChange={(e) => setNewCode(e.target.value)}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg text-xs font-mono uppercase focus:ring-2 focus:ring-indigo-500 outline-none"
                  />
                </div>
                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">Template Name *</label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. Growth Annual Pro Package"
                    value={newName}
                    onChange={(e) => setNewName(e.target.value)}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-indigo-500 outline-none"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">Associated Subscription Plan *</label>
                <select
                  required
                  value={newPlanId}
                  onChange={(e) => setNewPlanId(e.target.value)}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-indigo-500 outline-none"
                >
                  <option value="">-- Choose Active Plan --</option>
                  {plans.map((p) => (
                    <option key={p.id} value={p.id}>
                      {p.name} ({p.code})
                    </option>
                  ))}
                </select>
              </div>

              <div className="grid grid-cols-4 gap-3">
                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">Validity (Days)</label>
                  <input
                    type="number"
                    min="1"
                    max="365"
                    value={newValidityDays}
                    onChange={(e) => setNewValidityDays(Number(e.target.value))}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-indigo-500 outline-none"
                  />
                </div>
                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">Payment Terms</label>
                  <select
                    value={newTerms}
                    onChange={(e) => setNewTerms(e.target.value)}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-indigo-500 outline-none"
                  >
                    <option value="IMMEDIATE">IMMEDIATE</option>
                    <option value="NET_15">NET 15</option>
                    <option value="NET_30">NET 30</option>
                    <option value="NET_60">NET 60</option>
                  </select>
                </div>
                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">Tax Rate (%)</label>
                  <input
                    type="text"
                    value={newTaxRate}
                    onChange={(e) => setNewTaxRate(e.target.value)}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-indigo-500 outline-none"
                  />
                </div>
                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">Discount (₹)</label>
                  <input
                    type="text"
                    value={newDiscount}
                    onChange={(e) => setNewDiscount(e.target.value)}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-indigo-500 outline-none"
                  />
                </div>
              </div>

              <div className="flex justify-end gap-2 pt-2 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setIsCreateOpen(false)}
                  className="px-4 py-2 border border-slate-300 rounded-lg text-xs font-semibold text-slate-700 hover:bg-slate-50"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isSubmitting}
                  className="px-4 py-2 bg-indigo-600 hover:bg-indigo-700 disabled:opacity-50 text-white rounded-lg text-xs font-bold flex items-center gap-1.5"
                >
                  {isSubmitting && <Loader2 className="h-4 w-4 animate-spin" />}
                  {isSubmitting ? "Saving..." : "Create Template"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
