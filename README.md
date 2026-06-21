# B2B

Zensoft B2B bayi portalı için Flutter + Riverpod + PostgREST + PostgreSQL başlangıç deposu.

Bu depoda uygulama katmanı `Rentacar` referansındaki feature-first Flutter yaklaşımına, servis katmanı ise `RetailEX` PostgREST düzenine uygun kuruldu:

- Flutter istemci
- Riverpod provider/notifier yapısı
- HTTP tabanlı standalone PostgREST istemcisi
- PostgreSQL ana veri katmanı
- PostgREST ile tablo/RPC tabanlı REST API
- `logic.verify_login(username, password, firm_nr)` RPC yapısı
- `public`, `logic`, `b2b` şema ayrımı

## Canlı site inceleme notları

Kontrol edilen adres: <https://b2b.zensoft.com.tr/>

- Ana sayfa misafir kullanıcıyla açılıyor.
- Login route'u `/login`.
- Korumalı sayfalar örn. `/payments`, `/login?ReturnUrl=%2Fpayments` adresine yönleniyor.
- Ürün/kategori görselleri `https://serviceb2b.gastropos.com.tr/uploads/...` servisinden geliyor.
- Görünen ana modüller: ürünler, sipariş, ödeme, kampanyalar, duyurular, önceki/bekleyen siparişler, cari ekstresi, sevk adresleri, ödenmemiş faturalar, çek/senet ve faturalanmamış irsaliyeler.

## Hızlı başlangıç — API

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

## Hızlı başlangıç — Flutter

```bash
flutter pub get
flutter run \
  --dart-define=POSTGREST_URL=http://localhost:3002 \
  --dart-define=USE_DEMO_FALLBACK=true
```

Demo giriş:

```text
demo
1234
```

## Dosya yapısı

```text
lib/
  app/
  core/
    config/
    network/
    providers/
  features/
    auth/
    catalog/
    orders/
config/
  postgrest.conf
  postgrest.env.example
database/
  README_POSTGREST.md
  migrations/
    000_b2b_schema.sql
    001_postgrest_anon_and_rpc.sql
```

## Flutter mimarisi

```text
feature/
  domain/entities
  domain/repositories
  data/repositories
  presentation/providers
  presentation/pages
```

Ana feature'lar:

- `auth`: `logic.verify_login` RPC ile giriş, local session.
- `catalog`: `b2b.product_catalog` view'ı üzerinden ürün listeleri.
- `orders`: sepet taslağı, toplam hesaplama, `orders` ve `order_lines` yazımı.

PostgREST istemcisi `lib/core/network/postgrest_client.dart` içindedir ve standalone PostgREST'e bağlanır. Supabase bağımlılığı zorunlu değildir.

## Güvenlik notu

Bu iskelet yerel geliştirme ve API yapısını kurmak içindir. Production ortamında:

- Gerçek veritabanı parolalarını repoya yazmayın.
- PostgREST için JWT/RLS veya servis arkasında uygulama yetkilendirmesi kullanın.
- Demo kullanıcı/parola yalnızca yerel seed verisi olarak tutulmalıdır.
