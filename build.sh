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
    echo "  build [arch]     Build specific architecture (default: i386)"
    echo "  test [arch]      Build and test in QEMU"
    echo "  graphics         Build and run graphics mode with VNC"
    echo "  graphics-i386    Build and run i386 graphics mode (macOS optimized)"
    echo "  test-graphics    Test graphics mode (10 second demo)"
    echo "  all              Build all architectures"
    echo "  clean            Clean all build files"
    echo "  setup-macos      Install macOS dependencies"
    echo "  setup-graphics   Setup graphics mode for macOS"
    echo "  help             Show this help"
    echo ""
    echo "Architectures:"
    echo "  i386             Intel/AMD 32-bit (fully working, default)"
    echo "  x86_64           Intel/AMD 64-bit (build issues)"
    echo "  aarch64          ARM 64-bit (builds, hangs in QEMU)"
    echo "  arm              ARM 32-bit (builds, hangs in QEMU)"
    echo "  riscv64          RISC-V 64-bit (needs toolchain)"
    echo ""
    echo "Examples:"
    echo "  $0 build                # Build i386"
    echo "  $0 build aarch64        # Build ARM64"
    echo "  $0 test                 # Build and test i386"
    echo "  $0 graphics             # Run graphics mode with VNC"
    echo "  $0 test-graphics        # Test graphics mode"
    echo "  $0 all                  # Build all architectures"
    echo ""
}

# Build single architecture
build_arch() {
    local arch=${1:-i386}
    print_info "Building $arch..."
    
    if make ARCH=$arch; then
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
    local arch=${1:-i386}
    print_info "Testing $arch in QEMU..."
    
    if ! build_arch $arch; then
        return 1
    fi
    
    print_info "Starting QEMU test (10 second timeout)..."
    make test ARCH=$arch
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
    make clean
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

# Build graphics kernel and run interactively
build_graphics_interactive() {
    print_info "Building and starting graphics mode for i386..."
    
    # Build graphics kernel
    print_info "Building graphics kernel..."
    if ! ./scripts/graphics/build-graphics.sh i386; then
        print_error "Graphics build failed"
        return 1
    fi
    
    print_success "Graphics kernel built successfully!"
    echo ""
    print_info "🖥️  Starting SAGE-OS in graphics mode..."
    print_info "🔗  VNC server will be available on localhost:5900"
    print_info "📱  Connect with VNC viewer to see the graphics interface"
    print_info "⌨️  Use keyboard in VNC to interact with SAGE-OS shell"
    print_info "🛑  Press Ctrl+C to stop the server"
    echo ""
    
    # Start QEMU with VNC
    qemu-system-i386 -kernel build/i386-graphics/kernel.elf -m 128M -vnc :0 -no-reboot
}

# Setup graphics mode for macOS
setup_graphics_macos() {
    print_info "Setting up graphics mode for macOS..."
    
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This command is for macOS only"
        return 1
    fi
    
    if [[ -f "./setup-macos-graphics.sh" ]]; then
        print_info "Running macOS graphics setup script..."
        ./setup-macos-graphics.sh
    else
        print_error "Setup script not found: ./setup-macos-graphics.sh"
        print_info "Please ensure you're in the SAGE-OS directory"
        return 1
    fi
}

# Test graphics kernel
test_graphics() {
    print_info "Testing graphics mode for i386 (10 second demo)..."
    
    # Build graphics kernel
    print_info "Building graphics kernel..."
    if ! ./build-graphics.sh i386 build; then
        print_error "Graphics build failed"
        return 1
    fi
    
    print_success "Graphics kernel built successfully!"
    print_info "Running 10-second graphics test..."
    print_info "This will show text output of the graphics kernel"
    echo ""
    
    # Test with timeout (use -nographic for text output)
    timeout 10s qemu-system-i386 -kernel build/i386-graphics/kernel.elf -nographic -no-reboot || true
    
    echo ""
    print_success "Graphics test completed!"
    echo ""
    print_info "💡 To run full graphics mode with GUI:"
    print_info "   qemu-system-i386 -kernel build/i386-graphics/kernel.elf -m 128M"
    print_info "💡 To run graphics mode with VNC:"
    print_info "   qemu-system-i386 -kernel build/i386-graphics/kernel.elf -m 128M -vnc :0"
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
        "setup-graphics")
            print_header
            setup_graphics_macos
            ;;
        "graphics")
            print_header
            build_graphics_interactive
            ;;
        "graphics-i386")
            print_header
            print_info "Building i386 graphics mode..."
            ./build-i386-graphics.sh
            print_success "i386 graphics build completed!"
            print_info "Run with: ./run-i386-graphics.sh cocoa"
            ;;
        "test-graphics")
            print_header
            test_graphics
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