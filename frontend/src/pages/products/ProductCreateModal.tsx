import React, { useState } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { productsApi } from "@/api/products";
import { ProductCreateInput, ProductType, AdjustmentType } from "@/types";
import { useToast } from "@/components/ui/toast";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { X, Plus, Trash2, Loader2, Sparkles } from "lucide-react";

interface ProductCreateModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess?: (productId: string) => void;
}

export const ProductCreateModal: React.FC<ProductCreateModalProps> = ({
  isOpen,
  onClose,
  onSuccess,
}) => {
  const { success, error } = useToast();
  const queryClient = useQueryClient();

  const [name, setName] = useState("");
  const [sku, setSku] = useState("");
  const [productType, setProductType] = useState<ProductType>("SOFTWARE");
  const [salesPrice, setSalesPrice] = useState("");
  const [costPrice, setCostPrice] = useState("");
  const [currency, setCurrency] = useState("INR");
  const [description, setDescription] = useState("");
  const [notes, setNotes] = useState("");

  const [variants, setVariants] = useState<
    Array<{
      variant_name: string;
      variant_code: string;
      adjustment_type: AdjustmentType;
      adjustment_value: string;
    }>
  >([]);

  const createMutation = useMutation({
    mutationFn: (data: ProductCreateInput) => productsApi.createProduct(data),
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ["products"] });
      success(`Successfully created ${data.name} (${data.sku})`, "Product Created");
      onClose();
      if (onSuccess) onSuccess(data.id);
    },
    onError: (err: any) => {
      error(
        err.response?.data?.detail || "Failed to create product. Check inputs.",
        "Creation Failed"
      );
    },
  });

  if (!isOpen) return null;

  const handleAddVariant = () => {
    setVariants([
      ...variants,
      {
        variant_name: "",
        variant_code: "",
        adjustment_type: "FIXED_AMOUNT",
        adjustment_value: "0.0000",
      },
    ]);
  };

  const handleRemoveVariant = (index: number) => {
    setVariants(variants.filter((_, i) => i !== index));
  };

  const handleVariantChange = (
    index: number,
    field: string,
    value: string
  ) => {
    const updated = [...variants];
    updated[index] = { ...updated[index], [field]: value };
    setVariants(updated);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim() || !sku.trim() || !salesPrice) {
      error("Please fill in all required fields (Name, SKU, Sales Price).", "Validation Error");
      return;
    }

    const payload: ProductCreateInput = {
      name: name.trim(),
      sku: sku.trim().toUpperCase(),
      product_type: productType,
      sales_price: Number(salesPrice).toFixed(4),
      cost_price: costPrice ? Number(costPrice).toFixed(4) : undefined,
      currency: currency.trim().toUpperCase(),
      description: description.trim() || undefined,
      notes: notes.trim() || undefined,
      variants: variants
        .filter((v) => v.variant_name.trim() && v.variant_code.trim())
        .map((v) => ({
          variant_name: v.variant_name.trim(),
          variant_code: v.variant_code.trim().toUpperCase(),
          adjustment_type: v.adjustment_type,
          adjustment_value: Number(v.adjustment_value || 0).toFixed(4),
        })),
    };

    createMutation.mutate(payload);
  };

  return (
    <div className="fixed inset-0 z-50 bg-slate-900/40 backdrop-blur-xs flex items-center justify-center p-4 overflow-y-auto">
      <div className="bg-white rounded-xl shadow-xl border border-slate-200/80 w-full max-w-2xl my-8 overflow-hidden animate-in fade-in zoom-in-95 duration-150">
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100 bg-slate-50/50">
          <div className="flex items-center gap-2.5">
            <div className="h-8 w-8 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center">
              <Sparkles className="w-4 h-4" />
            </div>
            <div>
              <h3 className="font-semibold text-slate-900 text-base leading-tight">
                Create New Product
              </h3>
              <p className="text-xs text-slate-500">
                Add a product to Brightloop's authoritative catalog
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-1 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-5">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="space-y-1.5">
              <Label htmlFor="name">Product Name *</Label>
              <Input
                id="name"
                placeholder="e.g. Brightloop ERP Core"
                value={name}
                onChange={(e) => setName(e.target.value)}
                required
              />
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="sku">SKU / Internal Code *</Label>
              <Input
                id="sku"
                placeholder="e.g. ERP-CORE-V1"
                value={sku}
                onChange={(e) => setSku(e.target.value)}
                required
              />
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div className="space-y-1.5">
              <Label htmlFor="type">Product Type *</Label>
              <select
                id="type"
                className="w-full h-10 px-3 rounded-lg border border-slate-200 bg-white text-sm focus:outline-hidden focus:ring-2 focus:ring-blue-500/20 focus:border-blue-600"
                value={productType}
                onChange={(e) => setProductType(e.target.value as ProductType)}
              >
                <option value="SOFTWARE">Software</option>
                <option value="ADDON">Add-on</option>
                <option value="PHYSICAL_PRODUCT">Physical Product</option>
              </select>
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="currency">Currency *</Label>
              <Input
                id="currency"
                placeholder="INR"
                value={currency}
                maxLength={3}
                onChange={(e) => setCurrency(e.target.value)}
                required
              />
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="sales_price">Sales Price *</Label>
              <Input
                id="sales_price"
                type="number"
                step="0.0001"
                min="0"
                placeholder="2000.0000"
                value={salesPrice}
                onChange={(e) => setSalesPrice(e.target.value)}
                required
              />
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div className="space-y-1.5">
              <Label htmlFor="cost_price">Cost Price (Optional)</Label>
              <Input
                id="cost_price"
                type="number"
                step="0.0001"
                min="0"
                placeholder="500.0000"
                value={costPrice}
                onChange={(e) => setCostPrice(e.target.value)}
              />
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="description">Description</Label>
              <Input
                id="description"
                placeholder="Short summary of product"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
              />
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="notes">Internal Notes</Label>
              <Input
                id="notes"
                placeholder="Optional internal notes"
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
              />
            </div>
          </div>

          {/* Variants Builder Section */}
          <div className="pt-2 border-t border-slate-100">
            <div className="flex items-center justify-between mb-3">
              <div>
                <h4 className="text-sm font-semibold text-slate-900">
                  Initial Product Variants
                </h4>
                <p className="text-xs text-slate-500">
                  Optional variants with fixed or percentage adjustments
                </p>
              </div>
              <Button
                type="button"
                variant="outline"
                size="sm"
                onClick={handleAddVariant}
                className="gap-1 text-xs"
              >
                <Plus className="w-3.5 h-3.5" />
                Add Variant
              </Button>
            </div>

            {variants.length === 0 ? (
              <div className="p-4 border border-dashed border-slate-200 rounded-lg text-center bg-slate-50/50">
                <p className="text-xs text-slate-500">
                  No variants added. Product will use base pricing.
                </p>
              </div>
            ) : (
              <div className="space-y-3">
                {variants.map((v, idx) => (
                  <div
                    key={idx}
                    className="p-3 bg-slate-50 rounded-lg border border-slate-200/80 grid grid-cols-12 gap-2.5 items-center"
                  >
                    <div className="col-span-3">
                      <Input
                        placeholder="Variant Name"
                        value={v.variant_name}
                        onChange={(e) =>
                          handleVariantChange(idx, "variant_name", e.target.value)
                        }
                        className="text-xs h-9 bg-white"
                        required
                      />
                    </div>
                    <div className="col-span-2">
                      <Input
                        placeholder="CODE"
                        value={v.variant_code}
                        onChange={(e) =>
                          handleVariantChange(idx, "variant_code", e.target.value)
                        }
                        className="text-xs h-9 bg-white uppercase"
                        required
                      />
                    </div>
                    <div className="col-span-3">
                      <select
                        className="w-full h-9 px-2 rounded-lg border border-slate-200 bg-white text-xs"
                        value={v.adjustment_type}
                        onChange={(e) =>
                          handleVariantChange(
                            idx,
                            "adjustment_type",
                            e.target.value
                          )
                        }
                      >
                        <option value="FIXED_AMOUNT">+ Fixed Amount</option>
                        <option value="PERCENTAGE">+ Percentage (%)</option>
                      </select>
                    </div>
                    <div className="col-span-3">
                      <Input
                        type="number"
                        step="0.0001"
                        placeholder="Adjustment"
                        value={v.adjustment_value}
                        onChange={(e) =>
                          handleVariantChange(
                            idx,
                            "adjustment_value",
                            e.target.value
                          )
                        }
                        className="text-xs h-9 bg-white"
                        required
                      />
                    </div>
                    <div className="col-span-1 flex justify-center">
                      <button
                        type="button"
                        onClick={() => handleRemoveVariant(idx)}
                        className="p-1 text-slate-400 hover:text-rose-600 transition-colors"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          <div className="flex items-center justify-end gap-3 pt-4 border-t border-slate-100">
            <Button
              type="button"
              variant="outline"
              onClick={onClose}
              disabled={createMutation.isPending}
            >
              Cancel
            </Button>
            <Button
              type="submit"
              disabled={createMutation.isPending}
              className="bg-blue-600 hover:bg-blue-700 text-white gap-2"
            >
              {createMutation.isPending && (
                <Loader2 className="w-4 h-4 animate-spin" />
              )}
              Create Product
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
};
