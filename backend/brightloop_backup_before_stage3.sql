--
-- PostgreSQL database dump
--

\restrict cfptdwGOYPnXpviu8KatGzO8DBjffw66KLgsbw1ML4ujJdGVdY1CwhqP5eLCZaN

-- Dumped from database version 16.15
-- Dumped by pg_dump version 16.15

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: brightloop_user
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO brightloop_user;

--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: brightloop_user
--

CREATE TABLE public.audit_logs (
    id uuid NOT NULL,
    user_id uuid,
    action character varying(64) NOT NULL,
    resource_type character varying(64) NOT NULL,
    resource_id character varying(64),
    details jsonb DEFAULT '{}'::jsonb NOT NULL,
    ip_address character varying(45),
    user_agent character varying(512),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.audit_logs OWNER TO brightloop_user;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: brightloop_user
--

CREATE TABLE public.customers (
    id uuid NOT NULL,
    user_id uuid,
    customer_number character varying(50) NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    phone character varying(50),
    company_name character varying(255),
    billing_address_line1 character varying(255),
    billing_address_line2 character varying(255),
    billing_city character varying(100),
    billing_state character varying(100),
    billing_postal_code character varying(20),
    billing_country character varying(100) DEFAULT 'India'::character varying NOT NULL,
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    created_by_id uuid,
    updated_by_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.customers OWNER TO brightloop_user;

--
-- Name: invoice_items; Type: TABLE; Schema: public; Owner: brightloop_user
--

CREATE TABLE public.invoice_items (
    id uuid NOT NULL,
    invoice_id uuid NOT NULL,
    product_id uuid NOT NULL,
    variant_id uuid,
    description character varying(255) NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    unit_price numeric(14,4) NOT NULL,
    subtotal numeric(14,4) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.invoice_items OWNER TO brightloop_user;

--
-- Name: invoices; Type: TABLE; Schema: public; Owner: brightloop_user
--

CREATE TABLE public.invoices (
    id uuid NOT NULL,
    invoice_number character varying(50) NOT NULL,
    subscription_id uuid NOT NULL,
    customer_id uuid NOT NULL,
    status character varying(30) DEFAULT 'DRAFT'::character varying NOT NULL,
    payment_status character varying(30) DEFAULT 'UNPAID'::character varying NOT NULL,
    issue_date timestamp with time zone NOT NULL,
    due_date timestamp with time zone NOT NULL,
    billing_period_start timestamp with time zone NOT NULL,
    billing_period_end timestamp with time zone NOT NULL,
    currency character varying(3) DEFAULT 'INR'::character varying NOT NULL,
    subtotal numeric(14,4) NOT NULL,
    tax_rate numeric(6,4) DEFAULT 18.0000 NOT NULL,
    tax_amount numeric(14,4) DEFAULT 0.0000 NOT NULL,
    discount_amount numeric(14,4) DEFAULT 0.0000 NOT NULL,
    total_amount numeric(14,4) NOT NULL,
    amount_paid numeric(14,4) DEFAULT 0.0000 NOT NULL,
    balance_due numeric(14,4) NOT NULL,
    notes text,
    created_by_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.invoices OWNER TO brightloop_user;

--
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: brightloop_user
--

CREATE TABLE public.password_reset_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_hash character varying(128) NOT NULL,
    is_used boolean DEFAULT false NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.password_reset_tokens OWNER TO brightloop_user;

--
-- Name: payments; Type: TABLE; Schema: public; Owner: brightloop_user
--

CREATE TABLE public.payments (
    id uuid NOT NULL,
    payment_number character varying(50) NOT NULL,
    invoice_id uuid NOT NULL,
    customer_id uuid NOT NULL,
    amount numeric(14,4) NOT NULL,
    currency character varying(3) DEFAULT 'INR'::character varying NOT NULL,
    payment_method character varying(30) NOT NULL,
    payment_date timestamp with time zone NOT NULL,
    reference_number character varying(100),
    notes text,
    recorded_by_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.payments OWNER TO brightloop_user;

--
-- Name: plan_products; Type: TABLE; Schema: public; Owner: brightloop_user
--

CREATE TABLE public.plan_products (
    id uuid NOT NULL,
    plan_id uuid NOT NULL,
    product_id uuid NOT NULL,
    variant_id uuid,
    default_quantity integer DEFAULT 1 NOT NULL,
    is_optional boolean DEFAULT false NOT NULL,
    price_override numeric(14,4),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.plan_products OWNER TO brightloop_user;

--
-- Name: product_price_history; Type: TABLE; Schema: public; Owner: brightloop_user
--

CREATE TABLE public.product_price_history (
    id uuid NOT NULL,
    product_id uuid NOT NULL,
    price_field character varying(32) NOT NULL,
    old_price numeric(14,4),
    new_price numeric(14,4) NOT NULL,
    changed_by_id uuid,
    reason text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.product_price_history OWNER TO brightloop_user;

--
-- Name: product_variants; Type: TABLE; Schema: public; Owner: brightloop_user
--

CREATE TABLE public.product_variants (
    id uuid NOT NULL,
    product_id uuid NOT NULL,
    variant_name character varying(255) NOT NULL,
    variant_code character varying(100) NOT NULL,
    adjustment_type character varying(32) DEFAULT 'FIXED_AMOUNT'::character varying NOT NULL,
    adjustment_value numeric(14,4) DEFAULT 0.0000 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.product_variants OWNER TO brightloop_user;

--
-- Name: products; Type: TABLE; Schema: public; Owner: brightloop_user
--

CREATE TABLE public.products (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    sku character varying(100) NOT NULL,
    product_type character varying(32) NOT NULL,
    description text,
    notes text,
    sales_price numeric(14,4) NOT NULL,
    cost_price numeric(14,4),
    currency character varying(3) DEFAULT 'INR'::character varying NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    is_archived boolean DEFAULT false NOT NULL,
    created_by_id uuid,
    updated_by_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.products OWNER TO brightloop_user;

--
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: brightloop_user
--

CREATE TABLE public.refresh_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_hash character varying(128) NOT NULL,
    family_id uuid NOT NULL,
    is_revoked boolean DEFAULT false NOT NULL,
    is_used boolean DEFAULT false NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_agent character varying(512),
    ip_address character varying(45)
);


ALTER TABLE public.refresh_tokens OWNER TO brightloop_user;

--
-- Name: subscription_items; Type: TABLE; Schema: public; Owner: brightloop_user
--

CREATE TABLE public.subscription_items (
    id uuid NOT NULL,
    subscription_id uuid NOT NULL,
    product_id uuid NOT NULL,
    variant_id uuid,
    quantity integer DEFAULT 1 NOT NULL,
    unit_price numeric(14,4) NOT NULL,
    subtotal numeric(14,4) NOT NULL,
    notes character varying(255),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.subscription_items OWNER TO brightloop_user;

--
-- Name: subscription_plans; Type: TABLE; Schema: public; Owner: brightloop_user
--

CREATE TABLE public.subscription_plans (
    id uuid NOT NULL,
    code character varying(100) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    billing_interval character varying(32) DEFAULT 'MONTHLY'::character varying NOT NULL,
    interval_count integer DEFAULT 1 NOT NULL,
    trial_period_days integer DEFAULT 0 NOT NULL,
    status character varying(32) DEFAULT 'DRAFT'::character varying NOT NULL,
    currency character varying(3) DEFAULT 'INR'::character varying NOT NULL,
    min_quantity integer DEFAULT 1 NOT NULL,
    max_quantity integer,
    is_auto_close boolean DEFAULT false NOT NULL,
    availability_start_date timestamp with time zone,
    availability_end_date timestamp with time zone,
    created_by_id uuid,
    updated_by_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.subscription_plans OWNER TO brightloop_user;

--
-- Name: subscription_status_history; Type: TABLE; Schema: public; Owner: brightloop_user
--

CREATE TABLE public.subscription_status_history (
    id uuid NOT NULL,
    subscription_id uuid NOT NULL,
    from_status character varying(30),
    to_status character varying(30) NOT NULL,
    reason character varying(255),
    changed_by_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.subscription_status_history OWNER TO brightloop_user;

--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: brightloop_user
--

CREATE TABLE public.subscriptions (
    id uuid NOT NULL,
    subscription_number character varying(50) NOT NULL,
    customer_id uuid NOT NULL,
    plan_id uuid NOT NULL,
    status character varying(30) DEFAULT 'DRAFT'::character varying NOT NULL,
    start_date timestamp with time zone NOT NULL,
    expiry_date timestamp with time zone,
    billing_interval character varying(20) NOT NULL,
    interval_count integer DEFAULT 1 NOT NULL,
    currency character varying(3) DEFAULT 'INR'::character varying NOT NULL,
    payment_terms character varying(30) DEFAULT 'NET_30'::character varying NOT NULL,
    subtotal numeric(14,4) DEFAULT 0.0000 NOT NULL,
    tax_rate numeric(6,4) DEFAULT 18.0000 NOT NULL,
    tax_amount numeric(14,4) DEFAULT 0.0000 NOT NULL,
    discount_amount numeric(14,4) DEFAULT 0.0000 NOT NULL,
    total_amount numeric(14,4) DEFAULT 0.0000 NOT NULL,
    notes text,
    created_by_id uuid,
    updated_by_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.subscriptions OWNER TO brightloop_user;

--
-- Name: users; Type: TABLE; Schema: public; Owner: brightloop_user
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    email character varying(255) NOT NULL,
    full_name character varying(255) NOT NULL,
    hashed_password character varying(255) NOT NULL,
    role character varying(32) DEFAULT 'CUSTOMER'::character varying NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    is_verified boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.users OWNER TO brightloop_user;

--
-- Name: variant_price_history; Type: TABLE; Schema: public; Owner: brightloop_user
--

CREATE TABLE public.variant_price_history (
    id uuid NOT NULL,
    variant_id uuid NOT NULL,
    old_adjustment_type character varying(32),
    new_adjustment_type character varying(32) NOT NULL,
    old_adjustment_value numeric(14,4),
    new_adjustment_value numeric(14,4) NOT NULL,
    changed_by_id uuid,
    reason text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.variant_price_history OWNER TO brightloop_user;

--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: brightloop_user
--

COPY public.alembic_version (version_num) FROM stdin;
003_subscription_billing_schema
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: brightloop_user
--

COPY public.audit_logs (id, user_id, action, resource_type, resource_id, details, ip_address, user_agent, created_at) FROM stdin;
73145437-6722-4472-bd03-150b29ca4d3b	5040313c-9900-4630-93f9-1f0e119412dd	ADMIN_BOOTSTRAPPED	user	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com", "source": "CLI"}	\N	\N	2026-10-31 04:11:58.133516+00
ecfaca69-262d-4347-af0c-12e208c0cad7	86e39d83-656a-4a5f-b96d-9ee66a6620ca	USER_REGISTERED	user	86e39d83-656a-4a5f-b96d-9ee66a6620ca	{"role": "CUSTOMER", "email": "customer_8a0265cf@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:13:42.779947+00
44e6407f-40b2-4337-bec3-cbe806cbae08	6e59d264-58ea-4ada-ae92-99dd3d5aa6d9	USER_REGISTERED	user	6e59d264-58ea-4ada-ae92-99dd3d5aa6d9	{"role": "CUSTOMER", "email": "login_user_128727ed@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:13:43.210571+00
1f11fe2e-ba45-456d-94d0-e31cba9d4668	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 07:43:37.072307+00
a1f763c3-dd01-4f02-94f1-982e6e5b5a1f	6e59d264-58ea-4ada-ae92-99dd3d5aa6d9	AUTH_LOGIN_SUCCESS	auth	6e59d264-58ea-4ada-ae92-99dd3d5aa6d9	{"role": "CUSTOMER", "email": "login_user_128727ed@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:13:43.325325+00
8dc31a6b-c3f7-449a-ba6a-9512137396a4	eff31d33-4717-4f20-8fb1-480799cdeae5	USER_REGISTERED	user	eff31d33-4717-4f20-8fb1-480799cdeae5	{"role": "CUSTOMER", "email": "reset_d49fb5b2@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:13:43.606226+00
e8f04a60-3cff-4b16-a9a8-87d3febc7803	eff31d33-4717-4f20-8fb1-480799cdeae5	PASSWORD_RESET_REQUESTED	auth	eff31d33-4717-4f20-8fb1-480799cdeae5	{"email": "reset_d49fb5b2@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:13:43.677203+00
a87a071c-1a6f-4be7-850c-25ebdb059631	eff31d33-4717-4f20-8fb1-480799cdeae5	PASSWORD_RESET_COMPLETED	auth	eff31d33-4717-4f20-8fb1-480799cdeae5	{"email": "reset_d49fb5b2@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:13:43.703589+00
6658248d-0575-4186-bacb-e5a7a0bdbe73	f8153125-3c20-42d4-ad8f-09c161b7bb5d	TOKEN_REUSE_DETECTED	auth	1f6b1709-567a-48bc-9b25-cb847ff9e043	{"reason": "Attempted reuse of consumed token", "family_id": "c8310cba-720d-42be-96de-aab6b79ddf7b"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:07.388781+00
8d4eda52-fa4b-446c-b365-b097f5b5126c	eff31d33-4717-4f20-8fb1-480799cdeae5	AUTH_LOGIN_SUCCESS	auth	eff31d33-4717-4f20-8fb1-480799cdeae5	{"role": "CUSTOMER", "email": "reset_d49fb5b2@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:13:43.810756+00
78fdcb66-2eaf-40fd-a464-8fca3c5c2aef	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:13:44.010691+00
818d6aa4-f58a-4788-899f-13ae31d76fbb	323912e5-9c09-4482-8595-d1428cf1c4c0	USER_REGISTERED	user	323912e5-9c09-4482-8595-d1428cf1c4c0	{"role": "CUSTOMER", "email": "cust_4ff5b2fc@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:13:44.074631+00
dd83a787-e9ce-418d-9911-59f0c4c80c78	5040313c-9900-4630-93f9-1f0e119412dd	STAFF_CREATED	user	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	{"role": "STAFF", "created_email": "staff_47ff2f38@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:13:44.154827+00
e3d73a71-a25f-438e-ad43-c960ed1f783e	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	AUTH_LOGIN_SUCCESS	auth	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	{"role": "STAFF", "email": "staff_47ff2f38@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:13:44.207955+00
e0d97006-e819-4546-bee0-0d89b40211de	5040313c-9900-4630-93f9-1f0e119412dd	USER_STATUS_UPDATED	user	323912e5-9c09-4482-8595-d1428cf1c4c0	{"is_active": false, "target_email": "cust_4ff5b2fc@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:13:44.278068+00
370c58ac-dbfc-4cb0-985b-e0526d2b4cc0	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	875aa731-5cb8-4dda-8c8f-30e6c35a22f2	{"reason": "Proposal signed by client", "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:09.486241+00
9dabae98-6558-4df0-8463-d99c5a4c27c0	b4ee41b2-33d5-46a9-b2de-35d6515f5a97	USER_REGISTERED	user	b4ee41b2-33d5-46a9-b2de-35d6515f5a97	{"role": "CUSTOMER", "email": "customer_b1715f05@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:14:26.770563+00
66feff9c-6ac3-4335-815b-55a033479b1e	c79cc6d8-b258-40df-888c-bd338cf6809d	USER_REGISTERED	user	c79cc6d8-b258-40df-888c-bd338cf6809d	{"role": "CUSTOMER", "email": "login_user_670e2dec@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:14:27.171131+00
de78c729-9cd6-44d5-ab73-0584694d59ed	5040313c-9900-4630-93f9-1f0e119412dd	INVOICE_GENERATED	invoice	4655f402-97bb-4f99-8409-66dd3fb31826	{"total_amount": "59000.0000", "invoice_number": "INV-202610-0016", "subscription_id": "d3d2ff47-1496-45ee-bc84-ec7e81aced75"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:11.624711+00
6f8e7db7-f7b4-48e4-b60f-3a8b62b09193	c79cc6d8-b258-40df-888c-bd338cf6809d	AUTH_LOGIN_SUCCESS	auth	c79cc6d8-b258-40df-888c-bd338cf6809d	{"role": "CUSTOMER", "email": "login_user_670e2dec@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:14:27.29852+00
5bee180f-ca3d-478a-8136-6af20382b0c3	1ceff4fa-c65a-4484-90fa-936b33db28a2	USER_REGISTERED	user	1ceff4fa-c65a-4484-90fa-936b33db28a2	{"role": "CUSTOMER", "email": "customer_6dcaefec@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:14:56.170402+00
dacc54fe-40ff-439e-a25f-ba0d8083be49	ef828a90-4f4a-4a4f-8178-3995232f893c	USER_REGISTERED	user	ef828a90-4f4a-4a4f-8178-3995232f893c	{"role": "CUSTOMER", "email": "dup_ffbea23b@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:14:56.309467+00
1c0392f9-4da6-4b76-a15e-798f95886382	cee17693-481d-4828-a0e6-1c42aaa54c5a	USER_REGISTERED	user	cee17693-481d-4828-a0e6-1c42aaa54c5a	{"role": "CUSTOMER", "email": "login_user_e28fd751@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:14:56.40142+00
8b3c5bc6-b573-43b8-ab02-804bfce1231c	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	301ea4cb-eb59-46ff-ad62-95a188d9d00d	{"plan_id": "19f0e22f-9e12-42eb-800e-bb733dc5e7a9", "quantity": 2, "product_id": "20b44ac3-ad76-4788-a710-a08a854f2184", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:13.603269+00
2d84a123-5d20-419b-8d88-576ae9a8470b	cee17693-481d-4828-a0e6-1c42aaa54c5a	AUTH_LOGIN_SUCCESS	auth	cee17693-481d-4828-a0e6-1c42aaa54c5a	{"role": "CUSTOMER", "email": "login_user_e28fd751@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:14:56.535106+00
fc29b09a-eb7f-43e8-875a-3a67bbb2ff28	640afb31-c926-413e-a5f1-0342024aedc3	USER_REGISTERED	user	640afb31-c926-413e-a5f1-0342024aedc3	{"role": "CUSTOMER", "email": "rotation_7f104c3b@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:14:56.600793+00
3de2e13b-8a53-48a0-84f5-3b52379d9296	640afb31-c926-413e-a5f1-0342024aedc3	TOKEN_ROTATED	auth	640afb31-c926-413e-a5f1-0342024aedc3	{"family_id": "3720d32c-aa92-4926-9a6c-c16a79cae3da"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:14:56.669625+00
4066448c-09d1-4efa-9ebc-8b39f522cb44	640afb31-c926-413e-a5f1-0342024aedc3	TOKEN_ROTATED	auth	640afb31-c926-413e-a5f1-0342024aedc3	{"family_id": "3720d32c-aa92-4926-9a6c-c16a79cae3da"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:14:56.705948+00
de064c94-fcd9-47bb-8654-507c150e276d	1f4ef7b6-1866-4f50-9627-2d5340886b2f	USER_REGISTERED	user	1f4ef7b6-1866-4f50-9627-2d5340886b2f	{"role": "CUSTOMER", "email": "reset_286520da@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:14:56.748002+00
9e48f819-61ac-4e31-8f52-2221340ed12a	1f4ef7b6-1866-4f50-9627-2d5340886b2f	PASSWORD_RESET_REQUESTED	auth	1f4ef7b6-1866-4f50-9627-2d5340886b2f	{"email": "reset_286520da@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:14:56.821513+00
09a94eef-e4da-4d97-99fa-90c3502f5f3f	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:14:57.20306+00
a4a5804b-bcaf-4b66-b4bb-30e9fe144060	66d3aecf-e430-45ec-a173-a50b9d8af0ea	USER_REGISTERED	user	66d3aecf-e430-45ec-a173-a50b9d8af0ea	{"role": "CUSTOMER", "email": "cust_1da30322@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:14:57.271035+00
51fd0259-2507-47da-af1b-0aac37bd7a98	5040313c-9900-4630-93f9-1f0e119412dd	STAFF_CREATED	user	5aa3d456-9f57-44bb-b5f4-a6bc74747829	{"role": "STAFF", "created_email": "staff_87dc5697@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:14:57.391976+00
23608cb5-9e9f-4f76-b0f5-58a9b33ac608	5aa3d456-9f57-44bb-b5f4-a6bc74747829	AUTH_LOGIN_SUCCESS	auth	5aa3d456-9f57-44bb-b5f4-a6bc74747829	{"role": "STAFF", "email": "staff_87dc5697@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:14:57.45351+00
56fd43e3-9bdc-42a1-a881-6c2b92dfb28d	5040313c-9900-4630-93f9-1f0e119412dd	USER_STATUS_UPDATED	user	66d3aecf-e430-45ec-a173-a50b9d8af0ea	{"is_active": false, "target_email": "cust_1da30322@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:14:57.55105+00
d98ed235-3b98-4acb-ad7b-9c2b3089c486	8f41d28e-a0e1-4e20-a55e-4119ca48209a	USER_REGISTERED	user	8f41d28e-a0e1-4e20-a55e-4119ca48209a	{"role": "CUSTOMER", "email": "rotation_6e3d8010@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:05.25356+00
fb3d8584-811d-43a5-af4b-50f1eec153f0	8f41d28e-a0e1-4e20-a55e-4119ca48209a	TOKEN_ROTATED	auth	8f41d28e-a0e1-4e20-a55e-4119ca48209a	{"family_id": "e6490189-9696-4641-a600-501d454da5af"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:05.337603+00
50bcf76b-b453-4ae1-a9f2-180935c286d9	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 07:46:13.571377+00
90b8dc33-d745-4618-b163-62a9fcb03346	8f41d28e-a0e1-4e20-a55e-4119ca48209a	TOKEN_ROTATED	auth	8f41d28e-a0e1-4e20-a55e-4119ca48209a	{"family_id": "e6490189-9696-4641-a600-501d454da5af"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:05.372021+00
bff4b5db-8006-4b6e-b52b-08b2960eb84c	75a26128-3f2e-489a-a766-30ea3e7197db	USER_REGISTERED	user	75a26128-3f2e-489a-a766-30ea3e7197db	{"role": "CUSTOMER", "email": "reset_712ffed8@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:15.254074+00
39b96141-b210-4bc2-9cc3-933d1dec98b8	75a26128-3f2e-489a-a766-30ea3e7197db	PASSWORD_RESET_REQUESTED	auth	75a26128-3f2e-489a-a766-30ea3e7197db	{"email": "reset_712ffed8@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:15.341804+00
2e9ca061-4084-4121-8b13-bf137e99e449	4d322516-9c79-4e12-a8ab-978e9d93b784	USER_REGISTERED	user	4d322516-9c79-4e12-a8ab-978e9d93b784	{"role": "CUSTOMER", "email": "customer_bacd3c24@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:41.059033+00
f00a064d-fc77-4fa0-a120-af4003604279	e01c5123-e863-4c73-addf-fc8ccb55a8a0	USER_REGISTERED	user	e01c5123-e863-4c73-addf-fc8ccb55a8a0	{"role": "CUSTOMER", "email": "dup_8ab07fe6@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:41.192039+00
9ff1297f-317b-461f-a319-2e8557597ff0	8441df5e-d166-45ec-8867-4eaeff3cbb11	USER_REGISTERED	user	8441df5e-d166-45ec-8867-4eaeff3cbb11	{"role": "CUSTOMER", "email": "login_user_ad8f418a@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:41.28279+00
f47ba87a-d109-4968-b5ae-634ae3d7f37a	5040313c-9900-4630-93f9-1f0e119412dd	TOKEN_ROTATED	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"family_id": "b4d1f7e3-fe22-442d-b9ea-c5052b34fd72"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 07:46:15.964458+00
61287350-c174-47c5-ace2-594e3874c685	8441df5e-d166-45ec-8867-4eaeff3cbb11	AUTH_LOGIN_SUCCESS	auth	8441df5e-d166-45ec-8867-4eaeff3cbb11	{"role": "CUSTOMER", "email": "login_user_ad8f418a@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:41.412143+00
fbdd9a3b-7f42-4ed9-b403-8fdc8226ed44	f7e590af-5146-4d2f-bcc9-b032839d70da	USER_REGISTERED	user	f7e590af-5146-4d2f-bcc9-b032839d70da	{"role": "CUSTOMER", "email": "rotation_5305b5f1@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:41.475872+00
196454e3-644f-461d-a2b0-ab53cbe75175	f7e590af-5146-4d2f-bcc9-b032839d70da	TOKEN_ROTATED	auth	f7e590af-5146-4d2f-bcc9-b032839d70da	{"family_id": "6e575e57-772e-4f25-bdf7-ab700fa9fdfc"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:41.54632+00
bc3f272c-50be-42f3-9bf0-3f78f723ae8e	f7e590af-5146-4d2f-bcc9-b032839d70da	TOKEN_REUSE_DETECTED	auth	44ced137-4083-4b7e-aea8-6192306e412f	{"reason": "Attempted reuse of consumed token", "family_id": "6e575e57-772e-4f25-bdf7-ab700fa9fdfc"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:41.565145+00
7256b44a-6dae-4b41-862f-27b6f17cbb54	f7e590af-5146-4d2f-bcc9-b032839d70da	TOKEN_REUSE_DETECTED	auth	16de581c-8767-4f97-af9d-13abc677be8b	{"reason": "Attempted reuse of consumed token", "family_id": "6e575e57-772e-4f25-bdf7-ab700fa9fdfc"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:41.581879+00
0fb28541-0234-4d80-86c0-8698f34470b7	f1606ee3-6693-4e3a-9e7a-9fc18d00a065	USER_REGISTERED	user	f1606ee3-6693-4e3a-9e7a-9fc18d00a065	{"role": "CUSTOMER", "email": "reset_4f6413b7@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:41.603106+00
d2677afa-c301-41ca-becc-1bce91fe9818	f1606ee3-6693-4e3a-9e7a-9fc18d00a065	PASSWORD_RESET_REQUESTED	auth	f1606ee3-6693-4e3a-9e7a-9fc18d00a065	{"email": "reset_4f6413b7@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:41.704663+00
de27c1a9-57cd-404d-ad10-02cee4a79041	f1606ee3-6693-4e3a-9e7a-9fc18d00a065	PASSWORD_RESET_COMPLETED	auth	f1606ee3-6693-4e3a-9e7a-9fc18d00a065	{"email": "reset_4f6413b7@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:41.748475+00
dcf1bb1d-531c-4551-9352-829e9e75c18c	f8153125-3c20-42d4-ad8f-09c161b7bb5d	TOKEN_REUSE_DETECTED	auth	8925a8d5-67a1-43fd-90e7-d7b4f170037a	{"reason": "Attempted reuse of consumed token", "family_id": "c8310cba-720d-42be-96de-aab6b79ddf7b"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:07.409603+00
5871be16-6ae5-4084-9644-8020d7d6d123	f1606ee3-6693-4e3a-9e7a-9fc18d00a065	AUTH_LOGIN_SUCCESS	auth	f1606ee3-6693-4e3a-9e7a-9fc18d00a065	{"role": "CUSTOMER", "email": "reset_4f6413b7@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:41.870933+00
4c93ca84-f42e-424a-95d5-0809ec40442c	5bc72d2e-c41b-4937-99d4-3830e341b00b	USER_REGISTERED	user	5bc72d2e-c41b-4937-99d4-3830e341b00b	{"role": "CUSTOMER", "email": "customer_ff3e3775@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:47.7414+00
633c7420-715f-43b1-918d-0f5140f7b72b	4be22406-b9c4-417e-bfb6-89fe16aa6a6f	USER_REGISTERED	user	4be22406-b9c4-417e-bfb6-89fe16aa6a6f	{"role": "CUSTOMER", "email": "dup_3629ad10@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:47.832315+00
a01d873d-ff18-49e9-9f58-76a3ddccd909	da3d6346-7764-44d5-9245-80549c1b2757	USER_REGISTERED	user	da3d6346-7764-44d5-9245-80549c1b2757	{"role": "CUSTOMER", "email": "login_user_59673ca7@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:47.923767+00
53618c27-a212-4e07-864a-7abcc3014f56	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	CUSTOMER_CREATED	customer	8f7b1967-edec-430c-a7a9-a4043dcb3de4	{"email": "enterprise_2f6bd5@brightloop.io", "user_id": "5298e1ce-ccb5-43ae-8827-e4f1b219d6f6", "customer_number": "CUST-2026-0050"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:09.709897+00
61a97564-3559-4723-a50c-78a354c17691	da3d6346-7764-44d5-9245-80549c1b2757	AUTH_LOGIN_SUCCESS	auth	da3d6346-7764-44d5-9245-80549c1b2757	{"role": "CUSTOMER", "email": "login_user_59673ca7@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:48.061784+00
b0450592-9f05-4a9c-96e6-048d929805b3	508d414f-cd5b-47f4-85e9-59ee42f1b800	USER_REGISTERED	user	508d414f-cd5b-47f4-85e9-59ee42f1b800	{"role": "CUSTOMER", "email": "rotation_91e80c38@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:48.131822+00
b2995089-6c34-4e22-ab21-fadc4c1cfedc	508d414f-cd5b-47f4-85e9-59ee42f1b800	TOKEN_ROTATED	auth	508d414f-cd5b-47f4-85e9-59ee42f1b800	{"family_id": "4404de9b-8718-4ffd-b692-8515a5455320"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:48.202912+00
0674c928-7176-4f94-972c-8661e7316917	508d414f-cd5b-47f4-85e9-59ee42f1b800	TOKEN_REUSE_DETECTED	auth	b88b6a2e-a4c9-437a-9e60-decc1b879e71	{"reason": "Attempted reuse of consumed token", "family_id": "4404de9b-8718-4ffd-b692-8515a5455320"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:48.224073+00
0f1e98cf-6ba0-4afb-86d8-93d3e04dab06	508d414f-cd5b-47f4-85e9-59ee42f1b800	TOKEN_REUSE_DETECTED	auth	3a721209-c3d6-4f90-a6ea-a7e26f06679e	{"reason": "Attempted reuse of consumed token", "family_id": "4404de9b-8718-4ffd-b692-8515a5455320"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:48.239518+00
6488270b-1c2c-4f8e-9b21-f1d56e737863	aa322c84-c6ac-4251-8e52-4f77ec351b2c	USER_REGISTERED	user	aa322c84-c6ac-4251-8e52-4f77ec351b2c	{"role": "CUSTOMER", "email": "reset_d9151576@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:48.261053+00
cd9d6f99-7b29-45fc-a879-9120b9d975d0	aa322c84-c6ac-4251-8e52-4f77ec351b2c	PASSWORD_RESET_REQUESTED	auth	aa322c84-c6ac-4251-8e52-4f77ec351b2c	{"email": "reset_d9151576@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:48.373362+00
b9d48f29-b03c-415b-91c1-948021e42353	aa322c84-c6ac-4251-8e52-4f77ec351b2c	PASSWORD_RESET_COMPLETED	auth	aa322c84-c6ac-4251-8e52-4f77ec351b2c	{"email": "reset_d9151576@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:48.410133+00
0a9ef1e1-c575-4bc4-a7d8-d0dcbd979d00	aa322c84-c6ac-4251-8e52-4f77ec351b2c	AUTH_LOGIN_SUCCESS	auth	aa322c84-c6ac-4251-8e52-4f77ec351b2c	{"role": "CUSTOMER", "email": "reset_d9151576@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:48.535344+00
901971f2-8574-47a6-bc29-92ad3d59eedf	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:48.760305+00
4963ce38-d920-4ee4-9c1f-67c8b0bc1d9b	7c459673-c3dd-4a31-8aaf-aae44ae3aed2	USER_REGISTERED	user	7c459673-c3dd-4a31-8aaf-aae44ae3aed2	{"role": "CUSTOMER", "email": "cust_25450062@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:48.831257+00
64872baf-ccb3-4959-a0ea-c64243f95625	5040313c-9900-4630-93f9-1f0e119412dd	STAFF_CREATED	user	1b19476e-a38c-4a3c-94a9-44f5d229de92	{"role": "STAFF", "created_email": "staff_e6640988@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:48.948852+00
f63bfe24-454f-440e-93e5-034ea7881cdb	1b19476e-a38c-4a3c-94a9-44f5d229de92	AUTH_LOGIN_SUCCESS	auth	1b19476e-a38c-4a3c-94a9-44f5d229de92	{"role": "STAFF", "email": "staff_e6640988@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:49.01484+00
724268dc-87ec-4c11-aed2-6214b8776c46	5040313c-9900-4630-93f9-1f0e119412dd	USER_STATUS_UPDATED	user	7c459673-c3dd-4a31-8aaf-aae44ae3aed2	{"is_active": false, "target_email": "cust_25450062@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 04:15:49.109561+00
e3a8e0dc-dcb2-4e20-873c-ae6006175f05	5040313c-9900-4630-93f9-1f0e119412dd	TOKEN_REUSE_DETECTED	auth	075de9b1-6319-4c12-87d4-6ceab4000a25	{"reason": "Attempted reuse of consumed token", "family_id": "b4d1f7e3-fe22-442d-b9ea-c5052b34fd72"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 07:46:15.965262+00
12ad41d1-a117-4760-a18f-bbf963987396	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	curl/8.22.0	2026-10-31 04:32:15.282641+00
09cb6179-a960-4124-b407-3cfe3fc782cd	5040313c-9900-4630-93f9-1f0e119412dd	TOKEN_ROTATED	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"family_id": "1568f001-aa97-4636-bc9a-a62a08c76175"}	127.0.0.1	curl/8.22.0	2026-10-31 04:32:35.780076+00
128ac762-61a9-4c40-9890-e7e9eaa06727	f8a76800-1d18-4ecc-8527-7b4f59687fa3	USER_REGISTERED	user	f8a76800-1d18-4ecc-8527-7b4f59687fa3	{"role": "CUSTOMER", "email": "bala@gmail.com"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 04:37:24.58218+00
75a7d92c-357f-4d83-ab99-08ce390a9182	f8a76800-1d18-4ecc-8527-7b4f59687fa3	TOKEN_ROTATED	auth	f8a76800-1d18-4ecc-8527-7b4f59687fa3	{"family_id": "6f5975ac-a49f-415f-b8b1-e689c722f9ae"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 04:58:13.461433+00
8e95303e-04d1-4320-93d1-3dc963d92d8a	f8a76800-1d18-4ecc-8527-7b4f59687fa3	AUTH_LOGOUT	auth	f8a76800-1d18-4ecc-8527-7b4f59687fa3	{}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 04:58:13.492186+00
d520532d-72dd-4330-9772-650e440a8225	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 04:58:24.022952+00
af5adfba-331b-47ac-8afe-ca37b4119671	0ce2e170-1e3e-4de7-a2ac-dc825e758e34	USER_REGISTERED	user	0ce2e170-1e3e-4de7-a2ac-dc825e758e34	{"role": "CUSTOMER", "email": "customer_6ff4119b@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:18.164047+00
ae00d98e-d974-4f34-9cea-5a22d168945f	84826d40-07ee-4610-9be7-a79c044c44b3	USER_REGISTERED	user	84826d40-07ee-4610-9be7-a79c044c44b3	{"role": "CUSTOMER", "email": "dup_897a8d61@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:18.292588+00
abdb8140-30a3-4a69-9ad2-86abd260f094	bb198713-2d29-417d-8ffc-c56958a55829	USER_REGISTERED	user	bb198713-2d29-417d-8ffc-c56958a55829	{"role": "CUSTOMER", "email": "login_user_e2651688@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:18.390833+00
b2839ed8-e0d5-4eb1-a5d6-8bcfa35e113c	ebae68dd-3887-4b84-9db4-99d2fbbdb3a2	USER_REGISTERED	user	ebae68dd-3887-4b84-9db4-99d2fbbdb3a2	{"role": "CUSTOMER", "email": "reset_75d9fc69@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:07.436075+00
d41ce015-b51f-4e24-9863-fc10fcec0793	bb198713-2d29-417d-8ffc-c56958a55829	AUTH_LOGIN_SUCCESS	auth	bb198713-2d29-417d-8ffc-c56958a55829	{"role": "CUSTOMER", "email": "login_user_e2651688@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:18.532099+00
6d56f374-74f8-4633-ac22-43198615cba9	4edfd77a-b6fa-4f69-995e-06e0f4f58770	USER_REGISTERED	user	4edfd77a-b6fa-4f69-995e-06e0f4f58770	{"role": "CUSTOMER", "email": "rotation_7c0bb09c@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:18.599704+00
0f6a16f4-adf1-4785-bd8b-6652ba229354	4edfd77a-b6fa-4f69-995e-06e0f4f58770	TOKEN_ROTATED	auth	4edfd77a-b6fa-4f69-995e-06e0f4f58770	{"family_id": "9c98c892-5e0e-4148-8e4d-981d890407c8"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:18.675844+00
ed7d2048-ca29-4093-abce-a2c15c4311c4	4edfd77a-b6fa-4f69-995e-06e0f4f58770	TOKEN_REUSE_DETECTED	auth	9e7b7de1-6c45-49b6-bf84-a122b63344bb	{"reason": "Attempted reuse of consumed token", "family_id": "9c98c892-5e0e-4148-8e4d-981d890407c8"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:18.694824+00
c6e69856-8ef9-41db-8664-cdf06f2eef04	4edfd77a-b6fa-4f69-995e-06e0f4f58770	TOKEN_REUSE_DETECTED	auth	d3239968-43b9-488b-9d43-811c81eefde6	{"reason": "Attempted reuse of consumed token", "family_id": "9c98c892-5e0e-4148-8e4d-981d890407c8"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:18.710733+00
972953d6-6027-4f13-a9ae-31ab8789bb3c	ea823d6a-8512-4342-8975-0f9a54160a14	USER_REGISTERED	user	ea823d6a-8512-4342-8975-0f9a54160a14	{"role": "CUSTOMER", "email": "reset_35077ca6@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:18.730343+00
86fde903-c72f-41aa-af7f-21771c7a26bd	ea823d6a-8512-4342-8975-0f9a54160a14	PASSWORD_RESET_REQUESTED	auth	ea823d6a-8512-4342-8975-0f9a54160a14	{"email": "reset_35077ca6@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:18.807783+00
5592e3b5-806a-4bcb-af06-2e6e1141a4cc	ea823d6a-8512-4342-8975-0f9a54160a14	PASSWORD_RESET_COMPLETED	auth	ea823d6a-8512-4342-8975-0f9a54160a14	{"email": "reset_35077ca6@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:18.852716+00
1b33b4c8-4be7-45a4-9ca0-5ded6af0069d	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:10.873863+00
bca5a5cc-4cf2-41f6-a542-07b17b117aa8	ea823d6a-8512-4342-8975-0f9a54160a14	AUTH_LOGIN_SUCCESS	auth	ea823d6a-8512-4342-8975-0f9a54160a14	{"role": "CUSTOMER", "email": "reset_35077ca6@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:19.000206+00
d703af14-729b-4acc-b668-38a5292bf4b5	82da7fb7-b8ce-4ee7-884d-200a4b3646df	USER_REGISTERED	user	82da7fb7-b8ce-4ee7-884d-200a4b3646df	{"role": "CUSTOMER", "email": "multi_reset_958c3508@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:19.104331+00
868a923b-0583-486a-b992-f3656ba2c00f	82da7fb7-b8ce-4ee7-884d-200a4b3646df	PASSWORD_RESET_REQUESTED	auth	82da7fb7-b8ce-4ee7-884d-200a4b3646df	{"email": "multi_reset_958c3508@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:19.192861+00
71f9a739-74a3-49d6-bdee-4b8a94370f25	82da7fb7-b8ce-4ee7-884d-200a4b3646df	PASSWORD_RESET_REQUESTED	auth	82da7fb7-b8ce-4ee7-884d-200a4b3646df	{"email": "multi_reset_958c3508@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:19.24435+00
413b9c28-5219-44ad-937e-55f27d491eb7	bb612e5e-1fe9-4976-a447-d79a6b87f11e	USER_REGISTERED	user	bb612e5e-1fe9-4976-a447-d79a6b87f11e	{"role": "CUSTOMER", "email": "logout_no_jwt_73289972@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:19.450956+00
fa20498a-f640-423b-b3a9-8b60cb0441c6	bb612e5e-1fe9-4976-a447-d79a6b87f11e	TOKEN_REUSE_DETECTED	auth	d9c4a4e4-20a2-46d8-8d44-9085d35e8a04	{"reason": "Attempted reuse of consumed token", "family_id": "b6771679-1ad7-4ccd-9fc6-9646eade32e4"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:19.539811+00
11d53df8-39a7-41ff-932c-137ffd565ae1	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:19.711797+00
baa8b06b-c137-4883-b50f-6d81f29a60d6	850ca8b4-8d10-4ecd-b372-def1c1923a17	USER_REGISTERED	user	850ca8b4-8d10-4ecd-b372-def1c1923a17	{"role": "CUSTOMER", "email": "cust1_99d88c2d@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:19.782912+00
e1c3430b-3824-42ec-9403-b91685960951	0422c9f3-3ebe-4ab1-a2c2-1cae4aa66b82	USER_REGISTERED	user	0422c9f3-3ebe-4ab1-a2c2-1cae4aa66b82	{"role": "CUSTOMER", "email": "cust2_a9b085bf@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:19.860308+00
58ef7593-ea11-41a1-be46-812a7342ae8d	5040313c-9900-4630-93f9-1f0e119412dd	STAFF_CREATED	user	e88974b4-122b-41f8-8b21-15e3247977af	{"role": "STAFF", "created_email": "staff_d3fd83b0@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:19.998672+00
4b94458e-eab0-4f9d-89b1-35341c063d94	e88974b4-122b-41f8-8b21-15e3247977af	AUTH_LOGIN_SUCCESS	auth	e88974b4-122b-41f8-8b21-15e3247977af	{"role": "STAFF", "email": "staff_d3fd83b0@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:20.066916+00
c66219ea-d73a-4169-8841-5543afdb2fce	5040313c-9900-4630-93f9-1f0e119412dd	USER_STATUS_UPDATED	user	850ca8b4-8d10-4ecd-b372-def1c1923a17	{"is_active": false, "target_email": "cust1_99d88c2d@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:20.221213+00
01ac336c-7e2a-4dbf-abea-100b99c0283f	418eabf0-b1e9-4819-8d36-01633b5e2b34	USER_REGISTERED	user	418eabf0-b1e9-4819-8d36-01633b5e2b34	{"role": "CUSTOMER", "email": "customer_d28c2688@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:50.56917+00
1e563193-87f3-4aea-bfe1-c747aec7e7de	b90cf5af-bb7b-404a-ab1c-76e7ce6fce3c	USER_REGISTERED	user	b90cf5af-bb7b-404a-ab1c-76e7ce6fce3c	{"role": "CUSTOMER", "email": "dup_49d0cfa5@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:50.662995+00
db4e78de-b020-4852-b6f3-109ba08a8f09	6e771bcb-2e4c-4d0f-8bc9-dcf52646d9ac	USER_REGISTERED	user	6e771bcb-2e4c-4d0f-8bc9-dcf52646d9ac	{"role": "CUSTOMER", "email": "login_user_744fa4eb@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:50.761766+00
dad10372-1ec4-400a-b35b-9752957be91a	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 07:47:24.572881+00
771042d3-3251-44e2-a359-ba66358ed104	6e771bcb-2e4c-4d0f-8bc9-dcf52646d9ac	AUTH_LOGIN_SUCCESS	auth	6e771bcb-2e4c-4d0f-8bc9-dcf52646d9ac	{"role": "CUSTOMER", "email": "login_user_744fa4eb@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:50.902857+00
ba3454bc-710d-4cb1-a231-1108991c65ce	493d5223-982d-420a-b75f-03b1ff60757b	USER_REGISTERED	user	493d5223-982d-420a-b75f-03b1ff60757b	{"role": "CUSTOMER", "email": "rotation_e1995080@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:50.980356+00
433c4e29-d88d-4db0-85e4-fafdfc553caa	493d5223-982d-420a-b75f-03b1ff60757b	TOKEN_ROTATED	auth	493d5223-982d-420a-b75f-03b1ff60757b	{"family_id": "eb361a0b-5ed2-47f9-8779-a76024fe6ebe"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:51.055026+00
be918c2d-0511-4297-b3db-ca1ac4e09f3f	493d5223-982d-420a-b75f-03b1ff60757b	TOKEN_REUSE_DETECTED	auth	85dd8858-1003-4937-9b15-d70d8dab266b	{"reason": "Attempted reuse of consumed token", "family_id": "eb361a0b-5ed2-47f9-8779-a76024fe6ebe"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:51.074209+00
f6a8a1a1-966f-4533-8cb6-eb5f6aa61ace	493d5223-982d-420a-b75f-03b1ff60757b	TOKEN_REUSE_DETECTED	auth	dc8e186a-b007-400d-a913-f484f8dbe9d5	{"reason": "Attempted reuse of consumed token", "family_id": "eb361a0b-5ed2-47f9-8779-a76024fe6ebe"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:51.089782+00
108d3826-5fbd-443e-972e-d635b4466d1f	8336509a-cf9b-4a96-a0b6-7bc3890a3f63	USER_REGISTERED	user	8336509a-cf9b-4a96-a0b6-7bc3890a3f63	{"role": "CUSTOMER", "email": "reset_eb58bd19@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:51.110789+00
671c54ba-70df-4297-89c3-56ef4be23ad9	8336509a-cf9b-4a96-a0b6-7bc3890a3f63	PASSWORD_RESET_REQUESTED	auth	8336509a-cf9b-4a96-a0b6-7bc3890a3f63	{"email": "reset_eb58bd19@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:51.184823+00
41f50cc6-7143-4c05-a75d-0e28f71a07cb	8336509a-cf9b-4a96-a0b6-7bc3890a3f63	PASSWORD_RESET_COMPLETED	auth	8336509a-cf9b-4a96-a0b6-7bc3890a3f63	{"email": "reset_eb58bd19@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:51.230311+00
08596622-ddd6-4c2f-b1be-969474c731bd	ebae68dd-3887-4b84-9db4-99d2fbbdb3a2	PASSWORD_RESET_REQUESTED	auth	ebae68dd-3887-4b84-9db4-99d2fbbdb3a2	{"email": "reset_75d9fc69@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:07.523773+00
d4f1bacf-ff7a-412b-877e-6ddc59da5aff	8336509a-cf9b-4a96-a0b6-7bc3890a3f63	AUTH_LOGIN_SUCCESS	auth	8336509a-cf9b-4a96-a0b6-7bc3890a3f63	{"role": "CUSTOMER", "email": "reset_eb58bd19@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:51.361816+00
ab144c0e-28f5-47c7-8e1f-eb99494a4023	d9538ec8-6c00-4ca4-bcf6-813e57938761	USER_REGISTERED	user	d9538ec8-6c00-4ca4-bcf6-813e57938761	{"role": "CUSTOMER", "email": "multi_reset_be0ee2da@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:51.449134+00
6ef50cc8-6b08-47a3-a6e1-1fa9dfabef4f	d9538ec8-6c00-4ca4-bcf6-813e57938761	PASSWORD_RESET_REQUESTED	auth	d9538ec8-6c00-4ca4-bcf6-813e57938761	{"email": "multi_reset_be0ee2da@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:51.52769+00
dcd6a23a-3760-4b0d-9785-d9521ec337b5	d9538ec8-6c00-4ca4-bcf6-813e57938761	PASSWORD_RESET_REQUESTED	auth	d9538ec8-6c00-4ca4-bcf6-813e57938761	{"email": "multi_reset_be0ee2da@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:51.564014+00
b47df5e4-7e9a-4a39-afb1-9de6fb8e5fb7	fb7dfeed-8809-4af1-b766-eeb8358e487a	USER_REGISTERED	user	fb7dfeed-8809-4af1-b766-eeb8358e487a	{"role": "CUSTOMER", "email": "logout_no_jwt_c5a249af@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:51.614475+00
6d93f863-dfd5-48a4-a057-1146c903e902	fb7dfeed-8809-4af1-b766-eeb8358e487a	TOKEN_REUSE_DETECTED	auth	97d6d9bb-7bde-403e-9f9f-c2f2c84dba21	{"reason": "Attempted reuse of consumed token", "family_id": "a1734442-d309-4825-badd-9493cdeef9eb"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:51.703129+00
910394f2-196e-4d47-bf19-00c1c250bb87	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:51.87456+00
8bd91028-90a9-49d6-8811-220410f7466c	73aa11e6-38c1-4540-8082-fb20b88fb3ef	USER_REGISTERED	user	73aa11e6-38c1-4540-8082-fb20b88fb3ef	{"role": "CUSTOMER", "email": "cust1_eb8c8416@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:51.946416+00
8869e85b-0619-4eaa-8ab9-4da0f1f5bf5e	bb2b4c98-c7eb-4c8d-a57e-4712599f3c60	USER_REGISTERED	user	bb2b4c98-c7eb-4c8d-a57e-4712599f3c60	{"role": "CUSTOMER", "email": "cust2_972b6d50@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:52.017647+00
1d2cfa7f-df2a-4902-82fa-24b31ebd83a0	5040313c-9900-4630-93f9-1f0e119412dd	STAFF_CREATED	user	d98e5248-96d2-4067-a0dd-aa3f7d8d6187	{"role": "STAFF", "created_email": "staff_d6d0a59b@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:52.163887+00
c06376eb-f70a-42db-9dca-97b07d78c2fc	d98e5248-96d2-4067-a0dd-aa3f7d8d6187	AUTH_LOGIN_SUCCESS	auth	d98e5248-96d2-4067-a0dd-aa3f7d8d6187	{"role": "STAFF", "email": "staff_d6d0a59b@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:52.232498+00
0f9c7b31-8342-4f16-8fe3-e0038e21765f	5040313c-9900-4630-93f9-1f0e119412dd	USER_STATUS_UPDATED	user	73aa11e6-38c1-4540-8082-fb20b88fb3ef	{"is_active": false, "target_email": "cust1_eb8c8416@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:11:52.383536+00
6d176c95-35da-4ed5-a3a4-b9a64ab3e7ab	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	bca5e35f-ed0e-4e3c-a57f-eb24c360a6fb	{"email": "audit_corp_8ebd0b@demo.com", "user_id": "f74ba7a3-179b-484c-ac47-f96d0e199cdb", "customer_number": "CUST-2026-0051"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:11.075402+00
069b2b00-3549-45ca-9fe7-c554f501e48a	58a3d472-5559-4c23-8bb0-42ddd385362b	USER_REGISTERED	user	58a3d472-5559-4c23-8bb0-42ddd385362b	{"role": "CUSTOMER", "email": "customer_c39659ae@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:12:56.158651+00
b3d53a0e-cdaa-4195-b9a9-5141e5d78d99	26fe5070-9272-4fa1-a1ff-afe0a7cc4df4	USER_REGISTERED	user	26fe5070-9272-4fa1-a1ff-afe0a7cc4df4	{"role": "CUSTOMER", "email": "dup_110abcfe@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:12:56.254212+00
e8ccfe9a-30f7-46b5-9d07-762e336be68f	e0d35775-e51a-4eb1-aef9-e87b0f8ddb5b	USER_REGISTERED	user	e0d35775-e51a-4eb1-aef9-e87b0f8ddb5b	{"role": "CUSTOMER", "email": "login_user_7dc552a3@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:12:56.350348+00
a46070d2-37f5-4caa-9f3d-3daf7bd03a3f	e0d35775-e51a-4eb1-aef9-e87b0f8ddb5b	AUTH_LOGIN_SUCCESS	auth	e0d35775-e51a-4eb1-aef9-e87b0f8ddb5b	{"role": "CUSTOMER", "email": "login_user_7dc552a3@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:12:56.480238+00
67ce5052-c7e2-476e-af12-f5436ede99cd	cc84eb5e-99b4-4870-8de1-0b4289ec8987	USER_REGISTERED	user	cc84eb5e-99b4-4870-8de1-0b4289ec8987	{"role": "CUSTOMER", "email": "rotation_d01f06af@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:12:56.547239+00
c6edeaee-21e5-4317-82ff-a9a3ad669ef8	cc84eb5e-99b4-4870-8de1-0b4289ec8987	TOKEN_ROTATED	auth	cc84eb5e-99b4-4870-8de1-0b4289ec8987	{"family_id": "d08af015-dd92-4439-90be-946804f19586"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:12:56.626568+00
2f05df5f-1207-4407-997e-8d0563698d85	cc84eb5e-99b4-4870-8de1-0b4289ec8987	TOKEN_REUSE_DETECTED	auth	78a58f9c-1e0e-4749-ab9a-d91fa6c4198e	{"reason": "Attempted reuse of consumed token", "family_id": "d08af015-dd92-4439-90be-946804f19586"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:12:56.686083+00
4204f9d0-7463-4efb-8c67-9d5670303c7e	cc84eb5e-99b4-4870-8de1-0b4289ec8987	TOKEN_REUSE_DETECTED	auth	0416c60f-ddbe-4189-90d4-4edd742f0754	{"reason": "Attempted reuse of consumed token", "family_id": "d08af015-dd92-4439-90be-946804f19586"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:12:56.702244+00
4dcd14ce-7f99-4f04-8eea-c7175e97afe3	d119b3bf-3c56-42b9-98f5-79275414ee22	USER_REGISTERED	user	d119b3bf-3c56-42b9-98f5-79275414ee22	{"role": "CUSTOMER", "email": "reset_ebeeecd0@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:12:56.722808+00
2b9c5e3f-5d0f-43b8-90cd-91b77b463fbc	d119b3bf-3c56-42b9-98f5-79275414ee22	PASSWORD_RESET_REQUESTED	auth	d119b3bf-3c56-42b9-98f5-79275414ee22	{"email": "reset_ebeeecd0@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:12:56.831699+00
4a8b1429-631a-4e07-8bb8-3ec1f341b8d7	d119b3bf-3c56-42b9-98f5-79275414ee22	PASSWORD_RESET_COMPLETED	auth	d119b3bf-3c56-42b9-98f5-79275414ee22	{"email": "reset_ebeeecd0@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:12:56.872818+00
2c8ae18c-ba98-4e4d-bc23-fb36d6b1f6af	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 07:49:26.235694+00
3c4e160d-7362-4cc2-b8c9-938a4fe62a34	d119b3bf-3c56-42b9-98f5-79275414ee22	AUTH_LOGIN_SUCCESS	auth	d119b3bf-3c56-42b9-98f5-79275414ee22	{"role": "CUSTOMER", "email": "reset_ebeeecd0@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:12:56.992448+00
a1aa2acb-1947-474e-aab5-4a21c59b5688	12a618c3-a8ef-459e-9c5c-977db2a3608a	USER_REGISTERED	user	12a618c3-a8ef-459e-9c5c-977db2a3608a	{"role": "CUSTOMER", "email": "multi_reset_e96e56c2@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:12:57.071808+00
400292f7-c34d-4f06-aa4d-71073a751a48	12a618c3-a8ef-459e-9c5c-977db2a3608a	PASSWORD_RESET_REQUESTED	auth	12a618c3-a8ef-459e-9c5c-977db2a3608a	{"email": "multi_reset_e96e56c2@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:12:57.14828+00
6701bbdb-a847-44dc-8bbd-7a74f2b3c585	12a618c3-a8ef-459e-9c5c-977db2a3608a	PASSWORD_RESET_REQUESTED	auth	12a618c3-a8ef-459e-9c5c-977db2a3608a	{"email": "multi_reset_e96e56c2@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:12:57.187063+00
6712c82b-76ff-4073-b736-e2d1c46dcb6b	2010d324-f276-46dd-8b17-7c86b2b0332c	USER_REGISTERED	user	2010d324-f276-46dd-8b17-7c86b2b0332c	{"role": "CUSTOMER", "email": "logout_no_jwt_56704ccd@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:12:57.240812+00
2674cd3f-40cd-42e3-b5c3-1021b583782a	2010d324-f276-46dd-8b17-7c86b2b0332c	TOKEN_REUSE_DETECTED	auth	504decbd-87a8-4e7b-aa57-beba7d2841eb	{"reason": "Attempted reuse of consumed token", "family_id": "84984630-2320-4ef5-b490-f0eee82abb13"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:12:57.325402+00
d429e49b-927c-42c1-8de2-1d96737edbae	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:12:57.505074+00
0d1486aa-ac5c-4529-b230-28596c2e49e6	d86b78e7-7242-47ab-bdc9-8983b447ffe8	USER_REGISTERED	user	d86b78e7-7242-47ab-bdc9-8983b447ffe8	{"role": "CUSTOMER", "email": "cust1_30ad72fc@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:12:57.575305+00
205e9cca-1ce1-41bb-a580-5ce09ba4c3a0	4a9bea9a-27b0-4f42-86e3-635c4e82a73d	USER_REGISTERED	user	4a9bea9a-27b0-4f42-86e3-635c4e82a73d	{"role": "CUSTOMER", "email": "cust2_e8475fde@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:12:57.648762+00
7ab5f80c-cc2d-47c1-a170-3e25645a8d53	5040313c-9900-4630-93f9-1f0e119412dd	STAFF_CREATED	user	478c30bc-05ff-499e-9589-44fd39434fef	{"role": "STAFF", "created_email": "staff_0fd5a7cd@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:12:57.781238+00
a9400937-e767-4234-b83e-586a5e7f4f6a	478c30bc-05ff-499e-9589-44fd39434fef	AUTH_LOGIN_SUCCESS	auth	478c30bc-05ff-499e-9589-44fd39434fef	{"role": "STAFF", "email": "staff_0fd5a7cd@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:12:57.847106+00
0eca4124-2cb3-4926-b2dd-aac2f2a9a599	5040313c-9900-4630-93f9-1f0e119412dd	USER_STATUS_UPDATED	user	d86b78e7-7242-47ab-bdc9-8983b447ffe8	{"is_active": false, "target_email": "cust1_30ad72fc@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:12:58.003414+00
29759436-da1c-4907-baf4-e2c92f1339f2	ebae68dd-3887-4b84-9db4-99d2fbbdb3a2	PASSWORD_RESET_COMPLETED	auth	ebae68dd-3887-4b84-9db4-99d2fbbdb3a2	{"email": "reset_75d9fc69@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:07.578562+00
d1f8bd0c-f7fe-4679-bd18-5d56281daa3e	5040313c-9900-4630-93f9-1f0e119412dd	TOKEN_ROTATED	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"family_id": "26e962c3-4fd4-454a-80e8-9e786c52d2ff"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 05:14:32.725912+00
4b553f49-b8c0-4677-8a89-8ea5b82f19b5	5040313c-9900-4630-93f9-1f0e119412dd	TOKEN_ROTATED	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"family_id": "26e962c3-4fd4-454a-80e8-9e786c52d2ff"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 05:14:32.72899+00
e22f5786-859a-4ae6-981d-841c1d7c4cb4	80e3b0af-deac-4692-9dd5-10bbbb4b5858	USER_REGISTERED	user	80e3b0af-deac-4692-9dd5-10bbbb4b5858	{"role": "CUSTOMER", "email": "customer_b9a6810c@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:46:03.767289+00
0dfa50cc-f2a8-4b55-a4f3-167cf21d52eb	c78e4e78-d91c-4b9e-aa5b-8d6502c5d6fa	USER_REGISTERED	user	c78e4e78-d91c-4b9e-aa5b-8d6502c5d6fa	{"role": "CUSTOMER", "email": "dup_f606dcae@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:46:03.915932+00
e9357903-750d-41d1-994b-911db6dd75c3	957ae5b2-8621-43a2-9515-2b43afc0cbd2	USER_REGISTERED	user	957ae5b2-8621-43a2-9515-2b43afc0cbd2	{"role": "CUSTOMER", "email": "login_user_e0e50205@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:46:04.010042+00
537dbf10-58a0-49c5-b968-8d05a00a25d8	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	4bde00c2-5efd-4694-bcd0-41be8b23aedb	{"sku": "AUD-SKU-8EBD0B", "name": "Audit Analytics Suite 8ebd0b", "currency": "INR", "sales_price": "50000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:11.196744+00
8b255a49-7c73-4a03-b098-5bdb119985f0	957ae5b2-8621-43a2-9515-2b43afc0cbd2	AUTH_LOGIN_SUCCESS	auth	957ae5b2-8621-43a2-9515-2b43afc0cbd2	{"role": "CUSTOMER", "email": "login_user_e0e50205@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:46:04.14164+00
7dabbf4a-8de7-43f9-aa54-6abcd38b999e	32183dff-fa8d-462b-8def-bebe75c72f2d	USER_REGISTERED	user	32183dff-fa8d-462b-8def-bebe75c72f2d	{"role": "CUSTOMER", "email": "rotation_8286539c@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:46:04.210173+00
fcbe5519-7fdf-4b42-a23a-2e8f31309fbe	32183dff-fa8d-462b-8def-bebe75c72f2d	TOKEN_ROTATED	auth	32183dff-fa8d-462b-8def-bebe75c72f2d	{"family_id": "c9beb3d3-bb36-4270-9737-d404d4395d0d"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:46:04.279496+00
69c6f804-26cd-45b2-8f62-c5232d10339e	32183dff-fa8d-462b-8def-bebe75c72f2d	TOKEN_REUSE_DETECTED	auth	8d47802a-3374-4223-9992-e1bdda380d7f	{"reason": "Attempted reuse of consumed token", "family_id": "c9beb3d3-bb36-4270-9737-d404d4395d0d"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:46:04.335948+00
7377df0f-1c11-4252-99c5-399787cc377b	32183dff-fa8d-462b-8def-bebe75c72f2d	TOKEN_REUSE_DETECTED	auth	4484ec25-347d-44f0-b782-ddb991e30197	{"reason": "Attempted reuse of consumed token", "family_id": "c9beb3d3-bb36-4270-9737-d404d4395d0d"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:46:04.350631+00
169af212-c72a-4723-aa9f-5ad1787c2fa2	b0ffc2ce-dc12-4fad-b3d6-eca9b62ca5ef	USER_REGISTERED	user	b0ffc2ce-dc12-4fad-b3d6-eca9b62ca5ef	{"role": "CUSTOMER", "email": "reset_58609b88@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:46:04.37052+00
223e77ca-f746-4cdc-b73b-2aaf3edee191	b0ffc2ce-dc12-4fad-b3d6-eca9b62ca5ef	PASSWORD_RESET_REQUESTED	auth	b0ffc2ce-dc12-4fad-b3d6-eca9b62ca5ef	{"email": "reset_58609b88@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:46:04.447609+00
e4e29399-0325-4f1f-bfe8-9a69d2f6aa6b	b0ffc2ce-dc12-4fad-b3d6-eca9b62ca5ef	PASSWORD_RESET_COMPLETED	auth	b0ffc2ce-dc12-4fad-b3d6-eca9b62ca5ef	{"email": "reset_58609b88@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:46:04.505147+00
26043a43-2333-4a67-a065-54c5415d47fa	b0ffc2ce-dc12-4fad-b3d6-eca9b62ca5ef	AUTH_LOGIN_SUCCESS	auth	b0ffc2ce-dc12-4fad-b3d6-eca9b62ca5ef	{"role": "CUSTOMER", "email": "reset_58609b88@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:46:04.6419+00
5e41fd9f-b5ea-4ed7-8191-dfb4cef0e9d7	dbce35f4-40f9-4a80-bf40-937820427ad4	USER_REGISTERED	user	dbce35f4-40f9-4a80-bf40-937820427ad4	{"role": "CUSTOMER", "email": "multi_reset_34068c2b@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:46:04.732703+00
a2149b0b-0a67-4b15-b03a-056b001919f8	dbce35f4-40f9-4a80-bf40-937820427ad4	PASSWORD_RESET_REQUESTED	auth	dbce35f4-40f9-4a80-bf40-937820427ad4	{"email": "multi_reset_34068c2b@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:46:04.814017+00
7a449562-4469-400d-9787-fed419f647a6	dbce35f4-40f9-4a80-bf40-937820427ad4	PASSWORD_RESET_REQUESTED	auth	dbce35f4-40f9-4a80-bf40-937820427ad4	{"email": "multi_reset_34068c2b@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:46:04.856382+00
83abcd04-e7ec-4c06-99b6-c08e74d94813	14f8e0f5-981e-458c-977d-9ebcdbfad1cd	USER_REGISTERED	user	14f8e0f5-981e-458c-977d-9ebcdbfad1cd	{"role": "CUSTOMER", "email": "logout_no_jwt_a6410786@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:46:04.910883+00
01343851-533e-48c6-b90c-6053a5d77180	14f8e0f5-981e-458c-977d-9ebcdbfad1cd	TOKEN_REUSE_DETECTED	auth	a80c411e-a345-4406-a781-59af58397e92	{"reason": "Attempted reuse of consumed token", "family_id": "42cbbc98-a8a5-4297-8573-bbcbc286430e"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:46:05.005095+00
d7765d19-1fbd-4387-bd19-c7e70dc70c9f	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:46:05.178996+00
a4e902a3-c1e8-4436-9ce0-a8d0fbc59141	8ac7ab9e-54b9-4cd2-b2a8-332bcef9c7c3	USER_REGISTERED	user	8ac7ab9e-54b9-4cd2-b2a8-332bcef9c7c3	{"role": "CUSTOMER", "email": "cust1_ee070961@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:46:05.249438+00
73cd3ee5-5336-4b86-aafe-a6abd66d4e6f	26fa02bf-d700-49fb-9933-597991093516	USER_REGISTERED	user	26fa02bf-d700-49fb-9933-597991093516	{"role": "CUSTOMER", "email": "cust2_1328f058@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:46:05.326966+00
8298a196-c518-4d92-af0e-bdac3ffea485	5040313c-9900-4630-93f9-1f0e119412dd	STAFF_CREATED	user	229153d3-a459-4880-8cb2-2215fe1f792f	{"role": "STAFF", "created_email": "staff_a3dfde5e@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:46:05.47229+00
56b7a7a0-7f8e-48e7-968f-129e3875e8bf	229153d3-a459-4880-8cb2-2215fe1f792f	AUTH_LOGIN_SUCCESS	auth	229153d3-a459-4880-8cb2-2215fe1f792f	{"role": "STAFF", "email": "staff_a3dfde5e@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:46:05.542589+00
d81ba79f-5260-4bee-b468-5c68190d60c8	5040313c-9900-4630-93f9-1f0e119412dd	USER_STATUS_UPDATED	user	8ac7ab9e-54b9-4cd2-b2a8-332bcef9c7c3	{"is_active": false, "target_email": "cust1_ee070961@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:46:05.702733+00
f65d04db-d07a-423f-8d7f-69e553a9e5a1	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 07:50:49.140909+00
caaede77-f611-45f4-ab24-8b05d4b9a217	b2370d12-52df-42d4-b383-0f2c4061c9d9	USER_REGISTERED	user	b2370d12-52df-42d4-b383-0f2c4061c9d9	{"role": "CUSTOMER", "email": "customer_a645fedd@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:52:55.175523+00
75b0d97e-849d-4d1a-a0ea-6df2c799cf25	8b079a79-938b-4e39-8d8c-955005e0f0fb	USER_REGISTERED	user	8b079a79-938b-4e39-8d8c-955005e0f0fb	{"role": "CUSTOMER", "email": "dup_4745a18e@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:52:55.277896+00
ce111f27-eeee-4f60-8a83-4a69c00444cf	6113e0cc-f1e8-4330-acc4-4e4d35544e2d	USER_REGISTERED	user	6113e0cc-f1e8-4330-acc4-4e4d35544e2d	{"role": "CUSTOMER", "email": "login_user_e982a35c@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:52:55.377852+00
94198231-560e-411a-9b4a-cc9277a540e0	6113e0cc-f1e8-4330-acc4-4e4d35544e2d	AUTH_LOGIN_SUCCESS	auth	6113e0cc-f1e8-4330-acc4-4e4d35544e2d	{"role": "CUSTOMER", "email": "login_user_e982a35c@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:52:55.527917+00
d6d2fa33-7515-488f-85dc-ff6c16af1138	55f4d195-e9fb-48b4-9902-ea14e0eb9aa4	USER_REGISTERED	user	55f4d195-e9fb-48b4-9902-ea14e0eb9aa4	{"role": "CUSTOMER", "email": "rotation_9650da71@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:52:55.619036+00
fd63d4d2-2138-4820-bc48-81c8b3aebc9b	55f4d195-e9fb-48b4-9902-ea14e0eb9aa4	TOKEN_ROTATED	auth	55f4d195-e9fb-48b4-9902-ea14e0eb9aa4	{"family_id": "36c7fb59-2fc2-4680-a65b-a0def53f653e"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:52:55.701146+00
ee1f487f-bbd8-4649-bceb-73df476c886e	55f4d195-e9fb-48b4-9902-ea14e0eb9aa4	TOKEN_REUSE_DETECTED	auth	9d2f0ae7-2487-4e4b-81e2-2bcd32eadd60	{"reason": "Attempted reuse of consumed token", "family_id": "36c7fb59-2fc2-4680-a65b-a0def53f653e"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:52:55.725723+00
deaf76a1-b6c0-4c43-b16f-4b0034a2c650	55f4d195-e9fb-48b4-9902-ea14e0eb9aa4	TOKEN_REUSE_DETECTED	auth	bdad12f6-6e5b-4e54-8c21-a2357d8d3494	{"reason": "Attempted reuse of consumed token", "family_id": "36c7fb59-2fc2-4680-a65b-a0def53f653e"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:52:55.744963+00
57996228-babc-405c-b0a6-fec687796cbc	5e5e63e5-354e-42be-9956-4f3237c85440	USER_REGISTERED	user	5e5e63e5-354e-42be-9956-4f3237c85440	{"role": "CUSTOMER", "email": "reset_54fd6b2c@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:52:55.765881+00
4c3d78df-f8ba-44c7-a145-6c7d8a26f22c	5e5e63e5-354e-42be-9956-4f3237c85440	PASSWORD_RESET_REQUESTED	auth	5e5e63e5-354e-42be-9956-4f3237c85440	{"email": "reset_54fd6b2c@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:52:55.846184+00
13b33aa6-4820-4008-a35d-a61e282913da	5e5e63e5-354e-42be-9956-4f3237c85440	PASSWORD_RESET_COMPLETED	auth	5e5e63e5-354e-42be-9956-4f3237c85440	{"email": "reset_54fd6b2c@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:52:55.890849+00
d5381906-004c-4dd0-a504-4c7c8b02ef1d	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	3737c0df-0bb6-4dee-a209-5b1b1c4d31b9	{"code": "PLAN-AUD-8EBD0B", "name": "Audit Pro Plan 8ebd0b", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:11.233467+00
378828fa-75d1-400c-a8fe-94a4fee34130	5e5e63e5-354e-42be-9956-4f3237c85440	AUTH_LOGIN_SUCCESS	auth	5e5e63e5-354e-42be-9956-4f3237c85440	{"role": "CUSTOMER", "email": "reset_54fd6b2c@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:52:56.026793+00
edeaad24-0820-4a50-b68c-03b6e7348eb7	2a7a573c-ee88-475c-8c7e-776a32e72b4d	USER_REGISTERED	user	2a7a573c-ee88-475c-8c7e-776a32e72b4d	{"role": "CUSTOMER", "email": "multi_reset_f266ec52@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:52:56.11085+00
ea00d880-bb20-4ca5-b0a2-400a9906fe8d	2a7a573c-ee88-475c-8c7e-776a32e72b4d	PASSWORD_RESET_REQUESTED	auth	2a7a573c-ee88-475c-8c7e-776a32e72b4d	{"email": "multi_reset_f266ec52@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:52:56.182721+00
9ba0b845-42a3-4fd7-8f76-d0b7ad63dde6	2a7a573c-ee88-475c-8c7e-776a32e72b4d	PASSWORD_RESET_REQUESTED	auth	2a7a573c-ee88-475c-8c7e-776a32e72b4d	{"email": "multi_reset_f266ec52@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:52:56.222978+00
70ede20a-f163-453d-8cff-e7dde1021861	2a114299-eb44-4513-8e2a-b9be6095f425	USER_REGISTERED	user	2a114299-eb44-4513-8e2a-b9be6095f425	{"role": "CUSTOMER", "email": "logout_no_jwt_e520c1de@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:52:56.275101+00
2247c7f8-2429-4fe8-822d-8eef3aa7d8be	2a114299-eb44-4513-8e2a-b9be6095f425	TOKEN_REUSE_DETECTED	auth	400867c3-8946-493e-9681-92f363ec4a4a	{"reason": "Attempted reuse of consumed token", "family_id": "16627cc3-f9d0-4582-94de-9674bb8ed38c"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:52:56.370527+00
b85922ae-5f8c-4429-ab79-263caff6fbd2	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:52:56.534255+00
00905b06-4084-4639-9b8b-49726f60cf06	d226394d-e959-42a2-8fc6-70a387db8078	USER_REGISTERED	user	d226394d-e959-42a2-8fc6-70a387db8078	{"role": "CUSTOMER", "email": "cust1_84368aeb@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:52:56.604813+00
0320bef1-5c60-4bdf-9488-71909ea30866	196da70a-1ea1-48ba-bb07-bff22caa8a5b	USER_REGISTERED	user	196da70a-1ea1-48ba-bb07-bff22caa8a5b	{"role": "CUSTOMER", "email": "cust2_ffb3116a@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:52:56.683387+00
568e746d-981a-4dde-9e39-7c3e37273998	5040313c-9900-4630-93f9-1f0e119412dd	STAFF_CREATED	user	94505853-0e43-42d8-9b0b-d84ca7865932	{"role": "STAFF", "created_email": "staff_f280c9c3@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:52:56.83058+00
e8e8d346-be38-4cab-b17a-f56492decc4c	94505853-0e43-42d8-9b0b-d84ca7865932	AUTH_LOGIN_SUCCESS	auth	94505853-0e43-42d8-9b0b-d84ca7865932	{"role": "STAFF", "email": "staff_f280c9c3@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:52:56.898206+00
1fd38cb4-3423-4cf3-8a6d-7c3f01ab3406	5040313c-9900-4630-93f9-1f0e119412dd	USER_STATUS_UPDATED	user	d226394d-e959-42a2-8fc6-70a387db8078	{"is_active": false, "target_email": "cust1_84368aeb@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:52:57.060594+00
c7c39ba8-9b39-4d12-9e11-f0272a295a4a	554c7280-7d85-47dd-8078-fc3476659719	USER_REGISTERED	user	554c7280-7d85-47dd-8078-fc3476659719	{"role": "CUSTOMER", "email": "customer_1ee5dc71@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:24.960117+00
17546506-40d0-43c1-9923-4e5a385ffd7d	63ef12fb-5488-4e39-baa2-4c876441802c	USER_REGISTERED	user	63ef12fb-5488-4e39-baa2-4c876441802c	{"role": "CUSTOMER", "email": "dup_3f4cf89a@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:25.101046+00
4ca1fb1d-715f-4cad-acdf-2d32f5c69f07	e7b763d5-0438-4f7b-8241-e50c55546570	USER_REGISTERED	user	e7b763d5-0438-4f7b-8241-e50c55546570	{"role": "CUSTOMER", "email": "login_user_cbfe3236@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:25.249862+00
47cd78e3-837a-488b-8fa0-ec6ce5b8319f	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 07:52:25.838259+00
e707b75f-a34e-4906-999f-85f8d2b42676	e7b763d5-0438-4f7b-8241-e50c55546570	AUTH_LOGIN_SUCCESS	auth	e7b763d5-0438-4f7b-8241-e50c55546570	{"role": "CUSTOMER", "email": "login_user_cbfe3236@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:25.431258+00
e2485076-38b5-4324-9696-55a4b8f9d45d	be4ff5c5-16fb-4e4c-9fdb-db6c443464c9	USER_REGISTERED	user	be4ff5c5-16fb-4e4c-9fdb-db6c443464c9	{"role": "CUSTOMER", "email": "rotation_01896082@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:25.51118+00
52591a39-cce7-46c5-9a1f-57215911d580	be4ff5c5-16fb-4e4c-9fdb-db6c443464c9	TOKEN_ROTATED	auth	be4ff5c5-16fb-4e4c-9fdb-db6c443464c9	{"family_id": "3310df78-58c0-4527-a04f-25b1ecbc1e8f"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:25.673861+00
4452e21c-c46d-4d1a-b142-e35d07a5292d	be4ff5c5-16fb-4e4c-9fdb-db6c443464c9	TOKEN_REUSE_DETECTED	auth	5db81516-93cf-4e41-a3f5-a03c21a63c06	{"reason": "Attempted reuse of consumed token", "family_id": "3310df78-58c0-4527-a04f-25b1ecbc1e8f"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:25.69909+00
19ad674c-5c76-4d1b-9fe6-698b83f59f50	be4ff5c5-16fb-4e4c-9fdb-db6c443464c9	TOKEN_REUSE_DETECTED	auth	d1fec6e9-c0ae-41d7-8fe4-402c94036a2d	{"reason": "Attempted reuse of consumed token", "family_id": "3310df78-58c0-4527-a04f-25b1ecbc1e8f"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:25.717255+00
fda86a6d-96cb-4f05-aeaa-19015ec04a05	b144c086-d788-4342-8e6b-3dfee3355527	USER_REGISTERED	user	b144c086-d788-4342-8e6b-3dfee3355527	{"role": "CUSTOMER", "email": "reset_b3ef8251@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:25.742714+00
1a512655-5831-4d9f-9706-c5689351a3c9	b144c086-d788-4342-8e6b-3dfee3355527	PASSWORD_RESET_REQUESTED	auth	b144c086-d788-4342-8e6b-3dfee3355527	{"email": "reset_b3ef8251@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:25.865086+00
f4e2efa3-c0e2-460b-9a0d-cbf9245e7046	b144c086-d788-4342-8e6b-3dfee3355527	PASSWORD_RESET_COMPLETED	auth	b144c086-d788-4342-8e6b-3dfee3355527	{"email": "reset_b3ef8251@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:25.919531+00
947b7ec0-978f-44f5-8e19-441e28a84223	b144c086-d788-4342-8e6b-3dfee3355527	AUTH_LOGIN_SUCCESS	auth	b144c086-d788-4342-8e6b-3dfee3355527	{"role": "CUSTOMER", "email": "reset_b3ef8251@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:26.044475+00
909628a1-562d-4ed5-a52c-07e86d0ad900	156085e9-785e-4e4b-8e1e-b6109bbc1876	USER_REGISTERED	user	156085e9-785e-4e4b-8e1e-b6109bbc1876	{"role": "CUSTOMER", "email": "multi_reset_4e2ff372@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:26.140976+00
779779f5-289b-4883-9da9-d3d550728458	156085e9-785e-4e4b-8e1e-b6109bbc1876	PASSWORD_RESET_REQUESTED	auth	156085e9-785e-4e4b-8e1e-b6109bbc1876	{"email": "multi_reset_4e2ff372@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:26.323619+00
2984c136-f4ba-4d57-900a-48023bbaebcd	156085e9-785e-4e4b-8e1e-b6109bbc1876	PASSWORD_RESET_REQUESTED	auth	156085e9-785e-4e4b-8e1e-b6109bbc1876	{"email": "multi_reset_4e2ff372@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:26.496267+00
f7a00e2f-f640-473f-b218-1d7042c0e2c5	2f082914-d1df-42d4-8237-de9abce8e0bd	USER_REGISTERED	user	2f082914-d1df-42d4-8237-de9abce8e0bd	{"role": "CUSTOMER", "email": "logout_no_jwt_6c05fbe6@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:26.550904+00
b6bf0a0c-fabf-4eb5-84dc-e7a3d85d6edd	2f082914-d1df-42d4-8237-de9abce8e0bd	TOKEN_REUSE_DETECTED	auth	6112e874-40fc-4197-9101-c244b01032b8	{"reason": "Attempted reuse of consumed token", "family_id": "012c6b65-ed2d-4d11-bcdf-8e6e4f597957"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:26.712252+00
27371ff0-23bc-4f9a-a8db-21d2353a1abd	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:26.750013+00
0a68206b-8b28-4829-b096-1de20a447e57	5040313c-9900-4630-93f9-1f0e119412dd	STAFF_CREATED	user	faa7c350-693c-4f32-a946-cf94bb2338b8	{"role": "STAFF", "created_email": "staff_67b452e4@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:26.830226+00
03b8effc-6527-4e57-8f29-d81e762fc21b	faa7c350-693c-4f32-a946-cf94bb2338b8	AUTH_LOGIN_SUCCESS	auth	faa7c350-693c-4f32-a946-cf94bb2338b8	{"role": "STAFF", "email": "staff_67b452e4@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:26.905572+00
a56b8a24-ab3b-49a2-b136-57cc264aaf14	f7dde876-4c5d-41bd-83c7-a550a7f01087	USER_REGISTERED	user	f7dde876-4c5d-41bd-83c7-a550a7f01087	{"role": "CUSTOMER", "email": "cust_3afb0aa8@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:26.980888+00
805c33f6-38f0-4207-b7d5-3efedf9f9197	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:27.267956+00
5780d3bd-1a69-4a6f-b85a-9dc1315ba75a	5040313c-9900-4630-93f9-1f0e119412dd	STAFF_CREATED	user	5c14ac70-d6d0-4bbc-9526-ea6177d39455	{"role": "STAFF", "created_email": "staff_3a46f6c8@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:27.35196+00
dab86c34-fe01-47d2-96ad-6155587cc1d7	5c14ac70-d6d0-4bbc-9526-ea6177d39455	AUTH_LOGIN_SUCCESS	auth	5c14ac70-d6d0-4bbc-9526-ea6177d39455	{"role": "STAFF", "email": "staff_3a46f6c8@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:27.419131+00
acc383aa-508c-4917-80c9-f8acda161230	9baaaaf9-3e73-45d1-83aa-47e512236d5c	USER_REGISTERED	user	9baaaaf9-3e73-45d1-83aa-47e512236d5c	{"role": "CUSTOMER", "email": "cust_f5cad3b7@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:27.490971+00
eb701ca3-caaf-4617-8e02-1e898c1acc1b	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:27.670208+00
0f2be5fa-1d5d-4533-ae8f-34096100f102	5040313c-9900-4630-93f9-1f0e119412dd	STAFF_CREATED	user	9eda81c6-d4ec-4b2e-9ba2-8ff6d92a4479	{"role": "STAFF", "created_email": "staff_fe3bccfa@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:27.733305+00
9a2475a1-ab82-434c-8a29-0a03baf6549d	9eda81c6-d4ec-4b2e-9ba2-8ff6d92a4479	AUTH_LOGIN_SUCCESS	auth	9eda81c6-d4ec-4b2e-9ba2-8ff6d92a4479	{"role": "STAFF", "email": "staff_fe3bccfa@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:27.795282+00
0397686c-7054-40c9-9971-3361da619701	6f23938c-cddc-4a28-8f42-c0cb597748e0	USER_REGISTERED	user	6f23938c-cddc-4a28-8f42-c0cb597748e0	{"role": "CUSTOMER", "email": "cust_3ade737f@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:27.859586+00
e93fc56f-0149-4b0b-8a21-98a76ba1d4fe	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:28.040666+00
721331de-643c-4e21-86b2-2a360f2624be	5040313c-9900-4630-93f9-1f0e119412dd	STAFF_CREATED	user	fbc2d60f-635f-4ccf-bd0b-d5af2b51a2fb	{"role": "STAFF", "created_email": "staff_fb8f1fc9@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:28.109749+00
ef01e499-2038-45b1-bdb4-82715ac3a89e	fbc2d60f-635f-4ccf-bd0b-d5af2b51a2fb	AUTH_LOGIN_SUCCESS	auth	fbc2d60f-635f-4ccf-bd0b-d5af2b51a2fb	{"role": "STAFF", "email": "staff_fb8f1fc9@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:28.179956+00
67084c79-de83-4db7-aa53-f0b9cb5a3b57	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:28.261003+00
45394d3a-8fc8-4069-abdb-b7b2332054c1	5040313c-9900-4630-93f9-1f0e119412dd	STAFF_CREATED	user	270816b6-4630-4347-ae89-93ea0cda1589	{"role": "STAFF", "created_email": "staff_adfb1a40@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:28.332504+00
06582960-5985-49cc-9147-ddad96475cf6	270816b6-4630-4347-ae89-93ea0cda1589	AUTH_LOGIN_SUCCESS	auth	270816b6-4630-4347-ae89-93ea0cda1589	{"role": "STAFF", "email": "staff_adfb1a40@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:28.412225+00
f5a739b4-a44a-4961-8b2e-1aff46303dfa	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:28.488429+00
6f7668c9-6f6b-46a0-998f-3fb328e49041	5040313c-9900-4630-93f9-1f0e119412dd	STAFF_CREATED	user	1acab13b-f7e8-4a35-b7fb-3aa9ab2e2c61	{"role": "STAFF", "created_email": "staff_fe873303@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:28.556004+00
5a237952-fc97-49fd-804b-0e85b42af7ac	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:28.836847+00
469535d1-2175-4d9b-9370-c7b8e60e837e	14f0ac70-8a59-4176-b597-f585bed001fc	USER_REGISTERED	user	14f0ac70-8a59-4176-b597-f585bed001fc	{"role": "CUSTOMER", "email": "cust1_035c523d@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:28.905451+00
dc41c48c-e5a2-43d6-973c-4198cfdc8037	6fdbe691-57bf-4f06-a74e-c36de5cd1ae3	USER_REGISTERED	user	6fdbe691-57bf-4f06-a74e-c36de5cd1ae3	{"role": "CUSTOMER", "email": "cust2_26a1b187@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:29.001919+00
34371c3a-ff66-4417-9a2a-9202c0b788a0	5040313c-9900-4630-93f9-1f0e119412dd	STAFF_CREATED	user	b4d76ced-14b7-45da-a840-51a3352235f9	{"role": "STAFF", "created_email": "staff_f99a162f@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:29.218071+00
4b3126a9-39a8-447f-9d66-2e94fa9afc47	b4d76ced-14b7-45da-a840-51a3352235f9	AUTH_LOGIN_SUCCESS	auth	b4d76ced-14b7-45da-a840-51a3352235f9	{"role": "STAFF", "email": "staff_f99a162f@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:29.293933+00
893e4a5f-5164-4c41-bca8-c63170607ede	5040313c-9900-4630-93f9-1f0e119412dd	USER_STATUS_UPDATED	user	14f0ac70-8a59-4176-b597-f585bed001fc	{"is_active": false, "target_email": "cust1_035c523d@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 05:59:29.485183+00
896d1d23-4fb1-4be4-a44b-f2c59f683329	ebae68dd-3887-4b84-9db4-99d2fbbdb3a2	AUTH_LOGIN_SUCCESS	auth	ebae68dd-3887-4b84-9db4-99d2fbbdb3a2	{"role": "CUSTOMER", "email": "reset_75d9fc69@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:07.732672+00
f725673f-a84e-46f8-8f8c-a1d4321f82f9	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	04f99474-55d2-40d1-9f94-1a6801714aa9	{"sku": "SKU-65297C", "name": "Brightloop ERP Cloud", "currency": "INR", "sales_price": "2000.0000", "variants_count": 2}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:09:09.211336+00
96713937-f71c-446f-9187-74a838c71b09	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	fecd3eea-595f-4f74-9950-501860332150	{"sku": "HIST-507D7C", "name": "History Test Product", "currency": "INR", "sales_price": "1000.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:09:09.457432+00
ea7888db-06cc-42b7-b9c4-1c22a35ffea5	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	2dc487cb-fc10-4132-a1a7-e071ed3741f8	{"plan_id": "3737c0df-0bb6-4dee-a209-5b1b1c4d31b9", "quantity": 1, "product_id": "4bde00c2-5efd-4694-bcd0-41be8b23aedb", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:11.267263+00
7319220a-e10d-4ba2-a93d-40c5a9495131	5040313c-9900-4630-93f9-1f0e119412dd	PAYMENT_RECORDED	payment	811bc1b6-5056-49b3-b39d-15c5c29d7379	{"amount": "20000.0000", "invoice_number": "INV-202610-0016", "payment_number": "PAY-202610-0017", "is_full_payment": false}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:11.756752+00
82328c51-c148-4690-a114-1b03b51e97fd	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	19f0e22f-9e12-42eb-800e-bb733dc5e7a9	{"code": "PLAN-QTY-16E322", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:13.636972+00
9b63dcc8-5370-42e5-b38d-89e663cf84a3	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	63848a77-2df4-4368-8796-c09dac27b6f4	{"code": "OVL-PLAN-B22D76", "name": "Overlap Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:14.264524+00
f2067db2-f8cd-41df-82e6-acaa321e392a	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	7cee942d-916e-4554-97ca-d3f431fcdae6	{"sku": "SKU-0E9912", "name": "Brightloop ERP Cloud", "currency": "INR", "sales_price": "2000.0000", "variants_count": 2}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:11:22.986832+00
d5e35ff9-1c70-4795-85aa-a93dd6f6bc81	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_CREATED	PRODUCT_VARIANT	2c9a051f-9788-4fb4-a69e-cab282aae68c	{"product_id": "7cee942d-916e-4554-97ca-d3f431fcdae6", "variant_code": "ENT", "variant_name": "Enterprise Addon", "adjustment_type": "PERCENTAGE", "adjustment_value": "25.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:11:23.067041+00
04a530e3-f52c-45af-a1bc-d44f54bdbea9	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	8a67e854-290f-4c20-bf43-531932afd4ae	{"sku": "RBAC-9655B5", "name": "Admin Product", "currency": "INR", "sales_price": "500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:11:23.194565+00
55ee3e06-b12e-415d-a0c2-ac222e1861af	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	526f5031-c01b-47e1-9931-12d6f9bcdd29	{"sku": "HIST-61CAE9", "name": "History Test Product", "currency": "INR", "sales_price": "1000.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:11:23.264967+00
845e6ab5-eb56-4196-bf12-926b79b4fb0b	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_UPDATED	PRODUCT	526f5031-c01b-47e1-9931-12d6f9bcdd29	{"sku": "HIST-61CAE9", "name": "History Test Product", "reason": "Annual inflation rate increase", "price_changes": {"cost_price": {"new": "450.0000", "old": "300.0000"}, "sales_price": {"new": "1500.0000", "old": "1000.0000"}}}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:11:23.298861+00
4f6190a7-c0a2-4ff5-b39d-75217c897ad6	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_UPDATED	PRODUCT_VARIANT	14b6b487-3a78-4e2c-868e-ed879361bdc6	{"variant_code": "PRO", "variant_name": "Pro Pack", "adjustment_type": "PERCENTAGE", "adjustment_value": "30.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:11:23.340133+00
13e1de84-5507-46c5-8e85-fe6b4876a8a3	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	36f00791-876c-4b44-be3c-1d4cede92e5b	{"sku": "ARCH-D8B80E", "name": "To Archive Product", "currency": "INR", "sales_price": "750.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:11:23.388354+00
16a4a192-0889-4960-8b18-7ed8b3350b73	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_ARCHIVED	PRODUCT	36f00791-876c-4b44-be3c-1d4cede92e5b	{"sku": "ARCH-D8B80E", "name": "To Archive Product", "deactivated_plan_line_items": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:11:23.422626+00
6388739b-07f2-45b6-a1dd-8abc784405be	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_DEACTIVATED	PRODUCT_VARIANT	f247a797-cd47-4d54-a9bf-6aaee5854c48	{"variant_code": "VA", "variant_name": "Variant A", "deactivated_plan_line_items": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:11:23.468463+00
1ee906ba-26b7-4ec9-aa28-fe185a3087dd	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	6ef0bb02-187d-4513-9122-eaa480de77bf	{"sku": "INR-B8169D", "name": "INR Service", "currency": "INR", "sales_price": "1000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:11:29.778543+00
ad953499-0d8b-4b08-b3e9-282aa138e40c	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	c042ca25-b44c-480c-87c6-c073a654cf9a	{"sku": "USD-9FE080", "name": "USD Service", "currency": "USD", "sales_price": "50.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:11:29.824637+00
77cc6339-9ea1-4a6f-834c-dfb2e4208316	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	e305ebea-d9ab-41f3-8ef1-9223230f0c71	{"code": "PLAN-INR-6BD23A", "name": "Enterprise INR Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:11:29.861466+00
3db7ee6b-fb45-4cd9-90bb-f005e937b166	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	2ac5a489-4d8b-4b58-a126-f9f4bfc54a4a	{"plan_id": "e305ebea-d9ab-41f3-8ef1-9223230f0c71", "quantity": 2, "product_id": "6ef0bb02-187d-4513-9122-eaa480de77bf", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:11:29.928487+00
d8854ceb-cab8-40da-ad3d-ce23c0ac5ed7	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	82427998-6488-45c4-9bc0-6a9582a2a880	{"code": "GUARD-13DAC7", "name": "Empty Draft Plan", "currency": "INR", "billing_interval": "YEARLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:11:29.984149+00
5171bddc-10e2-4e39-9024-dc398b7d727e	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	969a867e-b20a-4c5f-b1b5-f0cfe67a5bb1	{"sku": "BASE-3FD745", "name": "Base Software", "currency": "INR", "sales_price": "3000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:11:30.060245+00
45123282-85e0-405f-b957-236e229398b7	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	2eb221c6-f071-4a0b-bad0-9d8fbe7047f9	{"plan_id": "82427998-6488-45c4-9bc0-6a9582a2a880", "quantity": 1, "product_id": "969a867e-b20a-4c5f-b1b5-f0cfe67a5bb1", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:11:30.12249+00
3b7620d8-b0e2-4979-ab4a-2f02f3ad4734	5040313c-9900-4630-93f9-1f0e119412dd	SETUP_DEFAULT_CATALOGUE	CATALOGUE	\N	{"plans_created": [{"id": "0086d29b-ddd9-4dc5-9ac0-3d74ea38cba4", "code": "BL-CAT-STARTER-M", "name": "Starter Monthly"}, {"id": "d5281260-fa65-4500-aa04-21fb2bfdd3cc", "code": "BL-CAT-STARTER-Y", "name": "Starter Annual"}, {"id": "ceaa5e9c-c99e-4a47-acd6-f7c9a6583c51", "code": "BL-CAT-GROWTH-M", "name": "Growth Monthly"}, {"id": "859f0f9d-a947-453c-83cc-3df6adea52dc", "code": "BL-CAT-GROWTH-Y", "name": "Growth Annual"}, {"id": "48036860-006a-41f3-901a-61f5704256f5", "code": "BL-CAT-BIZ-M", "name": "Business Monthly"}, {"id": "c5ee0288-e16e-4654-8c0d-fac0b0b6fd20", "code": "BL-CAT-BIZ-Y", "name": "Business Annual"}], "products_created": [{"id": "158c96d4-cbb8-49f2-a7d7-4e828fc64d3e", "sku": "BL-PROD-STARTER", "name": "Brightloop Starter Platform"}, {"id": "0a3ccc4b-2420-4f5b-b9df-7aaac0ef8f41", "sku": "BL-PROD-GROWTH", "name": "Brightloop Growth Platform"}, {"id": "b2d1720c-2e2b-4c84-8b21-e1ae51e0809b", "sku": "BL-PROD-BUSINESS", "name": "Brightloop Business Platform"}, {"id": "5cfef298-79f5-4173-83f3-3aace17688da", "sku": "BL-PROD-ADDON-AI", "name": "AI Intelligence Module"}, {"id": "d27b68c7-a92c-4877-a0db-983aaaf1945a", "sku": "BL-PROD-ADDON-SLA", "name": "Premium SLA Support"}, {"id": "f092ee5a-dce2-4417-9bfb-fc5935d8a7b7", "sku": "BL-PROD-ADDON-SEAT", "name": "Additional User Seat"}], "plans_created_count": 6, "products_created_count": 6}	\N	\N	2026-10-31 08:17:09.776641+00
acbdfff4-d61b-4c50-ae85-186720e544f5	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	688622e3-2494-4fde-90d4-78107b647e2e	{"sku": "AC-57D9FF", "name": "Auto Close Product", "currency": "INR", "sales_price": "1500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:11:30.379504+00
7a694973-2659-40bc-b26f-6751dc1a400f	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	306fc9ef-de46-4c3f-9bee-4ed48d306cca	{"code": "AUTO-CA569B", "name": "Limited Time Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:11:30.412308+00
716068fc-f5ee-4239-98c9-d235654ed8d3	234f60f6-3d4d-4c10-80f6-ffe716741112	USER_REGISTERED	user	234f60f6-3d4d-4c10-80f6-ffe716741112	{"role": "CUSTOMER", "email": "multi_reset_93dc6051@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:07.845612+00
14b5841b-894e-490d-810f-69ca9e3adcb4	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	121eaa2b-9e29-4c21-947f-9a2d28de1b57	{"sku": "CRM-3B5AF2", "name": "CRM Software", "currency": "INR", "sales_price": "2000.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:11:30.61083+00
4b2d0c5a-6ae5-4d01-8219-8c6265f55b9a	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	2d3fc097-a040-4d26-ac79-060315cb6a0f	{"code": "CRM-PLAN-63CBBB", "name": "CRM Standard Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:11:30.655069+00
205e2f78-68e0-4639-9e4f-3ea892db4515	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	41ef98fe-e7b3-46e3-91a9-511587a0f0a2	{"plan_id": "2d3fc097-a040-4d26-ac79-060315cb6a0f", "quantity": 3, "product_id": "121eaa2b-9e29-4c21-947f-9a2d28de1b57", "variant_id": "a4240ace-a976-408e-8d29-916a7ceb90be", "price_override": "2200.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:11:30.679362+00
3d5c8335-7caf-45bc-a7c6-be73e4bdfe75	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_UPDATED	PLAN_PRODUCT	41ef98fe-e7b3-46e3-91a9-511587a0f0a2	{"plan_id": "2d3fc097-a040-4d26-ac79-060315cb6a0f", "quantity": 5, "is_active": true}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:11:30.756047+00
8206f742-deec-4661-b66f-2998c98bd210	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_REMOVED	PLAN_PRODUCT	41ef98fe-e7b3-46e3-91a9-511587a0f0a2	{"plan_id": "2d3fc097-a040-4d26-ac79-060315cb6a0f"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:11:30.835901+00
b5c40475-d4e7-4f6c-81a3-131aaf1df199	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	2465ee22-301b-433a-a7d9-69e023d2a19f	{"sku": "INR-5FAAF3", "name": "INR Service", "currency": "INR", "sales_price": "1000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:12:45.19549+00
f635a676-4124-44a8-9bf0-2cfa196eece1	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	9f4e11a1-974c-45c7-9b4f-9723e768ae0a	{"sku": "USD-EC2A8D", "name": "USD Service", "currency": "USD", "sales_price": "50.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:12:45.237544+00
f68f58ea-2ab3-4027-971b-48127b039cf1	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	8ed7bc01-3a16-47e8-9ead-150ad6535e7e	{"sku": "AC-CD14A6", "name": "Auto Close Product", "currency": "INR", "sales_price": "1500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:12:45.884736+00
c63689ac-5bdc-4163-b7ea-79e53abbeb36	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	9ebfdf67-a925-40e8-93fe-8666a6d59fbd	{"sku": "CRM-3F6A7B", "name": "CRM Software", "currency": "INR", "sales_price": "2000.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:12:46.235778+00
786d882e-1e49-47d8-9ebd-abe0b7ea9e69	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	861ae7ab-d090-419b-9955-d4663145fc15	{"sku": "INR-8576D9", "name": "INR Service", "currency": "INR", "sales_price": "1000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:12:59.638933+00
b60ba3d7-2d06-4eb6-a0d7-422f136e7fe3	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	eb1965b5-8923-4f65-8ac9-3943b4d5cd1d	{"sku": "USD-90D405", "name": "USD Service", "currency": "USD", "sales_price": "50.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:12:59.680451+00
2bf35c96-5b4d-4fbf-bf4c-ebab7259a2ec	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	3ff1e4cf-d506-4b90-a393-887d66a2a495	{"code": "PLAN-INR-D9B3DB", "name": "Enterprise INR Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:12:59.70691+00
6a67bb60-6ff2-4e1c-a2be-655ba8b651c9	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	569f9d4c-d6ca-4810-8ea7-6ce5409e2318	{"plan_id": "3ff1e4cf-d506-4b90-a393-887d66a2a495", "quantity": 2, "product_id": "861ae7ab-d090-419b-9955-d4663145fc15", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:12:59.769469+00
86e7eae4-d0c5-4de9-acf7-e462ace708e0	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	48c8dd02-1258-4513-b665-f8726f987084	{"code": "GUARD-5D8655", "name": "Empty Draft Plan", "currency": "INR", "billing_interval": "YEARLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:12:59.822235+00
50420c56-3b07-409f-9e3a-d4b2700c06be	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	04e41d81-94e0-4b86-a71b-db756e3f224c	{"sku": "BASE-ADE7E9", "name": "Base Software", "currency": "INR", "sales_price": "3000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:12:59.861116+00
e1ac9bc3-4238-4a64-a61e-19f611b852a3	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	ef7eb394-aecd-46b6-bc2b-71e35d273b06	{"code": "CRM-PLAN-F69AC5", "name": "CRM Standard Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:21.539432+00
79a31adb-268d-4547-8f6d-0d597a082e10	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	0e9850ad-e661-4317-bdfd-40ad2aae4f52	{"plan_id": "48c8dd02-1258-4513-b665-f8726f987084", "quantity": 1, "product_id": "04e41d81-94e0-4b86-a71b-db756e3f224c", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:12:59.890477+00
9b3e8325-393f-45c5-a8a2-b59b3ac66467	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	48c8dd02-1258-4513-b665-f8726f987084	{"code": "GUARD-5D8655", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:12:59.917988+00
d35231a3-f0da-4e97-844d-d37deb68eec4	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	48c8dd02-1258-4513-b665-f8726f987084	{"code": "GUARD-5D8655", "new_status": "INACTIVE", "old_status": "INACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:12:59.957658+00
9700afaa-ecce-478a-b123-a3cf27d626a1	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	48c8dd02-1258-4513-b665-f8726f987084	{"code": "GUARD-5D8655", "new_status": "ARCHIVED", "old_status": "ARCHIVED"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:12:59.997508+00
8cae5783-82fc-40d5-972a-2924f11d65dc	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	79144eb3-21f8-490f-bd46-ac454693355f	{"sku": "AC-360675", "name": "Auto Close Product", "currency": "INR", "sales_price": "1500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:00.078228+00
a865e14f-a051-4848-9957-52f5a029da19	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	7bdc7075-09f4-4d9b-8738-14587dae6430	{"code": "AUTO-91F3B2", "name": "Limited Time Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:00.110556+00
d9ec0433-0c3f-42e2-aa96-8da7b921735c	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:23:57.032754+00
6e1bc4a6-0124-441d-9eb9-240b6d1bd3e4	234f60f6-3d4d-4c10-80f6-ffe716741112	PASSWORD_RESET_REQUESTED	auth	234f60f6-3d4d-4c10-80f6-ffe716741112	{"email": "multi_reset_93dc6051@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:07.937592+00
89bed2fa-0f4f-4a34-9cda-5c57fce5cd57	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	dba660b1-6890-47b4-9aa1-923db0f660af	{"sku": "CRM-1F79B2", "name": "CRM Software", "currency": "INR", "sales_price": "2000.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:00.313423+00
14557ca5-9b40-4229-b7f9-27da45fd009f	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	804ac948-ab8b-42e6-acfc-c94449522292	{"code": "CRM-PLAN-3A042A", "name": "CRM Standard Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:00.349621+00
c0ceb7c4-d4d7-46d4-b0f9-dc20e3ac2dea	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	304c6f4e-ec7f-4ae5-9b27-5bd526d577a5	{"plan_id": "804ac948-ab8b-42e6-acfc-c94449522292", "quantity": 3, "product_id": "dba660b1-6890-47b4-9aa1-923db0f660af", "variant_id": "cb45dbbc-02c4-4185-9dcb-d489323f84cd", "price_override": "2200.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:00.374327+00
e089f96f-a65e-477c-9bfd-d0ce10c87158	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_UPDATED	PLAN_PRODUCT	304c6f4e-ec7f-4ae5-9b27-5bd526d577a5	{"plan_id": "804ac948-ab8b-42e6-acfc-c94449522292", "quantity": 5, "is_active": true}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:00.441632+00
4c06501e-a40a-4715-920b-8f85485dfc6c	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_REMOVED	PLAN_PRODUCT	304c6f4e-ec7f-4ae5-9b27-5bd526d577a5	{"plan_id": "804ac948-ab8b-42e6-acfc-c94449522292"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:00.518802+00
9e788e35-e78f-4a22-a8a8-dfdb446f0481	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	0399f8a6-2a2e-4fe4-aab1-c06d51fc6f84	{"sku": "INR-5504F9", "name": "INR Service", "currency": "INR", "sales_price": "1000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:20.9046+00
ed381345-e7e3-4fcd-85ea-1abe0a5c833a	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	178c904f-9799-4510-80a3-0369ac205548	{"sku": "USD-1B2AEB", "name": "USD Service", "currency": "USD", "sales_price": "50.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:20.946015+00
abc6b29f-a2f7-4c96-b7a1-c5acc8d2c856	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	52c160f2-a7b8-4c40-b4c3-ff13e513fd07	{"code": "PLAN-INR-676999", "name": "Enterprise INR Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:20.974544+00
91d239a3-be9d-4fce-bc04-de005fc75c24	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	9055c4fd-dd13-4e3a-bada-be34cbcf5649	{"plan_id": "52c160f2-a7b8-4c40-b4c3-ff13e513fd07", "quantity": 2, "product_id": "0399f8a6-2a2e-4fe4-aab1-c06d51fc6f84", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:21.038291+00
0cd0a752-e818-4a6b-bbe0-697b358d01d3	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	6e16e0be-7a50-4e8e-9ac6-f1675ac37aa2	{"code": "GUARD-F4E077", "name": "Empty Draft Plan", "currency": "INR", "billing_interval": "YEARLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:21.094239+00
77990033-5564-4f7d-85f2-97ce2b52d822	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	63e331fa-ccfe-48a4-99a2-71cd3d362192	{"sku": "BASE-51CE58", "name": "Base Software", "currency": "INR", "sales_price": "3000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:21.13612+00
0b4b0cae-9ae7-4c9c-ab62-c690a83c83aa	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	cecceb9c-61dd-46ba-afd7-d524457eadf5	{"plan_id": "6e16e0be-7a50-4e8e-9ac6-f1675ac37aa2", "quantity": 1, "product_id": "63e331fa-ccfe-48a4-99a2-71cd3d362192", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:21.16259+00
6f28e684-5d6f-40fd-9764-64531449ff12	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	6e16e0be-7a50-4e8e-9ac6-f1675ac37aa2	{"code": "GUARD-F4E077", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:21.192757+00
77ebc78b-fb75-414e-8422-7fe1591afa53	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	6e16e0be-7a50-4e8e-9ac6-f1675ac37aa2	{"code": "GUARD-F4E077", "new_status": "INACTIVE", "old_status": "INACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:21.230456+00
e9c6f686-e5bf-4e62-9528-0cd04016c5f5	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	6e16e0be-7a50-4e8e-9ac6-f1675ac37aa2	{"code": "GUARD-F4E077", "new_status": "ARCHIVED", "old_status": "ARCHIVED"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:21.268991+00
cac2dbff-303b-42e9-9a97-c60e8f33df57	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	a73fe521-614b-4045-b1fa-6cbb5b177ec1	{"sku": "AC-E03589", "name": "Auto Close Product", "currency": "INR", "sales_price": "1500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:21.35121+00
2e325b03-5007-44e1-bf3f-938c108a63f8	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	17cdbc0c-02c6-4db1-979a-761060e6fbf4	{"code": "AUTO-DC87C0", "name": "Limited Time Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:21.380174+00
a8d12334-8647-468c-b6d8-cd07d9673385	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	17cdbc0c-02c6-4db1-979a-761060e6fbf4	{"code": "AUTO-DC87C0", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:21.417299+00
f9b6f46d-4206-4250-93d6-30b9857d14d8	\N	PLAN_AUTO_CLOSED	SUBSCRIPTION_PLAN	17cdbc0c-02c6-4db1-979a-761060e6fbf4	{"code": "AUTO-DC87C0", "reason": "Availability end date '2026-10-31 04:13:21.373372+00:00' reached."}	\N	\N	2026-10-31 06:13:21.417299+00
fde28293-7aed-4033-bc0f-d37392adbfa2	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	6fe79193-857b-4c53-b7ec-be99fe2247d1	{"sku": "CRM-7A3073", "name": "CRM Software", "currency": "INR", "sales_price": "2000.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:21.502324+00
6b5d478c-0041-40b6-8e5d-66600136a218	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	5cb6275f-5ad3-4606-be2d-79096c1d2a74	{"plan_id": "ef7eb394-aecd-46b6-bc2b-71e35d273b06", "quantity": 3, "product_id": "6fe79193-857b-4c53-b7ec-be99fe2247d1", "variant_id": "1c1ec097-b256-48f1-abec-265d94ffbbdf", "price_override": "2200.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:21.563654+00
8e1c774b-74cf-43f1-b2ba-e6be0ca3bed9	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_UPDATED	PLAN_PRODUCT	5cb6275f-5ad3-4606-be2d-79096c1d2a74	{"plan_id": "ef7eb394-aecd-46b6-bc2b-71e35d273b06", "quantity": 5, "is_active": true}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:21.637657+00
df515f86-fb66-4ad1-bf1c-724d4a3225e7	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_REMOVED	PLAN_PRODUCT	5cb6275f-5ad3-4606-be2d-79096c1d2a74	{"plan_id": "ef7eb394-aecd-46b6-bc2b-71e35d273b06"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:21.717639+00
3113542c-c265-45e7-be15-ed18ee772f1c	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	af3fd5b5-b681-402e-8575-5ffd9b88f130	{"sku": "ERP-ED850A", "name": "ERP Financials", "currency": "INR", "sales_price": "2000.0000", "variants_count": 2}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:28.044234+00
25d42fc1-18c7-4307-9840-7b2095f07ac9	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	321df9e4-d590-466f-9521-5937cdff48d3	{"sku": "SW-81EFB2", "name": "Standard Software", "currency": "INR", "sales_price": "5000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:28.181489+00
7c83d6c1-d9ad-4304-929a-0475ff60fc46	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	9acc2664-1ed1-4b32-b7d0-6879f0911497	{"sku": "INR-3ABC9B", "name": "INR Product", "currency": "INR", "sales_price": "100.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:28.243043+00
c99d8fc7-2f54-401d-88bd-9fef0d4dfbff	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	a6135f0d-9e90-41a4-b131-b000633d2464	{"sku": "ERP-28F5B7", "name": "ERP Financials", "currency": "INR", "sales_price": "2000.0000", "variants_count": 2}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:42.969597+00
f3bee4ad-779c-41e3-88f3-863f6047c0e5	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	32ed9f4b-3646-4de1-8d31-51a566d18f6a	{"sku": "SW-22646A", "name": "Standard Software", "currency": "INR", "sales_price": "5000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:43.0766+00
8b2b5f05-6776-4c1b-9670-fcca53e9498f	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	08548eb4-b59f-4b5c-b05e-646ca08e643c	{"sku": "INR-310E2C", "name": "INR Product", "currency": "INR", "sales_price": "100.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:43.133947+00
fcd45b1b-ae58-4388-9850-c33994539090	c32a5212-b7f3-47b9-92fe-96e24c186d3a	USER_REGISTERED	user	c32a5212-b7f3-47b9-92fe-96e24c186d3a	{"role": "CUSTOMER", "email": "customer_0267bc46@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:49.510019+00
1393b6fd-64bc-4541-95c0-d6a1eb6d1b0a	d2702a1d-a785-409d-8cab-f3fca8383db5	USER_REGISTERED	user	d2702a1d-a785-409d-8cab-f3fca8383db5	{"role": "CUSTOMER", "email": "dup_4dc08be5@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:49.709246+00
c2362ee8-5e10-49ce-8acb-1f91bfdac9b6	6eaadb1f-a86c-4a96-9f46-5be20c86d832	USER_REGISTERED	user	6eaadb1f-a86c-4a96-9f46-5be20c86d832	{"role": "CUSTOMER", "email": "login_user_a133e419@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:49.810271+00
a23f85da-ef43-4f77-a894-5a0fa1846891	b84bc79d-7fba-4cbc-b4df-2680463dc2f3	USER_REGISTERED	user	b84bc79d-7fba-4cbc-b4df-2680463dc2f3	{"role": "CUSTOMER", "email": "catalog_cust_c51f8b@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:23:57.24956+00
45a7fd2d-47a3-45f4-b039-14a9941d2c16	6eaadb1f-a86c-4a96-9f46-5be20c86d832	AUTH_LOGIN_SUCCESS	auth	6eaadb1f-a86c-4a96-9f46-5be20c86d832	{"role": "CUSTOMER", "email": "login_user_a133e419@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:49.961677+00
fbd0e8c1-dc9c-426d-b4f4-9a1ec66569f8	273c9f88-fd9f-41a8-ad7f-fda6f3e69768	USER_REGISTERED	user	273c9f88-fd9f-41a8-ad7f-fda6f3e69768	{"role": "CUSTOMER", "email": "rotation_c395c625@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:50.042695+00
40af7ed5-c866-4a6a-85a1-bbe9f5ae57da	273c9f88-fd9f-41a8-ad7f-fda6f3e69768	TOKEN_ROTATED	auth	273c9f88-fd9f-41a8-ad7f-fda6f3e69768	{"family_id": "3bb36288-f744-4889-9e0d-36241512b68b"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:50.133715+00
a8d25c82-48fe-4eb1-9f6b-1fe53759a5d4	273c9f88-fd9f-41a8-ad7f-fda6f3e69768	TOKEN_REUSE_DETECTED	auth	7e3f9ff3-e4cf-4886-9b56-d4b38a1e4783	{"reason": "Attempted reuse of consumed token", "family_id": "3bb36288-f744-4889-9e0d-36241512b68b"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:50.15537+00
a79abcc3-8aec-4267-803c-8ee8194a3761	273c9f88-fd9f-41a8-ad7f-fda6f3e69768	TOKEN_REUSE_DETECTED	auth	1a669a36-48ab-4ad0-b252-634a7c7f4579	{"reason": "Attempted reuse of consumed token", "family_id": "3bb36288-f744-4889-9e0d-36241512b68b"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:50.170985+00
a564cbcf-559d-4572-9091-a941a3c7c159	b23e2baa-5c89-4c93-b7a7-129f2c72d695	USER_REGISTERED	user	b23e2baa-5c89-4c93-b7a7-129f2c72d695	{"role": "CUSTOMER", "email": "reset_bd7038dd@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:50.189973+00
b024eb07-1691-423a-ab9d-48014c59615c	b23e2baa-5c89-4c93-b7a7-129f2c72d695	PASSWORD_RESET_REQUESTED	auth	b23e2baa-5c89-4c93-b7a7-129f2c72d695	{"email": "reset_bd7038dd@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:50.264457+00
2ba4655c-53d1-4d7e-86d4-a4ce3be7da99	b23e2baa-5c89-4c93-b7a7-129f2c72d695	PASSWORD_RESET_COMPLETED	auth	b23e2baa-5c89-4c93-b7a7-129f2c72d695	{"email": "reset_bd7038dd@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:50.314685+00
26880e15-b043-4c0a-8f54-334c5f5da13e	b23e2baa-5c89-4c93-b7a7-129f2c72d695	AUTH_LOGIN_SUCCESS	auth	b23e2baa-5c89-4c93-b7a7-129f2c72d695	{"role": "CUSTOMER", "email": "reset_bd7038dd@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:50.444043+00
915a62eb-ec9b-4ab1-b571-23226c9f1e29	363682ab-f901-4a29-a3aa-ba02862dffe8	USER_REGISTERED	user	363682ab-f901-4a29-a3aa-ba02862dffe8	{"role": "CUSTOMER", "email": "multi_reset_79dc88a0@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:50.526877+00
ae387007-9a16-4dbe-8bd1-a8ec491e8604	363682ab-f901-4a29-a3aa-ba02862dffe8	PASSWORD_RESET_REQUESTED	auth	363682ab-f901-4a29-a3aa-ba02862dffe8	{"email": "multi_reset_79dc88a0@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:50.606424+00
0ac73aaa-fb58-42ab-9a1b-0967117ba8a0	363682ab-f901-4a29-a3aa-ba02862dffe8	PASSWORD_RESET_REQUESTED	auth	363682ab-f901-4a29-a3aa-ba02862dffe8	{"email": "multi_reset_79dc88a0@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:50.649528+00
bb1c15aa-5dca-425a-bd29-0ed457aabe85	cc2d41cf-22a5-4018-b6a0-a26f4f36f26e	USER_REGISTERED	user	cc2d41cf-22a5-4018-b6a0-a26f4f36f26e	{"role": "CUSTOMER", "email": "logout_no_jwt_76d82c97@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:50.705132+00
b208716a-eb51-4a15-aabb-bf108dfe5988	cc2d41cf-22a5-4018-b6a0-a26f4f36f26e	TOKEN_REUSE_DETECTED	auth	18f53e9f-8812-45d8-9866-d40d838985f1	{"reason": "Attempted reuse of consumed token", "family_id": "6ed9f997-d85e-4f7f-9ef7-8235e9e05394"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:50.794512+00
83bfe779-b109-4321-be31-7b535c1ad18c	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	358dac3d-dac5-49aa-aa87-02e1382ee3bb	{"sku": "INR-25BE9E", "name": "INR Service", "currency": "INR", "sales_price": "1000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:50.870471+00
f7539302-5466-4a37-a4a7-b206ce6a876a	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	09020a22-da2c-4da8-b6b0-8f371b2dc361	{"sku": "USD-EA4AF2", "name": "USD Service", "currency": "USD", "sales_price": "50.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:50.902008+00
ec13ccb2-a890-4f6b-986c-79a80c3b44a7	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	58e5db85-a522-4c2e-ae0e-7c59bb12a005	{"code": "PLAN-INR-F67B9F", "name": "Enterprise INR Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:50.928359+00
2e81024c-fd27-45c5-ab9d-4d43f9a96835	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_DEACTIVATED	PRODUCT_VARIANT	c963199d-9887-4663-86ab-af9a1af8540a	{"variant_code": "VA", "variant_name": "Variant A", "deactivated_plan_line_items": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:52.334352+00
14a41c7a-aa58-4056-92e2-a3da917a05c2	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	a0c8ca3c-7a52-4329-aa48-c16eb76770af	{"plan_id": "58e5db85-a522-4c2e-ae0e-7c59bb12a005", "quantity": 2, "product_id": "358dac3d-dac5-49aa-aa87-02e1382ee3bb", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:50.985053+00
a5707cb4-3f8f-49d0-8474-da57e650cf27	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	0dc7b634-cf11-4b86-8fe2-865f1569dcfc	{"code": "GUARD-909BE1", "name": "Empty Draft Plan", "currency": "INR", "billing_interval": "YEARLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:51.031779+00
2206a81b-3034-455d-9e37-51b10a07f2f7	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	e76fe912-75c8-45d2-9051-5d5cc3dd8f1e	{"sku": "BASE-240CB1", "name": "Base Software", "currency": "INR", "sales_price": "3000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:51.070842+00
2206821f-679d-4205-ad8b-cbc351df6d21	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	641ecf9e-5636-448f-a58a-06da42e3a7bb	{"plan_id": "0dc7b634-cf11-4b86-8fe2-865f1569dcfc", "quantity": 1, "product_id": "e76fe912-75c8-45d2-9051-5d5cc3dd8f1e", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:51.099261+00
5934faa4-ca79-43ca-8c05-c1ef38241588	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	0dc7b634-cf11-4b86-8fe2-865f1569dcfc	{"code": "GUARD-909BE1", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:51.127699+00
1b88ef81-6cc1-42b0-bbca-38ad4437be88	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	0dc7b634-cf11-4b86-8fe2-865f1569dcfc	{"code": "GUARD-909BE1", "new_status": "INACTIVE", "old_status": "INACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:51.171449+00
62a329bb-6ec2-4172-a99f-0f6cae58a08e	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	0dc7b634-cf11-4b86-8fe2-865f1569dcfc	{"code": "GUARD-909BE1", "new_status": "ARCHIVED", "old_status": "ARCHIVED"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:51.212704+00
49cb4356-df17-4cb2-8742-8f2fd6f65847	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	6fa297e4-67e6-4d76-9c5c-c502ecf1ea18	{"sku": "AC-F6DD88", "name": "Auto Close Product", "currency": "INR", "sales_price": "1500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:51.304615+00
87f312a7-35fb-4c9b-96a3-5ce4e2af20e6	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	5e11e3c1-5e4b-4960-a35a-34e971d57feb	{"code": "AUTO-4EB311", "name": "Limited Time Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:51.330111+00
c3e8c57a-afc0-497b-8aee-2915f9db5c2b	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	5e11e3c1-5e4b-4960-a35a-34e971d57feb	{"code": "AUTO-4EB311", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:51.369076+00
6d93e65a-eb09-4421-b1cf-648b6158d9f3	\N	PLAN_AUTO_CLOSED	SUBSCRIPTION_PLAN	5e11e3c1-5e4b-4960-a35a-34e971d57feb	{"code": "AUTO-4EB311", "reason": "Availability end date '2026-10-31 04:13:51.324040+00:00' reached."}	\N	\N	2026-10-31 06:13:51.369076+00
0236e61d-5569-447f-974a-2c4e7d7ad2b5	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	04373e00-7bd0-4ff4-aab7-e964ad3db065	{"sku": "CRM-51660B", "name": "CRM Software", "currency": "INR", "sales_price": "2000.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:51.455491+00
f955b5e8-680d-4c53-887f-0a39551192a0	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	62ebe75d-fc33-4d89-bf7d-3cd2bd7bbaeb	{"code": "CRM-PLAN-7156B5", "name": "CRM Standard Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:51.492502+00
8c630f87-3b43-444e-9e13-3dfc1fe3bc42	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	bb5d658e-d7dc-4b7b-999e-4b5402e98c77	{"plan_id": "62ebe75d-fc33-4d89-bf7d-3cd2bd7bbaeb", "quantity": 3, "product_id": "04373e00-7bd0-4ff4-aab7-e964ad3db065", "variant_id": "8fd87388-1f5d-4b91-9a9a-7c8271705edb", "price_override": "2200.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:51.51912+00
70444493-68e0-426a-a339-832b173018af	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_UPDATED	PLAN_PRODUCT	bb5d658e-d7dc-4b7b-999e-4b5402e98c77	{"plan_id": "62ebe75d-fc33-4d89-bf7d-3cd2bd7bbaeb", "quantity": 5, "is_active": true}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:51.58556+00
495a89df-1a22-4939-94eb-6de9892f6d88	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_REMOVED	PLAN_PRODUCT	bb5d658e-d7dc-4b7b-999e-4b5402e98c77	{"plan_id": "62ebe75d-fc33-4d89-bf7d-3cd2bd7bbaeb"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:51.668081+00
86c04b8c-1b55-4730-9671-9c7f2430a614	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	7c6f805a-640e-4ecc-978e-7901e5586d3b	{"sku": "ERP-C611B4", "name": "ERP Financials", "currency": "INR", "sales_price": "2000.0000", "variants_count": 2}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:51.73966+00
8184367e-10a3-4841-8067-05c46e5b7949	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	edc1c0b2-f0bf-44f9-8f33-8a7dbeb41a2e	{"sku": "SW-DE75CB", "name": "Standard Software", "currency": "INR", "sales_price": "5000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:51.824624+00
a15be75d-5859-47af-b003-9bb371651608	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	43a13440-84e9-4ad7-bebf-7fdbb5001fb8	{"sku": "INR-602C73", "name": "INR Product", "currency": "INR", "sales_price": "100.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:51.881627+00
f528de76-25db-43db-80dc-00756f25284b	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	f05e44c4-d451-4a45-89ef-63044010ffb3	{"sku": "SKU-38E5BF", "name": "Brightloop ERP Cloud", "currency": "INR", "sales_price": "2000.0000", "variants_count": 2}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:51.950086+00
5bfe8cf8-0bc9-48b1-a172-302fac4b19cf	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_CREATED	PRODUCT_VARIANT	7c978ef8-1885-4ca9-885d-ae81a97a51bf	{"product_id": "f05e44c4-d451-4a45-89ef-63044010ffb3", "variant_code": "ENT", "variant_name": "Enterprise Addon", "adjustment_type": "PERCENTAGE", "adjustment_value": "25.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:52.004188+00
5a963828-4d05-40db-bd2c-c5dd16e89301	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	f6557609-20bd-4660-99ac-ddaca5c790a8	{"sku": "RBAC-BC7A10", "name": "Admin Product", "currency": "INR", "sales_price": "500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:52.113599+00
39edcf7f-69ae-4353-af02-6e879c1f17aa	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	4f1193b4-eaae-45eb-86c7-8fa397deba44	{"sku": "HIST-70AF6B", "name": "History Test Product", "currency": "INR", "sales_price": "1000.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:52.170244+00
7b6efdad-3812-4c07-9d7f-0b9080f978b9	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_UPDATED	PRODUCT	4f1193b4-eaae-45eb-86c7-8fa397deba44	{"sku": "HIST-70AF6B", "name": "History Test Product", "reason": "Annual inflation rate increase", "price_changes": {"cost_price": {"new": "450.0000", "old": "300.0000"}, "sales_price": {"new": "1500.0000", "old": "1000.0000"}}}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:52.197517+00
4e2261e6-5df4-4e58-a5d5-992953535017	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_UPDATED	PRODUCT_VARIANT	b9a95e2b-3ae8-40fc-918a-0f414359c493	{"variant_code": "PRO", "variant_name": "Pro Pack", "adjustment_type": "PERCENTAGE", "adjustment_value": "30.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:52.230443+00
8819cb8f-d854-4d68-83fc-f826feb464df	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	e4211d2a-d133-4063-a34f-f874d9f95e86	{"sku": "ARCH-B14899", "name": "To Archive Product", "currency": "INR", "sales_price": "750.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:52.271187+00
fd72ed2e-04a0-42d1-8e31-3808f02ac17c	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_ARCHIVED	PRODUCT	e4211d2a-d133-4063-a34f-f874d9f95e86	{"sku": "ARCH-B14899", "name": "To Archive Product", "deactivated_plan_line_items": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:52.302442+00
1750d9bd-3aaf-45ea-b5c6-879b730d6d2e	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:52.496563+00
a9d9ec55-22a4-4161-9584-69b321fb2b72	a3acd349-ecfe-43b2-b0c5-0b32d9b9ffaf	USER_REGISTERED	user	a3acd349-ecfe-43b2-b0c5-0b32d9b9ffaf	{"role": "CUSTOMER", "email": "cust1_82238fba@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:52.563498+00
f4e86a42-b2e5-4615-bc90-43bc1a363f73	ab9eb3ad-9572-473b-87e5-ecfb47c8c965	USER_REGISTERED	user	ab9eb3ad-9572-473b-87e5-ecfb47c8c965	{"role": "CUSTOMER", "email": "cust2_371d946d@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:52.647464+00
c4b90d82-e230-45ec-9c85-570944aeeb17	5040313c-9900-4630-93f9-1f0e119412dd	STAFF_CREATED	user	8ec9343a-c648-44c8-970a-e80a8b737f13	{"role": "STAFF", "created_email": "staff_2ae8d1b8@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:52.791714+00
a38ef587-22d4-4baa-ae35-82e7a9e39427	8ec9343a-c648-44c8-970a-e80a8b737f13	AUTH_LOGIN_SUCCESS	auth	8ec9343a-c648-44c8-970a-e80a8b737f13	{"role": "STAFF", "email": "staff_2ae8d1b8@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:52.859656+00
e0517b55-12a9-47f5-ad33-adb99fe77a1a	5040313c-9900-4630-93f9-1f0e119412dd	USER_STATUS_UPDATED	user	a3acd349-ecfe-43b2-b0c5-0b32d9b9ffaf	{"is_active": false, "target_email": "cust1_82238fba@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:13:53.019633+00
49ed9b46-9370-406e-a050-98ba08e454f9	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:23:57.529824+00
2dcabe67-e1a7-4db7-818d-e592b4410f73	758cbb6e-1315-4950-951a-1f33572219e7	USER_REGISTERED	user	758cbb6e-1315-4950-951a-1f33572219e7	{"role": "CUSTOMER", "email": "customer_453a387a@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:01.187694+00
e66ee491-340c-403d-b4fb-3e4e0400c586	33690c3d-86a0-4aba-abf2-1fca9b4cbe33	USER_REGISTERED	user	33690c3d-86a0-4aba-abf2-1fca9b4cbe33	{"role": "CUSTOMER", "email": "dup_8fa111d9@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:01.338979+00
50844523-4c6a-4bd6-9248-ed5c4306a451	c05057aa-da45-490a-b1ea-f30a2d1379cf	USER_REGISTERED	user	c05057aa-da45-490a-b1ea-f30a2d1379cf	{"role": "CUSTOMER", "email": "login_user_324c57a4@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:01.431994+00
faab1369-3406-47d3-b9ab-61bde1673204	234f60f6-3d4d-4c10-80f6-ffe716741112	PASSWORD_RESET_REQUESTED	auth	234f60f6-3d4d-4c10-80f6-ffe716741112	{"email": "multi_reset_93dc6051@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:07.991879+00
68dbe1aa-315b-4079-bf7e-06cdaa337d81	c05057aa-da45-490a-b1ea-f30a2d1379cf	AUTH_LOGIN_SUCCESS	auth	c05057aa-da45-490a-b1ea-f30a2d1379cf	{"role": "CUSTOMER", "email": "login_user_324c57a4@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:01.573081+00
a6766420-1771-45cf-9ec0-1a8cc465668e	e0236433-07f7-49d1-a82f-7d0f89d8c405	USER_REGISTERED	user	e0236433-07f7-49d1-a82f-7d0f89d8c405	{"role": "CUSTOMER", "email": "rotation_fea2b7e4@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:01.638016+00
b50a5eda-d137-49c5-a3df-453b0ab22ac1	e0236433-07f7-49d1-a82f-7d0f89d8c405	TOKEN_ROTATED	auth	e0236433-07f7-49d1-a82f-7d0f89d8c405	{"family_id": "8daeb7cf-6d64-47c6-932d-8e2dc8525751"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:01.711867+00
56fc020b-ba5e-4655-9cec-f387e761c7f8	e0236433-07f7-49d1-a82f-7d0f89d8c405	TOKEN_REUSE_DETECTED	auth	cdc70191-d1ef-46ba-8fdc-95191368d2ee	{"reason": "Attempted reuse of consumed token", "family_id": "8daeb7cf-6d64-47c6-932d-8e2dc8525751"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:01.731066+00
b83b9c9c-74c5-4822-913a-b4ca0bb5c54b	e0236433-07f7-49d1-a82f-7d0f89d8c405	TOKEN_REUSE_DETECTED	auth	0430cbed-3dd5-45c1-93cd-b62faae84cb5	{"reason": "Attempted reuse of consumed token", "family_id": "8daeb7cf-6d64-47c6-932d-8e2dc8525751"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:01.748661+00
e16dae86-b7f5-4b80-bef1-81c842213bc9	537a0cb3-7755-40b3-b86c-fbb8b65dc2a8	USER_REGISTERED	user	537a0cb3-7755-40b3-b86c-fbb8b65dc2a8	{"role": "CUSTOMER", "email": "reset_787135c5@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:01.768606+00
6d7b5880-2fd7-4bd4-bb81-72ef2a5f7a5e	537a0cb3-7755-40b3-b86c-fbb8b65dc2a8	PASSWORD_RESET_REQUESTED	auth	537a0cb3-7755-40b3-b86c-fbb8b65dc2a8	{"email": "reset_787135c5@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:01.844406+00
e27e7959-42c2-4a5c-956d-3b71ba78e293	537a0cb3-7755-40b3-b86c-fbb8b65dc2a8	PASSWORD_RESET_COMPLETED	auth	537a0cb3-7755-40b3-b86c-fbb8b65dc2a8	{"email": "reset_787135c5@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:01.887263+00
5f070c10-c4a1-4df1-b818-8419f7c83f0a	d9cf23a9-f82e-4101-839c-2dad7bc4dbd4	USER_REGISTERED	user	d9cf23a9-f82e-4101-839c-2dad7bc4dbd4	{"role": "CUSTOMER", "email": "cust1_a69ddd16@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:21.891528+00
c467c745-8b68-410d-a634-67ac0de5dab5	537a0cb3-7755-40b3-b86c-fbb8b65dc2a8	AUTH_LOGIN_SUCCESS	auth	537a0cb3-7755-40b3-b86c-fbb8b65dc2a8	{"role": "CUSTOMER", "email": "reset_787135c5@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:02.009595+00
4f990d46-66e2-402a-ad5e-faf2ff6e1e5d	0e6486aa-8925-457f-b2a3-a8e65f6daf02	USER_REGISTERED	user	0e6486aa-8925-457f-b2a3-a8e65f6daf02	{"role": "CUSTOMER", "email": "multi_reset_2e398a35@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:02.088925+00
18220e56-e61b-4517-aa42-39381565791c	0e6486aa-8925-457f-b2a3-a8e65f6daf02	PASSWORD_RESET_REQUESTED	auth	0e6486aa-8925-457f-b2a3-a8e65f6daf02	{"email": "multi_reset_2e398a35@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:02.162243+00
5dbcd751-c11f-447c-bb10-590e51cc113d	0e6486aa-8925-457f-b2a3-a8e65f6daf02	PASSWORD_RESET_REQUESTED	auth	0e6486aa-8925-457f-b2a3-a8e65f6daf02	{"email": "multi_reset_2e398a35@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:02.203685+00
d3f9f67b-cc8d-4a3d-a7f2-3033b35f8bab	83f844e2-9feb-4657-81e7-4bd8b52e65a4	USER_REGISTERED	user	83f844e2-9feb-4657-81e7-4bd8b52e65a4	{"role": "CUSTOMER", "email": "logout_no_jwt_18f47f3c@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:02.262328+00
ad8a2ce8-ca58-4395-a142-e3df3d62e3eb	83f844e2-9feb-4657-81e7-4bd8b52e65a4	TOKEN_REUSE_DETECTED	auth	c91ce0e1-d913-4382-8d42-886303ed115f	{"reason": "Attempted reuse of consumed token", "family_id": "86310231-a813-4237-9712-7a2c925e5780"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:02.354061+00
000a1c1d-e023-45f1-9fca-6a01a366b664	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	1f9dfc87-7c86-463e-b39c-02772e22a98a	{"sku": "INR-D22377", "name": "INR Service", "currency": "INR", "sales_price": "1000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:02.428427+00
6e579323-eec2-42c7-8d12-abb890317103	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	f60e9831-d881-4d3d-9f4d-c2e498fd1936	{"sku": "USD-E2E4C5", "name": "USD Service", "currency": "USD", "sales_price": "50.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:02.46143+00
c5c5477d-d86f-4f27-8909-e198d977a0bd	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	4924ebc4-0f98-4df0-9e71-1b0144dc2977	{"code": "PLAN-INR-6A2113", "name": "Enterprise INR Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:02.486816+00
c68b87c6-12f2-482d-867c-92331d9b8c53	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	722147e3-e10f-43e7-b4a4-fa9e7c73a157	{"plan_id": "4924ebc4-0f98-4df0-9e71-1b0144dc2977", "quantity": 2, "product_id": "1f9dfc87-7c86-463e-b39c-02772e22a98a", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:02.539256+00
9d3c3e8d-6d80-4b3c-ab8b-8ee227911df6	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	d02c1550-ee4a-4624-b566-2bc4a408805f	{"code": "GUARD-3B059D", "name": "Empty Draft Plan", "currency": "INR", "billing_interval": "YEARLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:02.587342+00
0139312c-a7cb-4c14-8b1a-94de8b765ee6	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	d5bbca6b-8ff8-4282-9156-303ae81f081d	{"sku": "BASE-740480", "name": "Base Software", "currency": "INR", "sales_price": "3000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:02.632078+00
1dc378f0-6022-4e35-8d44-79a5e6bca639	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	0992c14e-749a-4d73-8519-279211e53f41	{"plan_id": "d02c1550-ee4a-4624-b566-2bc4a408805f", "quantity": 1, "product_id": "d5bbca6b-8ff8-4282-9156-303ae81f081d", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:02.659572+00
a7f285f0-948a-4074-bc49-d9606f9c3665	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	d02c1550-ee4a-4624-b566-2bc4a408805f	{"code": "GUARD-3B059D", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:02.68832+00
4f6e1b5c-6c50-41d1-ae3d-68e06db4f313	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	d02c1550-ee4a-4624-b566-2bc4a408805f	{"code": "GUARD-3B059D", "new_status": "INACTIVE", "old_status": "INACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:02.725271+00
31fca9cd-a3b5-410c-85a3-a1a1575090d6	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	d02c1550-ee4a-4624-b566-2bc4a408805f	{"code": "GUARD-3B059D", "new_status": "ARCHIVED", "old_status": "ARCHIVED"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:02.762174+00
12992ac1-733b-4fbb-b87a-bc81d7fe36c5	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	2a6ac91d-0ff8-4157-80a7-5f3426f49ad3	{"sku": "AC-ADBADD", "name": "Auto Close Product", "currency": "INR", "sales_price": "1500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:02.834952+00
e6e2017a-b637-45c5-96e8-0745017e59bb	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	d9308bf5-9a8f-4597-9075-f8888ea04a22	{"code": "AUTO-777204", "name": "Limited Time Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:02.86143+00
901cadeb-bc91-40c9-a0cf-0188e4ae20dc	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	d9308bf5-9a8f-4597-9075-f8888ea04a22	{"code": "AUTO-777204", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:02.898391+00
62585e6f-b345-4af9-a874-207fa44524d6	\N	PLAN_AUTO_CLOSED	SUBSCRIPTION_PLAN	d9308bf5-9a8f-4597-9075-f8888ea04a22	{"code": "AUTO-777204", "reason": "Availability end date '2026-10-31 04:26:02.855062+00:00' reached."}	\N	\N	2026-10-31 06:26:02.898391+00
f91e9389-c3e8-4f9a-bdb0-9681c4963d46	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	d6d87563-ae37-492a-b2e0-942bb7b70a12	{"sku": "CRM-ADF403", "name": "CRM Software", "currency": "INR", "sales_price": "2000.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:02.973651+00
6776a265-3e32-4b0f-be86-e9cc0cc0925c	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	6f0692b1-674a-4801-b15f-644ae613c6ba	{"code": "CRM-PLAN-6813A9", "name": "CRM Standard Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:03.006386+00
220f7e13-425d-4ebc-a19c-572736fc8447	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	6d571819-8142-4880-a3a2-15745c10e325	{"plan_id": "6f0692b1-674a-4801-b15f-644ae613c6ba", "quantity": 3, "product_id": "d6d87563-ae37-492a-b2e0-942bb7b70a12", "variant_id": "e18c25c6-b3fe-4ea0-a4cd-f0de05ff52ab", "price_override": "2200.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:03.031052+00
450ed8d5-9670-4c17-b283-12f3b6ed484e	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_UPDATED	PLAN_PRODUCT	6d571819-8142-4880-a3a2-15745c10e325	{"plan_id": "6f0692b1-674a-4801-b15f-644ae613c6ba", "quantity": 5, "is_active": true}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:03.094679+00
3242d9bd-d5ae-42c4-b732-d212e86504c3	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_REMOVED	PLAN_PRODUCT	6d571819-8142-4880-a3a2-15745c10e325	{"plan_id": "6f0692b1-674a-4801-b15f-644ae613c6ba"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:03.174059+00
ab7100f3-adf7-4b7f-96e5-81f0fd686eb6	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	2bcd0897-91e7-4ced-aa4d-e38791d0ac93	{"sku": "ERP-88400D", "name": "ERP Financials", "currency": "INR", "sales_price": "2000.0000", "variants_count": 2}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:03.238769+00
e4fda356-e5ea-4bd3-9b14-803a59ffb891	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	3d343c77-1349-4c87-aaf6-ef9bdcdcf562	{"sku": "SW-A30EEC", "name": "Standard Software", "currency": "INR", "sales_price": "5000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:03.317992+00
ef85820f-3c06-4c45-8953-54917471239f	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	2a0b1bde-ad3b-413a-b5cc-a9e481dab438	{"sku": "INR-84E728", "name": "INR Product", "currency": "INR", "sales_price": "100.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:03.379057+00
6f3946a9-735a-4294-83ab-86c3beb90894	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	a308717f-0607-4833-859f-42b9407e171b	{"sku": "SKU-C3CB5A", "name": "Brightloop ERP Cloud", "currency": "INR", "sales_price": "2000.0000", "variants_count": 2}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:03.451849+00
4b79ab61-274d-4277-a5e1-adb8bce97608	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_CREATED	PRODUCT_VARIANT	501b4455-d0fe-4c3a-9286-ad9233b31152	{"product_id": "a308717f-0607-4833-859f-42b9407e171b", "variant_code": "ENT", "variant_name": "Enterprise Addon", "adjustment_type": "PERCENTAGE", "adjustment_value": "25.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:03.50579+00
df754ece-f953-4ff1-baab-06ea955115e2	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	9bbac0ae-0433-4cd3-8bbc-77756a37a057	{"sku": "RBAC-83ABDA", "name": "Admin Product", "currency": "INR", "sales_price": "500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:03.626045+00
732aac06-5038-4b91-b1ab-0e1b44c73a20	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	455a8b2f-dcc1-4aac-9413-33465f3173e5	{"sku": "HIST-F9F53B", "name": "History Test Product", "currency": "INR", "sales_price": "1000.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:03.696165+00
d1b4aa05-877d-4b66-ac79-c04aab290c16	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_UPDATED	PRODUCT	455a8b2f-dcc1-4aac-9413-33465f3173e5	{"sku": "HIST-F9F53B", "name": "History Test Product", "reason": "Annual inflation rate increase", "price_changes": {"cost_price": {"new": "450.0000", "old": "300.0000"}, "sales_price": {"new": "1500.0000", "old": "1000.0000"}}}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:03.725792+00
70b11a80-d4cb-46fe-ada8-a5ea5289cae0	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_UPDATED	PRODUCT_VARIANT	a60361be-a9d2-4b9d-926a-852584870054	{"variant_code": "PRO", "variant_name": "Pro Pack", "adjustment_type": "PERCENTAGE", "adjustment_value": "30.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:03.761454+00
575c5761-ab0f-4fe5-9b27-9b67d64e701f	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	cd326af2-56c6-4257-a9be-36963a814ea0	{"sku": "ARCH-749820", "name": "To Archive Product", "currency": "INR", "sales_price": "750.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:03.799583+00
43cfdb35-9dd2-4d6c-a4cc-f223e6be807f	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_ARCHIVED	PRODUCT	cd326af2-56c6-4257-a9be-36963a814ea0	{"sku": "ARCH-749820", "name": "To Archive Product", "deactivated_plan_line_items": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:03.827721+00
78e6e104-c6ac-4c3c-b359-c4fb93336ea7	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_DEACTIVATED	PRODUCT_VARIANT	b36dcf42-8323-40eb-a599-9bdef190a97c	{"variant_code": "VA", "variant_name": "Variant A", "deactivated_plan_line_items": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:03.860037+00
b46b07a8-d390-4e8e-9906-477409be0042	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:04.027736+00
22739252-ce78-41ef-abe1-5b1533948905	b259462e-0d8f-4f33-8f56-bb56201b88ae	USER_REGISTERED	user	b259462e-0d8f-4f33-8f56-bb56201b88ae	{"role": "CUSTOMER", "email": "cust1_d1067a64@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:04.102479+00
427df3cd-060c-4598-90bd-a183b4aabefc	b82acb67-c9ec-4162-96b0-0123c438f125	USER_REGISTERED	user	b82acb67-c9ec-4162-96b0-0123c438f125	{"role": "CUSTOMER", "email": "cust2_f6f25478@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:04.177992+00
3a0ba892-e2af-4114-af15-ca611bcf385b	5040313c-9900-4630-93f9-1f0e119412dd	STAFF_CREATED	user	988dcc1f-2a72-452d-8edc-e69b41088cb7	{"role": "STAFF", "created_email": "staff_fda470b0@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:04.320067+00
fe0ddd1c-86d9-4314-b5ef-79a67895dba2	988dcc1f-2a72-452d-8edc-e69b41088cb7	AUTH_LOGIN_SUCCESS	auth	988dcc1f-2a72-452d-8edc-e69b41088cb7	{"role": "STAFF", "email": "staff_fda470b0@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:04.389644+00
64db1ca2-d4a6-4973-8411-80c41f579025	5040313c-9900-4630-93f9-1f0e119412dd	USER_STATUS_UPDATED	user	b259462e-0d8f-4f33-8f56-bb56201b88ae	{"is_active": false, "target_email": "cust1_d1067a64@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:26:04.544323+00
ecf91bec-442c-4311-9e24-e8596bbe298b	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	8a9d9a1d-6169-461f-8fad-82cfda34d74b	{"email": "starter_corp_aff995@example.com", "user_id": "755ecc05-8b2e-4094-b235-d22c1ae31dde", "customer_number": "CUST-2026-0048"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:23:57.688377+00
9c1dd298-cc9c-4e2d-a780-89e824ecd8cd	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	2026-10-31 06:36:08.51892+00
cbcf2fd1-0cdb-46cc-b9f7-802c0a5162b0	8cefc72d-4b6b-460e-8272-580cc96d8fa4	USER_REGISTERED	user	8cefc72d-4b6b-460e-8272-580cc96d8fa4	{"role": "CUSTOMER", "email": "customer_34f9a0e6@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:44.904109+00
beb85f9d-04fe-4599-8ed4-6e7bead8ed14	f91d5aaf-69ff-4084-a36c-0fae96432e54	USER_REGISTERED	user	f91d5aaf-69ff-4084-a36c-0fae96432e54	{"role": "CUSTOMER", "email": "dup_1c6cdd4a@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:45.051525+00
2f92d301-3209-45e3-ab80-379aa066b606	6f42db5f-3763-4a9c-a203-4d0c3cf09e17	USER_REGISTERED	user	6f42db5f-3763-4a9c-a203-4d0c3cf09e17	{"role": "CUSTOMER", "email": "login_user_d2c49193@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:45.146353+00
ee21db9d-3bf3-43e8-bba3-97be3cdf37ae	9da9137d-e784-4775-b856-e577b39a1e06	USER_REGISTERED	user	9da9137d-e784-4775-b856-e577b39a1e06	{"role": "CUSTOMER", "email": "logout_no_jwt_037afcef@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:08.061916+00
fb65dab4-164b-4684-84c1-269e9395a6a7	6f42db5f-3763-4a9c-a203-4d0c3cf09e17	AUTH_LOGIN_SUCCESS	auth	6f42db5f-3763-4a9c-a203-4d0c3cf09e17	{"role": "CUSTOMER", "email": "login_user_d2c49193@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:45.318507+00
8a2f5ab5-7e28-4ef3-8bed-5f4a8ce44643	1ba8e121-7af8-4e63-9dc2-4e8bfb005045	USER_REGISTERED	user	1ba8e121-7af8-4e63-9dc2-4e8bfb005045	{"role": "CUSTOMER", "email": "rotation_4c4d4339@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:45.391578+00
2120e25a-85eb-4297-8e6c-1def67394d28	1ba8e121-7af8-4e63-9dc2-4e8bfb005045	TOKEN_ROTATED	auth	1ba8e121-7af8-4e63-9dc2-4e8bfb005045	{"family_id": "168bd358-fa50-44de-8815-f08fdce273f7"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:45.472446+00
b295dbc3-b543-41d2-b6d6-36cfa5d7b3c6	1ba8e121-7af8-4e63-9dc2-4e8bfb005045	TOKEN_REUSE_DETECTED	auth	5188e84d-ddfc-404d-a3a6-7ad609832fcb	{"reason": "Attempted reuse of consumed token", "family_id": "168bd358-fa50-44de-8815-f08fdce273f7"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:45.495047+00
0492e2ae-9658-431d-9a27-b27e9e9d3cab	1ba8e121-7af8-4e63-9dc2-4e8bfb005045	TOKEN_REUSE_DETECTED	auth	2c84bf58-08e4-4226-a8ac-54579470cdca	{"reason": "Attempted reuse of consumed token", "family_id": "168bd358-fa50-44de-8815-f08fdce273f7"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:45.511792+00
3758561d-8843-4d4a-819a-048819f33d11	7350b76c-28c0-4b09-98e2-6eca12318089	USER_REGISTERED	user	7350b76c-28c0-4b09-98e2-6eca12318089	{"role": "CUSTOMER", "email": "reset_8a9ee8cc@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:45.534526+00
96cd67ba-ff21-479c-8517-ef8c3bfcc324	7350b76c-28c0-4b09-98e2-6eca12318089	PASSWORD_RESET_REQUESTED	auth	7350b76c-28c0-4b09-98e2-6eca12318089	{"email": "reset_8a9ee8cc@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:45.616655+00
7f1e0fae-879a-48d9-bebf-06a550ae6d58	7350b76c-28c0-4b09-98e2-6eca12318089	PASSWORD_RESET_COMPLETED	auth	7350b76c-28c0-4b09-98e2-6eca12318089	{"email": "reset_8a9ee8cc@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:45.666481+00
c172b723-b784-432b-b96b-5d278bddfd4f	cdacf1a8-1514-426f-a2d2-ec546983efdf	USER_REGISTERED	user	cdacf1a8-1514-426f-a2d2-ec546983efdf	{"role": "CUSTOMER", "email": "cust2_5ddec5f9@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:21.972496+00
8ebbece0-383b-43df-8af4-e924c6f6ad76	7350b76c-28c0-4b09-98e2-6eca12318089	AUTH_LOGIN_SUCCESS	auth	7350b76c-28c0-4b09-98e2-6eca12318089	{"role": "CUSTOMER", "email": "reset_8a9ee8cc@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:45.821237+00
d02a7402-7ea2-47ef-8a3e-7131733bfea3	8917a4d5-0384-45b4-9836-1bdecdf360ca	USER_REGISTERED	user	8917a4d5-0384-45b4-9836-1bdecdf360ca	{"role": "CUSTOMER", "email": "multi_reset_fdbea0df@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:45.910027+00
fe6fdfca-bfb7-452f-9822-b376b273c751	8917a4d5-0384-45b4-9836-1bdecdf360ca	PASSWORD_RESET_REQUESTED	auth	8917a4d5-0384-45b4-9836-1bdecdf360ca	{"email": "multi_reset_fdbea0df@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:46.000426+00
cdedc000-33c1-4194-9956-09cf03bba921	8917a4d5-0384-45b4-9836-1bdecdf360ca	PASSWORD_RESET_REQUESTED	auth	8917a4d5-0384-45b4-9836-1bdecdf360ca	{"email": "multi_reset_fdbea0df@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:46.047441+00
cf1e9681-bd9b-4c3b-8466-5e068482dceb	bfef7ec7-8624-4555-9e1e-8c418e6f2f61	USER_REGISTERED	user	bfef7ec7-8624-4555-9e1e-8c418e6f2f61	{"role": "CUSTOMER", "email": "logout_no_jwt_1c66e050@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:46.104617+00
632eefdd-d4d7-43f3-a93e-142f2890abc6	bfef7ec7-8624-4555-9e1e-8c418e6f2f61	TOKEN_REUSE_DETECTED	auth	f6132f94-dba7-4a70-b48c-cd52b992ed69	{"reason": "Attempted reuse of consumed token", "family_id": "63fc9259-5043-4f1a-a4b6-c75714536892"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:46.201811+00
2b56ed2c-7fd5-4587-b0e6-df4de9fd82db	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	1f276a0d-edd6-453c-ae2b-47c28fb3eb96	{"sku": "INR-A35493", "name": "INR Service", "currency": "INR", "sales_price": "1000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:46.286958+00
83356b8e-c5a6-42cc-afa3-674eb950e980	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	c8c73b82-9167-4008-a67d-3fc77a8b51ad	{"sku": "USD-7462F9", "name": "USD Service", "currency": "USD", "sales_price": "50.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:46.324005+00
2f7edbb1-b624-4836-a52c-0b9a2cb0ae7c	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	43272446-ad12-47cd-aa6a-fde3a345a0f5	{"code": "PLAN-INR-EEDCD3", "name": "Enterprise INR Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:46.350414+00
96afe1c7-be1e-4208-ae4f-9bb69e611608	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	1791a596-9a2d-47f9-99bb-ed45a9489ba5	{"plan_id": "43272446-ad12-47cd-aa6a-fde3a345a0f5", "quantity": 2, "product_id": "1f276a0d-edd6-453c-ae2b-47c28fb3eb96", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:46.411915+00
6d24cdc9-96d5-4c0d-8706-022e1b461bcf	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	b449504e-ff50-451d-9d99-f4409ca41c79	{"code": "GUARD-0D3421", "name": "Empty Draft Plan", "currency": "INR", "billing_interval": "YEARLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:46.463042+00
37048671-2e41-4848-8a98-8c2e1d1f3e42	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	8194a38c-c919-47f3-88d2-e11ad42b8d01	{"sku": "BASE-B3F084", "name": "Base Software", "currency": "INR", "sales_price": "3000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:46.509591+00
93611432-39fb-46df-80f7-d66972cb912f	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	496e07c4-5db3-4f73-b1c5-ea20e694da05	{"plan_id": "b449504e-ff50-451d-9d99-f4409ca41c79", "quantity": 1, "product_id": "8194a38c-c919-47f3-88d2-e11ad42b8d01", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:46.536079+00
2e09e9f6-2aa7-44fb-9730-a911b5055644	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	b449504e-ff50-451d-9d99-f4409ca41c79	{"code": "GUARD-0D3421", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:46.56569+00
48e6b31b-2397-4564-a394-bb00f26c8c58	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	b449504e-ff50-451d-9d99-f4409ca41c79	{"code": "GUARD-0D3421", "new_status": "INACTIVE", "old_status": "INACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:46.616012+00
c6ae0d33-210e-4334-9e4b-fa23c0c1b419	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	b449504e-ff50-451d-9d99-f4409ca41c79	{"code": "GUARD-0D3421", "new_status": "ARCHIVED", "old_status": "ARCHIVED"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:46.656124+00
c37d59d0-b2b5-45e2-aca6-515a66dfba05	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	2753c50b-661b-4631-ba1f-0e4cb7c3bcea	{"sku": "AC-588CE6", "name": "Auto Close Product", "currency": "INR", "sales_price": "1500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:46.737755+00
0794d221-7e8a-49b6-9a43-e05cb7d2c9da	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	5350071d-5afd-48a9-aa83-2d2935ab73f9	{"code": "AUTO-36D461", "name": "Limited Time Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:46.767305+00
bb0884d1-bee2-4cbb-86a3-01c8547e4686	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	5350071d-5afd-48a9-aa83-2d2935ab73f9	{"code": "AUTO-36D461", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:46.808983+00
2ecb35c6-7c94-4efe-b507-da852216cee9	\N	PLAN_AUTO_CLOSED	SUBSCRIPTION_PLAN	5350071d-5afd-48a9-aa83-2d2935ab73f9	{"code": "AUTO-36D461", "reason": "Availability end date '2026-10-31 04:56:46.760531+00:00' reached."}	\N	\N	2026-10-31 06:56:46.808983+00
64efef96-eb8b-4f3c-93c1-70a74191f3dd	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	1bd42398-2250-4041-94de-21a445c29ff2	{"sku": "CRM-355AB3", "name": "CRM Software", "currency": "INR", "sales_price": "2000.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:46.892346+00
7e9e47b2-e197-425b-be25-77c5c82425cc	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	9b66bfd1-a67a-4c8f-9faf-9c4d43296459	{"code": "CRM-PLAN-3C9AB2", "name": "CRM Standard Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:46.925968+00
4ec2fd7b-75b6-43f9-8a6a-be7b74c7a514	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	16f630a7-3c80-4f47-984e-a962f0f143e7	{"plan_id": "9b66bfd1-a67a-4c8f-9faf-9c4d43296459", "quantity": 3, "product_id": "1bd42398-2250-4041-94de-21a445c29ff2", "variant_id": "4602eab7-0f64-4ee6-83f9-16bf629b0cff", "price_override": "2200.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:46.949909+00
fb99ab5b-dabe-4dd0-999d-948b31fa77cd	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_UPDATED	PLAN_PRODUCT	16f630a7-3c80-4f47-984e-a962f0f143e7	{"plan_id": "9b66bfd1-a67a-4c8f-9faf-9c4d43296459", "quantity": 5, "is_active": true}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:47.017407+00
8525b5d6-9ffb-4848-9ac9-0dbb29b0e3f0	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_REMOVED	PLAN_PRODUCT	16f630a7-3c80-4f47-984e-a962f0f143e7	{"plan_id": "9b66bfd1-a67a-4c8f-9faf-9c4d43296459"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:47.102586+00
3fa99505-5e9f-493e-8076-6efca2135b62	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	99426a0c-726c-4c52-a8ee-1db8061495de	{"sku": "ERP-664F6A", "name": "ERP Financials", "currency": "INR", "sales_price": "2000.0000", "variants_count": 2}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:47.179122+00
25310a53-3d61-47ed-91cd-887cb6b376d5	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	cdebf907-a043-424b-88a6-35f300fec891	{"sku": "SW-A3F9F5", "name": "Standard Software", "currency": "INR", "sales_price": "5000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:47.269995+00
039afe56-b568-4c3e-82a1-66d4ae4c49da	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	f9eeb635-8cd6-4569-a539-23fac41fcd29	{"sku": "INR-60E80A", "name": "INR Product", "currency": "INR", "sales_price": "100.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:47.333192+00
582d687a-52cc-43e7-9858-5c4d4fbb9653	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	e55e63cc-b037-406a-a7f2-6843e840c190	{"sku": "SKU-3EA127", "name": "Brightloop ERP Cloud", "currency": "INR", "sales_price": "2000.0000", "variants_count": 2}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:47.412714+00
9c652832-2bf1-4aee-aebc-653d67642799	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_CREATED	PRODUCT_VARIANT	f3282671-469f-4989-9cb8-159877a7c3e9	{"product_id": "e55e63cc-b037-406a-a7f2-6843e840c190", "variant_code": "ENT", "variant_name": "Enterprise Addon", "adjustment_type": "PERCENTAGE", "adjustment_value": "25.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:47.481981+00
c7f7f6ef-4918-4319-9c22-99d036addd61	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	7550f7f8-4c9c-4ea5-9602-4cf0a0237da9	{"sku": "RBAC-377BB8", "name": "Admin Product", "currency": "INR", "sales_price": "500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:47.604436+00
19b30eca-ee5f-4467-a9b5-c5010a19ff41	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	2f29e6e9-36db-40c5-aeb4-8363d6384102	{"sku": "HIST-8A2D2C", "name": "History Test Product", "currency": "INR", "sales_price": "1000.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:47.677206+00
1cc8cfd8-2476-4d23-820a-bcdc61025e28	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_UPDATED	PRODUCT	2f29e6e9-36db-40c5-aeb4-8363d6384102	{"sku": "HIST-8A2D2C", "name": "History Test Product", "reason": "Annual inflation rate increase", "price_changes": {"cost_price": {"new": "450.0000", "old": "300.0000"}, "sales_price": {"new": "1500.0000", "old": "1000.0000"}}}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:47.71192+00
96fe6daa-9a0d-4d50-ada8-9b1675cd7c2a	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_UPDATED	PRODUCT_VARIANT	e67d3b20-e99a-4713-9602-fa5d19e0ddd1	{"variant_code": "PRO", "variant_name": "Pro Pack", "adjustment_type": "PERCENTAGE", "adjustment_value": "30.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:47.746607+00
ebce2618-a311-4f6b-ab4a-4bbf457099d2	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	552aec1f-af4b-4a87-a336-0f45a07a662e	{"sku": "ARCH-577F09", "name": "To Archive Product", "currency": "INR", "sales_price": "750.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:47.789903+00
a0d12b1f-24fb-44ce-b563-8e8acac0bb36	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_ARCHIVED	PRODUCT	552aec1f-af4b-4a87-a336-0f45a07a662e	{"sku": "ARCH-577F09", "name": "To Archive Product", "deactivated_plan_line_items": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:47.822005+00
e0f7250b-b6bd-40db-ba40-afae37566662	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_DEACTIVATED	PRODUCT_VARIANT	6b896431-0624-4579-8a4e-793d44498f3a	{"variant_code": "VA", "variant_name": "Variant A", "deactivated_plan_line_items": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:47.86115+00
4015e24a-bd45-4bf0-8466-3bad8433c2c1	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:48.065597+00
6a7f9846-3005-4ecd-bfa1-28d1c22c0f5b	12fcf2a8-0bcd-418f-b045-b86a3e365b43	USER_REGISTERED	user	12fcf2a8-0bcd-418f-b045-b86a3e365b43	{"role": "CUSTOMER", "email": "cust1_f1b6ca98@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:48.140734+00
8d4c1b14-c10c-4432-9fb6-41d0ee49440f	03ab9f1d-1184-44f8-8487-d37950fff752	USER_REGISTERED	user	03ab9f1d-1184-44f8-8487-d37950fff752	{"role": "CUSTOMER", "email": "cust2_3283f97a@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:48.221244+00
9721d22a-aac4-49ad-baae-4c3cceab1ee5	5040313c-9900-4630-93f9-1f0e119412dd	STAFF_CREATED	user	e3a621ee-c790-4d80-9300-bcb723ea2b6a	{"role": "STAFF", "created_email": "staff_859e83f3@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:48.368434+00
b8b1b9f4-550e-4052-87d7-4b101b5ae1d5	e3a621ee-c790-4d80-9300-bcb723ea2b6a	AUTH_LOGIN_SUCCESS	auth	e3a621ee-c790-4d80-9300-bcb723ea2b6a	{"role": "STAFF", "email": "staff_859e83f3@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:48.439921+00
00bf9d7d-c0f5-4450-a4fa-41ba4c63b0a7	5040313c-9900-4630-93f9-1f0e119412dd	USER_STATUS_UPDATED	user	12fcf2a8-0bcd-418f-b045-b86a3e365b43	{"is_active": false, "target_email": "cust1_f1b6ca98@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:56:48.604585+00
d7b21962-0f07-48b8-95ed-ef4f0092a809	a9dbd524-4906-43f3-9565-1a1dc3e68164	USER_REGISTERED	user	a9dbd524-4906-43f3-9565-1a1dc3e68164	{"role": "CUSTOMER", "email": "customer_9082194f@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:54.716176+00
4e4e228b-f088-49c7-9a05-8f85908f3341	c1c316c1-d0ea-4de2-a38e-8b0c34a96c1b	USER_REGISTERED	user	c1c316c1-d0ea-4de2-a38e-8b0c34a96c1b	{"role": "CUSTOMER", "email": "dup_d5f8168b@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:54.818812+00
a9d11de1-5c2e-4e88-9e99-adebe213f357	3154a4b6-3a58-467d-ad61-21f197e468ee	USER_REGISTERED	user	3154a4b6-3a58-467d-ad61-21f197e468ee	{"role": "CUSTOMER", "email": "login_user_e8bd0dc1@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:54.918132+00
23f1a21b-e1f8-4840-81c6-3d7babea0613	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	55ef6071-df63-4182-abe2-9cbf151bdad3	{"plan_id": "0086d29b-ddd9-4dc5-9ac0-3d74ea38cba4", "customer_id": "8a9d9a1d-6169-461f-8fad-82cfda34d74b", "total_amount": "1178.8200", "subscription_number": "SUB-202610-0026"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:23:57.805197+00
df3bc77b-44ce-4d7d-9ad1-d9868a4f8ccf	3154a4b6-3a58-467d-ad61-21f197e468ee	AUTH_LOGIN_SUCCESS	auth	3154a4b6-3a58-467d-ad61-21f197e468ee	{"role": "CUSTOMER", "email": "login_user_e8bd0dc1@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:55.057789+00
38dc7f50-6167-4d2e-a40f-0625bef347e3	fd65f38f-87cc-42a6-ab9a-7b804b139103	USER_REGISTERED	user	fd65f38f-87cc-42a6-ab9a-7b804b139103	{"role": "CUSTOMER", "email": "rotation_6aa0b9f2@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:55.132279+00
5783a98c-7cd1-4f49-92a7-0b5f97a4df46	fd65f38f-87cc-42a6-ab9a-7b804b139103	TOKEN_ROTATED	auth	fd65f38f-87cc-42a6-ab9a-7b804b139103	{"family_id": "eae1d466-da5f-4985-9449-225e3a3f6244"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:55.2096+00
1f78b496-7735-4e11-b1f8-7d5f7b392aff	fd65f38f-87cc-42a6-ab9a-7b804b139103	TOKEN_REUSE_DETECTED	auth	f7d628bf-727d-48f0-a538-e05239c92859	{"reason": "Attempted reuse of consumed token", "family_id": "eae1d466-da5f-4985-9449-225e3a3f6244"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:55.231271+00
be99298c-5e4a-4985-963e-1e48aeafb343	fd65f38f-87cc-42a6-ab9a-7b804b139103	TOKEN_REUSE_DETECTED	auth	746bc48c-d1f7-4139-bae1-42f7404bca61	{"reason": "Attempted reuse of consumed token", "family_id": "eae1d466-da5f-4985-9449-225e3a3f6244"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:55.248892+00
46d9a5cc-15b3-4b66-bc8b-b5ee706f1e99	8c3d9164-64db-4f25-bd84-c74a61f47a07	USER_REGISTERED	user	8c3d9164-64db-4f25-bd84-c74a61f47a07	{"role": "CUSTOMER", "email": "reset_013d69fa@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:55.2706+00
97fb7688-5d57-4751-88e5-caeb44c53969	8c3d9164-64db-4f25-bd84-c74a61f47a07	PASSWORD_RESET_REQUESTED	auth	8c3d9164-64db-4f25-bd84-c74a61f47a07	{"email": "reset_013d69fa@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:55.34629+00
656764a4-4def-47e1-b767-d063ba07e5b5	8c3d9164-64db-4f25-bd84-c74a61f47a07	PASSWORD_RESET_COMPLETED	auth	8c3d9164-64db-4f25-bd84-c74a61f47a07	{"email": "reset_013d69fa@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:55.40018+00
ba94b932-f3b0-4264-b6a7-bce36241d1c6	8c3d9164-64db-4f25-bd84-c74a61f47a07	AUTH_LOGIN_SUCCESS	auth	8c3d9164-64db-4f25-bd84-c74a61f47a07	{"role": "CUSTOMER", "email": "reset_013d69fa@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:55.53423+00
17a56779-521e-40ff-a0b8-aac56fda545c	0ee8c0fb-b477-4640-96f9-55e7f4e62d18	USER_REGISTERED	user	0ee8c0fb-b477-4640-96f9-55e7f4e62d18	{"role": "CUSTOMER", "email": "multi_reset_872da885@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:55.62166+00
bff6b950-4f22-43b4-a2e1-f50f6e104a25	0ee8c0fb-b477-4640-96f9-55e7f4e62d18	PASSWORD_RESET_REQUESTED	auth	0ee8c0fb-b477-4640-96f9-55e7f4e62d18	{"email": "multi_reset_872da885@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:55.704897+00
bb49bd18-e592-4e80-b001-26d0f194fb1d	0ee8c0fb-b477-4640-96f9-55e7f4e62d18	PASSWORD_RESET_REQUESTED	auth	0ee8c0fb-b477-4640-96f9-55e7f4e62d18	{"email": "multi_reset_872da885@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:55.750976+00
46c8d44c-ad5a-459f-af3a-163f7fbf4823	ef934208-21d3-43e9-9451-426a3526c623	USER_REGISTERED	user	ef934208-21d3-43e9-9451-426a3526c623	{"role": "CUSTOMER", "email": "logout_no_jwt_6878d751@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:55.814069+00
54cd86e1-24af-4afb-979e-8c1b3680d82a	ef934208-21d3-43e9-9451-426a3526c623	TOKEN_REUSE_DETECTED	auth	c91448fe-ffb1-4f37-a699-aa7322ea6b57	{"reason": "Attempted reuse of consumed token", "family_id": "b7fc5b20-4b73-47d7-a412-e0a13e865e4b"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:55.916082+00
af99a7d6-0868-411d-a5e9-4c1902faf6fb	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	9d3c3d84-ca09-4f7b-8010-cbcd9e9a2e8d	{"email": "customer_8a0265cf@example.com", "user_id": "86e39d83-656a-4a5f-b96d-9ee66a6620ca", "customer_number": "CUST-2026-0001"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:56.330857+00
b8ee1111-aefd-4853-9c19-f6a41d6c4187	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	27c92d51-b12b-4c5e-b05a-4bb416e31ea4	{"sku": "SEC-E1AC4", "name": "Cloud Security Suite", "currency": "INR", "sales_price": "2000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:56.679875+00
2483668f-b7b9-4e60-ad36-ab9ad50d1dbe	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	2ca2f32b-f68e-48e7-9c09-4baf61d9398f	{"code": "PLAN-SEC-D2571", "name": "Security Pro Monthly", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:56.717156+00
b1315b79-9b0c-43da-9c6d-f775a50031f6	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	89e53b25-16d2-4096-b4d6-2333d6b1cb93	{"plan_id": "2ca2f32b-f68e-48e7-9c09-4baf61d9398f", "quantity": 1, "product_id": "27c92d51-b12b-4c5e-b05a-4bb416e31ea4", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:56.751532+00
64c9aeda-30b6-4598-afcf-7c25e67d02b2	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	26f84f34-1499-418a-96e0-bc6600944e48	{"sku": "INR-A58921", "name": "INR Service", "currency": "INR", "sales_price": "1000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:56.97341+00
6e7f5d48-c761-4c38-abaf-a2e8a7748aa8	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	e3a078ec-80ca-4ea1-bea2-363927191966	{"sku": "USD-0B73E7", "name": "USD Service", "currency": "USD", "sales_price": "50.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:57.002483+00
92e21113-0f4e-44df-984a-b72704645d35	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	9b79b0a2-506a-4c3b-b87b-119f948e2ac8	{"code": "PLAN-INR-22102B", "name": "Enterprise INR Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:57.02943+00
488f6146-81ec-49ac-99d4-dcb19e4c03de	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	4a7471fc-bd4e-4068-9944-4e3e52b523c8	{"plan_id": "9b79b0a2-506a-4c3b-b87b-119f948e2ac8", "quantity": 2, "product_id": "26f84f34-1499-418a-96e0-bc6600944e48", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:57.082845+00
7de3eac3-ac5c-46e5-b861-3e57c4a4d6fc	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	42f65e61-0335-4f69-8bf9-ed8ef63465e5	{"code": "GUARD-9AB7A2", "name": "Empty Draft Plan", "currency": "INR", "billing_interval": "YEARLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:57.147977+00
1ee9b471-cd59-466c-bf98-5ca1bfcaaf8f	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	d83d7b84-4d47-426e-8b1b-b7e3a99a02d3	{"sku": "BASE-999E56", "name": "Base Software", "currency": "INR", "sales_price": "3000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:57.197927+00
40becf37-28ae-4110-afb8-01b65778b1d7	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	168cf881-a76d-4ed3-a850-6e58c5332461	{"plan_id": "42f65e61-0335-4f69-8bf9-ed8ef63465e5", "quantity": 1, "product_id": "d83d7b84-4d47-426e-8b1b-b7e3a99a02d3", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:57.224605+00
4238d8e0-eddf-4106-9b0d-b36c0d87db67	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	42f65e61-0335-4f69-8bf9-ed8ef63465e5	{"code": "GUARD-9AB7A2", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:57.254923+00
1141cd36-b7f9-475a-86d5-4bf4c50276be	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	42f65e61-0335-4f69-8bf9-ed8ef63465e5	{"code": "GUARD-9AB7A2", "new_status": "INACTIVE", "old_status": "INACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:57.29687+00
b07cf67a-24e3-42bc-83cb-baf52861bba7	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	42f65e61-0335-4f69-8bf9-ed8ef63465e5	{"code": "GUARD-9AB7A2", "new_status": "ARCHIVED", "old_status": "ARCHIVED"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:57.335841+00
3e6e8095-6897-47eb-bcef-f13c8f26f9c5	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	2641368d-ece5-41b8-98d6-50367dafc985	{"sku": "AC-26A1C7", "name": "Auto Close Product", "currency": "INR", "sales_price": "1500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:57.419779+00
a442fbe8-279a-437e-9a65-ebdb046dec22	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	777c8b66-be1d-4560-87e3-289d56a3fece	{"code": "AUTO-A943BB", "name": "Limited Time Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:57.447869+00
a7046f63-5918-498d-b6b3-2ae333dbfc10	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	777c8b66-be1d-4560-87e3-289d56a3fece	{"code": "AUTO-A943BB", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:57.491187+00
5e0d8876-a589-41a3-900e-14270471d1ce	\N	PLAN_AUTO_CLOSED	SUBSCRIPTION_PLAN	777c8b66-be1d-4560-87e3-289d56a3fece	{"code": "AUTO-A943BB", "reason": "Availability end date '2026-10-31 04:57:57.441200+00:00' reached."}	\N	\N	2026-10-31 06:57:57.491187+00
fb2ff7ad-ae0d-44cc-8d16-8ad76d8f1d06	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	2ce2ddd9-fbfc-4ed4-8d98-80e4f09b97f6	{"sku": "CRM-A27282", "name": "CRM Software", "currency": "INR", "sales_price": "2000.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:57.583235+00
bb6443ba-1acd-42e7-9ebc-9dd305117fc6	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	383d0b44-7758-49ef-a7d4-cdd7b41a552e	{"code": "CRM-PLAN-E2EEE5", "name": "CRM Standard Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:57.622497+00
ae3f228b-6d60-4e51-b305-ff97af3a6554	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	5d37e206-c4f4-4ce1-949e-26ea56874e07	{"plan_id": "383d0b44-7758-49ef-a7d4-cdd7b41a552e", "quantity": 3, "product_id": "2ce2ddd9-fbfc-4ed4-8d98-80e4f09b97f6", "variant_id": "a0559654-7d26-4f01-a04f-dda83c0edee0", "price_override": "2200.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:57.650182+00
d85a8cce-06bd-4852-8298-04f2b6a522e7	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_UPDATED	PLAN_PRODUCT	5d37e206-c4f4-4ce1-949e-26ea56874e07	{"plan_id": "383d0b44-7758-49ef-a7d4-cdd7b41a552e", "quantity": 5, "is_active": true}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:57.723513+00
6e4ea8c0-72f9-451e-b1a5-9ee8bc04c3e5	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_REMOVED	PLAN_PRODUCT	5d37e206-c4f4-4ce1-949e-26ea56874e07	{"plan_id": "383d0b44-7758-49ef-a7d4-cdd7b41a552e"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:57.80711+00
4373f8fa-6e9b-46c3-a685-2a54f958e4f1	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	f584e165-c6aa-49ef-8f1c-e85c6c6ef708	{"sku": "ERP-40B008", "name": "ERP Financials", "currency": "INR", "sales_price": "2000.0000", "variants_count": 2}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:57.889803+00
2f8d5b7a-55ee-4a47-91d8-c980230e5697	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	79fec419-75c1-4edf-81d6-a288b3755330	{"sku": "SW-023B7E", "name": "Standard Software", "currency": "INR", "sales_price": "5000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:57.977655+00
2bcb6539-472b-4cbf-af2d-38f077114504	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	59b29da9-cc1e-498a-b178-ab4465418044	{"sku": "INR-CCA9AF", "name": "INR Product", "currency": "INR", "sales_price": "100.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:58.042303+00
1b11cf88-ee29-44e7-ae98-c760fc9d159f	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	b424bbf3-e5ba-4fff-952c-09798d164e6f	{"sku": "SKU-7B8F84", "name": "Brightloop ERP Cloud", "currency": "INR", "sales_price": "2000.0000", "variants_count": 2}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:58.121428+00
003dd710-1df7-4e6c-8e8d-a746f747fa7a	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_CREATED	PRODUCT_VARIANT	dac2de5d-9451-4bb1-b5b9-31bfc5a35283	{"product_id": "b424bbf3-e5ba-4fff-952c-09798d164e6f", "variant_code": "ENT", "variant_name": "Enterprise Addon", "adjustment_type": "PERCENTAGE", "adjustment_value": "25.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:58.190747+00
f7d90728-b874-4d2d-8161-7a4b44cfe57f	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	129fd1cb-d109-4b96-97f2-b00736810e4b	{"sku": "RBAC-8868B7", "name": "Admin Product", "currency": "INR", "sales_price": "500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:58.321459+00
1a0e52d0-ce44-4c67-b3a9-8da798abdf2d	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	6efd9ced-9483-4f1a-a825-1e060928e307	{"sku": "HIST-07916E", "name": "History Test Product", "currency": "INR", "sales_price": "1000.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:58.391548+00
c62635f9-4252-4b54-b17b-cd3d3ec8c96b	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_UPDATED	PRODUCT	6efd9ced-9483-4f1a-a825-1e060928e307	{"sku": "HIST-07916E", "name": "History Test Product", "reason": "Annual inflation rate increase", "price_changes": {"cost_price": {"new": "450.0000", "old": "300.0000"}, "sales_price": {"new": "1500.0000", "old": "1000.0000"}}}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:58.42399+00
cbd255e8-a378-4274-8d99-19dfb9c7e94a	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_UPDATED	PRODUCT_VARIANT	75e8ab88-d794-43e4-9510-2f6577bd1ab8	{"variant_code": "PRO", "variant_name": "Pro Pack", "adjustment_type": "PERCENTAGE", "adjustment_value": "30.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:58.464766+00
480a0d15-461b-4328-ba4b-943313a69f47	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	cd8a2e3d-1839-4802-a654-08cdf79eb7cb	{"sku": "ARCH-8C8462", "name": "To Archive Product", "currency": "INR", "sales_price": "750.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:58.513056+00
895632ff-382b-4896-951d-3a80fa2fb95d	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_ARCHIVED	PRODUCT	cd8a2e3d-1839-4802-a654-08cdf79eb7cb	{"sku": "ARCH-8C8462", "name": "To Archive Product", "deactivated_plan_line_items": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:58.549589+00
747ab149-c4da-45f6-b561-8f94962f4b02	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_DEACTIVATED	PRODUCT_VARIANT	1b428e94-dc86-4434-bdd6-07e7b41c9ebd	{"variant_code": "VA", "variant_name": "Variant A", "deactivated_plan_line_items": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:58.585438+00
3bbc55eb-aa2f-44cb-86ef-30bf25e22350	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	56739bff-c037-4087-95b3-bb4c35c05732	{"sku": "PROD-SUB-094FC", "name": "Cloud CRM Platform", "currency": "INR", "sales_price": "5000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:58.850321+00
8e71b143-ad25-430a-8cbf-3dbfc01ef3de	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	c6186b0e-5ace-4203-a620-1231bb6a822c	{"code": "PLAN-CRM-855BF", "name": "Enterprise CRM Annual", "currency": "INR", "billing_interval": "YEARLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:58.879874+00
dcb23dcb-6788-4305-9e6d-526d37a63917	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	7aa45ea7-75a3-4c43-8de5-8b6c5d6b0af2	{"plan_id": "c6186b0e-5ace-4203-a620-1231bb6a822c", "quantity": 2, "product_id": "56739bff-c037-4087-95b3-bb4c35c05732", "variant_id": null, "price_override": "4500.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:58.90483+00
499fac6c-dff1-485e-a0da-af7b12d88752	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:58.940972+00
9c9c2277-6d80-4074-aeb8-81e0d5d09355	dc41ff91-d203-479c-ab89-c1ca59c3f3f3	USER_REGISTERED	user	dc41ff91-d203-479c-ab89-c1ca59c3f3f3	{"role": "CUSTOMER", "email": "cust1_211f0517@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:59.01048+00
ae569e82-e73f-4482-ba4b-ddc020b71710	14717e01-a79b-4bdd-a7cf-6a79edbe15ca	USER_REGISTERED	user	14717e01-a79b-4bdd-a7cf-6a79edbe15ca	{"role": "CUSTOMER", "email": "cust2_f9e6c7bc@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:59.093527+00
4f70d5f9-ad92-483b-93fe-06a221690bba	5040313c-9900-4630-93f9-1f0e119412dd	STAFF_CREATED	user	94c223b6-7cf9-490c-b244-b8184c45c9d6	{"role": "STAFF", "created_email": "staff_716e2d75@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:59.239138+00
8354a7d3-bfe4-4cfa-ace3-d2c8e0d4ae52	94c223b6-7cf9-490c-b244-b8184c45c9d6	AUTH_LOGIN_SUCCESS	auth	94c223b6-7cf9-490c-b244-b8184c45c9d6	{"role": "STAFF", "email": "staff_716e2d75@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:59.309029+00
d8865261-1fff-4f73-bdec-4f8f2c03095c	5040313c-9900-4630-93f9-1f0e119412dd	USER_STATUS_UPDATED	user	dc41ff91-d203-479c-ab89-c1ca59c3f3f3	{"is_active": false, "target_email": "cust1_211f0517@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 06:57:59.483746+00
e93af9aa-f95c-419c-8413-a29125218bed	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	55ef6071-df63-4182-abe2-9cbf151bdad3	{"reason": "Sent commercial proposal", "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:23:57.9012+00
775bc75d-57fd-4c06-948b-d833b0206b3a	7285aedf-bec0-472a-ac22-a2e63c91662c	USER_REGISTERED	user	7285aedf-bec0-472a-ac22-a2e63c91662c	{"role": "CUSTOMER", "email": "customer_5cdb35d8@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:01.26288+00
d4bce10c-c903-4892-b894-2d86f116fca5	bd79e4fc-af1a-494f-b781-9a704b44e479	USER_REGISTERED	user	bd79e4fc-af1a-494f-b781-9a704b44e479	{"role": "CUSTOMER", "email": "dup_c64a41e3@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:01.37425+00
d0d19bfa-3f38-4b3b-b826-aa558bc52554	052060c6-0beb-4e7d-8fd7-08856f7e1ec9	USER_REGISTERED	user	052060c6-0beb-4e7d-8fd7-08856f7e1ec9	{"role": "CUSTOMER", "email": "login_user_a9ced511@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:01.475425+00
afa0dd55-81b7-49d4-98c6-29f68e891f38	9da9137d-e784-4775-b856-e577b39a1e06	TOKEN_REUSE_DETECTED	auth	0f178aa8-8032-42c8-87c5-bdf6cee35309	{"reason": "Attempted reuse of consumed token", "family_id": "82a5a71e-f00e-4391-a762-d339bf15402b"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:08.170657+00
aa1bca2a-11cd-40c9-8f71-3516465e124c	052060c6-0beb-4e7d-8fd7-08856f7e1ec9	AUTH_LOGIN_SUCCESS	auth	052060c6-0beb-4e7d-8fd7-08856f7e1ec9	{"role": "CUSTOMER", "email": "login_user_a9ced511@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:01.623097+00
9a59b260-4e21-4568-8eea-93e54f55e966	9997dea5-958b-4168-8e34-cbce8da19cba	USER_REGISTERED	user	9997dea5-958b-4168-8e34-cbce8da19cba	{"role": "CUSTOMER", "email": "rotation_43fdd08b@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:01.692273+00
d158ca78-fcfa-4ab3-ba5f-5a300916edab	9997dea5-958b-4168-8e34-cbce8da19cba	TOKEN_ROTATED	auth	9997dea5-958b-4168-8e34-cbce8da19cba	{"family_id": "32d6fe83-c95d-40f7-9d79-fcf6a2e305c8"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:01.770935+00
e2ef8b75-5d26-455b-8f26-b4d08c6dc92c	9997dea5-958b-4168-8e34-cbce8da19cba	TOKEN_REUSE_DETECTED	auth	99708784-ca57-4d9c-b193-1192d345bd8b	{"reason": "Attempted reuse of consumed token", "family_id": "32d6fe83-c95d-40f7-9d79-fcf6a2e305c8"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:01.790648+00
551d6b25-3776-4f36-96f4-8e43fac43134	9997dea5-958b-4168-8e34-cbce8da19cba	TOKEN_REUSE_DETECTED	auth	2f93c9e6-8fb4-48c6-856b-60b8557be279	{"reason": "Attempted reuse of consumed token", "family_id": "32d6fe83-c95d-40f7-9d79-fcf6a2e305c8"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:01.809198+00
d594c761-8ee0-4241-8a8d-74d0cfcf12a0	9454fb0f-4bec-4f35-8752-0ff0c45850ad	USER_REGISTERED	user	9454fb0f-4bec-4f35-8752-0ff0c45850ad	{"role": "CUSTOMER", "email": "reset_f1c7eb8f@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:01.830447+00
4b485727-174d-4c55-b177-72c3be73de66	9454fb0f-4bec-4f35-8752-0ff0c45850ad	PASSWORD_RESET_REQUESTED	auth	9454fb0f-4bec-4f35-8752-0ff0c45850ad	{"email": "reset_f1c7eb8f@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:01.908312+00
239be5b6-8b8e-46e4-8522-48fe4ebc671f	9454fb0f-4bec-4f35-8752-0ff0c45850ad	PASSWORD_RESET_COMPLETED	auth	9454fb0f-4bec-4f35-8752-0ff0c45850ad	{"email": "reset_f1c7eb8f@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:01.957267+00
82ff3f73-ed8a-461a-a509-28088486a59c	9454fb0f-4bec-4f35-8752-0ff0c45850ad	AUTH_LOGIN_SUCCESS	auth	9454fb0f-4bec-4f35-8752-0ff0c45850ad	{"role": "CUSTOMER", "email": "reset_f1c7eb8f@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:02.093234+00
ec3d49a0-1818-4c26-9e3b-df45f890ecb4	ef162596-be5a-46c7-b5c9-96fffde7649e	USER_REGISTERED	user	ef162596-be5a-46c7-b5c9-96fffde7649e	{"role": "CUSTOMER", "email": "multi_reset_5c960c5d@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:02.17639+00
5f7262b9-789e-4dcb-a819-37d3fe074481	ef162596-be5a-46c7-b5c9-96fffde7649e	PASSWORD_RESET_REQUESTED	auth	ef162596-be5a-46c7-b5c9-96fffde7649e	{"email": "multi_reset_5c960c5d@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:02.256941+00
d80eb2c9-48a7-42c8-a82a-a941be9b7304	ef162596-be5a-46c7-b5c9-96fffde7649e	PASSWORD_RESET_REQUESTED	auth	ef162596-be5a-46c7-b5c9-96fffde7649e	{"email": "multi_reset_5c960c5d@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:02.300859+00
2c7a67a0-2409-4cdc-984b-b779437f9ea4	b1d34f68-343e-4b28-9091-6a9d6962b7ec	USER_REGISTERED	user	b1d34f68-343e-4b28-9091-6a9d6962b7ec	{"role": "CUSTOMER", "email": "logout_no_jwt_ca7868d0@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:02.359036+00
c416987b-aa13-485c-93df-ee5329ba9aa2	b1d34f68-343e-4b28-9091-6a9d6962b7ec	TOKEN_REUSE_DETECTED	auth	9e48b18d-9219-4a4c-bc53-84d26d3e2dea	{"reason": "Attempted reuse of consumed token", "family_id": "e3949227-1100-41ab-90ac-0edc924da6b8"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:02.453428+00
0806c830-b003-4b05-b6d6-9c6e3cd0e5dd	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	ec449749-6f32-41e4-ac37-bcfcdffb15aa	{"sku": "SEC-EC79A", "name": "Cloud Security Suite", "currency": "INR", "sales_price": "2000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:03.222637+00
0c861a30-0005-4b45-a6a9-e2979b650b97	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	de9962cf-ac9f-4f88-80c8-1cdac851d647	{"code": "PLAN-SEC-DEC0E", "name": "Security Pro Monthly", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:03.259946+00
ef38dadd-31a7-4aa2-b0f7-a7b9973b7503	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	0fa49024-26ba-4446-818f-5dff6775191d	{"plan_id": "de9962cf-ac9f-4f88-80c8-1cdac851d647", "quantity": 1, "product_id": "ec449749-6f32-41e4-ac37-bcfcdffb15aa", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:03.29679+00
e87d2914-ff9e-43cd-9e4b-d5f7bac06ec6	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	de9962cf-ac9f-4f88-80c8-1cdac851d647	{"code": "PLAN-SEC-DEC0E", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:03.330547+00
6f982f8d-2fef-41b5-a9d3-1d3175c7b509	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	1a7b37b3-13b2-47a3-ad9e-59476f54fde4	{"sku": "INR-B4AE55", "name": "INR Service", "currency": "INR", "sales_price": "1000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:03.585235+00
ab5248f9-0382-48b3-9a2e-19979a7f333e	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	dbb65843-0e0b-43ba-9f98-c849f4c084e7	{"sku": "USD-313AC1", "name": "USD Service", "currency": "USD", "sales_price": "50.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:03.613693+00
2d1a88da-9b25-43cf-add5-b8d9e0bbaf4a	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	117a6864-250c-43d3-be06-27ba2f039e5c	{"code": "PLAN-INR-C9C768", "name": "Enterprise INR Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:03.641749+00
3774062c-9c18-4110-ba11-7e9ebd5e26dd	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	6f169605-ba28-4932-9c72-739573c38bb4	{"plan_id": "117a6864-250c-43d3-be06-27ba2f039e5c", "quantity": 2, "product_id": "1a7b37b3-13b2-47a3-ad9e-59476f54fde4", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:03.691969+00
f35b9487-0b4f-4b6f-9296-ab3d6f5112d6	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	41ef282a-db52-430a-b1e6-edf0491923c6	{"code": "GUARD-F554CC", "name": "Empty Draft Plan", "currency": "INR", "billing_interval": "YEARLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:03.74147+00
067cabc2-321f-4574-9762-d6c6bb2e6a65	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	aec1dd88-b055-432e-b06e-f5ff5c1b646d	{"sku": "BASE-CF9C26", "name": "Base Software", "currency": "INR", "sales_price": "3000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:03.787789+00
f1de3c54-6de6-4e24-ae4a-19133d00e4fb	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	0d69dfc9-061a-46d1-8a78-e10c1facbd7e	{"plan_id": "41ef282a-db52-430a-b1e6-edf0491923c6", "quantity": 1, "product_id": "aec1dd88-b055-432e-b06e-f5ff5c1b646d", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:03.818133+00
1e4917c6-8f95-4047-a750-5ae061a9b54b	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	41ef282a-db52-430a-b1e6-edf0491923c6	{"code": "GUARD-F554CC", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:03.850551+00
f89df8cd-5fa9-4a93-8ce8-244944feff6d	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	41ef282a-db52-430a-b1e6-edf0491923c6	{"code": "GUARD-F554CC", "new_status": "INACTIVE", "old_status": "INACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:03.892672+00
900fc0c3-53f6-4be7-b0b6-d2353b34244b	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	41ef282a-db52-430a-b1e6-edf0491923c6	{"code": "GUARD-F554CC", "new_status": "ARCHIVED", "old_status": "ARCHIVED"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:03.934695+00
f527ea84-3fc4-488e-a907-36aad7f7c218	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	4ba0da92-15b8-40b9-b909-6d56804c20a5	{"sku": "AC-294B31", "name": "Auto Close Product", "currency": "INR", "sales_price": "1500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:04.012099+00
9bd8c646-26ec-47d1-b3e6-c5d781c689b1	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	611849fd-1a00-42b7-b8dd-1c5a045efb2d	{"code": "AUTO-00C0AE", "name": "Limited Time Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:04.041625+00
2b3757b3-0268-4a2d-8d79-0c4d576a6d77	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	611849fd-1a00-42b7-b8dd-1c5a045efb2d	{"code": "AUTO-00C0AE", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:04.082866+00
28ab9b96-2498-4d77-8453-793088b00266	\N	PLAN_AUTO_CLOSED	SUBSCRIPTION_PLAN	611849fd-1a00-42b7-b8dd-1c5a045efb2d	{"code": "AUTO-00C0AE", "reason": "Availability end date '2026-10-31 05:01:04.034958+00:00' reached."}	\N	\N	2026-10-31 07:01:04.082866+00
76204cb4-8516-4727-aa30-a7cbd3a4ed06	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	89b050d6-580f-4d2a-b3d5-e2302e098e0a	{"sku": "CRM-439A29", "name": "CRM Software", "currency": "INR", "sales_price": "2000.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:04.176984+00
12e78fcf-6162-49c4-b1ae-943a9c1b4b22	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	8ac21648-3cc0-4863-88ac-b14df0fa1a95	{"code": "CRM-PLAN-4433B0", "name": "CRM Standard Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:04.214058+00
dca2328e-b758-43c3-9a18-78f34d6eb489	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	130c4ffb-0c26-47b5-a3c1-791f0eadc863	{"plan_id": "8ac21648-3cc0-4863-88ac-b14df0fa1a95", "quantity": 3, "product_id": "89b050d6-580f-4d2a-b3d5-e2302e098e0a", "variant_id": "1c64c824-6536-4e25-b7ea-4ae90ccf9a6c", "price_override": "2200.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:04.242027+00
981fe7fb-9a26-4848-8350-506d37e7a038	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_UPDATED	PLAN_PRODUCT	130c4ffb-0c26-47b5-a3c1-791f0eadc863	{"plan_id": "8ac21648-3cc0-4863-88ac-b14df0fa1a95", "quantity": 5, "is_active": true}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:04.311237+00
a967e566-db8e-4796-86e4-664af2776edf	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_REMOVED	PLAN_PRODUCT	130c4ffb-0c26-47b5-a3c1-791f0eadc863	{"plan_id": "8ac21648-3cc0-4863-88ac-b14df0fa1a95"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:04.405257+00
869a4f01-a323-452e-bd62-cf0eef2e4824	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	dcadd733-135a-4805-b06b-b64fb797e0d4	{"sku": "ERP-F2401C", "name": "ERP Financials", "currency": "INR", "sales_price": "2000.0000", "variants_count": 2}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:04.484265+00
186cf565-44c9-4edc-b0a6-29b62b7b05b3	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	bff5887a-24e0-49bf-bf0e-06a8e356708c	{"sku": "SW-0A1A8E", "name": "Standard Software", "currency": "INR", "sales_price": "5000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:04.572516+00
0eb77955-4080-4d0a-93e7-ad810c3cc490	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	80c46f8b-f67a-4adb-a093-adecd4aaf89f	{"sku": "INR-86A747", "name": "INR Product", "currency": "INR", "sales_price": "100.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:04.636933+00
0977f79f-98ad-4b7e-831d-85f2ddb42860	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	da10e298-6d0d-4547-a7f3-403e4900837e	{"sku": "SKU-F12635", "name": "Brightloop ERP Cloud", "currency": "INR", "sales_price": "2000.0000", "variants_count": 2}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:04.718922+00
4262b144-a9ec-44f9-abd6-ae84801ef7aa	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_CREATED	PRODUCT_VARIANT	887d0e72-05f5-4794-8775-7edc39c55b03	{"product_id": "da10e298-6d0d-4547-a7f3-403e4900837e", "variant_code": "ENT", "variant_name": "Enterprise Addon", "adjustment_type": "PERCENTAGE", "adjustment_value": "25.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:04.786595+00
09ec78fe-8603-4fad-a431-ae1d460f6c25	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	244411b9-f877-4e5e-b38e-6667d74a54c8	{"sku": "RBAC-68379E", "name": "Admin Product", "currency": "INR", "sales_price": "500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:04.916884+00
c96f731c-f9ec-426a-ac9c-03c6183bc3b5	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	af3e7ff0-ad14-4014-911c-29a00143c4c9	{"sku": "HIST-597567", "name": "History Test Product", "currency": "INR", "sales_price": "1000.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:04.987565+00
f4e8252c-a2f8-4be7-b77b-992cd0db0a96	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_UPDATED	PRODUCT	af3e7ff0-ad14-4014-911c-29a00143c4c9	{"sku": "HIST-597567", "name": "History Test Product", "reason": "Annual inflation rate increase", "price_changes": {"cost_price": {"new": "450.0000", "old": "300.0000"}, "sales_price": {"new": "1500.0000", "old": "1000.0000"}}}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:05.021061+00
ae636408-0116-449c-b074-1df22e2f60b3	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_UPDATED	PRODUCT_VARIANT	7e83e4b5-871d-4dd7-8bd6-081d90189851	{"variant_code": "PRO", "variant_name": "Pro Pack", "adjustment_type": "PERCENTAGE", "adjustment_value": "30.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:05.054887+00
46c642fe-b4bb-4f7f-8c27-5b7d97980865	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	73fde76b-895e-448f-9937-68b57e886cec	{"sku": "ARCH-EA187B", "name": "To Archive Product", "currency": "INR", "sales_price": "750.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:05.097802+00
d19d69ca-ea99-4789-b3eb-49ada5b95263	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_ARCHIVED	PRODUCT	73fde76b-895e-448f-9937-68b57e886cec	{"sku": "ARCH-EA187B", "name": "To Archive Product", "deactivated_plan_line_items": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:05.129126+00
6590bbdc-e550-462d-907e-7a39a5c7b6aa	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_DEACTIVATED	PRODUCT_VARIANT	10c9d83a-c2f2-4e06-9bd1-9abba908535b	{"variant_code": "VA", "variant_name": "Variant A", "deactivated_plan_line_items": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:05.164967+00
b8f51cb3-d22b-410a-a8c1-33c8d980ce76	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	dda6994b-3b5c-468d-817c-fe2a53ce5ec3	{"sku": "PROD-SUB-E2F3B", "name": "Cloud CRM Platform", "currency": "INR", "sales_price": "5000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:05.403993+00
a7b69e32-2a7c-4286-a01f-bc052a93db60	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	de14b5ef-30b4-4c34-9855-9f041f222fcb	{"code": "PLAN-CRM-95731", "name": "Enterprise CRM Annual", "currency": "INR", "billing_interval": "YEARLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:05.429467+00
4b908792-b1e1-4d01-86a6-ededf3d1c3fb	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	f240fbd5-8eb0-4715-8cc6-3684178d1760	{"plan_id": "de14b5ef-30b4-4c34-9855-9f041f222fcb", "quantity": 2, "product_id": "dda6994b-3b5c-468d-817c-fe2a53ce5ec3", "variant_id": null, "price_override": "4500.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:05.45331+00
11c9522a-8d16-4b8e-9473-ca29ae4893e9	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	de14b5ef-30b4-4c34-9855-9f041f222fcb	{"code": "PLAN-CRM-95731", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:05.480124+00
bbbf6706-30af-4e75-914d-03a981418b4c	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:05.687536+00
061e092a-22e6-401e-9b4d-d29800a84775	4396aa50-9bab-4349-8eef-cbde4ec50b3d	USER_REGISTERED	user	4396aa50-9bab-4349-8eef-cbde4ec50b3d	{"role": "CUSTOMER", "email": "cust1_3d3b7595@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:05.75911+00
0a171da8-fa8a-4822-8cb2-660c2af9b053	732aab7b-d07d-42f4-8f2e-e4ebb31bab45	USER_REGISTERED	user	732aab7b-d07d-42f4-8f2e-e4ebb31bab45	{"role": "CUSTOMER", "email": "cust2_7b31f2d7@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:05.836726+00
fa953006-99d6-4535-9015-0f87c316a523	5040313c-9900-4630-93f9-1f0e119412dd	STAFF_CREATED	user	0fbbf616-93e4-4ce8-ae5a-80ee0780422e	{"role": "STAFF", "created_email": "staff_764c6227@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:05.982777+00
59929dc2-0af6-4ed7-8893-b1297acfd5ba	0fbbf616-93e4-4ce8-ae5a-80ee0780422e	AUTH_LOGIN_SUCCESS	auth	0fbbf616-93e4-4ce8-ae5a-80ee0780422e	{"role": "STAFF", "email": "staff_764c6227@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:06.050405+00
c7491cd2-761f-4895-85ae-266fd515771f	5040313c-9900-4630-93f9-1f0e119412dd	USER_STATUS_UPDATED	user	4396aa50-9bab-4349-8eef-cbde4ec50b3d	{"is_active": false, "target_email": "cust1_3d3b7595@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:06.22384+00
c16801e4-50e4-42ef-a72c-c7c1e16caf4f	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	55ef6071-df63-4182-abe2-9cbf151bdad3	{"reason": "Proposal signed by client", "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:23:57.97134+00
3382b070-bfb2-48d9-bea6-8cf21ea1f345	b1e6be92-ec85-4cca-a299-b325aa4567d4	USER_REGISTERED	user	b1e6be92-ec85-4cca-a299-b325aa4567d4	{"role": "CUSTOMER", "email": "customer_f1218604@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:36.90258+00
24b78781-ded8-474e-858c-6aaab279389f	10928483-3589-4bcc-ac16-474f6dde1852	USER_REGISTERED	user	10928483-3589-4bcc-ac16-474f6dde1852	{"role": "CUSTOMER", "email": "dup_c1080a57@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:37.008228+00
53681b08-a5e8-41a4-bbae-c51179e293ac	1943c312-634a-4ab3-b6fe-fa2081ec0dbd	USER_REGISTERED	user	1943c312-634a-4ab3-b6fe-fa2081ec0dbd	{"role": "CUSTOMER", "email": "login_user_bea0db1b@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:37.106345+00
96c7e18b-5913-4a33-8cc7-c75be605bb97	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:08.564134+00
5b704426-61f1-4197-98c9-3f2d35b182bd	1943c312-634a-4ab3-b6fe-fa2081ec0dbd	AUTH_LOGIN_SUCCESS	auth	1943c312-634a-4ab3-b6fe-fa2081ec0dbd	{"role": "CUSTOMER", "email": "login_user_bea0db1b@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:37.256054+00
4f52a841-ff2b-457a-a448-028f53094ea0	1811d575-46d3-4f84-8a1c-85d8e2504dac	USER_REGISTERED	user	1811d575-46d3-4f84-8a1c-85d8e2504dac	{"role": "CUSTOMER", "email": "rotation_3f5bacf4@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:37.330017+00
25ea8c3d-3d4e-48d3-98d4-18f9912e7913	1811d575-46d3-4f84-8a1c-85d8e2504dac	TOKEN_ROTATED	auth	1811d575-46d3-4f84-8a1c-85d8e2504dac	{"family_id": "cd47ef46-6360-4e4b-97be-bac4d22590c5"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:37.407163+00
8869861c-8ae9-41f9-b2fc-8628298d3524	1811d575-46d3-4f84-8a1c-85d8e2504dac	TOKEN_REUSE_DETECTED	auth	5281da18-56c1-45be-842c-14a17c1e9b3b	{"reason": "Attempted reuse of consumed token", "family_id": "cd47ef46-6360-4e4b-97be-bac4d22590c5"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:37.428886+00
a720efff-1290-420e-91aa-75e4b393af35	1811d575-46d3-4f84-8a1c-85d8e2504dac	TOKEN_REUSE_DETECTED	auth	f6d7ab30-584e-48fd-9e10-b379ed269175	{"reason": "Attempted reuse of consumed token", "family_id": "cd47ef46-6360-4e4b-97be-bac4d22590c5"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:37.446618+00
093ab67e-450e-4f04-9b96-85f14163185f	79afecfb-a64b-47a2-813c-72f6eec196c4	USER_REGISTERED	user	79afecfb-a64b-47a2-813c-72f6eec196c4	{"role": "CUSTOMER", "email": "reset_fe205b7b@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:37.477638+00
c012d2e8-2d43-4862-8957-84f323292e09	79afecfb-a64b-47a2-813c-72f6eec196c4	PASSWORD_RESET_REQUESTED	auth	79afecfb-a64b-47a2-813c-72f6eec196c4	{"email": "reset_fe205b7b@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:37.563723+00
11814a2c-ba78-4026-a58c-de4cc479fb67	79afecfb-a64b-47a2-813c-72f6eec196c4	PASSWORD_RESET_COMPLETED	auth	79afecfb-a64b-47a2-813c-72f6eec196c4	{"email": "reset_fe205b7b@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:37.623606+00
d1fd5c19-27f1-42a2-9591-732c2557da14	5040313c-9900-4630-93f9-1f0e119412dd	STAFF_CREATED	user	5c45be20-2ccb-4a5c-a8cd-97cfad043ed8	{"role": "STAFF", "created_email": "staff_6da5635c@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:22.124108+00
00572e46-1d26-4057-ab18-ad1223b4b21b	79afecfb-a64b-47a2-813c-72f6eec196c4	AUTH_LOGIN_SUCCESS	auth	79afecfb-a64b-47a2-813c-72f6eec196c4	{"role": "CUSTOMER", "email": "reset_fe205b7b@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:37.756645+00
eb977ded-1f4b-44fb-b262-855054a902bd	07c13107-a120-4937-b7bb-b235ecc5b8c4	USER_REGISTERED	user	07c13107-a120-4937-b7bb-b235ecc5b8c4	{"role": "CUSTOMER", "email": "multi_reset_0997a18f@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:37.843828+00
744381fa-e97e-41b8-a695-7e57776ca0cd	07c13107-a120-4937-b7bb-b235ecc5b8c4	PASSWORD_RESET_REQUESTED	auth	07c13107-a120-4937-b7bb-b235ecc5b8c4	{"email": "multi_reset_0997a18f@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:37.922781+00
598d23cd-04e4-4c52-af99-f1372e5a1a11	07c13107-a120-4937-b7bb-b235ecc5b8c4	PASSWORD_RESET_REQUESTED	auth	07c13107-a120-4937-b7bb-b235ecc5b8c4	{"email": "multi_reset_0997a18f@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:37.968453+00
d556ffb7-a24f-4cde-8716-890a296ee5af	9bd376ca-84e7-48cd-a91e-9002151bf344	USER_REGISTERED	user	9bd376ca-84e7-48cd-a91e-9002151bf344	{"role": "CUSTOMER", "email": "logout_no_jwt_9dc09355@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:38.041031+00
4e4c72c1-4a4e-4529-bd94-8dcc51ca3656	9bd376ca-84e7-48cd-a91e-9002151bf344	TOKEN_REUSE_DETECTED	auth	9692b9bd-99d6-41f6-97b0-8dd1b0be1323	{"reason": "Attempted reuse of consumed token", "family_id": "d3f958ed-c4c3-496b-93a0-d66c7b4b3bca"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:38.144013+00
053a5de7-5058-4d14-87ec-35b271df4dee	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	CUSTOMER_CREATED	customer	77028f6c-fe83-4e5c-9632-4700dea97986	{"email": "enterprise_dd7722@brightloop.io", "user_id": "628ea848-2123-49bf-a1bd-07be4afca2c7", "customer_number": "CUST-2026-0002"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:38.272438+00
2a6ec2bb-3376-488f-abc6-cb4d0e8e209b	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	cd07bdd3-8925-4e1c-8754-a33b7b02246c	{"sku": "SEC-6664B", "name": "Cloud Security Suite", "currency": "INR", "sales_price": "2000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:38.870784+00
f6e5fa65-ec2a-413a-88e6-c48bebda78b9	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	55293743-248d-46b3-88bf-847e5bf20636	{"code": "PLAN-SEC-F1D49", "name": "Security Pro Monthly", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:38.905103+00
f3c48d6f-d6b6-4dfa-a200-88a7e033b0be	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	daa8e84a-3b70-46b5-9bd7-e61e04129b30	{"plan_id": "55293743-248d-46b3-88bf-847e5bf20636", "quantity": 1, "product_id": "cd07bdd3-8925-4e1c-8754-a33b7b02246c", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:38.937475+00
bec2cd8c-917a-4df7-84cd-7424a90159e8	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	55293743-248d-46b3-88bf-847e5bf20636	{"code": "PLAN-SEC-F1D49", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:38.974299+00
55c5862d-662d-49c2-b9de-0557c97c1647	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	CUSTOMER_CREATED	customer	d8aba305-385d-4f8c-abcd-ee4db0e52f4d	{"email": "billing_8527b@infosys.com", "user_id": "a5b1716b-c164-4def-bae1-66f1e258b42c", "customer_number": "CUST-2026-0003"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:39.0156+00
b4144089-2a05-4285-90e0-7e379b185eb3	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_CREATED	subscription	4d53671e-2944-412a-a719-7177196275b6	{"plan_id": "55293743-248d-46b3-88bf-847e5bf20636", "customer_id": "d8aba305-385d-4f8c-abcd-ee4db0e52f4d", "total_amount": "2360.0000", "subscription_number": "SUB-202610-0001"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:39.102637+00
2682da69-67d5-4b6d-9123-fc434dd7502e	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_STATUS_CHANGED	subscription	4d53671e-2944-412a-a719-7177196275b6	{"reason": null, "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:39.185286+00
f9bb9ef7-4a4a-4f13-bc5c-8d2eb15efa17	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_STATUS_CHANGED	subscription	4d53671e-2944-412a-a719-7177196275b6	{"reason": null, "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:39.245179+00
ab03e32f-829f-4a32-bea4-1b027fc0b467	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	INVOICE_GENERATED	invoice	c8a257fd-b794-4423-84f9-59a2ff027466	{"total_amount": "2360.0000", "invoice_number": "INV-202610-0001", "subscription_id": "4d53671e-2944-412a-a719-7177196275b6"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:39.309746+00
023af08c-42ff-4bf0-a81f-d22d59b4e125	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	PAYMENT_RECORDED	payment	dd9e5f2f-e36d-45f8-86f2-2d41d3df1458	{"amount": "1000.0000", "invoice_number": "INV-202610-0001", "payment_number": "PAY-202610-0001", "is_full_payment": false}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:39.578634+00
692ef430-4033-4989-9ec5-1c56b29a3b1a	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	PAYMENT_RECORDED	payment	c478f047-1aaf-40ce-acb7-827884ce7506	{"amount": "1360.0000", "invoice_number": "INV-202610-0001", "payment_number": "PAY-202610-0002", "is_full_payment": true}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:40.011002+00
49b2d783-5338-452d-897f-9aaf1aa2570c	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	854ebbc5-1efb-41a4-8fa2-16cf3c26a41b	{"sku": "INR-52B877", "name": "INR Service", "currency": "INR", "sales_price": "1000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:40.521617+00
eb6b39d1-e89d-4e15-b2ce-eaa293ec074a	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	d84397f9-160d-40ba-ac60-58cd088d5c5f	{"sku": "USD-9D1F84", "name": "USD Service", "currency": "USD", "sales_price": "50.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:40.572892+00
b9c8ebc3-af9c-42b3-a4e3-e76c351b3bcf	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	606b3af1-65ff-488b-b8f8-e4bc196f57c5	{"code": "PLAN-INR-75BD24", "name": "Enterprise INR Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:40.60226+00
351e676b-d5d0-4afd-a299-9441429b640c	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	587a0d01-5857-49fc-875b-a02c541fa827	{"plan_id": "606b3af1-65ff-488b-b8f8-e4bc196f57c5", "quantity": 2, "product_id": "854ebbc5-1efb-41a4-8fa2-16cf3c26a41b", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:40.652859+00
b7be8208-c8a6-4b84-b7b1-9b2c5007c461	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	e4dc4e54-8377-4cb3-b7de-aa68603f1056	{"code": "GUARD-8C1478", "name": "Empty Draft Plan", "currency": "INR", "billing_interval": "YEARLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:40.700281+00
cd28ca6a-3324-4bed-91b1-30f22ce99779	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	feaed8df-addd-425d-9ed2-ecfaf1340189	{"sku": "BASE-5A56A1", "name": "Base Software", "currency": "INR", "sales_price": "3000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:40.747253+00
eb16cd6d-5267-458c-8e7f-919fbd68a21c	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	26df45e7-0252-43e6-9a5e-7a65d6e1acc5	{"plan_id": "e4dc4e54-8377-4cb3-b7de-aa68603f1056", "quantity": 1, "product_id": "feaed8df-addd-425d-9ed2-ecfaf1340189", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:40.777586+00
52c139d6-7d9b-4cff-be0a-2bf74a690dc6	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	e4dc4e54-8377-4cb3-b7de-aa68603f1056	{"code": "GUARD-8C1478", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:40.816567+00
63ecdebf-9d6f-4364-8829-8474c123e5fc	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	e4dc4e54-8377-4cb3-b7de-aa68603f1056	{"code": "GUARD-8C1478", "new_status": "INACTIVE", "old_status": "INACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:40.880746+00
3901b43e-1c76-4cb3-b68e-abb485e4e989	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	e4dc4e54-8377-4cb3-b7de-aa68603f1056	{"code": "GUARD-8C1478", "new_status": "ARCHIVED", "old_status": "ARCHIVED"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:40.925209+00
f7034187-1c2e-4ddd-8031-09784576303d	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	5d320af8-6a44-4f17-a7b2-33fc4de8fc75	{"sku": "AC-16FB68", "name": "Auto Close Product", "currency": "INR", "sales_price": "1500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:41.012002+00
52a7ce94-fe3f-4640-80fa-f40313732084	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	3a2519e1-04b4-44b0-acd4-0d6e123c3b30	{"code": "AUTO-0C5A5A", "name": "Limited Time Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:41.040091+00
fe5e4af9-ad82-4277-93fc-5969699568df	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	3a2519e1-04b4-44b0-acd4-0d6e123c3b30	{"code": "AUTO-0C5A5A", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:41.078626+00
7b842a99-b21c-4f81-bcc1-aefc8d9c6088	\N	PLAN_AUTO_CLOSED	SUBSCRIPTION_PLAN	3a2519e1-04b4-44b0-acd4-0d6e123c3b30	{"code": "AUTO-0C5A5A", "reason": "Availability end date '2026-10-31 05:01:41.033259+00:00' reached."}	\N	\N	2026-10-31 07:01:41.078626+00
7cfcade0-df8a-4a09-83cd-b58bea1e8e1a	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	2ad32ed2-97a9-4050-9215-98c7da066e2b	{"sku": "CRM-7D041C", "name": "CRM Software", "currency": "INR", "sales_price": "2000.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:41.163375+00
3380d278-3519-4d21-beab-e95011c617cf	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	3f42283e-473e-43c9-856a-c65f061a9c2f	{"code": "CRM-PLAN-4E07A5", "name": "CRM Standard Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:41.196078+00
6e50a709-847a-4464-926e-74e7a1f093fe	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	b684a14d-405b-4642-810f-1aa2b06e7cf1	{"plan_id": "3f42283e-473e-43c9-856a-c65f061a9c2f", "quantity": 3, "product_id": "2ad32ed2-97a9-4050-9215-98c7da066e2b", "variant_id": "9369f5a3-310b-4235-a2a3-f257bc8b50fe", "price_override": "2200.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:41.223204+00
1bd953d0-4cb3-4c28-bffe-5f60daa9d8dc	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_UPDATED	PLAN_PRODUCT	b684a14d-405b-4642-810f-1aa2b06e7cf1	{"plan_id": "3f42283e-473e-43c9-856a-c65f061a9c2f", "quantity": 5, "is_active": true}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:41.297398+00
bad96f7b-84a9-409a-97d5-e5c4cf4ea3ce	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_REMOVED	PLAN_PRODUCT	b684a14d-405b-4642-810f-1aa2b06e7cf1	{"plan_id": "3f42283e-473e-43c9-856a-c65f061a9c2f"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:41.383003+00
9b5eaef8-4fa3-432b-a486-a38e17192ecd	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	c77d4e45-cbef-4387-bd62-fbb9dda3a326	{"sku": "ERP-B0A7CE", "name": "ERP Financials", "currency": "INR", "sales_price": "2000.0000", "variants_count": 2}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:41.45576+00
e3acef7d-f810-4ecf-90de-dd70ccce9ec8	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	af5076dc-fb4c-45c7-9a5f-bbd5ceaa40fa	{"sku": "SW-13CD7A", "name": "Standard Software", "currency": "INR", "sales_price": "5000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:41.539605+00
6c2f34e9-ab24-422b-a38c-3af114f9272c	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	fd73a7e4-f39d-4e1b-9fe3-da976679b1bc	{"sku": "INR-C3E965", "name": "INR Product", "currency": "INR", "sales_price": "100.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:41.604242+00
4761a5e8-a638-4ed9-910b-7ec02021bad8	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	59cf8561-3fe4-4734-bbe2-95dba84775f9	{"sku": "SKU-F3D98A", "name": "Brightloop ERP Cloud", "currency": "INR", "sales_price": "2000.0000", "variants_count": 2}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:41.67762+00
e4609508-8ba0-4712-8aff-0c3ef677b5db	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_CREATED	PRODUCT_VARIANT	67302c4c-d599-49f5-bc58-663c4491706e	{"product_id": "59cf8561-3fe4-4734-bbe2-95dba84775f9", "variant_code": "ENT", "variant_name": "Enterprise Addon", "adjustment_type": "PERCENTAGE", "adjustment_value": "25.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:41.743588+00
60c22bf2-d9a8-4e1c-ad5a-d51a71af1b1d	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	d87788ef-ad41-4620-b2f2-d03d7a71db46	{"sku": "RBAC-19EA09", "name": "Admin Product", "currency": "INR", "sales_price": "500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:41.869698+00
0790e2e8-e9b3-4bd1-a7c7-ac87f9a18d2a	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	f01493de-49af-430b-a4c3-c4363e662aa0	{"sku": "HIST-C15172", "name": "History Test Product", "currency": "INR", "sales_price": "1000.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:41.942969+00
6da54677-2790-45a0-ac63-9b02a9aac287	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_UPDATED	PRODUCT	f01493de-49af-430b-a4c3-c4363e662aa0	{"sku": "HIST-C15172", "name": "History Test Product", "reason": "Annual inflation rate increase", "price_changes": {"cost_price": {"new": "450.0000", "old": "300.0000"}, "sales_price": {"new": "1500.0000", "old": "1000.0000"}}}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:41.977332+00
700aa0ae-c083-4041-bee3-a823d53f7c59	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_UPDATED	PRODUCT_VARIANT	a7fc4a31-685c-42ba-a888-7621e16cce08	{"variant_code": "PRO", "variant_name": "Pro Pack", "adjustment_type": "PERCENTAGE", "adjustment_value": "30.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:42.01415+00
59180c6c-8012-4d30-8630-6753df7d563a	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	5c0fd786-581f-4a73-a82b-8963d1479d94	{"sku": "ARCH-CBC8F7", "name": "To Archive Product", "currency": "INR", "sales_price": "750.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:42.058117+00
f03ad7f2-afdd-4e2a-9e03-2d14464c8976	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_ARCHIVED	PRODUCT	5c0fd786-581f-4a73-a82b-8963d1479d94	{"sku": "ARCH-CBC8F7", "name": "To Archive Product", "deactivated_plan_line_items": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:42.0907+00
102a9a63-1e47-4b40-b3a5-d37093d95e40	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_DEACTIVATED	PRODUCT_VARIANT	38f2909c-1b14-4be0-9033-3fb9c37b8893	{"variant_code": "VA", "variant_name": "Variant A", "deactivated_plan_line_items": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:42.128077+00
88f6e309-5da5-4f23-b432-3647e2bd171c	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	c48f1d45-bed4-411a-a422-daed07f89681	{"sku": "PROD-SUB-DBAB3", "name": "Cloud CRM Platform", "currency": "INR", "sales_price": "5000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:42.381422+00
3af6b34d-9dc6-439f-a4bc-1eb0263714a8	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	2cf2f096-5052-4398-9a1f-f75a93f0df4b	{"code": "PLAN-CRM-59150", "name": "Enterprise CRM Annual", "currency": "INR", "billing_interval": "YEARLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:42.411164+00
c6fb45f8-9d12-4820-ad63-b773dee3bae0	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	d786e9d7-2d45-40b8-b8e4-fb02c2564694	{"plan_id": "2cf2f096-5052-4398-9a1f-f75a93f0df4b", "quantity": 2, "product_id": "c48f1d45-bed4-411a-a422-daed07f89681", "variant_id": null, "price_override": "4500.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:42.437075+00
5e47a610-d39f-4c39-81f0-5ce00c55d196	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	2cf2f096-5052-4398-9a1f-f75a93f0df4b	{"code": "PLAN-CRM-59150", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:42.468856+00
acac5d13-89fa-4690-ba8a-6e09ed723f0f	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	CUSTOMER_CREATED	customer	4220650e-a590-4d9f-bbc1-f91752567133	{"email": "tata_6e42a@tatatech.com", "user_id": "e56fe90d-6089-4c10-9c2c-9c47b80033a0", "customer_number": "CUST-2026-0004"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:42.510931+00
06de77db-673a-46fd-b3db-c71777f99ad2	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_CREATED	subscription	db7dd7b6-1d74-4e90-930f-dcd1b1b9fb6e	{"plan_id": "2cf2f096-5052-4398-9a1f-f75a93f0df4b", "customer_id": "4220650e-a590-4d9f-bbc1-f91752567133", "total_amount": "10030.0000", "subscription_number": "SUB-202610-0002"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:42.60332+00
5f4aece7-b19c-4b4f-99db-4c1e6b8b00d5	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_STATUS_CHANGED	subscription	db7dd7b6-1d74-4e90-930f-dcd1b1b9fb6e	{"reason": "Sent quote to client", "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:42.672103+00
e71feb3b-0376-4b16-abcf-7c479ab895fe	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_STATUS_CHANGED	subscription	db7dd7b6-1d74-4e90-930f-dcd1b1b9fb6e	{"reason": "Client signed contract", "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:42.736766+00
e45d1b7f-a2ec-4742-8f7f-da578cc2734b	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:42.874452+00
00f4e9df-1371-49c3-9124-731532ea1255	a0978a5e-7bfc-4269-847a-0ddf8279f862	USER_REGISTERED	user	a0978a5e-7bfc-4269-847a-0ddf8279f862	{"role": "CUSTOMER", "email": "cust1_295491fd@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:42.940442+00
b27a22b7-9be6-469a-bc6d-a3171ecc3c39	9ea6e003-d6af-41ba-a523-1a52ae2fe703	USER_REGISTERED	user	9ea6e003-d6af-41ba-a523-1a52ae2fe703	{"role": "CUSTOMER", "email": "cust2_810c5a9d@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:43.024392+00
d541b116-08cc-4a3e-9c87-b77bc7b5b656	5040313c-9900-4630-93f9-1f0e119412dd	STAFF_CREATED	user	b2a6f66d-fc41-4eb0-86e7-36e98e60b7fa	{"role": "STAFF", "created_email": "staff_02da18b2@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:43.165113+00
eb4ef45c-c631-44ed-9b47-e71dec15ec25	b2a6f66d-fc41-4eb0-86e7-36e98e60b7fa	AUTH_LOGIN_SUCCESS	auth	b2a6f66d-fc41-4eb0-86e7-36e98e60b7fa	{"role": "STAFF", "email": "staff_02da18b2@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:43.233556+00
82cee49d-f72d-42ba-817d-caa3298d0853	5040313c-9900-4630-93f9-1f0e119412dd	USER_STATUS_UPDATED	user	a0978a5e-7bfc-4269-847a-0ddf8279f862	{"is_active": false, "target_email": "cust1_295491fd@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:01:43.396811+00
4169faea-2ba8-4e9e-beb9-0e9b8d0b4f8c	5040313c-9900-4630-93f9-1f0e119412dd	USER_STATUS_UPDATED	user	6190315d-16e2-42b7-8ebb-ae669aa4a9e9	{"is_active": false, "target_email": "cust1_0044b42d@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:23.734942+00
84682c4c-f7cd-4375-acd9-7e3b59b2d332	5040313c-9900-4630-93f9-1f0e119412dd	TOKEN_ROTATED	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"family_id": "26e962c3-4fd4-454a-80e8-9e786c52d2ff"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 07:16:00.53884+00
1a44585a-2eac-4e1b-82ca-4dcb6ce48880	5040313c-9900-4630-93f9-1f0e119412dd	TOKEN_REUSE_DETECTED	auth	152477a2-0aab-481c-93b7-907f13156c59	{"reason": "Attempted reuse of consumed token", "family_id": "26e962c3-4fd4-454a-80e8-9e786c52d2ff"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 07:16:00.542299+00
ed666828-cd93-4777-a058-84ecc7a71de3	5040313c-9900-4630-93f9-1f0e119412dd	TOKEN_REUSE_DETECTED	auth	a05fbe91-0358-4930-a062-a3d2f6118285	{"reason": "Attempted reuse of consumed token", "family_id": "26e962c3-4fd4-454a-80e8-9e786c52d2ff"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 07:16:14.401042+00
0bdea772-7a63-4297-9dbf-2b4e716cdc3d	5040313c-9900-4630-93f9-1f0e119412dd	TOKEN_REUSE_DETECTED	auth	a05fbe91-0358-4930-a062-a3d2f6118285	{"reason": "Attempted reuse of consumed token", "family_id": "26e962c3-4fd4-454a-80e8-9e786c52d2ff"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 07:16:14.404309+00
8c734a38-c67e-4fd2-b016-93bb9fa72020	5040313c-9900-4630-93f9-1f0e119412dd	TOKEN_REUSE_DETECTED	auth	a05fbe91-0358-4930-a062-a3d2f6118285	{"reason": "Attempted reuse of consumed token", "family_id": "26e962c3-4fd4-454a-80e8-9e786c52d2ff"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 07:16:14.402859+00
f89111ab-e172-48f5-b430-a5ac1f537505	5040313c-9900-4630-93f9-1f0e119412dd	TOKEN_REUSE_DETECTED	auth	a05fbe91-0358-4930-a062-a3d2f6118285	{"reason": "Attempted reuse of consumed token", "family_id": "26e962c3-4fd4-454a-80e8-9e786c52d2ff"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 07:16:14.406072+00
cc5b168b-535b-4a34-9795-6940f1e9e773	5040313c-9900-4630-93f9-1f0e119412dd	TOKEN_REUSE_DETECTED	auth	a05fbe91-0358-4930-a062-a3d2f6118285	{"reason": "Attempted reuse of consumed token", "family_id": "26e962c3-4fd4-454a-80e8-9e786c52d2ff"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 07:16:14.432067+00
9a9640b2-8a33-47a2-b1ca-8eccb519f66e	5040313c-9900-4630-93f9-1f0e119412dd	TOKEN_REUSE_DETECTED	auth	a05fbe91-0358-4930-a062-a3d2f6118285	{"reason": "Attempted reuse of consumed token", "family_id": "26e962c3-4fd4-454a-80e8-9e786c52d2ff"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 07:16:14.433452+00
7b8a2470-ffba-49a3-be34-968b5cbb5170	5040313c-9900-4630-93f9-1f0e119412dd	TOKEN_REUSE_DETECTED	auth	a05fbe91-0358-4930-a062-a3d2f6118285	{"reason": "Attempted reuse of consumed token", "family_id": "26e962c3-4fd4-454a-80e8-9e786c52d2ff"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 07:16:14.497771+00
293ca30a-450e-4ff4-8cfe-0c5e9c63cd7b	5040313c-9900-4630-93f9-1f0e119412dd	TOKEN_REUSE_DETECTED	auth	a05fbe91-0358-4930-a062-a3d2f6118285	{"reason": "Attempted reuse of consumed token", "family_id": "26e962c3-4fd4-454a-80e8-9e786c52d2ff"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 07:16:14.498712+00
fa751a49-adcf-4c37-8763-d88f43f1e872	f8a76800-1d18-4ecc-8527-7b4f59687fa3	AUTH_LOGIN_SUCCESS	auth	f8a76800-1d18-4ecc-8527-7b4f59687fa3	{"role": "CUSTOMER", "email": "bala@gmail.com"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 07:16:23.531936+00
eae1427e-496a-4d46-9247-1266b12bd3d0	843d4960-08ca-47f4-adcb-9867809d7989	USER_REGISTERED	user	843d4960-08ca-47f4-adcb-9867809d7989	{"role": "CUSTOMER", "email": "customer_bdb18c73@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:16.771431+00
495e7faa-c1bf-4551-9fb1-439102083da3	59227789-261d-4aab-b74d-03ffa1e2271a	USER_REGISTERED	user	59227789-261d-4aab-b74d-03ffa1e2271a	{"role": "CUSTOMER", "email": "dup_6f4c094e@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:16.882566+00
2f2866d8-1f68-4b16-bcef-ec9185a4dbd2	1737e95e-822d-4c0f-ac0f-c702a5b2109f	USER_REGISTERED	user	1737e95e-822d-4c0f-ac0f-c702a5b2109f	{"role": "CUSTOMER", "email": "login_user_8b4bbab4@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:16.989825+00
2adfbe64-71b7-474a-a8fa-95e07835b4f8	b52828e4-2c04-4936-bde5-6760082942f3	USER_REGISTERED	user	b52828e4-2c04-4936-bde5-6760082942f3	{"role": "CUSTOMER", "email": "customer_04132d57@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:06.700147+00
a2ed8ab5-e3b6-4562-aa0f-29f249a9597c	1737e95e-822d-4c0f-ac0f-c702a5b2109f	AUTH_LOGIN_SUCCESS	auth	1737e95e-822d-4c0f-ac0f-c702a5b2109f	{"role": "CUSTOMER", "email": "login_user_8b4bbab4@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:17.135293+00
3323743d-48ef-4ae1-a35b-ca817f60c5ce	36726a35-4372-4be4-9321-48da65360248	USER_REGISTERED	user	36726a35-4372-4be4-9321-48da65360248	{"role": "CUSTOMER", "email": "rotation_d9b630f4@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:17.207968+00
48c87de3-200e-4762-853d-f78ff89dd05e	36726a35-4372-4be4-9321-48da65360248	TOKEN_ROTATED	auth	36726a35-4372-4be4-9321-48da65360248	{"family_id": "a9470d31-b14b-4d5f-bf7a-96d512cbc0c4"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:17.300726+00
4de3e550-8f89-4ba9-84e7-02de1ef434f0	36726a35-4372-4be4-9321-48da65360248	TOKEN_REUSE_DETECTED	auth	bc0cecb4-c483-4fcd-888d-74518dd635e6	{"reason": "Attempted reuse of consumed token", "family_id": "a9470d31-b14b-4d5f-bf7a-96d512cbc0c4"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:17.32287+00
6ca6baa5-da66-45d2-bff4-12d3cfd97f5c	36726a35-4372-4be4-9321-48da65360248	TOKEN_REUSE_DETECTED	auth	7bfcebdd-5dd1-42fc-af97-c57abfb66d5b	{"reason": "Attempted reuse of consumed token", "family_id": "a9470d31-b14b-4d5f-bf7a-96d512cbc0c4"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:17.340689+00
8cc8e34e-2330-4dd5-9093-ac872295c1c8	f2b5bafc-3d46-4968-bfae-1f837ee70ea7	USER_REGISTERED	user	f2b5bafc-3d46-4968-bfae-1f837ee70ea7	{"role": "CUSTOMER", "email": "reset_961880ed@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:17.366165+00
d781fbab-109f-4ba3-ab86-145baa7b79bc	f2b5bafc-3d46-4968-bfae-1f837ee70ea7	PASSWORD_RESET_REQUESTED	auth	f2b5bafc-3d46-4968-bfae-1f837ee70ea7	{"email": "reset_961880ed@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:17.445515+00
e7d07585-160e-4dac-be9b-4226cd6b179a	f2b5bafc-3d46-4968-bfae-1f837ee70ea7	PASSWORD_RESET_COMPLETED	auth	f2b5bafc-3d46-4968-bfae-1f837ee70ea7	{"email": "reset_961880ed@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:17.493583+00
53222493-5e99-4893-b86c-a03aa3afed37	44bc6514-544b-4e38-963c-a0a30017da4c	USER_REGISTERED	user	44bc6514-544b-4e38-963c-a0a30017da4c	{"role": "CUSTOMER", "email": "catalog_cust_6b6abd@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:08.81289+00
0ec3454c-fa9f-44a7-a73f-a650cc174a96	f2b5bafc-3d46-4968-bfae-1f837ee70ea7	AUTH_LOGIN_SUCCESS	auth	f2b5bafc-3d46-4968-bfae-1f837ee70ea7	{"role": "CUSTOMER", "email": "reset_961880ed@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:17.641927+00
fd3ae71e-418f-4f85-b049-5f7212fc0317	d9d4a6b9-4e42-40a7-a637-1c3cd145c1e4	USER_REGISTERED	user	d9d4a6b9-4e42-40a7-a637-1c3cd145c1e4	{"role": "CUSTOMER", "email": "multi_reset_0d6a2fbc@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:17.727004+00
c6e803da-affd-42b2-8cea-087c7b1117ff	d9d4a6b9-4e42-40a7-a637-1c3cd145c1e4	PASSWORD_RESET_REQUESTED	auth	d9d4a6b9-4e42-40a7-a637-1c3cd145c1e4	{"email": "multi_reset_0d6a2fbc@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:17.811431+00
ed188c30-213c-4ed8-aca8-c87a6beb1a22	d9d4a6b9-4e42-40a7-a637-1c3cd145c1e4	PASSWORD_RESET_REQUESTED	auth	d9d4a6b9-4e42-40a7-a637-1c3cd145c1e4	{"email": "multi_reset_0d6a2fbc@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:17.86269+00
8160aeda-060a-45c1-a926-4963e773c793	c14ed6f5-aeb4-4e9c-8944-4e898df4b9f4	USER_REGISTERED	user	c14ed6f5-aeb4-4e9c-8944-4e898df4b9f4	{"role": "CUSTOMER", "email": "logout_no_jwt_7e625db9@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:17.922061+00
c443e6e9-8984-42eb-8adc-0392eec9eb12	c14ed6f5-aeb4-4e9c-8944-4e898df4b9f4	TOKEN_REUSE_DETECTED	auth	5e38f4f7-44ec-48a2-872f-e4866aa6a771	{"reason": "Attempted reuse of consumed token", "family_id": "afbb815c-81fd-4105-97d4-e3fcfe083a50"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:18.017439+00
27e67b4b-fa24-44a6-8843-34bbd95cee4e	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	CUSTOMER_CREATED	customer	d11ed7a0-16d7-495f-a4d7-591d0b4fbfe4	{"email": "enterprise_6c39f9@brightloop.io", "user_id": "3fac70e5-8751-4981-a145-bb97fbce8d27", "customer_number": "CUST-2026-0005"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:18.140946+00
a5ff20ef-24bf-4831-a2b8-bb155e85e8b4	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	edbb467f-ee59-4f31-94aa-588b436d4eaa	{"sku": "SEC-AA770", "name": "Cloud Security Suite", "currency": "INR", "sales_price": "2000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:19.120917+00
f53bc11a-4ba4-4385-87be-0f220c85982d	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	4681a3b4-7b93-4d9a-849e-224f0b310797	{"code": "PLAN-SEC-B2DB7", "name": "Security Pro Monthly", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:19.153356+00
51291a80-510b-4385-9c5b-33e876eb5615	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	569dd5f9-0d48-4f9e-bb6c-c4ddda81f7a2	{"plan_id": "4681a3b4-7b93-4d9a-849e-224f0b310797", "quantity": 1, "product_id": "edbb467f-ee59-4f31-94aa-588b436d4eaa", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:19.192396+00
2891dd61-b59d-41ad-a602-fd0bdfc52c73	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	4681a3b4-7b93-4d9a-849e-224f0b310797	{"code": "PLAN-SEC-B2DB7", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:19.24644+00
05c2ace5-c1a2-4e05-a456-fed6d385812d	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	CUSTOMER_CREATED	customer	20de22c3-c73e-40d3-bc37-9cf9b129a783	{"email": "billing_c26fb@infosys.com", "user_id": "2de8920e-abf2-44f4-9d69-d48779260b63", "customer_number": "CUST-2026-0006"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:19.297932+00
1be4858f-329f-4713-b469-57a70b175bfe	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_CREATED	subscription	056e88ff-c823-4843-b98f-65f3b616c0b0	{"plan_id": "4681a3b4-7b93-4d9a-849e-224f0b310797", "customer_id": "20de22c3-c73e-40d3-bc37-9cf9b129a783", "total_amount": "2360.0000", "subscription_number": "SUB-202610-0003"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:19.395714+00
346c48a2-f5ad-44eb-b46a-9e4f1caeaaa6	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_STATUS_CHANGED	subscription	056e88ff-c823-4843-b98f-65f3b616c0b0	{"reason": null, "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:19.486258+00
7d149148-de9d-4394-a5e8-a3c40cb00eb8	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_STATUS_CHANGED	subscription	056e88ff-c823-4843-b98f-65f3b616c0b0	{"reason": null, "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:19.557854+00
d3916489-06bd-4e82-9994-7c8e68fb2c13	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	INVOICE_GENERATED	invoice	6ca8252d-9d7c-4a93-b23b-b81acade770e	{"total_amount": "2360.0000", "invoice_number": "INV-202610-0002", "subscription_id": "056e88ff-c823-4843-b98f-65f3b616c0b0"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:19.620146+00
118f4187-f248-442a-9346-725b90634ca3	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	PAYMENT_RECORDED	payment	d949664f-78a8-45ae-b811-2bb1e1115093	{"amount": "1000.0000", "invoice_number": "INV-202610-0002", "payment_number": "PAY-202610-0003", "is_full_payment": false}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:19.885648+00
43ac80f6-bac8-428a-8bd1-e8651cdb9ef0	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	PAYMENT_RECORDED	payment	56d4e791-57ea-4546-9354-12208df0b054	{"amount": "1360.0000", "invoice_number": "INV-202610-0002", "payment_number": "PAY-202610-0004", "is_full_payment": true}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:20.308171+00
a32c5557-cefd-43df-8d1a-c1a8fc3f07c0	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	8e39b9d6-f2be-477f-89b8-2d6840dc802b	{"sku": "INR-65A231", "name": "INR Service", "currency": "INR", "sales_price": "1000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:20.816328+00
3aa51d54-3005-4184-9b43-5ce86d024bda	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	3efeb345-1ddd-42e3-b156-f5dd8b3e3a9e	{"sku": "USD-420C87", "name": "USD Service", "currency": "USD", "sales_price": "50.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:20.850565+00
97de0621-a353-494d-8011-9ae04f6924b5	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	1baded46-0fe4-44d5-a732-857b80b1d55d	{"code": "PLAN-INR-151FD6", "name": "Enterprise INR Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:20.878841+00
b548b5c5-b504-4434-a065-67b7713033b6	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	9e1ec54b-1839-4b68-809f-186cb406b380	{"plan_id": "1baded46-0fe4-44d5-a732-857b80b1d55d", "quantity": 2, "product_id": "8e39b9d6-f2be-477f-89b8-2d6840dc802b", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:20.930568+00
863dd699-bde5-45d1-87c7-af2c61fb940a	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	6c7f0f09-2321-4b2b-b692-7e79692d4079	{"code": "GUARD-847124", "name": "Empty Draft Plan", "currency": "INR", "billing_interval": "YEARLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:20.987104+00
53bb2b33-a773-4b94-a733-f173f891455a	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	23cb2b12-e720-4012-b44a-98da5b5c9b9d	{"sku": "BASE-9E4051", "name": "Base Software", "currency": "INR", "sales_price": "3000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:21.030442+00
e1106dd6-b12b-4d9b-8433-a9b0acf7706d	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	ed8134fd-d432-49e9-9c02-86480e2b0dc8	{"plan_id": "6c7f0f09-2321-4b2b-b692-7e79692d4079", "quantity": 1, "product_id": "23cb2b12-e720-4012-b44a-98da5b5c9b9d", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:21.058573+00
2fde248b-25c6-4741-ba51-e4b2de6c8c19	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	6c7f0f09-2321-4b2b-b692-7e79692d4079	{"code": "GUARD-847124", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:21.089298+00
5f8e899a-accf-4f7d-ae25-efbf034ddf90	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	6c7f0f09-2321-4b2b-b692-7e79692d4079	{"code": "GUARD-847124", "new_status": "INACTIVE", "old_status": "INACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:21.124805+00
f4e8d271-1dae-4924-b4e6-bcbd8d689297	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	6c7f0f09-2321-4b2b-b692-7e79692d4079	{"code": "GUARD-847124", "new_status": "ARCHIVED", "old_status": "ARCHIVED"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:21.169816+00
3901350d-cbd3-474c-8348-97198ecb3112	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	d04c4ec8-e918-490e-8571-b56018b0c3ca	{"sku": "AC-953014", "name": "Auto Close Product", "currency": "INR", "sales_price": "1500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:21.251941+00
a1e15b83-83d2-4e6d-b12d-7921f892adb2	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	72870f5f-71f6-4347-a85c-b49987b29213	{"code": "AUTO-7CEE22", "name": "Limited Time Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:21.283174+00
0481e866-3f35-4a6f-87af-c88187908310	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	72870f5f-71f6-4347-a85c-b49987b29213	{"code": "AUTO-7CEE22", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:21.324648+00
e6bbab2b-42b9-4402-b4c4-f7f1f8a062e6	\N	PLAN_AUTO_CLOSED	SUBSCRIPTION_PLAN	72870f5f-71f6-4347-a85c-b49987b29213	{"code": "AUTO-7CEE22", "reason": "Availability end date '2026-10-31 05:24:21.275471+00:00' reached."}	\N	\N	2026-10-31 07:24:21.324648+00
2e4d49af-ab7d-45a2-8fb0-55ebe7aefe6a	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	b22df97a-2fa6-449e-aafd-12ca0a45d15e	{"sku": "CRM-60072A", "name": "CRM Software", "currency": "INR", "sales_price": "2000.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:21.416759+00
6af1e001-6faa-40c7-9ba9-0c0600522c9e	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	bc16a23d-c598-491c-aeef-09fb888fdcd2	{"code": "CRM-PLAN-5E9ABC", "name": "CRM Standard Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:21.450872+00
4525f258-ad67-4ad3-8704-53f5647288ac	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	864a6155-5b65-4454-a32c-6275159955b5	{"plan_id": "bc16a23d-c598-491c-aeef-09fb888fdcd2", "quantity": 3, "product_id": "b22df97a-2fa6-449e-aafd-12ca0a45d15e", "variant_id": "d29668bc-3460-4d77-abfc-51bec2a342ac", "price_override": "2200.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:21.476046+00
0765050d-74b2-4cce-be51-683f4df3b9a7	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_UPDATED	PLAN_PRODUCT	864a6155-5b65-4454-a32c-6275159955b5	{"plan_id": "bc16a23d-c598-491c-aeef-09fb888fdcd2", "quantity": 5, "is_active": true}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:21.544917+00
b6fef561-6198-4d36-ad97-fd5484df67b1	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_REMOVED	PLAN_PRODUCT	864a6155-5b65-4454-a32c-6275159955b5	{"plan_id": "bc16a23d-c598-491c-aeef-09fb888fdcd2"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:21.635198+00
b3d95ab5-961c-46d6-8430-bd4c620fcfe1	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	b62c5ef2-e8a4-444e-854a-338a2b639bcc	{"sku": "ERP-9B128F", "name": "ERP Financials", "currency": "INR", "sales_price": "2000.0000", "variants_count": 2}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:21.714405+00
fb08ef34-dd47-4b52-854d-e375b2ae83a3	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	de41995c-95e2-44be-b6b6-1c22ddb11d9d	{"sku": "SW-523E7D", "name": "Standard Software", "currency": "INR", "sales_price": "5000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:21.795659+00
bda2b384-0ebb-4537-aa43-db4d012c00e6	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	b2291501-041e-4f78-9499-424109c6f3a6	{"sku": "INR-CEE61D", "name": "INR Product", "currency": "INR", "sales_price": "100.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:21.862488+00
e84c4abb-a331-481b-807a-572bc1c8156a	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	b49a17d4-223c-42ab-abbf-f8e658d82530	{"sku": "SKU-ADEBDC", "name": "Brightloop ERP Cloud", "currency": "INR", "sales_price": "2000.0000", "variants_count": 2}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:21.938189+00
a0b1d2fc-15d3-49c1-a23a-1691e2827d51	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_CREATED	PRODUCT_VARIANT	1c142a8c-6173-4174-8df2-1fae3ea9c8fe	{"product_id": "b49a17d4-223c-42ab-abbf-f8e658d82530", "variant_code": "ENT", "variant_name": "Enterprise Addon", "adjustment_type": "PERCENTAGE", "adjustment_value": "25.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:21.994158+00
38b8e770-16b0-43c8-b284-f1a754acaa6b	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	18a5cd0c-9068-42b0-b42d-453881b90fe3	{"sku": "RBAC-E40A38", "name": "Admin Product", "currency": "INR", "sales_price": "500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:22.111094+00
06110687-455f-445e-a8f4-750e7e77bb62	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	20a46d09-18d3-43a7-87e9-ea6287e1cc29	{"sku": "HIST-CD6C64", "name": "History Test Product", "currency": "INR", "sales_price": "1000.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:22.180328+00
6767f649-b61e-49cd-825a-4afff894454c	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_UPDATED	PRODUCT	20a46d09-18d3-43a7-87e9-ea6287e1cc29	{"sku": "HIST-CD6C64", "name": "History Test Product", "reason": "Annual inflation rate increase", "price_changes": {"cost_price": {"new": "450.0000", "old": "300.0000"}, "sales_price": {"new": "1500.0000", "old": "1000.0000"}}}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:22.212534+00
ad78d336-9489-42a9-bda2-067d20869ba3	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_UPDATED	PRODUCT_VARIANT	ec7fd122-b0e0-4f71-b1cc-1898ae07d7b3	{"variant_code": "PRO", "variant_name": "Pro Pack", "adjustment_type": "PERCENTAGE", "adjustment_value": "30.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:22.248062+00
d33227bd-fd1e-4481-8a0a-b1f009574d38	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	f154b89e-3860-40f9-9a41-ae91a70b21d2	{"sku": "ARCH-D2E3DC", "name": "To Archive Product", "currency": "INR", "sales_price": "750.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:22.289844+00
e97e3d49-dd75-41dc-acf5-b94e9b90a798	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_ARCHIVED	PRODUCT	f154b89e-3860-40f9-9a41-ae91a70b21d2	{"sku": "ARCH-D2E3DC", "name": "To Archive Product", "deactivated_plan_line_items": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:22.325343+00
563f695f-eb7b-4158-acd8-ac96864d117b	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_DEACTIVATED	PRODUCT_VARIANT	9ce9c660-c379-475f-99e9-ad70d90e830a	{"variant_code": "VA", "variant_name": "Variant A", "deactivated_plan_line_items": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:22.362509+00
e4ffc853-5b41-45c0-9fa0-f24c458e2bf4	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	37387601-cec8-4c66-b427-84f6104b528c	{"sku": "PROD-SUB-4007D", "name": "Cloud CRM Platform", "currency": "INR", "sales_price": "5000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:22.612997+00
597e2fe5-fed7-454c-86e4-d1570e3c7dd0	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	c6243761-457c-4c31-bace-512802fd0015	{"code": "PLAN-CRM-88229", "name": "Enterprise CRM Annual", "currency": "INR", "billing_interval": "YEARLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:22.660875+00
d660b66e-4ec3-4b74-bb19-91e37e08771f	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	1e04434b-84d5-48db-96c4-2a14f7f2f768	{"plan_id": "c6243761-457c-4c31-bace-512802fd0015", "quantity": 2, "product_id": "37387601-cec8-4c66-b427-84f6104b528c", "variant_id": null, "price_override": "4500.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:22.687225+00
a76869c9-942a-495a-a19a-5cd6588a2b4b	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	c6243761-457c-4c31-bace-512802fd0015	{"code": "PLAN-CRM-88229", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:22.721321+00
38a0dceb-66c0-4da9-9fec-82513a517500	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	CUSTOMER_CREATED	customer	bae036c5-9766-4885-9b31-95a70c4cea4f	{"email": "tata_7b7c7@tatatech.com", "user_id": "0f393bda-925a-4ca8-8a28-7db07ce74607", "customer_number": "CUST-2026-0007"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:22.757832+00
ddfdf1e2-58d2-4e22-9b79-ef620ed83c5a	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_CREATED	subscription	ca6b4850-fa26-42ea-8602-c9b11b500ce3	{"plan_id": "c6243761-457c-4c31-bace-512802fd0015", "customer_id": "bae036c5-9766-4885-9b31-95a70c4cea4f", "total_amount": "10030.0000", "subscription_number": "SUB-202610-0004"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:22.847953+00
36121eef-f309-4bfd-85e3-f7e32aa8d0fe	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_STATUS_CHANGED	subscription	ca6b4850-fa26-42ea-8602-c9b11b500ce3	{"reason": "Sent quote to client", "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:22.920415+00
83cf0459-8073-467b-8338-2e56241cd675	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_STATUS_CHANGED	subscription	ca6b4850-fa26-42ea-8602-c9b11b500ce3	{"reason": "Client signed contract", "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:23.071911+00
2b27d874-bcb5-4395-b460-c9670d36e03d	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:23.210262+00
8eebf5a7-b126-4098-bf9a-2b0e7411d869	6190315d-16e2-42b7-8ebb-ae669aa4a9e9	USER_REGISTERED	user	6190315d-16e2-42b7-8ebb-ae669aa4a9e9	{"role": "CUSTOMER", "email": "cust1_0044b42d@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:23.280124+00
03b60b90-82d8-4134-ab59-5d68e9447a68	5ace8bc1-63d8-411f-a11d-e6a1704ed15b	USER_REGISTERED	user	5ace8bc1-63d8-411f-a11d-e6a1704ed15b	{"role": "CUSTOMER", "email": "cust2_791a6af8@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:23.362743+00
90654663-c7fb-4ed5-851f-64f8953f2a93	5040313c-9900-4630-93f9-1f0e119412dd	STAFF_CREATED	user	ae4ffc0c-35ef-4e8e-9f0c-2e3b996c7115	{"role": "STAFF", "created_email": "staff_9eb997ff@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:23.503608+00
7dfafdbd-98ee-4272-bc3e-f5afe829df0c	ae4ffc0c-35ef-4e8e-9f0c-2e3b996c7115	AUTH_LOGIN_SUCCESS	auth	ae4ffc0c-35ef-4e8e-9f0c-2e3b996c7115	{"role": "STAFF", "email": "staff_9eb997ff@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:24:23.571842+00
eb330750-c71f-47d4-b199-fc4a1305313e	451b08f3-8939-4a62-a424-5ee548a6a453	USER_REGISTERED	user	451b08f3-8939-4a62-a424-5ee548a6a453	{"role": "CUSTOMER", "email": "dup_effa0801@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:06.814165+00
1490f263-52c0-482f-8451-bdcbf2309a56	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:08.988829+00
d7647ec7-e836-4d06-8a96-7b37fa30cbdf	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	3737c0df-0bb6-4dee-a209-5b1b1c4d31b9	{"code": "PLAN-AUD-8EBD0B", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:11.301511+00
9e05b31c-3213-48b6-a46b-d0d663d64052	5040313c-9900-4630-93f9-1f0e119412dd	PAYMENT_RECORDED	payment	514bdbfa-0f76-4f18-8811-9eac1d42dc54	{"amount": "39000.0000", "invoice_number": "INV-202610-0016", "payment_number": "PAY-202610-0018", "is_full_payment": true}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:12.46962+00
d8ec1f3b-8848-4571-b9bb-4b0c34b302b5	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	960071b7-9b0e-4ccc-88a7-c796d91fc1b4	{"email": "qty_16e322@test.com", "user_id": "d478a015-b108-49b2-86ea-6f6f31ec31c6", "customer_number": "CUST-2026-0053"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:13.677608+00
02fdbf0a-4e0f-4988-9bd3-09338676c2b5	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	d71babd3-e861-4689-a6c9-ee4691abf4f7	{"plan_id": "63848a77-2df4-4368-8796-c09dac27b6f4", "quantity": 1, "product_id": "f9b16ecd-e8bf-46ef-8482-2a84eb215fd2", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:14.301963+00
0ca94d42-b350-4d13-b01e-4ec6638b32e0	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	f6261125-c013-4208-a694-f85ba034150b	{"reason": null, "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:14.536827+00
495b43b8-4499-4bb6-a730-e6286603e299	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	bf0fe4c3-380f-497b-8893-9827fde63b12	{"code": "OP-PLAN-DBFA6B", "name": "Overpay Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:15.156127+00
0b6601f0-ee5c-4c8a-9a74-bc38568113dc	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	96e254fe-161e-43c8-bd4e-374d2a6277a3	{"plan_id": "bf0fe4c3-380f-497b-8893-9827fde63b12", "customer_id": "40937aa1-dcea-4eee-b28b-597f431549e5", "total_amount": "1180.0000", "subscription_number": "SUB-202610-0030"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:15.391893+00
92cfdcef-2ba6-4e2f-9f0a-f659e3112015	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	91d9d1c1-f92f-45ad-9077-5a379b947378	{"email": "iso1_f46fbb@demo.com", "user_id": "98cd3f6e-4144-4803-8bed-4f58edc93bfc", "customer_number": "CUST-2026-0057"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:16.16648+00
05cdd095-a825-4987-95b2-63e260b8fd8a	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	88688e20-0c4e-4ebd-b421-4288dfc86ba3	{"plan_id": "2174e10f-65e8-4882-b370-2dfd10171b07", "quantity": 1, "product_id": "6d9f2b8f-4038-4bf7-baee-a0bbd91ba314", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:16.674309+00
9439814f-8c9f-4ff5-bc94-ba9c562cdbf8	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	6b0a8d72-7313-402a-9e66-e287cb1eef53	{"reason": null, "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:16.923822+00
0e66fe59-4bb5-4393-813d-ee07090b4c2d	5040313c-9900-4630-93f9-1f0e119412dd	PAYMENT_RECORDED	payment	c36f1400-387b-4432-9001-6e62ae343bb3	{"amount": "590.0000", "invoice_number": "INV-202610-0019", "payment_number": "PAY-202610-0019", "is_full_payment": true}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:17.17587+00
b1c7a740-3589-4627-8e50-685333ece375	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	52114349-8af8-469e-ada3-7e2712631161	{"plan_id": "02bd8e1a-1f5f-4e5d-8c1e-1d909a546854", "quantity": 1, "product_id": "3e3ede4f-d267-4cff-8549-9755a16fc590", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:17.806464+00
0ceef102-46c4-4445-afc3-0139a60196e6	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_CREATED	subscription	1145b2e2-2ee9-4ecc-ac68-7e3e0e6c3a86	{"plan_id": "02bd8e1a-1f5f-4e5d-8c1e-1d909a546854", "customer_id": "f4256ea5-779c-448a-b1fb-6a98398d127c", "total_amount": "2360.0000", "subscription_number": "SUB-202610-0032"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:17.973194+00
99c4ab3d-6c9e-4011-958a-a29175837355	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	INVOICE_GENERATED	invoice	397b784d-7ee3-465d-8c49-92313e63407c	{"total_amount": "2360.0000", "invoice_number": "INV-202610-0020", "subscription_id": "1145b2e2-2ee9-4ecc-ac68-7e3e0e6c3a86"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:18.182825+00
8cec01fc-c2be-47c2-b53d-38565619d57b	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	9b7d0387-53f9-4167-97b1-f2ec87c80dca	{"code": "GUARD-B3A8CA", "name": "Empty Draft Plan", "currency": "INR", "billing_interval": "YEARLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:19.61097+00
bbc80b14-c769-462b-88a2-f2e5dca5be18	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	9b7d0387-53f9-4167-97b1-f2ec87c80dca	{"code": "GUARD-B3A8CA", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:19.722992+00
e7eabd59-108c-4b90-a693-d195c835a6fb	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	dcf62b2b-3bb7-41c6-90a2-0df56926f3d3	{"sku": "AC-EBE78B", "name": "Auto Close Product", "currency": "INR", "sales_price": "1500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:19.907895+00
54b0b9dd-0cb1-4b85-9256-71914e662d32	\N	PLAN_AUTO_CLOSED	SUBSCRIPTION_PLAN	bec2abb3-07f2-4cc0-9dde-297e1e6ac75a	{"code": "AUTO-873AA0", "reason": "Availability end date '2026-10-31 06:24:19.930793+00:00' reached."}	\N	\N	2026-10-31 08:24:19.980873+00
1509eb13-ed0f-42cb-8487-b514dc3feec7	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	945c525c-7140-4809-9579-fa77f6408378	{"code": "CRM-PLAN-F3D889", "name": "CRM Standard Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:20.102065+00
5624b4a7-0e07-41f0-be35-7be7172316a4	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_UPDATED	PLAN_PRODUCT	519863d5-522a-4ef8-8f96-44f28d90d71e	{"plan_id": "945c525c-7140-4809-9579-fa77f6408378", "quantity": 5, "is_active": true}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:20.195222+00
8a807d1a-7cd5-40b5-84ee-65ca375bfb9d	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	d9d4cfa1-d7ff-4475-81ef-aacf2209bae8	{"sku": "ERP-B028FA", "name": "ERP Financials", "currency": "INR", "sales_price": "2000.0000", "variants_count": 2}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:20.357187+00
4d553744-40e4-4543-84f5-3afa25ba75a7	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	23901c36-a9a0-44ad-98af-92fe4a5b1d88	{"sku": "INR-4BD35F", "name": "INR Product", "currency": "INR", "sales_price": "100.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:20.511977+00
4ad204cd-96de-42de-a593-16fe5838b5e6	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_CREATED	PRODUCT_VARIANT	d21571c0-2316-4fd5-ab99-c1a7853fa5d4	{"product_id": "ca9093a9-8946-45d9-9f7c-0fed270ee1b7", "variant_code": "ENT", "variant_name": "Enterprise Addon", "adjustment_type": "PERCENTAGE", "adjustment_value": "25.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:20.66303+00
4523957c-4bd0-460f-8f79-74425b43a648	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_UPDATED	PRODUCT	1da1085b-388e-42ba-a756-8d3905e1119b	{"sku": "HIST-CBAAA9", "name": "History Test Product", "reason": "Annual inflation rate increase", "price_changes": {"cost_price": {"new": "450.0000", "old": "300.0000"}, "sales_price": {"new": "1500.0000", "old": "1000.0000"}}}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:20.825569+00
969530e2-206f-44b6-8128-d68b1fafc708	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	fa4315a7-89d6-4aec-906e-eaceb128d2ab	{"code": "PLAN-AUD-3A32A8", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:29.441334+00
067381b4-53b0-4ce9-a38f-48a1757ac874	1bf8ea9f-6b06-4da9-be91-3c8731819498	USER_REGISTERED	user	1bf8ea9f-6b06-4da9-be91-3c8731819498	{"role": "CUSTOMER", "email": "login_user_a3fd2c4e@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:06.92716+00
9314ad2d-b5ea-405a-989c-f1a24428ea32	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	01b93597-5723-44ad-9492-ef3607218c92	{"email": "starter_corp_4ead21@example.com", "user_id": "589b2d88-254a-488c-8a51-2a4d18b192c2", "customer_number": "CUST-2026-0049"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:09.098736+00
4977f9e1-2c66-4e83-961a-9fcd19ae6013	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	d3d2ff47-1496-45ee-bc84-ec7e81aced75	{"plan_id": "3737c0df-0bb6-4dee-a209-5b1b1c4d31b9", "customer_id": "bca5e35f-ed0e-4e3c-a57f-eb24c360a6fb", "total_amount": "59000.0000", "subscription_number": "SUB-202610-0028"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:11.358629+00
fe9ad419-f8af-4d42-b4ea-195dd812a814	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	e6bd4afa-c438-44e4-888d-b341f4e4c4db	{"email": "dup_5552ec@domain.com", "user_id": "4f043cb7-ad10-4a07-8093-4a7e81edcc1c", "customer_number": "CUST-2026-0052"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:13.328596+00
0aa5e7fd-66c8-421d-b712-93b4e9d653d4	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	8fd4b604-eb35-45c7-bdd2-1ab8102d63f5	{"code": "DRAFT-4E9051", "name": "Draft Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:13.956089+00
460ccfb4-e164-4f13-9de6-62c6a0566445	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	63848a77-2df4-4368-8796-c09dac27b6f4	{"code": "OVL-PLAN-B22D76", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:14.342183+00
2ba41acf-0b62-4e4a-80c7-5dc5173e5310	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	f6261125-c013-4208-a694-f85ba034150b	{"reason": null, "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:14.706785+00
d06594f1-a458-4905-b12c-935e8274e825	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	fcf7a62e-95ef-4549-add2-66b95dea341b	{"plan_id": "bf0fe4c3-380f-497b-8893-9827fde63b12", "quantity": 1, "product_id": "7f8d1ec4-f42c-48c7-928f-278cf9d23b34", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:15.19137+00
c9f1f8cf-4ccb-45ab-b820-bf8f65217669	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	96e254fe-161e-43c8-bd4e-374d2a6277a3	{"reason": null, "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:15.472122+00
ca1a6d58-fe75-4fb1-8915-6165bf223926	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	6f8dadf5-e36a-4840-9dd9-18c6678b3565	{"email": "iso2_f46fbb@demo.com", "user_id": "e5f4628a-254f-4743-900d-c4c5848dc4c5", "customer_number": "CUST-2026-0058"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:16.282343+00
e5aa6a91-c7fd-43a7-88fe-bd6e40fa18cf	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	2174e10f-65e8-4882-b370-2dfd10171b07	{"code": "PLAN-NEG9-7559A3", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:16.711841+00
cb46fc8b-1af3-4f50-9af1-b87d03b9fa50	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	6b0a8d72-7313-402a-9e66-e287cb1eef53	{"reason": null, "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:16.995376+00
5ec04e0a-58fa-438e-a874-2bff6f61f91d	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	3e3ede4f-d267-4cff-8549-9755a16fc590	{"sku": "SEC-D4CB3", "name": "Cloud Security Suite", "currency": "INR", "sales_price": "2000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:17.742565+00
7ff9b4da-81e1-4346-b7e1-486abfa6db4a	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	02bd8e1a-1f5f-4e5d-8c1e-1d909a546854	{"code": "PLAN-SEC-8F01D", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:17.839456+00
d71337c7-1e32-4303-a4af-f08f63993f37	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_STATUS_CHANGED	subscription	1145b2e2-2ee9-4ecc-ac68-7e3e0e6c3a86	{"reason": null, "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:18.038333+00
b33127ec-cd09-4712-9233-835456f007f0	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	PAYMENT_RECORDED	payment	2f6cb0a0-b66d-4911-a1fd-d9f9fc6146b3	{"amount": "1000.0000", "invoice_number": "INV-202610-0020", "payment_number": "PAY-202610-0020", "is_full_payment": false}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:18.4432+00
8de2faa4-67b1-46f1-bc7f-aa7babcc432f	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	bcd56009-9fcb-4079-b8c3-42057803de96	{"sku": "BASE-ABE7B8", "name": "Base Software", "currency": "INR", "sales_price": "3000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:19.665087+00
aaa59da0-fb79-4f82-928e-5557709d5445	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	9b7d0387-53f9-4167-97b1-f2ec87c80dca	{"code": "GUARD-B3A8CA", "new_status": "INACTIVE", "old_status": "INACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:19.764043+00
090ba8fc-ada9-46b6-9bc0-875c412efcb6	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	bec2abb3-07f2-4cc0-9dde-297e1e6ac75a	{"code": "AUTO-873AA0", "name": "Limited Time Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:19.937304+00
2666928a-8645-464d-a45d-2ab33ff4c58e	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	f8fb9c0c-8135-427d-a119-1af9ce6e9a02	{"sku": "CRM-B6E95F", "name": "CRM Software", "currency": "INR", "sales_price": "2000.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:20.06928+00
29439208-21e5-4f79-9b6d-2bbe263f54c3	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	519863d5-522a-4ef8-8f96-44f28d90d71e	{"plan_id": "945c525c-7140-4809-9579-fa77f6408378", "quantity": 3, "product_id": "f8fb9c0c-8135-427d-a119-1af9ce6e9a02", "variant_id": "d0505c31-1a18-4121-abc7-dc5d5170262b", "price_override": "2200.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:20.124529+00
1d3aefa7-7135-4324-b2e6-6dcc60675b68	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_REMOVED	PLAN_PRODUCT	519863d5-522a-4ef8-8f96-44f28d90d71e	{"plan_id": "945c525c-7140-4809-9579-fa77f6408378"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:20.279799+00
1c9eae23-dc62-4262-8dc8-50d085491bfa	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	427f1a59-ae24-45e4-bc39-24b8f1acd32f	{"sku": "SW-505DE1", "name": "Standard Software", "currency": "INR", "sales_price": "5000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:20.443316+00
6864fc36-bb03-4c28-a745-4a71871330a8	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	ca9093a9-8946-45d9-9f7c-0fed270ee1b7	{"sku": "SKU-D1E67E", "name": "Brightloop ERP Cloud", "currency": "INR", "sales_price": "2000.0000", "variants_count": 2}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:20.593607+00
73eb37f6-ceb0-49e7-a754-de738f5629d9	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	1da1085b-388e-42ba-a756-8d3905e1119b	{"sku": "HIST-CBAAA9", "name": "History Test Product", "currency": "INR", "sales_price": "1000.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:20.786671+00
0db6cd8d-f55e-495b-a064-4cd03baa6ef1	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_UPDATED	PRODUCT_VARIANT	d62c2f56-26d5-405a-9cff-076773776786	{"variant_code": "PRO", "variant_name": "Pro Pack", "adjustment_type": "PERCENTAGE", "adjustment_value": "30.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:20.86472+00
216ad31c-ef11-46bf-b0be-e969093f4ba1	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	5a501b7e-5295-4719-8c88-20c5ffcced35	{"sku": "ARCH-48E91E", "name": "To Archive Product", "currency": "INR", "sales_price": "750.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:20.912848+00
dc8d436e-1ac9-471a-a1d5-3c1b421ffda5	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	f2b75ded-d929-4852-bceb-9abbaa11ef6c	{"reason": null, "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:23.350722+00
36dcb5b2-1541-4906-8083-d78059039681	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	875aa731-5cb8-4dda-8c8f-30e6c35a22f2	{"plan_id": "0086d29b-ddd9-4dc5-9ac0-3d74ea38cba4", "customer_id": "01b93597-5723-44ad-9492-ef3607218c92", "total_amount": "1178.8200", "subscription_number": "SUB-202610-0027"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:09.278061+00
e6b6f8a2-a5ac-4958-9090-7ada0c85a470	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	d3d2ff47-1496-45ee-bc84-ec7e81aced75	{"reason": "Formal quote dispatched", "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:11.44719+00
2a2cf4c7-d0c5-44eb-82f9-54997e5e9393	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	20b44ac3-ad76-4788-a710-a08a854f2184	{"sku": "QTY-16E322", "name": "Qty Test Product 16e322", "currency": "INR", "sales_price": "100.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:13.542583+00
75e21ff7-3f5e-4789-b4b2-aca6432f6094	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	5dcccc33-0f78-45de-9732-d802e749060b	{"email": "draft_4e9051@test.com", "user_id": "bff68c14-6701-4be2-8a60-ba9d40b78c05", "customer_number": "CUST-2026-0054"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:13.985849+00
a07ee373-5d10-48a8-980e-ebed25b44a75	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	0e75110e-28f7-451f-a480-86c34b25a040	{"email": "ovl_b22d76@test.com", "user_id": "78d99fdc-1cd2-4bc3-be11-c53f8128703d", "customer_number": "CUST-2026-0055"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:14.381543+00
75947df4-fbd7-4150-be85-0bfee2f7f828	5040313c-9900-4630-93f9-1f0e119412dd	INVOICE_GENERATED	invoice	46674e86-de9a-478d-8905-e318902d5646	{"total_amount": "1180.0000", "invoice_number": "INV-202610-0017", "subscription_id": "f6261125-c013-4208-a694-f85ba034150b"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:14.76841+00
c7fb4e60-4457-414b-acda-0d5beb3dbda9	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	bf0fe4c3-380f-497b-8893-9827fde63b12	{"code": "OP-PLAN-DBFA6B", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:15.23167+00
34d3f898-84a2-4689-8977-415ebdcdaa22	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	96e254fe-161e-43c8-bd4e-374d2a6277a3	{"reason": null, "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:15.561272+00
8c4bf9e4-3676-4c6e-ae2a-24c394b597eb	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	6d9f2b8f-4038-4bf7-baee-a0bbd91ba314	{"sku": "NEG9-7559A3", "name": "Neg9 Prod 7559a3", "currency": "INR", "sales_price": "500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:16.618806+00
c5b2dca1-de51-4fa3-af90-5a3fbd41f550	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	ef262998-7f20-45f5-bed3-ac7a7de9c250	{"email": "neg9_7559a3@test.com", "user_id": "9c032f6d-4d9c-49c6-be87-6f45c6528780", "customer_number": "CUST-2026-0059"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:16.755764+00
e4c9f9b8-0662-4b77-905b-c223d71c3ce3	5040313c-9900-4630-93f9-1f0e119412dd	INVOICE_GENERATED	invoice	a38ddb73-7a1e-4e90-b394-39a597c03588	{"total_amount": "590.0000", "invoice_number": "INV-202610-0019", "subscription_id": "6b0a8d72-7313-402a-9e66-e287cb1eef53"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:17.073667+00
9718650b-c359-4aaf-a602-d5cbbca91b41	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	02bd8e1a-1f5f-4e5d-8c1e-1d909a546854	{"code": "PLAN-SEC-8F01D", "name": "Security Pro Monthly", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:17.774856+00
69504068-4429-49ec-8e68-321a386ba3f3	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	CUSTOMER_CREATED	customer	f4256ea5-779c-448a-b1fb-6a98398d127c	{"email": "billing_9a5fc@infosys.com", "user_id": "580e2b4f-9f9e-4b88-9f6d-bd0e4e68b826", "customer_number": "CUST-2026-0060"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:17.878602+00
ea836de1-a62a-4b0b-96ae-0366e47c52e6	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_STATUS_CHANGED	subscription	1145b2e2-2ee9-4ecc-ac68-7e3e0e6c3a86	{"reason": null, "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:18.111443+00
66c4e7d2-9ba6-4f71-917c-9c5090f13c48	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	PAYMENT_RECORDED	payment	6d426c1f-1dc0-42d0-a527-e771c0adbfef	{"amount": "1360.0000", "invoice_number": "INV-202610-0020", "payment_number": "PAY-202610-0021", "is_full_payment": true}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:18.900848+00
bdd1659d-f05e-47be-90a7-c858cdd0a41b	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	476818c7-ba57-43a1-b836-2bda62794c00	{"plan_id": "9b7d0387-53f9-4167-97b1-f2ec87c80dca", "quantity": 1, "product_id": "bcd56009-9fcb-4079-b8c3-42057803de96", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:19.693865+00
8d864d0b-068d-401d-b9dc-92fe1aa25587	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	9b7d0387-53f9-4167-97b1-f2ec87c80dca	{"code": "GUARD-B3A8CA", "new_status": "ARCHIVED", "old_status": "ARCHIVED"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:19.813512+00
62a6c6e3-0e4c-4245-a13e-1eaa59d17e29	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	bec2abb3-07f2-4cc0-9dde-297e1e6ac75a	{"code": "AUTO-873AA0", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:19.980873+00
7888f37e-9cdd-4d9b-9189-9b4ad09ec9ab	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	186b4bbe-6fca-4f10-8817-a4b71efd0762	{"sku": "BL-CORE-01", "name": "Brightloop Enterprise Core Platform", "currency": "INR", "sales_price": "49999.0000", "variants_count": 1}	\N	\N	2026-10-31 07:33:24.444528+00
71c227d2-c5e6-4406-a949-158e8de9ed4d	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	48db2113-98c2-44bb-8fb5-491a6e75ddfd	{"sku": "BL-ADDON-AI", "name": "Advanced Billing Intelligence & Churn Predictor", "currency": "INR", "sales_price": "19999.0000", "variants_count": 0}	\N	\N	2026-10-31 07:33:24.444528+00
ec5ffcc9-7e08-44eb-be7a-1a32f71a06cc	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	ebc4abad-f5e7-4644-9567-8d7fdad06fd4	{"sku": "BL-SRV-SLA", "name": "24/7 Dedicated Enterprise Support & Solutions Architect", "currency": "INR", "sales_price": "15000.0000", "variants_count": 0}	\N	\N	2026-10-31 07:33:24.444528+00
8604456a-0260-42e2-a103-c44fe8380c43	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	d384f73d-e895-4459-ab35-677aa5b24362	{"code": "BL-PLAN-ENT-Y", "name": "Brightloop Enterprise ERP Suite (Annual)", "currency": "INR", "billing_interval": "YEARLY", "bundled_products_count": 3}	\N	\N	2026-10-31 07:33:24.444528+00
58877b5a-cddf-4076-a8ae-43c224edc331	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	d384f73d-e895-4459-ab35-677aa5b24362	{"code": "BL-PLAN-ENT-Y", "new_status": "ACTIVE", "old_status": "ACTIVE"}	\N	\N	2026-10-31 07:33:24.444528+00
3b0271c3-083a-4571-b55b-72607b797abb	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	c74c2965-322c-4f1c-b764-71a5d895d2d8	{"code": "BL-PLAN-GROWTH-M", "name": "Brightloop Growth Operations (Monthly)", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 1}	\N	\N	2026-10-31 07:33:24.444528+00
05e2569b-4c2e-48d8-a077-2e68786f5a36	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	c74c2965-322c-4f1c-b764-71a5d895d2d8	{"code": "BL-PLAN-GROWTH-M", "new_status": "ACTIVE", "old_status": "ACTIVE"}	\N	\N	2026-10-31 07:33:24.444528+00
8019af4f-48f3-489a-bb03-7895da51ac21	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	0bbc71dc-0eda-419a-88a5-03fb4ff39b6b	{"email": "billing@tcs-enterprise.com", "user_id": "42ac6db9-70d7-4973-8852-c8c16d975be9", "customer_number": "CUST-2026-0008"}	\N	\N	2026-10-31 07:33:24.444528+00
fe80631d-b3a6-4cd8-a149-0feade20a658	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	c35f47e5-0366-411b-81af-49b909c51fbc	{"email": "finance@zomato-corp.com", "user_id": "0edd6c45-63f8-4d39-aade-7746228f0b98", "customer_number": "CUST-2026-0009"}	\N	\N	2026-10-31 07:33:24.444528+00
006ef29d-9eb9-47a2-a92e-f6a20ead748e	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	5aa41d88-f9e6-405b-981a-c96dd1144e29	{"email": "accounts@swiggy.in", "user_id": "ab39119d-27a4-4eae-b2ea-b2413a1540ad", "customer_number": "CUST-2026-0010"}	\N	\N	2026-10-31 07:33:24.444528+00
2db2ce74-24be-4f81-adad-a48b6460a932	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	72541aa9-36f8-4b9c-9626-b060cc5140d3	{"plan_id": "d384f73d-e895-4459-ab35-677aa5b24362", "customer_id": "0bbc71dc-0eda-419a-88a5-03fb4ff39b6b", "total_amount": "141600.0000", "subscription_number": "SUB-202610-0005"}	\N	\N	2026-10-31 07:33:24.444528+00
07f54a54-1ebe-4e82-b590-6284008bbc12	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	72541aa9-36f8-4b9c-9626-b060cc5140d3	{"reason": "Quotation issued to TCS procurement", "to_status": "QUOTATION", "from_status": "DRAFT"}	\N	\N	2026-10-31 07:33:24.444528+00
c5da3a33-3344-4bd7-9f3a-cda457baf908	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	72541aa9-36f8-4b9c-9626-b060cc5140d3	{"reason": "PO received from TCS", "to_status": "CONFIRMED", "from_status": "QUOTATION"}	\N	\N	2026-10-31 07:33:24.444528+00
60eba238-0547-4637-b13e-7e429bea039b	5040313c-9900-4630-93f9-1f0e119412dd	INVOICE_GENERATED	invoice	c22ea219-4c7d-4125-a575-f217346e48ec	{"total_amount": "141600.0000", "invoice_number": "INV-202610-0003", "subscription_id": "72541aa9-36f8-4b9c-9626-b060cc5140d3"}	\N	\N	2026-10-31 07:33:24.444528+00
ee1a3302-d18b-4cdf-8cc4-01498ff9a492	5040313c-9900-4630-93f9-1f0e119412dd	PAYMENT_RECORDED	payment	23af4ff8-29fe-4090-a7cf-1ac030ac6af5	{"amount": "141600.0000", "invoice_number": "INV-202610-0003", "payment_number": "PAY-202610-0005", "is_full_payment": true}	\N	\N	2026-10-31 07:33:24.444528+00
0b7f1295-4664-4b79-8118-2c2f1dcf36af	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	cecfc49e-26c5-4e3f-bac9-8f8458dc4598	{"plan_id": "c74c2965-322c-4f1c-b764-71a5d895d2d8", "customer_id": "c35f47e5-0366-411b-81af-49b909c51fbc", "total_amount": "17700.0000", "subscription_number": "SUB-202610-0006"}	\N	\N	2026-10-31 07:33:24.444528+00
c53d79ce-3a34-4628-99bb-950276d31604	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	cecfc49e-26c5-4e3f-bac9-8f8458dc4598	{"reason": "Quotation reviewed by Zomato VP Tech", "to_status": "QUOTATION", "from_status": "DRAFT"}	\N	\N	2026-10-31 07:33:24.444528+00
22aa8180-92a5-43de-a3bb-6dfe9cf3ac0a	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	cecfc49e-26c5-4e3f-bac9-8f8458dc4598	{"reason": "Direct authorization granted", "to_status": "CONFIRMED", "from_status": "QUOTATION"}	\N	\N	2026-10-31 07:33:24.444528+00
4e3ec178-a483-406c-9a9c-b03c39015f6a	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	cecfc49e-26c5-4e3f-bac9-8f8458dc4598	{"reason": "Activated on trial terms", "to_status": "ACTIVE", "from_status": "CONFIRMED"}	\N	\N	2026-10-31 07:33:24.444528+00
0a97c13f-62f0-4f16-8968-de0019250015	5040313c-9900-4630-93f9-1f0e119412dd	INVOICE_GENERATED	invoice	1346cc70-fc94-44e1-a3b2-624c05cff912	{"total_amount": "17700.0000", "invoice_number": "INV-202610-0004", "subscription_id": "cecfc49e-26c5-4e3f-bac9-8f8458dc4598"}	\N	\N	2026-10-31 07:33:24.444528+00
69f09521-071b-4cb3-a7a5-1b7255478385	5040313c-9900-4630-93f9-1f0e119412dd	PAYMENT_RECORDED	payment	5e7140a6-17d0-46e0-93c6-8e8e90e3dc9a	{"amount": "10000.0000", "invoice_number": "INV-202610-0004", "payment_number": "PAY-202610-0006", "is_full_payment": false}	\N	\N	2026-10-31 07:33:24.444528+00
b011d561-085e-4f3b-b559-271a98155dce	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	84b00a2f-0122-4bc7-a407-040b02cb1133	{"plan_id": "d384f73d-e895-4459-ab35-677aa5b24362", "customer_id": "5aa41d88-f9e6-405b-981a-c96dd1144e29", "total_amount": "141600.0000", "subscription_number": "SUB-202610-0007"}	\N	\N	2026-10-31 07:33:24.444528+00
113448ad-8220-4521-8252-1e66a87fdebb	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	84b00a2f-0122-4bc7-a407-040b02cb1133	{"reason": "Quotation submitted", "to_status": "QUOTATION", "from_status": "DRAFT"}	\N	\N	2026-10-31 07:33:24.444528+00
3c093121-8ab9-4997-a179-0045eb21966e	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	84b00a2f-0122-4bc7-a407-040b02cb1133	{"reason": "PO issued by Swiggy Accounts", "to_status": "CONFIRMED", "from_status": "QUOTATION"}	\N	\N	2026-10-31 07:33:24.444528+00
6ec9d506-6277-48f4-bc4c-983066440102	5040313c-9900-4630-93f9-1f0e119412dd	INVOICE_GENERATED	invoice	24391ca7-3405-4e6d-899b-629ef9e1fbfb	{"total_amount": "141600.0000", "invoice_number": "INV-202610-0005", "subscription_id": "84b00a2f-0122-4bc7-a407-040b02cb1133"}	\N	\N	2026-10-31 07:33:24.444528+00
83b78793-bfbe-40cf-bba3-75e2cb575610	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:20.256881+00
4e97e738-426d-479c-9012-13e481fb1a10	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	8b412e2c-8436-413f-924b-fa819d601cf2	{"email": "audit_corp_dbbe98@demo.com", "user_id": "319ca723-eafd-4883-b097-6b20dd0faabb", "customer_number": "CUST-2026-0011"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:20.464995+00
56ee6960-6b4a-471e-96e9-a2f897f9365e	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	942c213b-7840-4549-aa89-94c83ee4842a	{"sku": "AUD-SKU-DBBE98", "name": "Audit Analytics Suite dbbe98", "currency": "INR", "sales_price": "50000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:20.586873+00
1c397c11-d25d-46ed-9241-72a3b53db89e	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	6900679d-5caa-4a5f-a0fa-4e68c86687a6	{"code": "PLAN-AUD-DBBE98", "name": "Audit Pro Plan dbbe98", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:20.620298+00
3a3879d5-a3d8-48bb-9f74-f95131be1a3d	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	01b289a5-ff28-40ec-a1d7-ece1a3cca8f4	{"plan_id": "6900679d-5caa-4a5f-a0fa-4e68c86687a6", "quantity": 1, "product_id": "942c213b-7840-4549-aa89-94c83ee4842a", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:20.652287+00
96beaa85-30a1-4836-8616-50b9efcf252d	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	6900679d-5caa-4a5f-a0fa-4e68c86687a6	{"code": "PLAN-AUD-DBBE98", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:20.690139+00
8686c2ca-51df-498b-be02-edcdf7c51dd5	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	810a53cb-11f3-4c83-8617-5835e2ab20b4	{"plan_id": "6900679d-5caa-4a5f-a0fa-4e68c86687a6", "customer_id": "8b412e2c-8436-413f-924b-fa819d601cf2", "total_amount": "59000.0000", "subscription_number": "SUB-202610-0008"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:20.737791+00
dc3eaf5d-1a2f-47dc-b4c9-63fe8298b64e	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	0cde400f-7b0c-46e6-85d7-fd508589878e	{"email": "dup_ccb42b@domain.com", "user_id": "b0289709-fdb9-4186-8170-97d5fe8ca536", "customer_number": "CUST-2026-0012"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:20.912989+00
75a72d3f-699c-4d9a-ac91-a76392a06466	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	401ad69d-e929-4555-87ce-ff5b306799a8	{"sku": "QTY-FEA26E", "name": "Qty Test Product fea26e", "currency": "INR", "sales_price": "100.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:21.108966+00
e2d6ed83-a599-43c8-9dad-d507f943acd4	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	242a449a-f506-45e7-a7d6-1c8d482c3eca	{"code": "PLAN-QTY-FEA26E", "name": "Limited Quantity Plan fea26e", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:21.138167+00
0177e439-1b90-4552-b0af-158874f7fc19	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	ea31d072-04e8-4301-b8da-9a0221dfc1b7	{"plan_id": "242a449a-f506-45e7-a7d6-1c8d482c3eca", "quantity": 2, "product_id": "401ad69d-e929-4555-87ce-ff5b306799a8", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:21.16598+00
6cb8ecad-8970-477b-a552-c2c9d11fdf26	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	242a449a-f506-45e7-a7d6-1c8d482c3eca	{"code": "PLAN-QTY-FEA26E", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:21.198934+00
3b3e0a8c-4b1d-4254-bcbf-0ceb3956f57a	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	f78bfeac-5bcf-4aae-b274-2b9f1f65bf62	{"email": "qty_fea26e@test.com", "user_id": "62ba0cee-0bbc-4fa2-a484-0d17e7e96c78", "customer_number": "CUST-2026-0013"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:21.235137+00
2871bf4a-f04c-4922-873c-d75b2624e41e	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	f6ed1002-f02c-40b5-a8de-3427ffcfdcc8	{"code": "DRAFT-5E366F", "name": "Draft Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:21.484861+00
7601b907-7448-416a-9712-e67153055406	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	cca5c902-64d6-4e7e-a51b-f8ddc0208c33	{"email": "draft_5e366f@test.com", "user_id": "e9e2cf4f-ce8b-4220-bdec-6d394ba91885", "customer_number": "CUST-2026-0014"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:21.512494+00
e2e46ac1-b8e3-46c6-9c0e-4b2103f9c2df	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	77f7a1a1-923b-4307-b433-b3653d77faf2	{"sku": "OVL-20B80A", "name": "Overlap Prod 20b80a", "currency": "INR", "sales_price": "1000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:21.722144+00
a4c20b35-5439-4056-835a-00b475df9209	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	5a6f8220-4f8c-4192-a679-dae3a6888a01	{"code": "OVL-PLAN-20B80A", "name": "Overlap Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:21.749633+00
2595c0c8-2a6b-461f-a89b-9fea9a150e91	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	615a72f2-dcdd-49f7-bd52-f9d13da74e0d	{"plan_id": "5a6f8220-4f8c-4192-a679-dae3a6888a01", "quantity": 1, "product_id": "77f7a1a1-923b-4307-b433-b3653d77faf2", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:21.775526+00
552cac92-992a-4f57-8612-148dc8643d57	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	5a6f8220-4f8c-4192-a679-dae3a6888a01	{"code": "OVL-PLAN-20B80A", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:21.810272+00
6fec4360-0e83-4ab3-b368-9cb79bf7b6fd	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	c10a4652-77d5-42e5-a1d4-9eb8ed365153	{"email": "ovl_20b80a@test.com", "user_id": "6f71e03b-972e-4a07-a28f-831713f9da1c", "customer_number": "CUST-2026-0015"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:21.851666+00
9a4979fa-9447-4e22-9185-47d952100167	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	0f932e65-0914-408c-9d68-93cb5d16040e	{"plan_id": "5a6f8220-4f8c-4192-a679-dae3a6888a01", "customer_id": "c10a4652-77d5-42e5-a1d4-9eb8ed365153", "total_amount": "1180.0000", "subscription_number": "SUB-202610-0009"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:21.946376+00
5544100c-1756-4847-9fcb-3fe8b7cbdb04	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	ddac571a-50c8-46a7-aae6-c9699a912456	{"sku": "OP-B78A98", "name": "OP Prod b78a98", "currency": "INR", "sales_price": "1000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:22.240495+00
d7dde292-f7da-4d2b-a317-56a2f69f139f	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	85463b60-e094-4575-9c20-02f2bd715080	{"code": "OP-PLAN-B78A98", "name": "Overpay Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:22.267429+00
99198428-107b-462b-8948-f48932d16ea4	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	bcf964cb-e8a6-4ecb-9188-5f5ffcb1376e	{"plan_id": "85463b60-e094-4575-9c20-02f2bd715080", "quantity": 1, "product_id": "ddac571a-50c8-46a7-aae6-c9699a912456", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:22.293963+00
4b834876-ace4-4eb1-9e19-861b7257a0b1	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	85463b60-e094-4575-9c20-02f2bd715080	{"code": "OP-PLAN-B78A98", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:22.330417+00
b70d96b0-031e-4e28-897d-5d322f0eb579	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	1214e873-31fb-4ac4-89d7-eaabfff658bd	{"email": "op_b78a98@test.com", "user_id": "e82dfe6d-4528-4957-b697-af13e73699a8", "customer_number": "CUST-2026-0016"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:22.372764+00
96a3f9c5-df8b-4df5-8076-e61a2a8e35c5	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	a3627d27-1e03-4400-97eb-4116a9658759	{"plan_id": "85463b60-e094-4575-9c20-02f2bd715080", "customer_id": "1214e873-31fb-4ac4-89d7-eaabfff658bd", "total_amount": "1180.0000", "subscription_number": "SUB-202610-0010"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:22.464794+00
98494428-7d24-4ab5-bd52-77f054669293	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	996e7e31-9bc8-4564-9457-8ca7927dfb84	{"sku": "NEG9-2A13BB", "name": "Neg9 Prod 2a13bb", "currency": "INR", "sales_price": "500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:22.854986+00
82ba2dca-911c-425a-8fdd-0495e2adfe06	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	092e3a0c-9bd7-4bf4-98cd-c6bd89bf06c6	{"code": "PLAN-NEG9-2A13BB", "name": "Neg9 Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:22.883144+00
2f34fdce-b028-45cc-92d4-871e93d7dc6a	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	f5236551-01cc-4312-823b-8a44c76df0b5	{"plan_id": "092e3a0c-9bd7-4bf4-98cd-c6bd89bf06c6", "quantity": 1, "product_id": "996e7e31-9bc8-4564-9457-8ca7927dfb84", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:22.908608+00
17d47ef3-fbd4-453c-84d6-e028d8dd6dfe	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	092e3a0c-9bd7-4bf4-98cd-c6bd89bf06c6	{"code": "PLAN-NEG9-2A13BB", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:22.935533+00
da403b46-a4f6-42d4-9af7-0d78420f5cc5	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	42fdbc73-7c79-4ce4-a25f-85420d3bf4fe	{"email": "neg9_2a13bb@test.com", "user_id": "1db238e8-d823-4e53-a192-4cbe1979c01a", "customer_number": "CUST-2026-0017"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:22.969455+00
b93d55b6-2928-4235-a9ae-b5a434fabe25	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	102dc1b3-faff-452a-a726-68f4db877dc0	{"plan_id": "092e3a0c-9bd7-4bf4-98cd-c6bd89bf06c6", "customer_id": "42fdbc73-7c79-4ce4-a25f-85420d3bf4fe", "total_amount": "590.0000", "subscription_number": "SUB-202610-0011"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:35:23.059597+00
78623cac-8f7e-482e-8457-df6717c913c9	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:29.016015+00
6149695c-cead-4c40-b451-4504d61de076	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	d1ad1940-cda3-43d9-8725-9af55aabf801	{"email": "audit_corp_3a32a8@demo.com", "user_id": "6c761294-0188-4925-9242-3fddfec0c211", "customer_number": "CUST-2026-0018"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:29.206418+00
11ffe4c1-c185-4a46-a91b-0b7b6ae96efe	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	39e2f841-cf98-4c62-809a-d941b1637c23	{"sku": "AUD-SKU-3A32A8", "name": "Audit Analytics Suite 3a32a8", "currency": "INR", "sales_price": "50000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:29.332951+00
d93c3dbb-349f-4708-ab9a-6edeed9d66e7	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	fa4315a7-89d6-4aec-906e-eaceb128d2ab	{"code": "PLAN-AUD-3A32A8", "name": "Audit Pro Plan 3a32a8", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:29.372724+00
89e42ddc-bbc7-47fd-8ef9-21d79bc8e49a	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	40fee025-2a17-4ad4-8072-ccf0d38e18f6	{"plan_id": "fa4315a7-89d6-4aec-906e-eaceb128d2ab", "quantity": 1, "product_id": "39e2f841-cf98-4c62-809a-d941b1637c23", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:29.406964+00
cf28e030-d79f-481a-9469-045d6f3c1863	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	f1e7cc49-c8af-465e-9d83-d64f5101b2bb	{"plan_id": "fa4315a7-89d6-4aec-906e-eaceb128d2ab", "customer_id": "d1ad1940-cda3-43d9-8725-9af55aabf801", "total_amount": "59000.0000", "subscription_number": "SUB-202610-0012"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:29.488582+00
5514ed40-cb3f-4b5b-97d5-871e01b6ca4e	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	f1e7cc49-c8af-465e-9d83-d64f5101b2bb	{"reason": "Formal quote dispatched", "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:29.578939+00
2a993e72-319b-4061-9078-6efadf69ff76	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	f1e7cc49-c8af-465e-9d83-d64f5101b2bb	{"reason": "Customer approved quote", "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:29.647454+00
d26ee577-a70a-4fa2-852e-9eb39d61942e	5040313c-9900-4630-93f9-1f0e119412dd	INVOICE_GENERATED	invoice	27881d41-b173-47f6-8e0c-3ec728bdec01	{"total_amount": "59000.0000", "invoice_number": "INV-202610-0006", "subscription_id": "f1e7cc49-c8af-465e-9d83-d64f5101b2bb"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:29.723883+00
1bc5b633-30ec-45d6-b414-7934a195deb3	5040313c-9900-4630-93f9-1f0e119412dd	PAYMENT_RECORDED	payment	f2525ae1-1bb0-4094-9ed1-e84cf9e07761	{"amount": "20000.0000", "invoice_number": "INV-202610-0006", "payment_number": "PAY-202610-0007", "is_full_payment": false}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:29.885189+00
4d11e45f-1a57-48d3-b463-5bc40df19fa5	5040313c-9900-4630-93f9-1f0e119412dd	PAYMENT_RECORDED	payment	4d77293b-522b-45fd-91ee-feba1b7d50f8	{"amount": "39000.0000", "invoice_number": "INV-202610-0006", "payment_number": "PAY-202610-0008", "is_full_payment": true}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:30.32658+00
0282f326-b9f9-4137-b3da-9b0c1b25b9c9	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	9b65bcea-400c-4ebe-b3a4-94e4c3978d54	{"email": "dup_b8f8b4@domain.com", "user_id": "fda5f60c-b55c-4681-8eee-8754701bb862", "customer_number": "CUST-2026-0019"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:31.169295+00
fd6896ec-eee4-4916-becc-302e3e55dd5f	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	62d13717-1a0d-4a1d-b4fd-71cf741c8ba5	{"sku": "QTY-EF54CA", "name": "Qty Test Product ef54ca", "currency": "INR", "sales_price": "100.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:31.367084+00
21b42e50-a342-4bb3-a7ca-438bc0a49ace	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	5d83f931-1a37-489f-88f1-b646f5e30693	{"code": "PLAN-QTY-EF54CA", "name": "Limited Quantity Plan ef54ca", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:31.398528+00
125ecbf4-a7d7-4b01-903e-d86497367d8c	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	b335c2f3-f424-438f-979a-27db5f7e1740	{"plan_id": "5d83f931-1a37-489f-88f1-b646f5e30693", "quantity": 2, "product_id": "62d13717-1a0d-4a1d-b4fd-71cf741c8ba5", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:31.425238+00
8dc298fc-524b-4a68-8948-582c5e8712f2	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	5d83f931-1a37-489f-88f1-b646f5e30693	{"code": "PLAN-QTY-EF54CA", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:31.460662+00
89376905-fb62-4d8c-9007-b4c16222e1e2	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	5776e2ea-fce0-44d0-abcc-6a821efc973d	{"email": "qty_ef54ca@test.com", "user_id": "0bc3d615-5e7e-42bb-8e77-55fe6d255d6f", "customer_number": "CUST-2026-0020"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:31.499712+00
a7cdf326-babb-46d7-9859-51ff6dab1d22	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	f734effe-4020-4023-9e75-ea23508dfd18	{"code": "DRAFT-DE3B95", "name": "Draft Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:31.751155+00
1609b407-0586-431e-a9b3-8a82648ef109	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	b8d55661-d47f-4ea9-a7b1-8fe6936be42a	{"email": "draft_de3b95@test.com", "user_id": "e92e067c-86a6-41c9-95f9-04601ecea5ac", "customer_number": "CUST-2026-0021"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:31.777375+00
a4de0b09-ad38-4610-9efe-6bfefb6a4382	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	683a33cf-43e1-4b69-adc0-50512d118c91	{"sku": "OVL-0531CA", "name": "Overlap Prod 0531ca", "currency": "INR", "sales_price": "1000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:31.962817+00
227d0bb6-a85d-472d-818b-13c2b9dc00a4	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	0a961d0a-af94-4712-9de1-331c2f043343	{"code": "OVL-PLAN-0531CA", "name": "Overlap Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:31.992404+00
78c3a48b-0015-4c32-b651-14f01f94547a	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	f16875ac-edfa-4e5b-ab6a-6e899ce16a93	{"plan_id": "0a961d0a-af94-4712-9de1-331c2f043343", "quantity": 1, "product_id": "683a33cf-43e1-4b69-adc0-50512d118c91", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:32.020103+00
49be7d84-1b2b-474e-8899-b1dea14b8445	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	0a961d0a-af94-4712-9de1-331c2f043343	{"code": "OVL-PLAN-0531CA", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:32.049712+00
171b1c23-0e54-493e-9371-b7222f41ab57	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	33ac25c4-2e2a-40b1-ab02-908cc110c426	{"email": "ovl_0531ca@test.com", "user_id": "31ead84d-8593-44a7-82be-62269162708b", "customer_number": "CUST-2026-0022"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:32.08704+00
841a6759-ec4f-40fb-af45-7c025cde141d	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	9ca3f8e0-9c33-428b-9ba7-8713614d9d5c	{"plan_id": "0a961d0a-af94-4712-9de1-331c2f043343", "customer_id": "33ac25c4-2e2a-40b1-ab02-908cc110c426", "total_amount": "1180.0000", "subscription_number": "SUB-202610-0013"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:32.17377+00
faefa22e-d6b7-4ff4-a07a-90b4184935fa	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	b37d638a-f942-49d6-8e03-68859649bc3a	{"sku": "OP-FFEE42", "name": "OP Prod ffee42", "currency": "INR", "sales_price": "1000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:32.526056+00
7780b83b-0b5c-45a3-bd38-3a7e5818fa02	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	497e8a79-6474-4c05-ae8f-c3504448bcc6	{"code": "OP-PLAN-FFEE42", "name": "Overpay Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:32.555633+00
28ac27b1-3f7b-4a37-8db1-4dee60d4a092	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	9a7daab5-ed27-451d-841f-0b1b7d1d8705	{"plan_id": "497e8a79-6474-4c05-ae8f-c3504448bcc6", "quantity": 1, "product_id": "b37d638a-f942-49d6-8e03-68859649bc3a", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:32.580922+00
8ff7719a-4840-4d1b-818c-d7ffd9537bde	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	497e8a79-6474-4c05-ae8f-c3504448bcc6	{"code": "OP-PLAN-FFEE42", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:32.615317+00
0b4fc8ea-94ca-4607-92c9-7d4634eec11c	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	f77c7295-47d5-4694-adea-980a61c56830	{"email": "op_ffee42@test.com", "user_id": "010ca79b-8c8d-4721-a74f-ce2fdc90ed73", "customer_number": "CUST-2026-0023"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:32.654626+00
5cf07992-b31d-470d-8c5b-f76e2476fdb5	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	b6ddf376-f7bf-46c9-9436-be398070771d	{"plan_id": "497e8a79-6474-4c05-ae8f-c3504448bcc6", "customer_id": "f77c7295-47d5-4694-adea-980a61c56830", "total_amount": "1180.0000", "subscription_number": "SUB-202610-0014"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:32.747767+00
5c15c7a6-af95-4284-bf08-7eb65031fd8a	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	f7a28ffc-22f2-49cd-8d64-cbd034fc3c2c	{"email": "iso1_4899a8@demo.com", "user_id": "fbc9f9fb-074d-4943-a212-dde7cf5eaf6e", "customer_number": "CUST-2026-0024"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:32.993211+00
134c1c7c-5877-4a6e-abd4-71bfc5fbdcca	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	a0bc69d1-c9fd-4817-80a3-9debd95762e9	{"email": "iso2_4899a8@demo.com", "user_id": "2fbae6f5-da89-4056-a5d9-51a70577af1e", "customer_number": "CUST-2026-0025"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:33.083142+00
3a8028e3-3a43-4810-8571-a9b30f38b61a	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	a1eae06d-1777-4cb6-b063-6a2580b8a280	{"sku": "NEG9-18B7B5", "name": "Neg9 Prod 18b7b5", "currency": "INR", "sales_price": "500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:33.415205+00
2b296a14-4237-4223-8592-54179f451062	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	7d53651d-4f7a-4d08-ae20-255e14608dac	{"code": "PLAN-NEG9-18B7B5", "name": "Neg9 Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:33.445078+00
a4072a1d-0786-4ae5-a725-ddd6ac36526b	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	b17fc25b-9115-49c0-bff3-25c499177ca9	{"plan_id": "7d53651d-4f7a-4d08-ae20-255e14608dac", "quantity": 1, "product_id": "a1eae06d-1777-4cb6-b063-6a2580b8a280", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:33.470954+00
ac9785ef-57d0-4db8-9981-6d51cce887e4	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	7d53651d-4f7a-4d08-ae20-255e14608dac	{"code": "PLAN-NEG9-18B7B5", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:33.503019+00
745a1e52-9f64-4bcd-95de-5bc33d2b71b6	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	11c4eb39-bdc0-4da1-bb1d-9b33bed52f9a	{"email": "neg9_18b7b5@test.com", "user_id": "617b7b2d-6424-4b9d-9a95-0b2c97d88eae", "customer_number": "CUST-2026-0026"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:33.540809+00
0c6804f6-3a5a-48eb-8aa7-af791dc7a4a5	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	765c3a10-ad74-4467-a542-1bc924e47c3a	{"plan_id": "7d53651d-4f7a-4d08-ae20-255e14608dac", "customer_id": "11c4eb39-bdc0-4da1-bb1d-9b33bed52f9a", "total_amount": "590.0000", "subscription_number": "SUB-202610-0015"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:37:33.637009+00
0cf90a2a-19e0-482c-b30b-8165cc25e35b	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:18.094798+00
0b7b30f0-b3ed-45de-9ba3-6b3f47797d72	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	ad1f6972-67c1-4b0b-a015-ba3aea186bc9	{"email": "audit_corp_2c1132@demo.com", "user_id": "e4783364-7813-465d-ae8d-04a025ea069e", "customer_number": "CUST-2026-0027"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:18.277993+00
1c962257-46da-41b2-8338-cfdd9763acdb	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	53b00a01-c903-4f64-9e72-5088c4c0e028	{"sku": "AUD-SKU-2C1132", "name": "Audit Analytics Suite 2c1132", "currency": "INR", "sales_price": "50000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:18.399867+00
07153264-5d64-48ec-ad60-6f200c14c411	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	e84fb213-7803-4a33-90c7-62ac22c16ae7	{"code": "PLAN-AUD-2C1132", "name": "Audit Pro Plan 2c1132", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:18.438142+00
07cb3ce8-af80-42e2-9c09-9f20ec823fdb	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	95db978a-a612-4ac5-96d3-6b9c497138ad	{"plan_id": "e84fb213-7803-4a33-90c7-62ac22c16ae7", "quantity": 1, "product_id": "53b00a01-c903-4f64-9e72-5088c4c0e028", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:18.471727+00
207206a7-a7bc-4a79-8446-725df9649a91	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	e84fb213-7803-4a33-90c7-62ac22c16ae7	{"code": "PLAN-AUD-2C1132", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:18.506789+00
0137062a-9c4f-4a70-b9d3-a26fd90401f2	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	94fc7b5b-d190-4f0d-a531-7d7a3ddd92cf	{"plan_id": "e84fb213-7803-4a33-90c7-62ac22c16ae7", "customer_id": "ad1f6972-67c1-4b0b-a015-ba3aea186bc9", "total_amount": "59000.0000", "subscription_number": "SUB-202610-0016"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:18.551974+00
a314e7dc-e5b0-437b-961f-30c09013ff9e	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	94fc7b5b-d190-4f0d-a531-7d7a3ddd92cf	{"reason": "Formal quote dispatched", "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:18.634712+00
71c1692a-1952-4698-bb27-edb61fa979b0	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	94fc7b5b-d190-4f0d-a531-7d7a3ddd92cf	{"reason": "Customer approved quote", "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:18.708508+00
4f27b86f-5e3e-4725-af38-e3a8645ffa6c	5040313c-9900-4630-93f9-1f0e119412dd	INVOICE_GENERATED	invoice	f045f94c-d267-4dfe-a757-a867da47d824	{"total_amount": "59000.0000", "invoice_number": "INV-202610-0007", "subscription_id": "94fc7b5b-d190-4f0d-a531-7d7a3ddd92cf"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:18.777905+00
339c2e01-e01e-42f3-93bd-09ca97508142	5040313c-9900-4630-93f9-1f0e119412dd	PAYMENT_RECORDED	payment	a54305b9-52ff-45ab-86c5-1af3907b2382	{"amount": "20000.0000", "invoice_number": "INV-202610-0007", "payment_number": "PAY-202610-0009", "is_full_payment": false}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:18.923305+00
2a834dd4-d99b-4ebe-897c-939aac61c60a	5040313c-9900-4630-93f9-1f0e119412dd	PAYMENT_RECORDED	payment	e662361e-cd4a-43f2-927c-e171c60666b0	{"amount": "39000.0000", "invoice_number": "INV-202610-0007", "payment_number": "PAY-202610-0010", "is_full_payment": true}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:19.395995+00
f911d86d-70df-4529-9a18-8d01cfdb67fd	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	a04eb519-94ca-4932-9f59-7c6c430a2ccd	{"email": "dup_091447@domain.com", "user_id": "54e697f5-ec86-49d0-a228-a4ce85abf64b", "customer_number": "CUST-2026-0028"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:20.334866+00
dc12795b-a17a-4880-a4d2-21f043fc8aa5	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	a98b731e-2a49-4e70-85b8-405fbc73f791	{"sku": "QTY-2446FD", "name": "Qty Test Product 2446fd", "currency": "INR", "sales_price": "100.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:20.532174+00
91d72c48-bc48-4f3e-8f0e-c62152495fe3	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	dbac552f-2c45-4830-ba3e-84d75d087d53	{"code": "PLAN-QTY-2446FD", "name": "Limited Quantity Plan 2446fd", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:20.563475+00
5e478717-1ef6-4395-b24b-b1e2763dd245	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	7aef97c0-23ea-4675-97bd-a502c718fd28	{"plan_id": "dbac552f-2c45-4830-ba3e-84d75d087d53", "quantity": 2, "product_id": "a98b731e-2a49-4e70-85b8-405fbc73f791", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:20.593899+00
b7d233dd-8dae-4a4d-8a4c-0f20347ac1b3	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	dbac552f-2c45-4830-ba3e-84d75d087d53	{"code": "PLAN-QTY-2446FD", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:20.630969+00
e78f13ca-a683-4408-80a5-d44c2a873817	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	178346a1-f0d1-48da-89f0-69b57a540b49	{"email": "qty_2446fd@test.com", "user_id": "83ff8008-a19a-4079-a653-cd9066754e47", "customer_number": "CUST-2026-0029"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:20.674165+00
6e670354-8d9f-44f9-a376-39893ca47e7b	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	fc81659d-6231-4468-a404-31cf05aa73ab	{"code": "DRAFT-5E80AC", "name": "Draft Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:20.919362+00
6aa32859-ade9-4c80-bede-16b224a6962e	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	df79c8e4-2ba0-4c30-96bc-c9c8db6ee7dc	{"email": "draft_5e80ac@test.com", "user_id": "c6865499-f520-4b3a-bd59-d7ac73da12ae", "customer_number": "CUST-2026-0030"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:20.947056+00
c7f5bf62-9b68-480c-8261-ab4504d88153	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	ed0db0d3-c8a8-4bc2-ac69-92b127dcbd38	{"sku": "OVL-FB54D3", "name": "Overlap Prod fb54d3", "currency": "INR", "sales_price": "1000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:21.148112+00
6c46cec5-601e-4cae-b0ad-b5914122a909	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	364ce5b7-24c4-4e38-8370-245fb703bc22	{"code": "OVL-PLAN-FB54D3", "name": "Overlap Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:21.184812+00
4a13628f-27b0-458c-a395-3203c5690343	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	de4cd00e-207f-44c4-9091-8f9c0c362eeb	{"plan_id": "364ce5b7-24c4-4e38-8370-245fb703bc22", "quantity": 1, "product_id": "ed0db0d3-c8a8-4bc2-ac69-92b127dcbd38", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:21.21358+00
9818fc83-aac2-48d8-a47f-8bb1bcf67765	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	364ce5b7-24c4-4e38-8370-245fb703bc22	{"code": "OVL-PLAN-FB54D3", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:21.246083+00
cf45e601-82f0-49ed-88c3-b7bb95b1eb01	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	1391c136-849b-4cbc-8cdb-7c35f86cd85e	{"email": "ovl_fb54d3@test.com", "user_id": "d9a03e5a-b69a-466c-a629-bd1ae2fc92ee", "customer_number": "CUST-2026-0031"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:21.289533+00
c983c950-5e48-4736-862b-0cd37e42ffa8	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	d0c58c40-a1f6-4a94-bbfd-bef418d3fe4a	{"plan_id": "364ce5b7-24c4-4e38-8370-245fb703bc22", "customer_id": "1391c136-849b-4cbc-8cdb-7c35f86cd85e", "total_amount": "1180.0000", "subscription_number": "SUB-202610-0017"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:21.418813+00
5b50286e-09d7-4979-a98f-9524b251c564	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	d0c58c40-a1f6-4a94-bbfd-bef418d3fe4a	{"reason": null, "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:21.484101+00
ffe3ff2f-f49f-4086-b111-7b01a3702f22	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	d0c58c40-a1f6-4a94-bbfd-bef418d3fe4a	{"reason": null, "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:21.552868+00
31bf8f33-6930-47bb-9e27-d98691ecbba8	5040313c-9900-4630-93f9-1f0e119412dd	INVOICE_GENERATED	invoice	7e8dfe6e-8aa2-4ad6-b61d-2d765bc9dd5d	{"total_amount": "1180.0000", "invoice_number": "INV-202610-0008", "subscription_id": "d0c58c40-a1f6-4a94-bbfd-bef418d3fe4a"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:21.621141+00
37a1df9d-5bc9-4ab9-abe6-43ea926e142f	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	db17cf02-d6b1-4db4-a8e9-5bf25f5a34f1	{"sku": "OP-DE242A", "name": "OP Prod de242a", "currency": "INR", "sales_price": "1000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:21.96493+00
f8dd0a9d-b922-4c63-b421-40b172aff397	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	7fdf215f-b7a1-4f77-8a65-3894140e0123	{"code": "OP-PLAN-DE242A", "name": "Overpay Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:21.994133+00
74f4e313-1d96-4505-ba4f-ec9b089179ca	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	4c391195-3813-48ba-8f4b-9e84de325bfd	{"plan_id": "7fdf215f-b7a1-4f77-8a65-3894140e0123", "quantity": 1, "product_id": "db17cf02-d6b1-4db4-a8e9-5bf25f5a34f1", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:22.019917+00
38ac019a-e74a-45b9-a652-ce5cede36ba0	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	7fdf215f-b7a1-4f77-8a65-3894140e0123	{"code": "OP-PLAN-DE242A", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:22.054715+00
10689aa9-4d99-4ee9-8a2a-3901c5f3dd4f	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	e5f99822-843b-4c7c-bd7b-3afa17d5e1c9	{"email": "op_de242a@test.com", "user_id": "84993fe6-4f73-4a8b-955a-f15c1376d1ca", "customer_number": "CUST-2026-0032"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:22.092443+00
2a26969d-6fbc-4302-9ad4-adca0597f51b	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	56bce7e4-07dc-4507-bd3a-99fbbd8415fb	{"plan_id": "7fdf215f-b7a1-4f77-8a65-3894140e0123", "customer_id": "e5f99822-843b-4c7c-bd7b-3afa17d5e1c9", "total_amount": "1180.0000", "subscription_number": "SUB-202610-0018"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:22.18957+00
cb8f3591-804d-4da3-a7d8-b2f26786e37a	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	56bce7e4-07dc-4507-bd3a-99fbbd8415fb	{"reason": null, "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:22.257115+00
099e73a1-0785-46f2-b545-77f78b6cb29b	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	56bce7e4-07dc-4507-bd3a-99fbbd8415fb	{"reason": null, "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:22.33173+00
98b99216-93a0-4608-abbd-5bd42a3df167	5040313c-9900-4630-93f9-1f0e119412dd	INVOICE_GENERATED	invoice	a9c2def3-0595-4a6f-98b3-418033c61e4d	{"total_amount": "1180.0000", "invoice_number": "INV-202610-0009", "subscription_id": "56bce7e4-07dc-4507-bd3a-99fbbd8415fb"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:22.400217+00
5ecf027b-db3d-4440-8164-a18eefc3f2dc	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	5177e078-61aa-4ac3-8f84-98df259d9d46	{"email": "iso1_cf17b0@demo.com", "user_id": "65b91682-558b-4f4c-951d-539434c14ef3", "customer_number": "CUST-2026-0033"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:22.658939+00
78667036-2cae-4715-ae70-784398827652	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	8da91ecb-8d8f-4399-a8d5-61db8250c6cb	{"email": "iso2_cf17b0@demo.com", "user_id": "af4e9265-bea5-47d4-9c2e-a362271ee196", "customer_number": "CUST-2026-0034"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:22.753581+00
3015c91f-f0e8-4751-ad7f-5db3fbdf30f9	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	650bdf95-c3b6-4a92-955b-9551fb73a316	{"sku": "NEG9-BA08BE", "name": "Neg9 Prod ba08be", "currency": "INR", "sales_price": "500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:23.067316+00
b3668ea5-7d71-42ac-b7cb-22ec4ba0755d	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	8aba86b1-d16b-4d9d-bb5f-3aa6e899dfef	{"code": "PLAN-NEG9-BA08BE", "name": "Neg9 Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:23.098977+00
ee4b3366-cd79-4c08-b231-aed840fca459	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	99be8c90-3d1a-4b57-8908-a17baa74f89f	{"plan_id": "8aba86b1-d16b-4d9d-bb5f-3aa6e899dfef", "quantity": 1, "product_id": "650bdf95-c3b6-4a92-955b-9551fb73a316", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:23.126682+00
f644a259-11d3-42fb-9f2f-5b03cb4dd125	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	8aba86b1-d16b-4d9d-bb5f-3aa6e899dfef	{"code": "PLAN-NEG9-BA08BE", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:23.157898+00
651bfe73-66a5-4219-bbd4-f0cd9c39575d	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	eb64f133-dafc-418f-8f4a-90e9dbc9cdcb	{"email": "neg9_ba08be@test.com", "user_id": "c22eb824-9d62-4962-8be8-1833cdd8ebdc", "customer_number": "CUST-2026-0035"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:23.1962+00
8affc695-31e4-4fb5-929b-b50d723d109b	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	f2b75ded-d929-4852-bceb-9abbaa11ef6c	{"plan_id": "8aba86b1-d16b-4d9d-bb5f-3aa6e899dfef", "customer_id": "eb64f133-dafc-418f-8f4a-90e9dbc9cdcb", "total_amount": "590.0000", "subscription_number": "SUB-202610-0019"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:23.28779+00
bbef9f99-8c36-4747-86c8-d9b63f1648cc	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	f2b75ded-d929-4852-bceb-9abbaa11ef6c	{"reason": null, "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:23.426327+00
b63ee6b1-4d1c-4aff-8b0f-01384644d667	5040313c-9900-4630-93f9-1f0e119412dd	INVOICE_GENERATED	invoice	0aab8183-061d-420f-94f8-28ccb3787387	{"total_amount": "590.0000", "invoice_number": "INV-202610-0010", "subscription_id": "f2b75ded-d929-4852-bceb-9abbaa11ef6c"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:23.499339+00
248a8981-97a8-4de8-a45d-1dba25407018	5040313c-9900-4630-93f9-1f0e119412dd	PAYMENT_RECORDED	payment	0f5b434f-bfad-44a2-a8e2-8c533e4b4da1	{"amount": "590.0000", "invoice_number": "INV-202610-0010", "payment_number": "PAY-202610-0011", "is_full_payment": true}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:23.596007+00
73577a25-b7c0-4116-9479-2122d60518ac	dd33a8aa-2d10-4ea2-91f8-045bc99db960	USER_REGISTERED	user	dd33a8aa-2d10-4ea2-91f8-045bc99db960	{"role": "CUSTOMER", "email": "customer_d5454a40@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:30.179672+00
31f31631-977b-4be8-9bcc-bbde48b04628	fc4eae69-efe6-4708-8c47-2aabba7084a6	USER_REGISTERED	user	fc4eae69-efe6-4708-8c47-2aabba7084a6	{"role": "CUSTOMER", "email": "dup_f5928f44@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:30.283603+00
d86a9239-d7cc-4932-80b9-1b1d986fd2b7	1d904ead-64da-41dd-8f28-84d07d2d29fa	USER_REGISTERED	user	1d904ead-64da-41dd-8f28-84d07d2d29fa	{"role": "CUSTOMER", "email": "login_user_5b5392cc@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:30.385422+00
2a9c31f6-b419-4c7e-9146-be207b45f7c6	1bf8ea9f-6b06-4da9-be91-3c8731819498	AUTH_LOGIN_SUCCESS	auth	1bf8ea9f-6b06-4da9-be91-3c8731819498	{"role": "CUSTOMER", "email": "login_user_a3fd2c4e@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:07.125393+00
7864a552-fa05-4a70-8d68-82935142be70	1d904ead-64da-41dd-8f28-84d07d2d29fa	AUTH_LOGIN_SUCCESS	auth	1d904ead-64da-41dd-8f28-84d07d2d29fa	{"role": "CUSTOMER", "email": "login_user_5b5392cc@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:30.535517+00
5661e1fc-6f2d-4a29-a0b8-2b10d60a70a6	47723f47-a83b-49e9-9544-0636e3b2e6b6	USER_REGISTERED	user	47723f47-a83b-49e9-9544-0636e3b2e6b6	{"role": "CUSTOMER", "email": "rotation_53c86ba9@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:30.610225+00
054aa6eb-9510-442e-8f65-eefb73a10b27	47723f47-a83b-49e9-9544-0636e3b2e6b6	TOKEN_ROTATED	auth	47723f47-a83b-49e9-9544-0636e3b2e6b6	{"family_id": "04998bfc-7d7a-4ed6-8330-1bfbfd3c6df0"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:30.693499+00
bd4ff61d-0854-46ca-ae1d-eaaec1d3c473	47723f47-a83b-49e9-9544-0636e3b2e6b6	TOKEN_REUSE_DETECTED	auth	c755d880-28f2-4871-9cf4-f14ce1b2bc40	{"reason": "Attempted reuse of consumed token", "family_id": "04998bfc-7d7a-4ed6-8330-1bfbfd3c6df0"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:30.717048+00
a692f2e4-acec-4f64-844c-8767ae1dc7cd	47723f47-a83b-49e9-9544-0636e3b2e6b6	TOKEN_REUSE_DETECTED	auth	3a9481fc-a08f-45ac-98a5-23ee7c7cf9bb	{"reason": "Attempted reuse of consumed token", "family_id": "04998bfc-7d7a-4ed6-8330-1bfbfd3c6df0"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:30.733883+00
2ee661af-be3e-4762-ab51-87eaf63aba14	b52074b1-7721-4486-aeb4-afada943f5cb	USER_REGISTERED	user	b52074b1-7721-4486-aeb4-afada943f5cb	{"role": "CUSTOMER", "email": "reset_2229b567@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:30.758689+00
0d974922-c376-4188-8699-79e7c6feddbb	b52074b1-7721-4486-aeb4-afada943f5cb	PASSWORD_RESET_REQUESTED	auth	b52074b1-7721-4486-aeb4-afada943f5cb	{"email": "reset_2229b567@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:30.839246+00
11d22069-0ac7-4969-83d5-275c3d5c96be	b52074b1-7721-4486-aeb4-afada943f5cb	PASSWORD_RESET_COMPLETED	auth	b52074b1-7721-4486-aeb4-afada943f5cb	{"email": "reset_2229b567@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:30.887169+00
ca0eeb3c-d605-4952-9239-9994f2484e58	b52074b1-7721-4486-aeb4-afada943f5cb	AUTH_LOGIN_SUCCESS	auth	b52074b1-7721-4486-aeb4-afada943f5cb	{"role": "CUSTOMER", "email": "reset_2229b567@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:31.019684+00
051427ad-0e0e-417e-808d-da3d7eb6592e	34f73287-5b8b-4edb-ab26-59b47bf6a813	USER_REGISTERED	user	34f73287-5b8b-4edb-ab26-59b47bf6a813	{"role": "CUSTOMER", "email": "multi_reset_1666611e@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:31.106245+00
d9592ec0-744e-4ed3-8493-31d3f6b457de	34f73287-5b8b-4edb-ab26-59b47bf6a813	PASSWORD_RESET_REQUESTED	auth	34f73287-5b8b-4edb-ab26-59b47bf6a813	{"email": "multi_reset_1666611e@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:31.183889+00
305e62f4-a85f-40f2-93c3-a5091b5f396f	34f73287-5b8b-4edb-ab26-59b47bf6a813	PASSWORD_RESET_REQUESTED	auth	34f73287-5b8b-4edb-ab26-59b47bf6a813	{"email": "multi_reset_1666611e@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:31.227712+00
dfd8f471-39b6-4245-a036-8eeddf245272	6e6cdc35-89ed-4d73-aebc-71bf44d5af09	USER_REGISTERED	user	6e6cdc35-89ed-4d73-aebc-71bf44d5af09	{"role": "CUSTOMER", "email": "logout_no_jwt_cde5f8ca@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:31.287301+00
f3071fc7-2c69-46cf-9e85-44fac203ee22	6e6cdc35-89ed-4d73-aebc-71bf44d5af09	TOKEN_REUSE_DETECTED	auth	021337e5-8995-4409-a417-a8ab91c87763	{"reason": "Attempted reuse of consumed token", "family_id": "0f630c5f-bd50-49a8-b186-d549094d3284"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:31.381856+00
996eef6f-ce36-44c8-8339-17f13829ca35	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	CUSTOMER_CREATED	customer	57adf978-6279-45ec-9fd8-80bdc24a4052	{"email": "enterprise_dd0d05@brightloop.io", "user_id": "fb9db2a2-56bc-409c-aeaf-a5401434e4e0", "customer_number": "CUST-2026-0036"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:31.508129+00
9ae8b58f-f0c7-4e40-b8e2-aa1d7dc05492	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:32.43992+00
4a7c62d8-fd2b-4610-a0c7-34268907916e	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	b9ba2119-ac8a-4bf5-85ff-889e7efba0d6	{"email": "audit_corp_4492ce@demo.com", "user_id": "4fab871e-76a3-44d9-b79f-cfa00204da30", "customer_number": "CUST-2026-0037"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:32.596675+00
405fb4f7-a90d-42c9-98a9-17d7fad2b060	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	7fc3f342-51f1-4164-8bae-dfa344fbf476	{"sku": "AUD-SKU-4492CE", "name": "Audit Analytics Suite 4492ce", "currency": "INR", "sales_price": "50000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:32.70076+00
27472600-345a-4be1-ab35-fcb6cbbdf802	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	80d48bf7-069c-4120-b281-056deee297dd	{"code": "PLAN-AUD-4492CE", "name": "Audit Pro Plan 4492ce", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:32.735377+00
0588b7a0-09ca-4021-9bba-070921364211	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	ecca1741-1162-4954-ad38-e2e75fd113f9	{"plan_id": "80d48bf7-069c-4120-b281-056deee297dd", "quantity": 1, "product_id": "7fc3f342-51f1-4164-8bae-dfa344fbf476", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:32.764902+00
5d255752-37ee-4c1d-813a-c0ceeecbba86	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	80d48bf7-069c-4120-b281-056deee297dd	{"code": "PLAN-AUD-4492CE", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:32.799907+00
5ff63d4f-3ac5-432c-b28e-821c4e1a3bc9	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	30ad68cd-90d1-4fc9-b2b5-ff49f20f8dfc	{"plan_id": "80d48bf7-069c-4120-b281-056deee297dd", "customer_id": "b9ba2119-ac8a-4bf5-85ff-889e7efba0d6", "total_amount": "59000.0000", "subscription_number": "SUB-202610-0020"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:32.841738+00
7e079e5f-f420-4a62-bacb-7d98cd7fb069	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	30ad68cd-90d1-4fc9-b2b5-ff49f20f8dfc	{"reason": "Formal quote dispatched", "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:32.917458+00
5e8488f4-4770-447d-8d1a-c1ac5a5777ad	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	30ad68cd-90d1-4fc9-b2b5-ff49f20f8dfc	{"reason": "Customer approved quote", "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:32.996538+00
09ae0051-9946-4217-89a6-aa30f739f2ec	5040313c-9900-4630-93f9-1f0e119412dd	INVOICE_GENERATED	invoice	153907e7-11b5-4b59-bff6-74e65a43799a	{"total_amount": "59000.0000", "invoice_number": "INV-202610-0011", "subscription_id": "30ad68cd-90d1-4fc9-b2b5-ff49f20f8dfc"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:33.063629+00
d6e93674-05ff-4b8c-bf8d-45c8c5796007	5040313c-9900-4630-93f9-1f0e119412dd	PAYMENT_RECORDED	payment	88722456-b85a-4c6d-9612-2a0b88525425	{"amount": "20000.0000", "invoice_number": "INV-202610-0011", "payment_number": "PAY-202610-0012", "is_full_payment": false}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:33.187334+00
2a650c28-cef8-4a4c-8f05-2d195ef3c8cb	5040313c-9900-4630-93f9-1f0e119412dd	PAYMENT_RECORDED	payment	ce557445-cab9-4ed6-88e0-0f6f628ebd2d	{"amount": "39000.0000", "invoice_number": "INV-202610-0011", "payment_number": "PAY-202610-0013", "is_full_payment": true}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:33.622729+00
c9d70519-eb81-4e4b-9a45-85d20b6660f6	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	22663fed-2aed-45ed-b61b-d8114b0fe954	{"email": "dup_8d6cbc@domain.com", "user_id": "88f37654-643e-4bd2-9dee-3ca6a2161e0a", "customer_number": "CUST-2026-0038"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:34.407562+00
8547068d-77eb-4c78-a6b4-2961cba0aa74	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	4f2a6c17-03c3-4515-be61-1269cf0fb4ab	{"sku": "QTY-62AA14", "name": "Qty Test Product 62aa14", "currency": "INR", "sales_price": "100.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:34.595836+00
aaa09485-e041-41ed-9c5d-bd2c6c2968c1	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	71fc50de-6cd7-44d2-81c6-5e749dee85f0	{"code": "PLAN-QTY-62AA14", "name": "Limited Quantity Plan 62aa14", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:34.623282+00
e3c582cf-94b9-4cb4-9f12-f0986ec041be	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	5e9bad8f-1986-4c50-84a4-a77c3df039f7	{"plan_id": "71fc50de-6cd7-44d2-81c6-5e749dee85f0", "quantity": 2, "product_id": "4f2a6c17-03c3-4515-be61-1269cf0fb4ab", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:34.648373+00
0ebce085-f7e4-4f86-9735-e3a783d009ef	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	71fc50de-6cd7-44d2-81c6-5e749dee85f0	{"code": "PLAN-QTY-62AA14", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:34.682266+00
24d0b7c8-ada4-4fd0-a647-cc56321e1712	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	78039001-abed-4aa5-9f3b-66cd3818e34d	{"email": "qty_62aa14@test.com", "user_id": "91efbe36-b71d-42fd-b7c3-e0b6d794f087", "customer_number": "CUST-2026-0039"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:34.721226+00
5cf53f6d-546f-4a53-b1f0-e42cfa31cfd4	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	31f17fbe-0754-4a16-8d91-827771aa6807	{"code": "DRAFT-185244", "name": "Draft Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:34.960286+00
0c2d6389-577f-4fb8-bf8d-2b360d125ce8	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	9af7b73b-6803-4f43-8a20-da983c986f12	{"email": "draft_185244@test.com", "user_id": "c389cf50-e0a6-4e9d-902d-dbde029ae58a", "customer_number": "CUST-2026-0040"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:34.986736+00
d698aa6e-5cc3-4e55-a88b-7261d05dbb9e	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	8e677bd2-2a28-432f-95eb-337f2b48f1e5	{"sku": "OVL-A17EC1", "name": "Overlap Prod a17ec1", "currency": "INR", "sales_price": "1000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:35.185917+00
29d14a53-1c19-4f60-ae80-2a2f774148a8	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	71bc4fdd-3710-4983-b791-4d51f05fc06f	{"code": "OVL-PLAN-A17EC1", "name": "Overlap Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:35.21748+00
0b52d84a-e215-4ec4-abd6-3f955c589d9b	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	752f1554-8d07-4354-aefe-17ad9c4e9556	{"plan_id": "71bc4fdd-3710-4983-b791-4d51f05fc06f", "quantity": 1, "product_id": "8e677bd2-2a28-432f-95eb-337f2b48f1e5", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:35.244351+00
88daa96d-0d31-400c-a083-e70c086b1e0c	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	71bc4fdd-3710-4983-b791-4d51f05fc06f	{"code": "OVL-PLAN-A17EC1", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:35.27682+00
71bc0028-df8d-45cf-a09c-ff5c084fe101	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	a7b2a3b6-0da7-4090-91a0-c7dcf15afcce	{"email": "ovl_a17ec1@test.com", "user_id": "90a4e297-4cad-4ec5-b65f-a0653eff9316", "customer_number": "CUST-2026-0041"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:35.316262+00
44268228-cc3f-49c7-8bd3-67cad3a20e54	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	2c293e93-3a1f-4630-8462-a57f05ea41c7	{"plan_id": "71bc4fdd-3710-4983-b791-4d51f05fc06f", "customer_id": "a7b2a3b6-0da7-4090-91a0-c7dcf15afcce", "total_amount": "1180.0000", "subscription_number": "SUB-202610-0021"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:35.407239+00
468d9d59-dd17-441e-95db-00c49e5a1eec	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	2c293e93-3a1f-4630-8462-a57f05ea41c7	{"reason": null, "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:35.483545+00
4ce7bffc-3140-40ee-acde-78e444e41cb1	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	2c293e93-3a1f-4630-8462-a57f05ea41c7	{"reason": null, "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:35.558102+00
14609d30-c3de-4467-8ccb-86e2735b1093	5040313c-9900-4630-93f9-1f0e119412dd	INVOICE_GENERATED	invoice	af36956d-d174-4992-8e6c-f6e22f04cc4d	{"total_amount": "1180.0000", "invoice_number": "INV-202610-0012", "subscription_id": "2c293e93-3a1f-4630-8462-a57f05ea41c7"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:35.624136+00
471ffc54-a846-4848-ad73-5cb5217449dc	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	c490928c-9a8c-4437-9601-1abebc4075b7	{"sku": "OP-625C40", "name": "OP Prod 625c40", "currency": "INR", "sales_price": "1000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:35.97391+00
0264cf5c-6683-44e2-99b7-23432d7b27af	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	09cd09d4-49bb-445a-a354-dbadde65da9b	{"code": "OP-PLAN-625C40", "name": "Overpay Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:36.006507+00
8dff7f37-613a-46df-8acf-ee68ac36170e	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	5bb98351-e93b-420e-89e4-0f186cbc3c35	{"plan_id": "09cd09d4-49bb-445a-a354-dbadde65da9b", "quantity": 1, "product_id": "c490928c-9a8c-4437-9601-1abebc4075b7", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:36.036448+00
60360591-3137-49e6-93dd-9820fea20ac7	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	09cd09d4-49bb-445a-a354-dbadde65da9b	{"code": "OP-PLAN-625C40", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:36.069601+00
464fb0e1-e9f4-4a97-a5d6-0c6c52ee1886	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	0704c6a3-68be-4b4c-adca-8184b6bdbc45	{"email": "op_625c40@test.com", "user_id": "889eda05-ce54-41a7-b84f-f6a34f2875e6", "customer_number": "CUST-2026-0042"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:36.108204+00
52709190-0a8f-4283-8122-ff8d806a7f46	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	1d20677a-d222-4695-b150-72ad3587c5e6	{"plan_id": "09cd09d4-49bb-445a-a354-dbadde65da9b", "customer_id": "0704c6a3-68be-4b4c-adca-8184b6bdbc45", "total_amount": "1180.0000", "subscription_number": "SUB-202610-0022"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:36.198985+00
853e2ae1-e7cc-459d-9dc2-4c34aacdac84	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	1d20677a-d222-4695-b150-72ad3587c5e6	{"reason": null, "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:36.263245+00
73a10ab3-4bfb-4b6e-8e66-2965a0ba7d69	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	1d20677a-d222-4695-b150-72ad3587c5e6	{"reason": null, "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:36.332723+00
50a6a799-1011-4b25-9c89-6bbf27dfa850	5040313c-9900-4630-93f9-1f0e119412dd	INVOICE_GENERATED	invoice	1683324b-0c67-4574-9665-a0acb335760e	{"total_amount": "1180.0000", "invoice_number": "INV-202610-0013", "subscription_id": "1d20677a-d222-4695-b150-72ad3587c5e6"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:36.402136+00
f5fc38ff-f4e9-46de-ad9b-ba13994dced5	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	179bb96c-2092-44ba-a19d-6237f83958f8	{"email": "iso1_a2be66@demo.com", "user_id": "e33b5e88-21a9-45d1-b952-d136248b7c66", "customer_number": "CUST-2026-0043"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:36.728894+00
4021b4ce-2530-4642-a10f-9374921f3974	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	e53b2007-eddf-4d04-baa3-ced00620b74f	{"email": "iso2_a2be66@demo.com", "user_id": "6f4196d9-dfc0-4b52-a861-f008e3abf5d1", "customer_number": "CUST-2026-0044"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:36.8174+00
08b1a67f-a109-422a-a9b8-31c9ce9e622d	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	5bea6103-3d8f-49c0-b077-370f3e20b856	{"sku": "NEG9-2BACB8", "name": "Neg9 Prod 2bacb8", "currency": "INR", "sales_price": "500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:37.106524+00
2d23ae3b-aaf4-46bc-a77d-42dab2d68a3a	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	c1898049-e5c0-4876-895c-652b068ef387	{"code": "PLAN-NEG9-2BACB8", "name": "Neg9 Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:37.136183+00
9ea7664b-c266-4bf9-bbba-3354b9e384e0	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	f5c17154-a9af-4627-9d6b-0d5824397ef5	{"plan_id": "c1898049-e5c0-4876-895c-652b068ef387", "quantity": 1, "product_id": "5bea6103-3d8f-49c0-b077-370f3e20b856", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:37.164889+00
0f4d07a9-9ec3-4de7-a476-dbfe8d15227b	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	c1898049-e5c0-4876-895c-652b068ef387	{"code": "PLAN-NEG9-2BACB8", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:37.199994+00
106ea0a2-b4ec-465d-93b9-26f953d586de	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	cb06e29c-acf5-4d8e-9b97-91a250b6b4d8	{"email": "neg9_2bacb8@test.com", "user_id": "9d8e82ae-c214-4448-905b-a63fdf530a27", "customer_number": "CUST-2026-0045"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:37.240809+00
65446cbb-06fe-4006-ab67-25c10e4ccc64	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	b009b479-8b6f-4eb5-967e-c069ce31b7ad	{"plan_id": "c1898049-e5c0-4876-895c-652b068ef387", "customer_id": "cb06e29c-acf5-4d8e-9b97-91a250b6b4d8", "total_amount": "590.0000", "subscription_number": "SUB-202610-0023"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:37.338282+00
635af85f-f243-4392-a464-69807d7bba27	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	b009b479-8b6f-4eb5-967e-c069ce31b7ad	{"reason": null, "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:37.411224+00
ed9581f7-6b7b-48f7-9118-368ce5c909bc	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	b009b479-8b6f-4eb5-967e-c069ce31b7ad	{"reason": null, "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:37.483434+00
9195de66-34cb-46ca-8ef2-da16ef653db1	5040313c-9900-4630-93f9-1f0e119412dd	INVOICE_GENERATED	invoice	5324b6db-b19a-45b5-a2d0-9747f4fa1597	{"total_amount": "590.0000", "invoice_number": "INV-202610-0014", "subscription_id": "b009b479-8b6f-4eb5-967e-c069ce31b7ad"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:37.557389+00
358d356d-8db5-4a12-833a-a7d015336c44	5040313c-9900-4630-93f9-1f0e119412dd	PAYMENT_RECORDED	payment	4206fd6f-01c7-4917-9334-8cc479280b8e	{"amount": "590.0000", "invoice_number": "INV-202610-0014", "payment_number": "PAY-202610-0014", "is_full_payment": true}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:37.656834+00
596920c6-4e10-4d22-82f7-4f6c5eb8b85a	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	e7f7f3ac-3fa7-4818-b3da-4d643758ecfc	{"sku": "SEC-4E2C2", "name": "Cloud Security Suite", "currency": "INR", "sales_price": "2000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:38.172839+00
dd3364e2-cc9f-4224-8ff8-480df73a7c4d	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	607f6d79-67ea-4b2a-8264-eae014a615e5	{"code": "PLAN-SEC-85D02", "name": "Security Pro Monthly", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:38.200451+00
03d0180e-23ea-4d63-bd25-71b4776c3f8c	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	adabf165-15ac-4b4b-89a8-41454f93b3f3	{"plan_id": "607f6d79-67ea-4b2a-8264-eae014a615e5", "quantity": 1, "product_id": "e7f7f3ac-3fa7-4818-b3da-4d643758ecfc", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:38.228827+00
e50f1e9d-38d8-4dcf-a740-3c9d05039f52	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	607f6d79-67ea-4b2a-8264-eae014a615e5	{"code": "PLAN-SEC-85D02", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:38.262217+00
be480f52-a460-4d95-9035-4771dd1134e2	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	CUSTOMER_CREATED	customer	4f3ec259-43da-4e7a-8316-22a71e23d0db	{"email": "billing_db7e4@infosys.com", "user_id": "aff0484e-01ce-4d30-b1e8-4912a70980ff", "customer_number": "CUST-2026-0046"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:38.300921+00
27905feb-92a0-42ca-867f-7b24ccfc8d90	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_CREATED	subscription	5ac937b7-c600-4f8e-9e05-4df0583deeb6	{"plan_id": "607f6d79-67ea-4b2a-8264-eae014a615e5", "customer_id": "4f3ec259-43da-4e7a-8316-22a71e23d0db", "total_amount": "2360.0000", "subscription_number": "SUB-202610-0024"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:38.395942+00
14b0dad5-2b79-45b9-b8f7-e6ea16514c20	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_STATUS_CHANGED	subscription	5ac937b7-c600-4f8e-9e05-4df0583deeb6	{"reason": null, "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:38.457305+00
e20ae752-1212-4ebd-8196-46090e1ff0a4	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_STATUS_CHANGED	subscription	5ac937b7-c600-4f8e-9e05-4df0583deeb6	{"reason": null, "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:38.532723+00
737e469e-55c3-48ee-8791-416f639f45c7	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	INVOICE_GENERATED	invoice	9796d144-f65d-43e5-91cb-f5f5420c1cef	{"total_amount": "2360.0000", "invoice_number": "INV-202610-0015", "subscription_id": "5ac937b7-c600-4f8e-9e05-4df0583deeb6"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:38.601462+00
799e985e-83ac-4126-97ed-812c7e54f2b6	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	PAYMENT_RECORDED	payment	16ea77b9-f232-4fd2-9cbc-fab74c4cbe21	{"amount": "1000.0000", "invoice_number": "INV-202610-0015", "payment_number": "PAY-202610-0015", "is_full_payment": false}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:38.829944+00
9dc7538b-05c2-460e-bdde-bb53d0e4752d	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	PAYMENT_RECORDED	payment	2e2c12bb-bbda-4a23-bac9-ae415d598d3a	{"amount": "1360.0000", "invoice_number": "INV-202610-0015", "payment_number": "PAY-202610-0016", "is_full_payment": true}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:39.199716+00
1a0138dc-f506-404f-bd4e-5e2c5e1bc70f	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	7090854b-634c-430b-8251-559ea3b5b470	{"sku": "INR-FE88D0", "name": "INR Service", "currency": "INR", "sales_price": "1000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:39.808323+00
cce18f4e-337a-4b7f-b17a-672767a50295	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	f332c5d3-ccfe-4fb8-a940-9d0eebba6fab	{"sku": "USD-D615AB", "name": "USD Service", "currency": "USD", "sales_price": "50.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:39.840896+00
c2644cab-e877-4437-b99f-48025841dd8f	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	57fffd3e-9dc2-4994-9203-4f9ede28bca2	{"code": "PLAN-INR-715B11", "name": "Enterprise INR Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:39.883045+00
2a3b1581-fd55-44f9-b524-ffbb1a35b24b	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	cc6ad884-4520-4584-a76f-3b01331a3759	{"plan_id": "57fffd3e-9dc2-4994-9203-4f9ede28bca2", "quantity": 2, "product_id": "7090854b-634c-430b-8251-559ea3b5b470", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:39.934139+00
90639764-7516-4fb9-9113-f40c6151563a	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	87df6dd3-3156-40d5-a694-5e034f2b21e6	{"code": "GUARD-9584C7", "name": "Empty Draft Plan", "currency": "INR", "billing_interval": "YEARLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:39.984963+00
d52ee50d-f26f-4127-906b-fa2d1f68d137	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	e19e498e-8fbb-4734-9519-84c3a22650c1	{"sku": "BASE-9A2685", "name": "Base Software", "currency": "INR", "sales_price": "3000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:40.028576+00
796bdc05-4b31-4959-a789-bcd02d2272a4	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	6fa431c2-9e47-4326-a11d-1c7da2fc4dab	{"plan_id": "87df6dd3-3156-40d5-a694-5e034f2b21e6", "quantity": 1, "product_id": "e19e498e-8fbb-4734-9519-84c3a22650c1", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:40.054621+00
e4d1d9ae-7242-4860-b06e-84f5a7a46d9c	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	87df6dd3-3156-40d5-a694-5e034f2b21e6	{"code": "GUARD-9584C7", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:40.088606+00
8025cf53-b8d8-47a1-99f2-d5fb3eb196e0	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	87df6dd3-3156-40d5-a694-5e034f2b21e6	{"code": "GUARD-9584C7", "new_status": "INACTIVE", "old_status": "INACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:40.129127+00
1cc39a11-1e55-4264-9545-d00bdc245cb5	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	87df6dd3-3156-40d5-a694-5e034f2b21e6	{"code": "GUARD-9584C7", "new_status": "ARCHIVED", "old_status": "ARCHIVED"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:40.170807+00
4b26a90a-5437-40bc-9a60-9c352b804ff8	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	054c67bf-f82b-40c3-9817-1266139fb3ac	{"sku": "AC-DFD29F", "name": "Auto Close Product", "currency": "INR", "sales_price": "1500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:40.251474+00
53afcedd-1b64-4658-840c-c4f3015a8dd0	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	e2e7cde0-2a3a-4e25-ab6a-d281354dbf19	{"code": "AUTO-A43486", "name": "Limited Time Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:40.282797+00
daa65957-df96-4f8e-8f86-bc36067942f7	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	e2e7cde0-2a3a-4e25-ab6a-d281354dbf19	{"code": "AUTO-A43486", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:40.319869+00
db3bc9f3-c827-4eca-b1ed-d2971689bcd0	\N	PLAN_AUTO_CLOSED	SUBSCRIPTION_PLAN	e2e7cde0-2a3a-4e25-ab6a-d281354dbf19	{"code": "AUTO-A43486", "reason": "Availability end date '2026-10-31 05:38:40.276461+00:00' reached."}	\N	\N	2026-10-31 07:38:40.319869+00
9ef34dfc-1f5f-48fd-9a5b-0681f9c37285	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	d5802e47-aede-48cb-8212-855361c869b8	{"sku": "CRM-2FFB1A", "name": "CRM Software", "currency": "INR", "sales_price": "2000.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:40.410335+00
07340a24-98eb-41fa-9c4d-70bb9414b5fd	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	74e894ce-1042-41dc-8a01-f6cabb1babbe	{"code": "CRM-PLAN-0878D7", "name": "CRM Standard Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:40.448772+00
4c577a5a-dc08-4a9e-9664-f73c3876fee5	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	5c9d566f-4315-4653-ac3c-b6b9e78c62c8	{"plan_id": "74e894ce-1042-41dc-8a01-f6cabb1babbe", "quantity": 3, "product_id": "d5802e47-aede-48cb-8212-855361c869b8", "variant_id": "fd5cbb88-555d-497a-ae46-b3d5ad896298", "price_override": "2200.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:40.47355+00
76d5b9a8-7173-4122-9a4f-d35be33f82bc	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_UPDATED	PLAN_PRODUCT	5c9d566f-4315-4653-ac3c-b6b9e78c62c8	{"plan_id": "74e894ce-1042-41dc-8a01-f6cabb1babbe", "quantity": 5, "is_active": true}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:40.544976+00
1cf454a1-afb3-4cbc-8db6-9181d7e812d6	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_REMOVED	PLAN_PRODUCT	5c9d566f-4315-4653-ac3c-b6b9e78c62c8	{"plan_id": "74e894ce-1042-41dc-8a01-f6cabb1babbe"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:40.631317+00
757f1a80-4788-4523-b32d-6d3c78f1dd93	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	c96bdd64-40ce-40fc-a165-2ff67e37088e	{"sku": "ERP-446A89", "name": "ERP Financials", "currency": "INR", "sales_price": "2000.0000", "variants_count": 2}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:40.710591+00
7fcaaeb2-8ab0-457e-93e4-c452bc95a476	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	d3e8f730-2214-4391-99d7-42a257431398	{"sku": "SW-DC88D5", "name": "Standard Software", "currency": "INR", "sales_price": "5000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:40.794809+00
c85a3449-6ea4-46b6-a225-ff95d7faff1f	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	d8969bdc-b55f-45af-b479-0dbc098e71bc	{"sku": "INR-C53BA3", "name": "INR Product", "currency": "INR", "sales_price": "100.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:40.862446+00
d0f3b914-a3ee-4921-a066-d925d7052ba6	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	ccc3244e-bd3a-4ccf-9b7e-55060b9cec92	{"sku": "SKU-DC3FB5", "name": "Brightloop ERP Cloud", "currency": "INR", "sales_price": "2000.0000", "variants_count": 2}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:40.943603+00
0ed5defa-c54d-49cf-9f0a-65f179bbd576	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_CREATED	PRODUCT_VARIANT	06303433-bc3b-4d4f-979e-277003ab1aad	{"product_id": "ccc3244e-bd3a-4ccf-9b7e-55060b9cec92", "variant_code": "ENT", "variant_name": "Enterprise Addon", "adjustment_type": "PERCENTAGE", "adjustment_value": "25.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:41.011486+00
6223bb84-92fa-40f8-96f0-af58b8663be3	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	9fa9f36b-eab8-40f9-8e6e-f3c587af7e2f	{"sku": "RBAC-61D736", "name": "Admin Product", "currency": "INR", "sales_price": "500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:41.135501+00
31f7714c-2195-4b8f-ae75-f48ae4b34d44	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	e54b5f0a-5d7e-4477-add3-ca6039fd8723	{"sku": "HIST-15184D", "name": "History Test Product", "currency": "INR", "sales_price": "1000.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:41.207953+00
4c2c2872-6f79-42f3-80cd-3df7f926e3d8	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_UPDATED	PRODUCT	e54b5f0a-5d7e-4477-add3-ca6039fd8723	{"sku": "HIST-15184D", "name": "History Test Product", "reason": "Annual inflation rate increase", "price_changes": {"cost_price": {"new": "450.0000", "old": "300.0000"}, "sales_price": {"new": "1500.0000", "old": "1000.0000"}}}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:41.249154+00
bbe45534-0b96-4aeb-a50b-a8c3253966a5	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_UPDATED	PRODUCT_VARIANT	8defbe56-c536-4704-ba6f-f8c17666cfa0	{"variant_code": "PRO", "variant_name": "Pro Pack", "adjustment_type": "PERCENTAGE", "adjustment_value": "30.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:41.291098+00
0cdcf89d-ef84-4f9f-8b67-a4b88e6400d1	f8153125-3c20-42d4-ad8f-09c161b7bb5d	USER_REGISTERED	user	f8153125-3c20-42d4-ad8f-09c161b7bb5d	{"role": "CUSTOMER", "email": "rotation_1da38672@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:07.25796+00
4a99a4da-2dd0-4535-8f5b-a2d031fe8226	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	0c0bf333-9976-4b9c-ae78-70e1bd9fddc4	{"sku": "ARCH-0402FA", "name": "To Archive Product", "currency": "INR", "sales_price": "750.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:41.337753+00
dfdd1346-cfb9-484c-a67b-4916f99da522	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_ARCHIVED	PRODUCT	0c0bf333-9976-4b9c-ae78-70e1bd9fddc4	{"sku": "ARCH-0402FA", "name": "To Archive Product", "deactivated_plan_line_items": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:41.367624+00
f169f235-3a7e-4c73-941d-29656f6d853b	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_DEACTIVATED	PRODUCT_VARIANT	c061b2f3-abb8-494c-9177-bb3c19cb63b7	{"variant_code": "VA", "variant_name": "Variant A", "deactivated_plan_line_items": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:41.408063+00
f422bab3-902e-4de4-9058-df6f8df2431e	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	2758ae3b-77c6-43a1-ae62-0cf0bb304cac	{"sku": "PROD-SUB-2EE40", "name": "Cloud CRM Platform", "currency": "INR", "sales_price": "5000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:41.667772+00
d833abdb-0e30-4fcd-a73f-ae13792b360c	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	147b0b93-5602-4647-b291-00677cb15235	{"code": "PLAN-CRM-78888", "name": "Enterprise CRM Annual", "currency": "INR", "billing_interval": "YEARLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:41.70183+00
549ea819-e094-4454-86bb-ca4ec5749d0c	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	7b439a48-968d-4bd5-b799-d7a8b5ae2718	{"plan_id": "147b0b93-5602-4647-b291-00677cb15235", "quantity": 2, "product_id": "2758ae3b-77c6-43a1-ae62-0cf0bb304cac", "variant_id": null, "price_override": "4500.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:41.727266+00
f83181fa-3d28-4a4c-bcca-358ee61211fc	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	147b0b93-5602-4647-b291-00677cb15235	{"code": "PLAN-CRM-78888", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:41.759428+00
8e813e20-ab6b-4b15-8e4a-a3f22e9e726d	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	CUSTOMER_CREATED	customer	736170c1-8d28-4697-8a53-2078ecea8b13	{"email": "tata_63c79@tatatech.com", "user_id": "1a8e2f4a-a11b-4bed-a4ea-d7273cf7836e", "customer_number": "CUST-2026-0047"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:41.796065+00
611a6112-54a1-444c-8822-725db2a9093c	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_CREATED	subscription	92d73e49-4377-41ad-8f79-48c14bdee83a	{"plan_id": "147b0b93-5602-4647-b291-00677cb15235", "customer_id": "736170c1-8d28-4697-8a53-2078ecea8b13", "total_amount": "10030.0000", "subscription_number": "SUB-202610-0025"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:41.888923+00
00c4bfbe-f87c-405d-84e6-06a0425e26e0	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_STATUS_CHANGED	subscription	92d73e49-4377-41ad-8f79-48c14bdee83a	{"reason": "Sent quote to client", "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:41.95841+00
9523f9fc-3f02-41b2-a1ed-ee365d2f67e8	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_STATUS_CHANGED	subscription	92d73e49-4377-41ad-8f79-48c14bdee83a	{"reason": "Client signed contract", "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:42.032616+00
b46608c8-76f6-456a-8b08-f7cfefeb276b	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:42.161193+00
7e817bff-0575-411d-b40c-c5c4c24174b5	a7a24781-d0b5-4d15-bb0d-c952a1ccf9d9	USER_REGISTERED	user	a7a24781-d0b5-4d15-bb0d-c952a1ccf9d9	{"role": "CUSTOMER", "email": "cust1_c7e574ed@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:42.227976+00
32cbf37b-e9cf-4ba2-80c0-bcc25809d565	13d35249-411e-449c-b092-9fd70812906d	USER_REGISTERED	user	13d35249-411e-449c-b092-9fd70812906d	{"role": "CUSTOMER", "email": "cust2_d51356db@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:42.304818+00
d2153852-85fe-4cfd-af40-46a862622fe4	5040313c-9900-4630-93f9-1f0e119412dd	STAFF_CREATED	user	80dc8efc-2bf2-468d-84a3-7d3fde065492	{"role": "STAFF", "created_email": "staff_1bdadc01@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:42.443939+00
59f2531a-c87b-4c14-9283-6833f46bebac	80dc8efc-2bf2-468d-84a3-7d3fde065492	AUTH_LOGIN_SUCCESS	auth	80dc8efc-2bf2-468d-84a3-7d3fde065492	{"role": "STAFF", "email": "staff_1bdadc01@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:42.511442+00
4d5c8452-4590-4f94-892b-d38276c55efc	5040313c-9900-4630-93f9-1f0e119412dd	USER_STATUS_UPDATED	user	a7a24781-d0b5-4d15-bb0d-c952a1ccf9d9	{"is_active": false, "target_email": "cust1_c7e574ed@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 07:38:42.675896+00
5a4d2550-5e0c-4613-adbc-e513b95376a5	f8153125-3c20-42d4-ad8f-09c161b7bb5d	TOKEN_ROTATED	auth	f8153125-3c20-42d4-ad8f-09c161b7bb5d	{"family_id": "c8310cba-720d-42be-96de-aab6b79ddf7b"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:07.36568+00
f09d2df1-7633-4b62-afdd-1d8cf2a21d00	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	875aa731-5cb8-4dda-8c8f-30e6c35a22f2	{"reason": "Sent commercial proposal", "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:09.376958+00
19002448-02a3-4044-9ce7-42ad1b9c302d	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	d3d2ff47-1496-45ee-bc84-ec7e81aced75	{"reason": "Customer approved quote", "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:11.5357+00
c8a4ef90-57fa-44ca-bd65-0fc6553b49b7	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	19f0e22f-9e12-42eb-800e-bb733dc5e7a9	{"code": "PLAN-QTY-16E322", "name": "Limited Quantity Plan 16e322", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:13.575288+00
21a66b7b-86f6-41c6-9bf2-f809e06d39f5	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	f9b16ecd-e8bf-46ef-8482-2a84eb215fd2	{"sku": "OVL-B22D76", "name": "Overlap Prod b22d76", "currency": "INR", "sales_price": "1000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:14.227525+00
627ab8a3-44ad-4b95-a68c-96e67d72a1f8	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	f6261125-c013-4208-a694-f85ba034150b	{"plan_id": "63848a77-2df4-4368-8796-c09dac27b6f4", "customer_id": "0e75110e-28f7-451f-a480-86c34b25a040", "total_amount": "1180.0000", "subscription_number": "SUB-202610-0029"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:14.475416+00
9b5f0dc0-ccfd-4323-ae96-a1e1f1d03c50	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	7f8d1ec4-f42c-48c7-928f-278cf9d23b34	{"sku": "OP-DBFA6B", "name": "OP Prod dbfa6b", "currency": "INR", "sales_price": "1000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:15.121532+00
673418c9-47d3-43c2-84b5-fab2e7c22bc4	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	40937aa1-dcea-4eee-b28b-597f431549e5	{"email": "op_dbfa6b@test.com", "user_id": "261631bd-d1cf-446a-9f07-5b60a4dc8aaa", "customer_number": "CUST-2026-0056"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:15.282126+00
e3423f00-c71e-4988-a805-93e435729487	5040313c-9900-4630-93f9-1f0e119412dd	INVOICE_GENERATED	invoice	9d18c9ea-906f-47c7-8958-310eb2af70bb	{"total_amount": "1180.0000", "invoice_number": "INV-202610-0018", "subscription_id": "96e254fe-161e-43c8-bd4e-374d2a6277a3"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:15.660904+00
0bd44b64-66c7-4bf9-99fb-4e7ba8f24e37	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	2174e10f-65e8-4882-b370-2dfd10171b07	{"code": "PLAN-NEG9-7559A3", "name": "Neg9 Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:16.647592+00
0b1d7ec8-1e5e-4395-a8e4-3e0e948001d0	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	6b0a8d72-7313-402a-9e66-e287cb1eef53	{"plan_id": "2174e10f-65e8-4882-b370-2dfd10171b07", "customer_id": "ef262998-7f20-45f5-bed3-ac7a7de9c250", "total_amount": "590.0000", "subscription_number": "SUB-202610-0031"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:16.859998+00
ae89ca28-965e-4818-908d-2ebd8219b80f	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:21.814642+00
33eecbf0-93e8-459a-a369-1453a744f718	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_ARCHIVED	PRODUCT	5a501b7e-5295-4719-8c88-20c5ffcced35	{"sku": "ARCH-48E91E", "name": "To Archive Product", "deactivated_plan_line_items": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:20.950175+00
b3894027-f478-42f5-895d-88ca397d084c	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_DEACTIVATED	PRODUCT_VARIANT	de329838-0631-4665-9d7d-8fce07dcedd5	{"variant_code": "VA", "variant_name": "Variant A", "deactivated_plan_line_items": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:20.990176+00
253d2913-d722-420f-8428-bf058b237fa1	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	95724fee-0cd6-49aa-9308-0829fe8c0f13	{"sku": "PROD-SUB-673A0", "name": "Cloud CRM Platform", "currency": "INR", "sales_price": "5000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:21.253193+00
4fd058ee-5ebe-45a8-9348-7bbf4788213c	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	3ebd52a8-4f5e-4ffc-8137-ed0b98bf0ac6	{"code": "PLAN-CRM-1E964", "name": "Enterprise CRM Annual", "currency": "INR", "billing_interval": "YEARLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:21.292669+00
6a298bd8-ab6a-4067-8a79-701b723c82ea	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	e14b2065-2305-4afb-9e8a-f87e8f20738c	{"plan_id": "3ebd52a8-4f5e-4ffc-8137-ed0b98bf0ac6", "quantity": 2, "product_id": "95724fee-0cd6-49aa-9308-0829fe8c0f13", "variant_id": null, "price_override": "4500.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:21.323395+00
39f020a2-9c07-4f41-b9b4-789f675b7e74	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	3ebd52a8-4f5e-4ffc-8137-ed0b98bf0ac6	{"code": "PLAN-CRM-1E964", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:21.355648+00
96a0dfc8-19f9-4d6f-940b-148e2931f2de	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	CUSTOMER_CREATED	customer	dfba3c49-ad17-4293-b71b-dbbdc4b2f9e5	{"email": "tata_f6526@tatatech.com", "user_id": "9535692d-19c4-45bb-ab16-3053ea78719a", "customer_number": "CUST-2026-0061"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:21.397201+00
35b9c536-8958-4a22-aa33-5e48874708dc	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_CREATED	subscription	e5515f04-233b-497e-9d5c-ac98cbca4ba9	{"plan_id": "3ebd52a8-4f5e-4ffc-8137-ed0b98bf0ac6", "customer_id": "dfba3c49-ad17-4293-b71b-dbbdc4b2f9e5", "total_amount": "10030.0000", "subscription_number": "SUB-202610-0033"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:21.495802+00
c46fcfdb-5294-4376-bdf3-ca5aec35ff5f	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_STATUS_CHANGED	subscription	e5515f04-233b-497e-9d5c-ac98cbca4ba9	{"reason": "Sent quote to client", "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:21.570074+00
8e3dbaf1-fa8d-4452-a71b-a98f618b3f6c	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_STATUS_CHANGED	subscription	e5515f04-233b-497e-9d5c-ac98cbca4ba9	{"reason": "Client signed contract", "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:21.64325+00
552dab4b-9c72-4356-9c38-88fed6e0c4e7	5c45be20-2ccb-4a5c-a8cd-97cfad043ed8	AUTH_LOGIN_SUCCESS	auth	5c45be20-2ccb-4a5c-a8cd-97cfad043ed8	{"role": "STAFF", "email": "staff_6da5635c@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:22.19148+00
f0aed60d-76df-430e-9e4c-4a77fc64d830	5040313c-9900-4630-93f9-1f0e119412dd	USER_STATUS_UPDATED	user	d9cf23a9-f82e-4101-839c-2dad7bc4dbd4	{"is_active": false, "target_email": "cust1_a69ddd16@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:24:22.35312+00
2557a92f-9d95-4561-888a-9f98293a320e	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:24.145164+00
1696e5b1-cd07-4380-8a66-5a75d952c35f	50ec2373-3a67-4c8b-b33f-36a47643a3f2	USER_REGISTERED	user	50ec2373-3a67-4c8b-b33f-36a47643a3f2	{"role": "CUSTOMER", "email": "catalog_cust_7b58f5@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:24.335031+00
a79b9112-912c-4cc3-86a4-f3f2510695e8	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:24.518662+00
ee40dc84-64c9-47b3-95ef-2ca0cee06e96	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	471abd59-8328-4d62-86a5-c44e823b038f	{"email": "starter_corp_9ae423@example.com", "user_id": "d5006a51-cf62-44de-84be-7524ddd06dca", "customer_number": "CUST-2026-0062"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:24.62056+00
22b19fe2-2984-4cc4-aec9-be85e5f740f5	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	c922adde-b083-4ccc-8cf1-fbc7fe27b2dc	{"plan_id": "0086d29b-ddd9-4dc5-9ac0-3d74ea38cba4", "customer_id": "471abd59-8328-4d62-86a5-c44e823b038f", "total_amount": "1178.8200", "subscription_number": "SUB-202610-0034"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:24.723866+00
346e4e3e-9fa3-48f6-9241-7d2229ec7217	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	c922adde-b083-4ccc-8cf1-fbc7fe27b2dc	{"reason": "Sent commercial proposal", "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:24.812904+00
63c0b5ae-2b79-421a-b17f-0672540068b5	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	c922adde-b083-4ccc-8cf1-fbc7fe27b2dc	{"reason": "Proposal signed by client", "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:24.885613+00
96a270a0-7d1f-4817-9771-61d0d007777e	13cd1286-ab5c-489a-9999-083280c82eae	USER_REGISTERED	user	13cd1286-ab5c-489a-9999-083280c82eae	{"role": "CUSTOMER", "email": "customer_90929c8f@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:34.318087+00
32f85aca-3112-4759-b9aa-329920bcc11f	54190478-8281-4812-83fc-5079ac387073	USER_REGISTERED	user	54190478-8281-4812-83fc-5079ac387073	{"role": "CUSTOMER", "email": "dup_77bb179f@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:34.432848+00
dcd6b830-6a5c-497e-9d8d-729198a3e01d	b27cd89f-beef-49c0-85af-2bc3952bd5cb	USER_REGISTERED	user	b27cd89f-beef-49c0-85af-2bc3952bd5cb	{"role": "CUSTOMER", "email": "login_user_29b46b27@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:34.546948+00
a3579e70-13f4-4130-b644-2129e375331b	b27cd89f-beef-49c0-85af-2bc3952bd5cb	AUTH_LOGIN_SUCCESS	auth	b27cd89f-beef-49c0-85af-2bc3952bd5cb	{"role": "CUSTOMER", "email": "login_user_29b46b27@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:34.704336+00
bbf15f57-0c34-4283-bf04-db8fe5462f88	373dbb4e-b9d7-4ad0-874c-20cf17ad92e5	USER_REGISTERED	user	373dbb4e-b9d7-4ad0-874c-20cf17ad92e5	{"role": "CUSTOMER", "email": "rotation_1c7d18db@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:34.789575+00
199380c0-550f-4ecb-8bca-6a98dd3bc960	373dbb4e-b9d7-4ad0-874c-20cf17ad92e5	TOKEN_ROTATED	auth	373dbb4e-b9d7-4ad0-874c-20cf17ad92e5	{"family_id": "b6df9c13-608c-484e-9964-e66ee0da5fcf"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:34.87711+00
856f5969-86b4-4234-8881-b9fa4f884f00	373dbb4e-b9d7-4ad0-874c-20cf17ad92e5	TOKEN_REUSE_DETECTED	auth	87d736df-a0ae-4454-a763-79646498960a	{"reason": "Attempted reuse of consumed token", "family_id": "b6df9c13-608c-484e-9964-e66ee0da5fcf"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:34.898805+00
14ea5359-f699-428d-b5f7-6913c3c95361	373dbb4e-b9d7-4ad0-874c-20cf17ad92e5	TOKEN_REUSE_DETECTED	auth	85015884-6b4c-4a41-99b0-b1e689abfd5f	{"reason": "Attempted reuse of consumed token", "family_id": "b6df9c13-608c-484e-9964-e66ee0da5fcf"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:34.917055+00
48731271-6449-48a7-93e6-a12208fe86c3	886216f8-3ff4-4384-aa44-ea5894745b0a	USER_REGISTERED	user	886216f8-3ff4-4384-aa44-ea5894745b0a	{"role": "CUSTOMER", "email": "reset_3961d067@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:34.943842+00
d8750ac6-ad35-42b3-9284-332aeae12ea1	886216f8-3ff4-4384-aa44-ea5894745b0a	PASSWORD_RESET_REQUESTED	auth	886216f8-3ff4-4384-aa44-ea5894745b0a	{"email": "reset_3961d067@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:35.024792+00
c1a2cc89-c7dc-4201-b014-3d4e87f34ad3	886216f8-3ff4-4384-aa44-ea5894745b0a	PASSWORD_RESET_COMPLETED	auth	886216f8-3ff4-4384-aa44-ea5894745b0a	{"email": "reset_3961d067@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:35.076312+00
bb2c29da-279c-4635-9e88-32a14725e3e2	886216f8-3ff4-4384-aa44-ea5894745b0a	AUTH_LOGIN_SUCCESS	auth	886216f8-3ff4-4384-aa44-ea5894745b0a	{"role": "CUSTOMER", "email": "reset_3961d067@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:35.216817+00
7e888862-b507-45d7-b7fe-fa3fa896c471	fa542889-8820-45e9-b9f8-b63d3f0e47b2	USER_REGISTERED	user	fa542889-8820-45e9-b9f8-b63d3f0e47b2	{"role": "CUSTOMER", "email": "multi_reset_09a4652e@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:35.308811+00
17aeb0da-4ebe-4855-a2f4-ccf5959e34a2	fa542889-8820-45e9-b9f8-b63d3f0e47b2	PASSWORD_RESET_REQUESTED	auth	fa542889-8820-45e9-b9f8-b63d3f0e47b2	{"email": "multi_reset_09a4652e@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:35.395646+00
e0c87798-6a5d-4b48-a5ef-0dcee4cc54ad	fa542889-8820-45e9-b9f8-b63d3f0e47b2	PASSWORD_RESET_REQUESTED	auth	fa542889-8820-45e9-b9f8-b63d3f0e47b2	{"email": "multi_reset_09a4652e@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:35.447263+00
fa729872-9097-4264-8044-56622793f53d	4de1e8d0-84d1-4e9b-a25f-08b8351c57b7	USER_REGISTERED	user	4de1e8d0-84d1-4e9b-a25f-08b8351c57b7	{"role": "CUSTOMER", "email": "logout_no_jwt_01c4201f@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:35.526273+00
bad9fda9-de33-4f53-a766-43b59c4d3872	4de1e8d0-84d1-4e9b-a25f-08b8351c57b7	TOKEN_REUSE_DETECTED	auth	39545bfa-ff16-4caf-97f9-6120199b2aa6	{"reason": "Attempted reuse of consumed token", "family_id": "63a7cde1-7e4c-4f7e-822e-ccf9d133ae29"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:35.622597+00
cf6b28b5-5a2d-4052-a07b-54fca1a0d729	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:35.947805+00
3dcc76a4-f90d-4603-acf6-6490732e0a94	09b6e483-f874-4975-9136-3eff437aa445	USER_REGISTERED	user	09b6e483-f874-4975-9136-3eff437aa445	{"role": "CUSTOMER", "email": "catalog_cust_722211@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:36.121895+00
3c05f155-19f7-4fe8-acc2-e45cef823925	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:36.290401+00
423dfbc3-353d-4e6f-a06e-eefeca97f74e	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	2dae25d5-6862-4497-b9cc-45c004092c6e	{"email": "starter_corp_174d54@example.com", "user_id": "24c18ecd-5b5c-4e89-bcfd-91e486f86851", "customer_number": "CUST-2026-0063"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:36.402007+00
04ac200f-1abb-4a5e-ae9c-4c8ee27d1a94	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	f3e4a272-fb34-4599-8ee0-209476dc8f7c	{"plan_id": "0086d29b-ddd9-4dc5-9ac0-3d74ea38cba4", "customer_id": "2dae25d5-6862-4497-b9cc-45c004092c6e", "total_amount": "1178.8200", "subscription_number": "SUB-202610-0035"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:36.510292+00
a6d45656-a873-4a6a-b5c9-4633f092ee0a	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	f3e4a272-fb34-4599-8ee0-209476dc8f7c	{"reason": "Sent commercial proposal", "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:36.637713+00
5d3adc51-10f1-4f5f-8351-aed6b4d5b925	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	f3e4a272-fb34-4599-8ee0-209476dc8f7c	{"reason": "Proposal signed by client", "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:36.709776+00
2eb40869-ad1e-4103-8729-81c95b6c852c	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	CUSTOMER_CREATED	customer	ffc3cf8b-4873-44e7-a75d-7aad1361b179	{"email": "enterprise_705c86@brightloop.io", "user_id": "ec4aa706-03aa-4329-9b47-90b7b9a86ec2", "customer_number": "CUST-2026-0064"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:36.892126+00
e8694d0a-e05d-4f6b-b4fb-02fd32c2d93f	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:37.781143+00
78790dc6-4b22-4076-8543-4bbf240708a6	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	e86d89d3-0129-4b78-af76-2534ca7c0dce	{"email": "audit_corp_7b522b@demo.com", "user_id": "1956e56e-40e0-4306-a5e0-4750074e63fe", "customer_number": "CUST-2026-0065"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:37.942867+00
49e0d0db-da22-44f4-8fbd-77af7773edc0	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	3c81cd1f-5e81-45bc-9416-9e2095c3c324	{"sku": "AUD-SKU-7B522B", "name": "Audit Analytics Suite 7b522b", "currency": "INR", "sales_price": "50000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:38.052173+00
f9782fb4-9333-47c9-8009-882b5aae978e	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	d2654e09-aeee-46a4-94b4-84e10c0b7863	{"code": "PLAN-AUD-7B522B", "name": "Audit Pro Plan 7b522b", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:38.083008+00
d12d7d84-eaff-4d7a-9e80-a4ecb5f53def	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	e6e70895-c378-4ada-9782-9fa69e8e6ca3	{"plan_id": "d2654e09-aeee-46a4-94b4-84e10c0b7863", "quantity": 1, "product_id": "3c81cd1f-5e81-45bc-9416-9e2095c3c324", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:38.11184+00
5731147e-6951-4d2e-86cc-2d35ef03c713	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	d2654e09-aeee-46a4-94b4-84e10c0b7863	{"code": "PLAN-AUD-7B522B", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:38.148933+00
a764c501-666f-4567-9d30-2aaa706df8f2	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	a71d2d50-f658-4fd0-b097-6de1dc57d86f	{"plan_id": "d2654e09-aeee-46a4-94b4-84e10c0b7863", "customer_id": "e86d89d3-0129-4b78-af76-2534ca7c0dce", "total_amount": "59000.0000", "subscription_number": "SUB-202610-0036"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:38.189701+00
b3207786-f3f5-4411-b5b7-8290b0799a4d	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	a71d2d50-f658-4fd0-b097-6de1dc57d86f	{"reason": "Formal quote dispatched", "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:38.254663+00
e26711a8-8322-4a12-b5bd-193e059e090e	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	a71d2d50-f658-4fd0-b097-6de1dc57d86f	{"reason": "Customer approved quote", "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:38.331431+00
649fe581-5263-4dec-b480-c9e153e36f04	5040313c-9900-4630-93f9-1f0e119412dd	INVOICE_GENERATED	invoice	a6fb2feb-91a4-40e8-a929-493ad3c51655	{"total_amount": "59000.0000", "invoice_number": "INV-202610-0021", "subscription_id": "a71d2d50-f658-4fd0-b097-6de1dc57d86f"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:38.406661+00
903893ac-db41-4425-ad29-e44603b86363	5040313c-9900-4630-93f9-1f0e119412dd	PAYMENT_RECORDED	payment	8740cf5c-bed4-4350-a87f-992866650173	{"amount": "20000.0000", "invoice_number": "INV-202610-0021", "payment_number": "PAY-202610-0022", "is_full_payment": false}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:38.53764+00
3e3b5545-353a-4b16-b93d-33b630770e75	5040313c-9900-4630-93f9-1f0e119412dd	PAYMENT_RECORDED	payment	0f698ea0-464b-44a8-9bcd-577875e460a8	{"amount": "39000.0000", "invoice_number": "INV-202610-0021", "payment_number": "PAY-202610-0023", "is_full_payment": true}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:38.997464+00
cb904262-a1df-42d1-86d1-4a7e47c4fc74	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	14eb6c0e-ac1d-40c6-ab2c-15b2b3ecfa75	{"email": "dup_c22620@domain.com", "user_id": "a6d97da7-0272-4a4d-a204-35eb9ad005b9", "customer_number": "CUST-2026-0066"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:39.766737+00
f7179d58-5baf-42a0-b0fd-9a89a1dd3182	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	dc90eb67-7f8c-4214-b972-60afc7208384	{"sku": "QTY-F88C42", "name": "Qty Test Product f88c42", "currency": "INR", "sales_price": "100.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:39.95908+00
b0338581-22c4-4350-b8e9-afed7e19f5e4	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	478b9715-990a-49e0-b86c-363a1cd767be	{"code": "PLAN-QTY-F88C42", "name": "Limited Quantity Plan f88c42", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:39.987262+00
047a5e2a-6994-436d-86bc-295907161d0e	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	a00e60fd-09f8-4c2b-b7ca-2853e05bce99	{"plan_id": "478b9715-990a-49e0-b86c-363a1cd767be", "quantity": 2, "product_id": "dc90eb67-7f8c-4214-b972-60afc7208384", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:40.010946+00
20f8c813-d4f2-42b7-9804-83c311ae9305	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	478b9715-990a-49e0-b86c-363a1cd767be	{"code": "PLAN-QTY-F88C42", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:40.041932+00
0db96bc7-7838-4527-bc12-2e3c74ca2831	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	7f2a34b4-95a7-4c37-9f7b-644959ef215c	{"email": "qty_f88c42@test.com", "user_id": "2a81070c-8c42-427f-a85f-acec791d68c1", "customer_number": "CUST-2026-0067"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:40.078875+00
1d206036-0e44-4e5d-a43a-739a14cd53cc	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	102d2521-6977-4af9-83f3-a4be3470da39	{"code": "DRAFT-5ECABE", "name": "Draft Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:40.433176+00
e7d74a60-cc37-4e7d-8a69-173a86704d95	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	fa679bc8-4c44-4c3b-b5da-36d4b1e7ace2	{"email": "draft_5ecabe@test.com", "user_id": "b6200e86-7dad-4a30-8a00-f4b3254675f0", "customer_number": "CUST-2026-0068"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:40.465799+00
0d9057c6-bf1f-4e5f-bc4e-916134b4f105	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	48e0f739-0593-420f-a170-a77c35a41fae	{"sku": "OVL-425051", "name": "Overlap Prod 425051", "currency": "INR", "sales_price": "1000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:40.696678+00
b5462a3e-3fc5-4b16-818a-686d3c44cfd4	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	7197035c-ac98-4c4f-82fc-cef10aa9083c	{"code": "OVL-PLAN-425051", "name": "Overlap Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:40.739955+00
da4cfc60-769a-4c58-980d-c3e7b773c21b	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	b4141866-2780-4299-a632-f460d6972dd6	{"plan_id": "7197035c-ac98-4c4f-82fc-cef10aa9083c", "quantity": 1, "product_id": "48e0f739-0593-420f-a170-a77c35a41fae", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:40.77473+00
a6e1d853-9537-47c7-8fb8-5bf5c52d5da9	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	7197035c-ac98-4c4f-82fc-cef10aa9083c	{"code": "OVL-PLAN-425051", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:40.809933+00
72388604-97a9-4637-a51f-5ec2099f66e3	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	b9dbbade-cf48-41e7-8d11-ef09de2c12df	{"email": "ovl_425051@test.com", "user_id": "797544bf-e529-45a2-9ecf-d7135e0f3001", "customer_number": "CUST-2026-0069"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:40.856128+00
43c592c5-b46a-4d17-bc9c-2462b17c0bcb	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_REMOVED	PLAN_PRODUCT	8afa5ec7-c20a-4496-a4b0-da5ecea9f932	{"plan_id": "7d563e91-2eda-4022-8903-ef6644649b1b"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:46.181802+00
7d3e1f2c-7319-4afd-9de1-c541b6155823	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	73b766b0-35e5-4fc1-a7d8-d4d3fef4e1fd	{"plan_id": "7197035c-ac98-4c4f-82fc-cef10aa9083c", "customer_id": "b9dbbade-cf48-41e7-8d11-ef09de2c12df", "total_amount": "1180.0000", "subscription_number": "SUB-202610-0037"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:40.958558+00
a5e3f9f8-4a50-4cd2-9a2f-4060a693114e	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	73b766b0-35e5-4fc1-a7d8-d4d3fef4e1fd	{"reason": null, "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:41.024774+00
29314d33-7942-4673-8948-8193b4584641	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	73b766b0-35e5-4fc1-a7d8-d4d3fef4e1fd	{"reason": null, "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:41.093615+00
6b302151-cff7-45b2-a547-b5ddd60cf0cd	5040313c-9900-4630-93f9-1f0e119412dd	INVOICE_GENERATED	invoice	207eeac6-9033-4970-b642-39fda4d6185e	{"total_amount": "1180.0000", "invoice_number": "INV-202610-0022", "subscription_id": "73b766b0-35e5-4fc1-a7d8-d4d3fef4e1fd"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:41.159115+00
4be89d27-63af-4055-9e38-2212ecf431be	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	06a547de-b22a-49b3-9adc-fe3be1734f08	{"sku": "OP-934BD2", "name": "OP Prod 934bd2", "currency": "INR", "sales_price": "1000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:41.504162+00
4af827ea-4f75-47bb-a3fa-6ac11616db27	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	ec1f61ea-d591-435c-aff8-a2111e610265	{"code": "OP-PLAN-934BD2", "name": "Overpay Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:41.530324+00
3a1edeba-1265-4349-9945-91adfe9edc5b	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	9d05bfe4-0729-4b6d-b384-03fafaec8e79	{"plan_id": "ec1f61ea-d591-435c-aff8-a2111e610265", "quantity": 1, "product_id": "06a547de-b22a-49b3-9adc-fe3be1734f08", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:41.555536+00
681369f5-cc4b-4d69-867e-38fb93e8a197	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	ec1f61ea-d591-435c-aff8-a2111e610265	{"code": "OP-PLAN-934BD2", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:41.585899+00
157586b1-070e-4f66-b8a7-fb7359f917f9	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	3a143bfe-fc4e-40dd-9a30-3120cd17fc02	{"email": "op_934bd2@test.com", "user_id": "7586397c-7be1-4012-a3a4-6f30cffef43b", "customer_number": "CUST-2026-0070"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:41.624239+00
869de863-0b65-4117-bf7a-87c2e7fb2cc7	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	8b58c724-98ce-465c-a73a-82d998e94cff	{"plan_id": "ec1f61ea-d591-435c-aff8-a2111e610265", "customer_id": "3a143bfe-fc4e-40dd-9a30-3120cd17fc02", "total_amount": "1180.0000", "subscription_number": "SUB-202610-0038"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:41.719361+00
cdfb6f33-5398-4c4d-8579-9cd6af5a1ae3	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	8b58c724-98ce-465c-a73a-82d998e94cff	{"reason": null, "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:41.782177+00
088420c7-ace5-4538-a635-7099f212f494	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	8b58c724-98ce-465c-a73a-82d998e94cff	{"reason": null, "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:41.852872+00
3f66a5c5-cffe-41dc-a9ee-f1b4154dd3f4	5040313c-9900-4630-93f9-1f0e119412dd	INVOICE_GENERATED	invoice	3e8352ea-a990-49e7-a662-918dfa590cb2	{"total_amount": "1180.0000", "invoice_number": "INV-202610-0023", "subscription_id": "8b58c724-98ce-465c-a73a-82d998e94cff"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:41.91851+00
9903f999-2b48-4307-aeaf-1a67bbe777ae	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	2b653874-2806-4ae9-871c-cdbe5c08d1ff	{"email": "iso1_ae5ec2@demo.com", "user_id": "82fd49ba-17d2-4965-86ca-0153fb0187c2", "customer_number": "CUST-2026-0071"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:42.167737+00
7dfea5db-4c3c-450c-bd45-f4407649805b	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	c8060e07-5377-4101-b2e8-4598d52e71ab	{"email": "iso2_ae5ec2@demo.com", "user_id": "2db433b5-9f80-4d01-931e-b71e9b09a7ce", "customer_number": "CUST-2026-0072"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:42.266133+00
328de494-11ca-4a64-a324-e5d8e1cc7c6d	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	ca41c692-d96d-44a2-b66c-65b15120e34b	{"sku": "NEG9-B487F3", "name": "Neg9 Prod b487f3", "currency": "INR", "sales_price": "500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:42.573515+00
41b9eb9c-909b-47e0-8bbd-7657d82f11ae	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	6e0b404e-10dc-405d-9b5e-22f30b03af37	{"code": "PLAN-NEG9-B487F3", "name": "Neg9 Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:42.603105+00
643cae61-0d14-4017-84b8-4a0b7be311d1	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	4e2843ab-77c2-4e8e-a887-2cad35f202b8	{"plan_id": "6e0b404e-10dc-405d-9b5e-22f30b03af37", "quantity": 1, "product_id": "ca41c692-d96d-44a2-b66c-65b15120e34b", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:42.632199+00
e7e98b2e-a54d-44b2-94f5-716f2fdfdf34	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	6e0b404e-10dc-405d-9b5e-22f30b03af37	{"code": "PLAN-NEG9-B487F3", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:42.664176+00
e9d674d3-0e95-4e4d-8a3f-2ad7dd6e9a7a	5040313c-9900-4630-93f9-1f0e119412dd	CUSTOMER_CREATED	customer	d69a4475-31c3-44f8-b77e-8fce5e1c05df	{"email": "neg9_b487f3@test.com", "user_id": "2104ced0-8801-4857-a65b-b8eadb85f3b7", "customer_number": "CUST-2026-0073"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:42.710446+00
6d01c81b-b41c-468c-a271-6f063b156584	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_CREATED	subscription	2e63834d-8e53-411f-b939-f1d9e971f63e	{"plan_id": "6e0b404e-10dc-405d-9b5e-22f30b03af37", "customer_id": "d69a4475-31c3-44f8-b77e-8fce5e1c05df", "total_amount": "590.0000", "subscription_number": "SUB-202610-0039"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:42.817167+00
6b5789e4-2935-4c87-8a5c-8c79d4f6eea8	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	2e63834d-8e53-411f-b939-f1d9e971f63e	{"reason": null, "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:42.893668+00
ece40024-b64d-4bcf-bb61-a2ba8a428355	5040313c-9900-4630-93f9-1f0e119412dd	SUBSCRIPTION_STATUS_CHANGED	subscription	2e63834d-8e53-411f-b939-f1d9e971f63e	{"reason": null, "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:42.972808+00
5cfcbc66-ca8b-4591-b4aa-933302de54fd	5040313c-9900-4630-93f9-1f0e119412dd	INVOICE_GENERATED	invoice	dfd42561-82ce-4356-944a-1f33180471d6	{"total_amount": "590.0000", "invoice_number": "INV-202610-0024", "subscription_id": "2e63834d-8e53-411f-b939-f1d9e971f63e"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:43.044565+00
79cc04a6-ae10-40f4-a870-37358d738f8c	5040313c-9900-4630-93f9-1f0e119412dd	PAYMENT_RECORDED	payment	d7113a12-61c0-48e3-9b55-150e6bf45414	{"amount": "590.0000", "invoice_number": "INV-202610-0024", "payment_number": "PAY-202610-0024", "is_full_payment": true}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:43.148216+00
325cd940-91ac-4123-9084-3827dabb3642	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	c6410f1a-5961-42a0-b35f-800a55a315be	{"sku": "SEC-FB164", "name": "Cloud Security Suite", "currency": "INR", "sales_price": "2000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:43.731206+00
bc5c37cb-fd3b-4f06-b6a7-481cc6f23ca9	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	c0440129-1c09-4070-a713-c056c1eac0c1	{"code": "PLAN-SEC-1C087", "name": "Security Pro Monthly", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:43.762354+00
11689bf0-25dd-48e7-9409-f1d6522894b8	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	2eb5fd1d-c461-40a6-b8b3-3a06de9cf540	{"plan_id": "c0440129-1c09-4070-a713-c056c1eac0c1", "quantity": 1, "product_id": "c6410f1a-5961-42a0-b35f-800a55a315be", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:43.799598+00
70f9ce9c-7655-438a-bc52-fbf6f2007d36	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	c0440129-1c09-4070-a713-c056c1eac0c1	{"code": "PLAN-SEC-1C087", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:43.835973+00
ec8ff83a-76a5-4e4b-ba02-a48f0ba8d337	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	CUSTOMER_CREATED	customer	a5ecc61e-3478-4aac-9c83-7493ce661f9f	{"email": "billing_d2fae@infosys.com", "user_id": "4c56d2a2-7933-4bf8-b48e-e24352635408", "customer_number": "CUST-2026-0074"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:43.878779+00
4c996836-b507-473d-a4a7-73183be74b36	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_CREATED	subscription	504b31b6-e697-46b6-b0f4-7c48b4117fe0	{"plan_id": "c0440129-1c09-4070-a713-c056c1eac0c1", "customer_id": "a5ecc61e-3478-4aac-9c83-7493ce661f9f", "total_amount": "2360.0000", "subscription_number": "SUB-202610-0040"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:43.983912+00
5c1fcf94-ce3b-4387-bc2e-ea642117d4a9	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_STATUS_CHANGED	subscription	504b31b6-e697-46b6-b0f4-7c48b4117fe0	{"reason": null, "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:44.048587+00
b8cdf4d8-d37d-4675-b87b-544ea28295df	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_STATUS_CHANGED	subscription	504b31b6-e697-46b6-b0f4-7c48b4117fe0	{"reason": null, "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:44.12598+00
a18ed3e8-3766-41a7-8de3-096ce39d0201	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	INVOICE_GENERATED	invoice	64641d8f-1b99-44f9-9459-8c7d1acfba03	{"total_amount": "2360.0000", "invoice_number": "INV-202610-0025", "subscription_id": "504b31b6-e697-46b6-b0f4-7c48b4117fe0"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:44.194805+00
690ef438-d156-4c5d-999c-18d0833594d3	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	PAYMENT_RECORDED	payment	f73325f1-5f2a-4200-8c1e-5740b947efa4	{"amount": "1000.0000", "invoice_number": "INV-202610-0025", "payment_number": "PAY-202610-0025", "is_full_payment": false}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:44.411196+00
a918929b-5b5a-4270-8044-d5f1828dcdd4	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	PAYMENT_RECORDED	payment	89c880fa-f752-4b05-b6d2-38b1993228b2	{"amount": "1360.0000", "invoice_number": "INV-202610-0025", "payment_number": "PAY-202610-0026", "is_full_payment": true}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:44.813299+00
68fdc9a5-0822-439e-84c6-b35dc67fa755	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	8824b9cb-c3a7-4624-b125-4dd55b0bfbeb	{"sku": "INR-3846F7", "name": "INR Service", "currency": "INR", "sales_price": "1000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:45.347391+00
543cb3f1-91c3-47a6-a43f-095a46b76f32	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	35ddd7a9-e386-4b9a-9b32-408791cc0634	{"sku": "USD-8A8A3A", "name": "USD Service", "currency": "USD", "sales_price": "50.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:45.378666+00
b012ce9c-4da9-498b-9aef-ea3504277c22	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	d711461d-c647-4d49-a001-68817661c036	{"code": "PLAN-INR-E42D99", "name": "Enterprise INR Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:45.404521+00
6b0618d1-d466-4fff-bb19-bb25f74c2e68	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	e1340fe0-b2d1-4b18-95c6-c7eb90c08245	{"plan_id": "d711461d-c647-4d49-a001-68817661c036", "quantity": 2, "product_id": "8824b9cb-c3a7-4624-b125-4dd55b0bfbeb", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:45.45713+00
94b8d0ce-d87e-4422-9054-75bf1e0226f2	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	6d698fc6-103c-4088-8a1d-abd2383a2333	{"code": "GUARD-A76D66", "name": "Empty Draft Plan", "currency": "INR", "billing_interval": "YEARLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:45.507457+00
e1bd15c2-987e-462a-8f61-7aaaf98cef47	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	b4b7076e-7cc6-4f6e-a30a-4fbc79828243	{"sku": "BASE-010ACA", "name": "Base Software", "currency": "INR", "sales_price": "3000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:45.550283+00
39c3791a-7d38-4f07-8145-454566c1a60e	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	8d1a6d21-bc1e-44d2-be21-1fd24f6df239	{"plan_id": "6d698fc6-103c-4088-8a1d-abd2383a2333", "quantity": 1, "product_id": "b4b7076e-7cc6-4f6e-a30a-4fbc79828243", "variant_id": null, "price_override": null}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:45.576438+00
104931e9-e8d8-4992-bc85-c8562273ed6d	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	6d698fc6-103c-4088-8a1d-abd2383a2333	{"code": "GUARD-A76D66", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:45.606178+00
469680cf-c0b2-4366-9319-4968f54277dc	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	6d698fc6-103c-4088-8a1d-abd2383a2333	{"code": "GUARD-A76D66", "new_status": "INACTIVE", "old_status": "INACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:45.647128+00
7fcf9ce7-c1ea-4b3d-aee0-c4a09ce65ea4	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	6d698fc6-103c-4088-8a1d-abd2383a2333	{"code": "GUARD-A76D66", "new_status": "ARCHIVED", "old_status": "ARCHIVED"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:45.69582+00
09fecce7-ed99-4579-a9f8-98fff1bab71a	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	16bcdd98-d25d-4035-83fa-90919102c80a	{"sku": "AC-8CABC4", "name": "Auto Close Product", "currency": "INR", "sales_price": "1500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:45.779972+00
c92b3e5f-e1e3-4dec-8e64-968bd2958a8a	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	9fc57589-f51a-44c9-9695-dd62361a2078	{"code": "AUTO-E01B82", "name": "Limited Time Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:45.808632+00
a720714d-8ad7-417e-a56d-8cf0a75b447a	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	9fc57589-f51a-44c9-9695-dd62361a2078	{"code": "AUTO-E01B82", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:45.84787+00
23b47fdd-e576-434f-84cd-43080eeb1834	\N	PLAN_AUTO_CLOSED	SUBSCRIPTION_PLAN	9fc57589-f51a-44c9-9695-dd62361a2078	{"code": "AUTO-E01B82", "reason": "Availability end date '2026-10-31 06:27:45.802134+00:00' reached."}	\N	\N	2026-10-31 08:27:45.84787+00
de2206a7-a10a-4b0a-8db3-89f5783054f4	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	ba0da014-b338-4921-8cf2-e19f2f4fdcae	{"sku": "CRM-992EAD", "name": "CRM Software", "currency": "INR", "sales_price": "2000.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:45.940944+00
60ff5426-fb2d-498b-8010-6f0fd8bb686d	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	7d563e91-2eda-4022-8903-ef6644649b1b	{"code": "CRM-PLAN-DDC9B6", "name": "CRM Standard Plan", "currency": "INR", "billing_interval": "MONTHLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:45.982637+00
c3616c24-b66a-4c09-99f1-07f5fcd6f99c	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	8afa5ec7-c20a-4496-a4b0-da5ecea9f932	{"plan_id": "7d563e91-2eda-4022-8903-ef6644649b1b", "quantity": 3, "product_id": "ba0da014-b338-4921-8cf2-e19f2f4fdcae", "variant_id": "aff6e660-492c-4e6a-930a-cdce8d4bd68f", "price_override": "2200.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:46.009228+00
238d3047-427f-4293-bea0-5a95dd923e2f	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_UPDATED	PLAN_PRODUCT	8afa5ec7-c20a-4496-a4b0-da5ecea9f932	{"plan_id": "7d563e91-2eda-4022-8903-ef6644649b1b", "quantity": 5, "is_active": true}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:46.084165+00
4148cd39-2e6f-401c-84bf-3bbd0cb4eae4	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	93bfd89e-bc60-47c0-b494-e9b010980df0	{"sku": "ERP-86D601", "name": "ERP Financials", "currency": "INR", "sales_price": "2000.0000", "variants_count": 2}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:46.266357+00
acbe3500-d9de-4e3b-a957-a268d03ac3a9	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	ee8602df-7bf2-4bfb-b82d-06e892fec89e	{"sku": "SW-35CB17", "name": "Standard Software", "currency": "INR", "sales_price": "5000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:46.361271+00
c8bb5fa7-e284-4abe-bc10-b61fe04ef588	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	5d6f9fc2-e8ac-490d-9390-ab4bc994f650	{"sku": "INR-B6FB63", "name": "INR Product", "currency": "INR", "sales_price": "100.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:46.434638+00
43260f7e-a5b8-4422-a557-797cd8e7ae6b	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	f3c4dab1-cf3f-43eb-80f2-f7ddedf00f64	{"sku": "SKU-0AC8C5", "name": "Brightloop ERP Cloud", "currency": "INR", "sales_price": "2000.0000", "variants_count": 2}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:46.518896+00
ca196b8d-135e-4a96-9dca-674b3b5be683	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_CREATED	PRODUCT_VARIANT	ac708356-f298-4520-8b1d-0914a7baae33	{"product_id": "f3c4dab1-cf3f-43eb-80f2-f7ddedf00f64", "variant_code": "ENT", "variant_name": "Enterprise Addon", "adjustment_type": "PERCENTAGE", "adjustment_value": "25.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:46.585484+00
81babd21-b450-4b07-aabe-07952fc146d9	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	21f3dee2-08f1-4992-8579-fc021a4bdc17	{"sku": "RBAC-109F23", "name": "Admin Product", "currency": "INR", "sales_price": "500.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:46.706445+00
33ee32ae-2410-4c43-aabc-58b98a5a401a	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	6105c5e6-fce7-4f05-ab91-8fde170061c9	{"sku": "HIST-96CB53", "name": "History Test Product", "currency": "INR", "sales_price": "1000.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:46.787751+00
68acbcf0-4d0b-456d-899b-8bbbff0e7531	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_UPDATED	PRODUCT	6105c5e6-fce7-4f05-ab91-8fde170061c9	{"sku": "HIST-96CB53", "name": "History Test Product", "reason": "Annual inflation rate increase", "price_changes": {"cost_price": {"new": "450.0000", "old": "300.0000"}, "sales_price": {"new": "1500.0000", "old": "1000.0000"}}}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:46.823568+00
bdd4314d-089f-4482-9e05-19bb33997769	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_UPDATED	PRODUCT_VARIANT	3691cf50-db68-4305-96c2-c8bca1333fee	{"variant_code": "PRO", "variant_name": "Pro Pack", "adjustment_type": "PERCENTAGE", "adjustment_value": "30.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:46.870078+00
510c9e72-fb64-4b0c-a5a1-d3487ce3ea23	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	aed404df-5e24-47b3-b798-72d9daea4654	{"sku": "ARCH-C0B99E", "name": "To Archive Product", "currency": "INR", "sales_price": "750.0000", "variants_count": 1}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:46.928905+00
e2436db4-cbcc-46bf-bf28-c0f282c36dd4	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_ARCHIVED	PRODUCT	aed404df-5e24-47b3-b798-72d9daea4654	{"sku": "ARCH-C0B99E", "name": "To Archive Product", "deactivated_plan_line_items": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:46.987902+00
01590a78-c8e5-418b-858e-902f23991d89	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_VARIANT_DEACTIVATED	PRODUCT_VARIANT	390e2722-02a8-4158-b900-e4ea80e32da5	{"variant_code": "VA", "variant_name": "Variant A", "deactivated_plan_line_items": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:47.030924+00
53d41e61-bbbd-42b2-8b13-9f358798a301	5040313c-9900-4630-93f9-1f0e119412dd	PRODUCT_CREATED	PRODUCT	6cb1fe89-fd75-47ca-9b74-b6e591db1a33	{"sku": "PROD-SUB-5EF7F", "name": "Cloud CRM Platform", "currency": "INR", "sales_price": "5000.0000", "variants_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:47.291416+00
58842db2-2802-4011-bdd8-c4d80489fca9	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_CREATED	SUBSCRIPTION_PLAN	b22df9fd-08a0-41ff-a86e-314998debc76	{"code": "PLAN-CRM-BD0DA", "name": "Enterprise CRM Annual", "currency": "INR", "billing_interval": "YEARLY", "bundled_products_count": 0}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:47.320664+00
b828387f-f606-4a81-b181-2f152a06fa5c	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_PRODUCT_ADDED	PLAN_PRODUCT	5cce72bd-8ccf-4a0e-a840-2ff0fef8d689	{"plan_id": "b22df9fd-08a0-41ff-a86e-314998debc76", "quantity": 2, "product_id": "6cb1fe89-fd75-47ca-9b74-b6e591db1a33", "variant_id": null, "price_override": "4500.0000"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:47.346036+00
d73a88de-69f4-4677-8c2d-5e068a8edb09	5040313c-9900-4630-93f9-1f0e119412dd	PLAN_STATUS_CHANGED	SUBSCRIPTION_PLAN	b22df9fd-08a0-41ff-a86e-314998debc76	{"code": "PLAN-CRM-BD0DA", "new_status": "ACTIVE", "old_status": "ACTIVE"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:47.376612+00
de2d7f28-4ac8-44f1-aee0-4548e24c01c0	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	CUSTOMER_CREATED	customer	5c4355f7-6790-490d-949e-0f2519e701f7	{"email": "tata_9e752@tatatech.com", "user_id": "5dab76e6-0337-4d2b-a840-03d3051a6ec6", "customer_number": "CUST-2026-0075"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:47.411212+00
b91002f5-4f2a-4e21-88fc-dfa621720be6	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_CREATED	subscription	1659f7a4-97c9-4786-bba4-3bb3f7631f7f	{"plan_id": "b22df9fd-08a0-41ff-a86e-314998debc76", "customer_id": "5c4355f7-6790-490d-949e-0f2519e701f7", "total_amount": "10030.0000", "subscription_number": "SUB-202610-0041"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:47.504789+00
4ef224f0-d011-4df3-af49-040fe949dc38	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_STATUS_CHANGED	subscription	1659f7a4-97c9-4786-bba4-3bb3f7631f7f	{"reason": "Sent quote to client", "to_status": "QUOTATION", "from_status": "DRAFT"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:47.574828+00
7af0b7e3-77cc-49e2-925a-e683ef029af5	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	SUBSCRIPTION_STATUS_CHANGED	subscription	1659f7a4-97c9-4786-bba4-3bb3f7631f7f	{"reason": "Client signed contract", "to_status": "CONFIRMED", "from_status": "QUOTATION"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:47.635289+00
abe153f7-76ce-437b-91be-53a86fb95c88	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:47.772876+00
93c901b1-f547-46ec-b378-53f97a23f790	6c688382-392d-4b6b-8018-b43ca02eaa3a	USER_REGISTERED	user	6c688382-392d-4b6b-8018-b43ca02eaa3a	{"role": "CUSTOMER", "email": "cust1_061718e9@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:47.847161+00
6124fee4-9cb0-4e1d-a8d5-2c41c557618f	bb2f3e5a-a4d7-4521-a39d-12a1ff065bff	USER_REGISTERED	user	bb2f3e5a-a4d7-4521-a39d-12a1ff065bff	{"role": "CUSTOMER", "email": "cust2_615014e7@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:47.929423+00
73e858d7-47db-4574-9b73-c8412feb1e8e	5040313c-9900-4630-93f9-1f0e119412dd	STAFF_CREATED	user	84d45c7b-6d0a-455c-a618-9af4d5a317a9	{"role": "STAFF", "created_email": "staff_46b735ab@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:48.081468+00
ff9ad6a1-1f36-4a32-aa74-8538137062d1	84d45c7b-6d0a-455c-a618-9af4d5a317a9	AUTH_LOGIN_SUCCESS	auth	84d45c7b-6d0a-455c-a618-9af4d5a317a9	{"role": "STAFF", "email": "staff_46b735ab@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:48.15339+00
437f2e0b-ff81-4a52-9341-a5992ca1c84e	5040313c-9900-4630-93f9-1f0e119412dd	USER_STATUS_UPDATED	user	6c688382-392d-4b6b-8018-b43ca02eaa3a	{"is_active": false, "target_email": "cust1_061718e9@example.com"}	127.0.0.1	python-httpx/0.28.1	2026-10-31 08:27:48.333607+00
5b39c6a0-d3d8-4f21-962c-f5b9a9cf5827	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 08:29:23.453559+00
10282cd8-bc09-43e1-b703-5f115889837e	f8a76800-1d18-4ecc-8527-7b4f59687fa3	TOKEN_ROTATED	auth	f8a76800-1d18-4ecc-8527-7b4f59687fa3	{"family_id": "bc4726b8-0354-460a-b1b7-d669788436c9"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 08:34:33.802225+00
47a6359d-5794-4b9b-94b8-11d78812a265	f8a76800-1d18-4ecc-8527-7b4f59687fa3	TOKEN_REUSE_DETECTED	auth	af36b640-150c-4f7a-9853-111633917f48	{"reason": "Attempted reuse of consumed token", "family_id": "bc4726b8-0354-460a-b1b7-d669788436c9"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 08:34:33.802762+00
80b57188-abac-4f21-8878-2526fc1dbe88	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGIN_SUCCESS	auth	5040313c-9900-4630-93f9-1f0e119412dd	{"role": "ADMIN", "email": "admin@brightloop.com"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 08:34:53.408692+00
a92ba1c6-6d44-4e8e-bc25-0189220a0806	5040313c-9900-4630-93f9-1f0e119412dd	AUTH_LOGOUT	auth	5040313c-9900-4630-93f9-1f0e119412dd	{}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 08:37:07.662995+00
7d67f36f-f787-4d3d-afa4-95909199d332	f8a76800-1d18-4ecc-8527-7b4f59687fa3	AUTH_LOGIN_SUCCESS	auth	f8a76800-1d18-4ecc-8527-7b4f59687fa3	{"role": "CUSTOMER", "email": "bala@gmail.com"}	127.0.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	2026-10-31 08:37:28.073857+00
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: brightloop_user
--

COPY public.customers (id, user_id, customer_number, name, email, phone, company_name, billing_address_line1, billing_address_line2, billing_city, billing_state, billing_postal_code, billing_country, status, created_by_id, updated_by_id, created_at, updated_at) FROM stdin;
9d3c3d84-ca09-4f7b-8010-cbcd9e9a2e8d	86e39d83-656a-4a5f-b96d-9ee66a6620ca	CUST-2026-0001	Cust1 Organization	customer_8a0265cf@example.com	\N	Org 1	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:57:56.330857+00	2026-10-31 06:57:56.330857+00
77028f6c-fe83-4e5c-9632-4700dea97986	628ea848-2123-49bf-a1bd-07be4afca2c7	CUST-2026-0002	Acme Global Corp	enterprise_dd7722@brightloop.io	+91 9876543210	Acme Global Technologies Pvt Ltd	100 MG Road	\N	Bengaluru	Karnataka	560001	India	ACTIVE	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:01:38.272438+00	2026-10-31 07:01:38.272438+00
d8aba305-385d-4f8c-abcd-ee4db0e52f4d	a5b1716b-c164-4def-bae1-66f1e258b42c	CUST-2026-0003	Infosys Corp	billing_8527b@infosys.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:01:39.0156+00	2026-10-31 07:01:39.0156+00
4220650e-a590-4d9f-bbc1-f91752567133	e56fe90d-6089-4c10-9c2c-9c47b80033a0	CUST-2026-0004	Tata Tech	tata_6e42a@tatatech.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:01:42.510931+00	2026-10-31 07:01:42.510931+00
d11ed7a0-16d7-495f-a4d7-591d0b4fbfe4	3fac70e5-8751-4981-a145-bb97fbce8d27	CUST-2026-0005	Acme Global Corp	enterprise_6c39f9@brightloop.io	+91 9876543210	Acme Global Technologies Pvt Ltd	100 MG Road	\N	Bengaluru	Karnataka	560001	India	ACTIVE	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:24:18.140946+00	2026-10-31 07:24:18.140946+00
20de22c3-c73e-40d3-bc37-9cf9b129a783	2de8920e-abf2-44f4-9d69-d48779260b63	CUST-2026-0006	Infosys Corp	billing_c26fb@infosys.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:24:19.297932+00	2026-10-31 07:24:19.297932+00
bae036c5-9766-4885-9b31-95a70c4cea4f	0f393bda-925a-4ca8-8a28-7db07ce74607	CUST-2026-0007	Tata Tech	tata_7b7c7@tatatech.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:24:22.757832+00	2026-10-31 07:24:22.757832+00
0bbc71dc-0eda-419a-88a5-03fb4ff39b6b	42ac6db9-70d7-4973-8852-c8c16d975be9	CUST-2026-0008	Tata Consultancy Services Ltd	billing@tcs-enterprise.com	+91 98765 43210	Tata Consultancy Services Ltd	TCS Olympus, Hiranandani Estate, Ghodbunder Rd	Building 5, Executive Wing	Thane	Maharashtra	400607	IN	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
c35f47e5-0366-411b-81af-49b909c51fbc	0edd6c45-63f8-4d39-aade-7746228f0b98	CUST-2026-0009	Zomato Media Private Ltd	finance@zomato-corp.com	+91 91234 56789	Zomato Media Private Ltd	Ground Floor, 12A, 94 Meghdoot Building	Nehru Place Corporate District	New Delhi	Delhi	110019	IN	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
5aa41d88-f9e6-405b-981a-c96dd1144e29	ab39119d-27a4-4eae-b2ea-b2413a1540ad	CUST-2026-0010	Swiggy Bundl Technologies	accounts@swiggy.in	+91 99887 76655	Bundl Technologies Pvt Ltd	Devarabisanahalli, Outer Ring Road	Tower A, 4th Floor	Bengaluru	Karnataka	560103	IN	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
8b412e2c-8436-413f-924b-fa819d601cf2	319ca723-eafd-4883-b097-6b20dd0faabb	CUST-2026-0011	Audit Enterprise dbbe98	audit_corp_dbbe98@demo.com	+91 98765 00000	Audit Global Corp	Level 10, Brigade Gateway	\N	Bengaluru	Karnataka	560055	IN	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:35:20.464995+00	2026-10-31 07:35:20.464995+00
0cde400f-7b0c-46e6-85d7-fd508589878e	b0289709-fdb9-4186-8170-97d5fe8ca536	CUST-2026-0012	Company Alpha	dup_ccb42b@domain.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:35:20.912989+00	2026-10-31 07:35:20.912989+00
f78bfeac-5bcf-4aae-b274-2b9f1f65bf62	62ba0cee-0bbc-4fa2-a484-0d17e7e96c78	CUST-2026-0013	Qty Customer fea26e	qty_fea26e@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:35:21.235137+00	2026-10-31 07:35:21.235137+00
cca5c902-64d6-4e7e-a51b-f8ddc0208c33	e9e2cf4f-ce8b-4220-bdec-6d394ba91885	CUST-2026-0014	Draft Tester	draft_5e366f@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:35:21.512494+00	2026-10-31 07:35:21.512494+00
c10a4652-77d5-42e5-a1d4-9eb8ed365153	6f71e03b-972e-4a07-a28f-831713f9da1c	CUST-2026-0015	Overlap Cust	ovl_20b80a@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:35:21.851666+00	2026-10-31 07:35:21.851666+00
1214e873-31fb-4ac4-89d7-eaabfff658bd	e82dfe6d-4528-4957-b697-af13e73699a8	CUST-2026-0016	Overpay Cust	op_b78a98@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:35:22.372764+00	2026-10-31 07:35:22.372764+00
42fdbc73-7c79-4ce4-a25f-85420d3bf4fe	1db238e8-d823-4e53-a192-4cbe1979c01a	CUST-2026-0017	Neg9 Cust	neg9_2a13bb@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:35:22.969455+00	2026-10-31 07:35:22.969455+00
d1ad1940-cda3-43d9-8725-9af55aabf801	6c761294-0188-4925-9242-3fddfec0c211	CUST-2026-0018	Audit Enterprise 3a32a8	audit_corp_3a32a8@demo.com	+91 98765 00000	Audit Global Corp	Level 10, Brigade Gateway	\N	Bengaluru	Karnataka	560055	IN	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:29.206418+00	2026-10-31 07:37:29.206418+00
9b65bcea-400c-4ebe-b3a4-94e4c3978d54	fda5f60c-b55c-4681-8eee-8754701bb862	CUST-2026-0019	Company Alpha	dup_b8f8b4@domain.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:31.169295+00	2026-10-31 07:37:31.169295+00
5776e2ea-fce0-44d0-abcc-6a821efc973d	0bc3d615-5e7e-42bb-8e77-55fe6d255d6f	CUST-2026-0020	Qty Customer ef54ca	qty_ef54ca@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:31.499712+00	2026-10-31 07:37:31.499712+00
b8d55661-d47f-4ea9-a7b1-8fe6936be42a	e92e067c-86a6-41c9-95f9-04601ecea5ac	CUST-2026-0021	Draft Tester	draft_de3b95@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:31.777375+00	2026-10-31 07:37:31.777375+00
33ac25c4-2e2a-40b1-ab02-908cc110c426	31ead84d-8593-44a7-82be-62269162708b	CUST-2026-0022	Overlap Cust	ovl_0531ca@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:32.08704+00	2026-10-31 07:37:32.08704+00
f77c7295-47d5-4694-adea-980a61c56830	010ca79b-8c8d-4721-a74f-ce2fdc90ed73	CUST-2026-0023	Overpay Cust	op_ffee42@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:32.654626+00	2026-10-31 07:37:32.654626+00
f7a28ffc-22f2-49cd-8d64-cbd034fc3c2c	fbc9f9fb-074d-4943-a212-dde7cf5eaf6e	CUST-2026-0024	Customer One Profile	iso1_4899a8@demo.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:32.993211+00	2026-10-31 07:37:32.993211+00
a0bc69d1-c9fd-4817-80a3-9debd95762e9	2fbae6f5-da89-4056-a5d9-51a70577af1e	CUST-2026-0025	Customer Two Profile	iso2_4899a8@demo.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:33.083142+00	2026-10-31 07:37:33.083142+00
11c4eb39-bdc0-4da1-bb1d-9b33bed52f9a	617b7b2d-6424-4b9d-9a95-0b2c97d88eae	CUST-2026-0026	Neg9 Cust	neg9_18b7b5@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:33.540809+00	2026-10-31 07:37:33.540809+00
ad1f6972-67c1-4b0b-a015-ba3aea186bc9	e4783364-7813-465d-ae8d-04a025ea069e	CUST-2026-0027	Audit Enterprise 2c1132	audit_corp_2c1132@demo.com	+91 98765 00000	Audit Global Corp	Level 10, Brigade Gateway	\N	Bengaluru	Karnataka	560055	IN	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:18.277993+00	2026-10-31 07:38:18.277993+00
a04eb519-94ca-4932-9f59-7c6c430a2ccd	54e697f5-ec86-49d0-a228-a4ce85abf64b	CUST-2026-0028	Company Alpha	dup_091447@domain.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:20.334866+00	2026-10-31 07:38:20.334866+00
178346a1-f0d1-48da-89f0-69b57a540b49	83ff8008-a19a-4079-a653-cd9066754e47	CUST-2026-0029	Qty Customer 2446fd	qty_2446fd@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:20.674165+00	2026-10-31 07:38:20.674165+00
df79c8e4-2ba0-4c30-96bc-c9c8db6ee7dc	c6865499-f520-4b3a-bd59-d7ac73da12ae	CUST-2026-0030	Draft Tester	draft_5e80ac@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:20.947056+00	2026-10-31 07:38:20.947056+00
1391c136-849b-4cbc-8cdb-7c35f86cd85e	d9a03e5a-b69a-466c-a629-bd1ae2fc92ee	CUST-2026-0031	Overlap Cust	ovl_fb54d3@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:21.289533+00	2026-10-31 07:38:21.289533+00
e5f99822-843b-4c7c-bd7b-3afa17d5e1c9	84993fe6-4f73-4a8b-955a-f15c1376d1ca	CUST-2026-0032	Overpay Cust	op_de242a@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:22.092443+00	2026-10-31 07:38:22.092443+00
5177e078-61aa-4ac3-8f84-98df259d9d46	65b91682-558b-4f4c-951d-539434c14ef3	CUST-2026-0033	Customer One Profile	iso1_cf17b0@demo.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:22.658939+00	2026-10-31 07:38:22.658939+00
8da91ecb-8d8f-4399-a8d5-61db8250c6cb	af4e9265-bea5-47d4-9c2e-a362271ee196	CUST-2026-0034	Customer Two Profile	iso2_cf17b0@demo.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:22.753581+00	2026-10-31 07:38:22.753581+00
eb64f133-dafc-418f-8f4a-90e9dbc9cdcb	c22eb824-9d62-4962-8be8-1833cdd8ebdc	CUST-2026-0035	Neg9 Cust	neg9_ba08be@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:23.1962+00	2026-10-31 07:38:23.1962+00
57adf978-6279-45ec-9fd8-80bdc24a4052	fb9db2a2-56bc-409c-aeaf-a5401434e4e0	CUST-2026-0036	Acme Global Corp	enterprise_dd0d05@brightloop.io	+91 9876543210	Acme Global Technologies Pvt Ltd	100 MG Road	\N	Bengaluru	Karnataka	560001	India	ACTIVE	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:38:31.508129+00	2026-10-31 07:38:31.508129+00
b9ba2119-ac8a-4bf5-85ff-889e7efba0d6	4fab871e-76a3-44d9-b79f-cfa00204da30	CUST-2026-0037	Audit Enterprise 4492ce	audit_corp_4492ce@demo.com	+91 98765 00000	Audit Global Corp	Level 10, Brigade Gateway	\N	Bengaluru	Karnataka	560055	IN	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:32.596675+00	2026-10-31 07:38:32.596675+00
22663fed-2aed-45ed-b61b-d8114b0fe954	88f37654-643e-4bd2-9dee-3ca6a2161e0a	CUST-2026-0038	Company Alpha	dup_8d6cbc@domain.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:34.407562+00	2026-10-31 07:38:34.407562+00
78039001-abed-4aa5-9f3b-66cd3818e34d	91efbe36-b71d-42fd-b7c3-e0b6d794f087	CUST-2026-0039	Qty Customer 62aa14	qty_62aa14@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:34.721226+00	2026-10-31 07:38:34.721226+00
9af7b73b-6803-4f43-8a20-da983c986f12	c389cf50-e0a6-4e9d-902d-dbde029ae58a	CUST-2026-0040	Draft Tester	draft_185244@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:34.986736+00	2026-10-31 07:38:34.986736+00
a7b2a3b6-0da7-4090-91a0-c7dcf15afcce	90a4e297-4cad-4ec5-b65f-a0653eff9316	CUST-2026-0041	Overlap Cust	ovl_a17ec1@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:35.316262+00	2026-10-31 07:38:35.316262+00
0704c6a3-68be-4b4c-adca-8184b6bdbc45	889eda05-ce54-41a7-b84f-f6a34f2875e6	CUST-2026-0042	Overpay Cust	op_625c40@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:36.108204+00	2026-10-31 07:38:36.108204+00
179bb96c-2092-44ba-a19d-6237f83958f8	e33b5e88-21a9-45d1-b952-d136248b7c66	CUST-2026-0043	Customer One Profile	iso1_a2be66@demo.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:36.728894+00	2026-10-31 07:38:36.728894+00
e53b2007-eddf-4d04-baa3-ced00620b74f	6f4196d9-dfc0-4b52-a861-f008e3abf5d1	CUST-2026-0044	Customer Two Profile	iso2_a2be66@demo.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:36.8174+00	2026-10-31 07:38:36.8174+00
cb06e29c-acf5-4d8e-9b97-91a250b6b4d8	9d8e82ae-c214-4448-905b-a63fdf530a27	CUST-2026-0045	Neg9 Cust	neg9_2bacb8@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:37.240809+00	2026-10-31 07:38:37.240809+00
4f3ec259-43da-4e7a-8316-22a71e23d0db	aff0484e-01ce-4d30-b1e8-4912a70980ff	CUST-2026-0046	Infosys Corp	billing_db7e4@infosys.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:38:38.300921+00	2026-10-31 07:38:38.300921+00
736170c1-8d28-4697-8a53-2078ecea8b13	1a8e2f4a-a11b-4bed-a4ea-d7273cf7836e	CUST-2026-0047	Tata Tech	tata_63c79@tatatech.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:38:41.796065+00	2026-10-31 07:38:41.796065+00
8a9d9a1d-6169-461f-8fad-82cfda34d74b	755ecc05-8b2e-4094-b235-d22c1ae31dde	CUST-2026-0048	Starter Corp India	starter_corp_aff995@example.com	+91 9888877777	Starter Corp Pvt Ltd	Level 4, Cyber Gateway	\N	Hyderabad	Telangana	500081	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:23:57.688377+00	2026-10-31 08:23:57.688377+00
01b93597-5723-44ad-9492-ef3607218c92	589b2d88-254a-488c-8a51-2a4d18b192c2	CUST-2026-0049	Starter Corp India	starter_corp_4ead21@example.com	+91 9888877777	Starter Corp Pvt Ltd	Level 4, Cyber Gateway	\N	Hyderabad	Telangana	500081	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:09.098736+00	2026-10-31 08:24:09.098736+00
8f7b1967-edec-430c-a7a9-a4043dcb3de4	5298e1ce-ccb5-43ae-8827-e4f1b219d6f6	CUST-2026-0050	Acme Global Corp	enterprise_2f6bd5@brightloop.io	+91 9876543210	Acme Global Technologies Pvt Ltd	100 MG Road	\N	Bengaluru	Karnataka	560001	India	ACTIVE	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:24:09.709897+00	2026-10-31 08:24:09.709897+00
bca5e35f-ed0e-4e3c-a57f-eb24c360a6fb	f74ba7a3-179b-484c-ac47-f96d0e199cdb	CUST-2026-0051	Audit Enterprise 8ebd0b	audit_corp_8ebd0b@demo.com	+91 98765 00000	Audit Global Corp	Level 10, Brigade Gateway	\N	Bengaluru	Karnataka	560055	IN	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:11.075402+00	2026-10-31 08:24:11.075402+00
e6bd4afa-c438-44e4-888d-b341f4e4c4db	4f043cb7-ad10-4a07-8093-4a7e81edcc1c	CUST-2026-0052	Company Alpha	dup_5552ec@domain.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:13.328596+00	2026-10-31 08:24:13.328596+00
960071b7-9b0e-4ccc-88a7-c796d91fc1b4	d478a015-b108-49b2-86ea-6f6f31ec31c6	CUST-2026-0053	Qty Customer 16e322	qty_16e322@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:13.677608+00	2026-10-31 08:24:13.677608+00
5dcccc33-0f78-45de-9732-d802e749060b	bff68c14-6701-4be2-8a60-ba9d40b78c05	CUST-2026-0054	Draft Tester	draft_4e9051@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:13.985849+00	2026-10-31 08:24:13.985849+00
0e75110e-28f7-451f-a480-86c34b25a040	78d99fdc-1cd2-4bc3-be11-c53f8128703d	CUST-2026-0055	Overlap Cust	ovl_b22d76@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:14.381543+00	2026-10-31 08:24:14.381543+00
40937aa1-dcea-4eee-b28b-597f431549e5	261631bd-d1cf-446a-9f07-5b60a4dc8aaa	CUST-2026-0056	Overpay Cust	op_dbfa6b@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:15.282126+00	2026-10-31 08:24:15.282126+00
91d9d1c1-f92f-45ad-9077-5a379b947378	98cd3f6e-4144-4803-8bed-4f58edc93bfc	CUST-2026-0057	Customer One Profile	iso1_f46fbb@demo.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:16.16648+00	2026-10-31 08:24:16.16648+00
6f8dadf5-e36a-4840-9dd9-18c6678b3565	e5f4628a-254f-4743-900d-c4c5848dc4c5	CUST-2026-0058	Customer Two Profile	iso2_f46fbb@demo.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:16.282343+00	2026-10-31 08:24:16.282343+00
ef262998-7f20-45f5-bed3-ac7a7de9c250	9c032f6d-4d9c-49c6-be87-6f45c6528780	CUST-2026-0059	Neg9 Cust	neg9_7559a3@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:16.755764+00	2026-10-31 08:24:16.755764+00
f4256ea5-779c-448a-b1fb-6a98398d127c	580e2b4f-9f9e-4b88-9f6d-bd0e4e68b826	CUST-2026-0060	Infosys Corp	billing_9a5fc@infosys.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:24:17.878602+00	2026-10-31 08:24:17.878602+00
dfba3c49-ad17-4293-b71b-dbbdc4b2f9e5	9535692d-19c4-45bb-ab16-3053ea78719a	CUST-2026-0061	Tata Tech	tata_f6526@tatatech.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:24:21.397201+00	2026-10-31 08:24:21.397201+00
471abd59-8328-4d62-86a5-c44e823b038f	d5006a51-cf62-44de-84be-7524ddd06dca	CUST-2026-0062	Starter Corp India	starter_corp_9ae423@example.com	+91 9888877777	Starter Corp Pvt Ltd	Level 4, Cyber Gateway	\N	Hyderabad	Telangana	500081	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:24.62056+00	2026-10-31 08:27:24.62056+00
2dae25d5-6862-4497-b9cc-45c004092c6e	24c18ecd-5b5c-4e89-bcfd-91e486f86851	CUST-2026-0063	Starter Corp India	starter_corp_174d54@example.com	+91 9888877777	Starter Corp Pvt Ltd	Level 4, Cyber Gateway	\N	Hyderabad	Telangana	500081	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:36.402007+00	2026-10-31 08:27:36.402007+00
ffc3cf8b-4873-44e7-a75d-7aad1361b179	ec4aa706-03aa-4329-9b47-90b7b9a86ec2	CUST-2026-0064	Acme Global Corp	enterprise_705c86@brightloop.io	+91 9876543210	Acme Global Technologies Pvt Ltd	100 MG Road	\N	Bengaluru	Karnataka	560001	India	ACTIVE	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:27:36.892126+00	2026-10-31 08:27:36.892126+00
e86d89d3-0129-4b78-af76-2534ca7c0dce	1956e56e-40e0-4306-a5e0-4750074e63fe	CUST-2026-0065	Audit Enterprise 7b522b	audit_corp_7b522b@demo.com	+91 98765 00000	Audit Global Corp	Level 10, Brigade Gateway	\N	Bengaluru	Karnataka	560055	IN	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:37.942867+00	2026-10-31 08:27:37.942867+00
14eb6c0e-ac1d-40c6-ab2c-15b2b3ecfa75	a6d97da7-0272-4a4d-a204-35eb9ad005b9	CUST-2026-0066	Company Alpha	dup_c22620@domain.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:39.766737+00	2026-10-31 08:27:39.766737+00
7f2a34b4-95a7-4c37-9f7b-644959ef215c	2a81070c-8c42-427f-a85f-acec791d68c1	CUST-2026-0067	Qty Customer f88c42	qty_f88c42@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:40.078875+00	2026-10-31 08:27:40.078875+00
fa679bc8-4c44-4c3b-b5da-36d4b1e7ace2	b6200e86-7dad-4a30-8a00-f4b3254675f0	CUST-2026-0068	Draft Tester	draft_5ecabe@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:40.465799+00	2026-10-31 08:27:40.465799+00
b9dbbade-cf48-41e7-8d11-ef09de2c12df	797544bf-e529-45a2-9ecf-d7135e0f3001	CUST-2026-0069	Overlap Cust	ovl_425051@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:40.856128+00	2026-10-31 08:27:40.856128+00
3a143bfe-fc4e-40dd-9a30-3120cd17fc02	7586397c-7be1-4012-a3a4-6f30cffef43b	CUST-2026-0070	Overpay Cust	op_934bd2@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:41.624239+00	2026-10-31 08:27:41.624239+00
2b653874-2806-4ae9-871c-cdbe5c08d1ff	82fd49ba-17d2-4965-86ca-0153fb0187c2	CUST-2026-0071	Customer One Profile	iso1_ae5ec2@demo.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:42.167737+00	2026-10-31 08:27:42.167737+00
c8060e07-5377-4101-b2e8-4598d52e71ab	2db433b5-9f80-4d01-931e-b71e9b09a7ce	CUST-2026-0072	Customer Two Profile	iso2_ae5ec2@demo.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:42.266133+00	2026-10-31 08:27:42.266133+00
d69a4475-31c3-44f8-b77e-8fce5e1c05df	2104ced0-8801-4857-a65b-b8eadb85f3b7	CUST-2026-0073	Neg9 Cust	neg9_b487f3@test.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:42.710446+00	2026-10-31 08:27:42.710446+00
a5ecc61e-3478-4aac-9c83-7493ce661f9f	4c56d2a2-7933-4bf8-b48e-e24352635408	CUST-2026-0074	Infosys Corp	billing_d2fae@infosys.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:27:43.878779+00	2026-10-31 08:27:43.878779+00
5c4355f7-6790-490d-949e-0f2519e701f7	5dab76e6-0337-4d2b-a840-03d3051a6ec6	CUST-2026-0075	Tata Tech	tata_9e752@tatatech.com	\N	\N	\N	\N	\N	\N	\N	India	ACTIVE	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:27:47.411212+00	2026-10-31 08:27:47.411212+00
\.


--
-- Data for Name: invoice_items; Type: TABLE DATA; Schema: public; Owner: brightloop_user
--

COPY public.invoice_items (id, invoice_id, product_id, variant_id, description, quantity, unit_price, subtotal, created_at, updated_at) FROM stdin;
0f9ede5f-51c2-4a3a-9136-950282122b91	c8a257fd-b794-4423-84f9-59a2ff027466	cd07bdd3-8925-4e1c-8754-a33b7b02246c	\N	Cloud Security Suite	1	2000.0000	2000.0000	2026-10-31 07:01:39.309746+00	2026-10-31 07:01:39.309746+00
197d3b65-dd42-4f3c-ba8f-8463d11e1462	6ca8252d-9d7c-4a93-b23b-b81acade770e	edbb467f-ee59-4f31-94aa-588b436d4eaa	\N	Cloud Security Suite	1	2000.0000	2000.0000	2026-10-31 07:24:19.620146+00	2026-10-31 07:24:19.620146+00
902d2076-bc3b-490d-b5b5-42984aa2da64	c22ea219-4c7d-4125-a575-f217346e48ec	186b4bbe-6fca-4f10-8817-a4b71efd0762	\N	Brightloop Enterprise Core Platform	1	60000.0000	60000.0000	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
bb6c5e98-4fba-4f06-a2cc-4e1ce5aeb5da	c22ea219-4c7d-4125-a575-f217346e48ec	48db2113-98c2-44bb-8fb5-491a6e75ddfd	\N	Advanced Billing Intelligence & Churn Predictor	1	35000.0000	35000.0000	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
97373dc9-a665-4197-b28c-6b11c05f8895	c22ea219-4c7d-4125-a575-f217346e48ec	ebc4abad-f5e7-4644-9567-8d7fdad06fd4	\N	24/7 Dedicated Enterprise Support & Solutions Architect	1	25000.0000	25000.0000	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
7041b3dc-8f62-422b-ae04-6308ffbd4f62	1346cc70-fc94-44e1-a3b2-624c05cff912	186b4bbe-6fca-4f10-8817-a4b71efd0762	\N	Brightloop Enterprise Core Platform	1	15000.0000	15000.0000	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
f0ddc21a-88a1-48ea-bb6c-d20730a66e3c	24391ca7-3405-4e6d-899b-629ef9e1fbfb	186b4bbe-6fca-4f10-8817-a4b71efd0762	\N	Brightloop Enterprise Core Platform	1	60000.0000	60000.0000	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
5e922148-28b9-453a-bfcf-7103e2c4ce53	24391ca7-3405-4e6d-899b-629ef9e1fbfb	48db2113-98c2-44bb-8fb5-491a6e75ddfd	\N	Advanced Billing Intelligence & Churn Predictor	1	35000.0000	35000.0000	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
39561d3f-980b-40dd-8250-e4c2c351154c	24391ca7-3405-4e6d-899b-629ef9e1fbfb	ebc4abad-f5e7-4644-9567-8d7fdad06fd4	\N	24/7 Dedicated Enterprise Support & Solutions Architect	1	25000.0000	25000.0000	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
365e3a91-a42f-4211-b1b7-4b41bcb06940	27881d41-b173-47f6-8e0c-3ec728bdec01	39e2f841-cf98-4c62-809a-d941b1637c23	\N	Audit Analytics Suite 3a32a8	1	50000.0000	50000.0000	2026-10-31 07:37:29.723883+00	2026-10-31 07:37:29.723883+00
85ca5963-3cca-4519-b67b-877fc6d84620	f045f94c-d267-4dfe-a757-a867da47d824	53b00a01-c903-4f64-9e72-5088c4c0e028	\N	Audit Analytics Suite 2c1132	1	50000.0000	50000.0000	2026-10-31 07:38:18.777905+00	2026-10-31 07:38:18.777905+00
68415e87-3246-4dde-a689-a351bf959fa7	7e8dfe6e-8aa2-4ad6-b61d-2d765bc9dd5d	ed0db0d3-c8a8-4bc2-ac69-92b127dcbd38	\N	Overlap Prod fb54d3	1	1000.0000	1000.0000	2026-10-31 07:38:21.621141+00	2026-10-31 07:38:21.621141+00
e0134c94-ef86-4dc8-bd82-55be2c005253	a9c2def3-0595-4a6f-98b3-418033c61e4d	db17cf02-d6b1-4db4-a8e9-5bf25f5a34f1	\N	OP Prod de242a	1	1000.0000	1000.0000	2026-10-31 07:38:22.400217+00	2026-10-31 07:38:22.400217+00
8c8d62f0-637b-4276-a04d-52727d05467f	0aab8183-061d-420f-94f8-28ccb3787387	650bdf95-c3b6-4a92-955b-9551fb73a316	\N	Neg9 Prod ba08be	1	500.0000	500.0000	2026-10-31 07:38:23.499339+00	2026-10-31 07:38:23.499339+00
af392b58-2160-4763-a2f5-7a93393c45fd	153907e7-11b5-4b59-bff6-74e65a43799a	7fc3f342-51f1-4164-8bae-dfa344fbf476	\N	Audit Analytics Suite 4492ce	1	50000.0000	50000.0000	2026-10-31 07:38:33.063629+00	2026-10-31 07:38:33.063629+00
a6deaf38-2b29-4671-a7f4-b32e75725401	af36956d-d174-4992-8e6c-f6e22f04cc4d	8e677bd2-2a28-432f-95eb-337f2b48f1e5	\N	Overlap Prod a17ec1	1	1000.0000	1000.0000	2026-10-31 07:38:35.624136+00	2026-10-31 07:38:35.624136+00
42aec33e-bf11-41eb-b1c9-32d9e00e98d3	1683324b-0c67-4574-9665-a0acb335760e	c490928c-9a8c-4437-9601-1abebc4075b7	\N	OP Prod 625c40	1	1000.0000	1000.0000	2026-10-31 07:38:36.402136+00	2026-10-31 07:38:36.402136+00
8d90f330-6864-4112-9d6e-1d33188e5d09	5324b6db-b19a-45b5-a2d0-9747f4fa1597	5bea6103-3d8f-49c0-b077-370f3e20b856	\N	Neg9 Prod 2bacb8	1	500.0000	500.0000	2026-10-31 07:38:37.557389+00	2026-10-31 07:38:37.557389+00
e363a4b6-b90c-4abd-87e8-f5970c65b302	9796d144-f65d-43e5-91cb-f5f5420c1cef	e7f7f3ac-3fa7-4818-b3da-4d643758ecfc	\N	Cloud Security Suite	1	2000.0000	2000.0000	2026-10-31 07:38:38.601462+00	2026-10-31 07:38:38.601462+00
a53e4174-496e-4b3d-b487-f2e810887555	4655f402-97bb-4f99-8409-66dd3fb31826	4bde00c2-5efd-4694-bcd0-41be8b23aedb	\N	Audit Analytics Suite 8ebd0b	1	50000.0000	50000.0000	2026-10-31 08:24:11.624711+00	2026-10-31 08:24:11.624711+00
d9d0353f-feba-4825-8367-4d79441d9aa0	46674e86-de9a-478d-8905-e318902d5646	f9b16ecd-e8bf-46ef-8482-2a84eb215fd2	\N	Overlap Prod b22d76	1	1000.0000	1000.0000	2026-10-31 08:24:14.76841+00	2026-10-31 08:24:14.76841+00
a8a11a9a-6a84-457a-b8c4-c0f7e6b9389b	9d18c9ea-906f-47c7-8958-310eb2af70bb	7f8d1ec4-f42c-48c7-928f-278cf9d23b34	\N	OP Prod dbfa6b	1	1000.0000	1000.0000	2026-10-31 08:24:15.660904+00	2026-10-31 08:24:15.660904+00
674a9283-db3c-47d5-8ad5-4a187c028ced	a38ddb73-7a1e-4e90-b394-39a597c03588	6d9f2b8f-4038-4bf7-baee-a0bbd91ba314	\N	Neg9 Prod 7559a3	1	500.0000	500.0000	2026-10-31 08:24:17.073667+00	2026-10-31 08:24:17.073667+00
fcda4b11-f709-4cf0-9913-28fff26d054b	397b784d-7ee3-465d-8c49-92313e63407c	3e3ede4f-d267-4cff-8549-9755a16fc590	\N	Cloud Security Suite	1	2000.0000	2000.0000	2026-10-31 08:24:18.182825+00	2026-10-31 08:24:18.182825+00
1d68293f-0176-4757-9d9c-5fa9cb7e4eda	a6fb2feb-91a4-40e8-a929-493ad3c51655	3c81cd1f-5e81-45bc-9416-9e2095c3c324	\N	Audit Analytics Suite 7b522b	1	50000.0000	50000.0000	2026-10-31 08:27:38.406661+00	2026-10-31 08:27:38.406661+00
c40b8577-4f9f-49cc-ab29-31308ee5677c	207eeac6-9033-4970-b642-39fda4d6185e	48e0f739-0593-420f-a170-a77c35a41fae	\N	Overlap Prod 425051	1	1000.0000	1000.0000	2026-10-31 08:27:41.159115+00	2026-10-31 08:27:41.159115+00
464df00c-8f71-44d6-9ef5-3c79a0126c9d	3e8352ea-a990-49e7-a662-918dfa590cb2	06a547de-b22a-49b3-9adc-fe3be1734f08	\N	OP Prod 934bd2	1	1000.0000	1000.0000	2026-10-31 08:27:41.91851+00	2026-10-31 08:27:41.91851+00
5445fe77-f601-435d-aecc-426902d28070	dfd42561-82ce-4356-944a-1f33180471d6	ca41c692-d96d-44a2-b66c-65b15120e34b	\N	Neg9 Prod b487f3	1	500.0000	500.0000	2026-10-31 08:27:43.044565+00	2026-10-31 08:27:43.044565+00
4ae6114e-76d6-41c1-afe7-471cc437a750	64641d8f-1b99-44f9-9459-8c7d1acfba03	c6410f1a-5961-42a0-b35f-800a55a315be	\N	Cloud Security Suite	1	2000.0000	2000.0000	2026-10-31 08:27:44.194805+00	2026-10-31 08:27:44.194805+00
\.


--
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: brightloop_user
--

COPY public.invoices (id, invoice_number, subscription_id, customer_id, status, payment_status, issue_date, due_date, billing_period_start, billing_period_end, currency, subtotal, tax_rate, tax_amount, discount_amount, total_amount, amount_paid, balance_due, notes, created_by_id, created_at, updated_at) FROM stdin;
c8a257fd-b794-4423-84f9-59a2ff027466	INV-202610-0001	4d53671e-2944-412a-a719-7177196275b6	d8aba305-385d-4f8c-abcd-ee4db0e52f4d	PAID	PAID	2026-10-31 07:01:39.337179+00	2026-11-30 07:01:39.337179+00	2026-10-31 07:01:39.095339+00	2026-11-30 07:01:39.095339+00	INR	2000.0000	18.0000	360.0000	0.0000	2360.0000	2360.0000	0.0000	\N	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:01:39.309746+00	2026-10-31 07:01:40.011002+00
6ca8252d-9d7c-4a93-b23b-b81acade770e	INV-202610-0002	056e88ff-c823-4843-b98f-65f3b616c0b0	20de22c3-c73e-40d3-bc37-9cf9b129a783	PAID	PAID	2026-10-31 07:24:19.655843+00	2026-11-30 07:24:19.655843+00	2026-10-31 07:24:19.387008+00	2026-11-30 07:24:19.387008+00	INR	2000.0000	18.0000	360.0000	0.0000	2360.0000	2360.0000	0.0000	\N	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:24:19.620146+00	2026-10-31 07:24:20.308171+00
c22ea219-4c7d-4125-a575-f217346e48ec	INV-202610-0003	72541aa9-36f8-4b9c-9626-b060cc5140d3	0bbc71dc-0eda-419a-88a5-03fb4ff39b6b	PAID	PAID	2026-10-16 07:33:24.877413+00	2026-11-15 07:33:24.877413+00	2026-10-01 07:33:24.877413+00	2027-10-01 07:33:24.877413+00	INR	120000.0000	18.0000	21600.0000	0.0000	141600.0000	141600.0000	0.0000	Annual recurring fee + 18% GST	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
1346cc70-fc94-44e1-a3b2-624c05cff912	INV-202610-0004	cecfc49e-26c5-4e3f-bac9-8f8458dc4598	c35f47e5-0366-411b-81af-49b909c51fbc	CONFIRMED	PARTIALLY_PAID	2026-10-27 07:33:24.877413+00	2026-11-11 07:33:24.877413+00	2026-10-26 07:33:24.877413+00	2026-11-25 07:33:24.877413+00	INR	15000.0000	18.0000	2700.0000	0.0000	17700.0000	10000.0000	7700.0000	Monthly Growth tier billing	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
24391ca7-3405-4e6d-899b-629ef9e1fbfb	INV-202610-0005	84b00a2f-0122-4bc7-a407-040b02cb1133	5aa41d88-f9e6-405b-981a-c96dd1144e29	CONFIRMED	UNPAID	2026-10-31 07:33:24.877413+00	2026-11-30 07:33:24.877413+00	2026-10-31 07:33:24.877413+00	2027-10-31 07:33:24.877413+00	INR	120000.0000	18.0000	21600.0000	0.0000	141600.0000	0.0000	141600.0000	Awaiting finance release under NET 30	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
27881d41-b173-47f6-8e0c-3ec728bdec01	INV-202610-0006	f1e7cc49-c8af-465e-9d83-d64f5101b2bb	d1ad1940-cda3-43d9-8725-9af55aabf801	PAID	PAID	2026-10-31 07:37:29.478344+00	2026-11-30 07:37:29.478344+00	2026-10-31 07:37:29.478344+00	2026-11-30 07:37:29.478344+00	INR	50000.0000	18.0000	9000.0000	0.0000	59000.0000	59000.0000	0.0000	First billing period invoice	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:29.723883+00	2026-10-31 07:37:30.32658+00
f045f94c-d267-4dfe-a757-a867da47d824	INV-202610-0007	94fc7b5b-d190-4f0d-a531-7d7a3ddd92cf	ad1f6972-67c1-4b0b-a015-ba3aea186bc9	PAID	PAID	2026-10-31 07:38:18.541645+00	2026-11-30 07:38:18.541645+00	2026-10-31 07:38:18.541645+00	2026-11-30 07:38:18.541645+00	INR	50000.0000	18.0000	9000.0000	0.0000	59000.0000	59000.0000	0.0000	First billing period invoice	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:18.777905+00	2026-10-31 07:38:19.395995+00
7e8dfe6e-8aa2-4ad6-b61d-2d765bc9dd5d	INV-202610-0008	d0c58c40-a1f6-4a94-bbfd-bef418d3fe4a	1391c136-849b-4cbc-8cdb-7c35f86cd85e	CONFIRMED	UNPAID	2026-10-31 07:38:21.652845+00	2026-11-30 07:38:21.652845+00	2026-10-31 07:38:21.411067+00	2026-11-30 07:38:21.411067+00	INR	1000.0000	18.0000	180.0000	0.0000	1180.0000	0.0000	1180.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:21.621141+00	2026-10-31 07:38:21.621141+00
a9c2def3-0595-4a6f-98b3-418033c61e4d	INV-202610-0009	56bce7e4-07dc-4507-bd3a-99fbbd8415fb	e5f99822-843b-4c7c-bd7b-3afa17d5e1c9	CONFIRMED	UNPAID	2026-10-31 07:38:22.435767+00	2026-11-30 07:38:22.435767+00	2026-10-31 07:38:22.180773+00	2026-11-30 07:38:22.180773+00	INR	1000.0000	18.0000	180.0000	0.0000	1180.0000	0.0000	1180.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:22.400217+00	2026-10-31 07:38:22.400217+00
0aab8183-061d-420f-94f8-28ccb3787387	INV-202610-0010	f2b75ded-d929-4852-bceb-9abbaa11ef6c	eb64f133-dafc-418f-8f4a-90e9dbc9cdcb	PAID	PAID	2026-10-31 07:38:23.530359+00	2026-11-30 07:38:23.530359+00	2026-10-31 07:38:23.279972+00	2026-11-30 07:38:23.279972+00	INR	500.0000	18.0000	90.0000	0.0000	590.0000	590.0000	0.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:23.499339+00	2026-10-31 07:38:23.596007+00
153907e7-11b5-4b59-bff6-74e65a43799a	INV-202610-0011	30ad68cd-90d1-4fc9-b2b5-ff49f20f8dfc	b9ba2119-ac8a-4bf5-85ff-889e7efba0d6	PAID	PAID	2026-10-31 07:38:32.833159+00	2026-11-30 07:38:32.833159+00	2026-10-31 07:38:32.833159+00	2026-11-30 07:38:32.833159+00	INR	50000.0000	18.0000	9000.0000	0.0000	59000.0000	59000.0000	0.0000	First billing period invoice	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:33.063629+00	2026-10-31 07:38:33.622729+00
af36956d-d174-4992-8e6c-f6e22f04cc4d	INV-202610-0012	2c293e93-3a1f-4630-8462-a57f05ea41c7	a7b2a3b6-0da7-4090-91a0-c7dcf15afcce	CONFIRMED	UNPAID	2026-10-31 07:38:35.656461+00	2026-11-30 07:38:35.656461+00	2026-10-31 07:38:35.400398+00	2026-11-30 07:38:35.400398+00	INR	1000.0000	18.0000	180.0000	0.0000	1180.0000	0.0000	1180.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:35.624136+00	2026-10-31 07:38:35.624136+00
1683324b-0c67-4574-9665-a0acb335760e	INV-202610-0013	1d20677a-d222-4695-b150-72ad3587c5e6	0704c6a3-68be-4b4c-adca-8184b6bdbc45	CONFIRMED	UNPAID	2026-10-31 07:38:36.434073+00	2026-11-30 07:38:36.434073+00	2026-10-31 07:38:36.192046+00	2026-11-30 07:38:36.192046+00	INR	1000.0000	18.0000	180.0000	0.0000	1180.0000	0.0000	1180.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:36.402136+00	2026-10-31 07:38:36.402136+00
5324b6db-b19a-45b5-a2d0-9747f4fa1597	INV-202610-0014	b009b479-8b6f-4eb5-967e-c069ce31b7ad	cb06e29c-acf5-4d8e-9b97-91a250b6b4d8	PAID	PAID	2026-10-31 07:38:37.592445+00	2026-11-30 07:38:37.592445+00	2026-10-31 07:38:37.330844+00	2026-11-30 07:38:37.330844+00	INR	500.0000	18.0000	90.0000	0.0000	590.0000	590.0000	0.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:37.557389+00	2026-10-31 07:38:37.656834+00
9796d144-f65d-43e5-91cb-f5f5420c1cef	INV-202610-0015	5ac937b7-c600-4f8e-9e05-4df0583deeb6	4f3ec259-43da-4e7a-8316-22a71e23d0db	PAID	PAID	2026-10-31 07:38:38.633372+00	2026-11-30 07:38:38.633372+00	2026-10-31 07:38:38.387872+00	2026-11-30 07:38:38.387872+00	INR	2000.0000	18.0000	360.0000	0.0000	2360.0000	2360.0000	0.0000	\N	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:38:38.601462+00	2026-10-31 07:38:39.199716+00
4655f402-97bb-4f99-8409-66dd3fb31826	INV-202610-0016	d3d2ff47-1496-45ee-bc84-ec7e81aced75	bca5e35f-ed0e-4e3c-a57f-eb24c360a6fb	PAID	PAID	2026-10-31 08:24:11.350081+00	2026-11-30 08:24:11.350081+00	2026-10-31 08:24:11.350081+00	2026-11-30 08:24:11.350081+00	INR	50000.0000	18.0000	9000.0000	0.0000	59000.0000	59000.0000	0.0000	First billing period invoice	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:11.624711+00	2026-10-31 08:24:12.46962+00
46674e86-de9a-478d-8905-e318902d5646	INV-202610-0017	f6261125-c013-4208-a694-f85ba034150b	0e75110e-28f7-451f-a480-86c34b25a040	CONFIRMED	UNPAID	2026-10-31 08:24:14.796368+00	2026-11-30 08:24:14.796368+00	2026-10-31 08:24:14.467785+00	2026-11-30 08:24:14.467785+00	INR	1000.0000	18.0000	180.0000	0.0000	1180.0000	0.0000	1180.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:14.76841+00	2026-10-31 08:24:14.76841+00
9d18c9ea-906f-47c7-8958-310eb2af70bb	INV-202610-0018	96e254fe-161e-43c8-bd4e-374d2a6277a3	40937aa1-dcea-4eee-b28b-597f431549e5	CONFIRMED	UNPAID	2026-10-31 08:24:15.702724+00	2026-11-30 08:24:15.702724+00	2026-10-31 08:24:15.384225+00	2026-11-30 08:24:15.384225+00	INR	1000.0000	18.0000	180.0000	0.0000	1180.0000	0.0000	1180.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:15.660904+00	2026-10-31 08:24:15.660904+00
a38ddb73-7a1e-4e90-b394-39a597c03588	INV-202610-0019	6b0a8d72-7313-402a-9e66-e287cb1eef53	ef262998-7f20-45f5-bed3-ac7a7de9c250	PAID	PAID	2026-10-31 08:24:17.111743+00	2026-11-30 08:24:17.111743+00	2026-10-31 08:24:16.851203+00	2026-11-30 08:24:16.851203+00	INR	500.0000	18.0000	90.0000	0.0000	590.0000	590.0000	0.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:17.073667+00	2026-10-31 08:24:17.17587+00
397b784d-7ee3-465d-8c49-92313e63407c	INV-202610-0020	1145b2e2-2ee9-4ecc-ac68-7e3e0e6c3a86	f4256ea5-779c-448a-b1fb-6a98398d127c	PAID	PAID	2026-10-31 08:24:18.218932+00	2026-11-30 08:24:18.218932+00	2026-10-31 08:24:17.96618+00	2026-11-30 08:24:17.96618+00	INR	2000.0000	18.0000	360.0000	0.0000	2360.0000	2360.0000	0.0000	\N	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:24:18.182825+00	2026-10-31 08:24:18.900848+00
a6fb2feb-91a4-40e8-a929-493ad3c51655	INV-202610-0021	a71d2d50-f658-4fd0-b097-6de1dc57d86f	e86d89d3-0129-4b78-af76-2534ca7c0dce	PAID	PAID	2026-10-31 08:27:38.183028+00	2026-11-30 08:27:38.183028+00	2026-10-31 08:27:38.183028+00	2026-11-30 08:27:38.183028+00	INR	50000.0000	18.0000	9000.0000	0.0000	59000.0000	59000.0000	0.0000	First billing period invoice	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:38.406661+00	2026-10-31 08:27:38.997464+00
207eeac6-9033-4970-b642-39fda4d6185e	INV-202610-0022	73b766b0-35e5-4fc1-a7d8-d4d3fef4e1fd	b9dbbade-cf48-41e7-8d11-ef09de2c12df	CONFIRMED	UNPAID	2026-10-31 08:27:41.190307+00	2026-11-30 08:27:41.190307+00	2026-10-31 08:27:40.951096+00	2026-11-30 08:27:40.951096+00	INR	1000.0000	18.0000	180.0000	0.0000	1180.0000	0.0000	1180.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:41.159115+00	2026-10-31 08:27:41.159115+00
3e8352ea-a990-49e7-a662-918dfa590cb2	INV-202610-0023	8b58c724-98ce-465c-a73a-82d998e94cff	3a143bfe-fc4e-40dd-9a30-3120cd17fc02	CONFIRMED	UNPAID	2026-10-31 08:27:41.951806+00	2026-11-30 08:27:41.951806+00	2026-10-31 08:27:41.71284+00	2026-11-30 08:27:41.71284+00	INR	1000.0000	18.0000	180.0000	0.0000	1180.0000	0.0000	1180.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:41.91851+00	2026-10-31 08:27:41.91851+00
dfd42561-82ce-4356-944a-1f33180471d6	INV-202610-0024	2e63834d-8e53-411f-b939-f1d9e971f63e	d69a4475-31c3-44f8-b77e-8fce5e1c05df	PAID	PAID	2026-10-31 08:27:43.079027+00	2026-11-30 08:27:43.079027+00	2026-10-31 08:27:42.80916+00	2026-11-30 08:27:42.80916+00	INR	500.0000	18.0000	90.0000	0.0000	590.0000	590.0000	0.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:43.044565+00	2026-10-31 08:27:43.148216+00
64641d8f-1b99-44f9-9459-8c7d1acfba03	INV-202610-0025	504b31b6-e697-46b6-b0f4-7c48b4117fe0	a5ecc61e-3478-4aac-9c83-7493ce661f9f	PAID	PAID	2026-10-31 08:27:44.226846+00	2026-11-30 08:27:44.226846+00	2026-10-31 08:27:43.976407+00	2026-11-30 08:27:43.976407+00	INR	2000.0000	18.0000	360.0000	0.0000	2360.0000	2360.0000	0.0000	\N	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:27:44.194805+00	2026-10-31 08:27:44.813299+00
\.


--
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: brightloop_user
--

COPY public.password_reset_tokens (id, user_id, token_hash, is_used, expires_at, created_at) FROM stdin;
e5353b04-b921-4465-b4bb-dede8ab522e8	eff31d33-4717-4f20-8fb1-480799cdeae5	ffe054fe7ae0cb6dc65c3af9b61d5209f439851db43d0ba5997337df154668eb	t	2026-10-31 05:13:43.677676+00	2026-10-31 04:13:43.677203+00
3b6d67be-37c2-4ac8-a35b-32d786359d83	1f4ef7b6-1866-4f50-9627-2d5340886b2f	179d3b49961dbf52b7030da842a234bb2e4bf216f7ef7e5d6c3d0de2c6a80499	f	2026-10-31 05:14:56.823898+00	2026-10-31 04:14:56.821513+00
c0aef9d7-c296-4e60-8bc6-82a0e4079364	f2b5bafc-3d46-4968-bfae-1f837ee70ea7	1b819de8073af2632c832d56f4c95e65daf134f9d795f5714294429abf79f2ce	t	2026-10-31 08:24:17.449905+00	2026-10-31 07:24:17.445515+00
b7c882c6-c88f-413c-a023-7a8823d8cc1f	75a26128-3f2e-489a-a766-30ea3e7197db	7212c436fdff21aa2f4af76b7fdc3b55f9a0e62429bcbc61fba7a98c956a3fe1	f	2026-10-31 05:15:15.343926+00	2026-10-31 04:15:15.341804+00
d5825692-2f9b-4ee0-8b70-f5fa300db9af	d9d4a6b9-4e42-40a7-a637-1c3cd145c1e4	38fac27ac6f4d140fdfc54f6b6bf67deb38e8a2397cad6251e1da5be0b3616cb	t	2026-10-31 08:24:17.815422+00	2026-10-31 07:24:17.811431+00
c5bf5ea7-9730-46e7-b816-5c7525242625	f1606ee3-6693-4e3a-9e7a-9fc18d00a065	a4ed17de30dfb6b4d2cddaace5abe17b0dd16fd5a1845e00d0f987a251d15aeb	t	2026-10-31 05:15:41.707573+00	2026-10-31 04:15:41.704663+00
1286d2c6-5cc6-4901-b0cf-3e24e7140b4e	d9d4a6b9-4e42-40a7-a637-1c3cd145c1e4	ef7c784db6ad93d77dfcefcf61b537bb6fa4226627b60bb5d2c5f7182ba709a9	f	2026-10-31 08:24:17.867466+00	2026-10-31 07:24:17.86269+00
fc4111ae-d3ca-4432-b3d6-29e275d915c4	3fac70e5-8751-4981-a145-bb97fbce8d27	263d5bf771433002485bd4c63488d6221362abbd110c9fa14599e099949a2106	f	2026-11-01 07:24:18.198293+00	2026-10-31 07:24:18.140946+00
1893e212-11e1-4442-baaa-1e659d75e381	aa322c84-c6ac-4251-8e52-4f77ec351b2c	283fbae18d0d45f67188aa3052c5078b78078e31cb01d6b81d43bc4e3c3edbaf	t	2026-10-31 05:15:48.375349+00	2026-10-31 04:15:48.373362+00
31167da1-d916-4c77-807c-e857d9e39d29	2de8920e-abf2-44f4-9d69-d48779260b63	63e67dad1c2fe3439bebb0f11f4ca054784b330f6595e8602a8ac6027ef2addc	f	2026-11-01 07:24:19.354008+00	2026-10-31 07:24:19.297932+00
ed819d39-0e4d-4144-ad9a-fa8366011f7b	0f393bda-925a-4ca8-8a28-7db07ce74607	a440a42b8cb5d9f83c679d41e63df482e7322fa1c429cb293b37a28542519b48	f	2026-11-01 07:24:22.812553+00	2026-10-31 07:24:22.757832+00
e918d8e0-133b-4c58-94e9-60ee06e842ce	ea823d6a-8512-4342-8975-0f9a54160a14	0b7310ae1b22491c2ca884a0dbb460e532d018e2e45dd46475a8c0a28e60d745	t	2026-10-31 06:11:18.812122+00	2026-10-31 05:11:18.807783+00
ab810466-2308-47d4-a959-a56ac2eba6b9	82da7fb7-b8ce-4ee7-884d-200a4b3646df	93a65edc08ca0c7009f60c6060f0f226d38fb7897331782108118bd58a071df7	t	2026-10-31 06:11:19.197627+00	2026-10-31 05:11:19.192861+00
e9872dc2-f280-4d61-9bf4-ed38ad3f0261	82da7fb7-b8ce-4ee7-884d-200a4b3646df	03729202671c6c7a705a39d3a956f767eb490647ceed2adca767b6e095ba9467	f	2026-10-31 06:11:19.248966+00	2026-10-31 05:11:19.24435+00
bdcf67ee-b0ab-4c5b-9e2c-b95173f6f2b0	8336509a-cf9b-4a96-a0b6-7bc3890a3f63	b6e6ac3dc03da7e54bd7478f8ae1a96bffa1e19f726c8ad6453edcffb1dcd8da	t	2026-10-31 06:11:51.189735+00	2026-10-31 05:11:51.184823+00
73309901-29b3-4dfa-ad9c-66918d0f3541	d9538ec8-6c00-4ca4-bcf6-813e57938761	cbc0becd20c9b84fb142e479fdb44b029c5d861007f33918aee1e4eca15407ed	t	2026-10-31 06:11:51.53095+00	2026-10-31 05:11:51.52769+00
28479485-c00c-4d0d-8ce0-fed2bc7fa892	d9538ec8-6c00-4ca4-bcf6-813e57938761	04035f701e35b7413fb031ab5d7cef879f1f481941fb621bbfcc3ea771262da9	f	2026-10-31 06:11:51.567258+00	2026-10-31 05:11:51.564014+00
d8659a68-a953-4427-a3e4-0466d1146281	d119b3bf-3c56-42b9-98f5-79275414ee22	c8438ff0a7dfd333dcfd4ba9805406280656e029b1b26c6a8d2ee644adb7833d	t	2026-10-31 06:12:56.836407+00	2026-10-31 05:12:56.831699+00
906cadd6-658f-41bb-9bad-fb86a36abf86	12a618c3-a8ef-459e-9c5c-977db2a3608a	3dc70e4e83ce5deaad9623a17b839d0dbe8aeb7c2f6233940810712630c5a629	t	2026-10-31 06:12:57.152617+00	2026-10-31 05:12:57.14828+00
4a360e43-1dd2-477e-886e-0c7e56459bb2	12a618c3-a8ef-459e-9c5c-977db2a3608a	748288179bd3cb23a517103fe8104569a5b610040a71c8ad4b7cb20f64c6e190	f	2026-10-31 06:12:57.190431+00	2026-10-31 05:12:57.187063+00
583f58f6-eb56-4cec-9996-8a884fb642db	b0ffc2ce-dc12-4fad-b3d6-eca9b62ca5ef	359dc618e3e9af42e2d5436219a054f968607d7308a680b7c49209e6a2348c08	t	2026-10-31 06:46:04.452419+00	2026-10-31 05:46:04.447609+00
15ad33ab-b265-41bc-9c6a-f8b390935b83	dbce35f4-40f9-4a80-bf40-937820427ad4	25e15050fd9c4c7476530715369913e2107b76a33241ca964db6e26885156260	t	2026-10-31 06:46:04.817885+00	2026-10-31 05:46:04.814017+00
02841019-21e1-4272-86d6-30323bb8790c	dbce35f4-40f9-4a80-bf40-937820427ad4	b8e8562c5d5ec243a37726d2bd8afd3847500ab37c07af93f5893e5426fddc95	f	2026-10-31 06:46:04.860273+00	2026-10-31 05:46:04.856382+00
179fcc92-e0bf-41ec-88be-a3b7e5c6bddf	5e5e63e5-354e-42be-9956-4f3237c85440	902ceb670ca688b4a0d14e30d958eea141305e3f288d9e0dcc270e37cce28fa9	t	2026-10-31 06:52:55.850458+00	2026-10-31 05:52:55.846184+00
4125fb9f-48ff-45a5-abf6-583ee88b5ffa	2a7a573c-ee88-475c-8c7e-776a32e72b4d	74799004dc337d17c0871b83feddaa042c0e89f5257d9bdb4509443b6877f65c	t	2026-10-31 06:52:56.187265+00	2026-10-31 05:52:56.182721+00
4d6d9e53-ec80-4ce4-8248-19c82bd7429e	2a7a573c-ee88-475c-8c7e-776a32e72b4d	82bf91d3b14a57fc2695eb8398eaaf243cc35d629e8cc720a2a0b58eea351249	f	2026-10-31 06:52:56.226657+00	2026-10-31 05:52:56.222978+00
6ff4c643-4816-4df8-af82-bde77b02f6f6	b144c086-d788-4342-8e6b-3dfee3355527	bd3e60696ba7ccef83970bb554ab8a09aba4c938fa078727a6137e2e41752303	t	2026-10-31 06:59:25.86972+00	2026-10-31 05:59:25.865086+00
d30d5aaf-8fb4-46b0-8f0e-81a51ebeb8cf	156085e9-785e-4e4b-8e1e-b6109bbc1876	3fc396f229ba8d52bfd14eeefcf9619171fbafb3d5c6f3677ca67c6512c05aeb	t	2026-10-31 06:59:26.329128+00	2026-10-31 05:59:26.323619+00
c19ce2ad-7f2a-402b-ae36-cf4cd00861f2	156085e9-785e-4e4b-8e1e-b6109bbc1876	4099a35b95a91c28769fa10db6dd428762bf3b327a9676723297f95c97ddf6fc	f	2026-10-31 06:59:26.499827+00	2026-10-31 05:59:26.496267+00
bf6e9790-ee28-4dfd-b2d2-fc671df4ca3d	b23e2baa-5c89-4c93-b7a7-129f2c72d695	badd1bb073be3801f5c8f8bf602481102915f747b2465246fb7681cf11efb0bc	t	2026-10-31 07:13:50.26815+00	2026-10-31 06:13:50.264457+00
d3f6df10-bb70-453e-8561-4ab7f4556387	363682ab-f901-4a29-a3aa-ba02862dffe8	fcc00e590575b5d7debf23c98eb10b2c066c1874df5f97f39a482831b02c28da	t	2026-10-31 07:13:50.611338+00	2026-10-31 06:13:50.606424+00
b2ee22e1-dd02-455b-9ab6-04c27fb76900	363682ab-f901-4a29-a3aa-ba02862dffe8	3b40a03c71e5d7789c900c70731bc76449abb98ba9fbb6e4206e7ad11f1735bf	f	2026-10-31 07:13:50.653697+00	2026-10-31 06:13:50.649528+00
89efd9f1-635f-4833-a609-b330d7a26c8f	537a0cb3-7755-40b3-b86c-fbb8b65dc2a8	93ab1a70ed5a0fcdd0fdd9b27a953b3b9b156a43b756761c23f6d6735ac0d46c	t	2026-10-31 07:26:01.849087+00	2026-10-31 06:26:01.844406+00
e3ff2b10-63f5-4dd3-84d1-f9fcc29307d9	0e6486aa-8925-457f-b2a3-a8e65f6daf02	96718b3bbd6e4bdbe793845827bd1cf1dad106b7d1bb1e22016d44847da6cffe	t	2026-10-31 07:26:02.167136+00	2026-10-31 06:26:02.162243+00
843c51b9-1c76-49e6-bc76-e3d909d3554a	0e6486aa-8925-457f-b2a3-a8e65f6daf02	fd0ecd8133949925a84a5b92430405ce4ce57bb689aec28de6e2f6310428b09c	f	2026-10-31 07:26:02.207962+00	2026-10-31 06:26:02.203685+00
efb93027-eb12-473f-8a96-c386216511a4	7350b76c-28c0-4b09-98e2-6eca12318089	99f057f55e70ff0bb05eac6a54e1557531adcf27376960312d503a66b20f82ee	t	2026-10-31 07:56:45.621834+00	2026-10-31 06:56:45.616655+00
393c4d3d-7f10-4386-a6f8-bac2c97f10eb	8917a4d5-0384-45b4-9836-1bdecdf360ca	d0514a4e5b53c932f6aa4470aeb3f7bc9198fb4a9541ecaa7e09cfeb73c62a04	t	2026-10-31 07:56:46.004433+00	2026-10-31 06:56:46.000426+00
5f1d7a1b-01e2-48a2-8351-a2ce8b60c190	8917a4d5-0384-45b4-9836-1bdecdf360ca	5327e2404a830326f3eaf69c3045d563b3d873e8322a97b37395deee94ca9466	f	2026-10-31 07:56:46.051398+00	2026-10-31 06:56:46.047441+00
94af29d4-01a0-4f8d-ae67-0258bd340ec6	8c3d9164-64db-4f25-bd84-c74a61f47a07	b0a5d263132ef8ead8a248d09ec262e2a295ea707dc46e8ce1e7569a61d12f5b	t	2026-10-31 07:57:55.350647+00	2026-10-31 06:57:55.34629+00
68269d76-a560-427f-8e1d-dded7e3d311a	0ee8c0fb-b477-4640-96f9-55e7f4e62d18	5c519efb129cb2ab6212d59aaee1effd5d9d7b81f22af14ed7509038baec271a	t	2026-10-31 07:57:55.709584+00	2026-10-31 06:57:55.704897+00
96cf9564-097e-4434-861f-673d24be82d5	0ee8c0fb-b477-4640-96f9-55e7f4e62d18	f1b169c0fb5bcf9afff7873cda174e52ca366f59af6798e4b74d673bd4126f3f	f	2026-10-31 07:57:55.756635+00	2026-10-31 06:57:55.750976+00
1e5a7f94-9e10-42a6-a4cb-bd85111679bb	9454fb0f-4bec-4f35-8752-0ff0c45850ad	7bab0dac9ffee999af56edf0af980d72f37e3bd48a490b2c3b620e03c94b579a	t	2026-10-31 08:01:01.912971+00	2026-10-31 07:01:01.908312+00
4ad57dae-d3d7-4acc-aab1-9ab620f55717	ef162596-be5a-46c7-b5c9-96fffde7649e	05fdc81145cdbdc0d3a39a6e5a01b7b32ca0aecd489a38f302bb000925b3dae5	t	2026-10-31 08:01:02.262467+00	2026-10-31 07:01:02.256941+00
d109b330-3332-46e6-b8bd-10cdd735310b	ef162596-be5a-46c7-b5c9-96fffde7649e	5b13f9c241a35086c04532c0dadf23da7bc8b2a890601e62331f478dccfd89f9	f	2026-10-31 08:01:02.305433+00	2026-10-31 07:01:02.300859+00
9e3b7cf6-26a5-454f-82ed-7bfb01a78e0f	79afecfb-a64b-47a2-813c-72f6eec196c4	f49f9ce6dd103940e12dbaa37b5cb10c991e55377753d0b096813997cdfc83a1	t	2026-10-31 08:01:37.571355+00	2026-10-31 07:01:37.563723+00
de30e4a6-c619-400e-a22c-01fc12d3d62c	07c13107-a120-4937-b7bb-b235ecc5b8c4	4d5b6a1a96bcb90e4dcbecc7a3c833b5c378e8eb4a579a154de648128d7fab2f	t	2026-10-31 08:01:37.927164+00	2026-10-31 07:01:37.922781+00
dccbf6c1-37f0-40c8-991e-d2460672d6aa	07c13107-a120-4937-b7bb-b235ecc5b8c4	8c02a8f59f610dfaa3258a3a352389e27a979f4f135a4235a84c5e6cb08229ea	f	2026-10-31 08:01:37.972679+00	2026-10-31 07:01:37.968453+00
4b79b294-2266-485d-8b88-c2330197d938	42ac6db9-70d7-4973-8852-c8c16d975be9	751e4d66e9719639f8f4185a4fa6a987c8775c8ed4cfb6cc6850b78246e69ce7	f	2026-11-01 07:33:24.693616+00	2026-10-31 07:33:24.444528+00
4d7df965-d2ec-4407-9336-14ca710c6a67	0edd6c45-63f8-4d39-aade-7746228f0b98	00aec03d3badd4493249314c51dab94bad67e53b1c0bb357d78269a88c7687af	f	2026-11-01 07:33:24.781265+00	2026-10-31 07:33:24.444528+00
51fd8775-0998-4aa5-bbd3-247f7b00768a	ab39119d-27a4-4eae-b2ea-b2413a1540ad	bc8dab27e0656c2d441a7527e3c29bcd14a8ddc6648a3459666da2cf8cd7a4bc	f	2026-11-01 07:33:24.85252+00	2026-10-31 07:33:24.444528+00
6007e46e-7bc1-44eb-acc9-6bc6d23830f6	319ca723-eafd-4883-b097-6b20dd0faabb	6048e928b2a8623993464a4f3bd5b6cd34ae93abd15a61789f72f63d6a8a5d8e	f	2026-11-01 07:35:20.521763+00	2026-10-31 07:35:20.464995+00
e480f9b6-24b3-4c30-a45e-4248b4f49954	b0289709-fdb9-4186-8170-97d5fe8ca536	7685f9904783404ee7a156ba463739b2a98f48caf96f0f094f48695b1317e0c9	f	2026-11-01 07:35:20.968687+00	2026-10-31 07:35:20.912989+00
e81b77e1-e63f-418c-bc52-91958c8281ba	62ba0cee-0bbc-4fa2-a484-0d17e7e96c78	c5c6258e60d03f1563bc9edb456e1b7224cc43d0423231a5a583171bd072c4f5	f	2026-11-01 07:35:21.292534+00	2026-10-31 07:35:21.235137+00
0c250348-55ed-48d7-af2e-773db3d700eb	e9e2cf4f-ce8b-4220-bdec-6d394ba91885	4f1067c8ea0f17550d5e5af712f1fc76a406145ed41097586b2621fc45bd94f6	f	2026-11-01 07:35:21.570554+00	2026-10-31 07:35:21.512494+00
ab925af6-6955-4eb6-85de-a63d3a155315	6f71e03b-972e-4a07-a28f-831713f9da1c	3c385280aeebcdb37fd0d0063d474f8a6d74ccc2b28204d7251ba2d59472e5f1	f	2026-11-01 07:35:21.908556+00	2026-10-31 07:35:21.851666+00
37c7e188-6b7a-45b9-9059-41cc06dfce15	e82dfe6d-4528-4957-b697-af13e73699a8	9a8d092c927db5f06296b11549bdb79b5df39ef0ca936d80eb70b206bd1b479e	f	2026-11-01 07:35:22.428461+00	2026-10-31 07:35:22.372764+00
3538db07-28ce-40b9-9fc0-7448ae0cfa7e	1db238e8-d823-4e53-a192-4cbe1979c01a	b2c48f529a3af7ba7e35b57e3e5ac0de637e10cfd83872a11808f385b8835b18	f	2026-11-01 07:35:23.025899+00	2026-10-31 07:35:22.969455+00
5859e5d8-7028-44a2-9931-c48537cfdf29	6c761294-0188-4925-9242-3fddfec0c211	b66d7ff011b1f8b1d80aadf9ba1ec9c06047b616252d1975534b33a99292198f	f	2026-11-01 07:37:29.269075+00	2026-10-31 07:37:29.206418+00
13e739c3-1216-4e7a-a277-e11f20e19319	fda5f60c-b55c-4681-8eee-8754701bb862	30862196e305427ccc25fe7e2549cb9d77d79caf97a3a1a9131b0ed7c5777822	f	2026-11-01 07:37:31.22552+00	2026-10-31 07:37:31.169295+00
88a0cfbd-69a4-43f0-b7e7-98e717af0042	0bc3d615-5e7e-42bb-8e77-55fe6d255d6f	8f1dfc51d0867cc059b1ee0fa96bedfcd88f3e405b4a6cde953d6f70fff0fe4c	f	2026-11-01 07:37:31.555112+00	2026-10-31 07:37:31.499712+00
b8ef1fed-134f-4924-92cc-a52ca0906a68	e92e067c-86a6-41c9-95f9-04601ecea5ac	24424ba42774c8624b6a50c250be929844da63d3c8fac991835795cd60915351	f	2026-11-01 07:37:31.831792+00	2026-10-31 07:37:31.777375+00
97908da8-9227-4682-81a2-819777da54b6	31ead84d-8593-44a7-82be-62269162708b	97c9a2aea2cb2a044b180719bcc2bb78bdb3e502d91d54db705016c21364e260	f	2026-11-01 07:37:32.138874+00	2026-10-31 07:37:32.08704+00
f089aae6-05bd-49d3-b9f0-ff9097ceec30	010ca79b-8c8d-4721-a74f-ce2fdc90ed73	2f2bb2ef453de58064fccd5c03afe94ba5a943324a56320aa352b8311276b9c0	f	2026-11-01 07:37:32.710026+00	2026-10-31 07:37:32.654626+00
676e4e06-47bf-4663-ba12-ab41140e817d	fbc9f9fb-074d-4943-a212-dde7cf5eaf6e	7bcbed58e8115be1820c55d7c721fcfc08611fef5f2d9c79d4653d236673e28d	f	2026-11-01 07:37:33.047784+00	2026-10-31 07:37:32.993211+00
2ae7e21d-46ac-45e3-87db-127344771b19	2fbae6f5-da89-4056-a5d9-51a70577af1e	d608d50de426ecdd8e201fc7102d9353aff911a64620adbcecbdac0b4902dcd5	f	2026-11-01 07:37:33.15899+00	2026-10-31 07:37:33.083142+00
fdbddc3c-9795-4d2d-ad01-788dae226c75	617b7b2d-6424-4b9d-9a95-0b2c97d88eae	fc97cfca375fa5aa9a174943a372af67f37886306cd228cf13f900c61dafadba	f	2026-11-01 07:37:33.600178+00	2026-10-31 07:37:33.540809+00
b7393d0d-4773-49ec-b106-7693e579de75	e4783364-7813-465d-ae8d-04a025ea069e	8f518be61934c5745ed65fd7e8486126ec3ad8373ad11e0965a1bf9f2abb53d3	f	2026-11-01 07:38:18.335686+00	2026-10-31 07:38:18.277993+00
c7462755-3392-46c9-81c4-57308997620c	54e697f5-ec86-49d0-a228-a4ce85abf64b	6daac92b92eb6877ab73c1463419eb62bd2055488719f5cf23a65b2b6601acc3	f	2026-11-01 07:38:20.390552+00	2026-10-31 07:38:20.334866+00
8018452d-cf43-41d9-8892-6f25374b483c	83ff8008-a19a-4079-a653-cd9066754e47	6b74f12a0c861c2c1cdbb7cb10950784985f50dc66963e7f2e6e01a23e81ccfc	f	2026-11-01 07:38:20.727645+00	2026-10-31 07:38:20.674165+00
5d890dd6-2766-452f-941a-3114d3cb560d	c6865499-f520-4b3a-bd59-d7ac73da12ae	e134fd5972f50486b470845b1d0e1b42398a9ce6a1ed5fd9edc779f8ac76dc39	f	2026-11-01 07:38:21.004004+00	2026-10-31 07:38:20.947056+00
7a0ff35e-8d3e-4b8b-a5b1-b6041d591978	d9a03e5a-b69a-466c-a629-bd1ae2fc92ee	e64cd91853e77915ecaf54cfc070dffe4dac4007ac3c5be28535e75edd68ef70	f	2026-11-01 07:38:21.361262+00	2026-10-31 07:38:21.289533+00
c3cf08e4-f69b-4ba9-9d6a-86b2b612fa23	84993fe6-4f73-4a8b-955a-f15c1376d1ca	ea384f067848029166b8d9a6d316c2fb7f7ddbec507b80229ae5b644ae0e29b4	f	2026-11-01 07:38:22.148397+00	2026-10-31 07:38:22.092443+00
4b1113c8-a471-4964-8052-f03ee2b770f7	65b91682-558b-4f4c-951d-539434c14ef3	90cb0c4c64ddd95d9be3ae6d16e36240ff7403853224aa5afbc20b2eb42b584b	f	2026-11-01 07:38:22.714942+00	2026-10-31 07:38:22.658939+00
df58aa71-b8e3-4e18-b5e3-ec19286f28bc	af4e9265-bea5-47d4-9c2e-a362271ee196	bfb0c48e113833de5909fcc194598a2a1e863c5ab342b0dda7c6d0cb026fba8b	f	2026-11-01 07:38:22.809436+00	2026-10-31 07:38:22.753581+00
0085c03e-5d4a-4f59-abb4-fca3b7d2d7c4	c22eb824-9d62-4962-8be8-1833cdd8ebdc	b9ffd064b9440e12cde0cbddab50830a93831badabaeb885c5ac8404c9021b96	f	2026-11-01 07:38:23.25021+00	2026-10-31 07:38:23.1962+00
914c86ca-93e6-45cc-9dbd-6de3917c82d6	b52074b1-7721-4486-aeb4-afada943f5cb	ec1181f287bf602ea0f0e1adf94f0cdf7eac6552061289554dff8f20567f4e8f	t	2026-10-31 08:38:30.845281+00	2026-10-31 07:38:30.839246+00
3594d205-19c4-491e-bf11-1607d58c869b	34f73287-5b8b-4edb-ab26-59b47bf6a813	cb1ce1c407855788886b45f3c9f71840dc6b9fe81c68c9894e1554cc58d4f53e	t	2026-10-31 08:38:31.188792+00	2026-10-31 07:38:31.183889+00
195fe1a1-9022-46b5-b8b3-a39113ec3327	34f73287-5b8b-4edb-ab26-59b47bf6a813	29cee0d238db6492563d0136eff8027e4f45ab47e16b4b51c50956fb60a2cdc3	f	2026-10-31 08:38:31.231994+00	2026-10-31 07:38:31.227712+00
4a7b89a9-2ae1-448a-8397-f83db36f55fc	fb9db2a2-56bc-409c-aeaf-a5401434e4e0	0230796967bdef93d527753305c24ce50749b66c0b67e48cb9bffdcbdf773fca	f	2026-11-01 07:38:31.566266+00	2026-10-31 07:38:31.508129+00
5eaf40c1-775b-4f24-a0ba-4639da3b0e2f	4fab871e-76a3-44d9-b79f-cfa00204da30	aa533f43371163694e478d77c0263a77a28ed605fa9462c1ad552438a0ab38b7	f	2026-11-01 07:38:32.653516+00	2026-10-31 07:38:32.596675+00
31a17fb9-7ae7-4b87-9ea4-2ef6b9b11384	88f37654-643e-4bd2-9dee-3ca6a2161e0a	24a75caac661dbcc373afad8eb750acb0dadc4c89fab0eb8c5ba06fe9de5a4cf	f	2026-11-01 07:38:34.462302+00	2026-10-31 07:38:34.407562+00
7177e8d5-1346-435a-8575-67ac65de77ed	91efbe36-b71d-42fd-b7c3-e0b6d794f087	8023437e9967773046e61605fd46c286d0b5a4bc5d8006a1797c25442c3009f7	f	2026-11-01 07:38:34.775144+00	2026-10-31 07:38:34.721226+00
b5156590-818d-4cab-88cc-4956b059d9f9	c389cf50-e0a6-4e9d-902d-dbde029ae58a	71635a5df4437aa7063405c736f705cef38b3b93a954599fdcf2fe401e951c58	f	2026-11-01 07:38:35.040354+00	2026-10-31 07:38:34.986736+00
823fd827-8aa3-4f60-9fb4-6044163bba1b	90a4e297-4cad-4ec5-b65f-a0653eff9316	f0928ecd97e36df846093b1ef6f6faff6501f7ae5d614b2eb3557c015bf59f28	f	2026-11-01 07:38:35.37224+00	2026-10-31 07:38:35.316262+00
d76e7aa9-7b49-4a93-a990-fa753722935b	889eda05-ce54-41a7-b84f-f6a34f2875e6	5169f05f2e25cdbb1af58661102a890c26d6c965a4307c8bdc44251dbd5122a1	f	2026-11-01 07:38:36.162769+00	2026-10-31 07:38:36.108204+00
b956c399-7ad1-4bf4-9fa0-cc444e21f172	e33b5e88-21a9-45d1-b952-d136248b7c66	335b47e5437d5ff98696a1e8b86b2a8de3e1e32693b863f970b78ea034648da8	f	2026-11-01 07:38:36.782435+00	2026-10-31 07:38:36.728894+00
7a23ac66-c46e-4817-9fc3-f359c95f9d02	6f4196d9-dfc0-4b52-a861-f008e3abf5d1	0240f482812efff20f952f00b142190604d389b9f397cfc81f4480e15406c75e	f	2026-11-01 07:38:36.870702+00	2026-10-31 07:38:36.8174+00
8b33243e-16d8-4673-bd01-95caae202d8c	9d8e82ae-c214-4448-905b-a63fdf530a27	77be9c4d1ddd8da2c62c67c1c7f7dc1602e4178e598cd5d58a287e87f683f2ef	f	2026-11-01 07:38:37.296683+00	2026-10-31 07:38:37.240809+00
d5c963f4-9863-487d-adcb-73a9a2b8e851	aff0484e-01ce-4d30-b1e8-4912a70980ff	74b8d851f870d6f52e01438a64e7f13aa7c5ae786242e9f480ae58677aa8529c	f	2026-11-01 07:38:38.355117+00	2026-10-31 07:38:38.300921+00
a479e71f-ba59-4484-a09b-8f442a6d18d0	1a8e2f4a-a11b-4bed-a4ea-d7273cf7836e	80708fc4b02434af7ae784af3535766a731015adea105439c7063888925e37f4	f	2026-11-01 07:38:41.851454+00	2026-10-31 07:38:41.796065+00
257c242f-5777-4c41-9a51-448ac36a17cd	755ecc05-8b2e-4094-b235-d22c1ae31dde	4750a2b1b282116931152d77840f2e0b5e0fd0390bb71e1306e69dbe47c7e748	f	2026-11-01 08:23:57.752968+00	2026-10-31 08:23:57.688377+00
05a8adeb-ada1-4df0-b871-05e799072faf	ebae68dd-3887-4b84-9db4-99d2fbbdb3a2	e6f4ffa749090d2f324458a0ff072bc563f29abf00725d18288fb8cab13c92f4	t	2026-10-31 09:24:07.528296+00	2026-10-31 08:24:07.523773+00
c4cf4628-7dfa-4762-ab4c-65bb01d6c239	234f60f6-3d4d-4c10-80f6-ffe716741112	2116b457c8f301902d142fe5b37b27070d4bdade06353232da3b57d8b012933f	t	2026-10-31 09:24:07.94232+00	2026-10-31 08:24:07.937592+00
1452b152-af6c-4d7d-a3a7-2d3503f33649	234f60f6-3d4d-4c10-80f6-ffe716741112	d30576a8ec0df2490f72209d7914ec95e13fac8744a637b49d8b5a999aec2fc5	f	2026-10-31 09:24:07.99787+00	2026-10-31 08:24:07.991879+00
77477a93-b13e-4e0f-a5cd-c93bd243a67a	589b2d88-254a-488c-8a51-2a4d18b192c2	77c370e84fc632a2651829e93f3a7b6052de49cdae1b79912fabea51b2d47547	f	2026-11-01 08:24:09.186533+00	2026-10-31 08:24:09.098736+00
1506c88f-fa77-4cbf-b1b1-93dfbae269ef	5298e1ce-ccb5-43ae-8827-e4f1b219d6f6	911f2e4c8a6ddafb9e812f7d9121751c99c8d84acb598a3f9cb49a80248e19ce	f	2026-11-01 08:24:09.792626+00	2026-10-31 08:24:09.709897+00
07ca6f15-bf6a-4de5-836b-539bd211a5db	f74ba7a3-179b-484c-ac47-f96d0e199cdb	747fcc4d3071c7d2c3c67fa4dfd3cfbedf92855048bf66571e5bfdc52d6be855	f	2026-11-01 08:24:11.140947+00	2026-10-31 08:24:11.075402+00
8aad9599-e271-4806-9c8f-04ba0f1f27c2	4f043cb7-ad10-4a07-8093-4a7e81edcc1c	427fc11ffcdce3af0a44a44edef8951593d8d51ba4375032d6b6925c0b58155b	f	2026-11-01 08:24:13.394536+00	2026-10-31 08:24:13.328596+00
fb5f42d5-67e0-4a84-8755-61bb02854c7c	d478a015-b108-49b2-86ea-6f6f31ec31c6	8a7b543bf592e2b9f7e7cf7368adfe8789e23dcfa18d9deecd97c3bb2ca3eedb	f	2026-11-01 08:24:13.736974+00	2026-10-31 08:24:13.677608+00
7daf4771-a4b2-4596-bfe6-96aeb19f0146	bff68c14-6701-4be2-8a60-ba9d40b78c05	ff74fa59e8af122a81c1036dd550bdea56fe7b773f04101257fb494bc68c4aff	f	2026-11-01 08:24:14.054383+00	2026-10-31 08:24:13.985849+00
ef3e2ff9-1e6f-4cc1-9128-560f17178e38	78d99fdc-1cd2-4bc3-be11-c53f8128703d	e9e7cafa1a2e4d37d461efb98305627dd84a9cbe8efd3c500a9a6bc296702c7b	f	2026-11-01 08:24:14.437625+00	2026-10-31 08:24:14.381543+00
f0e88375-af74-44f4-ba9f-96d5726d7744	261631bd-d1cf-446a-9f07-5b60a4dc8aaa	5d565ef3ce672bf827f47a69c9d894d534423665c2cd5b85b57aa417079cd000	f	2026-11-01 08:24:15.350222+00	2026-10-31 08:24:15.282126+00
d6497026-1988-4c68-a9a9-e847aeee1fba	98cd3f6e-4144-4803-8bed-4f58edc93bfc	2fc60754f68bfce3aba04a812383860ec63fe14ee20e46861e6512d67e09f672	f	2026-11-01 08:24:16.238852+00	2026-10-31 08:24:16.16648+00
f44fbcb8-2077-4e13-9b4d-acb331b95805	e5f4628a-254f-4743-900d-c4c5848dc4c5	f32744620113b1895b45187969c31d96d4ef71058d0a85bda6236d0ad797d687	f	2026-11-01 08:24:16.341187+00	2026-10-31 08:24:16.282343+00
7eedfe59-710c-4797-9b56-3298e23a7a0c	9c032f6d-4d9c-49c6-be87-6f45c6528780	da24665c64fdadb32692a9129df50e4fa926c103b710aa94b0570545ec5fe83a	f	2026-11-01 08:24:16.820259+00	2026-10-31 08:24:16.755764+00
ecf02de0-365b-4347-acf8-f77cc9a6de42	580e2b4f-9f9e-4b88-9f6d-bd0e4e68b826	19baa2f4d6a99fce90ca0de330fd17a70fecd7aaaa624e712ab28d6aed2fb789	f	2026-11-01 08:24:17.936025+00	2026-10-31 08:24:17.878602+00
7102ea7f-147b-4977-86a3-2d2d0db28d8a	9535692d-19c4-45bb-ab16-3053ea78719a	b3cb4d100520c7b79485d6878436a771893979867a838e3f225a902e35acd6dd	f	2026-11-01 08:24:21.454723+00	2026-10-31 08:24:21.397201+00
4ec45440-d622-410d-9d27-2f529702caea	d5006a51-cf62-44de-84be-7524ddd06dca	b7611950a5254f2bf54545c049c702c66fddb50f14937a34b8bfdfab85349fb8	f	2026-11-01 08:27:24.675599+00	2026-10-31 08:27:24.62056+00
bb9949db-4a45-4ff7-abb3-86bd8cc15fa8	886216f8-3ff4-4384-aa44-ea5894745b0a	f057b5f211314ffb74608c40822d65f55315cb5a8a3d57e0476d00f4f600c68c	t	2026-10-31 09:27:35.029263+00	2026-10-31 08:27:35.024792+00
f8a475d9-0909-4afe-a14d-4bbd52c4aeb2	fa542889-8820-45e9-b9f8-b63d3f0e47b2	b69c6d7c0d8bf5904015260de668b34f43f34359f991e4f492eaad2f64cd48cf	t	2026-10-31 09:27:35.400294+00	2026-10-31 08:27:35.395646+00
15cd8522-a8c0-4c33-9b9c-d92cf5611bd2	fa542889-8820-45e9-b9f8-b63d3f0e47b2	1a6fa4b80be92e2b726c14bf18283b13f42b3b2fa8c07cb07789f2b1fa5505d2	f	2026-10-31 09:27:35.452102+00	2026-10-31 08:27:35.447263+00
56cd5828-af45-4bd6-984a-9c3e5fec7f99	24c18ecd-5b5c-4e89-bcfd-91e486f86851	a729adf38ebacf99c1a8f75ebcb1513d7480ba8ae961efcef8c429c3272c7ffa	f	2026-11-01 08:27:36.461279+00	2026-10-31 08:27:36.402007+00
da275121-293b-47c9-80f2-e8ebfdb5ec06	ec4aa706-03aa-4329-9b47-90b7b9a86ec2	e3ae7f3598dfa1fd3aee870318ceea9efd2ca151f3dddbd644ea3fd16875f1f2	f	2026-11-01 08:27:36.949117+00	2026-10-31 08:27:36.892126+00
f933f1cf-d348-4db6-bd6e-737a8791b89d	1956e56e-40e0-4306-a5e0-4750074e63fe	5ce8a1521107d3a3237c28c7b07d48cb50238aff556bd057069722776aa5839e	f	2026-11-01 08:27:38.004435+00	2026-10-31 08:27:37.942867+00
dd69fa64-3a0a-43b5-9f8c-dceeefcb896d	a6d97da7-0272-4a4d-a204-35eb9ad005b9	225012435631c1156970cc0a6c4514912d5b83028c1472bdcc91d43f7273c0d2	f	2026-11-01 08:27:39.822556+00	2026-10-31 08:27:39.766737+00
dafe1807-5687-443d-a72f-58d1ed54ccd6	2a81070c-8c42-427f-a85f-acec791d68c1	015f52001a99edf96378459b01bbf4d91a120df64cb915b15f4b9c7f18e7f75b	f	2026-11-01 08:27:40.136129+00	2026-10-31 08:27:40.078875+00
176959cd-a230-47b6-a6c1-22dfad440a11	b6200e86-7dad-4a30-8a00-f4b3254675f0	baeace5ed6bd1c7ed6b9684ae9e708fabbe2bce1aabe64da591e2ae43d76a1a1	f	2026-11-01 08:27:40.531006+00	2026-10-31 08:27:40.465799+00
07e4585d-0623-4a05-9698-a849fdab5581	797544bf-e529-45a2-9ecf-d7135e0f3001	92298826aad3334af55920e04620fd3f5f2654bad4a10841be64f2c73cf9c2aa	f	2026-11-01 08:27:40.917589+00	2026-10-31 08:27:40.856128+00
3055d020-ba6d-4684-b56a-dc630be6e11a	7586397c-7be1-4012-a3a4-6f30cffef43b	96d543355e4d3f181f22431d635083c8e6191f3eaed4ae10ef87c86db9a1058a	f	2026-11-01 08:27:41.681046+00	2026-10-31 08:27:41.624239+00
7a037c19-18c6-4006-800d-29532516c4c2	82fd49ba-17d2-4965-86ca-0153fb0187c2	29d8d8a3bf8c1d5f056d37849534bf5cfb6441585fa1844971c08d1b26502acf	f	2026-11-01 08:27:42.228613+00	2026-10-31 08:27:42.167737+00
89a2f7aa-dcf6-4fa5-b5d8-7316cdf6c462	2db433b5-9f80-4d01-931e-b71e9b09a7ce	5cf9618365c6076469d670544ee934d9c3cbc4b31cc5486b3fc2a6c36811d5de	f	2026-11-01 08:27:42.325156+00	2026-10-31 08:27:42.266133+00
9326b20a-1bc7-42f9-a524-b0741059d8a5	2104ced0-8801-4857-a65b-b8eadb85f3b7	74aa77d4fc6864f4fde74e829316dea091fc8b3d86a1e8d0d53a818367751f67	f	2026-11-01 08:27:42.773609+00	2026-10-31 08:27:42.710446+00
f94aa49d-61ff-4604-bc27-6496c56b7840	4c56d2a2-7933-4bf8-b48e-e24352635408	9ca0efa38e821766d8de8de76897bb38102d3c7af0d4ea4166eac6b300dbb238	f	2026-11-01 08:27:43.937665+00	2026-10-31 08:27:43.878779+00
3435f0b1-625e-4d71-96e4-fb8681fe5078	5dab76e6-0337-4d2b-a840-03d3051a6ec6	cf4dc8b86d46175adde5fb6464a3583f741969be80cc843e4770999a87ba491c	f	2026-11-01 08:27:47.466607+00	2026-10-31 08:27:47.411212+00
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: brightloop_user
--

COPY public.payments (id, payment_number, invoice_id, customer_id, amount, currency, payment_method, payment_date, reference_number, notes, recorded_by_id, created_at) FROM stdin;
dd9e5f2f-e36d-45f8-86f2-2d41d3df1458	PAY-202610-0001	c8a257fd-b794-4423-84f9-59a2ff027466	d8aba305-385d-4f8c-abcd-ee4db0e52f4d	1000.0000	INR	UPI	2026-10-31 07:01:39.676814+00	UPI-PART-1	\N	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:01:39.578634+00
c478f047-1aaf-40ce-acb7-827884ce7506	PAY-202610-0002	c8a257fd-b794-4423-84f9-59a2ff027466	d8aba305-385d-4f8c-abcd-ee4db0e52f4d	1360.0000	INR	BANK_TRANSFER	2026-10-31 07:01:40.152685+00	NEFT-FINAL-2	\N	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:01:40.011002+00
d949664f-78a8-45ae-b811-2bb1e1115093	PAY-202610-0003	6ca8252d-9d7c-4a93-b23b-b81acade770e	20de22c3-c73e-40d3-bc37-9cf9b129a783	1000.0000	INR	UPI	2026-10-31 07:24:19.984109+00	UPI-PART-1	\N	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:24:19.885648+00
56d4e791-57ea-4546-9354-12208df0b054	PAY-202610-0004	6ca8252d-9d7c-4a93-b23b-b81acade770e	20de22c3-c73e-40d3-bc37-9cf9b129a783	1360.0000	INR	BANK_TRANSFER	2026-10-31 07:24:20.439084+00	NEFT-FINAL-2	\N	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:24:20.308171+00
23af4ff8-29fe-4090-a7cf-1ac030ac6af5	PAY-202610-0005	c22ea219-4c7d-4125-a575-f217346e48ec	0bbc71dc-0eda-419a-88a5-03fb4ff39b6b	141600.0000	INR	BANK_TRANSFER	2026-10-21 07:33:24.877413+00	HDFC-RTGS-992144-TCS	Settlement received via RTGS	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:33:24.444528+00
5e7140a6-17d0-46e0-93c6-8e8e90e3dc9a	PAY-202610-0006	1346cc70-fc94-44e1-a3b2-624c05cff912	c35f47e5-0366-411b-81af-49b909c51fbc	10000.0000	INR	CREDIT_CARD	2026-10-29 07:33:24.877413+00	RZP-CC-ZOMATO-PARTIAL	Initial card authorization payment	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:33:24.444528+00
f2525ae1-1bb0-4094-9ed1-e84cf9e07761	PAY-202610-0007	27881d41-b173-47f6-8e0c-3ec728bdec01	d1ad1940-cda3-43d9-8725-9af55aabf801	20000.0000	INR	BANK_TRANSFER	2026-10-31 07:37:29.478344+00	RTGS-3a32a8-1	First milestone payment	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:29.885189+00
4d77293b-522b-45fd-91ee-feba1b7d50f8	PAY-202610-0008	27881d41-b173-47f6-8e0c-3ec728bdec01	d1ad1940-cda3-43d9-8725-9af55aabf801	39000.0000	INR	CREDIT_CARD	2026-10-31 07:37:29.478344+00	CC-3a32a8-2	Final settlement	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:30.32658+00
a54305b9-52ff-45ab-86c5-1af3907b2382	PAY-202610-0009	f045f94c-d267-4dfe-a757-a867da47d824	ad1f6972-67c1-4b0b-a015-ba3aea186bc9	20000.0000	INR	BANK_TRANSFER	2026-10-31 07:38:18.541645+00	RTGS-2c1132-1	First milestone payment	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:18.923305+00
e662361e-cd4a-43f2-927c-e171c60666b0	PAY-202610-0010	f045f94c-d267-4dfe-a757-a867da47d824	ad1f6972-67c1-4b0b-a015-ba3aea186bc9	39000.0000	INR	CREDIT_CARD	2026-10-31 07:38:18.541645+00	CC-2c1132-2	Final settlement	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:19.395995+00
0f5b434f-bfad-44a2-a8e2-8c533e4b4da1	PAY-202610-0011	0aab8183-061d-420f-94f8-28ccb3787387	eb64f133-dafc-418f-8f4a-90e9dbc9cdcb	590.0000	INR	BANK_TRANSFER	2026-10-31 07:38:23.697658+00	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:23.596007+00
88722456-b85a-4c6d-9612-2a0b88525425	PAY-202610-0012	153907e7-11b5-4b59-bff6-74e65a43799a	b9ba2119-ac8a-4bf5-85ff-889e7efba0d6	20000.0000	INR	BANK_TRANSFER	2026-10-31 07:38:32.833159+00	RTGS-4492ce-1	First milestone payment	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:33.187334+00
ce557445-cab9-4ed6-88e0-0f6f628ebd2d	PAY-202610-0013	153907e7-11b5-4b59-bff6-74e65a43799a	b9ba2119-ac8a-4bf5-85ff-889e7efba0d6	39000.0000	INR	CREDIT_CARD	2026-10-31 07:38:32.833159+00	CC-4492ce-2	Final settlement	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:33.622729+00
4206fd6f-01c7-4917-9334-8cc479280b8e	PAY-202610-0014	5324b6db-b19a-45b5-a2d0-9747f4fa1597	cb06e29c-acf5-4d8e-9b97-91a250b6b4d8	590.0000	INR	BANK_TRANSFER	2026-10-31 07:38:37.769494+00	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:37.656834+00
16ea77b9-f232-4fd2-9cbc-fab74c4cbe21	PAY-202610-0015	9796d144-f65d-43e5-91cb-f5f5420c1cef	4f3ec259-43da-4e7a-8316-22a71e23d0db	1000.0000	INR	UPI	2026-10-31 07:38:38.930747+00	UPI-PART-1	\N	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:38:38.829944+00
2e2c12bb-bbda-4a23-bac9-ae415d598d3a	PAY-202610-0016	9796d144-f65d-43e5-91cb-f5f5420c1cef	4f3ec259-43da-4e7a-8316-22a71e23d0db	1360.0000	INR	BANK_TRANSFER	2026-10-31 07:38:39.357903+00	NEFT-FINAL-2	\N	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:38:39.199716+00
811bc1b6-5056-49b3-b39d-15c5c29d7379	PAY-202610-0017	4655f402-97bb-4f99-8409-66dd3fb31826	bca5e35f-ed0e-4e3c-a57f-eb24c360a6fb	20000.0000	INR	BANK_TRANSFER	2026-10-31 08:24:11.350081+00	RTGS-8ebd0b-1	First milestone payment	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:11.756752+00
514bdbfa-0f76-4f18-8811-9eac1d42dc54	PAY-202610-0018	4655f402-97bb-4f99-8409-66dd3fb31826	bca5e35f-ed0e-4e3c-a57f-eb24c360a6fb	39000.0000	INR	CREDIT_CARD	2026-10-31 08:24:11.350081+00	CC-8ebd0b-2	Final settlement	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:12.46962+00
c36f1400-387b-4432-9001-6e62ae343bb3	PAY-202610-0019	a38ddb73-7a1e-4e90-b394-39a597c03588	ef262998-7f20-45f5-bed3-ac7a7de9c250	590.0000	INR	BANK_TRANSFER	2026-10-31 08:24:17.317064+00	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:17.17587+00
2f6cb0a0-b66d-4911-a1fd-d9f9fc6146b3	PAY-202610-0020	397b784d-7ee3-465d-8c49-92313e63407c	f4256ea5-779c-448a-b1fb-6a98398d127c	1000.0000	INR	UPI	2026-10-31 08:24:18.557144+00	UPI-PART-1	\N	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:24:18.4432+00
6d426c1f-1dc0-42d0-a527-e771c0adbfef	PAY-202610-0021	397b784d-7ee3-465d-8c49-92313e63407c	f4256ea5-779c-448a-b1fb-6a98398d127c	1360.0000	INR	BANK_TRANSFER	2026-10-31 08:24:19.065123+00	NEFT-FINAL-2	\N	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:24:18.900848+00
8740cf5c-bed4-4350-a87f-992866650173	PAY-202610-0022	a6fb2feb-91a4-40e8-a929-493ad3c51655	e86d89d3-0129-4b78-af76-2534ca7c0dce	20000.0000	INR	BANK_TRANSFER	2026-10-31 08:27:38.183028+00	RTGS-7b522b-1	First milestone payment	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:38.53764+00
0f698ea0-464b-44a8-9bcd-577875e460a8	PAY-202610-0023	a6fb2feb-91a4-40e8-a929-493ad3c51655	e86d89d3-0129-4b78-af76-2534ca7c0dce	39000.0000	INR	CREDIT_CARD	2026-10-31 08:27:38.183028+00	CC-7b522b-2	Final settlement	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:38.997464+00
d7113a12-61c0-48e3-9b55-150e6bf45414	PAY-202610-0024	dfd42561-82ce-4356-944a-1f33180471d6	d69a4475-31c3-44f8-b77e-8fce5e1c05df	590.0000	INR	BANK_TRANSFER	2026-10-31 08:27:43.25708+00	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:43.148216+00
f73325f1-5f2a-4200-8c1e-5740b947efa4	PAY-202610-0025	64641d8f-1b99-44f9-9459-8c7d1acfba03	a5ecc61e-3478-4aac-9c83-7493ce661f9f	1000.0000	INR	UPI	2026-10-31 08:27:44.524525+00	UPI-PART-1	\N	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:27:44.411196+00
89c880fa-f752-4b05-b6d2-38b1993228b2	PAY-202610-0026	64641d8f-1b99-44f9-9459-8c7d1acfba03	a5ecc61e-3478-4aac-9c83-7493ce661f9f	1360.0000	INR	BANK_TRANSFER	2026-10-31 08:27:44.961665+00	NEFT-FINAL-2	\N	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:27:44.813299+00
\.


--
-- Data for Name: plan_products; Type: TABLE DATA; Schema: public; Owner: brightloop_user
--

COPY public.plan_products (id, plan_id, product_id, variant_id, default_quantity, is_optional, price_override, is_active, created_at, updated_at) FROM stdin;
2ac5a489-4d8b-4b58-a126-f9f4bfc54a4a	e305ebea-d9ab-41f3-8ef1-9223230f0c71	6ef0bb02-187d-4513-9122-eaa480de77bf	\N	2	f	\N	t	2026-10-31 06:11:29.928487+00	2026-10-31 06:11:29.928487+00
2eb221c6-f071-4a0b-bad0-9d8fbe7047f9	82427998-6488-45c4-9bc0-6a9582a2a880	969a867e-b20a-4c5f-b1b5-f0cfe67a5bb1	\N	1	f	\N	t	2026-10-31 06:11:30.12249+00	2026-10-31 06:11:30.12249+00
f729e0a0-db6c-48d3-8cda-86d5874c82b9	306fc9ef-de46-4c3f-9bee-4ed48d306cca	688622e3-2494-4fde-90d4-78107b647e2e	\N	1	f	\N	t	2026-10-31 06:11:30.412308+00	2026-10-31 06:11:30.412308+00
569f9d4c-d6ca-4810-8ea7-6ce5409e2318	3ff1e4cf-d506-4b90-a393-887d66a2a495	861ae7ab-d090-419b-9955-d4663145fc15	\N	2	f	\N	t	2026-10-31 06:12:59.769469+00	2026-10-31 06:12:59.769469+00
0e9850ad-e661-4317-bdfd-40ad2aae4f52	48c8dd02-1258-4513-b665-f8726f987084	04e41d81-94e0-4b86-a71b-db756e3f224c	\N	1	f	\N	t	2026-10-31 06:12:59.890477+00	2026-10-31 06:12:59.890477+00
55faf586-219f-4c07-9c61-61cfc3eca542	7bdc7075-09f4-4d9b-8738-14587dae6430	79144eb3-21f8-490f-bd46-ac454693355f	\N	1	f	\N	t	2026-10-31 06:13:00.110556+00	2026-10-31 06:13:00.110556+00
9055c4fd-dd13-4e3a-bada-be34cbcf5649	52c160f2-a7b8-4c40-b4c3-ff13e513fd07	0399f8a6-2a2e-4fe4-aab1-c06d51fc6f84	\N	2	f	\N	t	2026-10-31 06:13:21.038291+00	2026-10-31 06:13:21.038291+00
cecceb9c-61dd-46ba-afd7-d524457eadf5	6e16e0be-7a50-4e8e-9ac6-f1675ac37aa2	63e331fa-ccfe-48a4-99a2-71cd3d362192	\N	1	f	\N	t	2026-10-31 06:13:21.16259+00	2026-10-31 06:13:21.16259+00
b2f78f17-1c9a-47f7-b19b-5fcc29571994	17cdbc0c-02c6-4db1-979a-761060e6fbf4	a73fe521-614b-4045-b1fa-6cbb5b177ec1	\N	1	f	\N	t	2026-10-31 06:13:21.380174+00	2026-10-31 06:13:21.380174+00
a0c8ca3c-7a52-4329-aa48-c16eb76770af	58e5db85-a522-4c2e-ae0e-7c59bb12a005	358dac3d-dac5-49aa-aa87-02e1382ee3bb	\N	2	f	\N	t	2026-10-31 06:13:50.985053+00	2026-10-31 06:13:50.985053+00
641ecf9e-5636-448f-a58a-06da42e3a7bb	0dc7b634-cf11-4b86-8fe2-865f1569dcfc	e76fe912-75c8-45d2-9051-5d5cc3dd8f1e	\N	1	f	\N	t	2026-10-31 06:13:51.099261+00	2026-10-31 06:13:51.099261+00
56c254f0-c093-4336-acf0-e26063f8fac0	5e11e3c1-5e4b-4960-a35a-34e971d57feb	6fa297e4-67e6-4d76-9c5c-c502ecf1ea18	\N	1	f	\N	t	2026-10-31 06:13:51.330111+00	2026-10-31 06:13:51.330111+00
722147e3-e10f-43e7-b4a4-fa9e7c73a157	4924ebc4-0f98-4df0-9e71-1b0144dc2977	1f9dfc87-7c86-463e-b39c-02772e22a98a	\N	2	f	\N	t	2026-10-31 06:26:02.539256+00	2026-10-31 06:26:02.539256+00
0992c14e-749a-4d73-8519-279211e53f41	d02c1550-ee4a-4624-b566-2bc4a408805f	d5bbca6b-8ff8-4282-9156-303ae81f081d	\N	1	f	\N	t	2026-10-31 06:26:02.659572+00	2026-10-31 06:26:02.659572+00
456b7d87-c926-4ae1-a1c9-3348ada4453c	d9308bf5-9a8f-4597-9075-f8888ea04a22	2a6ac91d-0ff8-4157-80a7-5f3426f49ad3	\N	1	f	\N	t	2026-10-31 06:26:02.86143+00	2026-10-31 06:26:02.86143+00
1791a596-9a2d-47f9-99bb-ed45a9489ba5	43272446-ad12-47cd-aa6a-fde3a345a0f5	1f276a0d-edd6-453c-ae2b-47c28fb3eb96	\N	2	f	\N	t	2026-10-31 06:56:46.411915+00	2026-10-31 06:56:46.411915+00
496e07c4-5db3-4f73-b1c5-ea20e694da05	b449504e-ff50-451d-9d99-f4409ca41c79	8194a38c-c919-47f3-88d2-e11ad42b8d01	\N	1	f	\N	t	2026-10-31 06:56:46.536079+00	2026-10-31 06:56:46.536079+00
d4d664e7-9d5c-4190-9178-30838f080378	5350071d-5afd-48a9-aa83-2d2935ab73f9	2753c50b-661b-4631-ba1f-0e4cb7c3bcea	\N	1	f	\N	t	2026-10-31 06:56:46.767305+00	2026-10-31 06:56:46.767305+00
89e53b25-16d2-4096-b4d6-2333d6b1cb93	2ca2f32b-f68e-48e7-9c09-4baf61d9398f	27c92d51-b12b-4c5e-b05a-4bb416e31ea4	\N	1	f	\N	t	2026-10-31 06:57:56.751532+00	2026-10-31 06:57:56.751532+00
4a7471fc-bd4e-4068-9944-4e3e52b523c8	9b79b0a2-506a-4c3b-b87b-119f948e2ac8	26f84f34-1499-418a-96e0-bc6600944e48	\N	2	f	\N	t	2026-10-31 06:57:57.082845+00	2026-10-31 06:57:57.082845+00
168cf881-a76d-4ed3-a850-6e58c5332461	42f65e61-0335-4f69-8bf9-ed8ef63465e5	d83d7b84-4d47-426e-8b1b-b7e3a99a02d3	\N	1	f	\N	t	2026-10-31 06:57:57.224605+00	2026-10-31 06:57:57.224605+00
9ae74e23-8700-432f-adaf-29e422c958dd	777c8b66-be1d-4560-87e3-289d56a3fece	2641368d-ece5-41b8-98d6-50367dafc985	\N	1	f	\N	t	2026-10-31 06:57:57.447869+00	2026-10-31 06:57:57.447869+00
7aa45ea7-75a3-4c43-8de5-8b6c5d6b0af2	c6186b0e-5ace-4203-a620-1231bb6a822c	56739bff-c037-4087-95b3-bb4c35c05732	\N	2	f	4500.0000	t	2026-10-31 06:57:58.90483+00	2026-10-31 06:57:58.90483+00
0fa49024-26ba-4446-818f-5dff6775191d	de9962cf-ac9f-4f88-80c8-1cdac851d647	ec449749-6f32-41e4-ac37-bcfcdffb15aa	\N	1	f	\N	t	2026-10-31 07:01:03.29679+00	2026-10-31 07:01:03.29679+00
6f169605-ba28-4932-9c72-739573c38bb4	117a6864-250c-43d3-be06-27ba2f039e5c	1a7b37b3-13b2-47a3-ad9e-59476f54fde4	\N	2	f	\N	t	2026-10-31 07:01:03.691969+00	2026-10-31 07:01:03.691969+00
0d69dfc9-061a-46d1-8a78-e10c1facbd7e	41ef282a-db52-430a-b1e6-edf0491923c6	aec1dd88-b055-432e-b06e-f5ff5c1b646d	\N	1	f	\N	t	2026-10-31 07:01:03.818133+00	2026-10-31 07:01:03.818133+00
e9f5a570-4b9e-48a3-adec-9f8153195180	611849fd-1a00-42b7-b8dd-1c5a045efb2d	4ba0da92-15b8-40b9-b909-6d56804c20a5	\N	1	f	\N	t	2026-10-31 07:01:04.041625+00	2026-10-31 07:01:04.041625+00
f240fbd5-8eb0-4715-8cc6-3684178d1760	de14b5ef-30b4-4c34-9855-9f041f222fcb	dda6994b-3b5c-468d-817c-fe2a53ce5ec3	\N	2	f	4500.0000	t	2026-10-31 07:01:05.45331+00	2026-10-31 07:01:05.45331+00
daa8e84a-3b70-46b5-9bd7-e61e04129b30	55293743-248d-46b3-88bf-847e5bf20636	cd07bdd3-8925-4e1c-8754-a33b7b02246c	\N	1	f	\N	t	2026-10-31 07:01:38.937475+00	2026-10-31 07:01:38.937475+00
587a0d01-5857-49fc-875b-a02c541fa827	606b3af1-65ff-488b-b8f8-e4bc196f57c5	854ebbc5-1efb-41a4-8fa2-16cf3c26a41b	\N	2	f	\N	t	2026-10-31 07:01:40.652859+00	2026-10-31 07:01:40.652859+00
26df45e7-0252-43e6-9a5e-7a65d6e1acc5	e4dc4e54-8377-4cb3-b7de-aa68603f1056	feaed8df-addd-425d-9ed2-ecfaf1340189	\N	1	f	\N	t	2026-10-31 07:01:40.777586+00	2026-10-31 07:01:40.777586+00
1b80d1b5-9540-45e4-85c7-600ac98bed1f	3a2519e1-04b4-44b0-acd4-0d6e123c3b30	5d320af8-6a44-4f17-a7b2-33fc4de8fc75	\N	1	f	\N	t	2026-10-31 07:01:41.040091+00	2026-10-31 07:01:41.040091+00
d786e9d7-2d45-40b8-b8e4-fb02c2564694	2cf2f096-5052-4398-9a1f-f75a93f0df4b	c48f1d45-bed4-411a-a422-daed07f89681	\N	2	f	4500.0000	t	2026-10-31 07:01:42.437075+00	2026-10-31 07:01:42.437075+00
569dd5f9-0d48-4f9e-bb6c-c4ddda81f7a2	4681a3b4-7b93-4d9a-849e-224f0b310797	edbb467f-ee59-4f31-94aa-588b436d4eaa	\N	1	f	\N	t	2026-10-31 07:24:19.192396+00	2026-10-31 07:24:19.192396+00
9e1ec54b-1839-4b68-809f-186cb406b380	1baded46-0fe4-44d5-a732-857b80b1d55d	8e39b9d6-f2be-477f-89b8-2d6840dc802b	\N	2	f	\N	t	2026-10-31 07:24:20.930568+00	2026-10-31 07:24:20.930568+00
ed8134fd-d432-49e9-9c02-86480e2b0dc8	6c7f0f09-2321-4b2b-b692-7e79692d4079	23cb2b12-e720-4012-b44a-98da5b5c9b9d	\N	1	f	\N	t	2026-10-31 07:24:21.058573+00	2026-10-31 07:24:21.058573+00
675da539-2b44-43e5-9619-4c770234f9db	72870f5f-71f6-4347-a85c-b49987b29213	d04c4ec8-e918-490e-8571-b56018b0c3ca	\N	1	f	\N	t	2026-10-31 07:24:21.283174+00	2026-10-31 07:24:21.283174+00
1e04434b-84d5-48db-96c4-2a14f7f2f768	c6243761-457c-4c31-bace-512802fd0015	37387601-cec8-4c66-b427-84f6104b528c	\N	2	f	4500.0000	t	2026-10-31 07:24:22.687225+00	2026-10-31 07:24:22.687225+00
8936a88a-e1f7-464c-ab7c-778710cabe99	d384f73d-e895-4459-ab35-677aa5b24362	186b4bbe-6fca-4f10-8817-a4b71efd0762	\N	1	f	60000.0000	t	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
f23cdfaa-84a7-486a-b1ee-b3e3c11ae74b	d384f73d-e895-4459-ab35-677aa5b24362	48db2113-98c2-44bb-8fb5-491a6e75ddfd	\N	1	f	35000.0000	t	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
abbe3ec1-4793-4067-b22f-e8b99652daa8	d384f73d-e895-4459-ab35-677aa5b24362	ebc4abad-f5e7-4644-9567-8d7fdad06fd4	\N	1	f	25000.0000	t	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
1ffe3ff4-bb36-4bd9-99ce-080ca735a7d5	c74c2965-322c-4f1c-b764-71a5d895d2d8	186b4bbe-6fca-4f10-8817-a4b71efd0762	\N	1	f	15000.0000	t	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
01b289a5-ff28-40ec-a1d7-ece1a3cca8f4	6900679d-5caa-4a5f-a0fa-4e68c86687a6	942c213b-7840-4549-aa89-94c83ee4842a	\N	1	f	\N	t	2026-10-31 07:35:20.652287+00	2026-10-31 07:35:20.652287+00
ea31d072-04e8-4301-b8da-9a0221dfc1b7	242a449a-f506-45e7-a7d6-1c8d482c3eca	401ad69d-e929-4555-87ce-ff5b306799a8	\N	2	f	\N	t	2026-10-31 07:35:21.16598+00	2026-10-31 07:35:21.16598+00
615a72f2-dcdd-49f7-bd52-f9d13da74e0d	5a6f8220-4f8c-4192-a679-dae3a6888a01	77f7a1a1-923b-4307-b433-b3653d77faf2	\N	1	f	\N	t	2026-10-31 07:35:21.775526+00	2026-10-31 07:35:21.775526+00
bcf964cb-e8a6-4ecb-9188-5f5ffcb1376e	85463b60-e094-4575-9c20-02f2bd715080	ddac571a-50c8-46a7-aae6-c9699a912456	\N	1	f	\N	t	2026-10-31 07:35:22.293963+00	2026-10-31 07:35:22.293963+00
f5236551-01cc-4312-823b-8a44c76df0b5	092e3a0c-9bd7-4bf4-98cd-c6bd89bf06c6	996e7e31-9bc8-4564-9457-8ca7927dfb84	\N	1	f	\N	t	2026-10-31 07:35:22.908608+00	2026-10-31 07:35:22.908608+00
40fee025-2a17-4ad4-8072-ccf0d38e18f6	fa4315a7-89d6-4aec-906e-eaceb128d2ab	39e2f841-cf98-4c62-809a-d941b1637c23	\N	1	f	\N	t	2026-10-31 07:37:29.406964+00	2026-10-31 07:37:29.406964+00
b335c2f3-f424-438f-979a-27db5f7e1740	5d83f931-1a37-489f-88f1-b646f5e30693	62d13717-1a0d-4a1d-b4fd-71cf741c8ba5	\N	2	f	\N	t	2026-10-31 07:37:31.425238+00	2026-10-31 07:37:31.425238+00
f16875ac-edfa-4e5b-ab6a-6e899ce16a93	0a961d0a-af94-4712-9de1-331c2f043343	683a33cf-43e1-4b69-adc0-50512d118c91	\N	1	f	\N	t	2026-10-31 07:37:32.020103+00	2026-10-31 07:37:32.020103+00
9a7daab5-ed27-451d-841f-0b1b7d1d8705	497e8a79-6474-4c05-ae8f-c3504448bcc6	b37d638a-f942-49d6-8e03-68859649bc3a	\N	1	f	\N	t	2026-10-31 07:37:32.580922+00	2026-10-31 07:37:32.580922+00
b17fc25b-9115-49c0-bff3-25c499177ca9	7d53651d-4f7a-4d08-ae20-255e14608dac	a1eae06d-1777-4cb6-b063-6a2580b8a280	\N	1	f	\N	t	2026-10-31 07:37:33.470954+00	2026-10-31 07:37:33.470954+00
95db978a-a612-4ac5-96d3-6b9c497138ad	e84fb213-7803-4a33-90c7-62ac22c16ae7	53b00a01-c903-4f64-9e72-5088c4c0e028	\N	1	f	\N	t	2026-10-31 07:38:18.471727+00	2026-10-31 07:38:18.471727+00
7aef97c0-23ea-4675-97bd-a502c718fd28	dbac552f-2c45-4830-ba3e-84d75d087d53	a98b731e-2a49-4e70-85b8-405fbc73f791	\N	2	f	\N	t	2026-10-31 07:38:20.593899+00	2026-10-31 07:38:20.593899+00
de4cd00e-207f-44c4-9091-8f9c0c362eeb	364ce5b7-24c4-4e38-8370-245fb703bc22	ed0db0d3-c8a8-4bc2-ac69-92b127dcbd38	\N	1	f	\N	t	2026-10-31 07:38:21.21358+00	2026-10-31 07:38:21.21358+00
4c391195-3813-48ba-8f4b-9e84de325bfd	7fdf215f-b7a1-4f77-8a65-3894140e0123	db17cf02-d6b1-4db4-a8e9-5bf25f5a34f1	\N	1	f	\N	t	2026-10-31 07:38:22.019917+00	2026-10-31 07:38:22.019917+00
99be8c90-3d1a-4b57-8908-a17baa74f89f	8aba86b1-d16b-4d9d-bb5f-3aa6e899dfef	650bdf95-c3b6-4a92-955b-9551fb73a316	\N	1	f	\N	t	2026-10-31 07:38:23.126682+00	2026-10-31 07:38:23.126682+00
ecca1741-1162-4954-ad38-e2e75fd113f9	80d48bf7-069c-4120-b281-056deee297dd	7fc3f342-51f1-4164-8bae-dfa344fbf476	\N	1	f	\N	t	2026-10-31 07:38:32.764902+00	2026-10-31 07:38:32.764902+00
5e9bad8f-1986-4c50-84a4-a77c3df039f7	71fc50de-6cd7-44d2-81c6-5e749dee85f0	4f2a6c17-03c3-4515-be61-1269cf0fb4ab	\N	2	f	\N	t	2026-10-31 07:38:34.648373+00	2026-10-31 07:38:34.648373+00
752f1554-8d07-4354-aefe-17ad9c4e9556	71bc4fdd-3710-4983-b791-4d51f05fc06f	8e677bd2-2a28-432f-95eb-337f2b48f1e5	\N	1	f	\N	t	2026-10-31 07:38:35.244351+00	2026-10-31 07:38:35.244351+00
5bb98351-e93b-420e-89e4-0f186cbc3c35	09cd09d4-49bb-445a-a354-dbadde65da9b	c490928c-9a8c-4437-9601-1abebc4075b7	\N	1	f	\N	t	2026-10-31 07:38:36.036448+00	2026-10-31 07:38:36.036448+00
f5c17154-a9af-4627-9d6b-0d5824397ef5	c1898049-e5c0-4876-895c-652b068ef387	5bea6103-3d8f-49c0-b077-370f3e20b856	\N	1	f	\N	t	2026-10-31 07:38:37.164889+00	2026-10-31 07:38:37.164889+00
adabf165-15ac-4b4b-89a8-41454f93b3f3	607f6d79-67ea-4b2a-8264-eae014a615e5	e7f7f3ac-3fa7-4818-b3da-4d643758ecfc	\N	1	f	\N	t	2026-10-31 07:38:38.228827+00	2026-10-31 07:38:38.228827+00
cc6ad884-4520-4584-a76f-3b01331a3759	57fffd3e-9dc2-4994-9203-4f9ede28bca2	7090854b-634c-430b-8251-559ea3b5b470	\N	2	f	\N	t	2026-10-31 07:38:39.934139+00	2026-10-31 07:38:39.934139+00
6fa431c2-9e47-4326-a11d-1c7da2fc4dab	87df6dd3-3156-40d5-a694-5e034f2b21e6	e19e498e-8fbb-4734-9519-84c3a22650c1	\N	1	f	\N	t	2026-10-31 07:38:40.054621+00	2026-10-31 07:38:40.054621+00
b15dda99-1cd9-48f9-b0b4-7742848cd61c	e2e7cde0-2a3a-4e25-ab6a-d281354dbf19	054c67bf-f82b-40c3-9817-1266139fb3ac	\N	1	f	\N	t	2026-10-31 07:38:40.282797+00	2026-10-31 07:38:40.282797+00
7b439a48-968d-4bd5-b799-d7a8b5ae2718	147b0b93-5602-4647-b291-00677cb15235	2758ae3b-77c6-43a1-ae62-0cf0bb304cac	\N	2	f	4500.0000	t	2026-10-31 07:38:41.727266+00	2026-10-31 07:38:41.727266+00
e2ac9ca8-3385-48f6-9087-b6ccf5499f7d	0086d29b-ddd9-4dc5-9ac0-3d74ea38cba4	158c96d4-cbb8-49f2-a7d7-4e828fc64d3e	\N	1	f	\N	t	2026-10-31 08:17:09.727071+00	2026-10-31 08:17:09.727071+00
54808c36-5150-4d39-b442-dee5b34e2859	d5281260-fa65-4500-aa04-21fb2bfdd3cc	158c96d4-cbb8-49f2-a7d7-4e828fc64d3e	\N	1	f	9990.0000	t	2026-10-31 08:17:09.727071+00	2026-10-31 08:17:09.727071+00
389b7817-3a7d-46ea-913f-b256d3de2ee8	ceaa5e9c-c99e-4a47-acd6-f7c9a6583c51	0a3ccc4b-2420-4f5b-b9df-7aaac0ef8f41	\N	1	f	\N	t	2026-10-31 08:17:09.727071+00	2026-10-31 08:17:09.727071+00
490a67a7-0c45-47f8-b5c0-c308d2646d99	859f0f9d-a947-453c-83cc-3df6adea52dc	0a3ccc4b-2420-4f5b-b9df-7aaac0ef8f41	\N	1	f	24990.0000	t	2026-10-31 08:17:09.727071+00	2026-10-31 08:17:09.727071+00
47262228-fd35-43ec-a120-cf0c2713addb	48036860-006a-41f3-901a-61f5704256f5	b2d1720c-2e2b-4c84-8b21-e1ae51e0809b	\N	1	f	\N	t	2026-10-31 08:17:09.727071+00	2026-10-31 08:17:09.727071+00
b60611dc-ce53-42be-8275-e767abaf1495	c5ee0288-e16e-4654-8c0d-fac0b0b6fd20	b2d1720c-2e2b-4c84-8b21-e1ae51e0809b	\N	1	f	59990.0000	t	2026-10-31 08:17:09.727071+00	2026-10-31 08:17:09.727071+00
2dc487cb-fc10-4132-a1a7-e071ed3741f8	3737c0df-0bb6-4dee-a209-5b1b1c4d31b9	4bde00c2-5efd-4694-bcd0-41be8b23aedb	\N	1	f	\N	t	2026-10-31 08:24:11.267263+00	2026-10-31 08:24:11.267263+00
301ea4cb-eb59-46ff-ad62-95a188d9d00d	19f0e22f-9e12-42eb-800e-bb733dc5e7a9	20b44ac3-ad76-4788-a710-a08a854f2184	\N	2	f	\N	t	2026-10-31 08:24:13.603269+00	2026-10-31 08:24:13.603269+00
d71babd3-e861-4689-a6c9-ee4691abf4f7	63848a77-2df4-4368-8796-c09dac27b6f4	f9b16ecd-e8bf-46ef-8482-2a84eb215fd2	\N	1	f	\N	t	2026-10-31 08:24:14.301963+00	2026-10-31 08:24:14.301963+00
fcf7a62e-95ef-4549-add2-66b95dea341b	bf0fe4c3-380f-497b-8893-9827fde63b12	7f8d1ec4-f42c-48c7-928f-278cf9d23b34	\N	1	f	\N	t	2026-10-31 08:24:15.19137+00	2026-10-31 08:24:15.19137+00
88688e20-0c4e-4ebd-b421-4288dfc86ba3	2174e10f-65e8-4882-b370-2dfd10171b07	6d9f2b8f-4038-4bf7-baee-a0bbd91ba314	\N	1	f	\N	t	2026-10-31 08:24:16.674309+00	2026-10-31 08:24:16.674309+00
52114349-8af8-469e-ada3-7e2712631161	02bd8e1a-1f5f-4e5d-8c1e-1d909a546854	3e3ede4f-d267-4cff-8549-9755a16fc590	\N	1	f	\N	t	2026-10-31 08:24:17.806464+00	2026-10-31 08:24:17.806464+00
476818c7-ba57-43a1-b836-2bda62794c00	9b7d0387-53f9-4167-97b1-f2ec87c80dca	bcd56009-9fcb-4079-b8c3-42057803de96	\N	1	f	\N	t	2026-10-31 08:24:19.693865+00	2026-10-31 08:24:19.693865+00
cdd6be0d-5149-45fb-964e-f2842747e750	bec2abb3-07f2-4cc0-9dde-297e1e6ac75a	dcf62b2b-3bb7-41c6-90a2-0df56926f3d3	\N	1	f	\N	t	2026-10-31 08:24:19.937304+00	2026-10-31 08:24:19.937304+00
e14b2065-2305-4afb-9e8a-f87e8f20738c	3ebd52a8-4f5e-4ffc-8137-ed0b98bf0ac6	95724fee-0cd6-49aa-9308-0829fe8c0f13	\N	2	f	4500.0000	t	2026-10-31 08:24:21.323395+00	2026-10-31 08:24:21.323395+00
e6e70895-c378-4ada-9782-9fa69e8e6ca3	d2654e09-aeee-46a4-94b4-84e10c0b7863	3c81cd1f-5e81-45bc-9416-9e2095c3c324	\N	1	f	\N	t	2026-10-31 08:27:38.11184+00	2026-10-31 08:27:38.11184+00
a00e60fd-09f8-4c2b-b7ca-2853e05bce99	478b9715-990a-49e0-b86c-363a1cd767be	dc90eb67-7f8c-4214-b972-60afc7208384	\N	2	f	\N	t	2026-10-31 08:27:40.010946+00	2026-10-31 08:27:40.010946+00
b4141866-2780-4299-a632-f460d6972dd6	7197035c-ac98-4c4f-82fc-cef10aa9083c	48e0f739-0593-420f-a170-a77c35a41fae	\N	1	f	\N	t	2026-10-31 08:27:40.77473+00	2026-10-31 08:27:40.77473+00
9d05bfe4-0729-4b6d-b384-03fafaec8e79	ec1f61ea-d591-435c-aff8-a2111e610265	06a547de-b22a-49b3-9adc-fe3be1734f08	\N	1	f	\N	t	2026-10-31 08:27:41.555536+00	2026-10-31 08:27:41.555536+00
4e2843ab-77c2-4e8e-a887-2cad35f202b8	6e0b404e-10dc-405d-9b5e-22f30b03af37	ca41c692-d96d-44a2-b66c-65b15120e34b	\N	1	f	\N	t	2026-10-31 08:27:42.632199+00	2026-10-31 08:27:42.632199+00
2eb5fd1d-c461-40a6-b8b3-3a06de9cf540	c0440129-1c09-4070-a713-c056c1eac0c1	c6410f1a-5961-42a0-b35f-800a55a315be	\N	1	f	\N	t	2026-10-31 08:27:43.799598+00	2026-10-31 08:27:43.799598+00
e1340fe0-b2d1-4b18-95c6-c7eb90c08245	d711461d-c647-4d49-a001-68817661c036	8824b9cb-c3a7-4624-b125-4dd55b0bfbeb	\N	2	f	\N	t	2026-10-31 08:27:45.45713+00	2026-10-31 08:27:45.45713+00
8d1a6d21-bc1e-44d2-be21-1fd24f6df239	6d698fc6-103c-4088-8a1d-abd2383a2333	b4b7076e-7cc6-4f6e-a30a-4fbc79828243	\N	1	f	\N	t	2026-10-31 08:27:45.576438+00	2026-10-31 08:27:45.576438+00
34bbdfe2-baa3-4391-892f-04c12294ab74	9fc57589-f51a-44c9-9695-dd62361a2078	16bcdd98-d25d-4035-83fa-90919102c80a	\N	1	f	\N	t	2026-10-31 08:27:45.808632+00	2026-10-31 08:27:45.808632+00
5cce72bd-8ccf-4a0e-a840-2ff0fef8d689	b22df9fd-08a0-41ff-a86e-314998debc76	6cb1fe89-fd75-47ca-9b74-b6e591db1a33	\N	2	f	4500.0000	t	2026-10-31 08:27:47.346036+00	2026-10-31 08:27:47.346036+00
\.


--
-- Data for Name: product_price_history; Type: TABLE DATA; Schema: public; Owner: brightloop_user
--

COPY public.product_price_history (id, product_id, price_field, old_price, new_price, changed_by_id, reason, created_at) FROM stdin;
5ea3e4e1-68e5-4b2c-a948-9a976dd2d72d	04f99474-55d2-40d1-9f94-1a6801714aa9	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:09:09.211336+00
5cd8b296-844c-4251-876e-d0d8ce34652a	04f99474-55d2-40d1-9f94-1a6801714aa9	cost_price	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:09:09.211336+00
e01ab1a8-fa01-41dd-9a70-de94b129d0dc	fecd3eea-595f-4f74-9950-501860332150	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:09:09.457432+00
fd15e3fb-27fe-4087-81d2-8be4b9778ff1	fecd3eea-595f-4f74-9950-501860332150	cost_price	\N	300.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:09:09.457432+00
8d8c675f-75a6-4bb9-94cc-d9e1e3c9d126	7cee942d-916e-4554-97ca-d3f431fcdae6	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:11:22.986832+00
18756ea8-8820-4078-9594-d6a456df92e0	7cee942d-916e-4554-97ca-d3f431fcdae6	cost_price	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:11:22.986832+00
5a9d89cf-bfa7-4428-9b73-fa0b1a6a2a4e	8a67e854-290f-4c20-bf43-531932afd4ae	sales_price	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:11:23.194565+00
fa435845-e6b7-4841-af29-11a4b5f78cc3	526f5031-c01b-47e1-9931-12d6f9bcdd29	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:11:23.264967+00
5b0f8816-bf3d-4aa9-a496-9a5cf7142018	526f5031-c01b-47e1-9931-12d6f9bcdd29	cost_price	\N	300.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:11:23.264967+00
aee98222-9479-4c96-8454-64fbd307cf61	526f5031-c01b-47e1-9931-12d6f9bcdd29	sales_price	1000.0000	1500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Annual inflation rate increase	2026-10-31 06:11:23.298861+00
fd7aa1fa-d77b-46a9-8d45-f67519c6f21b	526f5031-c01b-47e1-9931-12d6f9bcdd29	cost_price	300.0000	450.0000	5040313c-9900-4630-93f9-1f0e119412dd	Annual inflation rate increase	2026-10-31 06:11:23.298861+00
1a08ad54-4b8f-4007-86fe-474643b1c792	36f00791-876c-4b44-be3c-1d4cede92e5b	sales_price	\N	750.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:11:23.388354+00
a78dc203-9a08-4c3d-8789-316be98c1069	6ef0bb02-187d-4513-9122-eaa480de77bf	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:11:29.778543+00
28fd8699-4256-472d-a032-c3d73c9c00b7	c042ca25-b44c-480c-87c6-c073a654cf9a	sales_price	\N	50.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:11:29.824637+00
362f6b3b-b77e-4444-94cc-5ea2ef25d137	969a867e-b20a-4c5f-b1b5-f0cfe67a5bb1	sales_price	\N	3000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:11:30.060245+00
a995be97-44cf-4057-99c1-131f3fb1e1b6	688622e3-2494-4fde-90d4-78107b647e2e	sales_price	\N	1500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:11:30.379504+00
f483db54-800c-4a7e-afaf-a7edd52592ec	121eaa2b-9e29-4c21-947f-9a2d28de1b57	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:11:30.61083+00
9ef131ae-9416-45c5-b965-ed469f123b93	2465ee22-301b-433a-a7d9-69e023d2a19f	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:12:45.19549+00
5bf0fa98-c095-4bbe-bae8-b40c25029cad	9f4e11a1-974c-45c7-9b4f-9723e768ae0a	sales_price	\N	50.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:12:45.237544+00
9a2d32c5-be83-460a-baac-8c6b64a15f6b	8ed7bc01-3a16-47e8-9ead-150ad6535e7e	sales_price	\N	1500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:12:45.884736+00
57d75c63-5f2f-4574-a234-3fbfc68f9413	9ebfdf67-a925-40e8-93fe-8666a6d59fbd	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:12:46.235778+00
6d06085a-5e94-4ece-9b7d-4ce83aee7f18	861ae7ab-d090-419b-9955-d4663145fc15	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:12:59.638933+00
49102f8e-47c4-464b-bc71-a4f267728548	eb1965b5-8923-4f65-8ac9-3943b4d5cd1d	sales_price	\N	50.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:12:59.680451+00
9a3b4554-293f-41d5-858c-05b3ca43dc0a	04e41d81-94e0-4b86-a71b-db756e3f224c	sales_price	\N	3000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:12:59.861116+00
22fa2873-bb4c-47e7-80ad-7cd36a79e409	79144eb3-21f8-490f-bd46-ac454693355f	sales_price	\N	1500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:13:00.078228+00
6fcb146a-031b-4aee-b6ab-707531c911eb	dba660b1-6890-47b4-9aa1-923db0f660af	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:13:00.313423+00
45bf3b65-91df-4efa-b31b-cefea249abb9	0399f8a6-2a2e-4fe4-aab1-c06d51fc6f84	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:13:20.9046+00
beb5353a-bb03-42e3-8941-66af84c47e27	178c904f-9799-4510-80a3-0369ac205548	sales_price	\N	50.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:13:20.946015+00
7be8c66a-bfdf-46aa-beb5-2b0356da5ad3	63e331fa-ccfe-48a4-99a2-71cd3d362192	sales_price	\N	3000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:13:21.13612+00
d656e1db-3efe-4cb7-8ba3-bac4907361c0	a73fe521-614b-4045-b1fa-6cbb5b177ec1	sales_price	\N	1500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:13:21.35121+00
f094a109-1aef-4ac4-945e-dab93de218cb	6fe79193-857b-4c53-b7ec-be99fe2247d1	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:13:21.502324+00
7d330dac-8eb2-4858-9902-7a065115169e	af3fd5b5-b681-402e-8575-5ffd9b88f130	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:13:28.044234+00
04aa35b9-7e51-4cb8-9965-76c4246f05fd	321df9e4-d590-466f-9521-5937cdff48d3	sales_price	\N	5000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:13:28.181489+00
cc82fce2-60f7-400c-bb9a-ae07869bd2d4	9acc2664-1ed1-4b32-b7d0-6879f0911497	sales_price	\N	100.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:13:28.243043+00
6ba0b417-86ab-4510-ad3b-b3ebd1382150	a6135f0d-9e90-41a4-b131-b000633d2464	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:13:42.969597+00
273d150b-dd5b-4b21-8d85-d9c1fd0e9261	32ed9f4b-3646-4de1-8d31-51a566d18f6a	sales_price	\N	5000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:13:43.0766+00
ba3cf504-8aa8-4000-9dc4-2fd19f86a191	08548eb4-b59f-4b5c-b05e-646ca08e643c	sales_price	\N	100.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:13:43.133947+00
55eb402e-7dfd-4635-bbcd-3e4f8827c092	358dac3d-dac5-49aa-aa87-02e1382ee3bb	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:13:50.870471+00
e0d12a74-4719-4dce-ba67-f4e0dc38d1cc	09020a22-da2c-4da8-b6b0-8f371b2dc361	sales_price	\N	50.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:13:50.902008+00
d22455ca-c305-4565-bce6-2198f2fccbfe	e76fe912-75c8-45d2-9051-5d5cc3dd8f1e	sales_price	\N	3000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:13:51.070842+00
c0e9eca2-1fff-43e6-bcf7-5e89a5614092	6fa297e4-67e6-4d76-9c5c-c502ecf1ea18	sales_price	\N	1500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:13:51.304615+00
dab8b212-e39f-4651-9a4d-1912233e10f3	04373e00-7bd0-4ff4-aab7-e964ad3db065	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:13:51.455491+00
d8c65ff9-7b07-4da7-984a-95b007559986	7c6f805a-640e-4ecc-978e-7901e5586d3b	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:13:51.73966+00
52a9bdd7-86d0-4487-b7d2-8c846418561a	edc1c0b2-f0bf-44f9-8f33-8a7dbeb41a2e	sales_price	\N	5000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:13:51.824624+00
8ed6efb7-18f4-4a46-b797-36344621e711	43a13440-84e9-4ad7-bebf-7fdbb5001fb8	sales_price	\N	100.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:13:51.881627+00
c0349ade-db7d-4cec-a39e-45d0cec0987d	f05e44c4-d451-4a45-89ef-63044010ffb3	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:13:51.950086+00
b2e3b292-3e1e-4cf6-94d7-2b82ef7ed035	f05e44c4-d451-4a45-89ef-63044010ffb3	cost_price	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:13:51.950086+00
d09a03fe-8d8a-4f23-a6fd-686139240a1d	f6557609-20bd-4660-99ac-ddaca5c790a8	sales_price	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:13:52.113599+00
b56f3dac-a207-4fa8-bec7-6b3284095165	4f1193b4-eaae-45eb-86c7-8fa397deba44	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:13:52.170244+00
53779ae5-914d-4c7d-be47-bce8f869b240	4f1193b4-eaae-45eb-86c7-8fa397deba44	cost_price	\N	300.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:13:52.170244+00
aa7d62f9-eb90-43ed-8af4-cd715d659d01	4f1193b4-eaae-45eb-86c7-8fa397deba44	sales_price	1000.0000	1500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Annual inflation rate increase	2026-10-31 06:13:52.197517+00
4ee1feed-7bcc-4478-a58e-6c703ecb3dab	4f1193b4-eaae-45eb-86c7-8fa397deba44	cost_price	300.0000	450.0000	5040313c-9900-4630-93f9-1f0e119412dd	Annual inflation rate increase	2026-10-31 06:13:52.197517+00
8fa0b6af-0751-4f90-9ae6-fd5aaaf34a45	e4211d2a-d133-4063-a34f-f874d9f95e86	sales_price	\N	750.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:13:52.271187+00
41b6561e-f966-46f6-9f6e-4b0e497ed8ef	1f9dfc87-7c86-463e-b39c-02772e22a98a	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:26:02.428427+00
8578b2f4-6d8d-4fca-ae36-04fe6097ced5	f60e9831-d881-4d3d-9f4d-c2e498fd1936	sales_price	\N	50.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:26:02.46143+00
c3911a1c-b491-46f0-ba15-b7fe4b718df4	d5bbca6b-8ff8-4282-9156-303ae81f081d	sales_price	\N	3000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:26:02.632078+00
5b08374f-788b-4925-a070-1e372cb509f8	2a6ac91d-0ff8-4157-80a7-5f3426f49ad3	sales_price	\N	1500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:26:02.834952+00
89acb18c-ee94-4d00-b3c1-fd4f811adb8b	d6d87563-ae37-492a-b2e0-942bb7b70a12	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:26:02.973651+00
76f2cb4f-a697-4c5f-a729-041ca175838c	2bcd0897-91e7-4ced-aa4d-e38791d0ac93	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:26:03.238769+00
a894303f-9834-45aa-94c1-da6165e2d168	3d343c77-1349-4c87-aaf6-ef9bdcdcf562	sales_price	\N	5000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:26:03.317992+00
92f90dbb-a8f8-444e-af1b-cc63741209ca	2a0b1bde-ad3b-413a-b5cc-a9e481dab438	sales_price	\N	100.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:26:03.379057+00
0628d9ed-ca0f-49f3-97e6-ead7b644c67f	a308717f-0607-4833-859f-42b9407e171b	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:26:03.451849+00
2516f936-02cd-43b6-8fda-94c7c184fa20	a308717f-0607-4833-859f-42b9407e171b	cost_price	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:26:03.451849+00
7f2decb7-a1b6-4994-a753-50b3a03dfa88	9bbac0ae-0433-4cd3-8bbc-77756a37a057	sales_price	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:26:03.626045+00
6efacecf-448f-4821-9bbd-86dfa495e085	455a8b2f-dcc1-4aac-9413-33465f3173e5	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:26:03.696165+00
68a6d5ff-2242-452a-bbdc-ded3e9e22ca0	455a8b2f-dcc1-4aac-9413-33465f3173e5	cost_price	\N	300.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:26:03.696165+00
ae022085-b7e8-4be3-a679-304ae9f4505e	455a8b2f-dcc1-4aac-9413-33465f3173e5	sales_price	1000.0000	1500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Annual inflation rate increase	2026-10-31 06:26:03.725792+00
8db5ef87-959c-45a5-b688-0f8852708483	455a8b2f-dcc1-4aac-9413-33465f3173e5	cost_price	300.0000	450.0000	5040313c-9900-4630-93f9-1f0e119412dd	Annual inflation rate increase	2026-10-31 06:26:03.725792+00
73426c18-37fd-428f-83eb-64a70b70021c	cd326af2-56c6-4257-a9be-36963a814ea0	sales_price	\N	750.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:26:03.799583+00
25de9261-0f0e-4e93-8eb6-cf7e14f6e094	1f276a0d-edd6-453c-ae2b-47c28fb3eb96	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:56:46.286958+00
303772e0-132e-4bf7-93b7-63308a6bc084	c8c73b82-9167-4008-a67d-3fc77a8b51ad	sales_price	\N	50.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:56:46.324005+00
d643e7a6-dd37-450a-95b7-c4d92d4ceb14	8194a38c-c919-47f3-88d2-e11ad42b8d01	sales_price	\N	3000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:56:46.509591+00
45ab8748-eea3-416b-9e11-7da9b6bb8d46	2753c50b-661b-4631-ba1f-0e4cb7c3bcea	sales_price	\N	1500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:56:46.737755+00
617a6d3c-ed1b-42af-add8-994c73fd763c	1bd42398-2250-4041-94de-21a445c29ff2	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:56:46.892346+00
0cd8ab0d-78e4-4766-af16-1279a38f42be	99426a0c-726c-4c52-a8ee-1db8061495de	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:56:47.179122+00
c3b87363-f4e5-4a59-919c-6fddab15c430	cdebf907-a043-424b-88a6-35f300fec891	sales_price	\N	5000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:56:47.269995+00
4946ad87-152b-42c2-afd7-51aa7645df24	f9eeb635-8cd6-4569-a539-23fac41fcd29	sales_price	\N	100.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:56:47.333192+00
386edcef-e1f1-4047-a39c-2ecab2fff9bc	e55e63cc-b037-406a-a7f2-6843e840c190	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:56:47.412714+00
c056ac77-47aa-4a49-96db-e1d1b11656e3	e55e63cc-b037-406a-a7f2-6843e840c190	cost_price	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:56:47.412714+00
4e9255f8-6668-4419-b85d-05af39ba4557	7550f7f8-4c9c-4ea5-9602-4cf0a0237da9	sales_price	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:56:47.604436+00
a1c76692-aa97-4e89-9ab1-203a186b90c7	2f29e6e9-36db-40c5-aeb4-8363d6384102	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:56:47.677206+00
cd4aaa78-1c3a-407b-8c79-fdce1ce21cc3	2f29e6e9-36db-40c5-aeb4-8363d6384102	cost_price	\N	300.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:56:47.677206+00
a37bd499-eae1-4999-8bd7-00c7260bba0a	2f29e6e9-36db-40c5-aeb4-8363d6384102	sales_price	1000.0000	1500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Annual inflation rate increase	2026-10-31 06:56:47.71192+00
d6bcf6d5-f1ea-4c6e-8fe7-cb3cdcc63056	2f29e6e9-36db-40c5-aeb4-8363d6384102	cost_price	300.0000	450.0000	5040313c-9900-4630-93f9-1f0e119412dd	Annual inflation rate increase	2026-10-31 06:56:47.71192+00
08875abb-a7db-4d7f-a291-37e00f94ae1e	552aec1f-af4b-4a87-a336-0f45a07a662e	sales_price	\N	750.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:56:47.789903+00
d1fdd708-610d-4a25-87e8-c116b2e6d50b	27c92d51-b12b-4c5e-b05a-4bb416e31ea4	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:57:56.679875+00
c550ea6b-d7fc-45f5-9085-d7d9b4fe5399	26f84f34-1499-418a-96e0-bc6600944e48	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:57:56.97341+00
3cfb38d1-db8c-44a3-b390-4be2f3528af5	e3a078ec-80ca-4ea1-bea2-363927191966	sales_price	\N	50.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:57:57.002483+00
f0add8de-ff66-4bfc-9207-e45ead457949	d83d7b84-4d47-426e-8b1b-b7e3a99a02d3	sales_price	\N	3000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:57:57.197927+00
10a05328-d017-453f-964d-b8e7e61f9a9e	2641368d-ece5-41b8-98d6-50367dafc985	sales_price	\N	1500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:57:57.419779+00
914dd106-30b9-4059-b7c3-c71ee5e57faa	2ce2ddd9-fbfc-4ed4-8d98-80e4f09b97f6	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:57:57.583235+00
25c7d850-390d-4ec8-9b17-ff8b5d4160b5	f584e165-c6aa-49ef-8f1c-e85c6c6ef708	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:57:57.889803+00
a6559ab4-e10a-4572-b0f0-f21251f41027	79fec419-75c1-4edf-81d6-a288b3755330	sales_price	\N	5000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:57:57.977655+00
e15db17f-0f8c-4a30-8cdb-622be0a13ad7	59b29da9-cc1e-498a-b178-ab4465418044	sales_price	\N	100.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:57:58.042303+00
d170d5ed-88ee-430e-8d3e-10fd28c185ef	b424bbf3-e5ba-4fff-952c-09798d164e6f	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:57:58.121428+00
7ebede26-01eb-42d0-b1dd-b6d455acc358	b424bbf3-e5ba-4fff-952c-09798d164e6f	cost_price	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:57:58.121428+00
d2d6d67c-c07b-4b43-ba72-dee134ef07e0	129fd1cb-d109-4b96-97f2-b00736810e4b	sales_price	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:57:58.321459+00
04f1b2fe-ac07-4162-a58e-0e9e86596f11	6efd9ced-9483-4f1a-a825-1e060928e307	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:57:58.391548+00
69584fff-54d6-4b71-b264-4c1daf8c4303	6efd9ced-9483-4f1a-a825-1e060928e307	cost_price	\N	300.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:57:58.391548+00
3b978a88-779f-40cc-ae66-2a13f0a0e8d0	6efd9ced-9483-4f1a-a825-1e060928e307	sales_price	1000.0000	1500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Annual inflation rate increase	2026-10-31 06:57:58.42399+00
13c04723-0d7f-424e-8d73-5fcab285c94f	6efd9ced-9483-4f1a-a825-1e060928e307	cost_price	300.0000	450.0000	5040313c-9900-4630-93f9-1f0e119412dd	Annual inflation rate increase	2026-10-31 06:57:58.42399+00
a721b5b9-8af9-4c40-901c-9073c973451b	cd8a2e3d-1839-4802-a654-08cdf79eb7cb	sales_price	\N	750.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:57:58.513056+00
ebce3e38-234a-4884-86a3-3493b6de59ca	56739bff-c037-4087-95b3-bb4c35c05732	sales_price	\N	5000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:57:58.850321+00
2aef3fd0-8455-48ca-9fb5-05384535666d	56739bff-c037-4087-95b3-bb4c35c05732	cost_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 06:57:58.850321+00
ec9e7f74-0492-4c5e-8906-99aca3e15913	ec449749-6f32-41e4-ac37-bcfcdffb15aa	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:03.222637+00
5febb043-7115-400c-877a-6f612219f301	1a7b37b3-13b2-47a3-ad9e-59476f54fde4	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:03.585235+00
feffcfef-08c6-4efd-ace3-c17dbb27dfee	dbb65843-0e0b-43ba-9f98-c849f4c084e7	sales_price	\N	50.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:03.613693+00
26eebf72-0936-48af-bcf7-5d3f77234a2e	aec1dd88-b055-432e-b06e-f5ff5c1b646d	sales_price	\N	3000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:03.787789+00
c2768a9d-8f01-48b8-9ff4-b39a269743e1	4ba0da92-15b8-40b9-b909-6d56804c20a5	sales_price	\N	1500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:04.012099+00
74160d36-7730-4c69-b752-d8c688acc685	89b050d6-580f-4d2a-b3d5-e2302e098e0a	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:04.176984+00
d1a8c686-f93b-491d-8fd5-ff2032b4c016	dcadd733-135a-4805-b06b-b64fb797e0d4	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:04.484265+00
2f90fe01-6588-4fa5-b107-23c3484149b7	bff5887a-24e0-49bf-bf0e-06a8e356708c	sales_price	\N	5000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:04.572516+00
65663b82-e178-46cf-9ba5-308ea29140a8	80c46f8b-f67a-4adb-a093-adecd4aaf89f	sales_price	\N	100.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:04.636933+00
46866db5-65a3-4a31-b384-07998aae8a4f	da10e298-6d0d-4547-a7f3-403e4900837e	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:04.718922+00
b769cf8a-5a97-4c0e-937f-8bd37b9a2bad	da10e298-6d0d-4547-a7f3-403e4900837e	cost_price	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:04.718922+00
d9f01501-8059-4b3d-a9a8-fc855441db38	244411b9-f877-4e5e-b38e-6667d74a54c8	sales_price	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:04.916884+00
49acea40-a3be-4951-8bea-dba22cd25a64	af3e7ff0-ad14-4014-911c-29a00143c4c9	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:04.987565+00
2ff1f3ca-47c8-414a-8e47-a73001925808	af3e7ff0-ad14-4014-911c-29a00143c4c9	cost_price	\N	300.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:04.987565+00
8944e608-cfa4-41eb-a062-9e82dc3d6e36	af3e7ff0-ad14-4014-911c-29a00143c4c9	sales_price	1000.0000	1500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Annual inflation rate increase	2026-10-31 07:01:05.021061+00
7f8e3433-24f1-4a5a-b726-21999f22dc0f	af3e7ff0-ad14-4014-911c-29a00143c4c9	cost_price	300.0000	450.0000	5040313c-9900-4630-93f9-1f0e119412dd	Annual inflation rate increase	2026-10-31 07:01:05.021061+00
f28cb21e-df4a-4ec9-9de4-129edcdb5023	73fde76b-895e-448f-9937-68b57e886cec	sales_price	\N	750.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:05.097802+00
bc051721-b17a-43e1-a0f5-bee368d0b866	dda6994b-3b5c-468d-817c-fe2a53ce5ec3	sales_price	\N	5000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:05.403993+00
3c0ae551-48fb-421e-8eb0-d713ee9c8f90	dda6994b-3b5c-468d-817c-fe2a53ce5ec3	cost_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:05.403993+00
6d8e3709-9315-4371-9af2-21c7e3434260	cd07bdd3-8925-4e1c-8754-a33b7b02246c	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:38.870784+00
ce0c20bb-5971-4907-b943-182d9b920fa9	854ebbc5-1efb-41a4-8fa2-16cf3c26a41b	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:40.521617+00
b5272fa7-b653-4dca-80b8-e53594c5a21d	d84397f9-160d-40ba-ac60-58cd088d5c5f	sales_price	\N	50.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:40.572892+00
f3cfbcc6-822c-49ed-9861-28b1c9a86089	feaed8df-addd-425d-9ed2-ecfaf1340189	sales_price	\N	3000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:40.747253+00
6b1f7a59-b30d-4468-9c87-7b80d4647de8	5d320af8-6a44-4f17-a7b2-33fc4de8fc75	sales_price	\N	1500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:41.012002+00
76722b62-2ef7-4987-b95e-0e7b17cbacde	2ad32ed2-97a9-4050-9215-98c7da066e2b	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:41.163375+00
6ca969a1-83cc-4cae-9243-b7b3524dd24d	c77d4e45-cbef-4387-bd62-fbb9dda3a326	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:41.45576+00
a7c881cf-1cb1-4d8b-b6cb-fb07dc96943a	af5076dc-fb4c-45c7-9a5f-bbd5ceaa40fa	sales_price	\N	5000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:41.539605+00
96ca92d9-bc56-4e13-9081-4d5afdc562c2	fd73a7e4-f39d-4e1b-9fe3-da976679b1bc	sales_price	\N	100.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:41.604242+00
66cdb51a-fc24-4379-b505-ebabd2637ab8	59cf8561-3fe4-4734-bbe2-95dba84775f9	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:41.67762+00
28e253b9-216c-4ecf-bf46-13625e201487	59cf8561-3fe4-4734-bbe2-95dba84775f9	cost_price	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:41.67762+00
ca9ad92b-91a0-4c57-94a0-b99d7d354632	d87788ef-ad41-4620-b2f2-d03d7a71db46	sales_price	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:41.869698+00
46ad2228-a6ca-436f-86dd-584c07316480	f01493de-49af-430b-a4c3-c4363e662aa0	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:41.942969+00
7c652011-0670-4174-998e-b24922ac14ed	f01493de-49af-430b-a4c3-c4363e662aa0	cost_price	\N	300.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:41.942969+00
77386a60-f13c-4d82-908f-2b2baa3edc78	f01493de-49af-430b-a4c3-c4363e662aa0	sales_price	1000.0000	1500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Annual inflation rate increase	2026-10-31 07:01:41.977332+00
a57013b2-3838-48b0-8212-28b5f5d794f0	f01493de-49af-430b-a4c3-c4363e662aa0	cost_price	300.0000	450.0000	5040313c-9900-4630-93f9-1f0e119412dd	Annual inflation rate increase	2026-10-31 07:01:41.977332+00
6c1fccd3-1661-4c45-9829-4d91d3086d91	5c0fd786-581f-4a73-a82b-8963d1479d94	sales_price	\N	750.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:42.058117+00
5f5d4417-76a7-463e-8537-965b23001e51	c48f1d45-bed4-411a-a422-daed07f89681	sales_price	\N	5000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:42.381422+00
e6c8a645-89c5-45f7-accc-027b75f7a631	c48f1d45-bed4-411a-a422-daed07f89681	cost_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:01:42.381422+00
15cc8c73-4dbe-438b-a031-4842e8141563	edbb467f-ee59-4f31-94aa-588b436d4eaa	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:24:19.120917+00
70b2858a-9a3f-4e55-a814-4e7dae235622	8e39b9d6-f2be-477f-89b8-2d6840dc802b	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:24:20.816328+00
491b2755-6859-4f49-831b-815afb844187	3efeb345-1ddd-42e3-b156-f5dd8b3e3a9e	sales_price	\N	50.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:24:20.850565+00
c24caed7-a8c2-4e9c-a729-487c0e170801	23cb2b12-e720-4012-b44a-98da5b5c9b9d	sales_price	\N	3000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:24:21.030442+00
08b66a99-69b7-4d3d-a5b0-49e39eb96ff7	d04c4ec8-e918-490e-8571-b56018b0c3ca	sales_price	\N	1500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:24:21.251941+00
e1bc79f9-d42c-4ac7-9c3e-c458388db2de	b22df97a-2fa6-449e-aafd-12ca0a45d15e	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:24:21.416759+00
32097ef6-2227-4b09-9c14-fee223be17ab	b62c5ef2-e8a4-444e-854a-338a2b639bcc	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:24:21.714405+00
fe4ab4fa-fac2-49e6-8ed4-413a924fc479	de41995c-95e2-44be-b6b6-1c22ddb11d9d	sales_price	\N	5000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:24:21.795659+00
f246d1ee-2b47-4b07-8785-3a6398dcd901	b2291501-041e-4f78-9499-424109c6f3a6	sales_price	\N	100.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:24:21.862488+00
62b1c280-b176-4e69-8985-702b4a975690	b49a17d4-223c-42ab-abbf-f8e658d82530	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:24:21.938189+00
6f54159f-dded-4830-853f-9b8da0e4113d	b49a17d4-223c-42ab-abbf-f8e658d82530	cost_price	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:24:21.938189+00
2b6960fe-9cd7-4c21-b28f-99d4acfc6f4e	18a5cd0c-9068-42b0-b42d-453881b90fe3	sales_price	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:24:22.111094+00
94d87329-ce0c-4147-b408-64af534ed9c3	20a46d09-18d3-43a7-87e9-ea6287e1cc29	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:24:22.180328+00
c8bffe1a-7040-4a78-8928-a43a093165b4	20a46d09-18d3-43a7-87e9-ea6287e1cc29	cost_price	\N	300.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:24:22.180328+00
7f0e7d75-1c65-4c33-8db1-fa47c8de1ab3	20a46d09-18d3-43a7-87e9-ea6287e1cc29	sales_price	1000.0000	1500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Annual inflation rate increase	2026-10-31 07:24:22.212534+00
7870a16c-f50c-4ca3-b063-749ba7fd2e26	20a46d09-18d3-43a7-87e9-ea6287e1cc29	cost_price	300.0000	450.0000	5040313c-9900-4630-93f9-1f0e119412dd	Annual inflation rate increase	2026-10-31 07:24:22.212534+00
2d1755a0-5fe3-4877-8f50-505e352f8a12	f154b89e-3860-40f9-9a41-ae91a70b21d2	sales_price	\N	750.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:24:22.289844+00
49c813e6-da83-43b9-9682-8c91b7788caf	37387601-cec8-4c66-b427-84f6104b528c	sales_price	\N	5000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:24:22.612997+00
53ec22cc-8a50-4e42-924c-f7acbac6aa3b	37387601-cec8-4c66-b427-84f6104b528c	cost_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:24:22.612997+00
f0f0b704-abbb-493a-ab48-68fb0007bb87	186b4bbe-6fca-4f10-8817-a4b71efd0762	sales_price	\N	49999.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:33:24.444528+00
c858a911-0151-47c4-bef0-097e425e00c8	186b4bbe-6fca-4f10-8817-a4b71efd0762	cost_price	\N	15000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:33:24.444528+00
444ed39c-b17f-48c5-b593-49a9674ef749	48db2113-98c2-44bb-8fb5-491a6e75ddfd	sales_price	\N	19999.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:33:24.444528+00
f578408b-f2d2-4282-afcb-b0ff32a855b2	48db2113-98c2-44bb-8fb5-491a6e75ddfd	cost_price	\N	5000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:33:24.444528+00
eabd2a04-94de-4114-9157-84a9a9312309	ebc4abad-f5e7-4644-9567-8d7fdad06fd4	sales_price	\N	15000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:33:24.444528+00
c9a85ede-0cba-41ac-b38e-8e284e4e496c	ebc4abad-f5e7-4644-9567-8d7fdad06fd4	cost_price	\N	8000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:33:24.444528+00
de86284f-b55c-4b05-94ee-d385bd7fc4ec	942c213b-7840-4549-aa89-94c83ee4842a	sales_price	\N	50000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:35:20.586873+00
6f449d47-6786-4eab-90c6-68dbcb3a7044	401ad69d-e929-4555-87ce-ff5b306799a8	sales_price	\N	100.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:35:21.108966+00
5b595e72-2347-48e2-8c25-f9d1f519e3f4	77f7a1a1-923b-4307-b433-b3653d77faf2	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:35:21.722144+00
0b5457c3-ce74-4a36-99ea-5cf44c504ee1	ddac571a-50c8-46a7-aae6-c9699a912456	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:35:22.240495+00
2ef2d085-627e-4ae2-8738-c02d83d594ab	996e7e31-9bc8-4564-9457-8ca7927dfb84	sales_price	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:35:22.854986+00
4b90a61f-d487-4e93-934f-2ff4a13056a8	39e2f841-cf98-4c62-809a-d941b1637c23	sales_price	\N	50000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:37:29.332951+00
030e5533-b6b7-4a89-b3b5-0982f159d9d8	62d13717-1a0d-4a1d-b4fd-71cf741c8ba5	sales_price	\N	100.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:37:31.367084+00
ccc76fd0-931e-4d14-8378-bb174ce38b08	683a33cf-43e1-4b69-adc0-50512d118c91	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:37:31.962817+00
e5cc668f-476b-47cc-9484-8d29e5fd8a78	b37d638a-f942-49d6-8e03-68859649bc3a	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:37:32.526056+00
cac841c2-759d-43af-bc64-17ede5b291b0	a1eae06d-1777-4cb6-b063-6a2580b8a280	sales_price	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:37:33.415205+00
26ffb218-c4b5-4f57-998b-b0a53ec4b9e3	53b00a01-c903-4f64-9e72-5088c4c0e028	sales_price	\N	50000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:38:18.399867+00
7dc43d60-2f43-4a8b-b8b9-1f29c1c8266b	a98b731e-2a49-4e70-85b8-405fbc73f791	sales_price	\N	100.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:38:20.532174+00
ef241aba-14e6-48a7-9013-6c618a2db881	ed0db0d3-c8a8-4bc2-ac69-92b127dcbd38	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:38:21.148112+00
91eeadba-b7bc-40c3-b45a-326eca13da60	db17cf02-d6b1-4db4-a8e9-5bf25f5a34f1	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:38:21.96493+00
21ab2089-6546-476b-ac9a-c902f42f4e67	650bdf95-c3b6-4a92-955b-9551fb73a316	sales_price	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:38:23.067316+00
9553f1e5-a52e-42c6-830e-117cd576bb0e	7fc3f342-51f1-4164-8bae-dfa344fbf476	sales_price	\N	50000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:38:32.70076+00
cc7073c5-232d-48f7-82d3-a88bc6554c66	4f2a6c17-03c3-4515-be61-1269cf0fb4ab	sales_price	\N	100.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:38:34.595836+00
5d64e93b-7122-40f3-8c61-b0e4d68dcf74	8e677bd2-2a28-432f-95eb-337f2b48f1e5	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:38:35.185917+00
bf0552d7-b7ac-4899-8f55-e85dc7c09e6a	c490928c-9a8c-4437-9601-1abebc4075b7	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:38:35.97391+00
17c8ab1d-c15f-4478-8883-20048f94a1ba	5bea6103-3d8f-49c0-b077-370f3e20b856	sales_price	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:38:37.106524+00
99f203c6-ec0b-4b3c-bec0-2c23d52fe079	e7f7f3ac-3fa7-4818-b3da-4d643758ecfc	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:38:38.172839+00
52d05ff3-2595-4968-9485-04edd7aece7d	7090854b-634c-430b-8251-559ea3b5b470	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:38:39.808323+00
8d9dcdf8-109d-4204-b989-58e4bf2e5be4	f332c5d3-ccfe-4fb8-a940-9d0eebba6fab	sales_price	\N	50.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:38:39.840896+00
5dc09c11-eeee-4922-9729-938945453c4b	e19e498e-8fbb-4734-9519-84c3a22650c1	sales_price	\N	3000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:38:40.028576+00
4c48454a-84a8-4839-b530-b45c281b6273	054c67bf-f82b-40c3-9817-1266139fb3ac	sales_price	\N	1500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:38:40.251474+00
b896ea62-7434-4949-b7a1-ccf073b820ea	d5802e47-aede-48cb-8212-855361c869b8	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:38:40.410335+00
334d4608-c74b-4492-923a-227c9215b139	c96bdd64-40ce-40fc-a165-2ff67e37088e	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:38:40.710591+00
b7c4d495-9d75-4690-b945-180d9a2e6895	d3e8f730-2214-4391-99d7-42a257431398	sales_price	\N	5000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:38:40.794809+00
31381d3d-0fdc-47ff-957d-622c56a8e63f	d8969bdc-b55f-45af-b479-0dbc098e71bc	sales_price	\N	100.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:38:40.862446+00
16e4d1ab-cd8c-4403-995c-b82080de324f	ccc3244e-bd3a-4ccf-9b7e-55060b9cec92	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:38:40.943603+00
e7a2fdba-b4b4-475c-bbc1-e6404ccf6eda	ccc3244e-bd3a-4ccf-9b7e-55060b9cec92	cost_price	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:38:40.943603+00
84d9dbe9-2dac-4665-aaff-a30e0f94a45b	9fa9f36b-eab8-40f9-8e6e-f3c587af7e2f	sales_price	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:38:41.135501+00
fed7e914-0462-45f2-bd1c-4c90e82375da	e54b5f0a-5d7e-4477-add3-ca6039fd8723	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:38:41.207953+00
90a34d64-2da6-4208-b6e4-a79a13b00e12	e54b5f0a-5d7e-4477-add3-ca6039fd8723	cost_price	\N	300.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:38:41.207953+00
bde33054-2af7-41b5-9644-df8f69298848	e54b5f0a-5d7e-4477-add3-ca6039fd8723	sales_price	1000.0000	1500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Annual inflation rate increase	2026-10-31 07:38:41.249154+00
af4f43a3-9058-441f-9ac0-5d86c3234efd	e54b5f0a-5d7e-4477-add3-ca6039fd8723	cost_price	300.0000	450.0000	5040313c-9900-4630-93f9-1f0e119412dd	Annual inflation rate increase	2026-10-31 07:38:41.249154+00
41f76f88-e80f-4e6f-a154-89a138856ca2	0c0bf333-9976-4b9c-ae78-70e1bd9fddc4	sales_price	\N	750.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:38:41.337753+00
bf885dc8-908e-49c1-9fdf-dcc852414c4d	2758ae3b-77c6-43a1-ae62-0cf0bb304cac	sales_price	\N	5000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:38:41.667772+00
9a292dae-fc9f-4d45-8e05-53742dc4b1a1	2758ae3b-77c6-43a1-ae62-0cf0bb304cac	cost_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 07:38:41.667772+00
9a8a9d5f-c501-4526-9adb-9e0eb4436eae	4bde00c2-5efd-4694-bcd0-41be8b23aedb	sales_price	\N	50000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:24:11.196744+00
9f1aaa7f-3448-44b8-9fb9-5eb3b7ad82ec	20b44ac3-ad76-4788-a710-a08a854f2184	sales_price	\N	100.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:24:13.542583+00
8fc32e82-a213-49db-8c6f-9372daeb360c	f9b16ecd-e8bf-46ef-8482-2a84eb215fd2	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:24:14.227525+00
caba6423-7b85-4b26-ae2b-eda9ec5013e8	7f8d1ec4-f42c-48c7-928f-278cf9d23b34	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:24:15.121532+00
0b59265b-adb0-41ee-a03b-e5fa107a64e8	6d9f2b8f-4038-4bf7-baee-a0bbd91ba314	sales_price	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:24:16.618806+00
df8fdebe-cb79-407f-951a-232151f1dcce	3e3ede4f-d267-4cff-8549-9755a16fc590	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:24:17.742565+00
d69feded-c411-473b-a683-1260987275cd	bcd56009-9fcb-4079-b8c3-42057803de96	sales_price	\N	3000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:24:19.665087+00
00f482b4-cc08-4be0-9519-cca5733ad659	dcf62b2b-3bb7-41c6-90a2-0df56926f3d3	sales_price	\N	1500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:24:19.907895+00
622ba891-e7cb-436f-9529-4d6259882832	f8fb9c0c-8135-427d-a119-1af9ce6e9a02	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:24:20.06928+00
e4c219ac-9743-4a7e-92f2-bfb8880edd88	d9d4cfa1-d7ff-4475-81ef-aacf2209bae8	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:24:20.357187+00
e791e65e-c48b-4dc1-a58f-f504207e332c	427f1a59-ae24-45e4-bc39-24b8f1acd32f	sales_price	\N	5000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:24:20.443316+00
b15cdd0d-10d9-4cca-8bd4-3e633facc25b	23901c36-a9a0-44ad-98af-92fe4a5b1d88	sales_price	\N	100.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:24:20.511977+00
f704d37a-605d-48e0-9dd1-8441c7f3e905	ca9093a9-8946-45d9-9f7c-0fed270ee1b7	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:24:20.593607+00
e60decc2-dc3f-4aa1-abb5-f77017d4069c	ca9093a9-8946-45d9-9f7c-0fed270ee1b7	cost_price	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:24:20.593607+00
15f13579-192f-42c5-a439-1de3983bba39	1da1085b-388e-42ba-a756-8d3905e1119b	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:24:20.786671+00
b494e85b-fca2-401c-aa73-13b0c22defbe	1da1085b-388e-42ba-a756-8d3905e1119b	cost_price	\N	300.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:24:20.786671+00
5c4ea351-d6e8-4c20-b7fd-001ffce96021	1da1085b-388e-42ba-a756-8d3905e1119b	sales_price	1000.0000	1500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Annual inflation rate increase	2026-10-31 08:24:20.825569+00
0dcaf884-d083-4d86-93fb-853231fdc0b9	1da1085b-388e-42ba-a756-8d3905e1119b	cost_price	300.0000	450.0000	5040313c-9900-4630-93f9-1f0e119412dd	Annual inflation rate increase	2026-10-31 08:24:20.825569+00
27364908-f550-477a-b2a3-30e43fcc71f7	5a501b7e-5295-4719-8c88-20c5ffcced35	sales_price	\N	750.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:24:20.912848+00
46f492ac-38a6-4f36-8c53-71711a3ef74d	95724fee-0cd6-49aa-9308-0829fe8c0f13	sales_price	\N	5000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:24:21.253193+00
ef652e6e-aa81-4c8c-b6f8-355d13bd49e5	95724fee-0cd6-49aa-9308-0829fe8c0f13	cost_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:24:21.253193+00
40d0a0da-aba2-4337-bee9-c81b46485b75	3c81cd1f-5e81-45bc-9416-9e2095c3c324	sales_price	\N	50000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:27:38.052173+00
9ee0fd5b-d78c-472e-b063-6ebbeb2d4fae	dc90eb67-7f8c-4214-b972-60afc7208384	sales_price	\N	100.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:27:39.95908+00
9e72ba21-9b86-4460-b6ba-8b589a393af7	48e0f739-0593-420f-a170-a77c35a41fae	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:27:40.696678+00
2d35b6ce-cdc9-4ac8-8795-f7d9f1fa643f	06a547de-b22a-49b3-9adc-fe3be1734f08	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:27:41.504162+00
abe2e686-e29b-48f3-a616-10d3d5f86c8a	ca41c692-d96d-44a2-b66c-65b15120e34b	sales_price	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:27:42.573515+00
0750117e-8f83-4ad2-b9e5-4fd3bd9ea190	c6410f1a-5961-42a0-b35f-800a55a315be	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:27:43.731206+00
e057d998-8ef1-420d-951e-7d10cca6a96e	8824b9cb-c3a7-4624-b125-4dd55b0bfbeb	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:27:45.347391+00
a697d4e2-7bcf-44ac-85c5-6cf87a45f22d	35ddd7a9-e386-4b9a-9b32-408791cc0634	sales_price	\N	50.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:27:45.378666+00
2a90fa11-5e63-45b9-bbdb-1a2525b53961	b4b7076e-7cc6-4f6e-a30a-4fbc79828243	sales_price	\N	3000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:27:45.550283+00
302e651f-518f-427a-b2d5-a4c2a2da2f70	16bcdd98-d25d-4035-83fa-90919102c80a	sales_price	\N	1500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:27:45.779972+00
e92c1a5e-6b6b-4c8e-89a4-450ae2a6195a	ba0da014-b338-4921-8cf2-e19f2f4fdcae	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:27:45.940944+00
23a7ecc4-50a9-435e-9211-ede03dce4c1c	93bfd89e-bc60-47c0-b494-e9b010980df0	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:27:46.266357+00
c4870665-8a86-41ee-88cb-08bf22d99760	ee8602df-7bf2-4bfb-b82d-06e892fec89e	sales_price	\N	5000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:27:46.361271+00
7a92dd45-f621-4bd0-857b-85085311f1f5	5d6f9fc2-e8ac-490d-9390-ab4bc994f650	sales_price	\N	100.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:27:46.434638+00
2b623031-52bc-4143-abfe-300efeae203a	f3c4dab1-cf3f-43eb-80f2-f7ddedf00f64	sales_price	\N	2000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:27:46.518896+00
327705b6-a583-4e56-9013-2743d26de848	f3c4dab1-cf3f-43eb-80f2-f7ddedf00f64	cost_price	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:27:46.518896+00
e8a1abe0-05cd-485d-a857-1b14feee94ea	21f3dee2-08f1-4992-8579-fc021a4bdc17	sales_price	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:27:46.706445+00
59cfaff9-642b-498c-86bd-841f21dd4c9c	6105c5e6-fce7-4f05-ab91-8fde170061c9	sales_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:27:46.787751+00
58ee5b4c-ab06-4934-827e-8ee25f94d0e9	6105c5e6-fce7-4f05-ab91-8fde170061c9	cost_price	\N	300.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:27:46.787751+00
a2fcae0a-bbda-4df5-b971-fe3792d66fe0	6105c5e6-fce7-4f05-ab91-8fde170061c9	sales_price	1000.0000	1500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Annual inflation rate increase	2026-10-31 08:27:46.823568+00
3eabb536-adb9-449f-9b05-796c2b73a8e7	6105c5e6-fce7-4f05-ab91-8fde170061c9	cost_price	300.0000	450.0000	5040313c-9900-4630-93f9-1f0e119412dd	Annual inflation rate increase	2026-10-31 08:27:46.823568+00
1e61af25-c863-440b-9529-d7834378c34f	aed404df-5e24-47b3-b798-72d9daea4654	sales_price	\N	750.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:27:46.928905+00
526f02ad-2709-4bbe-a0a8-c0b4647e8dd0	6cb1fe89-fd75-47ca-9b74-b6e591db1a33	sales_price	\N	5000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:27:47.291416+00
d241e9bf-1a4b-4d08-ab7d-5eede6bde4a0	6cb1fe89-fd75-47ca-9b74-b6e591db1a33	cost_price	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial product creation	2026-10-31 08:27:47.291416+00
\.


--
-- Data for Name: product_variants; Type: TABLE DATA; Schema: public; Owner: brightloop_user
--

COPY public.product_variants (id, product_id, variant_name, variant_code, adjustment_type, adjustment_value, is_active, description, created_at, updated_at) FROM stdin;
7f637b2a-7015-462b-8fff-2d6e4ec870d2	04f99474-55d2-40d1-9f94-1a6801714aa9	Standard Edition	STD	FIXED_AMOUNT	0.0000	t	\N	2026-10-31 06:09:09.211336+00	2026-10-31 06:09:09.211336+00
b197ac43-9c8c-4a50-b86e-1801ee29ff2f	04f99474-55d2-40d1-9f94-1a6801714aa9	Premium Edition	PREM	FIXED_AMOUNT	1000.0000	t	\N	2026-10-31 06:09:09.211336+00	2026-10-31 06:09:09.211336+00
3e8da5f7-3f7f-48c5-b383-5a45987b4580	fecd3eea-595f-4f74-9950-501860332150	Pro Pack	PRO	FIXED_AMOUNT	200.0000	t	\N	2026-10-31 06:09:09.457432+00	2026-10-31 06:09:09.457432+00
907568e7-b630-4b2a-8efd-04d0cb0cb53d	7cee942d-916e-4554-97ca-d3f431fcdae6	Standard Edition	STD	FIXED_AMOUNT	0.0000	t	\N	2026-10-31 06:11:22.986832+00	2026-10-31 06:11:22.986832+00
64f3265d-f7cb-4977-b77c-0c4ba591c298	7cee942d-916e-4554-97ca-d3f431fcdae6	Premium Edition	PREM	FIXED_AMOUNT	1000.0000	t	\N	2026-10-31 06:11:22.986832+00	2026-10-31 06:11:22.986832+00
2c9a051f-9788-4fb4-a69e-cab282aae68c	7cee942d-916e-4554-97ca-d3f431fcdae6	Enterprise Addon	ENT	PERCENTAGE	25.0000	t	\N	2026-10-31 06:11:23.067041+00	2026-10-31 06:11:23.067041+00
14b6b487-3a78-4e2c-868e-ed879361bdc6	526f5031-c01b-47e1-9931-12d6f9bcdd29	Pro Pack	PRO	PERCENTAGE	30.0000	t	\N	2026-10-31 06:11:23.264967+00	2026-10-31 06:11:23.340133+00
f247a797-cd47-4d54-a9bf-6aaee5854c48	36f00791-876c-4b44-be3c-1d4cede92e5b	Variant A	VA	FIXED_AMOUNT	50.0000	f	\N	2026-10-31 06:11:23.388354+00	2026-10-31 06:11:23.468463+00
a4240ace-a976-408e-8d29-916a7ceb90be	121eaa2b-9e29-4c21-947f-9a2d28de1b57	Premium Support	SUP	FIXED_AMOUNT	500.0000	t	\N	2026-10-31 06:11:30.61083+00	2026-10-31 06:11:30.61083+00
b9e43893-8cc6-4a57-ae38-990694394fc0	9ebfdf67-a925-40e8-93fe-8666a6d59fbd	Premium Support	SUP	FIXED_AMOUNT	500.0000	t	\N	2026-10-31 06:12:46.235778+00	2026-10-31 06:12:46.235778+00
cb45dbbc-02c4-4185-9dcb-d489323f84cd	dba660b1-6890-47b4-9aa1-923db0f660af	Premium Support	SUP	FIXED_AMOUNT	500.0000	t	\N	2026-10-31 06:13:00.313423+00	2026-10-31 06:13:00.313423+00
1c1ec097-b256-48f1-abec-265d94ffbbdf	6fe79193-857b-4c53-b7ec-be99fe2247d1	Premium Support	SUP	FIXED_AMOUNT	500.0000	t	\N	2026-10-31 06:13:21.502324+00	2026-10-31 06:13:21.502324+00
25173b97-8ce1-493e-a708-f1bfea0d2946	af3fd5b5-b681-402e-8575-5ffd9b88f130	Odoo Integration	ODOO	FIXED_AMOUNT	560.0000	t	\N	2026-10-31 06:13:28.044234+00	2026-10-31 06:13:28.044234+00
c14ca68d-c322-4545-b3db-77c83734d4f6	af3fd5b5-b681-402e-8575-5ffd9b88f130	Multi-Company	MCOMP	PERCENTAGE	15.0000	t	\N	2026-10-31 06:13:28.044234+00	2026-10-31 06:13:28.044234+00
17bbc51d-82ba-401d-aec3-0fdf2301e7a1	a6135f0d-9e90-41a4-b131-b000633d2464	Odoo Integration	ODOO	FIXED_AMOUNT	560.0000	t	\N	2026-10-31 06:13:42.969597+00	2026-10-31 06:13:42.969597+00
a68fd77e-7a83-40ba-a822-44cb57ecd883	a6135f0d-9e90-41a4-b131-b000633d2464	Multi-Company	MCOMP	PERCENTAGE	15.0000	t	\N	2026-10-31 06:13:42.969597+00	2026-10-31 06:13:42.969597+00
8fd87388-1f5d-4b91-9a9a-7c8271705edb	04373e00-7bd0-4ff4-aab7-e964ad3db065	Premium Support	SUP	FIXED_AMOUNT	500.0000	t	\N	2026-10-31 06:13:51.455491+00	2026-10-31 06:13:51.455491+00
0b91335e-5667-4d1b-a83f-731bca7b9f8b	7c6f805a-640e-4ecc-978e-7901e5586d3b	Odoo Integration	ODOO	FIXED_AMOUNT	560.0000	t	\N	2026-10-31 06:13:51.73966+00	2026-10-31 06:13:51.73966+00
87fbfe6d-a0be-46e8-9ffa-137804bfa6e2	7c6f805a-640e-4ecc-978e-7901e5586d3b	Multi-Company	MCOMP	PERCENTAGE	15.0000	t	\N	2026-10-31 06:13:51.73966+00	2026-10-31 06:13:51.73966+00
b3ee21c0-17b9-42a6-9379-7f1dd12740a5	f05e44c4-d451-4a45-89ef-63044010ffb3	Standard Edition	STD	FIXED_AMOUNT	0.0000	t	\N	2026-10-31 06:13:51.950086+00	2026-10-31 06:13:51.950086+00
69eaf125-7746-4c33-b26e-dbfa769b55a0	f05e44c4-d451-4a45-89ef-63044010ffb3	Premium Edition	PREM	FIXED_AMOUNT	1000.0000	t	\N	2026-10-31 06:13:51.950086+00	2026-10-31 06:13:51.950086+00
7c978ef8-1885-4ca9-885d-ae81a97a51bf	f05e44c4-d451-4a45-89ef-63044010ffb3	Enterprise Addon	ENT	PERCENTAGE	25.0000	t	\N	2026-10-31 06:13:52.004188+00	2026-10-31 06:13:52.004188+00
b9a95e2b-3ae8-40fc-918a-0f414359c493	4f1193b4-eaae-45eb-86c7-8fa397deba44	Pro Pack	PRO	PERCENTAGE	30.0000	t	\N	2026-10-31 06:13:52.170244+00	2026-10-31 06:13:52.230443+00
c963199d-9887-4663-86ab-af9a1af8540a	e4211d2a-d133-4063-a34f-f874d9f95e86	Variant A	VA	FIXED_AMOUNT	50.0000	f	\N	2026-10-31 06:13:52.271187+00	2026-10-31 06:13:52.334352+00
e18c25c6-b3fe-4ea0-a4cd-f0de05ff52ab	d6d87563-ae37-492a-b2e0-942bb7b70a12	Premium Support	SUP	FIXED_AMOUNT	500.0000	t	\N	2026-10-31 06:26:02.973651+00	2026-10-31 06:26:02.973651+00
79fc5752-dd62-4007-8b50-a8b0143c17ec	2bcd0897-91e7-4ced-aa4d-e38791d0ac93	Odoo Integration	ODOO	FIXED_AMOUNT	560.0000	t	\N	2026-10-31 06:26:03.238769+00	2026-10-31 06:26:03.238769+00
67088a76-85a0-438c-a30e-2834b4c8ad6b	2bcd0897-91e7-4ced-aa4d-e38791d0ac93	Multi-Company	MCOMP	PERCENTAGE	15.0000	t	\N	2026-10-31 06:26:03.238769+00	2026-10-31 06:26:03.238769+00
e06fcae1-fb23-41ad-b3d4-17411ef9e71f	a308717f-0607-4833-859f-42b9407e171b	Standard Edition	STD	FIXED_AMOUNT	0.0000	t	\N	2026-10-31 06:26:03.451849+00	2026-10-31 06:26:03.451849+00
3dc3f175-6abb-4f76-bb94-ce005b2b28dd	a308717f-0607-4833-859f-42b9407e171b	Premium Edition	PREM	FIXED_AMOUNT	1000.0000	t	\N	2026-10-31 06:26:03.451849+00	2026-10-31 06:26:03.451849+00
501b4455-d0fe-4c3a-9286-ad9233b31152	a308717f-0607-4833-859f-42b9407e171b	Enterprise Addon	ENT	PERCENTAGE	25.0000	t	\N	2026-10-31 06:26:03.50579+00	2026-10-31 06:26:03.50579+00
a60361be-a9d2-4b9d-926a-852584870054	455a8b2f-dcc1-4aac-9413-33465f3173e5	Pro Pack	PRO	PERCENTAGE	30.0000	t	\N	2026-10-31 06:26:03.696165+00	2026-10-31 06:26:03.761454+00
b36dcf42-8323-40eb-a599-9bdef190a97c	cd326af2-56c6-4257-a9be-36963a814ea0	Variant A	VA	FIXED_AMOUNT	50.0000	f	\N	2026-10-31 06:26:03.799583+00	2026-10-31 06:26:03.860037+00
4602eab7-0f64-4ee6-83f9-16bf629b0cff	1bd42398-2250-4041-94de-21a445c29ff2	Premium Support	SUP	FIXED_AMOUNT	500.0000	t	\N	2026-10-31 06:56:46.892346+00	2026-10-31 06:56:46.892346+00
7d6e0fdc-d3a4-4f2d-88ab-5901081cb213	99426a0c-726c-4c52-a8ee-1db8061495de	Odoo Integration	ODOO	FIXED_AMOUNT	560.0000	t	\N	2026-10-31 06:56:47.179122+00	2026-10-31 06:56:47.179122+00
830cd203-3b78-4a8d-9575-f0812f4ab769	99426a0c-726c-4c52-a8ee-1db8061495de	Multi-Company	MCOMP	PERCENTAGE	15.0000	t	\N	2026-10-31 06:56:47.179122+00	2026-10-31 06:56:47.179122+00
150df79f-92e3-4a41-8316-efb918c8aa6d	e55e63cc-b037-406a-a7f2-6843e840c190	Standard Edition	STD	FIXED_AMOUNT	0.0000	t	\N	2026-10-31 06:56:47.412714+00	2026-10-31 06:56:47.412714+00
ca0bad42-d760-4f35-9a75-9f8f97abf60e	e55e63cc-b037-406a-a7f2-6843e840c190	Premium Edition	PREM	FIXED_AMOUNT	1000.0000	t	\N	2026-10-31 06:56:47.412714+00	2026-10-31 06:56:47.412714+00
f3282671-469f-4989-9cb8-159877a7c3e9	e55e63cc-b037-406a-a7f2-6843e840c190	Enterprise Addon	ENT	PERCENTAGE	25.0000	t	\N	2026-10-31 06:56:47.481981+00	2026-10-31 06:56:47.481981+00
e67d3b20-e99a-4713-9602-fa5d19e0ddd1	2f29e6e9-36db-40c5-aeb4-8363d6384102	Pro Pack	PRO	PERCENTAGE	30.0000	t	\N	2026-10-31 06:56:47.677206+00	2026-10-31 06:56:47.746607+00
6b896431-0624-4579-8a4e-793d44498f3a	552aec1f-af4b-4a87-a336-0f45a07a662e	Variant A	VA	FIXED_AMOUNT	50.0000	f	\N	2026-10-31 06:56:47.789903+00	2026-10-31 06:56:47.86115+00
a0559654-7d26-4f01-a04f-dda83c0edee0	2ce2ddd9-fbfc-4ed4-8d98-80e4f09b97f6	Premium Support	SUP	FIXED_AMOUNT	500.0000	t	\N	2026-10-31 06:57:57.583235+00	2026-10-31 06:57:57.583235+00
6bb06fa0-24a6-41f7-b77a-c464343c013e	f584e165-c6aa-49ef-8f1c-e85c6c6ef708	Odoo Integration	ODOO	FIXED_AMOUNT	560.0000	t	\N	2026-10-31 06:57:57.889803+00	2026-10-31 06:57:57.889803+00
7db0c03a-312e-4487-9d75-5706ccbb6d60	f584e165-c6aa-49ef-8f1c-e85c6c6ef708	Multi-Company	MCOMP	PERCENTAGE	15.0000	t	\N	2026-10-31 06:57:57.889803+00	2026-10-31 06:57:57.889803+00
db2dba94-71ab-488b-aa18-5caa79fb50f6	b424bbf3-e5ba-4fff-952c-09798d164e6f	Standard Edition	STD	FIXED_AMOUNT	0.0000	t	\N	2026-10-31 06:57:58.121428+00	2026-10-31 06:57:58.121428+00
adc3ab03-606e-4410-98de-59b5b04fe827	b424bbf3-e5ba-4fff-952c-09798d164e6f	Premium Edition	PREM	FIXED_AMOUNT	1000.0000	t	\N	2026-10-31 06:57:58.121428+00	2026-10-31 06:57:58.121428+00
dac2de5d-9451-4bb1-b5b9-31bfc5a35283	b424bbf3-e5ba-4fff-952c-09798d164e6f	Enterprise Addon	ENT	PERCENTAGE	25.0000	t	\N	2026-10-31 06:57:58.190747+00	2026-10-31 06:57:58.190747+00
75e8ab88-d794-43e4-9510-2f6577bd1ab8	6efd9ced-9483-4f1a-a825-1e060928e307	Pro Pack	PRO	PERCENTAGE	30.0000	t	\N	2026-10-31 06:57:58.391548+00	2026-10-31 06:57:58.464766+00
1b428e94-dc86-4434-bdd6-07e7b41c9ebd	cd8a2e3d-1839-4802-a654-08cdf79eb7cb	Variant A	VA	FIXED_AMOUNT	50.0000	f	\N	2026-10-31 06:57:58.513056+00	2026-10-31 06:57:58.585438+00
1c64c824-6536-4e25-b7ea-4ae90ccf9a6c	89b050d6-580f-4d2a-b3d5-e2302e098e0a	Premium Support	SUP	FIXED_AMOUNT	500.0000	t	\N	2026-10-31 07:01:04.176984+00	2026-10-31 07:01:04.176984+00
423a284a-ea87-415c-965d-7478c5c2dd99	dcadd733-135a-4805-b06b-b64fb797e0d4	Odoo Integration	ODOO	FIXED_AMOUNT	560.0000	t	\N	2026-10-31 07:01:04.484265+00	2026-10-31 07:01:04.484265+00
24677ada-6dfc-4079-88be-c503241c1818	dcadd733-135a-4805-b06b-b64fb797e0d4	Multi-Company	MCOMP	PERCENTAGE	15.0000	t	\N	2026-10-31 07:01:04.484265+00	2026-10-31 07:01:04.484265+00
be510b4d-686d-4fdd-a697-2560772dcb16	da10e298-6d0d-4547-a7f3-403e4900837e	Standard Edition	STD	FIXED_AMOUNT	0.0000	t	\N	2026-10-31 07:01:04.718922+00	2026-10-31 07:01:04.718922+00
6e8b7448-dfc6-4a25-8ac9-c07162db0c8e	da10e298-6d0d-4547-a7f3-403e4900837e	Premium Edition	PREM	FIXED_AMOUNT	1000.0000	t	\N	2026-10-31 07:01:04.718922+00	2026-10-31 07:01:04.718922+00
887d0e72-05f5-4794-8775-7edc39c55b03	da10e298-6d0d-4547-a7f3-403e4900837e	Enterprise Addon	ENT	PERCENTAGE	25.0000	t	\N	2026-10-31 07:01:04.786595+00	2026-10-31 07:01:04.786595+00
7e83e4b5-871d-4dd7-8bd6-081d90189851	af3e7ff0-ad14-4014-911c-29a00143c4c9	Pro Pack	PRO	PERCENTAGE	30.0000	t	\N	2026-10-31 07:01:04.987565+00	2026-10-31 07:01:05.054887+00
10c9d83a-c2f2-4e06-9bd1-9abba908535b	73fde76b-895e-448f-9937-68b57e886cec	Variant A	VA	FIXED_AMOUNT	50.0000	f	\N	2026-10-31 07:01:05.097802+00	2026-10-31 07:01:05.164967+00
9369f5a3-310b-4235-a2a3-f257bc8b50fe	2ad32ed2-97a9-4050-9215-98c7da066e2b	Premium Support	SUP	FIXED_AMOUNT	500.0000	t	\N	2026-10-31 07:01:41.163375+00	2026-10-31 07:01:41.163375+00
f24282e2-777b-4b11-bf3d-cd5a00498bb3	c77d4e45-cbef-4387-bd62-fbb9dda3a326	Odoo Integration	ODOO	FIXED_AMOUNT	560.0000	t	\N	2026-10-31 07:01:41.45576+00	2026-10-31 07:01:41.45576+00
85033796-a602-4126-b842-8b3329d193e8	c77d4e45-cbef-4387-bd62-fbb9dda3a326	Multi-Company	MCOMP	PERCENTAGE	15.0000	t	\N	2026-10-31 07:01:41.45576+00	2026-10-31 07:01:41.45576+00
c588cf51-5e14-445e-af7c-24a7f4c3ddf7	59cf8561-3fe4-4734-bbe2-95dba84775f9	Standard Edition	STD	FIXED_AMOUNT	0.0000	t	\N	2026-10-31 07:01:41.67762+00	2026-10-31 07:01:41.67762+00
6a4a5ed2-25ac-4f43-b1e1-762efe85d6ee	59cf8561-3fe4-4734-bbe2-95dba84775f9	Premium Edition	PREM	FIXED_AMOUNT	1000.0000	t	\N	2026-10-31 07:01:41.67762+00	2026-10-31 07:01:41.67762+00
67302c4c-d599-49f5-bc58-663c4491706e	59cf8561-3fe4-4734-bbe2-95dba84775f9	Enterprise Addon	ENT	PERCENTAGE	25.0000	t	\N	2026-10-31 07:01:41.743588+00	2026-10-31 07:01:41.743588+00
a7fc4a31-685c-42ba-a888-7621e16cce08	f01493de-49af-430b-a4c3-c4363e662aa0	Pro Pack	PRO	PERCENTAGE	30.0000	t	\N	2026-10-31 07:01:41.942969+00	2026-10-31 07:01:42.01415+00
38f2909c-1b14-4be0-9033-3fb9c37b8893	5c0fd786-581f-4a73-a82b-8963d1479d94	Variant A	VA	FIXED_AMOUNT	50.0000	f	\N	2026-10-31 07:01:42.058117+00	2026-10-31 07:01:42.128077+00
d29668bc-3460-4d77-abfc-51bec2a342ac	b22df97a-2fa6-449e-aafd-12ca0a45d15e	Premium Support	SUP	FIXED_AMOUNT	500.0000	t	\N	2026-10-31 07:24:21.416759+00	2026-10-31 07:24:21.416759+00
bad29ead-e771-460d-953a-8a09fa128dbf	b62c5ef2-e8a4-444e-854a-338a2b639bcc	Odoo Integration	ODOO	FIXED_AMOUNT	560.0000	t	\N	2026-10-31 07:24:21.714405+00	2026-10-31 07:24:21.714405+00
7a532abb-68a8-42e2-8a9c-77212b5ab45f	b62c5ef2-e8a4-444e-854a-338a2b639bcc	Multi-Company	MCOMP	PERCENTAGE	15.0000	t	\N	2026-10-31 07:24:21.714405+00	2026-10-31 07:24:21.714405+00
d66d823c-646e-4d29-8324-0d38e3427048	b49a17d4-223c-42ab-abbf-f8e658d82530	Standard Edition	STD	FIXED_AMOUNT	0.0000	t	\N	2026-10-31 07:24:21.938189+00	2026-10-31 07:24:21.938189+00
e44f953d-2002-424b-ae71-f63b4561cab9	b49a17d4-223c-42ab-abbf-f8e658d82530	Premium Edition	PREM	FIXED_AMOUNT	1000.0000	t	\N	2026-10-31 07:24:21.938189+00	2026-10-31 07:24:21.938189+00
1c142a8c-6173-4174-8df2-1fae3ea9c8fe	b49a17d4-223c-42ab-abbf-f8e658d82530	Enterprise Addon	ENT	PERCENTAGE	25.0000	t	\N	2026-10-31 07:24:21.994158+00	2026-10-31 07:24:21.994158+00
ec7fd122-b0e0-4f71-b1cc-1898ae07d7b3	20a46d09-18d3-43a7-87e9-ea6287e1cc29	Pro Pack	PRO	PERCENTAGE	30.0000	t	\N	2026-10-31 07:24:22.180328+00	2026-10-31 07:24:22.248062+00
9ce9c660-c379-475f-99e9-ad70d90e830a	f154b89e-3860-40f9-9a41-ae91a70b21d2	Variant A	VA	FIXED_AMOUNT	50.0000	f	\N	2026-10-31 07:24:22.289844+00	2026-10-31 07:24:22.362509+00
6fc9a4b4-1077-4a77-a69b-3c4a2741bc9f	186b4bbe-6fca-4f10-8817-a4b71efd0762	High-Concurrency Cluster Add-on	BL-CORE-HIGHCONCUR	FIXED_AMOUNT	15000.0000	t	Additional worker instances for sub-second webhook fan-out	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
fd5cbb88-555d-497a-ae46-b3d5ad896298	d5802e47-aede-48cb-8212-855361c869b8	Premium Support	SUP	FIXED_AMOUNT	500.0000	t	\N	2026-10-31 07:38:40.410335+00	2026-10-31 07:38:40.410335+00
3ab8bedc-c021-464a-83b5-e4d8a15754b5	c96bdd64-40ce-40fc-a165-2ff67e37088e	Odoo Integration	ODOO	FIXED_AMOUNT	560.0000	t	\N	2026-10-31 07:38:40.710591+00	2026-10-31 07:38:40.710591+00
73b12ae1-55cf-49b1-b815-c17c883aa66d	c96bdd64-40ce-40fc-a165-2ff67e37088e	Multi-Company	MCOMP	PERCENTAGE	15.0000	t	\N	2026-10-31 07:38:40.710591+00	2026-10-31 07:38:40.710591+00
e701f190-a116-47cf-a73f-6996264d9f9f	ccc3244e-bd3a-4ccf-9b7e-55060b9cec92	Standard Edition	STD	FIXED_AMOUNT	0.0000	t	\N	2026-10-31 07:38:40.943603+00	2026-10-31 07:38:40.943603+00
02fb92be-f163-426f-ab8c-82431682d514	ccc3244e-bd3a-4ccf-9b7e-55060b9cec92	Premium Edition	PREM	FIXED_AMOUNT	1000.0000	t	\N	2026-10-31 07:38:40.943603+00	2026-10-31 07:38:40.943603+00
06303433-bc3b-4d4f-979e-277003ab1aad	ccc3244e-bd3a-4ccf-9b7e-55060b9cec92	Enterprise Addon	ENT	PERCENTAGE	25.0000	t	\N	2026-10-31 07:38:41.011486+00	2026-10-31 07:38:41.011486+00
8defbe56-c536-4704-ba6f-f8c17666cfa0	e54b5f0a-5d7e-4477-add3-ca6039fd8723	Pro Pack	PRO	PERCENTAGE	30.0000	t	\N	2026-10-31 07:38:41.207953+00	2026-10-31 07:38:41.291098+00
c061b2f3-abb8-494c-9177-bb3c19cb63b7	0c0bf333-9976-4b9c-ae78-70e1bd9fddc4	Variant A	VA	FIXED_AMOUNT	50.0000	f	\N	2026-10-31 07:38:41.337753+00	2026-10-31 07:38:41.408063+00
d0505c31-1a18-4121-abc7-dc5d5170262b	f8fb9c0c-8135-427d-a119-1af9ce6e9a02	Premium Support	SUP	FIXED_AMOUNT	500.0000	t	\N	2026-10-31 08:24:20.06928+00	2026-10-31 08:24:20.06928+00
97f243d0-a14b-4006-86cd-10dd4f1640e2	d9d4cfa1-d7ff-4475-81ef-aacf2209bae8	Odoo Integration	ODOO	FIXED_AMOUNT	560.0000	t	\N	2026-10-31 08:24:20.357187+00	2026-10-31 08:24:20.357187+00
cdf44a25-44b0-4f23-8bb2-2f87dc99493b	d9d4cfa1-d7ff-4475-81ef-aacf2209bae8	Multi-Company	MCOMP	PERCENTAGE	15.0000	t	\N	2026-10-31 08:24:20.357187+00	2026-10-31 08:24:20.357187+00
2b345a5e-f517-463d-a260-f66f99970b60	ca9093a9-8946-45d9-9f7c-0fed270ee1b7	Standard Edition	STD	FIXED_AMOUNT	0.0000	t	\N	2026-10-31 08:24:20.593607+00	2026-10-31 08:24:20.593607+00
6b24c4db-63fc-48da-83c7-253559ebb787	ca9093a9-8946-45d9-9f7c-0fed270ee1b7	Premium Edition	PREM	FIXED_AMOUNT	1000.0000	t	\N	2026-10-31 08:24:20.593607+00	2026-10-31 08:24:20.593607+00
d21571c0-2316-4fd5-ab99-c1a7853fa5d4	ca9093a9-8946-45d9-9f7c-0fed270ee1b7	Enterprise Addon	ENT	PERCENTAGE	25.0000	t	\N	2026-10-31 08:24:20.66303+00	2026-10-31 08:24:20.66303+00
d62c2f56-26d5-405a-9cff-076773776786	1da1085b-388e-42ba-a756-8d3905e1119b	Pro Pack	PRO	PERCENTAGE	30.0000	t	\N	2026-10-31 08:24:20.786671+00	2026-10-31 08:24:20.86472+00
de329838-0631-4665-9d7d-8fce07dcedd5	5a501b7e-5295-4719-8c88-20c5ffcced35	Variant A	VA	FIXED_AMOUNT	50.0000	f	\N	2026-10-31 08:24:20.912848+00	2026-10-31 08:24:20.990176+00
aff6e660-492c-4e6a-930a-cdce8d4bd68f	ba0da014-b338-4921-8cf2-e19f2f4fdcae	Premium Support	SUP	FIXED_AMOUNT	500.0000	t	\N	2026-10-31 08:27:45.940944+00	2026-10-31 08:27:45.940944+00
2b5a7780-8c0f-444e-87e7-542ac1da4e2f	93bfd89e-bc60-47c0-b494-e9b010980df0	Odoo Integration	ODOO	FIXED_AMOUNT	560.0000	t	\N	2026-10-31 08:27:46.266357+00	2026-10-31 08:27:46.266357+00
b4467832-9761-460c-b909-5261365f6018	93bfd89e-bc60-47c0-b494-e9b010980df0	Multi-Company	MCOMP	PERCENTAGE	15.0000	t	\N	2026-10-31 08:27:46.266357+00	2026-10-31 08:27:46.266357+00
a8de6386-3edb-4195-9cdc-f052e9cb84ad	f3c4dab1-cf3f-43eb-80f2-f7ddedf00f64	Standard Edition	STD	FIXED_AMOUNT	0.0000	t	\N	2026-10-31 08:27:46.518896+00	2026-10-31 08:27:46.518896+00
f003c6b6-45e5-4dd1-b60e-2d1a52f58c77	f3c4dab1-cf3f-43eb-80f2-f7ddedf00f64	Premium Edition	PREM	FIXED_AMOUNT	1000.0000	t	\N	2026-10-31 08:27:46.518896+00	2026-10-31 08:27:46.518896+00
ac708356-f298-4520-8b1d-0914a7baae33	f3c4dab1-cf3f-43eb-80f2-f7ddedf00f64	Enterprise Addon	ENT	PERCENTAGE	25.0000	t	\N	2026-10-31 08:27:46.585484+00	2026-10-31 08:27:46.585484+00
3691cf50-db68-4305-96c2-c8bca1333fee	6105c5e6-fce7-4f05-ab91-8fde170061c9	Pro Pack	PRO	PERCENTAGE	30.0000	t	\N	2026-10-31 08:27:46.787751+00	2026-10-31 08:27:46.870078+00
390e2722-02a8-4158-b900-e4ea80e32da5	aed404df-5e24-47b3-b798-72d9daea4654	Variant A	VA	FIXED_AMOUNT	50.0000	f	\N	2026-10-31 08:27:46.928905+00	2026-10-31 08:27:47.030924+00
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: brightloop_user
--

COPY public.products (id, name, sku, product_type, description, notes, sales_price, cost_price, currency, is_active, is_archived, created_by_id, updated_by_id, created_at, updated_at) FROM stdin;
04f99474-55d2-40d1-9f94-1a6801714aa9	Brightloop ERP Cloud	SKU-65297C	SOFTWARE	Enterprise cloud accounting and subscription platform	\N	2000.0000	500.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:09:09.211336+00	2026-10-31 06:09:09.211336+00
fecd3eea-595f-4f74-9950-501860332150	History Test Product	HIST-507D7C	SOFTWARE	\N	\N	1000.0000	300.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:09:09.457432+00	2026-10-31 06:09:09.457432+00
7cee942d-916e-4554-97ca-d3f431fcdae6	Brightloop ERP Cloud	SKU-0E9912	SOFTWARE	Enterprise cloud accounting and subscription platform	\N	2000.0000	500.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:11:22.986832+00	2026-10-31 06:11:22.986832+00
8a67e854-290f-4c20-bf43-531932afd4ae	Admin Product	RBAC-9655B5	ADDON	\N	\N	500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:11:23.194565+00	2026-10-31 06:11:23.194565+00
526f5031-c01b-47e1-9931-12d6f9bcdd29	History Test Product	HIST-61CAE9	SOFTWARE	\N	\N	1500.0000	450.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:11:23.264967+00	2026-10-31 06:11:23.298861+00
36f00791-876c-4b44-be3c-1d4cede92e5b	To Archive Product	ARCH-D8B80E	PHYSICAL_PRODUCT	\N	\N	750.0000	\N	INR	f	t	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:11:23.388354+00	2026-10-31 06:11:23.422626+00
6ef0bb02-187d-4513-9122-eaa480de77bf	INR Service	INR-B8169D	SOFTWARE	\N	\N	1000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:11:29.778543+00	2026-10-31 06:11:29.778543+00
c042ca25-b44c-480c-87c6-c073a654cf9a	USD Service	USD-9FE080	SOFTWARE	\N	\N	50.0000	\N	USD	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:11:29.824637+00	2026-10-31 06:11:29.824637+00
969a867e-b20a-4c5f-b1b5-f0cfe67a5bb1	Base Software	BASE-3FD745	SOFTWARE	\N	\N	3000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:11:30.060245+00	2026-10-31 06:11:30.060245+00
688622e3-2494-4fde-90d4-78107b647e2e	Auto Close Product	AC-57D9FF	SOFTWARE	\N	\N	1500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:11:30.379504+00	2026-10-31 06:11:30.379504+00
121eaa2b-9e29-4c21-947f-9a2d28de1b57	CRM Software	CRM-3B5AF2	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:11:30.61083+00	2026-10-31 06:11:30.61083+00
2465ee22-301b-433a-a7d9-69e023d2a19f	INR Service	INR-5FAAF3	SOFTWARE	\N	\N	1000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:12:45.19549+00	2026-10-31 06:12:45.19549+00
9f4e11a1-974c-45c7-9b4f-9723e768ae0a	USD Service	USD-EC2A8D	SOFTWARE	\N	\N	50.0000	\N	USD	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:12:45.237544+00	2026-10-31 06:12:45.237544+00
8ed7bc01-3a16-47e8-9ead-150ad6535e7e	Auto Close Product	AC-CD14A6	SOFTWARE	\N	\N	1500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:12:45.884736+00	2026-10-31 06:12:45.884736+00
9ebfdf67-a925-40e8-93fe-8666a6d59fbd	CRM Software	CRM-3F6A7B	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:12:46.235778+00	2026-10-31 06:12:46.235778+00
861ae7ab-d090-419b-9955-d4663145fc15	INR Service	INR-8576D9	SOFTWARE	\N	\N	1000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:12:59.638933+00	2026-10-31 06:12:59.638933+00
eb1965b5-8923-4f65-8ac9-3943b4d5cd1d	USD Service	USD-90D405	SOFTWARE	\N	\N	50.0000	\N	USD	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:12:59.680451+00	2026-10-31 06:12:59.680451+00
04e41d81-94e0-4b86-a71b-db756e3f224c	Base Software	BASE-ADE7E9	SOFTWARE	\N	\N	3000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:12:59.861116+00	2026-10-31 06:12:59.861116+00
79144eb3-21f8-490f-bd46-ac454693355f	Auto Close Product	AC-360675	SOFTWARE	\N	\N	1500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:00.078228+00	2026-10-31 06:13:00.078228+00
dba660b1-6890-47b4-9aa1-923db0f660af	CRM Software	CRM-1F79B2	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:00.313423+00	2026-10-31 06:13:00.313423+00
0399f8a6-2a2e-4fe4-aab1-c06d51fc6f84	INR Service	INR-5504F9	SOFTWARE	\N	\N	1000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:20.9046+00	2026-10-31 06:13:20.9046+00
178c904f-9799-4510-80a3-0369ac205548	USD Service	USD-1B2AEB	SOFTWARE	\N	\N	50.0000	\N	USD	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:20.946015+00	2026-10-31 06:13:20.946015+00
63e331fa-ccfe-48a4-99a2-71cd3d362192	Base Software	BASE-51CE58	SOFTWARE	\N	\N	3000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:21.13612+00	2026-10-31 06:13:21.13612+00
a73fe521-614b-4045-b1fa-6cbb5b177ec1	Auto Close Product	AC-E03589	SOFTWARE	\N	\N	1500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:21.35121+00	2026-10-31 06:13:21.35121+00
6fe79193-857b-4c53-b7ec-be99fe2247d1	CRM Software	CRM-7A3073	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:21.502324+00	2026-10-31 06:13:21.502324+00
af3fd5b5-b681-402e-8575-5ffd9b88f130	ERP Financials	ERP-ED850A	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:28.044234+00	2026-10-31 06:13:28.044234+00
321df9e4-d590-466f-9521-5937cdff48d3	Standard Software	SW-81EFB2	SOFTWARE	\N	\N	5000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:28.181489+00	2026-10-31 06:13:28.181489+00
9acc2664-1ed1-4b32-b7d0-6879f0911497	INR Product	INR-3ABC9B	SOFTWARE	\N	\N	100.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:28.243043+00	2026-10-31 06:13:28.243043+00
a6135f0d-9e90-41a4-b131-b000633d2464	ERP Financials	ERP-28F5B7	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:42.969597+00	2026-10-31 06:13:42.969597+00
32ed9f4b-3646-4de1-8d31-51a566d18f6a	Standard Software	SW-22646A	SOFTWARE	\N	\N	5000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:43.0766+00	2026-10-31 06:13:43.0766+00
08548eb4-b59f-4b5c-b05e-646ca08e643c	INR Product	INR-310E2C	SOFTWARE	\N	\N	100.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:43.133947+00	2026-10-31 06:13:43.133947+00
358dac3d-dac5-49aa-aa87-02e1382ee3bb	INR Service	INR-25BE9E	SOFTWARE	\N	\N	1000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:50.870471+00	2026-10-31 06:13:50.870471+00
09020a22-da2c-4da8-b6b0-8f371b2dc361	USD Service	USD-EA4AF2	SOFTWARE	\N	\N	50.0000	\N	USD	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:50.902008+00	2026-10-31 06:13:50.902008+00
e76fe912-75c8-45d2-9051-5d5cc3dd8f1e	Base Software	BASE-240CB1	SOFTWARE	\N	\N	3000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:51.070842+00	2026-10-31 06:13:51.070842+00
6fa297e4-67e6-4d76-9c5c-c502ecf1ea18	Auto Close Product	AC-F6DD88	SOFTWARE	\N	\N	1500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:51.304615+00	2026-10-31 06:13:51.304615+00
04373e00-7bd0-4ff4-aab7-e964ad3db065	CRM Software	CRM-51660B	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:51.455491+00	2026-10-31 06:13:51.455491+00
7c6f805a-640e-4ecc-978e-7901e5586d3b	ERP Financials	ERP-C611B4	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:51.73966+00	2026-10-31 06:13:51.73966+00
edc1c0b2-f0bf-44f9-8f33-8a7dbeb41a2e	Standard Software	SW-DE75CB	SOFTWARE	\N	\N	5000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:51.824624+00	2026-10-31 06:13:51.824624+00
43a13440-84e9-4ad7-bebf-7fdbb5001fb8	INR Product	INR-602C73	SOFTWARE	\N	\N	100.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:51.881627+00	2026-10-31 06:13:51.881627+00
f05e44c4-d451-4a45-89ef-63044010ffb3	Brightloop ERP Cloud	SKU-38E5BF	SOFTWARE	Enterprise cloud accounting and subscription platform	\N	2000.0000	500.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:51.950086+00	2026-10-31 06:13:51.950086+00
f6557609-20bd-4660-99ac-ddaca5c790a8	Admin Product	RBAC-BC7A10	ADDON	\N	\N	500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:52.113599+00	2026-10-31 06:13:52.113599+00
4f1193b4-eaae-45eb-86c7-8fa397deba44	History Test Product	HIST-70AF6B	SOFTWARE	\N	\N	1500.0000	450.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:52.170244+00	2026-10-31 06:13:52.197517+00
e4211d2a-d133-4063-a34f-f874d9f95e86	To Archive Product	ARCH-B14899	PHYSICAL_PRODUCT	\N	\N	750.0000	\N	INR	f	t	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:52.271187+00	2026-10-31 06:13:52.302442+00
1f9dfc87-7c86-463e-b39c-02772e22a98a	INR Service	INR-D22377	SOFTWARE	\N	\N	1000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:26:02.428427+00	2026-10-31 06:26:02.428427+00
f60e9831-d881-4d3d-9f4d-c2e498fd1936	USD Service	USD-E2E4C5	SOFTWARE	\N	\N	50.0000	\N	USD	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:26:02.46143+00	2026-10-31 06:26:02.46143+00
d5bbca6b-8ff8-4282-9156-303ae81f081d	Base Software	BASE-740480	SOFTWARE	\N	\N	3000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:26:02.632078+00	2026-10-31 06:26:02.632078+00
2a6ac91d-0ff8-4157-80a7-5f3426f49ad3	Auto Close Product	AC-ADBADD	SOFTWARE	\N	\N	1500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:26:02.834952+00	2026-10-31 06:26:02.834952+00
d6d87563-ae37-492a-b2e0-942bb7b70a12	CRM Software	CRM-ADF403	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:26:02.973651+00	2026-10-31 06:26:02.973651+00
2bcd0897-91e7-4ced-aa4d-e38791d0ac93	ERP Financials	ERP-88400D	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:26:03.238769+00	2026-10-31 06:26:03.238769+00
3d343c77-1349-4c87-aaf6-ef9bdcdcf562	Standard Software	SW-A30EEC	SOFTWARE	\N	\N	5000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:26:03.317992+00	2026-10-31 06:26:03.317992+00
2a0b1bde-ad3b-413a-b5cc-a9e481dab438	INR Product	INR-84E728	SOFTWARE	\N	\N	100.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:26:03.379057+00	2026-10-31 06:26:03.379057+00
a308717f-0607-4833-859f-42b9407e171b	Brightloop ERP Cloud	SKU-C3CB5A	SOFTWARE	Enterprise cloud accounting and subscription platform	\N	2000.0000	500.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:26:03.451849+00	2026-10-31 06:26:03.451849+00
9bbac0ae-0433-4cd3-8bbc-77756a37a057	Admin Product	RBAC-83ABDA	ADDON	\N	\N	500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:26:03.626045+00	2026-10-31 06:26:03.626045+00
455a8b2f-dcc1-4aac-9413-33465f3173e5	History Test Product	HIST-F9F53B	SOFTWARE	\N	\N	1500.0000	450.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:26:03.696165+00	2026-10-31 06:26:03.725792+00
cd326af2-56c6-4257-a9be-36963a814ea0	To Archive Product	ARCH-749820	PHYSICAL_PRODUCT	\N	\N	750.0000	\N	INR	f	t	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:26:03.799583+00	2026-10-31 06:26:03.827721+00
1f276a0d-edd6-453c-ae2b-47c28fb3eb96	INR Service	INR-A35493	SOFTWARE	\N	\N	1000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:56:46.286958+00	2026-10-31 06:56:46.286958+00
c8c73b82-9167-4008-a67d-3fc77a8b51ad	USD Service	USD-7462F9	SOFTWARE	\N	\N	50.0000	\N	USD	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:56:46.324005+00	2026-10-31 06:56:46.324005+00
8194a38c-c919-47f3-88d2-e11ad42b8d01	Base Software	BASE-B3F084	SOFTWARE	\N	\N	3000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:56:46.509591+00	2026-10-31 06:56:46.509591+00
2753c50b-661b-4631-ba1f-0e4cb7c3bcea	Auto Close Product	AC-588CE6	SOFTWARE	\N	\N	1500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:56:46.737755+00	2026-10-31 06:56:46.737755+00
1bd42398-2250-4041-94de-21a445c29ff2	CRM Software	CRM-355AB3	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:56:46.892346+00	2026-10-31 06:56:46.892346+00
99426a0c-726c-4c52-a8ee-1db8061495de	ERP Financials	ERP-664F6A	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:56:47.179122+00	2026-10-31 06:56:47.179122+00
cdebf907-a043-424b-88a6-35f300fec891	Standard Software	SW-A3F9F5	SOFTWARE	\N	\N	5000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:56:47.269995+00	2026-10-31 06:56:47.269995+00
f9eeb635-8cd6-4569-a539-23fac41fcd29	INR Product	INR-60E80A	SOFTWARE	\N	\N	100.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:56:47.333192+00	2026-10-31 06:56:47.333192+00
e55e63cc-b037-406a-a7f2-6843e840c190	Brightloop ERP Cloud	SKU-3EA127	SOFTWARE	Enterprise cloud accounting and subscription platform	\N	2000.0000	500.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:56:47.412714+00	2026-10-31 06:56:47.412714+00
7550f7f8-4c9c-4ea5-9602-4cf0a0237da9	Admin Product	RBAC-377BB8	ADDON	\N	\N	500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:56:47.604436+00	2026-10-31 06:56:47.604436+00
2f29e6e9-36db-40c5-aeb4-8363d6384102	History Test Product	HIST-8A2D2C	SOFTWARE	\N	\N	1500.0000	450.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:56:47.677206+00	2026-10-31 06:56:47.71192+00
552aec1f-af4b-4a87-a336-0f45a07a662e	To Archive Product	ARCH-577F09	PHYSICAL_PRODUCT	\N	\N	750.0000	\N	INR	f	t	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:56:47.789903+00	2026-10-31 06:56:47.822005+00
27c92d51-b12b-4c5e-b05a-4bb416e31ea4	Cloud Security Suite	SEC-E1AC4	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:57:56.679875+00	2026-10-31 06:57:56.679875+00
26f84f34-1499-418a-96e0-bc6600944e48	INR Service	INR-A58921	SOFTWARE	\N	\N	1000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:57:56.97341+00	2026-10-31 06:57:56.97341+00
e3a078ec-80ca-4ea1-bea2-363927191966	USD Service	USD-0B73E7	SOFTWARE	\N	\N	50.0000	\N	USD	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:57:57.002483+00	2026-10-31 06:57:57.002483+00
d83d7b84-4d47-426e-8b1b-b7e3a99a02d3	Base Software	BASE-999E56	SOFTWARE	\N	\N	3000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:57:57.197927+00	2026-10-31 06:57:57.197927+00
2641368d-ece5-41b8-98d6-50367dafc985	Auto Close Product	AC-26A1C7	SOFTWARE	\N	\N	1500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:57:57.419779+00	2026-10-31 06:57:57.419779+00
2ce2ddd9-fbfc-4ed4-8d98-80e4f09b97f6	CRM Software	CRM-A27282	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:57:57.583235+00	2026-10-31 06:57:57.583235+00
f584e165-c6aa-49ef-8f1c-e85c6c6ef708	ERP Financials	ERP-40B008	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:57:57.889803+00	2026-10-31 06:57:57.889803+00
79fec419-75c1-4edf-81d6-a288b3755330	Standard Software	SW-023B7E	SOFTWARE	\N	\N	5000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:57:57.977655+00	2026-10-31 06:57:57.977655+00
59b29da9-cc1e-498a-b178-ab4465418044	INR Product	INR-CCA9AF	SOFTWARE	\N	\N	100.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:57:58.042303+00	2026-10-31 06:57:58.042303+00
b424bbf3-e5ba-4fff-952c-09798d164e6f	Brightloop ERP Cloud	SKU-7B8F84	SOFTWARE	Enterprise cloud accounting and subscription platform	\N	2000.0000	500.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:57:58.121428+00	2026-10-31 06:57:58.121428+00
129fd1cb-d109-4b96-97f2-b00736810e4b	Admin Product	RBAC-8868B7	ADDON	\N	\N	500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:57:58.321459+00	2026-10-31 06:57:58.321459+00
6efd9ced-9483-4f1a-a825-1e060928e307	History Test Product	HIST-07916E	SOFTWARE	\N	\N	1500.0000	450.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:57:58.391548+00	2026-10-31 06:57:58.42399+00
cd8a2e3d-1839-4802-a654-08cdf79eb7cb	To Archive Product	ARCH-8C8462	PHYSICAL_PRODUCT	\N	\N	750.0000	\N	INR	f	t	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:57:58.513056+00	2026-10-31 06:57:58.549589+00
56739bff-c037-4087-95b3-bb4c35c05732	Cloud CRM Platform	PROD-SUB-094FC	SOFTWARE	\N	\N	5000.0000	1000.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:57:58.850321+00	2026-10-31 06:57:58.850321+00
ec449749-6f32-41e4-ac37-bcfcdffb15aa	Cloud Security Suite	SEC-EC79A	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:03.222637+00	2026-10-31 07:01:03.222637+00
1a7b37b3-13b2-47a3-ad9e-59476f54fde4	INR Service	INR-B4AE55	SOFTWARE	\N	\N	1000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:03.585235+00	2026-10-31 07:01:03.585235+00
dbb65843-0e0b-43ba-9f98-c849f4c084e7	USD Service	USD-313AC1	SOFTWARE	\N	\N	50.0000	\N	USD	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:03.613693+00	2026-10-31 07:01:03.613693+00
aec1dd88-b055-432e-b06e-f5ff5c1b646d	Base Software	BASE-CF9C26	SOFTWARE	\N	\N	3000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:03.787789+00	2026-10-31 07:01:03.787789+00
4ba0da92-15b8-40b9-b909-6d56804c20a5	Auto Close Product	AC-294B31	SOFTWARE	\N	\N	1500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:04.012099+00	2026-10-31 07:01:04.012099+00
89b050d6-580f-4d2a-b3d5-e2302e098e0a	CRM Software	CRM-439A29	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:04.176984+00	2026-10-31 07:01:04.176984+00
dcadd733-135a-4805-b06b-b64fb797e0d4	ERP Financials	ERP-F2401C	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:04.484265+00	2026-10-31 07:01:04.484265+00
bff5887a-24e0-49bf-bf0e-06a8e356708c	Standard Software	SW-0A1A8E	SOFTWARE	\N	\N	5000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:04.572516+00	2026-10-31 07:01:04.572516+00
80c46f8b-f67a-4adb-a093-adecd4aaf89f	INR Product	INR-86A747	SOFTWARE	\N	\N	100.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:04.636933+00	2026-10-31 07:01:04.636933+00
da10e298-6d0d-4547-a7f3-403e4900837e	Brightloop ERP Cloud	SKU-F12635	SOFTWARE	Enterprise cloud accounting and subscription platform	\N	2000.0000	500.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:04.718922+00	2026-10-31 07:01:04.718922+00
244411b9-f877-4e5e-b38e-6667d74a54c8	Admin Product	RBAC-68379E	ADDON	\N	\N	500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:04.916884+00	2026-10-31 07:01:04.916884+00
af3e7ff0-ad14-4014-911c-29a00143c4c9	History Test Product	HIST-597567	SOFTWARE	\N	\N	1500.0000	450.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:04.987565+00	2026-10-31 07:01:05.021061+00
73fde76b-895e-448f-9937-68b57e886cec	To Archive Product	ARCH-EA187B	PHYSICAL_PRODUCT	\N	\N	750.0000	\N	INR	f	t	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:05.097802+00	2026-10-31 07:01:05.129126+00
dda6994b-3b5c-468d-817c-fe2a53ce5ec3	Cloud CRM Platform	PROD-SUB-E2F3B	SOFTWARE	\N	\N	5000.0000	1000.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:05.403993+00	2026-10-31 07:01:05.403993+00
cd07bdd3-8925-4e1c-8754-a33b7b02246c	Cloud Security Suite	SEC-6664B	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:38.870784+00	2026-10-31 07:01:38.870784+00
854ebbc5-1efb-41a4-8fa2-16cf3c26a41b	INR Service	INR-52B877	SOFTWARE	\N	\N	1000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:40.521617+00	2026-10-31 07:01:40.521617+00
d84397f9-160d-40ba-ac60-58cd088d5c5f	USD Service	USD-9D1F84	SOFTWARE	\N	\N	50.0000	\N	USD	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:40.572892+00	2026-10-31 07:01:40.572892+00
feaed8df-addd-425d-9ed2-ecfaf1340189	Base Software	BASE-5A56A1	SOFTWARE	\N	\N	3000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:40.747253+00	2026-10-31 07:01:40.747253+00
5d320af8-6a44-4f17-a7b2-33fc4de8fc75	Auto Close Product	AC-16FB68	SOFTWARE	\N	\N	1500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:41.012002+00	2026-10-31 07:01:41.012002+00
2ad32ed2-97a9-4050-9215-98c7da066e2b	CRM Software	CRM-7D041C	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:41.163375+00	2026-10-31 07:01:41.163375+00
c77d4e45-cbef-4387-bd62-fbb9dda3a326	ERP Financials	ERP-B0A7CE	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:41.45576+00	2026-10-31 07:01:41.45576+00
af5076dc-fb4c-45c7-9a5f-bbd5ceaa40fa	Standard Software	SW-13CD7A	SOFTWARE	\N	\N	5000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:41.539605+00	2026-10-31 07:01:41.539605+00
fd73a7e4-f39d-4e1b-9fe3-da976679b1bc	INR Product	INR-C3E965	SOFTWARE	\N	\N	100.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:41.604242+00	2026-10-31 07:01:41.604242+00
59cf8561-3fe4-4734-bbe2-95dba84775f9	Brightloop ERP Cloud	SKU-F3D98A	SOFTWARE	Enterprise cloud accounting and subscription platform	\N	2000.0000	500.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:41.67762+00	2026-10-31 07:01:41.67762+00
d87788ef-ad41-4620-b2f2-d03d7a71db46	Admin Product	RBAC-19EA09	ADDON	\N	\N	500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:41.869698+00	2026-10-31 07:01:41.869698+00
f01493de-49af-430b-a4c3-c4363e662aa0	History Test Product	HIST-C15172	SOFTWARE	\N	\N	1500.0000	450.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:41.942969+00	2026-10-31 07:01:41.977332+00
5c0fd786-581f-4a73-a82b-8963d1479d94	To Archive Product	ARCH-CBC8F7	PHYSICAL_PRODUCT	\N	\N	750.0000	\N	INR	f	t	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:42.058117+00	2026-10-31 07:01:42.0907+00
c48f1d45-bed4-411a-a422-daed07f89681	Cloud CRM Platform	PROD-SUB-DBAB3	SOFTWARE	\N	\N	5000.0000	1000.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:42.381422+00	2026-10-31 07:01:42.381422+00
edbb467f-ee59-4f31-94aa-588b436d4eaa	Cloud Security Suite	SEC-AA770	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:24:19.120917+00	2026-10-31 07:24:19.120917+00
8e39b9d6-f2be-477f-89b8-2d6840dc802b	INR Service	INR-65A231	SOFTWARE	\N	\N	1000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:24:20.816328+00	2026-10-31 07:24:20.816328+00
3efeb345-1ddd-42e3-b156-f5dd8b3e3a9e	USD Service	USD-420C87	SOFTWARE	\N	\N	50.0000	\N	USD	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:24:20.850565+00	2026-10-31 07:24:20.850565+00
23cb2b12-e720-4012-b44a-98da5b5c9b9d	Base Software	BASE-9E4051	SOFTWARE	\N	\N	3000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:24:21.030442+00	2026-10-31 07:24:21.030442+00
d04c4ec8-e918-490e-8571-b56018b0c3ca	Auto Close Product	AC-953014	SOFTWARE	\N	\N	1500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:24:21.251941+00	2026-10-31 07:24:21.251941+00
b22df97a-2fa6-449e-aafd-12ca0a45d15e	CRM Software	CRM-60072A	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:24:21.416759+00	2026-10-31 07:24:21.416759+00
b62c5ef2-e8a4-444e-854a-338a2b639bcc	ERP Financials	ERP-9B128F	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:24:21.714405+00	2026-10-31 07:24:21.714405+00
de41995c-95e2-44be-b6b6-1c22ddb11d9d	Standard Software	SW-523E7D	SOFTWARE	\N	\N	5000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:24:21.795659+00	2026-10-31 07:24:21.795659+00
b2291501-041e-4f78-9499-424109c6f3a6	INR Product	INR-CEE61D	SOFTWARE	\N	\N	100.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:24:21.862488+00	2026-10-31 07:24:21.862488+00
b49a17d4-223c-42ab-abbf-f8e658d82530	Brightloop ERP Cloud	SKU-ADEBDC	SOFTWARE	Enterprise cloud accounting and subscription platform	\N	2000.0000	500.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:24:21.938189+00	2026-10-31 07:24:21.938189+00
18a5cd0c-9068-42b0-b42d-453881b90fe3	Admin Product	RBAC-E40A38	ADDON	\N	\N	500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:24:22.111094+00	2026-10-31 07:24:22.111094+00
20a46d09-18d3-43a7-87e9-ea6287e1cc29	History Test Product	HIST-CD6C64	SOFTWARE	\N	\N	1500.0000	450.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:24:22.180328+00	2026-10-31 07:24:22.212534+00
f154b89e-3860-40f9-9a41-ae91a70b21d2	To Archive Product	ARCH-D2E3DC	PHYSICAL_PRODUCT	\N	\N	750.0000	\N	INR	f	t	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:24:22.289844+00	2026-10-31 07:24:22.325343+00
37387601-cec8-4c66-b427-84f6104b528c	Cloud CRM Platform	PROD-SUB-4007D	SOFTWARE	\N	\N	5000.0000	1000.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:24:22.612997+00	2026-10-31 07:24:22.612997+00
186b4bbe-6fca-4f10-8817-a4b71efd0762	Brightloop Enterprise Core Platform	BL-CORE-01	SOFTWARE	Multi-tenant subscription engine, billing automation, and webhook infrastructure.	Includes 99.9% uptime SLA.	49999.0000	15000.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
48db2113-98c2-44bb-8fb5-491a6e75ddfd	Advanced Billing Intelligence & Churn Predictor	BL-ADDON-AI	ADDON	ML-driven revenue leak detection and automated dunning workflows.	Integrates directly with payment gateways.	19999.0000	5000.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
ebc4abad-f5e7-4644-9567-8d7fdad06fd4	24/7 Dedicated Enterprise Support & Solutions Architect	BL-SRV-SLA	ADDON	Dedicated Technical Account Manager and 1-hour critical response SLA.	Billed annually or monthly alongside core platform.	15000.0000	8000.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
942c213b-7840-4549-aa89-94c83ee4842a	Audit Analytics Suite dbbe98	AUD-SKU-DBBE98	SOFTWARE	\N	\N	50000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:35:20.586873+00	2026-10-31 07:35:20.586873+00
401ad69d-e929-4555-87ce-ff5b306799a8	Qty Test Product fea26e	QTY-FEA26E	SOFTWARE	\N	\N	100.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:35:21.108966+00	2026-10-31 07:35:21.108966+00
77f7a1a1-923b-4307-b433-b3653d77faf2	Overlap Prod 20b80a	OVL-20B80A	SOFTWARE	\N	\N	1000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:35:21.722144+00	2026-10-31 07:35:21.722144+00
ddac571a-50c8-46a7-aae6-c9699a912456	OP Prod b78a98	OP-B78A98	SOFTWARE	\N	\N	1000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:35:22.240495+00	2026-10-31 07:35:22.240495+00
996e7e31-9bc8-4564-9457-8ca7927dfb84	Neg9 Prod 2a13bb	NEG9-2A13BB	SOFTWARE	\N	\N	500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:35:22.854986+00	2026-10-31 07:35:22.854986+00
39e2f841-cf98-4c62-809a-d941b1637c23	Audit Analytics Suite 3a32a8	AUD-SKU-3A32A8	SOFTWARE	\N	\N	50000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:29.332951+00	2026-10-31 07:37:29.332951+00
62d13717-1a0d-4a1d-b4fd-71cf741c8ba5	Qty Test Product ef54ca	QTY-EF54CA	SOFTWARE	\N	\N	100.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:31.367084+00	2026-10-31 07:37:31.367084+00
683a33cf-43e1-4b69-adc0-50512d118c91	Overlap Prod 0531ca	OVL-0531CA	SOFTWARE	\N	\N	1000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:31.962817+00	2026-10-31 07:37:31.962817+00
b37d638a-f942-49d6-8e03-68859649bc3a	OP Prod ffee42	OP-FFEE42	SOFTWARE	\N	\N	1000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:32.526056+00	2026-10-31 07:37:32.526056+00
a1eae06d-1777-4cb6-b063-6a2580b8a280	Neg9 Prod 18b7b5	NEG9-18B7B5	SOFTWARE	\N	\N	500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:33.415205+00	2026-10-31 07:37:33.415205+00
53b00a01-c903-4f64-9e72-5088c4c0e028	Audit Analytics Suite 2c1132	AUD-SKU-2C1132	SOFTWARE	\N	\N	50000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:18.399867+00	2026-10-31 07:38:18.399867+00
a98b731e-2a49-4e70-85b8-405fbc73f791	Qty Test Product 2446fd	QTY-2446FD	SOFTWARE	\N	\N	100.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:20.532174+00	2026-10-31 07:38:20.532174+00
ed0db0d3-c8a8-4bc2-ac69-92b127dcbd38	Overlap Prod fb54d3	OVL-FB54D3	SOFTWARE	\N	\N	1000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:21.148112+00	2026-10-31 07:38:21.148112+00
db17cf02-d6b1-4db4-a8e9-5bf25f5a34f1	OP Prod de242a	OP-DE242A	SOFTWARE	\N	\N	1000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:21.96493+00	2026-10-31 07:38:21.96493+00
650bdf95-c3b6-4a92-955b-9551fb73a316	Neg9 Prod ba08be	NEG9-BA08BE	SOFTWARE	\N	\N	500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:23.067316+00	2026-10-31 07:38:23.067316+00
7fc3f342-51f1-4164-8bae-dfa344fbf476	Audit Analytics Suite 4492ce	AUD-SKU-4492CE	SOFTWARE	\N	\N	50000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:32.70076+00	2026-10-31 07:38:32.70076+00
4f2a6c17-03c3-4515-be61-1269cf0fb4ab	Qty Test Product 62aa14	QTY-62AA14	SOFTWARE	\N	\N	100.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:34.595836+00	2026-10-31 07:38:34.595836+00
8e677bd2-2a28-432f-95eb-337f2b48f1e5	Overlap Prod a17ec1	OVL-A17EC1	SOFTWARE	\N	\N	1000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:35.185917+00	2026-10-31 07:38:35.185917+00
c490928c-9a8c-4437-9601-1abebc4075b7	OP Prod 625c40	OP-625C40	SOFTWARE	\N	\N	1000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:35.97391+00	2026-10-31 07:38:35.97391+00
5bea6103-3d8f-49c0-b077-370f3e20b856	Neg9 Prod 2bacb8	NEG9-2BACB8	SOFTWARE	\N	\N	500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:37.106524+00	2026-10-31 07:38:37.106524+00
e7f7f3ac-3fa7-4818-b3da-4d643758ecfc	Cloud Security Suite	SEC-4E2C2	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:38.172839+00	2026-10-31 07:38:38.172839+00
7090854b-634c-430b-8251-559ea3b5b470	INR Service	INR-FE88D0	SOFTWARE	\N	\N	1000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:39.808323+00	2026-10-31 07:38:39.808323+00
f332c5d3-ccfe-4fb8-a940-9d0eebba6fab	USD Service	USD-D615AB	SOFTWARE	\N	\N	50.0000	\N	USD	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:39.840896+00	2026-10-31 07:38:39.840896+00
e19e498e-8fbb-4734-9519-84c3a22650c1	Base Software	BASE-9A2685	SOFTWARE	\N	\N	3000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:40.028576+00	2026-10-31 07:38:40.028576+00
054c67bf-f82b-40c3-9817-1266139fb3ac	Auto Close Product	AC-DFD29F	SOFTWARE	\N	\N	1500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:40.251474+00	2026-10-31 07:38:40.251474+00
d5802e47-aede-48cb-8212-855361c869b8	CRM Software	CRM-2FFB1A	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:40.410335+00	2026-10-31 07:38:40.410335+00
c96bdd64-40ce-40fc-a165-2ff67e37088e	ERP Financials	ERP-446A89	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:40.710591+00	2026-10-31 07:38:40.710591+00
d3e8f730-2214-4391-99d7-42a257431398	Standard Software	SW-DC88D5	SOFTWARE	\N	\N	5000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:40.794809+00	2026-10-31 07:38:40.794809+00
d8969bdc-b55f-45af-b479-0dbc098e71bc	INR Product	INR-C53BA3	SOFTWARE	\N	\N	100.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:40.862446+00	2026-10-31 07:38:40.862446+00
ccc3244e-bd3a-4ccf-9b7e-55060b9cec92	Brightloop ERP Cloud	SKU-DC3FB5	SOFTWARE	Enterprise cloud accounting and subscription platform	\N	2000.0000	500.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:40.943603+00	2026-10-31 07:38:40.943603+00
9fa9f36b-eab8-40f9-8e6e-f3c587af7e2f	Admin Product	RBAC-61D736	ADDON	\N	\N	500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:41.135501+00	2026-10-31 07:38:41.135501+00
e54b5f0a-5d7e-4477-add3-ca6039fd8723	History Test Product	HIST-15184D	SOFTWARE	\N	\N	1500.0000	450.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:41.207953+00	2026-10-31 07:38:41.249154+00
0c0bf333-9976-4b9c-ae78-70e1bd9fddc4	To Archive Product	ARCH-0402FA	PHYSICAL_PRODUCT	\N	\N	750.0000	\N	INR	f	t	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:41.337753+00	2026-10-31 07:38:41.367624+00
2758ae3b-77c6-43a1-ae62-0cf0bb304cac	Cloud CRM Platform	PROD-SUB-2EE40	SOFTWARE	\N	\N	5000.0000	1000.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:41.667772+00	2026-10-31 07:38:41.667772+00
0a3ccc4b-2420-4f5b-b9df-7aaac0ef8f41	Brightloop Growth Platform	BL-PROD-GROWTH	SOFTWARE	Advanced subscription automation, customer lifecycle intelligence, and recurring invoicing.	\N	2499.0000	500.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:17:09.727071+00	2026-10-31 08:17:09.727071+00
b2d1720c-2e2b-4c84-8b21-e1ae51e0809b	Brightloop Business Platform	BL-PROD-BUSINESS	SOFTWARE	High-volume enterprise subscription engine with multi-entity billing and audit controls.	\N	5999.0000	1200.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:17:09.727071+00	2026-10-31 08:17:09.727071+00
5cfef298-79f5-4173-83f3-3aace17688da	AI Intelligence Module	BL-PROD-ADDON-AI	ADDON	Predictive churn analytics, payment failure recovery, and automated revenue insights.	\N	499.0000	100.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:17:09.727071+00	2026-10-31 08:17:09.727071+00
d27b68c7-a92c-4877-a0db-983aaaf1945a	Premium SLA Support	BL-PROD-ADDON-SLA	ADDON	24/7 dedicated engineering response with 99.99% uptime guarantee and priority ticketing.	\N	999.0000	250.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:17:09.727071+00	2026-10-31 08:17:09.727071+00
f092ee5a-dce2-4417-9bfb-fc5935d8a7b7	Additional User Seat	BL-PROD-ADDON-SEAT	ADDON	Extra operator seat for staff and finance team members with role-based access.	\N	199.0000	20.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:17:09.727071+00	2026-10-31 08:17:09.727071+00
ca9093a9-8946-45d9-9f7c-0fed270ee1b7	Brightloop ERP Cloud	SKU-D1E67E	SOFTWARE	Enterprise cloud accounting and subscription platform	\N	2000.0000	500.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:20.593607+00	2026-10-31 08:24:20.593607+00
1da1085b-388e-42ba-a756-8d3905e1119b	History Test Product	HIST-CBAAA9	SOFTWARE	\N	\N	1500.0000	450.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:20.786671+00	2026-10-31 08:24:20.825569+00
5a501b7e-5295-4719-8c88-20c5ffcced35	To Archive Product	ARCH-48E91E	PHYSICAL_PRODUCT	\N	\N	750.0000	\N	INR	f	t	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:20.912848+00	2026-10-31 08:24:20.950175+00
3c81cd1f-5e81-45bc-9416-9e2095c3c324	Audit Analytics Suite 7b522b	AUD-SKU-7B522B	SOFTWARE	\N	\N	50000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:38.052173+00	2026-10-31 08:27:38.052173+00
4bde00c2-5efd-4694-bcd0-41be8b23aedb	Audit Analytics Suite 8ebd0b	AUD-SKU-8EBD0B	SOFTWARE	\N	\N	50000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:11.196744+00	2026-10-31 08:24:11.196744+00
20b44ac3-ad76-4788-a710-a08a854f2184	Qty Test Product 16e322	QTY-16E322	SOFTWARE	\N	\N	100.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:13.542583+00	2026-10-31 08:24:13.542583+00
f9b16ecd-e8bf-46ef-8482-2a84eb215fd2	Overlap Prod b22d76	OVL-B22D76	SOFTWARE	\N	\N	1000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:14.227525+00	2026-10-31 08:24:14.227525+00
7f8d1ec4-f42c-48c7-928f-278cf9d23b34	OP Prod dbfa6b	OP-DBFA6B	SOFTWARE	\N	\N	1000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:15.121532+00	2026-10-31 08:24:15.121532+00
6d9f2b8f-4038-4bf7-baee-a0bbd91ba314	Neg9 Prod 7559a3	NEG9-7559A3	SOFTWARE	\N	\N	500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:16.618806+00	2026-10-31 08:24:16.618806+00
3e3ede4f-d267-4cff-8549-9755a16fc590	Cloud Security Suite	SEC-D4CB3	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:17.742565+00	2026-10-31 08:24:17.742565+00
bcd56009-9fcb-4079-b8c3-42057803de96	Base Software	BASE-ABE7B8	SOFTWARE	\N	\N	3000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:19.665087+00	2026-10-31 08:24:19.665087+00
dcf62b2b-3bb7-41c6-90a2-0df56926f3d3	Auto Close Product	AC-EBE78B	SOFTWARE	\N	\N	1500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:19.907895+00	2026-10-31 08:24:19.907895+00
f8fb9c0c-8135-427d-a119-1af9ce6e9a02	CRM Software	CRM-B6E95F	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:20.06928+00	2026-10-31 08:24:20.06928+00
d9d4cfa1-d7ff-4475-81ef-aacf2209bae8	ERP Financials	ERP-B028FA	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:20.357187+00	2026-10-31 08:24:20.357187+00
427f1a59-ae24-45e4-bc39-24b8f1acd32f	Standard Software	SW-505DE1	SOFTWARE	\N	\N	5000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:20.443316+00	2026-10-31 08:24:20.443316+00
23901c36-a9a0-44ad-98af-92fe4a5b1d88	INR Product	INR-4BD35F	SOFTWARE	\N	\N	100.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:20.511977+00	2026-10-31 08:24:20.511977+00
95724fee-0cd6-49aa-9308-0829fe8c0f13	Cloud CRM Platform	PROD-SUB-673A0	SOFTWARE	\N	\N	5000.0000	1000.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:21.253193+00	2026-10-31 08:24:21.253193+00
dc90eb67-7f8c-4214-b972-60afc7208384	Qty Test Product f88c42	QTY-F88C42	SOFTWARE	\N	\N	100.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:39.95908+00	2026-10-31 08:27:39.95908+00
48e0f739-0593-420f-a170-a77c35a41fae	Overlap Prod 425051	OVL-425051	SOFTWARE	\N	\N	1000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:40.696678+00	2026-10-31 08:27:40.696678+00
06a547de-b22a-49b3-9adc-fe3be1734f08	OP Prod 934bd2	OP-934BD2	SOFTWARE	\N	\N	1000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:41.504162+00	2026-10-31 08:27:41.504162+00
158c96d4-cbb8-49f2-a7d7-4e828fc64d3e	Brightloop Starter Platform	BL-PROD-STARTER	SOFTWARE	Essential subscription management and billing foundation for emerging businesses and startups.	\N	999.0000	200.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:17:09.727071+00	2026-10-31 08:27:35.928513+00
ca41c692-d96d-44a2-b66c-65b15120e34b	Neg9 Prod b487f3	NEG9-B487F3	SOFTWARE	\N	\N	500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:42.573515+00	2026-10-31 08:27:42.573515+00
c6410f1a-5961-42a0-b35f-800a55a315be	Cloud Security Suite	SEC-FB164	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:43.731206+00	2026-10-31 08:27:43.731206+00
8824b9cb-c3a7-4624-b125-4dd55b0bfbeb	INR Service	INR-3846F7	SOFTWARE	\N	\N	1000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:45.347391+00	2026-10-31 08:27:45.347391+00
35ddd7a9-e386-4b9a-9b32-408791cc0634	USD Service	USD-8A8A3A	SOFTWARE	\N	\N	50.0000	\N	USD	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:45.378666+00	2026-10-31 08:27:45.378666+00
b4b7076e-7cc6-4f6e-a30a-4fbc79828243	Base Software	BASE-010ACA	SOFTWARE	\N	\N	3000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:45.550283+00	2026-10-31 08:27:45.550283+00
16bcdd98-d25d-4035-83fa-90919102c80a	Auto Close Product	AC-8CABC4	SOFTWARE	\N	\N	1500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:45.779972+00	2026-10-31 08:27:45.779972+00
ba0da014-b338-4921-8cf2-e19f2f4fdcae	CRM Software	CRM-992EAD	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:45.940944+00	2026-10-31 08:27:45.940944+00
93bfd89e-bc60-47c0-b494-e9b010980df0	ERP Financials	ERP-86D601	SOFTWARE	\N	\N	2000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:46.266357+00	2026-10-31 08:27:46.266357+00
ee8602df-7bf2-4bfb-b82d-06e892fec89e	Standard Software	SW-35CB17	SOFTWARE	\N	\N	5000.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:46.361271+00	2026-10-31 08:27:46.361271+00
5d6f9fc2-e8ac-490d-9390-ab4bc994f650	INR Product	INR-B6FB63	SOFTWARE	\N	\N	100.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:46.434638+00	2026-10-31 08:27:46.434638+00
f3c4dab1-cf3f-43eb-80f2-f7ddedf00f64	Brightloop ERP Cloud	SKU-0AC8C5	SOFTWARE	Enterprise cloud accounting and subscription platform	\N	2000.0000	500.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:46.518896+00	2026-10-31 08:27:46.518896+00
21f3dee2-08f1-4992-8579-fc021a4bdc17	Admin Product	RBAC-109F23	ADDON	\N	\N	500.0000	\N	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:46.706445+00	2026-10-31 08:27:46.706445+00
6105c5e6-fce7-4f05-ab91-8fde170061c9	History Test Product	HIST-96CB53	SOFTWARE	\N	\N	1500.0000	450.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:46.787751+00	2026-10-31 08:27:46.823568+00
aed404df-5e24-47b3-b798-72d9daea4654	To Archive Product	ARCH-C0B99E	PHYSICAL_PRODUCT	\N	\N	750.0000	\N	INR	f	t	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:46.928905+00	2026-10-31 08:27:46.987902+00
6cb1fe89-fd75-47ca-9b74-b6e591db1a33	Cloud CRM Platform	PROD-SUB-5EF7F	SOFTWARE	\N	\N	5000.0000	1000.0000	INR	t	f	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:47.291416+00	2026-10-31 08:27:47.291416+00
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: brightloop_user
--

COPY public.refresh_tokens (id, user_id, token_hash, family_id, is_revoked, is_used, expires_at, created_at, user_agent, ip_address) FROM stdin;
08296f8c-0846-4459-9ed0-964affd3f1a0	86e39d83-656a-4a5f-b96d-9ee66a6620ca	a88b2f1829c7a8389e1d2a48618edbd79859c418b6357149cb18fdab7234fb69	2ecbbe15-8b1f-483d-830b-2427286ea6c3	f	f	2026-11-07 04:13:42.83262+00	2026-10-31 04:13:42.779947+00	python-httpx/0.28.1	127.0.0.1
5596cae8-abc8-4b65-943d-345e47e2c90c	6e59d264-58ea-4ada-ae92-99dd3d5aa6d9	675f7280aca7132999f28d8322f13fb924ee72a367115dd5d73a309253128929	e2ccf559-f1bb-4537-a369-c7ee302cde47	f	f	2026-11-07 04:13:43.25875+00	2026-10-31 04:13:43.210571+00	python-httpx/0.28.1	127.0.0.1
cefd5611-0ed9-49f8-a9e0-300946ff51d6	6e59d264-58ea-4ada-ae92-99dd3d5aa6d9	36e4449fbddbfe40d6b645ea8718c4b52caa254ae48f44e253530487fba8a302	3f502b19-3683-4d02-95e9-b5fdd058f406	f	f	2026-11-07 04:13:43.367442+00	2026-10-31 04:13:43.325325+00	python-httpx/0.28.1	127.0.0.1
edb619ce-6da3-454c-8420-da2bba3e1403	5040313c-9900-4630-93f9-1f0e119412dd	96c5d7a3294905be1967b80febe362253b2210d20cc7e1b44c2e6fba8040a7bd	207112d0-53c3-482a-8c38-5b32844d8825	f	f	2026-11-07 08:24:10.933719+00	2026-10-31 08:24:10.873863+00	python-httpx/0.28.1	127.0.0.1
ed33a984-0a4d-4442-950c-b53df67b9331	eff31d33-4717-4f20-8fb1-480799cdeae5	8341d339960b84de280a080835cffe3ab5f6c4d8740ce3beeaf6f31aae7de620	ee1a6b6e-1e89-4d4b-b2a1-995757ea98d3	t	f	2026-11-07 04:13:43.654602+00	2026-10-31 04:13:43.606226+00	python-httpx/0.28.1	127.0.0.1
0440a0ac-180d-4be2-954d-3758761b9db1	eff31d33-4717-4f20-8fb1-480799cdeae5	624286180ce46ff7d1d4c20ab5fdfc9fa26a213780bf2fba96f28eab5d69923c	844dbedc-9350-404f-866c-dc7ed2529503	f	f	2026-11-07 04:13:43.854256+00	2026-10-31 04:13:43.810756+00	python-httpx/0.28.1	127.0.0.1
72d82fbf-ee0a-4513-8c64-e2a4483e6a80	5040313c-9900-4630-93f9-1f0e119412dd	d32eba3124e44ecc28a27ccfd3cfca0e8216cc5be13447387eb2867b643cd325	165b3b2d-85e3-4a1e-b0f8-c70c81081f25	f	f	2026-11-07 04:13:44.060335+00	2026-10-31 04:13:44.010691+00	python-httpx/0.28.1	127.0.0.1
069b7c49-2cd8-473a-a7e9-df34788fe48c	5040313c-9900-4630-93f9-1f0e119412dd	d6792f9b62bbfa333dbe851e503f47f315f18beb405a9c4ebbf6a1de12ef5c47	e916e266-1347-40c7-ba6a-95b5d2381ef2	f	f	2026-11-07 08:27:24.567099+00	2026-10-31 08:27:24.518662+00	python-httpx/0.28.1	127.0.0.1
3419597d-1ff8-4adf-99f5-2d72d3c2886a	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	6145bf1d1df3b089560883bf6ec411934e611e28c37be0957323293f32d9e127	754cdd52-67a3-476d-afac-ce51a2ab4d63	f	f	2026-11-07 04:13:44.252002+00	2026-10-31 04:13:44.207955+00	python-httpx/0.28.1	127.0.0.1
935bbb65-c335-4d53-b28d-9143713bc00d	323912e5-9c09-4482-8595-d1428cf1c4c0	951173dcc0efb0ed29f6c355e0f209507dd1b80273f141c4f785436f3ddbccad	18d17c5e-5548-4c04-a702-a72f5a563108	t	f	2026-11-07 04:13:44.120295+00	2026-10-31 04:13:44.074631+00	python-httpx/0.28.1	127.0.0.1
5bf4567a-db02-4dc4-92c3-516099057bbf	b4ee41b2-33d5-46a9-b2de-35d6515f5a97	abc27bb673ff9d84d8633ad8619c828ddfb78d42c508ff4021ee1b3dbc67fedc	4bb656ad-ca01-44db-b4f8-4b2c0f2be54b	f	f	2026-11-07 04:14:26.832774+00	2026-10-31 04:14:26.770563+00	python-httpx/0.28.1	127.0.0.1
fb0c6e52-74d1-4c1a-91b4-3d8f1991bb4c	c79cc6d8-b258-40df-888c-bd338cf6809d	b4f7f16b2bec40403a1cee86cb34eb8d5ee526fda1c2d15e4e91686daf96e823	87c5bde5-9e0f-4fcf-a887-c8956395bccf	f	f	2026-11-07 04:14:27.220532+00	2026-10-31 04:14:27.171131+00	python-httpx/0.28.1	127.0.0.1
e510fe52-b58c-4d57-8941-b028f76ba2dd	c79cc6d8-b258-40df-888c-bd338cf6809d	abda8916c4faccd9454cb150996576820356a6fbf82f25354f29faa2afaddb5e	571c1255-93c3-4aef-aa40-943d503d2e4b	f	f	2026-11-07 04:14:27.341152+00	2026-10-31 04:14:27.29852+00	python-httpx/0.28.1	127.0.0.1
679d25d5-0d6b-4728-ab91-431a2e57442a	1ceff4fa-c65a-4484-90fa-936b33db28a2	34a82dda496b21655d4cbb62ec3494561cfbd366bfda71d2e257f08cd255bbf0	b0c5e6fc-e95f-4d88-b28a-25e9426e28eb	f	f	2026-11-07 04:14:56.21997+00	2026-10-31 04:14:56.170402+00	python-httpx/0.28.1	127.0.0.1
1ce1b74a-a308-4fcf-bc45-4eeeac68770a	ef828a90-4f4a-4a4f-8178-3995232f893c	866320f6c0015e850beeca21c8b71c28072da24d0c574b12e599d284adfc4080	68e3c98e-74bd-434f-8a6a-b59a814d1f0a	f	f	2026-11-07 04:14:56.357396+00	2026-10-31 04:14:56.309467+00	python-httpx/0.28.1	127.0.0.1
ca71e116-e5a4-493f-935c-70a5270541fb	cee17693-481d-4828-a0e6-1c42aaa54c5a	8731108d22ff5e0764e256642718dce480ffb3194bdaee555de3506eb82bb412	36371c4c-f36d-4813-963f-60b7034a9b55	f	f	2026-11-07 04:14:56.450594+00	2026-10-31 04:14:56.40142+00	python-httpx/0.28.1	127.0.0.1
a22e489f-3f3d-47cd-a6bf-9bf809cf7fe5	cee17693-481d-4828-a0e6-1c42aaa54c5a	5de46ea28adc6d369407ea0f396800d598b9c5f737f38530a6a092d4fd61db8b	addf720f-14ef-42c2-89a3-e41896a0c405	f	f	2026-11-07 04:14:56.580978+00	2026-10-31 04:14:56.535106+00	python-httpx/0.28.1	127.0.0.1
0d74aaf6-6caa-4e03-9255-643b3738bc0c	640afb31-c926-413e-a5f1-0342024aedc3	196cbde218dfef43923b0fb0fc8767e4d73d687fbff2dee47d5a5c18b1c28a29	3720d32c-aa92-4926-9a6c-c16a79cae3da	f	t	2026-11-07 04:14:56.647318+00	2026-10-31 04:14:56.600793+00	python-httpx/0.28.1	127.0.0.1
f4b5c414-c56d-4049-9178-bea898e2fc59	640afb31-c926-413e-a5f1-0342024aedc3	2005ea5fb99bb8e2662d556ff907d0454634ebd372d6e98caabcb2333edf5da3	3720d32c-aa92-4926-9a6c-c16a79cae3da	f	t	2026-11-07 04:14:56.672678+00	2026-10-31 04:14:56.669625+00	python-httpx/0.28.1	127.0.0.1
7189140a-c7bd-4fe4-ba33-aa82e6b4ade5	640afb31-c926-413e-a5f1-0342024aedc3	e7437e2041e15a5512096d7f571a21d2f77f88177736bfc32e1cc2073601fc4a	3720d32c-aa92-4926-9a6c-c16a79cae3da	f	f	2026-11-07 04:14:56.708215+00	2026-10-31 04:14:56.705948+00	python-httpx/0.28.1	127.0.0.1
f4206b76-628c-4c6d-9c3c-7059f5780298	1f4ef7b6-1866-4f50-9627-2d5340886b2f	b4866bdcd3c29d84dc024810a651ffba7f2c0df72c34bd90e941c4f2c68ef87f	cd967fb7-d179-470f-a617-00cb6f494b0e	f	f	2026-11-07 04:14:56.795129+00	2026-10-31 04:14:56.748002+00	python-httpx/0.28.1	127.0.0.1
9a20a3fc-b3a2-4bf9-829a-c4bec6d2490c	5040313c-9900-4630-93f9-1f0e119412dd	f0f8510e6face10f26ed5230f6ee78222554b85da30154667fe333d458ca7029	1da6fc9c-2e19-4d8c-b292-e21431b62b4c	f	f	2026-11-07 04:14:57.249594+00	2026-10-31 04:14:57.20306+00	python-httpx/0.28.1	127.0.0.1
4bdfe914-3cd7-4a68-aee2-466c316907b3	5aa3d456-9f57-44bb-b5f4-a6bc74747829	ab997f77ae941205c56aba3529f675d50552092025a7f09c0129219684da6972	d5aaa195-8b66-4daa-a755-536a525615b7	f	f	2026-11-07 04:14:57.497538+00	2026-10-31 04:14:57.45351+00	python-httpx/0.28.1	127.0.0.1
9912adec-219d-4cbe-a703-8b19a96e04c6	66d3aecf-e430-45ec-a173-a50b9d8af0ea	e9f85cd19c609e2a2de53f624b4ee23bcf51318b222853131806a27569b330e2	75de36bf-426c-47e7-8cf0-bd7e5d1118be	t	f	2026-11-07 04:14:57.318117+00	2026-10-31 04:14:57.271035+00	python-httpx/0.28.1	127.0.0.1
f5494985-7c13-4d14-9dfb-50258d195acc	8f41d28e-a0e1-4e20-a55e-4119ca48209a	ee718ea110464de50d0552af1e97753b0a90eb0ea5ca0c941e8293ec6a57a7d7	e6490189-9696-4641-a600-501d454da5af	f	t	2026-11-07 04:15:05.303921+00	2026-10-31 04:15:05.25356+00	python-httpx/0.28.1	127.0.0.1
305eec37-7330-4843-bce3-411c602c6747	8f41d28e-a0e1-4e20-a55e-4119ca48209a	862f3a77b21ac4bf54cfc91d7431c98d433a4cb811f4d7b7df1096896a909837	e6490189-9696-4641-a600-501d454da5af	f	t	2026-11-07 04:15:05.340276+00	2026-10-31 04:15:05.337603+00	python-httpx/0.28.1	127.0.0.1
9cfa7973-75a3-4916-9bc2-ec8ceb4c9382	8f41d28e-a0e1-4e20-a55e-4119ca48209a	139e5f3c9075b922789b4927a49dbe15e391298915d54d7f5e432a099f723c5c	e6490189-9696-4641-a600-501d454da5af	f	f	2026-11-07 04:15:05.374121+00	2026-10-31 04:15:05.372021+00	python-httpx/0.28.1	127.0.0.1
5e157f09-b4e5-4e6f-bd95-3b3af02d1ef3	75a26128-3f2e-489a-a766-30ea3e7197db	41d40c3010065684d6916afc8dde216daf8a0137535bf6aa8584143e3096646b	1db6117e-23d8-4a15-acc2-a62b06dbbf3e	f	f	2026-11-07 04:15:15.30456+00	2026-10-31 04:15:15.254074+00	python-httpx/0.28.1	127.0.0.1
56289b1d-993d-49da-b7b0-2076975fc1ad	4d322516-9c79-4e12-a8ab-978e9d93b784	454598aa1cc7f6409b06f92afe8b5128cb14a51f050dd4980de8e79c84956d9b	8a5c1b51-34f4-4b05-9f6c-8213c871b0ad	f	f	2026-11-07 04:15:41.107952+00	2026-10-31 04:15:41.059033+00	python-httpx/0.28.1	127.0.0.1
4aa4aae4-0cbc-4502-91d4-eebf33945f6c	e01c5123-e863-4c73-addf-fc8ccb55a8a0	bbca005e9da32af11c399691676b074b34a61736161e2d4e5dcbf7d81905cf97	12e6ad5f-8f46-4048-a126-0dfcad4a0084	f	f	2026-11-07 04:15:41.239407+00	2026-10-31 04:15:41.192039+00	python-httpx/0.28.1	127.0.0.1
a911122d-5c77-42a0-a7bd-0d4493d726ee	8441df5e-d166-45ec-8867-4eaeff3cbb11	b1df52ed8351da7aa3d4a3e99d4261fefccbf02f778a10365624ebe2ea8a74c4	3619f937-5fe6-4276-8d07-d0ab50f19afa	f	f	2026-11-07 04:15:41.329145+00	2026-10-31 04:15:41.28279+00	python-httpx/0.28.1	127.0.0.1
d4aa1fce-b08c-4421-b926-2dd56969c792	8441df5e-d166-45ec-8867-4eaeff3cbb11	b9f4e2e034e09f274fa31e5325a4934e9c482b648ed5a35b4ed986d8e41b6f44	8ef81e94-f66b-4515-bf92-d79650244c7f	f	f	2026-11-07 04:15:41.457209+00	2026-10-31 04:15:41.412143+00	python-httpx/0.28.1	127.0.0.1
a6e396d6-2e2c-4ac1-ab9d-7fa9082ca1b4	f1606ee3-6693-4e3a-9e7a-9fc18d00a065	751d4bd8914df89698f8b162c77d20eb28a6437c8bfb6b20918622e6e034e3d2	122f835b-587a-4309-a539-8238e1d0a4c8	t	f	2026-11-07 04:15:41.672295+00	2026-10-31 04:15:41.603106+00	python-httpx/0.28.1	127.0.0.1
44ced137-4083-4b7e-aea8-6192306e412f	f7e590af-5146-4d2f-bcc9-b032839d70da	c3d33305a831a8e9f88790e6f0c979c9669534b222028792727c2ceb29b986ea	6e575e57-772e-4f25-bdf7-ab700fa9fdfc	t	t	2026-11-07 04:15:41.522372+00	2026-10-31 04:15:41.475872+00	python-httpx/0.28.1	127.0.0.1
16de581c-8767-4f97-af9d-13abc677be8b	f7e590af-5146-4d2f-bcc9-b032839d70da	6b8b0833b53af22f011ba05b36a1005353256bc0bec9323d524c77023d012490	6e575e57-772e-4f25-bdf7-ab700fa9fdfc	t	f	2026-11-07 04:15:41.549069+00	2026-10-31 04:15:41.54632+00	python-httpx/0.28.1	127.0.0.1
ab54dc33-0bc6-48f1-9343-a6f09a0921a6	f1606ee3-6693-4e3a-9e7a-9fc18d00a065	231a5c278d7e7492d8ce80ce2eefc758c73d474548e96e4f4d85511d870a57bc	10b6dbaa-d91f-4799-af51-cc15a9b5a680	f	f	2026-11-07 04:15:41.91628+00	2026-10-31 04:15:41.870933+00	python-httpx/0.28.1	127.0.0.1
392847f9-661c-497a-90ba-9f6cdc9e298a	5bc72d2e-c41b-4937-99d4-3830e341b00b	b50bf8484bdc4d3f983d75163739236183b443ed4de7d5e86a0f440b4dd0bdb6	06785039-6a6f-4b82-ac2c-aecf727f279d	f	f	2026-11-07 04:15:47.790651+00	2026-10-31 04:15:47.7414+00	python-httpx/0.28.1	127.0.0.1
a32836d0-c272-411b-b259-3d0c59cb1b81	4be22406-b9c4-417e-bfb6-89fe16aa6a6f	06f1fe080343b45bf7563544b7bb4252140aaa67c7bd0183768d9483e77e4348	dceb886f-a374-49fb-9ef1-0acaae3456f5	f	f	2026-11-07 04:15:47.880865+00	2026-10-31 04:15:47.832315+00	python-httpx/0.28.1	127.0.0.1
ed345368-d4fc-46b8-9e40-242623f776d3	da3d6346-7764-44d5-9245-80549c1b2757	a34645532771df32649dbd5fe975ff4aa7640f73ec39671476a4f8e52948d836	da197d03-03d5-4168-b022-bd17f477eec4	f	f	2026-11-07 04:15:47.975898+00	2026-10-31 04:15:47.923767+00	python-httpx/0.28.1	127.0.0.1
7d090d3f-a599-4c40-b6aa-7db70a68998b	da3d6346-7764-44d5-9245-80549c1b2757	5fd3950dfedea9bd5fbe860cd03ab2c6a1682e0d52fe3eaaf19ee0e486c7c6cf	612ebdb8-a6c6-4c64-9249-6fa9befd3f1d	f	f	2026-11-07 04:15:48.110072+00	2026-10-31 04:15:48.061784+00	python-httpx/0.28.1	127.0.0.1
b88b6a2e-a4c9-437a-9e60-decc1b879e71	508d414f-cd5b-47f4-85e9-59ee42f1b800	cb4635b45b91099d13b8f19304af8e6b08b651526a1eabe472ca3c6adb6b42dc	4404de9b-8718-4ffd-b692-8515a5455320	t	t	2026-11-07 04:15:48.180017+00	2026-10-31 04:15:48.131822+00	python-httpx/0.28.1	127.0.0.1
3a721209-c3d6-4f90-a6ea-a7e26f06679e	508d414f-cd5b-47f4-85e9-59ee42f1b800	5c83242002dae2ae504265b2b7bff6ba587ba44953a7aa37406d7cb22e71f7dc	4404de9b-8718-4ffd-b692-8515a5455320	t	f	2026-11-07 04:15:48.205741+00	2026-10-31 04:15:48.202912+00	python-httpx/0.28.1	127.0.0.1
1eeea041-6eaa-46f1-962b-3d174fd15496	5040313c-9900-4630-93f9-1f0e119412dd	e3bf058e9373a3af67d05b841ab5c0d41b15eedaf75c1022d2bf322965988553	b4902a61-8dd8-424e-9cd8-dddbb6baa08b	f	f	2026-11-07 08:24:21.872051+00	2026-10-31 08:24:21.814642+00	python-httpx/0.28.1	127.0.0.1
c16a44f6-c378-4aad-b8c5-91c545d87fd4	aa322c84-c6ac-4251-8e52-4f77ec351b2c	104d630c92fe8b9ebe0bbd289fd828f98c7b3ebf167f5207087d04ec460ea063	f0532d44-05f0-4258-9a03-42e77ca3c904	t	f	2026-11-07 04:15:48.309136+00	2026-10-31 04:15:48.261053+00	python-httpx/0.28.1	127.0.0.1
8381f3ae-c490-4ccc-b90e-b0b147ebd2ab	aa322c84-c6ac-4251-8e52-4f77ec351b2c	3b57f9905882fe5482caff5b1a0f5f590309b0b10ed8f078a7a7d8254eab3e45	42c11791-e5f7-4f79-8911-4361b4d28c7f	f	f	2026-11-07 04:15:48.579583+00	2026-10-31 04:15:48.535344+00	python-httpx/0.28.1	127.0.0.1
0d8364ec-6cde-476c-b535-03fd250cb2aa	5040313c-9900-4630-93f9-1f0e119412dd	c34e83dc662ae1931bb5040c74a4be576e51729c64fcd3cbe2ad8910eb6de9f2	edc0ea43-fbbf-4ad7-a15b-86b1b63a87d5	f	f	2026-11-07 04:15:48.809935+00	2026-10-31 04:15:48.760305+00	python-httpx/0.28.1	127.0.0.1
4bcc5322-7080-42d8-bbad-dc2fcd1b2877	13cd1286-ab5c-489a-9999-083280c82eae	aa1b02f54d0c73d73609cb4a2ee8249176172e79cb3a2a49e65d41135cfffcce	919366ff-7e63-418c-9245-cf29a8c5259f	f	f	2026-11-07 08:27:34.376703+00	2026-10-31 08:27:34.318087+00	python-httpx/0.28.1	127.0.0.1
41f67b2f-99f5-4f9a-906c-e2cfac9a5d87	1b19476e-a38c-4a3c-94a9-44f5d229de92	82dac52b59b550be35c8d0ce3efcbbaa195600a06dcb399b89bf721a96b047fe	6af6e99e-efa3-40da-9e52-8ff87858db14	f	f	2026-11-07 04:15:49.058854+00	2026-10-31 04:15:49.01484+00	python-httpx/0.28.1	127.0.0.1
c136aa46-5ba7-41b7-9a62-bc8cfb0ad4c6	7c459673-c3dd-4a31-8aaf-aae44ae3aed2	4d8081580ae1f717a93cf509da7e7fb558786e73f17da21b7b6eda78b2243edc	85ddf597-e4c6-447b-9df0-5813ca25e7d5	t	f	2026-11-07 04:15:48.87805+00	2026-10-31 04:15:48.831257+00	python-httpx/0.28.1	127.0.0.1
347e9b9a-a0bf-477c-9cc8-4e8c4f10728d	5040313c-9900-4630-93f9-1f0e119412dd	615d0c45cc2a79af15416786d5425d3e3293541485edd13db252386c40728df8	1568f001-aa97-4636-bc9a-a62a08c76175	f	t	2026-11-07 04:32:15.335345+00	2026-10-31 04:32:15.282641+00	curl/8.22.0	127.0.0.1
0fffa113-97cb-4f1c-9f7f-bfea0ccd043d	5040313c-9900-4630-93f9-1f0e119412dd	bf9e1551cc7b3df6bacd5f612d0d8ad71ceb21b137d49ff17c406b073daeec9f	1568f001-aa97-4636-bc9a-a62a08c76175	f	f	2026-11-07 04:32:35.78154+00	2026-10-31 04:32:35.780076+00	curl/8.22.0	127.0.0.1
2c43e89f-920b-4eee-a8f9-f16cb52fb816	f8a76800-1d18-4ecc-8527-7b4f59687fa3	8632169dbba23e5fe1aa799c686c4956c8da15eb00bb586df83936657dbc98ce	6f5975ac-a49f-415f-b8b1-e689c722f9ae	t	t	2026-11-07 04:37:24.64103+00	2026-10-31 04:37:24.58218+00	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	127.0.0.1
abdf1c08-8e9b-488b-89ec-21c6102636e9	f8a76800-1d18-4ecc-8527-7b4f59687fa3	8295fed66c6632e390ddd9161384c981e423d81faf0c229bd332c5b5f2085644	6f5975ac-a49f-415f-b8b1-e689c722f9ae	t	f	2026-11-07 04:58:13.466185+00	2026-10-31 04:58:13.461433+00	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	127.0.0.1
df3da3fb-f112-49fd-a957-c4d8be11c4a8	0ce2e170-1e3e-4de7-a2ac-dc825e758e34	b7add5334f98da415ee817e4a7774fd3e491e957aa3e247fd2e31497cf720f01	5599bce1-a3fd-4c3a-af69-df028e8c04cd	f	f	2026-11-07 05:11:18.217355+00	2026-10-31 05:11:18.164047+00	python-httpx/0.28.1	127.0.0.1
34d65a1a-2c31-4574-8b21-f033baeffeb9	84826d40-07ee-4610-9be7-a79c044c44b3	901de8dd22fecfabd18c901e5d34740fac26869d1bbca78254d1ae2449e6a842	811e8e9d-f351-4b7a-ad1e-fdfbd3f9281c	f	f	2026-11-07 05:11:18.345519+00	2026-10-31 05:11:18.292588+00	python-httpx/0.28.1	127.0.0.1
3b51ba95-911e-4f7c-a2ac-18dae72c45cf	bb198713-2d29-417d-8ffc-c56958a55829	5b2bf8521af81cbb5132285c49b7209d2ce7fbca31fb3db91a9fd51523b1a271	a5f28c10-3fb5-4e57-941a-2f6d9cdeb783	f	f	2026-11-07 05:11:18.445431+00	2026-10-31 05:11:18.390833+00	python-httpx/0.28.1	127.0.0.1
111704a4-4631-4eda-b81a-baa959420388	bb198713-2d29-417d-8ffc-c56958a55829	9b1d727a3dd80c2b006a627841496f7c6f107fe1be8943678711c631cf31e925	6a12e688-65c1-47ae-ab9e-09bbea6ce67b	f	f	2026-11-07 05:11:18.578896+00	2026-10-31 05:11:18.532099+00	python-httpx/0.28.1	127.0.0.1
50a3a833-c83e-4796-8f21-3a3ad1f4deaf	0422c9f3-3ebe-4ab1-a2c2-1cae4aa66b82	289a561fc6676583129bc7a2fd72ada521747053cc3ee06b89319ab995265844	f87e845b-e407-4369-9a73-b162ba82a671	f	f	2026-11-07 05:11:19.908042+00	2026-10-31 05:11:19.860308+00	python-httpx/0.28.1	127.0.0.1
9e7b7de1-6c45-49b6-bf84-a122b63344bb	4edfd77a-b6fa-4f69-995e-06e0f4f58770	c3a2e0689085205a8fc07a7c24b655af97933f8e9d3c2d22bba75f8fdef55f3a	9c98c892-5e0e-4148-8e4d-981d890407c8	t	t	2026-11-07 05:11:18.650078+00	2026-10-31 05:11:18.599704+00	python-httpx/0.28.1	127.0.0.1
d3239968-43b9-488b-9d43-811c81eefde6	4edfd77a-b6fa-4f69-995e-06e0f4f58770	69adc8edcc4e761010f344c2056dfffaa99b45a865903f77e112de806ca47f81	9c98c892-5e0e-4148-8e4d-981d890407c8	t	f	2026-11-07 05:11:18.67857+00	2026-10-31 05:11:18.675844+00	python-httpx/0.28.1	127.0.0.1
98d51b2a-ae38-4d87-8153-9a22d09bf412	ea823d6a-8512-4342-8975-0f9a54160a14	3756d3e0a476e353b0504f52cc17a92d0bd065b6445b3576980aa41b494ba503	ab8b48f2-a4af-42a1-804f-b34929e0cf4e	t	f	2026-11-07 05:11:18.780966+00	2026-10-31 05:11:18.730343+00	python-httpx/0.28.1	127.0.0.1
d46b6821-3be5-4755-b1fd-774d121383f7	ea823d6a-8512-4342-8975-0f9a54160a14	f08e613a9b6bd56c7091dd391542c21f9c728cfa00f698e1810778f274525e22	33c2e1ce-37f0-4b47-85a6-f82a596bf766	f	f	2026-11-07 05:11:19.068999+00	2026-10-31 05:11:19.000206+00	python-httpx/0.28.1	127.0.0.1
e9da29f3-e6ee-4d98-9e30-67391df1f525	82da7fb7-b8ce-4ee7-884d-200a4b3646df	1c274beed0dba6f5efc3247391414d54da8caa78804024a991e20d9ee94d55d8	e2fd5fb4-df41-431b-b1be-fe7c9ade5cff	f	f	2026-11-07 05:11:19.168029+00	2026-10-31 05:11:19.104331+00	python-httpx/0.28.1	127.0.0.1
d9c4a4e4-20a2-46d8-8d44-9085d35e8a04	bb612e5e-1fe9-4976-a447-d79a6b87f11e	b73f7dc8a0a00addd3ee353c137ad2bdb5c7069ae13145c3e310c3f68418eb78	b6771679-1ad7-4ccd-9fc6-9646eade32e4	t	f	2026-11-07 05:11:19.501199+00	2026-10-31 05:11:19.450956+00	python-httpx/0.28.1	127.0.0.1
f8157108-c709-4fcb-a72a-7b2336a71f88	5040313c-9900-4630-93f9-1f0e119412dd	c02df82274121b00a522a8b5d1daff687759c830e78a638c42ad1d7e36a50f90	f78ff611-2332-4e16-a847-317dbcb8f072	f	f	2026-11-07 05:11:19.762599+00	2026-10-31 05:11:19.711797+00	python-httpx/0.28.1	127.0.0.1
1cf24cfe-153b-4a38-90a0-1889e007c073	e88974b4-122b-41f8-8b21-15e3247977af	5e37040ab20cf1d7c7d1cd3f7c60c09cb40d90f901ffc5eb354c0ecc186cbc43	1436fa0c-a1bb-4424-b928-dbbb2ddc45cc	f	f	2026-11-07 05:11:20.114921+00	2026-10-31 05:11:20.066916+00	python-httpx/0.28.1	127.0.0.1
3bb4c476-08e5-4b79-bb1d-d0fb68c32cfc	850ca8b4-8d10-4ecd-b372-def1c1923a17	837df46b5422142a6f37f90fd3c406904c3fd2f67e2208569d2d9dd6f0754ba7	b33ad9dc-f357-47ec-97c5-f4914d8fb498	t	f	2026-11-07 05:11:19.83632+00	2026-10-31 05:11:19.782912+00	python-httpx/0.28.1	127.0.0.1
f2463156-2319-4a99-bce9-67028cad142a	418eabf0-b1e9-4819-8d36-01633b5e2b34	4d472c33013f73f94ea61e65d4f8cfe64771a89cfb55015759e520003353e4a6	b2302a6c-35f9-4594-8bc0-75152d9bb661	f	f	2026-11-07 05:11:50.618647+00	2026-10-31 05:11:50.56917+00	python-httpx/0.28.1	127.0.0.1
16bafd21-ea7d-4e07-91ae-17883c4e20d3	b90cf5af-bb7b-404a-ab1c-76e7ce6fce3c	ec48d3c2c7275596f2f72255be60ef3bd05df0174714a5e523073092e8351a76	49ae945c-5bb6-4839-95cc-b55f5bde5ebf	f	f	2026-11-07 05:11:50.714012+00	2026-10-31 05:11:50.662995+00	python-httpx/0.28.1	127.0.0.1
4356beb2-0786-4d8d-b8be-bd321e26a130	6e771bcb-2e4c-4d0f-8bc9-dcf52646d9ac	d376ae7b8fa7fc234540c8cf598fff1911bb2dd94f426fef4b2d6cca0a1a02e8	640614de-a79d-439f-8019-08b63eab7abd	f	f	2026-11-07 05:11:50.817049+00	2026-10-31 05:11:50.761766+00	python-httpx/0.28.1	127.0.0.1
623e3b17-4ab7-4f3e-b322-9e2f8ea6c33f	6e771bcb-2e4c-4d0f-8bc9-dcf52646d9ac	a99afc6b19de5d1c059cbd6d2111af689845b9b6cced2c6ab2977ced0de95612	6dcfc7a6-f213-492a-b57d-ef385c061a93	f	f	2026-11-07 05:11:50.957658+00	2026-10-31 05:11:50.902857+00	python-httpx/0.28.1	127.0.0.1
22fa7917-ae07-4616-8ebe-5981d9e67e31	8336509a-cf9b-4a96-a0b6-7bc3890a3f63	6881ca0fec61e4eb71cca4a0ca6d141dd51b970f35f7479615c715557e9dec74	8b6f434f-b236-44c6-8271-26a5df009ab9	t	f	2026-11-07 05:11:51.159994+00	2026-10-31 05:11:51.110789+00	python-httpx/0.28.1	127.0.0.1
85dd8858-1003-4937-9b15-d70d8dab266b	493d5223-982d-420a-b75f-03b1ff60757b	fbc0cb2617fb24e91a22b9f4989b5f9475d2e316ef1a1e0bcb3113762f1d7bff	eb361a0b-5ed2-47f9-8779-a76024fe6ebe	t	t	2026-11-07 05:11:51.028336+00	2026-10-31 05:11:50.980356+00	python-httpx/0.28.1	127.0.0.1
dc8e186a-b007-400d-a913-f484f8dbe9d5	493d5223-982d-420a-b75f-03b1ff60757b	47c12debdba25fa534267109ab49727112a0b74fa28b0c4c009012b720503630	eb361a0b-5ed2-47f9-8779-a76024fe6ebe	t	f	2026-11-07 05:11:51.057309+00	2026-10-31 05:11:51.055026+00	python-httpx/0.28.1	127.0.0.1
434c2bc7-b1c5-44ca-97b9-79ea0754268c	8336509a-cf9b-4a96-a0b6-7bc3890a3f63	5abdb70582026e8f448c395dc14a0e4d1183c26536b8ff26e58a0c09d7b64233	7dbd037f-42c3-46cc-bb7b-5b506e1051c8	f	f	2026-11-07 05:11:51.414491+00	2026-10-31 05:11:51.361816+00	python-httpx/0.28.1	127.0.0.1
45336afd-d3c3-408a-b421-887d6af8ae3a	d9538ec8-6c00-4ca4-bcf6-813e57938761	a98282820ff181264a7c07d8b69702aaea77e4dcaa38bb9db41299523deb1edf	96003170-9bf8-4d24-9a71-d255f7de206b	f	f	2026-11-07 05:11:51.503042+00	2026-10-31 05:11:51.449134+00	python-httpx/0.28.1	127.0.0.1
97d6d9bb-7bde-403e-9f9f-c2f2c84dba21	fb7dfeed-8809-4af1-b766-eeb8358e487a	e127fdbdad9614a2ac9078ecf030d95908d5a96b31559a09fec718595fefbd60	a1734442-d309-4825-badd-9493cdeef9eb	t	f	2026-11-07 05:11:51.662699+00	2026-10-31 05:11:51.614475+00	python-httpx/0.28.1	127.0.0.1
a278612a-7edf-4f0b-b28a-8dbbdf7e089c	5040313c-9900-4630-93f9-1f0e119412dd	32f5efa6f728937bbb16bde5002f3aa3e79ce125bd2de119c5f4ed3fd5574dd3	52cb0e15-c1b2-460d-9110-44adb0063b6c	f	f	2026-11-07 05:11:51.925737+00	2026-10-31 05:11:51.87456+00	python-httpx/0.28.1	127.0.0.1
4e6e4db1-736a-4745-bf85-e4fac29cdd97	bb2b4c98-c7eb-4c8d-a57e-4712599f3c60	7d83cd2975079f48a56458401f8ff5e42b56d43db2951eacabc1cf6910376a06	eb14218e-17d4-496c-93ea-4dacd15d3ee7	f	f	2026-11-07 05:11:52.069108+00	2026-10-31 05:11:52.017647+00	python-httpx/0.28.1	127.0.0.1
6476faf7-1300-44e6-a468-e59d640cbe85	d98e5248-96d2-4067-a0dd-aa3f7d8d6187	f7b808f5554f4281c086c79ad1b76411f919d8fa6167e913fd396b6f50016847	3d58e88b-b1bc-43a7-94c2-a3d8a7106779	f	f	2026-11-07 05:11:52.279746+00	2026-10-31 05:11:52.232498+00	python-httpx/0.28.1	127.0.0.1
a8a73c76-3221-4f47-a65b-0aacd1a4c04f	73aa11e6-38c1-4540-8082-fb20b88fb3ef	a84e50d4b84d676596becb31181bdc77f86bfe2bf6eb264949bd1487ce2ca6ef	a574e7dd-0554-431e-b6c0-1ac955e04ebc	t	f	2026-11-07 05:11:51.993881+00	2026-10-31 05:11:51.946416+00	python-httpx/0.28.1	127.0.0.1
e3c7c301-35a5-4daf-85f8-48c8a44408b1	58a3d472-5559-4c23-8bb0-42ddd385362b	ced7924d82df436b313bd4b6a374fa0130df276a25be2806ce2bc405baadd613	1bea3139-2f22-43c9-9d7b-657c464b3965	f	f	2026-11-07 05:12:56.212623+00	2026-10-31 05:12:56.158651+00	python-httpx/0.28.1	127.0.0.1
47458b29-0cc3-4d88-b9d0-9dab4c9a90e0	26fe5070-9272-4fa1-a1ff-afe0a7cc4df4	7d045f2904c2b0319774858df6e073b95948dbeab8e7d439873d20fd12743d68	6eb903cd-6f8a-4921-bd71-fbf74585f68d	f	f	2026-11-07 05:12:56.304796+00	2026-10-31 05:12:56.254212+00	python-httpx/0.28.1	127.0.0.1
a95dac66-2e0c-4af9-9c28-e78b7e9bdaa0	e0d35775-e51a-4eb1-aef9-e87b0f8ddb5b	4aafb37c497719aa706c92bd2265172b749a11e601f0249dff11dee3e690fa33	b2946c3c-0638-49e0-8fb1-820b3ac1ff46	f	f	2026-11-07 05:12:56.398531+00	2026-10-31 05:12:56.350348+00	python-httpx/0.28.1	127.0.0.1
193afc93-3637-4ae8-b5fc-02aa8d91dc88	e0d35775-e51a-4eb1-aef9-e87b0f8ddb5b	5d2c8ed6c9e11bf661a6689d3d9d3ed013c3e9ce9fae760a4f48f2dd444c0ca6	2096b21c-860a-474c-99af-d0181161d724	f	f	2026-11-07 05:12:56.526562+00	2026-10-31 05:12:56.480238+00	python-httpx/0.28.1	127.0.0.1
d1d5ac69-4a23-42c0-9c6c-c7613c1343f7	b0ffc2ce-dc12-4fad-b3d6-eca9b62ca5ef	b2c6a093dd104c1279d685f04588e84e3f9ebeee1a563cd6e6dc2f1cee63acbe	90ee716f-3b37-487d-911b-015069e4d0e7	t	f	2026-11-07 05:46:04.421144+00	2026-10-31 05:46:04.37052+00	python-httpx/0.28.1	127.0.0.1
0c92bed2-d546-468a-9391-a2a66f0703b4	d9cf23a9-f82e-4101-839c-2dad7bc4dbd4	af41f8f5bdc04b11209ebcdccac39d2a773246cebe92e0b2b07f21e8d81a95f7	8c8c9bf9-9470-4dc6-976c-f889008ea699	t	f	2026-11-07 08:24:21.94458+00	2026-10-31 08:24:21.891528+00	python-httpx/0.28.1	127.0.0.1
78a58f9c-1e0e-4749-ab9a-d91fa6c4198e	cc84eb5e-99b4-4870-8de1-0b4289ec8987	ede0c228354322abf78650476ad05d36f2697857060261bb38de0b3982273e92	d08af015-dd92-4439-90be-946804f19586	t	t	2026-11-07 05:12:56.600857+00	2026-10-31 05:12:56.547239+00	python-httpx/0.28.1	127.0.0.1
0416c60f-ddbe-4189-90d4-4edd742f0754	cc84eb5e-99b4-4870-8de1-0b4289ec8987	918e8dc9f0c2267b52cb6dcb0ef4fa8540ecfa45670df511687bc373f8ca7faf	d08af015-dd92-4439-90be-946804f19586	t	f	2026-11-07 05:12:56.629163+00	2026-10-31 05:12:56.626568+00	python-httpx/0.28.1	127.0.0.1
b238e33e-284f-4b09-b132-7349fc49cf2a	54190478-8281-4812-83fc-5079ac387073	9714f092d12d0cc9f2a36de0654650624b1c2396813cf5d93544595442dbcb59	3fbe0b1b-1ba4-4f18-bfc3-b4cfb6d4a3ee	f	f	2026-11-07 08:27:34.494795+00	2026-10-31 08:27:34.432848+00	python-httpx/0.28.1	127.0.0.1
30cd775c-0b7c-4e3a-a66d-92a78eedd92b	d119b3bf-3c56-42b9-98f5-79275414ee22	158166fc34d529edb15f7879747cd16b6ebb16576828977102571ff19a2d92c0	50994972-e2e2-4ade-987c-ebf18dbf47e8	t	f	2026-11-07 05:12:56.792488+00	2026-10-31 05:12:56.722808+00	python-httpx/0.28.1	127.0.0.1
8e0b1334-0648-4090-883b-f4ea375bf9bf	d119b3bf-3c56-42b9-98f5-79275414ee22	549bfe6ae71f33fc1e0466b723188dccfa52f91cfbe85b529b3846a6ca1bacc1	cc07894e-3d42-459f-9792-0412e3c94c77	f	f	2026-11-07 05:12:57.03765+00	2026-10-31 05:12:56.992448+00	python-httpx/0.28.1	127.0.0.1
62bd910c-8540-436c-bcdc-f20f5cf446d3	12a618c3-a8ef-459e-9c5c-977db2a3608a	bb5d96b7644a08545d8c6557f7a0eaad719267df00601564009b724f420de358	47fd9f1b-bf22-4a00-b749-f2b1791047de	f	f	2026-11-07 05:12:57.122449+00	2026-10-31 05:12:57.071808+00	python-httpx/0.28.1	127.0.0.1
504decbd-87a8-4e7b-aa57-beba7d2841eb	2010d324-f276-46dd-8b17-7c86b2b0332c	8fb4d2bddfc991539f652b1894da55948ea11d0772b21240c34763b92d629b04	84984630-2320-4ef5-b490-f0eee82abb13	t	f	2026-11-07 05:12:57.288778+00	2026-10-31 05:12:57.240812+00	python-httpx/0.28.1	127.0.0.1
c0e0cb3b-69e2-4537-861b-4b378e2cc1fd	5040313c-9900-4630-93f9-1f0e119412dd	a67050b9fdcfbc7fc6c780a2db547904d26e53fea5587358b10ff35eb5586843	22bfae0a-5616-4a22-a70b-9f0232e517c2	f	f	2026-11-07 05:12:57.554805+00	2026-10-31 05:12:57.505074+00	python-httpx/0.28.1	127.0.0.1
21c07ea8-3ce9-4750-b55b-632b8774893f	4a9bea9a-27b0-4f42-86e3-635c4e82a73d	2777c80cd9df031b744039746e1153e42b999dd4974c437291a788d99e04c070	3670d01c-7efc-45ae-a626-448ea835b6b3	f	f	2026-11-07 05:12:57.694425+00	2026-10-31 05:12:57.648762+00	python-httpx/0.28.1	127.0.0.1
89c77289-966b-4796-a247-fbdf471eec62	478c30bc-05ff-499e-9589-44fd39434fef	0cd88df0e1eee75188d7bf4bf79875dc58c7fcb8f997e7029f2c96e09f9bd005	6f16f162-8008-4dbf-a87d-ccaffa56e9e4	f	f	2026-11-07 05:12:57.895284+00	2026-10-31 05:12:57.847106+00	python-httpx/0.28.1	127.0.0.1
6fdac401-1426-4b2f-bc96-d9bae7a200bb	d86b78e7-7242-47ab-bdc9-8983b447ffe8	b7d51d773b3d9f0794f170a45397cfe3a8803731b3a1fb33a40f40610079ab46	fadbe3ad-01d1-4530-80f8-d1862132f9b1	t	f	2026-11-07 05:12:57.623594+00	2026-10-31 05:12:57.575305+00	python-httpx/0.28.1	127.0.0.1
85015884-6b4c-4a41-99b0-b1e689abfd5f	373dbb4e-b9d7-4ad0-874c-20cf17ad92e5	553df5b0867e0ad6d9ba8ebd946c27cd7d25ff0958c62f5904d8e5da6b70420e	b6df9c13-608c-484e-9964-e66ee0da5fcf	t	f	2026-11-07 08:27:34.880034+00	2026-10-31 08:27:34.87711+00	python-httpx/0.28.1	127.0.0.1
b2a13b3a-3deb-424e-81d3-3e43bb83414e	80e3b0af-deac-4692-9dd5-10bbbb4b5858	0f07bdfa08d70a141846bc8ecefba032c4f9de7abd810bc3e72a10b536b23a73	2bb69bf1-0c67-4857-81cf-1af34c2caf06	f	f	2026-11-07 05:46:03.820972+00	2026-10-31 05:46:03.767289+00	python-httpx/0.28.1	127.0.0.1
c47dc7ca-c539-4051-a26c-dd66a33a48ed	c78e4e78-d91c-4b9e-aa5b-8d6502c5d6fa	fe94ad872116512003d9a54492b31e329a01c057bd3f0f95de18a321efec8cda	53b4120d-b166-4928-a2cc-567f81964a5a	f	f	2026-11-07 05:46:03.964548+00	2026-10-31 05:46:03.915932+00	python-httpx/0.28.1	127.0.0.1
b982d295-2d66-4a30-af48-5b335b3599ce	957ae5b2-8621-43a2-9515-2b43afc0cbd2	9bd68c6501bc6149838154b6ebf10a42382a746da623be2fb4283d0c11ee0832	f86047fa-24e4-4e65-8bfd-7e6cee008a89	f	f	2026-11-07 05:46:04.058665+00	2026-10-31 05:46:04.010042+00	python-httpx/0.28.1	127.0.0.1
7515fdc8-b73c-4735-83bb-0c58a0517065	957ae5b2-8621-43a2-9515-2b43afc0cbd2	87ae7f3512fda1ac657aab774015e7d2e9f1ee0b58c11c6addfb9f139be842f1	aad3a558-3f4e-418d-a667-8f3e9b20978a	f	f	2026-11-07 05:46:04.187298+00	2026-10-31 05:46:04.14164+00	python-httpx/0.28.1	127.0.0.1
379a7dcb-8ce7-46eb-8b5b-76d50a3338ca	b0ffc2ce-dc12-4fad-b3d6-eca9b62ca5ef	9e1189786ac7470e7287fd2d504506e41ccfaa03bbffa931c27db0adf86fa5bf	756d5478-aee4-44bf-8597-f106ac64ada6	f	f	2026-11-07 05:46:04.696306+00	2026-10-31 05:46:04.6419+00	python-httpx/0.28.1	127.0.0.1
8d47802a-3374-4223-9992-e1bdda380d7f	32183dff-fa8d-462b-8def-bebe75c72f2d	f119f60cb48fed2ef3da9edb3e3467050d7a6285a4aa1c1b72ebf22c9e3d9989	c9beb3d3-bb36-4270-9737-d404d4395d0d	t	t	2026-11-07 05:46:04.257627+00	2026-10-31 05:46:04.210173+00	python-httpx/0.28.1	127.0.0.1
4484ec25-347d-44f0-b782-ddb991e30197	32183dff-fa8d-462b-8def-bebe75c72f2d	a065a650286fc5b1d358f97547e41a7a53caf13db968f1979e38288f5e802e10	c9beb3d3-bb36-4270-9737-d404d4395d0d	t	f	2026-11-07 05:46:04.282071+00	2026-10-31 05:46:04.279496+00	python-httpx/0.28.1	127.0.0.1
7381c235-f68e-4b49-ab99-de8c0c93ebcf	dbce35f4-40f9-4a80-bf40-937820427ad4	3d0eeb915f23a04901bfe3d839d8c46638e8a5971c38007c3b308c93649e1cdc	004e85b5-8e25-4522-b140-b51db676eb58	f	f	2026-11-07 05:46:04.785907+00	2026-10-31 05:46:04.732703+00	python-httpx/0.28.1	127.0.0.1
a80c411e-a345-4406-a781-59af58397e92	14f8e0f5-981e-458c-977d-9ebcdbfad1cd	e3bc64d6d02eefad90951817efdfb3406e3f68f48545e57689d1c9a73f6b2158	42cbbc98-a8a5-4297-8573-bbcbc286430e	t	f	2026-11-07 05:46:04.962574+00	2026-10-31 05:46:04.910883+00	python-httpx/0.28.1	127.0.0.1
e98989c6-9235-438b-b42a-2e2bad0ef8b2	5040313c-9900-4630-93f9-1f0e119412dd	45fdef02f044cb856dec24779f883d81c99ce719d420b9ed563398b9bec2eafc	90c3ff0a-8c9e-420f-a8b8-17f6afe38203	f	f	2026-11-07 05:46:05.227628+00	2026-10-31 05:46:05.178996+00	python-httpx/0.28.1	127.0.0.1
209f667f-43d3-42a9-aa56-eb67646f8ce9	26fa02bf-d700-49fb-9933-597991093516	36d301add3f3b8c2d00ac211d2c089b8a2b77b99ff282b67db3dd6733e326295	ab019f3f-43b0-44eb-acb9-b86589c602d4	f	f	2026-11-07 05:46:05.37799+00	2026-10-31 05:46:05.326966+00	python-httpx/0.28.1	127.0.0.1
4e368716-05ab-4430-8443-5e82803f5fa1	229153d3-a459-4880-8cb2-2215fe1f792f	b20b5b61e3742ca14deb6ded82cc69e7a6b8a61c16f0b4116b125f2e21de7da8	5f40a051-e685-420f-86c4-b2dffe5423f7	f	f	2026-11-07 05:46:05.5927+00	2026-10-31 05:46:05.542589+00	python-httpx/0.28.1	127.0.0.1
6e94ae4b-3614-43ca-a7f7-7f512321ffce	8ac7ab9e-54b9-4cd2-b2a8-332bcef9c7c3	188ea33d8a19910f2cc1b9eff9f2238f2be78730863a6b830c608181d1a062f8	1de09d10-4be9-403c-bb46-ffa70f1056f5	t	f	2026-11-07 05:46:05.299788+00	2026-10-31 05:46:05.249438+00	python-httpx/0.28.1	127.0.0.1
fb510593-1a7c-4cb5-8791-13eb8b82bc7f	b2370d12-52df-42d4-b383-0f2c4061c9d9	08e7380c3a14e353ad80c1e439b06ad6d3bcfe3b6d76a5da8446daca68cc9921	eefe23d1-1e65-4754-8271-ba667075cf4d	f	f	2026-11-07 05:52:55.230598+00	2026-10-31 05:52:55.175523+00	python-httpx/0.28.1	127.0.0.1
715ae10b-64a2-4d34-afb1-a0d395e3b2f9	8b079a79-938b-4e39-8d8c-955005e0f0fb	4d3bf9b5ece8b814e2028b321522eb760dc7ba7cd9643e023a5a388931dc74d1	e01e4e0b-ab2b-4a3d-bcda-0785e348f71a	f	f	2026-11-07 05:52:55.332285+00	2026-10-31 05:52:55.277896+00	python-httpx/0.28.1	127.0.0.1
08e02319-f8f2-491f-8b0e-5e19af560453	6113e0cc-f1e8-4330-acc4-4e4d35544e2d	3c4cfc47435ac2ec52271a4a8a4a3ada620c19eb95a4a8a22359fc783ff2e5ba	bf297b22-554e-4eea-a768-dedd5723e54a	f	f	2026-11-07 05:52:55.431414+00	2026-10-31 05:52:55.377852+00	python-httpx/0.28.1	127.0.0.1
8e457143-ba74-4840-a74b-5e4f15a8c4c1	6113e0cc-f1e8-4330-acc4-4e4d35544e2d	a23af810dbeae22541dfc9e8c23da36bbf39cc5279d5186fcb50d6df6df73573	42a17fb9-8885-4e69-b864-dd6902958224	f	f	2026-11-07 05:52:55.595044+00	2026-10-31 05:52:55.527917+00	python-httpx/0.28.1	127.0.0.1
9d2f0ae7-2487-4e4b-81e2-2bcd32eadd60	55f4d195-e9fb-48b4-9902-ea14e0eb9aa4	1051c481b6c215e6f716f1204fcb4bcab4a37741debe6b1e4f5af4e94f9207df	36c7fb59-2fc2-4680-a65b-a0def53f653e	t	t	2026-11-07 05:52:55.67356+00	2026-10-31 05:52:55.619036+00	python-httpx/0.28.1	127.0.0.1
bdad12f6-6e5b-4e54-8c21-a2357d8d3494	55f4d195-e9fb-48b4-9902-ea14e0eb9aa4	d6cc971a7391e33367e7882f9bc8a1313d94ba08039b00d62f5fe1f90c02ed5e	36c7fb59-2fc2-4680-a65b-a0def53f653e	t	f	2026-11-07 05:52:55.704997+00	2026-10-31 05:52:55.701146+00	python-httpx/0.28.1	127.0.0.1
c31884c8-a548-4761-976b-2efd141725c2	5e5e63e5-354e-42be-9956-4f3237c85440	5957f0c7fc046def6187f8d7d348fdb789a3c224a48804786135e69f4f971f26	f860416d-3b4e-48bc-aa01-c891b372fb67	t	f	2026-11-07 05:52:55.819923+00	2026-10-31 05:52:55.765881+00	python-httpx/0.28.1	127.0.0.1
dfef135b-e8c0-403c-ae69-39acf3c7f51a	5e5e63e5-354e-42be-9956-4f3237c85440	71e7145fe1fd062866bb83ad387efb4bdf6df14c68cc47ee1755fbb3e542404e	349c4491-fb9a-4680-9a10-12e74288c60c	f	f	2026-11-07 05:52:56.07437+00	2026-10-31 05:52:56.026793+00	python-httpx/0.28.1	127.0.0.1
ea631486-efaf-4579-ae45-5815651c699a	2a7a573c-ee88-475c-8c7e-776a32e72b4d	4d72bc940726c2b3b45747a79360d53fe9f4336a80b9f96c4d9335d39d843aed	a9d62810-c97c-495f-97c5-b7bbd238296a	f	f	2026-11-07 05:52:56.158886+00	2026-10-31 05:52:56.11085+00	python-httpx/0.28.1	127.0.0.1
d7199bd7-0d3c-4a7a-b913-c015be3d33a1	cdacf1a8-1514-426f-a2d2-ec546983efdf	e56ba45803eb30fedef0b78d7cd6bd5d535d76265a19e7db1b894871f5f377ad	baf7782d-b2b8-4ea7-8fbc-bedf7f70d60f	f	f	2026-11-07 08:24:22.032166+00	2026-10-31 08:24:21.972496+00	python-httpx/0.28.1	127.0.0.1
400867c3-8946-493e-9681-92f363ec4a4a	2a114299-eb44-4513-8e2a-b9be6095f425	e97c0a04a175ff12b72f98dc84bea2cb18c664ff85296722f91bf039fb270159	16627cc3-f9d0-4582-94de-9674bb8ed38c	t	f	2026-11-07 05:52:56.320595+00	2026-10-31 05:52:56.275101+00	python-httpx/0.28.1	127.0.0.1
60801e31-744f-498d-8966-326e132e4013	5040313c-9900-4630-93f9-1f0e119412dd	d603a80981d25788c4456a0b3464ff18bf72d16cc3a845e659a227ddfeef147e	dfb3c8a6-fe6e-4f57-a1a9-cb231165b174	f	f	2026-11-07 05:52:56.584511+00	2026-10-31 05:52:56.534255+00	python-httpx/0.28.1	127.0.0.1
4d27849f-fe50-4286-8396-31f1300e7823	b27cd89f-beef-49c0-85af-2bc3952bd5cb	d30427904900467ab34425c4efd406efc8e906ecf2688a0e39ce0cc345932bbd	6486f071-1985-401c-82e9-e53cad5595b7	f	f	2026-11-07 08:27:34.606329+00	2026-10-31 08:27:34.546948+00	python-httpx/0.28.1	127.0.0.1
d61e486f-fba5-4316-b41e-fb4d0f22bda1	196da70a-1ea1-48ba-bb07-bff22caa8a5b	13407fed2834d5da9295a00dcfc49e4105ad2406192cc499378509a2004872df	8b307cb9-4865-49d6-8fd1-b8657af4539f	f	f	2026-11-07 05:52:56.734634+00	2026-10-31 05:52:56.683387+00	python-httpx/0.28.1	127.0.0.1
0570d3fb-789d-498c-ab67-d23433d9fe9e	94505853-0e43-42d8-9b0b-d84ca7865932	a7b56aa8cb090cfb152eb5dddfcb14a8a2f1fca037cc6d353424a0a243c77887	a3bce55f-d9bb-4f5c-808c-3cc0f7911218	f	f	2026-11-07 05:52:56.946546+00	2026-10-31 05:52:56.898206+00	python-httpx/0.28.1	127.0.0.1
02e8f897-1361-4aaa-9718-3c28fda9ab54	d226394d-e959-42a2-8fc6-70a387db8078	22f05e870963c4d7ab2baa641614cde8907b0b0b2e2919c6e6f09071d8f0a012	a2604a65-322b-4b69-8244-e89f96dc63bb	t	f	2026-11-07 05:52:56.654901+00	2026-10-31 05:52:56.604813+00	python-httpx/0.28.1	127.0.0.1
da21bc52-131f-4cf6-9569-7c0e25a76d22	554c7280-7d85-47dd-8078-fc3476659719	d458dec5afb5283e8121b76e56ae5108c070c85b008e586bbf9619a26431d151	fc1c70f4-5322-4865-a186-d63d48be9545	f	f	2026-11-07 05:59:25.039778+00	2026-10-31 05:59:24.960117+00	python-httpx/0.28.1	127.0.0.1
e3ee3c53-68d1-4ff2-b952-c63501ed79b4	63ef12fb-5488-4e39-baa2-4c876441802c	a032405bdd2fc264cd8222bd92f31eba26e8f3bbf5cbe100c8fff3354f117a08	ac0f4632-2651-495a-a5ae-a8ec2618bf74	f	f	2026-11-07 05:59:25.163493+00	2026-10-31 05:59:25.101046+00	python-httpx/0.28.1	127.0.0.1
0764cdec-6444-46f2-9722-d82d96ff0da3	e7b763d5-0438-4f7b-8241-e50c55546570	9f8006fd66c842b9eeb3279ac36c4d3ab878aef5e65f1f729d750ade797a7f19	1c513946-0e57-4434-bc7b-b831db22561c	f	f	2026-11-07 05:59:25.306462+00	2026-10-31 05:59:25.249862+00	python-httpx/0.28.1	127.0.0.1
93750d59-f81b-4b71-bb57-31f808b2cad6	e7b763d5-0438-4f7b-8241-e50c55546570	5f62ffb1cd6dbe163197e35f9692014cdca43b422672626a399134d24cd80bd0	bc575480-086a-40df-8253-90c3b378a558	f	f	2026-11-07 05:59:25.486086+00	2026-10-31 05:59:25.431258+00	python-httpx/0.28.1	127.0.0.1
a68d0d98-f9e3-4745-a191-f7f4ef9cc963	270816b6-4630-4347-ae89-93ea0cda1589	97a341d144bab10921fcc0b8758fa8711711e470e0f6a9d2bb7f1dbdde8cac69	84d3aea2-7e2a-43b5-b50a-f571bbbb68af	f	f	2026-11-07 05:59:28.460958+00	2026-10-31 05:59:28.412225+00	python-httpx/0.28.1	127.0.0.1
5db81516-93cf-4e41-a3f5-a03c21a63c06	be4ff5c5-16fb-4e4c-9fdb-db6c443464c9	9076f72ee133e440c0469c2039707c125765d0311c263d72189802e8bc79cea0	3310df78-58c0-4527-a04f-25b1ecbc1e8f	t	t	2026-11-07 05:59:25.569727+00	2026-10-31 05:59:25.51118+00	python-httpx/0.28.1	127.0.0.1
d1fec6e9-c0ae-41d7-8fe4-402c94036a2d	be4ff5c5-16fb-4e4c-9fdb-db6c443464c9	f1d5040a56388ab15a972844f1535c2ec8d4be62b931782c50811973c15167e5	3310df78-58c0-4527-a04f-25b1ecbc1e8f	t	f	2026-11-07 05:59:25.677876+00	2026-10-31 05:59:25.673861+00	python-httpx/0.28.1	127.0.0.1
6b74d978-2f02-4930-a2d8-6b711dfda531	b144c086-d788-4342-8e6b-3dfee3355527	cf43db8e1800994ff2c705b5e49c9e33708c9005b9d26d3d926e3cf56f701bd3	27906b28-f800-4609-83e7-6a0bb0b88b2c	t	f	2026-11-07 05:59:25.797633+00	2026-10-31 05:59:25.742714+00	python-httpx/0.28.1	127.0.0.1
73a13289-d52b-4e4b-bbe4-888eddc753f0	b144c086-d788-4342-8e6b-3dfee3355527	3c519258b47ec1f35fcc762fb07248318da751131d61e24a3d7f62222380ef53	b042885c-1a51-47b1-bb40-87f37f3505fb	f	f	2026-11-07 05:59:26.101528+00	2026-10-31 05:59:26.044475+00	python-httpx/0.28.1	127.0.0.1
b2fce864-42cb-49e3-9423-bba9cd62f07d	156085e9-785e-4e4b-8e1e-b6109bbc1876	b05a0ae4b1e264e27840f129b8bd1759b4f5ca3b932ae39d3e7cfbc1cf3b4823	893c321f-971e-4574-9cea-489df3d1db13	f	f	2026-11-07 05:59:26.191553+00	2026-10-31 05:59:26.140976+00	python-httpx/0.28.1	127.0.0.1
6112e874-40fc-4197-9101-c244b01032b8	2f082914-d1df-42d4-8237-de9abce8e0bd	69828fef5e34f08b1f7ea9859face7e9b969fc0970438ea959870008ed68f55e	012c6b65-ed2d-4d11-bcdf-8e6e4f597957	t	f	2026-11-07 05:59:26.619128+00	2026-10-31 05:59:26.550904+00	python-httpx/0.28.1	127.0.0.1
7c45b407-ed71-4e33-8445-920452c5fb3c	5040313c-9900-4630-93f9-1f0e119412dd	cbe1d20adfc7af44eb5e38cb0d4e5d6c74b723cfbeab12253d9f84bdf7b3f181	92d62784-dab5-46b4-8e9b-98c5673887ad	f	f	2026-11-07 05:59:26.807258+00	2026-10-31 05:59:26.750013+00	python-httpx/0.28.1	127.0.0.1
47a53fe1-2812-477f-aa1d-2f0d8f64666d	faa7c350-693c-4f32-a946-cf94bb2338b8	b7c085dbf1549fd337b6563af54a62ecf52c1cb7b826e9facea948b92f794194	17d0fca7-9c09-4bb0-b728-a417df4ac84c	f	f	2026-11-07 05:59:26.963087+00	2026-10-31 05:59:26.905572+00	python-httpx/0.28.1	127.0.0.1
2f41f15f-cedf-412b-a50b-158a5f64c949	f7dde876-4c5d-41bd-83c7-a550a7f01087	5701a105e53af69972226be6336a21fe7fbd7b0a42b46666648db379b132463a	c04cd9d6-5f05-4639-ab7c-b81bf4c5a6e6	f	f	2026-11-07 05:59:27.03703+00	2026-10-31 05:59:26.980888+00	python-httpx/0.28.1	127.0.0.1
0cdb4fe9-c5b9-48a3-86ec-d438d7afbb9f	5040313c-9900-4630-93f9-1f0e119412dd	31c0396a8394b2843487eee340cf4e170cb440d34cdbdfcbc095aea511d23808	11a98ed2-8787-408c-9c43-337a4d90411f	f	f	2026-11-07 05:59:27.328902+00	2026-10-31 05:59:27.267956+00	python-httpx/0.28.1	127.0.0.1
1fea45a5-c446-4f26-9296-3baadef25efb	5c14ac70-d6d0-4bbc-9526-ea6177d39455	e094a7386255acb3855cdc70912aa556046b66dd049cee28eef69e03a2c3a5b3	1e48853c-86cb-4b7b-bf7f-4f62048fb738	f	f	2026-11-07 05:59:27.470795+00	2026-10-31 05:59:27.419131+00	python-httpx/0.28.1	127.0.0.1
a818edb1-7322-467a-9bac-0decd298fcaf	9baaaaf9-3e73-45d1-83aa-47e512236d5c	b681f71fd7987b4ed6f75c02bac4ecf6bfcdfd51a5813bc1ed06605097732fd2	cd4d0a27-eef5-4621-8545-a55bf27d1dbc	f	f	2026-11-07 05:59:27.538644+00	2026-10-31 05:59:27.490971+00	python-httpx/0.28.1	127.0.0.1
c4fdda70-c76f-4c16-9f83-4af786a8782a	5040313c-9900-4630-93f9-1f0e119412dd	a9004047660882925dd5d469ceaff0ab58506d8564041acc7956961f472b6567	64ee7d84-f316-4543-a9f2-bc0e091c3634	f	f	2026-11-07 05:59:27.715807+00	2026-10-31 05:59:27.670208+00	python-httpx/0.28.1	127.0.0.1
b255652e-e2d9-4e4d-8c30-b34ffc498cc0	9eda81c6-d4ec-4b2e-9ba2-8ff6d92a4479	027132ace7c95a9966d927da113c0a5d109e171c96cbfcfc4d17a636b9e73e9a	53383a81-c476-4c99-87dc-602c7e759963	f	f	2026-11-07 05:59:27.842705+00	2026-10-31 05:59:27.795282+00	python-httpx/0.28.1	127.0.0.1
86725c1f-5de4-4ee8-bd10-059544fba199	6f23938c-cddc-4a28-8f42-c0cb597748e0	3da04985236e6118779796f6b122c940f0a5c14f850aaf239d179d7c7712c382	9e0c06d5-9ddd-445f-ab26-5a8ff4e6819c	f	f	2026-11-07 05:59:27.90986+00	2026-10-31 05:59:27.859586+00	python-httpx/0.28.1	127.0.0.1
38a8cd2c-652d-4418-befd-0c9b323589f0	5040313c-9900-4630-93f9-1f0e119412dd	ee56770c868dd4cd42a46b96bb376e07ef73415bf080bfa5d07da77c2102bd9d	fef7d296-0dbd-428b-8161-783a83978aba	f	f	2026-11-07 05:59:28.090215+00	2026-10-31 05:59:28.040666+00	python-httpx/0.28.1	127.0.0.1
f49f2c2e-6778-4f92-8ee2-a8ebac8238c5	fbc2d60f-635f-4ccf-bd0b-d5af2b51a2fb	5275f31ca37ff478a6400ecf7d2fc2fe3406ef82f45b7fd686d8756d6a661262	16823f84-79ae-43ea-b43d-659fe048e7c5	f	f	2026-11-07 05:59:28.23195+00	2026-10-31 05:59:28.179956+00	python-httpx/0.28.1	127.0.0.1
0d8bf8f5-d363-4a6f-a170-f10884209c52	5040313c-9900-4630-93f9-1f0e119412dd	4e97a314cce30e3af6faac1a43ec5e17bc10bd8d646aa05bdc8ef08b92acf736	02b8df57-a773-40bf-a6cf-4b09a5093668	f	f	2026-11-07 05:59:28.31001+00	2026-10-31 05:59:28.261003+00	python-httpx/0.28.1	127.0.0.1
89ef2ca3-bf38-4473-84bf-f4052baf2a48	5040313c-9900-4630-93f9-1f0e119412dd	bb207bd31bef874ab76e59dfffb9384e22dd8e573935ad45466c0214f5df368e	6ce019dd-4b46-4ab0-933d-a52a8c9931a1	f	f	2026-11-07 05:59:28.538691+00	2026-10-31 05:59:28.488429+00	python-httpx/0.28.1	127.0.0.1
ec7a5e3e-051b-42b1-916b-fa91c1ed3d09	5040313c-9900-4630-93f9-1f0e119412dd	449393686eee87cd621d3459a7c012ec9dcdf43fce7bea08e756512547f5e1ca	dd89ae4f-34e3-467a-9bb2-827f86c80f18	f	f	2026-11-07 05:59:28.887442+00	2026-10-31 05:59:28.836847+00	python-httpx/0.28.1	127.0.0.1
dcaf168f-6d7e-4ebd-b52c-d271f80bede2	6fdbe691-57bf-4f06-a74e-c36de5cd1ae3	4155c0ddfffa1ffb7ffcb34876f03e976efa30fba677093cf6ac775a9bcd624b	9c6392bc-5840-48f5-adb4-6db45dc75d39	f	f	2026-11-07 05:59:29.058409+00	2026-10-31 05:59:29.001919+00	python-httpx/0.28.1	127.0.0.1
9d24372c-5b20-40bc-b372-a0ebe6c00cce	b4d76ced-14b7-45da-a840-51a3352235f9	00356d9c5c1e8680b81a20b4167d2bd50acbd8ed2a1781705d9b91b23e31f93a	cc025937-4ecb-42f3-9f0e-43ec5cc2d400	f	f	2026-11-07 05:59:29.346005+00	2026-10-31 05:59:29.293933+00	python-httpx/0.28.1	127.0.0.1
a68d7edc-e122-41b5-aff3-d737ce113200	14f0ac70-8a59-4176-b597-f585bed001fc	d074fc647d2672a908c4a71017cabe5dd6006a652452b77adf4d617ee118b448	78bb87be-dcbe-4e4c-b068-504974f105f4	t	f	2026-11-07 05:59:28.962537+00	2026-10-31 05:59:28.905451+00	python-httpx/0.28.1	127.0.0.1
14ed5866-0ab9-465f-80d5-aefebff6408e	c32a5212-b7f3-47b9-92fe-96e24c186d3a	2640bb5b13ea7513dd63ff602df86b9b1f86e21e82f9929d73c5165e63218e5f	3b579010-29a8-4478-8f13-192c5b789a36	f	f	2026-11-07 06:13:49.564766+00	2026-10-31 06:13:49.510019+00	python-httpx/0.28.1	127.0.0.1
c41ec000-7703-4798-b8fc-e61b077415fb	d2702a1d-a785-409d-8cab-f3fca8383db5	0525936525a01112254b1eb498dd24a7a3133b5923aa6fee0356962e3900bbdd	ec7d1ce5-585b-4123-a8cf-c86287050ef3	f	f	2026-11-07 06:13:49.76515+00	2026-10-31 06:13:49.709246+00	python-httpx/0.28.1	127.0.0.1
5be3cd8c-93f5-4588-b562-15d5ca1c90cc	6eaadb1f-a86c-4a96-9f46-5be20c86d832	a5e5a10e20599ae77e847ffa68492bd26826f8ddf5a1acd1036882557781814c	fef2d298-7e22-4d25-bee1-3a3b87e9523a	f	f	2026-11-07 06:13:49.866323+00	2026-10-31 06:13:49.810271+00	python-httpx/0.28.1	127.0.0.1
a9a380a3-a03e-4245-879f-43aca06f2726	6eaadb1f-a86c-4a96-9f46-5be20c86d832	ad281582c6dc5c382547cd2420dc86fbe59ecdedfc5cc56dd1a5b8e2f11ed49f	c3efbc5d-c43c-41bb-9959-d11932c8594e	f	f	2026-11-07 06:13:50.013664+00	2026-10-31 06:13:49.961677+00	python-httpx/0.28.1	127.0.0.1
7e3f9ff3-e4cf-4886-9b56-d4b38a1e4783	273c9f88-fd9f-41a8-ad7f-fda6f3e69768	c791b0ac0b60ae0cd0132084ceb8e2deaefd6edfe411ee4c3b2005fa04f32b6a	3bb36288-f744-4889-9e0d-36241512b68b	t	t	2026-11-07 06:13:50.104979+00	2026-10-31 06:13:50.042695+00	python-httpx/0.28.1	127.0.0.1
1a669a36-48ab-4ad0-b252-634a7c7f4579	273c9f88-fd9f-41a8-ad7f-fda6f3e69768	3cd0a7dcc1557a75bc12a9770f6f7f76c2d7032caa5299482d15cb450859ebcf	3bb36288-f744-4889-9e0d-36241512b68b	t	f	2026-11-07 06:13:50.136365+00	2026-10-31 06:13:50.133715+00	python-httpx/0.28.1	127.0.0.1
9ed211e6-5007-40c2-8d53-7951b40c4240	b23e2baa-5c89-4c93-b7a7-129f2c72d695	5cad946c6a76da6b49a2d9bd021da9b15aecb296f12c39c2d9fe9f392a35a7b2	8eb013db-7dab-4959-b350-4fb0dfe6690e	t	f	2026-11-07 06:13:50.240277+00	2026-10-31 06:13:50.189973+00	python-httpx/0.28.1	127.0.0.1
8ec52fd2-b712-4fb9-ae33-1c46ee586775	b23e2baa-5c89-4c93-b7a7-129f2c72d695	2de6498190259fc010505dfe4893ad490b3a9d623aaf7a98371ce89d690c6a97	6344e800-0b48-4fe8-86de-6d24368c491e	f	f	2026-11-07 06:13:50.489162+00	2026-10-31 06:13:50.444043+00	python-httpx/0.28.1	127.0.0.1
2444074f-5b5b-4475-afbb-c7f770810e01	363682ab-f901-4a29-a3aa-ba02862dffe8	99b2b5248048664cf4897f1153bf7b93c348d3013426e1a005d1b91deb689eec	9cff5072-a953-4715-919e-ca088697b1b3	f	f	2026-11-07 06:13:50.576669+00	2026-10-31 06:13:50.526877+00	python-httpx/0.28.1	127.0.0.1
18f53e9f-8812-45d8-9866-d40d838985f1	cc2d41cf-22a5-4018-b6a0-a26f4f36f26e	d2d2a66355e9a065220f4a8e16483d435c5bf27bfd95de81e9ebf0a579278982	6ed9f997-d85e-4f7f-9ef7-8235e9e05394	t	f	2026-11-07 06:13:50.754196+00	2026-10-31 06:13:50.705132+00	python-httpx/0.28.1	127.0.0.1
31e4ad8e-fc3a-4558-be1c-04e6d85cf481	5040313c-9900-4630-93f9-1f0e119412dd	98c207920e0322967c072452fd60d617c1dc82d5c27cd2625427e86a6e71834b	bf69b40e-4376-4d76-9141-c8283fa97a9c	f	f	2026-11-07 06:13:52.542211+00	2026-10-31 06:13:52.496563+00	python-httpx/0.28.1	127.0.0.1
6da63356-0ba2-4305-8df8-6fb16d87c210	ab9eb3ad-9572-473b-87e5-ecfb47c8c965	ee2a37d600edff5e13daa2b5877e6091ef1dcacf538bcf03d030eeed935fcf1f	adae5854-e5c7-445c-9e86-076447345d4f	f	f	2026-11-07 06:13:52.69984+00	2026-10-31 06:13:52.647464+00	python-httpx/0.28.1	127.0.0.1
22b1e4ca-273c-4e88-a45c-989202c39509	8ec9343a-c648-44c8-970a-e80a8b737f13	cc56efb33fe1a131d7aff13fa1cf47bd3fdb8ff5a1437e05e7d3c6427c17cc82	b6e03fa3-cd0c-4860-8856-2efa52fb4af6	f	f	2026-11-07 06:13:52.909782+00	2026-10-31 06:13:52.859656+00	python-httpx/0.28.1	127.0.0.1
76019e4b-a4e9-46a4-9d6a-3096921ad439	a3acd349-ecfe-43b2-b0c5-0b32d9b9ffaf	d20559a19de1f724a8ac15a0097939bfdacfa636baf9be908f728275a513ab0c	572b3de7-bb4c-4261-bc08-4963adba76b5	t	f	2026-11-07 06:13:52.617079+00	2026-10-31 06:13:52.563498+00	python-httpx/0.28.1	127.0.0.1
8c7556b2-8cf1-490b-aa87-54c1aee8ed1c	758cbb6e-1315-4950-951a-1f33572219e7	7b89ae04fb98511f3de59b6cd5d0c7469b4ce77d739f89225e69d5ba5e25c0f0	bbc8ea59-360e-486d-a22e-6df2ad3eb851	f	f	2026-11-07 06:26:01.239492+00	2026-10-31 06:26:01.187694+00	python-httpx/0.28.1	127.0.0.1
b6b563bb-49dc-4544-8273-af43dd3e1cab	33690c3d-86a0-4aba-abf2-1fca9b4cbe33	4aa5cd4111b685289dec6275b30625f34455a828063684be805be935a1caf7fc	4cd0b608-51e9-4d49-8905-0e6dca7d4b44	f	f	2026-11-07 06:26:01.388929+00	2026-10-31 06:26:01.338979+00	python-httpx/0.28.1	127.0.0.1
d5689621-f785-49d6-a713-3c022e31c313	c05057aa-da45-490a-b1ea-f30a2d1379cf	8d8e955fb52b1ffcd1210789abb17c2b52845d512e678c6e6eb3b8e926511d3f	244e32c1-5053-4d36-8973-3668f7a5b4ef	f	f	2026-11-07 06:26:01.484251+00	2026-10-31 06:26:01.431994+00	python-httpx/0.28.1	127.0.0.1
51c1ed29-3115-4d47-9438-4d36191cdd79	c05057aa-da45-490a-b1ea-f30a2d1379cf	c0c1f6da4a7f2b20a6efbbea788ad8009ead2927f4a5a675b0fd6e6aa3900137	d2f508cd-ac79-4619-aaf6-fe98d5a4fe93	f	f	2026-11-07 06:26:01.619053+00	2026-10-31 06:26:01.573081+00	python-httpx/0.28.1	127.0.0.1
6ef4c571-233b-4ea9-92a4-78b1a00099c7	6f42db5f-3763-4a9c-a203-4d0c3cf09e17	c5cf90d569561f1e4d2a2f51318b58963694855f5bf6282d2aaf735d3944de47	b6e965ef-2d89-4c8d-9150-2d94a8305e61	f	f	2026-11-07 06:56:45.215668+00	2026-10-31 06:56:45.146353+00	python-httpx/0.28.1	127.0.0.1
cdc70191-d1ef-46ba-8fdc-95191368d2ee	e0236433-07f7-49d1-a82f-7d0f89d8c405	bb438a3265497675d6f74ac9211e4b9bc1283968aa6630fa4bac7582c768fcdc	8daeb7cf-6d64-47c6-932d-8e2dc8525751	t	t	2026-11-07 06:26:01.687234+00	2026-10-31 06:26:01.638016+00	python-httpx/0.28.1	127.0.0.1
0430cbed-3dd5-45c1-93cd-b62faae84cb5	e0236433-07f7-49d1-a82f-7d0f89d8c405	6a6491d24b3630afaf7ee97890bf0b6f380f3c89677055006ac71ba876174fad	8daeb7cf-6d64-47c6-932d-8e2dc8525751	t	f	2026-11-07 06:26:01.714839+00	2026-10-31 06:26:01.711867+00	python-httpx/0.28.1	127.0.0.1
4e0b0c0b-ba00-45a5-9062-73e8077187cf	537a0cb3-7755-40b3-b86c-fbb8b65dc2a8	2be61814d14101442f1fc26772866012b44794f929fe4dfaf16a1664aff40475	aa451e46-aab4-487d-ac4c-c0e46166d763	t	f	2026-11-07 06:26:01.818101+00	2026-10-31 06:26:01.768606+00	python-httpx/0.28.1	127.0.0.1
b705aea4-7d18-432a-90bb-618303d6d55c	537a0cb3-7755-40b3-b86c-fbb8b65dc2a8	faeeb7eb28a395ff37a66a23a9fc95f565b88da2cb6e04e09ad5c3899a9dc8f2	5bf3c59f-f72c-46e4-91a2-b3090fb26854	f	f	2026-11-07 06:26:02.055328+00	2026-10-31 06:26:02.009595+00	python-httpx/0.28.1	127.0.0.1
28754323-9fe4-421e-9f5e-7b032aa01392	0e6486aa-8925-457f-b2a3-a8e65f6daf02	4f9906e2d09c4b3b45a105c07c102983367bbe83bb0860e8ed344d804f88e553	f90854ee-c301-448e-9d75-14ada6479d04	f	f	2026-11-07 06:26:02.138249+00	2026-10-31 06:26:02.088925+00	python-httpx/0.28.1	127.0.0.1
c91ce0e1-d913-4382-8d42-886303ed115f	83f844e2-9feb-4657-81e7-4bd8b52e65a4	08750943cf1d013a2d3bd21a6e979c72e5fae82d6313192083dff1953001221b	86310231-a813-4237-9712-7a2c925e5780	t	f	2026-11-07 06:26:02.31227+00	2026-10-31 06:26:02.262328+00	python-httpx/0.28.1	127.0.0.1
417fb6a0-e603-4ba3-94e1-ac03ff05858f	5040313c-9900-4630-93f9-1f0e119412dd	b2ddbd88c34035b8b68c3c8e073108d273d60aa6380ca6d3737160a571b25299	d86712d0-c3cc-47da-b586-39ddf14ad302	f	f	2026-11-07 06:26:04.079357+00	2026-10-31 06:26:04.027736+00	python-httpx/0.28.1	127.0.0.1
8e334e7b-0bbe-4677-a70d-5906c3cbd60f	b82acb67-c9ec-4162-96b0-0123c438f125	7e03534d278589f4f1296849b8d9ca5a141adede136dc435b11d4ad2137c686a	b286c4ad-2f17-4d6a-9502-fb2a10d2bf78	f	f	2026-11-07 06:26:04.228191+00	2026-10-31 06:26:04.177992+00	python-httpx/0.28.1	127.0.0.1
d65aab00-aca0-4cdc-ace2-62c702363473	988dcc1f-2a72-452d-8edc-e69b41088cb7	4b6aab2b55467a361e84df1d8c7492aa22b3f400e9417e9d666b10688a77a60c	cc37c44c-50ec-4aa9-8c23-62ce19abf179	f	f	2026-11-07 06:26:04.436876+00	2026-10-31 06:26:04.389644+00	python-httpx/0.28.1	127.0.0.1
fc5aad84-d307-4512-aeb2-6f08617890ea	b259462e-0d8f-4f33-8f56-bb56201b88ae	47ae721a8ee2fedc254dd873ae8466d09ddcc02b4447f292ec0b47d966569bbb	f84523af-d9c5-46e9-9935-08f7315c30a5	t	f	2026-11-07 06:26:04.154106+00	2026-10-31 06:26:04.102479+00	python-httpx/0.28.1	127.0.0.1
ece0d696-f153-4436-b4ec-5b4b8dee565b	5040313c-9900-4630-93f9-1f0e119412dd	f14c7902905a218f29ccb4cffa5f01fa45e1be19cfd8c35297481567796348c1	ca79bd5b-77cc-475b-a976-1541d2aaa2ab	f	f	2026-11-07 06:36:08.593126+00	2026-10-31 06:36:08.51892+00	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	127.0.0.1
cdb9b25b-96b3-486f-acc5-67b0e7eaed0f	8cefc72d-4b6b-460e-8272-580cc96d8fa4	b00ee4605ebdde002053c8dda48fd8a5b57da63123ba147e4943413c2b661deb	b9c6072f-2f19-41bc-a355-a93ec008f43a	f	f	2026-11-07 06:56:44.960056+00	2026-10-31 06:56:44.904109+00	python-httpx/0.28.1	127.0.0.1
36065545-e134-424d-a433-dc082b34261b	f91d5aaf-69ff-4084-a36c-0fae96432e54	e1eaa7728bf25fa5da6067e47f7f5d6eb8e17a7b55b196f78e4f56c1e3c978e7	c5ae53ea-9809-486a-a045-708db437bde8	f	f	2026-11-07 06:56:45.104154+00	2026-10-31 06:56:45.051525+00	python-httpx/0.28.1	127.0.0.1
a5a48bb5-e8e4-4922-8fbf-7ac76e4ab760	6f42db5f-3763-4a9c-a203-4d0c3cf09e17	f027a92827853e0836c5f5bd1805b37d752a5738ae78022931eb5727409e035d	d038f193-681e-417a-a54d-5afb49379bc6	f	f	2026-11-07 06:56:45.369443+00	2026-10-31 06:56:45.318507+00	python-httpx/0.28.1	127.0.0.1
bc89c1fd-1223-4ff1-8c03-20165c59af51	8917a4d5-0384-45b4-9836-1bdecdf360ca	38203ed91f5b3385dcc6ad7b13320b9d53d86eccbb468994441f6e3915566ab2	d48f9645-65df-431b-8544-4998768dcaf7	f	f	2026-11-07 06:56:45.967325+00	2026-10-31 06:56:45.910027+00	python-httpx/0.28.1	127.0.0.1
5188e84d-ddfc-404d-a3a6-7ad609832fcb	1ba8e121-7af8-4e63-9dc2-4e8bfb005045	6a970b0f2a2b7231b21eaaaee65d14f913ab5213c82e5660dfa24160be82e2a4	168bd358-fa50-44de-8815-f08fdce273f7	t	t	2026-11-07 06:56:45.444468+00	2026-10-31 06:56:45.391578+00	python-httpx/0.28.1	127.0.0.1
2c84bf58-08e4-4226-a8ac-54579470cdca	1ba8e121-7af8-4e63-9dc2-4e8bfb005045	bda71b71c88de493bd047b1d62035d3eb8309c98dd9ea7308dbf2437c3c5cfb1	168bd358-fa50-44de-8815-f08fdce273f7	t	f	2026-11-07 06:56:45.476164+00	2026-10-31 06:56:45.472446+00	python-httpx/0.28.1	127.0.0.1
ad38cf51-2607-4eab-9e48-f51af700630a	7350b76c-28c0-4b09-98e2-6eca12318089	b8a25894b9274f72c55b5b7c6e24c57b4763a453accf8aa56077585c39cdba5c	6245ebef-aed5-4e9b-b3d8-ed2af3793ea0	t	f	2026-11-07 06:56:45.588741+00	2026-10-31 06:56:45.534526+00	python-httpx/0.28.1	127.0.0.1
f03cefe8-34cc-4f37-b6f9-8649de0d57de	7350b76c-28c0-4b09-98e2-6eca12318089	9ab967f0f47449a19609c1148ac1635e21885c46a66d09f2d6248c9efc580e9e	5e5c73bd-1042-41db-818b-5bfd92e2f8f2	f	f	2026-11-07 06:56:45.875426+00	2026-10-31 06:56:45.821237+00	python-httpx/0.28.1	127.0.0.1
f6132f94-dba7-4a70-b48c-cd52b992ed69	bfef7ec7-8624-4555-9e1e-8c418e6f2f61	6a25e6ac690d7ffc9ae0eb6a62a573abee876369ad5c5c4b4c2230bb408a875a	63fc9259-5043-4f1a-a4b6-c75714536892	t	f	2026-11-07 06:56:46.158151+00	2026-10-31 06:56:46.104617+00	python-httpx/0.28.1	127.0.0.1
d5fd1b36-ac2b-4302-a3f4-17f1498973af	5040313c-9900-4630-93f9-1f0e119412dd	900e2a943b28f76813c0073dba684ad2da6a07161501e11d07812324672f7573	03d9cc98-b0d3-4a14-afcb-968e9f72eee4	f	f	2026-11-07 06:56:48.119264+00	2026-10-31 06:56:48.065597+00	python-httpx/0.28.1	127.0.0.1
9b621db3-65c0-4c0d-a04b-b5a22c7364e3	03ab9f1d-1184-44f8-8487-d37950fff752	2ae05db40368f26831abc4d12a23810e175012d60c8be52c30f4a6fe43809071	aec91374-267b-409d-9b29-c97a49f19203	f	f	2026-11-07 06:56:48.273934+00	2026-10-31 06:56:48.221244+00	python-httpx/0.28.1	127.0.0.1
21ef2191-3453-4918-aaa6-511d97873c13	e3a621ee-c790-4d80-9300-bcb723ea2b6a	33839a19bd0e23dacb2849bc63a877f59f3b0913b6e55accd05eb102a0f2671d	ef50677d-32bf-4094-9132-532f0d00ee33	f	f	2026-11-07 06:56:48.489398+00	2026-10-31 06:56:48.439921+00	python-httpx/0.28.1	127.0.0.1
df4fb22c-63ef-425d-9b58-3a75f8d8bd8d	12fcf2a8-0bcd-418f-b045-b86a3e365b43	0cbb95e9eee1cd342aae225eb2dca703abc377ab3eded864da31f987b9abd29b	c02ed96f-2136-440e-b765-47a899ce9b32	t	f	2026-11-07 06:56:48.193838+00	2026-10-31 06:56:48.140734+00	python-httpx/0.28.1	127.0.0.1
b2b2611c-1187-4201-969c-3eab341828f4	a9dbd524-4906-43f3-9565-1a1dc3e68164	ea33891c1bf3d347ccc7f27dac591e94f4c38141b68ca8bbbfc599d16e303b9c	b1736ac1-a1a7-4eec-a990-5b6b6656ee0d	f	f	2026-11-07 06:57:54.771499+00	2026-10-31 06:57:54.716176+00	python-httpx/0.28.1	127.0.0.1
45b1df40-6474-4e9a-a956-0979a0e74aff	c1c316c1-d0ea-4de2-a38e-8b0c34a96c1b	a4496be9f5ae7c59f9b099a5b222211733cb937b485c0bfc2e32179f6785090c	0eeb2c87-56b4-461c-8fca-a60ac0c74219	f	f	2026-11-07 06:57:54.870785+00	2026-10-31 06:57:54.818812+00	python-httpx/0.28.1	127.0.0.1
28e652f6-6b4e-4daa-a62f-434330625aac	3154a4b6-3a58-467d-ad61-21f197e468ee	c4248c7b96c517d13edd563b7a2418262608637fc0c3f03e41b6b08aba49b537	a211af93-f91d-44f0-a1c5-751673072933	f	f	2026-11-07 06:57:54.96892+00	2026-10-31 06:57:54.918132+00	python-httpx/0.28.1	127.0.0.1
249a5207-3fe4-4701-94ec-66bd86a9e377	3154a4b6-3a58-467d-ad61-21f197e468ee	8b7d6e63aa8514e35ad5fe1ed70202a5a4fab4b8e9e90540557f7511916264fc	7fc0e2f7-8984-4b09-8e4d-600bc8204346	f	f	2026-11-07 06:57:55.106789+00	2026-10-31 06:57:55.057789+00	python-httpx/0.28.1	127.0.0.1
e2f5dceb-0047-4efb-9c96-987e77b8f665	5c45be20-2ccb-4a5c-a8cd-97cfad043ed8	f2eab10b51ffa9f7e37de2078ff9b6e7a10831641a38c5e2591dea926597b8d2	317b6490-415f-4220-b08c-fdcc6510b85a	f	f	2026-11-07 08:24:22.242163+00	2026-10-31 08:24:22.19148+00	python-httpx/0.28.1	127.0.0.1
cde22a8a-52b1-4826-b6a5-f0ddd269cf28	b27cd89f-beef-49c0-85af-2bc3952bd5cb	a7a744b885ffed78df8abfba5111843f600574ebed1da23e6f59df3c8f1adcf3	915b3ef6-47a2-4f60-9c45-95d8523f2030	f	f	2026-11-07 08:27:34.758637+00	2026-10-31 08:27:34.704336+00	python-httpx/0.28.1	127.0.0.1
f7d628bf-727d-48f0-a538-e05239c92859	fd65f38f-87cc-42a6-ab9a-7b804b139103	90d2920634c0d85b9b33ad84a8e7675cd281b6bf713a235ca60f16e32fae026a	eae1d466-da5f-4985-9449-225e3a3f6244	t	t	2026-11-07 06:57:55.181402+00	2026-10-31 06:57:55.132279+00	python-httpx/0.28.1	127.0.0.1
746bc48c-d1f7-4139-bae1-42f7404bca61	fd65f38f-87cc-42a6-ab9a-7b804b139103	0be396583f013d8a2ff2f6381896c537bc051430d2bf8208d57d433f2184b5be	eae1d466-da5f-4985-9449-225e3a3f6244	t	f	2026-11-07 06:57:55.212211+00	2026-10-31 06:57:55.2096+00	python-httpx/0.28.1	127.0.0.1
ea5a9b50-1fd6-4cf9-8950-b9780df0f641	8c3d9164-64db-4f25-bd84-c74a61f47a07	eb0591ff79b3106c62ccb6a6f3a273d9d696a19ab365e5ea3217773c4c271454	596dfac1-d3a9-474e-aa21-be8dfe23b344	t	f	2026-11-07 06:57:55.320177+00	2026-10-31 06:57:55.2706+00	python-httpx/0.28.1	127.0.0.1
0a7cfda4-4bf5-4a28-b4a4-6388e6a0c80c	8c3d9164-64db-4f25-bd84-c74a61f47a07	8d2eaa1ab07869ce660ebafd4a49359869e1751d5f8b7b0bad7b2b84fa3eb0a3	4c43ad8e-360d-4fed-a2fb-003cb82971e9	f	f	2026-11-07 06:57:55.586284+00	2026-10-31 06:57:55.53423+00	python-httpx/0.28.1	127.0.0.1
47edab11-aa01-4bf0-9389-813967d786c7	0ee8c0fb-b477-4640-96f9-55e7f4e62d18	26c92d5ac53c1d9a03c76a29964d24977d30a011e103141aa194c19665314bb6	7b44b7ce-4e5a-47ab-a260-76dfda364562	f	f	2026-11-07 06:57:55.676493+00	2026-10-31 06:57:55.62166+00	python-httpx/0.28.1	127.0.0.1
c91448fe-ffb1-4f37-a699-aa7322ea6b57	ef934208-21d3-43e9-9451-426a3526c623	7d6164da28c7ed235c6e1557a1a5228b7fb0c91693f7acc564caa000cd45ff2b	b7fc5b20-4b73-47d7-a412-e0a13e865e4b	t	f	2026-11-07 06:57:55.867122+00	2026-10-31 06:57:55.814069+00	python-httpx/0.28.1	127.0.0.1
5076137d-f612-46be-8bd1-6377b359f43d	5040313c-9900-4630-93f9-1f0e119412dd	d89876a7b30f87ed0602f3848c4ddd55270887889a478f16c8e699aeae5bb08a	5f6ee138-6bf9-4904-a8d3-303e9244eb37	f	f	2026-11-07 06:57:58.990895+00	2026-10-31 06:57:58.940972+00	python-httpx/0.28.1	127.0.0.1
bd76d0ef-eb2f-4bf5-8c2c-59a26ef2890d	14717e01-a79b-4bdd-a7cf-6a79edbe15ca	9e7d71653701282ea9f6bed44bb0a0be7602a458fec9a974e842b2c0390111bd	e41a90cc-d158-42a9-aa55-47dddaf545fc	f	f	2026-11-07 06:57:59.146084+00	2026-10-31 06:57:59.093527+00	python-httpx/0.28.1	127.0.0.1
dc558698-7dd5-4860-93e6-dcefe575874c	94c223b6-7cf9-490c-b244-b8184c45c9d6	b0531c06ea3716199bac7027a7e2292daa5355647a0e7421a77829ccaf34f8e0	8411c325-c399-4e06-bbcc-cc4eb969787a	f	f	2026-11-07 06:57:59.361927+00	2026-10-31 06:57:59.309029+00	python-httpx/0.28.1	127.0.0.1
4a9636ff-c9cd-4f72-baea-b6fa07c372fc	dc41ff91-d203-479c-ab89-c1ca59c3f3f3	c7ca2dfd8a891187bc027be8a4d2a84c24e25ae1f77c2e1385a91a25c8e77589	e2034fa6-1f0e-43e7-86b1-c47058882f2f	t	f	2026-11-07 06:57:59.06444+00	2026-10-31 06:57:59.01048+00	python-httpx/0.28.1	127.0.0.1
e731c2b6-6f79-4b14-8d4b-e0884aa0c80f	7285aedf-bec0-472a-ac22-a2e63c91662c	0b9889ec27afd6f917ce60311d0bd673cb45f38011a358ff5949798d547adb0a	0a651dd8-3325-416a-9140-424d39d53775	f	f	2026-11-07 07:01:01.321282+00	2026-10-31 07:01:01.26288+00	python-httpx/0.28.1	127.0.0.1
4f1d9c69-9769-4a08-9fbe-6d4de225c5a7	bd79e4fc-af1a-494f-b781-9a704b44e479	fc2e528ea60a561c85e39eca2744bc3b5eddb8d0e9fa304681cb47c442d62957	29bb4489-4aa1-4938-a181-55253406ca35	f	f	2026-11-07 07:01:01.426604+00	2026-10-31 07:01:01.37425+00	python-httpx/0.28.1	127.0.0.1
748efaf1-970a-4177-bc9d-e33e3bca9e2c	052060c6-0beb-4e7d-8fd7-08856f7e1ec9	8366ce0b6f6c3d2915c9c96fb5702dd8448236234353c2499ec09e4f0f26a42f	2f6d8883-bcba-4546-879a-080f235e2fe3	f	f	2026-11-07 07:01:01.530111+00	2026-10-31 07:01:01.475425+00	python-httpx/0.28.1	127.0.0.1
cae804b5-9245-4bf4-a0de-700a5756a1be	052060c6-0beb-4e7d-8fd7-08856f7e1ec9	f1d0c5e124e64bfd946dd4bce1e5d5c83f293ec68107fed3bf406a3a669c7cec	c46e3025-12bb-4fe1-bc1f-3d28fa19b865	f	f	2026-11-07 07:01:01.671214+00	2026-10-31 07:01:01.623097+00	python-httpx/0.28.1	127.0.0.1
7513b855-149b-4b26-9c5e-48a53caa5ec6	732aab7b-d07d-42f4-8f2e-e4ebb31bab45	682a2988c46fb71df0131ba965c331fa791b28c4bf2f6101e8815e12bd8bfffb	7067392c-ba2b-412e-bd34-799d3c8b4015	f	f	2026-11-07 07:01:05.886922+00	2026-10-31 07:01:05.836726+00	python-httpx/0.28.1	127.0.0.1
99708784-ca57-4d9c-b193-1192d345bd8b	9997dea5-958b-4168-8e34-cbce8da19cba	a44da0f690881577aeea0e9f27b189f2a6c341629ba599e242669bd59174579e	32d6fe83-c95d-40f7-9d79-fcf6a2e305c8	t	t	2026-11-07 07:01:01.743696+00	2026-10-31 07:01:01.692273+00	python-httpx/0.28.1	127.0.0.1
2f93c9e6-8fb4-48c6-856b-60b8557be279	9997dea5-958b-4168-8e34-cbce8da19cba	3171206d65886c12d7e09ce7728fd2192007509186349a596e762f9e5d47d632	32d6fe83-c95d-40f7-9d79-fcf6a2e305c8	t	f	2026-11-07 07:01:01.773273+00	2026-10-31 07:01:01.770935+00	python-httpx/0.28.1	127.0.0.1
0d5cdc5e-8190-41f4-b7cc-f352abead56f	9454fb0f-4bec-4f35-8752-0ff0c45850ad	ebcd0cd163ad95c8d983b86476d4e71af079bdbe712830367511bd5a72cf76f6	fcac5ef6-c665-4537-acc0-71034f32da35	t	f	2026-11-07 07:01:01.88003+00	2026-10-31 07:01:01.830447+00	python-httpx/0.28.1	127.0.0.1
d51d709e-ff28-4783-afd4-e5b9264ca7b0	9454fb0f-4bec-4f35-8752-0ff0c45850ad	ad1f74025cd907c933436d6d8c7a43f7c6c8497bfefdbb25a4631fddaffb28b6	cb274a8d-f62a-47e7-999f-8f050b93d234	f	f	2026-11-07 07:01:02.141298+00	2026-10-31 07:01:02.093234+00	python-httpx/0.28.1	127.0.0.1
f2559a16-3334-4677-a3af-35b6dce9869d	ef162596-be5a-46c7-b5c9-96fffde7649e	f21c03e00f0a2ef1e91b68d61159b2d1e0f5e1324d2ce412111dcfce9e2fed77	fcd8b29d-4e92-4f3e-83aa-10b101e91a2f	f	f	2026-11-07 07:01:02.228492+00	2026-10-31 07:01:02.17639+00	python-httpx/0.28.1	127.0.0.1
9e48b18d-9219-4a4c-bc53-84d26d3e2dea	b1d34f68-343e-4b28-9091-6a9d6962b7ec	a54ab63c47ea73fc91e6c291629c55e985f263631c304527855204a0a3d8d24c	e3949227-1100-41ab-90ac-0edc924da6b8	t	f	2026-11-07 07:01:02.410909+00	2026-10-31 07:01:02.359036+00	python-httpx/0.28.1	127.0.0.1
5e19a3b5-5d4d-47a6-80be-bd2e54dd81ff	5040313c-9900-4630-93f9-1f0e119412dd	d35882eab518acc86d44c9d1be48f38a1dc61afa87ba74d2a31ffd3ddbbc58c6	5a6e585b-d46b-42fc-9a69-f1b34214670b	f	f	2026-11-07 07:01:05.737039+00	2026-10-31 07:01:05.687536+00	python-httpx/0.28.1	127.0.0.1
2e711c83-e9ee-41c2-8ac0-b5f179db800e	0fbbf616-93e4-4ce8-ae5a-80ee0780422e	45d04baa665fc6777d2aec6165c8161580d421652ef96041fd40f448e3297c99	4a6a8ed1-65a3-4ee6-9c02-9e20083d11a4	f	f	2026-11-07 07:01:06.104451+00	2026-10-31 07:01:06.050405+00	python-httpx/0.28.1	127.0.0.1
6a49ecff-6e39-4b21-b0cd-064106e9853f	4396aa50-9bab-4349-8eef-cbde4ec50b3d	5b54d6657d0e2a10b67c7cfc856d11b741b05067bd1589d92f158133c2b1f947	1a638078-43c1-45df-90f2-76f0c8304c61	t	f	2026-11-07 07:01:05.809314+00	2026-10-31 07:01:05.75911+00	python-httpx/0.28.1	127.0.0.1
a488865c-18c6-43fc-823d-bbf49d55c4f5	b1e6be92-ec85-4cca-a299-b325aa4567d4	bab12c43f8dacba9625afb0dbc1b3f96376dfdb327179d0abb1b00783a32a332	b6ea6f4c-5ed8-45a2-a0d9-360542a2e150	f	f	2026-11-07 07:01:36.955908+00	2026-10-31 07:01:36.90258+00	python-httpx/0.28.1	127.0.0.1
a2aacad2-058f-4f95-b4bb-9dda301257e2	10928483-3589-4bcc-ac16-474f6dde1852	b0b5006601bc97df27e4e411a772aabed576d461cb3e99dd9c352c252f817dd8	c33c1042-63ee-4546-af08-108fc5d49c35	f	f	2026-11-07 07:01:37.058544+00	2026-10-31 07:01:37.008228+00	python-httpx/0.28.1	127.0.0.1
45449e13-ae40-4899-b09f-18adae24a778	1943c312-634a-4ab3-b6fe-fa2081ec0dbd	ac2356d159d71925fd007ec97abfd6ece3a2a8d0bbdd6e23c2883c05ca2f743e	59c78311-9ead-41a8-b64e-21afaa070057	f	f	2026-11-07 07:01:37.160977+00	2026-10-31 07:01:37.106345+00	python-httpx/0.28.1	127.0.0.1
594cb008-f2b9-42e6-a3ef-b81b0b7f6265	1943c312-634a-4ab3-b6fe-fa2081ec0dbd	4d98c681e0197f62f345c37308cec6d858bbda7ebf133295fc60bf62de4fee30	94538520-cc70-49f4-ab35-811b37434aae	f	f	2026-11-07 07:01:37.303844+00	2026-10-31 07:01:37.256054+00	python-httpx/0.28.1	127.0.0.1
427a8726-346f-4a3d-b88c-dfdb0fb922f2	79afecfb-a64b-47a2-813c-72f6eec196c4	1dce43c47afadc9ae32b6b9f926ab6e30452d08e1bba53c07a1c6fd2e578c4c4	1c88ff7b-7c45-4ce2-a60a-da9ca37cb454	t	f	2026-11-07 07:01:37.527515+00	2026-10-31 07:01:37.477638+00	python-httpx/0.28.1	127.0.0.1
5281da18-56c1-45be-842c-14a17c1e9b3b	1811d575-46d3-4f84-8a1c-85d8e2504dac	a4c731178a446db1d7c2b355166fc2f323d1c30dcb496f254901ae9a4f62dd6f	cd47ef46-6360-4e4b-97be-bac4d22590c5	t	t	2026-11-07 07:01:37.380397+00	2026-10-31 07:01:37.330017+00	python-httpx/0.28.1	127.0.0.1
f6d7ab30-584e-48fd-9e10-b379ed269175	1811d575-46d3-4f84-8a1c-85d8e2504dac	b26f4db6c5a4bde2acd7e30420929cc07504811d68e9ae7398a4f1721991169a	cd47ef46-6360-4e4b-97be-bac4d22590c5	t	f	2026-11-07 07:01:37.410761+00	2026-10-31 07:01:37.407163+00	python-httpx/0.28.1	127.0.0.1
75fb6c9f-f282-49be-9897-5de6f59199c3	79afecfb-a64b-47a2-813c-72f6eec196c4	9f0dd4043065d077f64ad7b9341102103f1de9b0953b8a157680f02ae8e9b1f7	90dcbde8-c0cb-4e2a-a64d-1d137531b697	f	f	2026-11-07 07:01:37.803622+00	2026-10-31 07:01:37.756645+00	python-httpx/0.28.1	127.0.0.1
1ae2a63c-7982-4b20-b960-df5c7aa4adb4	07c13107-a120-4937-b7bb-b235ecc5b8c4	4fa0746ac5ae7d6aeb77fb038657b86af7e120dc7e7337d0a7da9dfbcc3fcadd	66ef9910-df5b-4ae2-8ede-f66b2acc3eb7	f	f	2026-11-07 07:01:37.893581+00	2026-10-31 07:01:37.843828+00	python-httpx/0.28.1	127.0.0.1
9692b9bd-99d6-41f6-97b0-8dd1b0be1323	9bd376ca-84e7-48cd-a91e-9002151bf344	dd2182cf9064b6df4b4aa887ce3f1fadb7cbc476c906e67e7e2e29f9bbfabc2e	d3f958ed-c4c3-496b-93a0-d66c7b4b3bca	t	f	2026-11-07 07:01:38.099907+00	2026-10-31 07:01:38.041031+00	python-httpx/0.28.1	127.0.0.1
eedf3ae3-7e24-49c1-9b4b-098604b7ea46	5040313c-9900-4630-93f9-1f0e119412dd	73f7f613e7c7dda1e64291d869cada389f136c3e7e8efe38453731ff292b7aba	683842eb-7f15-477f-912f-e9d6f9b28c38	f	f	2026-11-07 07:01:42.921122+00	2026-10-31 07:01:42.874452+00	python-httpx/0.28.1	127.0.0.1
6304cddc-dbf9-4f10-8fc3-31d6b2a9556c	9ea6e003-d6af-41ba-a523-1a52ae2fe703	62daf1b9fd9607ed3252abf7eb585b379f6ba134ea5f3fa5c41fe655383470f9	9e63c2bf-64b4-4972-a5da-9d5a3ac36ff0	f	f	2026-11-07 07:01:43.079166+00	2026-10-31 07:01:43.024392+00	python-httpx/0.28.1	127.0.0.1
da23efae-dd56-4bf0-b225-f0c3b4b6598e	b2a6f66d-fc41-4eb0-86e7-36e98e60b7fa	6d1b6e5d75555836bb734e568703139434da7035d50f9a9e04fec45a8e93a42a	a277ec9b-edca-41f5-b70c-7134b782afaa	f	f	2026-11-07 07:01:43.28135+00	2026-10-31 07:01:43.233556+00	python-httpx/0.28.1	127.0.0.1
dcb193f3-cb8e-4085-80d8-377a9c1ce0ec	a0978a5e-7bfc-4269-847a-0ddf8279f862	1c0f706368c40899ed3464d6f56b9deef4855aef9ca436c1daa66d8d1604d8fe	e155ea42-db82-40b2-aa1a-2a090b89b9a4	t	f	2026-11-07 07:01:42.994365+00	2026-10-31 07:01:42.940442+00	python-httpx/0.28.1	127.0.0.1
c64668d2-0f5e-42bb-bbd0-a4192a6a788d	5040313c-9900-4630-93f9-1f0e119412dd	a1693af1ba39fcc2ef0aa1f3b77fa9693c5dd670c144c02ba7361652d9bf3ff5	79f15237-160e-4b44-a4da-60f6a1ecdc01	f	f	2026-11-07 08:27:24.199291+00	2026-10-31 08:27:24.145164+00	python-httpx/0.28.1	127.0.0.1
07eda35f-221b-42f8-8047-923553f54660	5040313c-9900-4630-93f9-1f0e119412dd	24bbad8ae046c47f8af0f598811b352116660be78c785bbe62dab433aae6408a	26e962c3-4fd4-454a-80e8-9e786c52d2ff	t	f	2026-11-07 05:14:32.729285+00	2026-10-31 05:14:32.725912+00	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	127.0.0.1
7af3606a-65fa-4369-a17d-cfb97b8de303	5040313c-9900-4630-93f9-1f0e119412dd	9072230dc014126115ad939da1ad4ef7ae28ce99405627429566022a5d61b0a3	26e962c3-4fd4-454a-80e8-9e786c52d2ff	t	t	2026-11-07 04:58:24.08646+00	2026-10-31 04:58:24.022952+00	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	127.0.0.1
152477a2-0aab-481c-93b7-907f13156c59	5040313c-9900-4630-93f9-1f0e119412dd	3596e8a66204b9fa6866bafbd99f25a6b900582bddd030cb9d2f79f58b481103	26e962c3-4fd4-454a-80e8-9e786c52d2ff	t	t	2026-11-07 05:14:32.734998+00	2026-10-31 05:14:32.72899+00	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	127.0.0.1
a05fbe91-0358-4930-a062-a3d2f6118285	5040313c-9900-4630-93f9-1f0e119412dd	a7dd3e84c7870b34c839b3ab57dfcf1b2a3a9672286c5df01c3eb0929734bb7d	26e962c3-4fd4-454a-80e8-9e786c52d2ff	t	f	2026-11-07 07:16:00.542788+00	2026-10-31 07:16:00.53884+00	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	127.0.0.1
0aa2ade2-9d74-4cc7-8162-4c71884c0a04	843d4960-08ca-47f4-adcb-9867809d7989	b9a3248d2dd34688f54feab10ac896394b064fe629b1cc6c83df28fb9f33a9e2	f5a89efe-24ec-47ff-9758-3cfd4301da7d	f	f	2026-11-07 07:24:16.831647+00	2026-10-31 07:24:16.771431+00	python-httpx/0.28.1	127.0.0.1
c05ccda0-25ee-4493-be0d-72bfddd94da0	59227789-261d-4aab-b74d-03ffa1e2271a	4d7514e77242f4bcbc7f0dd74e6aadbf5e65f82d0cc27d62208fcd22f1c9a5b5	7f514134-ac73-4977-ab57-8e971f7cf2c2	f	f	2026-11-07 07:24:16.939017+00	2026-10-31 07:24:16.882566+00	python-httpx/0.28.1	127.0.0.1
fa47f9cf-0bf6-4f8e-8230-77b84fb3a998	1737e95e-822d-4c0f-ac0f-c702a5b2109f	3c413d643a19c581bf64eb32eab7e571ecc608ee84c86e830e41cce063a26e3c	bc410fcb-779f-4910-9193-1112377f2409	f	f	2026-11-07 07:24:17.042868+00	2026-10-31 07:24:16.989825+00	python-httpx/0.28.1	127.0.0.1
7870ebe4-56f9-4c84-be94-7e2dd49ffdd0	1737e95e-822d-4c0f-ac0f-c702a5b2109f	87e218bc3ac748683f0f7b0c5e9079ae34ee2df2fa919683abb6cb18a4facb9d	8c288d4b-bbfe-4b57-95ee-e4b8c9c90ab7	f	f	2026-11-07 07:24:17.182467+00	2026-10-31 07:24:17.135293+00	python-httpx/0.28.1	127.0.0.1
148007fe-7412-4bb6-87fc-8da347b324fb	ae4ffc0c-35ef-4e8e-9f0c-2e3b996c7115	d4c1a85d1b98b4d5e2fbcb776a5463186afbf8bf71ad5bf0fe1410c56eefd7a3	8a62ebd1-4bb0-48d0-9ffa-3437e8694563	f	f	2026-11-07 07:24:23.620149+00	2026-10-31 07:24:23.571842+00	python-httpx/0.28.1	127.0.0.1
bc0cecb4-c483-4fcd-888d-74518dd635e6	36726a35-4372-4be4-9321-48da65360248	2fecfca7575e07f2adb66c4571095fe383f7252d4b001fc57d6dee81ba25b89e	a9470d31-b14b-4d5f-bf7a-96d512cbc0c4	t	t	2026-11-07 07:24:17.268286+00	2026-10-31 07:24:17.207968+00	python-httpx/0.28.1	127.0.0.1
7bfcebdd-5dd1-42fc-af97-c57abfb66d5b	36726a35-4372-4be4-9321-48da65360248	fa23071a04fed70edece5a2aacfea7ebcf4bd0d2e254c80da6228356e5f514e1	a9470d31-b14b-4d5f-bf7a-96d512cbc0c4	t	f	2026-11-07 07:24:17.303553+00	2026-10-31 07:24:17.300726+00	python-httpx/0.28.1	127.0.0.1
ed9657a5-cbf3-4222-bc07-de8376031ea3	6190315d-16e2-42b7-8ebb-ae669aa4a9e9	236cda8629574ec00d0e6fa24f9c189f862de00ca55d8797d4ba967b32c78a8b	eb574a6d-10ca-486d-beb6-3248b65c64cd	t	f	2026-11-07 07:24:23.33241+00	2026-10-31 07:24:23.280124+00	python-httpx/0.28.1	127.0.0.1
2b66ceda-792d-4f29-a46d-eda26d7e8aff	5040313c-9900-4630-93f9-1f0e119412dd	1b7cce9f668063ebc42d4e7c0daefc62f2acfb1ce9f30b1127f978769c97ddd1	527ee5b7-aec9-4562-94e5-5b9782bcb440	f	f	2026-11-07 07:35:20.310651+00	2026-10-31 07:35:20.256881+00	python-httpx/0.28.1	127.0.0.1
8ba213fb-72e1-48f4-85a5-fca89c9d767a	5040313c-9900-4630-93f9-1f0e119412dd	12ac31d5bdda92f8977e292f930f1ea8d7a557a10792d71af464a43b751e4d66	3c5e5b44-3b94-48e4-b0e7-887ac0afc443	f	f	2026-11-07 07:37:29.066835+00	2026-10-31 07:37:29.016015+00	python-httpx/0.28.1	127.0.0.1
45ee81a1-1683-4586-bf1c-6e286e1e9385	5040313c-9900-4630-93f9-1f0e119412dd	948e9f39e47e5c69b9445ffc2afbf5f99c92f21f7c095dad6aceeda29b62616c	b54c3165-a464-4881-be70-a88f48c0d74d	f	f	2026-11-07 07:38:18.145804+00	2026-10-31 07:38:18.094798+00	python-httpx/0.28.1	127.0.0.1
6d8ad676-7d53-4e27-aeef-ad0eb6ce1d64	dd33a8aa-2d10-4ea2-91f8-045bc99db960	dd4c35052d83977b40b1f3d7fbc0c6f61dad6172808d07bc6d062cece2b57e0e	99d19cfb-a95c-41fc-85f1-8568ec589009	f	f	2026-11-07 07:38:30.233333+00	2026-10-31 07:38:30.179672+00	python-httpx/0.28.1	127.0.0.1
df4ca8dd-b574-4956-9188-3c0d165b647d	fc4eae69-efe6-4708-8c47-2aabba7084a6	63e6564b4ae50903dba677633d6198dfa672c43ed65812ea7564ae4b21065eec	b5a54810-d27c-46f2-b44b-451a868279ae	f	f	2026-11-07 07:38:30.336221+00	2026-10-31 07:38:30.283603+00	python-httpx/0.28.1	127.0.0.1
38c79a9d-04f8-480c-88fc-93702c0d1f44	1d904ead-64da-41dd-8f28-84d07d2d29fa	3aef17376177e13e4e16bea3e18a23c99afc29e1b4819116e21026a7ec482fff	b790a348-abf6-4ee0-8209-b40a00b4bd0b	f	f	2026-11-07 07:38:30.440042+00	2026-10-31 07:38:30.385422+00	python-httpx/0.28.1	127.0.0.1
853a69dd-1c40-4ad6-b746-2651c9663c54	1d904ead-64da-41dd-8f28-84d07d2d29fa	1eff7fdc14e7cf23364a1605b6deae1fe18cb09efef8de4e3cea8a6a67f68b4f	7b9e282a-eb9c-4cf4-a2fb-9488fe30d9bf	f	f	2026-11-07 07:38:30.585044+00	2026-10-31 07:38:30.535517+00	python-httpx/0.28.1	127.0.0.1
02dd482e-e9dc-4b23-9f77-23436f186a82	f2b5bafc-3d46-4968-bfae-1f837ee70ea7	2c18c3165c2a401f9bed879b64cbee9ba5b7c721e01e6f9944390d1cf8ddf0e4	fa24ebd1-351c-4262-bb2d-e9b1523b5628	t	f	2026-11-07 07:24:17.418277+00	2026-10-31 07:24:17.366165+00	python-httpx/0.28.1	127.0.0.1
8170ec09-b243-4ba1-a3f0-57a8506a93da	f2b5bafc-3d46-4968-bfae-1f837ee70ea7	c317f1e6c04721e44f0db6c9b6883bf1feec8cbc95ca582a7e80f98db42c7bd1	9afd0a2c-3bb9-4898-9f75-5cb9de273947	f	f	2026-11-07 07:24:17.691014+00	2026-10-31 07:24:17.641927+00	python-httpx/0.28.1	127.0.0.1
cbf8235a-001d-480d-bc32-f28a14b08fdf	d9d4a6b9-4e42-40a7-a637-1c3cd145c1e4	a8c26ad79c1fe8764dcabcbf65f2b310ac8314407c5f4144aa89de6e2de07eb0	72dd8eff-e57e-41ba-a5f7-9c2bebbefcf9	f	f	2026-11-07 07:24:17.783613+00	2026-10-31 07:24:17.727004+00	python-httpx/0.28.1	127.0.0.1
5e38f4f7-44ec-48a2-872f-e4866aa6a771	c14ed6f5-aeb4-4e9c-8944-4e898df4b9f4	3e854be5fd31052c597b2954b1fac6cbb8ee80289b6cb9a35be233ab12f9bc98	afbb815c-81fd-4105-97d4-e3fcfe083a50	t	f	2026-11-07 07:24:17.973199+00	2026-10-31 07:24:17.922061+00	python-httpx/0.28.1	127.0.0.1
be1be1e2-d90c-4ade-87ad-5bb3f8f332d5	5040313c-9900-4630-93f9-1f0e119412dd	10663b38055d279efec401cafd197225573409692020c58a8cb553fbf0f66606	7dce7e75-4b66-4c5d-8888-e4a266622258	f	f	2026-11-07 07:24:23.259637+00	2026-10-31 07:24:23.210262+00	python-httpx/0.28.1	127.0.0.1
c6c73930-c211-4100-b0c7-d4b5668e9182	5ace8bc1-63d8-411f-a11d-e6a1704ed15b	8df1fd6d81ccb81b7d3fef9d22292a74c11c9c296a7450b9eb226c1458601ac2	a858427f-a320-4515-8dff-a4f51d61d1a5	f	f	2026-11-07 07:24:23.418129+00	2026-10-31 07:24:23.362743+00	python-httpx/0.28.1	127.0.0.1
0b00078d-c066-40c8-a468-0c4f987c78ce	34f73287-5b8b-4edb-ab26-59b47bf6a813	1a775ef2abbe40d41051c3002921ad5454d2b62afaabd95c887e8d7127ca88fb	02684ae4-918c-4649-9660-75b58cf44ace	f	f	2026-11-07 07:38:31.156922+00	2026-10-31 07:38:31.106245+00	python-httpx/0.28.1	127.0.0.1
c755d880-28f2-4871-9cf4-f14ce1b2bc40	47723f47-a83b-49e9-9544-0636e3b2e6b6	f0ce3fe8e180fbf3249d79538f4b81eacb7e36eef1e7bbe0b7c9527ac4449680	04998bfc-7d7a-4ed6-8330-1bfbfd3c6df0	t	t	2026-11-07 07:38:30.662434+00	2026-10-31 07:38:30.610225+00	python-httpx/0.28.1	127.0.0.1
3a9481fc-a08f-45ac-98a5-23ee7c7cf9bb	47723f47-a83b-49e9-9544-0636e3b2e6b6	1213918f15be682aa86a532e94a330d0fff5f3f5dedc7853d933ff1d05b980c4	04998bfc-7d7a-4ed6-8330-1bfbfd3c6df0	t	f	2026-11-07 07:38:30.697251+00	2026-10-31 07:38:30.693499+00	python-httpx/0.28.1	127.0.0.1
baeb8a28-ffa7-4bdd-a1cf-ce66bf81fe40	b52074b1-7721-4486-aeb4-afada943f5cb	895d5146bde93242d030b947d8808232d942d5070f83edcfd0ea4c7e2fb64e6c	ff3c376c-9f7e-4f6a-8bb0-4019984e5279	t	f	2026-11-07 07:38:30.809967+00	2026-10-31 07:38:30.758689+00	python-httpx/0.28.1	127.0.0.1
8e33477a-3e26-42b1-842b-1a7e9d4e2ced	b52074b1-7721-4486-aeb4-afada943f5cb	2dd694330abb0b47fe1eb9a45fd9ff99a180534e5208bc4f17f88a44e88228b0	5c3b6ba8-2cc6-4ce7-969a-73c26f8bf1d8	f	f	2026-11-07 07:38:31.066734+00	2026-10-31 07:38:31.019684+00	python-httpx/0.28.1	127.0.0.1
021337e5-8995-4409-a417-a8ab91c87763	6e6cdc35-89ed-4d73-aebc-71bf44d5af09	4b46a6483ec80de63b99d9de97eb355773a9467c348d6957c2dfeec234689250	0f630c5f-bd50-49a8-b186-d549094d3284	t	f	2026-11-07 07:38:31.337554+00	2026-10-31 07:38:31.287301+00	python-httpx/0.28.1	127.0.0.1
bde669c3-13d7-40a0-b00d-ebeb18d77d4b	5040313c-9900-4630-93f9-1f0e119412dd	6358c11cd503fc3edf83f172bcf9865aa01fcef4c579dc92811461589e6a6354	c4a495ac-dd81-49b1-82ca-5286cc904ff8	f	f	2026-11-07 07:38:32.491668+00	2026-10-31 07:38:32.43992+00	python-httpx/0.28.1	127.0.0.1
dec7659c-3df4-413d-a343-174b1d925b88	5040313c-9900-4630-93f9-1f0e119412dd	c8c04844327fe17812a4c849c901042e9c005e875f584cd64d16ea2657ece988	e4f04a77-426c-4029-ab51-2d0b3feb8b25	f	f	2026-11-07 07:38:42.208093+00	2026-10-31 07:38:42.161193+00	python-httpx/0.28.1	127.0.0.1
92c1876a-6515-48fc-9da3-6cd915cfc144	13d35249-411e-449c-b092-9fd70812906d	b37d355b950bd482864f6efac265a5ccd0f97f574cac8a64d8dad8d14d0eb505	c2ed646f-9a0d-4327-a17c-26fc624ef079	f	f	2026-11-07 07:38:42.355067+00	2026-10-31 07:38:42.304818+00	python-httpx/0.28.1	127.0.0.1
992a06ec-63c1-4ee5-9629-1743534754cf	80dc8efc-2bf2-468d-84a3-7d3fde065492	a92eb2bd5062909316cd29b50cfdb07b726eadfef02acc3565a8e434bbcb726d	ebfd2f26-cb99-4f40-bd8d-b08ba4ab725c	f	f	2026-11-07 07:38:42.561097+00	2026-10-31 07:38:42.511442+00	python-httpx/0.28.1	127.0.0.1
834f9677-4ad6-4af4-b085-50f57a62645e	a7a24781-d0b5-4d15-bb0d-c952a1ccf9d9	eff0757ab8d206e6482e9ea111591e7008cab7b7821a7d54156f811c4f7d9448	5a65ae17-0484-4e70-8ff9-cca24933d85d	t	f	2026-11-07 07:38:42.278521+00	2026-10-31 07:38:42.227976+00	python-httpx/0.28.1	127.0.0.1
ad9beda5-1d4f-4ea4-881d-a5a950a34d2e	5040313c-9900-4630-93f9-1f0e119412dd	519de23e5074f641fb0a382ecd6eb6600c595a7a763ecf1dab8e5bc5932b470c	08687e48-630d-44f5-83d2-7bb2d5ff5780	f	f	2026-11-07 07:43:37.128878+00	2026-10-31 07:43:37.072307+00	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	127.0.0.1
49a02652-7a29-45ce-898c-0fda03b0fe74	50ec2373-3a67-4c8b-b33f-36a47643a3f2	46d0f52dd906d2f86e37d8c14e169c22cfe900f3ab41ec6070cc8fa10c8858d0	13d133dc-fcac-42f1-8b10-55d58a9e560d	f	f	2026-11-07 08:27:24.388704+00	2026-10-31 08:27:24.335031+00	python-httpx/0.28.1	127.0.0.1
075de9b1-6319-4c12-87d4-6ceab4000a25	5040313c-9900-4630-93f9-1f0e119412dd	29d3b864d11b25c1828d60146f59d1f4515006e0dc8cb420d84830e4e46103ae	b4d1f7e3-fe22-442d-b9ea-c5052b34fd72	t	t	2026-11-07 07:46:13.628864+00	2026-10-31 07:46:13.571377+00	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	127.0.0.1
32832953-8cd9-449f-9edc-f255b28b6a0f	5040313c-9900-4630-93f9-1f0e119412dd	378a9c23710ab0da7a7492b9b40e29e4b5644bfadb7ea01cc49e53d4104495b3	b4d1f7e3-fe22-442d-b9ea-c5052b34fd72	t	f	2026-11-07 07:46:15.966249+00	2026-10-31 07:46:15.964458+00	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	127.0.0.1
17ef1e77-6a57-45e3-9abe-414c0457c9f5	5040313c-9900-4630-93f9-1f0e119412dd	32a6dbc5dc89a01f865ac6450166afded6d45c9b9ae37946cc198023d05ce382	b0d21f27-3f13-4bf7-9b39-5850ee8bc91b	f	f	2026-11-07 07:47:24.632016+00	2026-10-31 07:47:24.572881+00	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	127.0.0.1
bc7f4249-c971-4014-90bb-a1b8cb619cee	5040313c-9900-4630-93f9-1f0e119412dd	8068a54f6b6c7a072deaa6dfde66187a148443b2c110dca29f721a766a101b01	eebd42d8-464e-4be4-8d57-8627118d63d3	f	f	2026-11-07 07:49:26.304168+00	2026-10-31 07:49:26.235694+00	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	127.0.0.1
340f2520-bb85-43ac-8b1e-408f48ef7b2d	5040313c-9900-4630-93f9-1f0e119412dd	9faa0607de733f3fc7a7fe6023555a0cf906e49030b4a3b3a5280d81c4c934ae	870d1c98-c6ce-4a06-89c9-821fafa64a03	f	f	2026-11-07 07:50:49.205862+00	2026-10-31 07:50:49.140909+00	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	127.0.0.1
f88f025b-3faa-4a23-9460-f3acc760e9a2	5040313c-9900-4630-93f9-1f0e119412dd	1fbf70eab7b417192832773bdabc88aa24bed688ce9fabcc0ff764356aa70ffe	b5f5c451-4199-4f84-9548-bff3821f7817	f	f	2026-11-07 07:52:25.89498+00	2026-10-31 07:52:25.838259+00	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	127.0.0.1
c48d7569-4981-424c-9edc-d59e61b3b298	5040313c-9900-4630-93f9-1f0e119412dd	4dcdb3120f2f5060cfe77f1aed2881bf1dfc4f4d7be1115f47f532ccc5b4e1ee	50e555c4-6592-4b66-b815-73286e2d77fb	f	f	2026-11-07 08:23:57.102085+00	2026-10-31 08:23:57.032754+00	python-httpx/0.28.1	127.0.0.1
ea619f38-b8ae-4ad8-bd75-2557f6aa03dc	b84bc79d-7fba-4cbc-b4df-2680463dc2f3	4602b29aa4132764f249d896af2b85b2444b3d4fced34222d5e7a1a86b4a7135	877ab8cf-31ce-4ec8-826e-038c7ef30a06	f	f	2026-11-07 08:23:57.312743+00	2026-10-31 08:23:57.24956+00	python-httpx/0.28.1	127.0.0.1
03e83790-a160-4ee6-b9d5-79fd43908203	5040313c-9900-4630-93f9-1f0e119412dd	b44ec3ebb9f9554f83d628a63972da1329d157011b87f9ccfe58b14af8b2f269	dc9976aa-8d36-4dc7-91be-2c1a711f09d1	f	f	2026-11-07 08:23:57.622454+00	2026-10-31 08:23:57.529824+00	python-httpx/0.28.1	127.0.0.1
60c4c158-60ff-43cb-a230-38616f567c8a	b52828e4-2c04-4936-bde5-6760082942f3	e192bfc480f4bf1209bcacf935ea921d20606f31d610fdaf53b90557e21af54b	571b3029-c290-4550-b21c-76fde44ece95	f	f	2026-11-07 08:24:06.75736+00	2026-10-31 08:24:06.700147+00	python-httpx/0.28.1	127.0.0.1
7d1cf531-2a5a-43e9-8cb0-b2824c868b09	451b08f3-8939-4a62-a424-5ee548a6a453	6f7591be0122c3b9ac6314b306a2dee15cf07bdbcde0d06b6e7e16944c48c2d5	db9f088e-6294-44e0-84b8-b511190f764e	f	f	2026-11-07 08:24:06.870951+00	2026-10-31 08:24:06.814165+00	python-httpx/0.28.1	127.0.0.1
78c40cf4-4f8b-42c1-b57c-d8ae95da41ac	1bf8ea9f-6b06-4da9-be91-3c8731819498	b2297af48def04f06632fb22e41e2dd2dca83c929c1fb3106c128f9e762f8f2e	a40a8a6f-1545-4d4e-ac7f-e0e2eb638b51	f	f	2026-11-07 08:24:06.985683+00	2026-10-31 08:24:06.92716+00	python-httpx/0.28.1	127.0.0.1
75e9acd3-204e-44f7-ab36-5207c0a5178d	1bf8ea9f-6b06-4da9-be91-3c8731819498	da27c939f223b597c4c08f4569ca03f9cc2a8219d9bb6518b8c5dbbde5511949	71811048-7b3c-418f-b619-2c1b08d5e286	f	f	2026-11-07 08:24:07.216212+00	2026-10-31 08:24:07.125393+00	python-httpx/0.28.1	127.0.0.1
a3cb8951-dcfd-4cc1-9834-4c491ba3a2fe	5040313c-9900-4630-93f9-1f0e119412dd	3b04e948a54232be436d9238b0b45fffc8bf1b83c42801066c71f3964034062f	85b2419a-f591-475f-9f62-8fd87523f555	f	f	2026-11-07 08:27:36.345044+00	2026-10-31 08:27:36.290401+00	python-httpx/0.28.1	127.0.0.1
87d736df-a0ae-4454-a763-79646498960a	373dbb4e-b9d7-4ad0-874c-20cf17ad92e5	dae36636f72cdd7526a5d5a1b8e670c20f1f2e65613909b7df8e59e36d393793	b6df9c13-608c-484e-9964-e66ee0da5fcf	t	t	2026-11-07 08:27:34.850314+00	2026-10-31 08:27:34.789575+00	python-httpx/0.28.1	127.0.0.1
1f6b1709-567a-48bc-9b25-cb847ff9e043	f8153125-3c20-42d4-ad8f-09c161b7bb5d	78cc7d88eae08e0b74c972e90a32051e0c0f2e6ebdf75cac6aa7d996ef7cd33b	c8310cba-720d-42be-96de-aab6b79ddf7b	t	t	2026-11-07 08:24:07.327069+00	2026-10-31 08:24:07.25796+00	python-httpx/0.28.1	127.0.0.1
8925a8d5-67a1-43fd-90e7-d7b4f170037a	f8153125-3c20-42d4-ad8f-09c161b7bb5d	45240b1933f2757bc79324d00e899c4e5b3fc57bddfda2de3a208b9a1b6132a0	c8310cba-720d-42be-96de-aab6b79ddf7b	t	f	2026-11-07 08:24:07.368135+00	2026-10-31 08:24:07.36568+00	python-httpx/0.28.1	127.0.0.1
f5daab03-0ef0-434e-8808-a2532e920099	ebae68dd-3887-4b84-9db4-99d2fbbdb3a2	a148bdf9bd05b620a6587be8f0246d232e784ac3e533d834d3447db0981580c5	100a6de5-d4c9-4b84-8556-442d3510d607	t	f	2026-11-07 08:24:07.494193+00	2026-10-31 08:24:07.436075+00	python-httpx/0.28.1	127.0.0.1
9b1ff565-c32e-4c17-8c11-eb91c3594092	ebae68dd-3887-4b84-9db4-99d2fbbdb3a2	4cf5ad39d2bd6d491ba208a0152946ace8a628bea38426dce3960872dc6326ba	b9119bb1-b403-4664-b669-64d4121daef4	f	f	2026-11-07 08:24:07.797993+00	2026-10-31 08:24:07.732672+00	python-httpx/0.28.1	127.0.0.1
f43390cf-39cb-4a01-ada3-a2ae6a0119d7	234f60f6-3d4d-4c10-80f6-ffe716741112	01abe2a4ab6a74218e69c86fe68ec51b1127d490548d2f51b8c07b1ab39b72cf	75e8603b-8d60-4485-93ac-8a1f0390f5fa	f	f	2026-11-07 08:24:07.902697+00	2026-10-31 08:24:07.845612+00	python-httpx/0.28.1	127.0.0.1
8ed6fdd3-6f48-437b-a180-9c28eedd7d5e	886216f8-3ff4-4384-aa44-ea5894745b0a	c736682d674d72d269dfe29d7002f8af58206a0a1d4dae131c2101825ff5463d	68042858-0b3d-4ba3-9faa-042544e02647	t	f	2026-11-07 08:27:34.997908+00	2026-10-31 08:27:34.943842+00	python-httpx/0.28.1	127.0.0.1
0f178aa8-8032-42c8-87c5-bdf6cee35309	9da9137d-e784-4775-b856-e577b39a1e06	0ad3ef516bd48ac2317e576413d8e730a662d634ed3a9df7ea8821cc5b5d87d0	82a5a71e-f00e-4391-a762-d339bf15402b	t	f	2026-11-07 08:24:08.12162+00	2026-10-31 08:24:08.061916+00	python-httpx/0.28.1	127.0.0.1
30b7128b-5539-4cb5-be6f-cd2166a55e15	5040313c-9900-4630-93f9-1f0e119412dd	343047a290b8de8be3601ce6a2ff254e7b1ce2eeafce8d28766c479d0a0aa7a7	2111dd99-a11b-48ca-9c65-3ce9f423e512	f	f	2026-11-07 08:24:08.665706+00	2026-10-31 08:24:08.564134+00	python-httpx/0.28.1	127.0.0.1
839a78dc-7c46-419a-be8d-cc21da1a7919	44bc6514-544b-4e38-963c-a0a30017da4c	f942982cb4b3a35bff162d61f4c2bb0f27c10a16c89cf3fff492b354acc72a29	35f7714e-2e68-438f-9d36-bfaa4d2b6d11	f	f	2026-11-07 08:24:08.866118+00	2026-10-31 08:24:08.81289+00	python-httpx/0.28.1	127.0.0.1
20bcdd96-8350-49c0-89e4-45f96ab2779f	5040313c-9900-4630-93f9-1f0e119412dd	621105d97e4ba9498141a0fb000112291386614f8afd6c70c677808ff0e1408c	42180d42-0094-42ce-ae19-e8097e021c52	f	f	2026-11-07 08:24:09.043355+00	2026-10-31 08:24:08.988829+00	python-httpx/0.28.1	127.0.0.1
f52067ed-d0ab-480f-8d18-2c915e74606f	886216f8-3ff4-4384-aa44-ea5894745b0a	b79f12d3f0e45fad335687274c931e51caa04b1298f52fcb6cd51b81613de1c6	4662af54-8dd1-46c2-9e0d-2dd58b1cfdb0	f	f	2026-11-07 08:27:35.268796+00	2026-10-31 08:27:35.216817+00	python-httpx/0.28.1	127.0.0.1
abee0d52-8a7d-4f76-9177-028177018219	fa542889-8820-45e9-b9f8-b63d3f0e47b2	093bfb9f07711f18d190c416af757b5c3220df026cf539521760739497b515eb	7dc53d55-253f-40c3-8d31-b1edc948a5b6	f	f	2026-11-07 08:27:35.366578+00	2026-10-31 08:27:35.308811+00	python-httpx/0.28.1	127.0.0.1
39545bfa-ff16-4caf-97f9-6120199b2aa6	4de1e8d0-84d1-4e9b-a25f-08b8351c57b7	4bb19490214340b1c0d0eb1773133edd6983481b13a2c3ad9d0f225da0210dce	63a7cde1-7e4c-4f7e-822e-ccf9d133ae29	t	f	2026-11-07 08:27:35.581073+00	2026-10-31 08:27:35.526273+00	python-httpx/0.28.1	127.0.0.1
b14a1313-d007-4cf2-a461-0a3db7428a0e	5040313c-9900-4630-93f9-1f0e119412dd	b45c229c39c9d9d55b407f71b3a114d96097d1085eb64c761ba9e5ecf402fb92	28b681d1-1364-4fd4-9433-68523753069d	f	f	2026-11-07 08:27:35.997678+00	2026-10-31 08:27:35.947805+00	python-httpx/0.28.1	127.0.0.1
b50cd429-79ac-4770-b4df-642c3a6635af	09b6e483-f874-4975-9136-3eff437aa445	0d03f51da67b49c7ba98905b701dc4249562c2b733b0f0411a756dadbbbd6d99	56646f57-6557-4915-95c8-f0a050bdaa42	f	f	2026-11-07 08:27:36.182149+00	2026-10-31 08:27:36.121895+00	python-httpx/0.28.1	127.0.0.1
01fb31d7-cbc7-4792-9603-450cffff14f5	5040313c-9900-4630-93f9-1f0e119412dd	6e2755a379581b87c3af847f192bf8796492a2a723599908c5492dfdda396ed3	2bb8e699-3f5d-479d-9f0b-2c24a7259840	f	f	2026-11-07 08:27:37.835823+00	2026-10-31 08:27:37.781143+00	python-httpx/0.28.1	127.0.0.1
eb1dec19-655f-4706-8245-a0ed8a3a4a14	5040313c-9900-4630-93f9-1f0e119412dd	464078fff2cf42f14d1d85f25e2b2f1cbaf1160082ac7301f37cc15ce467be82	870f9c7a-a991-425c-8b3e-754edcab7b8d	f	f	2026-11-07 08:27:47.829102+00	2026-10-31 08:27:47.772876+00	python-httpx/0.28.1	127.0.0.1
91e86fd5-65ca-41fb-87ed-6f2a58447863	bb2f3e5a-a4d7-4521-a39d-12a1ff065bff	452998ee2196fd663dde021c517782eed04a4cc0e378242dec4b378f2781f51d	79c20f87-aa30-48c1-b8dd-ec94e69a5bed	f	f	2026-11-07 08:27:47.987332+00	2026-10-31 08:27:47.929423+00	python-httpx/0.28.1	127.0.0.1
d30fc819-3e61-43d9-bdf2-879b2f682f76	84d45c7b-6d0a-455c-a618-9af4d5a317a9	1d6c6ce566f50c6946dbeb6640561a4932ddbe7d7e5a44a2c400c44332c6a36d	9b842870-2325-47ff-9e3e-23da1243913e	f	f	2026-11-07 08:27:48.209218+00	2026-10-31 08:27:48.15339+00	python-httpx/0.28.1	127.0.0.1
1a2b3140-ef60-4827-bfc5-59cfabcf0339	6c688382-392d-4b6b-8018-b43ca02eaa3a	e999f7c786d63dc802442eee3c87eb43db9d6356a03fbae8acfd036fe9ee9c23	e4ad6220-b219-4626-aa06-c942d8d6ecf5	t	f	2026-11-07 08:27:47.901326+00	2026-10-31 08:27:47.847161+00	python-httpx/0.28.1	127.0.0.1
b00c4fb3-8d68-4642-be76-659503de579a	5040313c-9900-4630-93f9-1f0e119412dd	191c08f140b57b9eb027c99845479b7f7446fa5bf6ca16398506de438d37d7e7	b47258d9-36da-48e5-a822-bf498ed16d82	f	f	2026-11-07 08:29:23.519234+00	2026-10-31 08:29:23.453559+00	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	127.0.0.1
af36b640-150c-4f7a-9853-111633917f48	f8a76800-1d18-4ecc-8527-7b4f59687fa3	0b7f69fa844c522beed4e32a000bb9af3dc639bf72631e94b025cfdb2778ae55	bc4726b8-0354-460a-b1b7-d669788436c9	t	t	2026-11-07 07:16:23.597487+00	2026-10-31 07:16:23.531936+00	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	127.0.0.1
643e42e5-d538-4d9b-90c0-aa0afac11c07	f8a76800-1d18-4ecc-8527-7b4f59687fa3	ac1f325ca7491d0c4b1e26556849f91fff807ba3860a8857e7417b262e1df273	bc4726b8-0354-460a-b1b7-d669788436c9	t	f	2026-11-07 08:34:33.805989+00	2026-10-31 08:34:33.802225+00	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	127.0.0.1
1eefbb9e-5903-4b19-986f-95ee947a0db5	5040313c-9900-4630-93f9-1f0e119412dd	9a35f5d2e0f5465e54d599717f4c6f9db6a791e0e7dd334588b57f28c5073910	81714391-8d20-4b6f-8dc6-82fc5969315f	t	f	2026-11-07 08:34:53.472902+00	2026-10-31 08:34:53.408692+00	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	127.0.0.1
d3ebe207-460e-4294-b38a-8624ad358d8b	f8a76800-1d18-4ecc-8527-7b4f59687fa3	1264c1c035cb15197ab509134615519e84722521c6dd41db1bd8a5eb0c602210	7461af4f-8f98-4901-86cc-c22288b46479	f	f	2026-11-07 08:37:28.130658+00	2026-10-31 08:37:28.073857+00	Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0	127.0.0.1
\.


--
-- Data for Name: subscription_items; Type: TABLE DATA; Schema: public; Owner: brightloop_user
--

COPY public.subscription_items (id, subscription_id, product_id, variant_id, quantity, unit_price, subtotal, notes, created_at, updated_at) FROM stdin;
b36eba36-3e79-44a4-b0a0-9d067f759b19	4d53671e-2944-412a-a719-7177196275b6	cd07bdd3-8925-4e1c-8754-a33b7b02246c	\N	1	2000.0000	2000.0000	\N	2026-10-31 07:01:39.102637+00	2026-10-31 07:01:39.102637+00
f928bfcb-bc4a-4344-853f-1efc5af299f0	db7dd7b6-1d74-4e90-930f-dcd1b1b9fb6e	c48f1d45-bed4-411a-a422-daed07f89681	\N	2	4500.0000	9000.0000	\N	2026-10-31 07:01:42.60332+00	2026-10-31 07:01:42.60332+00
6e5756b7-2995-492f-ad6f-ecaea57972e6	056e88ff-c823-4843-b98f-65f3b616c0b0	edbb467f-ee59-4f31-94aa-588b436d4eaa	\N	1	2000.0000	2000.0000	\N	2026-10-31 07:24:19.395714+00	2026-10-31 07:24:19.395714+00
9fd83cd7-d413-40da-b1c5-a10fe2baa5f0	ca6b4850-fa26-42ea-8602-c9b11b500ce3	37387601-cec8-4c66-b427-84f6104b528c	\N	2	4500.0000	9000.0000	\N	2026-10-31 07:24:22.847953+00	2026-10-31 07:24:22.847953+00
502056f3-2c4e-460f-ac46-15f0da86918a	72541aa9-36f8-4b9c-9626-b060cc5140d3	186b4bbe-6fca-4f10-8817-a4b71efd0762	\N	1	60000.0000	60000.0000	\N	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
89603b27-4e24-453e-95ba-48614ca81852	72541aa9-36f8-4b9c-9626-b060cc5140d3	48db2113-98c2-44bb-8fb5-491a6e75ddfd	\N	1	35000.0000	35000.0000	\N	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
97e61950-c533-48ef-b4af-5d3e642feea2	72541aa9-36f8-4b9c-9626-b060cc5140d3	ebc4abad-f5e7-4644-9567-8d7fdad06fd4	\N	1	25000.0000	25000.0000	\N	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
4725c73d-698e-4189-84ab-e701f41e5ef1	cecfc49e-26c5-4e3f-bac9-8f8458dc4598	186b4bbe-6fca-4f10-8817-a4b71efd0762	\N	1	15000.0000	15000.0000	\N	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
5606544f-aede-4260-ad6f-c1719a091417	84b00a2f-0122-4bc7-a407-040b02cb1133	186b4bbe-6fca-4f10-8817-a4b71efd0762	\N	1	60000.0000	60000.0000	\N	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
7860d6d7-cb5b-4ed5-a99d-323da4d6349d	84b00a2f-0122-4bc7-a407-040b02cb1133	48db2113-98c2-44bb-8fb5-491a6e75ddfd	\N	1	35000.0000	35000.0000	\N	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
b7bcac6c-0df9-4e42-8a60-55b3b8e94e1b	84b00a2f-0122-4bc7-a407-040b02cb1133	ebc4abad-f5e7-4644-9567-8d7fdad06fd4	\N	1	25000.0000	25000.0000	\N	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
80c217d6-3987-4aa6-8c8a-c3df5c2b51ea	810a53cb-11f3-4c83-8617-5835e2ab20b4	942c213b-7840-4549-aa89-94c83ee4842a	\N	1	50000.0000	50000.0000	\N	2026-10-31 07:35:20.737791+00	2026-10-31 07:35:20.737791+00
9015b14c-26eb-41b2-a780-5279fb389867	0f932e65-0914-408c-9d68-93cb5d16040e	77f7a1a1-923b-4307-b433-b3653d77faf2	\N	1	1000.0000	1000.0000	\N	2026-10-31 07:35:21.946376+00	2026-10-31 07:35:21.946376+00
dedb47fc-27b5-4199-a9c3-90a23fc245c3	a3627d27-1e03-4400-97eb-4116a9658759	ddac571a-50c8-46a7-aae6-c9699a912456	\N	1	1000.0000	1000.0000	\N	2026-10-31 07:35:22.464794+00	2026-10-31 07:35:22.464794+00
49d6628f-da8d-4bfe-b19e-168cf95ee685	102dc1b3-faff-452a-a726-68f4db877dc0	996e7e31-9bc8-4564-9457-8ca7927dfb84	\N	1	500.0000	500.0000	\N	2026-10-31 07:35:23.059597+00	2026-10-31 07:35:23.059597+00
8dbbf24c-bdc7-4f11-bdcf-098237127427	f1e7cc49-c8af-465e-9d83-d64f5101b2bb	39e2f841-cf98-4c62-809a-d941b1637c23	\N	1	50000.0000	50000.0000	\N	2026-10-31 07:37:29.488582+00	2026-10-31 07:37:29.488582+00
7d5714fe-e19e-4405-9582-880b283efa94	9ca3f8e0-9c33-428b-9ba7-8713614d9d5c	683a33cf-43e1-4b69-adc0-50512d118c91	\N	1	1000.0000	1000.0000	\N	2026-10-31 07:37:32.17377+00	2026-10-31 07:37:32.17377+00
345894d2-df44-4c58-9231-586d516a5f5f	b6ddf376-f7bf-46c9-9436-be398070771d	b37d638a-f942-49d6-8e03-68859649bc3a	\N	1	1000.0000	1000.0000	\N	2026-10-31 07:37:32.747767+00	2026-10-31 07:37:32.747767+00
2fff44ab-4d67-4ad8-8d06-fe6ee2dd17b5	765c3a10-ad74-4467-a542-1bc924e47c3a	a1eae06d-1777-4cb6-b063-6a2580b8a280	\N	1	500.0000	500.0000	\N	2026-10-31 07:37:33.637009+00	2026-10-31 07:37:33.637009+00
4e57991e-cbcd-43bd-9b4f-f62dbb3cda0e	94fc7b5b-d190-4f0d-a531-7d7a3ddd92cf	53b00a01-c903-4f64-9e72-5088c4c0e028	\N	1	50000.0000	50000.0000	\N	2026-10-31 07:38:18.551974+00	2026-10-31 07:38:18.551974+00
d1456f5b-9a57-47d3-b7af-336bcfb60481	d0c58c40-a1f6-4a94-bbfd-bef418d3fe4a	ed0db0d3-c8a8-4bc2-ac69-92b127dcbd38	\N	1	1000.0000	1000.0000	\N	2026-10-31 07:38:21.418813+00	2026-10-31 07:38:21.418813+00
17fb1428-9bef-4be5-bd40-a7fcef1a3c7f	56bce7e4-07dc-4507-bd3a-99fbbd8415fb	db17cf02-d6b1-4db4-a8e9-5bf25f5a34f1	\N	1	1000.0000	1000.0000	\N	2026-10-31 07:38:22.18957+00	2026-10-31 07:38:22.18957+00
5fcb99f8-cd9f-4a1b-9819-16d29140997f	f2b75ded-d929-4852-bceb-9abbaa11ef6c	650bdf95-c3b6-4a92-955b-9551fb73a316	\N	1	500.0000	500.0000	\N	2026-10-31 07:38:23.28779+00	2026-10-31 07:38:23.28779+00
89fffb0d-361f-475b-ac43-ad7d763d7acf	30ad68cd-90d1-4fc9-b2b5-ff49f20f8dfc	7fc3f342-51f1-4164-8bae-dfa344fbf476	\N	1	50000.0000	50000.0000	\N	2026-10-31 07:38:32.841738+00	2026-10-31 07:38:32.841738+00
3faf832f-3a08-4758-bb02-2fc1120e5072	2c293e93-3a1f-4630-8462-a57f05ea41c7	8e677bd2-2a28-432f-95eb-337f2b48f1e5	\N	1	1000.0000	1000.0000	\N	2026-10-31 07:38:35.407239+00	2026-10-31 07:38:35.407239+00
b08daa30-d5ee-44da-acdf-217f74b4a253	1d20677a-d222-4695-b150-72ad3587c5e6	c490928c-9a8c-4437-9601-1abebc4075b7	\N	1	1000.0000	1000.0000	\N	2026-10-31 07:38:36.198985+00	2026-10-31 07:38:36.198985+00
9d5d0fad-55c7-4d9f-9d4e-3eed2c436995	b009b479-8b6f-4eb5-967e-c069ce31b7ad	5bea6103-3d8f-49c0-b077-370f3e20b856	\N	1	500.0000	500.0000	\N	2026-10-31 07:38:37.338282+00	2026-10-31 07:38:37.338282+00
d30eeaef-d60a-46a1-b6f7-cd3ffdb41750	5ac937b7-c600-4f8e-9e05-4df0583deeb6	e7f7f3ac-3fa7-4818-b3da-4d643758ecfc	\N	1	2000.0000	2000.0000	\N	2026-10-31 07:38:38.395942+00	2026-10-31 07:38:38.395942+00
a125ad1c-22f8-4b26-bb35-f6f9b5e0bedc	92d73e49-4377-41ad-8f79-48c14bdee83a	2758ae3b-77c6-43a1-ae62-0cf0bb304cac	\N	2	4500.0000	9000.0000	\N	2026-10-31 07:38:41.888923+00	2026-10-31 07:38:41.888923+00
07531af8-93da-4555-a52e-55bab098be54	55ef6071-df63-4182-abe2-9cbf151bdad3	158c96d4-cbb8-49f2-a7d7-4e828fc64d3e	\N	1	999.0000	999.0000	\N	2026-10-31 08:23:57.805197+00	2026-10-31 08:23:57.805197+00
258c7f47-1738-4718-82e9-d6523e3d3085	875aa731-5cb8-4dda-8c8f-30e6c35a22f2	158c96d4-cbb8-49f2-a7d7-4e828fc64d3e	\N	1	999.0000	999.0000	\N	2026-10-31 08:24:09.278061+00	2026-10-31 08:24:09.278061+00
5ecb4344-432f-44ab-b058-60e9f90bd4b5	d3d2ff47-1496-45ee-bc84-ec7e81aced75	4bde00c2-5efd-4694-bcd0-41be8b23aedb	\N	1	50000.0000	50000.0000	\N	2026-10-31 08:24:11.358629+00	2026-10-31 08:24:11.358629+00
4f03cd75-540a-4115-ad22-5666e88985b1	f6261125-c013-4208-a694-f85ba034150b	f9b16ecd-e8bf-46ef-8482-2a84eb215fd2	\N	1	1000.0000	1000.0000	\N	2026-10-31 08:24:14.475416+00	2026-10-31 08:24:14.475416+00
f9d0e321-443a-4a5a-9a1e-97a1a65b4c40	96e254fe-161e-43c8-bd4e-374d2a6277a3	7f8d1ec4-f42c-48c7-928f-278cf9d23b34	\N	1	1000.0000	1000.0000	\N	2026-10-31 08:24:15.391893+00	2026-10-31 08:24:15.391893+00
f7484c28-6f9c-49e9-b012-976674ab33e6	6b0a8d72-7313-402a-9e66-e287cb1eef53	6d9f2b8f-4038-4bf7-baee-a0bbd91ba314	\N	1	500.0000	500.0000	\N	2026-10-31 08:24:16.859998+00	2026-10-31 08:24:16.859998+00
501569ea-e4db-4cfb-8bdc-663896e18cb0	1145b2e2-2ee9-4ecc-ac68-7e3e0e6c3a86	3e3ede4f-d267-4cff-8549-9755a16fc590	\N	1	2000.0000	2000.0000	\N	2026-10-31 08:24:17.973194+00	2026-10-31 08:24:17.973194+00
0d6fc3e0-9887-4670-baeb-f8eb9d112bfa	e5515f04-233b-497e-9d5c-ac98cbca4ba9	95724fee-0cd6-49aa-9308-0829fe8c0f13	\N	2	4500.0000	9000.0000	\N	2026-10-31 08:24:21.495802+00	2026-10-31 08:24:21.495802+00
45786d14-c05b-4a9f-9029-fc9c55a26bc3	c922adde-b083-4ccc-8cf1-fbc7fe27b2dc	158c96d4-cbb8-49f2-a7d7-4e828fc64d3e	\N	1	999.0000	999.0000	\N	2026-10-31 08:27:24.723866+00	2026-10-31 08:27:24.723866+00
efb022d9-0a47-4240-bb58-ad31fc15b4c4	f3e4a272-fb34-4599-8ee0-209476dc8f7c	158c96d4-cbb8-49f2-a7d7-4e828fc64d3e	\N	1	999.0000	999.0000	\N	2026-10-31 08:27:36.510292+00	2026-10-31 08:27:36.510292+00
1a74e3cd-cdc4-4714-ade9-55e3133b4129	a71d2d50-f658-4fd0-b097-6de1dc57d86f	3c81cd1f-5e81-45bc-9416-9e2095c3c324	\N	1	50000.0000	50000.0000	\N	2026-10-31 08:27:38.189701+00	2026-10-31 08:27:38.189701+00
bb60d2ee-902e-4afc-a98c-8fafaffd0496	73b766b0-35e5-4fc1-a7d8-d4d3fef4e1fd	48e0f739-0593-420f-a170-a77c35a41fae	\N	1	1000.0000	1000.0000	\N	2026-10-31 08:27:40.958558+00	2026-10-31 08:27:40.958558+00
722e4d62-aaab-4ac7-8aa0-63c5553d3a0c	8b58c724-98ce-465c-a73a-82d998e94cff	06a547de-b22a-49b3-9adc-fe3be1734f08	\N	1	1000.0000	1000.0000	\N	2026-10-31 08:27:41.719361+00	2026-10-31 08:27:41.719361+00
f70bea06-8bf9-4f4a-885b-afee0129f7be	2e63834d-8e53-411f-b939-f1d9e971f63e	ca41c692-d96d-44a2-b66c-65b15120e34b	\N	1	500.0000	500.0000	\N	2026-10-31 08:27:42.817167+00	2026-10-31 08:27:42.817167+00
303077ab-f2d9-4299-ae6a-7067a56dbfe6	504b31b6-e697-46b6-b0f4-7c48b4117fe0	c6410f1a-5961-42a0-b35f-800a55a315be	\N	1	2000.0000	2000.0000	\N	2026-10-31 08:27:43.983912+00	2026-10-31 08:27:43.983912+00
718ee965-1ca3-4320-aa84-761c6f6de88e	1659f7a4-97c9-4786-bba4-3bb3f7631f7f	6cb1fe89-fd75-47ca-9b74-b6e591db1a33	\N	2	4500.0000	9000.0000	\N	2026-10-31 08:27:47.504789+00	2026-10-31 08:27:47.504789+00
\.


--
-- Data for Name: subscription_plans; Type: TABLE DATA; Schema: public; Owner: brightloop_user
--

COPY public.subscription_plans (id, code, name, description, billing_interval, interval_count, trial_period_days, status, currency, min_quantity, max_quantity, is_auto_close, availability_start_date, availability_end_date, created_by_id, updated_by_id, created_at, updated_at) FROM stdin;
e305ebea-d9ab-41f3-8ef1-9223230f0c71	PLAN-INR-6BD23A	Enterprise INR Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:11:29.861466+00	2026-10-31 06:11:29.861466+00
82427998-6488-45c4-9bc0-6a9582a2a880	GUARD-13DAC7	Empty Draft Plan	\N	YEARLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:11:29.984149+00	2026-10-31 06:11:29.984149+00
306fc9ef-de46-4c3f-9bee-4ed48d306cca	AUTO-CA569B	Limited Time Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	t	\N	2026-10-31 04:11:30.40526+00	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:11:30.412308+00	2026-10-31 06:11:30.412308+00
2d3fc097-a040-4d26-ac79-060315cb6a0f	CRM-PLAN-63CBBB	CRM Standard Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:11:30.655069+00	2026-10-31 06:11:30.655069+00
3ff1e4cf-d506-4b90-a393-887d66a2a495	PLAN-INR-D9B3DB	Enterprise INR Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:12:59.70691+00	2026-10-31 06:12:59.70691+00
48c8dd02-1258-4513-b665-f8726f987084	GUARD-5D8655	Empty Draft Plan	\N	YEARLY	1	0	ARCHIVED	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:12:59.822235+00	2026-10-31 06:12:59.997508+00
7bdc7075-09f4-4d9b-8738-14587dae6430	AUTO-91F3B2	Limited Time Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	t	\N	2026-10-31 04:13:00.103792+00	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:00.110556+00	2026-10-31 06:13:00.110556+00
804ac948-ab8b-42e6-acfc-c94449522292	CRM-PLAN-3A042A	CRM Standard Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:00.349621+00	2026-10-31 06:13:00.349621+00
52c160f2-a7b8-4c40-b4c3-ff13e513fd07	PLAN-INR-676999	Enterprise INR Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:20.974544+00	2026-10-31 06:13:20.974544+00
6e16e0be-7a50-4e8e-9ac6-f1675ac37aa2	GUARD-F4E077	Empty Draft Plan	\N	YEARLY	1	0	ARCHIVED	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:21.094239+00	2026-10-31 06:13:21.268991+00
17cdbc0c-02c6-4db1-979a-761060e6fbf4	AUTO-DC87C0	Limited Time Plan	\N	MONTHLY	1	0	ARCHIVED	INR	1	\N	t	\N	2026-10-31 04:13:21.373372+00	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:21.380174+00	2026-10-31 06:13:21.417299+00
ef7eb394-aecd-46b6-bc2b-71e35d273b06	CRM-PLAN-F69AC5	CRM Standard Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:21.539432+00	2026-10-31 06:13:21.539432+00
58e5db85-a522-4c2e-ae0e-7c59bb12a005	PLAN-INR-F67B9F	Enterprise INR Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:50.928359+00	2026-10-31 06:13:50.928359+00
0dc7b634-cf11-4b86-8fe2-865f1569dcfc	GUARD-909BE1	Empty Draft Plan	\N	YEARLY	1	0	ARCHIVED	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:51.031779+00	2026-10-31 06:13:51.212704+00
5e11e3c1-5e4b-4960-a35a-34e971d57feb	AUTO-4EB311	Limited Time Plan	\N	MONTHLY	1	0	ARCHIVED	INR	1	\N	t	\N	2026-10-31 04:13:51.32404+00	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:51.330111+00	2026-10-31 06:13:51.369076+00
62ebe75d-fc33-4d89-bf7d-3cd2bd7bbaeb	CRM-PLAN-7156B5	CRM Standard Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:13:51.492502+00	2026-10-31 06:13:51.492502+00
4924ebc4-0f98-4df0-9e71-1b0144dc2977	PLAN-INR-6A2113	Enterprise INR Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:26:02.486816+00	2026-10-31 06:26:02.486816+00
d02c1550-ee4a-4624-b566-2bc4a408805f	GUARD-3B059D	Empty Draft Plan	\N	YEARLY	1	0	ARCHIVED	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:26:02.587342+00	2026-10-31 06:26:02.762174+00
d9308bf5-9a8f-4597-9075-f8888ea04a22	AUTO-777204	Limited Time Plan	\N	MONTHLY	1	0	ARCHIVED	INR	1	\N	t	\N	2026-10-31 04:26:02.855062+00	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:26:02.86143+00	2026-10-31 06:26:02.898391+00
6f0692b1-674a-4801-b15f-644ae613c6ba	CRM-PLAN-6813A9	CRM Standard Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:26:03.006386+00	2026-10-31 06:26:03.006386+00
43272446-ad12-47cd-aa6a-fde3a345a0f5	PLAN-INR-EEDCD3	Enterprise INR Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:56:46.350414+00	2026-10-31 06:56:46.350414+00
b449504e-ff50-451d-9d99-f4409ca41c79	GUARD-0D3421	Empty Draft Plan	\N	YEARLY	1	0	ARCHIVED	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:56:46.463042+00	2026-10-31 06:56:46.656124+00
5350071d-5afd-48a9-aa83-2d2935ab73f9	AUTO-36D461	Limited Time Plan	\N	MONTHLY	1	0	ARCHIVED	INR	1	\N	t	\N	2026-10-31 04:56:46.760531+00	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:56:46.767305+00	2026-10-31 06:56:46.808983+00
9b66bfd1-a67a-4c8f-9faf-9c4d43296459	CRM-PLAN-3C9AB2	CRM Standard Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:56:46.925968+00	2026-10-31 06:56:46.925968+00
2ca2f32b-f68e-48e7-9c09-4baf61d9398f	PLAN-SEC-D2571	Security Pro Monthly	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:57:56.717156+00	2026-10-31 06:57:56.717156+00
9b79b0a2-506a-4c3b-b87b-119f948e2ac8	PLAN-INR-22102B	Enterprise INR Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:57:57.02943+00	2026-10-31 06:57:57.02943+00
42f65e61-0335-4f69-8bf9-ed8ef63465e5	GUARD-9AB7A2	Empty Draft Plan	\N	YEARLY	1	0	ARCHIVED	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:57:57.147977+00	2026-10-31 06:57:57.335841+00
777c8b66-be1d-4560-87e3-289d56a3fece	AUTO-A943BB	Limited Time Plan	\N	MONTHLY	1	0	ARCHIVED	INR	1	\N	t	\N	2026-10-31 04:57:57.4412+00	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:57:57.447869+00	2026-10-31 06:57:57.491187+00
383d0b44-7758-49ef-a7d4-cdd7b41a552e	CRM-PLAN-E2EEE5	CRM Standard Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:57:57.622497+00	2026-10-31 06:57:57.622497+00
c6186b0e-5ace-4203-a620-1231bb6a822c	PLAN-CRM-855BF	Enterprise CRM Annual	\N	YEARLY	1	0	DRAFT	INR	1	10	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 06:57:58.879874+00	2026-10-31 06:57:58.879874+00
de9962cf-ac9f-4f88-80c8-1cdac851d647	PLAN-SEC-DEC0E	Security Pro Monthly	\N	MONTHLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:03.259946+00	2026-10-31 07:01:03.330547+00
117a6864-250c-43d3-be06-27ba2f039e5c	PLAN-INR-C9C768	Enterprise INR Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:03.641749+00	2026-10-31 07:01:03.641749+00
41ef282a-db52-430a-b1e6-edf0491923c6	GUARD-F554CC	Empty Draft Plan	\N	YEARLY	1	0	ARCHIVED	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:03.74147+00	2026-10-31 07:01:03.934695+00
611849fd-1a00-42b7-b8dd-1c5a045efb2d	AUTO-00C0AE	Limited Time Plan	\N	MONTHLY	1	0	ARCHIVED	INR	1	\N	t	\N	2026-10-31 05:01:04.034958+00	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:04.041625+00	2026-10-31 07:01:04.082866+00
8ac21648-3cc0-4863-88ac-b14df0fa1a95	CRM-PLAN-4433B0	CRM Standard Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:04.214058+00	2026-10-31 07:01:04.214058+00
de14b5ef-30b4-4c34-9855-9f041f222fcb	PLAN-CRM-95731	Enterprise CRM Annual	\N	YEARLY	1	0	ACTIVE	INR	1	10	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:05.429467+00	2026-10-31 07:01:05.480124+00
55293743-248d-46b3-88bf-847e5bf20636	PLAN-SEC-F1D49	Security Pro Monthly	\N	MONTHLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:38.905103+00	2026-10-31 07:01:38.974299+00
606b3af1-65ff-488b-b8f8-e4bc196f57c5	PLAN-INR-75BD24	Enterprise INR Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:40.60226+00	2026-10-31 07:01:40.60226+00
e4dc4e54-8377-4cb3-b7de-aa68603f1056	GUARD-8C1478	Empty Draft Plan	\N	YEARLY	1	0	ARCHIVED	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:40.700281+00	2026-10-31 07:01:40.925209+00
3a2519e1-04b4-44b0-acd4-0d6e123c3b30	AUTO-0C5A5A	Limited Time Plan	\N	MONTHLY	1	0	ARCHIVED	INR	1	\N	t	\N	2026-10-31 05:01:41.033259+00	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:41.040091+00	2026-10-31 07:01:41.078626+00
3f42283e-473e-43c9-856a-c65f061a9c2f	CRM-PLAN-4E07A5	CRM Standard Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:41.196078+00	2026-10-31 07:01:41.196078+00
2cf2f096-5052-4398-9a1f-f75a93f0df4b	PLAN-CRM-59150	Enterprise CRM Annual	\N	YEARLY	1	0	ACTIVE	INR	1	10	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:01:42.411164+00	2026-10-31 07:01:42.468856+00
4681a3b4-7b93-4d9a-849e-224f0b310797	PLAN-SEC-B2DB7	Security Pro Monthly	\N	MONTHLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:24:19.153356+00	2026-10-31 07:24:19.24644+00
1baded46-0fe4-44d5-a732-857b80b1d55d	PLAN-INR-151FD6	Enterprise INR Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:24:20.878841+00	2026-10-31 07:24:20.878841+00
6c7f0f09-2321-4b2b-b692-7e79692d4079	GUARD-847124	Empty Draft Plan	\N	YEARLY	1	0	ARCHIVED	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:24:20.987104+00	2026-10-31 07:24:21.169816+00
72870f5f-71f6-4347-a85c-b49987b29213	AUTO-7CEE22	Limited Time Plan	\N	MONTHLY	1	0	ARCHIVED	INR	1	\N	t	\N	2026-10-31 05:24:21.275471+00	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:24:21.283174+00	2026-10-31 07:24:21.324648+00
bc16a23d-c598-491c-aeef-09fb888fdcd2	CRM-PLAN-5E9ABC	CRM Standard Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:24:21.450872+00	2026-10-31 07:24:21.450872+00
c6243761-457c-4c31-bace-512802fd0015	PLAN-CRM-88229	Enterprise CRM Annual	\N	YEARLY	1	0	ACTIVE	INR	1	10	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:24:22.660875+00	2026-10-31 07:24:22.721321+00
d384f73d-e895-4459-ab35-677aa5b24362	BL-PLAN-ENT-Y	Brightloop Enterprise ERP Suite (Annual)	Comprehensive annual enterprise subscription bundling Core, AI Billing, and 24/7 Support.	YEARLY	1	0	ACTIVE	INR	1	50	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
c74c2965-322c-4f1c-b764-71a5d895d2d8	BL-PLAN-GROWTH-M	Brightloop Growth Operations (Monthly)	Monthly subscription for scaling technology startups.	MONTHLY	1	0	ACTIVE	INR	1	10	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
6900679d-5caa-4a5f-a0fa-4e68c86687a6	PLAN-AUD-DBBE98	Audit Pro Plan dbbe98	\N	MONTHLY	1	0	ACTIVE	INR	1	10	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:35:20.620298+00	2026-10-31 07:35:20.690139+00
242a449a-f506-45e7-a7d6-1c8d482c3eca	PLAN-QTY-FEA26E	Limited Quantity Plan fea26e	\N	MONTHLY	1	0	ACTIVE	INR	2	5	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:35:21.138167+00	2026-10-31 07:35:21.198934+00
f6ed1002-f02c-40b5-a8de-3427ffcfdcc8	DRAFT-5E366F	Draft Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:35:21.484861+00	2026-10-31 07:35:21.484861+00
5a6f8220-4f8c-4192-a679-dae3a6888a01	OVL-PLAN-20B80A	Overlap Plan	\N	MONTHLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:35:21.749633+00	2026-10-31 07:35:21.810272+00
85463b60-e094-4575-9c20-02f2bd715080	OP-PLAN-B78A98	Overpay Plan	\N	MONTHLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:35:22.267429+00	2026-10-31 07:35:22.330417+00
092e3a0c-9bd7-4bf4-98cd-c6bd89bf06c6	PLAN-NEG9-2A13BB	Neg9 Plan	\N	MONTHLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:35:22.883144+00	2026-10-31 07:35:22.935533+00
fa4315a7-89d6-4aec-906e-eaceb128d2ab	PLAN-AUD-3A32A8	Audit Pro Plan 3a32a8	\N	MONTHLY	1	0	ACTIVE	INR	1	10	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:29.372724+00	2026-10-31 07:37:29.441334+00
5d83f931-1a37-489f-88f1-b646f5e30693	PLAN-QTY-EF54CA	Limited Quantity Plan ef54ca	\N	MONTHLY	1	0	ACTIVE	INR	2	5	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:31.398528+00	2026-10-31 07:37:31.460662+00
f734effe-4020-4023-9e75-ea23508dfd18	DRAFT-DE3B95	Draft Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:31.751155+00	2026-10-31 07:37:31.751155+00
0a961d0a-af94-4712-9de1-331c2f043343	OVL-PLAN-0531CA	Overlap Plan	\N	MONTHLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:31.992404+00	2026-10-31 07:37:32.049712+00
497e8a79-6474-4c05-ae8f-c3504448bcc6	OP-PLAN-FFEE42	Overpay Plan	\N	MONTHLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:32.555633+00	2026-10-31 07:37:32.615317+00
7d53651d-4f7a-4d08-ae20-255e14608dac	PLAN-NEG9-18B7B5	Neg9 Plan	\N	MONTHLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:33.445078+00	2026-10-31 07:37:33.503019+00
e84fb213-7803-4a33-90c7-62ac22c16ae7	PLAN-AUD-2C1132	Audit Pro Plan 2c1132	\N	MONTHLY	1	0	ACTIVE	INR	1	10	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:18.438142+00	2026-10-31 07:38:18.506789+00
dbac552f-2c45-4830-ba3e-84d75d087d53	PLAN-QTY-2446FD	Limited Quantity Plan 2446fd	\N	MONTHLY	1	0	ACTIVE	INR	2	5	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:20.563475+00	2026-10-31 07:38:20.630969+00
fc81659d-6231-4468-a404-31cf05aa73ab	DRAFT-5E80AC	Draft Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:20.919362+00	2026-10-31 07:38:20.919362+00
364ce5b7-24c4-4e38-8370-245fb703bc22	OVL-PLAN-FB54D3	Overlap Plan	\N	MONTHLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:21.184812+00	2026-10-31 07:38:21.246083+00
7fdf215f-b7a1-4f77-8a65-3894140e0123	OP-PLAN-DE242A	Overpay Plan	\N	MONTHLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:21.994133+00	2026-10-31 07:38:22.054715+00
8aba86b1-d16b-4d9d-bb5f-3aa6e899dfef	PLAN-NEG9-BA08BE	Neg9 Plan	\N	MONTHLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:23.098977+00	2026-10-31 07:38:23.157898+00
80d48bf7-069c-4120-b281-056deee297dd	PLAN-AUD-4492CE	Audit Pro Plan 4492ce	\N	MONTHLY	1	0	ACTIVE	INR	1	10	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:32.735377+00	2026-10-31 07:38:32.799907+00
71fc50de-6cd7-44d2-81c6-5e749dee85f0	PLAN-QTY-62AA14	Limited Quantity Plan 62aa14	\N	MONTHLY	1	0	ACTIVE	INR	2	5	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:34.623282+00	2026-10-31 07:38:34.682266+00
31f17fbe-0754-4a16-8d91-827771aa6807	DRAFT-185244	Draft Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:34.960286+00	2026-10-31 07:38:34.960286+00
71bc4fdd-3710-4983-b791-4d51f05fc06f	OVL-PLAN-A17EC1	Overlap Plan	\N	MONTHLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:35.21748+00	2026-10-31 07:38:35.27682+00
09cd09d4-49bb-445a-a354-dbadde65da9b	OP-PLAN-625C40	Overpay Plan	\N	MONTHLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:36.006507+00	2026-10-31 07:38:36.069601+00
c1898049-e5c0-4876-895c-652b068ef387	PLAN-NEG9-2BACB8	Neg9 Plan	\N	MONTHLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:37.136183+00	2026-10-31 07:38:37.199994+00
607f6d79-67ea-4b2a-8264-eae014a615e5	PLAN-SEC-85D02	Security Pro Monthly	\N	MONTHLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:38.200451+00	2026-10-31 07:38:38.262217+00
57fffd3e-9dc2-4994-9203-4f9ede28bca2	PLAN-INR-715B11	Enterprise INR Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:39.883045+00	2026-10-31 07:38:39.883045+00
87df6dd3-3156-40d5-a694-5e034f2b21e6	GUARD-9584C7	Empty Draft Plan	\N	YEARLY	1	0	ARCHIVED	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:39.984963+00	2026-10-31 07:38:40.170807+00
e2e7cde0-2a3a-4e25-ab6a-d281354dbf19	AUTO-A43486	Limited Time Plan	\N	MONTHLY	1	0	ARCHIVED	INR	1	\N	t	\N	2026-10-31 05:38:40.276461+00	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:40.282797+00	2026-10-31 07:38:40.319869+00
74e894ce-1042-41dc-8a01-f6cabb1babbe	CRM-PLAN-0878D7	CRM Standard Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:40.448772+00	2026-10-31 07:38:40.448772+00
147b0b93-5602-4647-b291-00677cb15235	PLAN-CRM-78888	Enterprise CRM Annual	\N	YEARLY	1	0	ACTIVE	INR	1	10	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:41.70183+00	2026-10-31 07:38:41.759428+00
0086d29b-ddd9-4dc5-9ac0-3d74ea38cba4	BL-CAT-STARTER-M	Starter Monthly	Starter subscription plan with monthly billing cadence (₹999/month).	MONTHLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:17:09.727071+00	2026-10-31 08:17:09.727071+00
d5281260-fa65-4500-aa04-21fb2bfdd3cc	BL-CAT-STARTER-Y	Starter Annual	Starter subscription plan with annual billing cadence (₹9,990/year, save ~17%).	YEARLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:17:09.727071+00	2026-10-31 08:17:09.727071+00
ceaa5e9c-c99e-4a47-acd6-f7c9a6583c51	BL-CAT-GROWTH-M	Growth Monthly	Growth subscription plan with monthly billing cadence (₹2,499/month).	MONTHLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:17:09.727071+00	2026-10-31 08:17:09.727071+00
859f0f9d-a947-453c-83cc-3df6adea52dc	BL-CAT-GROWTH-Y	Growth Annual	Growth subscription plan with annual billing cadence (₹24,990/year, save ~17%).	YEARLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:17:09.727071+00	2026-10-31 08:17:09.727071+00
48036860-006a-41f3-901a-61f5704256f5	BL-CAT-BIZ-M	Business Monthly	Business subscription plan with monthly billing cadence (₹5,999/month).	MONTHLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:17:09.727071+00	2026-10-31 08:17:09.727071+00
c5ee0288-e16e-4654-8c0d-fac0b0b6fd20	BL-CAT-BIZ-Y	Business Annual	Business subscription plan with annual billing cadence (₹59,990/year, save ~17%).	YEARLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:17:09.727071+00	2026-10-31 08:17:09.727071+00
3737c0df-0bb6-4dee-a209-5b1b1c4d31b9	PLAN-AUD-8EBD0B	Audit Pro Plan 8ebd0b	\N	MONTHLY	1	0	ACTIVE	INR	1	10	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:11.233467+00	2026-10-31 08:24:11.301511+00
19f0e22f-9e12-42eb-800e-bb733dc5e7a9	PLAN-QTY-16E322	Limited Quantity Plan 16e322	\N	MONTHLY	1	0	ACTIVE	INR	2	5	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:13.575288+00	2026-10-31 08:24:13.636972+00
8fd4b604-eb35-45c7-bdd2-1ab8102d63f5	DRAFT-4E9051	Draft Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:13.956089+00	2026-10-31 08:24:13.956089+00
63848a77-2df4-4368-8796-c09dac27b6f4	OVL-PLAN-B22D76	Overlap Plan	\N	MONTHLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:14.264524+00	2026-10-31 08:24:14.342183+00
bf0fe4c3-380f-497b-8893-9827fde63b12	OP-PLAN-DBFA6B	Overpay Plan	\N	MONTHLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:15.156127+00	2026-10-31 08:24:15.23167+00
2174e10f-65e8-4882-b370-2dfd10171b07	PLAN-NEG9-7559A3	Neg9 Plan	\N	MONTHLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:16.647592+00	2026-10-31 08:24:16.711841+00
02bd8e1a-1f5f-4e5d-8c1e-1d909a546854	PLAN-SEC-8F01D	Security Pro Monthly	\N	MONTHLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:17.774856+00	2026-10-31 08:24:17.839456+00
9b7d0387-53f9-4167-97b1-f2ec87c80dca	GUARD-B3A8CA	Empty Draft Plan	\N	YEARLY	1	0	ARCHIVED	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:19.61097+00	2026-10-31 08:24:19.813512+00
bec2abb3-07f2-4cc0-9dde-297e1e6ac75a	AUTO-873AA0	Limited Time Plan	\N	MONTHLY	1	0	ARCHIVED	INR	1	\N	t	\N	2026-10-31 06:24:19.930793+00	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:19.937304+00	2026-10-31 08:24:19.980873+00
945c525c-7140-4809-9579-fa77f6408378	CRM-PLAN-F3D889	CRM Standard Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:20.102065+00	2026-10-31 08:24:20.102065+00
3ebd52a8-4f5e-4ffc-8137-ed0b98bf0ac6	PLAN-CRM-1E964	Enterprise CRM Annual	\N	YEARLY	1	0	ACTIVE	INR	1	10	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:21.292669+00	2026-10-31 08:24:21.355648+00
d2654e09-aeee-46a4-94b4-84e10c0b7863	PLAN-AUD-7B522B	Audit Pro Plan 7b522b	\N	MONTHLY	1	0	ACTIVE	INR	1	10	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:38.083008+00	2026-10-31 08:27:38.148933+00
478b9715-990a-49e0-b86c-363a1cd767be	PLAN-QTY-F88C42	Limited Quantity Plan f88c42	\N	MONTHLY	1	0	ACTIVE	INR	2	5	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:39.987262+00	2026-10-31 08:27:40.041932+00
102d2521-6977-4af9-83f3-a4be3470da39	DRAFT-5ECABE	Draft Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:40.433176+00	2026-10-31 08:27:40.433176+00
7197035c-ac98-4c4f-82fc-cef10aa9083c	OVL-PLAN-425051	Overlap Plan	\N	MONTHLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:40.739955+00	2026-10-31 08:27:40.809933+00
ec1f61ea-d591-435c-aff8-a2111e610265	OP-PLAN-934BD2	Overpay Plan	\N	MONTHLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:41.530324+00	2026-10-31 08:27:41.585899+00
6e0b404e-10dc-405d-9b5e-22f30b03af37	PLAN-NEG9-B487F3	Neg9 Plan	\N	MONTHLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:42.603105+00	2026-10-31 08:27:42.664176+00
c0440129-1c09-4070-a713-c056c1eac0c1	PLAN-SEC-1C087	Security Pro Monthly	\N	MONTHLY	1	0	ACTIVE	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:43.762354+00	2026-10-31 08:27:43.835973+00
d711461d-c647-4d49-a001-68817661c036	PLAN-INR-E42D99	Enterprise INR Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:45.404521+00	2026-10-31 08:27:45.404521+00
6d698fc6-103c-4088-8a1d-abd2383a2333	GUARD-A76D66	Empty Draft Plan	\N	YEARLY	1	0	ARCHIVED	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:45.507457+00	2026-10-31 08:27:45.69582+00
9fc57589-f51a-44c9-9695-dd62361a2078	AUTO-E01B82	Limited Time Plan	\N	MONTHLY	1	0	ARCHIVED	INR	1	\N	t	\N	2026-10-31 06:27:45.802134+00	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:45.808632+00	2026-10-31 08:27:45.84787+00
7d563e91-2eda-4022-8903-ef6644649b1b	CRM-PLAN-DDC9B6	CRM Standard Plan	\N	MONTHLY	1	0	DRAFT	INR	1	\N	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:45.982637+00	2026-10-31 08:27:45.982637+00
b22df9fd-08a0-41ff-a86e-314998debc76	PLAN-CRM-BD0DA	Enterprise CRM Annual	\N	YEARLY	1	0	ACTIVE	INR	1	10	f	\N	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:47.320664+00	2026-10-31 08:27:47.376612+00
\.


--
-- Data for Name: subscription_status_history; Type: TABLE DATA; Schema: public; Owner: brightloop_user
--

COPY public.subscription_status_history (id, subscription_id, from_status, to_status, reason, changed_by_id, created_at) FROM stdin;
fb127766-e70d-4413-af05-bb73450b4e2b	4d53671e-2944-412a-a719-7177196275b6	\N	DRAFT	Subscription initiated as DRAFT	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:01:39.102637+00
3c328fc0-9bee-40e8-b542-ea2f9d0cfa3a	4d53671e-2944-412a-a719-7177196275b6	DRAFT	QUOTATION	Transitioned to QUOTATION by operator	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:01:39.185286+00
02d70992-3232-47c5-a3f9-9dd0df1b2141	4d53671e-2944-412a-a719-7177196275b6	QUOTATION	CONFIRMED	Transitioned to CONFIRMED by operator	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:01:39.245179+00
94e86766-334c-4ad5-afb7-a95fd8f13396	4d53671e-2944-412a-a719-7177196275b6	CONFIRMED	ACTIVE	Auto-activated upon full payment of invoice INV-202610-0001	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:01:40.011002+00
48f79c80-257c-4ec3-b1f5-bed85288f169	db7dd7b6-1d74-4e90-930f-dcd1b1b9fb6e	\N	DRAFT	Subscription initiated as DRAFT	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:01:42.60332+00
9a910c6b-9155-4fc4-afd5-1e711547fa65	db7dd7b6-1d74-4e90-930f-dcd1b1b9fb6e	DRAFT	QUOTATION	Sent quote to client	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:01:42.672103+00
d14a4d82-ebdf-4b43-8ea0-d3faf1a8f438	db7dd7b6-1d74-4e90-930f-dcd1b1b9fb6e	QUOTATION	CONFIRMED	Client signed contract	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:01:42.736766+00
af1290d5-64e2-4165-a6e8-161ad9f40867	056e88ff-c823-4843-b98f-65f3b616c0b0	\N	DRAFT	Subscription initiated as DRAFT	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:24:19.395714+00
eef80ce7-65b3-4449-a700-bfc3d731f3a2	056e88ff-c823-4843-b98f-65f3b616c0b0	DRAFT	QUOTATION	Transitioned to QUOTATION by operator	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:24:19.486258+00
4e1cde57-85ed-44aa-a916-ed48407532ed	056e88ff-c823-4843-b98f-65f3b616c0b0	QUOTATION	CONFIRMED	Transitioned to CONFIRMED by operator	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:24:19.557854+00
8d6be07a-0b81-4f9c-9f32-d12be2c15f5d	056e88ff-c823-4843-b98f-65f3b616c0b0	CONFIRMED	ACTIVE	Auto-activated upon full payment of invoice INV-202610-0002	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:24:20.308171+00
77c8ce23-473b-41de-9ed0-213871211ecf	ca6b4850-fa26-42ea-8602-c9b11b500ce3	\N	DRAFT	Subscription initiated as DRAFT	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:24:22.847953+00
0384d568-34ef-4e8c-b2cc-c3d16770728b	ca6b4850-fa26-42ea-8602-c9b11b500ce3	DRAFT	QUOTATION	Sent quote to client	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:24:22.920415+00
5dfd7db3-058e-44db-9b7f-2774464bea96	ca6b4850-fa26-42ea-8602-c9b11b500ce3	QUOTATION	CONFIRMED	Client signed contract	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:24:23.071911+00
bfa40e97-b9f9-41c7-9a2e-a8487ab4385e	72541aa9-36f8-4b9c-9626-b060cc5140d3	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:33:24.444528+00
9f182bd4-9c9e-48c8-848d-ad7c4277f486	72541aa9-36f8-4b9c-9626-b060cc5140d3	DRAFT	QUOTATION	Quotation issued to TCS procurement	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:33:24.444528+00
0adba142-5267-4657-a3e2-973992e46ff7	72541aa9-36f8-4b9c-9626-b060cc5140d3	QUOTATION	CONFIRMED	PO received from TCS	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:33:24.444528+00
273d185a-e8f1-43f0-89bf-0461e25af2e9	72541aa9-36f8-4b9c-9626-b060cc5140d3	CONFIRMED	ACTIVE	Auto-activated upon full payment of invoice INV-202610-0003	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:33:24.444528+00
6e3e7868-0ee9-4ae3-bc72-4352b2051245	cecfc49e-26c5-4e3f-bac9-8f8458dc4598	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:33:24.444528+00
8b1a29c6-20d5-4623-adb6-7a4d36c49355	cecfc49e-26c5-4e3f-bac9-8f8458dc4598	DRAFT	QUOTATION	Quotation reviewed by Zomato VP Tech	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:33:24.444528+00
dd66b871-4b33-4dc5-99ab-f98304aa761f	cecfc49e-26c5-4e3f-bac9-8f8458dc4598	QUOTATION	CONFIRMED	Direct authorization granted	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:33:24.444528+00
efc356f9-6d3a-49b4-8811-84eee4cf29ed	cecfc49e-26c5-4e3f-bac9-8f8458dc4598	CONFIRMED	ACTIVE	Activated on trial terms	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:33:24.444528+00
0afd783c-5f75-42a6-9f8f-0dd4ef7cb022	84b00a2f-0122-4bc7-a407-040b02cb1133	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:33:24.444528+00
17b21172-0bb1-41b2-a057-fb3b8fd89024	84b00a2f-0122-4bc7-a407-040b02cb1133	DRAFT	QUOTATION	Quotation submitted	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:33:24.444528+00
a5c64298-0280-443b-b5d1-5e28d3d95a55	84b00a2f-0122-4bc7-a407-040b02cb1133	QUOTATION	CONFIRMED	PO issued by Swiggy Accounts	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:33:24.444528+00
9e3626bb-3c30-428c-83b5-a411d02297f6	810a53cb-11f3-4c83-8617-5835e2ab20b4	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:35:20.737791+00
a33c5d5d-72a0-4402-926a-458b5b3f6426	0f932e65-0914-408c-9d68-93cb5d16040e	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:35:21.946376+00
73156007-52cb-4d90-bdbf-969ddfa16a19	a3627d27-1e03-4400-97eb-4116a9658759	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:35:22.464794+00
2b372c86-4653-4f38-8307-349361ba25e7	102dc1b3-faff-452a-a726-68f4db877dc0	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:35:23.059597+00
0835866e-ee27-46fc-adde-aa7cbf3668aa	f1e7cc49-c8af-465e-9d83-d64f5101b2bb	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:29.488582+00
3ce8fc01-6bdf-49a2-bdb9-404b4f783f64	f1e7cc49-c8af-465e-9d83-d64f5101b2bb	DRAFT	QUOTATION	Formal quote dispatched	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:29.578939+00
3c78a975-4a64-4570-a7ee-e29aa1ca3f40	f1e7cc49-c8af-465e-9d83-d64f5101b2bb	QUOTATION	CONFIRMED	Customer approved quote	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:29.647454+00
20d9e990-b90d-4a34-8bd5-49072431dca1	f1e7cc49-c8af-465e-9d83-d64f5101b2bb	CONFIRMED	ACTIVE	Auto-activated upon full payment of invoice INV-202610-0006	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:30.32658+00
3933a78f-b950-4ba1-ae99-3729c987c7b8	9ca3f8e0-9c33-428b-9ba7-8713614d9d5c	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:32.17377+00
0aa4e14f-d300-4e7f-89e7-2b096218e962	b6ddf376-f7bf-46c9-9436-be398070771d	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:32.747767+00
32126787-22dc-4f31-9784-bf16068f6a2c	765c3a10-ad74-4467-a542-1bc924e47c3a	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:33.637009+00
58fc5dd6-dc95-4e80-af94-2c84771a0b51	94fc7b5b-d190-4f0d-a531-7d7a3ddd92cf	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:18.551974+00
f49698d6-b294-4c6f-ae46-78345c0c9f59	94fc7b5b-d190-4f0d-a531-7d7a3ddd92cf	DRAFT	QUOTATION	Formal quote dispatched	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:18.634712+00
418b94fe-2661-4a9d-88f1-d437512ece38	94fc7b5b-d190-4f0d-a531-7d7a3ddd92cf	QUOTATION	CONFIRMED	Customer approved quote	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:18.708508+00
2978c663-6e54-47dd-921c-9d1189b77abb	94fc7b5b-d190-4f0d-a531-7d7a3ddd92cf	CONFIRMED	ACTIVE	Auto-activated upon full payment of invoice INV-202610-0007	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:19.395995+00
f573cacf-d066-4f7f-8d29-b352c9680cec	d0c58c40-a1f6-4a94-bbfd-bef418d3fe4a	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:21.418813+00
c5763cc3-c5b0-4a08-a7ab-2e6918308fb2	d0c58c40-a1f6-4a94-bbfd-bef418d3fe4a	DRAFT	QUOTATION	Transitioned to QUOTATION by operator	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:21.484101+00
1868438c-5de3-4f3d-9edb-94ab87101621	d0c58c40-a1f6-4a94-bbfd-bef418d3fe4a	QUOTATION	CONFIRMED	Transitioned to CONFIRMED by operator	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:21.552868+00
2b30dea1-aa8c-49d4-b0c9-4c261f0576bf	56bce7e4-07dc-4507-bd3a-99fbbd8415fb	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:22.18957+00
24bc982b-074f-4ba8-84cd-45ee7b0c8070	56bce7e4-07dc-4507-bd3a-99fbbd8415fb	DRAFT	QUOTATION	Transitioned to QUOTATION by operator	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:22.257115+00
d25c8241-74ec-40d3-9887-a24741ea7df4	56bce7e4-07dc-4507-bd3a-99fbbd8415fb	QUOTATION	CONFIRMED	Transitioned to CONFIRMED by operator	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:22.33173+00
4b028ee8-0c9b-4588-b624-2e8f13ade029	f2b75ded-d929-4852-bceb-9abbaa11ef6c	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:23.28779+00
2d48de39-1fee-47d0-a383-0a11e12ec0a4	f2b75ded-d929-4852-bceb-9abbaa11ef6c	DRAFT	QUOTATION	Transitioned to QUOTATION by operator	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:23.350722+00
fce600d2-e102-49ae-88b2-486eb0c0ed01	f2b75ded-d929-4852-bceb-9abbaa11ef6c	QUOTATION	CONFIRMED	Transitioned to CONFIRMED by operator	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:23.426327+00
013718ac-ef7f-4986-8825-123e517bf82e	f2b75ded-d929-4852-bceb-9abbaa11ef6c	CONFIRMED	ACTIVE	Auto-activated upon full payment of invoice INV-202610-0010	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:23.596007+00
0ad44a8e-b9b7-4bf5-b15e-69a6221a7059	30ad68cd-90d1-4fc9-b2b5-ff49f20f8dfc	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:32.841738+00
f1bdb425-f0b0-4eeb-adc2-84605ecbea44	30ad68cd-90d1-4fc9-b2b5-ff49f20f8dfc	DRAFT	QUOTATION	Formal quote dispatched	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:32.917458+00
2e281610-c7a9-4421-aebe-6345c9640a21	30ad68cd-90d1-4fc9-b2b5-ff49f20f8dfc	QUOTATION	CONFIRMED	Customer approved quote	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:32.996538+00
30126b30-84a5-46b3-8054-b5ebd0b60bad	30ad68cd-90d1-4fc9-b2b5-ff49f20f8dfc	CONFIRMED	ACTIVE	Auto-activated upon full payment of invoice INV-202610-0011	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:33.622729+00
1f1d69a0-f4d7-4ad1-a67f-27a7e20f329d	2c293e93-3a1f-4630-8462-a57f05ea41c7	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:35.407239+00
7161245c-e4aa-4597-a951-12fc183a5fdc	2c293e93-3a1f-4630-8462-a57f05ea41c7	DRAFT	QUOTATION	Transitioned to QUOTATION by operator	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:35.483545+00
47125cb9-77d3-457b-98ec-809897ce79f8	2c293e93-3a1f-4630-8462-a57f05ea41c7	QUOTATION	CONFIRMED	Transitioned to CONFIRMED by operator	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:35.558102+00
911cccf9-5663-437b-bf97-f5e27ed8e262	1d20677a-d222-4695-b150-72ad3587c5e6	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:36.198985+00
43123935-e3c5-4761-8837-2425028b2bd9	1d20677a-d222-4695-b150-72ad3587c5e6	DRAFT	QUOTATION	Transitioned to QUOTATION by operator	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:36.263245+00
f722d9c7-9bff-45d8-ba58-5134813884c2	1d20677a-d222-4695-b150-72ad3587c5e6	QUOTATION	CONFIRMED	Transitioned to CONFIRMED by operator	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:36.332723+00
897cd3cb-15c0-4681-997b-ce54ce6b6550	b009b479-8b6f-4eb5-967e-c069ce31b7ad	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:37.338282+00
2051d202-338a-4079-8cc0-75154a6c21ae	b009b479-8b6f-4eb5-967e-c069ce31b7ad	DRAFT	QUOTATION	Transitioned to QUOTATION by operator	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:37.411224+00
62364625-bd27-4819-84cb-c4682c96d2fb	b009b479-8b6f-4eb5-967e-c069ce31b7ad	QUOTATION	CONFIRMED	Transitioned to CONFIRMED by operator	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:37.483434+00
38bef815-18e7-4393-8acd-3ae80ff17f8c	b009b479-8b6f-4eb5-967e-c069ce31b7ad	CONFIRMED	ACTIVE	Auto-activated upon full payment of invoice INV-202610-0014	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:37.656834+00
9df8935a-773c-4389-9513-4474329d5ed9	5ac937b7-c600-4f8e-9e05-4df0583deeb6	\N	DRAFT	Subscription initiated as DRAFT	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:38:38.395942+00
e0b8c275-4b1e-4ff5-9394-1fb2f7837f0a	5ac937b7-c600-4f8e-9e05-4df0583deeb6	DRAFT	QUOTATION	Transitioned to QUOTATION by operator	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:38:38.457305+00
647bd27d-6ca6-45bb-8538-29a630b0ee42	5ac937b7-c600-4f8e-9e05-4df0583deeb6	QUOTATION	CONFIRMED	Transitioned to CONFIRMED by operator	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:38:38.532723+00
5b4b6edd-b146-4291-9485-5b8f44c06a49	5ac937b7-c600-4f8e-9e05-4df0583deeb6	CONFIRMED	ACTIVE	Auto-activated upon full payment of invoice INV-202610-0015	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:38:39.199716+00
2f9da66a-2cf2-411c-bf06-f3de2d8bed3d	92d73e49-4377-41ad-8f79-48c14bdee83a	\N	DRAFT	Subscription initiated as DRAFT	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:38:41.888923+00
e6940d0c-139e-4625-814c-3737807107ac	92d73e49-4377-41ad-8f79-48c14bdee83a	DRAFT	QUOTATION	Sent quote to client	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:38:41.95841+00
5b0e8fad-7e56-423e-8cc3-acf77e9fe819	92d73e49-4377-41ad-8f79-48c14bdee83a	QUOTATION	CONFIRMED	Client signed contract	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:38:42.032616+00
ff3a4750-e8ea-41fc-a8c5-0fdb1f182fe9	55ef6071-df63-4182-abe2-9cbf151bdad3	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:23:57.805197+00
18523668-170a-47f6-bc30-a9a1c23e0716	55ef6071-df63-4182-abe2-9cbf151bdad3	DRAFT	QUOTATION	Sent commercial proposal	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:23:57.9012+00
6fed70d9-0243-4c9c-ab90-c5e33aea81f4	55ef6071-df63-4182-abe2-9cbf151bdad3	QUOTATION	CONFIRMED	Proposal signed by client	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:23:57.97134+00
d8d5e228-23d0-4281-8f63-0c33a6f47901	875aa731-5cb8-4dda-8c8f-30e6c35a22f2	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:09.278061+00
86cdc844-f4d2-482f-ad4d-52419ba32423	875aa731-5cb8-4dda-8c8f-30e6c35a22f2	DRAFT	QUOTATION	Sent commercial proposal	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:09.376958+00
b205d733-011a-4b63-acf5-0fde6f06d2d2	875aa731-5cb8-4dda-8c8f-30e6c35a22f2	QUOTATION	CONFIRMED	Proposal signed by client	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:09.486241+00
7241a1ba-2aa5-4951-9269-3850c14cb71e	d3d2ff47-1496-45ee-bc84-ec7e81aced75	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:11.358629+00
e560f47e-6725-4f7c-a5ab-2706b7b21da9	d3d2ff47-1496-45ee-bc84-ec7e81aced75	DRAFT	QUOTATION	Formal quote dispatched	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:11.44719+00
c9a14221-d8ba-4b92-903f-80a6995a6007	d3d2ff47-1496-45ee-bc84-ec7e81aced75	QUOTATION	CONFIRMED	Customer approved quote	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:11.5357+00
9e067adc-2781-4544-91bc-26dbd01b326f	d3d2ff47-1496-45ee-bc84-ec7e81aced75	CONFIRMED	ACTIVE	Auto-activated upon full payment of invoice INV-202610-0016	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:12.46962+00
2dc8016f-8792-4b90-aba7-16d0b0e82c35	f6261125-c013-4208-a694-f85ba034150b	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:14.475416+00
ef391d50-673b-42f6-969d-df4069477c58	f6261125-c013-4208-a694-f85ba034150b	DRAFT	QUOTATION	Transitioned to QUOTATION by operator	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:14.536827+00
468665eb-5b40-44a4-a66b-a910f50db05f	f6261125-c013-4208-a694-f85ba034150b	QUOTATION	CONFIRMED	Transitioned to CONFIRMED by operator	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:14.706785+00
cd1fd573-fe2a-4279-8a36-762bd9e523ec	96e254fe-161e-43c8-bd4e-374d2a6277a3	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:15.391893+00
d8e2b433-7876-4a7f-a779-a1860cb1012b	96e254fe-161e-43c8-bd4e-374d2a6277a3	DRAFT	QUOTATION	Transitioned to QUOTATION by operator	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:15.472122+00
b0f40c05-d4a3-41ac-b3df-54f8a75d7219	96e254fe-161e-43c8-bd4e-374d2a6277a3	QUOTATION	CONFIRMED	Transitioned to CONFIRMED by operator	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:15.561272+00
23fa06e3-dbf8-4147-a64a-d78164c4285c	6b0a8d72-7313-402a-9e66-e287cb1eef53	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:16.859998+00
ce20c95e-3fc4-40e0-90d8-80f48b041ccc	6b0a8d72-7313-402a-9e66-e287cb1eef53	DRAFT	QUOTATION	Transitioned to QUOTATION by operator	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:16.923822+00
84dbb6f7-86bf-4a4d-95d9-2a4808640482	6b0a8d72-7313-402a-9e66-e287cb1eef53	QUOTATION	CONFIRMED	Transitioned to CONFIRMED by operator	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:16.995376+00
5473656b-44cb-40cf-954b-97983259672b	6b0a8d72-7313-402a-9e66-e287cb1eef53	CONFIRMED	ACTIVE	Auto-activated upon full payment of invoice INV-202610-0019	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:17.17587+00
224ba09d-2b39-47fc-8573-7f4c95d5191c	1145b2e2-2ee9-4ecc-ac68-7e3e0e6c3a86	\N	DRAFT	Subscription initiated as DRAFT	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:24:17.973194+00
7ad3df19-efd7-4e2e-8212-c10075657dac	1145b2e2-2ee9-4ecc-ac68-7e3e0e6c3a86	DRAFT	QUOTATION	Transitioned to QUOTATION by operator	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:24:18.038333+00
836858f0-de47-4e0e-84d3-b648589b21b8	1145b2e2-2ee9-4ecc-ac68-7e3e0e6c3a86	QUOTATION	CONFIRMED	Transitioned to CONFIRMED by operator	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:24:18.111443+00
7d341bcd-a53d-4bf0-9a80-03b1fba0e29e	1145b2e2-2ee9-4ecc-ac68-7e3e0e6c3a86	CONFIRMED	ACTIVE	Auto-activated upon full payment of invoice INV-202610-0020	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:24:18.900848+00
a222813f-d86d-4cc2-b368-63bd79232e4a	e5515f04-233b-497e-9d5c-ac98cbca4ba9	\N	DRAFT	Subscription initiated as DRAFT	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:24:21.495802+00
c5f4238d-c154-4e31-9970-065d98991f3e	e5515f04-233b-497e-9d5c-ac98cbca4ba9	DRAFT	QUOTATION	Sent quote to client	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:24:21.570074+00
ec783634-5cbd-43f9-b86b-3c1e491320c2	e5515f04-233b-497e-9d5c-ac98cbca4ba9	QUOTATION	CONFIRMED	Client signed contract	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:24:21.64325+00
aae5c112-2b0c-4dd9-a082-1437d1db7be7	c922adde-b083-4ccc-8cf1-fbc7fe27b2dc	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:24.723866+00
10f6586c-97f3-49cf-8bbd-e2e6f9e7dd9f	c922adde-b083-4ccc-8cf1-fbc7fe27b2dc	DRAFT	QUOTATION	Sent commercial proposal	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:24.812904+00
bb30c83c-e069-4cce-81db-50893d695b30	c922adde-b083-4ccc-8cf1-fbc7fe27b2dc	QUOTATION	CONFIRMED	Proposal signed by client	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:24.885613+00
dd5302d7-6593-4ddb-b1a8-3a9e92d466c5	f3e4a272-fb34-4599-8ee0-209476dc8f7c	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:36.510292+00
c4eaf482-21d9-4a2b-815b-e24b0eb969be	f3e4a272-fb34-4599-8ee0-209476dc8f7c	DRAFT	QUOTATION	Sent commercial proposal	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:36.637713+00
01c7c5e4-6af9-465a-a2ad-ddd6d5a92ee7	f3e4a272-fb34-4599-8ee0-209476dc8f7c	QUOTATION	CONFIRMED	Proposal signed by client	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:36.709776+00
7f0fd60d-fa21-4b23-8030-273ede2c338b	a71d2d50-f658-4fd0-b097-6de1dc57d86f	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:38.189701+00
0205e7ea-cf33-4706-a91e-45033b75b9be	a71d2d50-f658-4fd0-b097-6de1dc57d86f	DRAFT	QUOTATION	Formal quote dispatched	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:38.254663+00
8afa92d2-fe5f-4cdc-87af-8c40f08eabc2	a71d2d50-f658-4fd0-b097-6de1dc57d86f	QUOTATION	CONFIRMED	Customer approved quote	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:38.331431+00
72df2ec8-aac6-4e13-aa20-8d203e2cb99f	a71d2d50-f658-4fd0-b097-6de1dc57d86f	CONFIRMED	ACTIVE	Auto-activated upon full payment of invoice INV-202610-0021	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:38.997464+00
9d4884c0-a4e7-4f26-b7be-5982ffcaf881	73b766b0-35e5-4fc1-a7d8-d4d3fef4e1fd	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:40.958558+00
55dc40de-d8cd-4432-acc9-7aa65596f360	73b766b0-35e5-4fc1-a7d8-d4d3fef4e1fd	DRAFT	QUOTATION	Transitioned to QUOTATION by operator	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:41.024774+00
0931fa8a-6537-4edf-8118-e175dff092a6	73b766b0-35e5-4fc1-a7d8-d4d3fef4e1fd	QUOTATION	CONFIRMED	Transitioned to CONFIRMED by operator	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:41.093615+00
f9714887-8a65-475b-8795-d018c8a5e950	8b58c724-98ce-465c-a73a-82d998e94cff	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:41.719361+00
33d8bf92-1606-4387-987e-7c73c6fe1a93	8b58c724-98ce-465c-a73a-82d998e94cff	DRAFT	QUOTATION	Transitioned to QUOTATION by operator	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:41.782177+00
7ff64bb1-f331-45af-af34-bc13f78d5a39	8b58c724-98ce-465c-a73a-82d998e94cff	QUOTATION	CONFIRMED	Transitioned to CONFIRMED by operator	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:41.852872+00
3f07f4f9-dc35-49e0-bf1a-62b67dd7785c	2e63834d-8e53-411f-b939-f1d9e971f63e	\N	DRAFT	Subscription initiated as DRAFT	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:42.817167+00
f266f94b-e455-410d-8186-fe3dff384eb2	2e63834d-8e53-411f-b939-f1d9e971f63e	DRAFT	QUOTATION	Transitioned to QUOTATION by operator	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:42.893668+00
ff3631cb-fe0c-4262-98e0-40a77396f5cb	2e63834d-8e53-411f-b939-f1d9e971f63e	QUOTATION	CONFIRMED	Transitioned to CONFIRMED by operator	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:42.972808+00
29c7c0a6-1698-44a0-b3eb-a67179658e67	2e63834d-8e53-411f-b939-f1d9e971f63e	CONFIRMED	ACTIVE	Auto-activated upon full payment of invoice INV-202610-0024	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:43.148216+00
a59c5717-ab2c-47b0-b752-c9300266518f	504b31b6-e697-46b6-b0f4-7c48b4117fe0	\N	DRAFT	Subscription initiated as DRAFT	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:27:43.983912+00
2e6920d8-ddae-4412-92b9-95c58f6043bc	504b31b6-e697-46b6-b0f4-7c48b4117fe0	DRAFT	QUOTATION	Transitioned to QUOTATION by operator	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:27:44.048587+00
81bc5f93-3fc5-42b3-8b76-fbd831cb621a	504b31b6-e697-46b6-b0f4-7c48b4117fe0	QUOTATION	CONFIRMED	Transitioned to CONFIRMED by operator	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:27:44.12598+00
e079e3c1-d132-4e04-8de7-884635e764a2	504b31b6-e697-46b6-b0f4-7c48b4117fe0	CONFIRMED	ACTIVE	Auto-activated upon full payment of invoice INV-202610-0025	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:27:44.813299+00
9c4b8871-84a4-4bf0-9a58-abe89ffb3cc1	1659f7a4-97c9-4786-bba4-3bb3f7631f7f	\N	DRAFT	Subscription initiated as DRAFT	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:27:47.504789+00
b0bc4268-71d0-4c2d-a40d-6223f5ff1f12	1659f7a4-97c9-4786-bba4-3bb3f7631f7f	DRAFT	QUOTATION	Sent quote to client	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:27:47.574828+00
cddf9a25-3b42-4ffc-b298-6cf696854047	1659f7a4-97c9-4786-bba4-3bb3f7631f7f	QUOTATION	CONFIRMED	Client signed contract	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:27:47.635289+00
\.


--
-- Data for Name: subscriptions; Type: TABLE DATA; Schema: public; Owner: brightloop_user
--

COPY public.subscriptions (id, subscription_number, customer_id, plan_id, status, start_date, expiry_date, billing_interval, interval_count, currency, payment_terms, subtotal, tax_rate, tax_amount, discount_amount, total_amount, notes, created_by_id, updated_by_id, created_at, updated_at) FROM stdin;
55ef6071-df63-4182-abe2-9cbf151bdad3	SUB-202610-0026	8a9d9a1d-6169-461f-8fad-82cfda34d74b	0086d29b-ddd9-4dc5-9ac0-3d74ea38cba4	CONFIRMED	2026-11-01 00:00:00+00	2026-12-01 00:00:00+00	MONTHLY	1	INR	NET_30	999.0000	18.0000	179.8200	0.0000	1178.8200	Starter catalogue plan subscription	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:23:57.805197+00	2026-10-31 08:23:57.97134+00
4d53671e-2944-412a-a719-7177196275b6	SUB-202610-0001	d8aba305-385d-4f8c-abcd-ee4db0e52f4d	55293743-248d-46b3-88bf-847e5bf20636	ACTIVE	2026-10-31 07:01:39.095339+00	2026-11-30 07:01:39.095339+00	MONTHLY	1	INR	NET_30	2000.0000	18.0000	360.0000	0.0000	2360.0000	\N	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:01:39.102637+00	2026-10-31 07:01:40.011002+00
db7dd7b6-1d74-4e90-930f-dcd1b1b9fb6e	SUB-202610-0002	4220650e-a590-4d9f-bbc1-f91752567133	2cf2f096-5052-4398-9a1f-f75a93f0df4b	CONFIRMED	2026-10-31 07:01:42.596194+00	2027-10-31 07:01:42.596194+00	YEARLY	1	INR	NET_30	9000.0000	18.0000	1530.0000	500.0000	10030.0000	Annual enterprise contract	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:01:42.60332+00	2026-10-31 07:01:42.736766+00
875aa731-5cb8-4dda-8c8f-30e6c35a22f2	SUB-202610-0027	01b93597-5723-44ad-9492-ef3607218c92	0086d29b-ddd9-4dc5-9ac0-3d74ea38cba4	CONFIRMED	2026-11-01 00:00:00+00	2026-12-01 00:00:00+00	MONTHLY	1	INR	NET_30	999.0000	18.0000	179.8200	0.0000	1178.8200	Starter catalogue plan subscription	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:09.278061+00	2026-10-31 08:24:09.486241+00
056e88ff-c823-4843-b98f-65f3b616c0b0	SUB-202610-0003	20de22c3-c73e-40d3-bc37-9cf9b129a783	4681a3b4-7b93-4d9a-849e-224f0b310797	ACTIVE	2026-10-31 07:24:19.387008+00	2026-11-30 07:24:19.387008+00	MONTHLY	1	INR	NET_30	2000.0000	18.0000	360.0000	0.0000	2360.0000	\N	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:24:19.395714+00	2026-10-31 07:24:20.308171+00
d3d2ff47-1496-45ee-bc84-ec7e81aced75	SUB-202610-0028	bca5e35f-ed0e-4e3c-a57f-eb24c360a6fb	3737c0df-0bb6-4dee-a209-5b1b1c4d31b9	ACTIVE	2026-10-31 08:24:11.350081+00	2026-11-30 08:24:11.350081+00	MONTHLY	1	INR	NET_30	50000.0000	18.0000	9000.0000	0.0000	59000.0000	E2E Audit subscription instance	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:11.358629+00	2026-10-31 08:24:12.46962+00
ca6b4850-fa26-42ea-8602-c9b11b500ce3	SUB-202610-0004	bae036c5-9766-4885-9b31-95a70c4cea4f	c6243761-457c-4c31-bace-512802fd0015	CONFIRMED	2026-10-31 07:24:22.840214+00	2027-10-31 07:24:22.840214+00	YEARLY	1	INR	NET_30	9000.0000	18.0000	1530.0000	500.0000	10030.0000	Annual enterprise contract	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:24:22.847953+00	2026-10-31 07:24:23.071911+00
f6261125-c013-4208-a694-f85ba034150b	SUB-202610-0029	0e75110e-28f7-451f-a480-86c34b25a040	63848a77-2df4-4368-8796-c09dac27b6f4	CONFIRMED	2026-10-31 08:24:14.467785+00	2026-11-30 08:24:14.467785+00	MONTHLY	1	INR	NET_30	1000.0000	18.0000	180.0000	0.0000	1180.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:14.475416+00	2026-10-31 08:24:14.706785+00
96e254fe-161e-43c8-bd4e-374d2a6277a3	SUB-202610-0030	40937aa1-dcea-4eee-b28b-597f431549e5	bf0fe4c3-380f-497b-8893-9827fde63b12	CONFIRMED	2026-10-31 08:24:15.384225+00	2026-11-30 08:24:15.384225+00	MONTHLY	1	INR	NET_30	1000.0000	18.0000	180.0000	0.0000	1180.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:15.391893+00	2026-10-31 08:24:15.561272+00
6b0a8d72-7313-402a-9e66-e287cb1eef53	SUB-202610-0031	ef262998-7f20-45f5-bed3-ac7a7de9c250	2174e10f-65e8-4882-b370-2dfd10171b07	ACTIVE	2026-10-31 08:24:16.851203+00	2026-11-30 08:24:16.851203+00	MONTHLY	1	INR	NET_30	500.0000	18.0000	90.0000	0.0000	590.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:24:16.859998+00	2026-10-31 08:24:17.17587+00
1145b2e2-2ee9-4ecc-ac68-7e3e0e6c3a86	SUB-202610-0032	f4256ea5-779c-448a-b1fb-6a98398d127c	02bd8e1a-1f5f-4e5d-8c1e-1d909a546854	ACTIVE	2026-10-31 08:24:17.96618+00	2026-11-30 08:24:17.96618+00	MONTHLY	1	INR	NET_30	2000.0000	18.0000	360.0000	0.0000	2360.0000	\N	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:24:17.973194+00	2026-10-31 08:24:18.900848+00
72541aa9-36f8-4b9c-9626-b060cc5140d3	SUB-202610-0005	0bbc71dc-0eda-419a-88a5-03fb4ff39b6b	d384f73d-e895-4459-ab35-677aa5b24362	ACTIVE	2026-10-01 07:33:24.877413+00	2027-10-01 07:33:24.877413+00	YEARLY	1	INR	NET_30	120000.0000	18.0000	21600.0000	0.0000	141600.0000	Annual Enterprise SaaS Contract FY26-27	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
cecfc49e-26c5-4e3f-bac9-8f8458dc4598	SUB-202610-0006	c35f47e5-0366-411b-81af-49b909c51fbc	c74c2965-322c-4f1c-b764-71a5d895d2d8	ACTIVE	2026-10-26 07:33:24.877413+00	2026-11-25 07:33:24.877413+00	MONTHLY	1	INR	NET_15	15000.0000	18.0000	2700.0000	0.0000	17700.0000	Monthly Growth License	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
84b00a2f-0122-4bc7-a407-040b02cb1133	SUB-202610-0007	5aa41d88-f9e6-405b-981a-c96dd1144e29	d384f73d-e895-4459-ab35-677aa5b24362	CONFIRMED	2026-10-31 07:33:24.877413+00	2027-10-31 07:33:24.877413+00	YEARLY	1	INR	NET_30	120000.0000	18.0000	21600.0000	0.0000	141600.0000	Annual Enterprise Rollout	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
810a53cb-11f3-4c83-8617-5835e2ab20b4	SUB-202610-0008	8b412e2c-8436-413f-924b-fa819d601cf2	6900679d-5caa-4a5f-a0fa-4e68c86687a6	DRAFT	2026-10-31 07:35:20.727537+00	2026-11-30 07:35:20.727537+00	MONTHLY	1	INR	NET_30	50000.0000	18.0000	9000.0000	0.0000	59000.0000	E2E Audit subscription instance	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:35:20.737791+00	2026-10-31 07:35:20.737791+00
0f932e65-0914-408c-9d68-93cb5d16040e	SUB-202610-0009	c10a4652-77d5-42e5-a1d4-9eb8ed365153	5a6f8220-4f8c-4192-a679-dae3a6888a01	DRAFT	2026-10-31 07:35:21.939824+00	2026-11-30 07:35:21.939824+00	MONTHLY	1	INR	NET_30	1000.0000	18.0000	180.0000	0.0000	1180.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:35:21.946376+00	2026-10-31 07:35:21.946376+00
a3627d27-1e03-4400-97eb-4116a9658759	SUB-202610-0010	1214e873-31fb-4ac4-89d7-eaabfff658bd	85463b60-e094-4575-9c20-02f2bd715080	DRAFT	2026-10-31 07:35:22.457963+00	2026-11-30 07:35:22.457963+00	MONTHLY	1	INR	NET_30	1000.0000	18.0000	180.0000	0.0000	1180.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:35:22.464794+00	2026-10-31 07:35:22.464794+00
102dc1b3-faff-452a-a726-68f4db877dc0	SUB-202610-0011	42fdbc73-7c79-4ce4-a25f-85420d3bf4fe	092e3a0c-9bd7-4bf4-98cd-c6bd89bf06c6	DRAFT	2026-10-31 07:35:23.05347+00	2026-11-30 07:35:23.05347+00	MONTHLY	1	INR	NET_30	500.0000	18.0000	90.0000	0.0000	590.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:35:23.059597+00	2026-10-31 07:35:23.059597+00
f1e7cc49-c8af-465e-9d83-d64f5101b2bb	SUB-202610-0012	d1ad1940-cda3-43d9-8725-9af55aabf801	fa4315a7-89d6-4aec-906e-eaceb128d2ab	ACTIVE	2026-10-31 07:37:29.478344+00	2026-11-30 07:37:29.478344+00	MONTHLY	1	INR	NET_30	50000.0000	18.0000	9000.0000	0.0000	59000.0000	E2E Audit subscription instance	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:29.488582+00	2026-10-31 07:37:30.32658+00
9ca3f8e0-9c33-428b-9ba7-8713614d9d5c	SUB-202610-0013	33ac25c4-2e2a-40b1-ab02-908cc110c426	0a961d0a-af94-4712-9de1-331c2f043343	DRAFT	2026-10-31 07:37:32.166475+00	2026-11-30 07:37:32.166475+00	MONTHLY	1	INR	NET_30	1000.0000	18.0000	180.0000	0.0000	1180.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:32.17377+00	2026-10-31 07:37:32.17377+00
b6ddf376-f7bf-46c9-9436-be398070771d	SUB-202610-0014	f77c7295-47d5-4694-adea-980a61c56830	497e8a79-6474-4c05-ae8f-c3504448bcc6	DRAFT	2026-10-31 07:37:32.739565+00	2026-11-30 07:37:32.739565+00	MONTHLY	1	INR	NET_30	1000.0000	18.0000	180.0000	0.0000	1180.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:32.747767+00	2026-10-31 07:37:32.747767+00
765c3a10-ad74-4467-a542-1bc924e47c3a	SUB-202610-0015	11c4eb39-bdc0-4da1-bb1d-9b33bed52f9a	7d53651d-4f7a-4d08-ae20-255e14608dac	DRAFT	2026-10-31 07:37:33.630083+00	2026-11-30 07:37:33.630083+00	MONTHLY	1	INR	NET_30	500.0000	18.0000	90.0000	0.0000	590.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:37:33.637009+00	2026-10-31 07:37:33.637009+00
94fc7b5b-d190-4f0d-a531-7d7a3ddd92cf	SUB-202610-0016	ad1f6972-67c1-4b0b-a015-ba3aea186bc9	e84fb213-7803-4a33-90c7-62ac22c16ae7	ACTIVE	2026-10-31 07:38:18.541645+00	2026-11-30 07:38:18.541645+00	MONTHLY	1	INR	NET_30	50000.0000	18.0000	9000.0000	0.0000	59000.0000	E2E Audit subscription instance	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:18.551974+00	2026-10-31 07:38:19.395995+00
d0c58c40-a1f6-4a94-bbfd-bef418d3fe4a	SUB-202610-0017	1391c136-849b-4cbc-8cdb-7c35f86cd85e	364ce5b7-24c4-4e38-8370-245fb703bc22	CONFIRMED	2026-10-31 07:38:21.411067+00	2026-11-30 07:38:21.411067+00	MONTHLY	1	INR	NET_30	1000.0000	18.0000	180.0000	0.0000	1180.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:21.418813+00	2026-10-31 07:38:21.552868+00
56bce7e4-07dc-4507-bd3a-99fbbd8415fb	SUB-202610-0018	e5f99822-843b-4c7c-bd7b-3afa17d5e1c9	7fdf215f-b7a1-4f77-8a65-3894140e0123	CONFIRMED	2026-10-31 07:38:22.180773+00	2026-11-30 07:38:22.180773+00	MONTHLY	1	INR	NET_30	1000.0000	18.0000	180.0000	0.0000	1180.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:22.18957+00	2026-10-31 07:38:22.33173+00
f2b75ded-d929-4852-bceb-9abbaa11ef6c	SUB-202610-0019	eb64f133-dafc-418f-8f4a-90e9dbc9cdcb	8aba86b1-d16b-4d9d-bb5f-3aa6e899dfef	ACTIVE	2026-10-31 07:38:23.279972+00	2026-11-30 07:38:23.279972+00	MONTHLY	1	INR	NET_30	500.0000	18.0000	90.0000	0.0000	590.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:23.28779+00	2026-10-31 07:38:23.596007+00
30ad68cd-90d1-4fc9-b2b5-ff49f20f8dfc	SUB-202610-0020	b9ba2119-ac8a-4bf5-85ff-889e7efba0d6	80d48bf7-069c-4120-b281-056deee297dd	ACTIVE	2026-10-31 07:38:32.833159+00	2026-11-30 07:38:32.833159+00	MONTHLY	1	INR	NET_30	50000.0000	18.0000	9000.0000	0.0000	59000.0000	E2E Audit subscription instance	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:32.841738+00	2026-10-31 07:38:33.622729+00
2c293e93-3a1f-4630-8462-a57f05ea41c7	SUB-202610-0021	a7b2a3b6-0da7-4090-91a0-c7dcf15afcce	71bc4fdd-3710-4983-b791-4d51f05fc06f	CONFIRMED	2026-10-31 07:38:35.400398+00	2026-11-30 07:38:35.400398+00	MONTHLY	1	INR	NET_30	1000.0000	18.0000	180.0000	0.0000	1180.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:35.407239+00	2026-10-31 07:38:35.558102+00
1d20677a-d222-4695-b150-72ad3587c5e6	SUB-202610-0022	0704c6a3-68be-4b4c-adca-8184b6bdbc45	09cd09d4-49bb-445a-a354-dbadde65da9b	CONFIRMED	2026-10-31 07:38:36.192046+00	2026-11-30 07:38:36.192046+00	MONTHLY	1	INR	NET_30	1000.0000	18.0000	180.0000	0.0000	1180.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:36.198985+00	2026-10-31 07:38:36.332723+00
b009b479-8b6f-4eb5-967e-c069ce31b7ad	SUB-202610-0023	cb06e29c-acf5-4d8e-9b97-91a250b6b4d8	c1898049-e5c0-4876-895c-652b068ef387	ACTIVE	2026-10-31 07:38:37.330844+00	2026-11-30 07:38:37.330844+00	MONTHLY	1	INR	NET_30	500.0000	18.0000	90.0000	0.0000	590.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 07:38:37.338282+00	2026-10-31 07:38:37.656834+00
5ac937b7-c600-4f8e-9e05-4df0583deeb6	SUB-202610-0024	4f3ec259-43da-4e7a-8316-22a71e23d0db	607f6d79-67ea-4b2a-8264-eae014a615e5	ACTIVE	2026-10-31 07:38:38.387872+00	2026-11-30 07:38:38.387872+00	MONTHLY	1	INR	NET_30	2000.0000	18.0000	360.0000	0.0000	2360.0000	\N	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:38:38.395942+00	2026-10-31 07:38:39.199716+00
92d73e49-4377-41ad-8f79-48c14bdee83a	SUB-202610-0025	736170c1-8d28-4697-8a53-2078ecea8b13	147b0b93-5602-4647-b291-00677cb15235	CONFIRMED	2026-10-31 07:38:41.882073+00	2027-10-31 07:38:41.882073+00	YEARLY	1	INR	NET_30	9000.0000	18.0000	1530.0000	500.0000	10030.0000	Annual enterprise contract	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 07:38:41.888923+00	2026-10-31 07:38:42.032616+00
e5515f04-233b-497e-9d5c-ac98cbca4ba9	SUB-202610-0033	dfba3c49-ad17-4293-b71b-dbbdc4b2f9e5	3ebd52a8-4f5e-4ffc-8137-ed0b98bf0ac6	CONFIRMED	2026-10-31 08:24:21.487723+00	2027-10-31 08:24:21.487723+00	YEARLY	1	INR	NET_30	9000.0000	18.0000	1530.0000	500.0000	10030.0000	Annual enterprise contract	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:24:21.495802+00	2026-10-31 08:24:21.64325+00
c922adde-b083-4ccc-8cf1-fbc7fe27b2dc	SUB-202610-0034	471abd59-8328-4d62-86a5-c44e823b038f	0086d29b-ddd9-4dc5-9ac0-3d74ea38cba4	CONFIRMED	2026-11-01 00:00:00+00	2026-12-01 00:00:00+00	MONTHLY	1	INR	NET_30	999.0000	18.0000	179.8200	0.0000	1178.8200	Starter catalogue plan subscription	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:24.723866+00	2026-10-31 08:27:24.885613+00
f3e4a272-fb34-4599-8ee0-209476dc8f7c	SUB-202610-0035	2dae25d5-6862-4497-b9cc-45c004092c6e	0086d29b-ddd9-4dc5-9ac0-3d74ea38cba4	CONFIRMED	2026-11-01 00:00:00+00	2026-12-01 00:00:00+00	MONTHLY	1	INR	NET_30	999.0000	18.0000	179.8200	0.0000	1178.8200	Starter catalogue plan subscription	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:36.510292+00	2026-10-31 08:27:36.709776+00
a71d2d50-f658-4fd0-b097-6de1dc57d86f	SUB-202610-0036	e86d89d3-0129-4b78-af76-2534ca7c0dce	d2654e09-aeee-46a4-94b4-84e10c0b7863	ACTIVE	2026-10-31 08:27:38.183028+00	2026-11-30 08:27:38.183028+00	MONTHLY	1	INR	NET_30	50000.0000	18.0000	9000.0000	0.0000	59000.0000	E2E Audit subscription instance	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:38.189701+00	2026-10-31 08:27:38.997464+00
73b766b0-35e5-4fc1-a7d8-d4d3fef4e1fd	SUB-202610-0037	b9dbbade-cf48-41e7-8d11-ef09de2c12df	7197035c-ac98-4c4f-82fc-cef10aa9083c	CONFIRMED	2026-10-31 08:27:40.951096+00	2026-11-30 08:27:40.951096+00	MONTHLY	1	INR	NET_30	1000.0000	18.0000	180.0000	0.0000	1180.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:40.958558+00	2026-10-31 08:27:41.093615+00
8b58c724-98ce-465c-a73a-82d998e94cff	SUB-202610-0038	3a143bfe-fc4e-40dd-9a30-3120cd17fc02	ec1f61ea-d591-435c-aff8-a2111e610265	CONFIRMED	2026-10-31 08:27:41.71284+00	2026-11-30 08:27:41.71284+00	MONTHLY	1	INR	NET_30	1000.0000	18.0000	180.0000	0.0000	1180.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:41.719361+00	2026-10-31 08:27:41.852872+00
2e63834d-8e53-411f-b939-f1d9e971f63e	SUB-202610-0039	d69a4475-31c3-44f8-b77e-8fce5e1c05df	6e0b404e-10dc-405d-9b5e-22f30b03af37	ACTIVE	2026-10-31 08:27:42.80916+00	2026-11-30 08:27:42.80916+00	MONTHLY	1	INR	NET_30	500.0000	18.0000	90.0000	0.0000	590.0000	\N	5040313c-9900-4630-93f9-1f0e119412dd	5040313c-9900-4630-93f9-1f0e119412dd	2026-10-31 08:27:42.817167+00	2026-10-31 08:27:43.148216+00
504b31b6-e697-46b6-b0f4-7c48b4117fe0	SUB-202610-0040	a5ecc61e-3478-4aac-9c83-7493ce661f9f	c0440129-1c09-4070-a713-c056c1eac0c1	ACTIVE	2026-10-31 08:27:43.976407+00	2026-11-30 08:27:43.976407+00	MONTHLY	1	INR	NET_30	2000.0000	18.0000	360.0000	0.0000	2360.0000	\N	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:27:43.983912+00	2026-10-31 08:27:44.813299+00
1659f7a4-97c9-4786-bba4-3bb3f7631f7f	SUB-202610-0041	5c4355f7-6790-490d-949e-0f2519e701f7	b22df9fd-08a0-41ff-a86e-314998debc76	CONFIRMED	2026-10-31 08:27:47.497199+00	2027-10-31 08:27:47.497199+00	YEARLY	1	INR	NET_30	9000.0000	18.0000	1530.0000	500.0000	10030.0000	Annual enterprise contract	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	c1bdd9d8-2163-4523-80ef-785a90e7c4e2	2026-10-31 08:27:47.504789+00	2026-10-31 08:27:47.635289+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: brightloop_user
--

COPY public.users (id, email, full_name, hashed_password, role, is_active, is_verified, created_at, updated_at) FROM stdin;
5040313c-9900-4630-93f9-1f0e119412dd	admin@brightloop.com	System Administrator	$argon2id$v=19$m=65536,t=3,p=4$mYYd1CqDuonNEjXG3exfmQ$v8PB4KXHtymZeRkmFTkXCa/LQZMwHnu+jgkfnTctSsA	ADMIN	t	t	2026-10-31 04:11:58.133516+00	2026-10-31 04:11:58.133516+00
86e39d83-656a-4a5f-b96d-9ee66a6620ca	customer_8a0265cf@example.com	Test Customer	$argon2id$v=19$m=65536,t=3,p=4$tpZ+lTNC61j3udJ+J9EovQ$QESDbdI9WCLaK1OHtSVbl0T8hTSE6SoP7sx1yZLrC24	CUSTOMER	t	t	2026-10-31 04:13:42.779947+00	2026-10-31 04:13:42.779947+00
6e59d264-58ea-4ada-ae92-99dd3d5aa6d9	login_user_128727ed@example.com	Login User	$argon2id$v=19$m=65536,t=3,p=4$wpbETr4gN9DtE29aSSxOMQ$zHZa9gVvqo+pweHxFfV/8DWPKX8BEALFqGcvcEYXQJU	CUSTOMER	t	t	2026-10-31 04:13:43.210571+00	2026-10-31 04:13:43.210571+00
eff31d33-4717-4f20-8fb1-480799cdeae5	reset_d49fb5b2@example.com	Reset User	$argon2id$v=19$m=65536,t=3,p=4$GOLJr613hbNZ7C7Wk7ndsA$9MFuMOBBKZ7Tp3LmkwWsumzqLdkcku/L3z01txaKSrU	CUSTOMER	t	t	2026-10-31 04:13:43.606226+00	2026-10-31 04:13:43.703589+00
c1bdd9d8-2163-4523-80ef-785a90e7c4e2	staff_47ff2f38@example.com	Support Staff Member	$argon2id$v=19$m=65536,t=3,p=4$pxt6rtn3jXC1BXrCIJkEZw$QfecuUMEhoMGwBMGohbm1WqdQyTpRCbsFVbe5Y00W14	STAFF	t	t	2026-10-31 04:13:44.154827+00	2026-10-31 04:13:44.154827+00
323912e5-9c09-4482-8595-d1428cf1c4c0	cust_4ff5b2fc@example.com	Customer One	$argon2id$v=19$m=65536,t=3,p=4$/YKCb04Dkq/CNyR2wOSHzA$Syp+rZVU6C4LNeAE4R+aZGyEOLgaRg2RMwU63KH5tVw	CUSTOMER	f	t	2026-10-31 04:13:44.074631+00	2026-10-31 04:13:44.278068+00
b4ee41b2-33d5-46a9-b2de-35d6515f5a97	customer_b1715f05@example.com	Test Customer	$argon2id$v=19$m=65536,t=3,p=4$FBASwy0ZX2q+kjsxBZ/eOw$zMoMvnLSkRnYyf/mNXN8VCHC+gip/S8XUSEAknMVpn0	CUSTOMER	t	t	2026-10-31 04:14:26.770563+00	2026-10-31 04:14:26.770563+00
c79cc6d8-b258-40df-888c-bd338cf6809d	login_user_670e2dec@example.com	Login User	$argon2id$v=19$m=65536,t=3,p=4$D6W1M0tT/4JY7Isj9NrUxg$PNQnvit3xswpXXrWLEUH3sLDY5uJ2eR5WHtFmWA5/IA	CUSTOMER	t	t	2026-10-31 04:14:27.171131+00	2026-10-31 04:14:27.171131+00
1ceff4fa-c65a-4484-90fa-936b33db28a2	customer_6dcaefec@example.com	Test Customer	$argon2id$v=19$m=65536,t=3,p=4$l7BaZC8mZmQjDA+OFd6r2w$5V9qg5rtwY+VqH9CUfZfScCdcsIjIeqG5MN8kkb//5U	CUSTOMER	t	t	2026-10-31 04:14:56.170402+00	2026-10-31 04:14:56.170402+00
ef828a90-4f4a-4a4f-8178-3995232f893c	dup_ffbea23b@example.com	First User	$argon2id$v=19$m=65536,t=3,p=4$OnCx75kOip+fFE8mesEJDA$/1cXoitNUaPLAWUESObWHbA0Sw1HYI5CCaTRNheQ1G8	CUSTOMER	t	t	2026-10-31 04:14:56.309467+00	2026-10-31 04:14:56.309467+00
cee17693-481d-4828-a0e6-1c42aaa54c5a	login_user_e28fd751@example.com	Login User	$argon2id$v=19$m=65536,t=3,p=4$ZP4Lp5hQVZ9By25+9JDsBg$GiV7Bn/tvFVT+esOyn/ICS7e2AymhWBMvmid/eBzCRQ	CUSTOMER	t	t	2026-10-31 04:14:56.40142+00	2026-10-31 04:14:56.40142+00
640afb31-c926-413e-a5f1-0342024aedc3	rotation_7f104c3b@example.com	Rotation User	$argon2id$v=19$m=65536,t=3,p=4$fbPucYOnMBvsjiUXKYnFsg$Nhihnl/GGJ4XTCbSAfpOqifl7jn1+A0albTLz+YRy+k	CUSTOMER	t	t	2026-10-31 04:14:56.600793+00	2026-10-31 04:14:56.600793+00
1f4ef7b6-1866-4f50-9627-2d5340886b2f	reset_286520da@example.com	Reset User	$argon2id$v=19$m=65536,t=3,p=4$6iGMQmx087kIJjiYEyej0Q$zt99kbLBskta2qZ/ESvUj7AMNpQBogp2+tk95Jso7tE	CUSTOMER	t	t	2026-10-31 04:14:56.748002+00	2026-10-31 04:14:56.748002+00
5aa3d456-9f57-44bb-b5f4-a6bc74747829	staff_87dc5697@example.com	Support Staff Member	$argon2id$v=19$m=65536,t=3,p=4$4ufU8Qtq1aY9p3HQXgyOGg$64qiX43+DM/B9vYfo3FkOV+tM6dSKAO/KKzHpyHDR9s	STAFF	t	t	2026-10-31 04:14:57.391976+00	2026-10-31 04:14:57.391976+00
66d3aecf-e430-45ec-a173-a50b9d8af0ea	cust_1da30322@example.com	Customer One	$argon2id$v=19$m=65536,t=3,p=4$MyYAWRFgcpiCoOvayXhstQ$1YLmjflM+fcDH67RceMdgsIeZk0nAwv7ygjB+HiTFPQ	CUSTOMER	f	t	2026-10-31 04:14:57.271035+00	2026-10-31 04:14:57.55105+00
8f41d28e-a0e1-4e20-a55e-4119ca48209a	rotation_6e3d8010@example.com	Rotation User	$argon2id$v=19$m=65536,t=3,p=4$euQWjNG/W+IModWJu8gMcQ$H2Z+TYXo/+wo8iHILGolyeu1zFboQ+vxRwFy3/c5dsE	CUSTOMER	t	t	2026-10-31 04:15:05.25356+00	2026-10-31 04:15:05.25356+00
75a26128-3f2e-489a-a766-30ea3e7197db	reset_712ffed8@example.com	Reset User	$argon2id$v=19$m=65536,t=3,p=4$3o1alfD9UQ2yzCbrIseXvQ$msUEz8KVzR0Lwo/x0ppJxf46o/FXSrGRBTFIo+2T9Eg	CUSTOMER	t	t	2026-10-31 04:15:15.254074+00	2026-10-31 04:15:15.254074+00
4d322516-9c79-4e12-a8ab-978e9d93b784	customer_bacd3c24@example.com	Test Customer	$argon2id$v=19$m=65536,t=3,p=4$bcwH/PzRpKqrAcWfpsUgWQ$NBmXd8RUH4O025jMztjqt9xekrSgD4t/aEmcQEX5kIE	CUSTOMER	t	t	2026-10-31 04:15:41.059033+00	2026-10-31 04:15:41.059033+00
e01c5123-e863-4c73-addf-fc8ccb55a8a0	dup_8ab07fe6@example.com	First User	$argon2id$v=19$m=65536,t=3,p=4$am/Ul3TpK0HO+4QOgCsdLA$8dKlreKjhR0/6x2Zt+qamlNXIrIp6aWR8rmc9o8NxOI	CUSTOMER	t	t	2026-10-31 04:15:41.192039+00	2026-10-31 04:15:41.192039+00
8441df5e-d166-45ec-8867-4eaeff3cbb11	login_user_ad8f418a@example.com	Login User	$argon2id$v=19$m=65536,t=3,p=4$5CpbPYro8LKbnFETyvQv1A$99wU6ODW+Ni8eA51DF8fVfK4OoT/AldOmgafeoDaQtc	CUSTOMER	t	t	2026-10-31 04:15:41.28279+00	2026-10-31 04:15:41.28279+00
f7e590af-5146-4d2f-bcc9-b032839d70da	rotation_5305b5f1@example.com	Rotation User	$argon2id$v=19$m=65536,t=3,p=4$Y7RnpacJjcEQ7dPoWswTTg$60MRFniqoHcDxnr8RtJc1rLB5eUwSVHMdqGVZWohr5E	CUSTOMER	t	t	2026-10-31 04:15:41.475872+00	2026-10-31 04:15:41.475872+00
f1606ee3-6693-4e3a-9e7a-9fc18d00a065	reset_4f6413b7@example.com	Reset User	$argon2id$v=19$m=65536,t=3,p=4$0lXMwkrFG0wvwPbXTI/5zQ$yQmbatD5Qgu/+xwX0BmR19nLqy1aO4RufdnOSqJ6B9w	CUSTOMER	t	t	2026-10-31 04:15:41.603106+00	2026-10-31 04:15:41.748475+00
5bc72d2e-c41b-4937-99d4-3830e341b00b	customer_ff3e3775@example.com	Test Customer	$argon2id$v=19$m=65536,t=3,p=4$Cz3bFJWxtIhLkzafl+rorA$xrclKV0Bz8VySVMfMRcKugj36M8x8MZNA3aP+PP9kDg	CUSTOMER	t	t	2026-10-31 04:15:47.7414+00	2026-10-31 04:15:47.7414+00
4be22406-b9c4-417e-bfb6-89fe16aa6a6f	dup_3629ad10@example.com	First User	$argon2id$v=19$m=65536,t=3,p=4$GEfjabAjw25JtpOY49wozw$IjDbwb7ZG9FVV2AyrK2n1k9/3tFsmS9tSpd0RdJL9KI	CUSTOMER	t	t	2026-10-31 04:15:47.832315+00	2026-10-31 04:15:47.832315+00
da3d6346-7764-44d5-9245-80549c1b2757	login_user_59673ca7@example.com	Login User	$argon2id$v=19$m=65536,t=3,p=4$JnrqhOhQA2wI97KtuhthuQ$/mJQW3ypWZsdYIGFJdBq2+6ULMv4zoiidqXuQUaN+as	CUSTOMER	t	t	2026-10-31 04:15:47.923767+00	2026-10-31 04:15:47.923767+00
508d414f-cd5b-47f4-85e9-59ee42f1b800	rotation_91e80c38@example.com	Rotation User	$argon2id$v=19$m=65536,t=3,p=4$21Owsq5dvvk0huhm3YBivQ$wAqDOr1Zx9scqbSWS+Fs/IU8PV65iYs8OzJ+q/b6aA8	CUSTOMER	t	t	2026-10-31 04:15:48.131822+00	2026-10-31 04:15:48.131822+00
aa322c84-c6ac-4251-8e52-4f77ec351b2c	reset_d9151576@example.com	Reset User	$argon2id$v=19$m=65536,t=3,p=4$tFEQmpBxMkD/AS70eP2PqQ$a6j7ORHs/N2ytf5stA26+5z9Cqi6c/ss5mnA9zfjK98	CUSTOMER	t	t	2026-10-31 04:15:48.261053+00	2026-10-31 04:15:48.410133+00
1b19476e-a38c-4a3c-94a9-44f5d229de92	staff_e6640988@example.com	Support Staff Member	$argon2id$v=19$m=65536,t=3,p=4$roCzvWY1Uh1lg3OVrtHQzQ$Yx9PGE+UQM/eCS4+JuEovCS7u+PIezUYxz1UyWeAjo0	STAFF	t	t	2026-10-31 04:15:48.948852+00	2026-10-31 04:15:48.948852+00
7c459673-c3dd-4a31-8aaf-aae44ae3aed2	cust_25450062@example.com	Customer One	$argon2id$v=19$m=65536,t=3,p=4$5+G7K2za6OpglMpHBdIx8w$Hbs5iXZNRCZdADxZlDJ3hM8avAPDj+i3QIauF9PxA8w	CUSTOMER	f	t	2026-10-31 04:15:48.831257+00	2026-10-31 04:15:49.109561+00
f8a76800-1d18-4ecc-8527-7b4f59687fa3	bala@gmail.com	bala	$argon2id$v=19$m=65536,t=3,p=4$rw6JK3YZ7aUh9rtAxMv5Lg$6IzaX8VBRML5rlb1DfEHe97MlqlG5UD3ulB1PX5untY	CUSTOMER	t	t	2026-10-31 04:37:24.58218+00	2026-10-31 04:37:24.58218+00
0ce2e170-1e3e-4de7-a2ac-dc825e758e34	customer_6ff4119b@example.com	Test Customer	$argon2id$v=19$m=65536,t=3,p=4$n8o9xW3H/dy+sXSsiFUetw$41paq4XUCmRxqoFFk/8dcKX3h8P1FOWbFIRzA7RpvcY	CUSTOMER	t	t	2026-10-31 05:11:18.164047+00	2026-10-31 05:11:18.164047+00
84826d40-07ee-4610-9be7-a79c044c44b3	dup_897a8d61@example.com	First User	$argon2id$v=19$m=65536,t=3,p=4$D8bp5PN1Nbq0q6ejZYNQzQ$EaCn+OdH7TetL0yWAVfYotG7HUpcZdNcnUXMQM3ZAX4	CUSTOMER	t	t	2026-10-31 05:11:18.292588+00	2026-10-31 05:11:18.292588+00
bb198713-2d29-417d-8ffc-c56958a55829	login_user_e2651688@example.com	Login User	$argon2id$v=19$m=65536,t=3,p=4$STYWCdL0vZ/yANPMf0Du9w$IIN0H/J0d3EXCuFMAAXCWQ9aUh6N0XnwT35nIgy6gY4	CUSTOMER	t	t	2026-10-31 05:11:18.390833+00	2026-10-31 05:11:18.390833+00
4edfd77a-b6fa-4f69-995e-06e0f4f58770	rotation_7c0bb09c@example.com	Rotation User	$argon2id$v=19$m=65536,t=3,p=4$SFFb0PC8gf5Tw3nZ6K6Urw$k53owWFCd03zxW5ibWmbv4lfytaHEJQZoDaBrRCoUzk	CUSTOMER	t	t	2026-10-31 05:11:18.599704+00	2026-10-31 05:11:18.599704+00
ea823d6a-8512-4342-8975-0f9a54160a14	reset_35077ca6@example.com	Reset User	$argon2id$v=19$m=65536,t=3,p=4$uIYowRrGLwu7L38p4Coh4g$pIIz1LmPJ/YYFYeEsEH8iTJME6VcpkmQZGZj9JKT4rY	CUSTOMER	t	t	2026-10-31 05:11:18.730343+00	2026-10-31 05:11:18.852716+00
82da7fb7-b8ce-4ee7-884d-200a4b3646df	multi_reset_958c3508@example.com	Multi Reset User	$argon2id$v=19$m=65536,t=3,p=4$IlWh7zRLvxJQQ/eoHPpEsQ$9/f+GAT3QAgylEATQI5lZCeP4B8ECaZthP+cH0MFbgs	CUSTOMER	t	t	2026-10-31 05:11:19.104331+00	2026-10-31 05:11:19.104331+00
bb612e5e-1fe9-4976-a447-d79a6b87f11e	logout_no_jwt_73289972@example.com	Logout User	$argon2id$v=19$m=65536,t=3,p=4$++inKP0baWiFzsIPSI02sQ$Yj2wfY+8s/25sgp+N24QUDtZm/8aMnPPL6n3JT5ZyqA	CUSTOMER	t	t	2026-10-31 05:11:19.450956+00	2026-10-31 05:11:19.450956+00
0422c9f3-3ebe-4ab1-a2c2-1cae4aa66b82	cust2_a9b085bf@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$jF7fkhIFF3Gh512LBSJSZw$SlMH/WHRm1MLuIqyhh5O56Eh6CL/8xqrG/SCgwkkPVM	CUSTOMER	t	t	2026-10-31 05:11:19.860308+00	2026-10-31 05:11:19.860308+00
e88974b4-122b-41f8-8b21-15e3247977af	staff_d3fd83b0@example.com	Support Staff Member	$argon2id$v=19$m=65536,t=3,p=4$Nd6MgcuX/U+zW1My30HqzA$s9Zq2hhB8yhp8RwDoPuO0t6J/gg+LUUzMXJRnO0Focs	STAFF	t	t	2026-10-31 05:11:19.998672+00	2026-10-31 05:11:19.998672+00
850ca8b4-8d10-4ecd-b372-def1c1923a17	cust1_99d88c2d@example.com	Customer One	$argon2id$v=19$m=65536,t=3,p=4$EtylhDkzJ0QnK2/NnzEo8A$iPotEDFBwBDyk2nGfZYXpzKJtYE/ti1HpB0zR9p/FO8	CUSTOMER	f	t	2026-10-31 05:11:19.782912+00	2026-10-31 05:11:20.221213+00
418eabf0-b1e9-4819-8d36-01633b5e2b34	customer_d28c2688@example.com	Test Customer	$argon2id$v=19$m=65536,t=3,p=4$FXMte+s6bjSRDhEtlCKN4A$ovL04Gn90eVcQVvzexYTOy+7Sv1XG2E145SKaL5B8oc	CUSTOMER	t	t	2026-10-31 05:11:50.56917+00	2026-10-31 05:11:50.56917+00
b90cf5af-bb7b-404a-ab1c-76e7ce6fce3c	dup_49d0cfa5@example.com	First User	$argon2id$v=19$m=65536,t=3,p=4$WxcFQiiX7uQa9ADAVdO9SA$zw4+H88iuLbCiDWpYXSxomBJdqB8r9HyOnmEZUzrLdM	CUSTOMER	t	t	2026-10-31 05:11:50.662995+00	2026-10-31 05:11:50.662995+00
6e771bcb-2e4c-4d0f-8bc9-dcf52646d9ac	login_user_744fa4eb@example.com	Login User	$argon2id$v=19$m=65536,t=3,p=4$OULezma9vBqkFkD++eprRQ$SJb4iVPGU9HGGKMJLXUbik1OTe6bXu9suw350mkxTtM	CUSTOMER	t	t	2026-10-31 05:11:50.761766+00	2026-10-31 05:11:50.761766+00
493d5223-982d-420a-b75f-03b1ff60757b	rotation_e1995080@example.com	Rotation User	$argon2id$v=19$m=65536,t=3,p=4$6H7YxNWpN3Q3dPkW1/RddQ$VD/UkmzTBhR+lcSDd6+jd3wcfTyBbBlPSDySqzWcExQ	CUSTOMER	t	t	2026-10-31 05:11:50.980356+00	2026-10-31 05:11:50.980356+00
8336509a-cf9b-4a96-a0b6-7bc3890a3f63	reset_eb58bd19@example.com	Reset User	$argon2id$v=19$m=65536,t=3,p=4$2OKGbhZErbjKxM05elxHwA$BBk+GB5tdTje6EsqbNWPbBJhrZlCXBkhQeSu8uYpuvo	CUSTOMER	t	t	2026-10-31 05:11:51.110789+00	2026-10-31 05:11:51.230311+00
d9538ec8-6c00-4ca4-bcf6-813e57938761	multi_reset_be0ee2da@example.com	Multi Reset User	$argon2id$v=19$m=65536,t=3,p=4$X5LJtsT2zSWlXFnPSIqc1A$paSaEH1rW8hOHivE3ClFiYV8UJqLNHblAYrzuybYB4Y	CUSTOMER	t	t	2026-10-31 05:11:51.449134+00	2026-10-31 05:11:51.449134+00
fb7dfeed-8809-4af1-b766-eeb8358e487a	logout_no_jwt_c5a249af@example.com	Logout User	$argon2id$v=19$m=65536,t=3,p=4$tLWm0bNCnsQF0goAsLpdCg$CkZieKsofEW1yhxM8PJB4jCLp1X64ESfvCViuysFJjw	CUSTOMER	t	t	2026-10-31 05:11:51.614475+00	2026-10-31 05:11:51.614475+00
bb2b4c98-c7eb-4c8d-a57e-4712599f3c60	cust2_972b6d50@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$088o42gmXpERbCxBKGEeuQ$JGQml5vZpCpLY0R4Mpemfxo9EdJ4ErOmtLEcXT/fRus	CUSTOMER	t	t	2026-10-31 05:11:52.017647+00	2026-10-31 05:11:52.017647+00
d98e5248-96d2-4067-a0dd-aa3f7d8d6187	staff_d6d0a59b@example.com	Support Staff Member	$argon2id$v=19$m=65536,t=3,p=4$NfVC2WhiXye8JKKeqHZJKQ$PtBel0gahdMPeN+aURs+1sQh9NvVDHwBhkZdugdw3Q0	STAFF	t	t	2026-10-31 05:11:52.163887+00	2026-10-31 05:11:52.163887+00
73aa11e6-38c1-4540-8082-fb20b88fb3ef	cust1_eb8c8416@example.com	Customer One	$argon2id$v=19$m=65536,t=3,p=4$YsVZIDipAiivKjTSAbHZBQ$tr7PRqtxBUoYoHJiiuT6zASJ4ILWkNV5kRJJgrQ9r5w	CUSTOMER	f	t	2026-10-31 05:11:51.946416+00	2026-10-31 05:11:52.383536+00
58a3d472-5559-4c23-8bb0-42ddd385362b	customer_c39659ae@example.com	Test Customer	$argon2id$v=19$m=65536,t=3,p=4$hx4dXWvvdtayWogOd6xDVg$azgqD4+76O9YWVEWke4WVm/QsOhLtjswIunLB5PkLsc	CUSTOMER	t	t	2026-10-31 05:12:56.158651+00	2026-10-31 05:12:56.158651+00
26fe5070-9272-4fa1-a1ff-afe0a7cc4df4	dup_110abcfe@example.com	First User	$argon2id$v=19$m=65536,t=3,p=4$CjmlbMFlCFdLAidX/tQEPQ$UJ98ROiyAyuz6Y8vHOMi/t3M6dURfIt4e7e1BcrebEI	CUSTOMER	t	t	2026-10-31 05:12:56.254212+00	2026-10-31 05:12:56.254212+00
e0d35775-e51a-4eb1-aef9-e87b0f8ddb5b	login_user_7dc552a3@example.com	Login User	$argon2id$v=19$m=65536,t=3,p=4$1pC4QDKv0MQovPLxsZcSLQ$/fP775Kr8g2ZLOlv1/SiJ27tvSCSzsuv4bOXSQCTatk	CUSTOMER	t	t	2026-10-31 05:12:56.350348+00	2026-10-31 05:12:56.350348+00
cc84eb5e-99b4-4870-8de1-0b4289ec8987	rotation_d01f06af@example.com	Rotation User	$argon2id$v=19$m=65536,t=3,p=4$NtvEfQGdbHLEXbtkSJLp2A$SZ85QPKKLL8RxKJmPxHYHnIjLL+aHRd7uCpoyHyp3r0	CUSTOMER	t	t	2026-10-31 05:12:56.547239+00	2026-10-31 05:12:56.547239+00
d119b3bf-3c56-42b9-98f5-79275414ee22	reset_ebeeecd0@example.com	Reset User	$argon2id$v=19$m=65536,t=3,p=4$74y+9sDMZZ6eNoij25tyuQ$fWEt4EHgk8FqbT3NfLe8RxQefDBo80NbpIVgpbHi8r4	CUSTOMER	t	t	2026-10-31 05:12:56.722808+00	2026-10-31 05:12:56.872818+00
12a618c3-a8ef-459e-9c5c-977db2a3608a	multi_reset_e96e56c2@example.com	Multi Reset User	$argon2id$v=19$m=65536,t=3,p=4$Sa0lag467P1onv4AhqndNg$fW0HVLNkl/DN+uvffY1iWeSxwpk+yxTCmvwU5PWLU+s	CUSTOMER	t	t	2026-10-31 05:12:57.071808+00	2026-10-31 05:12:57.071808+00
2010d324-f276-46dd-8b17-7c86b2b0332c	logout_no_jwt_56704ccd@example.com	Logout User	$argon2id$v=19$m=65536,t=3,p=4$tPHdZJA7PS6StNPWgb1FeA$f4vJ/AlE+BmqfbH2b75uLS3vQUu6L+Qpvui402PnD48	CUSTOMER	t	t	2026-10-31 05:12:57.240812+00	2026-10-31 05:12:57.240812+00
4a9bea9a-27b0-4f42-86e3-635c4e82a73d	cust2_e8475fde@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$J167vMh/G3DE51KS+hBI5w$rgQ5yDHUj66FCMmIHMq3CAUfdrU0c/bw7/p7FgXKE1w	CUSTOMER	t	t	2026-10-31 05:12:57.648762+00	2026-10-31 05:12:57.648762+00
478c30bc-05ff-499e-9589-44fd39434fef	staff_0fd5a7cd@example.com	Support Staff Member	$argon2id$v=19$m=65536,t=3,p=4$bsvD0XKTJY0NrcGfavbThA$etY+CSzm1PDkqrNs0H2fCpyFkvW6oHUA9CAMrWt6Mr8	STAFF	t	t	2026-10-31 05:12:57.781238+00	2026-10-31 05:12:57.781238+00
d86b78e7-7242-47ab-bdc9-8983b447ffe8	cust1_30ad72fc@example.com	Customer One	$argon2id$v=19$m=65536,t=3,p=4$YT5f04n9ZwVQ8yPiFhZpvw$cgsv/7Bx7JqMGusUoJdhuiXMjgQ9b697MdoMpCIBaF4	CUSTOMER	f	t	2026-10-31 05:12:57.575305+00	2026-10-31 05:12:58.003414+00
80e3b0af-deac-4692-9dd5-10bbbb4b5858	customer_b9a6810c@example.com	Test Customer	$argon2id$v=19$m=65536,t=3,p=4$iF6chOBFkR9hZwqr/6LEbQ$8yWXZWiss3RbE2it5b/oaM3F2h0hp8hseu+cqih5I2Y	CUSTOMER	t	t	2026-10-31 05:46:03.767289+00	2026-10-31 05:46:03.767289+00
c78e4e78-d91c-4b9e-aa5b-8d6502c5d6fa	dup_f606dcae@example.com	First User	$argon2id$v=19$m=65536,t=3,p=4$+LRR7Qak3mql5hLpH3p/xw$6dMDSkH71yLC84CHCwSvC8FP61Zyg7joIjZ8i5aFn2M	CUSTOMER	t	t	2026-10-31 05:46:03.915932+00	2026-10-31 05:46:03.915932+00
957ae5b2-8621-43a2-9515-2b43afc0cbd2	login_user_e0e50205@example.com	Login User	$argon2id$v=19$m=65536,t=3,p=4$xgqPSokrmb78aVGcOlGMPQ$IdOe4HOKPgX0kqlKsSzeas1kZG45WcTVhSHGV07vgiI	CUSTOMER	t	t	2026-10-31 05:46:04.010042+00	2026-10-31 05:46:04.010042+00
32183dff-fa8d-462b-8def-bebe75c72f2d	rotation_8286539c@example.com	Rotation User	$argon2id$v=19$m=65536,t=3,p=4$kDFZHIQ0rYvq4/DZ8d3AVw$ECbpg0xoyKViD1p578cmdt2hJfLvcVTAsOPc4RRW/7o	CUSTOMER	t	t	2026-10-31 05:46:04.210173+00	2026-10-31 05:46:04.210173+00
b0ffc2ce-dc12-4fad-b3d6-eca9b62ca5ef	reset_58609b88@example.com	Reset User	$argon2id$v=19$m=65536,t=3,p=4$w4nyy++ByPq5ilczS2M0FA$iQes4ByFmbVr+7RlVDjMISIHne/+KNh3bcz4nEfKw0s	CUSTOMER	t	t	2026-10-31 05:46:04.37052+00	2026-10-31 05:46:04.505147+00
dbce35f4-40f9-4a80-bf40-937820427ad4	multi_reset_34068c2b@example.com	Multi Reset User	$argon2id$v=19$m=65536,t=3,p=4$H4lJQooOt+7ti+t8p9yOfA$O94DwkliGKwFImoM441dffrr/LqQBo7GZ7Zbx6btIu8	CUSTOMER	t	t	2026-10-31 05:46:04.732703+00	2026-10-31 05:46:04.732703+00
14f8e0f5-981e-458c-977d-9ebcdbfad1cd	logout_no_jwt_a6410786@example.com	Logout User	$argon2id$v=19$m=65536,t=3,p=4$1VaSgicJbr9Wy8Un4zz5mQ$pj+1sxk4hPpHMD4LHho64rJPSFht0cq6BlmfsYCOpMo	CUSTOMER	t	t	2026-10-31 05:46:04.910883+00	2026-10-31 05:46:04.910883+00
26fa02bf-d700-49fb-9933-597991093516	cust2_1328f058@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$RHLq7aT+leAXBdVLMBD5/w$evPNoTzFB17/7foooPXH3OEK74bbL2ZAxqOJr4op5qA	CUSTOMER	t	t	2026-10-31 05:46:05.326966+00	2026-10-31 05:46:05.326966+00
229153d3-a459-4880-8cb2-2215fe1f792f	staff_a3dfde5e@example.com	Support Staff Member	$argon2id$v=19$m=65536,t=3,p=4$FgEOdrEdVysCz8PZIHoaAA$EChcmDvQb6lvhkMadNur7wm85O30238YteNxd1EFhNU	STAFF	t	t	2026-10-31 05:46:05.47229+00	2026-10-31 05:46:05.47229+00
8ac7ab9e-54b9-4cd2-b2a8-332bcef9c7c3	cust1_ee070961@example.com	Customer One	$argon2id$v=19$m=65536,t=3,p=4$pZe/zxdGuef/LHe+oMUpwg$lmBjLMSbUyY4EBJ0YzSNjmpWKk/DbGI0hI1HXyzmchM	CUSTOMER	f	t	2026-10-31 05:46:05.249438+00	2026-10-31 05:46:05.702733+00
b2370d12-52df-42d4-b383-0f2c4061c9d9	customer_a645fedd@example.com	Test Customer	$argon2id$v=19$m=65536,t=3,p=4$NWCQR59eUt5WPqmPJmF3kQ$J8G/x8BJe8P0FPu84gAeUM+kn8Gcl3xXKDp31yxfd1o	CUSTOMER	t	t	2026-10-31 05:52:55.175523+00	2026-10-31 05:52:55.175523+00
8b079a79-938b-4e39-8d8c-955005e0f0fb	dup_4745a18e@example.com	First User	$argon2id$v=19$m=65536,t=3,p=4$FgRUfctJ4nk6d6Vs3PYbjg$W3YqDpfOuYofS0+O/mzW0fYbxIKeOlaHjnf16kpobW4	CUSTOMER	t	t	2026-10-31 05:52:55.277896+00	2026-10-31 05:52:55.277896+00
6113e0cc-f1e8-4330-acc4-4e4d35544e2d	login_user_e982a35c@example.com	Login User	$argon2id$v=19$m=65536,t=3,p=4$NzlWu9nKR2v6LE+ieF/OSQ$S7OGa6sHg/Ut7rDmkQuI4jagez4YX9aQ3Tat3v2ecKQ	CUSTOMER	t	t	2026-10-31 05:52:55.377852+00	2026-10-31 05:52:55.377852+00
55f4d195-e9fb-48b4-9902-ea14e0eb9aa4	rotation_9650da71@example.com	Rotation User	$argon2id$v=19$m=65536,t=3,p=4$mki/pDZMIh6nZOEepLcZRA$CYWH62Q7nQ8Y+Zy5D1mo8YmkHfZgRs9EG25Z5wl2bRQ	CUSTOMER	t	t	2026-10-31 05:52:55.619036+00	2026-10-31 05:52:55.619036+00
5e5e63e5-354e-42be-9956-4f3237c85440	reset_54fd6b2c@example.com	Reset User	$argon2id$v=19$m=65536,t=3,p=4$OaWkaRrz/kdv86VOl2LP7A$IbwqvCHiF8d/MloPIuP5uVj7pPUUnsAR1RmEozzBrBo	CUSTOMER	t	t	2026-10-31 05:52:55.765881+00	2026-10-31 05:52:55.890849+00
2a7a573c-ee88-475c-8c7e-776a32e72b4d	multi_reset_f266ec52@example.com	Multi Reset User	$argon2id$v=19$m=65536,t=3,p=4$wwZz8390oiMqFJMEm51rXQ$nA2c/C7FRCAlAVaTHdDBmyZ/LogBCEsjgBNlALjRhmA	CUSTOMER	t	t	2026-10-31 05:52:56.11085+00	2026-10-31 05:52:56.11085+00
2a114299-eb44-4513-8e2a-b9be6095f425	logout_no_jwt_e520c1de@example.com	Logout User	$argon2id$v=19$m=65536,t=3,p=4$2CPX7/2H/XrcDLTUC9aFaQ$epinwySCPyqMahwXwEyoIH3wD5t5Yqj49E0+GZfMWy0	CUSTOMER	t	t	2026-10-31 05:52:56.275101+00	2026-10-31 05:52:56.275101+00
196da70a-1ea1-48ba-bb07-bff22caa8a5b	cust2_ffb3116a@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$BTlkhC+fESq1QwFr0L87QQ$pZsAAL3lU0PIvE+uwYd/O0mYSq0APdUyffk+w/l4/VQ	CUSTOMER	t	t	2026-10-31 05:52:56.683387+00	2026-10-31 05:52:56.683387+00
94505853-0e43-42d8-9b0b-d84ca7865932	staff_f280c9c3@example.com	Support Staff Member	$argon2id$v=19$m=65536,t=3,p=4$UZkF6VVGvHJas/hjad5GLw$zwhancwoyt2i4dwiCLDVqAJYGb/SwdjdMDuKKg5kY/w	STAFF	t	t	2026-10-31 05:52:56.83058+00	2026-10-31 05:52:56.83058+00
d226394d-e959-42a2-8fc6-70a387db8078	cust1_84368aeb@example.com	Customer One	$argon2id$v=19$m=65536,t=3,p=4$gz8S8wkxUGuHqDIbtRGQtQ$qxGOgZxeSUizCHZdd1N1WdwKggUybd5N04NYIgmmces	CUSTOMER	f	t	2026-10-31 05:52:56.604813+00	2026-10-31 05:52:57.060594+00
554c7280-7d85-47dd-8078-fc3476659719	customer_1ee5dc71@example.com	Test Customer	$argon2id$v=19$m=65536,t=3,p=4$/cuf2RpvM+JQ6ABdxRNHnQ$cYUJLOE/2cyuzMl+mY0Zye2oi/2uDN2PSS8iTjKGVbw	CUSTOMER	t	t	2026-10-31 05:59:24.960117+00	2026-10-31 05:59:24.960117+00
63ef12fb-5488-4e39-baa2-4c876441802c	dup_3f4cf89a@example.com	First User	$argon2id$v=19$m=65536,t=3,p=4$x+gjvvG3Mfpi3JtmRKpfQA$kPzE9U7qtIBtr1+elaYSzW628K7EuUgkZVU9YabU/8E	CUSTOMER	t	t	2026-10-31 05:59:25.101046+00	2026-10-31 05:59:25.101046+00
e7b763d5-0438-4f7b-8241-e50c55546570	login_user_cbfe3236@example.com	Login User	$argon2id$v=19$m=65536,t=3,p=4$VHOiNPNSdbk/i15e4dVhKQ$QwJUDAsn7nGrBD+iMOM1IrsnsVB0vlqJvowI2pGO2hc	CUSTOMER	t	t	2026-10-31 05:59:25.249862+00	2026-10-31 05:59:25.249862+00
be4ff5c5-16fb-4e4c-9fdb-db6c443464c9	rotation_01896082@example.com	Rotation User	$argon2id$v=19$m=65536,t=3,p=4$chgPQJL2NsnmLqE/Z4d3bg$ylZ63uV/AqOP+gskmlTV9UYMzUhWfYBYBeFLLyiq8tE	CUSTOMER	t	t	2026-10-31 05:59:25.51118+00	2026-10-31 05:59:25.51118+00
b144c086-d788-4342-8e6b-3dfee3355527	reset_b3ef8251@example.com	Reset User	$argon2id$v=19$m=65536,t=3,p=4$uUMOvO3mlkQuaPNJaZsmxg$y+NZYFy/f7tBsBGp95YNwoEfm96sF/MRWuqgLbhWcQs	CUSTOMER	t	t	2026-10-31 05:59:25.742714+00	2026-10-31 05:59:25.919531+00
156085e9-785e-4e4b-8e1e-b6109bbc1876	multi_reset_4e2ff372@example.com	Multi Reset User	$argon2id$v=19$m=65536,t=3,p=4$eUEeJpfXsXkHljJp6qtAQw$zi7hrgrIu6OzVAP/Vn2d6JtHmvYcj0mMCA8dCCttD1k	CUSTOMER	t	t	2026-10-31 05:59:26.140976+00	2026-10-31 05:59:26.140976+00
2f082914-d1df-42d4-8237-de9abce8e0bd	logout_no_jwt_6c05fbe6@example.com	Logout User	$argon2id$v=19$m=65536,t=3,p=4$Z6lr5CwXVhi/rtK6kiI1Ww$qBqmojcMWVzUnNbDj5fJU8rPPG1YbG1vbSelVg6iRzc	CUSTOMER	t	t	2026-10-31 05:59:26.550904+00	2026-10-31 05:59:26.550904+00
faa7c350-693c-4f32-a946-cf94bb2338b8	staff_67b452e4@example.com	Test Staff	$argon2id$v=19$m=65536,t=3,p=4$BTlsKR+NAjTD6mdGbxBhtQ$7qjFeE/hKIXq/0DHWsTBuibXkBba+7wAmW1phoFF+BE	STAFF	t	t	2026-10-31 05:59:26.830226+00	2026-10-31 05:59:26.830226+00
f7dde876-4c5d-41bd-83c7-a550a7f01087	cust_3afb0aa8@example.com	Test Cust	$argon2id$v=19$m=65536,t=3,p=4$Bt4Ml63bINM6Saw+lceqTQ$zzZZ7pg+JGlOvPNbnHGMolf3HuVK7sUJmtOGCXIDDJQ	CUSTOMER	t	t	2026-10-31 05:59:26.980888+00	2026-10-31 05:59:26.980888+00
5c14ac70-d6d0-4bbc-9526-ea6177d39455	staff_3a46f6c8@example.com	Test Staff	$argon2id$v=19$m=65536,t=3,p=4$IC7dJVhIIvp4NwQemf131A$S/f373j/GjFr2u6pkuht5f5/Vd+oIHaxrXHjTPKqFO8	STAFF	t	t	2026-10-31 05:59:27.35196+00	2026-10-31 05:59:27.35196+00
9baaaaf9-3e73-45d1-83aa-47e512236d5c	cust_f5cad3b7@example.com	Test Cust	$argon2id$v=19$m=65536,t=3,p=4$9TScpmZFuUQdrawDcLbssg$QLzm1YLq+dmJJdmoRK4FYIhRVMIUNxjME/82845kZfg	CUSTOMER	t	t	2026-10-31 05:59:27.490971+00	2026-10-31 05:59:27.490971+00
9eda81c6-d4ec-4b2e-9ba2-8ff6d92a4479	staff_fe3bccfa@example.com	Test Staff	$argon2id$v=19$m=65536,t=3,p=4$avL6Q527ScEoStI/bT0dbQ$pbkgplf/BbnqUgLLpSusw9QcVrjoUTbfzMZN7dBvZbo	STAFF	t	t	2026-10-31 05:59:27.733305+00	2026-10-31 05:59:27.733305+00
6f23938c-cddc-4a28-8f42-c0cb597748e0	cust_3ade737f@example.com	Test Cust	$argon2id$v=19$m=65536,t=3,p=4$FtGh4hC5fWWRDd1d+DnpJg$e88sbt80EPEEOdZWh+OfATewcgFIYhiWPUYpQd/on7k	CUSTOMER	t	t	2026-10-31 05:59:27.859586+00	2026-10-31 05:59:27.859586+00
fbc2d60f-635f-4ccf-bd0b-d5af2b51a2fb	staff_fb8f1fc9@example.com	Test Staff	$argon2id$v=19$m=65536,t=3,p=4$DwlppE7Ehu6a+fBulVo2XA$5JotTG55IdTVAoYe5DQw5JCYRNzG9a3u4RHU0iFPFV4	STAFF	t	t	2026-10-31 05:59:28.109749+00	2026-10-31 05:59:28.109749+00
270816b6-4630-4347-ae89-93ea0cda1589	staff_adfb1a40@example.com	Test Staff	$argon2id$v=19$m=65536,t=3,p=4$EkMgjSHh3djT0KFuTSE3og$yuWl5/p1REUSJx9Zgg6VEUubDXx+miP2CCcC4CwzRi0	STAFF	t	t	2026-10-31 05:59:28.332504+00	2026-10-31 05:59:28.332504+00
1acab13b-f7e8-4a35-b7fb-3aa9ab2e2c61	staff_fe873303@example.com	Test Staff	$argon2id$v=19$m=65536,t=3,p=4$kUlBA38uaz2kWN7BW5jBbA$wlEkPkXyIrIIghWSghISPv/oNEho/Dz9Yi7B3wWWPAk	STAFF	t	t	2026-10-31 05:59:28.556004+00	2026-10-31 05:59:28.556004+00
6fdbe691-57bf-4f06-a74e-c36de5cd1ae3	cust2_26a1b187@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$cscR4tTRfldRdWZFknuYLw$piPFfN8J9V7KxSelraKalZHm+fVA8MUfdl2mpFORfT8	CUSTOMER	t	t	2026-10-31 05:59:29.001919+00	2026-10-31 05:59:29.001919+00
b4d76ced-14b7-45da-a840-51a3352235f9	staff_f99a162f@example.com	Support Staff Member	$argon2id$v=19$m=65536,t=3,p=4$W8Pv2A3qZmr0IYGdpkmXUg$nopJcDxLar9CHpRxtfRVNmN1++ZJqHrqcdNEBzm8rP8	STAFF	t	t	2026-10-31 05:59:29.218071+00	2026-10-31 05:59:29.218071+00
14f0ac70-8a59-4176-b597-f585bed001fc	cust1_035c523d@example.com	Customer One	$argon2id$v=19$m=65536,t=3,p=4$YrUyEXb73xRwVbnUmnx6QA$XNhu1WIYfgDaK5BgNWHcI3is8ZGt2shScHAZmamrEf4	CUSTOMER	f	t	2026-10-31 05:59:28.905451+00	2026-10-31 05:59:29.485183+00
c32a5212-b7f3-47b9-92fe-96e24c186d3a	customer_0267bc46@example.com	Test Customer	$argon2id$v=19$m=65536,t=3,p=4$v4wVHqSCH/iYh7pAw8XflA$yVk3BQArRriPe4dXkMzJv/C8CWe71nDtCYP7ttHFZKU	CUSTOMER	t	t	2026-10-31 06:13:49.510019+00	2026-10-31 06:13:49.510019+00
d2702a1d-a785-409d-8cab-f3fca8383db5	dup_4dc08be5@example.com	First User	$argon2id$v=19$m=65536,t=3,p=4$yZ/tsQ4EozRwe8hbEBzuKw$MPDoD/nfZsCtTvad7fs/a+CZzltWpRXfJvIeYFj21fA	CUSTOMER	t	t	2026-10-31 06:13:49.709246+00	2026-10-31 06:13:49.709246+00
6eaadb1f-a86c-4a96-9f46-5be20c86d832	login_user_a133e419@example.com	Login User	$argon2id$v=19$m=65536,t=3,p=4$rdKL+nkERUhvAngCfPpDTg$RT5JzFv7LgG9hQ2VUl1OEHUOoIt5+Mm4Jd+GNXPXPks	CUSTOMER	t	t	2026-10-31 06:13:49.810271+00	2026-10-31 06:13:49.810271+00
273c9f88-fd9f-41a8-ad7f-fda6f3e69768	rotation_c395c625@example.com	Rotation User	$argon2id$v=19$m=65536,t=3,p=4$DdF+j7MZYbDI4+gOmQQfrg$X+cThtbCgOYiBT8WsYrKjjDCGrdwm6C15EOQngpA6jk	CUSTOMER	t	t	2026-10-31 06:13:50.042695+00	2026-10-31 06:13:50.042695+00
b23e2baa-5c89-4c93-b7a7-129f2c72d695	reset_bd7038dd@example.com	Reset User	$argon2id$v=19$m=65536,t=3,p=4$Y4eaiMcky8b5HpvmHbEuMw$z/55dlRf+QkJuP8e71St+gRvMJg05lLxw3bMm1VWiKY	CUSTOMER	t	t	2026-10-31 06:13:50.189973+00	2026-10-31 06:13:50.314685+00
363682ab-f901-4a29-a3aa-ba02862dffe8	multi_reset_79dc88a0@example.com	Multi Reset User	$argon2id$v=19$m=65536,t=3,p=4$0qhmrmsaWFkQ0AxNZJ7u/Q$6dX+LNqge/pD9ofxZ00edtwMJq2TVeStzW0QelJcEzA	CUSTOMER	t	t	2026-10-31 06:13:50.526877+00	2026-10-31 06:13:50.526877+00
cc2d41cf-22a5-4018-b6a0-a26f4f36f26e	logout_no_jwt_76d82c97@example.com	Logout User	$argon2id$v=19$m=65536,t=3,p=4$Y813Nk+Zd3TKdzUliXRuOw$2WWnb2UcwP3kCbuZUl0spezDsDA1AbtBgvJlyqz2Gqo	CUSTOMER	t	t	2026-10-31 06:13:50.705132+00	2026-10-31 06:13:50.705132+00
ab9eb3ad-9572-473b-87e5-ecfb47c8c965	cust2_371d946d@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$n/sG03lGFjS68lFYwOb+iw$lzCJKP+jHyt/GDKZAT5opK4CknQq869PwAZbLpuNZ6Q	CUSTOMER	t	t	2026-10-31 06:13:52.647464+00	2026-10-31 06:13:52.647464+00
8ec9343a-c648-44c8-970a-e80a8b737f13	staff_2ae8d1b8@example.com	Support Staff Member	$argon2id$v=19$m=65536,t=3,p=4$NBsKJAsfX2D5ltKN+DSrCQ$/3/dovOoluU1leEAF7sNklAyKSnneY2VZTa1j/mJFaI	STAFF	t	t	2026-10-31 06:13:52.791714+00	2026-10-31 06:13:52.791714+00
a3acd349-ecfe-43b2-b0c5-0b32d9b9ffaf	cust1_82238fba@example.com	Customer One	$argon2id$v=19$m=65536,t=3,p=4$+GDRnmceWGNLibzEk7wdiw$HtzqjYdaLfgzvmebnuOtUf39jlyZXQTP+/9KBfHnWQo	CUSTOMER	f	t	2026-10-31 06:13:52.563498+00	2026-10-31 06:13:53.019633+00
758cbb6e-1315-4950-951a-1f33572219e7	customer_453a387a@example.com	Test Customer	$argon2id$v=19$m=65536,t=3,p=4$QT3XrnqEmn9QAXiDBkHFFQ$EvTsSno8y1g8bli3a7of5yVzAB1un8VbzBvPuWRMVHU	CUSTOMER	t	t	2026-10-31 06:26:01.187694+00	2026-10-31 06:26:01.187694+00
33690c3d-86a0-4aba-abf2-1fca9b4cbe33	dup_8fa111d9@example.com	First User	$argon2id$v=19$m=65536,t=3,p=4$gbiCiGumYrbZZa4YODRqpQ$scwjY3K529qlV/T9ATCRgjRuFljWXc1Ib33paXzWXks	CUSTOMER	t	t	2026-10-31 06:26:01.338979+00	2026-10-31 06:26:01.338979+00
c05057aa-da45-490a-b1ea-f30a2d1379cf	login_user_324c57a4@example.com	Login User	$argon2id$v=19$m=65536,t=3,p=4$maxE83cWHjjjS3pwbkF4iQ$84TBvxeSPLAmR7YZemdb6aNxkc9SH1u5BKX+fmAfUA0	CUSTOMER	t	t	2026-10-31 06:26:01.431994+00	2026-10-31 06:26:01.431994+00
e0236433-07f7-49d1-a82f-7d0f89d8c405	rotation_fea2b7e4@example.com	Rotation User	$argon2id$v=19$m=65536,t=3,p=4$k8rCJqQD/87SIPvPDAUvsw$XJx3LTMdd0wyYkuL9MvCfXlkhHObwL16s9HdV0REbDw	CUSTOMER	t	t	2026-10-31 06:26:01.638016+00	2026-10-31 06:26:01.638016+00
537a0cb3-7755-40b3-b86c-fbb8b65dc2a8	reset_787135c5@example.com	Reset User	$argon2id$v=19$m=65536,t=3,p=4$twTvDxvCWWvcUre8DPekLg$9Gs0GghREuBGZHg/G3LzGgf26Tkr5qwYeBKDY+G9emk	CUSTOMER	t	t	2026-10-31 06:26:01.768606+00	2026-10-31 06:26:01.887263+00
0e6486aa-8925-457f-b2a3-a8e65f6daf02	multi_reset_2e398a35@example.com	Multi Reset User	$argon2id$v=19$m=65536,t=3,p=4$x1Ox6Crl9tCxVYdpbAFczQ$YJ8Dg716puiv+dg6JdWtu94XnynYwpEtq/csQt1fGYA	CUSTOMER	t	t	2026-10-31 06:26:02.088925+00	2026-10-31 06:26:02.088925+00
83f844e2-9feb-4657-81e7-4bd8b52e65a4	logout_no_jwt_18f47f3c@example.com	Logout User	$argon2id$v=19$m=65536,t=3,p=4$Oip68m17QeFkgaPhPnXzZA$/Yb31FGF7qu5g88BzhybbL7wU42/QAoPBnkFAvpzEwk	CUSTOMER	t	t	2026-10-31 06:26:02.262328+00	2026-10-31 06:26:02.262328+00
b82acb67-c9ec-4162-96b0-0123c438f125	cust2_f6f25478@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$61gvwnuqxTCdPNuna3p75A$ELJePyuEKpnUZGL4KXjiYi/22hrUckNgwHBnmq9lNP4	CUSTOMER	t	t	2026-10-31 06:26:04.177992+00	2026-10-31 06:26:04.177992+00
988dcc1f-2a72-452d-8edc-e69b41088cb7	staff_fda470b0@example.com	Support Staff Member	$argon2id$v=19$m=65536,t=3,p=4$Ht1/JIUK8JgHVRS0hvHy2Q$LX11A3z76kxki/OKm1fgX5wKPYq0LIPDGflcWLRx1oo	STAFF	t	t	2026-10-31 06:26:04.320067+00	2026-10-31 06:26:04.320067+00
b259462e-0d8f-4f33-8f56-bb56201b88ae	cust1_d1067a64@example.com	Customer One	$argon2id$v=19$m=65536,t=3,p=4$pE3TNy27yz/y0KlwOQ/gLQ$dF6snJchKjVNFjbv65vML+DDGDDbjsivpLJZ3Kvzxlk	CUSTOMER	f	t	2026-10-31 06:26:04.102479+00	2026-10-31 06:26:04.544323+00
8cefc72d-4b6b-460e-8272-580cc96d8fa4	customer_34f9a0e6@example.com	Test Customer	$argon2id$v=19$m=65536,t=3,p=4$FmhV/tMpAuzVN098PmNDfQ$U+PpOYRlS2SvwAP4N7RioP3m7kKdyDAmUaPne+Op4xg	CUSTOMER	t	t	2026-10-31 06:56:44.904109+00	2026-10-31 06:56:44.904109+00
f91d5aaf-69ff-4084-a36c-0fae96432e54	dup_1c6cdd4a@example.com	First User	$argon2id$v=19$m=65536,t=3,p=4$kBEAqiazzKei4nTK8J7XzA$aA8OnCV7+g0ATNatFW41B0Rf8a4WFnfMvKmxbxa3bL4	CUSTOMER	t	t	2026-10-31 06:56:45.051525+00	2026-10-31 06:56:45.051525+00
6f42db5f-3763-4a9c-a203-4d0c3cf09e17	login_user_d2c49193@example.com	Login User	$argon2id$v=19$m=65536,t=3,p=4$DGw5lCZk6KGn7sUPQqWI7A$rqFxW85TxKjHqOcQyvXq1TI6NJ+hrQu9i+GKXOEGd9s	CUSTOMER	t	t	2026-10-31 06:56:45.146353+00	2026-10-31 06:56:45.146353+00
1ba8e121-7af8-4e63-9dc2-4e8bfb005045	rotation_4c4d4339@example.com	Rotation User	$argon2id$v=19$m=65536,t=3,p=4$gOJic87/X8VQl0Zr7Ewoqg$H6gdpoWrtr0U8TAsB3K9uV53iA8IyUGFBnvczl1eamk	CUSTOMER	t	t	2026-10-31 06:56:45.391578+00	2026-10-31 06:56:45.391578+00
7350b76c-28c0-4b09-98e2-6eca12318089	reset_8a9ee8cc@example.com	Reset User	$argon2id$v=19$m=65536,t=3,p=4$YtR+g85ukNCoJlNv8t95qA$XUu/0+rrTKCUDhpXbWZIB6jGl8G90Rv5IlsNCOeSxwM	CUSTOMER	t	t	2026-10-31 06:56:45.534526+00	2026-10-31 06:56:45.666481+00
8917a4d5-0384-45b4-9836-1bdecdf360ca	multi_reset_fdbea0df@example.com	Multi Reset User	$argon2id$v=19$m=65536,t=3,p=4$2Yu3ZpLlN6GLJHAoYb8W+g$yuEjlSWTLLCZ4xvo2ez7ZnsW5NAQEP8N4Qx1FgsweN4	CUSTOMER	t	t	2026-10-31 06:56:45.910027+00	2026-10-31 06:56:45.910027+00
bfef7ec7-8624-4555-9e1e-8c418e6f2f61	logout_no_jwt_1c66e050@example.com	Logout User	$argon2id$v=19$m=65536,t=3,p=4$3MxPCIiUEo+dWx9Whf1qNw$zLQjAYhsriHSTGUKt+BgPrfpwAxEvrBDLr2nVKOB+es	CUSTOMER	t	t	2026-10-31 06:56:46.104617+00	2026-10-31 06:56:46.104617+00
03ab9f1d-1184-44f8-8487-d37950fff752	cust2_3283f97a@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$fGWGQlvEEvViOcnszcZcSA$EuzVxkKzNS2CXP8xIOyxm9O6duP5zQ8pl/JjQnJjy0k	CUSTOMER	t	t	2026-10-31 06:56:48.221244+00	2026-10-31 06:56:48.221244+00
e3a621ee-c790-4d80-9300-bcb723ea2b6a	staff_859e83f3@example.com	Support Staff Member	$argon2id$v=19$m=65536,t=3,p=4$tJhZLgdpLtO/2CXcBFrn/w$/6HDE3fDIQ3Y9h0IepWuMZqWDFuiYw0BGBPqiFqSP5w	STAFF	t	t	2026-10-31 06:56:48.368434+00	2026-10-31 06:56:48.368434+00
12fcf2a8-0bcd-418f-b045-b86a3e365b43	cust1_f1b6ca98@example.com	Customer One	$argon2id$v=19$m=65536,t=3,p=4$Yj3R0vBRIQAU7V6/PeW8LA$tZ4ATv+ghcM4YcdgzvsZHaId7J2ttUreRQ27uM0wtik	CUSTOMER	f	t	2026-10-31 06:56:48.140734+00	2026-10-31 06:56:48.604585+00
a9dbd524-4906-43f3-9565-1a1dc3e68164	customer_9082194f@example.com	Test Customer	$argon2id$v=19$m=65536,t=3,p=4$3A/bxsjfCkdwrFQEi3gVzQ$0Tg3f00RvX7YlVmIxTIJu2knzwq8mrbcK/4bc66j5H4	CUSTOMER	t	t	2026-10-31 06:57:54.716176+00	2026-10-31 06:57:54.716176+00
c1c316c1-d0ea-4de2-a38e-8b0c34a96c1b	dup_d5f8168b@example.com	First User	$argon2id$v=19$m=65536,t=3,p=4$Dv6JO6V8sBAdtvxrXJg+/w$GVJHRzW8Xi/I1DXGtUx8mbvCvsG3vtWtj7iBo4Bu/RQ	CUSTOMER	t	t	2026-10-31 06:57:54.818812+00	2026-10-31 06:57:54.818812+00
3154a4b6-3a58-467d-ad61-21f197e468ee	login_user_e8bd0dc1@example.com	Login User	$argon2id$v=19$m=65536,t=3,p=4$SGick+QYD8m0B7BJ+9ryrQ$wymlkli2bNuIR9zhkPPkWCrwHov67rMlsSTvojyGe3Y	CUSTOMER	t	t	2026-10-31 06:57:54.918132+00	2026-10-31 06:57:54.918132+00
fd65f38f-87cc-42a6-ab9a-7b804b139103	rotation_6aa0b9f2@example.com	Rotation User	$argon2id$v=19$m=65536,t=3,p=4$JuRRHZ4ueaK/6pK7fNOemw$OhChBgn3zXN8SUaWczkSXbkS+DRKRkJB0Ah0CdS7q4M	CUSTOMER	t	t	2026-10-31 06:57:55.132279+00	2026-10-31 06:57:55.132279+00
8c3d9164-64db-4f25-bd84-c74a61f47a07	reset_013d69fa@example.com	Reset User	$argon2id$v=19$m=65536,t=3,p=4$HOJmNJMq3PrO9+etZpIIpQ$T6JSOb6ImB52QgQYbnOPOI6JtQuEDgOSca4w3hvljjg	CUSTOMER	t	t	2026-10-31 06:57:55.2706+00	2026-10-31 06:57:55.40018+00
0ee8c0fb-b477-4640-96f9-55e7f4e62d18	multi_reset_872da885@example.com	Multi Reset User	$argon2id$v=19$m=65536,t=3,p=4$GUOKu9hXBDAiuHP0P2v9Qw$l+qyJWkKV8BPQ8XrP5Z78jyLQFPqQGSasSzmgfP5gZc	CUSTOMER	t	t	2026-10-31 06:57:55.62166+00	2026-10-31 06:57:55.62166+00
ef934208-21d3-43e9-9451-426a3526c623	logout_no_jwt_6878d751@example.com	Logout User	$argon2id$v=19$m=65536,t=3,p=4$kgvpwLOBm5MSGbqelZMrhw$fjgBfzQtVZ+fBpveT7f9dNhBVvXlwFswYQPyr3ZDLA8	CUSTOMER	t	t	2026-10-31 06:57:55.814069+00	2026-10-31 06:57:55.814069+00
7ad8ce04-63b2-471c-9d89-9d2953f57842	cust2_02fdc8@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$ql/Ak7ZaQuBd2MTrx3VTSA$ZaPn0NA0FNbxv2PQubK3QHomMFj+n4DhND6NyHifmZM	CUSTOMER	t	t	2026-10-31 06:57:55.934883+00	2026-10-31 06:57:55.934883+00
97b82360-dbf0-4363-b80e-521408b6db59	cust2_501f39@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$aWZrdo8rFRIKPexY5aD+vg$D4t9NUEdzc28gQr1iW0qostJyY+Gsdf6hgZcon6mJ9A	CUSTOMER	t	t	2026-10-31 06:57:56.247084+00	2026-10-31 06:57:56.247084+00
290ae5fc-413f-4c19-b23d-8213f13711a6	cust2_b5000b@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$dALfDM1/BOXoXwEekZBejw$R93TrCvx0OQA9LAj2FWGx7IuyDL9z9tcJtFVXq0/z4s	CUSTOMER	t	t	2026-10-31 06:57:56.411952+00	2026-10-31 06:57:56.411952+00
d14de26f-512c-40fd-bc90-9222ae08714c	cust2_586ca9@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$HwrXKv15702TNrrbXz/e6A$SfQa/PpOdZj8VWZxy9msR9JMbLPjxDpx/eM6xJTeA2w	CUSTOMER	t	t	2026-10-31 06:57:56.601124+00	2026-10-31 06:57:56.601124+00
8da790a9-4448-487c-b6f9-a556c48a1ceb	cust2_fab806@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$SnVNM06LpzZcztoBqH/RtQ$xneBkVUtD1xfloA/QkHZpItK9B4HM8KYlJaHTDIKgeU	CUSTOMER	t	t	2026-10-31 06:57:58.765976+00	2026-10-31 06:57:58.765976+00
14717e01-a79b-4bdd-a7cf-6a79edbe15ca	cust2_f9e6c7bc@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$HYSjqRZiFsKln1Qb/sRXfw$5yOsv6yBaOX8sd0p/B1bP6lckLHFKzo9OO5iT2nkWpI	CUSTOMER	t	t	2026-10-31 06:57:59.093527+00	2026-10-31 06:57:59.093527+00
94c223b6-7cf9-490c-b244-b8184c45c9d6	staff_716e2d75@example.com	Support Staff Member	$argon2id$v=19$m=65536,t=3,p=4$LvQ9v0dHf/y/fPVJvf6uuQ$dyQ767YaZpx/8gZmbIoe47IlJNy5xzXWa/jkHdhKtUc	STAFF	t	t	2026-10-31 06:57:59.239138+00	2026-10-31 06:57:59.239138+00
dc41ff91-d203-479c-ab89-c1ca59c3f3f3	cust1_211f0517@example.com	Customer One	$argon2id$v=19$m=65536,t=3,p=4$5cLti5+vvHELm+w363gTnQ$PVoeFmL15VXMTxqeqgP0FpDQqKqVCYJalGIVDu1Rz3U	CUSTOMER	f	t	2026-10-31 06:57:59.01048+00	2026-10-31 06:57:59.483746+00
a1fa285d-14cc-40fd-a787-908ce2a6ce98	cust2_bbd9e5@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$E6aTVnjOiYML9cxan8KMNQ$53OGlImKrzxw/ZX1jnkhTvzh1djP0Hkb3ci0//toLuA	CUSTOMER	t	t	2026-10-31 06:58:10.699948+00	2026-10-31 06:58:10.699948+00
f3513394-caf9-443d-9971-8893cb4884c9	cust2_4affe6@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$ItsSl2I/QZccD7zxeP9dMw$Q4tR4L29R1jHJEoGVUIR5K+nz7AZpAo37WDrt8FV1Ds	CUSTOMER	t	t	2026-10-31 06:58:10.98596+00	2026-10-31 06:58:10.98596+00
7285aedf-bec0-472a-ac22-a2e63c91662c	customer_5cdb35d8@example.com	Test Customer	$argon2id$v=19$m=65536,t=3,p=4$Fr8QfNmruXqC8gRH20ydww$0pMlXVI08M25Xo0MJt7TPmsXxzqhUycZPRL9JIAF2tM	CUSTOMER	t	t	2026-10-31 07:01:01.26288+00	2026-10-31 07:01:01.26288+00
bd79e4fc-af1a-494f-b781-9a704b44e479	dup_c64a41e3@example.com	First User	$argon2id$v=19$m=65536,t=3,p=4$yKxe99emavZGSOHod82VFw$y+rPj4YjyWr9io1Et3/oErDQ/p1qVHP42KUdFdSApkA	CUSTOMER	t	t	2026-10-31 07:01:01.37425+00	2026-10-31 07:01:01.37425+00
052060c6-0beb-4e7d-8fd7-08856f7e1ec9	login_user_a9ced511@example.com	Login User	$argon2id$v=19$m=65536,t=3,p=4$ITje1zsNBYepkruzh0s8CQ$T2goAXA1EFa4oW7JMIVydY2BIlqbJ6EG3fEL0Te6mrA	CUSTOMER	t	t	2026-10-31 07:01:01.475425+00	2026-10-31 07:01:01.475425+00
9997dea5-958b-4168-8e34-cbce8da19cba	rotation_43fdd08b@example.com	Rotation User	$argon2id$v=19$m=65536,t=3,p=4$8YdEMsEMAp1YrBC5iQ0sHg$HYBdhDdzRe9XGcY3moCxlqVnh6akuUu/9pfRSIO7VPk	CUSTOMER	t	t	2026-10-31 07:01:01.692273+00	2026-10-31 07:01:01.692273+00
9454fb0f-4bec-4f35-8752-0ff0c45850ad	reset_f1c7eb8f@example.com	Reset User	$argon2id$v=19$m=65536,t=3,p=4$HWWblRmJiCLRX/HF07R/wA$xgkLmmxXUd1zjmqmSGR9EyZVHEE4cVjuU+riawoQt+w	CUSTOMER	t	t	2026-10-31 07:01:01.830447+00	2026-10-31 07:01:01.957267+00
ef162596-be5a-46c7-b5c9-96fffde7649e	multi_reset_5c960c5d@example.com	Multi Reset User	$argon2id$v=19$m=65536,t=3,p=4$xBI3WtD5fOtjTEh6em6XHA$3iYMl6PeEO5fNCC6Np7phHyVNkYw7fpTkxgll2Ap2T8	CUSTOMER	t	t	2026-10-31 07:01:02.17639+00	2026-10-31 07:01:02.17639+00
b1d34f68-343e-4b28-9091-6a9d6962b7ec	logout_no_jwt_ca7868d0@example.com	Logout User	$argon2id$v=19$m=65536,t=3,p=4$gieobssxuy41QLLTr8dwcQ$HInHwG++mDaOlthRnfXJAWbDmaKI7W9lv0VpqbB/GMU	CUSTOMER	t	t	2026-10-31 07:01:02.359036+00	2026-10-31 07:01:02.359036+00
926ab6fe-9343-4422-817a-9aae8decb985	cust2_77c50f@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$DO+mqvFE6LRr+0lXi8daUg$M7e0u3MoJfm+jgyLCoO+24A5jPKhmjglPh9am5+l1Hg	CUSTOMER	t	t	2026-10-31 07:01:02.473737+00	2026-10-31 07:01:02.473737+00
7cc50e24-d20c-43ca-8534-34ed51e72b8d	cust2_7b6a95@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$iMnJNZB+A/XWWki/M4rMhg$BttdY6zjtvI7c76OHdAsZ3vxaEVWHzVRncxqbGXDRYA	CUSTOMER	t	t	2026-10-31 07:01:02.782893+00	2026-10-31 07:01:02.782893+00
6902aa55-56e7-4069-b623-6c0ce3306e8b	cust2_cc5afc@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$a+6FU++OpidGdK6L3g68wA$cf1xleRnY9qzlLMLYDo+xc07onQRzCf/XKyJaCCMHnM	CUSTOMER	t	t	2026-10-31 07:01:02.955244+00	2026-10-31 07:01:02.955244+00
cdfca457-4b84-41d3-9dac-cda258fce71d	cust2_e46b7a@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$KQd0bSNpUaJ4H5bOfbKnJw$BGAzk5GpIJucDTq1WJ1lOpv47XW5kMKHgsR9HefWKIw	CUSTOMER	t	t	2026-10-31 07:01:03.148328+00	2026-10-31 07:01:03.148328+00
22ff8011-c39b-44be-a463-6b55f05e104a	cust2_b86bd6@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$IsaRUpEgWEt17ayav7Aijw$C/gMjeH4jXlsQpoZvHjJCykEhV9JGmXoU28JxZ7kU4k	CUSTOMER	t	t	2026-10-31 07:01:05.327695+00	2026-10-31 07:01:05.327695+00
732aab7b-d07d-42f4-8f2e-e4ebb31bab45	cust2_7b31f2d7@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$XSYEDquxBva3V4Rkd6QcXg$TGU9MuVLKQkKTF03hCrR8uPfn1s/FJ1EbO8aaH22/nQ	CUSTOMER	t	t	2026-10-31 07:01:05.836726+00	2026-10-31 07:01:05.836726+00
0fbbf616-93e4-4ce8-ae5a-80ee0780422e	staff_764c6227@example.com	Support Staff Member	$argon2id$v=19$m=65536,t=3,p=4$FjkcfEWMPMmZS7tTVUvlug$7okobNAczx6Xuxu6o8Uxst5Y0wJVLrkQ7QmbBWks/dc	STAFF	t	t	2026-10-31 07:01:05.982777+00	2026-10-31 07:01:05.982777+00
4396aa50-9bab-4349-8eef-cbde4ec50b3d	cust1_3d3b7595@example.com	Customer One	$argon2id$v=19$m=65536,t=3,p=4$RTPZbD7WzZEk6qJrHghYzg$uDMVWW1j/68s38mK+6DcCPXHClbq/YG9VuuDd33cap0	CUSTOMER	f	t	2026-10-31 07:01:05.75911+00	2026-10-31 07:01:06.22384+00
b1e6be92-ec85-4cca-a299-b325aa4567d4	customer_f1218604@example.com	Test Customer	$argon2id$v=19$m=65536,t=3,p=4$4xrhzKkYTaH47yuoBEPnOA$M3FazglDe+inysM3RmRcT5DAfF35DEfHK41cu2OXH+A	CUSTOMER	t	t	2026-10-31 07:01:36.90258+00	2026-10-31 07:01:36.90258+00
10928483-3589-4bcc-ac16-474f6dde1852	dup_c1080a57@example.com	First User	$argon2id$v=19$m=65536,t=3,p=4$tIEo16rVn4biykbUaHyMDQ$ZNXF5wPBmfM4B66p8mHxDFjqhLiUzqSpiUlq9lrQE/g	CUSTOMER	t	t	2026-10-31 07:01:37.008228+00	2026-10-31 07:01:37.008228+00
1943c312-634a-4ab3-b6fe-fa2081ec0dbd	login_user_bea0db1b@example.com	Login User	$argon2id$v=19$m=65536,t=3,p=4$Fc1eD1HbzFFV9if/gUDzcg$pc/KXJHH8lWtnI26PwQouJoFGRXK5eLc00F4TFLjT88	CUSTOMER	t	t	2026-10-31 07:01:37.106345+00	2026-10-31 07:01:37.106345+00
1811d575-46d3-4f84-8a1c-85d8e2504dac	rotation_3f5bacf4@example.com	Rotation User	$argon2id$v=19$m=65536,t=3,p=4$6JJmPR6ydhGrwnshpRE7QQ$dQWVTwQgsjAR9APR6CtPDY6XUMtAIFprEnSn+h452vs	CUSTOMER	t	t	2026-10-31 07:01:37.330017+00	2026-10-31 07:01:37.330017+00
79afecfb-a64b-47a2-813c-72f6eec196c4	reset_fe205b7b@example.com	Reset User	$argon2id$v=19$m=65536,t=3,p=4$VVWY7QN0bl6dLSBuxY8u0g$afamWGMZYKAwUBFKJ1elpsy3ZIQTWySC70D3iOZnzP4	CUSTOMER	t	t	2026-10-31 07:01:37.477638+00	2026-10-31 07:01:37.623606+00
07c13107-a120-4937-b7bb-b235ecc5b8c4	multi_reset_0997a18f@example.com	Multi Reset User	$argon2id$v=19$m=65536,t=3,p=4$ECaCC4qJbUjbpOLaTXPcvg$ZqAeMvjC3FiZylsKIe1slvbeGuClzQLjoaTXYjDGZUE	CUSTOMER	t	t	2026-10-31 07:01:37.843828+00	2026-10-31 07:01:37.843828+00
9bd376ca-84e7-48cd-a91e-9002151bf344	logout_no_jwt_9dc09355@example.com	Logout User	$argon2id$v=19$m=65536,t=3,p=4$nCmwLlr8TOWIZddAnB3eKQ$T3cewyp3vojmSqciEtzIX2t+8FY9QUnfMY8CilqiXds	CUSTOMER	t	t	2026-10-31 07:01:38.041031+00	2026-10-31 07:01:38.041031+00
48f390f9-b8dd-4aca-8a52-b9bdee14206e	cust2_4bfeae@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$ErtPIidF6AxJYGIlW7WgKA$5llwSmZQLqiOAw6kpu+XOSYmX6KCaPP1JeI96/7aZ24	CUSTOMER	t	t	2026-10-31 07:01:38.168929+00	2026-10-31 07:01:38.168929+00
628ea848-2123-49bf-a1bd-07be4afca2c7	enterprise_dd7722@brightloop.io	Acme Global Corp	$argon2id$v=19$m=65536,t=3,p=4$Y07u0snu2nYuNRCfzN/MWg$AMydxO3VRCw6Au/y7sQu7vW8hZehigObc04kwM6ZtDg	CUSTOMER	t	t	2026-10-31 07:01:38.272438+00	2026-10-31 07:01:38.272438+00
2a90d3b3-e4df-4048-9a87-2d5c49f84f6e	cust2_5f769a@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$o4LBYURovatLeC7LKSkwng$jX6iXUS0u2NH1NTZ4nE0+Mkqp8hMqlwYDGH9TaRMJyM	CUSTOMER	t	t	2026-10-31 07:01:38.4225+00	2026-10-31 07:01:38.4225+00
9860c761-8e2a-40ee-8c7c-a0bcdc77be0f	cust2_750078@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$3JmXquG5dzxPuhYCoZtD5A$wa/VPOXEPc4rCbw+im0j1a6I3Z6t5lxSp7dQyP1jjzA	CUSTOMER	t	t	2026-10-31 07:01:38.592592+00	2026-10-31 07:01:38.592592+00
f486b32d-7960-48fc-b4c4-14a4fcb646fb	cust2_767869@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$gfXHfCqppa4y7y5g6K77YQ$YZaMWsAa5Vq3D/X2nt/wFbHdez3h4k8mP6j9olyQhbM	CUSTOMER	t	t	2026-10-31 07:01:38.789919+00	2026-10-31 07:01:38.789919+00
a5b1716b-c164-4def-bae1-66f1e258b42c	billing_8527b@infosys.com	Infosys Corp	$argon2id$v=19$m=65536,t=3,p=4$O1J+XMpOk/Lhr51NtaXIFQ$EDtCVvydQ5koGGE8CxIIIeznArj2iv8Cuclb8xkTyPI	CUSTOMER	t	t	2026-10-31 07:01:39.0156+00	2026-10-31 07:01:39.0156+00
01d7b313-b33c-454e-99d7-a06dc04cb10f	cust2_c1a0fb@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$rhnTVk5sWdqNmnculnFoLQ$C398LBitIZpk1jQIztRLsrFZin6Wj0I1TvDBD+Bet7Q	CUSTOMER	t	t	2026-10-31 07:01:42.304033+00	2026-10-31 07:01:42.304033+00
e56fe90d-6089-4c10-9c2c-9c47b80033a0	tata_6e42a@tatatech.com	Tata Tech	$argon2id$v=19$m=65536,t=3,p=4$GM1rS3tGsTxqEM6iMVc2yA$yIZNUBLd+L3ePjHM9gQ6t8ZaVezWCFetrna5EzkdAgE	CUSTOMER	t	t	2026-10-31 07:01:42.510931+00	2026-10-31 07:01:42.510931+00
9ea6e003-d6af-41ba-a523-1a52ae2fe703	cust2_810c5a9d@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$zbPArJgFN0E9Ue1pvLV9AQ$olA/D1ImMIFVWf3rmDE3swBoRApcRaI+wcZZyMKT3uY	CUSTOMER	t	t	2026-10-31 07:01:43.024392+00	2026-10-31 07:01:43.024392+00
b2a6f66d-fc41-4eb0-86e7-36e98e60b7fa	staff_02da18b2@example.com	Support Staff Member	$argon2id$v=19$m=65536,t=3,p=4$K46u/ZK1ame4KpFFUNvLnQ$Hl9hLwrPc7VFpzBYCrVXdY+sEpZMc3rPPD1RbsITrLc	STAFF	t	t	2026-10-31 07:01:43.165113+00	2026-10-31 07:01:43.165113+00
a0978a5e-7bfc-4269-847a-0ddf8279f862	cust1_295491fd@example.com	Customer One	$argon2id$v=19$m=65536,t=3,p=4$n0YNOTUETNQcNEUUQKGPlA$FTzVDBd+z1OqTjMpZq3nvbdCed887SgSRHVS6FwuFQ4	CUSTOMER	f	t	2026-10-31 07:01:42.940442+00	2026-10-31 07:01:43.396811+00
843d4960-08ca-47f4-adcb-9867809d7989	customer_bdb18c73@example.com	Test Customer	$argon2id$v=19$m=65536,t=3,p=4$4gmRlaAE44m0UhQJtYhYFA$W6LdQ8zmk/TVnMOskmLY4FBsplVL15YuJBD/SGVFQ7M	CUSTOMER	t	t	2026-10-31 07:24:16.771431+00	2026-10-31 07:24:16.771431+00
59227789-261d-4aab-b74d-03ffa1e2271a	dup_6f4c094e@example.com	First User	$argon2id$v=19$m=65536,t=3,p=4$wtoLV2ml/DyKtQPzI/CSkw$LlngCbUMITEOAZDlhjMdMpn/AkDOdsoEdsiiIiaDRa0	CUSTOMER	t	t	2026-10-31 07:24:16.882566+00	2026-10-31 07:24:16.882566+00
1737e95e-822d-4c0f-ac0f-c702a5b2109f	login_user_8b4bbab4@example.com	Login User	$argon2id$v=19$m=65536,t=3,p=4$5BSC/slJuQmabUZpIV5VJg$8aFdP2qvNmAzxpALYYoOPsn3HjE09JeRcIQ/WfSZKrM	CUSTOMER	t	t	2026-10-31 07:24:16.989825+00	2026-10-31 07:24:16.989825+00
36726a35-4372-4be4-9321-48da65360248	rotation_d9b630f4@example.com	Rotation User	$argon2id$v=19$m=65536,t=3,p=4$idpLlsAl+jvOGtIiivjmCg$IHu7XPN4miaUkSud/+nk6bcb6Y0TZazBxU94gx++g40	CUSTOMER	t	t	2026-10-31 07:24:17.207968+00	2026-10-31 07:24:17.207968+00
f2b5bafc-3d46-4968-bfae-1f837ee70ea7	reset_961880ed@example.com	Reset User	$argon2id$v=19$m=65536,t=3,p=4$f4fTgzBviXhg8wMMBxvn5A$JqXncBi9MIGKWJKsW+01NVi1D+BiPZGPIKREJCOY5G8	CUSTOMER	t	t	2026-10-31 07:24:17.366165+00	2026-10-31 07:24:17.493583+00
d9d4a6b9-4e42-40a7-a637-1c3cd145c1e4	multi_reset_0d6a2fbc@example.com	Multi Reset User	$argon2id$v=19$m=65536,t=3,p=4$3hFkf43hvzNPYMQFJgGtzA$e8ZryAbP90rZi89ulLFXSfLCNHVFQvOHrpZ1Ij7MMRk	CUSTOMER	t	t	2026-10-31 07:24:17.727004+00	2026-10-31 07:24:17.727004+00
c14ed6f5-aeb4-4e9c-8944-4e898df4b9f4	logout_no_jwt_7e625db9@example.com	Logout User	$argon2id$v=19$m=65536,t=3,p=4$LA1KllQwRP5SVFBTrNHPeg$Iuz/n2gaEhf5tTwHj6vuNkT6FYXlf3nIu+L1lxoKARo	CUSTOMER	t	t	2026-10-31 07:24:17.922061+00	2026-10-31 07:24:17.922061+00
ec3888b4-a55e-47f0-9767-68f91fde6d49	cust2_c9ef4d@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$9wiXrYCL53jQnkiZriTKVg$7lw4zKoL4D+CjfdXk4ChMCklMquZ4afPl9mVvfQebr0	CUSTOMER	t	t	2026-10-31 07:24:18.041779+00	2026-10-31 07:24:18.041779+00
3fac70e5-8751-4981-a145-bb97fbce8d27	enterprise_6c39f9@brightloop.io	Acme Global Corp	$argon2id$v=19$m=65536,t=3,p=4$qVQSH/n4rG6u/iQxZZCzyQ$DtsCopf1YvrPZ/C+SZYihd0WmfKYqy7qRGFDf48wXSc	CUSTOMER	t	t	2026-10-31 07:24:18.140946+00	2026-10-31 07:24:18.140946+00
0c580c52-c313-40fb-9c35-122a5fa9422e	cust2_22cf6e@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$93WETdiOWPenII0W6ChKUw$EQgEiLMgewIW0OOQcHZlqD4bCt873aqgZ1QxAJNtVf0	CUSTOMER	t	t	2026-10-31 07:24:18.29003+00	2026-10-31 07:24:18.29003+00
0dd86b90-6875-4296-9988-8d1f12afd433	cust2_853a2c@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$w7yiNHZG791Qk2eu7kcSGg$w7bPPOQrkPNwEbDgyWP+vRbBY3mrh4kcoWyiCh1pVYE	CUSTOMER	t	t	2026-10-31 07:24:18.457801+00	2026-10-31 07:24:18.457801+00
e48d0348-26f5-4cfd-9313-a7ab28c1a2f4	cust2_73ce2e@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$gU2PXAhQo4FLvQ24ArmMgA$J+YNcCdOqdh2C+jHSOFu5VeYBX/65dcKgdzA3do/OLE	CUSTOMER	t	t	2026-10-31 07:24:19.044504+00	2026-10-31 07:24:19.044504+00
2de8920e-abf2-44f4-9d69-d48779260b63	billing_c26fb@infosys.com	Infosys Corp	$argon2id$v=19$m=65536,t=3,p=4$GBSXU4XSye6tLBi551T4Lg$GgFEu3yqSipYanHU+eaFDU9Yr9aRZdQ0xaQ8JaBm3c4	CUSTOMER	t	t	2026-10-31 07:24:19.297932+00	2026-10-31 07:24:19.297932+00
409db828-c01a-4684-b00f-e8986e543612	cust2_6d55bc@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$Qxv528mJHJWtHCosOm+rdg$qK2j76uJrVOAbJbmMZtP/ssRRpE3Tgzeogj2S0LLjSk	CUSTOMER	t	t	2026-10-31 07:24:22.535798+00	2026-10-31 07:24:22.535798+00
0f393bda-925a-4ca8-8a28-7db07ce74607	tata_7b7c7@tatatech.com	Tata Tech	$argon2id$v=19$m=65536,t=3,p=4$y74YN4gTBateOsVoAg+HiA$OS8jtFd33e+amHFdRMTCaSDLlZIry1d+qnasLJtCPFA	CUSTOMER	t	t	2026-10-31 07:24:22.757832+00	2026-10-31 07:24:22.757832+00
5ace8bc1-63d8-411f-a11d-e6a1704ed15b	cust2_791a6af8@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$6D1PnSFWzWMWtnaFzlIRXw$Ed63+BmsfvhaUt6oJHpdPn3JUI/Juor+lnh59LA0gls	CUSTOMER	t	t	2026-10-31 07:24:23.362743+00	2026-10-31 07:24:23.362743+00
ae4ffc0c-35ef-4e8e-9f0c-2e3b996c7115	staff_9eb997ff@example.com	Support Staff Member	$argon2id$v=19$m=65536,t=3,p=4$yE/8bGjPXTgZuonS1sxgZw$4W5MDS8bnnhDFdEHeDAZruf4Sw4JnBXZbuK/RN6g45c	STAFF	t	t	2026-10-31 07:24:23.503608+00	2026-10-31 07:24:23.503608+00
6190315d-16e2-42b7-8ebb-ae669aa4a9e9	cust1_0044b42d@example.com	Customer One	$argon2id$v=19$m=65536,t=3,p=4$WAZN/28mCRfQqqF4NWFdeg$DPGB0QAnqNPh4FOfjWjSYfvG/+dC/lX20iAc5DoDFBk	CUSTOMER	f	t	2026-10-31 07:24:23.280124+00	2026-10-31 07:24:23.734942+00
42ac6db9-70d7-4973-8852-c8c16d975be9	billing@tcs-enterprise.com	Tata Consultancy Services Ltd	$argon2id$v=19$m=65536,t=3,p=4$vohcVfUOzk4HvLndyID69g$+lnEDwyYILg8WDwDpKFjvn4DktGvcDeqpEmc5KOdGeE	CUSTOMER	t	t	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
0edd6c45-63f8-4d39-aade-7746228f0b98	finance@zomato-corp.com	Zomato Media Private Ltd	$argon2id$v=19$m=65536,t=3,p=4$29cAZhPpiPlWGi3t+43e8g$5QtbBqmrXVTte71XU0a50+XsYvGkXfbblkUx237XiBs	CUSTOMER	t	t	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
ab39119d-27a4-4eae-b2ea-b2413a1540ad	accounts@swiggy.in	Swiggy Bundl Technologies	$argon2id$v=19$m=65536,t=3,p=4$lC1F6cXFIyk3oy1sZI2lYA$rLVH7yPCZ7iwTgCEs84iTm6a3cLZl1DyhL8vzv8f9YA	CUSTOMER	t	t	2026-10-31 07:33:24.444528+00	2026-10-31 07:33:24.444528+00
b14eb4e6-76f7-49a7-a2a8-c85e589399d4	cust2_cadeec@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$8c7gKVG8ZGF/gXGhExa3eA$5rrporrcWUXA+8VEA6IPew2lroI07NNth+mFK7VHesU	CUSTOMER	t	t	2026-10-31 07:35:20.365155+00	2026-10-31 07:35:20.365155+00
319ca723-eafd-4883-b097-6b20dd0faabb	audit_corp_dbbe98@demo.com	Audit Enterprise dbbe98	$argon2id$v=19$m=65536,t=3,p=4$HyoKWl8C1KeEXlkYjtJBIA$vru6dIzWNFB3iUG2gbNdu5jzVcod6Ch8hKCGxQUoaO8	CUSTOMER	t	t	2026-10-31 07:35:20.464995+00	2026-10-31 07:35:20.464995+00
8380c157-6826-4727-b21c-04aa9d7cd2d5	cust2_450a54@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$44QTZTvhoA90yS7JcJoDyw$6ClEPYKWwg6pCxsyGr7Tnq4tfOR6vwaCQjZh2aiIq5w	CUSTOMER	t	t	2026-10-31 07:35:20.840438+00	2026-10-31 07:35:20.840438+00
b0289709-fdb9-4186-8170-97d5fe8ca536	dup_ccb42b@domain.com	Company Alpha	$argon2id$v=19$m=65536,t=3,p=4$cLEPL67XR6pBbUYLO1bTdg$ox80oHfp1Yh62MBTPdxVkG2CTvXZXfiRD3cyvwokupM	CUSTOMER	t	t	2026-10-31 07:35:20.912989+00	2026-10-31 07:35:20.912989+00
3df5e67f-40cb-4150-ad30-f300344ad8d3	cust2_8ee731@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$ysYlTY4/SpSs3KDys/O1fQ$2634/EPtTToy3fPHAWzR+j6pksf6CTc5LijxqHj9c+A	CUSTOMER	t	t	2026-10-31 07:35:21.030488+00	2026-10-31 07:35:21.030488+00
62ba0cee-0bbc-4fa2-a484-0d17e7e96c78	qty_fea26e@test.com	Qty Customer fea26e	$argon2id$v=19$m=65536,t=3,p=4$fej4Hi7J//dILpC0yPeEbg$phS4/toFnMwquKqVMv6fK/PMQEQ1N9Vzs8sEDEnV9rw	CUSTOMER	t	t	2026-10-31 07:35:21.235137+00	2026-10-31 07:35:21.235137+00
5ad95117-34b1-45f3-9305-42ca74c49dbf	cust2_625a3c@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$8WgAzzE8k3YWN+x9wH9lpQ$72t6kMkA4tPKMVYAzI5FT5V2Vy88CjMCREkBMe1uJ6M	CUSTOMER	t	t	2026-10-31 07:35:21.408501+00	2026-10-31 07:35:21.408501+00
e9e2cf4f-ce8b-4220-bdec-6d394ba91885	draft_5e366f@test.com	Draft Tester	$argon2id$v=19$m=65536,t=3,p=4$8/FefMAc6Mm2SJPgWVxLCQ$WCvf7dHKi8iW6uLL9cuYDCKPPKcrpMUNKtBLG7As6j8	CUSTOMER	t	t	2026-10-31 07:35:21.512494+00	2026-10-31 07:35:21.512494+00
26df84f4-c293-4983-88b9-eaf55694eeb6	cust2_05ff88@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$f/MYBE6UVPr7ZINA0MvTwg$0LTyVADiPf2v582DmjZZ32U7RibmPTj7QDr1PoEMHoQ	CUSTOMER	t	t	2026-10-31 07:35:21.638829+00	2026-10-31 07:35:21.638829+00
6f71e03b-972e-4a07-a28f-831713f9da1c	ovl_20b80a@test.com	Overlap Cust	$argon2id$v=19$m=65536,t=3,p=4$5Djuh9vAY+1nHW/a4fD6tg$S+NEjW7ix3c21VKwb4J2RBiqjMi19mMvCrjvVoC8QBA	CUSTOMER	t	t	2026-10-31 07:35:21.851666+00	2026-10-31 07:35:21.851666+00
a2ad94d6-01fb-4828-be74-523913d08cbe	cust2_b1a7f9@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$CTgeqSOFGZHFCsnRs47mKA$mz+HBCno+GRO2MwTabBLQ1XJW8ZR3eYwu8NmcyMBuyo	CUSTOMER	t	t	2026-10-31 07:35:22.063208+00	2026-10-31 07:35:22.063208+00
d0fd89bf-76fe-4bbd-a550-64d20acf2bc9	cust2_141880@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$RpKAP9rZgtenhIUol9xxIQ$wdRHftJMZZCzwfcCYAMsqsjSgvfGuxkw6K9pbVId9sQ	CUSTOMER	t	t	2026-10-31 07:35:22.163688+00	2026-10-31 07:35:22.163688+00
e82dfe6d-4528-4957-b697-af13e73699a8	op_b78a98@test.com	Overpay Cust	$argon2id$v=19$m=65536,t=3,p=4$9qtcm8Ecr8O+bRLUBj8Nrw$3ImtEvVQ4zIaEnFl6Gh0niN9a+YZurGAnzYo3mfYPc0	CUSTOMER	t	t	2026-10-31 07:35:22.372764+00	2026-10-31 07:35:22.372764+00
d2056938-07e4-4a17-922c-3795abbf95c6	cust2_352af4@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$lDx6vap8YbTA7VQ1Eo+zXg$j5o1LHl52shaETBnCc8L0qHtRx5nr6OtncwhYBeH+sE	CUSTOMER	t	t	2026-10-31 07:35:22.595871+00	2026-10-31 07:35:22.595871+00
b0f86890-64bf-48f9-9eb9-e94891fc5d6c	cust2_880131@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$WO/5dsqWK0hh7kz4jrpqow$Khc2yl/jMHE2ELSiIrMs4Lq5whcp9K/SbFbeNzMkIEU	CUSTOMER	t	t	2026-10-31 07:35:22.699664+00	2026-10-31 07:35:22.699664+00
3b28c923-5187-4c07-a30a-66be7d024afa	cust2_582d07@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$trqwW30HfowNyo9mqirHuA$EspDmhEUp9Uh4N+dMjX0vi4aPFV+7AsUBWsZBzHwFXM	CUSTOMER	t	t	2026-10-31 07:35:22.782986+00	2026-10-31 07:35:22.782986+00
1db238e8-d823-4e53-a192-4cbe1979c01a	neg9_2a13bb@test.com	Neg9 Cust	$argon2id$v=19$m=65536,t=3,p=4$+hZLMhTD3p+5gOYpjysKmw$b9FM3PQlUOr0RFukOBfI0xtfWok+M28uawYaFlKhabQ	CUSTOMER	t	t	2026-10-31 07:35:22.969455+00	2026-10-31 07:35:22.969455+00
0430a575-53f5-4a6c-9e63-77a7fd2f1cb7	cust2_b4855c@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$xO/SCc2dTbLMr8VRHr62Vw$T6e06aLYJ3btgAo0oa7cf4KYUM1aRG6K996N4L/48Qo	CUSTOMER	t	t	2026-10-31 07:36:18.175733+00	2026-10-31 07:36:18.175733+00
3ff93d20-fe6a-41a3-aeaf-e6589846282e	cust2_51d683@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$qxJscvKLR2BftYqoYfzoeA$ZkLtBgkywzHTMS2UXeJL6bA5tYwwlIOpuKOki+85WaI	CUSTOMER	t	t	2026-10-31 07:36:18.336618+00	2026-10-31 07:36:18.336618+00
385851d6-dca5-43fa-8dac-17f006fe0a0d	cust2_d2e3b4@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$m6itipLj+zlIOmudeV8nLg$DiYIC/E8+lvqj9LTqNAMCPL0scYg8kzJyS2d7o0kdjQ	CUSTOMER	t	t	2026-10-31 07:37:29.098858+00	2026-10-31 07:37:29.098858+00
6c761294-0188-4925-9242-3fddfec0c211	audit_corp_3a32a8@demo.com	Audit Enterprise 3a32a8	$argon2id$v=19$m=65536,t=3,p=4$+Z9m4TNdLMIadwcO2nE9hg$fGHi+rUOJ8xsrvRo9FcaDyMQr4rtZw6hOpWLR974H3s	CUSTOMER	t	t	2026-10-31 07:37:29.206418+00	2026-10-31 07:37:29.206418+00
b1cb0f14-225d-4c13-8270-b3c898b0c92e	cust2_5abd94@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$Aq5xo/TEQzPPU7QPAsQP5A$5PpH4f5fFX6VxzhPhQyTXNPUNfDToGtYdYG0o/xNF40	CUSTOMER	t	t	2026-10-31 07:37:31.088785+00	2026-10-31 07:37:31.088785+00
fda5f60c-b55c-4681-8eee-8754701bb862	dup_b8f8b4@domain.com	Company Alpha	$argon2id$v=19$m=65536,t=3,p=4$fypxU4AjP+o8F0eB3HsWlQ$4cWy3KU09OG7uyJq5cNmeND3H1BsV2GdWfUtoYbooHw	CUSTOMER	t	t	2026-10-31 07:37:31.169295+00	2026-10-31 07:37:31.169295+00
7aba5f99-4a73-43ff-95dd-c6f542225c92	cust2_6ef3e1@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$xxSEvwPKn32Whk63pZJo8w$WqYO9LcApmNE8Jz280YfWKftV21WDRwG+w9Ip5Ww3J4	CUSTOMER	t	t	2026-10-31 07:37:31.28686+00	2026-10-31 07:37:31.28686+00
0bc3d615-5e7e-42bb-8e77-55fe6d255d6f	qty_ef54ca@test.com	Qty Customer ef54ca	$argon2id$v=19$m=65536,t=3,p=4$EJgaeCJVMff3q5+ovBUr2g$M4rFqxDaiYuxfhIKgGRa4FyOk7+e/Km6sh7WiYchj0A	CUSTOMER	t	t	2026-10-31 07:37:31.499712+00	2026-10-31 07:37:31.499712+00
0c87e267-807d-4f12-96d6-dee71bd57a18	cust2_e3af90@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$vig8JhymqpuckzD2VWUqaA$ARdUq0QWzKh066XsQz81vm+pcAWEkft5ROgtLLIqy3o	CUSTOMER	t	t	2026-10-31 07:37:31.669484+00	2026-10-31 07:37:31.669484+00
e92e067c-86a6-41c9-95f9-04601ecea5ac	draft_de3b95@test.com	Draft Tester	$argon2id$v=19$m=65536,t=3,p=4$UPdh4EJ7wEwsIYFbNjXD1w$E5A7S5CIQ4JnsB6EyvawUCaOunrFk14OCsNokp90b28	CUSTOMER	t	t	2026-10-31 07:37:31.777375+00	2026-10-31 07:37:31.777375+00
fd1b14d6-eefd-4e69-b5bf-9526acd67e1a	cust2_469d22@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$ErRI+2cYKsxO09DXkkDIkA$ZoubQeIv1eLYYeL2E+Fc4/kR+A1bZF0rPwjMb5zJREs	CUSTOMER	t	t	2026-10-31 07:37:31.889288+00	2026-10-31 07:37:31.889288+00
31ead84d-8593-44a7-82be-62269162708b	ovl_0531ca@test.com	Overlap Cust	$argon2id$v=19$m=65536,t=3,p=4$V0pUU8CvkjWZX8bSMDvi8g$0MEfDWgFzLbCgZMexdNel9QRoHndEj4elSD+eK1hLBk	CUSTOMER	t	t	2026-10-31 07:37:32.08704+00	2026-10-31 07:37:32.08704+00
bde15e77-96ba-464c-a1b9-87d14ddce11f	cust2_eecaca@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$zbspleO9jRUdhklqE9CBpQ$spd9jq9Hqot8bQ7oWtG/tuyQBQ0F791Lx7CCplJyoZU	CUSTOMER	t	t	2026-10-31 07:37:32.345993+00	2026-10-31 07:37:32.345993+00
6521cff3-9c4e-401c-b667-406abc99c808	cust2_56a56c@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$p1rJdYb7CEsUR0fboAeVsg$T7XD/1jEsDAkOsrAb68CAog1YTiQPuJ3Xh7BvKX5ldc	CUSTOMER	t	t	2026-10-31 07:37:32.447282+00	2026-10-31 07:37:32.447282+00
010ca79b-8c8d-4721-a74f-ce2fdc90ed73	op_ffee42@test.com	Overpay Cust	$argon2id$v=19$m=65536,t=3,p=4$9y0IBPb76zLBP8xtIPJmyg$q0aemAf4Ode/IsRpaqu1QHkhMQ6il5iu9ND4HY2h7Oc	CUSTOMER	t	t	2026-10-31 07:37:32.654626+00	2026-10-31 07:37:32.654626+00
dcc01a12-5f77-4958-9093-099d0c40fb7f	cust2_bb259d@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$HVmyKkJWHKcr1fuXC5Su1A$1+Lt5nq2SBItHmTIwYW1y+mTVqLSAbjnGlcyFizMuu0	CUSTOMER	t	t	2026-10-31 07:37:32.915137+00	2026-10-31 07:37:32.915137+00
fbc9f9fb-074d-4943-a212-dde7cf5eaf6e	iso1_4899a8@demo.com	Customer One Profile	$argon2id$v=19$m=65536,t=3,p=4$zC9nx9jPMU5YcgyBoa0T5Q$0pg8AV/vqtkoXsWU0KN+f9vJcI/0IJ2efSfBaQBzVzc	CUSTOMER	t	t	2026-10-31 07:37:32.993211+00	2026-10-31 07:37:32.993211+00
2fbae6f5-da89-4056-a5d9-51a70577af1e	iso2_4899a8@demo.com	Customer Two Profile	$argon2id$v=19$m=65536,t=3,p=4$TVKS0DbURddscfCMBqo2rA$+QtDUun8IIiHH2Yev0Aa0jG76vXEy4oCzP3jFCjntA4	CUSTOMER	t	t	2026-10-31 07:37:33.083142+00	2026-10-31 07:37:33.083142+00
7323fbdd-56b5-42ef-b08e-47af3e49559d	cust2_e73f5e@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$mpy6Oj2mMpKD5bnxEAW1CQ$zGDDKSrVsxyX74mupI0pof0O2wSWjvLwqk5vAD1BIBQ	CUSTOMER	t	t	2026-10-31 07:37:33.2394+00	2026-10-31 07:37:33.2394+00
36bcf48e-1398-4dd0-9489-8a3341fce8fb	cust2_5467a8@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$3IrRY9H6PjXJdMUU4bw6wA$Crswo4c0hROsddrW77J+eN6EiTkTjvACvrr15QleayU	CUSTOMER	t	t	2026-10-31 07:37:33.338456+00	2026-10-31 07:37:33.338456+00
617b7b2d-6424-4b9d-9a95-0b2c97d88eae	neg9_18b7b5@test.com	Neg9 Cust	$argon2id$v=19$m=65536,t=3,p=4$/fN5zrp93xtmGyMM+c7IiQ$1xmA4E4pTem8va5esIa6nFDIx9xgmZ0URlnoQ5sLZKg	CUSTOMER	t	t	2026-10-31 07:37:33.540809+00	2026-10-31 07:37:33.540809+00
ffbd1dc9-dbb6-4aa7-a860-a2031117710a	cust2_0a076a@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$t1VFrpmolBthzkytPtjV2w$PAL2GW51WnaQqbBcjIq0BntjGrzGALKGdNMKr7rlzW0	CUSTOMER	t	t	2026-10-31 07:37:51.207163+00	2026-10-31 07:37:51.207163+00
8d243da3-179e-4eed-a755-27d116a69fb2	cust2_4bd9cf@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$+HuX1MZfcrTWsDEqzUkbnQ$c+lcPzjWu0wSxcOGly3Ex5URvqhc95mAQIwP9kwqn9Q	CUSTOMER	t	t	2026-10-31 07:38:18.177024+00	2026-10-31 07:38:18.177024+00
e4783364-7813-465d-ae8d-04a025ea069e	audit_corp_2c1132@demo.com	Audit Enterprise 2c1132	$argon2id$v=19$m=65536,t=3,p=4$KydqgjYVNYlWKbqWmfY/LA$1SfpBkP3FWwggU4nx8s+cG8J47y7zrZmMqTEnmhmCfQ	CUSTOMER	t	t	2026-10-31 07:38:18.277993+00	2026-10-31 07:38:18.277993+00
ad9b19e5-4b4a-407a-ba8b-d70a4d0d6da7	cust2_85d929@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$Qte+3Mp57qUtiw1r3vSm/w$+FuAAp9y0dZ+UnvJAuRUrcS7HWolvwxiqv0jYv1Rw1w	CUSTOMER	t	t	2026-10-31 07:38:20.251471+00	2026-10-31 07:38:20.251471+00
54e697f5-ec86-49d0-a228-a4ce85abf64b	dup_091447@domain.com	Company Alpha	$argon2id$v=19$m=65536,t=3,p=4$oQt64Y/i65mAa7z89yZVmg$1BaISRvY2vRis8jxQWSS6oyienDd0VsNc6QTzqA5uRA	CUSTOMER	t	t	2026-10-31 07:38:20.334866+00	2026-10-31 07:38:20.334866+00
75662c13-6b9d-400a-bddd-5c1c84f33b94	cust2_677a2f@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$09ocNf8nhjDplPxLQd41SQ$ILKdOx+yF0sJJJr72WNBVRxpFuGF9JpW5nWNpr13wpk	CUSTOMER	t	t	2026-10-31 07:38:20.453889+00	2026-10-31 07:38:20.453889+00
83ff8008-a19a-4079-a653-cd9066754e47	qty_2446fd@test.com	Qty Customer 2446fd	$argon2id$v=19$m=65536,t=3,p=4$gRZJ+IT8PBsORR4o81JMuA$1SrnljjfK452DiaF63yk4CT0+GrKjXij/TELfHIbh8g	CUSTOMER	t	t	2026-10-31 07:38:20.674165+00	2026-10-31 07:38:20.674165+00
03343c05-a1b4-448c-8b54-85712d6d8c75	cust2_e1c6e0@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$KjGbtU7m4yKAWh8CDAo4AA$KjSZI7n3zL8ZGnH9vXVXaMvYEmmnAoM9j3mx4M4pyNY	CUSTOMER	t	t	2026-10-31 07:38:20.837876+00	2026-10-31 07:38:20.837876+00
c6865499-f520-4b3a-bd59-d7ac73da12ae	draft_5e80ac@test.com	Draft Tester	$argon2id$v=19$m=65536,t=3,p=4$Tvh5APbq/SMaMdPFWPGsaw$WWi+IsQ/LvHcNmfx++FPHbLSZ1EBz/Q4PbsDTne/sYs	CUSTOMER	t	t	2026-10-31 07:38:20.947056+00	2026-10-31 07:38:20.947056+00
298f09d5-5e71-44e2-90ec-16956dbcb121	cust2_e20360@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$sIbWhMCC3hfR21LCQFBaXQ$8ivEEFvncfUiTj1WLhTPGffBXTQwLm7JOJrKM9GpNY0	CUSTOMER	t	t	2026-10-31 07:38:21.070369+00	2026-10-31 07:38:21.070369+00
d9a03e5a-b69a-466c-a629-bd1ae2fc92ee	ovl_fb54d3@test.com	Overlap Cust	$argon2id$v=19$m=65536,t=3,p=4$ANiid0D2K6a5f+1gz/clcw$eJAD/MXdUYn8sNT9BVdBvNHjvlDAYWValHjyI+ZscbE	CUSTOMER	t	t	2026-10-31 07:38:21.289533+00	2026-10-31 07:38:21.289533+00
eb56a399-e9a8-4e4c-987f-7737bacca7c0	cust2_9e3ef3@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$+0oqKeO3tKcvSIrWY7QWqA$1gUT/siMYlfbtMcZtMbNt6ZJjw7lHMqQETlSu6BCxvg	CUSTOMER	t	t	2026-10-31 07:38:21.781764+00	2026-10-31 07:38:21.781764+00
b175c196-5162-4e7f-89a8-c302c571ede0	cust2_b6bb80@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$0/jCnvfW3c98O9eRsjsd6g$amPGZPRIOX/dq0hNCrCQtCzARSZr/iBhPYWCOCd02jM	CUSTOMER	t	t	2026-10-31 07:38:21.885747+00	2026-10-31 07:38:21.885747+00
84993fe6-4f73-4a8b-955a-f15c1376d1ca	op_de242a@test.com	Overpay Cust	$argon2id$v=19$m=65536,t=3,p=4$OgQw+8XTjRZggBhe4JSfnA$t+N24DnK87u2LgHqpZebongrBkHjJsX//alMGjuywzI	CUSTOMER	t	t	2026-10-31 07:38:22.092443+00	2026-10-31 07:38:22.092443+00
a893e1ee-721a-44ca-9df8-94fda7aa25d9	cust2_959162@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$cILn8XUwRTZHGDYQb+gccw$Kz04gEr7gYprK3mzKa7VWSziYFsVEOVBOBHQAZRIX7c	CUSTOMER	t	t	2026-10-31 07:38:22.582402+00	2026-10-31 07:38:22.582402+00
65b91682-558b-4f4c-951d-539434c14ef3	iso1_cf17b0@demo.com	Customer One Profile	$argon2id$v=19$m=65536,t=3,p=4$+uMgRSTy+4I2RQshlg01Ww$V2UehOvIqXteZx4SfYoXt4OJQJnGCf9A803eZRns6to	CUSTOMER	t	t	2026-10-31 07:38:22.658939+00	2026-10-31 07:38:22.658939+00
af4e9265-bea5-47d4-9c2e-a362271ee196	iso2_cf17b0@demo.com	Customer Two Profile	$argon2id$v=19$m=65536,t=3,p=4$6Rl+5aHidJXzYh+n7G5Rcw$ma8cygJQLivbFwIpGjNDDvDYggVH9DTX4kQN8RNWjE4	CUSTOMER	t	t	2026-10-31 07:38:22.753581+00	2026-10-31 07:38:22.753581+00
d98b42b7-e16a-423d-bcbc-ec6e20ca4ac6	cust2_bb5d80@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$XnVfaqjx9nvVUMORw5v0hA$w//gKhVkGorlbFCZ/d66hzE8sbhB8YXU313BkxjOX6U	CUSTOMER	t	t	2026-10-31 07:38:22.894334+00	2026-10-31 07:38:22.894334+00
2065ee99-0eef-46c0-9ecd-ad096a9853e2	cust2_c0e776@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$CK88pMnDh/65H0qqvNcIxg$p1UtxqhRVSn8v1QfBTJaOD5yMbBeIrS5i+uRMjm0o7c	CUSTOMER	t	t	2026-10-31 07:38:22.989087+00	2026-10-31 07:38:22.989087+00
c22eb824-9d62-4962-8be8-1833cdd8ebdc	neg9_ba08be@test.com	Neg9 Cust	$argon2id$v=19$m=65536,t=3,p=4$5EYF2A9OEVKzvskgCF1Qqw$C7D/UpCJioQq4wKMmngEIoUK5wiZYNKdgIq+MaHrUYI	CUSTOMER	t	t	2026-10-31 07:38:23.1962+00	2026-10-31 07:38:23.1962+00
dd33a8aa-2d10-4ea2-91f8-045bc99db960	customer_d5454a40@example.com	Test Customer	$argon2id$v=19$m=65536,t=3,p=4$55Y1p7ApVxZYblmCGB3Glw$epcIpYjnKhP+xy7wSEBprfEwFU48jMWvVw6C/WgsCkk	CUSTOMER	t	t	2026-10-31 07:38:30.179672+00	2026-10-31 07:38:30.179672+00
fc4eae69-efe6-4708-8c47-2aabba7084a6	dup_f5928f44@example.com	First User	$argon2id$v=19$m=65536,t=3,p=4$Zmhm4tBsWKLiAffHHm5vMA$vmiX6CL6XZC6+drmLohEtb/J1beT/6Xw8SC7TgknxBE	CUSTOMER	t	t	2026-10-31 07:38:30.283603+00	2026-10-31 07:38:30.283603+00
1d904ead-64da-41dd-8f28-84d07d2d29fa	login_user_5b5392cc@example.com	Login User	$argon2id$v=19$m=65536,t=3,p=4$Uur38x2p4guKdXB6+tL0og$/N19x4mRl4h/2r7rj59m852EWG/HqlZ90E16gaHGemQ	CUSTOMER	t	t	2026-10-31 07:38:30.385422+00	2026-10-31 07:38:30.385422+00
47723f47-a83b-49e9-9544-0636e3b2e6b6	rotation_53c86ba9@example.com	Rotation User	$argon2id$v=19$m=65536,t=3,p=4$ecHpsKUIcmqVdp3zyq7ykA$yypOSA5zEQlCDOjKDWd7+LAqnoVTbeEZQ456SoPeK+0	CUSTOMER	t	t	2026-10-31 07:38:30.610225+00	2026-10-31 07:38:30.610225+00
b52074b1-7721-4486-aeb4-afada943f5cb	reset_2229b567@example.com	Reset User	$argon2id$v=19$m=65536,t=3,p=4$UBbxZaOqmBTjs0vhyBtP8A$8H5dqw70EKjbM1tnsHumZGKOZnl2NHMEUKRkSTfMBNY	CUSTOMER	t	t	2026-10-31 07:38:30.758689+00	2026-10-31 07:38:30.887169+00
34f73287-5b8b-4edb-ab26-59b47bf6a813	multi_reset_1666611e@example.com	Multi Reset User	$argon2id$v=19$m=65536,t=3,p=4$WUS21bopvzJvlxNiP8BHyA$ZDYSdtSYEtKK0IkAAS+BxUgSW8jzBF2l7Usa0d9yKTk	CUSTOMER	t	t	2026-10-31 07:38:31.106245+00	2026-10-31 07:38:31.106245+00
6e6cdc35-89ed-4d73-aebc-71bf44d5af09	logout_no_jwt_cde5f8ca@example.com	Logout User	$argon2id$v=19$m=65536,t=3,p=4$ap7z0mBFvoSKjHE5/JA/yg$FpTOcX1oiAlxPRV0gq3yWpT0ijejC9vAMPEEZfR1RTU	CUSTOMER	t	t	2026-10-31 07:38:31.287301+00	2026-10-31 07:38:31.287301+00
c02ec594-7dd0-47ed-9b05-edae1ba4586e	cust2_fbd043@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$be70V3rqpmM0ellZ0GSHfA$1C1txsqzWOgTMztlRxozotjIReXSVatbs5n/0U2vWlw	CUSTOMER	t	t	2026-10-31 07:38:31.407715+00	2026-10-31 07:38:31.407715+00
fb9db2a2-56bc-409c-aeaf-a5401434e4e0	enterprise_dd0d05@brightloop.io	Acme Global Corp	$argon2id$v=19$m=65536,t=3,p=4$Pd5P2wPoE8WQAIHB/5exaw$VMba7FSHZvswP6dA1gtLqX4lN3ajN9ZEms3PN97J5Iw	CUSTOMER	t	t	2026-10-31 07:38:31.508129+00	2026-10-31 07:38:31.508129+00
ddd15917-4d2e-4556-be44-cdce37a5e639	cust2_1429d0@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$WqnvV+kQtjgj3IOh/m0neA$eea6AwujUem8TeTEStdRSxpYjDOLy1YHfxD8iHXycIE	CUSTOMER	t	t	2026-10-31 07:38:31.66374+00	2026-10-31 07:38:31.66374+00
49231c18-1d6e-448d-9731-e17a69793fc3	cust2_a1489c@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$urYSb1zJcN3BYCUONZzjag$1PH0NB/gjDR6U9Fe+LyhC2JbZ8Q7/huS6XmRBCWRUj4	CUSTOMER	t	t	2026-10-31 07:38:31.837477+00	2026-10-31 07:38:31.837477+00
4384a35d-df7c-4f4e-a7f1-765a7be25001	cust2_5190b0@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$i6mJgS0p+ZXE9GypyGNWFQ$F0J2v8T7vGmS0URuNUmbTJIzOgE45PY0ufZ769/ST58	CUSTOMER	t	t	2026-10-31 07:38:32.517393+00	2026-10-31 07:38:32.517393+00
4fab871e-76a3-44d9-b79f-cfa00204da30	audit_corp_4492ce@demo.com	Audit Enterprise 4492ce	$argon2id$v=19$m=65536,t=3,p=4$yqF9Of4Jkc0m6wBinLl5wg$/k2uU1rxbl6HYwb+IoBWE6EsqQ0Mmu75rU4ost8xHFw	CUSTOMER	t	t	2026-10-31 07:38:32.596675+00	2026-10-31 07:38:32.596675+00
f2bcc2ce-0a00-4553-9b8e-7c6781d96c32	cust2_cca322@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$KHeqwNZyZTA+fMmG7AfJuQ$h+b42sRqWTW4lKREvDQtWHjEJmSFJk0pQNW0DohwqMY	CUSTOMER	t	t	2026-10-31 07:38:34.325987+00	2026-10-31 07:38:34.325987+00
88f37654-643e-4bd2-9dee-3ca6a2161e0a	dup_8d6cbc@domain.com	Company Alpha	$argon2id$v=19$m=65536,t=3,p=4$8wP71YmOIdxZxFRJ8h0erw$LB2mNJEII9BwK7TjLqHF0wfhykS6jq9MK0cTEDamSFw	CUSTOMER	t	t	2026-10-31 07:38:34.407562+00	2026-10-31 07:38:34.407562+00
e18217b4-a84c-40f1-afef-107b2b8765d9	cust2_648c75@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$MychsDTVvmMU75ZC/jblzA$A2fFGYEh+ZDY5Zy3h9IoT2FXaHdxKJ7DTtnHQfPYhb8	CUSTOMER	t	t	2026-10-31 07:38:34.521633+00	2026-10-31 07:38:34.521633+00
91efbe36-b71d-42fd-b7c3-e0b6d794f087	qty_62aa14@test.com	Qty Customer 62aa14	$argon2id$v=19$m=65536,t=3,p=4$UTZETmqOw75KrseJuSaN4g$vQ2gv2lbM1Li/7zvzYJ6sioQdl2vqMXmGuofk6tVbe4	CUSTOMER	t	t	2026-10-31 07:38:34.721226+00	2026-10-31 07:38:34.721226+00
ca78ecae-d8c4-4686-bc2f-8b6e5ae21c8a	cust2_f71987@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$ybX996LChHO0BsYYrw0+oA$yKn7ZkijpWy9pSrAxIC06FCxwhRlbyOk1g5AlbTxsPQ	CUSTOMER	t	t	2026-10-31 07:38:34.880254+00	2026-10-31 07:38:34.880254+00
c389cf50-e0a6-4e9d-902d-dbde029ae58a	draft_185244@test.com	Draft Tester	$argon2id$v=19$m=65536,t=3,p=4$mf7kLu3/bRiUsML6zAmlTA$SkyJciUz2nwtw1cEqWUUdxEI6ZzJFOIYaMgEEzHNEjk	CUSTOMER	t	t	2026-10-31 07:38:34.986736+00	2026-10-31 07:38:34.986736+00
4b747974-2075-4e24-a029-609f26551d6d	cust2_87732e@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$Fwtzci++1xM0ghSN61dGkQ$x34M/aqFh4nnr7I8jRnJcUiQ/vAFSXKaAjxXtRRs4zs	CUSTOMER	t	t	2026-10-31 07:38:35.108068+00	2026-10-31 07:38:35.108068+00
90a4e297-4cad-4ec5-b65f-a0653eff9316	ovl_a17ec1@test.com	Overlap Cust	$argon2id$v=19$m=65536,t=3,p=4$UchmFkK4Z9/gAaeCg1QKFg$Kck2Wc5NDvtmgUpXXtRK/AUL1aYHW5xnMpKsqf2oeiA	CUSTOMER	t	t	2026-10-31 07:38:35.316262+00	2026-10-31 07:38:35.316262+00
09c88d64-cb48-4d7c-a836-19dce69e7b19	cust2_5dab8b@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$5fEZKKNeG6/LIvzXfltJZA$c1S/6cTWwma8jdcKtrC8YMz4GZzE06uge55p2uRf8DU	CUSTOMER	t	t	2026-10-31 07:38:35.791859+00	2026-10-31 07:38:35.791859+00
23c16343-1cb7-40a8-9f3d-1f12a6efad59	cust2_34c4a7@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$Sx6xY3d6uFAFsydzPCVUGA$Y5PoeSqOXJRDezSwKTIE5ozHkciPzdGe5/i3eICpM6I	CUSTOMER	t	t	2026-10-31 07:38:35.895638+00	2026-10-31 07:38:35.895638+00
889eda05-ce54-41a7-b84f-f6a34f2875e6	op_625c40@test.com	Overpay Cust	$argon2id$v=19$m=65536,t=3,p=4$OpK0BmAIY9iy2FN1OPE+tA$faPJxjujACPqiBwI3LXXpj/qYavqWBEhSqPJzAcxQnY	CUSTOMER	t	t	2026-10-31 07:38:36.108204+00	2026-10-31 07:38:36.108204+00
ef6a32a5-8afc-4018-9eab-b4619d2bb3b0	cust2_5ee860@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$VStSGDMHQ6QctmfSHDYL7A$bzIT2wxXvfwfN0lvIa2pUEZyUulHc7Adu6KHv23umlQ	CUSTOMER	t	t	2026-10-31 07:38:36.565962+00	2026-10-31 07:38:36.565962+00
e33b5e88-21a9-45d1-b952-d136248b7c66	iso1_a2be66@demo.com	Customer One Profile	$argon2id$v=19$m=65536,t=3,p=4$EiIb71P97HZbyTKz9kFTrQ$kHHNaWfAL8UUE5ErISY4wQKKgQZQwLwwtXYdiNlh9BU	CUSTOMER	t	t	2026-10-31 07:38:36.728894+00	2026-10-31 07:38:36.728894+00
6f4196d9-dfc0-4b52-a861-f008e3abf5d1	iso2_a2be66@demo.com	Customer Two Profile	$argon2id$v=19$m=65536,t=3,p=4$6aMnou8CzCrU5Yy82YCwkg$xXb3EN+U5eN2pZs5Y5dtROcEXUP3NVW+a0AzcoGL2i8	CUSTOMER	t	t	2026-10-31 07:38:36.8174+00	2026-10-31 07:38:36.8174+00
2e941f15-914e-4138-8665-e2501da0ce58	cust2_b73ef6@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$NBWPxhR0rZDpszIvRQ6+Zw$ryegJVTXrv5G9hJ7VJ+uQDruHyYT9Kw0DGpX1JuN0ec	CUSTOMER	t	t	2026-10-31 07:38:36.939557+00	2026-10-31 07:38:36.939557+00
e5f9da57-ccc5-43a2-9d7d-a04e06f85c76	cust2_76b14c@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$OzAw8N6Wa27bg7YrbWppKA$ibMFw70ere60Jjrb4gQBrYBfXPvnkB9JawHrqOFtTYI	CUSTOMER	t	t	2026-10-31 07:38:37.027579+00	2026-10-31 07:38:37.027579+00
9d8e82ae-c214-4448-905b-a63fdf530a27	neg9_2bacb8@test.com	Neg9 Cust	$argon2id$v=19$m=65536,t=3,p=4$/qOHhxmHEhJ86/PR9CHEVA$neliCXQkU4YaMR1hRj9vW5xOnTXLXXgXUfNuScpNZJ0	CUSTOMER	t	t	2026-10-31 07:38:37.240809+00	2026-10-31 07:38:37.240809+00
70d8c8d4-dcf9-43c1-a7c8-eb1ee89645e3	cust2_4634fc@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$ny9hDiqYP6vMVuXqpYIiwQ$qIu6KUU15A8LarbbKR54HMGPz8GJfmDsQaBAtrNJsas	CUSTOMER	t	t	2026-10-31 07:38:38.092827+00	2026-10-31 07:38:38.092827+00
aff0484e-01ce-4d30-b1e8-4912a70980ff	billing_db7e4@infosys.com	Infosys Corp	$argon2id$v=19$m=65536,t=3,p=4$ybMLwhXnCelz75aGeLBRPw$TD63g8aQ6+JKrxdmA8hcyX9JHldj+nBOriI7PjSS7PA	CUSTOMER	t	t	2026-10-31 07:38:38.300921+00	2026-10-31 07:38:38.300921+00
04a60199-bbbf-4dfb-aa69-d750e06ae714	cust2_c342ed@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$/zcu4qTy/BgAC3fWzle83Q$XOJV+YU9ia0qtrd7JVvbTXwqq1T89leBpbn22ADiqPw	CUSTOMER	t	t	2026-10-31 07:38:41.587787+00	2026-10-31 07:38:41.587787+00
1a8e2f4a-a11b-4bed-a4ea-d7273cf7836e	tata_63c79@tatatech.com	Tata Tech	$argon2id$v=19$m=65536,t=3,p=4$3wBOcIEy0jl+Tfk8PawD1w$AxaaQxaXGD8LVVqUNFgzAJmf+/OATYRd5AOz3Zpn7/4	CUSTOMER	t	t	2026-10-31 07:38:41.796065+00	2026-10-31 07:38:41.796065+00
13d35249-411e-449c-b092-9fd70812906d	cust2_d51356db@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$HKYdCIJAw2T3qZNstIeQWA$15RC6MobcAAO7pR21YXnh938XZAJt23O4IX1BzY+Ztg	CUSTOMER	t	t	2026-10-31 07:38:42.304818+00	2026-10-31 07:38:42.304818+00
80dc8efc-2bf2-468d-84a3-7d3fde065492	staff_1bdadc01@example.com	Support Staff Member	$argon2id$v=19$m=65536,t=3,p=4$cR0pnl6IfW2F7yVbR1Sftw$DBQGYTUaxHnpuknXJmRaf7e4yDo0JxF2RPaPSCYwgOQ	STAFF	t	t	2026-10-31 07:38:42.443939+00	2026-10-31 07:38:42.443939+00
a7a24781-d0b5-4d15-bb0d-c952a1ccf9d9	cust1_c7e574ed@example.com	Customer One	$argon2id$v=19$m=65536,t=3,p=4$Ew9SZpJ1MKRlIKBtPSJ9xQ$X48sT7BxcHmtDWldh3J+idkLHjfYSZdxB+Yl35udIrA	CUSTOMER	f	t	2026-10-31 07:38:42.227976+00	2026-10-31 07:38:42.675896+00
b84bc79d-7fba-4cbc-b4df-2680463dc2f3	catalog_cust_c51f8b@example.com	Catalogue Customer	$argon2id$v=19$m=65536,t=3,p=4$THiwtjZ2mR7rHZRj0eLZsQ$58fWGUDlPHXgm3ANvOUOvLjtZGGU5wquAyTrkL8CNUM	CUSTOMER	t	t	2026-10-31 08:23:57.24956+00	2026-10-31 08:23:57.24956+00
755ecc05-8b2e-4094-b235-d22c1ae31dde	starter_corp_aff995@example.com	Starter Corp India	$argon2id$v=19$m=65536,t=3,p=4$O3Jwo1g2BEUPZO+PkWzh4w$gh03LYU/GiTE+sx5GzMWVre6L4oAHagYpSXEPO1KpzQ	CUSTOMER	t	t	2026-10-31 08:23:57.688377+00	2026-10-31 08:23:57.688377+00
b52828e4-2c04-4936-bde5-6760082942f3	customer_04132d57@example.com	Test Customer	$argon2id$v=19$m=65536,t=3,p=4$X8WujWyOX9wEzX2lqwVC2g$R33hbREuyYydRUN17AdXsjCXCgm3njpngDqgHBjzNpg	CUSTOMER	t	t	2026-10-31 08:24:06.700147+00	2026-10-31 08:24:06.700147+00
451b08f3-8939-4a62-a424-5ee548a6a453	dup_effa0801@example.com	First User	$argon2id$v=19$m=65536,t=3,p=4$4aM06uWQMoQ5uo19gvqIwQ$HNIQoLJFrLCn39DdIgVD3NJSl6e1BEY5dM73zoLbWgI	CUSTOMER	t	t	2026-10-31 08:24:06.814165+00	2026-10-31 08:24:06.814165+00
1bf8ea9f-6b06-4da9-be91-3c8731819498	login_user_a3fd2c4e@example.com	Login User	$argon2id$v=19$m=65536,t=3,p=4$3S6x6OqqUszTuhoMGU5SXQ$M6G/w0xk+FTHli+6yaz0TmJsF6rkfS10ZmScvNidLnw	CUSTOMER	t	t	2026-10-31 08:24:06.92716+00	2026-10-31 08:24:06.92716+00
f8153125-3c20-42d4-ad8f-09c161b7bb5d	rotation_1da38672@example.com	Rotation User	$argon2id$v=19$m=65536,t=3,p=4$EEJWRtIH6oJIWG7rbSgnyQ$RBKtx7gQHND97gGf9Q+U+gQMxDiDptoPVSEPcC2tCMo	CUSTOMER	t	t	2026-10-31 08:24:07.25796+00	2026-10-31 08:24:07.25796+00
ebae68dd-3887-4b84-9db4-99d2fbbdb3a2	reset_75d9fc69@example.com	Reset User	$argon2id$v=19$m=65536,t=3,p=4$6JsEp0P/goMOgTvt17HKTQ$UNslnVk+p9TXgJvtg5klfDZ4YIoXadvoLQ7QlNfayVs	CUSTOMER	t	t	2026-10-31 08:24:07.436075+00	2026-10-31 08:24:07.578562+00
234f60f6-3d4d-4c10-80f6-ffe716741112	multi_reset_93dc6051@example.com	Multi Reset User	$argon2id$v=19$m=65536,t=3,p=4$e3XGxmQeW4+PyTJw6FLoig$IvNHtwiO0r8zQAdFeLKSSgf97PY3Kcw0vBRtQ4VJvf8	CUSTOMER	t	t	2026-10-31 08:24:07.845612+00	2026-10-31 08:24:07.845612+00
9da9137d-e784-4775-b856-e577b39a1e06	logout_no_jwt_037afcef@example.com	Logout User	$argon2id$v=19$m=65536,t=3,p=4$+qoPP2dZIjlSpgltA7hNYA$WrbqpcLS9jy0cPADbWLPxv8lxuRrItEoBt3wcOAk4nQ	CUSTOMER	t	t	2026-10-31 08:24:08.061916+00	2026-10-31 08:24:08.061916+00
44bc6514-544b-4e38-963c-a0a30017da4c	catalog_cust_6b6abd@example.com	Catalogue Customer	$argon2id$v=19$m=65536,t=3,p=4$yJUpaQPnZBIekzp8zubWzg$3OifsaRfsW6rx2O5q3TnQ0ax1OdjttMb54WkeHfVAAQ	CUSTOMER	t	t	2026-10-31 08:24:08.81289+00	2026-10-31 08:24:08.81289+00
589b2d88-254a-488c-8a51-2a4d18b192c2	starter_corp_4ead21@example.com	Starter Corp India	$argon2id$v=19$m=65536,t=3,p=4$aH5SeeFzGBmrS3/5lwkGhQ$W+lg9YSWrzECstk5bpEjIIFGhP2UXa7yCyPgegSjkrU	CUSTOMER	t	t	2026-10-31 08:24:09.098736+00	2026-10-31 08:24:09.098736+00
6247b467-760c-4c47-a017-950eff6ac9eb	cust2_f2c64c@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$/3oe8y1WYKz5YulGIl5rOA$wXRuBsZSNWqKn1j6oFuGitmuZ/Wm9/4aKx2lNN39NQg	CUSTOMER	t	t	2026-10-31 08:24:09.604369+00	2026-10-31 08:24:09.604369+00
5298e1ce-ccb5-43ae-8827-e4f1b219d6f6	enterprise_2f6bd5@brightloop.io	Acme Global Corp	$argon2id$v=19$m=65536,t=3,p=4$oOrsOsGsiLZM6/i9DrKClg$jydYgOf+SY4tRRBHyc/4r3zrJLwcahVQEveVy1TpArk	CUSTOMER	t	t	2026-10-31 08:24:09.709897+00	2026-10-31 08:24:09.709897+00
f26ddab9-1b76-4053-affc-f3c0f11e8e1d	cust2_32b760@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$3jjHpcCKFkNe+ft2HMFZhw$6wlBPIaLK9PEN88IqFtwJNrvjVf0WGR+0IkLsEMUWLU	CUSTOMER	t	t	2026-10-31 08:24:09.930224+00	2026-10-31 08:24:09.930224+00
1449458a-8de0-4a8e-83d6-637062300cbf	cust2_9dd96d@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$T+JFlEmCGhidBh3M2tQMbw$LxoPpA/TKnQqXYV2wSJjLsXzb3caFENjv7o/U+90adU	CUSTOMER	t	t	2026-10-31 08:24:10.161175+00	2026-10-31 08:24:10.161175+00
118f84c0-bc0c-4221-996f-f812367900a2	cust2_ed54b1@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$H489XuOWmuTHnzMyF6tIMQ$bitD0RxASc8PJ0waMyrle+sHpkUvruGV2Z4e7iBM92E	CUSTOMER	t	t	2026-10-31 08:24:10.961472+00	2026-10-31 08:24:10.961472+00
f74ba7a3-179b-484c-ac47-f96d0e199cdb	audit_corp_8ebd0b@demo.com	Audit Enterprise 8ebd0b	$argon2id$v=19$m=65536,t=3,p=4$n4Puzs4RN01kUjrtLTUd9A$d9IvtwS4c0piwCIJdlH+Pz+WCF0IwybPB+vXAabdEK8	CUSTOMER	t	t	2026-10-31 08:24:11.075402+00	2026-10-31 08:24:11.075402+00
f97a56f0-a1f1-4ac0-be2d-dbb01237f707	cust2_033fe1@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$d/XoOKB4TJW1rY6DROo55w$V4O4OQo9vHZAl8Jk6f3WfdaOK+/hJQiIZQ+Rp+Fe5Fo	CUSTOMER	t	t	2026-10-31 08:24:13.238449+00	2026-10-31 08:24:13.238449+00
4f043cb7-ad10-4a07-8093-4a7e81edcc1c	dup_5552ec@domain.com	Company Alpha	$argon2id$v=19$m=65536,t=3,p=4$o1bdCDC2YpQT2xN2aKRrPg$FpNAqqcTn0WEUBD+RQj9vTdfkzrDsdjtZhDRQrj+HOc	CUSTOMER	t	t	2026-10-31 08:24:13.328596+00	2026-10-31 08:24:13.328596+00
7af0c475-9577-46c5-9a33-adbc82517d1c	cust2_50bdac@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$gypJ3I8TCAS51FBLkW7Yeg$qfcgsO2KQLtvlWB5+n0Y+FnhkRbTY5NXenRcKuNHBNo	CUSTOMER	t	t	2026-10-31 08:24:13.456452+00	2026-10-31 08:24:13.456452+00
d478a015-b108-49b2-86ea-6f6f31ec31c6	qty_16e322@test.com	Qty Customer 16e322	$argon2id$v=19$m=65536,t=3,p=4$Kv3D6ClXpufG+wE72gAoyA$Y6bR/0NQqSOAyhWKINDmMXn39K5y3aMYXsBrYK/2UDY	CUSTOMER	t	t	2026-10-31 08:24:13.677608+00	2026-10-31 08:24:13.677608+00
edcf7492-e04a-4b91-b491-379b837e3f74	cust2_cb48aa@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$S3UqHpCcbkbhpgUyIbP4Ig$q0UrqugxQAxTiCu0X7MDzs1MCdfWkZZtBg2/INYsQ1E	CUSTOMER	t	t	2026-10-31 08:24:13.858289+00	2026-10-31 08:24:13.858289+00
bff68c14-6701-4be2-8a60-ba9d40b78c05	draft_4e9051@test.com	Draft Tester	$argon2id$v=19$m=65536,t=3,p=4$sMeJY7yTASGbuRNg+rIbZg$bWzdLtDcGoDLm+rttD728MgMfyalaP6tJDN/ehOf2iQ	CUSTOMER	t	t	2026-10-31 08:24:13.985849+00	2026-10-31 08:24:13.985849+00
3536b718-1f75-440b-8c90-d32cada3887b	cust2_c5aff2@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$zU3KWYqdS4bAYAUfsR3lmw$6fHWB7F+I/f6uyOWmATI16YMB1+uX7f87QHsF3+thoE	CUSTOMER	t	t	2026-10-31 08:24:14.134492+00	2026-10-31 08:24:14.134492+00
78d99fdc-1cd2-4bc3-be11-c53f8128703d	ovl_b22d76@test.com	Overlap Cust	$argon2id$v=19$m=65536,t=3,p=4$AVNJD8cpHwcxSYfNxq6DHA$8LFvYLM6J00lX+P+Y6/Sxuctsr738Y7pVIq6wk2ZvqU	CUSTOMER	t	t	2026-10-31 08:24:14.381543+00	2026-10-31 08:24:14.381543+00
b75a1468-7270-4b2a-907e-700c60afef43	cust2_61680b@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$iTDqozDqmfpm43fbhAHwVw$gla7LvbfQiOkOFEE8F9wNxn3AJRpn2e8P0oJBvABUcQ	CUSTOMER	t	t	2026-10-31 08:24:14.916976+00	2026-10-31 08:24:14.916976+00
5c4f9c0a-5974-4b39-90bf-efd51a5d4151	cust2_95e166@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$mC7InLlCTMfohrBVr+EopA$80vsgAhM7FXWYAodUjed7ZQ4zsnu5E5HG7iTn99kPEw	CUSTOMER	t	t	2026-10-31 08:24:15.022174+00	2026-10-31 08:24:15.022174+00
261631bd-d1cf-446a-9f07-5b60a4dc8aaa	op_dbfa6b@test.com	Overpay Cust	$argon2id$v=19$m=65536,t=3,p=4$wvF0AN/8oolSXQ1FFHybIw$iR7Nrdcz6giNwJg1Fxwbyw5a7Iqy0FI1NJ97MddbOP4	CUSTOMER	t	t	2026-10-31 08:24:15.282126+00	2026-10-31 08:24:15.282126+00
fcaa1a3a-835f-42c5-b41f-813a330e6deb	cust2_ae2cda@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$s1YGUvJEIzX4WHUG+eg3uw$fpK++v7h9Vv7NPcZWfgyY8H+lr6lrKcyeQizfNexB4I	CUSTOMER	t	t	2026-10-31 08:24:15.999815+00	2026-10-31 08:24:15.999815+00
98cd3f6e-4144-4803-8bed-4f58edc93bfc	iso1_f46fbb@demo.com	Customer One Profile	$argon2id$v=19$m=65536,t=3,p=4$l3xax3G6ep/9biwXhzB5pw$fISTZILZefU7VXsR50qMTZZQih0Mddj40HkOK6xw2RA	CUSTOMER	t	t	2026-10-31 08:24:16.16648+00	2026-10-31 08:24:16.16648+00
e5f4628a-254f-4743-900d-c4c5848dc4c5	iso2_f46fbb@demo.com	Customer Two Profile	$argon2id$v=19$m=65536,t=3,p=4$De6EyrmM1MXUdz7PKTvQPw$pCJ1e1NH7odpTVP3JJRAQrM/dkXBUEmLfh/hHvZbxyI	CUSTOMER	t	t	2026-10-31 08:24:16.282343+00	2026-10-31 08:24:16.282343+00
ab158edb-4e51-43de-93ac-5a9b3e04d1af	cust2_3eb031@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$EyPJoeFODXG3fSTLU2+jZw$uwR7qq/Ya7yZ5XejIUH0nXGQDnp/dmqERpBpPfUvU9U	CUSTOMER	t	t	2026-10-31 08:24:16.416742+00	2026-10-31 08:24:16.416742+00
904b5e4a-ed30-4a3f-bf9d-44d306223961	cust2_65333d@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$IGt517f16DrY4sXgG+p5GA$uisHeDhWSBIjV3uBteef4fnf3wz65Fkke6CXMEuPzYs	CUSTOMER	t	t	2026-10-31 08:24:16.532953+00	2026-10-31 08:24:16.532953+00
9c032f6d-4d9c-49c6-be87-6f45c6528780	neg9_7559a3@test.com	Neg9 Cust	$argon2id$v=19$m=65536,t=3,p=4$I+iDS+2W5uQSCOdkcnNB+A$0k/tbRP25RPtseYzIlBh0DX4VRrdYj6E4xsQPrVtndc	CUSTOMER	t	t	2026-10-31 08:24:16.755764+00	2026-10-31 08:24:16.755764+00
542a8cad-e4a2-4dec-942a-f6f77ad179d0	cust2_4f5376@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$CcgV3JdpwLqlZlOkl80E6A$qAwkXHE5izuGY24YT2Rs6HHmLTPsEv0gj34PBaLaO1o	CUSTOMER	t	t	2026-10-31 08:24:17.657843+00	2026-10-31 08:24:17.657843+00
580e2b4f-9f9e-4b88-9f6d-bd0e4e68b826	billing_9a5fc@infosys.com	Infosys Corp	$argon2id$v=19$m=65536,t=3,p=4$j31oOk3I/ladXdIhWqWrEQ$RNw54ynaODxyooFESOZ/OgmACUO7aRrC6HRbkFtYgh0	CUSTOMER	t	t	2026-10-31 08:24:17.878602+00	2026-10-31 08:24:17.878602+00
f634f462-82f9-4c0d-a79a-4b8973f07689	cust2_c94005@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$ovm+48DLUU0oxxIzR/vK7Q$aFfloNHGDyb3WTgM7AH49UUZxFjoLVl+zLMDtlzh/To	CUSTOMER	t	t	2026-10-31 08:24:21.172967+00	2026-10-31 08:24:21.172967+00
9535692d-19c4-45bb-ab16-3053ea78719a	tata_f6526@tatatech.com	Tata Tech	$argon2id$v=19$m=65536,t=3,p=4$6o2ZQgyFXnYs4I9KI1VU1w$XIVPcF6ImZ6JOz0Bghnnlx0adudVCST2uvArB6R4nFE	CUSTOMER	t	t	2026-10-31 08:24:21.397201+00	2026-10-31 08:24:21.397201+00
cdacf1a8-1514-426f-a2d2-ec546983efdf	cust2_5ddec5f9@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$oJ/Lbn2HvrQEQqszcp7sog$QWl7KOw0lYaoyhqY0dDxxWz+DPfFt+BPfw5F+POAcdQ	CUSTOMER	t	t	2026-10-31 08:24:21.972496+00	2026-10-31 08:24:21.972496+00
5c45be20-2ccb-4a5c-a8cd-97cfad043ed8	staff_6da5635c@example.com	Support Staff Member	$argon2id$v=19$m=65536,t=3,p=4$imuzMeabhRGP+SeDF/6QTQ$qXmIeGZxp/zJy+y8HcPkhxVDyuHbnSTTuVhy9924mw8	STAFF	t	t	2026-10-31 08:24:22.124108+00	2026-10-31 08:24:22.124108+00
d9cf23a9-f82e-4101-839c-2dad7bc4dbd4	cust1_a69ddd16@example.com	Customer One	$argon2id$v=19$m=65536,t=3,p=4$HibZ2T2O8mPbGCDDvijNfQ$CnSdvx8Nbapf2MbE8Q+ugmaKvNhvL11pc3vqQHx9ZOQ	CUSTOMER	f	t	2026-10-31 08:24:21.891528+00	2026-10-31 08:24:22.35312+00
50ec2373-3a67-4c8b-b33f-36a47643a3f2	catalog_cust_7b58f5@example.com	Catalogue Customer	$argon2id$v=19$m=65536,t=3,p=4$QaMKOdZo3+mQdHKbRvOifg$mk8UKHMFUJGVQj0IYEGFlLNZ6wk81BWGOrRqtZkpQ4I	CUSTOMER	t	t	2026-10-31 08:27:24.335031+00	2026-10-31 08:27:24.335031+00
d5006a51-cf62-44de-84be-7524ddd06dca	starter_corp_9ae423@example.com	Starter Corp India	$argon2id$v=19$m=65536,t=3,p=4$OWsBk/tOs6Q8Zuj8mZSpIg$OinkJlmlPqXFij7JtBWVsJLYmioN0cDbG1mLtTzTC24	CUSTOMER	t	t	2026-10-31 08:27:24.62056+00	2026-10-31 08:27:24.62056+00
13cd1286-ab5c-489a-9999-083280c82eae	customer_90929c8f@example.com	Test Customer	$argon2id$v=19$m=65536,t=3,p=4$wFh0VNc4qOPLHcy0tp65+g$mJMWq8cppXLMcqX4m+7Q+8ZJRosWUtalBfZCSD+2wKI	CUSTOMER	t	t	2026-10-31 08:27:34.318087+00	2026-10-31 08:27:34.318087+00
54190478-8281-4812-83fc-5079ac387073	dup_77bb179f@example.com	First User	$argon2id$v=19$m=65536,t=3,p=4$LdJTS5upkJRXkaywZMkmFQ$XMOjz2vg8mGM/aL4ZFWdQR81m3xjvgg5HbSyHCPLfu8	CUSTOMER	t	t	2026-10-31 08:27:34.432848+00	2026-10-31 08:27:34.432848+00
b27cd89f-beef-49c0-85af-2bc3952bd5cb	login_user_29b46b27@example.com	Login User	$argon2id$v=19$m=65536,t=3,p=4$MyERHV+ru8RtUM7BrPLFhQ$Vq92D51Qh2XH8I7SPLjOtv9I4wH0Q89Kir3xaFLW1og	CUSTOMER	t	t	2026-10-31 08:27:34.546948+00	2026-10-31 08:27:34.546948+00
373dbb4e-b9d7-4ad0-874c-20cf17ad92e5	rotation_1c7d18db@example.com	Rotation User	$argon2id$v=19$m=65536,t=3,p=4$Ros1ZGVzm4+y0GqH25pSYw$XZ9EfiSfpe0L9MIssfzsL8B2m3K/hddK7ikHk/diMvQ	CUSTOMER	t	t	2026-10-31 08:27:34.789575+00	2026-10-31 08:27:34.789575+00
886216f8-3ff4-4384-aa44-ea5894745b0a	reset_3961d067@example.com	Reset User	$argon2id$v=19$m=65536,t=3,p=4$tRacjyrhZkklknNQDUqq2A$K9kjPzyEd3JkPyQlucNoafOmZMUNqFSWJp4WZsFU3oY	CUSTOMER	t	t	2026-10-31 08:27:34.943842+00	2026-10-31 08:27:35.076312+00
fa542889-8820-45e9-b9f8-b63d3f0e47b2	multi_reset_09a4652e@example.com	Multi Reset User	$argon2id$v=19$m=65536,t=3,p=4$r1TJ+JAfrI2QNHpsjxg2nw$EyCX7IvmvgbwMRE8vp/4hA5vZdWBCViCrpeB+jYM7+k	CUSTOMER	t	t	2026-10-31 08:27:35.308811+00	2026-10-31 08:27:35.308811+00
4de1e8d0-84d1-4e9b-a25f-08b8351c57b7	logout_no_jwt_01c4201f@example.com	Logout User	$argon2id$v=19$m=65536,t=3,p=4$LqklTZFs8ZLi7sgStpd1Dg$kTQUaYnJYw7bE4HZszpvGTel3c9K8d+7f8Rt/Ca8unI	CUSTOMER	t	t	2026-10-31 08:27:35.526273+00	2026-10-31 08:27:35.526273+00
09b6e483-f874-4975-9136-3eff437aa445	catalog_cust_722211@example.com	Catalogue Customer	$argon2id$v=19$m=65536,t=3,p=4$2XL6RsSz5bHQATVzK2Uoag$GHeL/299Z0MAB6sd8kZ8rpCtloZJrep5k3cl4vG8p+M	CUSTOMER	t	t	2026-10-31 08:27:36.121895+00	2026-10-31 08:27:36.121895+00
24c18ecd-5b5c-4e89-bcfd-91e486f86851	starter_corp_174d54@example.com	Starter Corp India	$argon2id$v=19$m=65536,t=3,p=4$xO3qix3FHpI2gAVZGRs3Lg$6Rjdh5BMBr5ggy86zdcsPTmqlf9Ptj25w7Uje48fr28	CUSTOMER	t	t	2026-10-31 08:27:36.402007+00	2026-10-31 08:27:36.402007+00
91b79532-170e-422b-8555-42315c8c14fe	cust2_a07bf0@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$LIzM164gNDatvfE0ZNXNjQ$c6/kl9Swks77OJ57E/lvLAbJEb6He4meAJqG0Ju+Tks	CUSTOMER	t	t	2026-10-31 08:27:36.80619+00	2026-10-31 08:27:36.80619+00
ec4aa706-03aa-4329-9b47-90b7b9a86ec2	enterprise_705c86@brightloop.io	Acme Global Corp	$argon2id$v=19$m=65536,t=3,p=4$+q1t4CACsh7Tp5xyHCpcdw$wovOawiZYq5tcp22ghURDErlJ9kNsYVOmDn61kfloZ8	CUSTOMER	t	t	2026-10-31 08:27:36.892126+00	2026-10-31 08:27:36.892126+00
36eeb24b-b026-4083-b530-6948b44e988b	cust2_4f1d96@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$YBz1ZO25f9glr0KInf4n3Q$thtwl1fxJf32Ilbs12mV1eEqrfR9x1cbocH6LinC+Zg	CUSTOMER	t	t	2026-10-31 08:27:37.036813+00	2026-10-31 08:27:37.036813+00
ef8a2628-be48-4571-8c9b-6fea31be105c	cust2_4e8542@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$1SkUgBeuNMvMWo+OJudr8Q$q58FqlAgH6I86USSKmPncQQXC2EXBt5U0Jq179BIkIs	CUSTOMER	t	t	2026-10-31 08:27:37.211552+00	2026-10-31 08:27:37.211552+00
5bca9386-0c8e-41fd-8842-0943f6560b0d	cust2_e8586e@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$2jaW8v1wz2/N7SJB9Iic6Q$vTvEBPeGe+0TN4ZxXhXLxTKdKP9EicNB1Oc3UgLpMmU	CUSTOMER	t	t	2026-10-31 08:27:37.862133+00	2026-10-31 08:27:37.862133+00
1956e56e-40e0-4306-a5e0-4750074e63fe	audit_corp_7b522b@demo.com	Audit Enterprise 7b522b	$argon2id$v=19$m=65536,t=3,p=4$5ICXDfoWV8774bogPkE85Q$VCrLTjfmvXFH4n+b2GoW8LreNBBrOY6BerUQh4cHm2o	CUSTOMER	t	t	2026-10-31 08:27:37.942867+00	2026-10-31 08:27:37.942867+00
14d8b734-75b3-4d98-b9c4-4b35ec65a9b1	cust2_5a63e3@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$HkOQa7CYCuubva/Y9Dk7EA$ShtoZ/kqVZRqCBR8SL7PEYvggcg+YwtXXpENZsGoFSo	CUSTOMER	t	t	2026-10-31 08:27:39.687024+00	2026-10-31 08:27:39.687024+00
a6d97da7-0272-4a4d-a204-35eb9ad005b9	dup_c22620@domain.com	Company Alpha	$argon2id$v=19$m=65536,t=3,p=4$yM18Ky/myB/bqsye7Ky05Q$oUONDhWGFbwbA9e8ncgG6XitP9K/8l5nzVBrj5RvS8E	CUSTOMER	t	t	2026-10-31 08:27:39.766737+00	2026-10-31 08:27:39.766737+00
c35d52a6-5dbd-4fd8-bc37-f7bc785761a6	cust2_e67daf@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$rfpwitS3vtWCfJed8dDHOw$66HiwuWz6v9a79OJO0o6/h9wybyvMNqWP+717MOAzjk	CUSTOMER	t	t	2026-10-31 08:27:39.879984+00	2026-10-31 08:27:39.879984+00
2a81070c-8c42-427f-a85f-acec791d68c1	qty_f88c42@test.com	Qty Customer f88c42	$argon2id$v=19$m=65536,t=3,p=4$NC4q4Ha9/ItesHrO1NzzXQ$0QrVnGtRNH//fOTVggMk5+GYhAQ7HckXg8xIPTUCnZM	CUSTOMER	t	t	2026-10-31 08:27:40.078875+00	2026-10-31 08:27:40.078875+00
49091a8e-2ac6-4958-9637-8f01b6967b6e	cust2_532c6e@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$IxBAsLqaq8964yh1gi7zfw$F1so8g57NNFdKPzrH2UECsl3SuK87gEpb1bq9+ZavqA	CUSTOMER	t	t	2026-10-31 08:27:40.249004+00	2026-10-31 08:27:40.249004+00
b6200e86-7dad-4a30-8a00-f4b3254675f0	draft_5ecabe@test.com	Draft Tester	$argon2id$v=19$m=65536,t=3,p=4$sf7ljAmdG89fSWrPnKrJWA$HA3MbjOTpYbhaCJI1A20n9JYzgmvxfbSmA+joAkjnGo	CUSTOMER	t	t	2026-10-31 08:27:40.465799+00	2026-10-31 08:27:40.465799+00
9785ff5b-70f4-46f9-96f4-0fbd839f6d2d	cust2_4c7005@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$/UnOypJ6qrtlnMM3yRlOGA$Yq4KGYnb5nXSxRYs7bQ1EDazUrerCBYdXP+GjxEP94o	CUSTOMER	t	t	2026-10-31 08:27:40.596114+00	2026-10-31 08:27:40.596114+00
797544bf-e529-45a2-9ecf-d7135e0f3001	ovl_425051@test.com	Overlap Cust	$argon2id$v=19$m=65536,t=3,p=4$WUOaNPLbVkKMkK8qfhhX/g$a0j9GPrfJhCbIGW9hR/p2j2GNYu7BoiFYKRsAYx1pYg	CUSTOMER	t	t	2026-10-31 08:27:40.856128+00	2026-10-31 08:27:40.856128+00
262bdfae-9be0-4d68-9716-3ee472d7c457	cust2_f0feab@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$Dik+Fyk5PMhse5dllac3WQ$GHSBsrSXTrXUkMRy19QnvnsXj96Av/FwY4OF4HIdfCA	CUSTOMER	t	t	2026-10-31 08:27:41.32056+00	2026-10-31 08:27:41.32056+00
9d7fda23-1bb3-4d85-9371-df7cbe8a3eeb	cust2_a8a68d@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$GvuYA18WzITzI2cDQcIlFA$NSgACDqnDJdaDmHvZeqQb+FtCNCP/S3xixmG1UPLlz4	CUSTOMER	t	t	2026-10-31 08:27:41.427921+00	2026-10-31 08:27:41.427921+00
7586397c-7be1-4012-a3a4-6f30cffef43b	op_934bd2@test.com	Overpay Cust	$argon2id$v=19$m=65536,t=3,p=4$KSuTGFXQwI6uA2sTVKUaxQ$Npvz/sea4QnNvRil+6x7zcB+CD+/PhLc2zGE5Y3V6Rc	CUSTOMER	t	t	2026-10-31 08:27:41.624239+00	2026-10-31 08:27:41.624239+00
6b3aa4d3-86f7-4bc8-90db-254cb28a4438	cust2_e6f167@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$goqqupEBMc7fT+5aq7SrEQ$BRHmkXz6pHX4Na7XclcxAnbruUvbf2IRq4ZeOK0QrLA	CUSTOMER	t	t	2026-10-31 08:27:42.080431+00	2026-10-31 08:27:42.080431+00
82fd49ba-17d2-4965-86ca-0153fb0187c2	iso1_ae5ec2@demo.com	Customer One Profile	$argon2id$v=19$m=65536,t=3,p=4$CKcGmJEBHd4UV9xERrUDKQ$9eCAO9Hhmw9cTGCwAgKBSWY/SYzfXP4xs21WIkM3Aew	CUSTOMER	t	t	2026-10-31 08:27:42.167737+00	2026-10-31 08:27:42.167737+00
2db433b5-9f80-4d01-931e-b71e9b09a7ce	iso2_ae5ec2@demo.com	Customer Two Profile	$argon2id$v=19$m=65536,t=3,p=4$QFKC6HaTWB6XpfQnkMkrfw$8tnfp0lQ1r25mvniE3F8+lX/7iAG0V8P0WaSYmHFB/c	CUSTOMER	t	t	2026-10-31 08:27:42.266133+00	2026-10-31 08:27:42.266133+00
2c092098-b1de-406c-bb3a-b7e4bfa41dd6	cust2_09cf30@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$nr/MrcvmN9y+H9DtGUZJJA$KMkS5hGmQi3KPbw+5Q55wH2p/GqEmoxGYEmMTpoUlm4	CUSTOMER	t	t	2026-10-31 08:27:42.392905+00	2026-10-31 08:27:42.392905+00
1e06a841-4aed-44c6-916b-a07d60c0d186	cust2_a4d6ba@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$bpnRHKnhuV8ELcJmJRyz5w$emNxrebhjFlBq0F75KmadLqrmWbOFIWHAv9avtYTsRs	CUSTOMER	t	t	2026-10-31 08:27:42.488913+00	2026-10-31 08:27:42.488913+00
2104ced0-8801-4857-a65b-b8eadb85f3b7	neg9_b487f3@test.com	Neg9 Cust	$argon2id$v=19$m=65536,t=3,p=4$cfOcxqeUlkF/NtBKdcbG+w$EDkPZXCwaUF4flwd7eZY43MPhBrBMZRgBK4dSOHZx2c	CUSTOMER	t	t	2026-10-31 08:27:42.710446+00	2026-10-31 08:27:42.710446+00
209ed41e-2e9f-4ef0-9bb5-30f1954ed4a8	cust2_41176f@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$Ek5gxGHE7/26Kt8MXd/Xzw$8IQtVmMdyhPZnTrHDD0HvDr/2dIQ6gbE27GKF5Hav7s	CUSTOMER	t	t	2026-10-31 08:27:43.647632+00	2026-10-31 08:27:43.647632+00
4c56d2a2-7933-4bf8-b48e-e24352635408	billing_d2fae@infosys.com	Infosys Corp	$argon2id$v=19$m=65536,t=3,p=4$PWTqmTxRsEwTlmzIca3ZAg$98u0sT5nvZPqbze3rgU1lN9C0YJOMK06FLs/RxT+KVE	CUSTOMER	t	t	2026-10-31 08:27:43.878779+00	2026-10-31 08:27:43.878779+00
407b39f0-be86-4814-8f6c-b1d8744e9b42	cust2_cd461b@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$7u7gNk+u2Cb8S9vobOaDbg$nLDwMiIYs9Ye2v1+rnsGb+AdH3wH52ggClatkDeO+nA	CUSTOMER	t	t	2026-10-31 08:27:47.211177+00	2026-10-31 08:27:47.211177+00
5dab76e6-0337-4d2b-a840-03d3051a6ec6	tata_9e752@tatatech.com	Tata Tech	$argon2id$v=19$m=65536,t=3,p=4$qS1f0RDbPjtfwxyCnZu9kQ$dYXzHCTdJEa2XHhKRpSdWKOx6QXiW1Acn+dsJlHY9Ag	CUSTOMER	t	t	2026-10-31 08:27:47.411212+00	2026-10-31 08:27:47.411212+00
bb2f3e5a-a4d7-4521-a39d-12a1ff065bff	cust2_615014e7@example.com	Customer Two	$argon2id$v=19$m=65536,t=3,p=4$mHQaOcMoSoW7P9ciB7pzgw$JQTIsSIUaTkofVJ7ZTOcrMGU0Lx4dWAIEHT1d9Z42nA	CUSTOMER	t	t	2026-10-31 08:27:47.929423+00	2026-10-31 08:27:47.929423+00
84d45c7b-6d0a-455c-a618-9af4d5a317a9	staff_46b735ab@example.com	Support Staff Member	$argon2id$v=19$m=65536,t=3,p=4$DkOhREcvWxi1mFxTKkteRA$w42cAVsxdDArQdpFuwMonjExApxMRvXvrUGa8OFliDc	STAFF	t	t	2026-10-31 08:27:48.081468+00	2026-10-31 08:27:48.081468+00
6c688382-392d-4b6b-8018-b43ca02eaa3a	cust1_061718e9@example.com	Customer One	$argon2id$v=19$m=65536,t=3,p=4$LiaVC58cJcCG9UxP/TyWJw$ZxiscW08UsLxa6EcmInIurbuD1Gv/CaJxS7rvGbbGtw	CUSTOMER	f	t	2026-10-31 08:27:47.847161+00	2026-10-31 08:27:48.333607+00
\.


--
-- Data for Name: variant_price_history; Type: TABLE DATA; Schema: public; Owner: brightloop_user
--

COPY public.variant_price_history (id, variant_id, old_adjustment_type, new_adjustment_type, old_adjustment_value, new_adjustment_value, changed_by_id, reason, created_at) FROM stdin;
5d60f2be-b060-43cd-b998-91a768a05cfa	7f637b2a-7015-462b-8fff-2d6e4ec870d2	\N	FIXED_AMOUNT	\N	0.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:09:09.211336+00
03b5ae57-6059-48dc-a1e7-fc35536f2ebe	b197ac43-9c8c-4a50-b86e-1801ee29ff2f	\N	FIXED_AMOUNT	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:09:09.211336+00
ce5d2211-b922-4b71-8eab-d888b800ca99	3e8da5f7-3f7f-48c5-b383-5a45987b4580	\N	FIXED_AMOUNT	\N	200.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:09:09.457432+00
82513a3d-d15a-4170-831b-0a589d123048	907568e7-b630-4b2a-8efd-04d0cb0cb53d	\N	FIXED_AMOUNT	\N	0.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:11:22.986832+00
9a5eda36-bde7-4f62-96fd-a5d243f352de	64f3265d-f7cb-4977-b77c-0c4ba591c298	\N	FIXED_AMOUNT	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:11:22.986832+00
6ae30c76-982a-4375-90fb-cf784dcad6ab	2c9a051f-9788-4fb4-a69e-cab282aae68c	\N	PERCENTAGE	\N	25.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:11:23.067041+00
a7df1c86-0b0f-4cf1-8baf-f3d0b83d6051	14b6b487-3a78-4e2c-868e-ed879361bdc6	\N	FIXED_AMOUNT	\N	200.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:11:23.264967+00
f4a4775d-1ac7-4621-90aa-714094407494	14b6b487-3a78-4e2c-868e-ed879361bdc6	FIXED_AMOUNT	PERCENTAGE	200.0000	30.0000	5040313c-9900-4630-93f9-1f0e119412dd	Switched to percentage based expansion	2026-10-31 06:11:23.340133+00
3cd32849-d197-4b1f-95aa-52f641cfaac7	f247a797-cd47-4d54-a9bf-6aaee5854c48	\N	FIXED_AMOUNT	\N	50.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:11:23.388354+00
fc51f98c-428c-4f6d-b5a0-3b7b37454712	a4240ace-a976-408e-8d29-916a7ceb90be	\N	FIXED_AMOUNT	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:11:30.61083+00
e7c6a0a9-2f7e-4688-a2ba-5313e0bfdff9	b9e43893-8cc6-4a57-ae38-990694394fc0	\N	FIXED_AMOUNT	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:12:46.235778+00
f2058ccc-3c6c-46f1-9291-d39468dd1b7d	cb45dbbc-02c4-4185-9dcb-d489323f84cd	\N	FIXED_AMOUNT	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:13:00.313423+00
da0c7341-3074-4662-8bad-4bdd048f300c	1c1ec097-b256-48f1-abec-265d94ffbbdf	\N	FIXED_AMOUNT	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:13:21.502324+00
8a14c3d1-aa23-4671-b171-74542033ffda	25173b97-8ce1-493e-a708-f1bfea0d2946	\N	FIXED_AMOUNT	\N	560.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:13:28.044234+00
83722236-0fae-402b-a8aa-ee5dc8e6c497	c14ca68d-c322-4545-b3db-77c83734d4f6	\N	PERCENTAGE	\N	15.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:13:28.044234+00
9167f6e7-755d-4c56-9a39-49ccb0710ed9	17bbc51d-82ba-401d-aec3-0fdf2301e7a1	\N	FIXED_AMOUNT	\N	560.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:13:42.969597+00
14382b83-7ab7-45aa-abeb-1dc47fa64404	a68fd77e-7a83-40ba-a822-44cb57ecd883	\N	PERCENTAGE	\N	15.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:13:42.969597+00
00125afb-098a-4427-aa39-871360dfc2e5	8fd87388-1f5d-4b91-9a9a-7c8271705edb	\N	FIXED_AMOUNT	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:13:51.455491+00
5340b5f8-f5c5-4dcf-adf7-f2fdbd1b70a8	0b91335e-5667-4d1b-a83f-731bca7b9f8b	\N	FIXED_AMOUNT	\N	560.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:13:51.73966+00
811bf3f3-5d72-415a-a9a1-27c6adf0b75e	87fbfe6d-a0be-46e8-9ffa-137804bfa6e2	\N	PERCENTAGE	\N	15.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:13:51.73966+00
88cc2f8b-3b98-4b73-9400-68d510cd0a4a	b3ee21c0-17b9-42a6-9379-7f1dd12740a5	\N	FIXED_AMOUNT	\N	0.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:13:51.950086+00
3dba63f5-2a6a-4ab9-828b-e3e3b22df183	69eaf125-7746-4c33-b26e-dbfa769b55a0	\N	FIXED_AMOUNT	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:13:51.950086+00
58c4098a-86fb-4a2a-bfbc-5f258741a2f4	7c978ef8-1885-4ca9-885d-ae81a97a51bf	\N	PERCENTAGE	\N	25.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:13:52.004188+00
96f1349e-6f84-49bb-814b-4d7e9ab2150b	b9a95e2b-3ae8-40fc-918a-0f414359c493	\N	FIXED_AMOUNT	\N	200.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:13:52.170244+00
9205bd24-f5a7-4620-a22c-d4935d431be1	b9a95e2b-3ae8-40fc-918a-0f414359c493	FIXED_AMOUNT	PERCENTAGE	200.0000	30.0000	5040313c-9900-4630-93f9-1f0e119412dd	Switched to percentage based expansion	2026-10-31 06:13:52.230443+00
3a5b4266-f1c8-4eb8-83a6-c59f75ad6bf3	c963199d-9887-4663-86ab-af9a1af8540a	\N	FIXED_AMOUNT	\N	50.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:13:52.271187+00
0b10a1d2-06a7-4429-857f-0ad20af76ff8	e18c25c6-b3fe-4ea0-a4cd-f0de05ff52ab	\N	FIXED_AMOUNT	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:26:02.973651+00
4749e5a8-32df-47bb-83dc-c45d5f173849	79fc5752-dd62-4007-8b50-a8b0143c17ec	\N	FIXED_AMOUNT	\N	560.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:26:03.238769+00
c0c93936-a954-437e-92e1-f460dfbf48ce	67088a76-85a0-438c-a30e-2834b4c8ad6b	\N	PERCENTAGE	\N	15.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:26:03.238769+00
27e04e4f-9721-4b1a-bd39-9bb74e8caa3b	e06fcae1-fb23-41ad-b3d4-17411ef9e71f	\N	FIXED_AMOUNT	\N	0.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:26:03.451849+00
dfd622b9-82e0-4ac2-aa1a-be99fd472552	3dc3f175-6abb-4f76-bb94-ce005b2b28dd	\N	FIXED_AMOUNT	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:26:03.451849+00
7391ed08-8331-4dd6-915b-72796b94e0f0	501b4455-d0fe-4c3a-9286-ad9233b31152	\N	PERCENTAGE	\N	25.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:26:03.50579+00
491225ba-3e8d-4ac1-8401-717478fb99a8	a60361be-a9d2-4b9d-926a-852584870054	\N	FIXED_AMOUNT	\N	200.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:26:03.696165+00
ffd0dc5d-2fba-4e90-abd5-29a116d53346	a60361be-a9d2-4b9d-926a-852584870054	FIXED_AMOUNT	PERCENTAGE	200.0000	30.0000	5040313c-9900-4630-93f9-1f0e119412dd	Switched to percentage based expansion	2026-10-31 06:26:03.761454+00
44cfcd41-6c1e-4d6f-ada9-47f99a5bd493	b36dcf42-8323-40eb-a599-9bdef190a97c	\N	FIXED_AMOUNT	\N	50.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:26:03.799583+00
f04bf40f-afaa-4689-ba79-4e4219ed2134	4602eab7-0f64-4ee6-83f9-16bf629b0cff	\N	FIXED_AMOUNT	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:56:46.892346+00
296f89dc-6dac-4dcf-b618-e0f2f6dd6543	7d6e0fdc-d3a4-4f2d-88ab-5901081cb213	\N	FIXED_AMOUNT	\N	560.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:56:47.179122+00
fa468b89-7821-432a-b9cc-3c6075710014	830cd203-3b78-4a8d-9575-f0812f4ab769	\N	PERCENTAGE	\N	15.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:56:47.179122+00
c0006d1c-9690-4872-b269-5e1e1d681b31	150df79f-92e3-4a41-8316-efb918c8aa6d	\N	FIXED_AMOUNT	\N	0.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:56:47.412714+00
9c3cb8e7-e315-4545-bf16-fc86a99c806c	ca0bad42-d760-4f35-9a75-9f8f97abf60e	\N	FIXED_AMOUNT	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:56:47.412714+00
41d1647d-19a1-49f7-be15-463175fa5448	f3282671-469f-4989-9cb8-159877a7c3e9	\N	PERCENTAGE	\N	25.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:56:47.481981+00
35742ccb-47a8-4ef6-87c4-d8f5558c4587	e67d3b20-e99a-4713-9602-fa5d19e0ddd1	\N	FIXED_AMOUNT	\N	200.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:56:47.677206+00
306521f2-c74c-4e61-8eb7-5f14edc98eed	e67d3b20-e99a-4713-9602-fa5d19e0ddd1	FIXED_AMOUNT	PERCENTAGE	200.0000	30.0000	5040313c-9900-4630-93f9-1f0e119412dd	Switched to percentage based expansion	2026-10-31 06:56:47.746607+00
cebe977f-649a-4a84-837c-5c3326caa8e6	6b896431-0624-4579-8a4e-793d44498f3a	\N	FIXED_AMOUNT	\N	50.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:56:47.789903+00
18442e2b-865f-414e-be9c-2a87f7e33025	a0559654-7d26-4f01-a04f-dda83c0edee0	\N	FIXED_AMOUNT	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:57:57.583235+00
6ce281d5-be07-458c-b598-df6391b72b2b	6bb06fa0-24a6-41f7-b77a-c464343c013e	\N	FIXED_AMOUNT	\N	560.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:57:57.889803+00
28afb3c8-8e1d-497b-b47d-1644d7ece033	7db0c03a-312e-4487-9d75-5706ccbb6d60	\N	PERCENTAGE	\N	15.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:57:57.889803+00
07b3b4e7-ecb4-4adb-baa4-948acb3d123a	db2dba94-71ab-488b-aa18-5caa79fb50f6	\N	FIXED_AMOUNT	\N	0.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:57:58.121428+00
168664fd-03ab-451c-a37d-d13a789963a4	adc3ab03-606e-4410-98de-59b5b04fe827	\N	FIXED_AMOUNT	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:57:58.121428+00
f318b24d-f780-4584-acae-c94e1a502cb3	dac2de5d-9451-4bb1-b5b9-31bfc5a35283	\N	PERCENTAGE	\N	25.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:57:58.190747+00
fe719caf-22b1-47d0-9c0a-e377d5806773	75e8ab88-d794-43e4-9510-2f6577bd1ab8	\N	FIXED_AMOUNT	\N	200.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:57:58.391548+00
9af2acac-b0bd-4e63-9993-5841f29b326a	75e8ab88-d794-43e4-9510-2f6577bd1ab8	FIXED_AMOUNT	PERCENTAGE	200.0000	30.0000	5040313c-9900-4630-93f9-1f0e119412dd	Switched to percentage based expansion	2026-10-31 06:57:58.464766+00
392d1b9b-f1d9-425e-91fc-343809f899bc	1b428e94-dc86-4434-bdd6-07e7b41c9ebd	\N	FIXED_AMOUNT	\N	50.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 06:57:58.513056+00
c42d9718-06fd-4662-9977-b7f7954ffae6	1c64c824-6536-4e25-b7ea-4ae90ccf9a6c	\N	FIXED_AMOUNT	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:01:04.176984+00
3793e13e-f5f1-4c06-93ae-f5a4cbe344f4	423a284a-ea87-415c-965d-7478c5c2dd99	\N	FIXED_AMOUNT	\N	560.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:01:04.484265+00
822882f0-2ff0-4be0-9f57-0c92c0285854	24677ada-6dfc-4079-88be-c503241c1818	\N	PERCENTAGE	\N	15.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:01:04.484265+00
ebf7ec05-459c-4c31-9aa2-2460c45b7039	be510b4d-686d-4fdd-a697-2560772dcb16	\N	FIXED_AMOUNT	\N	0.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:01:04.718922+00
74ecb30c-0573-4f02-a1b5-5f507bb268b4	6e8b7448-dfc6-4a25-8ac9-c07162db0c8e	\N	FIXED_AMOUNT	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:01:04.718922+00
1f176534-00e5-4569-9c9f-d962d38d7df3	887d0e72-05f5-4794-8775-7edc39c55b03	\N	PERCENTAGE	\N	25.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:01:04.786595+00
d9ff005d-d50f-416d-a30b-6abcb3a592dd	7e83e4b5-871d-4dd7-8bd6-081d90189851	\N	FIXED_AMOUNT	\N	200.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:01:04.987565+00
ff7310fd-77f5-419a-951a-f72746d5dcea	7e83e4b5-871d-4dd7-8bd6-081d90189851	FIXED_AMOUNT	PERCENTAGE	200.0000	30.0000	5040313c-9900-4630-93f9-1f0e119412dd	Switched to percentage based expansion	2026-10-31 07:01:05.054887+00
7a69360d-a329-4676-ae75-995b32e71482	10c9d83a-c2f2-4e06-9bd1-9abba908535b	\N	FIXED_AMOUNT	\N	50.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:01:05.097802+00
37aeaaa5-fc29-4b83-9f61-ea1b29d1bb9a	9369f5a3-310b-4235-a2a3-f257bc8b50fe	\N	FIXED_AMOUNT	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:01:41.163375+00
232471a6-3dee-46cc-b4e6-773462c28543	f24282e2-777b-4b11-bf3d-cd5a00498bb3	\N	FIXED_AMOUNT	\N	560.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:01:41.45576+00
654ef322-b8a5-412f-a710-9f996476c23c	85033796-a602-4126-b842-8b3329d193e8	\N	PERCENTAGE	\N	15.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:01:41.45576+00
e587334b-546b-49b5-8b98-d49309a33e2b	c588cf51-5e14-445e-af7c-24a7f4c3ddf7	\N	FIXED_AMOUNT	\N	0.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:01:41.67762+00
3e3c7222-65f2-4c36-b9ec-cbadbcbbf25c	6a4a5ed2-25ac-4f43-b1e1-762efe85d6ee	\N	FIXED_AMOUNT	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:01:41.67762+00
cac298fe-d103-47dc-a020-5bba507f8e4f	67302c4c-d599-49f5-bc58-663c4491706e	\N	PERCENTAGE	\N	25.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:01:41.743588+00
a5cef566-866f-431a-8756-2b0a7e5c5d53	a7fc4a31-685c-42ba-a888-7621e16cce08	\N	FIXED_AMOUNT	\N	200.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:01:41.942969+00
1651bcd3-e8b3-4210-aa2e-f64b3a05dd67	a7fc4a31-685c-42ba-a888-7621e16cce08	FIXED_AMOUNT	PERCENTAGE	200.0000	30.0000	5040313c-9900-4630-93f9-1f0e119412dd	Switched to percentage based expansion	2026-10-31 07:01:42.01415+00
478659a4-dcf0-42f9-8e82-bf8de30c50a9	38f2909c-1b14-4be0-9033-3fb9c37b8893	\N	FIXED_AMOUNT	\N	50.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:01:42.058117+00
4ff2d415-49c1-4864-a9a2-dc0714fd3d0b	d29668bc-3460-4d77-abfc-51bec2a342ac	\N	FIXED_AMOUNT	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:24:21.416759+00
5b7bd395-ab5f-44b7-bf35-20ad3022a2f2	bad29ead-e771-460d-953a-8a09fa128dbf	\N	FIXED_AMOUNT	\N	560.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:24:21.714405+00
cd7028e9-5422-4b6b-a96a-547c4b0dda3e	7a532abb-68a8-42e2-8a9c-77212b5ab45f	\N	PERCENTAGE	\N	15.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:24:21.714405+00
97e5cc28-7f2a-4dda-a21a-4595492b6c12	d66d823c-646e-4d29-8324-0d38e3427048	\N	FIXED_AMOUNT	\N	0.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:24:21.938189+00
0aaf4805-dae2-4354-aaff-3d8fc9004e1f	e44f953d-2002-424b-ae71-f63b4561cab9	\N	FIXED_AMOUNT	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:24:21.938189+00
05c9edcc-c3c5-4780-bbf0-06b4b6ff38b8	1c142a8c-6173-4174-8df2-1fae3ea9c8fe	\N	PERCENTAGE	\N	25.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:24:21.994158+00
deb7a41b-42ae-4d1c-908e-3537e077969d	ec7fd122-b0e0-4f71-b1cc-1898ae07d7b3	\N	FIXED_AMOUNT	\N	200.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:24:22.180328+00
3a95f987-d400-4301-af4f-7349c065e6b5	ec7fd122-b0e0-4f71-b1cc-1898ae07d7b3	FIXED_AMOUNT	PERCENTAGE	200.0000	30.0000	5040313c-9900-4630-93f9-1f0e119412dd	Switched to percentage based expansion	2026-10-31 07:24:22.248062+00
fb0b2e2e-f0b7-423b-b0ae-44ea1fe8ed7a	9ce9c660-c379-475f-99e9-ad70d90e830a	\N	FIXED_AMOUNT	\N	50.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:24:22.289844+00
7064ce28-6508-45bb-9489-b95559a47418	6fc9a4b4-1077-4a77-a69b-3c4a2741bc9f	\N	FIXED_AMOUNT	\N	15000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:33:24.444528+00
ae789336-2d54-4ab2-8acb-00e7929141b7	fd5cbb88-555d-497a-ae46-b3d5ad896298	\N	FIXED_AMOUNT	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:38:40.410335+00
9a57ee95-4637-4a64-a125-3bcbca5378a3	3ab8bedc-c021-464a-83b5-e4d8a15754b5	\N	FIXED_AMOUNT	\N	560.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:38:40.710591+00
ca592306-fd33-4d6f-ad21-372817f9de36	73b12ae1-55cf-49b1-b815-c17c883aa66d	\N	PERCENTAGE	\N	15.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:38:40.710591+00
c7b68953-6589-4a14-95d3-cec6ed4d8e75	e701f190-a116-47cf-a73f-6996264d9f9f	\N	FIXED_AMOUNT	\N	0.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:38:40.943603+00
2af049a7-9918-479e-9082-3bc8d862e008	02fb92be-f163-426f-ab8c-82431682d514	\N	FIXED_AMOUNT	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:38:40.943603+00
26ea58d6-866b-471c-9647-3b90dd517ff7	06303433-bc3b-4d4f-979e-277003ab1aad	\N	PERCENTAGE	\N	25.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:38:41.011486+00
ab2cb648-020a-41a0-8e21-e5c6db7b8d6c	8defbe56-c536-4704-ba6f-f8c17666cfa0	\N	FIXED_AMOUNT	\N	200.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:38:41.207953+00
6a4fc782-7579-46b4-9164-db936376f14d	8defbe56-c536-4704-ba6f-f8c17666cfa0	FIXED_AMOUNT	PERCENTAGE	200.0000	30.0000	5040313c-9900-4630-93f9-1f0e119412dd	Switched to percentage based expansion	2026-10-31 07:38:41.291098+00
75140136-fbf1-4bef-acd1-e06b85bbf59e	c061b2f3-abb8-494c-9177-bb3c19cb63b7	\N	FIXED_AMOUNT	\N	50.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 07:38:41.337753+00
5951b9ae-3c51-4329-be05-db15639355ae	d0505c31-1a18-4121-abc7-dc5d5170262b	\N	FIXED_AMOUNT	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 08:24:20.06928+00
75fe3e9c-ab81-4f12-b7b9-d7ebe60996ef	97f243d0-a14b-4006-86cd-10dd4f1640e2	\N	FIXED_AMOUNT	\N	560.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 08:24:20.357187+00
b4af9ad9-dbe6-4b74-b7f6-978fbe9e1b18	cdf44a25-44b0-4f23-8bb2-2f87dc99493b	\N	PERCENTAGE	\N	15.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 08:24:20.357187+00
e45c4453-4bc8-4a84-9fcf-283596e28839	2b345a5e-f517-463d-a260-f66f99970b60	\N	FIXED_AMOUNT	\N	0.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 08:24:20.593607+00
22ea997e-6a07-497c-9c90-2531a5ceda8b	6b24c4db-63fc-48da-83c7-253559ebb787	\N	FIXED_AMOUNT	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 08:24:20.593607+00
86d9637b-0b6c-469a-823f-ae1998901f55	d21571c0-2316-4fd5-ab99-c1a7853fa5d4	\N	PERCENTAGE	\N	25.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 08:24:20.66303+00
5edb4db5-0e95-4c4e-a614-accaf0064556	d62c2f56-26d5-405a-9cff-076773776786	\N	FIXED_AMOUNT	\N	200.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 08:24:20.786671+00
5252780e-5685-4074-9324-47edc8d18544	d62c2f56-26d5-405a-9cff-076773776786	FIXED_AMOUNT	PERCENTAGE	200.0000	30.0000	5040313c-9900-4630-93f9-1f0e119412dd	Switched to percentage based expansion	2026-10-31 08:24:20.86472+00
34460803-af2c-4373-ba70-52a459fc3363	de329838-0631-4665-9d7d-8fce07dcedd5	\N	FIXED_AMOUNT	\N	50.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 08:24:20.912848+00
2e9d3eb3-0583-40f8-8981-4d802991a281	aff6e660-492c-4e6a-930a-cdce8d4bd68f	\N	FIXED_AMOUNT	\N	500.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 08:27:45.940944+00
0a0821b0-3659-4d74-9f13-b2b670ea754f	2b5a7780-8c0f-444e-87e7-542ac1da4e2f	\N	FIXED_AMOUNT	\N	560.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 08:27:46.266357+00
45b7c90b-148a-4781-8b96-6df941f39071	b4467832-9761-460c-b909-5261365f6018	\N	PERCENTAGE	\N	15.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 08:27:46.266357+00
0cda4c35-9373-4a9b-ac5e-0734d804aa98	a8de6386-3edb-4195-9cdc-f052e9cb84ad	\N	FIXED_AMOUNT	\N	0.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 08:27:46.518896+00
a75abefa-4748-43a7-907a-827147153b11	f003c6b6-45e5-4dd1-b60e-2d1a52f58c77	\N	FIXED_AMOUNT	\N	1000.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 08:27:46.518896+00
f13aa29e-ff98-4be7-8bce-2521cc7a6aab	ac708356-f298-4520-8b1d-0914a7baae33	\N	PERCENTAGE	\N	25.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 08:27:46.585484+00
b32c24a6-c384-412e-b1bf-0fc78e3f8dcd	3691cf50-db68-4305-96c2-c8bca1333fee	\N	FIXED_AMOUNT	\N	200.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 08:27:46.787751+00
48614bbe-9cb7-48f1-86c3-238a6229cbcf	3691cf50-db68-4305-96c2-c8bca1333fee	FIXED_AMOUNT	PERCENTAGE	200.0000	30.0000	5040313c-9900-4630-93f9-1f0e119412dd	Switched to percentage based expansion	2026-10-31 08:27:46.870078+00
c1bcc1e0-e281-46fa-8a4e-f36069396bac	390e2722-02a8-4158-b900-e4ea80e32da5	\N	FIXED_AMOUNT	\N	50.0000	5040313c-9900-4630-93f9-1f0e119412dd	Initial variant creation	2026-10-31 08:27:46.928905+00
\.


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: customers customers_customer_number_key; Type: CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_customer_number_key UNIQUE (customer_number);


--
-- Name: customers customers_email_key; Type: CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_email_key UNIQUE (email);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: customers customers_user_id_key; Type: CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_user_id_key UNIQUE (user_id);


--
-- Name: invoice_items invoice_items_pkey; Type: CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_invoice_number_key; Type: CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key UNIQUE (invoice_number);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (id);


--
-- Name: payments payments_payment_number_key; Type: CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_payment_number_key UNIQUE (payment_number);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: plan_products plan_products_pkey; Type: CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.plan_products
    ADD CONSTRAINT plan_products_pkey PRIMARY KEY (id);


--
-- Name: product_price_history product_price_history_pkey; Type: CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.product_price_history
    ADD CONSTRAINT product_price_history_pkey PRIMARY KEY (id);


--
-- Name: product_variants product_variants_pkey; Type: CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.product_variants
    ADD CONSTRAINT product_variants_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: subscription_items subscription_items_pkey; Type: CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.subscription_items
    ADD CONSTRAINT subscription_items_pkey PRIMARY KEY (id);


--
-- Name: subscription_plans subscription_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.subscription_plans
    ADD CONSTRAINT subscription_plans_pkey PRIMARY KEY (id);


--
-- Name: subscription_status_history subscription_status_history_pkey; Type: CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.subscription_status_history
    ADD CONSTRAINT subscription_status_history_pkey PRIMARY KEY (id);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: subscriptions subscriptions_subscription_number_key; Type: CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_subscription_number_key UNIQUE (subscription_number);


--
-- Name: plan_products uq_plan_products_plan_product_variant; Type: CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.plan_products
    ADD CONSTRAINT uq_plan_products_plan_product_variant UNIQUE (plan_id, product_id, variant_id);


--
-- Name: product_variants uq_product_variants_product_code; Type: CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.product_variants
    ADD CONSTRAINT uq_product_variants_product_code UNIQUE (product_id, variant_code);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: variant_price_history variant_price_history_pkey; Type: CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.variant_price_history
    ADD CONSTRAINT variant_price_history_pkey PRIMARY KEY (id);


--
-- Name: ix_audit_logs_action; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_audit_logs_action ON public.audit_logs USING btree (action);


--
-- Name: ix_audit_logs_created_at; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_audit_logs_created_at ON public.audit_logs USING btree (created_at);


--
-- Name: ix_audit_logs_user_id; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_audit_logs_user_id ON public.audit_logs USING btree (user_id);


--
-- Name: ix_customers_customer_number; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_customers_customer_number ON public.customers USING btree (customer_number);


--
-- Name: ix_customers_email; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_customers_email ON public.customers USING btree (email);


--
-- Name: ix_customers_name; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_customers_name ON public.customers USING btree (name);


--
-- Name: ix_customers_status; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_customers_status ON public.customers USING btree (status);


--
-- Name: ix_invoice_items_invoice_id; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_invoice_items_invoice_id ON public.invoice_items USING btree (invoice_id);


--
-- Name: ix_invoices_customer_id; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_invoices_customer_id ON public.invoices USING btree (customer_id);


--
-- Name: ix_invoices_invoice_number; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_invoices_invoice_number ON public.invoices USING btree (invoice_number);


--
-- Name: ix_invoices_payment_status; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_invoices_payment_status ON public.invoices USING btree (payment_status);


--
-- Name: ix_invoices_status; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_invoices_status ON public.invoices USING btree (status);


--
-- Name: ix_invoices_subscription_id; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_invoices_subscription_id ON public.invoices USING btree (subscription_id);


--
-- Name: ix_password_reset_tokens_expires_at; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_password_reset_tokens_expires_at ON public.password_reset_tokens USING btree (expires_at);


--
-- Name: ix_password_reset_tokens_is_used; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_password_reset_tokens_is_used ON public.password_reset_tokens USING btree (is_used);


--
-- Name: ix_password_reset_tokens_token_hash; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE UNIQUE INDEX ix_password_reset_tokens_token_hash ON public.password_reset_tokens USING btree (token_hash);


--
-- Name: ix_password_reset_tokens_user_id; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_password_reset_tokens_user_id ON public.password_reset_tokens USING btree (user_id);


--
-- Name: ix_payments_customer_id; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_payments_customer_id ON public.payments USING btree (customer_id);


--
-- Name: ix_payments_invoice_id; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_payments_invoice_id ON public.payments USING btree (invoice_id);


--
-- Name: ix_payments_payment_number; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_payments_payment_number ON public.payments USING btree (payment_number);


--
-- Name: ix_payments_reference_number; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_payments_reference_number ON public.payments USING btree (reference_number);


--
-- Name: ix_plan_products_plan_id; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_plan_products_plan_id ON public.plan_products USING btree (plan_id);


--
-- Name: ix_plan_products_product_id; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_plan_products_product_id ON public.plan_products USING btree (product_id);


--
-- Name: ix_plan_products_variant_id; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_plan_products_variant_id ON public.plan_products USING btree (variant_id);


--
-- Name: ix_product_price_history_created_at; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_product_price_history_created_at ON public.product_price_history USING btree (created_at);


--
-- Name: ix_product_price_history_product_id; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_product_price_history_product_id ON public.product_price_history USING btree (product_id);


--
-- Name: ix_product_variants_is_active; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_product_variants_is_active ON public.product_variants USING btree (is_active);


--
-- Name: ix_product_variants_product_id; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_product_variants_product_id ON public.product_variants USING btree (product_id);


--
-- Name: ix_products_is_active; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_products_is_active ON public.products USING btree (is_active);


--
-- Name: ix_products_is_archived; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_products_is_archived ON public.products USING btree (is_archived);


--
-- Name: ix_products_name; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_products_name ON public.products USING btree (name);


--
-- Name: ix_products_product_type; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_products_product_type ON public.products USING btree (product_type);


--
-- Name: ix_products_sku; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE UNIQUE INDEX ix_products_sku ON public.products USING btree (sku);


--
-- Name: ix_refresh_tokens_expires_at; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_refresh_tokens_expires_at ON public.refresh_tokens USING btree (expires_at);


--
-- Name: ix_refresh_tokens_family_id; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_refresh_tokens_family_id ON public.refresh_tokens USING btree (family_id);


--
-- Name: ix_refresh_tokens_is_revoked; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_refresh_tokens_is_revoked ON public.refresh_tokens USING btree (is_revoked);


--
-- Name: ix_refresh_tokens_token_hash; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE UNIQUE INDEX ix_refresh_tokens_token_hash ON public.refresh_tokens USING btree (token_hash);


--
-- Name: ix_refresh_tokens_user_id; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_refresh_tokens_user_id ON public.refresh_tokens USING btree (user_id);


--
-- Name: ix_subscription_items_product_id; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_subscription_items_product_id ON public.subscription_items USING btree (product_id);


--
-- Name: ix_subscription_items_subscription_id; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_subscription_items_subscription_id ON public.subscription_items USING btree (subscription_id);


--
-- Name: ix_subscription_items_variant_id; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_subscription_items_variant_id ON public.subscription_items USING btree (variant_id);


--
-- Name: ix_subscription_plans_code; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE UNIQUE INDEX ix_subscription_plans_code ON public.subscription_plans USING btree (code);


--
-- Name: ix_subscription_plans_name; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_subscription_plans_name ON public.subscription_plans USING btree (name);


--
-- Name: ix_subscription_plans_status; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_subscription_plans_status ON public.subscription_plans USING btree (status);


--
-- Name: ix_subscription_status_history_subscription_id; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_subscription_status_history_subscription_id ON public.subscription_status_history USING btree (subscription_id);


--
-- Name: ix_subscriptions_customer_id; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_subscriptions_customer_id ON public.subscriptions USING btree (customer_id);


--
-- Name: ix_subscriptions_plan_id; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_subscriptions_plan_id ON public.subscriptions USING btree (plan_id);


--
-- Name: ix_subscriptions_status; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_subscriptions_status ON public.subscriptions USING btree (status);


--
-- Name: ix_subscriptions_subscription_number; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_subscriptions_subscription_number ON public.subscriptions USING btree (subscription_number);


--
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- Name: ix_users_is_active; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_users_is_active ON public.users USING btree (is_active);


--
-- Name: ix_users_role; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_users_role ON public.users USING btree (role);


--
-- Name: ix_variant_price_history_created_at; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_variant_price_history_created_at ON public.variant_price_history USING btree (created_at);


--
-- Name: ix_variant_price_history_variant_id; Type: INDEX; Schema: public; Owner: brightloop_user
--

CREATE INDEX ix_variant_price_history_variant_id ON public.variant_price_history USING btree (variant_id);


--
-- Name: audit_logs audit_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: customers customers_created_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: customers customers_updated_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_updated_by_id_fkey FOREIGN KEY (updated_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: customers customers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: invoice_items invoice_items_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(id) ON DELETE CASCADE;


--
-- Name: invoice_items invoice_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE RESTRICT;


--
-- Name: invoice_items invoice_items_variant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_variant_id_fkey FOREIGN KEY (variant_id) REFERENCES public.product_variants(id) ON DELETE RESTRICT;


--
-- Name: invoices invoices_created_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: invoices invoices_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE RESTRICT;


--
-- Name: invoices invoices_subscription_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES public.subscriptions(id) ON DELETE RESTRICT;


--
-- Name: password_reset_tokens password_reset_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: payments payments_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE RESTRICT;


--
-- Name: payments payments_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(id) ON DELETE RESTRICT;


--
-- Name: payments payments_recorded_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_recorded_by_id_fkey FOREIGN KEY (recorded_by_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: plan_products plan_products_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.plan_products
    ADD CONSTRAINT plan_products_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.subscription_plans(id) ON DELETE CASCADE;


--
-- Name: plan_products plan_products_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.plan_products
    ADD CONSTRAINT plan_products_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: plan_products plan_products_variant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.plan_products
    ADD CONSTRAINT plan_products_variant_id_fkey FOREIGN KEY (variant_id) REFERENCES public.product_variants(id) ON DELETE SET NULL;


--
-- Name: product_price_history product_price_history_changed_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.product_price_history
    ADD CONSTRAINT product_price_history_changed_by_id_fkey FOREIGN KEY (changed_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: product_price_history product_price_history_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.product_price_history
    ADD CONSTRAINT product_price_history_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_variants product_variants_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.product_variants
    ADD CONSTRAINT product_variants_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: products products_created_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: products products_updated_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_updated_by_id_fkey FOREIGN KEY (updated_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: refresh_tokens refresh_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: subscription_items subscription_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.subscription_items
    ADD CONSTRAINT subscription_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE RESTRICT;


--
-- Name: subscription_items subscription_items_subscription_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.subscription_items
    ADD CONSTRAINT subscription_items_subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES public.subscriptions(id) ON DELETE CASCADE;


--
-- Name: subscription_items subscription_items_variant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.subscription_items
    ADD CONSTRAINT subscription_items_variant_id_fkey FOREIGN KEY (variant_id) REFERENCES public.product_variants(id) ON DELETE RESTRICT;


--
-- Name: subscription_plans subscription_plans_created_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.subscription_plans
    ADD CONSTRAINT subscription_plans_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: subscription_plans subscription_plans_updated_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.subscription_plans
    ADD CONSTRAINT subscription_plans_updated_by_id_fkey FOREIGN KEY (updated_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: subscription_status_history subscription_status_history_changed_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.subscription_status_history
    ADD CONSTRAINT subscription_status_history_changed_by_id_fkey FOREIGN KEY (changed_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: subscription_status_history subscription_status_history_subscription_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.subscription_status_history
    ADD CONSTRAINT subscription_status_history_subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES public.subscriptions(id) ON DELETE CASCADE;


--
-- Name: subscriptions subscriptions_created_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: subscriptions subscriptions_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE RESTRICT;


--
-- Name: subscriptions subscriptions_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.subscription_plans(id) ON DELETE RESTRICT;


--
-- Name: subscriptions subscriptions_updated_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_updated_by_id_fkey FOREIGN KEY (updated_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: variant_price_history variant_price_history_changed_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.variant_price_history
    ADD CONSTRAINT variant_price_history_changed_by_id_fkey FOREIGN KEY (changed_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: variant_price_history variant_price_history_variant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: brightloop_user
--

ALTER TABLE ONLY public.variant_price_history
    ADD CONSTRAINT variant_price_history_variant_id_fkey FOREIGN KEY (variant_id) REFERENCES public.product_variants(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict cfptdwGOYPnXpviu8KatGzO8DBjffw66KLgsbw1ML4ujJdGVdY1CwhqP5eLCZaN

