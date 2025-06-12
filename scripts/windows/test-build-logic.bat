@echo off
REM Test script to validate build logic

echo Testing SAGE OS Build Script Logic
echo ===================================

REM Test parameter handling
set ARCH=i386
set TARGET=generic
if "%1" neq "" set ARCH=%1
if "%2" neq "" set TARGET=%2

echo Architecture: %ARCH%
echo Target: %TARGET%

REM Test build method detection
set BUILD_METHOD=auto
if "%3" neq "" set BUILD_METHOD=%3

echo Build Method: %BUILD_METHOD%

REM Test auto-detection logic
if "%BUILD_METHOD%"=="auto" (
    echo Testing auto-detection...
    
    REM Check for MSYS2
    if exist "C:\msys64\usr\bin\make.exe" (
        echo MSYS2 found
        set BUILD_METHOD=msys2
    ) else (
        echo MSYS2 not found
        
        REM Check for native make
        where make >nul 2>&1
        if %errorlevel% equ 0 (
            echo Native make found
            set BUILD_METHOD=native
        ) else (
            echo Native make not found
            
            REM Check for MinGW
            where mingw32-make >nul 2>&1
            if %errorlevel% equ 0 (
                echo MinGW make found
                set BUILD_METHOD=mingw
            ) else (
                echo No build tools found
                set BUILD_METHOD=none
            )
        )
    )
)

echo Final build method: %BUILD_METHOD%

REM Test conditional logic
if "%BUILD_METHOD%"=="msys2" (
    echo Would use MSYS2 build
) else if "%BUILD_METHOD%"=="native" (
    echo Would use native build
) else if "%BUILD_METHOD%"=="mingw" (
    echo Would use MinGW build
) else if "%BUILD_METHOD%"=="none" (
    echo No build method available
) else (
    echo Unknown build method: %BUILD_METHOD%
)

echo.
echo Test completed successfully!
pause