#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# Create ISO image for SAGE OS

set -e

ARCH=${1:-x86_64}
BUILD_DIR="build/${ARCH}"
ISO_DIR="build/iso"
ISO_FILE="build/sage-os-${ARCH}.iso"

echo "Creating ISO image for ${ARCH} architecture..."

# Check if kernel exists
if [ ! -f "${BUILD_DIR}/kernel.elf" ]; then
    echo "Error: Kernel not found at ${BUILD_DIR}/kernel.elf"
    echo "Please build the kernel first: make ARCH=${ARCH}"
    exit 1
fi

# Create ISO directory structure
mkdir -p "${ISO_DIR}/boot/grub"

# Copy kernel
cp "${BUILD_DIR}/kernel.elf" "${ISO_DIR}/boot/kernel.elf"

# Create GRUB configuration
cat > "${ISO_DIR}/boot/grub/grub.cfg" << EOF
set timeout=0
set default=0

menuentry "SAGE OS ${ARCH}" {
    multiboot /boot/kernel.elf
    boot
}
EOF

# Check if grub-mkrescue is available
if command -v grub-mkrescue >/dev/null 2>&1; then
    echo "Creating ISO with grub-mkrescue..."
    grub-mkrescue -o "${ISO_FILE}" "${ISO_DIR}"
    echo "ISO created: ${ISO_FILE}"
elif command -v xorriso >/dev/null 2>&1; then
    echo "Creating ISO with xorriso..."
    xorriso -as mkisofs -R -J -c boot/grub/boot.cat -b boot/grub/eltorito.img \
            -no-emul-boot -boot-load-size 4 -boot-info-table \
            -o "${ISO_FILE}" "${ISO_DIR}"
    echo "ISO created: ${ISO_FILE}"
else
    echo "Warning: Neither grub-mkrescue nor xorriso found."
    echo "Cannot create bootable ISO image."
    echo "Kernel ELF file is available at: ${BUILD_DIR}/kernel.elf"
    exit 1
fi

# Test with QEMU if available
if command -v qemu-system-x86_64 >/dev/null 2>&1 && [ "${ARCH}" = "x86_64" ]; then
    echo ""
    echo "To test the ISO with QEMU, run:"
    echo "qemu-system-x86_64 -cdrom ${ISO_FILE} -nographic"
fi

echo "ISO creation completed successfully!"