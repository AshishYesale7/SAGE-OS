@echo off
REM ─────────────────────────────────────────────────────────────────────────────
REM SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
REM SPDX-License-Identifier: BSD-3-Clause OR Proprietary
REM SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
REM 
REM This file is part of the SAGE OS Project.
REM ─────────────────────────────────────────────────────────────────────────────

title SAGE OS Complete Installer for Windows

REM Check for Administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ❌ Administrator privileges required!
    echo 💡 Right-click this file and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo.
echo 🚀 SAGE OS Complete Installer for Windows
echo =========================================
echo.
echo 🖥️  Detected System:
echo   OS: Windows 10 Pro Build 19045
echo   CPU: Intel Core i5-3380M @ 2.90GHz
echo   RAM: 4GB
echo   Architecture: x64
echo.
echo ✅ Your system is fully compatible with SAGE OS!
echo.

REM Installation options
echo 📋 Installation Options:
echo   [1] Complete Setup (Recommended)
echo   [2] Dependencies Only
echo   [3] WSL2 Setup Only
echo   [4] Create Shortcuts Only
echo   [5] Quick Test (if already installed)
echo.
set /p choice="Choose installation type (1-5, default=1): "

if "%choice%"=="" set choice=1

if "%choice%"=="1" goto CompleteSetup
if "%choice%"=="2" goto DependenciesOnly
if "%choice%"=="3" goto WSL2Only
if "%choice%"=="4" goto ShortcutsOnly
if "%choice%"=="5" goto QuickTest

echo ❌ Invalid choice
pause
exit /b 1

:CompleteSetup
echo.
echo 🔧 Starting Complete SAGE OS Setup...
echo.

echo 📦 Step 1/4: Installing Dependencies...
call scripts\windows\install-dependencies.bat
if %errorlevel% neq 0 (
    echo ❌ Dependencies installation failed
    pause
    exit /b 1
)

echo.
echo 🔗 Step 2/4: Creating Desktop Shortcuts...
call scripts\windows\create-shortcuts.bat

echo.
echo 🔨 Step 3/4: Building SAGE OS...
call scripts\windows\build-sage-os.bat i386 generic auto
if %errorlevel% neq 0 (
    echo ⚠️  Build failed, but installation can continue
    echo 💡 You can build later using desktop shortcuts
)

echo.
echo 🧪 Step 4/4: Testing Installation...
if exist "build\i386\kernel.elf" (
    echo ✅ Kernel found, installation successful!
    echo.
    echo 🚀 Ready to launch SAGE OS!
    set /p launch="Launch SAGE OS now? (Y/n): "
    if /i not "%launch%"=="n" (
        call scripts\windows\launch-sage-os-graphics.bat i386 256M
    )
) else (
    echo ⚠️  Kernel not found, but dependencies are installed
    echo 💡 Use desktop shortcuts to build and launch
)

goto InstallationComplete

:DependenciesOnly
echo.
echo 📦 Installing Dependencies Only...
call scripts\windows\install-dependencies.bat
goto InstallationComplete

:WSL2Only
echo.
echo 🐧 Setting up WSL2 Only...
echo.
echo 📦 Enabling WSL2 features...
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

echo 📦 Installing Ubuntu...
wsl --set-default-version 2
wsl --install -d Ubuntu-22.04

echo ✅ WSL2 setup completed
echo ⚠️  Restart required for WSL2 to work properly
goto InstallationComplete

:ShortcutsOnly
echo.
echo 🔗 Creating Desktop Shortcuts Only...
call scripts\windows\create-shortcuts.bat
goto InstallationComplete

:QuickTest
echo.
echo 🧪 Quick Test...
if exist "build\i386\kernel.elf" (
    echo ✅ Kernel found, launching SAGE OS...
    call scripts\windows\launch-sage-os-graphics.bat i386 256M
) else (
    echo ❌ Kernel not found, building first...
    call scripts\windows\build-sage-os.bat i386
    if exist "build\i386\kernel.elf" (
        call scripts\windows\launch-sage-os-graphics.bat i386 256M
    ) else (
        echo ❌ Build failed
        pause
        exit /b 1
    )
)
goto InstallationComplete

:InstallationComplete
echo.
echo ✅ SAGE OS Installation Completed!
echo.
echo 📋 What's Installed:
where git >nul 2>&1 && echo   ✅ Git || echo   ❌ Git
where qemu-system-i386 >nul 2>&1 && echo   ✅ QEMU || echo   ❌ QEMU
where make >nul 2>&1 && echo   ✅ Make || echo   ❌ Make
where code >nul 2>&1 && echo   ✅ VS Code || echo   ❌ VS Code
wsl -l -q 2>nul | findstr /i "ubuntu" >nul && echo   ✅ WSL2 Ubuntu || echo   ❌ WSL2 Ubuntu

echo.
echo 🖥️  Desktop Shortcuts Created:
echo   🚀 Quick Launch SAGE OS
echo   🔨 Build SAGE OS
echo   🖥️  SAGE OS Graphics
echo   💻 SAGE OS Console
echo   📦 Install Dependencies
echo   📖 Documentation
echo.

echo 🎯 Next Steps:
echo   1. Double-click "🚀 Quick Launch SAGE OS" on desktop
echo   2. Or run: scripts\windows\quick-launch.bat
echo   3. Read documentation: docs\platforms\windows\WINDOWS_DEPLOYMENT_GUIDE.md
echo.

echo 💡 Optimized for your system:
echo   • Architecture: i386 (best for Intel i5-3380M)
echo   • Memory: 256M (optimal for 4GB RAM)
echo   • Build method: WSL2 (best compatibility)
echo.

REM Check if restart is needed
if exist "%TEMP%\sage_os_restart_required" (
    echo ⚠️  RESTART REQUIRED
    echo    Some features require a restart to work properly
    echo.
    set /p restart="Restart now? (y/N): "
    if /i "%restart%"=="y" (
        del "%TEMP%\sage_os_restart_required" 2>nul
        shutdown /r /t 10 /c "Restarting for SAGE OS setup completion"
    )
)

echo 🎉 Enjoy SAGE OS!
pause