import { describe, it, expect } from "vitest";
import {
  passwordRegexRules,
  passwordSchema,
  loginSchema,
  registerSchema,
} from "@/lib/validations";

describe("Validation Rules", () => {
  it("validates password length (> 8 chars)", () => {
    expect(passwordRegexRules.minLength("12345678")).toBe(false);
    expect(passwordRegexRules.minLength("123456789")).toBe(true);
  });

  it("validates uppercase requirement", () => {
    expect(passwordRegexRules.hasUpper("lowercase123#")).toBe(false);
    expect(passwordRegexRules.hasUpper("Uppercase123#")).toBe(true);
  });

  it("validates lowercase requirement", () => {
    expect(passwordRegexRules.hasLower("UPPERCASE123#")).toBe(false);
    expect(passwordRegexRules.hasLower("Uppercase123#")).toBe(true);
  });

  it("validates number requirement", () => {
    expect(passwordRegexRules.hasNumber("NoNumbers#Pass")).toBe(false);
    expect(passwordRegexRules.hasNumber("HasNumber1#Pass")).toBe(true);
  });

  it("validates special character requirement", () => {
    expect(passwordRegexRules.hasSpecial("NoSpecial1234")).toBe(false);
    expect(passwordRegexRules.hasSpecial("HasSpecial#1234")).toBe(true);
  });

  it("rejects weak password with Zod schema", () => {
    const result = passwordSchema.safeParse("weak");
    expect(result.success).toBe(false);
  });

  it("accepts compliant password with Zod schema", () => {
    const result = passwordSchema.safeParse("Brightloop#2026");
    expect(result.success).toBe(true);
  });

  it("validates login schema", () => {
    expect(loginSchema.safeParse({ email: "invalid", password: "" }).success).toBe(false);
    expect(loginSchema.safeParse({ email: "valid@brightloop.com", password: "pwd" }).success).toBe(true);
  });

  it("validates register schema password matching", () => {
    const mismatched = registerSchema.safeParse({
      full_name: "Jane Doe",
      email: "jane@brightloop.com",
      password: "Brightloop#2026",
      confirmPassword: "Different#2026",
    });
    expect(mismatched.success).toBe(false);

    const matched = registerSchema.safeParse({
      full_name: "Jane Doe",
      email: "jane@brightloop.com",
      password: "Brightloop#2026",
      confirmPassword: "Brightloop#2026",
    });
    expect(matched.success).toBe(true);
  });
});
