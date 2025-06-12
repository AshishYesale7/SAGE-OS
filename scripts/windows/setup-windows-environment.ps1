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

# Function to install required packages
function Install-RequiredPackages {
    Write-Host "📦 Installing Required Packages..." -ForegroundColor Green
    
    $packages = @(
        "git",
        "qemu",
        "make",
        "mingw",
        "msys2",
        "vscode"
    )
    
    foreach ($package in $packages) {
        Write-Host "  Installing $package..." -ForegroundColor Yellow
        try {
            choco install $package -y --no-progress
            Write-Host "  ✅ $package installed" -ForegroundColor Green
        }
        catch {
            Write-Host "  ⚠️  Failed to install $package" -ForegroundColor Yellow
        }
    }
}

# Function to setup WSL2
function Setup-WSL2 {
    Write-Host "🐧 Setting up WSL2..." -ForegroundColor Green
    
    # Check if WSL is already enabled
    $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
    $vmFeature = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
    
    if ($wslFeature.State -eq "Enabled" -and $vmFeature.State -eq "Enabled") {
        Write-Host "  ✅ WSL2 features already enabled" -ForegroundColor Green
    }
    else {
        Write-Host "  Enabling WSL and Virtual Machine Platform..." -ForegroundColor Yellow
        
        try {
            Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
            Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
            Write-Host "  ✅ WSL2 features enabled (restart required)" -ForegroundColor Green
            $script:restart_required = $true
        }
        catch {
            Write-Host "  ❌ Failed to enable WSL2 features" -ForegroundColor Red
        }
    }
    
    # Install Ubuntu if not present
    if (-not (wsl -l -q | Select-String "Ubuntu")) {
        Write-Host "  Installing Ubuntu..." -ForegroundColor Yellow
        try {
            choco install wsl-ubuntu-2004 -y --no-progress
            Write-Host "  ✅ Ubuntu installed" -ForegroundColor Green
        }
        catch {
            Write-Host "  ⚠️  Failed to install Ubuntu via Chocolatey" -ForegroundColor Yellow
            Write-Host "  💡 Please install Ubuntu manually from Microsoft Store" -ForegroundColor Cyan
        }
    }
    else {
        Write-Host "  ✅ Ubuntu already installed" -ForegroundColor Green
    }
}

# Main execution
$restart_required = $false

Write-Host "🔧 Starting Windows Environment Setup..." -ForegroundColor Green
Write-Host ""

# Install Chocolatey
if (-not $SkipChocolatey) {
    Install-Chocolatey
}

# Install required packages
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Install-RequiredPackages
}

# Setup WSL2
if (-not $SkipWSL) {
    Setup-WSL2
}

Write-Host ""
Write-Host "✅ Windows Environment Setup Complete!" -ForegroundColor Green
Write-Host ""

if ($restart_required) {
    Write-Host "⚠️  RESTART REQUIRED" -ForegroundColor Yellow
    Write-Host "Please restart your computer to complete WSL2 setup." -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "🚀 Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Run: scripts\windows\create-launchers.ps1" -ForegroundColor White
Write-Host "  2. Build SAGE OS: scripts\windows\build-sage-os.bat" -ForegroundColor White
Write-Host "  3. Launch Graphics: scripts\windows\launch-sage-os-graphics.bat" -ForegroundColor White
Write-Host ""
Write-Host "🎉 Ready to run SAGE OS on Windows!" -ForegroundColor Green