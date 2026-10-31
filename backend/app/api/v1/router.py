from fastapi import APIRouter
from app.api.v1.endpoints import (
    audit_logs,
    auth,
    customers,
    dashboard,
    health,
    invoices,
    payments,
    plans,
    pricing,
    products,
    subscriptions,
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
