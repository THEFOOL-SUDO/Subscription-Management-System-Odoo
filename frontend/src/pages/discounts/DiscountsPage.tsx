import React, { useState, useEffect } from "react";
import { discountsApi } from "@/api/discounts";
import { DiscountRule } from "@/types/discount";
import {
  Tag,
  Plus,
  Percent,
  Loader2,
  AlertCircle,
  X,
  Sparkles,
} from "lucide-react";

export const DiscountsPage: React.FC = () => {
  const [discounts, setDiscounts] = useState<DiscountRule[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Create Modal
  const [isCreateOpen, setIsCreateOpen] = useState(false);
  const [code, setCode] = useState("");
  const [name, setName] = useState("");
  const [discountType, setDiscountType] = useState<"PERCENTAGE" | "FIXED_AMOUNT">("PERCENTAGE");
  const [discountValue, setDiscountValue] = useState("");
  const [minPurchase, setMinPurchase] = useState("");
  const [maxUses, setMaxUses] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    loadDiscounts();
  }, []);

  const loadDiscounts = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const res = await discountsApi.listDiscounts();
      setDiscounts(res.items);
    } catch (err: any) {
      setError(err?.response?.data?.detail || "Failed to load discount rules.");
    } finally {
      setIsLoading(false);
    }
  };

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!code || !name || !discountValue) return;
    setIsSubmitting(true);
    try {
      await discountsApi.createDiscount({
        code: code.trim().toUpperCase(),
        name,
        discount_type: discountType,
        discount_value: discountValue,
        min_purchase_amount: minPurchase ? minPurchase : undefined,
        max_uses: maxUses ? Number(maxUses) : undefined,
        is_active: true,
      });
      setIsCreateOpen(false);
      setCode("");
      setName("");
      setDiscountValue("");
      setMinPurchase("");
      setMaxUses("");
      loadDiscounts();
    } catch (err: any) {
      alert(err?.response?.data?.detail || "Failed to create discount rule.");
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
              <Tag className="h-6 w-6" />
            </span>
            <h1 className="text-2xl font-bold tracking-tight text-slate-900">Discount & Promo Rules</h1>
          </div>
          <p className="text-sm text-slate-500 mt-1">
            Configure promotional percentage cuts, fixed-amount credits, minimum purchase thresholds, and usage limits.
          </p>
        </div>

        <button
          onClick={() => setIsCreateOpen(true)}
          className="inline-flex items-center gap-2 px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg text-sm font-semibold shadow-sm transition-all"
        >
          <Plus className="h-4 w-4" />
          Add Discount Rule
        </button>
      </div>

      {isLoading ? (
        <div className="py-20 flex flex-col items-center justify-center text-slate-500 gap-3">
          <Loader2 className="h-8 w-8 animate-spin text-indigo-600" />
          <p className="text-sm">Loading discount rules...</p>
        </div>
      ) : error ? (
        <div className="p-4 bg-rose-50 border border-rose-200 rounded-lg text-rose-800 text-sm flex items-center gap-2">
          <AlertCircle className="h-5 w-5" />
          {error}
        </div>
      ) : discounts.length === 0 ? (
        <div className="bg-white rounded-xl border border-dashed border-slate-300 p-12 text-center">
          <Tag className="h-12 w-12 text-slate-400 mx-auto mb-3" />
          <h3 className="text-base font-semibold text-slate-900">No discount codes configured</h3>
          <p className="text-sm text-slate-500 mt-1 max-w-sm mx-auto">
            Create your first promo code or volume discount to incentivize new customer conversions.
          </p>
        </div>
      ) : (
        <div className="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
          <table className="w-full text-left text-xs text-slate-600">
            <thead className="bg-slate-50 border-b border-slate-200 text-slate-500 font-semibold uppercase tracking-wider text-[11px]">
              <tr>
                <th className="px-5 py-3">Code & Name</th>
                <th className="px-5 py-3">Discount Type</th>
                <th className="px-5 py-3">Value</th>
                <th className="px-5 py-3">Min Purchase</th>
                <th className="px-5 py-3">Usage</th>
                <th className="px-5 py-3">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {discounts.map((d) => (
                <tr key={d.id} className="hover:bg-slate-50/70 transition-colors">
                  <td className="px-5 py-4">
                    <div className="flex items-center gap-2">
                      <span className="font-mono font-bold text-xs bg-slate-100 text-slate-800 px-2 py-0.5 rounded border border-slate-200">
                        {d.code}
                      </span>
                      <span className="font-semibold text-slate-900">{d.name}</span>
                    </div>
                    {d.description && <div className="text-slate-400 text-[11px] mt-0.5">{d.description}</div>}
                  </td>
                  <td className="px-5 py-4">
                    <span className="inline-flex items-center gap-1 font-medium text-slate-700">
                      {d.discount_type === "PERCENTAGE" ? (
                        <>
                          <Percent className="h-3.5 w-3.5 text-indigo-600" />
                          Percentage
                        </>
                      ) : (
                        <>
                          <Sparkles className="h-3.5 w-3.5 text-emerald-600" />
                          Fixed Credit
                        </>
                      )}
                    </span>
                  </td>
                  <td className="px-5 py-4 font-bold text-slate-900">
                    {d.discount_type === "PERCENTAGE" ? `${d.discount_value}%` : `₹${d.discount_value}`}
                  </td>
                  <td className="px-5 py-4">
                    {d.min_purchase_amount ? `₹${d.min_purchase_amount}` : "None"}
                  </td>
                  <td className="px-5 py-4">
                    <span className="font-semibold text-slate-800">{d.current_uses}</span>
                    {d.max_uses ? ` / ${d.max_uses}` : " (unlimited)"}
                  </td>
                  <td className="px-5 py-4">
                    <span
                      className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-full font-semibold text-[11px] ${
                        d.is_active
                          ? "bg-emerald-50 text-emerald-700 border border-emerald-200"
                          : "bg-slate-100 text-slate-600"
                      }`}
                    >
                      {d.is_active ? "Active" : "Disabled"}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Create Modal */}
      {isCreateOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/50 backdrop-blur-sm p-4">
          <div className="bg-white rounded-xl shadow-xl border border-slate-200 w-full max-w-md overflow-hidden">
            <div className="px-5 py-4 border-b border-slate-200 flex items-center justify-between">
              <h3 className="text-base font-bold text-slate-900">Add Discount Rule</h3>
              <button onClick={() => setIsCreateOpen(false)} className="text-slate-400 hover:text-slate-600">
                <X className="h-5 w-5" />
              </button>
            </div>

            <form onSubmit={handleCreate} className="p-5 space-y-4">
              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">Promo Code *</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. SAVE20"
                  value={code}
                  onChange={(e) => setCode(e.target.value)}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg text-xs font-mono uppercase focus:ring-2 focus:ring-indigo-500 outline-none"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">Rule Name *</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Q4 Growth Promo"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-indigo-500 outline-none"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">Type *</label>
                  <select
                    value={discountType}
                    onChange={(e: any) => setDiscountType(e.target.value)}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-indigo-500 outline-none"
                  >
                    <option value="PERCENTAGE">Percentage (%)</option>
                    <option value="FIXED_AMOUNT">Fixed Amount (₹)</option>
                  </select>
                </div>
                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">Value *</label>
                  <input
                    type="number"
                    step="0.01"
                    required
                    placeholder="e.g. 20"
                    value={discountValue}
                    onChange={(e) => setDiscountValue(e.target.value)}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-indigo-500 outline-none"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">Min Purchase (₹)</label>
                  <input
                    type="number"
                    placeholder="Optional"
                    value={minPurchase}
                    onChange={(e) => setMinPurchase(e.target.value)}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-indigo-500 outline-none"
                  />
                </div>
                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">Max Redemptions</label>
                  <input
                    type="number"
                    placeholder="Optional"
                    value={maxUses}
                    onChange={(e) => setMaxUses(e.target.value)}
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
                  {isSubmitting ? "Saving..." : "Create Rule"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
