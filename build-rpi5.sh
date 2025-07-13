#!/bin/bash
# SAGE OS - Raspberry Pi 5 Build Script
# Custom build for RPi5 with UART support

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}🚀 SAGE OS - Raspberry Pi 5 Build${NC}"
    echo "=================================="
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_header

# Set architecture and target
ARCH=aarch64
TARGET=rpi5
VERSION=$(cat VERSION 2>/dev/null || echo "1.0.1")
BUILD_ID="SAGE-OS-${VERSION}-$(date +%Y%m%d-%H%M%S)-${ARCH}-${TARGET}"

print_info "Building for Raspberry Pi 5 (${ARCH})"
print_info "Build ID: ${BUILD_ID}"

# Create build directories
mkdir -p build/${ARCH}/{boot,kernel,kernel/ai,drivers,drivers/ai_hat}
mkdir -p output/${ARCH}

# Set cross-compilation toolchain
CROSS_COMPILE=aarch64-linux-gnu-
CC=${CROSS_COMPILE}gcc
LD=${CROSS_COMPILE}ld
OBJCOPY=${CROSS_COMPILE}objcopy

# Compiler flags optimized for Cortex-A76 (RPi5)
CFLAGS="-nostdlib -nostartfiles -ffreestanding -O2 -Wall -Wextra -I. -Ikernel -Idrivers -D__aarch64__ -mcpu=cortex-a76 -mtune=cortex-a76"
LDFLAGS="-T linker.ld"

print_info "Compiling boot code..."
${CC} ${CFLAGS} -c boot/boot.S -o build/${ARCH}/boot/boot.o

print_info "Compiling kernel..."
${CC} ${CFLAGS} -c kernel/kernel.c -o build/${ARCH}/kernel/kernel.o
${CC} ${CFLAGS} -c kernel/memory.c -o build/${ARCH}/kernel/memory.o
${CC} ${CFLAGS} -c kernel/shell.c -o build/${ARCH}/kernel/shell.o
${CC} ${CFLAGS} -c kernel/stdio.c -o build/${ARCH}/kernel/stdio.o
${CC} ${CFLAGS} -c kernel/utils.c -o build/${ARCH}/kernel/utils.o
${CC} ${CFLAGS} -c kernel/ai/ai_subsystem.c -o build/${ARCH}/kernel/ai/ai_subsystem.o

print_info "Compiling drivers..."
${CC} ${CFLAGS} -c drivers/i2c.c -o build/${ARCH}/drivers/i2c.o
${CC} ${CFLAGS} -c drivers/serial.c -o build/${ARCH}/drivers/serial.o
${CC} ${CFLAGS} -c drivers/spi.c -o build/${ARCH}/drivers/spi.o
${CC} ${CFLAGS} -c drivers/uart.c -o build/${ARCH}/drivers/uart.o
${CC} ${CFLAGS} -c drivers/vga.c -o build/${ARCH}/drivers/vga.o
${CC} ${CFLAGS} -c drivers/ai_hat/ai_hat.c -o build/${ARCH}/drivers/ai_hat/ai_hat.o

print_info "Linking kernel..."
${LD} ${LDFLAGS} -o build/${ARCH}/kernel.elf \
    build/${ARCH}/boot/boot.o \
    build/${ARCH}/kernel/kernel.o \
    build/${ARCH}/kernel/memory.o \
    build/${ARCH}/kernel/shell.o \
    build/${ARCH}/kernel/stdio.o \
    build/${ARCH}/kernel/utils.o \
    build/${ARCH}/kernel/ai/ai_subsystem.o \
    build/${ARCH}/drivers/i2c.o \
    build/${ARCH}/drivers/serial.o \
    build/${ARCH}/drivers/spi.o \
    build/${ARCH}/drivers/uart.o \
    build/${ARCH}/drivers/vga.o \
    build/${ARCH}/drivers/ai_hat/ai_hat.o

print_info "Creating kernel image..."
${OBJCOPY} -O binary build/${ARCH}/kernel.elf build/${ARCH}/kernel8.img

print_info "Creating bootable files..."
# Create a bootable file structure
mkdir -p build/${ARCH}/boot_files
cp build/${ARCH}/kernel8.img build/${ARCH}/boot_files/
cp config/platforms/config_rpi5.txt build/${ARCH}/boot_files/config.txt

# Create output directory and copy files
mkdir -p output/${ARCH}
OUTPUT_DIR="output/${ARCH}/${BUILD_ID}"
mkdir -p ${OUTPUT_DIR}
cp build/${ARCH}/kernel8.img ${OUTPUT_DIR}/
cp build/${ARCH}/boot_files/config.txt ${OUTPUT_DIR}/
cp build/${ARCH}/kernel.elf ${OUTPUT_DIR}/

# Create a simple archive for easy transfer
tar -czf ${OUTPUT_DIR}.tar.gz -C output/${ARCH} ${BUILD_ID##*/}

print_success "Build completed successfully!"
print_info "Kernel ELF: build/${ARCH}/kernel.elf"
print_info "Kernel Image: build/${ARCH}/kernel8.img"
print_info "Boot Files: ${OUTPUT_DIR}/"
print_info "Archive: ${OUTPUT_DIR}.tar.gz"

echo ""
echo -e "${YELLOW}📋 Next Steps for Raspberry Pi 5:${NC}"
echo "1. Format your 16GB SD card as FAT32"
echo ""
echo "2. Copy files to SD card root:"
echo "   - Copy ${OUTPUT_DIR}/kernel8.img to SD card root"
echo "   - Copy ${OUTPUT_DIR}/config.txt to SD card root"
echo ""
echo "3. Alternative: Extract archive to SD card:"
echo "   tar -xzf ${OUTPUT_DIR}.tar.gz"
echo ""
echo "3. Connect UART (CP2102 USB UART Board):"
echo "   - RPi5 Pin 8 (GPIO14/TXD) → CP2102 RXD"
echo "   - RPi5 Pin 10 (GPIO15/RXD) → CP2102 TXD"
echo "   - RPi5 Pin 6 (GND) → CP2102 GND"
echo ""
echo "4. Connect to UART on your Mac:"
echo "   screen /dev/tty.usbserial-* 115200"
echo "   or: minicom -D /dev/tty.usbserial-* -b 115200"
echo ""
echo -e "${GREEN}🎉 Your SAGE OS is ready for Raspberry Pi 5!${NC}"