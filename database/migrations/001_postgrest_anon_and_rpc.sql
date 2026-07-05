-- ============================================================================
-- B2B — PostgREST anon rolu ve login RPC
-- RetailEX desenindeki logic.verify_login(username, password, firm_nr) uyarlamasi.
-- ============================================================================

SET client_encoding = 'UTF8';

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE SCHEMA IF NOT EXISTS logic;
CREATE SCHEMA IF NOT EXISTS b2b;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'anon') THEN
    CREATE ROLE anon NOLOGIN;
  END IF;
END $$;

DO $$
BEGIN
  EXECUTE format('GRANT CONNECT ON DATABASE %I TO anon', current_database());
END $$;

DO $$
DECLARE
  s text;
BEGIN
  FOREACH s IN ARRAY ARRAY['public', 'logic', 'b2b'] LOOP
    IF EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = s) THEN
      EXECUTE format('GRANT USAGE ON SCHEMA %I TO anon', s);
      EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA %I TO anon', s);
      EXECUTE format('GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA %I TO anon', s);
      EXECUTE format('GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA %I TO anon', s);
      EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO anon', s);
      EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT USAGE, SELECT ON SEQUENCES TO anon', s);
      EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT EXECUTE ON FUNCTIONS TO anon', s);
    END IF;
  END LOOP;
END $$;

DROP FUNCTION IF EXISTS logic.verify_login(text, text, text);

CREATE OR REPLACE FUNCTION logic.verify_login(
  username text,
  password text,
  firm_nr text DEFAULT ''
)
RETURNS TABLE (
  id uuid,
  username text,
  email text,
  full_name text,
  customer_id uuid,
  customer_code text,
  customer_title text,
  firm_nr text,
  role_id uuid,
  role_name text,
  role_permissions jsonb,
  balance numeric,
  credit_limit numeric,
  average_maturity_days integer,
  past_due_balance numeric,
  created_at timestamptz
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $fn$
  SELECT
    u.id,
    u.username,
    u.email,
    u.full_name,
    c.id AS customer_id,
    c.code AS customer_code,
    c.title AS customer_title,
    c.code AS firm_nr,
    r.id AS role_id,
    r.name AS role_name,
    r.permissions AS role_permissions,
    c.balance,
    c.credit_limit,
    c.average_maturity_days,
    c.past_due_balance,
    u.created_at
  FROM public.users u
  LEFT JOIN public.customers c ON c.id = u.customer_id
  LEFT JOIN public.roles r ON r.id = u.role_id
  WHERE COALESCE(u.is_active, true)
    AND COALESCE(c.is_active, true)
    AND lower(u.username) = lower($1)
    AND u.password_hash IS NOT NULL
    AND u.password_hash = crypt($2, u.password_hash)
    AND (
      $3 IS NULL
      OR $3 = ''
      OR c.code = $3
    )
  LIMIT 1;
$fn$;

GRANT EXECUTE ON FUNCTION logic.verify_login(text, text, text) TO anon;

NOTIFY pgrst, 'reload schema';
