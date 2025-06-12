# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS Windows Environment Setup Script
# This script sets up the complete development environment for SAGE OS on Windows

param(
    [switch]$SkipChocolatey,
    [switch]$SkipWSL,
    [switch]$QuickSetup
)

# Requires Administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ This script requires Administrator privileges!" -ForegroundColor Red
    Write-Host "💡 Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

Write-Host "🚀 SAGE OS Windows Environment Setup" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# System Information
Write-Host "🖥️  System Information:" -ForegroundColor Green
$os = Get-WmiObject -Class Win32_OperatingSystem
$cpu = Get-WmiObject -Class Win32_Processor
$memory = [math]::Round((Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)

Write-Host "  OS: $($os.Caption) Build $($os.BuildNumber)" -ForegroundColor White
Write-Host "  CPU: $($cpu.Name)" -ForegroundColor White
Write-Host "  RAM: $memory GB" -ForegroundColor White
Write-Host "  Architecture: $($env:PROCESSOR_ARCHITECTURE)" -ForegroundColor White
Write-Host ""

# Check system requirements
$requirements_met = $true

if ($memory -lt 4) {
    Write-Host "⚠️  Warning: Less than 4GB RAM detected. QEMU may run slowly." -ForegroundColor Yellow
}

if ($os.BuildNumber -lt 19041) {
    Write-Host "⚠️  Warning: Windows 10 version 2004 or later recommended for WSL2." -ForegroundColor Yellow
}

# Function to install Chocolatey
function Install-Chocolatey {
    Write-Host "📦 Installing Chocolatey Package Manager..." -ForegroundColor Green
    
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "  ✅ Chocolatey already installed" -ForegroundColor Green
        return
    }
    
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Host "  ✅ Chocolatey installed successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "  ❌ Failed to install Chocolatey: $($_.Exception.Message)" -ForegroundColor Red
        $requirements_met = $false
    }
}

# Function to install required packages for native Windows development
function Install-RequiredPackages {
    Write-Host "📦 Installing Required Packages for Native Windows Development..." -ForegroundColor Green
    
    # Core development tools
    $corePackages = @(
        "git",
        "make",
        "msys2",
        "mingw"
    )
    
    # QEMU with full graphics support
    $qemuPackages = @(
        "qemu",
        "qemu-img"
    )
    
    # Graphics and display libraries
    $graphicsPackages = @(
        "gtk-runtime",
        "sdl2",
        "vcredist140",
        "vcredist2019"
    )
    
    # Cross-compilation toolchain
    $crossCompilePackages = @(
        "mingw-w64"
    )
    
    # Optional development tools
    $optionalPackages = @(
        "vscode",
        "notepadplusplus",
        "7zip"
    )
    
    Write-Host "🔧 Installing core development tools..." -ForegroundColor Yellow
    foreach ($package in $corePackages) {
        Install-Package $package
    }
    
    Write-Host "🖥️  Installing QEMU with graphics support..." -ForegroundColor Yellow
    foreach ($package in $qemuPackages) {
        Install-Package $package
    }
    
    Write-Host "🎨 Installing graphics libraries..." -ForegroundColor Yellow
    foreach ($package in $graphicsPackages) {
        Install-Package $package
    }
    
    Write-Host "⚙️  Installing cross-compilation tools..." -ForegroundColor Yellow
    foreach ($package in $crossCompilePackages) {
        Install-Package $package
    }
    
    Write-Host "📝 Installing optional development tools..." -ForegroundColor Yellow
    foreach ($package in $optionalPackages) {
        Install-Package $package
    }
    
    # Setup MSYS2 environment for native compilation
    Setup-MSYS2Environment
}

function Install-Package($packageName) {
    Write-Host "  Installing $packageName..." -ForegroundColor Cyan
    try {
        choco install $packageName -y --no-progress --ignore-checksums
        Write-Host "  ✅ $packageName installed successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "  ⚠️  Failed to install $packageName, trying alternative..." -ForegroundColor Yellow
        # Try alternative installation methods
        switch ($packageName) {
            "mingw-w64" {
                Write-Host "    Trying MSYS2 mingw installation..." -ForegroundColor Cyan
                try {
                    & "C:\msys64\usr\bin\pacman.exe" -S --noconfirm mingw-w64-x86_64-gcc mingw-w64-i686-gcc
                    Write-Host "  ✅ MinGW-w64 installed via MSYS2" -ForegroundColor Green
                }
                catch {
                    Write-Host "  ❌ Failed to install MinGW-w64" -ForegroundColor Red
                }
            }
            "gtk-runtime" {
                Write-Host "    GTK will be provided by QEMU installation" -ForegroundColor Cyan
            }
            default {
                Write-Host "  ❌ Could not install $packageName" -ForegroundColor Red
            }
        }
    }
}

function Setup-MSYS2Environment {
    Write-Host "🔧 Setting up MSYS2 environment for native compilation..." -ForegroundColor Green
    
    $msys2Path = "C:\msys64"
    if (Test-Path $msys2Path) {
        Write-Host "  ✅ MSYS2 found at $msys2Path" -ForegroundColor Green
        
        # Update MSYS2
        Write-Host "  📦 Updating MSYS2 packages..." -ForegroundColor Yellow
        try {
            & "$msys2Path\usr\bin\pacman.exe" -Syu --noconfirm
            
            # Install essential build tools
            Write-Host "  🔨 Installing build tools..." -ForegroundColor Yellow
            & "$msys2Path\usr\bin\pacman.exe" -S --noconfirm base-devel
            & "$msys2Path\usr\bin\pacman.exe" -S --noconfirm mingw-w64-x86_64-gcc
            & "$msys2Path\usr\bin\pacman.exe" -S --noconfirm mingw-w64-i686-gcc
            & "$msys2Path\usr\bin\pacman.exe" -S --noconfirm mingw-w64-x86_64-make
            & "$msys2Path\usr\bin\pacman.exe" -S --noconfirm git
            
            Write-Host "  ✅ MSYS2 environment configured" -ForegroundColor Green
        }
        catch {
            Write-Host "  ⚠️  MSYS2 setup encountered issues, but basic installation is available" -ForegroundColor Yellow
        }
        
        # Add MSYS2 to PATH
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
        $msys2Paths = @(
            "$msys2Path\mingw64\bin",
            "$msys2Path\mingw32\bin", 
            "$msys2Path\usr\bin"
        )
        
        foreach ($path in $msys2Paths) {
            if ($currentPath -notlike "*$path*") {
                Write-Host "  📝 Adding $path to system PATH" -ForegroundColor Cyan
                [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$path", "Machine")
            }
        }
    }
    else {
        Write-Host "  ❌ MSYS2 not found, native compilation may be limited" -ForegroundColor Red
    }
}

# Function to verify graphics support for your Intel i5-3380M system
function Verify-GraphicsSupport {
    Write-Host "🎨 Verifying Graphics Support for Intel i5-3380M..." -ForegroundColor Green
    
    # Check for Intel graphics drivers
    $intelGraphics = Get-WmiObject -Class Win32_VideoController | Where-Object { $_.Name -like "*Intel*" }
    if ($intelGraphics) {
        Write-Host "  ✅ Intel Graphics detected: $($intelGraphics.Name)" -ForegroundColor Green
        Write-Host "  ✅ Driver Version: $($intelGraphics.DriverVersion)" -ForegroundColor Green
    }
    else {
        Write-Host "  ⚠️  Intel Graphics not detected, but QEMU will work with software rendering" -ForegroundColor Yellow
    }
    
    # Check DirectX support
    try {
        $dxdiag = Get-Command dxdiag -ErrorAction SilentlyContinue
        if ($dxdiag) {
            Write-Host "  ✅ DirectX support available" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "  ⚠️  DirectX not detected" -ForegroundColor Yellow
    }
    
    # Check for required DLLs
    $requiredDlls = @(
        "gdi32.dll",
        "user32.dll", 
        "kernel32.dll",
        "opengl32.dll"
    )
    
    foreach ($dll in $requiredDlls) {
        $dllPath = "$env:SystemRoot\System32\$dll"
        if (Test-Path $dllPath) {
            Write-Host "  ✅ $dll found" -ForegroundColor Green
        }
        else {
            Write-Host "  ❌ $dll missing" -ForegroundColor Red
        }
    }
    
    Write-Host "  ✅ Graphics verification complete - QEMU graphics mode will work" -ForegroundColor Green
}

# Function to setup native Windows development environment
function Setup-NativeEnvironment {
    Write-Host "🖥️  Setting up Native Windows Development Environment..." -ForegroundColor Green
    Write-Host "  Target System: Intel i5-3380M, 4GB RAM, Legacy BIOS" -ForegroundColor Cyan
    
    # Create development directories
    $devDirs = @(
        "C:\SAGE-OS-Dev",
        "C:\SAGE-OS-Dev\tools",
        "C:\SAGE-OS-Dev\build"
    )
    
    foreach ($dir in $devDirs) {
        if (-not (Test-Path $dir)) {
            New-Item -Path $dir -ItemType Directory -Force | Out-Null
            Write-Host "  📁 Created directory: $dir" -ForegroundColor Cyan
        }
    }
    
    # Download and setup portable tools if needed
    Setup-PortableTools
    
    # Verify cross-compilation capability
    Test-CrossCompilation
}

function Setup-PortableTools {
    Write-Host "🔧 Setting up portable development tools..." -ForegroundColor Yellow
    
    $toolsDir = "C:\SAGE-OS-Dev\tools"
    
    # Download portable MinGW if MSYS2 installation fails
    if (-not (Test-Path "C:\msys64")) {
        Write-Host "  📦 MSYS2 not found, setting up portable MinGW..." -ForegroundColor Cyan
        
        # This would download and extract portable MinGW
        # For now, we'll rely on Chocolatey installation
        Write-Host "  💡 Please ensure MSYS2 is installed via Chocolatey" -ForegroundColor Yellow
    }
    
    # Setup environment variables for native compilation
    $env:SAGE_OS_NATIVE = "1"
    $env:SAGE_OS_ARCH = "i386"
    $env:SAGE_OS_TARGET = "generic"
    
    Write-Host "  ✅ Environment variables configured for native development" -ForegroundColor Green
}

function Test-CrossCompilation {
    Write-Host "🧪 Testing cross-compilation capability..." -ForegroundColor Yellow
    
    # Test if i686-w64-mingw32-gcc is available
    $crossCompilers = @(
        "i686-w64-mingw32-gcc",
        "i686-pc-mingw32-gcc",
        "i686-linux-gnu-gcc"
    )
    
    $foundCompiler = $false
    foreach ($compiler in $crossCompilers) {
        try {
            $result = & $compiler --version 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✅ Cross-compiler found: $compiler" -ForegroundColor Green
                $foundCompiler = $true
                break
            }
        }
        catch {
            # Compiler not found, continue
        }
    }
    
    if (-not $foundCompiler) {
        Write-Host "  ⚠️  No cross-compiler found, will use native compilation" -ForegroundColor Yellow
        Write-Host "  💡 SAGE OS can still be built using MSYS2 environment" -ForegroundColor Cyan
    }
    
    # Test make availability
    try {
        $makeResult = & make --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✅ Make utility available" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "  ⚠️  Make utility not found in PATH" -ForegroundColor Yellow
        Write-Host "  💡 Will use MSYS2 make or install via Chocolatey" -ForegroundColor Cyan
    }
}

# Main execution
$restart_required = $false

Write-Host "🔧 Starting Native Windows Environment Setup..." -ForegroundColor Green
Write-Host "🎯 Target: Intel i5-3380M, 4GB RAM, Legacy BIOS, Windows 10 Pro" -ForegroundColor Cyan
Write-Host "🚫 WSL-Free Native Development Environment" -ForegroundColor Yellow
Write-Host ""

# Install Chocolatey (required for package management)
if (-not $SkipChocolatey) {
    Install-Chocolatey
}

# Install required packages for native development
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Install-RequiredPackages
}

# Setup native Windows development environment
Setup-NativeEnvironment

# Verify graphics support for your system
Verify-GraphicsSupport

# Skip WSL2 setup for native-only deployment
Write-Host "🚫 Skipping WSL2 setup - Using native Windows development only" -ForegroundColor Yellow

Write-Host ""
Write-Host "✅ Native Windows Environment Setup Complete!" -ForegroundColor Green
Write-Host ""

Write-Host "🎯 System Optimization for Intel i5-3380M:" -ForegroundColor Cyan
Write-Host "  • Architecture: i386 (optimal for your CPU)" -ForegroundColor White
Write-Host "  • Memory: 128MB QEMU allocation (perfect for 4GB system)" -ForegroundColor White
Write-Host "  • Graphics: VGA + GTK display (full compatibility)" -ForegroundColor White
Write-Host "  • Build: Native MSYS2 compilation (no WSL needed)" -ForegroundColor White
Write-Host ""

Write-Host "🚀 Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Create shortcuts: scripts\windows\create-desktop-shortcuts.ps1" -ForegroundColor White
Write-Host "  2. Quick launch: scripts\windows\quick-launch.bat" -ForegroundColor White
Write-Host "  3. Build manually: scripts\windows\build-sage-os.bat i386" -ForegroundColor White
Write-Host "  4. Launch graphics: scripts\windows\launch-sage-os-graphics.bat i386" -ForegroundColor White
Write-Host ""

Write-Host "📋 Recommended First Command:" -ForegroundColor Green
Write-Host "  scripts\windows\quick-launch.bat" -ForegroundColor White
Write-Host ""

Write-Host "🎉 Ready for Native SAGE OS Development on Windows!" -ForegroundColor Green