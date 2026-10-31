import React, { useState } from "react";
import { Link, useSearchParams, useNavigate } from "react-router-dom";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { authApi } from "@/api/auth";
import { useToast } from "@/components/ui/toast";
import { resetPasswordSchema } from "@/lib/validations";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { PasswordStrengthIndicator } from "@/components/auth/PasswordStrengthIndicator";
import { Sparkles, CheckCircle2, AlertTriangle, ArrowRight } from "lucide-react";

type ResetPasswordValues = z.infer<typeof resetPasswordSchema>;

export const ResetPasswordPage: React.FC = () => {
  const [searchParams] = useSearchParams();
  const token = searchParams.get("token");
  const navigate = useNavigate();
  const { success: toastSuccess, error: toastError } = useToast();
  const [isLoading, setIsLoading] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);
  const [serverError, setServerError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    watch,
    formState: { errors },
  } = useForm<ResetPasswordValues>({
    resolver: zodResolver(resetPasswordSchema),
    defaultValues: {
      new_password: "",
      confirmPassword: "",
    },
  });

  const watchedPassword = watch("new_password");

  const onSubmit = async (data: ResetPasswordValues) => {
    if (!token) {
      toastError("Reset token is missing or malformed.", "Invalid Request");
      return;
    }

    setIsLoading(true);
    setServerError(null);
    try {
      await authApi.resetPassword({
        token,
        new_password: data.new_password,
      });
      setIsSuccess(true);
      toastSuccess("Your password has been securely reset. You can now log in.", "Password Updated");
    } catch (err: any) {
      const msg = err.response?.data?.detail || "Failed to reset password. The link may have expired.";
      setServerError(msg);
      toastError(msg, "Reset Failed");
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
          <p className="text-xs text-slate-500 font-medium mt-1">Set New Password</p>
        </div>

        <Card className="border border-slate-200/90 shadow-sm bg-white">
          <CardHeader className="space-y-1 pb-4">
            <CardTitle className="text-xl">Create New Password</CardTitle>
            <CardDescription>
              Enter a strong, secure password complying with enterprise security standards.
            </CardDescription>
          </CardHeader>
          <CardContent>
            {!token ? (
              <div className="space-y-4">
                <div className="rounded-xl bg-amber-50 border border-amber-200 p-4 text-center">
                  <AlertTriangle className="w-8 h-8 text-amber-600 mx-auto mb-2" />
                  <h3 className="text-sm font-semibold text-slate-900">Missing Reset Token</h3>
                  <p className="text-xs text-slate-600 mt-1">
                    This password reset link is invalid or incomplete. Please request a new recovery link.
                  </p>
                </div>
                <Button
                  onClick={() => navigate("/forgot-password")}
                  variant="outline"
                  className="w-full"
                >
                  Request New Reset Link
                </Button>
              </div>
            ) : isSuccess ? (
              <div className="space-y-4 text-center">
                <div className="rounded-xl bg-emerald-50 border border-emerald-200 p-5">
                  <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-emerald-100 text-emerald-600 mb-3">
                    <CheckCircle2 className="w-6 h-6" />
                  </div>
                  <h3 className="text-sm font-semibold text-slate-900">Password Reset Complete</h3>
                  <p className="mt-1 text-xs text-slate-600">
                    Your password has been changed and all previous active sessions have been invalidated.
                  </p>
                </div>

                <Button
                  onClick={() => navigate("/login")}
                  className="w-full"
                  size="md"
                >
                  Proceed to Sign In
                  <ArrowRight className="w-4 h-4 ml-1" />
                </Button>
              </div>
            ) : (
              <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
                {serverError && (
                  <div className="rounded-lg bg-red-50 border border-red-200 p-3 text-xs text-red-800">
                    {serverError}
                  </div>
                )}

                <div>
                  <Label htmlFor="new_password" required>New Password</Label>
                  <Input
                    id="new_password"
                    type="password"
                    autoComplete="new-password"
                    placeholder="••••••••••••"
                    error={errors.new_password?.message}
                    {...register("new_password")}
                  />
                  {watchedPassword && <PasswordStrengthIndicator password={watchedPassword} />}
                </div>

                <div>
                  <Label htmlFor="confirmPassword" required>Confirm New Password</Label>
                  <Input
                    id="confirmPassword"
                    type="password"
                    autoComplete="new-password"
                    placeholder="••••••••••••"
                    error={errors.confirmPassword?.message}
                    {...register("confirmPassword")}
                  />
                </div>

                <Button
                  type="submit"
                  className="w-full mt-2"
                  size="md"
                  isLoading={isLoading}
                >
                  Update Password
                </Button>

                <div className="text-center pt-2">
                  <Link
                    to="/login"
                    className="text-xs font-semibold text-slate-600 hover:text-slate-900"
                  >
                    Return to Sign In
                  </Link>
                </div>
              </form>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
};
