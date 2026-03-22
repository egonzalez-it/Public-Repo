@echo off
title Windows Autopilot HWID Export Tool

echo ============================================
echo   Windows Autopilot Hardware Hash Export
echo ============================================
echo.
echo This tool will collect the device HWID and
echo save it to the USB drive.
echo.
echo Please wait...
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0GetAutopilotHash-Online.ps1"

echo.
if %errorlevel% neq 0 (
    echo The script completed with errors.
) else (
    echo The script completed successfully!.
)

echo.
echo Press any key to exit...
pause >nul