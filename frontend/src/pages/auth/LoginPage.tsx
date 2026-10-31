import React, { useState } from "react";
import { Link, useNavigate, useLocation } from "react-router-dom";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { useAuth } from "@/hooks/useAuth";
import { useToast } from "@/components/ui/toast";
import { loginSchema } from "@/lib/validations";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Sparkles, Shield, ArrowRight } from "lucide-react";

type LoginFormValues = z.infer<typeof loginSchema>;

export const LoginPage: React.FC = () => {
  const { login } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const { error: toastError } = useToast();
  const [isLoading, setIsLoading] = useState(false);
  const [serverError, setServerError] = useState<string | null>(null);

  const from = (location.state as any)?.from?.pathname || null;

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginFormValues>({
    resolver: zodResolver(loginSchema),
    defaultValues: {
      email: "",
      password: "",
    },
  });

  const onSubmit = async (data: LoginFormValues) => {
    setIsLoading(true);
    setServerError(null);
    try {
      await login(data);
      // Auth state updated, navigate to target or role home
      if (from) {
        navigate(from, { replace: true });
      } else {
        // AuthProvider sets user, we can navigate to root which handles role-based routing
        navigate("/", { replace: true });
      }
    } catch (err: any) {
      const msg = err.response?.data?.detail || "Authentication failed. Please check your credentials.";
      setServerError(msg);
      toastError(msg, "Login Failed");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-slate-50 p-4">
      <div className="w-full max-w-md">
        {/* Brand Header */}
        <div className="flex flex-col items-center mb-8 text-center">
          <div className="h-12 w-12 rounded-2xl bg-slate-900 flex items-center justify-center text-white shadow-md mb-3">
            <Sparkles className="w-6 h-6 text-blue-400" />
          </div>
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Brightloop</h1>
          <p className="text-xs text-slate-500 font-medium mt-1">Enterprise Subscription Management</p>
        </div>

        <Card className="border border-slate-200/90 shadow-sm bg-white">
          <CardHeader className="space-y-1 pb-4">
            <CardTitle className="text-xl">Sign in to your account</CardTitle>
            <CardDescription>
              Enter your corporate credentials to access the subscription console.
            </CardDescription>
          </CardHeader>
          <CardContent>
            {serverError && (
              <div className="mb-4 rounded-lg bg-red-50 border border-red-200 p-3 text-xs text-red-800 flex items-center gap-2">
                <Shield className="w-4 h-4 text-red-600 shrink-0" />
                <span>{serverError}</span>
              </div>
            )}

            <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
              <div>
                <Label htmlFor="email" required>Email Address</Label>
                <Input
                  id="email"
                  type="email"
                  autoComplete="email"
                  placeholder="name@company.com"
                  error={errors.email?.message}
                  {...register("email")}
                />
              </div>

              <div>
                <div className="flex items-center justify-between mb-1">
                  <Label htmlFor="password" required>Password</Label>
                  <Link
                    to="/forgot-password"
                    className="text-xs text-blue-600 hover:text-blue-800 font-medium"
                  >
                    Forgot password?
                  </Link>
                </div>
                <Input
                  id="password"
                  type="password"
                  autoComplete="current-password"
                  placeholder="••••••••••••"
                  error={errors.password?.message}
                  {...register("password")}
                />
              </div>

              <Button
                type="submit"
                className="w-full mt-2"
                size="md"
                isLoading={isLoading}
              >
                Sign In
                <ArrowRight className="w-4 h-4 ml-1" />
              </Button>
            </form>

            <div className="mt-6 text-center text-xs text-slate-500">
              Need a customer account?{" "}
              <Link to="/register" className="font-semibold text-blue-600 hover:text-blue-800">
                Register here
              </Link>
            </div>
          </CardContent>
        </Card>

        {/* Development Helper Notice */}
        <div className="mt-6 rounded-lg border border-slate-200 bg-white p-3 text-xs text-slate-500 text-center">
          <p className="font-semibold text-slate-700">Initial System Admin Account:</p>
          <p className="font-mono text-[11px] text-slate-600 mt-0.5">
            admin@brightloop.com / Brightloop#Admin2026
          </p>
        </div>
      </div>
    </div>
  );
};
