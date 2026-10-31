import React, { useState } from "react";
import { useParams, Link } from "react-router-dom";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { plansApi } from "@/api/plans";
import { productsApi } from "@/api/products";
import { pricingApi } from "@/api/pricing";
import {
  PlanProduct,
  PlanProductCreateInput,
  PlanProductUpdateInput,
  PlanStatus,
} from "@/types";
import { useAuth } from "@/hooks/useAuth";
import { useToast } from "@/components/ui/toast";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import {
  ArrowLeft,
  Layers,
  Package,
  Plus,
  Trash2,
  AlertCircle,
  Loader2,
  Clock,
  Play,
  Pause,
  Archive,
  Calculator,
} from "lucide-react";

export const PlanDetailsPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const { user } = useAuth();
  const { success, error: toastError } = useToast();
  const queryClient = useQueryClient();
  const isAdmin = user?.role === "ADMIN";

  // Bundled Item Modals
  const [isAddOpen, setIsAddOpen] = useState(false);
  const [selectedProductId, setSelectedProductId] = useState("");
  const [selectedVariantId, setSelectedVariantId] = useState<string>("");
  const [defaultQuantity, setDefaultQuantity] = useState(1);
  const [priceOverride, setPriceOverride] = useState("");

  // Edit Line Item Modal
  const [editingItem, setEditingItem] = useState<PlanProduct | null>(null);
  const [editQty, setEditQty] = useState(1);
  const [editOverride, setEditOverride] = useState("");
  const [editIsActive, setEditIsActive] = useState(true);

  // Live price calculation preview state for Add Product modal
  const [livePreview, setLivePreview] = useState<string | null>(null);
  const [isPreviewLoading, setIsPreviewLoading] = useState(false);

  // Fetch plan
  const { data: plan, isLoading, error } = useQuery({
    queryKey: ["plan", id],
    queryFn: () => plansApi.getPlan(id!),
    enabled: !!id,
  });

  // Fetch candidate products matching plan currency
  const { data: catalogData } = useQuery({
    queryKey: ["catalog-candidates", plan?.currency],
    queryFn: () =>
      productsApi.listProducts({
        is_active: true,
        is_archived: false,
        limit: 100,
      }),
    enabled: !!plan?.currency,
  });

  // Filter catalog products to enforce currency homogeneity
  const candidateProducts = (catalogData?.items || []).filter(
    (p) => p.currency.toUpperCase() === plan?.currency.toUpperCase()
  );

  const selectedProduct = candidateProducts.find(
    (p) => p.id === selectedProductId
  );

  // Status transition mutation
  const statusMutation = useMutation({
    mutationFn: (newStatus: PlanStatus) =>
      plansApi.updatePlanStatus(id!, newStatus),
    onSuccess: (updated) => {
      queryClient.invalidateQueries({ queryKey: ["plan", id] });
      queryClient.invalidateQueries({ queryKey: ["plans"] });
      success(`Plan status changed to ${updated.status}`, "Status Updated");
    },
    onError: (err: any) => {
      toastError(err.response?.data?.detail || "Status change failed.", "Transition Rejected");
    },
  });

  // Add bundled product mutation
  const addBundledMutation = useMutation({
    mutationFn: (data: PlanProductCreateInput) =>
      plansApi.addBundledProduct(id!, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["plan", id] });
      success("Successfully added product to subscription plan.", "Product Bundled");
      setIsAddOpen(false);
      setSelectedProductId("");
      setSelectedVariantId("");
      setDefaultQuantity(1);
      setPriceOverride("");
      setLivePreview(null);
    },
    onError: (err: any) => {
      toastError(err.response?.data?.detail || "Could not bundle product.", "Failed to Add Product");
    },
  });

  // Update bundled line item mutation
  const updateLineItemMutation = useMutation({
    mutationFn: ({
      lineItemId,
      data,
    }: {
      lineItemId: string;
      data: PlanProductUpdateInput;
    }) => plansApi.updateBundledProduct(id!, lineItemId, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["plan", id] });
      success("Bundle line item has been updated.", "Line Item Updated");
      setEditingItem(null);
    },
    onError: (err: any) => {
      toastError(err.response?.data?.detail || "Could not update line item.", "Update Failed");
    },
  });

  // Remove bundled item mutation
  const removeBundledMutation = useMutation({
    mutationFn: (lineItemId: string) =>
      plansApi.removeBundledProduct(id!, lineItemId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["plan", id] });
      success("Bundled component was removed from plan.", "Item Removed");
    },
    onError: (err: any) => {
      toastError(err.response?.data?.detail || "Could not remove item.", "Removal Failed");
    },
  });

  // Recalculate live preview
  const handleCalculatePreview = async () => {
    if (!selectedProductId || !plan) return;
    setIsPreviewLoading(true);
    try {
      const res = await pricingApi.calculatePrices({
        currency: plan.currency,
        items: [
          {
            product_id: selectedProductId,
            variant_id: selectedVariantId || undefined,
            quantity: defaultQuantity,
            price_override: priceOverride
              ? Number(priceOverride).toFixed(4)
              : undefined,
          },
        ],
      });
      if (res.items.length > 0) {
        setLivePreview(res.items[0].effective_unit_price);
      }
    } catch (e: any) {
      setLivePreview(null);
    } finally {
      setIsPreviewLoading(false);
    }
  };

  const handleAddBundledSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedProductId) return;

    addBundledMutation.mutate({
      product_id: selectedProductId,
      variant_id: selectedVariantId || null,
      default_quantity: defaultQuantity,
      price_override: priceOverride ? Number(priceOverride).toFixed(4) : null,
      is_active: true,
    });
  };

  const startEditItem = (item: PlanProduct) => {
    setEditingItem(item);
    setEditQty(item.default_quantity);
    setEditOverride(item.price_override || "");
    setEditIsActive(item.is_active);
  };

  const handleSaveItemEdit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingItem) return;

    updateLineItemMutation.mutate({
      lineItemId: editingItem.id,
      data: {
        default_quantity: editQty,
        price_override: editOverride ? Number(editOverride).toFixed(4) : null,
        is_active: editIsActive,
      },
    });
  };

  if (isLoading) {
    return (
      <div className="p-16 text-center">
        <Loader2 className="w-8 h-8 animate-spin text-indigo-600 mx-auto mb-3" />
        <p className="text-sm text-slate-500 font-medium">
          Loading subscription plan record...
        </p>
      </div>
    );
  }

  if (error || !plan) {
    return (
      <div className="p-12 text-center text-rose-600 bg-white rounded-xl border border-rose-200">
        <AlertCircle className="w-10 h-10 mx-auto mb-3" />
        <h3 className="text-lg font-semibold">Plan Not Found</h3>
        <p className="text-sm text-slate-500 mt-1">
          The requested subscription plan does not exist.
        </p>
        <Link to="/plans" className="inline-block mt-4">
          <Button variant="outline" className="gap-2">
            <ArrowLeft className="w-4 h-4" />
            Back to Plans
          </Button>
        </Link>
      </div>
    );
  }

  const formatPrice = (price: string, currency: string) => {
    const num = Number(price);
    const sym = currency === "INR" ? "₹" : "$";
    return `${sym}${num.toLocaleString("en-IN", {
      minimumFractionDigits: 2,
      maximumFractionDigits: 4,
    })}`;
  };

  const isArchived = plan.status === "ARCHIVED";

  return (
    <div className="space-y-6">
      {/* Back Link & Header */}
      <div>
        <Link
          to="/plans"
          className="inline-flex items-center gap-1.5 text-xs font-semibold text-slate-500 hover:text-slate-900 transition-colors mb-3"
        >
          <ArrowLeft className="w-3.5 h-3.5" />
          Back to Subscription Plans
        </Link>

        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 bg-white p-6 rounded-xl border border-slate-200/80 shadow-xs">
          <div className="flex items-start gap-4">
            <div className="h-12 w-12 rounded-xl bg-indigo-50 text-indigo-600 flex items-center justify-center shrink-0">
              <Layers className="w-6 h-6" />
            </div>
            <div>
              <div className="flex items-center gap-2.5 flex-wrap">
                <h1 className="text-xl font-bold text-slate-900">{plan.name}</h1>
                <span className="font-mono text-xs px-2.5 py-0.5 rounded-md bg-slate-100 font-semibold text-slate-700">
                  {plan.code}
                </span>
                {plan.status === "ACTIVE" ? (
                  <Badge className="bg-emerald-50 text-emerald-700 border-emerald-200">
                    Active
                  </Badge>
                ) : plan.status === "DRAFT" ? (
                  <Badge className="bg-slate-100 text-slate-700 border-slate-200">
                    Draft
                  </Badge>
                ) : plan.status === "INACTIVE" ? (
                  <Badge className="bg-amber-50 text-amber-700 border-amber-200">
                    Inactive
                  </Badge>
                ) : (
                  <Badge className="bg-slate-100 text-slate-500 border-slate-200">
                    Archived
                  </Badge>
                )}
                {plan.is_auto_close && (
                  <Badge variant="outline" className="border-amber-300 text-amber-700 bg-amber-50/50">
                    Auto-Close Enabled
                  </Badge>
                )}
              </div>
              <p className="text-xs text-slate-500 mt-1 max-w-xl">
                {plan.description || "No plan description provided."}
              </p>
            </div>
          </div>

          <div className="flex flex-col md:flex-row md:items-center gap-4">
            <div>
              <span className="block text-xs text-slate-400 font-medium">
                Calculated Plan Total
              </span>
              <div className="text-2xl font-bold text-indigo-600">
                {formatPrice(plan.calculated_total_price, plan.currency)}
              </div>
              <span className="text-[11px] text-slate-400">
                per {plan.interval_count > 1 ? `${plan.interval_count} ` : ""}
                {plan.billing_interval.toLowerCase()}
              </span>
            </div>

            {/* Lifecycle Status Buttons for Admin */}
            {isAdmin && !isArchived && (
              <div className="flex items-center gap-2 border-t md:border-t-0 pt-3 md:pt-0">
                {plan.status === "DRAFT" && (
                  <Button
                    size="sm"
                    onClick={() => statusMutation.mutate("ACTIVE")}
                    disabled={statusMutation.isPending}
                    className="bg-emerald-600 hover:bg-emerald-700 text-white text-xs gap-1.5"
                  >
                    <Play className="w-3.5 h-3.5" />
                    Activate Plan
                  </Button>
                )}
                {plan.status === "ACTIVE" && (
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => statusMutation.mutate("INACTIVE")}
                    disabled={statusMutation.isPending}
                    className="text-amber-700 border-amber-200 hover:bg-amber-50 text-xs gap-1.5"
                  >
                    <Pause className="w-3.5 h-3.5" />
                    Deactivate
                  </Button>
                )}
                {plan.status === "INACTIVE" && (
                  <Button
                    size="sm"
                    onClick={() => statusMutation.mutate("ACTIVE")}
                    disabled={statusMutation.isPending}
                    className="bg-emerald-600 hover:bg-emerald-700 text-white text-xs gap-1.5"
                  >
                    <Play className="w-3.5 h-3.5" />
                    Reactivate
                  </Button>
                )}
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => {
                    if (window.confirm("Are you sure you want to archive this plan? It cannot be reactivated.")) {
                      statusMutation.mutate("ARCHIVED");
                    }
                  }}
                  disabled={statusMutation.isPending}
                  className="text-slate-500 hover:text-rose-600 hover:bg-rose-50 text-xs gap-1.5"
                >
                  <Archive className="w-3.5 h-3.5" />
                  Archive
                </Button>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Main Grid: Bundled Products & Plan Rules */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left 2 Cols: Bundled Products Line Items */}
        <div className="lg:col-span-2 space-y-6">
          <div className="bg-white rounded-xl border border-slate-200/80 p-6 shadow-xs space-y-4">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100">
              <div>
                <h3 className="font-semibold text-slate-900 text-base">
                  Bundled Product Components
                </h3>
                <p className="text-xs text-slate-500">
                  Products and variants bundled into this recurring subscription
                </p>
              </div>
              {isAdmin && !isArchived && (
                <Button
                  size="sm"
                  onClick={() => setIsAddOpen(true)}
                  className="bg-indigo-600 hover:bg-indigo-700 text-white gap-1.5 text-xs shadow-xs"
                >
                  <Plus className="w-3.5 h-3.5" />
                  Add Product to Bundle
                </Button>
              )}
            </div>

            {plan.bundled_products.length === 0 ? (
              <div className="p-8 border border-dashed border-slate-200 rounded-xl text-center bg-slate-50/50">
                <Package className="w-8 h-8 text-slate-400 mx-auto mb-2" />
                <h4 className="font-semibold text-slate-900 text-sm">
                  No bundled products
                </h4>
                <p className="text-xs text-slate-500 mt-0.5 max-w-sm mx-auto">
                  A plan must contain at least one active product before it can be activated.
                </p>
                {isAdmin && !isArchived && (
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setIsAddOpen(true)}
                    className="mt-3 text-xs gap-1"
                  >
                    <Plus className="w-3.5 h-3.5" />
                    Add First Product
                  </Button>
                )}
              </div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-left text-sm">
                  <thead className="bg-slate-50 border-b border-slate-200/80 text-xs font-semibold text-slate-500 uppercase tracking-wider">
                    <tr>
                      <th className="py-2.5 px-3">Product / Variant</th>
                      <th className="py-2.5 px-3">Quantity</th>
                      <th className="py-2.5 px-3">Unit Price</th>
                      <th className="py-2.5 px-3">Subtotal</th>
                      <th className="py-2.5 px-3">Status</th>
                      {isAdmin && !isArchived && (
                        <th className="py-2.5 px-3 text-right">Actions</th>
                      )}
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {plan.bundled_products.map((bp) => {
                      // Calculate unit price for display
                      let unitPrice = 0;
                      if (bp.price_override) {
                        unitPrice = Number(bp.price_override);
                      } else if (bp.product) {
                        unitPrice = Number(bp.product.sales_price);
                        if (bp.variant) {
                          const adj = Number(bp.variant.adjustment_value);
                          if (bp.variant.adjustment_type === "FIXED_AMOUNT") {
                            unitPrice += adj;
                          } else {
                            unitPrice += (unitPrice * adj) / 100;
                          }
                        }
                      }
                      const subtotal = unitPrice * bp.default_quantity;

                      return (
                        <tr
                          key={bp.id}
                          className={`hover:bg-slate-50/50 ${
                            !bp.is_active ? "opacity-60 bg-slate-50/30" : ""
                          }`}
                        >
                          <td className="py-3 px-3">
                            <div className="font-semibold text-slate-900">
                              {bp.product?.name || "Product"}
                            </div>
                            <div className="flex items-center gap-2 mt-0.5">
                              <span className="font-mono text-[11px] text-slate-500">
                                {bp.product?.sku}
                              </span>
                              {bp.variant && (
                                <span className="inline-flex items-center px-1.5 py-0.2 rounded text-[10px] font-semibold bg-indigo-50 text-indigo-700 border border-indigo-200">
                                  {bp.variant.variant_name} ({bp.variant.variant_code})
                                </span>
                              )}
                            </div>
                          </td>
                          <td className="py-3 px-3 font-semibold text-slate-800">
                            {bp.default_quantity}
                          </td>
                          <td className="py-3 px-3">
                            <span className="font-medium text-slate-900">
                              {formatPrice(unitPrice.toFixed(4), plan.currency)}
                            </span>
                            {bp.price_override && (
                              <span className="block text-[10px] font-semibold text-indigo-600 uppercase">
                                Override
                              </span>
                            )}
                          </td>
                          <td className="py-3 px-3 font-bold text-slate-900">
                            {formatPrice(subtotal.toFixed(4), plan.currency)}
                          </td>
                          <td className="py-3 px-3">
                            {bp.is_active ? (
                              <span className="text-[11px] font-medium text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200">
                                Active
                              </span>
                            ) : (
                              <span className="text-[11px] font-medium text-slate-500 bg-slate-100 px-2 py-0.5 rounded-full">
                                Inactive
                              </span>
                            )}
                          </td>
                          {isAdmin && !isArchived && (
                            <td className="py-3 px-3 text-right">
                              <div className="flex items-center justify-end gap-1">
                                <Button
                                  variant="ghost"
                                  size="sm"
                                  onClick={() => startEditItem(bp)}
                                  className="text-xs text-indigo-600 hover:text-indigo-700 hover:bg-indigo-50 h-8 px-2"
                                >
                                  Edit
                                </Button>
                                <Button
                                  variant="ghost"
                                  size="sm"
                                  onClick={() => removeBundledMutation.mutate(bp.id)}
                                  disabled={removeBundledMutation.isPending}
                                  className="text-xs text-slate-400 hover:text-rose-600 hover:bg-rose-50 h-8 px-2"
                                >
                                  <Trash2 className="w-3.5 h-3.5" />
                                </Button>
                              </div>
                            </td>
                          )}
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </div>

        {/* Right 1 Col: Plan Configuration Rules & Availability */}
        <div className="space-y-6">
          <div className="bg-white rounded-xl border border-slate-200/80 p-5 shadow-xs space-y-4">
            <h3 className="font-semibold text-slate-900 text-sm pb-2 border-b border-slate-100">
              Subscription Parameters
            </h3>

            <div className="space-y-3 text-xs">
              <div className="flex items-center justify-between">
                <span className="text-slate-500">Billing Interval</span>
                <span className="font-semibold text-slate-900">
                  {plan.billing_interval} (x{plan.interval_count})
                </span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-slate-500">Operating Currency</span>
                <span className="font-semibold text-slate-900 font-mono">
                  {plan.currency}
                </span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-slate-500">Trial Period</span>
                <span className="font-semibold text-slate-900">
                  {plan.trial_period_days > 0
                    ? `${plan.trial_period_days} days`
                    : "None"}
                </span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-slate-500">Min Quantity</span>
                <span className="font-semibold text-slate-900">
                  {plan.min_quantity}
                </span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-slate-500">Max Quantity</span>
                <span className="font-semibold text-slate-900">
                  {plan.max_quantity ? plan.max_quantity : "Unlimited"}
                </span>
              </div>
            </div>
          </div>

          {/* Auto-Close & Window */}
          <div className="bg-white rounded-xl border border-slate-200/80 p-5 shadow-xs space-y-3">
            <div className="flex items-center gap-2 pb-2 border-b border-slate-100">
              <Clock className="w-4 h-4 text-amber-600" />
              <h3 className="font-semibold text-slate-900 text-sm">
                Availability & Auto-Close
              </h3>
            </div>

            <div className="space-y-2.5 text-xs">
              <div className="flex items-center justify-between">
                <span className="text-slate-500">Auto-Close Mode</span>
                <span className={`font-semibold ${plan.is_auto_close ? "text-amber-700" : "text-slate-600"}`}>
                  {plan.is_auto_close ? "Enabled (Retire on End)" : "Disabled"}
                </span>
              </div>

              <div>
                <span className="block text-slate-400 mb-0.5">Availability Start</span>
                <span className="font-medium text-slate-800">
                  {plan.availability_start_date
                    ? new Date(plan.availability_start_date).toLocaleString()
                    : "Immediate (no restriction)"}
                </span>
              </div>

              <div>
                <span className="block text-slate-400 mb-0.5">Availability End</span>
                <span className="font-medium text-slate-800">
                  {plan.availability_end_date
                    ? new Date(plan.availability_end_date).toLocaleString()
                    : "No expiration date"}
                </span>
              </div>

              {plan.is_auto_close && plan.availability_end_date && (
                <div className="p-2.5 bg-amber-50 rounded-lg border border-amber-200/70 text-[11px] text-amber-800 mt-2">
                  When this plan reaches the end date, it automatically locks to new subscribers without disrupting current subscribers.
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Add Product Line Item Modal */}
      {isAddOpen && (
        <div className="fixed inset-0 z-50 bg-slate-900/40 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-xl shadow-xl border border-slate-200 w-full max-w-lg p-6 space-y-4 animate-in fade-in zoom-in-95 duration-150">
            <h3 className="font-semibold text-slate-900 text-base">
              Bundle Product into Plan
            </h3>
            <p className="text-xs text-slate-500">
              Only active products matching currency ({plan.currency}) are eligible.
            </p>

            <form onSubmit={handleAddBundledSubmit} className="space-y-4">
              <div className="space-y-1.5">
                <Label htmlFor="b_prod">Select Product *</Label>
                <select
                  id="b_prod"
                  className="w-full h-10 px-3 rounded-lg border border-slate-200 bg-white text-sm"
                  value={selectedProductId}
                  onChange={(e) => {
                    setSelectedProductId(e.target.value);
                    setSelectedVariantId("");
                    setLivePreview(null);
                  }}
                  required
                >
                  <option value="">-- Choose a Product --</option>
                  {candidateProducts.map((p) => (
                    <option key={p.id} value={p.id}>
                      {p.name} ({p.sku}) — {formatPrice(p.sales_price, p.currency)}
                    </option>
                  ))}
                </select>
              </div>

              {/* Variant selection if product has variants */}
              {selectedProduct && selectedProduct.variants_count > 0 && (
                <div className="space-y-1.5">
                  <Label htmlFor="b_var">Product Variant (Optional)</Label>
                  <select
                    id="b_var"
                    className="w-full h-10 px-3 rounded-lg border border-slate-200 bg-white text-sm"
                    value={selectedVariantId}
                    onChange={(e) => {
                      setSelectedVariantId(e.target.value);
                      setLivePreview(null);
                    }}
                  >
                    <option value="">-- Base Product (No Variant) --</option>
                    {/* We can fetch or show variants */}
                  </select>
                </div>
              )}

              <div className="grid grid-cols-2 gap-3">
                <div className="space-y-1.5">
                  <Label htmlFor="b_qty">Default Quantity *</Label>
                  <Input
                    id="b_qty"
                    type="number"
                    min="1"
                    value={defaultQuantity}
                    onChange={(e) => {
                      setDefaultQuantity(Number(e.target.value));
                      setLivePreview(null);
                    }}
                    required
                  />
                </div>
                <div className="space-y-1.5">
                  <Label htmlFor="b_override">Plan Price Override</Label>
                  <Input
                    id="b_override"
                    type="number"
                    step="0.0001"
                    min="0"
                    placeholder="Optional unit price"
                    value={priceOverride}
                    onChange={(e) => {
                      setPriceOverride(e.target.value);
                      setLivePreview(null);
                    }}
                  />
                </div>
              </div>

              {/* Live Preview Button */}
              <div className="p-3 bg-slate-50 rounded-lg border border-slate-200/80 flex items-center justify-between">
                <div>
                  <span className="text-xs font-semibold text-slate-700 block">
                    Calculated Effective Unit Price:
                  </span>
                  <span className="text-sm font-bold text-indigo-600">
                    {livePreview
                      ? formatPrice(livePreview, plan.currency)
                      : "Click Calculate to Preview"}
                  </span>
                </div>
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  onClick={handleCalculatePreview}
                  disabled={!selectedProductId || isPreviewLoading}
                  className="gap-1.5 text-xs"
                >
                  {isPreviewLoading ? (
                    <Loader2 className="w-3.5 h-3.5 animate-spin" />
                  ) : (
                    <Calculator className="w-3.5 h-3.5" />
                  )}
                  Calculate Price
                </Button>
              </div>

              <div className="flex items-center justify-end gap-2 pt-3 border-t border-slate-100">
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => setIsAddOpen(false)}
                >
                  Cancel
                </Button>
                <Button
                  type="submit"
                  disabled={addBundledMutation.isPending || !selectedProductId}
                  className="bg-indigo-600 hover:bg-indigo-700 text-white"
                >
                  {addBundledMutation.isPending && (
                    <Loader2 className="w-4 h-4 animate-spin mr-1" />
                  )}
                  Add to Bundle
                </Button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Edit Line Item Modal */}
      {editingItem && (
        <div className="fixed inset-0 z-50 bg-slate-900/40 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-xl shadow-xl border border-slate-200 w-full max-w-md p-6 space-y-4 animate-in fade-in zoom-in-95 duration-150">
            <h3 className="font-semibold text-slate-900 text-base">
              Edit Bundled Item
            </h3>
            <p className="text-xs text-slate-500 font-medium">
              {editingItem.product?.name} ({editingItem.product?.sku})
            </p>

            <form onSubmit={handleSaveItemEdit} className="space-y-4">
              <div className="space-y-1.5">
                <Label htmlFor="e_qty">Default Quantity</Label>
                <Input
                  id="e_qty"
                  type="number"
                  min="1"
                  value={editQty}
                  onChange={(e) => setEditQty(Number(e.target.value))}
                  required
                />
              </div>

              <div className="space-y-1.5">
                <Label htmlFor="e_override">Price Override ({plan.currency})</Label>
                <Input
                  id="e_override"
                  type="number"
                  step="0.0001"
                  min="0"
                  placeholder="Leave empty to use base/variant price"
                  value={editOverride}
                  onChange={(e) => setEditOverride(e.target.value)}
                />
              </div>

              <div className="flex items-center gap-2">
                <input
                  type="checkbox"
                  id="e_item_active"
                  checked={editIsActive}
                  onChange={(e) => setEditIsActive(e.target.checked)}
                  className="rounded border-slate-300 text-indigo-600 focus:ring-indigo-500"
                />
                <Label htmlFor="e_item_active" className="text-xs font-medium cursor-pointer">
                  Line Item is Active in Bundle
                </Label>
              </div>

              <div className="flex items-center justify-end gap-2 pt-3 border-t border-slate-100">
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => setEditingItem(null)}
                >
                  Cancel
                </Button>
                <Button
                  type="submit"
                  disabled={updateLineItemMutation.isPending}
                  className="bg-indigo-600 hover:bg-indigo-700 text-white"
                >
                  {updateLineItemMutation.isPending && (
                    <Loader2 className="w-4 h-4 animate-spin mr-1" />
                  )}
                  Save Item
                </Button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
