import React from "react";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { AuthProvider, useAuth } from "@/contexts/AuthContext";
import { ToastProvider } from "@/components/ui/toast";
import { ProtectedRoute } from "@/components/auth/ProtectedRoute";
import { AppLayout } from "@/components/layout/AppLayout";

// Auth Pages
import { LoginPage } from "@/pages/auth/LoginPage";
import { RegisterPage } from "@/pages/auth/RegisterPage";
import { ForgotPasswordPage } from "@/pages/auth/ForgotPasswordPage";
import { ResetPasswordPage } from "@/pages/auth/ResetPasswordPage";

// Dashboard Pages
import { AdminDashboard } from "@/pages/dashboard/AdminDashboard";
import { StaffDashboard } from "@/pages/dashboard/StaffDashboard";
import { CustomerPortal } from "@/pages/dashboard/CustomerPortal";
import { UserManagementPage } from "@/pages/dashboard/UserManagementPage";
import { AuditLogsPage } from "@/pages/audit/AuditLogsPage";
import { ProfilePage } from "@/pages/profile/ProfilePage";

// Product & Plan Pages
import { ProductsListPage } from "@/pages/products/ProductsListPage";
import { ProductDetailsPage } from "@/pages/products/ProductDetailsPage";
import { PlansListPage } from "@/pages/plans/PlansListPage";
import { PlanDetailsPage } from "@/pages/plans/PlanDetailsPage";
import { CataloguePage } from "@/pages/catalogue/CataloguePage";

// Phase 3 Pages: Customer, Subscription, Invoicing
import { CustomersListPage } from "@/pages/customers/CustomersListPage";
import { CustomerDetailsPage } from "@/pages/customers/CustomerDetailsPage";
import { SubscriptionsListPage } from "@/pages/subscriptions/SubscriptionsListPage";
import { SubscriptionDetailsPage } from "@/pages/subscriptions/SubscriptionDetailsPage";
import { InvoicesListPage } from "@/pages/invoices/InvoicesListPage";
import { InvoiceDetailsPage } from "@/pages/invoices/InvoiceDetailsPage";

// Commercial Elevation Pages
import { QuotationTemplatesPage } from "@/pages/quotations/QuotationTemplatesPage";
import { DiscountsPage } from "@/pages/discounts/DiscountsPage";
import { TaxSettingsPage } from "@/pages/taxes/TaxSettingsPage";

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
      retry: 1,
    },
  },
});

// Component to dynamically redirect from "/" to appropriate role dashboard
const RootRedirect: React.FC = () => {
  const { user } = useAuth();
  if (!user) return <Navigate to="/login" replace />;
  if (user.role === "ADMIN") return <Navigate to="/admin" replace />;
  if (user.role === "STAFF") return <Navigate to="/staff" replace />;
  return <Navigate to="/portal" replace />;
};

export const App: React.FC = () => {
  return (
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <ToastProvider>
          <BrowserRouter>
            <Routes>
              {/* Public Authentication Routes */}
              <Route path="/login" element={<LoginPage />} />
              <Route path="/register" element={<RegisterPage />} />
              <Route path="/forgot-password" element={<ForgotPasswordPage />} />
              <Route path="/reset-password" element={<ResetPasswordPage />} />

              {/* Protected Application Layout */}
              <Route
                element={
                  <ProtectedRoute>
                    <AppLayout />
                  </ProtectedRoute>
                }
              >
                <Route path="/" element={<RootRedirect />} />

                {/* Admin Shell Routes */}
                <Route
                  path="/admin"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN"]}>
                      <AdminDashboard />
                    </ProtectedRoute>
                  }
                />
                <Route
                  path="/admin/users"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN"]}>
                      <UserManagementPage />
                    </ProtectedRoute>
                  }
                />

                {/* Staff Shell Routes */}
                <Route
                  path="/staff"
                  element={
                    <ProtectedRoute allowedRoles={["STAFF", "ADMIN"]}>
                      <StaffDashboard />
                    </ProtectedRoute>
                  }
                />
                <Route
                  path="/staff/customers"
                  element={<Navigate to="/customers" replace />}
                />

                {/* Customer Portal Shell Routes */}
                <Route
                  path="/portal"
                  element={
                    <ProtectedRoute allowedRoles={["CUSTOMER", "ADMIN", "STAFF"]}>
                      <CustomerPortal />
                    </ProtectedRoute>
                  }
                />
                <Route
                  path="/portal/subscriptions"
                  element={<Navigate to="/subscriptions" replace />}
                />
                <Route
                  path="/portal/invoices"
                  element={<Navigate to="/invoices" replace />}
                />

                {/* Subscription & Product Catalogue (Admin, Staff, Customer) */}
                <Route
                  path="/catalogue"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN", "STAFF", "CUSTOMER"]}>
                      <CataloguePage />
                    </ProtectedRoute>
                  }
                />

                {/* Product Catalog (Admin & Staff) */}
                <Route
                  path="/products"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN", "STAFF"]}>
                      <ProductsListPage />
                    </ProtectedRoute>
                  }
                />
                <Route
                  path="/products/:id"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN", "STAFF"]}>
                      <ProductDetailsPage />
                    </ProtectedRoute>
                  }
                />

                {/* Subscription Plans (Admin & Staff) */}
                <Route
                  path="/plans"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN", "STAFF"]}>
                      <PlansListPage />
                    </ProtectedRoute>
                  }
                />
                <Route
                  path="/plans/:id"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN", "STAFF"]}>
                      <PlanDetailsPage />
                    </ProtectedRoute>
                  }
                />

                {/* Phase 3: Customer Management (Admin & Staff) */}
                <Route
                  path="/customers"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN", "STAFF"]}>
                      <CustomersListPage />
                    </ProtectedRoute>
                  }
                />
                <Route
                  path="/customers/:id"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN", "STAFF", "CUSTOMER"]}>
                      <CustomerDetailsPage />
                    </ProtectedRoute>
                  }
                />

                {/* Phase 3: Subscriptions (All Roles with server-side isolation) */}
                <Route
                  path="/subscriptions"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN", "STAFF", "CUSTOMER"]}>
                      <SubscriptionsListPage />
                    </ProtectedRoute>
                  }
                />
                <Route
                  path="/subscriptions/:id"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN", "STAFF", "CUSTOMER"]}>
                      <SubscriptionDetailsPage />
                    </ProtectedRoute>
                  }
                />

                {/* Phase 3: Invoices & Payments (All Roles with server-side isolation) */}
                <Route
                  path="/invoices"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN", "STAFF", "CUSTOMER"]}>
                      <InvoicesListPage />
                    </ProtectedRoute>
                  }
                />
                <Route
                  path="/invoices/:id"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN", "STAFF", "CUSTOMER"]}>
                      <InvoiceDetailsPage />
                    </ProtectedRoute>
                  }
                />

                {/* Commercial Elevation: Quotations, Discounts, Taxes */}
                <Route
                  path="/quotations"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN", "STAFF", "CUSTOMER"]}>
                      <QuotationTemplatesPage />
                    </ProtectedRoute>
                  }
                />
                <Route
                  path="/discounts"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN", "STAFF"]}>
                      <DiscountsPage />
                    </ProtectedRoute>
                  }
                />
                <Route
                  path="/taxes"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN", "STAFF"]}>
                      <TaxSettingsPage />
                    </ProtectedRoute>
                  }
                />

                {/* Audit Logs (Admin & Staff) */}
                <Route
                  path="/audit-logs"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN", "STAFF"]}>
                      <AuditLogsPage />
                    </ProtectedRoute>
                  }
                />

                {/* User Profile (All Authenticated Users) */}
                <Route path="/profile" element={<ProfilePage />} />
              </Route>

              {/* Catch-all */}
              <Route path="*" element={<Navigate to="/" replace />} />
            </Routes>
          </BrowserRouter>
        </ToastProvider>
      </AuthProvider>
    </QueryClientProvider>
  );
};

export default App;
