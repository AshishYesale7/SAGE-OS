#!/bin/bash

echo "🚀 Quick SAGE OS Test"
echo "===================="

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if image exists
if [ ! -f "build/macos/sage_os_macos.img" ]; then
    echo "❌ SAGE OS image not found. Run ./sage-os-macos.sh first to build it."
    exit 1
fi

echo "✅ Found SAGE OS image: build/macos/sage_os_macos.img"
echo "📏 Image size: $(ls -lh build/macos/sage_os_macos.img | awk '{print $5}')"

# Check boot signature
echo "🔍 Checking boot signature..."
BOOT_SIG=$(od -tx1 -j510 -N2 build/macos/sage_os_macos.img | head -1 | awk '{print $2 $3}')
if [ "$BOOT_SIG" = "55aa" ]; then
    echo "✅ Boot signature valid: 0x55AA"
else
    echo "❌ Invalid boot signature: 0x$BOOT_SIG"
fi

echo ""
echo "🎮 Quick Launch Options:"
echo "========================"
echo ""
echo "1. 🖥️  VNC (recommended for Apple Silicon):"
echo "   qemu-system-i386 -drive file=build/macos/sage_os_macos.img,format=raw,if=floppy,readonly=on -boot a -m 128M -vnc :1 -no-fd-bootchk &"
echo "   Then connect to localhost:5901 with Screen Sharing"
echo ""
echo "2. 🍎 Cocoa (for Intel Macs):"
echo "   qemu-system-i386 -drive file=build/macos/sage_os_macos.img,format=raw,if=floppy,readonly=on -boot a -m 128M -display cocoa -no-fd-bootchk"
echo ""
echo "3. 🧪 Test with minimal bootloader:"
if [ -f "sage_os_minimal.img" ]; then
    echo "   qemu-system-i386 -drive file=sage_os_minimal.img,format=raw,if=floppy,readonly=on -boot a -m 128M -vnc :2 -no-fd-bootchk &"
    echo "   Then connect to localhost:5902"
else
    echo "   (minimal bootloader not found - run create_minimal_bootloader.py first)"
fi

echo ""
echo "🎯 What you should see:"
echo "- Black screen with white text"
echo "- 'SAGE OS' bootloader message"
echo "- System ready prompt"
echo "- No 'Boot failed' errors"

echo ""
read -p "🚀 Launch SAGE OS with VNC now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🎮 Starting SAGE OS with VNC..."
    qemu-system-i386 \
        -drive file=build/macos/sage_os_macos.img,format=raw,if=floppy,readonly=on \
        -boot a \
        -m 128M \
        -vnc :1 \
        -no-fd-bootchk \
        -no-reboot \
        -name "SAGE OS Quick Test" &
    
    QEMU_PID=$!
    sleep 2
    
    if ps -p $QEMU_PID > /dev/null 2>&1; then
        echo "✅ SAGE OS started successfully!"
        echo "📺 Connect to localhost:5901 with VNC viewer"
        echo "   (Screen Sharing app on macOS)"
        echo ""
        echo "Press Enter to stop QEMU..."
        read
        kill $QEMU_PID 2>/dev/null
        echo "🛑 SAGE OS stopped"
    else
        echo "❌ Failed to start SAGE OS"
    fi
else
    echo "👍 Use the commands above to launch SAGE OS manually"
fi