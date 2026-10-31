import React, { useState } from "react";
import { useParams, Link } from "react-router-dom";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { productsApi } from "@/api/products";
import {
  ProductType,
  AdjustmentType,
  ProductUpdateInput,
  VariantCreateInput,
  VariantUpdateInput,
  ProductVariant,
} from "@/types";
import { useAuth } from "@/hooks/useAuth";
import { useToast } from "@/components/ui/toast";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import {
  ArrowLeft,
  Package,
  Layers,
  History,
  Edit,
  Plus,
  AlertCircle,
  Loader2,
  Clock,
} from "lucide-react";

export const ProductDetailsPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const { user } = useAuth();
  const { success, error: toastError } = useToast();
  const queryClient = useQueryClient();
  const isAdmin = user?.role === "ADMIN";

  const [activeTab, setActiveTab] = useState<"DETAILS" | "VARIANTS" | "HISTORY">(
    "DETAILS"
  );

  // Edit Product State
  const [isEditing, setIsEditing] = useState(false);
  const [editName, setEditName] = useState("");
  const [editSku, setEditSku] = useState("");
  const [editType, setEditType] = useState<ProductType>("SOFTWARE");
  const [editSalesPrice, setEditSalesPrice] = useState("");
  const [editCostPrice, setEditCostPrice] = useState("");
  const [editDesc, setEditDesc] = useState("");
  const [editNotes, setEditNotes] = useState("");
  const [editActive, setEditActive] = useState(true);
  const [priceReason, setPriceReason] = useState("");

  // Variant Modal State
  const [isAddVariantOpen, setIsAddVariantOpen] = useState(false);
  const [varName, setVarName] = useState("");
  const [varCode, setVarCode] = useState("");
  const [varAdjType, setVarAdjType] = useState<AdjustmentType>("FIXED_AMOUNT");
  const [varAdjVal, setVarAdjVal] = useState("0.0000");
  const [varDesc, setVarDesc] = useState("");

  // Edit Variant Modal State
  const [editingVariant, setEditingVariant] = useState<ProductVariant | null>(null);
  const [editVarName, setEditVarName] = useState("");
  const [editVarCode, setEditVarCode] = useState("");
  const [editVarAdjType, setEditVarAdjType] = useState<AdjustmentType>("FIXED_AMOUNT");
  const [editVarAdjVal, setEditVarAdjVal] = useState("0.0000");
  const [editVarReason, setEditVarReason] = useState("");

  const { data: product, isLoading, error } = useQuery({
    queryKey: ["product", id],
    queryFn: () => productsApi.getProduct(id!),
    enabled: !!id,
  });

  const startEditing = () => {
    if (!product) return;
    setEditName(product.name);
    setEditSku(product.sku);
    setEditType(product.product_type);
    setEditSalesPrice(product.sales_price);
    setEditCostPrice(product.cost_price || "");
    setEditDesc(product.description || "");
    setEditNotes(product.notes || "");
    setEditActive(product.is_active);
    setPriceReason("");
    setIsEditing(true);
  };

  const updateProductMutation = useMutation({
    mutationFn: (data: ProductUpdateInput) =>
      productsApi.updateProduct(id!, data),
    onSuccess: (updated) => {
      queryClient.invalidateQueries({ queryKey: ["product", id] });
      queryClient.invalidateQueries({ queryKey: ["products"] });
      success(`Successfully updated ${updated.name}`, "Product Updated");
      setIsEditing(false);
    },
    onError: (err: any) => {
      toastError(err.response?.data?.detail || "Could not save changes.", "Update Failed");
    },
  });

  const handleSaveProduct = (e: React.FormEvent) => {
    e.preventDefault();
    if (!product) return;

    const payload: ProductUpdateInput = {
      name: editName.trim(),
      sku: editSku.trim().toUpperCase(),
      product_type: editType,
      sales_price: Number(editSalesPrice).toFixed(4),
      cost_price: editCostPrice ? Number(editCostPrice).toFixed(4) : undefined,
      description: editDesc.trim() || undefined,
      notes: editNotes.trim() || undefined,
      is_active: editActive,
      price_change_reason: priceReason.trim() || undefined,
    };

    updateProductMutation.mutate(payload);
  };

  // Add Variant Mutation
  const addVariantMutation = useMutation({
    mutationFn: (data: VariantCreateInput) =>
      productsApi.createVariant(id!, data),
    onSuccess: (v) => {
      queryClient.invalidateQueries({ queryKey: ["product", id] });
      success(`Added variant ${v.variant_name} (${v.variant_code})`, "Variant Created");
      setIsAddVariantOpen(false);
      setVarName("");
      setVarCode("");
      setVarAdjVal("0.0000");
      setVarDesc("");
    },
    onError: (err: any) => {
      toastError(err.response?.data?.detail || "Check input fields.", "Failed to Add Variant");
    },
  });

  const handleAddVariant = (e: React.FormEvent) => {
    e.preventDefault();
    if (!varName.trim() || !varCode.trim()) return;

    addVariantMutation.mutate({
      variant_name: varName.trim(),
      variant_code: varCode.trim().toUpperCase(),
      adjustment_type: varAdjType,
      adjustment_value: Number(varAdjVal || 0).toFixed(4),
      description: varDesc.trim() || undefined,
    });
  };

  // Update Variant Mutation
  const updateVariantMutation = useMutation({
    mutationFn: ({
      variantId,
      data,
    }: {
      variantId: string;
      data: VariantUpdateInput;
    }) => productsApi.updateVariant(id!, variantId, data),
    onSuccess: (v) => {
      queryClient.invalidateQueries({ queryKey: ["product", id] });
      success(`Updated variant ${v.variant_name}`, "Variant Updated");
      setEditingVariant(null);
    },
    onError: (err: any) => {
      toastError(err.response?.data?.detail || "Failed to update variant.", "Update Failed");
    },
  });

  const startEditVariant = (v: ProductVariant) => {
    setEditingVariant(v);
    setEditVarName(v.variant_name);
    setEditVarCode(v.variant_code);
    setEditVarAdjType(v.adjustment_type);
    setEditVarAdjVal(v.adjustment_value);
    setEditVarReason("");
  };

  const handleSaveVariant = (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingVariant) return;

    updateVariantMutation.mutate({
      variantId: editingVariant.id,
      data: {
        variant_name: editVarName.trim(),
        variant_code: editVarCode.trim().toUpperCase(),
        adjustment_type: editVarAdjType,
        adjustment_value: Number(editVarAdjVal || 0).toFixed(4),
        reason: editVarReason.trim() || undefined,
      },
    });
  };

  // Archive Variant Mutation
  const archiveVariantMutation = useMutation({
    mutationFn: (variantId: string) =>
      productsApi.archiveVariant(id!, variantId),
    onSuccess: (v) => {
      queryClient.invalidateQueries({ queryKey: ["product", id] });
      success(`Deactivated ${v.variant_name}`, "Variant Deactivated");
    },
    onError: (err: any) => {
      toastError(err.response?.data?.detail || "Could not deactivate variant.", "Action Failed");
    },
  });

  if (isLoading) {
    return (
      <div className="p-16 text-center">
        <Loader2 className="w-8 h-8 animate-spin text-blue-600 mx-auto mb-3" />
        <p className="text-sm text-slate-500 font-medium">
          Loading product record...
        </p>
      </div>
    );
  }

  if (error || !product) {
    return (
      <div className="p-12 text-center text-rose-600 bg-white rounded-xl border border-rose-200">
        <AlertCircle className="w-10 h-10 mx-auto mb-3" />
        <h3 className="text-lg font-semibold">Product Not Found</h3>
        <p className="text-sm text-slate-500 mt-1">
          The requested product does not exist or has been removed.
        </p>
        <Link to="/products" className="inline-block mt-4">
          <Button variant="outline" className="gap-2">
            <ArrowLeft className="w-4 h-4" />
            Back to Catalog
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

  return (
    <div className="space-y-6">
      {/* Back Link & Header */}
      <div>
        <Link
          to="/products"
          className="inline-flex items-center gap-1.5 text-xs font-semibold text-slate-500 hover:text-slate-900 transition-colors mb-3"
        >
          <ArrowLeft className="w-3.5 h-3.5" />
          Back to Product Catalog
        </Link>

        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 bg-white p-6 rounded-xl border border-slate-200/80 shadow-xs">
          <div className="flex items-start gap-4">
            <div className="h-12 w-12 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center shrink-0">
              <Package className="w-6 h-6" />
            </div>
            <div>
              <div className="flex items-center gap-2.5 flex-wrap">
                <h1 className="text-xl font-bold text-slate-900">
                  {product.name}
                </h1>
                <span className="font-mono text-xs px-2.5 py-0.5 rounded-md bg-slate-100 font-semibold text-slate-700">
                  {product.sku}
                </span>
                <Badge
                  variant="secondary"
                  className={
                    product.product_type === "SOFTWARE"
                      ? "bg-blue-50 text-blue-700 border-blue-200"
                      : product.product_type === "ADDON"
                      ? "bg-purple-50 text-purple-700 border-purple-200"
                      : "bg-emerald-50 text-emerald-700 border-emerald-200"
                  }
                >
                  {product.product_type}
                </Badge>
                {product.is_archived ? (
                  <Badge className="bg-slate-100 text-slate-600 border-slate-200">
                    Archived
                  </Badge>
                ) : product.is_active ? (
                  <Badge className="bg-emerald-50 text-emerald-700 border-emerald-200">
                    Active
                  </Badge>
                ) : (
                  <Badge className="bg-amber-50 text-amber-700 border-amber-200">
                    Inactive
                  </Badge>
                )}
              </div>
              <p className="text-xs text-slate-500 mt-1 max-w-xl">
                {product.description || "No description provided."}
              </p>
            </div>
          </div>

          <div className="flex items-center gap-6 border-t md:border-t-0 pt-3 md:pt-0">
            <div>
              <span className="block text-xs text-slate-400 font-medium">
                Sales Unit Price
              </span>
              <span className="text-xl font-bold text-slate-900">
                {formatPrice(product.sales_price, product.currency)}
              </span>
            </div>
            {product.cost_price && (
              <div>
                <span className="block text-xs text-slate-400 font-medium">
                  Cost Price
                </span>
                <span className="text-sm font-semibold text-slate-600">
                  {formatPrice(product.cost_price, product.currency)}
                </span>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Navigation Tabs */}
      <div className="flex items-center gap-2 border-b border-slate-200">
        <button
          onClick={() => setActiveTab("DETAILS")}
          className={`flex items-center gap-2 px-4 py-2.5 text-sm font-medium border-b-2 -mb-px transition-colors ${
            activeTab === "DETAILS"
              ? "border-blue-600 text-blue-600 font-semibold"
              : "border-transparent text-slate-600 hover:text-slate-900"
          }`}
        >
          <Package className="w-4 h-4" />
          Product Info & Pricing
        </button>
        <button
          onClick={() => setActiveTab("VARIANTS")}
          className={`flex items-center gap-2 px-4 py-2.5 text-sm font-medium border-b-2 -mb-px transition-colors ${
            activeTab === "VARIANTS"
              ? "border-blue-600 text-blue-600 font-semibold"
              : "border-transparent text-slate-600 hover:text-slate-900"
          }`}
        >
          <Layers className="w-4 h-4" />
          Variants ({product.variants.length})
        </button>
        <button
          onClick={() => setActiveTab("HISTORY")}
          className={`flex items-center gap-2 px-4 py-2.5 text-sm font-medium border-b-2 -mb-px transition-colors ${
            activeTab === "HISTORY"
              ? "border-blue-600 text-blue-600 font-semibold"
              : "border-transparent text-slate-600 hover:text-slate-900"
          }`}
        >
          <History className="w-4 h-4" />
          Price History ({product.price_history.length})
        </button>
      </div>

      {/* Tab 1: Product Info & Pricing Form */}
      {activeTab === "DETAILS" && (
        <div className="bg-white rounded-xl border border-slate-200/80 p-6 shadow-xs">
          <div className="flex items-center justify-between pb-4 border-b border-slate-100 mb-6">
            <div>
              <h3 className="font-semibold text-slate-900 text-base">
                Product Specification & Pricing
              </h3>
              <p className="text-xs text-slate-500">
                Core master data and financial configuration
              </p>
            </div>
            {isAdmin && !isEditing && (
              <Button
                variant="outline"
                size="sm"
                onClick={startEditing}
                className="gap-2 text-xs"
              >
                <Edit className="w-3.5 h-3.5" />
                Edit Product
              </Button>
            )}
          </div>

          {isEditing ? (
            <form onSubmit={handleSaveProduct} className="space-y-5 max-w-2xl">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="space-y-1.5">
                  <Label htmlFor="e_name">Product Name *</Label>
                  <Input
                    id="e_name"
                    value={editName}
                    onChange={(e) => setEditName(e.target.value)}
                    required
                  />
                </div>
                <div className="space-y-1.5">
                  <Label htmlFor="e_sku">SKU Code *</Label>
                  <Input
                    id="e_sku"
                    value={editSku}
                    onChange={(e) => setEditSku(e.target.value)}
                    required
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="space-y-1.5">
                  <Label htmlFor="e_sales_price">Sales Price ({product.currency}) *</Label>
                  <Input
                    id="e_sales_price"
                    type="number"
                    step="0.0001"
                    min="0"
                    value={editSalesPrice}
                    onChange={(e) => setEditSalesPrice(e.target.value)}
                    required
                  />
                </div>
                <div className="space-y-1.5">
                  <Label htmlFor="e_cost_price">Cost Price ({product.currency})</Label>
                  <Input
                    id="e_cost_price"
                    type="number"
                    step="0.0001"
                    min="0"
                    value={editCostPrice}
                    onChange={(e) => setEditCostPrice(e.target.value)}
                  />
                </div>
              </div>

              {/* Price Change Reason input */}
              {(editSalesPrice !== product.sales_price ||
                (editCostPrice || "") !== (product.cost_price || "")) && (
                <div className="p-3.5 bg-amber-50 rounded-lg border border-amber-200/80 space-y-1.5 animate-in fade-in duration-150">
                  <Label htmlFor="price_reason" className="text-amber-900 font-semibold">
                    Price Change Audit Reason (Required for Ledger) *
                  </Label>
                  <Input
                    id="price_reason"
                    placeholder="e.g. Q4 vendor adjustment / feature upgrade"
                    value={priceReason}
                    onChange={(e) => setPriceReason(e.target.value)}
                    className="bg-white border-amber-300"
                    required
                  />
                  <p className="text-[11px] text-amber-700">
                    Brightloop maintains an immutable record of all price revisions for compliance.
                  </p>
                </div>
              )}

              <div className="space-y-1.5">
                <Label htmlFor="e_desc">Description</Label>
                <textarea
                  id="e_desc"
                  rows={3}
                  className="w-full px-3 py-2 rounded-lg border border-slate-200 bg-white text-sm focus:outline-hidden focus:ring-2 focus:ring-blue-500/20 focus:border-blue-600"
                  value={editDesc}
                  onChange={(e) => setEditDesc(e.target.value)}
                />
              </div>

              <div className="space-y-1.5">
                <Label htmlFor="e_notes">Internal Notes (Staff & Admin)</Label>
                <textarea
                  id="e_notes"
                  rows={2}
                  className="w-full px-3 py-2 rounded-lg border border-slate-200 bg-white text-sm focus:outline-hidden focus:ring-2 focus:ring-blue-500/20 focus:border-blue-600"
                  value={editNotes}
                  onChange={(e) => setEditNotes(e.target.value)}
                />
              </div>

              <div className="flex items-center gap-2">
                <input
                  type="checkbox"
                  id="e_active"
                  checked={editActive}
                  onChange={(e) => setEditActive(e.target.checked)}
                  className="rounded border-slate-300 text-blue-600 focus:ring-blue-500"
                />
                <Label htmlFor="e_active" className="text-sm cursor-pointer">
                  Product is Active (available for new subscription plans)
                </Label>
              </div>

              <div className="flex items-center gap-3 pt-3">
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => setIsEditing(false)}
                  disabled={updateProductMutation.isPending}
                >
                  Cancel
                </Button>
                <Button
                  type="submit"
                  disabled={updateProductMutation.isPending}
                  className="bg-blue-600 hover:bg-blue-700 text-white gap-2"
                >
                  {updateProductMutation.isPending && (
                    <Loader2 className="w-4 h-4 animate-spin" />
                  )}
                  Save Changes
                </Button>
              </div>
            </form>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-4">
                <div>
                  <span className="text-xs font-semibold uppercase text-slate-400">
                    Product Name
                  </span>
                  <p className="text-sm font-medium text-slate-900 mt-0.5">
                    {product.name}
                  </p>
                </div>
                <div>
                  <span className="text-xs font-semibold uppercase text-slate-400">
                    Internal SKU
                  </span>
                  <p className="text-sm font-mono text-slate-700 mt-0.5">
                    {product.sku}
                  </p>
                </div>
                <div>
                  <span className="text-xs font-semibold uppercase text-slate-400">
                    Product Classification
                  </span>
                  <p className="text-sm font-medium text-slate-900 mt-0.5">
                    {product.product_type}
                  </p>
                </div>
                <div>
                  <span className="text-xs font-semibold uppercase text-slate-400">
                    Description
                  </span>
                  <p className="text-sm text-slate-600 mt-0.5">
                    {product.description || "—"}
                  </p>
                </div>
              </div>

              <div className="space-y-4">
                <div>
                  <span className="text-xs font-semibold uppercase text-slate-400">
                    Sales Price
                  </span>
                  <p className="text-lg font-bold text-slate-900 mt-0.5">
                    {formatPrice(product.sales_price, product.currency)}
                  </p>
                </div>
                <div>
                  <span className="text-xs font-semibold uppercase text-slate-400">
                    Cost Price
                  </span>
                  <p className="text-sm font-medium text-slate-700 mt-0.5">
                    {product.cost_price
                      ? formatPrice(product.cost_price, product.currency)
                      : "Not specified"}
                  </p>
                </div>
                <div>
                  <span className="text-xs font-semibold uppercase text-slate-400">
                    Internal Notes
                  </span>
                  <p className="text-sm text-slate-600 mt-0.5">
                    {product.notes || "—"}
                  </p>
                </div>
                <div>
                  <span className="text-xs font-semibold uppercase text-slate-400">
                    Timestamps
                  </span>
                  <p className="text-xs text-slate-500 mt-0.5">
                    Created: {new Date(product.created_at).toLocaleString()}
                    <br />
                    Updated: {new Date(product.updated_at).toLocaleString()}
                  </p>
                </div>
              </div>
            </div>
          )}
        </div>
      )}

      {/* Tab 2: Variants Management */}
      {activeTab === "VARIANTS" && (
        <div className="bg-white rounded-xl border border-slate-200/80 p-6 shadow-xs space-y-6">
          <div className="flex items-center justify-between pb-4 border-b border-slate-100">
            <div>
              <h3 className="font-semibold text-slate-900 text-base">
                Product Variants
              </h3>
              <p className="text-xs text-slate-500">
                Configure editions, tiers, or regional variants with automatic price adjustments
              </p>
            </div>
            {isAdmin && (
              <Button
                size="sm"
                onClick={() => setIsAddVariantOpen(true)}
                className="bg-blue-600 hover:bg-blue-700 text-white gap-1.5 text-xs"
              >
                <Plus className="w-3.5 h-3.5" />
                Add Variant
              </Button>
            )}
          </div>

          {product.variants.length === 0 ? (
            <div className="p-8 border border-dashed border-slate-200 rounded-xl text-center bg-slate-50/50">
              <Layers className="w-8 h-8 text-slate-400 mx-auto mb-2" />
              <h4 className="font-semibold text-slate-900 text-sm">
                No variants defined
              </h4>
              <p className="text-xs text-slate-500 mt-0.5">
                This product currently uses only the base sales price.
              </p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-left text-sm">
                <thead className="bg-slate-50 border-b border-slate-200/80 text-xs font-semibold text-slate-500 uppercase tracking-wider">
                  <tr>
                    <th className="py-2.5 px-4">Variant Name</th>
                    <th className="py-2.5 px-4">Code</th>
                    <th className="py-2.5 px-4">Adjustment Rule</th>
                    <th className="py-2.5 px-4">Effective Unit Price</th>
                    <th className="py-2.5 px-4">Status</th>
                    <th className="py-2.5 px-4 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {product.variants.map((v) => {
                    const base = Number(product.sales_price);
                    const adj = Number(v.adjustment_value);
                    const effective =
                      v.adjustment_type === "FIXED_AMOUNT"
                        ? base + adj
                        : base + (base * adj) / 100;

                    return (
                      <tr key={v.id} className="hover:bg-slate-50/50">
                        <td className="py-3 px-4 font-semibold text-slate-900">
                          {v.variant_name}
                          {v.description && (
                            <span className="block text-xs font-normal text-slate-500">
                              {v.description}
                            </span>
                          )}
                        </td>
                        <td className="py-3 px-4 font-mono text-xs text-slate-600">
                          {v.variant_code}
                        </td>
                        <td className="py-3 px-4">
                          <span className="inline-flex items-center px-2 py-0.5 rounded-md text-xs font-medium bg-blue-50 text-blue-700 border border-blue-200">
                            {v.adjustment_type === "FIXED_AMOUNT"
                              ? `+ ${formatPrice(v.adjustment_value, product.currency)} (Fixed)`
                              : `+ ${Number(v.adjustment_value)}% (Percentage)`}
                          </span>
                        </td>
                        <td className="py-3 px-4 font-bold text-slate-900">
                          {formatPrice(effective.toFixed(4), product.currency)}
                        </td>
                        <td className="py-3 px-4">
                          {v.is_active ? (
                            <span className="text-xs font-medium text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200">
                              Active
                            </span>
                          ) : (
                            <span className="text-xs font-medium text-slate-500 bg-slate-100 px-2 py-0.5 rounded-full">
                              Inactive
                            </span>
                          )}
                        </td>
                        <td className="py-3 px-4 text-right">
                          {isAdmin && (
                            <div className="flex items-center justify-end gap-1.5">
                              <Button
                                variant="ghost"
                                size="sm"
                                onClick={() => startEditVariant(v)}
                                className="text-xs text-blue-600 hover:text-blue-700 hover:bg-blue-50"
                              >
                                Edit
                              </Button>
                              {v.is_active && (
                                <Button
                                  variant="ghost"
                                  size="sm"
                                  onClick={() =>
                                    archiveVariantMutation.mutate(v.id)
                                  }
                                  disabled={archiveVariantMutation.isPending}
                                  className="text-xs text-slate-400 hover:text-rose-600 hover:bg-rose-50"
                                >
                                  Deactivate
                                </Button>
                              )}
                            </div>
                          )}
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          )}
        </div>
      )}

      {/* Tab 3: Immutable Price History Timeline */}
      {activeTab === "HISTORY" && (
        <div className="bg-white rounded-xl border border-slate-200/80 p-6 shadow-xs space-y-6">
          <div className="pb-4 border-b border-slate-100">
            <h3 className="font-semibold text-slate-900 text-base">
              Price Revision Ledger
            </h3>
            <p className="text-xs text-slate-500">
              Immutable audit trail of base prices and adjustments
            </p>
          </div>

          {product.price_history.length === 0 ? (
            <div className="p-8 text-center text-slate-500 text-sm">
              No historical price modifications on record.
            </div>
          ) : (
            <div className="relative pl-6 space-y-6 before:absolute before:left-2 before:top-2 before:bottom-2 before:w-0.5 before:bg-slate-200">
              {product.price_history.map((h) => (
                <div key={h.id} className="relative group">
                  <div className="absolute -left-6 top-1.5 w-3.5 h-3.5 rounded-full bg-blue-600 ring-4 ring-white" />
                  <div className="bg-slate-50/75 p-4 rounded-lg border border-slate-200/80">
                    <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-1 text-xs text-slate-500 mb-1.5">
                      <div className="flex items-center gap-2">
                        <Clock className="w-3.5 h-3.5" />
                        <span className="font-medium text-slate-700">
                          {new Date(h.created_at).toLocaleString()}
                        </span>
                        <span className="text-slate-300">•</span>
                        <span className="uppercase font-semibold tracking-wider text-slate-600">
                          {h.price_field === "sales_price"
                            ? "Base Sales Price"
                            : "Cost Price"}
                        </span>
                      </div>
                    </div>
                    <div className="flex items-center gap-3 text-sm font-semibold text-slate-900">
                      {h.old_price ? (
                        <>
                          <span className="line-through text-slate-400">
                            {formatPrice(h.old_price, product.currency)}
                          </span>
                          <span className="text-slate-400">→</span>
                        </>
                      ) : (
                        <span className="text-emerald-600 text-xs uppercase font-bold">
                          Initial:
                        </span>
                      )}
                      <span className="text-blue-600 font-bold">
                        {formatPrice(h.new_price, product.currency)}
                      </span>
                    </div>
                    {h.reason && (
                      <p className="text-xs text-slate-600 mt-2 bg-white px-2.5 py-1.5 rounded-md border border-slate-200/60 inline-block">
                        <span className="font-semibold text-slate-700">Reason:</span>{" "}
                        {h.reason}
                      </p>
                    )}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {/* Add Variant Modal */}
      {isAddVariantOpen && (
        <div className="fixed inset-0 z-50 bg-slate-900/40 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-xl shadow-xl border border-slate-200 w-full max-w-md p-6 space-y-4 animate-in fade-in zoom-in-95 duration-150">
            <h3 className="font-semibold text-slate-900 text-base">
              Add Product Variant
            </h3>
            <form onSubmit={handleAddVariant} className="space-y-4">
              <div className="space-y-1.5">
                <Label htmlFor="v_name">Variant Name *</Label>
                <Input
                  id="v_name"
                  placeholder="e.g. Enterprise Edition"
                  value={varName}
                  onChange={(e) => setVarName(e.target.value)}
                  required
                />
              </div>
              <div className="space-y-1.5">
                <Label htmlFor="v_code">Variant Code *</Label>
                <Input
                  id="v_code"
                  placeholder="e.g. ENT-01"
                  value={varCode}
                  onChange={(e) => setVarCode(e.target.value)}
                  className="uppercase"
                  required
                />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div className="space-y-1.5">
                  <Label>Adjustment Type</Label>
                  <select
                    className="w-full h-10 px-3 rounded-lg border border-slate-200 bg-white text-sm"
                    value={varAdjType}
                    onChange={(e) =>
                      setVarAdjType(e.target.value as AdjustmentType)
                    }
                  >
                    <option value="FIXED_AMOUNT">Fixed Amount (+)</option>
                    <option value="PERCENTAGE">Percentage (%)</option>
                  </select>
                </div>
                <div className="space-y-1.5">
                  <Label>Value</Label>
                  <Input
                    type="number"
                    step="0.0001"
                    value={varAdjVal}
                    onChange={(e) => setVarAdjVal(e.target.value)}
                    required
                  />
                </div>
              </div>
              <div className="space-y-1.5">
                <Label htmlFor="v_desc">Description</Label>
                <Input
                  id="v_desc"
                  placeholder="Optional variant description"
                  value={varDesc}
                  onChange={(e) => setVarDesc(e.target.value)}
                />
              </div>
              <div className="flex items-center justify-end gap-2 pt-3 border-t border-slate-100">
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => setIsAddVariantOpen(false)}
                >
                  Cancel
                </Button>
                <Button
                  type="submit"
                  disabled={addVariantMutation.isPending}
                  className="bg-blue-600 hover:bg-blue-700 text-white"
                >
                  {addVariantMutation.isPending && (
                    <Loader2 className="w-4 h-4 animate-spin mr-1" />
                  )}
                  Create Variant
                </Button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Edit Variant Modal */}
      {editingVariant && (
        <div className="fixed inset-0 z-50 bg-slate-900/40 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-xl shadow-xl border border-slate-200 w-full max-w-md p-6 space-y-4 animate-in fade-in zoom-in-95 duration-150">
            <h3 className="font-semibold text-slate-900 text-base">
              Edit Variant: {editingVariant.variant_name}
            </h3>
            <form onSubmit={handleSaveVariant} className="space-y-4">
              <div className="space-y-1.5">
                <Label htmlFor="ev_name">Variant Name *</Label>
                <Input
                  id="ev_name"
                  value={editVarName}
                  onChange={(e) => setEditVarName(e.target.value)}
                  required
                />
              </div>
              <div className="space-y-1.5">
                <Label htmlFor="ev_code">Variant Code *</Label>
                <Input
                  id="ev_code"
                  value={editVarCode}
                  onChange={(e) => setEditVarCode(e.target.value)}
                  className="uppercase"
                  required
                />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div className="space-y-1.5">
                  <Label>Adjustment Type</Label>
                  <select
                    className="w-full h-10 px-3 rounded-lg border border-slate-200 bg-white text-sm"
                    value={editVarAdjType}
                    onChange={(e) =>
                      setEditVarAdjType(e.target.value as AdjustmentType)
                    }
                  >
                    <option value="FIXED_AMOUNT">Fixed Amount (+)</option>
                    <option value="PERCENTAGE">Percentage (%)</option>
                  </select>
                </div>
                <div className="space-y-1.5">
                  <Label>Adjustment Value</Label>
                  <Input
                    type="number"
                    step="0.0001"
                    value={editVarAdjVal}
                    onChange={(e) => setEditVarAdjVal(e.target.value)}
                    required
                  />
                </div>
              </div>
              {(editVarAdjType !== editingVariant.adjustment_type ||
                editVarAdjVal !== editingVariant.adjustment_value) && (
                <div className="space-y-1.5 bg-amber-50 p-3 rounded-lg border border-amber-200">
                  <Label className="text-amber-900 font-semibold text-xs">
                    Price Revision Reason *
                  </Label>
                  <Input
                    placeholder="e.g. Adjusted discount percentage"
                    value={editVarReason}
                    onChange={(e) => setEditVarReason(e.target.value)}
                    className="bg-white"
                    required
                  />
                </div>
              )}
              <div className="flex items-center justify-end gap-2 pt-3 border-t border-slate-100">
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => setEditingVariant(null)}
                >
                  Cancel
                </Button>
                <Button
                  type="submit"
                  disabled={updateVariantMutation.isPending}
                  className="bg-blue-600 hover:bg-blue-700 text-white"
                >
                  {updateVariantMutation.isPending && (
                    <Loader2 className="w-4 h-4 animate-spin mr-1" />
                  )}
                  Save Changes
                </Button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
