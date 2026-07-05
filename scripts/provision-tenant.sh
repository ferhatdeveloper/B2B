#!/usr/bin/env bash
# Yeni B2B kiracı veritabanı oluşturur ve merkez_db'ye kaydeder.
# Kullanım:
#   ./scripts/provision-tenant.sh zetem "Zetem" zetem_db 3003 GBP
#
# Argümanlar:
#   1 code          (küçük harf, örn. zetem)
#   2 display name  (örn. Zetem)
#   3 db_name       (örn. zetem_db)
#   4 postgrest_port (örn. 3003)
#   5 currency      (opsiyonel, varsayılan TRY)

set -euo pipefail

CODE="${1:?code gerekli (örn. zetem)}"
NAME="${2:?name gerekli}"
DB_NAME="${3:?db_name gerekli (örn. zetem_db)}"
PORT="${4:?postgrest port gerekli (örn. 3003)}"
CURRENCY="${5:-TRY}"

PGHOST="${PGHOST:-127.0.0.1}"
PGPORT="${PGPORT:-5432}"
PGUSER="${PGUSER:-postgres}"
PGPASSWORD="${PGPASSWORD:-postgres}"
export PGPASSWORD

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MIGRATIONS="$ROOT/database/migrations"
MERKEZ_SQL="$ROOT/database/merkez/001_merkez_schema.sql"
SEED_FILE="$ROOT/database/tenants/${CODE}_seed.sql"
GENERIC_SEED="$ROOT/database/tenants/_tenant_seed.sql"

echo ">> [$CODE] Veritabanı: $DB_NAME"

psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d postgres -v ON_ERROR_STOP=1 <<-EOSQL
  SELECT 'CREATE DATABASE ${DB_NAME}' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '${DB_NAME}')\gexec
EOSQL

for f in $(ls "$MIGRATIONS"/*.sql | sort); do
  echo "   migration: $(basename "$f")"
  psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -f "$f"
done

if [[ -f "$SEED_FILE" ]]; then
  echo "   seed: $(basename "$SEED_FILE")"
  psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -f "$SEED_FILE"
elif [[ -f "$GENERIC_SEED" ]]; then
  psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$DB_NAME" -v ON_ERROR_STOP=1 \
    -v tenant_code="$CODE" -v tenant_name="$NAME" -v tenant_currency="$CURRENCY" -f "$GENERIC_SEED"
fi

# merkez_db kaydı
psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d merkez_db -v ON_ERROR_STOP=1 <<-EOSQL
  INSERT INTO public.tenants (code, name, db_name, postgrest_url, currency_code)
  VALUES (
    lower('${CODE}'),
    '${NAME}',
    '${DB_NAME}',
    'http://localhost:${PORT}',
    '${CURRENCY}'
  )
  ON CONFLICT (code) DO UPDATE
  SET name = EXCLUDED.name,
      db_name = EXCLUDED.db_name,
      postgrest_url = EXCLUDED.postgrest_url,
      currency_code = EXCLUDED.currency_code,
      updated_at = now();
EOSQL

echo ">> [$CODE] Hazır. PostgREST: http://localhost:${PORT}  |  DB: ${DB_NAME}"
echo "   docker compose up -d postgrest-${CODE}  (servis tanımlıysa)"
