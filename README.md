# Brightloop — Subscription Management System

Enterprise-grade, production-minded SaaS subscription management platform for **Brightloop Software**.

---

## System Overview & Architecture (Phase 1)

Phase 1 establishes the rock-solid **Authentication & Identity Management** foundation:

- **Monorepo Architecture**: Clean separation between FastAPI backend and React Vite frontend.
- **Strict Layered Backend**:
  - `api/v1/`: Versioned REST API endpoints (`auth`, `users`, `audit_logs`, `health`).
  - `services/`: Business services coordinates domain rules, tokens, email dispatches, and audit trail.
  - `repositories/`: Async SQLAlchemy 2.0 query layer isolating persistence operations.
  - `models/`: Declarative models (`users`, `refresh_tokens`, `password_reset_tokens`, `audit_logs`).
  - `core/`: Argon2id password hashing, JWT operations, dependency injection, and Redis rate limiting.
- **Enterprise Light UI**:
  - Adaptive dashboard navigation for `ADMIN`, `STAFF`, and `CUSTOMER` roles.
  - User management console with staff provisioning and account status toggling.
  - Immutable security audit trail with live event inspection.
  - Customer self-service portal with meaningful empty states ready for Phase 2.
- **Defense in Depth**:
  - Passwords hashed with memory-hard **Argon2id**.
  - Passwords enforce strict complexity (>8 chars, uppercase, lowercase, numbers, special characters) on both frontend and backend.
  - Hybrid JWT tokens: access tokens kept in memory, refresh tokens stored in secure `httpOnly` cookies with automatic rotation and **token reuse detection** (revoking entire token families upon compromise).
  - Single-use SHA-256 hashed password reset tokens dispatched via local Mailpit SMTP.
  - Uniform timing-safe responses preventing email enumeration.

---

## Infrastructure & Port Allocation

To guarantee zero collisions with existing services on the host machine:

| Service | Container Port | Host Port | Description |
|---|---|---|---|
| **PostgreSQL 16** | `5432` | `5435` | Primary transactional database |
| **Redis 7** | `6379` | `6385` | Token blacklist & sliding window rate limiter |
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
The system administrator is provisioned exclusively through a secure CLI tool:
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
API Documentation is available at `http://localhost:8000/docs` and health check at `http://localhost:8000/api/v1/health`.

### 6. Frontend Setup & Startup
In a separate terminal:
```bash
cd frontend
npm install
npm run dev
```
Open `http://localhost:5173` in your browser.

---

## Running Verification & Tests

### Backend Automated Tests (Pytest)
```bash
cd backend
venv/bin/pytest -v
```
All 11 tests verify:
- Argon2id password hashing and complexity enforcement
- Customer registration and duplicate email rejection
- Login with short-lived JWT access tokens and httpOnly refresh cookies
- Refresh token rotation and token reuse detection (family revocation)
- Password reset token hashing, expiration, and single-use invalidation
- Role-based access control (RBAC) across Admin, Staff, and Customer
- Database and Redis health checks

### Frontend Verification (TypeScript, Vitest, & Production Build)
```bash
cd frontend

# TypeScript type checking (0 errors)
npm run typecheck

# Unit & component test suite (11 tests passed)
npm test

# Production build bundle
npm run build
```

---

## Default Development Accounts

| Role | Email | Password | Access Rights |
|---|---|---|---|
| **ADMIN** | `admin@brightloop.com` | `Brightloop#Admin2026` | Full system control, staff provisioning, status toggles, audit logs |
| **STAFF** | Provision via Admin UI (`/admin/users`) | Configured by Admin | Operations console, customer accounts, audit trail |
| **CUSTOMER** | Register at `/register` | User defined | Customer self-service portal, profile security |

---

## Dispatched Emails & Password Reset Testing
In local development, all emails are captured by **Mailpit**:
- Open **`http://localhost:8028`** in your browser to view incoming welcome emails and click password reset links.

---

## Roadmap: Next Milestones

- **Phase 2**: Products, Product Variants, Pricing Tiers, and Billing Frequencies.
- **Phase 3**: Quotations Engine & Quotation Templates.
- **Phase 4**: Subscription Lifecycle Management (Trials, Activations, Pauses, Cancellations, Upgrades).
- **Phase 5**: Recurring Invoices, Automatic Tax Calculations, and Discounts.
- **Phase 6**: Razorpay Payment Gateway Integration & Webhook Reconciliation.
- **Phase 7**: Customer Portal Self-Service Actions & Revenue Analytics.
