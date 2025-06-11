#!/bin/bash

# SAGE-OS Unified QEMU Testing Script
# ===================================
# 
# This script provides a simple, unified way to test SAGE-OS builds
# across all supported architectures in QEMU.
#
# Usage:
#   ./scripts/test-qemu.sh <architecture> [target]
#
# Examples:
#   ./scripts/test-qemu.sh i386
#   ./scripts/test-qemu.sh aarch64
#   ./scripts/test-qemu.sh aarch64 rpi5
#
# Author: Ashish Vasant Yesale
# Email: ashishyesale007@gmail.com

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    cat << EOF
SAGE-OS QEMU Testing Script

Usage: $0 <architecture> [target] [mode]

Supported Architectures:
  i386     - 32-bit x86 (fully working)
  aarch64  - 64-bit ARM (fully working)
  x86_64   - 64-bit x86 (partial support)
  riscv64  - 64-bit RISC-V (builds, boots with OpenSBI)

Supported Targets:
  generic  - Generic target (default)
  rpi4     - Raspberry Pi 4
  rpi5     - Raspberry Pi 5

Supported Modes:
  nographic - Serial console only (default)
  graphics  - VGA graphics mode with keyboard input (i386/x86_64 only)

Examples:
  $0 i386                           # Test i386 in serial mode
  $0 i386 generic graphics          # Test i386 in graphics mode
  $0 aarch64                        # Test aarch64 generic build
  $0 aarch64 rpi5                   # Test aarch64 Raspberry Pi 5 build

The script will:
1. Check if the kernel image exists
2. Build it if necessary
3. Launch QEMU with appropriate settings
4. Show boot output and interactive shell

Press Ctrl+A then X to exit QEMU.

EOF
}

# Function to get kernel image path
get_kernel_path() {
    local arch="$1"
    local target="${2:-generic}"
    local mode="${3:-nographic}"
    local version
    version=$(cat "$PROJECT_ROOT/VERSION" 2>/dev/null || echo "1.0.1")
    
    if [[ "$mode" == "graphics" ]]; then
        echo "$PROJECT_ROOT/output/$arch/sage-os-v${version}-${arch}-${target}-graphics.img"
    else
        echo "$PROJECT_ROOT/output/$arch/sage-os-v${version}-${arch}-${target}.img"
    fi
}

# Function to test architecture in QEMU
test_qemu() {
    local arch="$1"
    local target="${2:-generic}"
    local mode="${3:-nographic}"
    local kernel_path
    kernel_path=$(get_kernel_path "$arch" "$target" "$mode")
    
    print_info "Testing SAGE-OS for $arch architecture (target: $target, mode: $mode)"
    
    # Check if kernel exists, build if not
    if [[ ! -f "$kernel_path" ]]; then
        print_warning "Kernel image not found: $kernel_path"
        cd "$PROJECT_ROOT"
        
        if [[ "$mode" == "graphics" ]]; then
            print_info "Building graphics kernel for $arch..."
            ./scripts/build-graphics.sh "$arch" "$target"
        else
            print_info "Building kernel for $arch..."
            make ARCH="$arch" TARGET="$target"
        fi
        
        if [[ ! -f "$kernel_path" ]]; then
            print_error "Build failed or kernel image not created"
            return 1
        fi
    fi
    
    print_success "Found kernel image: $kernel_path"
    print_info "Starting QEMU for $arch in $mode mode..."
    
    if [[ "$mode" == "graphics" ]]; then
        if [[ "$arch" != "i386" && "$arch" != "x86_64" ]]; then
            print_warning "Graphics mode only supported on i386/x86_64, falling back to nographic"
            mode="nographic"
        else
            print_warning "Graphics mode: Use keyboard for input, close QEMU window to exit"
        fi
    else
        print_warning "Serial mode: Press Ctrl+A then X to exit QEMU"
    fi
    echo ""
    
    # Launch QEMU based on architecture and mode
    local qemu_args=""
    if [[ "$mode" == "graphics" ]]; then
        # Use VNC for headless graphics mode
        qemu_args="-no-reboot -vnc :1"
        print_info "VNC server will be available on localhost:5901"
        print_info "Connect with: vncviewer localhost:5901"
    else
        qemu_args="-nographic -no-reboot"
    fi
    
    case "$arch" in
        "i386")
            print_info "Launching i386 QEMU..."
            qemu-system-i386 \
                -kernel "$kernel_path" \
                $qemu_args
            ;;
        "aarch64")
            print_info "Launching AArch64 QEMU (ARM64)..."
            qemu-system-aarch64 \
                -M virt \
                -cpu cortex-a72 \
                -kernel "$kernel_path" \
                $qemu_args
            ;;
        "x86_64")
            print_info "Launching x86_64 QEMU..."
            print_warning "Note: x86_64 support is partial - GRUB boots but kernel may need debugging"
            qemu-system-x86_64 \
                -kernel "$kernel_path" \
                $qemu_args
            ;;
        "riscv64")
            print_info "Launching RISC-V 64-bit QEMU..."
            print_warning "Note: RISC-V builds and OpenSBI loads, but kernel may hang"
            qemu-system-riscv64 \
                -M virt \
                -kernel "$kernel_path" \
                $qemu_args
            ;;
        *)
            print_error "Unsupported architecture: $arch"
            print_info "Supported architectures: i386, aarch64, x86_64, riscv64"
            return 1
            ;;
    esac
    
    print_success "QEMU session ended"
}

# Main script logic
main() {
    local arch="${1:-}"
    local target="${2:-generic}"
    local mode="${3:-nographic}"
    
    if [[ -z "$arch" ]]; then
        print_error "Architecture not specified"
        show_usage
        exit 1
    fi
    
    case "$arch" in
        "help"|"-h"|"--help")
            show_usage
            exit 0
            ;;
        "i386"|"aarch64"|"x86_64"|"riscv64")
            test_qemu "$arch" "$target" "$mode"
            ;;
        *)
            print_error "Unknown architecture: $arch"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"