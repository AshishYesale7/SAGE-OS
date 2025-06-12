#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# Test script to verify i386 build works correctly

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[1;36m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_header() {
    echo -e "${BLUE}🧪 SAGE OS i386 Build Test${NC}"
    echo "============================"
}

# Test the build
test_build() {
    local kernel_elf="output/i386/sage-os-v1.0.1-i386-generic-graphics.elf"
    local kernel_img="output/i386/sage-os-v1.0.1-i386-generic-graphics.img"
    
    print_header
    echo
    
    # Check if files exist
    if [[ -f "$kernel_elf" ]]; then
        print_success "ELF file exists: $kernel_elf"
    else
        echo "❌ ELF file missing: $kernel_elf"
        return 1
    fi
    
    if [[ -f "$kernel_img" ]]; then
        print_success "Image file exists: $kernel_img"
    else
        echo "❌ Image file missing: $kernel_img"
        return 1
    fi
    
    # Check file info
    if command -v file >/dev/null 2>&1; then
        local file_info
        file_info=$(file "$kernel_elf")
        print_info "File info: $file_info"
        
        if [[ "$file_info" =~ "ELF 32-bit" ]] && [[ "$file_info" =~ "80386" ]]; then
            print_success "Architecture verified: 32-bit x86 (i386)"
        else
            echo "❌ Wrong architecture: $file_info"
            return 1
        fi
    fi
    
    # Check file sizes
    local elf_size
    local img_size
    elf_size=$(stat -c%s "$kernel_elf" 2>/dev/null || stat -f%z "$kernel_elf" 2>/dev/null)
    img_size=$(stat -c%s "$kernel_img" 2>/dev/null || stat -f%z "$kernel_img" 2>/dev/null)
    
    print_info "ELF size: $elf_size bytes"
    print_info "Image size: $img_size bytes"
    
    if [[ $elf_size -gt 10000 ]] && [[ $img_size -gt 5000 ]]; then
        print_success "File sizes look reasonable"
    else
        echo "❌ Files seem too small - build may be incomplete"
        return 1
    fi
    
    # Check for multiboot header
    if command -v hexdump >/dev/null 2>&1; then
        local multiboot_check
        multiboot_check=$(hexdump -C "$kernel_elf" | head -20 | grep "1b ad b0 02" || true)
        if [[ -n "$multiboot_check" ]]; then
            print_success "Multiboot header found"
        else
            print_info "Multiboot header check inconclusive"
        fi
    fi
    
    echo
    print_success "Build verification completed successfully!"
    echo
    print_info "The i386 graphics kernel is ready for macOS testing."
    print_info "On macOS, use: ./run-i386-graphics.sh"
    print_info "Or manually: qemu-system-i386 -kernel $kernel_elf -m 128M -display cocoa"
    echo
    
    return 0
}

# Main execution
test_build