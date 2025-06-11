#!/bin/bash
# SAGE OS - Simple Build Script
# One script to rule them all!

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}🚀 SAGE OS Build System${NC}"
    echo "=========================="
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
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Show help
show_help() {
    print_header
    echo ""
    echo "Usage: $0 [COMMAND] [ARCH]"
    echo ""
    echo "Commands:"
    echo "  build [arch]     Build specific architecture (default: x86_64)"
    echo "  test [arch]      Build and test in QEMU"
    echo "  all              Build all architectures"
    echo "  clean            Clean all build files"
    echo "  setup-macos      Install macOS dependencies"
    echo "  help             Show this help"
    echo ""
    echo "Architectures:"
    echo "  x86_64           Intel/AMD 64-bit (fully working)"
    echo "  aarch64          ARM 64-bit (builds, hangs in QEMU)"
    echo "  arm              ARM 32-bit (builds, hangs in QEMU)"
    echo "  riscv64          RISC-V 64-bit (needs toolchain)"
    echo ""
    echo "Examples:"
    echo "  $0 build                # Build x86_64"
    echo "  $0 build aarch64        # Build ARM64"
    echo "  $0 test                 # Build and test x86_64"
    echo "  $0 all                  # Build all architectures"
    echo ""
}

# Build single architecture
build_arch() {
    local arch=${1:-x86_64}
    print_info "Building $arch..."
    
    if make -f Makefile.simple ARCH=$arch; then
        print_success "$arch built successfully!"
        
        # Show kernel info
        if [ -f "build/$arch/kernel.img" ]; then
            local size=$(ls -lh "build/$arch/kernel.img" | awk '{print $5}')
            print_info "Kernel size: $size"
        fi
        
        return 0
    else
        print_error "$arch build failed!"
        return 1
    fi
}

# Test in QEMU
test_arch() {
    local arch=${1:-x86_64}
    print_info "Testing $arch in QEMU..."
    
    if ! build_arch $arch; then
        return 1
    fi
    
    print_info "Starting QEMU test (10 second timeout)..."
    make -f Makefile.simple test ARCH=$arch
}

# Build all architectures
build_all() {
    print_info "Building all architectures..."
    local success=0
    local total=0
    
    for arch in x86_64 aarch64 arm; do
        total=$((total + 1))
        if build_arch $arch; then
            success=$((success + 1))
        fi
        echo ""
    done
    
    # Try RISC-V if toolchain available
    if command -v riscv64-unknown-linux-gnu-gcc >/dev/null 2>&1; then
        total=$((total + 1))
        if build_arch riscv64; then
            success=$((success + 1))
        fi
    else
        print_warning "Skipping riscv64 (toolchain not found)"
    fi
    
    echo ""
    print_info "Build Summary: $success/$total architectures successful"
    
    if [ $success -eq $total ]; then
        print_success "All builds completed successfully!"
    else
        print_warning "Some builds failed"
    fi
}

# Clean builds
clean_all() {
    print_info "Cleaning all build files..."
    make -f Makefile.simple clean
    print_success "Build files cleaned!"
}

# Setup macOS dependencies
setup_macos() {
    print_info "Setting up macOS dependencies..."
    
    if ! command -v brew >/dev/null 2>&1; then
        print_error "Homebrew not found! Install from: https://brew.sh"
        exit 1
    fi
    
    print_info "Installing QEMU..."
    brew install qemu
    
    print_info "Installing cross-compilers..."
    brew install x86_64-elf-gcc || true
    brew install aarch64-elf-gcc || true
    brew install arm-none-eabi-gcc || true
    
    print_info "Optional: Install RISC-V toolchain"
    echo "Run: brew install riscv64-elf-gcc"
    
    print_success "macOS setup completed!"
}

# Main script
main() {
    case "${1:-help}" in
        "build")
            print_header
            build_arch $2
            ;;
        "test")
            print_header
            test_arch $2
            ;;
        "all")
            print_header
            build_all
            ;;
        "clean")
            print_header
            clean_all
            ;;
        "setup-macos")
            print_header
            setup_macos
            ;;
        "help"|"-h"|"--help")
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

# Run main function
main "$@"