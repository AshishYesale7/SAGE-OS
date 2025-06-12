#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# Comprehensive Build System Verification
# Tests all components: kernel, boot files, linkers, and scripts

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[1;36m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}🔍 SAGE OS Build System Verification${NC}"
    echo "====================================="
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_section() {
    echo
    echo -e "${BLUE}📋 $1${NC}"
    echo "$(printf '─%.0s' {1..50})"
}

# Global counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Test function
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    if eval "$test_command" >/dev/null 2>&1; then
        print_success "$test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        print_error "$test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Check file existence
check_file() {
    local file="$1"
    local description="$2"
    
    if [[ -f "$file" ]]; then
        print_success "$description: $file"
        return 0
    else
        print_error "$description missing: $file"
        return 1
    fi
}

# Check directory existence
check_directory() {
    local dir="$1"
    local description="$2"
    
    if [[ -d "$dir" ]]; then
        print_success "$description: $dir"
        return 0
    else
        print_error "$description missing: $dir"
        return 1
    fi
}

# Check executable
check_executable() {
    local file="$1"
    local description="$2"
    
    if [[ -x "$file" ]]; then
        print_success "$description executable: $file"
        return 0
    else
        print_error "$description not executable: $file"
        return 1
    fi
}

# Verify core files
verify_core_files() {
    print_section "Core Files Verification"
    
    # Kernel files
    check_file "kernel/kernel_graphics_simple.c" "Graphics kernel source"
    check_file "kernel/kernel_graphics.c" "Original graphics kernel"
    check_file "kernel/kernel.c" "Main kernel source"
    
    # Boot files
    check_file "boot/boot_i386.S" "Standard i386 boot loader"
    check_file "boot/boot_i386_improved.S" "Improved i386 boot loader"
    
    # Linker scripts
    check_file "linker_x86.ld" "Standard x86 linker script"
    check_file "linker_i386_graphics.ld" "i386 graphics linker script"
    check_file "linker_i386.ld" "i386 linker script"
    
    # Build scripts
    check_executable "build-i386-graphics.sh" "i386 graphics builder"
    check_executable "run-i386-graphics.sh" "i386 graphics runner"
    check_executable "test-i386-build.sh" "i386 build tester"
    
    # Directories
    check_directory "output" "Output directory"
    check_directory "kernel" "Kernel directory"
    check_directory "boot" "Boot directory"
    check_directory "drivers" "Drivers directory"
}

# Verify build tools
verify_build_tools() {
    print_section "Build Tools Verification"
    
    run_test "GCC compiler available" "command -v gcc"
    run_test "Clang compiler available" "command -v clang"
    run_test "GNU linker available" "command -v ld"
    run_test "objcopy available" "command -v objcopy"
    run_test "objdump available" "command -v objdump"
    run_test "file command available" "command -v file"
    run_test "hexdump available" "command -v hexdump"
    run_test "make available" "command -v make"
}

# Test compilation
test_compilation() {
    print_section "Compilation Tests"
    
    # Test boot loader compilation
    print_info "Testing boot loader compilation..."
    if gcc -m32 -c boot/boot_i386_improved.S -o /tmp/test_boot.o 2>/dev/null; then
        print_success "Improved boot loader compiles"
        rm -f /tmp/test_boot.o
    else
        print_error "Improved boot loader compilation failed"
        if gcc -m32 -c boot/boot_i386.S -o /tmp/test_boot.o 2>/dev/null; then
            print_success "Standard boot loader compiles"
            rm -f /tmp/test_boot.o
        else
            print_error "Standard boot loader compilation failed"
        fi
    fi
    
    # Test kernel compilation
    print_info "Testing kernel compilation..."
    if gcc -m32 -nostdlib -nostartfiles -ffreestanding -c kernel/kernel_graphics_simple.c -o /tmp/test_kernel.o 2>/dev/null; then
        print_success "Graphics kernel compiles"
        rm -f /tmp/test_kernel.o
    else
        print_error "Graphics kernel compilation failed"
    fi
}

# Test linker scripts
test_linker_scripts() {
    print_section "Linker Script Tests"
    
    # Create dummy object files for testing
    echo 'void _start() {}' > /tmp/test.c
    gcc -m32 -c /tmp/test.c -o /tmp/test.o 2>/dev/null || return 1
    
    # Test each linker script
    for linker in linker_x86.ld linker_i386.ld linker_i386_graphics.ld; do
        if [[ -f "$linker" ]]; then
            if ld -T "$linker" -m elf_i386 /tmp/test.o -o /tmp/test_kernel 2>/dev/null; then
                print_success "Linker script works: $linker"
                rm -f /tmp/test_kernel
            else
                print_error "Linker script failed: $linker"
            fi
        else
            print_warning "Linker script missing: $linker"
        fi
    done
    
    # Cleanup
    rm -f /tmp/test.c /tmp/test.o /tmp/test_kernel
}

# Test build scripts
test_build_scripts() {
    print_section "Build Script Tests"
    
    # Test script syntax
    for script in build-i386-graphics.sh run-i386-graphics.sh test-i386-build.sh; do
        if [[ -f "$script" ]]; then
            if bash -n "$script" 2>/dev/null; then
                print_success "Script syntax valid: $script"
            else
                print_error "Script syntax error: $script"
            fi
        else
            print_warning "Script missing: $script"
        fi
    done
    
    # Test script permissions
    for script in *.sh; do
        if [[ -f "$script" ]]; then
            if [[ -x "$script" ]]; then
                print_success "Script executable: $script"
            else
                print_warning "Script not executable: $script"
            fi
        fi
    done
}

# Test actual build
test_actual_build() {
    print_section "Actual Build Test"
    
    print_info "Testing i386 graphics build..."
    
    if [[ -x "build-i386-graphics.sh" ]]; then
        if ./build-i386-graphics.sh >/dev/null 2>&1; then
            print_success "i386 graphics build completed"
            
            # Verify output files
            local elf_file="output/i386/sage-os-v1.0.1-i386-generic-graphics.elf"
            local img_file="output/i386/sage-os-v1.0.1-i386-generic-graphics.img"
            
            if [[ -f "$elf_file" ]]; then
                print_success "ELF file created: $elf_file"
                
                # Check architecture
                if command -v file >/dev/null 2>&1; then
                    local file_info
                    file_info=$(file "$elf_file")
                    if [[ "$file_info" =~ "ELF 32-bit" ]] && [[ "$file_info" =~ "80386" ]]; then
                        print_success "Architecture verified: 32-bit x86"
                    else
                        print_error "Wrong architecture: $file_info"
                    fi
                fi
            else
                print_error "ELF file not created"
            fi
            
            if [[ -f "$img_file" ]]; then
                print_success "Image file created: $img_file"
            else
                print_error "Image file not created"
            fi
        else
            print_error "i386 graphics build failed"
        fi
    else
        print_error "Build script not executable"
    fi
}

# Test QEMU compatibility
test_qemu_compatibility() {
    print_section "QEMU Compatibility Test"
    
    # Check for QEMU
    if command -v qemu-system-i386 >/dev/null 2>&1; then
        print_success "QEMU i386 available"
        
        local qemu_version
        qemu_version=$(qemu-system-i386 --version | head -n1)
        print_info "QEMU version: $qemu_version"
        
        # Test QEMU help for required options
        if qemu-system-i386 -help | grep -q "\-kernel"; then
            print_success "QEMU supports -kernel option"
        else
            print_error "QEMU missing -kernel support"
        fi
        
        if qemu-system-i386 -help | grep -q "\-display"; then
            print_success "QEMU supports -display option"
        else
            print_error "QEMU missing -display support"
        fi
    else
        print_warning "QEMU i386 not available (install with: brew install qemu)"
    fi
}

# Generate report
generate_report() {
    print_section "Verification Summary"
    
    echo
    echo -e "${BLUE}📊 Test Results:${NC}"
    echo "  Total tests: $TESTS_TOTAL"
    echo -e "  Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "  Failed: ${RED}$TESTS_FAILED${NC}"
    
    local success_rate
    if [[ $TESTS_TOTAL -gt 0 ]]; then
        success_rate=$((TESTS_PASSED * 100 / TESTS_TOTAL))
        echo "  Success rate: $success_rate%"
    fi
    
    echo
    if [[ $TESTS_FAILED -eq 0 ]]; then
        print_success "All verification tests passed! ✨"
        echo
        print_info "Your SAGE OS build system is ready for use."
        print_info "Next steps:"
        echo "  1. Build: ./build-i386-graphics.sh"
        echo "  2. Test: ./test-i386-build.sh"
        echo "  3. Run: ./run-i386-graphics.sh cocoa"
    else
        print_error "Some verification tests failed."
        echo
        print_info "Please address the failed tests before proceeding."
        print_info "Check the error messages above for details."
    fi
    
    echo
}

# Main execution
main() {
    print_header
    echo
    
    verify_core_files
    verify_build_tools
    test_compilation
    test_linker_scripts
    test_build_scripts
    test_actual_build
    test_qemu_compatibility
    
    generate_report
}

# Run verification
main "$@"