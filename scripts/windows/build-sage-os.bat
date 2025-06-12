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

REM Auto-detect best build method (prioritize native over WSL)
if "%BUILD_METHOD%"=="auto" (
    echo 🔍 Auto-detecting best build method for native Windows...
    
    REM First check for MSYS2 (preferred native method)
    if exist "C:\msys64\usr\bin\make.exe" (
        echo ✅ MSYS2 detected - using native MSYS2 build
        set BUILD_METHOD=msys2
    ) else (
        REM Check if native make is available
        where make >nul 2>&1
        if %errorlevel% equ 0 (
            echo ✅ Native make detected - using native build
            set BUILD_METHOD=native
        ) else (
            REM Check for MinGW
            where mingw32-make >nul 2>&1
            if %errorlevel% equ 0 (
                echo ✅ MinGW make detected - using MinGW build
                set BUILD_METHOD=mingw
            ) else (
                echo ❌ No native build environment found
                echo.
                echo 💡 Setting up native build environment...
                echo   Installing MSYS2 for native compilation...
                
                REM Try to install MSYS2 automatically
                where choco >nul 2>&1
                if %errorlevel% equ 0 (
                    echo 📦 Installing MSYS2 via Chocolatey...
                    choco install msys2 -y
                    if %errorlevel% equ 0 (
                        echo ✅ MSYS2 installed, setting up build environment...
                        C:\msys64\usr\bin\pacman.exe -S --noconfirm base-devel mingw-w64-i686-gcc
                        set BUILD_METHOD=msys2
                    ) else (
                        echo ❌ Failed to install MSYS2
                        goto :BuildError
                    )
                ) else (
                    echo ❌ Chocolatey not found
                    goto :BuildError
                )
            )
        )
    )
)

goto :ContinueBuild

:BuildError
echo.
echo ❌ Build Environment Setup Failed
echo.
echo 💡 Manual Setup Options:
echo   1. Install Chocolatey: https://chocolatey.org/install
echo   2. Install MSYS2: https://www.msys2.org/
echo   3. Run setup script: scripts\windows\setup-windows-environment.ps1
echo.
pause
exit /b 1

:ContinueBuild

echo 🛠️  Using build method: %BUILD_METHOD%
echo.

REM Build based on method
if "%BUILD_METHOD%"=="msys2" (
    call :BuildWithMSYS2
) else if "%BUILD_METHOD%"=="native" (
    call :BuildNative
) else if "%BUILD_METHOD%"=="mingw" (
    call :BuildWithMinGW
) else if "%BUILD_METHOD%"=="docker" (
    call :BuildWithDocker
) else if "%BUILD_METHOD%"=="wsl" (
    call :BuildWithWSL
) else (
    echo ❌ Unknown build method: %BUILD_METHOD%
    exit /b 1
)

goto :BuildComplete

:BuildWithMSYS2
echo 🔧 Building with MSYS2 (Native Windows)...
echo 🎯 Optimized for Intel i5-3380M, 4GB RAM, Legacy BIOS
echo.

REM Set MSYS2 environment
set MSYS2_PATH=C:\msys64
set PATH=%MSYS2_PATH%\mingw32\bin;%MSYS2_PATH%\usr\bin;%PATH%

REM Check if cross-compilation tools are available
%MSYS2_PATH%\usr\bin\bash.exe -c "command -v i686-w64-mingw32-gcc >/dev/null 2>&1"
if %errorlevel% neq 0 (
    echo 📦 Installing i386 cross-compilation tools...
    %MSYS2_PATH%\usr\bin\pacman.exe -S --noconfirm mingw-w64-i686-gcc mingw-w64-i686-binutils
)

REM Build using MSYS2
echo 🔨 Building SAGE OS for %ARCH%...
%MSYS2_PATH%\usr\bin\bash.exe -c "cd '%CD%' && make clean && make ARCH=%ARCH% TARGET=%TARGET%"

if %errorlevel% equ 0 (
    echo ✅ MSYS2 build completed successfully
) else (
    echo ❌ MSYS2 build failed
    exit /b 1
)
goto :eof

:BuildWithMinGW
echo 🔧 Building with MinGW (Native Windows)...
echo.

REM Use MinGW make
mingw32-make clean
mingw32-make ARCH=%ARCH% TARGET=%TARGET%

if %errorlevel% equ 0 (
    echo ✅ MinGW build completed successfully
) else (
    echo ❌ MinGW build failed
    echo 💡 Try MSYS2 build: %0 %ARCH% %TARGET% msys2
    exit /b 1
)
goto :eof

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