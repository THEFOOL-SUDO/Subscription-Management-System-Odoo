import React from "react";
import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { PasswordStrengthIndicator } from "@/components/auth/PasswordStrengthIndicator";

describe("PasswordStrengthIndicator", () => {
  it("renders checklist criteria", () => {
    render(<PasswordStrengthIndicator password="" />);
    expect(screen.getByText("More than 8 characters")).toBeInTheDocument();
    expect(screen.getByText("At least one uppercase letter (A-Z)")).toBeInTheDocument();
    expect(screen.getByText("At least one lowercase letter (a-z)")).toBeInTheDocument();
    expect(screen.getByText("At least one number (0-9)")).toBeInTheDocument();
    expect(screen.getByText("At least one special character (!@#$...)")).toBeInTheDocument();
  });

  it("indicates met criteria when strong password provided", () => {
    const { container } = render(<PasswordStrengthIndicator password="StrongPassword#2026" />);
    // Check for emerald classes indicating met
    const metElements = container.querySelectorAll(".text-emerald-700");
    expect(metElements.length).toBe(5);
  });
});
