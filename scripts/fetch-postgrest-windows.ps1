# PostgREST v12.2.0 Windows x64 — bin/postgrest/ altina indirir (docker-compose ile ayni surum).
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$root = Split-Path -Parent $PSScriptRoot
$OutDir = Join-Path $root 'bin/postgrest/artifacts/postgrest-windows-x64'
$TargetExe = Join-Path $OutDir 'postgrest.exe'

if (Test-Path $TargetExe) {
  Write-Host "[postgrest] Zaten mevcut: $TargetExe"
  exit 0
}

$ver = '12.2.0'
$asset = "postgrest-v$ver-windows-x64.zip"
$ZipUrl = "https://github.com/PostgREST/postgrest/releases/download/v$ver/$asset"
$zipPath = Join-Path $env:TEMP "b2b-postgrest-$ver.zip"
$extract = Join-Path $env:TEMP "b2b-postgrest-extract"

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
Write-Host "[postgrest] Indiriliyor: $ZipUrl"
Invoke-WebRequest -Uri $ZipUrl -OutFile $zipPath -UseBasicParsing
if (Test-Path $extract) { Remove-Item $extract -Recurse -Force }
Expand-Archive -LiteralPath $zipPath -DestinationPath $extract -Force
$exe = Get-ChildItem -Path $extract -Filter 'postgrest.exe' -Recurse | Select-Object -First 1
if (-not $exe) { throw 'postgrest.exe arsivde bulunamadi.' }
Copy-Item -LiteralPath $exe.FullName -Destination $TargetExe -Force
Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
Remove-Item $extract -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "[postgrest] Tamam: $TargetExe"
