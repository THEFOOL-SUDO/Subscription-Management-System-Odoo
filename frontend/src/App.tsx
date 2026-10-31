import React, { Suspense, lazy } from "react";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { AuthProvider, useAuth } from "@/contexts/AuthContext";
import { ToastProvider } from "@/components/ui/toast";
import { ProtectedRoute } from "@/components/auth/ProtectedRoute";
import { AppLayout } from "@/components/layout/AppLayout";
import { PageSkeletonLoader } from "@/components/ui/PageSkeletonLoader";

// Synchronous Public Auth Pages for instant first-load
import { LoginPage } from "@/pages/auth/LoginPage";
import { RegisterPage } from "@/pages/auth/RegisterPage";
import { ForgotPasswordPage } from "@/pages/auth/ForgotPasswordPage";
import { ResetPasswordPage } from "@/pages/auth/ResetPasswordPage";

// Lazy-loaded Feature Modules (Code Split Chunks)
const AdminDashboard = lazy(() =>
  import("@/pages/dashboard/AdminDashboard").then((m) => ({ default: m.AdminDashboard }))
);
const StaffDashboard = lazy(() =>
  import("@/pages/dashboard/StaffDashboard").then((m) => ({ default: m.StaffDashboard }))
);
const CustomerPortal = lazy(() =>
  import("@/pages/dashboard/CustomerPortal").then((m) => ({ default: m.CustomerPortal }))
);
const UserManagementPage = lazy(() =>
  import("@/pages/dashboard/UserManagementPage").then((m) => ({ default: m.UserManagementPage }))
);
const AuditLogsPage = lazy(() =>
  import("@/pages/audit/AuditLogsPage").then((m) => ({ default: m.AuditLogsPage }))
);
const ProfilePage = lazy(() =>
  import("@/pages/profile/ProfilePage").then((m) => ({ default: m.ProfilePage }))
);

const ProductsListPage = lazy(() =>
  import("@/pages/products/ProductsListPage").then((m) => ({ default: m.ProductsListPage }))
);
const ProductDetailsPage = lazy(() =>
  import("@/pages/products/ProductDetailsPage").then((m) => ({ default: m.ProductDetailsPage }))
);
const PlansListPage = lazy(() =>
  import("@/pages/plans/PlansListPage").then((m) => ({ default: m.PlansListPage }))
);
const PlanDetailsPage = lazy(() =>
  import("@/pages/plans/PlanDetailsPage").then((m) => ({ default: m.PlanDetailsPage }))
);
const CataloguePage = lazy(() =>
  import("@/pages/catalogue/CataloguePage").then((m) => ({ default: m.CataloguePage }))
);

const CustomersListPage = lazy(() =>
  import("@/pages/customers/CustomersListPage").then((m) => ({ default: m.CustomersListPage }))
);
const CustomerDetailsPage = lazy(() =>
  import("@/pages/customers/CustomerDetailsPage").then((m) => ({ default: m.CustomerDetailsPage }))
);
const SubscriptionsListPage = lazy(() =>
  import("@/pages/subscriptions/SubscriptionsListPage").then((m) => ({ default: m.SubscriptionsListPage }))
);
const SubscriptionDetailsPage = lazy(() =>
  import("@/pages/subscriptions/SubscriptionDetailsPage").then((m) => ({ default: m.SubscriptionDetailsPage }))
);
const InvoicesListPage = lazy(() =>
  import("@/pages/invoices/InvoicesListPage").then((m) => ({ default: m.InvoicesListPage }))
);
const InvoiceDetailsPage = lazy(() =>
  import("@/pages/invoices/InvoiceDetailsPage").then((m) => ({ default: m.InvoiceDetailsPage }))
);

const QuotationTemplatesPage = lazy(() =>
  import("@/pages/quotations/QuotationTemplatesPage").then((m) => ({ default: m.QuotationTemplatesPage }))
);
const DiscountsPage = lazy(() =>
  import("@/pages/discounts/DiscountsPage").then((m) => ({ default: m.DiscountsPage }))
);
const TaxSettingsPage = lazy(() =>
  import("@/pages/taxes/TaxSettingsPage").then((m) => ({ default: m.TaxSettingsPage }))
);

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

              {/* Protected Application Layout with Suspense Boundary */}
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
                      <Suspense fallback={<PageSkeletonLoader />}>
                        <AdminDashboard />
                      </Suspense>
                    </ProtectedRoute>
                  }
                />
                <Route
                  path="/admin/users"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN"]}>
                      <Suspense fallback={<PageSkeletonLoader />}>
                        <UserManagementPage />
                      </Suspense>
                    </ProtectedRoute>
                  }
                />

                {/* Staff Shell Routes */}
                <Route
                  path="/staff"
                  element={
                    <ProtectedRoute allowedRoles={["STAFF", "ADMIN"]}>
                      <Suspense fallback={<PageSkeletonLoader />}>
                        <StaffDashboard />
                      </Suspense>
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
                      <Suspense fallback={<PageSkeletonLoader />}>
                        <CustomerPortal />
                      </Suspense>
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
                      <Suspense fallback={<PageSkeletonLoader />}>
                        <CataloguePage />
                      </Suspense>
                    </ProtectedRoute>
                  }
                />

                {/* Product Catalog (Admin & Staff) */}
                <Route
                  path="/products"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN", "STAFF"]}>
                      <Suspense fallback={<PageSkeletonLoader />}>
                        <ProductsListPage />
                      </Suspense>
                    </ProtectedRoute>
                  }
                />
                <Route
                  path="/products/:id"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN", "STAFF"]}>
                      <Suspense fallback={<PageSkeletonLoader />}>
                        <ProductDetailsPage />
                      </Suspense>
                    </ProtectedRoute>
                  }
                />

                {/* Subscription Plans (Admin & Staff) */}
                <Route
                  path="/plans"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN", "STAFF"]}>
                      <Suspense fallback={<PageSkeletonLoader />}>
                        <PlansListPage />
                      </Suspense>
                    </ProtectedRoute>
                  }
                />
                <Route
                  path="/plans/:id"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN", "STAFF"]}>
                      <Suspense fallback={<PageSkeletonLoader />}>
                        <PlanDetailsPage />
                      </Suspense>
                    </ProtectedRoute>
                  }
                />

                {/* Phase 3: Customer Management (Admin & Staff) */}
                <Route
                  path="/customers"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN", "STAFF"]}>
                      <Suspense fallback={<PageSkeletonLoader />}>
                        <CustomersListPage />
                      </Suspense>
                    </ProtectedRoute>
                  }
                />
                <Route
                  path="/customers/:id"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN", "STAFF", "CUSTOMER"]}>
                      <Suspense fallback={<PageSkeletonLoader />}>
                        <CustomerDetailsPage />
                      </Suspense>
                    </ProtectedRoute>
                  }
                />

                {/* Phase 3: Subscriptions (All Roles with server-side isolation) */}
                <Route
                  path="/subscriptions"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN", "STAFF", "CUSTOMER"]}>
                      <Suspense fallback={<PageSkeletonLoader />}>
                        <SubscriptionsListPage />
                      </Suspense>
                    </ProtectedRoute>
                  }
                />
                <Route
                  path="/subscriptions/:id"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN", "STAFF", "CUSTOMER"]}>
                      <Suspense fallback={<PageSkeletonLoader />}>
                        <SubscriptionDetailsPage />
                      </Suspense>
                    </ProtectedRoute>
                  }
                />

                {/* Phase 3: Invoices & Payments (All Roles with server-side isolation) */}
                <Route
                  path="/invoices"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN", "STAFF", "CUSTOMER"]}>
                      <Suspense fallback={<PageSkeletonLoader />}>
                        <InvoicesListPage />
                      </Suspense>
                    </ProtectedRoute>
                  }
                />
                <Route
                  path="/invoices/:id"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN", "STAFF", "CUSTOMER"]}>
                      <Suspense fallback={<PageSkeletonLoader />}>
                        <InvoiceDetailsPage />
                      </Suspense>
                    </ProtectedRoute>
                  }
                />

                {/* Commercial Elevation: Quotations, Discounts, Taxes */}
                <Route
                  path="/quotations"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN", "STAFF", "CUSTOMER"]}>
                      <Suspense fallback={<PageSkeletonLoader />}>
                        <QuotationTemplatesPage />
                      </Suspense>
                    </ProtectedRoute>
                  }
                />
                <Route
                  path="/discounts"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN", "STAFF"]}>
                      <Suspense fallback={<PageSkeletonLoader />}>
                        <DiscountsPage />
                      </Suspense>
                    </ProtectedRoute>
                  }
                />
                <Route
                  path="/taxes"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN", "STAFF"]}>
                      <Suspense fallback={<PageSkeletonLoader />}>
                        <TaxSettingsPage />
                      </Suspense>
                    </ProtectedRoute>
                  }
                />

                {/* Audit Logs (Admin & Staff) */}
                <Route
                  path="/audit-logs"
                  element={
                    <ProtectedRoute allowedRoles={["ADMIN", "STAFF"]}>
                      <Suspense fallback={<PageSkeletonLoader />}>
                        <AuditLogsPage />
                      </Suspense>
                    </ProtectedRoute>
                  }
                />

                {/* User Profile (All Authenticated Users) */}
                <Route
                  path="/profile"
                  element={
                    <Suspense fallback={<PageSkeletonLoader />}>
                      <ProfilePage />
                    </Suspense>
                  }
                />
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
