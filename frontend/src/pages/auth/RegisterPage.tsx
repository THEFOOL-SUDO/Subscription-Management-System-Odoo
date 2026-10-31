import React, { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { useAuth } from "@/hooks/useAuth";
import { useToast } from "@/components/ui/toast";
import { registerSchema } from "@/lib/validations";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { PasswordStrengthIndicator } from "@/components/auth/PasswordStrengthIndicator";
import { Sparkles, ArrowRight, ShieldCheck } from "lucide-react";

type RegisterFormValues = z.infer<typeof registerSchema>;

export const RegisterPage: React.FC = () => {
  const { register: registerUser } = useAuth();
  const navigate = useNavigate();
  const { success: toastSuccess, error: toastError } = useToast();
  const [isLoading, setIsLoading] = useState(false);
  const [serverError, setServerError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    watch,
    formState: { errors },
  } = useForm<RegisterFormValues>({
    resolver: zodResolver(registerSchema),
    defaultValues: {
      full_name: "",
      email: "",
      password: "",
      confirmPassword: "",
    },
  });

  const watchedPassword = watch("password");

  const onSubmit = async (data: RegisterFormValues) => {
    setIsLoading(true);
    setServerError(null);
    try {
      await registerUser({
        email: data.email,
        full_name: data.full_name,
        password: data.password,
      });
      toastSuccess("Account successfully created! Welcome to Brightloop.", "Registration Successful");
      navigate("/portal", { replace: true });
    } catch (err: any) {
      const msg = err.response?.data?.detail || "Registration failed. Please review your information.";
      setServerError(msg);
      toastError(msg, "Registration Failed");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-slate-50 p-4 py-8">
      <div className="w-full max-w-md">
        {/* Brand Header */}
        <div className="flex flex-col items-center mb-6 text-center">
          <div className="h-12 w-12 rounded-2xl bg-slate-900 flex items-center justify-center text-white shadow-md mb-3">
            <Sparkles className="w-6 h-6 text-blue-400" />
          </div>
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Brightloop</h1>
          <p className="text-xs text-slate-500 font-medium mt-1">Customer Self-Service Onboarding</p>
        </div>

        <Card className="border border-slate-200/90 shadow-sm bg-white">
          <CardHeader className="space-y-1 pb-4">
            <CardTitle className="text-xl">Create your customer account</CardTitle>
            <CardDescription>
              Sign up to manage your subscriptions, view quotations, and access invoices.
            </CardDescription>
          </CardHeader>
          <CardContent>
            {serverError && (
              <div className="mb-4 rounded-lg bg-red-50 border border-red-200 p-3 text-xs text-red-800">
                {serverError}
              </div>
            )}

            <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
              <div>
                <Label htmlFor="full_name" required>Full Name</Label>
                <Input
                  id="full_name"
                  type="text"
                  autoComplete="name"
                  placeholder="Jane Doe"
                  error={errors.full_name?.message}
                  {...register("full_name")}
                />
              </div>

              <div>
                <Label htmlFor="email" required>Corporate Email</Label>
                <Input
                  id="email"
                  type="email"
                  autoComplete="email"
                  placeholder="jane@company.com"
                  error={errors.email?.message}
                  {...register("email")}
                />
              </div>

              <div>
                <Label htmlFor="password" required>Password</Label>
                <Input
                  id="password"
                  type="password"
                  autoComplete="new-password"
                  placeholder="••••••••••••"
                  error={errors.password?.message}
                  {...register("password")}
                />
                {watchedPassword && <PasswordStrengthIndicator password={watchedPassword} />}
              </div>

              <div>
                <Label htmlFor="confirmPassword" required>Confirm Password</Label>
                <Input
                  id="confirmPassword"
                  type="password"
                  autoComplete="new-password"
                  placeholder="••••••••••••"
                  error={errors.confirmPassword?.message}
                  {...register("confirmPassword")}
                />
              </div>

              <div className="rounded-lg bg-slate-50 p-3 border border-slate-100 flex items-start gap-2.5">
                <ShieldCheck className="w-4 h-4 text-emerald-600 mt-0.5 shrink-0" />
                <p className="text-[11px] text-slate-600 leading-normal">
                  Accounts created here are strictly provisioned with <strong>CUSTOMER</strong> privileges. Administrative roles can only be granted by existing administrators.
                </p>
              </div>

              <Button
                type="submit"
                className="w-full mt-2"
                size="md"
                isLoading={isLoading}
              >
                Complete Registration
                <ArrowRight className="w-4 h-4 ml-1" />
              </Button>
            </form>

            <div className="mt-6 text-center text-xs text-slate-500">
              Already have an account?{" "}
              <Link to="/login" className="font-semibold text-blue-600 hover:text-blue-800">
                Sign in
              </Link>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
};
