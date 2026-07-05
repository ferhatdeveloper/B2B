# AGENTS.md

## Depo kuralları

- **Git:** Tüm agent değişiklikleri doğrudan `main` branch'ine commit ve `git push origin main` ile yüklenir.
- **Flutter:** Durum yönetimi yalnızca **Riverpod** (`flutter_riverpod`). Ayrıntılar: `.cursor/rules/flutter-riverpod-architecture.mdc`.

## Cursor Cloud specific instructions

### What this project is
B2B bayi portalı için REST servis iskeleti. "Uygulama" Docker Compose ile çalışan iki servistir:

| Servis | Port | Açıklama |
| --- | --- | --- |
| PostgreSQL 16 | 5432 | Ana veritabanı (`b2b_local`), şema/seed `database/migrations/` altından ilk açılışta uygulanır |
| PostgREST v12.2.0 | 3002 (host) → 3000 (container) | `public`, `logic`, `b2b` şemaları üzerinde tablo/RPC REST API |

Ayrıca `src/` altında yalnızca tip-kontrolü yapılan (çalıştırılmayan) bir TypeScript PostgREST istemcisi var.

`app/` altında bu REST API'yi tüketen bir **Flutter (web)** istemci uygulaması bulunur. İki deneyim içerir:
- **E-ticaret sitesi (storefront)** — herkese açık, misafir alışveriş (`app/lib/storefront/`). Varsayılan açılış budur; siparişler `retail` carisine `channel='storefront'` ile yazılır. 4 tema: **Zetem** (varsayılan, zetem.co.uk tarzı temiz cyan B2B), Minimal, Modern, Bold (sağ üstteki palet ikonu veya Ayarlar'dan seçilir). İki katmanlı header (üst destek/Bayi Girişi barı + logo/arama/sepet) + kategori nav + hero + kategori kartları + ürün grid + üç sütun footer. Sağ üstte **"Bayi Girişi"** bayi paneline götürür.
- **Bayi paneli (panel)** — giriş gerektirir: dashboard, ürün kataloğu, favoriler, kampanyalar, duyurular, sepet/sipariş, bekleyen/önceki siparişler, ödeme (Stripe), ödemelerim, cari ekstre, ödenmemiş faturalar, çek/senet, faturalanmamış irsaliyeler, sevk adresleri, cari hesap, **Ayarlar**.

Açılış modu (E-ticaret/Panel) ve storefront teması **Ayarlar › Site Görünümü**'nden seçilir ve `localStorage`'da saklanır (`appSettingsProvider`). Giriş yapan kullanıcı paneli, misafir ise storefront'u görür; panelden "E-ticaret sitesini önizle" ile storefront önizlenebilir.

`server/` altında bir **Node/Express entegrasyon servisi** bulunur (port 4000): Stripe ödeme (Checkout) ve **Logo Object REST Service** senkronizasyonu (ürün/cari). Gerçek `STRIPE_SECRET_KEY` / `LOGO_BASE_URL` verilmezse otomatik **mock modda** çalışır (yerelde uçtan uca demo için).

### Flutter uygulaması (`app/`)

**Mimari:** Riverpod 2.x — `ProviderScope`, `core/providers/` (auth, cart, app settings, b2b service). Ekranlar `ConsumerWidget` / `ConsumerStatefulWidget`. Yeni özellikler `features/<ad>/` altında feature-first eklenir. Performans: `select`, türetilmiş provider'lar, `const` widget'lar.

- Flutter SDK `/opt/flutter-sdk/bin` altındadır ve `~/.bashrc` ile PATH'e eklenmiştir; web hedefi etkindir (`flutter config --enable-web`). Android/Linux-desktop toolchain'leri kurulu DEĞİLDİR; sadece **web** (Chrome) hedefi çalışır.
- Geliştirme sunucusu: `cd app && flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0 --dart-define=POSTGREST_URL=http://localhost:3002`. Tarayıcıda `http://localhost:8080`.
- API tabanı `POSTGREST_URL` dart-define ile verilir (varsayılan `http://localhost:3002`, bkz. `app/lib/config/api_config.dart`).
- API tabanları derleme zamanı define'larıyla geçilir: `--dart-define=POSTGREST_URL=http://localhost:3002 --dart-define=INTEGRATION_URL=http://localhost:4000`.
- Lint/analiz: `cd app && flutter analyze`. Test: `cd app && flutter test`.
- İlk web derlemesi (debug) 20-40 sn sürebilir; ilk açılışta beyaz ekran görürseniz bekleyin veya bir kez hard-refresh (Ctrl+Shift+R) yapın.
- **Gotcha (boş/beyaz ekran):** Çok sayıda yeniden başlatma / paket ekleme sonrası Flutter web debug **DDC build önbelleği bayatlayıp** konsolda hata olmadan boş sayfa sunabilir. Çözüm: `flutter run`'ı durdurun, `cd app && rm -rf build .dart_tool/flutter_build` ile önbelleği silip yeniden başlatın (gerekirse tarayıcıyı hard-refresh). Yeni paket eklenince (pub add) dev sunucusunu tamamen yeniden başlatın; hot reload yeni bağımlılığı/asseti almaz.
- Web renderer CanvasKit'tir ve Flutter tarafından `/canvaskit/` üzerinden yerelden sunulur (harici CDN gerekmez).

### Entegrasyon servisi (`server/`) — Stripe + Logo
- Çalıştırma: `cd server && npm start` (veya `npm run dev`). Port 4000. PostgREST'e `POSTGREST_URL` (vars. `http://localhost:3002`) üzerinden yazar.
- Sağlık: `GET /api/health` → `{stripe: mock|live, logo: mock|live}`.
- **Logo:** `POST /api/logo/sync` ürün/cari çeker ve PostgREST tablolarına yazar (`products.source='logo'`). `LOGO_BASE_URL` verilmezse dahili mock Logo (`/mock-logo/api/v1`) kullanılır. Gerçek bağlantı için secret'lar: `LOGO_BASE_URL`, `LOGO_CLIENT_ID`/`LOGO_CLIENT_SECRET` (veya `LOGO_USERNAME`/`LOGO_PASSWORD`), `LOGO_FIRM_NO`, `LOGO_PERIOD_NO`. LRS endpoint deseni: `POST /api/v1/token` → bearer; `GET /api/v1/items|arps|inventories`.
- **Stripe:** `POST /api/payments/checkout {customer_id,amount}` → Checkout URL döner; başarıda webhook/redirect ödemeyi `approved` yapıp cari harekete `Tahsilat` ekler. `STRIPE_SECRET_KEY` yoksa mock akış (`/api/payments/mock-complete`) ile uçtan uca çalışır. Gerçek için secret'lar: `STRIPE_SECRET_KEY` (test `sk_test_...`), `STRIPE_WEBHOOK_SECRET`, ve `PUBLIC_APP_URL` (başarı/iptal dönüş adresi, vars. `http://localhost:8080`).
- Stripe Checkout tam-sayfa yönlendirme kullanır; Flutter SPA oturumu `localStorage`'da saklanır (`utils/session_store_web.dart`) ki ödemeden dönünce kullanıcı giriş yapmış kalsın.

### Şema (migration'lar)
- `database/migrations/` sırayla uygulanır: `000` temel şema+seed, `001` anon+`verify_login`, `002` genişletilmiş yapılar (dispatches/irsaliye, account_transactions + `b2b.account_statement` view, favorites, payments Stripe alanları, `products/customers.source`). Değişiklik sonrası yeniden uygulamak için `sudo docker compose down -v && up -d`.

### Tüm yığını çalıştırma sırası
1. `sudo dockerd &` (systemd yok) → `sudo docker compose up -d` (postgres+postgrest).
2. `cd server && npm start` (entegrasyon servisi, :4000).
3. `cd app && flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0 --dart-define=POSTGREST_URL=http://localhost:3002 --dart-define=INTEGRATION_URL=http://localhost:4000` → tarayıcı `http://localhost:8080` (demo/1234).

### Running services (Docker daemon must be started first)
- `systemd` bu ortamda çalışmaz; Docker daemon'ı manuel başlatın: arka planda `sudo dockerd` (örn. bir tmux oturumunda). Konteyner/daemon komutları `sudo` gerektirir.
- Docker 29.x ile `fuse-overlayfs` kullanmak için `/etc/docker/daemon.json` içinde `features.containerd-snapshotter` **false** olmalıdır; aksi halde storage driver hatası alınır.
- Yığını başlatma: `sudo docker compose up -d` (npm script karşılığı `npm run db:up`). Durdurma: `npm run db:down`.
- Migration'lar **yalnızca ilk açılışta** (boş `b2b_postgres_data` volume'ünde) çalışır. Şema/seed değişikliklerini yeniden uygulamak için: `sudo docker compose down -v` ile volume'ü silip tekrar `up` yapın.
- Şema değişikliğinden sonra PostgREST cache'ini yenilemek için DB'de `NOTIFY pgrst, 'reload schema';`.

### Lint / test / build / run commands
- Tip kontrolü (bu repodaki tek "lint/build" adımı): `npm run typecheck` (`tsc --noEmit`). Otomatik test paketi yoktur.
- API'yi elle doğrulama (curl) için README ve `database/README_POSTGREST.md` içindeki örnekleri kullanın.

### Non-obvious caveats
- PostgREST `Accept-Profile` / `Content-Profile` header'ları ile şema seçilir: tablolar için `public`, `verify_login` RPC için `logic`, view'lar (`product_catalog`, `customer_dashboard`) için `b2b`. Header verilmezse `public` varsayılır.
- Demo kimlik bilgileri seed verisinde gelir: kullanıcı `demo`, parola `1234` (`logic.verify_login` ile doğrulanır; parola `pgcrypto`/bcrypt hash'i).
- Host portu 3002'dir (container içinde 3000). README'deki tüm örnekler `http://localhost:3002` kullanır.
- **CORS:** PostgREST `server-cors-allowed-origins` (env: `PGRST_SERVER_CORS_ALLOWED_ORIGINS`) ayarını literal/virgülle ayrılmış bir origin allowlist'i olarak yorumlar — `"*"` wildcard DEĞİLDİR. `"*"` verilince hiçbir gerçek origin eşleşmez ve preflight'ta `Access-Control-Allow-Origin` dönmez, tarayıcı isteği "Failed to fetch" ile düşer. Bu yüzden ayar **bilerek boş bırakıldı**: ayarsızken PostgREST permissive olur ve istek Origin'ini yansıtır (Flutter web `:8080` → API `:3002` için gerekli). Production'da gerçek origin(ler) yazılmalıdır.
