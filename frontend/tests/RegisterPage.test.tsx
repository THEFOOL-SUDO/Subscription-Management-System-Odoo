import React from "react";
import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { BrowserRouter } from "react-router-dom";
import { RegisterPage } from "@/pages/auth/RegisterPage";
import { ToastProvider } from "@/components/ui/toast";

vi.mock("@/hooks/useAuth", () => ({
  useAuth: () => ({
    user: null,
    isAuthenticated: false,
    isLoading: false,
    register: vi.fn(),
  }),
}));

describe("RegisterPage", () => {
  it("renders registration inputs and security badge", () => {
    render(
      <ToastProvider>
        <BrowserRouter>
          <RegisterPage />
        </BrowserRouter>
      </ToastProvider>
    );

    expect(screen.getByRole("heading", { name: "Brightloop" })).toBeInTheDocument();
    expect(screen.getByRole("heading", { name: "Create your customer account" })).toBeInTheDocument();
    expect(screen.getByLabelText(/Full Name/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/Corporate Email/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/^Password/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/Confirm Password/i)).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /Complete Registration/i })).toBeInTheDocument();
    expect(screen.getByText(/strictly provisioned with/i)).toBeInTheDocument();
  });
});
