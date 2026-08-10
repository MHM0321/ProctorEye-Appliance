# ProctorEye appliance - FIRST-TIME setup only. Safe to re-run. When this
# finishes, go to ..\run and run run.bat to actually start the app - this
# script only prepares things, it never starts anything itself.
$ErrorActionPreference = "Stop"
Set-Location "$PSScriptRoot\.."

function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Exit-WithPause {
  Write-Host ""
  Read-Host "Press Enter to close"
  exit 1
}

# --- Docker check ---
Write-Step "Checking Docker..."
try {
  docker info *> $null
  if ($LASTEXITCODE -ne 0) { throw "not running" }
} catch {
  Write-Host ""
  Write-Host "Docker doesn't seem to be installed or running." -ForegroundColor Red
  Write-Host "Install Docker Desktop from https://www.docker.com/products/docker-desktop/" -ForegroundColor Red
  Write-Host "then start it and run this installer again."
  Exit-WithPause
}
Write-Host "Docker is running."

# --- .env ---
if (-not (Test-Path .env)) {
  Copy-Item .env.example .env
  Write-Step "Created .env from .env.example"
}

# --- license.jwt placeholder ---
# Must exist as a FILE before the first `docker compose up` - Docker
# silently creates a missing bind-mount source as a DIRECTORY instead,
# which would then block ever dropping a real license.jwt there later.
if (-not (Test-Path license.jwt)) {
  New-Item -ItemType File -Path license.jwt | Out-Null
  Write-Step "Created empty license.jwt placeholder (drop a real one here any time)"
}

# --- secrets ---
# Create()+GetBytes(), not the static ::Fill() - Fill only exists on newer
# .NET, and install.bat launches plain "powershell" (Windows PowerShell 5.1,
# .NET Framework) by default, not pwsh - confirmed directly, Fill failed
# with MethodNotFound there. Create()+GetBytes() works on both.
function New-RandomHex64 {
  $bytes = New-Object byte[] 32
  $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
  try { $rng.GetBytes($bytes) } finally { $rng.Dispose() }
  -join ($bytes | ForEach-Object { $_.ToString("x2") })
}

$envLines = Get-Content .env
$changed = $false
for ($i = 0; $i -lt $envLines.Count; $i++) {
  foreach ($key in @("JWT_SECRET", "INTERNAL_API_SECRET")) {
    if ($envLines[$i] -match "^$key=\s*$") {
      $envLines[$i] = "$key=$(New-RandomHex64)"
      Write-Step "Set $key"
      $changed = $true
    }
  }
}
if ($changed) { Set-Content -Path .env -Value $envLines -Encoding utf8 }

# --- sanity check ---
$envMap = @{}
Get-Content .env | Where-Object { $_ -match "^\w+=" } | ForEach-Object {
  $k, $v = $_ -split "=", 2
  $envMap[$k] = $v
}
if ($envMap["IMAGE_REGISTRY"] -eq "ghcr.io/change-me" -or [string]::IsNullOrWhiteSpace($envMap["IMAGE_REGISTRY"])) {
  Write-Host ""
  Write-Host "IMAGE_REGISTRY in .env is still the placeholder - set it to the" -ForegroundColor Yellow
  Write-Host "value ProctorEye gave you, then run this installer again." -ForegroundColor Yellow
  Exit-WithPause
}
if ($envMap["PUBLIC_API_URL"] -eq "http://localhost:4000") {
  Write-Host ""
  Write-Host "PUBLIC_API_URL in .env is still 'localhost' - fine for testing on" -ForegroundColor Yellow
  Write-Host "this machine only. For real use, set it to this machine's real" -ForegroundColor Yellow
  Write-Host "address (see .env.example), edit .env, then run this again." -ForegroundColor Yellow
}

# --- pull (setup only - does NOT start anything) ---
Write-Step "Pulling images (first run only downloads anything new)..."
docker compose pull
if ($LASTEXITCODE -ne 0) { Exit-WithPause }

Write-Host ""
Write-Host "Setup complete." -ForegroundColor Green
Write-Host "Next: go to the run folder and double-click run.bat to start ProctorEye."
Write-Host ""
Read-Host "Press Enter to close"
