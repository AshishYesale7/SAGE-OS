#!/bin/bash

# SAGE-OS Graphics Mode Build Script
# This script builds a special version of SAGE-OS with graphics support

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Get project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

# Parse arguments
ARCH="${1:-i386}"
TARGET="${2:-generic}"

# Only support x86 architectures for graphics mode
if [[ "$ARCH" != "i386" && "$ARCH" != "x86_64" ]]; then
    print_error "Graphics mode only supported on i386 and x86_64 architectures"
    print_info "Supported architectures for graphics: i386, x86_64"
    exit 1
fi

print_info "Building SAGE-OS Graphics Mode for $ARCH architecture (target: $TARGET)"

# Create temporary build directory
BUILD_DIR="build/${ARCH}-graphics"
OUTPUT_DIR="output/${ARCH}"
mkdir -p "$BUILD_DIR" "$OUTPUT_DIR"

# Get version
VERSION=$(cat VERSION 2>/dev/null || echo "1.0.1")

# Set up cross-compilation
if [[ "$ARCH" == "i386" ]]; then
    CROSS_COMPILE=""
    CFLAGS="-nostdlib -nostartfiles -ffreestanding -O2 -Wall -Wextra -I. -Ikernel -Idrivers -m32 -D__i386__ -fno-pic -fno-pie"
    LDFLAGS="-T linker_x86.ld -m elf_i386"
elif [[ "$ARCH" == "x86_64" ]]; then
    CROSS_COMPILE=""
    CFLAGS="-nostdlib -nostartfiles -ffreestanding -O2 -Wall -Wextra -I. -Ikernel -Idrivers -D__x86_64__ -fno-pic -fno-pie -mcmodel=kernel -mno-red-zone"
    LDFLAGS="-T linker_x86_64.ld"
fi

CC="${CROSS_COMPILE}gcc"
LD="${CROSS_COMPILE}ld"
OBJCOPY="${CROSS_COMPILE}objcopy"

print_info "Compiling graphics kernel..."

# Compile boot loader
if [[ "$ARCH" == "x86_64" ]]; then
    BOOT_SRC="boot/boot_no_multiboot.S"
    BOOT_OBJ="$BUILD_DIR/boot_no_multiboot.o"
else
    BOOT_SRC="boot/boot.S"
    BOOT_OBJ="$BUILD_DIR/boot.o"
fi

mkdir -p "$(dirname "$BOOT_OBJ")"
$CC $CFLAGS -c "$BOOT_SRC" -o "$BOOT_OBJ"

# Compile graphics kernel (standalone)
$CC $CFLAGS -c kernel/kernel_graphics.c -o "$BUILD_DIR/kernel_graphics.o"

# Compile VGA driver
$CC $CFLAGS -c drivers/vga.c -o "$BUILD_DIR/vga.o"

# Link everything
print_info "Linking graphics kernel..."
$LD $LDFLAGS -o "$BUILD_DIR/kernel.elf" "$BOOT_OBJ" "$BUILD_DIR/kernel_graphics.o" "$BUILD_DIR/vga.o"

# Create kernel image
print_info "Creating graphics kernel image..."
if [[ "$ARCH" == "i386" ]]; then
    # For i386, the kernel already has multiboot header, just copy the ELF
    cp "$BUILD_DIR/kernel.elf" "$BUILD_DIR/kernel.img"
else
    # For x86_64, copy as binary
    $OBJCOPY -O binary "$BUILD_DIR/kernel.elf" "$BUILD_DIR/kernel.img"
fi

# Copy to output directory with special graphics naming
GRAPHICS_NAME="sage-os-v${VERSION}-${ARCH}-${TARGET}-graphics"
cp "$BUILD_DIR/kernel.img" "$OUTPUT_DIR/${GRAPHICS_NAME}.img"
cp "$BUILD_DIR/kernel.elf" "$OUTPUT_DIR/${GRAPHICS_NAME}.elf"

print_success "Graphics build completed successfully!"
echo ""
echo "📁 Architecture: $ARCH"
echo "🎯 Target: $TARGET"
echo "📦 Version: $VERSION"
echo "🖥️ Mode: Graphics"
echo "🔧 Build ID: $GRAPHICS_NAME"
echo "📄 Kernel Image: $OUTPUT_DIR/${GRAPHICS_NAME}.img"
echo "🔍 Debug ELF: $OUTPUT_DIR/${GRAPHICS_NAME}.elf"
echo ""
print_info "To test graphics mode:"
echo "  ./scripts/test-qemu.sh $ARCH $TARGET graphics"
echo "  OR"
echo "  qemu-system-$ARCH -kernel $OUTPUT_DIR/${GRAPHICS_NAME}.img"