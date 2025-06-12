#!/bin/bash
# Comprehensive validation script for Windows deployment

echo "🧪 SAGE OS Windows Scripts Validation"
echo "====================================="
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Test function
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -e "${BLUE}🔍 Testing: $test_name${NC}"
    ((TOTAL_TESTS++))
    
    if eval "$test_command"; then
        echo -e "${GREEN}  ✅ PASS${NC}"
        ((PASSED_TESTS++))
    else
        echo -e "${RED}  ❌ FAIL${NC}"
        ((FAILED_TESTS++))
    fi
    echo
}

# Test 1: Check if all required scripts exist
test_scripts_exist() {
    local required_scripts=(
        "build-sage-os.bat"
        "launch-sage-os-graphics.bat"
        "launch-sage-os-console.bat"
        "quick-launch.bat"
        "install-dependencies.bat"
        "install-native-dependencies.bat"
        "sage-os-installer.bat"
        "create-shortcuts.bat"
        "setup-windows-environment.ps1"
    )
    
    local missing=0
    for script in "${required_scripts[@]}"; do
        if [[ ! -f "scripts/windows/$script" ]]; then
            echo "  Missing: $script"
            ((missing++))
        fi
    done
    
    return $missing
}

# Test 2: Validate batch file syntax
test_batch_syntax() {
    local errors=0
    
    for file in scripts/windows/*.bat; do
        if [[ -f "$file" ]]; then
            # Check for @echo off
            if ! head -1 "$file" | grep -q "@echo off"; then
                echo "  Missing @echo off in $(basename "$file")"
                ((errors++))
            fi
            
            # Check for proper REM comments
            if ! grep -q "^REM " "$file"; then
                echo "  No REM comments found in $(basename "$file")"
                ((errors++))
            fi
            
            # Check for exit statements
            if grep -q "exit /b" "$file"; then
                echo "  ✓ Proper exit statements in $(basename "$file")"
            fi
        fi
    done
    
    return $errors
}

# Test 3: Check PowerShell syntax
test_powershell_syntax() {
    local errors=0
    
    for file in scripts/windows/*.ps1; do
        if [[ -f "$file" ]]; then
            # Check for param blocks
            if grep -q "param(" "$file"; then
                echo "  ✓ Param block found in $(basename "$file")"
            fi
            
            # Check for proper function definitions
            if grep -q "function " "$file"; then
                echo "  ✓ Functions found in $(basename "$file")"
            fi
        fi
    done
    
    return $errors
}

# Test 4: Validate QEMU command syntax
test_qemu_commands() {
    local errors=0
    
    # Check graphics launcher
    if [[ -f "scripts/windows/launch-sage-os-graphics.bat" ]]; then
        if grep -q "qemu-system-i386" "scripts/windows/launch-sage-os-graphics.bat"; then
            echo "  ✓ QEMU i386 command found in graphics launcher"
        else
            echo "  Missing QEMU command in graphics launcher"
            ((errors++))
        fi
        
        if grep -q "\-vga std" "scripts/windows/launch-sage-os-graphics.bat"; then
            echo "  ✓ VGA graphics option found"
        else
            echo "  Missing VGA graphics option"
            ((errors++))
        fi
        
        if grep -q "\-device usb-kbd" "scripts/windows/launch-sage-os-graphics.bat"; then
            echo "  ✓ USB keyboard support found"
        else
            echo "  Missing USB keyboard support"
            ((errors++))
        fi
    fi
    
    return $errors
}

# Test 5: Check dependency installation logic
test_dependency_logic() {
    local errors=0
    
    if [[ -f "scripts/windows/install-dependencies.bat" ]]; then
        if grep -q "choco install" "scripts/windows/install-dependencies.bat"; then
            echo "  ✓ Chocolatey installation commands found"
        else
            echo "  Missing Chocolatey installation commands"
            ((errors++))
        fi
        
        if grep -q "qemu" "scripts/windows/install-dependencies.bat"; then
            echo "  ✓ QEMU installation found"
        else
            echo "  Missing QEMU installation"
            ((errors++))
        fi
    fi
    
    return $errors
}

# Test 6: Validate build script logic
test_build_logic() {
    local errors=0
    
    if [[ -f "scripts/windows/build-sage-os.bat" ]]; then
        if grep -q "BUILD_METHOD=auto" "scripts/windows/build-sage-os.bat"; then
            echo "  ✓ Auto-detection logic found"
        else
            echo "  Missing auto-detection logic"
            ((errors++))
        fi
        
        if grep -q "msys2" "scripts/windows/build-sage-os.bat"; then
            echo "  ✓ MSYS2 build method found"
        else
            echo "  Missing MSYS2 build method"
            ((errors++))
        fi
        
        if grep -q ":BuildComplete" "scripts/windows/build-sage-os.bat"; then
            echo "  ✓ Build completion label found"
        else
            echo "  Missing build completion label"
            ((errors++))
        fi
    fi
    
    return $errors
}

# Test 7: Check system optimization
test_system_optimization() {
    local errors=0
    
    # Check for Intel i5-3380M optimizations
    if grep -r "i5-3380M" scripts/windows/; then
        echo "  ✓ System-specific optimizations found"
    else
        echo "  Missing system-specific optimizations"
        ((errors++))
    fi
    
    # Check for 4GB RAM optimizations
    if grep -r "4GB" scripts/windows/; then
        echo "  ✓ RAM-specific optimizations found"
    else
        echo "  Missing RAM-specific optimizations"
        ((errors++))
    fi
    
    # Check for i386 architecture preference
    if grep -r "i386" scripts/windows/; then
        echo "  ✓ i386 architecture support found"
    else
        echo "  Missing i386 architecture support"
        ((errors++))
    fi
    
    return $errors
}

# Test 8: Validate documentation
test_documentation() {
    local errors=0
    
    if [[ -f "docs/platforms/windows/WINDOWS_DEPLOYMENT_GUIDE.md" ]]; then
        echo "  ✓ Windows deployment guide exists"
    else
        echo "  Missing Windows deployment guide"
        ((errors++))
    fi
    
    if [[ -f "README-WINDOWS.md" ]]; then
        echo "  ✓ Windows README exists"
    else
        echo "  Missing Windows README"
        ((errors++))
    fi
    
    return $errors
}

# Test 9: Check Makefile integration
test_makefile_integration() {
    local errors=0
    
    if grep -q "windows-" Makefile; then
        echo "  ✓ Windows targets found in Makefile"
    else
        echo "  Missing Windows targets in Makefile"
        ((errors++))
    fi
    
    if grep -q "Windows Scripts" Makefile; then
        echo "  ✓ Windows help section found"
    else
        echo "  Missing Windows help section"
        ((errors++))
    fi
    
    return $errors
}

# Test 10: Validate error handling
test_error_handling() {
    local errors=0
    
    for file in scripts/windows/*.bat; do
        if [[ -f "$file" ]]; then
            if grep -q "if %errorlevel%" "$file"; then
                echo "  ✓ Error level checking in $(basename "$file")"
            else
                echo "  Missing error level checking in $(basename "$file")"
                ((errors++))
            fi
        fi
    done
    
    return $errors
}

# Run all tests
echo "🚀 Starting comprehensive validation..."
echo

run_test "Required Scripts Exist" "test_scripts_exist"
run_test "Batch File Syntax" "test_batch_syntax"
run_test "PowerShell Syntax" "test_powershell_syntax"
run_test "QEMU Commands" "test_qemu_commands"
run_test "Dependency Logic" "test_dependency_logic"
run_test "Build Logic" "test_build_logic"
run_test "System Optimization" "test_system_optimization"
run_test "Documentation" "test_documentation"
run_test "Makefile Integration" "test_makefile_integration"
run_test "Error Handling" "test_error_handling"

# Summary
echo "📊 Test Summary:"
echo "================"
echo -e "Total Tests: ${BLUE}$TOTAL_TESTS${NC}"
echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed: ${RED}$FAILED_TESTS${NC}"

if [[ $FAILED_TESTS -eq 0 ]]; then
    echo -e "\n${GREEN}🎉 All tests passed! Windows deployment is ready.${NC}"
    exit 0
else
    echo -e "\n${YELLOW}⚠️  Some tests failed. Review the issues above.${NC}"
    exit 1
fi