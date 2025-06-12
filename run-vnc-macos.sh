#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS VNC Runner for macOS M1/Intel
# Automatically finds free VNC ports and handles macOS Screen Sharing conflicts
# Designed specifically for macOS development environment

set -e

# Configuration
ARCH="${1:-i386}"  # Default to i386, can be overridden
VNC_PASSWORD="sageos"

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
    echo -e "${BLUE}🚀 SAGE OS VNC Runner for macOS${NC}"
    echo "=================================="
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

# Find available VNC port (skip 5900 due to macOS Screen Sharing)
find_free_vnc_port() {
    # Start from port 5901 to avoid macOS Screen Sharing on 5900
    for i in {1..9}; do
        port=$((5900 + i))
        if ! lsof -i TCP:$port >/dev/null 2>&1; then
            echo $i
            return
        fi
    done
    print_error "No free VNC ports available (5901-5909)!"
    print_info "Try closing other VNC servers or QEMU instances"
    exit 1
}

# Check for third-party VNC clients
check_vnc_clients() {
    local clients=()
    
    # Check for common VNC clients
    if command -v /Applications/TigerVNC\ Viewer.app/Contents/MacOS/TigerVNC\ Viewer >/dev/null 2>&1; then
        clients+=("TigerVNC")
    fi
    
    if command -v /Applications/VNC\ Viewer.app/Contents/MacOS/vncviewer >/dev/null 2>&1; then
        clients+=("RealVNC")
    fi
    
    if [[ -d "/Applications/Remotix.app" ]]; then
        clients+=("Remotix")
    fi
    
    if [[ ${#clients[@]} -gt 0 ]]; then
        print_success "Found VNC clients: ${clients[*]}"
        return 0
    else
        print_warning "No third-party VNC clients found"
        print_info "macOS Screen Sharing may block local connections"
        print_info "Consider installing: TigerVNC, RealVNC Viewer, or Remotix"
        return 1
    fi
}

# Display connection information
display_connection_info() {
    local display_num=$1
    local port=$((5900 + display_num))
    
    echo
    print_info "🖥️  Kernel: $KERNEL_ELF"
    print_info "🔐 VNC Password: $VNC_PASSWORD"
    echo
    echo -e "${CYAN}📡 VNC Connection Information:${NC}"
    echo "  Host: localhost"
    echo "  Port: $port"
    echo "  Display: :$display_num"
    echo "  Password: $VNC_PASSWORD"
    echo
    echo -e "${YELLOW}🔗 Connection Methods:${NC}"
    echo "  1. Third-party VNC client (recommended):"
    echo "     - TigerVNC: localhost:$port"
    echo "     - RealVNC: localhost:$port"
    echo "     - Remotix: localhost:$port"
    echo
    echo "  2. macOS Screen Sharing (may not work for localhost):"
    echo "     open vnc://localhost:$port"
    echo
    echo -e "${YELLOW}💡 Tips for macOS:${NC}"
    echo "  • If Screen Sharing shows 'can't control your own screen',"
    echo "    use a third-party VNC client instead"
    echo "  • For native window without VNC, use: ./run-cocoa-macos.sh"
    echo "  • Port 5900 is skipped (used by macOS Screen Sharing)"
    echo
    echo -e "${CYAN}🛑 Press Ctrl+C to exit QEMU${NC}"
    echo
}

# Launch QEMU with VNC
launch_qemu_vnc() {
    local display_num=$1
    
    print_info "Starting QEMU with VNC on display :$display_num..."
    
    # Create temporary script for password setting
    local temp_script=$(mktemp)
    cat > "$temp_script" << EOF
change vnc password
$VNC_PASSWORD
EOF
    
    # Launch QEMU with VNC
    $QEMU_BIN \
        -kernel "$KERNEL_ELF" \
        -m 128M \
        -vga std \
        -vnc 127.0.0.1:$display_num,password=on \
        -monitor stdio \
        -no-reboot < "$temp_script"
    
    # Cleanup
    rm -f "$temp_script"
}

# Main execution
main() {
    print_header
    
    # Check if we're on macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        print_warning "This script is optimized for macOS"
        print_info "For other platforms, use: ./scripts/testing/test-qemu.sh"
    fi
    
    # Verify kernel exists
    check_kernel
    
    # Find free VNC port
    DISPLAY_NUM=$(find_free_vnc_port)
    
    # Check for VNC clients
    check_vnc_clients
    
    # Display connection information
    display_connection_info $DISPLAY_NUM
    
    # Launch QEMU
    launch_qemu_vnc $DISPLAY_NUM
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
    echo "  -p, --password Specify VNC password (default: $VNC_PASSWORD)"
    echo
    echo "Examples:"
    echo "  $0                                    # Use defaults"
    echo "  $0 -k output/x86_64/kernel.elf       # Use different kernel"
    echo "  $0 -p mypassword                     # Use custom password"
    echo
    echo "Troubleshooting:"
    echo "  • If VNC connection fails, try a third-party VNC client"
    echo "  • For native macOS window, use: ./run-cocoa-macos.sh"
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
        -p|--password)
            VNC_PASSWORD="$2"
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