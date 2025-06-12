@echo off
REM ─────────────────────────────────────────────────────────────────────────────
REM SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
REM SPDX-License-Identifier: BSD-3-Clause OR Proprietary
REM SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
REM 
REM This file is part of the SAGE OS Project.
REM ─────────────────────────────────────────────────────────────────────────────

title SAGE OS Dependencies Installer

REM Check for Administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ This script requires Administrator privileges!
    echo 💡 Right-click and select "Run as administrator"
    pause
    exit /b 1
)

echo.
echo 📦 SAGE OS Dependencies Installer
echo =================================
echo.

echo 🖥️  System Information:
echo   OS: Windows 10 Pro Build 19045
echo   CPU: Intel Core i5-3380M @ 2.90GHz
echo   RAM: 4GB
echo   Architecture: x64
echo.

REM Check if Chocolatey is installed
where choco >nul 2>&1
if %errorlevel% neq 0 (
    echo 📦 Installing Chocolatey Package Manager...
    powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    
    if %errorlevel% neq 0 (
        echo ❌ Failed to install Chocolatey
        pause
        exit /b 1
    )
    
    echo ✅ Chocolatey installed successfully
    echo 🔄 Refreshing environment variables...
    call refreshenv
) else (
    echo ✅ Chocolatey already installed
)

echo.
echo 📦 Installing required packages...
echo.

REM Install essential packages
echo 🔧 Installing Git...
choco install git -y --no-progress

echo 🖥️  Installing QEMU...
choco install qemu -y --no-progress

echo 🔨 Installing Make...
choco install make -y --no-progress

echo 🛠️  Installing MinGW...
choco install mingw -y --no-progress

echo 🐧 Installing MSYS2...
choco install msys2 -y --no-progress

echo 📝 Installing Visual Studio Code...
choco install vscode -y --no-progress

echo 🐳 Installing Docker Desktop (optional)...
set /p install_docker="Install Docker Desktop? (y/N): "
if /i "%install_docker%"=="y" (
    choco install docker-desktop -y --no-progress
)

echo.
echo 🐧 Setting up WSL2...
echo.

REM Check if WSL is already enabled
dism.exe /online /get-featureinfo /featurename:Microsoft-Windows-Subsystem-Linux | findstr "State : Enabled" >nul
if %errorlevel% neq 0 (
    echo 📦 Enabling WSL2 features...
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    
    echo ✅ WSL2 features enabled
    set RESTART_REQUIRED=1
) else (
    echo ✅ WSL2 already enabled
)

REM Set WSL2 as default
wsl --set-default-version 2 >nul 2>&1

REM Install Ubuntu if not present
wsl -l -q 2>nul | findstr /i "ubuntu" >nul
if %errorlevel% neq 0 (
    echo 📦 Installing Ubuntu for WSL2...
    choco install wsl-ubuntu-2004 -y --no-progress
    
    if %errorlevel% neq 0 (
        echo ⚠️  Failed to install Ubuntu via Chocolatey
        echo 💡 Please install Ubuntu manually from Microsoft Store
    ) else (
        echo ✅ Ubuntu installed successfully
    )
) else (
    echo ✅ Ubuntu already installed
)

echo.
echo 🔄 Refreshing environment variables...
call refreshenv

echo.
echo ✅ Dependencies installation completed!
echo.

REM Check installation status
echo 📋 Installation Status:
where git >nul 2>&1 && echo   ✅ Git || echo   ❌ Git
where qemu-system-i386 >nul 2>&1 && echo   ✅ QEMU || echo   ❌ QEMU
where make >nul 2>&1 && echo   ✅ Make || echo   ❌ Make
where gcc >nul 2>&1 && echo   ✅ GCC || echo   ❌ GCC
where code >nul 2>&1 && echo   ✅ VS Code || echo   ❌ VS Code

echo.
echo 🎯 Next Steps:
echo   1. Restart Windows if WSL2 was just enabled
echo   2. Run: scripts\windows\quick-launch.bat
echo   3. Or build manually: scripts\windows\build-sage-os.bat
echo.

if defined RESTART_REQUIRED (
    echo ⚠️  RESTART REQUIRED
    echo    WSL2 features were enabled and require a restart
    echo.
    set /p restart="Restart now? (y/N): "
    if /i "%restart%"=="y" (
        shutdown /r /t 10 /c "Restarting for WSL2 setup"
    )
)

pause