# Stops ProctorEye. Your data (sessions, uploads, the database) is
# untouched - `stop`, not `down` - run.bat starts it again instantly,
# no re-pull, no setup.
$ErrorActionPreference = "Stop"
Set-Location "$PSScriptRoot\.."

Write-Host "==> Stopping..." -ForegroundColor Cyan
docker compose stop
Write-Host ""
Write-Host "Stopped. Run run.bat any time to start it again." -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to close"
