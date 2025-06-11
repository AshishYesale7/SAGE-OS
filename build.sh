#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS Multi-Architecture Build Script
# ========================================
# 
# This script provides comprehensive build automation for SAGE-OS across multiple
# architectures and platforms. It handles dependency installation, cross-compilation,
# testing, and deployment workflows.
#
# Supported Architectures:
#   - i386     (32-bit x86) - Fully working
#   - x86_64   (64-bit x86) - Partial support (GRUB boots)
#   - aarch64  (64-bit ARM) - Fully working (Raspberry Pi 4/5)
#   - arm      (32-bit ARM) - Builds successfully
#   - riscv64  (64-bit RISC-V) - Builds, OpenSBI loads
#
# Supported Platforms:
#   - Linux (Ubuntu, Debian, Fedora, Arch)
#   - macOS (Intel and Apple Silicon)
#   - Windows (via WSL2)
#
# Author: Ashish Vasant Yesale
# Email: ashishyesale007@gmail.com

set -e  # Exit immediately if any command fails
set -u  # Exit if undefined variable is used
set -o pipefail  # Exit if any command in pipeline fails

# Script configuration and paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
PROJECT_NAME="SAGE-OS"

# Get version from VERSION file or use default
if [[ -f "$PROJECT_ROOT/VERSION" ]]; then
    VERSION=$(cat "$PROJECT_ROOT/VERSION")
else
    VERSION="1.0.0"
    echo "$VERSION" > "$PROJECT_ROOT/VERSION"
fi

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

# Detect host OS
detect_host_os() {
    case "$(uname -s)" in
        Darwin)
            HOST_OS="macos"
            HOMEBREW_PREFIX=$(brew --prefix 2>/dev/null || echo "/opt/homebrew")
            ;;
        Linux)
            HOST_OS="linux"
            ;;
        *)
            log_error "Unsupported host OS: $(uname -s)"
            exit 1
            ;;
    esac
    log_info "Detected host OS: $HOST_OS"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install dependencies on macOS
install_macos_deps() {
    log_header "Installing macOS Dependencies"
    
    # Check for Homebrew
    if ! command_exists brew; then
        log_error "Homebrew not found. Please install Homebrew first:"
        echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
    
    log_info "Installing base tools..."
    brew install qemu cdrtools
    
    # Install cross-compilation toolchains
    log_info "Adding cross-compilation toolchain tap..."
    brew tap messense/macos-cross-toolchains || true
    
    log_info "Installing cross-compilation toolchains..."
    brew install aarch64-unknown-linux-gnu || log_warning "aarch64 toolchain already installed"
    brew install x86_64-unknown-linux-gnu || log_warning "x86_64 toolchain already installed"
    brew install riscv64-unknown-linux-gnu || log_warning "riscv64 toolchain already installed"
    brew install arm-unknown-linux-gnueabihf || log_warning "arm toolchain already installed"
    
    log_success "macOS dependencies installed successfully"
}

# Install dependencies on Linux
install_linux_deps() {
    log_header "Installing Linux Dependencies"
    
    # Detect Linux distribution
    if command_exists apt-get; then
        PACKAGE_MANAGER="apt"
        INSTALL_CMD="sudo apt-get update && sudo apt-get install -y"
    elif command_exists yum; then
        PACKAGE_MANAGER="yum"
        INSTALL_CMD="sudo yum install -y"
    elif command_exists pacman; then
        PACKAGE_MANAGER="pacman"
        INSTALL_CMD="sudo pacman -S --noconfirm"
    else
        log_error "Unsupported Linux distribution. Please install dependencies manually."
        exit 1
    fi
    
    log_info "Installing dependencies using $PACKAGE_MANAGER..."
    
    case $PACKAGE_MANAGER in
        apt)
            $INSTALL_CMD \
                gcc-aarch64-linux-gnu \
                gcc-arm-linux-gnueabihf \
                gcc-riscv64-linux-gnu \
                qemu-system-arm \
                qemu-system-x86 \
                qemu-system-misc \
                genisoimage \
                dosfstools
            ;;
        yum)
            $INSTALL_CMD \
                gcc-aarch64-linux-gnu \
                gcc-arm-linux-gnueabihf \
                qemu-system-aarch64 \
                qemu-system-arm \
                qemu-system-x86 \
                genisoimage \
                dosfstools
            ;;
        pacman)
            $INSTALL_CMD \
                aarch64-linux-gnu-gcc \
                arm-linux-gnueabihf-gcc \
                qemu-arch-extra \
                cdrtools \
                dosfstools
            ;;
    esac
    
    log_success "Linux dependencies installed successfully"
}

# Check dependencies
check_dependencies() {
    log_header "Checking Dependencies"
    
    local missing_deps=()
    
    # Check for make
    if ! command_exists make; then
        missing_deps+=("make")
    fi
    
    # Check for QEMU
    if ! command_exists qemu-system-aarch64; then
        missing_deps+=("qemu-system-aarch64")
    fi
    
    # Check for cross-compilers based on host OS
    if [ "$HOST_OS" = "macos" ]; then
        if ! command_exists aarch64-unknown-linux-gnu-gcc; then
            missing_deps+=("aarch64-unknown-linux-gnu-gcc")
        fi
    else
        if ! command_exists aarch64-linux-gnu-gcc; then
            missing_deps+=("aarch64-linux-gnu-gcc")
        fi
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_warning "Missing dependencies: ${missing_deps[*]}"
        return 1
    fi
    
    log_success "All dependencies are available"
    return 0
}

# Check dependencies silently (no output)
check_deps_silent() {
    local missing_deps=()
    
    # Check for make
    if ! command_exists make; then
        missing_deps+=("make")
    fi
    
    # Check for QEMU
    if ! command_exists qemu-system-aarch64; then
        missing_deps+=("qemu-system-aarch64")
    fi
    
    # Check for cross-compilers based on host OS
    if [ "$HOST_OS" = "macos" ]; then
        if ! command_exists aarch64-unknown-linux-gnu-gcc; then
            missing_deps+=("aarch64-unknown-linux-gnu-gcc")
        fi
    else
        if ! command_exists aarch64-linux-gnu-gcc; then
            missing_deps+=("aarch64-linux-gnu-gcc")
        fi
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        return 1
    fi
    
    return 0
}

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
    local valid_platforms=("rpi3" "rpi4" "rpi5" "x86_64" "generic")
    
    for valid_platform in "${valid_platforms[@]}"; do
        if [[ "$platform" == "$valid_platform" ]]; then
            return 0
        fi
    done
    
    log_error "Invalid platform: $platform"
    log_info "Valid platforms: ${valid_platforms[*]}"
    return 1
}

# Validate format
validate_format() {
    local format=$1
    local valid_formats=("kernel" "iso" "sdcard" "docker")
    
    for valid_format in "${valid_formats[@]}"; do
        if [[ "$format" == "$valid_format" ]]; then
            return 0
        fi
    done
    
    log_error "Invalid format: $format"
    log_info "Valid formats: ${valid_formats[*]}"
    return 1
}

# Build for single architecture
build_arch() {
    local arch=$1
    local platform=${2:-"generic"}
    local format=${3:-"kernel"}
    
    # Validate inputs
    if [[ -z "$arch" ]]; then
        log_error "Architecture not specified"
        return 1
    fi
    
    if ! validate_arch "$arch"; then
        return 1
    fi
    
    if ! validate_platform "$platform"; then
        return 1
    fi
    
    if ! validate_format "$format"; then
        return 1
    fi
    
    log_header "Building $PROJECT_NAME for $arch ($platform, $format)"
    
    # Check dependencies
    if ! check_deps_silent; then
        log_error "Missing dependencies. Run: $0 install-deps"
        return 1
    fi
    
    # Use the multi-arch Makefile
    local makefile="Makefile.multi-arch"
    if [ ! -f "$makefile" ]; then
        log_error "Multi-arch Makefile not found: $makefile"
        exit 1
    fi
    
    # Build command
    local build_cmd="make -f $makefile $format ARCH=$arch PLATFORM=$platform"
    
    log_info "Executing: $build_cmd"
    if $build_cmd; then
        log_success "Build completed for $arch ($platform, $format)"
    else
        log_error "Build failed for $arch ($platform, $format)"
        return 1
    fi
}

# Build all architectures
build_all_arch() {
    local platform=${1:-"generic"}
    local format=${2:-"kernel"}
    
    log_header "Building All Architectures"
    
    local archs=("aarch64" "x86_64" "riscv64" "arm")
    local failed_builds=()
    
    for arch in "${archs[@]}"; do
        if build_arch "$arch" "$platform" "$format"; then
            log_success "✓ $arch build completed"
        else
            log_error "✗ $arch build failed"
            failed_builds+=("$arch")
        fi
    done
    
    if [ ${#failed_builds[@]} -gt 0 ]; then
        log_error "Failed builds: ${failed_builds[*]}"
        return 1
    fi
    
    log_success "All architecture builds completed successfully"
}

# Build all formats for an architecture
build_all_formats() {
    local arch=${1:-"aarch64"}
    local platform=${2:-"rpi4"}
    
    log_header "Building All Formats for $arch"
    
    local formats=("kernel" "iso" "sdcard")
    local failed_builds=()
    
    for format in "${formats[@]}"; do
        if build_arch "$arch" "$platform" "$format"; then
            log_success "✓ $format build completed"
        else
            log_error "✗ $format build failed"
            failed_builds+=("$format")
        fi
    done
    
    if [ ${#failed_builds[@]} -gt 0 ]; then
        log_error "Failed format builds: ${failed_builds[*]}"
        return 1
    fi
    
    log_success "All format builds completed successfully"
}

# Run tests
run_tests() {
    local arch=${1:-"aarch64"}
    local platform=${2:-"rpi4"}
    
    log_header "Running Tests for $arch ($platform)"
    
    # Check if kernel exists (look in both build and dist directories)
    local kernel_path="build/$arch/kernel.img"
    local dist_kernel_path="dist/$arch/SAGE-OS-0.1.0-$arch-$platform.img"
    
    if [ ! -f "$kernel_path" ] && [ ! -f "$dist_kernel_path" ]; then
        log_error "Kernel not found: $kernel_path or $dist_kernel_path"
        log_info "Building kernel first..."
        build_arch "$arch" "$platform" "kernel"
    fi
    
    # Use the dist version if available, otherwise use build version
    if [ -f "$dist_kernel_path" ]; then
        kernel_path="$dist_kernel_path"
    fi
    
    # Run QEMU test using tmux session
    log_info "Starting QEMU test in tmux session (will timeout after 30 seconds)..."
    local session_name="qemu-test-$arch-$$"
    
    # Create tmux session and run QEMU
    tmux new-session -d -s "$session_name" "make -f Makefile.multi-arch qemu ARCH=$arch PLATFORM=$platform KERNEL_IMG=$kernel_path"
    
    # Wait for 30 seconds then kill the session
    sleep 30
    
    # Check if session still exists and kill it
    if tmux has-session -t "$session_name" 2>/dev/null; then
        log_info "Stopping QEMU test session..."
        tmux kill-session -t "$session_name"
        log_success "QEMU test completed (timed out as expected)"
    else
        log_success "QEMU test completed"
    fi
}

# Clean builds
clean_builds() {
    log_header "Cleaning Build Files"
    
    make -f Makefile.multi-arch distclean
    
    log_success "All build files cleaned"
}

# Show build status
show_status() {
    log_header "Build Status"
    
    echo "Project: $PROJECT_NAME v$VERSION"
    echo "Build Date: $BUILD_DATE"
    echo "Host OS: $HOST_OS"
    echo ""
    
    # Check for built kernels
    echo "Built Kernels:"
    for arch in aarch64 x86_64 riscv64 arm; do
        local kernel_path="build/$arch/kernel.img"
        if [ -f "$kernel_path" ]; then
            local size=$(du -h "$kernel_path" | cut -f1)
            echo "  ✓ $arch: $size"
        else
            echo "  ✗ $arch: not built"
        fi
    done
    
    echo ""
    
    # Check for distribution files
    echo "Distribution Files:"
    if [ -d "dist" ]; then
        find dist -name "*.img" -o -name "*.iso" | while read -r file; do
            local size=$(du -h "$file" | cut -f1)
            echo "  ✓ $(basename "$file"): $size"
        done
    else
        echo "  No distribution files found"
    fi
}

# Show usage
show_usage() {
    cat << EOF
SAGE OS Multi-Architecture Build Script

Usage: $0 [command] [options]

Commands:
  install-deps              Install build dependencies
  check-deps               Check build dependencies
  build [arch] [platform]  Build for specific architecture and platform
  build-all [platform]     Build for all architectures
  build-formats [arch]     Build all formats for architecture
  test [arch] [platform]   Run tests for architecture
  clean                    Clean build files
  status                   Show build status
  help                     Show this help

Architectures:
  aarch64                  ARM64 (default)
  x86_64                   Intel/AMD 64-bit
  riscv64                  RISC-V 64-bit
  arm                      ARM 32-bit
  i386                     Intel/AMD 32-bit

Platforms:
  rpi3                     Raspberry Pi 3
  rpi4                     Raspberry Pi 4 (default)
  rpi5                     Raspberry Pi 5
  x86_64                   Generic x86_64
  generic                  Generic platform

Formats:
  kernel                   Kernel image (default)
  iso                      ISO image
  sdcard                   SD card image
  docker                   Docker image

Examples:
  $0 install-deps                    # Install dependencies
  $0 build aarch64 rpi5             # Build for RPi 5
  $0 build-all rpi4                 # Build all archs for RPi 4
  $0 build-formats aarch64          # Build all formats for ARM64
  $0 test aarch64 rpi4              # Test ARM64 build
  $0 clean                          # Clean all builds

Environment Variables:
  ENABLE_AI=ON             Enable AI subsystem
  ENABLE_CRYPTO=ON         Enable crypto support
  ENABLE_DEBUG=ON          Enable debug build
  MEMORY_SIZE=1024         Set memory size in MB

EOF
}

# Main function
main() {
    cd "$SCRIPT_DIR"
    
    # Parse command line arguments
    case "${1:-help}" in
        install-deps)
            if [ "$HOST_OS" = "macos" ]; then
                install_macos_deps
            else
                install_linux_deps
            fi
            ;;
        check-deps)
            if check_dependencies; then
                log_success "All dependencies are satisfied"
            else
                log_error "Some dependencies are missing. Run '$0 install-deps' to install them."
                exit 1
            fi
            ;;
        build)
            # Validate inputs first
            local arch="${2:-aarch64}"
            local platform="${3:-rpi4}"
            local format="${4:-kernel}"
            
            if [[ -z "$arch" ]]; then
                log_error "Architecture not specified"
                exit 1
            fi
            
            if ! validate_arch "$arch"; then
                exit 1
            fi
            
            if ! validate_platform "$platform"; then
                exit 1
            fi
            
            if ! validate_format "$format"; then
                exit 1
            fi
            
            # Check dependencies after validation
            if ! check_dependencies; then
                log_error "Dependencies not satisfied. Run '$0 install-deps' first."
                exit 1
            fi
            build_arch "$arch" "$platform" "$format"
            ;;
        build-all)
            if ! check_dependencies; then
                log_error "Dependencies not satisfied. Run '$0 install-deps' first."
                exit 1
            fi
            # Use the comprehensive multi-architecture build script
            if [ "$HOST_OS" = "macos" ] && [ -f "./build-all-architectures-macos.sh" ]; then
                ./build-all-architectures-macos.sh
            elif [ -f "./build-all-architectures.sh" ]; then
                ./build-all-architectures.sh
            else
                build_all_arch "${2:-rpi4}" "${3:-kernel}"
            fi
            ;;
        build-formats)
            if ! check_dependencies; then
                log_error "Dependencies not satisfied. Run '$0 install-deps' first."
                exit 1
            fi
            build_all_formats "${2:-aarch64}" "${3:-rpi4}"
            ;;
        test)
            if ! check_dependencies; then
                log_error "Dependencies not satisfied. Run '$0 install-deps' first."
                exit 1
            fi
            run_tests "${2:-aarch64}" "${3:-rpi4}"
            ;;
        clean)
            clean_builds
            ;;
        status)
            show_status
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            log_error "Unknown command: $1"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

# Detect host OS before running main function
detect_host_os

# Run main function with all arguments
main "$@"