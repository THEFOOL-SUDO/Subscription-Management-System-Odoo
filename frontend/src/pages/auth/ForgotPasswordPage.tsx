import React, { useState } from "react";
import { Link } from "react-router-dom";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { authApi } from "@/api/auth";
import { useToast } from "@/components/ui/toast";
import { forgotPasswordSchema } from "@/lib/validations";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Sparkles, ArrowLeft, MailCheck, ExternalLink } from "lucide-react";

type ForgotPasswordValues = z.infer<typeof forgotPasswordSchema>;

export const ForgotPasswordPage: React.FC = () => {
  const { error: toastError } = useToast();
  const [isLoading, setIsLoading] = useState(false);
  const [submittedEmail, setSubmittedEmail] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<ForgotPasswordValues>({
    resolver: zodResolver(forgotPasswordSchema),
    defaultValues: {
      email: "",
    },
  });

  const onSubmit = async (data: ForgotPasswordValues) => {
    setIsLoading(true);
    try {
      await authApi.forgotPassword(data.email);
      setSubmittedEmail(data.email);
    } catch (err: any) {
      toastError(err.response?.data?.detail || "Failed to process request. Please try again.");
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
          <p className="text-xs text-slate-500 font-medium mt-1">Account Recovery Portal</p>
        </div>

        <Card className="border border-slate-200/90 shadow-sm bg-white">
          <CardHeader className="space-y-1 pb-4">
            <CardTitle className="text-xl">Password Recovery</CardTitle>
            <CardDescription>
              Enter your registered email address to receive secure reset instructions.
            </CardDescription>
          </CardHeader>
          <CardContent>
            {submittedEmail ? (
              <div className="space-y-4">
                <div className="rounded-xl bg-blue-50/70 border border-blue-200/80 p-5 text-center">
                  <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-blue-100 text-blue-600 mb-3">
                    <MailCheck className="w-6 h-6" />
                  </div>
                  <h3 className="text-sm font-semibold text-slate-900">Check Your Inbox</h3>
                  <p className="mt-1 text-xs text-slate-600 leading-relaxed">
                    If an account exists for <span className="font-semibold text-slate-900">{submittedEmail}</span>, we have sent a single-use password reset link.
                  </p>
                </div>

                {/* Local Dev Mailpit Prompt */}
                <div className="rounded-lg border border-slate-200 bg-slate-50 p-3 text-center">
                  <p className="text-xs text-slate-600 font-medium mb-2">
                    Running in local development mode?
                  </p>
                  <a
                    href="http://localhost:8028"
                    target="_blank"
                    rel="noreferrer"
                    className="inline-flex items-center gap-1.5 text-xs font-semibold text-blue-600 hover:text-blue-800"
                  >
                    Open Mailpit Web Mailbox (Port 8028)
                    <ExternalLink className="w-3.5 h-3.5" />
                  </a>
                </div>

                <div className="text-center pt-2">
                  <Link
                    to="/login"
                    className="inline-flex items-center gap-1.5 text-xs font-semibold text-slate-700 hover:text-slate-900"
                  >
                    <ArrowLeft className="w-3.5 h-3.5" />
                    Back to Sign In
                  </Link>
                </div>
              </div>
            ) : (
              <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
                <div>
                  <Label htmlFor="email" required>Registered Email Address</Label>
                  <Input
                    id="email"
                    type="email"
                    autoComplete="email"
                    placeholder="name@company.com"
                    error={errors.email?.message}
                    {...register("email")}
                  />
                </div>

                <Button
                  type="submit"
                  className="w-full mt-2"
                  size="md"
                  isLoading={isLoading}
                >
                  Send Recovery Link
                </Button>

                <div className="text-center pt-2">
                  <Link
                    to="/login"
                    className="inline-flex items-center gap-1.5 text-xs font-semibold text-slate-600 hover:text-slate-900"
                  >
                    <ArrowLeft className="w-3.5 h-3.5" />
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
