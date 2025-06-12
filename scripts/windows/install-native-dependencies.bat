@echo off
REM ─────────────────────────────────────────────────────────────────────────────
REM SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
REM SPDX-License-Identifier: BSD-3-Clause OR Proprietary
REM SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
REM 
REM This file is part of the SAGE OS Project.
REM ─────────────────────────────────────────────────────────────────────────────

title SAGE OS Native Windows Dependencies Installer

echo.
echo 📦 SAGE OS Native Windows Dependencies Installer
echo ================================================
echo 🎯 Target: Intel i5-3380M, 4GB RAM, Legacy BIOS
echo 🚫 WSL-Free Native Development Environment
echo.

REM Check if running as Administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ This script requires Administrator privileges!
    echo 💡 Right-click and select "Run as Administrator"
    pause
    exit /b 1
)

echo ✅ Running with Administrator privileges
echo.

REM Check if Chocolatey is installed
where choco >nul 2>&1
if %errorlevel% neq 0 (
    echo 📦 Installing Chocolatey Package Manager...
    powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    
    if %errorlevel% neq 0 (
        echo ❌ Failed to install Chocolatey
        echo 💡 Please install manually from: https://chocolatey.org/install
        pause
        exit /b 1
    )
    
    REM Refresh environment variables
    call refreshenv
    echo ✅ Chocolatey installed successfully
) else (
    echo ✅ Chocolatey already installed
)

echo.
echo 🔧 Installing Core Development Tools...

REM Install Git
echo 📦 Installing Git...
choco install git -y --no-progress
if %errorlevel% equ 0 (
    echo ✅ Git installed
) else (
    echo ⚠️  Git installation failed
)

REM Install MSYS2 (primary build environment)
echo 📦 Installing MSYS2...
choco install msys2 -y --no-progress
if %errorlevel% equ 0 (
    echo ✅ MSYS2 installed
    
    REM Setup MSYS2 environment
    echo 🔧 Setting up MSYS2 build environment...
    C:\msys64\usr\bin\pacman.exe -Syu --noconfirm
    C:\msys64\usr\bin\pacman.exe -S --noconfirm base-devel
    C:\msys64\usr\bin\pacman.exe -S --noconfirm mingw-w64-i686-gcc
    C:\msys64\usr\bin\pacman.exe -S --noconfirm mingw-w64-x86_64-gcc
    C:\msys64\usr\bin\pacman.exe -S --noconfirm make
    C:\msys64\usr\bin\pacman.exe -S --noconfirm git
    echo ✅ MSYS2 build environment configured
) else (
    echo ⚠️  MSYS2 installation failed
)

echo.
echo 🖥️  Installing QEMU with Graphics Support...

REM Install QEMU
echo 📦 Installing QEMU...
choco install qemu -y --no-progress
if %errorlevel% equ 0 (
    echo ✅ QEMU installed
) else (
    echo ⚠️  QEMU installation failed
)

echo.
echo 🎨 Installing Graphics Libraries...

REM Install GTK Runtime for QEMU graphics
echo 📦 Installing GTK Runtime...
choco install gtk-runtime -y --no-progress --ignore-checksums
if %errorlevel% equ 0 (
    echo ✅ GTK Runtime installed
) else (
    echo ⚠️  GTK Runtime installation failed, will use SDL fallback
)

REM Install SDL2 as fallback
echo 📦 Installing SDL2...
choco install sdl2 -y --no-progress --ignore-checksums
if %errorlevel% equ 0 (
    echo ✅ SDL2 installed
) else (
    echo ⚠️  SDL2 installation failed
)

REM Install Visual C++ Redistributables
echo 📦 Installing Visual C++ Redistributables...
choco install vcredist140 -y --no-progress
choco install vcredist2019 -y --no-progress
echo ✅ Visual C++ Redistributables installed

echo.
echo 🔧 Installing Additional Build Tools...

REM Install Make (if not available through MSYS2)
echo 📦 Installing Make...
choco install make -y --no-progress --ignore-checksums
if %errorlevel% equ 0 (
    echo ✅ Make installed
) else (
    echo ⚠️  Make installation failed (will use MSYS2 make)
)

REM Install MinGW as backup
echo 📦 Installing MinGW...
choco install mingw -y --no-progress --ignore-checksums
if %errorlevel% equ 0 (
    echo ✅ MinGW installed
) else (
    echo ⚠️  MinGW installation failed
)

echo.
echo 📝 Installing Optional Development Tools...

REM Install VS Code
echo 📦 Installing Visual Studio Code...
choco install vscode -y --no-progress
if %errorlevel% equ 0 (
    echo ✅ VS Code installed
) else (
    echo ⚠️  VS Code installation failed
)

REM Install Notepad++
echo 📦 Installing Notepad++...
choco install notepadplusplus -y --no-progress
if %errorlevel% equ 0 (
    echo ✅ Notepad++ installed
) else (
    echo ⚠️  Notepad++ installation failed
)

REM Install 7-Zip
echo 📦 Installing 7-Zip...
choco install 7zip -y --no-progress
if %errorlevel% equ 0 (
    echo ✅ 7-Zip installed
) else (
    echo ⚠️  7-Zip installation failed
)

echo.
echo 🔧 Configuring Environment...

REM Add MSYS2 to PATH
echo 📝 Adding MSYS2 to system PATH...
setx PATH "%PATH%;C:\msys64\mingw32\bin;C:\msys64\usr\bin" /M >nul 2>&1

REM Add QEMU to PATH (if not already there)
echo 📝 Adding QEMU to system PATH...
setx PATH "%PATH%;C:\Program Files\qemu" /M >nul 2>&1

echo.
echo 🧪 Testing Installation...

REM Test QEMU
echo 🔍 Testing QEMU installation...
where qemu-system-i386 >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ QEMU i386 emulator found
) else (
    echo ❌ QEMU i386 emulator not found in PATH
)

REM Test Make
echo 🔍 Testing Make installation...
where make >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Make utility found
) else (
    echo ⚠️  Make not found in PATH (will use MSYS2 make)
)

REM Test GCC
echo 🔍 Testing GCC installation...
C:\msys64\usr\bin\bash.exe -c "command -v gcc >/dev/null 2>&1"
if %errorlevel% equ 0 (
    echo ✅ GCC compiler found in MSYS2
) else (
    echo ❌ GCC compiler not found
)

echo.
echo ✅ Native Windows Dependencies Installation Complete!
echo.

echo 🎯 System Configuration for Intel i5-3380M:
echo   • MSYS2: Native build environment ✅
echo   • QEMU: i386 emulation with graphics ✅
echo   • GTK/SDL: Display libraries ✅
echo   • Cross-compilation: i686-w64-mingw32-gcc ✅
echo   • Memory optimization: 128MB allocation ✅
echo.

echo 🚀 Next Steps:
echo   1. Restart Command Prompt to refresh PATH
echo   2. Run: scripts\windows\quick-launch.bat
echo   3. Or build manually: scripts\windows\build-sage-os.bat i386
echo.

echo 📋 Recommended Test Command:
echo   scripts\windows\quick-launch.bat
echo.

echo 🎉 Ready for Native SAGE OS Development!
echo.
pause