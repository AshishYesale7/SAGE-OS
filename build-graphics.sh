#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
#
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS Graphics Mode Build Script
# Builds SAGE OS with graphics support for interactive GUI experience

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🎨 SAGE OS Graphics Mode Builder${NC}"
echo "========================================"

# Check if we're on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "${GREEN}✅ Running on macOS: $(sw_vers -productName) $(sw_vers -productVersion)${NC}"
    
    # Check for Apple Silicon
    if [[ $(uname -m) == "arm64" ]]; then
        echo -e "${GREEN}✅ Apple Silicon (M1/M2/M3) detected${NC}"
    else
        echo -e "${YELLOW}⚠️  Intel Mac detected${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Not running on macOS (Linux environment detected)${NC}"
fi

# Architecture selection
ARCH=${1:-x86_64}
ACTION=${2:-build}

echo ""
echo -e "${BLUE}🏗️ Build Configuration${NC}"
echo "----------------------------------------"
echo "Architecture: $ARCH"
echo "Action: $ACTION"
echo "Graphics Mode: ENABLED"
echo "Keyboard Input: ENABLED"

# Validate architecture
case $ARCH in
    x86_64|i386)
        echo -e "${GREEN}✅ Graphics mode supported for $ARCH${NC}"
        ;;
    aarch64|arm|riscv64)
        echo -e "${RED}❌ Graphics mode not yet supported for $ARCH${NC}"
        echo "Graphics mode is currently only available for x86_64/i386 architectures."
        exit 1
        ;;
    *)
        echo -e "${RED}❌ Unsupported architecture: $ARCH${NC}"
        echo "Supported architectures: x86_64, i386"
        exit 1
        ;;
esac

# Create build directory
BUILD_DIR="build/${ARCH}-graphics"
mkdir -p "$BUILD_DIR"

echo ""
echo -e "${BLUE}📁 Build Directory${NC}"
echo "----------------------------------------"
echo "Build directory: $BUILD_DIR"

# Function to build graphics kernel
build_graphics_kernel() {
    echo ""
    echo -e "${MAGENTA}🔨 Building Graphics Kernel${NC}"
    echo "----------------------------------------"
    
    # Set up toolchain
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS toolchain
        if [[ $ARCH == "x86_64" ]]; then
            CC="x86_64-unknown-linux-gnu-gcc"
            LD="x86_64-unknown-linux-gnu-ld"
            OBJCOPY="x86_64-unknown-linux-gnu-objcopy"
        else
            CC="i386-unknown-linux-gnu-gcc"
            LD="i386-unknown-linux-gnu-ld"
            OBJCOPY="i386-unknown-linux-gnu-objcopy"
        fi
    else
        # Linux toolchain
        CC="gcc"
        LD="ld"
        OBJCOPY="objcopy"
    fi
    
    # Check if toolchain is available
    if ! command -v "$CC" >/dev/null 2>&1; then
        echo -e "${RED}❌ Cross-compiler not found: $CC${NC}"
        echo "Please install the cross-compilation toolchain:"
        echo "  brew install x86_64-unknown-linux-gnu"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Using toolchain: $CC${NC}"
    
    # Compiler flags
    CFLAGS="-m32 -nostdlib -nostartfiles -ffreestanding -O2 -Wall -Wextra"
    CFLAGS="$CFLAGS -I. -Ikernel -Idrivers -DARCH_X86_64 -DGRAPHICS_MODE"
    
    # Linker flags
    LDFLAGS="-T linker_i386.ld -nostdlib -m elf_i386"
    
    echo "Compiler flags: $CFLAGS"
    echo "Linker flags: $LDFLAGS"
    
    # Compile boot loader
    echo ""
    echo -e "${YELLOW}📦 Compiling boot loader...${NC}"
    $CC $CFLAGS -c boot/boot_i386.S -o "$BUILD_DIR/boot.o"
    echo -e "${GREEN}✅ Boot loader compiled${NC}"
    
    # Compile graphics kernel (use kernel_graphics.c instead of kernel.c)
    echo ""
    echo -e "${YELLOW}📦 Compiling graphics kernel...${NC}"
    $CC $CFLAGS -c kernel/kernel_graphics.c -o "$BUILD_DIR/kernel_graphics.o"
    echo -e "${GREEN}✅ Graphics kernel compiled${NC}"
    
    # Compile VGA driver
    echo ""
    echo -e "${YELLOW}📦 Compiling VGA driver...${NC}"
    $CC $CFLAGS -c drivers/vga.c -o "$BUILD_DIR/vga.o"
    echo -e "${GREEN}✅ VGA driver compiled${NC}"
    
    # Note: kernel_graphics.c is self-contained and includes its own serial functions
    # We only need the VGA driver as an external dependency
    
    # Link everything together
    echo ""
    echo -e "${YELLOW}🔗 Linking kernel...${NC}"
    
    # Collect all object files (minimal set for graphics kernel)
    OBJECTS="$BUILD_DIR/boot.o $BUILD_DIR/kernel_graphics.o $BUILD_DIR/vga.o"
    
    echo "Linking objects: $OBJECTS"
    
    $LD $LDFLAGS $OBJECTS -o "$BUILD_DIR/kernel.elf"
    echo -e "${GREEN}✅ Kernel linked successfully${NC}"
    
    # Create binary image
    echo ""
    echo -e "${YELLOW}📦 Creating binary image...${NC}"
    $OBJCOPY -O binary "$BUILD_DIR/kernel.elf" "$BUILD_DIR/kernel.img"
    echo -e "${GREEN}✅ Binary image created${NC}"
    
    # Show file sizes
    echo ""
    echo -e "${BLUE}📊 Build Results${NC}"
    echo "----------------------------------------"
    if [[ -f "$BUILD_DIR/kernel.elf" ]]; then
        ELF_SIZE=$(du -h "$BUILD_DIR/kernel.elf" | cut -f1)
        echo "ELF kernel: $ELF_SIZE"
    fi
    
    if [[ -f "$BUILD_DIR/kernel.img" ]]; then
        IMG_SIZE=$(du -h "$BUILD_DIR/kernel.img" | cut -f1)
        echo "Binary image: $IMG_SIZE"
    fi
    
    echo -e "${GREEN}✅ Graphics kernel build completed successfully!${NC}"
}

# Function to test graphics kernel
test_graphics_kernel() {
    echo ""
    echo -e "${MAGENTA}🧪 Testing Graphics Kernel${NC}"
    echo "----------------------------------------"
    
    if [[ ! -f "$BUILD_DIR/kernel.elf" ]]; then
        echo -e "${RED}❌ Kernel not found. Please build first.${NC}"
        exit 1
    fi
    
    # Check if QEMU is available
    QEMU_CMD=""
    if command -v qemu-system-i386 >/dev/null 2>&1; then
        QEMU_CMD="qemu-system-i386"
    elif command -v qemu-system-x86_64 >/dev/null 2>&1; then
        QEMU_CMD="qemu-system-x86_64"
    else
        echo -e "${RED}❌ QEMU not found${NC}"
        echo "Please install QEMU:"
        echo "  brew install qemu"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Using QEMU: $QEMU_CMD${NC}"
    
    echo ""
    echo -e "${CYAN}🚀 Starting SAGE OS in Graphics Mode${NC}"
    echo "========================================"
    echo ""
    echo -e "${YELLOW}📋 Instructions:${NC}"
    echo "• SAGE OS will boot in graphics mode with VGA display"
    echo "• Use keyboard to interact with the shell"
    echo "• Type 'help' to see available commands"
    echo "• Type 'colors' to test color display"
    echo "• Type 'demo' to run demo sequence"
    echo "• Type 'exit' to shutdown"
    echo "• Press Ctrl+Alt+G to release mouse (if captured)"
    echo "• Close QEMU window to exit"
    echo ""
    echo -e "${GREEN}Starting QEMU in 3 seconds...${NC}"
    sleep 3
    
    # Start QEMU in graphics mode (no -nographic flag)
    echo -e "${CYAN}🎮 QEMU Command:${NC}"
    echo "$QEMU_CMD -kernel $BUILD_DIR/kernel.elf -m 128M"
    echo ""
    
    $QEMU_CMD -kernel "$BUILD_DIR/kernel.elf" -m 128M
}

# Function to show help
show_help() {
    echo ""
    echo -e "${CYAN}🎨 SAGE OS Graphics Mode Builder${NC}"
    echo "========================================"
    echo ""
    echo -e "${YELLOW}Usage:${NC}"
    echo "  $0 [ARCHITECTURE] [ACTION]"
    echo ""
    echo -e "${YELLOW}Architectures:${NC}"
    echo "  x86_64      Build for x86_64 (default)"
    echo "  i386        Build for i386"
    echo ""
    echo -e "${YELLOW}Actions:${NC}"
    echo "  build       Build graphics kernel (default)"
    echo "  test        Test graphics kernel in QEMU"
    echo "  clean       Clean build directory"
    echo "  help        Show this help"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  $0                    # Build x86_64 graphics kernel"
    echo "  $0 x86_64 build       # Build x86_64 graphics kernel"
    echo "  $0 x86_64 test        # Test x86_64 graphics kernel"
    echo "  $0 x86_64 clean       # Clean x86_64 build"
    echo ""
    echo -e "${YELLOW}Features:${NC}"
    echo "  ✅ VGA graphics mode (80x25 text)"
    echo "  ✅ Keyboard input support"
    echo "  ✅ Interactive shell"
    echo "  ✅ Color display"
    echo "  ✅ Multiple commands"
    echo "  ✅ Demo sequences"
}

# Function to clean build
clean_build() {
    echo ""
    echo -e "${MAGENTA}🧹 Cleaning Build${NC}"
    echo "----------------------------------------"
    
    if [[ -d "$BUILD_DIR" ]]; then
        rm -rf "$BUILD_DIR"
        echo -e "${GREEN}✅ Build directory cleaned: $BUILD_DIR${NC}"
    else
        echo -e "${YELLOW}⚠️  Build directory not found: $BUILD_DIR${NC}"
    fi
}

# Main execution
case $ACTION in
    build)
        build_graphics_kernel
        echo ""
        echo -e "${CYAN}🎉 Graphics kernel ready!${NC}"
        echo "Test with: $0 $ARCH test"
        ;;
    test)
        test_graphics_kernel
        ;;
    clean)
        clean_build
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}❌ Unknown action: $ACTION${NC}"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}🎨 Graphics build script completed!${NC}"