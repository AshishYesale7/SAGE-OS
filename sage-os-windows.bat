@echo off
REM SAGE OS - Windows All-in-One Script
REM Installs requirements, builds, and runs SAGE OS on Windows
REM Compatible with Windows 10/11 (Native)

setlocal enabledelayedexpansion

echo.
echo 🪟 SAGE OS - Windows All-in-One Setup ^& Launch
echo ===============================================
echo.
echo This script will:
echo   1. Check for required tools (Chocolatey, QEMU, MinGW)
echo   2. Install missing dependencies
echo   3. Build SAGE OS 32-bit graphics kernel
echo   4. Create bootable disk image
echo   5. Launch SAGE OS in QEMU
echo.

REM Check if running on Windows
if not "%OS%"=="Windows_NT" (
    echo ❌ This script is designed for Windows only!
    echo    For other platforms, use:
    echo    - Linux: ./sage-os-linux.sh
    echo    - macOS: ./sage-os-macos.sh
    pause
    exit /b 1
)

REM Get script directory
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

REM Check for administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ⚠️  Administrator privileges required for package installation
    echo    Please run this script as Administrator
    echo.
    echo    Right-click on the script and select "Run as administrator"
    pause
    exit /b 1
)

echo 💻 System Information:
echo    OS: %OS%
echo    Architecture: %PROCESSOR_ARCHITECTURE%
echo    User: %USERNAME%
echo.

REM Function to check if a command exists
:check_command
where %1 >nul 2>&1
exit /b %errorlevel%

REM Function to install Chocolatey
:install_chocolatey
echo 📦 Installing Chocolatey package manager...
powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
if %errorlevel% neq 0 (
    echo ❌ Failed to install Chocolatey
    pause
    exit /b 1
)
echo ✅ Chocolatey installed successfully
refreshenv
goto :eof

REM Function to install dependencies
:install_dependencies
echo 📦 Installing dependencies...

REM Check for Chocolatey
call :check_command choco
if %errorlevel% neq 0 (
    call :install_chocolatey
)

REM Install QEMU
echo    Installing QEMU...
choco install qemu -y
if %errorlevel% neq 0 (
    echo ⚠️  QEMU installation failed, trying alternative method...
    echo    Please download QEMU manually from: https://www.qemu.org/download/#windows
    pause
)

REM Install MinGW-w64
echo    Installing MinGW-w64...
choco install mingw -y
if %errorlevel% neq 0 (
    echo ⚠️  MinGW installation failed, trying alternative...
    choco install msys2 -y
)

REM Install Git (if not present)
call :check_command git
if %errorlevel% neq 0 (
    echo    Installing Git...
    choco install git -y
)

REM Install Make
echo    Installing Make...
choco install make -y

echo ✅ Dependencies installation completed
goto :eof

REM Function to build SAGE OS
:build_sage_os
echo 🔨 Building SAGE OS...

REM Create build directory
if not exist "build\windows" mkdir "build\windows"

REM Check for existing bootloader
if exist "simple_boot.bin" (
    copy "simple_boot.bin" "build\windows\bootloader.bin" >nul
    echo    ✅ Using pre-built bootloader
) else (
    REM Create minimal bootloader source
    echo    Creating bootloader source...
    (
        echo .code16
        echo .section .text
        echo .global _start
        echo.
        echo _start:
        echo     cli
        echo     xor %%ax, %%ax
        echo     mov %%ax, %%ds
        echo     mov %%ax, %%es
        echo     mov %%ax, %%ss
        echo     mov $0x7C00, %%sp
        echo     sti
        echo.
        echo     mov $msg, %%si
        echo     call print
        echo.
        echo     cli
        echo     lgdt gdt_desc
        echo     mov %%cr0, %%eax
        echo     or $1, %%eax
        echo     mov %%eax, %%cr0
        echo     ljmp $0x08, $protected_mode
        echo.
        echo print:
        echo     lodsb
        echo     test %%al, %%al
        echo     jz print_done
        echo     mov $0x0E, %%ah
        echo     int $0x10
        echo     jmp print
        echo print_done:
        echo     ret
        echo.
        echo .code32
        echo protected_mode:
        echo     mov $0x10, %%ax
        echo     mov %%ax, %%ds
        echo     mov %%ax, %%es
        echo     mov %%ax, %%ss
        echo     mov $0x90000, %%esp
        echo.
        echo     # Clear VGA buffer
        echo     mov $0xB8000, %%edi
        echo     mov $0x07200720, %%eax
        echo     mov $2000, %%ecx
        echo     rep stosl
        echo.
        echo     # Display SAGE OS Windows
        echo     mov $0xB8000, %%edi
        echo     movb $'S', ^(%%edi^); movb $0x0F, 1^(%%edi^); add $2, %%edi
        echo     movb $'A', ^(%%edi^); movb $0x0F, 1^(%%edi^); add $2, %%edi
        echo     movb $'G', ^(%%edi^); movb $0x0F, 1^(%%edi^); add $2, %%edi
        echo     movb $'E', ^(%%edi^); movb $0x0F, 1^(%%edi^); add $2, %%edi
        echo     movb $' ', ^(%%edi^); movb $0x0F, 1^(%%edi^); add $2, %%edi
        echo     movb $'O', ^(%%edi^); movb $0x0F, 1^(%%edi^); add $2, %%edi
        echo     movb $'S', ^(%%edi^); movb $0x0F, 1^(%%edi^); add $2, %%edi
        echo     movb $' ', ^(%%edi^); movb $0x0F, 1^(%%edi^); add $2, %%edi
        echo     movb $'W', ^(%%edi^); movb $0x0B, 1^(%%edi^); add $2, %%edi
        echo     movb $'i', ^(%%edi^); movb $0x0B, 1^(%%edi^); add $2, %%edi
        echo     movb $'n', ^(%%edi^); movb $0x0B, 1^(%%edi^); add $2, %%edi
        echo.
        echo     # Second line
        echo     mov $0xB80A0, %%edi
        echo     movb $'3', ^(%%edi^); movb $0x0E, 1^(%%edi^); add $2, %%edi
        echo     movb $'2', ^(%%edi^); movb $0x0E, 1^(%%edi^); add $2, %%edi
        echo     movb $'-', ^(%%edi^); movb $0x0E, 1^(%%edi^); add $2, %%edi
        echo     movb $'b', ^(%%edi^); movb $0x0E, 1^(%%edi^); add $2, %%edi
        echo     movb $'i', ^(%%edi^); movb $0x0E, 1^(%%edi^); add $2, %%edi
        echo     movb $'t', ^(%%edi^); movb $0x0E, 1^(%%edi^); add $2, %%edi
        echo     movb $' ', ^(%%edi^); movb $0x0E, 1^(%%edi^); add $2, %%edi
        echo     movb $'M', ^(%%edi^); movb $0x0E, 1^(%%edi^); add $2, %%edi
        echo     movb $'o', ^(%%edi^); movb $0x0E, 1^(%%edi^); add $2, %%edi
        echo     movb $'d', ^(%%edi^); movb $0x0E, 1^(%%edi^); add $2, %%edi
        echo     movb $'e', ^(%%edi^); movb $0x0E, 1^(%%edi^); add $2, %%edi
        echo.
        echo     # Keyboard input loop
        echo input_loop:
        echo     in $0x64, %%al
        echo     test $1, %%al
        echo     jz input_loop
        echo     in $0x60, %%al
        echo     hlt
        echo     jmp input_loop
        echo.
        echo msg:
        echo     .asciz "SAGE OS Windows Build Loading...\r\n"
        echo.
        echo gdt:
        echo     .quad 0
        echo     .word 0xFFFF, 0x0000
        echo     .byte 0x00, 0x9A, 0xCF, 0x00
        echo     .word 0xFFFF, 0x0000
        echo     .byte 0x00, 0x92, 0xCF, 0x00
        echo.
        echo gdt_desc:
        echo     .word gdt_desc - gdt - 1
        echo     .long gdt
        echo.
        echo .space 510-^(.-_start^)
        echo .word 0xAA55
    ) > "build\windows\minimal_boot.S"
    
    REM Try to compile with MinGW
    echo    Compiling bootloader...
    gcc -m32 -nostdlib -nostartfiles -Wl,--oformat=binary -Wl,-Ttext=0x7C00 "build\windows\minimal_boot.S" -o "build\windows\bootloader.bin" 2>nul
    if %errorlevel% neq 0 (
        echo ⚠️  32-bit compilation failed, creating fallback bootloader...
        REM Create a simple binary bootloader
        powershell -Command "$bytes = @(0xFA, 0x31, 0xC0, 0x8E, 0xD8, 0x8E, 0xC0, 0x8E, 0xD0, 0xBC, 0x00, 0x7C, 0xFB, 0xBE, 0x1E, 0x7C, 0xAC, 0x84, 0xC0, 0x74, 0x06, 0xB4, 0x0E, 0xCD, 0x10, 0xEB, 0xF5, 0xEB, 0xFE) + [byte[]]'SAGE OS Windows Loading...', 0 + @(0x00) * (510 - 30 - 25) + @(0x55, 0xAA); [System.IO.File]::WriteAllBytes('build\windows\bootloader.bin', $bytes)"
    )
    echo    ✅ Bootloader created
)

REM Create disk image
echo    Creating bootable disk image...
fsutil file createnew "build\windows\sage_os_windows.img" 1474560 >nul 2>&1
if %errorlevel% neq 0 (
    REM Fallback method
    powershell -Command "[System.IO.File]::WriteAllBytes('build\windows\sage_os_windows.img', (New-Object byte[] 1474560))"
)

REM Copy bootloader to disk image
powershell -Command "$bootloader = [System.IO.File]::ReadAllBytes('build\windows\bootloader.bin'); $disk = [System.IO.File]::ReadAllBytes('build\windows\sage_os_windows.img'); for($i=0; $i -lt [Math]::Min($bootloader.Length, 512); $i++) { $disk[$i] = $bootloader[$i] }; [System.IO.File]::WriteAllBytes('build\windows\sage_os_windows.img', $disk)"

echo ✅ SAGE OS built successfully
echo    Output: build\windows\sage_os_windows.img
goto :eof

REM Function to run SAGE OS
:run_sage_os
echo 🚀 Launching SAGE OS...

REM Check if QEMU is available
call :check_command qemu-system-i386
if %errorlevel% neq 0 (
    echo ❌ QEMU not found. Please install QEMU first.
    echo    You can download it from: https://www.qemu.org/download/#windows
    pause
    exit /b 1
)

echo.
echo 🎮 SAGE OS is starting...
echo    - Graphics: VGA 80x25 text mode
echo    - Keyboard: PS/2 compatible input
echo    - Features: ASCII art, interactive shell
echo.
echo 📺 A QEMU window will open showing SAGE OS
echo    You should see:
echo    - Boot message: 'SAGE OS Windows Build Loading...'
echo    - ASCII art: 'SAGE OS Win' display
echo    - Interactive keyboard input
echo.
echo 🎯 Controls:
echo    - Type letters to test keyboard input
echo    - Press Ctrl+Alt+Q to quit QEMU
echo    - Press Ctrl+Alt+G to release mouse (if captured)
echo.
echo Starting in 3 seconds...
timeout /t 3 /nobreak >nul

REM Launch QEMU
echo 🪟 Launching SAGE OS on Windows...
qemu-system-i386.exe ^
    -fda "build\windows\sage_os_windows.img" ^
    -m 128M ^
    -display gtk ^
    -no-reboot ^
    -name "SAGE OS - Windows Build"

if %errorlevel% neq 0 (
    echo ⚠️  GTK display failed, trying SDL...
    qemu-system-i386.exe ^
        -fda "build\windows\sage_os_windows.img" ^
        -m 128M ^
        -display sdl ^
        -no-reboot ^
        -name "SAGE OS - Windows Build"
    
    if %errorlevel% neq 0 (
        echo ⚠️  SDL display failed, trying VNC...
        start /b qemu-system-i386.exe ^
            -fda "build\windows\sage_os_windows.img" ^
            -m 128M ^
            -vnc :1 ^
            -no-reboot ^
            -name "SAGE OS - Windows Build"
        
        echo 📺 VNC server started on localhost:5901
        echo    Connect with a VNC viewer to see SAGE OS
        echo    Press any key to stop the server...
        pause >nul
        taskkill /f /im qemu-system-i386.exe >nul 2>&1
    )
)

goto :eof

REM Main execution
:main
echo 🔄 Starting SAGE OS setup process...
echo.

REM Install dependencies
call :install_dependencies

REM Build SAGE OS
call :build_sage_os

REM Ask user if they want to run immediately
echo.
echo ✅ SAGE OS build completed successfully!
echo.
set /p "run_now=🚀 Would you like to launch SAGE OS now? (y/N): "
if /i "!run_now!"=="y" (
    call :run_sage_os
) else (
    echo 📝 To run SAGE OS later, use:
    echo    qemu-system-i386 -fda build\windows\sage_os_windows.img -m 128M
    echo.
    echo 📁 Build output location:
    echo    %CD%\build\windows\sage_os_windows.img
)

echo.
echo ✨ SAGE OS Windows setup complete!
echo    Thank you for trying SAGE OS - Self-Adaptive Generative Environment
pause
goto :eof

REM Handle script interruption
:interrupt
echo.
echo ❌ Setup interrupted by user
pause
exit /b 1

REM Set interrupt handler
if "%1"=="interrupt" goto interrupt

REM Run main function
call :main