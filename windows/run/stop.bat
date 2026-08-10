@echo off
REM Stops ProctorEye without deleting any data. run.bat starts it again.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0stop.ps1"
