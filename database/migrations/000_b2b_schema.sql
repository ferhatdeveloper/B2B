-- ============================================================================
-- B2B — temel PostgreSQL semasi
-- ============================================================================

SET client_encoding = 'UTF8';

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE SCHEMA IF NOT EXISTS logic;
CREATE SCHEMA IF NOT EXISTS b2b;

CREATE TABLE IF NOT EXISTS public.companies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  tax_office text,
  tax_number text,
  currency_code text NOT NULL DEFAULT 'TRY',
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.customers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  code text NOT NULL UNIQUE,
  title text NOT NULL,
  customer_type text NOT NULL DEFAULT 'company',
  email text,
  phone text,
  tax_number text,
  balance numeric(18, 2) NOT NULL DEFAULT 0,
  credit_limit numeric(18, 2) NOT NULL DEFAULT 0,
  average_maturity_days integer,
  past_due_balance numeric(18, 2) NOT NULL DEFAULT 0,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  permissions jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid REFERENCES public.customers(id) ON DELETE SET NULL,
  role_id uuid REFERENCES public.roles(id) ON DELETE SET NULL,
  username text NOT NULL UNIQUE,
  password_hash text NOT NULL,
  full_name text NOT NULL,
  email text,
  is_active boolean NOT NULL DEFAULT true,
  last_login_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id uuid REFERENCES public.categories(id) ON DELETE SET NULL,
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  slug text NOT NULL,
  image_url text,
  sort_order integer NOT NULL DEFAULT 0,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id uuid REFERENCES public.categories(id) ON DELETE SET NULL,
  sku text NOT NULL UNIQUE,
  name text NOT NULL,
  description text,
  brand text,
  unit text NOT NULL DEFAULT 'ADET',
  currency_code text NOT NULL DEFAULT 'TRY',
  price numeric(18, 4) NOT NULL DEFAULT 0,
  tax_rate numeric(5, 2) NOT NULL DEFAULT 20,
  stock_qty numeric(18, 4) NOT NULL DEFAULT 0,
  image_url text,
  is_featured boolean NOT NULL DEFAULT false,
  is_campaign boolean NOT NULL DEFAULT false,
  is_discounted boolean NOT NULL DEFAULT false,
  is_personal boolean NOT NULL DEFAULT false,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.product_images (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  image_url text NOT NULL,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.campaigns (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  description text,
  starts_at timestamptz,
  ends_at timestamptz,
  discount_pct numeric(6, 3) NOT NULL DEFAULT 0,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.product_campaigns (
  product_id uuid NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  campaign_id uuid NOT NULL REFERENCES public.campaigns(id) ON DELETE CASCADE,
  PRIMARY KEY (product_id, campaign_id)
);

CREATE TABLE IF NOT EXISTS public.announcements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  body text NOT NULL,
  starts_at timestamptz,
  ends_at timestamptz,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.shipping_addresses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
  title text NOT NULL,
  contact_name text,
  phone text,
  address_line text NOT NULL,
  district text,
  city text,
  country text NOT NULL DEFAULT 'TR',
  is_default boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_no text NOT NULL UNIQUE,
  customer_id uuid NOT NULL REFERENCES public.customers(id) ON DELETE RESTRICT,
  shipping_address_id uuid REFERENCES public.shipping_addresses(id) ON DELETE SET NULL,
  status text NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'pending', 'approved', 'shipped', 'completed', 'cancelled')),
  currency_code text NOT NULL DEFAULT 'TRY',
  subtotal numeric(18, 2) NOT NULL DEFAULT 0,
  discount_total numeric(18, 2) NOT NULL DEFAULT 0,
  tax_total numeric(18, 2) NOT NULL DEFAULT 0,
  grand_total numeric(18, 2) NOT NULL DEFAULT 0,
  note text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.order_lines (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  product_id uuid REFERENCES public.products(id) ON DELETE SET NULL,
  sku text NOT NULL,
  product_name text NOT NULL,
  qty numeric(18, 4) NOT NULL CHECK (qty > 0),
  unit_price numeric(18, 4) NOT NULL DEFAULT 0,
  discount_pct numeric(6, 3) NOT NULL DEFAULT 0,
  tax_rate numeric(5, 2) NOT NULL DEFAULT 20,
  line_total numeric(18, 2) NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid NOT NULL REFERENCES public.customers(id) ON DELETE RESTRICT,
  order_id uuid REFERENCES public.orders(id) ON DELETE SET NULL,
  payment_no text NOT NULL UNIQUE,
  method text NOT NULL DEFAULT 'card',
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'failed', 'cancelled')),
  currency_code text NOT NULL DEFAULT 'TRY',
  amount numeric(18, 2) NOT NULL CHECK (amount >= 0),
  paid_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.invoices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid NOT NULL REFERENCES public.customers(id) ON DELETE RESTRICT,
  order_id uuid REFERENCES public.orders(id) ON DELETE SET NULL,
  invoice_no text NOT NULL UNIQUE,
  status text NOT NULL DEFAULT 'unpaid' CHECK (status IN ('unpaid', 'partial', 'paid', 'cancelled')),
  currency_code text NOT NULL DEFAULT 'TRY',
  amount numeric(18, 2) NOT NULL DEFAULT 0,
  due_date date,
  issued_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.checks_notes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid NOT NULL REFERENCES public.customers(id) ON DELETE RESTRICT,
  document_no text NOT NULL,
  document_type text NOT NULL CHECK (document_type IN ('check', 'note')),
  status text NOT NULL DEFAULT 'open',
  currency_code text NOT NULL DEFAULT 'TRY',
  amount numeric(18, 2) NOT NULL DEFAULT 0,
  due_date date,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (customer_id, document_no)
);

CREATE OR REPLACE VIEW b2b.product_catalog AS
SELECT
  p.id,
  p.sku,
  p.name,
  p.description,
  p.brand,
  p.unit,
  p.currency_code,
  p.price,
  p.tax_rate,
  p.stock_qty,
  p.image_url,
  p.is_featured,
  p.is_campaign,
  p.is_discounted,
  p.is_personal,
  c.id AS category_id,
  c.code AS category_code,
  c.name AS category_name,
  c.slug AS category_slug
FROM public.products p
LEFT JOIN public.categories c ON c.id = p.category_id
WHERE p.is_active = true
  AND COALESCE(c.is_active, true) = true;

CREATE OR REPLACE VIEW b2b.customer_dashboard AS
SELECT
  c.id AS customer_id,
  c.code AS customer_code,
  c.title AS customer_title,
  c.balance,
  c.credit_limit,
  c.average_maturity_days,
  c.past_due_balance,
  count(o.id) FILTER (WHERE o.status IN ('open', 'pending')) AS open_order_count,
  count(o.id) FILTER (WHERE o.status = 'completed') AS completed_order_count,
  count(i.id) FILTER (WHERE i.status IN ('unpaid', 'partial')) AS unpaid_invoice_count
FROM public.customers c
LEFT JOIN public.orders o ON o.customer_id = c.id
LEFT JOIN public.invoices i ON i.customer_id = c.id
WHERE c.is_active = true
GROUP BY c.id;

CREATE INDEX IF NOT EXISTS idx_products_category_id ON public.products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_flags ON public.products(is_featured, is_campaign, is_discounted, is_personal);
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON public.orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_order_lines_order_id ON public.order_lines(order_id);
CREATE INDEX IF NOT EXISTS idx_payments_customer_id ON public.payments(customer_id);
CREATE INDEX IF NOT EXISTS idx_invoices_customer_id ON public.invoices(customer_id);

INSERT INTO public.companies (code, name, currency_code)
VALUES ('EXFIN', 'EXFIN B2B', 'TRY')
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name;

INSERT INTO public.roles (code, name, permissions)
VALUES
  ('dealer', 'Bayi Kullanici', '{"orders": true, "payments": true, "account": true}'::jsonb),
  ('admin', 'Yonetici', '{"admin": true, "orders": true, "payments": true, "account": true}'::jsonb)
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    permissions = EXCLUDED.permissions;

INSERT INTO public.customers (company_id, code, title, customer_type, balance, credit_limit, average_maturity_days, past_due_balance)
SELECT id, 'demo', 'Demo Bayi', 'company', 0, 100000, 30, 0
FROM public.companies
WHERE code = 'EXFIN'
ON CONFLICT (code) DO UPDATE
SET title = EXCLUDED.title,
    company_id = EXCLUDED.company_id;

INSERT INTO public.users (customer_id, role_id, username, password_hash, full_name, email)
SELECT c.id, r.id, 'demo', crypt('1234', gen_salt('bf')), 'Demo Kullanici', 'demo@example.local'
FROM public.customers c
CROSS JOIN public.roles r
WHERE c.code = 'demo'
  AND r.code = 'dealer'
ON CONFLICT (username) DO UPDATE
SET customer_id = EXCLUDED.customer_id,
    role_id = EXCLUDED.role_id,
    full_name = EXCLUDED.full_name,
    email = EXCLUDED.email;

INSERT INTO public.categories (code, name, slug, sort_order)
VALUES
  ('electronics', 'Elektronik', 'elektronik', 10),
  ('fashion', 'Moda', 'moda', 20),
  ('home-life', 'Ev-Yasam', 'ev-yasam', 30),
  ('diy-market', 'Yapi Market', 'yapi-market', 40),
  ('baby-toy', 'Anne Bebek Oyuncak', 'anne-bebek-oyuncak', 50),
  ('outdoor', 'Spor Outdoor', 'spor-outdoor', 60),
  ('cosmetics', 'Kozmetik', 'kozmetik', 70),
  ('book-music', 'Kitap Muzik', 'kitap-muzik', 80),
  ('beverage', 'Icecek', 'icecek', 90),
  ('tire', 'Lastik', 'lastik', 100)
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    slug = EXCLUDED.slug,
    sort_order = EXCLUDED.sort_order;

INSERT INTO public.products (category_id, sku, name, currency_code, price, tax_rate, stock_qty, image_url, is_featured, is_campaign, is_discounted, is_personal)
SELECT c.id, v.sku, v.name, v.currency_code, v.price, 20, v.stock_qty, v.image_url, v.is_featured, v.is_campaign, v.is_discounted, v.is_personal
FROM (
  VALUES
    ('electronics', 'EXF-5D-MARK-II', 'Canon EOS 5D Mark II', 'TRY', 297.50, 15, NULL, true, false, false, false),
    ('electronics', 'EXF-MI-14-PRO', 'Mi Note 14 Pro Plus', 'USD', 23546.40, 8, NULL, true, false, false, false),
    ('electronics', 'EXF-IPHONE-16S', 'IPhone 16S', 'TRY', 1.14, 5, NULL, true, false, false, false),
    ('electronics', 'EXF-SAMSUNG-16-PRO', 'Samsung 16 Pro', 'TRY', 4709.28, 9, NULL, true, false, false, false),
    ('electronics', 'EXF-ASUS-T-ROG', 'Asus T-ROG', 'TRY', 1300.00, 11, NULL, true, false, false, false),
    ('electronics', 'EXF-HP-250-G10', 'HP 250 G10 Intel Core i5 1334U', 'TRY', 38474.51, 6, NULL, false, true, false, false),
    ('electronics', 'EXF-HP-255-G9', 'HP 255 G9 AMD Ryzen 5 5625U', 'TRY', 32318.59, 6, NULL, false, true, false, false),
    ('electronics', 'EXF-APPLE-BT-KB', 'Apple Bluetooth Klavye', 'TRY', 3590.95, 20, NULL, false, false, true, false),
    ('home-life', 'EXF-VESTEL-SUPURGE', 'Vestel Dikey Supurge', 'TRY', 3839.83, 14, NULL, false, false, true, false),
    ('electronics', 'EXF-MSI-GAMING-PRO', 'Msi Gaming Pro', 'TRY', 5337.18, 10, NULL, false, false, false, true)
) AS v(category_code, sku, name, currency_code, price, stock_qty, image_url, is_featured, is_campaign, is_discounted, is_personal)
JOIN public.categories c ON c.code = v.category_code
ON CONFLICT (sku) DO UPDATE
SET name = EXCLUDED.name,
    category_id = EXCLUDED.category_id,
    currency_code = EXCLUDED.currency_code,
    price = EXCLUDED.price,
    stock_qty = EXCLUDED.stock_qty,
    image_url = EXCLUDED.image_url,
    is_featured = EXCLUDED.is_featured,
    is_campaign = EXCLUDED.is_campaign,
    is_discounted = EXCLUDED.is_discounted,
    is_personal = EXCLUDED.is_personal;

INSERT INTO public.campaigns (code, name, description, discount_pct)
VALUES ('demo-campaign', 'Kampanyali Urunler', 'Canli B2B ana sayfasindaki kampanya bolumu icin demo kampanya.', 5)
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    description = EXCLUDED.description,
    discount_pct = EXCLUDED.discount_pct;

INSERT INTO public.product_campaigns (product_id, campaign_id)
SELECT p.id, c.id
FROM public.products p
CROSS JOIN public.campaigns c
WHERE p.is_campaign = true
  AND c.code = 'demo-campaign'
ON CONFLICT DO NOTHING;
