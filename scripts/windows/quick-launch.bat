@echo off
REM ─────────────────────────────────────────────────────────────────────────────
REM SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
REM SPDX-License-Identifier: BSD-3-Clause OR Proprietary
REM SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
REM 
REM This file is part of the SAGE OS Project.
REM ─────────────────────────────────────────────────────────────────────────────

title SAGE OS Quick Launch

echo.
echo ⚡ SAGE OS Quick Launch
echo ======================
echo.

REM Set default architecture optimized for your system
REM Intel i5-3380M with 4GB RAM - i386 works best
set ARCH=i386
set MEMORY=256M

REM Override with command line argument if provided
if "%1" neq "" set ARCH=%1
if "%2" neq "" set MEMORY=%2

echo 🖥️  System: Intel i5-3380M @ 2.90GHz, 4GB RAM
echo 🏗️  Architecture: %ARCH% (optimized for your system)
echo 💾 Memory: %MEMORY%
echo.

REM Check if kernel exists, build if not
set KERNEL_PATH=build\%ARCH%\kernel.elf
if not exist "%KERNEL_PATH%" (
    echo 📦 Kernel not found, building automatically...
    echo.
    call scripts\windows\build-sage-os.bat %ARCH%
    
    if %errorlevel% neq 0 (
        echo ❌ Build failed
        pause
        exit /b 1
    )
)

REM Check if QEMU is installed
where qemu-system-i386 >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ QEMU not found in PATH
    echo.
    echo 💡 Installing QEMU via Chocolatey...
    where choco >nul 2>&1
    if %errorlevel% equ 0 (
        choco install qemu -y
    ) else (
        echo ❌ Chocolatey not found
        echo 📦 Please install QEMU manually or run setup script:
        echo   scripts\windows\setup-windows-environment.ps1
        pause
        exit /b 1
    )
)

echo ✅ All prerequisites ready
echo.

REM Ask user for launch mode
echo 🚀 Choose launch mode:
echo   [1] Graphics Mode (Recommended)
echo   [2] Console Mode
echo   [3] Auto-detect best mode
echo.
set /p choice="Enter choice (1-3, default=1): "

if "%choice%"=="" set choice=1
if "%choice%"=="3" (
    REM Auto-detect: prefer graphics if display is available
    set choice=1
)

if "%choice%"=="1" (
    echo 🖥️  Launching in Graphics Mode...
    call scripts\windows\launch-sage-os-graphics.bat %ARCH% %MEMORY%
) else if "%choice%"=="2" (
    echo 💻 Launching in Console Mode...
    call scripts\windows\launch-sage-os-console.bat %ARCH% %MEMORY%
) else (
    echo ❌ Invalid choice
    pause
    exit /b 1
)