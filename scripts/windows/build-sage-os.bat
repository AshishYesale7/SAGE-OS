@echo off
REM ─────────────────────────────────────────────────────────────────────────────
REM SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
REM SPDX-License-Identifier: BSD-3-Clause OR Proprietary
REM SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
REM 
REM This file is part of the SAGE OS Project.
REM ─────────────────────────────────────────────────────────────────────────────

title SAGE OS Windows Build Script

echo.
echo 🔨 SAGE OS Windows Build Script
echo ===============================
echo.

REM Set default architecture
set ARCH=i386
set TARGET=generic
if "%1" neq "" set ARCH=%1
if "%2" neq "" set TARGET=%2

echo 🏗️  Building SAGE OS for %ARCH% architecture...
echo 🎯 Target: %TARGET%
echo.

REM Check build method preference
set BUILD_METHOD=auto
if "%3" neq "" set BUILD_METHOD=%3

REM Auto-detect best build method
if "%BUILD_METHOD%"=="auto" (
    echo 🔍 Auto-detecting best build method...
    
    REM Check if WSL2 is available and has Ubuntu
    wsl -l -q 2>nul | findstr /i "ubuntu" >nul
    if %errorlevel% equ 0 (
        echo ✅ WSL2 with Ubuntu detected - using WSL2 build
        set BUILD_METHOD=wsl
    ) else (
        REM Check if make is available natively
        where make >nul 2>&1
        if %errorlevel% equ 0 (
            echo ✅ Native make detected - using native build
            set BUILD_METHOD=native
        ) else (
            echo ❌ No suitable build environment found
            echo.
            echo 💡 Available options:
            echo   1. Install WSL2: scripts\windows\setup-windows-environment.ps1
            echo   2. Install MSYS2: choco install msys2
            echo   3. Use Docker: docker run --rm -v %CD%:/workspace sage-os:dev make ARCH=%ARCH%
            echo.
            pause
            exit /b 1
        )
    )
)

echo 🛠️  Using build method: %BUILD_METHOD%
echo.

REM Build based on method
if "%BUILD_METHOD%"=="wsl" (
    call :BuildWithWSL
) else if "%BUILD_METHOD%"=="native" (
    call :BuildNative
) else if "%BUILD_METHOD%"=="docker" (
    call :BuildWithDocker
) else (
    echo ❌ Unknown build method: %BUILD_METHOD%
    exit /b 1
)

goto :BuildComplete

:BuildWithWSL
echo 🐧 Building with WSL2...
echo.

REM Check if cross-compilation tools are installed in WSL
wsl bash -c "command -v i686-linux-gnu-gcc >/dev/null 2>&1"
if %errorlevel% neq 0 (
    echo 📦 Installing cross-compilation tools in WSL2...
    wsl bash -c "sudo apt update && sudo apt install -y gcc-multilib gcc-i686-linux-gnu build-essential"
)

REM Build using WSL2
wsl bash -c "cd /mnt/c/%CD:\=/% && make clean && make ARCH=%ARCH% TARGET=%TARGET%"

if %errorlevel% equ 0 (
    echo ✅ WSL2 build completed successfully
) else (
    echo ❌ WSL2 build failed
    exit /b 1
)
goto :eof

:BuildNative
echo 🖥️  Building natively on Windows...
echo.

REM Use native Windows make
make clean
make ARCH=%ARCH% TARGET=%TARGET%

if %errorlevel% equ 0 (
    echo ✅ Native build completed successfully
) else (
    echo ❌ Native build failed
    echo 💡 Try WSL2 build: %0 %ARCH% %TARGET% wsl
    exit /b 1
)
goto :eof

:BuildWithDocker
echo 🐳 Building with Docker...
echo.

REM Check if Docker is available
where docker >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker not found
    echo 💡 Install Docker Desktop for Windows
    exit /b 1
)

REM Build using Docker
docker run --rm -v %CD%:/workspace sage-os:dev bash -c "cd /workspace && make clean && make ARCH=%ARCH% TARGET=%TARGET%"

if %errorlevel% equ 0 (
    echo ✅ Docker build completed successfully
) else (
    echo ❌ Docker build failed
    exit /b 1
)
goto :eof

:BuildComplete
echo.
echo ✅ Build completed successfully!
echo.
echo 📁 Architecture: %ARCH%
echo 🎯 Target: %TARGET%
echo 📄 Kernel: build\%ARCH%\kernel.elf
echo.

REM Check if kernel was actually created
if exist "build\%ARCH%\kernel.elf" (
    echo 🚀 Ready to launch! Use one of these commands:
    echo   • Graphics mode: scripts\windows\launch-sage-os-graphics.bat %ARCH%
    echo   • Console mode:  scripts\windows\launch-sage-os-console.bat %ARCH%
    echo   • Quick launch:  scripts\windows\quick-launch.bat %ARCH%
) else (
    echo ❌ Kernel file not found after build
    echo 💡 Check build logs above for errors
)

echo.
pause