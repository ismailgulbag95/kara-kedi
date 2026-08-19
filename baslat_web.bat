@echo off
title Kara Kedi Web Versiyonu Baslatici
echo ===================================================
echo   KARA KEDI: FARE ISTILASI - WEB VERSIYONU BASLATILIYOR
echo ===================================================
echo.
echo Tarayicinizda aciliyor: http://localhost:8000
start "" "http://localhost:8000"
powershell -ExecutionPolicy Bypass -File "%~dp0web\server.ps1"
pause
