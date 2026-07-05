# Çok kiracılı B2B veritabanları

## Yapı

| Veritabanı | Amaç | PostgREST |
| --- | --- | ---: |
| `merkez_db` | Kiracı kayıt defteri (`public.tenants`) | `http://localhost:3001` |
| `b2b_local` | EXFIN yerel geliştirme | `http://localhost:3002` |
| `zetem_db` | **Zetem** müşteri veritabanı | `http://localhost:3003` |

## İlk kurulum (Docker)

```bash
docker compose up -d
```

İlk açılışta `database/init/00-create-databases.sh` şunları yapar:

1. `merkez_db` + `zetem_db` oluşturur
2. `merkez_db` → `tenants` tablosu + kayıtlar
3. `b2b_local` ve `zetem_db` → B2B migration'ları (`000`…`003`)
4. `zetem_db` → `tenants/zetem_seed.sql` (ZETEM şirketi, demo kullanıcı)

## Zetem giriş bilgileri

| Alan | Değer |
| --- | --- |
| PostgREST | `http://localhost:3003` |
| Kullanıcı | `zetem` |
| Parola | `1234` |
| Para birimi | GBP |

## Kiracı listesi (merkez)

```bash
curl "http://localhost:3001/tenants?select=code,name,db_name,postgrest_url,is_active"
```

## Yeni müşteri ekleme

```bash
chmod +x scripts/provision-tenant.sh
./scripts/provision-tenant.sh yeni_musteri "Yeni Müşteri" yeni_musteri_db 3004 TRY
```

Özel seed için `database/tenants/{code}_seed.sql` dosyası oluşturun (örnek: `zetem_seed.sql`).

## Var olan PostgreSQL'e elle ekleme

```bash
export PGPASSWORD=postgres
./scripts/provision-tenant.sh zetem "Zetem" zetem_db 3003 GBP
```

`docker-compose.yml` içine yeni `postgrest-{code}` servisi ekleyin.
