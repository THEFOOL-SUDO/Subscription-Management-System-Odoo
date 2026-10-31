import React from "react";
import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { BrowserRouter } from "react-router-dom";
import { LoginPage } from "@/pages/auth/LoginPage";
import { ToastProvider } from "@/components/ui/toast";

// Mock useAuth
vi.mock("@/hooks/useAuth", () => ({
  useAuth: () => ({
    user: null,
    isAuthenticated: false,
    isLoading: false,
    login: vi.fn(),
    logout: vi.fn(),
  }),
}));

describe("LoginPage", () => {
  it("renders login form elements and corporate branding", () => {
    render(
      <ToastProvider>
        <BrowserRouter>
          <LoginPage />
        </BrowserRouter>
      </ToastProvider>
    );

    expect(screen.getByRole("heading", { name: "Brightloop" })).toBeInTheDocument();
    expect(screen.getByRole("heading", { name: "Sign in to your account" })).toBeInTheDocument();
    expect(screen.getByLabelText(/Email Address/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/Password/i)).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /Sign In/i })).toBeInTheDocument();
    expect(screen.getByText(/admin@brightloop.com/i)).toBeInTheDocument();
  });
});
