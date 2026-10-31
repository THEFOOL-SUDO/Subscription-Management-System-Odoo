import React, { useState } from "react";
import { useParams, Link } from "react-router-dom";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { customersApi } from "@/api/customers";
import { subscriptionsApi } from "@/api/subscriptions";
import { invoicesApi } from "@/api/invoices";
import { useAuth } from "@/hooks/useAuth";
import { CustomerUpdate } from "@/types";
import { useToast } from "@/components/ui/toast";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { formatDate, formatCurrency } from "@/lib/utils";
import {
  Building2,
  Mail,
  Phone,
  MapPin,
  Calendar,
  CreditCard,
  FileText,
  Loader2,
  Edit,
  ArrowLeft,
  ArrowRight,
} from "lucide-react";

export const CustomerDetailsPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const { user } = useAuth();
  const { success, error } = useToast();
  const queryClient = useQueryClient();
  const isOperator = user?.role === "ADMIN" || user?.role === "STAFF";

  const [isEditing, setIsEditing] = useState(false);
  const [activeTab, setActiveTab] = useState<"subscriptions" | "invoices">("subscriptions");

  // Edit form state
  const [name, setName] = useState("");
  const [phone, setPhone] = useState("");
  const [companyName, setCompanyName] = useState("");
  const [address1, setAddress1] = useState("");
  const [city, setCity] = useState("");
  const [state, setState] = useState("");
  const [postalCode, setPostalCode] = useState("");
  const [country, setCountry] = useState("");
  const [status, setStatus] = useState<"ACTIVE" | "INACTIVE">("ACTIVE");

  const { data: customer, isLoading: isLoadingCustomer } = useQuery({
    queryKey: ["customer", id],
    queryFn: async () => {
      if (!id) throw new Error("Missing customer ID");
      const c = await customersApi.getCustomer(id);
      setName(c.name);
      setPhone(c.phone || "");
      setCompanyName(c.company_name || "");
      setAddress1(c.billing_address_line1 || "");
      setCity(c.billing_city || "");
      setState(c.billing_state || "");
      setPostalCode(c.billing_postal_code || "");
      setCountry(c.billing_country || "India");
      setStatus(c.status);
      return c;
    },
    enabled: !!id,
  });

  const { data: subscriptionsData, isLoading: isLoadingSubs } = useQuery({
    queryKey: ["customer-subscriptions", id],
    queryFn: () => subscriptionsApi.listSubscriptions({ customer_id: id, limit: 50 }),
    enabled: !!id,
  });

  const { data: invoicesData, isLoading: isLoadingInvoices } = useQuery({
    queryKey: ["customer-invoices", id],
    queryFn: () => invoicesApi.listInvoices({ customer_id: id, limit: 50 }),
    enabled: !!id,
  });

  const updateMutation = useMutation({
    mutationFn: (data: CustomerUpdate) => {
      if (!id) throw new Error("Missing customer ID");
      return customersApi.updateCustomer(id, data);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["customer", id] });
      queryClient.invalidateQueries({ queryKey: ["customers"] });
      success("Customer details updated successfully", "Customer Updated");
      setIsEditing(false);
    },
    onError: (err: any) => {
      error(err.response?.data?.detail || "Failed to update customer", "Update Failed");
    },
  });

  if (isLoadingCustomer) {
    return (
      <div className="py-24 text-center">
        <Loader2 className="w-8 h-8 animate-spin mx-auto text-blue-600 mb-3" />
        <p className="text-sm text-slate-500">Loading customer account details...</p>
      </div>
    );
  }

  if (!customer) {
    return (
      <div className="py-12 text-center space-y-4">
        <h2 className="text-lg font-bold text-slate-800">Customer record not found</h2>
        <Link to="/customers">
          <Button variant="outline" className="gap-2">
            <ArrowLeft className="w-4 h-4" />
            Back to Customer Directory
          </Button>
        </Link>
      </div>
    );
  }

  const handleUpdate = (e: React.FormEvent) => {
    e.preventDefault();
    updateMutation.mutate({
      name: name.trim(),
      phone: phone.trim() || null,
      company_name: companyName.trim() || null,
      billing_address_line1: address1.trim() || null,
      billing_city: city.trim() || null,
      billing_state: state.trim() || null,
      billing_postal_code: postalCode.trim() || null,
      billing_country: country.trim() || "India",
      status: status,
    });
  };

  return (
    <div className="space-y-6">
      {/* Back button & Title */}
      <div className="flex items-center justify-between">
        <Link to="/customers">
          <Button variant="ghost" size="sm" className="gap-1.5 text-slate-600">
            <ArrowLeft className="w-4 h-4" />
            Back to Customers
          </Button>
        </Link>
        {isOperator && !isEditing && (
          <Button variant="outline" size="sm" onClick={() => setIsEditing(true)} className="gap-1.5">
            <Edit className="w-4 h-4 text-slate-500" />
            Edit Profile
          </Button>
        )}
      </div>

      {/* Customer Header Banner */}
      <Card>
        <CardContent className="p-6">
          <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
            <div>
              <div className="flex items-center gap-2.5">
                <h1 className="text-2xl font-bold tracking-tight text-slate-900">{customer.name}</h1>
                <Badge variant={customer.status === "ACTIVE" ? "success" : "neutral"}>
                  {customer.status}
                </Badge>
              </div>
              <p className="text-xs font-mono text-slate-400 mt-0.5">
                Customer Number: {customer.customer_number}
              </p>
            </div>

            <div className="flex items-center gap-2">
              <Link to="/subscriptions">
                <Button size="sm" className="gap-1.5">
                  <CreditCard className="w-4 h-4" />
                  New Subscription
                </Button>
              </Link>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mt-6 pt-6 border-t border-slate-100 text-xs">
            <div className="flex items-start gap-2">
              <Mail className="w-4 h-4 text-slate-400 shrink-0 mt-0.5" />
              <div>
                <span className="text-slate-400 block font-medium">Email Address</span>
                <span className="font-semibold text-slate-800">{customer.email}</span>
              </div>
            </div>

            <div className="flex items-start gap-2">
              <Phone className="w-4 h-4 text-slate-400 shrink-0 mt-0.5" />
              <div>
                <span className="text-slate-400 block font-medium">Contact Phone</span>
                <span className="font-semibold text-slate-800">{customer.phone || "Not configured"}</span>
              </div>
            </div>

            <div className="flex items-start gap-2">
              <Building2 className="w-4 h-4 text-slate-400 shrink-0 mt-0.5" />
              <div>
                <span className="text-slate-400 block font-medium">Company</span>
                <span className="font-semibold text-slate-800">{customer.company_name || "Individual"}</span>
              </div>
            </div>

            <div className="flex items-start gap-2">
              <Calendar className="w-4 h-4 text-slate-400 shrink-0 mt-0.5" />
              <div>
                <span className="text-slate-400 block font-medium">Customer Since</span>
                <span className="font-semibold text-slate-800">{formatDate(customer.created_at)}</span>
              </div>
            </div>
          </div>

          {/* Billing Address display */}
          <div className="mt-4 p-3 bg-slate-50 border border-slate-100 rounded-lg flex items-start gap-2 text-xs text-slate-600">
            <MapPin className="w-4 h-4 text-slate-400 shrink-0 mt-0.5" />
            <div>
              <span className="font-semibold text-slate-700">Billing Address: </span>
              {customer.billing_address_line1 ? (
                <span>
                  {customer.billing_address_line1}
                  {customer.billing_city && `, ${customer.billing_city}`}
                  {customer.billing_state && `, ${customer.billing_state}`}
                  {customer.billing_postal_code && ` - ${customer.billing_postal_code}`}
                  {customer.billing_country && `, ${customer.billing_country}`}
                </span>
              ) : (
                <span className="italic text-slate-400">No billing address saved yet.</span>
              )}
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Edit Form Modal/Drawer if editing */}
      {isEditing && (
        <Card className="border-blue-200 bg-blue-50/20">
          <CardHeader className="pb-3">
            <CardTitle className="text-base font-bold text-slate-900">Edit Customer Information</CardTitle>
            <CardDescription className="text-xs">
              Update contact info, organization details, and account status.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleUpdate} className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div className="space-y-1.5">
                  <Label htmlFor="custName">Customer Name</Label>
                  <Input id="custName" value={name} onChange={(e) => setName(e.target.value)} required />
                </div>
                <div className="space-y-1.5">
                  <Label htmlFor="custCompany">Company Name</Label>
                  <Input id="custCompany" value={companyName} onChange={(e) => setCompanyName(e.target.value)} />
                </div>
                <div className="space-y-1.5">
                  <Label htmlFor="custPhone">Phone Number</Label>
                  <Input id="custPhone" value={phone} onChange={(e) => setPhone(e.target.value)} />
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                <div className="space-y-1.5">
                  <Label htmlFor="custAddress">Street Address</Label>
                  <Input id="custAddress" value={address1} onChange={(e) => setAddress1(e.target.value)} />
                </div>
                <div className="space-y-1.5">
                  <Label htmlFor="custCity">City</Label>
                  <Input id="custCity" value={city} onChange={(e) => setCity(e.target.value)} />
                </div>
                <div className="space-y-1.5">
                  <Label htmlFor="custState">State</Label>
                  <Input id="custState" value={state} onChange={(e) => setState(e.target.value)} />
                </div>
                <div className="space-y-1.5">
                  <Label htmlFor="custStatus">Account Status</Label>
                  <select
                    id="custStatus"
                    value={status}
                    onChange={(e) => setStatus(e.target.value as any)}
                    className="w-full h-9 px-3 rounded-md border border-slate-200 bg-white text-sm"
                  >
                    <option value="ACTIVE">ACTIVE</option>
                    <option value="INACTIVE">INACTIVE</option>
                  </select>
                </div>
              </div>

              <div className="flex justify-end gap-2 pt-2">
                <Button type="button" variant="outline" size="sm" onClick={() => setIsEditing(false)}>
                  Cancel
                </Button>
                <Button type="submit" size="sm" disabled={updateMutation.isPending} className="gap-1.5">
                  {updateMutation.isPending && <Loader2 className="w-4 h-4 animate-spin" />}
                  Save Changes
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      )}

      {/* Tabs: Subscriptions vs Invoices */}
      <div className="flex items-center gap-2 border-b border-slate-200">
        <button
          onClick={() => setActiveTab("subscriptions")}
          className={`flex items-center gap-2 pb-3 px-3 text-sm font-semibold border-b-2 transition-colors ${
            activeTab === "subscriptions"
              ? "border-blue-600 text-blue-600"
              : "border-transparent text-slate-500 hover:text-slate-800"
          }`}
        >
          <CreditCard className="w-4 h-4" />
          Subscriptions ({subscriptionsData?.total || 0})
        </button>
        <button
          onClick={() => setActiveTab("invoices")}
          className={`flex items-center gap-2 pb-3 px-3 text-sm font-semibold border-b-2 transition-colors ${
            activeTab === "invoices"
              ? "border-blue-600 text-blue-600"
              : "border-transparent text-slate-500 hover:text-slate-800"
          }`}
        >
          <FileText className="w-4 h-4" />
          Invoices & Billing ({invoicesData?.total || 0})
        </button>
      </div>

      {/* Subscriptions Tab Content */}
      {activeTab === "subscriptions" && (
        <Card>
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm text-slate-600">
              <thead className="bg-slate-50 border-b border-slate-200/80 text-xs uppercase font-semibold text-slate-500">
                <tr>
                  <th className="py-3 px-4">Subscription #</th>
                  <th className="py-3 px-4">Plan Name</th>
                  <th className="py-3 px-4">Cadence</th>
                  <th className="py-3 px-4">Status</th>
                  <th className="py-3 px-4">Total Amount</th>
                  <th className="py-3 px-4 text-right">Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {isLoadingSubs ? (
                  <tr>
                    <td colSpan={6} className="py-8 text-center text-slate-400">
                      <Loader2 className="w-5 h-5 animate-spin mx-auto mb-1 text-blue-600" />
                      Loading subscriptions...
                    </td>
                  </tr>
                ) : subscriptionsData?.items.length === 0 ? (
                  <tr>
                    <td colSpan={6} className="py-8 text-center text-slate-400">
                      No subscriptions found for this customer.
                    </td>
                  </tr>
                ) : (
                  subscriptionsData?.items.map((sub) => (
                    <tr key={sub.id} className="hover:bg-slate-50 transition-colors">
                      <td className="py-3 px-4 font-mono font-medium text-slate-900">
                        {sub.subscription_number}
                      </td>
                      <td className="py-3 px-4 font-semibold text-slate-800">
                        {sub.plan?.name || "Standard Plan"}
                      </td>
                      <td className="py-3 px-4 text-xs text-slate-500">
                        {sub.billing_interval} ({sub.interval_count}x)
                      </td>
                      <td className="py-3 px-4">
                        <Badge
                          variant={
                            sub.status === "ACTIVE"
                              ? "success"
                              : sub.status === "CONFIRMED"
                              ? "info"
                              : sub.status === "QUOTATION"
                              ? "warning"
                              : "neutral"
                          }
                        >
                          {sub.status}
                        </Badge>
                      </td>
                      <td className="py-3 px-4 font-mono font-semibold text-slate-900">
                        {formatCurrency(sub.total_amount, sub.currency)}
                      </td>
                      <td className="py-3 px-4 text-right">
                        <Link to={`/subscriptions/${sub.id}`}>
                          <Button variant="ghost" size="sm" className="gap-1 text-xs">
                            View <ArrowRight className="w-3 h-3" />
                          </Button>
                        </Link>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </Card>
      )}

      {/* Invoices Tab Content */}
      {activeTab === "invoices" && (
        <Card>
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm text-slate-600">
              <thead className="bg-slate-50 border-b border-slate-200/80 text-xs uppercase font-semibold text-slate-500">
                <tr>
                  <th className="py-3 px-4">Invoice #</th>
                  <th className="py-3 px-4">Issue Date</th>
                  <th className="py-3 px-4">Due Date</th>
                  <th className="py-3 px-4">Lifecycle</th>
                  <th className="py-3 px-4">Payment</th>
                  <th className="py-3 px-4">Total</th>
                  <th className="py-3 px-4">Balance Due</th>
                  <th className="py-3 px-4 text-right">Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {isLoadingInvoices ? (
                  <tr>
                    <td colSpan={8} className="py-8 text-center text-slate-400">
                      <Loader2 className="w-5 h-5 animate-spin mx-auto mb-1 text-blue-600" />
                      Loading invoices...
                    </td>
                  </tr>
                ) : invoicesData?.items.length === 0 ? (
                  <tr>
                    <td colSpan={8} className="py-8 text-center text-slate-400">
                      No invoices found for this customer.
                    </td>
                  </tr>
                ) : (
                  invoicesData?.items.map((inv) => (
                    <tr key={inv.id} className="hover:bg-slate-50 transition-colors">
                      <td className="py-3 px-4 font-mono font-medium text-slate-900">
                        {inv.invoice_number}
                      </td>
                      <td className="py-3 px-4 text-xs text-slate-500">
                        {formatDate(inv.issue_date)}
                      </td>
                      <td className="py-3 px-4 text-xs text-slate-500">
                        {formatDate(inv.due_date)}
                      </td>
                      <td className="py-3 px-4">
                        <Badge
                          variant={
                            inv.status === "PAID"
                              ? "success"
                              : inv.status === "CONFIRMED"
                              ? "info"
                              : inv.status === "CANCELLED"
                              ? "destructive"
                              : "neutral"
                          }
                        >
                          {inv.status}
                        </Badge>
                      </td>
                      <td className="py-3 px-4">
                        <Badge
                          variant={
                            inv.payment_status === "PAID"
                              ? "success"
                              : inv.payment_status === "PARTIALLY_PAID"
                              ? "warning"
                              : "destructive"
                          }
                        >
                          {inv.payment_status}
                        </Badge>
                      </td>
                      <td className="py-3 px-4 font-mono text-slate-900">
                        {formatCurrency(inv.total_amount, inv.currency)}
                      </td>
                      <td className="py-3 px-4 font-mono font-semibold text-slate-900">
                        {formatCurrency(inv.balance_due, inv.currency)}
                      </td>
                      <td className="py-3 px-4 text-right">
                        <Link to={`/invoices/${inv.id}`}>
                          <Button variant="ghost" size="sm" className="gap-1 text-xs">
                            View <ArrowRight className="w-3 h-3" />
                          </Button>
                        </Link>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </Card>
      )}
    </div>
  );
};
