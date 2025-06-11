#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# Test SAGE OS in QEMU emulator
# Usage: ./scripts/test_emulated.sh [architecture] [timeout]

# Default architecture is aarch64
ARCH=${1:-aarch64}
# Default timeout is 10 seconds
TIMEOUT=${2:-10}

# Validate architecture
case $ARCH in
    x86_64|arm64|aarch64|riscv64)
        echo "Testing on $ARCH architecture"
        ;;
    *)
        echo "Error: Unsupported architecture: $ARCH"
        echo "Supported architectures: x86_64, arm64, aarch64, riscv64"
        exit 1
        ;;
esac

# Check if build directory exists
if [ ! -d "build/$ARCH" ]; then
    echo "Error: Build directory not found at build/$ARCH"
    echo "Please run 'make ARCH=$ARCH' first"
    exit 1
fi

# List available build artifacts
echo "Available build artifacts:"
find build/$ARCH -type f | sort

# Check if kernel image exists
if [ -f "build/$ARCH/kernel.img" ]; then
    KERNEL_IMG="build/$ARCH/kernel.img"
elif [ -f "build/$ARCH/kernel8.img" ]; then
    KERNEL_IMG="build/$ARCH/kernel8.img"
elif [ -f "build/$ARCH/kernel.elf" ]; then
    KERNEL_IMG="build/$ARCH/kernel.elf"
else
    echo "Error: No kernel image found in build/$ARCH/"
    exit 1
fi

echo "Using kernel image: $KERNEL_IMG"

echo "Testing SAGE OS on $ARCH architecture..."

# Set up QEMU parameters based on architecture
case $ARCH in
    x86_64)
        QEMU_CMD="qemu-system-x86_64 -kernel $KERNEL_IMG -nographic -no-reboot"
        ;;
    arm64|aarch64)
        QEMU_CMD="qemu-system-aarch64 -machine virt -cpu cortex-a57 -kernel $KERNEL_IMG -nographic -no-reboot"
        ;;
    riscv64)
        QEMU_CMD="qemu-system-riscv64 -machine virt -kernel $KERNEL_IMG -nographic -no-reboot"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Run QEMU with timeout
echo "Running: $QEMU_CMD"
timeout $TIMEOUT $QEMU_CMD || true

echo "Test completed for $ARCH architecture"
exit 0