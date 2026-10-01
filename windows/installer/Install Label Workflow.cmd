@echo off
rem Double-click to install Label Workflow for this Windows user (no administrator rights needed).
title Label Workflow installer
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
if errorlevel 1 (
  echo.
  echo Installation did not finish. See the message above.
) else (
  echo.
  echo Installation finished.
)
pause
