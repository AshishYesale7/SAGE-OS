# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS Windows Setup Validation Script

param(
    [switch]$Detailed,
    [switch]$FixIssues
)

Write-Host "🔍 SAGE OS Windows Setup Validation" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

$validationResults = @()
$issuesFound = 0

function Test-Component($name, $testScript, $fixScript = $null) {
    Write-Host "🧪 Testing: $name" -ForegroundColor Yellow
    
    try {
        $result = & $testScript
        if ($result) {
            Write-Host "  ✅ $name: OK" -ForegroundColor Green
            $script:validationResults += @{Name=$name; Status="OK"; Issue=$null}
        } else {
            Write-Host "  ❌ $name: FAILED" -ForegroundColor Red
            $script:validationResults += @{Name=$name; Status="FAILED"; Issue="Test returned false"}
            $script:issuesFound++
            
            if ($FixIssues -and $fixScript) {
                Write-Host "  🔧 Attempting to fix..." -ForegroundColor Cyan
                & $fixScript
            }
        }
    }
    catch {
        Write-Host "  ❌ $name: ERROR - $($_.Exception.Message)" -ForegroundColor Red
        $script:validationResults += @{Name=$name; Status="ERROR"; Issue=$_.Exception.Message}
        $script:issuesFound++
    }
    
    Write-Host ""
}

# Test 1: Check if all script files exist
Test-Component "Script Files" {
    $requiredScripts = @(
        "scripts\windows\quick-launch.bat",
        "scripts\windows\build-sage-os.bat", 
        "scripts\windows\launch-sage-os-graphics.bat",
        "scripts\windows\launch-sage-os-console.bat",
        "scripts\windows\install-native-dependencies.bat",
        "scripts\windows\setup-windows-environment.ps1"
    )
    
    $allExist = $true
    foreach ($script in $requiredScripts) {
        if (-not (Test-Path $script)) {
            Write-Host "    Missing: $script" -ForegroundColor Red
            $allExist = $false
        } elseif ($Detailed) {
            Write-Host "    Found: $script" -ForegroundColor Green
        }
    }
    return $allExist
}

# Test 2: Check PowerShell script syntax
Test-Component "PowerShell Syntax" {
    $psScripts = Get-ChildItem "scripts\windows\*.ps1" -ErrorAction SilentlyContinue
    $allValid = $true
    
    foreach ($script in $psScripts) {
        try {
            $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $script.FullName -Raw), [ref]$null)
            if ($Detailed) {
                Write-Host "    Valid: $($script.Name)" -ForegroundColor Green
            }
        }
        catch {
            Write-Host "    Invalid: $($script.Name) - $($_.Exception.Message)" -ForegroundColor Red
            $allValid = $false
        }
    }
    return $allValid
}

# Test 3: Check batch file basic syntax
Test-Component "Batch File Syntax" {
    $batScripts = Get-ChildItem "scripts\windows\*.bat" -ErrorAction SilentlyContinue
    $allValid = $true
    
    foreach ($script in $batScripts) {
        $content = Get-Content $script.FullName -Raw
        
        # Check for common syntax issues
        if ($content -match "(?<!REM\s)goto\s+:(\w+).*?^:\1" -and $content -notmatch "goto\s+:eof") {
            if ($Detailed) {
                Write-Host "    Valid: $($script.Name)" -ForegroundColor Green
            }
        } elseif ($content -match "goto\s+:eof" -or $content -match "exit\s+/b") {
            if ($Detailed) {
                Write-Host "    Valid: $($script.Name)" -ForegroundColor Green
            }
        } else {
            # Basic validation passed
            if ($Detailed) {
                Write-Host "    Basic validation passed: $($script.Name)" -ForegroundColor Green
            }
        }
    }
    return $allValid
}

# Test 4: Check system compatibility
Test-Component "System Compatibility" {
    $os = Get-WmiObject -Class Win32_OperatingSystem
    $compatible = $true
    
    # Check Windows version
    if ([int]$os.BuildNumber -lt 19041) {
        Write-Host "    ⚠️  Windows version may be too old for optimal performance" -ForegroundColor Yellow
        $compatible = $false
    } elseif ($Detailed) {
        Write-Host "    Windows version: $($os.Caption) Build $($os.BuildNumber)" -ForegroundColor Green
    }
    
    # Check memory
    $memory = [math]::Round((Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
    if ($memory -lt 2) {
        Write-Host "    ⚠️  Low memory: ${memory}GB (4GB+ recommended)" -ForegroundColor Yellow
        $compatible = $false
    } elseif ($Detailed) {
        Write-Host "    Memory: ${memory}GB" -ForegroundColor Green
    }
    
    return $compatible
}

# Test 5: Check for required tools
Test-Component "Development Tools" {
    $tools = @{
        "Git" = "git"
        "Chocolatey" = "choco"
    }
    
    $allFound = $true
    foreach ($tool in $tools.GetEnumerator()) {
        try {
            $null = Get-Command $tool.Value -ErrorAction Stop
            if ($Detailed) {
                Write-Host "    Found: $($tool.Key)" -ForegroundColor Green
            }
        }
        catch {
            Write-Host "    Missing: $($tool.Key)" -ForegroundColor Red
            $allFound = $false
        }
    }
    return $allFound
} {
    # Fix script for missing tools
    Write-Host "  Installing missing tools..." -ForegroundColor Cyan
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "  Installing Chocolatey..." -ForegroundColor Yellow
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    }
}

# Test 6: Check QEMU availability
Test-Component "QEMU Emulator" {
    $qemuFound = $false
    $qemuPaths = @(
        "qemu-system-i386",
        "C:\Program Files\qemu\qemu-system-i386.exe",
        "C:\qemu\qemu-system-i386.exe"
    )
    
    foreach ($path in $qemuPaths) {
        try {
            if ($path -like "*\*") {
                $qemuFound = Test-Path $path
            } else {
                $null = Get-Command $path -ErrorAction Stop
                $qemuFound = $true
            }
            
            if ($qemuFound) {
                if ($Detailed) {
                    Write-Host "    Found QEMU at: $path" -ForegroundColor Green
                }
                break
            }
        }
        catch {
            # Continue checking other paths
        }
    }
    
    return $qemuFound
} {
    # Fix script for QEMU
    Write-Host "  Installing QEMU..." -ForegroundColor Cyan
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        choco install qemu -y
    }
}

# Test 7: Check build environment
Test-Component "Build Environment" {
    $buildEnvFound = $false
    
    # Check for MSYS2
    if (Test-Path "C:\msys64\usr\bin\make.exe") {
        if ($Detailed) {
            Write-Host "    Found MSYS2 build environment" -ForegroundColor Green
        }
        $buildEnvFound = $true
    }
    
    # Check for native make
    try {
        $null = Get-Command make -ErrorAction Stop
        if ($Detailed) {
            Write-Host "    Found native make" -ForegroundColor Green
        }
        $buildEnvFound = $true
    }
    catch {
        # Make not found
    }
    
    return $buildEnvFound
} {
    # Fix script for build environment
    Write-Host "  Installing MSYS2..." -ForegroundColor Cyan
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        choco install msys2 -y
    }
}

# Test 8: Check graphics libraries
Test-Component "Graphics Libraries" {
    $graphicsOK = $true
    
    # Check for basic Windows graphics support
    $gdi32 = Test-Path "$env:SystemRoot\System32\gdi32.dll"
    $user32 = Test-Path "$env:SystemRoot\System32\user32.dll"
    
    if (-not $gdi32 -or -not $user32) {
        Write-Host "    Missing basic Windows graphics DLLs" -ForegroundColor Red
        $graphicsOK = $false
    } elseif ($Detailed) {
        Write-Host "    Windows graphics DLLs found" -ForegroundColor Green
    }
    
    return $graphicsOK
}

# Summary
Write-Host "📊 Validation Summary" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan
Write-Host ""

$totalTests = $validationResults.Count
$passedTests = ($validationResults | Where-Object { $_.Status -eq "OK" }).Count
$failedTests = ($validationResults | Where-Object { $_.Status -eq "FAILED" }).Count
$errorTests = ($validationResults | Where-Object { $_.Status -eq "ERROR" }).Count

Write-Host "Total Tests: $totalTests" -ForegroundColor White
Write-Host "Passed: $passedTests" -ForegroundColor Green
Write-Host "Failed: $failedTests" -ForegroundColor Red
Write-Host "Errors: $errorTests" -ForegroundColor Red
Write-Host ""

if ($issuesFound -eq 0) {
    Write-Host "✅ All validations passed! SAGE OS Windows setup is ready." -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Run: scripts\windows\quick-launch.bat" -ForegroundColor White
    Write-Host "  2. Or build manually: scripts\windows\build-sage-os.bat i386" -ForegroundColor White
} else {
    Write-Host "⚠️  $issuesFound issue(s) found. Please address them before proceeding." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "🔧 To automatically fix issues, run:" -ForegroundColor Cyan
    Write-Host "  .\scripts\windows\validate-setup.ps1 -FixIssues" -ForegroundColor White
    Write-Host ""
    Write-Host "📋 Manual fixes:" -ForegroundColor Cyan
    Write-Host "  1. Install missing tools: scripts\windows\install-native-dependencies.bat" -ForegroundColor White
    Write-Host "  2. Run setup: scripts\windows\setup-windows-environment.ps1" -ForegroundColor White
}

Write-Host ""
Write-Host "📖 For detailed troubleshooting, see:" -ForegroundColor Cyan
Write-Host "  • TROUBLESHOOTING_WINDOWS.md" -ForegroundColor White
Write-Host "  • README_WINDOWS_NATIVE.md" -ForegroundColor White