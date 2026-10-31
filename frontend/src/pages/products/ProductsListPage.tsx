import React, { useState } from "react";
import { Link } from "react-router-dom";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { productsApi } from "@/api/products";
import { ProductType } from "@/types";
import { useAuth } from "@/hooks/useAuth";
import { useToast } from "@/components/ui/toast";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { ProductCreateModal } from "./ProductCreateModal";
import {
  Package,
  Plus,
  Search,
  ArrowRight,
  Archive,
  CheckCircle2,
  AlertCircle,
  Loader2,
} from "lucide-react";

export const ProductsListPage: React.FC = () => {
  const { user } = useAuth();
  const { success, error: toastError } = useToast();
  const queryClient = useQueryClient();
  const isAdmin = user?.role === "ADMIN";

  const [page, setPage] = useState(1);
  const [search, setSearch] = useState("");
  const [productType, setProductType] = useState<string>("ALL");
  const [statusFilter, setStatusFilter] = useState<string>("ACTIVE");
  const [isCreateOpen, setIsCreateOpen] = useState(false);

  const { data, isLoading, error } = useQuery({
    queryKey: ["products", page, search, productType, statusFilter],
    queryFn: () =>
      productsApi.listProducts({
        page,
        limit: 10,
        search: search.trim() || undefined,
        product_type:
          productType !== "ALL" ? (productType as ProductType) : undefined,
        is_archived:
          statusFilter === "ARCHIVED"
            ? true
            : statusFilter === "ACTIVE"
            ? false
            : undefined,
      }),
  });

  const archiveMutation = useMutation({
    mutationFn: (productId: string) => productsApi.archiveProduct(productId),
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ["products"] });
      success(`${data.name} (${data.sku}) has been safely archived.`, "Product Archived");
    },
    onError: (err: any) => {
      toastError(err.response?.data?.detail || "Failed to archive product.", "Archival Failed");
    },
  });

  const handleArchive = (id: string, name: string) => {
    if (
      window.confirm(
        `Are you sure you want to archive "${name}"? It will deactivate associated plan line items.`
      )
    ) {
      archiveMutation.mutate(id);
    }
  };

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
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">
            Product Catalog
          </h1>
          <p className="text-sm text-slate-500 mt-1">
            Authoritative inventory of software, add-ons, and product variants
          </p>
        </div>
        {isAdmin && (
          <Button
            onClick={() => setIsCreateOpen(true)}
            className="bg-blue-600 hover:bg-blue-700 text-white gap-2 shrink-0 shadow-xs"
          >
            <Plus className="w-4 h-4" />
            Add New Product
          </Button>
        )}
      </div>

      {/* Filter and Search Bar */}
      <div className="bg-white p-4 rounded-xl border border-slate-200/80 shadow-xs flex flex-col md:flex-row gap-3 items-stretch md:items-center justify-between">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <Input
            placeholder="Search products by name, SKU or keyword..."
            value={search}
            onChange={(e) => {
              setSearch(e.target.value);
              setPage(1);
            }}
            className="pl-9 bg-slate-50/50 border-slate-200"
          />
        </div>

        <div className="flex flex-wrap items-center gap-2.5">
          <div className="flex items-center gap-1 bg-slate-100 p-1 rounded-lg">
            <button
              onClick={() => {
                setStatusFilter("ACTIVE");
                setPage(1);
              }}
              className={`px-3 py-1.5 text-xs font-medium rounded-md transition-colors ${
                statusFilter === "ACTIVE"
                  ? "bg-white text-slate-900 shadow-xs"
                  : "text-slate-600 hover:text-slate-900"
              }`}
            >
              Active
            </button>
            <button
              onClick={() => {
                setStatusFilter("ARCHIVED");
                setPage(1);
              }}
              className={`px-3 py-1.5 text-xs font-medium rounded-md transition-colors ${
                statusFilter === "ARCHIVED"
                  ? "bg-white text-slate-900 shadow-xs"
                  : "text-slate-600 hover:text-slate-900"
              }`}
            >
              Archived
            </button>
            <button
              onClick={() => {
                setStatusFilter("ALL");
                setPage(1);
              }}
              className={`px-3 py-1.5 text-xs font-medium rounded-md transition-colors ${
                statusFilter === "ALL"
                  ? "bg-white text-slate-900 shadow-xs"
                  : "text-slate-600 hover:text-slate-900"
              }`}
            >
              All
            </button>
          </div>

          <select
            value={productType}
            onChange={(e) => {
              setProductType(e.target.value);
              setPage(1);
            }}
            className="h-9 px-3 rounded-lg border border-slate-200 bg-white text-xs font-medium text-slate-700"
          >
            <option value="ALL">All Types</option>
            <option value="SOFTWARE">Software</option>
            <option value="ADDON">Add-on</option>
            <option value="PHYSICAL_PRODUCT">Physical Product</option>
          </select>
        </div>
      </div>

      {/* Products Table Card */}
      <div className="bg-white rounded-xl border border-slate-200/80 shadow-xs overflow-hidden">
        {isLoading ? (
          <div className="p-12 text-center">
            <Loader2 className="w-6 h-6 animate-spin text-blue-600 mx-auto mb-2" />
            <p className="text-sm text-slate-500">Loading catalog items...</p>
          </div>
        ) : error ? (
          <div className="p-8 text-center text-rose-600">
            <AlertCircle className="w-8 h-8 mx-auto mb-2" />
            <p className="text-sm font-medium">Failed to load products.</p>
          </div>
        ) : !data || data.items.length === 0 ? (
          <div className="p-12 text-center">
            <div className="h-12 w-12 rounded-xl bg-slate-100 text-slate-400 flex items-center justify-center mx-auto mb-3">
              <Package className="w-6 h-6" />
            </div>
            <h3 className="font-semibold text-slate-900 text-base">
              No products found
            </h3>
            <p className="text-sm text-slate-500 mt-1 max-w-sm mx-auto">
              {search || productType !== "ALL"
                ? "No products match your active search filters."
                : "No products exist in your catalog yet. Click Add New Product to get started."}
            </p>
          </div>
        ) : (
          <div className="overflow-x-auto max-h-[700px] overflow-y-auto">
            <table className="w-full text-left text-sm">
              <thead className="sticky top-0 bg-slate-50/95 backdrop-blur-xs z-10 border-b border-slate-200 text-xs font-semibold text-slate-500 uppercase tracking-wider">
                <tr>
                  <th className="py-3 px-4">Product</th>
                  <th className="py-3 px-4">SKU</th>
                  <th className="py-3 px-4">Type</th>
                  <th className="py-3 px-4">Sales Price</th>
                  <th className="py-3 px-4">Variants</th>
                  <th className="py-3 px-4">Status</th>
                  <th className="py-3 px-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {data.items.map((prod) => (
                  <tr
                    key={prod.id}
                    className="hover:bg-slate-50/50 transition-colors"
                  >
                    <td className="py-3.5 px-4">
                      <div className="font-semibold text-slate-900">
                        {prod.name}
                      </div>
                      {prod.description && (
                        <div className="text-xs text-slate-500 truncate max-w-xs">
                          {prod.description}
                        </div>
                      )}
                    </td>
                    <td className="py-3.5 px-4 font-mono text-xs font-medium text-slate-600">
                      {prod.sku}
                    </td>
                    <td className="py-3.5 px-4">
                      <Badge
                        variant="secondary"
                        className={
                          prod.product_type === "SOFTWARE"
                            ? "bg-blue-50 text-blue-700 border-blue-200"
                            : prod.product_type === "ADDON"
                            ? "bg-purple-50 text-purple-700 border-purple-200"
                            : "bg-emerald-50 text-emerald-700 border-emerald-200"
                        }
                      >
                        {prod.product_type === "SOFTWARE"
                          ? "Software"
                          : prod.product_type === "ADDON"
                          ? "Add-on"
                          : "Physical"}
                      </Badge>
                    </td>
                    <td className="py-3.5 px-4 font-semibold text-slate-900">
                      {formatPrice(prod.sales_price, prod.currency)}
                      {prod.cost_price && (
                        <span className="block text-[11px] font-normal text-slate-400">
                          Cost: {formatPrice(prod.cost_price, prod.currency)}
                        </span>
                      )}
                    </td>
                    <td className="py-3.5 px-4 text-slate-600">
                      <span className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-700">
                        {prod.variants_count} {prod.variants_count === 1 ? "variant" : "variants"}
                      </span>
                    </td>
                    <td className="py-3.5 px-4">
                      {prod.is_archived ? (
                        <span className="inline-flex items-center gap-1 text-xs font-medium text-slate-500 bg-slate-100 px-2 py-0.5 rounded-full">
                          <Archive className="w-3 h-3" />
                          Archived
                        </span>
                      ) : prod.is_active ? (
                        <span className="inline-flex items-center gap-1 text-xs font-medium text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200">
                          <CheckCircle2 className="w-3 h-3" />
                          Active
                        </span>
                      ) : (
                        <span className="inline-flex items-center gap-1 text-xs font-medium text-amber-700 bg-amber-50 px-2 py-0.5 rounded-full border border-amber-200">
                          Inactive
                        </span>
                      )}
                    </td>
                    <td className="py-3.5 px-4 text-right">
                      <div className="flex items-center justify-end gap-2">
                        <Link to={`/products/${prod.id}`}>
                          <Button
                            variant="ghost"
                            size="sm"
                            className="text-blue-600 hover:text-blue-700 hover:bg-blue-50 text-xs gap-1"
                          >
                            Manage
                            <ArrowRight className="w-3 h-3" />
                          </Button>
                        </Link>
                        {isAdmin && !prod.is_archived && (
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => handleArchive(prod.id, prod.name)}
                            disabled={archiveMutation.isPending}
                            className="text-slate-400 hover:text-rose-600 hover:bg-rose-50 text-xs"
                          >
                            <Archive className="w-3.5 h-3.5" />
                          </Button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {/* Pagination Footer */}
        {data && data.total_pages > 1 && (
          <div className="p-4 border-t border-slate-100 bg-slate-50/50 flex items-center justify-between">
            <span className="text-xs text-slate-500">
              Showing page {data.page} of {data.total_pages} ({data.total} total products)
            </span>
            <div className="flex items-center gap-2">
              <Button
                variant="outline"
                size="sm"
                onClick={() => setPage((p) => Math.max(1, p - 1))}
                disabled={page <= 1}
                className="text-xs"
              >
                Previous
              </Button>
              <Button
                variant="outline"
                size="sm"
                onClick={() => setPage((p) => Math.min(data.total_pages, p + 1))}
                disabled={page >= data.total_pages}
                className="text-xs"
              >
                Next
              </Button>
            </div>
          </div>
        )}
      </div>

      <ProductCreateModal
        isOpen={isCreateOpen}
        onClose={() => setIsCreateOpen(false)}
      />
    </div>
  );
};
