#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS Native Cocoa Runner for macOS
# Launches QEMU with native macOS window (no VNC required)
# Optimized for macOS M1/Intel development

set -e

# Configuration
ARCH="${1:-i386}"  # Default to i386, can be overridden

# Set QEMU binary and kernel path based on architecture
case $ARCH in
    i386)
        QEMU_BIN="qemu-system-i386"
        KERNEL_ELF="output/i386/sage-os-v1.0.1-i386-generic-graphics.elf"
        ;;
    x86_64)
        QEMU_BIN="qemu-system-x86_64"
        KERNEL_ELF="output/x86_64/sage-os-v1.0.1-x86_64-generic-graphics.elf"
        ;;
    aarch64|arm64)
        QEMU_BIN="qemu-system-aarch64"
        KERNEL_ELF="output/aarch64/sage-os-v1.0.1-aarch64-generic-graphics.elf"
        ;;
    arm)
        QEMU_BIN="qemu-system-arm"
        KERNEL_ELF="output/arm/sage-os-v1.0.1-arm-generic-graphics.elf"
        ;;
    riscv64)
        QEMU_BIN="qemu-system-riscv64"
        KERNEL_ELF="output/riscv64/sage-os-v1.0.1-riscv64-generic-graphics.elf"
        ;;
    *)
        print_error "Unsupported architecture: $ARCH"
        echo "Supported: i386, x86_64, aarch64, arm, riscv64"
        exit 1
        ;;
esac

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[1;36m'
NC='\033[0m'

# Functions
print_header() {
    echo -e "${BLUE}🚀 SAGE OS Native Cocoa Runner for macOS${NC}"
    echo "=========================================="
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

# Check if kernel exists and verify architecture
check_kernel() {
    if [[ ! -f "$KERNEL_ELF" ]]; then
        print_error "Kernel not found: $KERNEL_ELF"
        print_info "Please build the graphics kernel first:"
        echo "  ./build-graphics.sh $ARCH"
        echo "  OR"
        echo "  make ARCH=$ARCH TARGET=generic"
        exit 1
    fi
    
    # Verify kernel architecture matches QEMU binary
    if command -v file >/dev/null 2>&1; then
        local kernel_info
        kernel_info=$(file "$KERNEL_ELF")
        
        case $ARCH in
            i386)
                if [[ ! "$kernel_info" =~ "80386" ]] && [[ ! "$kernel_info" =~ "i386" ]]; then
                    print_error "Architecture mismatch!"
                    print_error "Kernel: $kernel_info"
                    print_error "Expected: 32-bit x86 (i386) for qemu-system-i386"
                    print_info "Rebuild with: ./build-graphics.sh i386"
                    exit 1
                fi
                ;;
            x86_64)
                if [[ ! "$kernel_info" =~ "x86-64" ]] && [[ ! "$kernel_info" =~ "x86_64" ]]; then
                    print_error "Architecture mismatch!"
                    print_error "Kernel: $kernel_info"
                    print_error "Expected: 64-bit x86 (x86_64) for qemu-system-x86_64"
                    print_info "Rebuild with: ./build-graphics.sh x86_64"
                    exit 1
                fi
                ;;
        esac
        
        print_success "Kernel architecture verified: $ARCH"
        print_info "Kernel file: $kernel_info"
    fi
}

# Check if we're on macOS
check_macos() {
    if [[ "$(uname)" != "Darwin" ]]; then
        print_error "This script requires macOS"
        print_info "For other platforms, use:"
        echo "  Linux: ./scripts/testing/test-qemu.sh $ARCH generic graphics"
        echo "  Windows: scripts\\windows\\launch-sage-os-graphics.bat"
        exit 1
    fi
}

# Check QEMU installation
check_qemu() {
    if ! command -v "$QEMU_BIN" >/dev/null 2>&1; then
        print_error "QEMU not found: $QEMU_BIN"
        print_info "Install QEMU using Homebrew:"
        echo "  brew install qemu"
        exit 1
    fi
    
    local qemu_version
    qemu_version=$($QEMU_BIN --version | head -n1)
    print_success "Found QEMU: $qemu_version"
}

# Display launch information
display_launch_info() {
    echo
    print_info "🖥️  Kernel: $KERNEL_ELF"
    print_info "🏗️  Architecture: $ARCH"
    print_info "🪟 Display: Native macOS Cocoa window"
    echo
    echo -e "${YELLOW}🎮 Controls:${NC}"
    echo "  • Mouse: Click to focus, move normally"
    echo "  • Keyboard: Type commands in SAGE OS shell"
    echo "  • Escape: Release mouse capture"
    echo "  • Cmd+Q or close window: Exit QEMU"
    echo
    echo -e "${YELLOW}💡 Features:${NC}"
    echo "  • Native macOS window (no VNC required)"
    echo "  • Full keyboard and mouse support"
    echo "  • VGA graphics with 80x25 text mode"
    echo "  • Interactive SAGE OS shell"
    echo
    echo -e "${CYAN}🛑 Press Cmd+Q or close the window to exit${NC}"
    echo
}

# Launch QEMU with Cocoa display
launch_qemu_cocoa() {
    print_info "Starting QEMU with native Cocoa display..."
    
    # Launch QEMU with Cocoa display
    $QEMU_BIN \
        -kernel "$KERNEL_ELF" \
        -m 128M \
        -vga std \
        -display cocoa \
        -serial stdio \
        -no-reboot \
        -name "SAGE OS v1.0.1 ($ARCH)"
}

# Main execution
main() {
    print_header
    
    # Verify environment
    check_macos
    check_kernel
    check_qemu
    
    # Display launch information
    display_launch_info
    
    # Launch QEMU
    launch_qemu_cocoa
}

# Help function
show_help() {
    print_header
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -k, --kernel   Specify kernel path (default: $KERNEL_ELF)"
    echo "  -a, --arch     Specify architecture (default: $ARCH)"
    echo
    echo "Examples:"
    echo "  $0                                    # Use defaults"
    echo "  $0 -k output/x86_64/kernel.elf       # Use different kernel"
    echo "  $0 -a x86_64                         # Use x86_64 architecture"
    echo
    echo "Features:"
    echo "  • Native macOS window (no VNC)"
    echo "  • Full keyboard and mouse support"
    echo "  • VGA graphics output"
    echo "  • Serial console in terminal"
    echo
    echo "Troubleshooting:"
    echo "  • If window doesn't appear, check QEMU installation"
    echo "  • For VNC mode, use: ./run-vnc-macos.sh"
    echo "  • To build graphics kernel: ./build.sh graphics"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -k|--kernel)
            KERNEL_ELF="$2"
            shift 2
            ;;
        -a|--arch)
            ARCH="$2"
            # Update QEMU binary based on architecture
            case $ARCH in
                i386)
                    QEMU_BIN="qemu-system-i386"
                    ;;
                x86_64)
                    QEMU_BIN="qemu-system-x86_64"
                    ;;
                aarch64|arm64)
                    QEMU_BIN="qemu-system-aarch64"
                    ;;
                arm)
                    QEMU_BIN="qemu-system-arm"
                    ;;
                riscv64)
                    QEMU_BIN="qemu-system-riscv64"
                    ;;
                *)
                    print_error "Unsupported architecture: $ARCH"
                    exit 1
                    ;;
            esac
            shift 2
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Run main function
main