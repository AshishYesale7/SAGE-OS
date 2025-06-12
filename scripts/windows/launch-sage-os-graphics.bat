@echo off
REM ─────────────────────────────────────────────────────────────────────────────
REM SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
REM SPDX-License-Identifier: BSD-3-Clause OR Proprietary
REM SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
REM 
REM This file is part of the SAGE OS Project.
REM ─────────────────────────────────────────────────────────────────────────────

title SAGE OS Graphics Mode Launcher

echo.
echo 🚀 SAGE OS Graphics Mode Launcher
echo ==================================
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
    echo 💡 Available options:
    echo   1. Build SAGE OS first: make ARCH=%ARCH% TARGET=generic
    echo   2. Use WSL2: wsl make ARCH=%ARCH% TARGET=generic
    echo   3. Use build script: scripts\windows\build-sage-os.bat
    echo   4. Check if path is correct
    echo.
    pause
    exit /b 1
)

echo ✅ Kernel found: %KERNEL_PATH%
echo.

REM Launch QEMU with graphics mode
echo 🚀 Launching SAGE OS in graphics mode...
echo.
echo 📋 Instructions:
echo   • SAGE OS will boot in a graphics window
echo   • Use keyboard to interact with the shell
echo   • Type 'help' to see available commands
echo   • Press Ctrl+Alt+G to release mouse cursor
echo   • Close window to exit
echo.

REM QEMU command for graphics mode
qemu-system-i386 ^
    -kernel "%KERNEL_PATH%" ^
    -m %MEMORY% ^
    -vga std ^
    -display gtk ^
    -device usb-kbd ^
    -device usb-mouse ^
    -name "SAGE OS v1.0.1" ^
    -no-reboot

echo.
echo 👋 SAGE OS session ended
pause