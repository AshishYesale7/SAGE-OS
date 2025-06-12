# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

param(
    [string]$Arch = "i386",
    [string]$Memory = "128M",
    [string]$KernelPath = "",
    [switch]$Console,
    [switch]$Help
)

if ($Help) {
    Write-Host "🚀 SAGE OS Graphics Launcher" -ForegroundColor Cyan
    Write-Host "Usage: .\launch-sage-os.ps1 [options]" -ForegroundColor White
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  -Arch <arch>        Architecture (i386, x86_64) [default: i386]"
    Write-Host "  -Memory <size>      Memory size [default: 128M]"
    Write-Host "  -KernelPath <path>  Custom kernel path"
    Write-Host "  -Console           Use console mode instead of graphics"
    Write-Host "  -Help              Show this help"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Green
    Write-Host "  .\launch-sage-os.ps1                    # Default graphics mode"
    Write-Host "  .\launch-sage-os.ps1 -Arch x86_64       # 64-bit graphics mode"
    Write-Host "  .\launch-sage-os.ps1 -Console           # Console mode"
    Write-Host "  .\launch-sage-os.ps1 -Memory 256M       # More memory"
    exit 0
}

Write-Host "🚀 SAGE OS Graphics Mode Launcher" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Auto-detect kernel path if not specified
if (-not $KernelPath) {
    $KernelPath = "build\$Arch\kernel.elf"
}

Write-Host "🖥️  Architecture: $Arch" -ForegroundColor Green
Write-Host "💾 Memory: $Memory" -ForegroundColor Green
Write-Host "📄 Kernel: $KernelPath" -ForegroundColor Green
Write-Host ""

# Check if QEMU is available
$qemuCmd = "qemu-system-$Arch"
if (-not (Get-Command $qemuCmd -ErrorAction SilentlyContinue)) {
    Write-Host "❌ $qemuCmd not found" -ForegroundColor Red
    Write-Host "💡 Install QEMU: choco install qemu" -ForegroundColor Yellow
    exit 1
}

# Check if kernel exists
if (-not (Test-Path $KernelPath)) {
    Write-Host "❌ Kernel not found: $KernelPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Build SAGE OS first:" -ForegroundColor Yellow
    Write-Host "  make ARCH=$Arch TARGET=generic" -ForegroundColor White
    Write-Host "  or use WSL2: wsl make ARCH=$Arch TARGET=generic" -ForegroundColor White
    exit 1
}

Write-Host "✅ Kernel found: $KernelPath" -ForegroundColor Green
Write-Host ""

# Prepare QEMU arguments
$qemuArgs = @(
    "-kernel", $KernelPath,
    "-m", $Memory,
    "-name", "SAGE OS v1.0.1",
    "-no-reboot"
)

if ($Console) {
    $qemuArgs += @("-nographic")
    Write-Host "🖥️  Launching SAGE OS in console mode..." -ForegroundColor Green
} else {
    $qemuArgs += @(
        "-vga", "std",
        "-display", "gtk",
        "-device", "usb-kbd",
        "-device", "usb-mouse"
    )
    Write-Host "🖥️  Launching SAGE OS in graphics mode..." -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Instructions:" -ForegroundColor Yellow
    Write-Host "  • SAGE OS will boot in a graphics window" -ForegroundColor White
    Write-Host "  • Use keyboard to interact with the shell" -ForegroundColor White
    Write-Host "  • Type 'help' to see available commands" -ForegroundColor White
    Write-Host "  • Press Ctrl+Alt+G to release mouse cursor" -ForegroundColor White
    Write-Host "  • Close window to exit" -ForegroundColor White
}

Write-Host ""

# Launch QEMU
try {
    & $qemuCmd $qemuArgs
    Write-Host ""
    Write-Host "👋 SAGE OS session ended" -ForegroundColor Green
}
catch {
    Write-Host "❌ Failed to launch QEMU: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}