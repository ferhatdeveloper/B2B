# AGENTS.md

## Cursor Cloud specific instructions

### What this project is
B2B bayi portalı için REST servis iskeleti. "Uygulama" Docker Compose ile çalışan iki servistir:

| Servis | Port | Açıklama |
| --- | --- | --- |
| PostgreSQL 16 | 5432 | Ana veritabanı (`b2b_local`), şema/seed `database/migrations/` altından ilk açılışta uygulanır |
| PostgREST v12.2.0 | 3002 (host) → 3000 (container) | `public`, `logic`, `b2b` şemaları üzerinde tablo/RPC REST API |

Ayrıca `src/` altında yalnızca tip-kontrolü yapılan (çalıştırılmayan) bir TypeScript PostgREST istemcisi var.

`app/` altında bu REST API'yi tüketen bir **Flutter (web)** istemci uygulaması bulunur (Zen B2B/C2C portalı): giriş, dashboard, ürün kataloğu, sepet, sipariş oluşturma, siparişler ve cari hesap ekranları.

### Flutter uygulaması (`app/`)
- Flutter SDK `/opt/flutter-sdk/bin` altındadır ve `~/.bashrc` ile PATH'e eklenmiştir; web hedefi etkindir (`flutter config --enable-web`). Android/Linux-desktop toolchain'leri kurulu DEĞİLDİR; sadece **web** (Chrome) hedefi çalışır.
- Geliştirme sunucusu: `cd app && flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0 --dart-define=POSTGREST_URL=http://localhost:3002`. Tarayıcıda `http://localhost:8080`.
- API tabanı `POSTGREST_URL` dart-define ile verilir (varsayılan `http://localhost:3002`, bkz. `app/lib/config/api_config.dart`).
- Lint/analiz: `cd app && flutter analyze`. Test: `cd app && flutter test`.
- İlk web derlemesi (debug) 20-40 sn sürebilir; ilk açılışta beyaz ekran görürseniz bekleyin veya bir kez hard-refresh (Ctrl+Shift+R) yapın.

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
