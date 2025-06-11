#!/bin/bash

# SAGE-OS QEMU Testing Script
# Tests kernel builds in QEMU emulation

set -e

ARCH=${1:-i386}
TARGET=${2:-generic}

echo "🧪 Testing SAGE-OS $ARCH build in QEMU..."

# Check if kernel exists
if [ "$ARCH" = "i386" ]; then
    KERNEL_PATH="build/i386/kernel.img"
    QEMU_CMD="qemu-system-i386"
    QEMU_ARGS="-kernel $KERNEL_PATH -nographic -no-reboot"
elif [ "$ARCH" = "x86_64" ]; then
    KERNEL_PATH="build/x86_64/kernel.elf"
    QEMU_CMD="qemu-system-i386"
    QEMU_ARGS="-kernel $KERNEL_PATH -nographic -no-reboot"
elif [ "$ARCH" = "aarch64" ]; then
    KERNEL_PATH="build/aarch64/kernel.img"
    QEMU_CMD="qemu-system-aarch64"
    QEMU_ARGS="-M virt -cpu cortex-a72 -m 1G -kernel $KERNEL_PATH -nographic -no-reboot"
elif [ "$ARCH" = "arm" ]; then
    KERNEL_PATH="build/arm/kernel.img"
    QEMU_CMD="qemu-system-arm"
    QEMU_ARGS="-M versatilepb -cpu arm1176 -m 256M -kernel $KERNEL_PATH -nographic -no-reboot"
else
    echo "❌ Unsupported architecture: $ARCH"
    exit 1
fi

if [ ! -f "$KERNEL_PATH" ]; then
    echo "❌ Kernel not found: $KERNEL_PATH"
    echo "   Run: make ARCH=$ARCH"
    exit 1
fi

echo "🚀 Starting QEMU for $ARCH..."
echo "   Kernel: $KERNEL_PATH"
echo "   Command: $QEMU_CMD $QEMU_ARGS"
echo ""
echo "⏰ Test will run for 10 seconds, then exit"
echo "   Look for 'SAGE-OS' boot message and shell prompt"
echo ""

# Run QEMU with timeout
timeout 10s $QEMU_CMD $QEMU_ARGS || {
    exit_code=$?
    if [ $exit_code -eq 124 ]; then
        echo ""
        echo "✅ QEMU test completed (10 second timeout reached)"
        echo "   If you saw boot messages, the kernel is working!"
    else
        echo ""
        echo "❌ QEMU test failed with exit code: $exit_code"
        exit 1
    fi
}

echo ""
echo "🎉 Test completed for $ARCH architecture"
echo ""
echo "💡 To run interactively:"
echo "   $QEMU_CMD $QEMU_ARGS"
echo ""