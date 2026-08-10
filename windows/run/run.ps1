# Everyday start - no setup, just starts what install\install.bat already
# configured, then opens 3 separate windows (api, worker, dashboard) that
# each tail ONE service's logs and stay open until YOU close them.
#
# Those 3 windows are just log VIEWERS, not what's keeping the app running -
# the containers run detached in the background regardless (so closing a
# log window is always safe, it only stops watching). To actually stop the
# app, use stop.bat in this same folder.
$ErrorActionPreference = "Stop"
Set-Location "$PSScriptRoot\.."

function Exit-WithPause {
  Write-Host ""
  Read-Host "Press Enter to close"
  exit 1
}

if (-not (Test-Path .env)) {
  Write-Host "No .env found - run install\install.bat first (one-time setup)." -ForegroundColor Red
  Exit-WithPause
}

try {
  docker info *> $null
  if ($LASTEXITCODE -ne 0) { throw "not running" }
} catch {
  Write-Host "Docker doesn't seem to be running. Start Docker Desktop and try again." -ForegroundColor Red
  Exit-WithPause
}

Write-Host "==> Starting..." -ForegroundColor Cyan
docker compose up -d
if ($LASTEXITCODE -ne 0) {
  Write-Host ""
  Write-Host "Failed to start - see the error above." -ForegroundColor Red
  Write-Host "(A common cause: it's already running. Check stop.bat if you need a clean restart.)" -ForegroundColor Yellow
  Exit-WithPause
}

Write-Host "==> Opening log windows for api, worker, and dashboard..." -ForegroundColor Cyan
$composeDir = (Get-Location).Path
foreach ($svc in @("api", "worker", "dashboard")) {
  $title = "ProctorEye logs: $svc"
  Start-Process powershell -ArgumentList @(
    "-NoExit", "-Command",
    "`$host.UI.RawUI.WindowTitle = '$title'; Set-Location '$composeDir'; Write-Host 'Logs for: $svc  (closing this window only stops watching - the app keeps running)' -ForegroundColor Cyan; docker compose logs -f --tail 100 $svc"
  )
}

$envMap = @{}
Get-Content .env | Where-Object { $_ -match "^\w+=" } | ForEach-Object {
  $k, $v = $_ -split "=", 2
  $envMap[$k] = $v
}
$dashPort = if ($envMap["DASHBOARD_PORT"]) { $envMap["DASHBOARD_PORT"] } else { "8080" }

Write-Host ""
Write-Host "Running. Open http://localhost:$dashPort" -ForegroundColor Green
Write-Host "(or this machine's real address if PUBLIC_API_URL points elsewhere)"
Write-Host ""
Write-Host "3 log windows just opened - closing them is fine, they're only viewers."
Write-Host "To stop ProctorEye itself, run stop.bat in this same folder."
Write-Host ""
Read-Host "Press Enter to close this window (the app keeps running)"
