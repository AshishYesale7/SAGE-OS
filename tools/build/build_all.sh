#!/bin/bash

# SAGE OS Build Script - All Architectures
# Author: Ashish Vasant Yesale
# Email: ashishyesale007@gmail.com

set -e

VERSION="v1.0.0"
DATE=$(date +%Y%m%d)
BUILD_DIR="build"

echo "🚀 Building SAGE OS ${VERSION} - ${DATE}"
echo "=================================================="

# Clean previous builds
echo "🧹 Cleaning previous builds..."
make clean

# Build all supported architectures
ARCHITECTURES=("i386" "x86_64" "aarch64" "riscv64")

for ARCH in "${ARCHITECTURES[@]}"; do
    echo ""
    echo "🔨 Building ${ARCH} architecture..."
    echo "----------------------------------------"
    
    if make ARCH=${ARCH}; then
        echo "✅ ${ARCH} build successful"
        
        # Create versioned kernel image
        KERNEL_OUTPUT="${BUILD_DIR}/${ARCH}/sage-os-${ARCH}-${VERSION}-${DATE}.img"
        cp "${BUILD_DIR}/${ARCH}/kernel.img" "${KERNEL_OUTPUT}"
        echo "📦 Created: ${KERNEL_OUTPUT}"
        
        # Create ISO for x86 architectures
        if [[ "${ARCH}" == "i386" || "${ARCH}" == "x86_64" ]]; then
            echo "💿 Creating bootable ISO for ${ARCH}..."
            mkdir -p "${BUILD_DIR}/${ARCH}/iso/boot/grub"
            cp "${BUILD_DIR}/${ARCH}/kernel.img" "${BUILD_DIR}/${ARCH}/iso/boot/kernel.img"
            cp grub.cfg "${BUILD_DIR}/${ARCH}/iso/boot/grub/"
            
            ISO_OUTPUT="${BUILD_DIR}/${ARCH}/sage-os-${ARCH}-${VERSION}-${DATE}.iso"
            grub-mkrescue -o "${ISO_OUTPUT}" "${BUILD_DIR}/${ARCH}/iso" 2>/dev/null
            echo "💿 Created: ${ISO_OUTPUT}"
        fi
        
    else
        echo "❌ ${ARCH} build failed"
    fi
done

echo ""
echo "📊 Build Summary"
echo "=================================================="
echo "Version: ${VERSION}"
echo "Date: ${DATE}"
echo "Built architectures:"

for ARCH in "${ARCHITECTURES[@]}"; do
    KERNEL_FILE="${BUILD_DIR}/${ARCH}/sage-os-${ARCH}-${VERSION}-${DATE}.img"
    if [[ -f "${KERNEL_FILE}" ]]; then
        SIZE=$(du -h "${KERNEL_FILE}" | cut -f1)
        echo "  ✅ ${ARCH}: ${SIZE} (${KERNEL_FILE})"
        
        if [[ "${ARCH}" == "i386" || "${ARCH}" == "x86_64" ]]; then
            ISO_FILE="${BUILD_DIR}/${ARCH}/sage-os-${ARCH}-${VERSION}-${DATE}.iso"
            if [[ -f "${ISO_FILE}" ]]; then
                ISO_SIZE=$(du -h "${ISO_FILE}" | cut -f1)
                echo "     💿 ISO: ${ISO_SIZE} (${ISO_FILE})"
            fi
        fi
    else
        echo "  ❌ ${ARCH}: Build failed"
    fi
done

echo ""
echo "🎉 Build completed!"
echo "=================================================="