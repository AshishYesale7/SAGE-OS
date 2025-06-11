#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS QEMU Testing Script with tmux Session Management
# Prevents terminal lockups and provides safe testing environment

set -e

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PROJECT_NAME="SAGE-OS"
VERSION="0.1.0"
BUILD_DATE=$(date +%Y%m%d-%H%M%S)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
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

log_header() {
    echo -e "${PURPLE}=== $1 ===${NC}"
}

# Default values
ARCH="aarch64"
PLATFORM="rpi4"
TIMEOUT=60
GRAPHICS=0
DEBUG=0
AUTO_EXIT=1

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--arch)
            ARCH="$2"
            shift 2
            ;;
        -p|--platform)
            PLATFORM="$2"
            shift 2
            ;;
        -t|--timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        -g|--graphics)
            GRAPHICS=1
            shift
            ;;
        -d|--debug)
            DEBUG=1
            shift
            ;;
        --no-auto-exit)
            AUTO_EXIT=0
            shift
            ;;
        -h|--help)
            cat << EOF
SAGE OS QEMU Testing Script with tmux Session Management

Usage: $0 [options]

Options:
  -a, --arch ARCH         Architecture to test (aarch64, x86_64, arm, riscv64, i386)
  -p, --platform PLATFORM Platform to test (rpi3, rpi4, rpi5, generic, virt)
  -t, --timeout SECONDS   Test timeout in seconds (default: 60)
  -g, --graphics          Enable graphics mode
  -d, --debug             Enable debug mode
  --no-auto-exit          Don't automatically exit after timeout
  -h, --help              Show this help message

Examples:
  $0                                    # Test aarch64 on rpi4 with default settings
  $0 -a x86_64 -p generic -t 120      # Test x86_64 for 2 minutes
  $0 -a aarch64 -p rpi5 -g             # Test aarch64 on rpi5 with graphics
  $0 -d --no-auto-exit                 # Debug mode without auto-exit

EOF
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Validate architecture
validate_arch() {
    local arch=$1
    local valid_archs=("aarch64" "x86_64" "riscv64" "arm" "i386")
    
    for valid_arch in "${valid_archs[@]}"; do
        if [[ "$arch" == "$valid_arch" ]]; then
            return 0
        fi
    done
    
    log_error "Invalid architecture: $arch"
    log_info "Valid architectures: ${valid_archs[*]}"
    return 1
}

# Validate platform
validate_platform() {
    local platform=$1
    local valid_platforms=("rpi3" "rpi4" "rpi5" "x86_64" "generic" "virt")
    
    for valid_platform in "${valid_platforms[@]}"; do
        if [[ "$platform" == "$valid_platform" ]]; then
            return 0
        fi
    done
    
    log_error "Invalid platform: $platform"
    log_info "Valid platforms: ${valid_platforms[*]}"
    return 1
}

# Check if tmux is available
check_tmux() {
    if ! command -v tmux >/dev/null 2>&1; then
        log_error "tmux is not installed. Please install tmux first:"
        echo "  Ubuntu/Debian: sudo apt-get install tmux"
        echo "  macOS: brew install tmux"
        echo "  CentOS/RHEL: sudo yum install tmux"
        exit 1
    fi
}

# Find kernel image
find_kernel_image() {
    local arch=$1
    local platform=$2
    
    # Look for versioned kernel in build-output
    local versioned_kernel="$PROJECT_ROOT/build-output/$PROJECT_NAME-$VERSION-*-$arch-$platform.img"
    local found_versioned=$(ls $versioned_kernel 2>/dev/null | head -1)
    
    if [[ -n "$found_versioned" ]]; then
        echo "$found_versioned"
        return 0
    fi
    
    # Look for standard kernel in build-output
    local standard_kernel="$PROJECT_ROOT/build-output/kernel-$arch-$platform.img"
    if [[ -f "$standard_kernel" ]]; then
        echo "$standard_kernel"
        return 0
    fi
    
    # Look for kernel in build directory
    local build_kernel="$PROJECT_ROOT/build/$arch/kernel.img"
    if [[ -f "$build_kernel" ]]; then
        echo "$build_kernel"
        return 0
    fi
    
    return 1
}

# Get QEMU command for architecture
get_qemu_command() {
    local arch=$1
    local platform=$2
    local kernel_path=$3
    
    case $arch in
        aarch64)
            echo "qemu-system-aarch64"
            ;;
        x86_64)
            echo "qemu-system-x86_64"
            ;;
        arm)
            echo "qemu-system-arm"
            ;;
        riscv64)
            echo "qemu-system-riscv64"
            ;;
        i386)
            echo "qemu-system-i386"
            ;;
        *)
            log_error "Unsupported architecture for QEMU: $arch"
            return 1
            ;;
    esac
}

# Get QEMU machine type
get_qemu_machine() {
    local arch=$1
    local platform=$2
    
    case $arch in
        aarch64)
            case $platform in
                rpi3|rpi4|rpi5)
                    echo "raspi3"
                    ;;
                virt|generic)
                    echo "virt"
                    ;;
                *)
                    echo "virt"
                    ;;
            esac
            ;;
        x86_64|i386)
            echo "pc"
            ;;
        arm)
            case $platform in
                rpi3|rpi4|rpi5)
                    echo "raspi2"
                    ;;
                *)
                    echo "virt"
                    ;;
            esac
            ;;
        riscv64)
            echo "virt"
            ;;
        *)
            echo "virt"
            ;;
    esac
}

# Build QEMU command line
build_qemu_cmdline() {
    local arch=$1
    local platform=$2
    local kernel_path=$3
    
    local qemu_cmd=$(get_qemu_command "$arch" "$platform" "$kernel_path")
    local machine=$(get_qemu_machine "$arch" "$platform")
    
    local cmdline="$qemu_cmd -M $machine"
    
    # Add kernel
    cmdline="$cmdline -kernel $kernel_path"
    
    # Add CPU for specific architectures
    case $arch in
        aarch64)
            if [[ "$machine" == "virt" ]]; then
                cmdline="$cmdline -cpu cortex-a72"
            fi
            ;;
        arm)
            if [[ "$machine" == "virt" ]]; then
                cmdline="$cmdline -cpu cortex-a15"
            fi
            ;;
        riscv64)
            cmdline="$cmdline -cpu rv64"
            ;;
    esac
    
    # Add memory
    cmdline="$cmdline -m 1024"
    
    # Add serial and graphics options
    if [[ $GRAPHICS -eq 1 ]]; then
        cmdline="$cmdline -serial mon:stdio"
    else
        cmdline="$cmdline -nographic -serial mon:stdio"
    fi
    
    # Add debug options if requested
    if [[ $DEBUG -eq 1 ]]; then
        cmdline="$cmdline -s -S"
        log_info "Debug mode enabled. Connect with GDB on port 1234"
    fi
    
    echo "$cmdline"
}

# Run QEMU test in tmux session
run_qemu_test() {
    local arch=$1
    local platform=$2
    local kernel_path=$3
    
    log_header "Running QEMU Test for $arch ($platform)"
    
    # Build QEMU command line
    local qemu_cmdline=$(build_qemu_cmdline "$arch" "$platform" "$kernel_path")
    
    log_info "QEMU command: $qemu_cmdline"
    log_info "Kernel: $kernel_path"
    log_info "Timeout: ${TIMEOUT}s"
    
    # Create unique session name
    local session_name="sage-os-test-$arch-$platform-$$"
    
    log_info "Creating tmux session: $session_name"
    
    # Create tmux session and run QEMU
    tmux new-session -d -s "$session_name" "$qemu_cmdline"
    
    if [[ $AUTO_EXIT -eq 1 ]]; then
        log_info "Test running... (will auto-exit after ${TIMEOUT}s)"
        log_info "To attach to session: tmux attach-session -t $session_name"
        log_info "To kill session manually: tmux kill-session -t $session_name"
        
        # Wait for specified timeout
        sleep "$TIMEOUT"
        
        # Check if session still exists and kill it
        if tmux has-session -t "$session_name" 2>/dev/null; then
            log_info "Stopping QEMU test session..."
            tmux kill-session -t "$session_name"
            log_success "QEMU test completed (auto-stopped after ${TIMEOUT}s)"
        else
            log_success "QEMU test completed (session ended naturally)"
        fi
    else
        log_info "Test running in background session: $session_name"
        log_info "To attach: tmux attach-session -t $session_name"
        log_info "To kill: tmux kill-session -t $session_name"
        log_info "Session will continue running until manually stopped"
    fi
}

# Main function
main() {
    cd "$PROJECT_ROOT"
    
    log_header "SAGE OS QEMU Testing with tmux"
    
    # Validate inputs
    if ! validate_arch "$ARCH"; then
        exit 1
    fi
    
    if ! validate_platform "$PLATFORM"; then
        exit 1
    fi
    
    # Check dependencies
    check_tmux
    
    # Find kernel image
    log_info "Looking for kernel image..."
    local kernel_path
    if kernel_path=$(find_kernel_image "$ARCH" "$PLATFORM"); then
        log_success "Found kernel: $kernel_path"
    else
        log_error "Kernel image not found for $ARCH ($PLATFORM)"
        log_info "Please build the kernel first:"
        echo "  ./build.sh build $ARCH $PLATFORM"
        exit 1
    fi
    
    # Check if QEMU is available
    local qemu_cmd=$(get_qemu_command "$ARCH" "$PLATFORM" "$kernel_path")
    if ! command -v "$qemu_cmd" >/dev/null 2>&1; then
        log_error "$qemu_cmd is not installed"
        log_info "Please install QEMU for $ARCH architecture"
        exit 1
    fi
    
    # Run the test
    run_qemu_test "$ARCH" "$PLATFORM" "$kernel_path"
}

# Run main function
main "$@"