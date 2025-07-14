#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Enhanced Build Script
# Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# ─────────────────────────────────────────────────────────────────────────────

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Enhanced build configuration
ENHANCED_VERSION="1.0.1-enhanced"
BUILD_OUTPUT_DIR="build-output"

# Print colored output
print_status() {
    echo -e "${BLUE}🚀 SAGE OS Enhanced Build System${NC}"
    echo -e "${BLUE}=================================${NC}"
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

# Check dependencies
check_dependencies() {
    print_info "Checking build dependencies..."
    
    local missing_deps=()
    
    if ! command -v gcc &> /dev/null; then
        missing_deps+=("gcc")
    fi
    
    if ! command -v ld &> /dev/null; then
        missing_deps+=("binutils")
    fi
    
    if ! command -v make &> /dev/null; then
        missing_deps+=("make")
    fi
    
    if ! command -v qemu-system-i386 &> /dev/null; then
        missing_deps+=("qemu-system-x86")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_info "Please install the missing dependencies and try again."
        exit 1
    fi
    
    print_success "All dependencies are available"
}

# Build enhanced kernel
build_enhanced() {
    local arch=${1:-i386}
    
    print_info "Building enhanced SAGE OS for $arch..."
    
    # Create output directory
    mkdir -p "$BUILD_OUTPUT_DIR"
    
    # Build using enhanced Makefile
    if make -f Makefile.enhanced enhanced ARCH="$arch"; then
        print_success "Enhanced SAGE OS built successfully for $arch"
        
        # Show build information
        local kernel_file="$BUILD_OUTPUT_DIR/sage-os-enhanced-$ENHANCED_VERSION-$arch-graphics.elf"
        if [ -f "$kernel_file" ]; then
            local size=$(du -h "$kernel_file" | cut -f1)
            print_info "Kernel file: $kernel_file"
            print_info "Kernel size: $size"
        fi
    else
        print_error "Enhanced build failed for $arch"
        exit 1
    fi
}

# Test enhanced kernel
test_enhanced() {
    local arch=${1:-i386}
    local mode=${2:-interactive}
    
    local kernel_file="$BUILD_OUTPUT_DIR/sage-os-enhanced-$ENHANCED_VERSION-$arch-graphics.elf"
    
    if [ ! -f "$kernel_file" ]; then
        print_error "Kernel file not found: $kernel_file"
        print_info "Please build the enhanced kernel first: $0 build $arch"
        exit 1
    fi
    
    print_info "Testing enhanced SAGE OS ($arch) in $mode mode..."
    print_warning "Use Ctrl+A then X to exit QEMU"
    
    case "$mode" in
        "interactive")
            make -f Makefile.enhanced test-enhanced-interactive ARCH="$arch"
            ;;
        "graphics")
            make -f Makefile.enhanced test-enhanced-graphics ARCH="$arch"
            ;;
        "nographic")
            make -f Makefile.enhanced test-enhanced ARCH="$arch"
            ;;
        *)
            print_error "Unknown test mode: $mode"
            print_info "Available modes: interactive, graphics, nographic"
            exit 1
            ;;
    esac
}

# Clean enhanced build
clean_enhanced() {
    print_info "Cleaning enhanced build files..."
    make -f Makefile.enhanced clean-enhanced
    print_success "Enhanced build files cleaned"
}

# Show enhanced build info
show_info() {
    make -f Makefile.enhanced info-enhanced
}

# Show help
show_help() {
    print_status
    echo ""
    echo -e "${PURPLE}Enhanced SAGE OS Build Script${NC}"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  build [arch]           - Build enhanced kernel (default: i386)"
    echo "  test [arch] [mode]     - Test enhanced kernel (default: i386, interactive)"
    echo "  clean                  - Clean build files"
    echo "  info                   - Show build information"
    echo "  help                   - Show this help"
    echo ""
    echo "Architectures:"
    echo "  i386                   - 32-bit x86 (default)"
    echo "  x86_64                 - 64-bit x86"
    echo ""
    echo "Test modes:"
    echo "  interactive            - Interactive mode with keyboard (default)"
    echo "  graphics               - Graphics mode with VGA display"
    echo "  nographic              - No graphics, serial only"
    echo ""
    echo "Examples:"
    echo "  $0 build               - Build for i386"
    echo "  $0 build x86_64        - Build for x86_64"
    echo "  $0 test                - Test i386 in interactive mode"
    echo "  $0 test i386 graphics  - Test i386 with graphics"
    echo "  $0 clean               - Clean all build files"
    echo ""
    echo -e "${CYAN}Enhanced Features:${NC}"
    echo "- Advanced file management with persistent storage"
    echo "- Enhanced VGA graphics with colors and styling"
    echo "- Improved shell with command history"
    echo "- Better keyboard input handling"
    echo "- File operations: save, cat, append, cp, mv, rm, find, grep, wc"
    echo "- System commands: help, clear, version, meminfo, history"
}

# Main script logic
main() {
    case "${1:-help}" in
        "build")
            print_status
            check_dependencies
            build_enhanced "${2:-i386}"
            ;;
        "test")
            print_status
            test_enhanced "${2:-i386}" "${3:-interactive}"
            ;;
        "clean")
            print_status
            clean_enhanced
            ;;
        "info")
            print_status
            show_info
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"