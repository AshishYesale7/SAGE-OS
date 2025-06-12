@echo off
REM ─────────────────────────────────────────────────────────────────────────────
REM SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
REM SPDX-License-Identifier: BSD-3-Clause OR Proprietary
REM SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
REM 
REM This file is part of the SAGE OS Project.
REM ─────────────────────────────────────────────────────────────────────────────

title SAGE OS Desktop Shortcuts Creator

echo.
echo 🖥️  SAGE OS Desktop Shortcuts Creator
echo ====================================
echo.

REM Get current directory
set CURRENT_DIR=%CD%

REM Get desktop path
for /f "tokens=3*" %%i in ('reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v Desktop 2^>nul') do set DESKTOP_DIR=%%i %%j

if "%DESKTOP_DIR%"=="" (
    set DESKTOP_DIR=%USERPROFILE%\Desktop
)

echo 📁 Desktop directory: %DESKTOP_DIR%
echo 📁 SAGE OS directory: %CURRENT_DIR%
echo.

REM Create VBS script for shortcut creation
echo Creating shortcut helper...
echo Set WshShell = WScript.CreateObject("WScript.Shell") > create_shortcut.vbs
echo Set oShellLink = WshShell.CreateShortcut(WScript.Arguments(0)) >> create_shortcut.vbs
echo oShellLink.TargetPath = WScript.Arguments(1) >> create_shortcut.vbs
echo oShellLink.WorkingDirectory = WScript.Arguments(2) >> create_shortcut.vbs
echo oShellLink.Description = WScript.Arguments(3) >> create_shortcut.vbs
echo oShellLink.IconLocation = WScript.Arguments(4) >> create_shortcut.vbs
echo oShellLink.Save >> create_shortcut.vbs

REM Create shortcuts
echo 🔗 Creating desktop shortcuts...

REM Quick Launch shortcut
echo   📱 Quick Launch SAGE OS...
cscript //nologo create_shortcut.vbs "%DESKTOP_DIR%\🚀 Quick Launch SAGE OS.lnk" "%CURRENT_DIR%\scripts\windows\quick-launch.bat" "%CURRENT_DIR%" "Quick build and launch SAGE OS" "%SystemRoot%\System32\shell32.dll,137"

REM Build shortcut
echo   🔨 Build SAGE OS...
cscript //nologo create_shortcut.vbs "%DESKTOP_DIR%\🔨 Build SAGE OS.lnk" "%CURRENT_DIR%\scripts\windows\build-sage-os.bat" "%CURRENT_DIR%" "Build SAGE OS for Windows" "%SystemRoot%\System32\shell32.dll,21"

REM Graphics Mode shortcut
echo   🖥️  SAGE OS Graphics...
cscript //nologo create_shortcut.vbs "%DESKTOP_DIR%\🖥️ SAGE OS Graphics.lnk" "%CURRENT_DIR%\scripts\windows\launch-sage-os-graphics.bat" "%CURRENT_DIR%" "Launch SAGE OS in Graphics Mode" "%SystemRoot%\System32\shell32.dll,15"

REM Console Mode shortcut
echo   💻 SAGE OS Console...
cscript //nologo create_shortcut.vbs "%DESKTOP_DIR%\💻 SAGE OS Console.lnk" "%CURRENT_DIR%\scripts\windows\launch-sage-os-console.bat" "%CURRENT_DIR%" "Launch SAGE OS in Console Mode" "%SystemRoot%\System32\shell32.dll,3"

REM Install Dependencies shortcut
echo   📦 Install Dependencies...
cscript //nologo create_shortcut.vbs "%DESKTOP_DIR%\📦 Install SAGE OS Dependencies.lnk" "%CURRENT_DIR%\scripts\windows\install-dependencies.bat" "%CURRENT_DIR%" "Install SAGE OS Dependencies" "%SystemRoot%\System32\shell32.dll,13"

REM Documentation shortcut
echo   📖 SAGE OS Documentation...
cscript //nologo create_shortcut.vbs "%DESKTOP_DIR%\📖 SAGE OS Documentation.lnk" "%CURRENT_DIR%\docs\platforms\windows\WINDOWS_DEPLOYMENT_GUIDE.md" "%CURRENT_DIR%" "SAGE OS Windows Documentation" "%SystemRoot%\System32\shell32.dll,23"

REM Clean up
del create_shortcut.vbs

echo.
echo ✅ Desktop shortcuts created successfully!
echo.
echo 📋 Available shortcuts:
echo   🚀 Quick Launch SAGE OS      - One-click build and launch
echo   🔨 Build SAGE OS            - Build kernel only
echo   🖥️  SAGE OS Graphics         - Launch in graphics mode
echo   💻 SAGE OS Console          - Launch in console mode
echo   📦 Install Dependencies     - Setup development environment
echo   📖 SAGE OS Documentation    - Windows deployment guide
echo.
echo 💡 Double-click any shortcut to get started!
echo.
pause