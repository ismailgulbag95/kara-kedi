@echo off
title Kara Kedi Web Versiyonu Baslatici
echo ===================================================
echo   KARA KEDI: FARE ISTILASI - WEB VERSIYONU
echo ===================================================
echo.
echo Tarayicinizda aciliyor...
powershell -ExecutionPolicy Bypass -File "%~dp0web\server.ps1"
pause
