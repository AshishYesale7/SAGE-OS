# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# Create Desktop Shortcuts for SAGE OS

Write-Host "🖥️  Creating SAGE OS Desktop Shortcuts" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

$currentDir = Get-Location
$desktop = [Environment]::GetFolderPath("Desktop")
$WshShell = New-Object -comObject WScript.Shell

# Create SAGE OS Quick Launch shortcut
Write-Host "📎 Creating Quick Launch shortcut..." -ForegroundColor Green
$Shortcut = $WshShell.CreateShortcut("$desktop\SAGE OS Quick Launch.lnk")
$Shortcut.TargetPath = "$currentDir\scripts\windows\quick-launch.bat"
$Shortcut.WorkingDirectory = $currentDir
$Shortcut.Description = "Quick Launch SAGE OS with Auto-Build"
$Shortcut.IconLocation = "shell32.dll,25"  # Computer icon
$Shortcut.Save()

# Create SAGE OS Graphics Mode shortcut
Write-Host "📎 Creating Graphics Mode shortcut..." -ForegroundColor Green
$Shortcut = $WshShell.CreateShortcut("$desktop\SAGE OS Graphics.lnk")
$Shortcut.TargetPath = "$currentDir\scripts\windows\launch-sage-os-graphics.bat"
$Shortcut.Arguments = "i386 128M"
$Shortcut.WorkingDirectory = $currentDir
$Shortcut.Description = "Launch SAGE OS in Graphics Mode (i386, 128M RAM)"
$Shortcut.IconLocation = "shell32.dll,15"  # Monitor icon
$Shortcut.Save()

# Create Build SAGE OS shortcut
Write-Host "📎 Creating Build shortcut..." -ForegroundColor Green
$Shortcut = $WshShell.CreateShortcut("$desktop\Build SAGE OS.lnk")
$Shortcut.TargetPath = "$currentDir\scripts\windows\build-sage-os.bat"
$Shortcut.Arguments = "i386 generic"
$Shortcut.WorkingDirectory = $currentDir
$Shortcut.Description = "Build SAGE OS for i386 Architecture"
$Shortcut.IconLocation = "shell32.dll,162"  # Gear icon
$Shortcut.Save()

# Create SAGE OS Console Mode shortcut
Write-Host "📎 Creating Console Mode shortcut..." -ForegroundColor Green
$Shortcut = $WshShell.CreateShortcut("$desktop\SAGE OS Console.lnk")
$Shortcut.TargetPath = "$currentDir\scripts\windows\launch-sage-os-console.bat"
$Shortcut.Arguments = "i386 128M"
$Shortcut.WorkingDirectory = $currentDir
$Shortcut.Description = "Launch SAGE OS in Console Mode (i386, 128M RAM)"
$Shortcut.IconLocation = "shell32.dll,137"  # Terminal icon
$Shortcut.Save()

Write-Host ""
Write-Host "✅ Desktop shortcuts created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Created shortcuts:" -ForegroundColor Yellow
Write-Host "  • SAGE OS Quick Launch - Auto-build and launch" -ForegroundColor White
Write-Host "  • SAGE OS Graphics - Direct graphics mode" -ForegroundColor White
Write-Host "  • Build SAGE OS - Build system only" -ForegroundColor White
Write-Host "  • SAGE OS Console - Text-only mode" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Double-click any shortcut to get started!" -ForegroundColor Green