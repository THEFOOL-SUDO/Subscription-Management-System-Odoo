import React, { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { useAuth } from "@/hooks/useAuth";
import { authApi } from "@/api/auth";
import { useToast } from "@/components/ui/toast";
import { changePasswordSchema, updateProfileSchema } from "@/lib/validations";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { RoleBadge, Badge } from "@/components/ui/badge";
import { PasswordStrengthIndicator } from "@/components/auth/PasswordStrengthIndicator";
import { formatDate } from "@/lib/utils";
import {
  User as UserIcon,
  KeyRound,
} from "lucide-react";

type ProfileFormValues = z.infer<typeof updateProfileSchema>;
type ChangePasswordValues = z.infer<typeof changePasswordSchema>;

export const ProfilePage: React.FC = () => {
  const { user, refreshUser, logout } = useAuth();
  const { success: toastSuccess, error: toastError } = useToast();

  const [isUpdatingProfile, setIsUpdatingProfile] = useState(false);
  const [isChangingPassword, setIsChangingPassword] = useState(false);

  // Profile Form
  const {
    register: registerProfile,
    handleSubmit: handleSubmitProfile,
    formState: { errors: profileErrors },
  } = useForm<ProfileFormValues>({
    resolver: zodResolver(updateProfileSchema),
    defaultValues: {
      full_name: user?.full_name || "",
    },
  });

  // Password Form
  const {
    register: registerPwd,
    handleSubmit: handleSubmitPwd,
    watch: watchPwd,
    reset: resetPwd,
    formState: { errors: pwdErrors },
  } = useForm<ChangePasswordValues>({
    resolver: zodResolver(changePasswordSchema),
    defaultValues: {
      current_password: "",
      new_password: "",
      confirmPassword: "",
    },
  });

  const watchedNewPassword = watchPwd("new_password");

  if (!user) return null;

  const onUpdateProfile = async (data: ProfileFormValues) => {
    setIsUpdatingProfile(true);
    try {
      await authApi.updateMe(data);
      await refreshUser();
      toastSuccess("Your profile information has been updated.", "Profile Updated");
    } catch (err: any) {
      toastError(err.response?.data?.detail || "Failed to update profile.");
    } finally {
      setIsUpdatingProfile(false);
    }
  };

  const onChangePassword = async (data: ChangePasswordValues) => {
    setIsChangingPassword(true);
    try {
      await authApi.changePassword({
        current_password: data.current_password,
        new_password: data.new_password,
      });
      toastSuccess(
        "Password changed successfully! You will now be redirected to sign in with your new password.",
        "Password Changed"
      );
      resetPwd();
      setTimeout(async () => {
        await logout();
      }, 2000);
    } catch (err: any) {
      toastError(err.response?.data?.detail || "Failed to change password.");
    } finally {
      setIsChangingPassword(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="border-b border-slate-200/80 pb-5">
        <h1 className="text-2xl font-bold tracking-tight text-slate-900">Account Settings</h1>
        <p className="text-xs text-slate-500 mt-1">
          Manage your identity credentials, profile details, and account security.
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left Column: Account Details Summary */}
        <Card className="lg:col-span-1 h-fit">
          <CardHeader className="pb-4">
            <div className="flex items-center gap-3">
              <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-slate-900 text-base font-bold text-white shadow-xs">
                {user.full_name.charAt(0).toUpperCase()}
              </div>
              <div>
                <CardTitle className="text-base">{user.full_name}</CardTitle>
                <div className="mt-1">
                  <RoleBadge role={user.role} />
                </div>
              </div>
            </div>
          </CardHeader>
          <CardContent className="space-y-3 pt-2 text-xs border-t border-slate-100">
            <div>
              <span className="text-slate-400 block font-medium">Email Address</span>
              <span className="text-slate-800 font-mono text-[11px]">{user.email}</span>
            </div>
            <div>
              <span className="text-slate-400 block font-medium">Account Identifier</span>
              <span className="text-slate-600 font-mono text-[11px]">{user.id}</span>
            </div>
            <div>
              <span className="text-slate-400 block font-medium">Registered Date</span>
              <span className="text-slate-800">{formatDate(user.created_at)}</span>
            </div>
            <div>
              <span className="text-slate-400 block font-medium">Account Status</span>
              <Badge variant={user.is_active ? "success" : "danger"} className="mt-1">
                {user.is_active ? "Active" : "Deactivated"}
              </Badge>
            </div>
          </CardContent>
        </Card>

        {/* Right Column: Update Forms */}
        <div className="lg:col-span-2 space-y-6">
          {/* Profile Details Form */}
          <Card>
            <CardHeader className="pb-3">
              <div className="flex items-center gap-2">
                <UserIcon className="w-4 h-4 text-slate-500" />
                <CardTitle className="text-base font-semibold">Personal Information</CardTitle>
              </div>
              <CardDescription className="text-xs">
                Update your public profile display name.
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleSubmitProfile(onUpdateProfile)} className="space-y-4">
                <div>
                  <Label htmlFor="full_name" required>Full Name</Label>
                  <Input
                    id="full_name"
                    placeholder="Jane Doe"
                    error={profileErrors.full_name?.message}
                    {...registerProfile("full_name")}
                  />
                </div>

                <div>
                  <Label htmlFor="email_disabled">Account Email (Immutable)</Label>
                  <Input
                    id="email_disabled"
                    value={user.email}
                    disabled
                    className="bg-slate-50 text-slate-500 cursor-not-allowed"
                    helperText="Corporate email address is bound to your account identity."
                  />
                </div>

                <Button type="submit" size="sm" isLoading={isUpdatingProfile}>
                  Save Changes
                </Button>
              </form>
            </CardContent>
          </Card>

          {/* Change Password Form */}
          <Card>
            <CardHeader className="pb-3">
              <div className="flex items-center gap-2">
                <KeyRound className="w-4 h-4 text-slate-500" />
                <CardTitle className="text-base font-semibold">Change Password</CardTitle>
              </div>
              <CardDescription className="text-xs">
                Update your login password. All existing refresh tokens will be automatically invalidated.
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleSubmitPwd(onChangePassword)} className="space-y-4">
                <div>
                  <Label htmlFor="current_password" required>Current Password</Label>
                  <Input
                    id="current_password"
                    type="password"
                    autoComplete="current-password"
                    placeholder="••••••••••••"
                    error={pwdErrors.current_password?.message}
                    {...registerPwd("current_password")}
                  />
                </div>

                <div>
                  <Label htmlFor="new_password" required>New Password</Label>
                  <Input
                    id="new_password"
                    type="password"
                    autoComplete="new-password"
                    placeholder="••••••••••••"
                    error={pwdErrors.new_password?.message}
                    {...registerPwd("new_password")}
                  />
                  {watchedNewPassword && <PasswordStrengthIndicator password={watchedNewPassword} />}
                </div>

                <div>
                  <Label htmlFor="confirm_new_password" required>Confirm New Password</Label>
                  <Input
                    id="confirm_new_password"
                    type="password"
                    autoComplete="new-password"
                    placeholder="••••••••••••"
                    error={pwdErrors.confirmPassword?.message}
                    {...registerPwd("confirmPassword")}
                  />
                </div>

                <Button type="submit" size="sm" isLoading={isChangingPassword}>
                  Update Password & Re-authenticate
                </Button>
              </form>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
};
