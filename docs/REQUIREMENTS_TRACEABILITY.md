# Brightloop — Requirements Traceability Matrix (RTM)

**Specification Authority**: `Subscription_Management_System.pdf`  
**Overall Status**: **100% PASS**  
**Evidence Standard**: Verified by live code inspection, PostgreSQL database constraints, and passing automated test suites.

---

## Section A: Authentication, RBAC & User Management

| ID | Specification Requirement | Status | Code Implementation | API Endpoint | Test Evidence |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **A-01** | User registration for Customer role with email, full name, password | **PASS** | [`auth_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/auth_service.py#L35) | `POST /api/v1/auth/register` | `test_auth.py::test_register_customer_success` |
| **A-02** | Password complexity enforcement (min 8 chars, uppercase, lowercase, digit, special) | **PASS** | [`auth.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/schemas/auth.py#L25) | `POST /api/v1/auth/register` | `test_auth.py::test_register_password_complexity_failure` |
| **A-03** | Argon2id password hashing | **PASS** | [`security.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/core/security.py#L18) | Internal helper | `test_security.py::test_password_hashing_argon2id` |
| **A-04** | Role-based authorization (`ADMIN`, `STAFF`, `CUSTOMER`) | **PASS** | [`dependencies.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/core/dependencies.py#L45) | All `/api/v1/*` routes | `test_users.py::test_rbac_and_user_management` |
| **A-05** | Refresh token rotation & reuse detection | **PASS** | [`auth_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/auth_service.py#L95) | `POST /api/v1/auth/refresh` | `test_auth.py::test_refresh_token_rotation_and_reuse_detection` |
| **A-06** | Secure password reset with single-use token and Mailpit dispatch | **PASS** | [`auth_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/auth_service.py#L140) | `POST /api/v1/auth/forgot-password`, `POST /api/v1/auth/reset-password` | `test_auth.py::test_forgot_and_reset_password_flow` |
| **A-07** | Staff cannot create Staff or Admin accounts | **PASS** | [`user_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/user_service.py#L45) | `POST /api/v1/users` | `test_demo_e2e_audit.py::test_neg_08_staff_forbidden_admin_endpoints` |

---

## Section B: Product & Variant Management

| ID | Specification Requirement | Status | Code Implementation | API Endpoint | Test Evidence |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **B-01** | Product catalog with SKU, name, type, sales price, cost price, notes | **PASS** | [`product.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/models/product.py#L25) | `POST /api/v1/products`, `GET /api/v1/products` | `test_products.py::test_product_creation_and_variant_management` |
| **B-02** | Product variants with fixed amount and percentage adjustments | **PASS** | [`product.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/models/product.py#L80) | `POST /api/v1/products/{id}/variants` | `test_pricing.py::test_pricing_calculation_fixed_and_percentage_adjustments` |
| **B-03** | Server-side Decimal pricing calculation with non-negative clamping | **PASS** | [`pricing_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/pricing_service.py#L22) | `POST /api/v1/pricing/calculate` | `test_pricing.py::test_pricing_calculation_override` |
| **B-04** | Currency homogeneity enforcement across products and plans | **PASS** | [`pricing_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/pricing_service.py#L62) | `POST /api/v1/pricing/calculate` | `test_pricing.py::test_pricing_currency_mismatch_fails` |
| **B-05** | Immutable price history tracking | **PASS** | [`product_repo.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/repositories/product_repo.py#L140) | Internal audit trigger | `test_products.py::test_product_price_history_and_immutability` |
| **B-06** | Soft archival guard preventing deletion of products referenced in plans/contracts | **PASS** | [`product_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/product_service.py#L125) | `DELETE /api/v1/products/{id}` | `test_products.py::test_product_archival_soft_guard` |

---

## Section C: Subscription Plan Management

| ID | Specification Requirement | Status | Code Implementation | API Endpoint | Test Evidence |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **C-01** | Subscription plan definition with billing intervals (`MONTHLY`, `ANNUAL`) | **PASS** | [`plan.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/models/plan.py#L20) | `POST /api/v1/plans`, `GET /api/v1/plans` | `test_plans.py::test_plan_creation_and_currency_homogeneity` |
| **C-02** | Bundling software components and add-ons with price overrides | **PASS** | [`plan_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/plan_service.py#L130) | `POST /api/v1/plans/{id}/products` | `test_plans.py::test_bundled_product_management_and_price_override` |
| **C-03** | Plan lifecycle state machine (`DRAFT`, `ACTIVE`, `ARCHIVED`) with activation guard | **PASS** | [`plan_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/plan_service.py#L170) | `PATCH /api/v1/plans/{id}/status` | `test_plans.py::test_plan_lifecycle_and_activation_guard` |
| **C-04** | Minimum and maximum quantity restrictions per plan | **PASS** | [`subscription_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/subscription_service.py#L233) | `POST /api/v1/subscriptions` | `test_demo_e2e_audit.py::test_neg_02_invalid_subscription_quantity` |
| **C-05** | Auto-close mechanism upon availability end date | **PASS** | [`plan_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/plan_service.py#L29) | Auto-evaluated on read/list | `test_plans.py::test_plan_auto_close_mechanism` |

---

## Section D: Customer Management & Data Isolation

| ID | Specification Requirement | Status | Code Implementation | API Endpoint | Test Evidence |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **D-01** | Enterprise customer profiles with unique code, name, email, billing address | **PASS** | [`customer.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/models/customer.py#L15) | `POST /api/v1/customers`, `GET /api/v1/customers` | `test_customers.py::test_customer_creation_auto_provisioning_and_rbac` |
| **D-02** | Automatic customer login account provisioning with secure activation email | **PASS** | [`customer_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/customer_service.py#L65) | `POST /api/v1/customers` | `test_customers.py::test_customer_creation_auto_provisioning_and_rbac` |
| **D-03** | Strict customer data isolation (customer can only view own records) | **PASS** | [`customer_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/customer_service.py#L35) | `GET /api/v1/customers/{id}` | `test_customers.py::test_customer_data_isolation` |
| **D-04** | Duplicate customer email prevention | **PASS** | [`customer_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/customer_service.py#L50) | `POST /api/v1/customers` | `test_demo_e2e_audit.py::test_neg_01_duplicate_customer_email` |

---

## Section E: Subscription Management & Lifecycle

| ID | Specification Requirement | Status | Code Implementation | API Endpoint | Test Evidence |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **E-01** | Subscription creation with server-generated unique number (`SUB-YYYYMM-XXXX`) | **PASS** | [`subscription_repo.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/repositories/subscription_repo.py#L55) | `POST /api/v1/subscriptions` | `test_subscriptions.py::test_subscription_creation_pricing_and_lifecycle` |
| **E-02** | 5-stage audited lifecycle state machine (`DRAFT → QUOTATION → CONFIRMED → ACTIVE → CLOSED`) | **PASS** | [`subscription_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/subscription_service.py#L145) | `POST /api/v1/subscriptions/{id}/status` | `test_demo_e2e_audit.py::test_e2e_positive_workflow_steps_02_to_11` |
| **E-03** | Subscriptions only created against ACTIVE plans | **PASS** | [`subscription_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/subscription_service.py#L210) | `POST /api/v1/subscriptions` | `test_demo_e2e_audit.py::test_neg_03_inactive_or_draft_plan` |
| **E-04** | Extended lifecycle operations: `PAUSE` and `RESUME` with pause day shift | **PASS** | [`subscription_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/subscription_service.py#L320) | `POST /api/v1/subscriptions/{id}/pause`, `POST /api/v1/subscriptions/{id}/resume` | `test_commercial_elevation.py` |
| **E-05** | Extended lifecycle operations: `RENEW` and `CLOSE` with audit history | **PASS** | [`subscription_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/subscription_service.py#L370) | `POST /api/v1/subscriptions/{id}/renew`, `POST /api/v1/subscriptions/{id}/close` | `test_commercial_elevation.py` |

---

## Section F: Invoicing Engine & Billing Rules

| ID | Specification Requirement | Status | Code Implementation | API Endpoint | Test Evidence |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **F-01** | Itemized invoice generation with unique number (`INV-YYYYMM-XXXX`) | **PASS** | [`invoice_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/invoice_service.py#L157) | `POST /api/v1/invoices` | `test_invoices_and_payments.py::test_invoice_creation_partial_payment_and_auto_activation` |
| **F-02** | Automatic 18.00% GST tax calculation with configurable tax rules | **PASS** | [`tax_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/tax_service.py#L25) | `GET /api/v1/taxes` | `test_commercial_elevation.py` |
| **F-03** | Duplicate billing period overlap prevention | **PASS** | [`invoice_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/invoice_service.py#L127) | `POST /api/v1/invoices` | `test_demo_e2e_audit.py::test_neg_04_duplicate_billing_period` |
| **F-04** | Invoice lifecycle (`DRAFT`, `CONFIRMED`, `PAID`, `CANCELLED`) with cancellation guards | **PASS** | [`invoice_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/invoice_service.py#L237) | `PATCH /api/v1/invoices/{id}/status` | `test_demo_e2e_audit.py::test_neg_09_payment_against_cancelled_or_paid_invoice` |
| **F-05** | Customer invoice data isolation (cross-access prohibited) | **PASS** | [`invoice_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/invoice_service.py#L50) | `GET /api/v1/invoices/{id}` | `test_demo_e2e_audit.py::test_neg_07_customer_isolation_cross_access` |
| **F-06** | Printable invoice format (`@media print`) and Mailpit HTML delivery | **PASS** | [`email_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/email_service.py#L65) | `POST /api/v1/invoices/{id}/send-email` | `test_commercial_elevation.py` |

---

## Section G: Payments & Safe Gateway Integration

| ID | Specification Requirement | Status | Code Implementation | API Endpoint | Test Evidence |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **G-01** | Safe Demo Payment Provider Engine (`DEMO_UPI`, `DEMO_CARD`, `DEMO_NETBANKING`) | **PASS** | [`demo_payment_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/demo_payment_service.py#L34) | `POST /api/v1/payments/demo/checkout-session`, `POST /api/v1/payments/demo/process` | `test_demo_payments.py::test_demo_payment_full_workflow` |
| **G-02** | Prominent amber warning banner displayed across checkout dialogs | **PASS** | [`DemoPaymentModal.tsx`](file:///home/z/Desktop/project/Subscription%20Management%20System/frontend/src/components/payments/DemoPaymentModal.tsx#L120) | Frontend Modal UI | `walkthrough.md` Screen Carousel (`17_demo_payment_checkout_modal.png`) |
| **G-03** | Partial payment recording and remaining balance tracking | **PASS** | [`demo_payment_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/demo_payment_service.py#L260) | `POST /api/v1/payments/demo/process` | `test_demo_payments.py::test_demo_payment_full_workflow` |
| **G-04** | Overpayment and non-positive payment rejection | **PASS** | [`demo_payment_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/demo_payment_service.py#L167) | `POST /api/v1/payments/demo/process` | `test_demo_e2e_audit.py::test_neg_05_zero_or_negative_payment`, `test_neg_06_overpayment_rejection` |
| **G-05** | Idempotency protection & concurrent race-condition prevention | **PASS** | [`demo_payment_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/demo_payment_service.py#L146) | `POST /api/v1/payments/demo/process` | `test_concurrency_and_atomicity.py::test_concurrent_duplicate_payment_requests` |
| **G-06** | Subscription auto-activation hook upon full settlement of confirmed invoice | **PASS** | [`demo_payment_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/demo_payment_service.py#L310) | Automated hook | `test_demo_payments.py::test_demo_payment_full_workflow` |

---

## Section H: Quotations, Discounts & Billing Engine

| ID | Specification Requirement | Status | Code Implementation | API Endpoint | Test Evidence |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **H-01** | Quotation templates with bundled line items, presets, and 1-click conversion | **PASS** | [`quotation_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/quotation_service.py#L30) | `POST /api/v1/quotation-templates/{id}/convert-to-subscription` | `test_commercial_elevation.py` |
| **H-02** | Configurable discount rules (percentage & fixed credit) with pre-validation | **PASS** | [`discount_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/discount_service.py#L34) | `POST /api/v1/discounts/validate` | `test_concurrency_and_atomicity.py::test_discount_validation_rules_and_quantities` |
| **H-03** | Automated recurring billing scheduler scanning due subscriptions | **PASS** | [`billing_scheduler_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/billing_scheduler_service.py#L35) | `POST /api/v1/billing/run-scheduler` | `test_concurrency_and_atomicity.py::test_concurrent_billing_scheduler_runs` |

---

## Section I: Telemetry, Reporting & Audit Logging

| ID | Specification Requirement | Status | Code Implementation | API Endpoint | Test Evidence |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **I-01** | Real PostgreSQL aggregated business metrics (0 mock arrays) | **PASS** | [`dashboard_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/dashboard_service.py#L21) | `GET /api/v1/dashboard/metrics` | `test_dashboard_metrics.py::test_dashboard_real_postgresql_aggregates` |
| **I-02** | Role-scoped telemetry visibility (Customer sees only own metrics) | **PASS** | [`dashboard_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/dashboard_service.py#L24) | `GET /api/v1/dashboard/metrics` | `test_dashboard_metrics.py::test_dashboard_real_postgresql_aggregates` |
| **I-03** | Comprehensive audit logging with actor IP, user agent, and payload diffs | **PASS** | [`audit_service.py`](file:///home/z/Desktop/project/Subscription%20Management%20System/backend/app/services/audit_service.py#L20) | `GET /api/v1/audit-logs` | All test workflows verify audit entries |

