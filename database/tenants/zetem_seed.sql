-- ============================================================================
-- zetem_db — Zetem kiracı seed (000…003 migration sonrası çalıştırılır)
-- ============================================================================

SET client_encoding = 'UTF8';

INSERT INTO public.companies (code, name, currency_code)
VALUES ('ZETEM', 'Zetem', 'GBP')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    currency_code = EXCLUDED.currency_code,
    is_active = true;

-- Demo bayi — Zetem şirketine bağla
INSERT INTO public.customers (company_id, code, title, customer_type, balance, credit_limit, average_maturity_days, past_due_balance, email, phone)
SELECT id, 'demo', 'Zetem Demo Bayi', 'company', 0, 50000, 30, 0, 'demo@zetem.co.uk', '+44 20 0000 0000'
FROM public.companies
WHERE code = 'ZETEM'
ON CONFLICT (code) DO UPDATE
SET title = EXCLUDED.title,
    company_id = EXCLUDED.company_id,
    email = EXCLUDED.email,
    phone = EXCLUDED.phone;

-- Perakende / vitrin cari
INSERT INTO public.customers (company_id, code, title, customer_type, credit_limit)
SELECT id, 'retail', 'Zetem Retail / Guest', 'individual', 0
FROM public.companies
WHERE code = 'ZETEM'
ON CONFLICT (code) DO UPDATE
SET title = EXCLUDED.title,
    company_id = EXCLUDED.company_id;

INSERT INTO public.users (customer_id, role_id, username, password_hash, full_name, email)
SELECT c.id, r.id, 'zetem', crypt('1234', gen_salt('bf')), 'Zetem Demo User', 'demo@zetem.co.uk'
FROM public.customers c
CROSS JOIN public.roles r
WHERE c.code = 'demo'
  AND r.code = 'dealer'
ON CONFLICT (username) DO UPDATE
SET customer_id = EXCLUDED.customer_id,
    role_id = EXCLUDED.role_id,
    full_name = EXCLUDED.full_name,
    email = EXCLUDED.email,
    password_hash = EXCLUDED.password_hash;

INSERT INTO public.announcements (title, body)
SELECT v.title, v.body
FROM (VALUES
  ('Welcome to Zetem', 'Wholesale B2B portal — new season lines now available.'),
  ('Free UK delivery', 'Orders over £500 qualify for free delivery.')
) AS v(title, body)
WHERE NOT EXISTS (
  SELECT 1 FROM public.announcements a WHERE a.title = v.title
);

-- EXFIN şablon kaydını pasifleştir (migration varsayılanı)
UPDATE public.companies SET is_active = false WHERE code = 'EXFIN';

NOTIFY pgrst, 'reload schema';
