import uuid
import pytest
from httpx import AsyncClient
from tests.test_products import get_auth_headers


@pytest.mark.asyncio
async def test_pricing_calculation_fixed_and_percentage_adjustments(client: AsyncClient):
    admin_headers, staff_headers, _ = await get_auth_headers(client)

    # Create Product with Fixed and Percentage variants
    p_res = await client.post(
        "/api/v1/products",
        headers=admin_headers,
        json={
            "name": "ERP Financials",
            "sku": f"ERP-{uuid.uuid4().hex[:6].upper()}",
            "product_type": "SOFTWARE",
            "sales_price": "2000.0000",
            "currency": "INR",
            "variants": [
                {
                    "variant_name": "Odoo Integration",
                    "variant_code": "ODOO",
                    "adjustment_type": "FIXED_AMOUNT",
                    "adjustment_value": "560.0000",
                },
                {
                    "variant_name": "Multi-Company",
                    "variant_code": "MCOMP",
                    "adjustment_type": "PERCENTAGE",
                    "adjustment_value": "15.0000",
                },
            ],
        },
    )
    prod = p_res.json()
    product_id = prod["id"]
    fixed_variant = next(v for v in prod["variants"] if v["variant_code"] == "ODOO")
    pct_variant = next(v for v in prod["variants"] if v["variant_code"] == "MCOMP")
    fixed_variant_id = fixed_variant["id"]
    pct_variant_id = pct_variant["id"]

    # Calculate pricing for both items
    calc_res = await client.post(
        "/api/v1/pricing/calculate",
        headers=staff_headers,  # Staff can also calculate pricing
        json={
            "currency": "INR",
            "items": [
                {
                    "product_id": product_id,
                    "variant_id": fixed_variant_id,
                    "quantity": 2,
                },
                {
                    "product_id": product_id,
                    "variant_id": pct_variant_id,
                    "quantity": 3,
                },
            ],
        },
    )
    assert calc_res.status_code == 200
    data = calc_res.json()
    assert data["currency"] == "INR"
    assert len(data["items"]) == 2

    item1 = data["items"][0]
    assert item1["base_unit_price"] == "2000.0000"
    assert item1["adjustment_type"] == "FIXED_AMOUNT"
    assert item1["effective_unit_price"] == "2560.0000"
    assert item1["quantity"] == 2
    assert item1["subtotal"] == "5120.0000"

    item2 = data["items"][1]
    assert item2["base_unit_price"] == "2000.0000"
    assert item2["adjustment_type"] == "PERCENTAGE"
    assert item2["effective_unit_price"] == "2300.0000"
    assert item2["quantity"] == 3
    assert item2["subtotal"] == "6900.0000"

    # Total: 5120 + 6900 = 12020
    assert data["total_price"] == "12020.0000"


@pytest.mark.asyncio
async def test_pricing_calculation_override(client: AsyncClient):
    admin_headers, _, _ = await get_auth_headers(client)

    p_res = await client.post(
        "/api/v1/products",
        headers=admin_headers,
        json={
            "name": "Standard Software",
            "sku": f"SW-{uuid.uuid4().hex[:6].upper()}",
            "product_type": "SOFTWARE",
            "sales_price": "5000.0000",
            "currency": "INR",
        },
    )
    product_id = p_res.json()["id"]

    calc_res = await client.post(
        "/api/v1/pricing/calculate",
        headers=admin_headers,
        json={
            "currency": "INR",
            "items": [
                {
                    "product_id": product_id,
                    "quantity": 4,
                    "price_override": "4500.0000",
                }
            ],
        },
    )
    assert calc_res.status_code == 200
    data = calc_res.json()
    item = data["items"][0]
    assert item["price_override_applied"] is True
    assert item["effective_unit_price"] == "4500.0000"
    assert item["subtotal"] == "18000.0000"
    assert data["total_price"] == "18000.0000"


@pytest.mark.asyncio
async def test_pricing_currency_mismatch_fails(client: AsyncClient):
    admin_headers, _, _ = await get_auth_headers(client)

    p_res = await client.post(
        "/api/v1/products",
        headers=admin_headers,
        json={
            "name": "INR Product",
            "sku": f"INR-{uuid.uuid4().hex[:6].upper()}",
            "product_type": "SOFTWARE",
            "sales_price": "100.0000",
            "currency": "INR",
        },
    )
    product_id = p_res.json()["id"]

    calc_res = await client.post(
        "/api/v1/pricing/calculate",
        headers=admin_headers,
        json={
            "currency": "USD",
            "items": [
                {
                    "product_id": product_id,
                    "quantity": 1,
                }
            ],
        },
    )
    assert calc_res.status_code == 400
    assert "currency" in calc_res.json()["detail"].lower()
