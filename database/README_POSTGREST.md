# PostgREST — B2B REST API

Bu yapı `RetailEX` deposundaki PostgREST yaklaşımının B2B için sadeleştirilmiş uyarlamasıdır.

## Servisler

| Servis | Port | Açıklama |
| --- | ---: | --- |
| PostgreSQL | 5432 | B2B veritabanı |
| PostgREST | 3002 | PostgreSQL tablo/RPC REST API |

## Şemalar

| Şema | Amaç |
| --- | --- |
| `public` | Ana tablolar: müşteri, kullanıcı, ürün, sipariş, ödeme |
| `logic` | RPC fonksiyonları: `verify_login` |
| `b2b` | REST için okunabilir view'lar: `product_catalog`, `customer_dashboard` |

## Kurulum

```bash
docker compose up -d
```

İlk açılışta `database/migrations` altındaki SQL dosyaları uygulanır.

Var olan bir PostgreSQL üzerinde elle çalıştırmak için:

```bash
psql -U postgres -d b2b_local -v ON_ERROR_STOP=1 -f database/migrations/000_b2b_schema.sql
psql -U postgres -d b2b_local -v ON_ERROR_STOP=1 -f database/migrations/001_postgrest_anon_and_rpc.sql
```

PostgREST binary ile çalıştırmak için:

```bash
PGRST_DB_URI="postgres://postgres:postgres@127.0.0.1:5432/b2b_local" \
  postgrest config/postgrest.conf
```

## Örnek REST çağrıları

Ürün kataloğu:

```bash
curl "http://localhost:3002/product_catalog?select=sku,name,price,currency_code&limit=10" \
  -H "Accept-Profile: b2b"
```

Öne çıkan ürünler:

```bash
curl "http://localhost:3002/product_catalog?is_featured=eq.true&select=sku,name,price" \
  -H "Accept-Profile: b2b"
```

Demo login RPC:

```bash
curl -X POST "http://localhost:3002/rpc/verify_login" \
  -H "Content-Type: application/json" \
  -H "Accept-Profile: logic" \
  -H "Content-Profile: logic" \
  -d '{"username":"demo","password":"1234","firm_nr":""}'
```

Sipariş oluşturma:

```bash
curl -X POST "http://localhost:3002/orders" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d '{"order_no":"WEB-0001","customer_id":"<customer_uuid>","status":"open"}'
```

## Modül / API eşlemesi

| Ekran/menü | REST karşılığı |
| --- | --- |
| Ürünler / öne çıkan ürünler | `b2b.product_catalog` |
| Kampanyalar | `public.campaigns`, `public.product_campaigns` |
| Duyurular | `public.announcements` |
| Sipariş ver / siparişlerim | `public.orders`, `public.order_lines` |
| Ödeme yap / ödemelerim | `public.payments` |
| Sevk adreslerim | `public.shipping_addresses` |
| Ödenmemiş faturalar | `public.invoices` |
| Çek / senet | `public.checks_notes` |
| Cari özet | `b2b.customer_dashboard` |

## Production notları

- `.env` ve gerçek veritabanı parolaları commit edilmemelidir.
- `anon` rolüne verilen yetkiler RetailEX yerel geliştirme düzeniyle uyumlu tutulmuştur; production'da JWT/RLS veya uygulama katmanı yetkilendirmesiyle daraltılmalıdır.
- Şema değişikliklerinden sonra PostgREST cache yenilemek için:

```sql
NOTIFY pgrst, 'reload schema';
```
