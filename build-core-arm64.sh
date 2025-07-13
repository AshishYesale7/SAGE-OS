#!/bin/bash

# Core SAGE OS ARM64 Build Script with File Management (No AI)
# Copyright (c) 2025 Ashish Vasant Yesale

set -e

echo "=========================================="
echo "SAGE OS Core ARM64 Build System"
echo "=========================================="

# Configuration
ARCH="arm64"
TARGET="aarch64-linux-gnu"
BUILD_DIR="build/${ARCH}"
OUTPUT_DIR="build-output"
VERSION="1.0.1"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
IMAGE_NAME="SAGE-OS-${VERSION}-${TIMESTAMP}-${ARCH}-rpi5-core"

# Compiler settings optimized for Raspberry Pi 5 (Cortex-A76)
CC="${TARGET}-gcc"
OBJCOPY="${TARGET}-objcopy"
CFLAGS="-ffreestanding -nostdlib -nostartfiles -mcpu=cortex-a76 -mtune=cortex-a76 -O2 -Wall -Wextra"
LDFLAGS="-T linker.ld -nostdlib"

echo "Building core SAGE OS for ARM64 (Cortex-A76)..."
echo "Target: ${TARGET}"
echo "Build directory: ${BUILD_DIR}"
echo "Output directory: ${OUTPUT_DIR}"

# Create build directories
mkdir -p "${BUILD_DIR}/boot"
mkdir -p "${BUILD_DIR}/kernel"
mkdir -p "${BUILD_DIR}/drivers"
mkdir -p "${BUILD_DIR}/boot_files"
mkdir -p "${OUTPUT_DIR}/${ARCH}"

echo "Compiling boot loader..."
${CC} ${CFLAGS} -c boot/boot_aarch64.S -o "${BUILD_DIR}/boot/boot.o"

echo "Compiling kernel components..."
${CC} ${CFLAGS} -c kernel/kernel.c -o "${BUILD_DIR}/kernel/kernel.o"
${CC} ${CFLAGS} -c kernel/memory.c -o "${BUILD_DIR}/kernel/memory.o"
${CC} ${CFLAGS} -c kernel/shell_core.c -o "${BUILD_DIR}/kernel/shell.o"
${CC} ${CFLAGS} -c kernel/stdio.c -o "${BUILD_DIR}/kernel/stdio.o"
${CC} ${CFLAGS} -c kernel/utils.c -o "${BUILD_DIR}/kernel/utils.o"
${CC} ${CFLAGS} -c kernel/filesystem.c -o "${BUILD_DIR}/kernel/filesystem.o"

echo "Compiling drivers..."
${CC} ${CFLAGS} -c drivers/serial.c -o "${BUILD_DIR}/drivers/serial.o"
${CC} ${CFLAGS} -c drivers/uart.c -o "${BUILD_DIR}/drivers/uart.o"
${CC} ${CFLAGS} -c drivers/vga.c -o "${BUILD_DIR}/drivers/vga.o"

echo "Linking kernel..."
${CC} ${LDFLAGS} \
    "${BUILD_DIR}/boot/boot.o" \
    "${BUILD_DIR}/kernel/kernel.o" \
    "${BUILD_DIR}/kernel/memory.o" \
    "${BUILD_DIR}/kernel/shell.o" \
    "${BUILD_DIR}/kernel/stdio.o" \
    "${BUILD_DIR}/kernel/utils.o" \
    "${BUILD_DIR}/kernel/filesystem.o" \
    "${BUILD_DIR}/drivers/serial.o" \
    "${BUILD_DIR}/drivers/uart.o" \
    "${BUILD_DIR}/drivers/vga.o" \
    -o "${BUILD_DIR}/kernel.elf"

echo "Creating kernel image..."
${OBJCOPY} -O binary "${BUILD_DIR}/kernel.elf" "${BUILD_DIR}/kernel8.img"

echo "Creating Raspberry Pi 5 configuration..."
cat > "${BUILD_DIR}/boot_files/config.txt" << EOF
# SAGE OS Raspberry Pi 5 Configuration
# Core ARM64 Edition with File Management

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

# Boot configuration
disable_splash=1
boot_delay=0

# SAGE OS Core Features
# File management system enabled
# Persistent memory storage enabled
# ARM64 optimizations enabled
EOF

# Copy files to boot directory
cp "${BUILD_DIR}/kernel.elf" "${BUILD_DIR}/boot_files/"
cp "${BUILD_DIR}/kernel8.img" "${BUILD_DIR}/boot_files/"

echo "Creating bootable SD card image..."

# Create output directory
mkdir -p "${OUTPUT_DIR}/${ARCH}"

# Create a bootable SD card image (32MB)
IMG_SIZE=32M
IMG_FILE="${OUTPUT_DIR}/${ARCH}/${IMAGE_NAME}.img"

# Create empty image file
dd if=/dev/zero of="${IMG_FILE}" bs=1M count=32 2>/dev/null

# Create FAT32 filesystem
mkfs.fat -F32 "${IMG_FILE}" >/dev/null 2>&1

# Create temporary mount point
MOUNT_POINT="/tmp/sage_os_mount_$$"
mkdir -p "${MOUNT_POINT}"

# Mount the image
mount -o loop "${IMG_FILE}" "${MOUNT_POINT}" 2>/dev/null || {
    echo "Warning: Could not mount image file. Creating directory structure instead."
    # Fallback: create directory structure
    mkdir -p "${OUTPUT_DIR}/${ARCH}/${IMAGE_NAME}"
    cp "${BUILD_DIR}/boot_files/"* "${OUTPUT_DIR}/${ARCH}/${IMAGE_NAME}/"
    
    # Also create a simple .img file by concatenating kernel
    cp "${BUILD_DIR}/kernel8.img" "${IMG_FILE}"
    echo "Created simple kernel image: ${IMG_FILE}"
    
    # Create tar.gz as backup
    cd "${BUILD_DIR}/boot_files"
    tar -czf "../../../${OUTPUT_DIR}/${ARCH}/${IMAGE_NAME}.tar.gz" *
    cd - > /dev/null
    
    # Skip to end
    MOUNT_SUCCESS=false
}

if [ "${MOUNT_SUCCESS}" != "false" ]; then
    # Copy boot files to mounted image
    cp "${BUILD_DIR}/boot_files/"* "${MOUNT_POINT}/"
    
    # Unmount
    umount "${MOUNT_POINT}" 2>/dev/null
    rmdir "${MOUNT_POINT}"
    
    echo "Created bootable SD card image: ${IMG_FILE}"
fi

# Also create directory structure for easy access
mkdir -p "${OUTPUT_DIR}/${ARCH}/${IMAGE_NAME}"
cp "${BUILD_DIR}/boot_files/"* "${OUTPUT_DIR}/${ARCH}/${IMAGE_NAME}/"

echo "Build completed successfully!"
echo ""
echo "=========================================="
echo "SAGE OS Core ARM64 Build Summary"
echo "=========================================="
echo "Version: ${VERSION}"
echo "Architecture: ARM64 (Cortex-A76 optimized)"
echo "Target Device: Raspberry Pi 5"
echo "Build Time: ${TIMESTAMP}"
echo ""
echo "Core Features Included:"
echo "✓ Enhanced file management system"
echo "✓ In-memory persistent storage"
echo "✓ Advanced shell commands (save, cat, ls, pwd, etc.)"
echo "✓ ARM64 Cortex-A76 optimizations"
echo "✓ Dual UART support (QEMU + RPi)"
echo "✓ Improved serial communication"
echo "✓ Memory management"
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