#!/bin/bash
# PostgreSQL ilk kurulum: merkez_db + kiracı veritabanları + migration'lar
set -euo pipefail

MIGRATIONS_DIR="/docker-entrypoint-initdb.d/migrations"
MERKEZ_SQL="/docker-entrypoint-initdb.d/merkez/001_merkez_schema.sql"
ZETEM_SEED="/docker-entrypoint-initdb.d/tenants/zetem_seed.sql"

run_migrations() {
  local db="$1"
  echo ">> [$db] B2B migration'ları uygulanıyor..."
  for f in $(ls "$MIGRATIONS_DIR"/*.sql 2>/dev/null | sort); do
    echo "   - $(basename "$f")"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$db" -f "$f"
  done
}

echo ">> merkez_db oluşturuluyor..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  SELECT 'CREATE DATABASE merkez_db' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'merkez_db')\gexec
  SELECT 'CREATE DATABASE zetem_db' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'zetem_db')\gexec
EOSQL

echo ">> merkez_db şeması..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname merkez_db -f "$MERKEZ_SQL"

run_migrations "$POSTGRES_DB"
run_migrations zetem_db

echo ">> zetem_db kiracı seed..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname zetem_db -f "$ZETEM_SEED"

echo ">> Tamamlandı: merkez_db, $POSTGRES_DB, zetem_db"
