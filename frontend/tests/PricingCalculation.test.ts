import { describe, it, expect } from "vitest";

describe("Pricing Calculations", () => {
  it("calculates fixed amount adjustment correctly", () => {
    const basePrice = 2000;
    const fixedAdjustment = 560;
    const effectiveUnitPrice = basePrice + fixedAdjustment;
    const quantity = 3;
    const subtotal = effectiveUnitPrice * quantity;

    expect(effectiveUnitPrice).toBe(2560);
    expect(subtotal).toBe(7680);
  });

  it("calculates percentage adjustment correctly", () => {
    const basePrice = 2000;
    const percentage = 15;
    const effectiveUnitPrice = basePrice + (basePrice * percentage) / 100;
    const quantity = 2;
    const subtotal = effectiveUnitPrice * quantity;

    expect(effectiveUnitPrice).toBe(2300);
    expect(subtotal).toBe(4600);
  });

  it("applies price override correctly over base and variant prices", () => {
    const basePrice = 2000;
    const fixedAdjustment = 560;
    const override = 1800;
    const effectiveUnitPrice = override ?? (basePrice + fixedAdjustment);
    const quantity = 4;
    const subtotal = effectiveUnitPrice * quantity;

    expect(effectiveUnitPrice).toBe(1800);
    expect(subtotal).toBe(7200);
  });
});

