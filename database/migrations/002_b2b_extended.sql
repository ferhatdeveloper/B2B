-- ============================================================================
-- B2B — genisletilmis yapilar
--   * Sevk irsaliyeleri (dispatches) + faturalanmamis irsaliye kavrami
--   * Cari hareketler (account_transactions) + b2b.account_statement (ekstre) view
--   * Favori urunler (favorites)
--   * Odeme saglayici / Stripe alanlari (payments uzerinde)
--   * Logo entegrasyonu icin kaynak izleme alanlari (source / external_code)
-- RetailEX deseni: tablolar `public`, REST view'lari `b2b`, RPC'ler `logic`.
-- ============================================================================

SET client_encoding = 'UTF8';

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE SCHEMA IF NOT EXISTS logic;
CREATE SCHEMA IF NOT EXISTS b2b;

-- --- Logo/dis kaynak izleme alanlari (idempotent) ---------------------------
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS source text NOT NULL DEFAULT 'local';
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS external_code text;
ALTER TABLE public.customers ADD COLUMN IF NOT EXISTS source text NOT NULL DEFAULT 'local';
ALTER TABLE public.customers ADD COLUMN IF NOT EXISTS external_code text;

-- --- Odeme saglayici / Stripe alanlari --------------------------------------
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS provider text NOT NULL DEFAULT 'manual';
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS stripe_session_id text;
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS stripe_payment_intent_id text;
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS stripe_status text;

-- --- Sevk irsaliyeleri -------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.dispatches (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid NOT NULL REFERENCES public.customers(id) ON DELETE RESTRICT,
  order_id uuid REFERENCES public.orders(id) ON DELETE SET NULL,
  invoice_id uuid REFERENCES public.invoices(id) ON DELETE SET NULL,
  dispatch_no text NOT NULL UNIQUE,
  status text NOT NULL DEFAULT 'open',
  currency_code text NOT NULL DEFAULT 'TRY',
  amount numeric(18, 2) NOT NULL DEFAULT 0,
  is_invoiced boolean NOT NULL DEFAULT false,
  dispatched_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_dispatches_customer_id ON public.dispatches(customer_id);

-- --- Favori urunler ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.favorites (
  customer_id uuid NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
  product_id uuid NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (customer_id, product_id)
);

-- --- Cari hareketler (ekstre kaynagi) ---------------------------------------
CREATE TABLE IF NOT EXISTS public.account_transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
  txn_date date NOT NULL DEFAULT current_date,
  doc_no text NOT NULL,
  doc_type text NOT NULL,
  debit numeric(18, 2) NOT NULL DEFAULT 0,
  credit numeric(18, 2) NOT NULL DEFAULT 0,
  description text,
  source text NOT NULL DEFAULT 'local',
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_acct_txn_customer ON public.account_transactions(customer_id, txn_date);

-- --- b2b view'lari -----------------------------------------------------------
-- Cari ekstre: tarih sirali, yuruyen bakiye (borc - alacak kumulatif).
CREATE OR REPLACE VIEW b2b.account_statement AS
SELECT
  t.id,
  t.customer_id,
  c.code AS customer_code,
  t.txn_date,
  t.doc_no,
  t.doc_type,
  t.debit,
  t.credit,
  t.description,
  sum(t.debit - t.credit) OVER (
    PARTITION BY t.customer_id
    ORDER BY t.txn_date, t.created_at
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS running_balance
FROM public.account_transactions t
JOIN public.customers c ON c.id = t.customer_id;

-- Faturalanmamis irsaliyeler.
CREATE OR REPLACE VIEW b2b.unbilled_dispatches AS
SELECT d.id, d.customer_id, d.dispatch_no, d.status, d.currency_code, d.amount, d.dispatched_at
FROM public.dispatches d
WHERE d.is_invoiced = false;

-- Odenmemis faturalar.
CREATE OR REPLACE VIEW b2b.open_invoices AS
SELECT i.id, i.customer_id, i.invoice_no, i.status, i.currency_code, i.amount, i.due_date, i.issued_at
FROM public.invoices i
WHERE i.status IN ('unpaid', 'partial');

-- ============================================================================
-- SEED — demo bayi icin tum menulerde icerik olusur
-- ============================================================================
DO $$
DECLARE
  v_customer uuid;
  v_order_completed uuid;
  v_order_pending uuid;
  v_inv1 uuid;
  v_inv2 uuid;
BEGIN
  SELECT id INTO v_customer FROM public.customers WHERE code = 'demo';
  IF v_customer IS NULL THEN
    RAISE NOTICE 'demo musteri yok, seed atlandi';
    RETURN;
  END IF;

  -- Sevk adresleri
  INSERT INTO public.shipping_addresses (customer_id, title, contact_name, phone, address_line, district, city, is_default)
  VALUES
    (v_customer, 'Merkez Depo', 'Demo Yetkili', '05050000000', 'Teknokent Kat:1', 'Merkez', 'Isparta', true),
    (v_customer, 'Sube 1', 'Sube Yetkili', '05050000001', 'Sanayi Sitesi No:10', 'Merkez', 'Antalya', false)
  ON CONFLICT DO NOTHING;

  -- Ornek siparisler (tamamlanan + bekleyen)
  INSERT INTO public.orders (order_no, customer_id, status, currency_code, subtotal, tax_total, grand_total, note)
  VALUES ('ORD-2026-0001', v_customer, 'completed', 'TRY', 10000, 2000, 12000, 'Gecmis siparis')
  ON CONFLICT (order_no) DO UPDATE SET status = EXCLUDED.status
  RETURNING id INTO v_order_completed;

  INSERT INTO public.orders (order_no, customer_id, status, currency_code, subtotal, tax_total, grand_total, note)
  VALUES ('ORD-2026-0002', v_customer, 'pending', 'TRY', 5000, 1000, 6000, 'Onay bekleyen siparis')
  ON CONFLICT (order_no) DO UPDATE SET status = EXCLUDED.status
  RETURNING id INTO v_order_pending;

  -- Faturalar (biri odenmemis, biri kismi)
  INSERT INTO public.invoices (customer_id, order_id, invoice_no, status, currency_code, amount, due_date)
  VALUES (v_customer, v_order_completed, 'FAT-2026-0001', 'unpaid', 'TRY', 12000, current_date + 15)
  ON CONFLICT (invoice_no) DO UPDATE SET status = EXCLUDED.status
  RETURNING id INTO v_inv1;

  INSERT INTO public.invoices (customer_id, invoice_no, status, currency_code, amount, due_date)
  VALUES (v_customer, 'FAT-2026-0002', 'partial', 'TRY', 8000, current_date + 30)
  ON CONFLICT (invoice_no) DO UPDATE SET status = EXCLUDED.status
  RETURNING id INTO v_inv2;

  -- Odemeler
  INSERT INTO public.payments (customer_id, payment_no, method, status, currency_code, amount, paid_at, provider)
  VALUES (v_customer, 'ODE-2026-0001', 'transfer', 'approved', 'TRY', 4000, now() - interval '5 days', 'manual')
  ON CONFLICT (payment_no) DO NOTHING;

  -- Sevk irsaliyeleri (biri faturalanmamis)
  INSERT INTO public.dispatches (customer_id, order_id, invoice_id, dispatch_no, status, amount, is_invoiced)
  VALUES
    (v_customer, v_order_completed, v_inv1, 'IRS-2026-0001', 'shipped', 12000, true),
    (v_customer, v_order_pending, NULL, 'IRS-2026-0002', 'shipped', 6000, false)
  ON CONFLICT (dispatch_no) DO NOTHING;

  -- Cek / senet
  INSERT INTO public.checks_notes (customer_id, document_no, document_type, status, currency_code, amount, due_date)
  VALUES
    (v_customer, 'CEK-001', 'check', 'open', 'TRY', 7500, current_date + 45),
    (v_customer, 'SEN-001', 'note', 'open', 'TRY', 5000, current_date + 60)
  ON CONFLICT (customer_id, document_no) DO NOTHING;

  -- Cari hareketler (ekstre)
  INSERT INTO public.account_transactions (customer_id, txn_date, doc_no, doc_type, debit, credit, description)
  VALUES
    (v_customer, current_date - 20, 'FAT-2026-0001', 'Satis Faturasi', 12000, 0, 'Mal satisi'),
    (v_customer, current_date - 15, 'ODE-2026-0001', 'Tahsilat', 0, 4000, 'Havale tahsilat'),
    (v_customer, current_date - 10, 'FAT-2026-0002', 'Satis Faturasi', 8000, 0, 'Mal satisi'),
    (v_customer, current_date - 3,  'CEK-001', 'Cek Girisi', 0, 7500, 'Musteri ceki')
  ON CONFLICT DO NOTHING;

  -- Favoriler
  INSERT INTO public.favorites (customer_id, product_id)
  SELECT v_customer, p.id FROM public.products p WHERE p.is_featured = true LIMIT 3
  ON CONFLICT DO NOTHING;

  -- Duyurular
  INSERT INTO public.announcements (title, body)
  VALUES
    ('Yeni Urun Lansmani', '2026 yeni urun ailesi satista.'),
    ('Bayram Tatili', 'Sevkiyatlar tatil sonrasi devam edecektir.')
  ON CONFLICT DO NOTHING;
END $$;

-- --- Yetkiler (yeni nesneler icin anon) -------------------------------------
DO $$
DECLARE
  s text;
BEGIN
  FOREACH s IN ARRAY ARRAY['public', 'logic', 'b2b'] LOOP
    EXECUTE format('GRANT USAGE ON SCHEMA %I TO anon', s);
    EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA %I TO anon', s);
    EXECUTE format('GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA %I TO anon', s);
    EXECUTE format('GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA %I TO anon', s);
  END LOOP;
END $$;

NOTIFY pgrst, 'reload schema';
