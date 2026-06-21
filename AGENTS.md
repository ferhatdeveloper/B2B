# AGENTS.md

## Cursor Cloud specific instructions

### What this project is
B2B bayi portalı için REST servis iskeleti. "Uygulama" Docker Compose ile çalışan iki servistir:

| Servis | Port | Açıklama |
| --- | --- | --- |
| PostgreSQL 16 | 5432 | Ana veritabanı (`b2b_local`), şema/seed `database/migrations/` altından ilk açılışta uygulanır |
| PostgREST v12.2.0 | 3002 (host) → 3000 (container) | `public`, `logic`, `b2b` şemaları üzerinde tablo/RPC REST API |

Ayrıca `src/` altında yalnızca tip-kontrolü yapılan (çalıştırılmayan) bir TypeScript PostgREST istemcisi var.

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
