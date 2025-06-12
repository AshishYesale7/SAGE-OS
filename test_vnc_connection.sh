#!/bin/bash

# Test VNC Connection for SAGE OS
echo "🔍 Testing VNC Connection for SAGE OS"
echo "====================================="

# Function to find available VNC port
find_available_vnc_port() {
    for port in {1..10}; do
        if ! lsof -i :$((5900 + port)) >/dev/null 2>&1; then
            echo $port
            return
        fi
    done
    echo "1"  # fallback to port 1
}

# Check if image exists
if [ ! -f "build/macos/sage_os_macos.img" ]; then
    echo "❌ SAGE OS image not found. Run ./sage-os-macos.sh first to build it."
    exit 1
fi

# Find available VNC port
VNC_PORT=$(find_available_vnc_port)
VNC_DISPLAY_PORT=$((5900 + VNC_PORT))

echo "🎮 Starting SAGE OS with VNC (no password)..."
echo "   VNC Port: :$VNC_PORT"
echo "   Display Port: localhost:$VNC_DISPLAY_PORT"
echo ""

# Start QEMU with VNC
qemu-system-i386 \
    -drive file=build/macos/sage_os_macos.img,format=raw,if=floppy,readonly=on \
    -boot a \
    -m 128M \
    -vnc :$VNC_PORT,password=off \
    -no-fd-bootchk \
    -no-reboot \
    -name "SAGE OS VNC Test" &

QEMU_PID=$!
sleep 3

if ps -p $QEMU_PID > /dev/null 2>&1; then
    echo "✅ QEMU started successfully!"
    echo ""
    echo "🔗 VNC Connection Details:"
    echo "   Server: localhost:$VNC_DISPLAY_PORT"
    echo "   Password: None (leave blank)"
    echo ""
    echo "📱 How to connect:"
    echo "   1. Open 'Screen Sharing' app on macOS"
    echo "   2. Enter: localhost:$VNC_DISPLAY_PORT"
    echo "   3. When prompted for password, leave blank and click 'Connect'"
    echo "   4. Or click 'Connect' without entering anything"
    echo ""
    echo "🎯 Expected display:"
    echo "   - Black screen with white text"
    echo "   - 'SAGE OS Bootloader Working!' message"
    echo "   - 'System Ready - Press any key' prompt"
    echo ""
    echo "Press Enter to stop QEMU..."
    read
    kill $QEMU_PID 2>/dev/null
    echo "🛑 QEMU stopped"
else
    echo "❌ Failed to start QEMU"
    exit 1
fi