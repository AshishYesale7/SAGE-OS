#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS i386 Graphics Builder
# Specifically builds 32-bit graphics kernel for maximum macOS compatibility

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[1;36m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}🎨 SAGE OS i386 Graphics Builder${NC}"
    echo "===================================="
    echo -e "${CYAN}Building 32-bit graphics kernel for macOS compatibility${NC}"
    echo
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# Configuration
ARCH="i386"
TARGET="generic"
VERSION="1.0.1"
BUILD_ID="sage-os-v${VERSION}-${ARCH}-${TARGET}-graphics"
OUTPUT_DIR="output/${ARCH}"
BUILD_DIR="build/${ARCH}-graphics"

# Create directories
create_directories() {
    print_info "Creating build directories..."
    mkdir -p "$BUILD_DIR"/{boot,kernel,drivers}
    mkdir -p "$OUTPUT_DIR"
}

# Clean previous builds
clean_build() {
    print_info "Cleaning previous builds..."
    rm -rf "$BUILD_DIR"
    rm -rf build/i386  # Also clean regular i386 build
}

# Build graphics kernel
build_graphics_kernel() {
    print_info "Building i386 graphics kernel..."
    
    # Use simple graphics kernel source (no conflicts)
    local kernel_source="kernel/kernel_graphics_simple.c"
    if [[ ! -f "$kernel_source" ]]; then
        print_error "Graphics kernel source not found: $kernel_source"
        exit 1
    fi
    
    # Compiler settings for i386
    local CC="gcc"
    local CFLAGS="-m32 -nostdlib -nostartfiles -ffreestanding -O2 -Wall -Wextra"
    CFLAGS="$CFLAGS -I. -Ikernel -Idrivers -D__i386__ -fno-pic -fno-pie"
    
    # Check if we're on macOS and adjust compiler
    if [[ "$(uname)" == "Darwin" ]]; then
        # On macOS, use clang with proper target
        CC="clang"
        CFLAGS="$CFLAGS -target i386-pc-none-elf"
        print_info "Using clang for macOS with i386 target"
    fi
    
    print_info "Compiler: $CC"
    print_info "CFLAGS: $CFLAGS"
    
    # Compile boot loader
    print_info "Compiling boot loader..."
    $CC $CFLAGS -c boot/boot_i386.S -o "$BUILD_DIR/boot/boot_i386.o"
    
    # Compile graphics kernel (self-contained, no external dependencies)
    print_info "Compiling graphics kernel..."
    $CC $CFLAGS -c "$kernel_source" -o "$BUILD_DIR/kernel/kernel_graphics_simple.o"
    
    # Link everything
    print_info "Linking kernel..."
    local LD="ld"
    local LDFLAGS="-T linker_x86.ld -m elf_i386"
    
    # Collect object files (just boot and kernel)
    local objects=()
    objects+=("$BUILD_DIR/boot/boot_i386.o")
    objects+=("$BUILD_DIR/kernel/kernel_graphics_simple.o")
    
    # Link to ELF
    $LD $LDFLAGS -o "$BUILD_DIR/kernel.elf" "${objects[@]}"
    
    # Create binary image
    print_info "Creating kernel image..."
    objcopy -O binary "$BUILD_DIR/kernel.elf" "$BUILD_DIR/kernel.bin"
    
    # Copy to output directory
    cp "$BUILD_DIR/kernel.elf" "$OUTPUT_DIR/$BUILD_ID.elf"
    cp "$BUILD_DIR/kernel.bin" "$OUTPUT_DIR/$BUILD_ID.img"
    
    print_success "i386 graphics kernel built successfully!"
    print_info "ELF file: $OUTPUT_DIR/$BUILD_ID.elf"
    print_info "Binary: $OUTPUT_DIR/$BUILD_ID.img"
}

# Verify build
verify_build() {
    local elf_file="$OUTPUT_DIR/$BUILD_ID.elf"
    local img_file="$OUTPUT_DIR/$BUILD_ID.img"
    
    if [[ ! -f "$elf_file" ]]; then
        print_error "ELF file not created: $elf_file"
        return 1
    fi
    
    if [[ ! -f "$img_file" ]]; then
        print_error "Image file not created: $img_file"
        return 1
    fi
    
    # Check architecture
    if command -v file >/dev/null 2>&1; then
        local file_info
        file_info=$(file "$elf_file")
        print_info "Kernel info: $file_info"
        
        if [[ "$file_info" =~ "80386" ]] || [[ "$file_info" =~ "i386" ]]; then
            print_success "Architecture verified: 32-bit x86 (i386)"
        else
            print_error "Architecture mismatch: $file_info"
            return 1
        fi
    fi
    
    # Check file sizes
    local elf_size
    local img_size
    elf_size=$(stat -f%z "$elf_file" 2>/dev/null || stat -c%s "$elf_file" 2>/dev/null)
    img_size=$(stat -f%z "$img_file" 2>/dev/null || stat -c%s "$img_file" 2>/dev/null)
    
    print_info "ELF size: $elf_size bytes"
    print_info "Image size: $img_size bytes"
    
    if [[ $elf_size -lt 1000 ]] || [[ $img_size -lt 500 ]]; then
        print_error "Kernel files seem too small - build may have failed"
        return 1
    fi
    
    return 0
}

# Main execution
main() {
    print_header
    
    # Check dependencies
    if ! command -v gcc >/dev/null 2>&1 && ! command -v clang >/dev/null 2>&1; then
        print_error "No C compiler found (gcc or clang required)"
        exit 1
    fi
    
    if ! command -v ld >/dev/null 2>&1; then
        print_error "Linker (ld) not found"
        exit 1
    fi
    
    if ! command -v objcopy >/dev/null 2>&1; then
        print_error "objcopy not found"
        exit 1
    fi
    
    # Build process
    clean_build
    create_directories
    build_graphics_kernel
    
    if verify_build; then
        echo
        print_success "Build completed successfully!"
        echo
        print_info "Next steps:"
        echo "  1. Test with: ./run-i386-graphics.sh"
        echo "  2. Or use: qemu-system-i386 -kernel $OUTPUT_DIR/$BUILD_ID.elf -m 128M -display cocoa"
        echo
    else
        print_error "Build verification failed!"
        exit 1
    fi
}

# Run main function
main "$@"