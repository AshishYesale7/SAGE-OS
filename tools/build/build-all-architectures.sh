#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS - Build All Architectures Script
# This script builds SAGE OS for all supported architectures

# set -e  # Disable exit on error for now

echo "🏗️  SAGE OS Multi-Architecture Build"
echo "===================================="

# Enable AI subsystem
export ENABLE_AI=ON

# Define architectures and platforms
declare -A ARCH_PLATFORMS
ARCH_PLATFORMS["aarch64"]="rpi4 rpi5 generic"
ARCH_PLATFORMS["arm"]="rpi4 rpi5 generic"
ARCH_PLATFORMS["x86_64"]="generic"
ARCH_PLATFORMS["riscv64"]="generic"

# Create output directory
OUTPUT_DIR="build-output"
mkdir -p "$OUTPUT_DIR"

# Build counter
TOTAL_BUILDS=0
SUCCESSFUL_BUILDS=0
FAILED_BUILDS=0

echo "📋 Build Plan:"
for arch in "${!ARCH_PLATFORMS[@]}"; do
    for platform in ${ARCH_PLATFORMS[$arch]}; do
        echo "   - $arch ($platform)"
        ((TOTAL_BUILDS++))
    done
done
echo ""

# Build each architecture/platform combination
for arch in "${!ARCH_PLATFORMS[@]}"; do
    for platform in ${ARCH_PLATFORMS[$arch]}; do
        echo "🔨 Building $arch ($platform)..."
        
        if ./build.sh build "$arch" "$platform"; then
            echo "✅ $arch ($platform) build successful"
            
            # Copy output files
            if [ -f "build/$arch/kernel.img" ]; then
                cp "build/$arch/kernel.img" "$OUTPUT_DIR/kernel-$arch-$platform.img"
                echo "   📦 Saved: $OUTPUT_DIR/kernel-$arch-$platform.img"
            fi
            
            if [ -f "build/$arch/kernel.elf" ]; then
                cp "build/$arch/kernel.elf" "$OUTPUT_DIR/kernel-$arch-$platform.elf"
                echo "   📦 Saved: $OUTPUT_DIR/kernel-$arch-$platform.elf"
            fi
            
            ((SUCCESSFUL_BUILDS++))
        else
            echo "❌ $arch ($platform) build failed"
            ((FAILED_BUILDS++))
        fi
        echo ""
    done
done

# Summary
echo "📊 Build Summary:"
echo "=================="
echo "Total builds:      $TOTAL_BUILDS"
echo "Successful builds: $SUCCESSFUL_BUILDS"
echo "Failed builds:     $FAILED_BUILDS"
echo ""

if [ $SUCCESSFUL_BUILDS -gt 0 ]; then
    echo "📁 Output files saved in: $OUTPUT_DIR/"
    echo "📋 Available kernel images:"
    ls -lh "$OUTPUT_DIR"/*.img 2>/dev/null || echo "   No .img files found"
    echo ""
    echo "📋 Available ELF files:"
    ls -lh "$OUTPUT_DIR"/*.elf 2>/dev/null || echo "   No .elf files found"
fi

if [ $FAILED_BUILDS -eq 0 ]; then
    echo "🎉 All builds completed successfully!"
    exit 0
else
    echo "⚠️  Some builds failed. Check the output above for details."
    exit 1
fi