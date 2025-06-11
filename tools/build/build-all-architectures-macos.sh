#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS - Build All Architectures Script (macOS Compatible)
# This script builds SAGE OS for all supported architectures on macOS
# Compatible with macOS default bash (3.2+) and handles missing RISC-V toolchain

echo "🍎 SAGE OS Multi-Architecture Build (macOS)"
echo "============================================"

# Enable AI subsystem
export ENABLE_AI=ON

# Create output directory
OUTPUT_DIR="build-output"
mkdir -p "$OUTPUT_DIR"

# Build counter
TOTAL_BUILDS=0
SUCCESSFUL_BUILDS=0
FAILED_BUILDS=0

# Define build targets (compatible with older bash)
# Skip RISC-V on macOS if toolchain is not available
BUILD_TARGETS=(
    "aarch64:rpi4"
    "aarch64:rpi5" 
    "aarch64:generic"
    "arm:rpi4"
    "arm:rpi5"
    "arm:generic"
    "x86_64:generic"
)

# Check if RISC-V toolchain is available
if command -v riscv64-linux-gnu-gcc >/dev/null 2>&1 || [ -f "/opt/homebrew/bin/riscv64-linux-gnu-gcc" ]; then
    BUILD_TARGETS+=("riscv64:generic")
    echo "✅ RISC-V toolchain found, including RISC-V builds"
else
    echo "⚠️  RISC-V toolchain not found, skipping RISC-V builds"
    echo "   To install: brew install riscv64-elf-gcc"
fi

echo ""
echo "📋 Build Plan:"
for target in "${BUILD_TARGETS[@]}"; do
    arch="${target%:*}"
    platform="${target#*:}"
    echo "   - $arch ($platform)"
    TOTAL_BUILDS=$((TOTAL_BUILDS + 1))
done
echo ""

# Build each architecture/platform combination
for target in "${BUILD_TARGETS[@]}"; do
    arch="${target%:*}"
    platform="${target#*:}"
    echo "🔨 Building $arch ($platform)..."
    
    if make -f Makefile.multi-arch kernel ARCH="$arch" PLATFORM="$platform" 2>/dev/null; then
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
        
        SUCCESSFUL_BUILDS=$((SUCCESSFUL_BUILDS + 1))
    else
        echo "❌ $arch ($platform) build failed"
        FAILED_BUILDS=$((FAILED_BUILDS + 1))
    fi
    echo ""
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
    if [ $SUCCESSFUL_BUILDS -gt 0 ]; then
        echo "✅ $SUCCESSFUL_BUILDS out of $TOTAL_BUILDS builds were successful."
    fi
    exit 1
fi