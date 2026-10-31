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
                  element={
                    <ProtectedRoute allowedRoles={["STAFF", "ADMIN"]}>
                      <StaffDashboard />
                    </ProtectedRoute>
                  }
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
                  element={
                    <ProtectedRoute allowedRoles={["CUSTOMER", "ADMIN", "STAFF"]}>
                      <CustomerPortal />
                    </ProtectedRoute>
                  }
                />
                <Route
                  path="/portal/invoices"
                  element={
                    <ProtectedRoute allowedRoles={["CUSTOMER", "ADMIN", "STAFF"]}>
                      <CustomerPortal />
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
