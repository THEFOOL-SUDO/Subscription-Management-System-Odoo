# Brightloop — Subscription Management System

Enterprise-grade, production-minded SaaS subscription management platform for **Brightloop Software**.

---

## System Overview & Architecture

### Phase 1: Authentication & Identity Management
- **Monorepo Architecture**: Clean separation between FastAPI backend and React Vite frontend.
- **Strict Layered Backend**:
  - `api/v1/`: Versioned REST API endpoints (`auth`, `users`, `audit_logs`, `health`).
  - `services/`: Domain services coordinating business rules, tokens, email dispatches, and audit trail.
  - `repositories/`: Async SQLAlchemy 2.0 query layer isolating persistence operations.
  - `models/`: Normalized models (`users`, `refresh_tokens`, `password_reset_tokens`, `audit_logs`).
  - `core/`: Argon2id password hashing, JWT operations, dependency injection, and Redis rate limiting.
- **Defense in Depth**:
  - Passwords hashed with memory-hard **Argon2id**.
  - Strict complexity rules (>8 chars, uppercase, lowercase, numbers, special characters).
  - Hybrid JWT tokens: in-memory access tokens and rotated `httpOnly` refresh tokens with **reuse detection** (family revocation).
  - Single-use SHA-256 hashed password reset tokens via Mailpit.
  - Uniform timing-safe responses preventing email enumeration.

### Phase 2: Product & Subscription Plan Management
- **Authoritative Product Catalog**:
  - Product classification: `SOFTWARE`, `ADDON`, `PHYSICAL_PRODUCT`.
  - Unique SKU enforcement and non-destructive archival (`is_archived = True`, `is_active = False`).
  - Monetary values stored using PostgreSQL `NUMERIC(14, 4)` and Python `Decimal`, strictly preventing IEEE-754 floating-point inaccuracies.
- **Product Variants & Pricing Engine**:
  - Sub-SKU variants with unique codes per product.
  - Support for `FIXED_AMOUNT` and `PERCENTAGE` unit price adjustments.
  - Authoritative backend pricing calculator (`POST /api/v1/pricing/calculate`) that never trusts client-supplied sums.
- **Immutable Price History**:
  - Dedicated revision ledgers (`product_price_history`, `variant_price_history`) tracking old price, new price, modifier user ID, timestamp, and audit change reasons.
  - Historical price records are permanent, providing snapshots for future Phase 4 subscriptions.
- **Subscription Plan Management**:
  - Lifecycle state machine: `DRAFT` ➔ `ACTIVE` ➔ `INACTIVE` ➔ `ARCHIVED`.
  - Activation guard: plans cannot be activated without at least one active bundled component.
  - Recurrence intervals: `DAILY`, `WEEKLY`, `MONTHLY`, `YEARLY` with configurable interval counts and trial days.
  - Availability-based auto-close: plans with past `availability_end_date` automatically transition out of `ACTIVE` to prevent new subscriptions.
  - Currency homogeneity: bundled products must match the plan's operating currency.
  - Soft-guard archival: archiving a product or variant safely deactivates associated plan line items with an audit notice.
- **Enterprise Light UI**:
  - Light-themed administrative UI with soft neutral backgrounds, subtle borders, and professional navy accents.
  - Live variant price preview calculators, audit timelines, and line-item bundle managers.

---

## Infrastructure & Port Allocation

| Service | Container Port | Host Port | Description |
|---|---|---|---|
| **PostgreSQL 16** | `5432` | `5435` | Primary transactional database |
| **Redis 7** | `6379` | `6385` | Rate limiter and cache |
| **Mailpit Web** | `8025` | `8028` | Local email testing web interface |
| **Mailpit SMTP** | `1025` | `1028` | Local email dispatch server |
| **FastAPI Backend** | `8000` | `8000` | REST API (`/api/v1`) |
| **React Vite SPA** | `5173` | `5173` | Enterprise web application |

---

## Quickstart & Installation

### 1. Start Infrastructure Containers
```bash
docker compose up -d
```
Verify containers are healthy:
```bash
docker ps --filter "name=brightloop"
```

### 2. Backend Setup
```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 3. Run Database Migrations
```bash
venv/bin/alembic upgrade head
```

### 4. Bootstrap Initial Administrator
```bash
venv/bin/python -m app.cli.bootstrap_admin \
  --email admin@brightloop.com \
  --name "System Administrator" \
  --password "Brightloop#Admin2026"
```

### 5. Start Backend Dev Server
```bash
venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
Interactive API documentation: `http://localhost:8000/docs`.

### 6. Frontend Setup & Startup
In a separate terminal:
```bash
cd frontend
npm install
npm run dev
```
Open `http://localhost:5173` in your browser.

---

## API Endpoints Reference

### Product Management (`/api/v1/products`)
- `GET /products`: List products with pagination, search, and type/status filters (Admin, Staff).
- `POST /products`: Create product with initial variants (Admin).
- `GET /products/{id}`: Full product record, variants, and immutable price revision timeline (Admin, Staff).
- `PUT /products/{id}`: Update product details and prices with mandatory reason tracking (Admin).
- `POST /products/{id}/archive`: Soft-archive product and deactivate associated plan items (Admin).
- `POST /products/{id}/variants`: Create product variant (Admin).
- `PUT /products/{id}/variants/{variant_id}`: Update variant adjustment rule and log price change (Admin).
- `POST /products/{id}/variants/{variant_id}/archive`: Deactivate variant (Admin).

### Subscription Plan Management (`/api/v1/plans`)
- `GET /plans`: List subscription plans with pagination and live bundle pricing (Admin, Staff).
- `POST /plans`: Create subscription plan (Admin).
- `GET /plans/{id}`: Get plan details, bundled line items, and auto-close status (Admin, Staff).
- `PUT /plans/{id}`: Update plan configuration (Admin).
- `PATCH /plans/{id}/status`: Transition plan status (`DRAFT`, `ACTIVE`, `INACTIVE`, `ARCHIVED`) (Admin).
- `POST /plans/{id}/products`: Bundle a product/variant into the plan (Admin).
- `PUT /plans/{id}/products/{line_item_id}`: Update line item quantity or price override (Admin).
- `DELETE /plans/{id}/products/{line_item_id}`: Remove line item from plan (Admin).

### Authoritative Pricing Engine (`/api/v1/pricing`)
- `POST /pricing/calculate`: Compute line-item effective prices, discounts, and order subtotals with exact `Decimal` precision (Admin, Staff).

---

## Running Automated Verification Suites

### Backend Tests (24 Pytest Tests)
```bash
cd backend
./venv/bin/pytest -v
```

### Frontend Vitest Tests (18 Tests)
```bash
cd frontend
npm test -- --run
```

### Frontend TypeScript Check
```bash
cd frontend
npm run typecheck
```

### Frontend Production Build
```bash
cd frontend
npm run build
```
