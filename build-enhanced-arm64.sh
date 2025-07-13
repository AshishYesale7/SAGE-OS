#!/bin/bash

# Enhanced SAGE OS ARM64 Build Script with File Management
# Copyright (c) 2025 Ashish Vasant Yesale

set -e

echo "=========================================="
echo "SAGE OS Enhanced ARM64 Build System"
echo "=========================================="

# Configuration
ARCH="aarch64"
TARGET="aarch64-linux-gnu"
BUILD_DIR="build/${ARCH}"
OUTPUT_DIR="build-output"
VERSION="1.0.1"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
IMAGE_NAME="SAGE-OS-${VERSION}-${TIMESTAMP}-${ARCH}-rpi5-enhanced"

# Compiler settings optimized for Raspberry Pi 5 (Cortex-A76)
CC="${TARGET}-gcc"
OBJCOPY="${TARGET}-objcopy"
CFLAGS="-ffreestanding -nostdlib -nostartfiles -mcpu=cortex-a76 -mtune=cortex-a76 -O2 -Wall -Wextra"
LDFLAGS="-T linker.ld -nostdlib"

echo "Building enhanced SAGE OS for ARM64 (Cortex-A76)..."
echo "Target: ${TARGET}"
echo "Build directory: ${BUILD_DIR}"
echo "Output directory: ${OUTPUT_DIR}"

# Create build directories
mkdir -p "${BUILD_DIR}/boot"
mkdir -p "${BUILD_DIR}/kernel"
mkdir -p "${BUILD_DIR}/kernel/ai"
mkdir -p "${BUILD_DIR}/drivers"
mkdir -p "${BUILD_DIR}/drivers/ai_hat"
mkdir -p "${BUILD_DIR}/boot_files"
mkdir -p "${OUTPUT_DIR}/${ARCH}"

echo "Compiling boot loader..."
${CC} ${CFLAGS} -c boot/boot_aarch64.S -o "${BUILD_DIR}/boot/boot.o"

echo "Compiling kernel components..."
${CC} ${CFLAGS} -c kernel/kernel.c -o "${BUILD_DIR}/kernel/kernel.o"
${CC} ${CFLAGS} -c kernel/memory.c -o "${BUILD_DIR}/kernel/memory.o"
${CC} ${CFLAGS} -c kernel/shell.c -o "${BUILD_DIR}/kernel/shell.o"
${CC} ${CFLAGS} -c kernel/stdio.c -o "${BUILD_DIR}/kernel/stdio.o"
${CC} ${CFLAGS} -c kernel/utils.c -o "${BUILD_DIR}/kernel/utils.o"
${CC} ${CFLAGS} -c kernel/filesystem.c -o "${BUILD_DIR}/kernel/filesystem.o"

echo "Compiling AI subsystem..."
${CC} ${CFLAGS} -c kernel/ai/ai_subsystem.c -o "${BUILD_DIR}/kernel/ai/ai_subsystem.o"

echo "Compiling drivers..."
${CC} ${CFLAGS} -c drivers/serial.c -o "${BUILD_DIR}/drivers/serial.o"
${CC} ${CFLAGS} -c drivers/uart.c -o "${BUILD_DIR}/drivers/uart.o"
${CC} ${CFLAGS} -c drivers/vga.c -o "${BUILD_DIR}/drivers/vga.o"
${CC} ${CFLAGS} -c drivers/i2c.c -o "${BUILD_DIR}/drivers/i2c.o"
${CC} ${CFLAGS} -c drivers/spi.c -o "${BUILD_DIR}/drivers/spi.o"
${CC} ${CFLAGS} -c drivers/ai_hat/ai_hat.c -o "${BUILD_DIR}/drivers/ai_hat/ai_hat.o"

echo "Linking kernel..."
${CC} ${LDFLAGS} \
    "${BUILD_DIR}/boot/boot.o" \
    "${BUILD_DIR}/kernel/kernel.o" \
    "${BUILD_DIR}/kernel/memory.o" \
    "${BUILD_DIR}/kernel/shell.o" \
    "${BUILD_DIR}/kernel/stdio.o" \
    "${BUILD_DIR}/kernel/utils.o" \
    "${BUILD_DIR}/kernel/filesystem.o" \
    "${BUILD_DIR}/kernel/ai/ai_subsystem.o" \
    "${BUILD_DIR}/drivers/serial.o" \
    "${BUILD_DIR}/drivers/uart.o" \
    "${BUILD_DIR}/drivers/vga.o" \
    "${BUILD_DIR}/drivers/i2c.o" \
    "${BUILD_DIR}/drivers/spi.o" \
    "${BUILD_DIR}/drivers/ai_hat/ai_hat.o" \
    -o "${BUILD_DIR}/kernel.elf"

echo "Creating kernel image..."
${OBJCOPY} -O binary "${BUILD_DIR}/kernel.elf" "${BUILD_DIR}/kernel8.img"

echo "Creating Raspberry Pi 5 configuration..."
cat > "${BUILD_DIR}/boot_files/config.txt" << EOF
# SAGE OS Raspberry Pi 5 Configuration
# Enhanced ARM64 Edition with File Management

# ARM 64-bit mode
arm_64bit=1

# Kernel configuration
kernel=kernel8.img
kernel_address=0x80000

# Memory configuration
gpu_mem=64
arm_freq=2400

# UART configuration for serial communication
enable_uart=1
uart_2ndstage=1

# USB configuration
max_usb_current=1
usb_max_current_enable=1

# Display configuration
hdmi_force_hotplug=1
hdmi_drive=2

# Performance settings for Cortex-A76
over_voltage=2
arm_freq_min=600

# Enable I2C and SPI for AI HAT+
dtparam=i2c_arm=on
dtparam=spi=on

# AI HAT+ specific settings
dtoverlay=ai-hat-plus

# Boot configuration
disable_splash=1
boot_delay=0

# SAGE OS specific
# Enhanced file management system enabled
# Persistent memory storage enabled
# ARM64 optimizations enabled
EOF

# Copy files to boot directory
cp "${BUILD_DIR}/kernel.elf" "${BUILD_DIR}/boot_files/"
cp "${BUILD_DIR}/kernel8.img" "${BUILD_DIR}/boot_files/"

echo "Creating bootable image..."
# Create a simple tar archive for easy deployment
cd "${BUILD_DIR}/boot_files"
tar -czf "../../../${OUTPUT_DIR}/${ARCH}/${IMAGE_NAME}.tar.gz" *
cd - > /dev/null

# Also create a directory structure for easy access
mkdir -p "${OUTPUT_DIR}/${ARCH}/${IMAGE_NAME}"
cp "${BUILD_DIR}/boot_files/"* "${OUTPUT_DIR}/${ARCH}/${IMAGE_NAME}/"

echo "Build completed successfully!"
echo ""
echo "=========================================="
echo "SAGE OS Enhanced ARM64 Build Summary"
echo "=========================================="
echo "Version: ${VERSION}"
echo "Architecture: ARM64 (Cortex-A76 optimized)"
echo "Target Device: Raspberry Pi 5"
echo "Build Time: ${TIMESTAMP}"
echo ""
echo "Features Included:"
echo "✓ Enhanced file management system"
echo "✓ In-memory persistent storage"
echo "✓ Advanced shell commands (save, cat, ls, pwd, etc.)"
echo "✓ ARM64 Cortex-A76 optimizations"
echo "✓ Dual UART support (QEMU + RPi)"
echo "✓ AI subsystem integration"
echo "✓ Improved serial communication"
echo ""
echo "Output Files:"
echo "- Kernel ELF: ${BUILD_DIR}/kernel.elf"
echo "- Kernel Image: ${BUILD_DIR}/kernel8.img"
echo "- Boot Config: ${BUILD_DIR}/boot_files/config.txt"
echo "- Archive: ${OUTPUT_DIR}/${ARCH}/${IMAGE_NAME}.tar.gz"
echo "- Directory: ${OUTPUT_DIR}/${ARCH}/${IMAGE_NAME}/"
echo ""
echo "Shell Commands Available:"
echo "- help          - Display available commands"
echo "- save <file> <content> - Save text to file"
echo "- cat <file>    - Display file contents"
echo "- ls            - List files"
echo "- pwd           - Show current directory"
echo "- clear         - Clear screen"
echo "- echo <text>   - Echo text"
echo "- meminfo       - Memory information"
echo "- version       - OS version"
echo "- reboot        - Reboot system"
echo "- append <file> <content> - Append to file"
echo "- delete <file> - Delete file"
echo "- fileinfo <file> - File information"
echo ""
echo "To test with QEMU:"
echo "qemu-system-aarch64 -M virt -cpu cortex-a76 -m 4096 \\"
echo "  -kernel ${BUILD_DIR}/kernel.elf -nographic -no-reboot"
echo ""
echo "To flash to SD card:"
echo "1. Extract ${OUTPUT_DIR}/${ARCH}/${IMAGE_NAME}.tar.gz to SD card"
echo "2. Insert SD card into Raspberry Pi 5"
echo "3. Connect serial console (115200 baud)"
echo "4. Power on and enjoy SAGE OS!"
echo "=========================================="