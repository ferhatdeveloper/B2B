-- ============================================================================
-- B2B/C2C — Storefront (e-ticaret) desteği
--   * Perakende/misafir cari: storefront siparişleri buraya bağlanır
--   * Sipariş kanalı (channel) alanı: 'b2b' (bayi paneli) vs 'storefront'
-- ============================================================================

SET client_encoding = 'UTF8';

ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS channel text NOT NULL DEFAULT 'b2b';
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS buyer_name text;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS buyer_email text;

-- Perakende (misafir) cari — storefront/C2C siparişleri için.
INSERT INTO public.customers (company_id, code, title, customer_type, credit_limit)
SELECT id, 'retail', 'Perakende / Misafir', 'individual', 0
FROM public.companies
WHERE code = 'EXFIN'
ON CONFLICT (code) DO UPDATE SET title = EXCLUDED.title;

-- Yeni nesneler/satırlar için anon yetkileri tazele.
DO $$
DECLARE s text;
BEGIN
  FOREACH s IN ARRAY ARRAY['public', 'logic', 'b2b'] LOOP
    EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA %I TO anon', s);
    EXECUTE format('GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA %I TO anon', s);
  END LOOP;
END $$;

NOTIFY pgrst, 'reload schema';
