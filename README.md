# B2B

B2B bayi portalı için başlangıç deposu.

Bu depoda `RetailEX` projesindeki REST servis yaklaşımı B2B alanına uyarlanmıştır:

- PostgreSQL ana veri katmanı
- PostgREST ile tablo/RPC tabanlı REST API
- `logic.verify_login(username, password, firm_nr)` RPC yapısı
- `public`, `logic`, `b2b` şema ayrımı
- Frontend tarafı için küçük PostgREST TypeScript istemcisi

## Hızlı başlangıç

```bash
cp config/postgrest.env.example .env.postgrest
docker compose up -d
```

PostgREST varsayılan olarak `http://localhost:3002` adresinde açılır.

Örnek kontroller:

```bash
curl "http://localhost:3002/product_catalog?select=sku,name,price&limit=5" \
  -H "Accept-Profile: b2b"

curl -X POST "http://localhost:3002/rpc/verify_login" \
  -H "Content-Type: application/json" \
  -H "Accept-Profile: logic" \
  -H "Content-Profile: logic" \
  -d '{"username":"demo","password":"1234","firm_nr":""}'
```

## Dosya yapısı

```text
config/
  postgrest.conf
  postgrest.env.example
database/
  README_POSTGREST.md
  migrations/
    000_b2b_schema.sql
    001_postgrest_anon_and_rpc.sql
src/
  config/postgrest.config.ts
  services/api/postgrestClient.ts
  services/b2bService.ts
```

## Güvenlik notu

Bu iskelet yerel geliştirme ve API yapısını kurmak içindir. Production ortamında:

- Gerçek veritabanı parolalarını repoya yazmayın.
- PostgREST için JWT/RLS veya servis arkasında uygulama yetkilendirmesi kullanın.
- Demo kullanıcı/parola yalnızca yerel seed verisi olarak tutulmalıdır.
