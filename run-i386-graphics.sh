#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS i386 Graphics Runner for macOS
# Specifically designed to run 32-bit SAGE OS with proper QEMU settings

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[1;36m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}🚀 SAGE OS i386 Graphics Runner${NC}"
    echo "=================================="
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
VERSION="1.0.1"
BUILD_ID="sage-os-v${VERSION}-${ARCH}-generic-graphics"
KERNEL_ELF="output/${ARCH}/${BUILD_ID}.elf"
KERNEL_IMG="output/${ARCH}/${BUILD_ID}.img"
QEMU_BIN="qemu-system-i386"

# Check if kernel exists
check_kernel() {
    if [[ ! -f "$KERNEL_ELF" ]]; then
        print_error "Kernel ELF not found: $KERNEL_ELF"
        print_info "Building i386 graphics kernel..."
        ./build-i386-graphics.sh
        
        if [[ ! -f "$KERNEL_ELF" ]]; then
            print_error "Failed to build kernel"
            exit 1
        fi
    fi
    
    # Verify it's actually i386
    if command -v file >/dev/null 2>&1; then
        local file_info
        file_info=$(file "$KERNEL_ELF")
        
        if [[ "$file_info" =~ "80386" ]] || [[ "$file_info" =~ "i386" ]]; then
            print_success "Kernel verified: 32-bit x86 (i386)"
        else
            print_error "Wrong architecture: $file_info"
            print_error "Expected: 32-bit x86 (i386)"
            exit 1
        fi
    fi
}

# Check QEMU
check_qemu() {
    if ! command -v "$QEMU_BIN" >/dev/null 2>&1; then
        print_error "QEMU not found: $QEMU_BIN"
        print_info "Install with: brew install qemu"
        exit 1
    fi
    
    local qemu_version
    qemu_version=$($QEMU_BIN --version | head -n1)
    print_success "Found QEMU: $qemu_version"
}

# Display launch info
display_launch_info() {
    echo
    print_info "🖥️  Kernel: $KERNEL_ELF"
    print_info "🏗️  Architecture: $ARCH (32-bit x86)"
    print_info "🎮 QEMU Binary: $QEMU_BIN"
    echo
    echo -e "${YELLOW}🎮 Controls:${NC}"
    echo "  • Mouse: Click to focus, move normally"
    echo "  • Keyboard: Type commands in SAGE OS shell"
    echo "  • Escape: Release mouse capture"
    echo "  • Cmd+Q or close window: Exit QEMU"
    echo
    echo -e "${YELLOW}💡 Expected Boot Sequence:${NC}"
    echo "  1. QEMU loads kernel directly (no BIOS)"
    echo "  2. SAGE OS boot loader starts"
    echo "  3. Kernel initializes graphics mode"
    echo "  4. Interactive shell appears"
    echo
    echo -e "${CYAN}🛑 Press Cmd+Q or close the window to exit${NC}"
    echo
}

# Launch QEMU with proper settings for direct kernel boot
launch_qemu() {
    print_info "Starting QEMU with direct kernel boot..."
    
    # Use -kernel to bypass BIOS and boot directly
    $QEMU_BIN \
        -kernel "$KERNEL_ELF" \
        -m 128M \
        -vga std \
        -display cocoa \
        -serial stdio \
        -no-reboot \
        -boot n \
        -name "SAGE OS v$VERSION ($ARCH)"
}

# Alternative launch with more debugging
launch_qemu_debug() {
    print_info "Starting QEMU with debug output..."
    
    $QEMU_BIN \
        -kernel "$KERNEL_ELF" \
        -m 128M \
        -vga std \
        -display cocoa \
        -serial stdio \
        -no-reboot \
        -boot n \
        -d guest_errors \
        -name "SAGE OS v$VERSION ($ARCH) [Debug]"
}

# VNC mode
launch_qemu_vnc() {
    local vnc_port=1
    
    print_info "Starting QEMU with VNC on port 590$vnc_port..."
    print_info "Connect with: open vnc://localhost:590$vnc_port"
    
    $QEMU_BIN \
        -kernel "$KERNEL_ELF" \
        -m 128M \
        -vga std \
        -vnc :$vnc_port,password=off \
        -serial stdio \
        -no-reboot \
        -boot n \
        -name "SAGE OS v$VERSION ($ARCH) [VNC]"
}

# Show menu
show_menu() {
    print_header
    echo
    echo -e "${YELLOW}Choose launch mode:${NC}"
    echo
    echo "1) Native macOS Window (Recommended)"
    echo "   • Best performance and compatibility"
    echo "   • Direct graphics output"
    echo
    echo "2) VNC Mode"
    echo "   • Remote desktop access"
    echo "   • Connect with VNC client"
    echo
    echo "3) Debug Mode"
    echo "   • Extra debugging output"
    echo "   • Useful for troubleshooting"
    echo
    echo "4) Build Kernel"
    echo "   • Rebuild i386 graphics kernel"
    echo
    echo "q) Quit"
    echo
}

# Handle menu choice
handle_choice() {
    local choice="$1"
    
    case $choice in
        1)
            display_launch_info
            launch_qemu
            ;;
        2)
            display_launch_info
            launch_qemu_vnc
            ;;
        3)
            display_launch_info
            launch_qemu_debug
            ;;
        4)
            print_info "Building i386 graphics kernel..."
            ./build-i386-graphics.sh
            ;;
        q|Q)
            print_info "Goodbye!"
            exit 0
            ;;
        *)
            print_error "Invalid choice: $choice"
            ;;
    esac
}

# Main execution
main() {
    # Check if we're on macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        print_error "This script is optimized for macOS"
        print_info "For other platforms, use standard QEMU commands"
    fi
    
    # Check dependencies
    check_qemu
    check_kernel
    
    # If run with argument, launch directly
    if [[ $# -gt 0 ]]; then
        case $1 in
            cocoa|native)
                display_launch_info
                launch_qemu
                ;;
            vnc)
                display_launch_info
                launch_qemu_vnc
                ;;
            debug)
                display_launch_info
                launch_qemu_debug
                ;;
            *)
                print_error "Unknown mode: $1"
                print_info "Available modes: cocoa, vnc, debug"
                exit 1
                ;;
        esac
        return
    fi
    
    # Interactive menu
    while true; do
        show_menu
        echo -n "Enter your choice [1-4, q]: "
        read -r choice
        echo
        handle_choice "$choice"
        
        if [[ "$choice" != "4" ]]; then
            break
        fi
    done
}

# Run main function
main "$@"