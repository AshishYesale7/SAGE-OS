#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS Smart Graphics Builder
# Automatically detects architecture and builds the correct graphics kernel
# Ensures QEMU binary matches kernel architecture

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[1;36m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}🎨 SAGE OS Smart Graphics Builder${NC}"
    echo "===================================="
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

# Detect best architecture for current platform
detect_best_arch() {
    local host_arch
    host_arch=$(uname -m)
    
    case $host_arch in
        x86_64)
            echo "i386"  # Use i386 for better compatibility and faster emulation
            ;;
        arm64|aarch64)
            echo "i386"  # Use i386 on Apple Silicon for x86 emulation
            ;;
        i386|i686)
            echo "i386"
            ;;
        *)
            echo "i386"  # Default to i386 for maximum compatibility
            ;;
    esac
}

# Check QEMU availability for architecture
check_qemu_support() {
    local arch="$1"
    local qemu_bin
    
    case $arch in
        i386)
            qemu_bin="qemu-system-i386"
            ;;
        x86_64)
            qemu_bin="qemu-system-x86_64"
            ;;
        aarch64)
            qemu_bin="qemu-system-aarch64"
            ;;
        arm)
            qemu_bin="qemu-system-arm"
            ;;
        riscv64)
            qemu_bin="qemu-system-riscv64"
            ;;
        *)
            print_error "Unknown architecture: $arch"
            return 1
            ;;
    esac
    
    if command -v "$qemu_bin" >/dev/null 2>&1; then
        print_success "QEMU support found: $qemu_bin"
        return 0
    else
        print_warning "QEMU not found: $qemu_bin"
        return 1
    fi
}

# Build graphics kernel for specific architecture
build_graphics_kernel() {
    local arch="$1"
    
    print_info "Building graphics kernel for $arch architecture..."
    
    # Clean previous builds
    print_info "Cleaning previous builds..."
    make clean >/dev/null 2>&1 || true
    
    # Build with graphics support
    print_info "Compiling kernel with graphics support..."
    
    # Use the graphics-specific build process
    if [[ -f "build-graphics.sh" ]]; then
        ./build-graphics.sh "$arch" build
    else
        # Fallback to Makefile
        make ARCH="$arch" TARGET=generic
    fi
    
    # Verify the build
    local kernel_path
    case $arch in
        i386)
            kernel_path="output/i386/sage-os-v1.0.1-i386-generic-graphics.elf"
            ;;
        x86_64)
            kernel_path="output/x86_64/sage-os-v1.0.1-x86_64-generic-graphics.elf"
            ;;
        aarch64)
            kernel_path="output/aarch64/sage-os-v1.0.1-aarch64-generic-graphics.elf"
            ;;
        arm)
            kernel_path="output/arm/sage-os-v1.0.1-arm-generic-graphics.elf"
            ;;
        riscv64)
            kernel_path="output/riscv64/sage-os-v1.0.1-riscv64-generic-graphics.elf"
            ;;
    esac
    
    if [[ -f "$kernel_path" ]]; then
        print_success "Graphics kernel built successfully!"
        print_info "Kernel path: $kernel_path"
        
        # Verify architecture
        if command -v file >/dev/null 2>&1; then
            local kernel_info
            kernel_info=$(file "$kernel_path")
            print_info "Kernel info: $kernel_info"
        fi
        
        return 0
    else
        print_error "Graphics kernel build failed!"
        print_error "Expected: $kernel_path"
        return 1
    fi
}

# Show usage information
show_usage() {
    print_header
    echo
    echo "Usage: $0 [ARCHITECTURE]"
    echo
    echo "Architectures:"
    echo "  i386     - 32-bit x86 (recommended for macOS)"
    echo "  x86_64   - 64-bit x86"
    echo "  aarch64  - 64-bit ARM"
    echo "  arm      - 32-bit ARM"
    echo "  riscv64  - 64-bit RISC-V"
    echo "  auto     - Auto-detect best architecture (default)"
    echo
    echo "Examples:"
    echo "  $0           # Auto-detect and build"
    echo "  $0 i386      # Build for 32-bit x86"
    echo "  $0 x86_64    # Build for 64-bit x86"
    echo
    echo "After building, use:"
    echo "  ./run-cocoa-macos.sh [ARCH]    # Native macOS window"
    echo "  ./run-vnc-macos.sh [ARCH]      # VNC mode"
}

# Main execution
main() {
    local arch="${1:-auto}"
    
    print_header
    
    # Handle help
    if [[ "$arch" == "-h" || "$arch" == "--help" ]]; then
        show_usage
        exit 0
    fi
    
    # Auto-detect architecture if requested
    if [[ "$arch" == "auto" ]]; then
        arch=$(detect_best_arch)
        print_info "Auto-detected architecture: $arch"
    fi
    
    # Validate architecture
    case $arch in
        i386|x86_64|aarch64|arm|riscv64)
            print_info "Target architecture: $arch"
            ;;
        *)
            print_error "Invalid architecture: $arch"
            show_usage
            exit 1
            ;;
    esac
    
    # Check QEMU support
    if ! check_qemu_support "$arch"; then
        print_warning "QEMU not available for $arch"
        print_info "Install QEMU with: brew install qemu"
        
        # Suggest alternative
        if [[ "$arch" != "i386" ]]; then
            print_info "Falling back to i386 (better compatibility)..."
            arch="i386"
            if ! check_qemu_support "$arch"; then
                print_error "No QEMU support available"
                exit 1
            fi
        else
            exit 1
        fi
    fi
    
    # Build the graphics kernel
    if build_graphics_kernel "$arch"; then
        echo
        print_success "Build completed successfully!"
        echo
        print_info "Next steps:"
        echo "  1. Test with native window: ./run-cocoa-macos.sh $arch"
        echo "  2. Test with VNC: ./run-vnc-macos.sh $arch"
        echo "  3. Interactive launcher: ./quick-graphics-macos.sh"
        echo
    else
        print_error "Build failed!"
        exit 1
    fi
}

# Run main function
main "$@"