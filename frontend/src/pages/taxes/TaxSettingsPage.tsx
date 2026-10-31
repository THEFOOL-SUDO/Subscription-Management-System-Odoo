import React, { useState, useEffect } from "react";
import { taxesApi } from "@/api/taxes";
import { TaxRule } from "@/types/tax";
import {
  Receipt,
  Plus,
  CheckCircle2,
  Loader2,
  AlertCircle,
  X,
  Globe,
} from "lucide-react";

export const TaxSettingsPage: React.FC = () => {
  const [taxes, setTaxes] = useState<TaxRule[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [isCreateOpen, setIsCreateOpen] = useState(false);
  const [name, setName] = useState("");
  const [rate, setRate] = useState("18.00");
  const [country, setCountry] = useState("IND");
  const [state, setState] = useState("");
  const [isDefault, setIsDefault] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    loadTaxes();
  }, []);

  const loadTaxes = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const res = await taxesApi.listTaxRules();
      setTaxes(res.items);
    } catch (err: any) {
      setError(err?.response?.data?.detail || "Failed to load tax rules.");
    } finally {
      setIsLoading(false);
    }
  };

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name || !rate) return;
    setIsSubmitting(true);
    try {
      await taxesApi.createTaxRule({
        name,
        tax_rate: rate,
        country,
        state: state || undefined,
        is_default: isDefault,
        is_active: true,
      });
      setIsCreateOpen(false);
      setName("");
      setRate("18.00");
      setState("");
      setIsDefault(false);
      loadTaxes();
    } catch (err: any) {
      alert(err?.response?.data?.detail || "Failed to create tax rule.");
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
              <Receipt className="h-6 w-6" />
            </span>
            <h1 className="text-2xl font-bold tracking-tight text-slate-900">Tax Configurations</h1>
          </div>
          <p className="text-sm text-slate-500 mt-1">
            Manage jurisdiction-specific tax schedules, India GST slabs, and automated line-item fiscal calculations.
          </p>
        </div>

        <button
          onClick={() => setIsCreateOpen(true)}
          className="inline-flex items-center gap-2 px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg text-sm font-semibold shadow-sm transition-all"
        >
          <Plus className="h-4 w-4" />
          Add Tax Schedule
        </button>
      </div>

      {isLoading ? (
        <div className="py-20 flex flex-col items-center justify-center text-slate-500 gap-3">
          <Loader2 className="h-8 w-8 animate-spin text-indigo-600" />
          <p className="text-sm">Loading tax rules...</p>
        </div>
      ) : error ? (
        <div className="p-4 bg-rose-50 border border-rose-200 rounded-lg text-rose-800 text-sm flex items-center gap-2">
          <AlertCircle className="h-5 w-5" />
          {error}
        </div>
      ) : taxes.length === 0 ? (
        <div className="bg-white rounded-xl border border-dashed border-slate-300 p-12 text-center">
          <Receipt className="h-12 w-12 text-slate-400 mx-auto mb-3" />
          <h3 className="text-base font-semibold text-slate-900">No tax rules configured</h3>
          <p className="text-sm text-slate-500 mt-1 max-w-sm mx-auto">
            Configure default 18% GST or region-specific fiscal schedules for automated billing calculations.
          </p>
        </div>
      ) : (
        <div className="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
          <div className="overflow-x-auto max-h-[700px] overflow-y-auto">
            <table className="w-full text-left text-xs text-slate-600">
              <thead className="sticky top-0 bg-slate-50/95 backdrop-blur-xs z-10 border-b border-slate-200 text-slate-500 font-semibold uppercase tracking-wider text-[11px]">
                <tr>
                <th className="px-5 py-3">Tax Name</th>
                <th className="px-5 py-3">Rate</th>
                <th className="px-5 py-3">Jurisdiction</th>
                <th className="px-5 py-3">Default Flag</th>
                <th className="px-5 py-3">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {taxes.map((t) => (
                <tr key={t.id} className="hover:bg-slate-50/70 transition-colors">
                  <td className="px-5 py-4 font-semibold text-slate-900">
                    {t.name}
                  </td>
                  <td className="px-5 py-4 font-mono font-bold text-slate-800 text-sm">
                    {t.tax_rate}%
                  </td>
                  <td className="px-5 py-4">
                    <span className="inline-flex items-center gap-1 font-medium text-slate-700">
                      <Globe className="h-3.5 w-3.5 text-slate-400" />
                      {t.country} {t.state ? `(${t.state})` : ""}
                    </span>
                  </td>
                  <td className="px-5 py-4">
                    {t.is_default ? (
                      <span className="inline-flex items-center gap-1 text-[11px] font-bold text-indigo-700 bg-indigo-50 border border-indigo-200 px-2 py-0.5 rounded-full">
                        <CheckCircle2 className="h-3 w-3" />
                        Default Rate
                      </span>
                    ) : (
                      <span className="text-slate-400">—</span>
                    )}
                  </td>
                  <td className="px-5 py-4">
                    <span
                      className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-full font-semibold text-[11px] ${
                        t.is_active
                          ? "bg-emerald-50 text-emerald-700 border border-emerald-200"
                          : "bg-slate-100 text-slate-600"
                      }`}
                    >
                      {t.is_active ? "Active" : "Inactive"}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          </div>
        </div>
      )}

      {/* Create Modal */}
      {isCreateOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/50 backdrop-blur-sm p-4">
          <div className="bg-white rounded-xl shadow-xl border border-slate-200 w-full max-w-md overflow-hidden">
            <div className="px-5 py-4 border-b border-slate-200 flex items-center justify-between">
              <h3 className="text-base font-bold text-slate-900">Add Tax Schedule</h3>
              <button onClick={() => setIsCreateOpen(false)} className="text-slate-400 hover:text-slate-600">
                <X className="h-5 w-5" />
              </button>
            </div>

            <form onSubmit={handleCreate} className="p-5 space-y-4">
              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">Schedule Name *</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Standard GST 18%"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-indigo-500 outline-none"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">Tax Rate (%) *</label>
                  <input
                    type="number"
                    step="0.01"
                    min="0"
                    max="100"
                    required
                    value={rate}
                    onChange={(e) => setRate(e.target.value)}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg text-xs font-mono font-bold focus:ring-2 focus:ring-indigo-500 outline-none"
                  />
                </div>
                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">Country Code</label>
                  <input
                    type="text"
                    maxLength={3}
                    value={country}
                    onChange={(e) => setCountry(e.target.value.toUpperCase())}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg text-xs font-mono uppercase focus:ring-2 focus:ring-indigo-500 outline-none"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">State / Province (Optional)</label>
                <input
                  type="text"
                  placeholder="e.g. Karnataka"
                  value={state}
                  onChange={(e) => setState(e.target.value)}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg text-xs focus:ring-2 focus:ring-indigo-500 outline-none"
                />
              </div>

              <div className="flex items-center gap-2 pt-1">
                <input
                  type="checkbox"
                  id="isDefault"
                  checked={isDefault}
                  onChange={(e) => setIsDefault(e.target.checked)}
                  className="rounded border-slate-300 text-indigo-600 focus:ring-indigo-500 h-4 w-4"
                />
                <label htmlFor="isDefault" className="text-xs font-medium text-slate-700">
                  Set as system default tax rate for new subscriptions & invoices
                </label>
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
                  {isSubmitting ? "Saving..." : "Create Schedule"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
