#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS Graphics Mode Testing Script
# This script launches SAGE OS in QEMU with graphics mode and keyboard support

set -e

ARCH=${1:-i386}
TARGET=${2:-generic}
MEMORY=${3:-128M}

echo "🖥️  SAGE OS Graphics Mode Test"
echo "================================"
echo "Architecture: $ARCH"
echo "Target: $TARGET"
echo "Memory: $MEMORY"
echo ""

# Check if kernel exists
KERNEL_PATH="build/$ARCH/kernel.elf"
if [ ! -f "$KERNEL_PATH" ]; then
    echo "❌ Kernel not found: $KERNEL_PATH"
    echo "💡 Run: make ARCH=$ARCH TARGET=$TARGET"
    exit 1
fi

echo "✅ Kernel found: $KERNEL_PATH"
echo ""

# Architecture-specific QEMU command
case $ARCH in
    i386)
        QEMU_CMD="qemu-system-i386"
        QEMU_ARGS="-kernel $KERNEL_PATH -m $MEMORY -vga std -display gtk -device usb-kbd -device usb-mouse"
        ;;
    x86_64)
        QEMU_CMD="qemu-system-x86_64"
        QEMU_ARGS="-kernel $KERNEL_PATH -m $MEMORY -vga std -display gtk -device usb-kbd -device usb-mouse"
        ;;
    *)
        echo "❌ Graphics mode not supported for architecture: $ARCH"
        echo "💡 Graphics mode is currently supported for i386 and x86_64 only"
        exit 1
        ;;
esac

# Check if QEMU is available
if ! command -v $QEMU_CMD &> /dev/null; then
    echo "❌ $QEMU_CMD not found"
    echo "💡 Install QEMU: apt-get install qemu-system-x86"
    exit 1
fi

echo "🚀 Launching SAGE OS in graphics mode..."
echo "Command: $QEMU_CMD $QEMU_ARGS"
echo ""
echo "📋 Instructions:"
echo "  • SAGE OS will boot in a graphics window"
echo "  • Use keyboard to interact with the shell"
echo "  • Type 'help' to see available commands"
echo "  • Press Ctrl+Alt+G to release mouse cursor"
echo "  • Close window or press Ctrl+C to exit"
echo ""

# Launch QEMU
exec $QEMU_CMD $QEMU_ARGS