@echo off
REM Starts ProctorEye and opens 3 separate log windows (api, worker,
REM dashboard). Run install\install.bat first if you haven't yet.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0run.ps1"
