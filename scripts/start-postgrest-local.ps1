# Yerel PostgreSQL uzerinde PostgREST baslatir (port 3002).
# Kullanim:
#   $env:PGRST_DB_PASSWORD = 'SIFRENIZ'
#   powershell -File scripts/start-postgrest-local.ps1
#
# Ilk kurulum: b2b_local veritabani + migration'lar uygulanmis olmali.

$ErrorActionPreference = 'Stop'

if (-not $env:PGRST_DB_PASSWORD) {
  Write-Error 'PGRST_DB_PASSWORD ortam degiskenini ayarlayin (PostgreSQL postgres kullanicisi parolasi).'
}

$root = Split-Path -Parent $PSScriptRoot
$postgrest = Join-Path $root 'bin/postgrest/artifacts/postgrest-windows-x64/postgrest.exe'
$config = Join-Path $root 'config/postgrest.conf'
$pgBin = 'C:\Program Files\PostgreSQL\16\bin'

if (-not (Test-Path $postgrest)) {
  Write-Error "postgrest.exe bulunamadi: $postgrest`nOnce: npm run postgrest:fetch"
}

if (Test-Path $pgBin) {
  $env:Path = "$pgBin;$env:Path"
}

$env:PGRST_DB_URI = "postgres://postgres:$($env:PGRST_DB_PASSWORD)@127.0.0.1:5432/b2b_local"

Write-Host "PostgREST baslatiliyor (http://localhost:3002, db=b2b_local)..."
& $postgrest $config
