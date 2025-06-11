#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS Local Deployment Script (No Docker Required)
# ─────────────────────────────────────────────────────────────────────────────

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SAGE_OS_DIR="$SCRIPT_DIR"

# Default values
ARCH="i386"
MODE="graphics"
MEMORY="128M"
VNC_PORT="5901"
QEMU_MONITOR_PORT="1234"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Help function
show_help() {
    cat << EOF
SAGE OS Local Deployment Script (No Docker Required)

Usage: $0 [OPTIONS] [COMMAND]

Commands:
    run         Run SAGE OS directly with QEMU
    test        Test QEMU installation and kernel files
    clean       Clean up temporary files
    help        Show this help message

Options:
    -a, --arch ARCH         Target architecture (i386, x86_64, aarch64, arm, riscv64) [default: i386]
    -m, --mode MODE         Display mode (graphics, text, vnc) [default: graphics]
    -M, --memory MEMORY     Memory allocation [default: 128M]
    -k, --kernel PATH       Path to kernel file (auto-detected if not specified)
    -v, --verbose           Enable verbose output
    -h, --help              Show this help message

Examples:
    $0 run                              # Run with default settings
    $0 run -a i386 -m graphics          # Run i386 with graphics mode
    $0 run -m text                      # Run in text mode
    $0 test                             # Test setup
    $0 run -k output/i386/kernel.elf    # Run with specific kernel

EOF
}

# Check dependencies
check_dependencies() {
    log_info "Checking dependencies..."
    
    # Check if QEMU is installed
    if ! command -v qemu-system-i386 &> /dev/null; then
        log_error "QEMU is not installed. Please install QEMU first."
        log_info "On macOS: brew install qemu"
        log_info "On Ubuntu: sudo apt-get install qemu-system"
        return 1
    fi
    
    log_success "QEMU is available"
    return 0
}

# Find kernel file
find_kernel() {
    local arch="$1"
    local kernel_file=""
    
    log_info "Looking for kernel file for architecture: $arch"
    
    # Check various possible locations
    if [[ -f "output/$arch/sage-os-v"*".elf" ]]; then
        kernel_file=$(ls output/$arch/sage-os-v*.elf | head -1)
    elif [[ -f "build/$arch/kernel.elf" ]]; then
        kernel_file="build/$arch/kernel.elf"
    elif [[ -f "build/$arch/kernel.img" ]]; then
        kernel_file="build/$arch/kernel.img"
    elif [[ -f "output/$arch-graphics/kernel.elf" ]]; then
        kernel_file="output/$arch-graphics/kernel.elf"
    elif [[ -f "build/$arch-graphics/kernel.elf" ]]; then
        kernel_file="build/$arch-graphics/kernel.elf"
    else
        log_error "No kernel file found for architecture $arch"
        log_info "Available files:"
        find . -name "*.elf" -o -name "*.img" 2>/dev/null | head -10
        return 1
    fi
    
    if [[ ! -f "$kernel_file" ]]; then
        log_error "Kernel file not found: $kernel_file"
        return 1
    fi
    
    log_success "Found kernel file: $kernel_file"
    echo "$kernel_file"
    return 0
}

# Run SAGE OS
run_sage_os() {
    local arch="$1"
    local mode="$2"
    local memory="$3"
    local kernel_file="$4"
    
    log_info "Starting SAGE OS..."
    log_info "  Architecture: $arch"
    log_info "  Mode: $mode"
    log_info "  Memory: $memory"
    log_info "  Kernel: $kernel_file"
    
    # QEMU command based on architecture
    local qemu_cmd=""
    local qemu_args=""
    
    case "$arch" in
        "i386"|"x86_64")
            qemu_cmd="qemu-system-i386"
            qemu_args="-kernel $kernel_file -m $memory"
            ;;
        "aarch64")
            qemu_cmd="qemu-system-aarch64"
            qemu_args="-M virt -cpu cortex-a57 -kernel $kernel_file -m $memory"
            ;;
        "arm")
            qemu_cmd="qemu-system-arm"
            qemu_args="-M versatilepb -kernel $kernel_file -m $memory"
            ;;
        "riscv64")
            qemu_cmd="qemu-system-riscv64"
            qemu_args="-M virt -kernel $kernel_file -m $memory"
            ;;
        *)
            log_error "Unsupported architecture: $arch"
            return 1
            ;;
    esac
    
    # Display mode configuration
    local display_args=""
    case "$mode" in
        "graphics")
            display_args="-vga std"
            log_info "Graphics mode: QEMU window will open"
            ;;
        "text")
            display_args="-nographic"
            log_info "Text mode: Running in terminal"
            ;;
        "vnc")
            display_args="-vga std -vnc :1"
            log_info "VNC mode: Connect to localhost:5901"
            ;;
        *)
            display_args="-vga std"
            ;;
    esac
    
    # Additional QEMU arguments for better compatibility
    local extra_args="-no-reboot -boot n"
    
    # Add monitor for debugging (only in text mode)
    if [[ "$mode" == "text" ]]; then
        extra_args="$extra_args -monitor telnet:127.0.0.1:$QEMU_MONITOR_PORT,server,nowait"
        log_info "QEMU monitor available at: telnet localhost $QEMU_MONITOR_PORT"
    fi
    
    # Final command
    local full_cmd="$qemu_cmd $qemu_args $display_args $extra_args"
    
    log_info "Executing: $full_cmd"
    echo
    log_success "Starting SAGE OS..."
    
    # Execute QEMU
    exec $full_cmd
}

# Test setup
test_setup() {
    log_info "Testing SAGE OS setup..."
    
    if ! check_dependencies; then
        return 1
    fi
    
    # Test kernel file detection for each architecture
    local archs=("i386" "x86_64" "aarch64" "arm" "riscv64")
    local found_kernels=0
    
    for arch in "${archs[@]}"; do
        log_info "Testing $arch..."
        if kernel_file=$(find_kernel "$arch" 2>/dev/null); then
            log_success "  $arch: $kernel_file"
            ((found_kernels++))
        else
            log_warning "  $arch: No kernel found"
        fi
    done
    
    if [[ $found_kernels -eq 0 ]]; then
        log_error "No kernel files found for any architecture"
        log_info "Please build SAGE OS first using: make ARCH=i386"
        return 1
    fi
    
    log_success "Setup test completed. Found $found_kernels kernel(s)."
    return 0
}

# Clean up
cleanup() {
    log_info "Cleaning up temporary files..."
    # Remove any temporary files if created
    log_success "Cleanup completed"
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -a|--arch)
                ARCH="$2"
                shift 2
                ;;
            -m|--mode)
                MODE="$2"
                shift 2
                ;;
            -M|--memory)
                MEMORY="$2"
                shift 2
                ;;
            -k|--kernel)
                KERNEL_FILE="$2"
                shift 2
                ;;
            -v|--verbose)
                set -x
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            run|test|clean|help)
                COMMAND="$1"
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Main execution
main() {
    # Set default command if none provided
    COMMAND="${COMMAND:-run}"
    
    log_info "SAGE OS Local Deployment Script"
    log_info "==============================="
    
    case "$COMMAND" in
        "run")
            if ! check_dependencies; then
                exit 1
            fi
            
            # Find kernel file if not specified
            if [[ -z "$KERNEL_FILE" ]]; then
                if ! KERNEL_FILE=$(find_kernel "$ARCH"); then
                    exit 1
                fi
            fi
            
            run_sage_os "$ARCH" "$MODE" "$MEMORY" "$KERNEL_FILE"
            ;;
        "test")
            test_setup
            ;;
        "clean")
            cleanup
            ;;
        "help")
            show_help
            ;;
        *)
            log_error "Unknown command: $COMMAND"
            show_help
            exit 1
            ;;
    esac
}

# Parse arguments and run main function
parse_args "$@"
main

# Show usage tips
if [[ "$COMMAND" == "run" ]]; then
    echo
    log_info "SAGE OS Tips:"
    case "$MODE" in
        "graphics")
            log_info "  - QEMU window should open with SAGE OS"
            log_info "  - Use mouse and keyboard to interact"
            log_info "  - Close window or Ctrl+Alt+Q to quit"
            ;;
        "text")
            log_info "  - Running in text mode"
            log_info "  - Use Ctrl+A, X to quit QEMU"
            log_info "  - Monitor: telnet localhost $QEMU_MONITOR_PORT"
            ;;
        "vnc")
            log_info "  - Connect VNC client to localhost:5901"
            log_info "  - Use any VNC viewer to access SAGE OS"
            ;;
    esac
    echo
fi