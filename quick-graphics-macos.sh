#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS Quick Graphics Launcher for macOS
# Interactive menu to choose between VNC and Cocoa display modes

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[1;36m'
NC='\033[0m'

print_header() {
    clear
    echo -e "${BLUE}🚀 SAGE OS Graphics Launcher for macOS${NC}"
    echo "========================================"
    echo
    echo -e "${CYAN}Choose your preferred graphics mode:${NC}"
    echo
}

print_option() {
    echo -e "${YELLOW}$1${NC} $2"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if graphics kernel exists for any architecture
check_graphics_kernel() {
    local found_kernels=()
    local architectures=("i386" "x86_64" "aarch64" "arm" "riscv64")
    
    # Check for existing graphics kernels
    for arch in "${architectures[@]}"; do
        local kernel="output/$arch/sage-os-v1.0.1-$arch-generic-graphics.elf"
        if [[ -f "$kernel" ]]; then
            found_kernels+=("$arch:$kernel")
        fi
    done
    
    if [[ ${#found_kernels[@]} -eq 0 ]]; then
        print_error "No graphics kernels found!"
        print_info "Building graphics kernel now..."
        echo
        ./build-graphics-smart.sh auto
        echo
        # Re-check after build
        for arch in "${architectures[@]}"; do
            local kernel="output/$arch/sage-os-v1.0.1-$arch-generic-graphics.elf"
            if [[ -f "$kernel" ]]; then
                found_kernels+=("$arch:$kernel")
                break
            fi
        done
        
        if [[ ${#found_kernels[@]} -eq 0 ]]; then
            print_error "Failed to build graphics kernel"
            exit 1
        fi
    fi
    
    # Show found kernels
    print_success "Found graphics kernels:"
    for kernel_info in "${found_kernels[@]}"; do
        local arch="${kernel_info%%:*}"
        local path="${kernel_info##*:}"
        echo "  • $arch: $path"
    done
    
    # Set default architecture to first found kernel
    DEFAULT_ARCH="${found_kernels[0]%%:*}"
    print_info "Default architecture: $DEFAULT_ARCH"
}

# Main menu
show_menu() {
    print_header
    
    print_option "1)" "Native macOS Window (Cocoa) - Recommended"
    echo "   • Fast native performance"
    echo "   • Full keyboard/mouse support"
    echo "   • No VNC setup required"
    echo
    
    print_option "2)" "VNC Mode (Remote Desktop)"
    echo "   • Connect with VNC client"
    echo "   • Good for remote access"
    echo "   • Requires VNC viewer"
    echo
    
    print_option "3)" "Build Graphics Kernel"
    echo "   • Rebuild graphics kernel"
    echo "   • Clean build process"
    echo
    
    print_option "4)" "Help & Troubleshooting"
    echo "   • View troubleshooting guide"
    echo "   • Common issues and solutions"
    echo
    
    print_option "q)" "Quit"
    echo
}

# Handle user choice
handle_choice() {
    local choice="$1"
    
    case $choice in
        1)
            print_info "Launching SAGE OS with native macOS window..."
            echo
            ./run-cocoa-macos.sh "${DEFAULT_ARCH:-i386}"
            ;;
        2)
            print_info "Launching SAGE OS with VNC..."
            echo
            ./run-vnc-macos.sh "${DEFAULT_ARCH:-i386}"
            ;;
        3)
            print_info "Building graphics kernel..."
            echo
            ./build-graphics-smart.sh auto
            echo
            print_success "Graphics kernel build completed!"
            echo
            read -p "Press Enter to return to menu..."
            ;;
        4)
            print_info "Opening troubleshooting guide..."
            echo
            if command -v open >/dev/null 2>&1; then
                open docs/platforms/macos/GRAPHICS_TROUBLESHOOTING_M1.md
            else
                cat docs/platforms/macos/GRAPHICS_TROUBLESHOOTING_M1.md | less
            fi
            echo
            read -p "Press Enter to return to menu..."
            ;;
        q|Q)
            print_info "Goodbye!"
            exit 0
            ;;
        *)
            print_error "Invalid choice: $choice"
            echo
            read -p "Press Enter to continue..."
            ;;
    esac
}

# Main execution
main() {
    # Check if we're on macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        print_error "This script is designed for macOS"
        print_info "For other platforms, use:"
        echo "  Linux: ./scripts/testing/test-qemu.sh i386 generic graphics"
        echo "  Windows: scripts\\windows\\launch-sage-os-graphics.bat"
        exit 1
    fi
    
    # Check for graphics kernel
    check_graphics_kernel
    
    # Main menu loop
    while true; do
        show_menu
        echo -n "Enter your choice [1-4, q]: "
        read -r choice
        echo
        handle_choice "$choice"
    done
}

# Run main function
main