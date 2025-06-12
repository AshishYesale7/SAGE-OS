#!/bin/bash

echo "🔍 Debugging SAGE OS boot process..."
echo "===================================="

cd /workspace/SAGE-OS

# Let's run QEMU with more verbose output to see what's happening
echo "🚀 Starting QEMU with debug output..."
echo ""
echo "Command: qemu-system-i386 -fda build/macos/sage_os_macos.img -boot a -m 128M -vnc :13 -no-fd-bootchk -monitor stdio"
echo ""
echo "This will:"
echo "1. Force boot from floppy (-boot a)"
echo "2. Disable floppy boot checks (-no-fd-bootchk)"
echo "3. Show QEMU monitor for debugging"
echo ""
echo "You should connect to VNC on localhost:5913 to see the display"
echo "Press Ctrl+C to stop QEMU"
echo ""

# Run QEMU with monitor for debugging
qemu-system-i386 \
    -fda build/macos/sage_os_macos.img \
    -boot a \
    -m 128M \
    -vnc :13 \
    -no-fd-bootchk \
    -monitor stdio \
    -name "SAGE OS Debug"