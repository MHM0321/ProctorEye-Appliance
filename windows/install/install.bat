@echo off
REM First-time setup only (Docker check, .env, secrets, image pull). Does
REM NOT start the app — after this finishes, go to ..\run and run run.bat.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
