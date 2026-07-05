-- ============================================================================
-- merkez_db — kiracı (tenant) kayıt defteri
-- Her B2B müşterisi: kendi PostgreSQL veritabanı + PostgREST uç noktası
-- ============================================================================

SET client_encoding = 'UTF8';

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS public.tenants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  db_name text NOT NULL UNIQUE,
  postgrest_url text NOT NULL,
  currency_code text NOT NULL DEFAULT 'TRY',
  default_store_theme text NOT NULL DEFAULT 'ella1',
  logo_firm_no integer,
  logo_period_no integer DEFAULT 1,
  contact_email text,
  is_active boolean NOT NULL DEFAULT true,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_tenants_active ON public.tenants (is_active) WHERE is_active = true;

COMMENT ON TABLE public.tenants IS 'B2B kiracı kayıtları — uygulama hangi DB/PostgREST ile çalışacağını buradan seçer';

-- Yerel geliştirme kayıtları
INSERT INTO public.tenants (code, name, db_name, postgrest_url, currency_code, default_store_theme, logo_firm_no, contact_email)
VALUES
  ('exfin', 'EXFIN B2B', 'b2b_local', 'http://localhost:3002', 'TRY', 'ella1', 1, 'demo@example.local'),
  ('zetem', 'Zetem', 'zetem_db', 'http://localhost:3003', 'GBP', 'ella1', 1, 'info@zetem.co.uk')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    db_name = EXCLUDED.db_name,
    postgrest_url = EXCLUDED.postgrest_url,
    currency_code = EXCLUDED.currency_code,
    default_store_theme = EXCLUDED.default_store_theme,
    logo_firm_no = EXCLUDED.logo_firm_no,
    contact_email = EXCLUDED.contact_email,
    updated_at = now();

-- PostgREST anon (kiracı listesi okuma)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'anon') THEN
    CREATE ROLE anon NOLOGIN;
  END IF;
END $$;

GRANT CONNECT ON DATABASE merkez_db TO anon;
GRANT USAGE ON SCHEMA public TO anon;
GRANT SELECT ON public.tenants TO anon;
