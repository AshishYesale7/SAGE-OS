@echo off
REM ─────────────────────────────────────────────────────────────────────────────
REM SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
REM SPDX-License-Identifier: BSD-3-Clause OR Proprietary
REM SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
REM 
REM This file is part of the SAGE OS Project.
REM ─────────────────────────────────────────────────────────────────────────────

title SAGE OS Console Mode Launcher

echo.
echo 🖥️  SAGE OS Console Mode Launcher
echo =================================
echo.

REM Check if QEMU is installed
where qemu-system-i386 >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ QEMU not found in PATH
    echo 💡 Please install QEMU or add it to your PATH
    echo 📦 Install via: choco install qemu
    pause
    exit /b 1
)

REM Set default values
set ARCH=i386
set MEMORY=128M
set KERNEL_PATH=build\%ARCH%\kernel.elf

REM Check for command line arguments
if "%1" neq "" set ARCH=%1
if "%2" neq "" set MEMORY=%2
if "%3" neq "" set KERNEL_PATH=%3

echo 🖥️  Architecture: %ARCH%
echo 💾 Memory: %MEMORY%
echo 📄 Kernel: %KERNEL_PATH%
echo.

REM Check if kernel exists
if not exist "%KERNEL_PATH%" (
    echo ❌ Kernel not found: %KERNEL_PATH%
    echo.
    echo 💡 Build SAGE OS first:
    echo   scripts\windows\build-sage-os.bat %ARCH%
    echo.
    pause
    exit /b 1
)

echo ✅ Kernel found: %KERNEL_PATH%
echo.

REM Launch QEMU in console mode
echo 🚀 Launching SAGE OS in console mode...
echo.
echo 📋 Instructions:
echo   • SAGE OS will run in this console window
echo   • Use keyboard to interact with the shell
echo   • Type 'help' to see available commands
echo   • Press Ctrl+C to exit QEMU
echo.

REM QEMU command for console mode
qemu-system-i386 ^
    -kernel "%KERNEL_PATH%" ^
    -m %MEMORY% ^
    -nographic ^
    -serial stdio ^
    -name "SAGE OS v1.0.1 Console" ^
    -no-reboot

echo.
echo 👋 SAGE OS session ended
pause