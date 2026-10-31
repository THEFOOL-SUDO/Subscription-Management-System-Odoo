from fastapi import APIRouter
from app.api.v1.endpoints import (
    audit_logs,
    auth,
    billing,
    customers,
    dashboard,
    discounts,
    health,
    invoices,
    payments,
    plans,
    pricing,
    products,
    quotations,
    subscriptions,
    taxes,
    users,
)

api_router = APIRouter()
api_router.include_router(health.router)
api_router.include_router(auth.router)
api_router.include_router(users.router)
api_router.include_router(audit_logs.router)
api_router.include_router(products.router)
api_router.include_router(plans.router)
api_router.include_router(pricing.router)
api_router.include_router(customers.router)
api_router.include_router(subscriptions.router)
api_router.include_router(invoices.router)
api_router.include_router(payments.router)
api_router.include_router(dashboard.router)
api_router.include_router(quotations.router)
api_router.include_router(discounts.router)
api_router.include_router(taxes.router)
api_router.include_router(billing.router)
