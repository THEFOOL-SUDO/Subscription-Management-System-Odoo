import React, { useState } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { customersApi } from "@/api/customers";
import { CustomerCreate } from "@/types";
import { useToast } from "@/components/ui/toast";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { X, Loader2, UserCheck, ShieldCheck } from "lucide-react";

interface CustomerCreateModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess?: (customerId: string) => void;
}

export const CustomerCreateModal: React.FC<CustomerCreateModalProps> = ({
  isOpen,
  onClose,
  onSuccess,
}) => {
  const { success, error } = useToast();
  const queryClient = useQueryClient();

  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [companyName, setCompanyName] = useState("");
  const [billingAddress1, setBillingAddress1] = useState("");
  const [billingCity, setBillingCity] = useState("");
  const [billingState, setBillingState] = useState("");
  const [billingPostalCode, setBillingPostalCode] = useState("");
  const [billingCountry, setBillingCountry] = useState("India");

  const createMutation = useMutation({
    mutationFn: (data: CustomerCreate) => customersApi.createCustomer(data),
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ["customers"] });
      queryClient.invalidateQueries({ queryKey: ["dashboard-metrics"] });
      success(`Successfully registered customer ${data.name} (${data.customer_number})`, "Customer Created");
      onClose();
      if (onSuccess) onSuccess(data.id);
    },
    onError: (err: any) => {
      error(
        err.response?.data?.detail || "Failed to create customer. Please verify inputs.",
        "Registration Failed"
      );
    },
  });

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim() || !email.trim()) {
      error("Name and primary email are strictly required.", "Validation Error");
      return;
    }

    createMutation.mutate({
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim() || null,
      company_name: companyName.trim() || null,
      billing_address_line1: billingAddress1.trim() || null,
      billing_city: billingCity.trim() || null,
      billing_state: billingState.trim() || null,
      billing_postal_code: billingPostalCode.trim() || null,
      billing_country: billingCountry.trim() || "India",
    });
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Backdrop */}
      <div
        className="fixed inset-0 bg-slate-900/40 backdrop-blur-xs transition-opacity"
        onClick={onClose}
      />

      {/* Modal Dialog */}
      <div className="relative z-50 w-full max-w-xl rounded-xl bg-white p-6 shadow-xl border border-slate-200 flex flex-col max-h-[90vh]">
        <div className="flex items-center justify-between pb-3 border-b border-slate-100">
          <div className="flex items-center gap-2">
            <div className="p-2 bg-blue-50 text-blue-700 rounded-lg">
              <UserCheck className="w-5 h-5" />
            </div>
            <div>
              <h2 className="text-lg font-bold text-slate-900">Register New Customer</h2>
              <p className="text-xs text-slate-500">
                Create customer account profile and link portal credentials
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="rounded-lg p-1 text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Informational Callout */}
        <div className="my-3 p-3 bg-slate-50 border border-slate-200/80 rounded-lg flex items-start gap-2.5 text-xs text-slate-600">
          <ShieldCheck className="w-4 h-4 text-blue-600 shrink-0 mt-0.5" />
          <p>
            Customer accounts automatically link to an existing user if registered, or auto-provision a secure customer portal account with a setup notification sent via email.
          </p>
        </div>

        <form onSubmit={handleSubmit} className="flex-1 overflow-y-auto space-y-4 pr-1">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-1.5">
              <Label htmlFor="name">
                Full Name <span className="text-red-500">*</span>
              </Label>
              <Input
                id="name"
                placeholder="e.g. Acme Corp / Rahul Sharma"
                value={name}
                onChange={(e) => setName(e.target.value)}
                required
              />
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="email">
                Primary Email <span className="text-red-500">*</span>
              </Label>
              <Input
                id="email"
                type="email"
                placeholder="billing@acmecorp.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-1.5">
              <Label htmlFor="companyName">Company / Organization</Label>
              <Input
                id="companyName"
                placeholder="Acme Global Technologies Pvt Ltd"
                value={companyName}
                onChange={(e) => setCompanyName(e.target.value)}
              />
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="phone">Phone / Mobile</Label>
              <Input
                id="phone"
                placeholder="+91 98765 43210"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
              />
            </div>
          </div>

          <div className="pt-2 border-t border-slate-100">
            <h4 className="text-xs font-semibold uppercase tracking-wider text-slate-500 mb-2">
              Billing Address Details
            </h4>
            <div className="space-y-3">
              <div className="space-y-1.5">
                <Label htmlFor="billingAddress1">Street Address</Label>
                <Input
                  id="billingAddress1"
                  placeholder="Plot 42, Electronics City Phase 1"
                  value={billingAddress1}
                  onChange={(e) => setBillingAddress1(e.target.value)}
                />
              </div>

              <div className="grid grid-cols-3 gap-3">
                <div className="space-y-1.5">
                  <Label htmlFor="billingCity">City</Label>
                  <Input
                    id="billingCity"
                    placeholder="Bengaluru"
                    value={billingCity}
                    onChange={(e) => setBillingCity(e.target.value)}
                  />
                </div>
                <div className="space-y-1.5">
                  <Label htmlFor="billingState">State</Label>
                  <Input
                    id="billingState"
                    placeholder="Karnataka"
                    value={billingState}
                    onChange={(e) => setBillingState(e.target.value)}
                  />
                </div>
                <div className="space-y-1.5">
                  <Label htmlFor="billingPostalCode">Postal Code</Label>
                  <Input
                    id="billingPostalCode"
                    placeholder="560100"
                    value={billingPostalCode}
                    onChange={(e) => setBillingPostalCode(e.target.value)}
                  />
                </div>
              </div>

              <div className="space-y-1.5">
                <Label htmlFor="billingCountry">Country</Label>
                <Input
                  id="billingCountry"
                  value={billingCountry}
                  onChange={(e) => setBillingCountry(e.target.value)}
                />
              </div>
            </div>
          </div>

          <div className="flex justify-end gap-2 pt-4 border-t border-slate-100">
            <Button type="button" variant="outline" onClick={onClose}>
              Cancel
            </Button>
            <Button type="submit" disabled={createMutation.isPending} className="gap-1.5">
              {createMutation.isPending && <Loader2 className="w-4 h-4 animate-spin" />}
              Create Customer Account
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
};

