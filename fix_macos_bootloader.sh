#!/bin/bash

# Fix the macOS bootloader issue
echo "🔧 Fixing macOS bootloader issue..."

# Copy the working bootloader
cp working_bootloader.bin build/macos/bootloader.bin

# Recreate the disk image properly
echo "📀 Creating fixed disk image..."
dd if=/dev/zero of="build/macos/sage_os_macos.img" bs=1024 count=1440 2>/dev/null
dd if="build/macos/bootloader.bin" of="build/macos/sage_os_macos.img" bs=512 count=1 conv=notrunc 2>/dev/null

echo "✅ Fixed macOS disk image!"
echo ""
echo "🚀 Test with:"
echo "qemu-system-i386 -fda build/macos/sage_os_macos.img -m 128M -display cocoa"
echo ""
echo "You should now see:"
echo "- 'SAGE OS - Working!' message"
echo "- No more SeaBIOS boot failures"
echo "- A working bootloader that displays text"