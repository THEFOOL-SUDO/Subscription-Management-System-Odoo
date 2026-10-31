from decimal import Decimal
import pytest
from httpx import AsyncClient
from tests.test_customers import get_test_headers


@pytest.mark.asyncio
async def test_dashboard_real_postgresql_aggregates(client: AsyncClient):
    admin_hdr, staff_hdr, cust1_hdr, _, _, _ = await get_test_headers()

    # 1. Admin/Staff receives global aggregates
    admin_res = await client.get("/api/v1/dashboard/metrics", headers=admin_hdr)
    assert admin_res.status_code == 200, admin_res.text
    data = admin_res.json()
    assert "active_subscriptions" in data
    assert "total_customers" in data
    assert "revenue_collected" in data
    assert "outstanding_invoice_amount" in data
    assert "overdue_invoices" in data
    assert "revenue_trend" in data
    assert "recent_payments" in data
    assert "recent_subscriptions" in data

    assert data["total_customers"] >= 1
    assert Decimal(data["revenue_collected"]) >= Decimal("0.0000")

    # Staff gets same operational view
    staff_res = await client.get("/api/v1/dashboard/metrics", headers=staff_hdr)
    assert staff_res.status_code == 200

    # 2. Customer receives role-scoped view of their own data
    cust_res = await client.get("/api/v1/dashboard/metrics", headers=cust1_hdr)
    assert cust_res.status_code == 200
    cust_data = cust_res.json()
    assert "revenue_collected" in cust_data
    assert "active_subscriptions" in cust_data

