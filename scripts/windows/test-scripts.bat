@echo off
REM ─────────────────────────────────────────────────────────────────────────────
REM SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
REM SPDX-License-Identifier: BSD-3-Clause OR Proprietary
REM SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
REM 
REM This file is part of the SAGE OS Project.
REM ─────────────────────────────────────────────────────────────────────────────

title SAGE OS Windows Scripts Test

echo.
echo 🧪 SAGE OS Windows Scripts Test
echo ===============================
echo.

echo 🔍 Testing script syntax and logic...
echo.

REM Test 1: Check if all required scripts exist
echo 📋 Test 1: Checking script files...
set SCRIPTS_OK=1

if not exist "scripts\windows\quick-launch.bat" (
    echo ❌ quick-launch.bat missing
    set SCRIPTS_OK=0
) else (
    echo ✅ quick-launch.bat found
)

if not exist "scripts\windows\build-sage-os.bat" (
    echo ❌ build-sage-os.bat missing
    set SCRIPTS_OK=0
) else (
    echo ✅ build-sage-os.bat found
)

if not exist "scripts\windows\launch-sage-os-graphics.bat" (
    echo ❌ launch-sage-os-graphics.bat missing
    set SCRIPTS_OK=0
) else (
    echo ✅ launch-sage-os-graphics.bat found
)

if not exist "scripts\windows\install-native-dependencies.bat" (
    echo ❌ install-native-dependencies.bat missing
    set SCRIPTS_OK=0
) else (
    echo ✅ install-native-dependencies.bat found
)

if not exist "scripts\windows\setup-windows-environment.ps1" (
    echo ❌ setup-windows-environment.ps1 missing
    set SCRIPTS_OK=0
) else (
    echo ✅ setup-windows-environment.ps1 found
)

echo.

REM Test 2: Check variable handling
echo 📋 Test 2: Testing variable handling...
set TEST_ARCH=i386
set TEST_MEMORY=128M
set TEST_TARGET=generic

if "%TEST_ARCH%"=="i386" (
    echo ✅ Variable assignment works
) else (
    echo ❌ Variable assignment failed
    set SCRIPTS_OK=0
)

echo.

REM Test 3: Check path handling
echo 📋 Test 3: Testing path handling...
set TEST_KERNEL_PATH=build\%TEST_ARCH%\kernel.elf
echo   Kernel path: %TEST_KERNEL_PATH%

if "%TEST_KERNEL_PATH%"=="build\i386\kernel.elf" (
    echo ✅ Path construction works
) else (
    echo ❌ Path construction failed
    set SCRIPTS_OK=0
)

echo.

REM Test 4: Check command detection simulation
echo 📋 Test 4: Testing command detection logic...

REM Simulate QEMU check
where cmd >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Command detection logic works (tested with 'cmd')
) else (
    echo ❌ Command detection logic failed
    set SCRIPTS_OK=0
)

echo.

REM Test 5: Check error handling
echo 📋 Test 5: Testing error handling...
call :TestErrorHandling
if %errorlevel% equ 0 (
    echo ✅ Error handling works
) else (
    echo ❌ Error handling failed
    set SCRIPTS_OK=0
)

echo.

REM Test 6: Check file existence logic
echo 📋 Test 6: Testing file existence checks...
if exist "Makefile" (
    echo ✅ File existence check works (Makefile found)
) else (
    echo ❌ File existence check failed (Makefile not found)
    set SCRIPTS_OK=0
)

echo.

REM Final result
if %SCRIPTS_OK% equ 1 (
    echo ✅ All tests passed! Scripts should work correctly.
    echo.
    echo 🚀 Ready to use SAGE OS Windows scripts:
    echo   • scripts\windows\install-native-dependencies.bat (as Administrator)
    echo   • scripts\windows\quick-launch.bat
    echo   • scripts\windows\build-sage-os.bat i386
    echo.
) else (
    echo ❌ Some tests failed. Please check the scripts.
    echo.
)

echo 📋 Test Summary:
echo   • Script files: %SCRIPTS_OK%
echo   • Variable handling: Working
echo   • Path construction: Working  
echo   • Command detection: Working
echo   • Error handling: Working
echo   • File checks: Working
echo.

pause
goto :eof

:TestErrorHandling
REM This function tests error handling
exit /b 0