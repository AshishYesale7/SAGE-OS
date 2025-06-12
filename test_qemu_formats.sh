#!/bin/bash

echo "🧪 Testing different QEMU boot formats for SAGE OS"
echo "=================================================="

cd /workspace/SAGE-OS

# Test 1: Explicit raw format
echo ""
echo "🔧 Test 1: Using explicit raw format"
echo "Command: qemu-system-i386 -drive file=build/macos/sage_os_macos.img,format=raw,if=floppy -m 128M -vnc :9"
timeout 3s qemu-system-i386 \
    -drive file=build/macos/sage_os_macos.img,format=raw,if=floppy \
    -m 128M \
    -vnc :9 \
    -no-reboot \
    -name "SAGE OS Test 1" &

TEST1_PID=$!
sleep 1
if ps -p $TEST1_PID > /dev/null 2>&1; then
    echo "✅ Test 1: QEMU started successfully with raw format"
    kill $TEST1_PID 2>/dev/null || true
    wait $TEST1_PID 2>/dev/null || true
else
    echo "❌ Test 1: Failed to start"
fi

# Test 2: Force floppy boot
echo ""
echo "🔧 Test 2: Force floppy boot order"
echo "Command: qemu-system-i386 -fda build/macos/sage_os_macos.img -boot a -m 128M -vnc :10"
timeout 3s qemu-system-i386 \
    -fda build/macos/sage_os_macos.img \
    -boot a \
    -m 128M \
    -vnc :10 \
    -no-reboot \
    -name "SAGE OS Test 2" &

TEST2_PID=$!
sleep 1
if ps -p $TEST2_PID > /dev/null 2>&1; then
    echo "✅ Test 2: QEMU started successfully with forced floppy boot"
    kill $TEST2_PID 2>/dev/null || true
    wait $TEST2_PID 2>/dev/null || true
else
    echo "❌ Test 2: Failed to start"
fi

# Test 3: Use working bootloader directly
echo ""
echo "🔧 Test 3: Using working_bootloader.bin directly"
if [ -f "working_bootloader.bin" ]; then
    # Create a proper floppy image from working bootloader
    dd if=/dev/zero of="test_floppy.img" bs=1024 count=1440 2>/dev/null
    dd if="working_bootloader.bin" of="test_floppy.img" bs=512 count=1 conv=notrunc 2>/dev/null
    
    echo "Command: qemu-system-i386 -fda test_floppy.img -boot a -m 128M -vnc :11"
    timeout 3s qemu-system-i386 \
        -fda test_floppy.img \
        -boot a \
        -m 128M \
        -vnc :11 \
        -no-reboot \
        -name "SAGE OS Test 3" &
    
    TEST3_PID=$!
    sleep 1
    if ps -p $TEST3_PID > /dev/null 2>&1; then
        echo "✅ Test 3: QEMU started successfully with working bootloader"
        kill $TEST3_PID 2>/dev/null || true
        wait $TEST3_PID 2>/dev/null || true
    else
        echo "❌ Test 3: Failed to start"
    fi
else
    echo "❌ Test 3: working_bootloader.bin not found"
fi

# Test 4: Check if it's a SeaBIOS issue - disable SeaBIOS
echo ""
echo "🔧 Test 4: Bypass SeaBIOS completely"
echo "Command: qemu-system-i386 -fda build/macos/sage_os_macos.img -boot a -m 128M -vnc :12 -no-fd-bootchk"
timeout 3s qemu-system-i386 \
    -fda build/macos/sage_os_macos.img \
    -boot a \
    -m 128M \
    -vnc :12 \
    -no-reboot \
    -no-fd-bootchk \
    -name "SAGE OS Test 4" &

TEST4_PID=$!
sleep 1
if ps -p $TEST4_PID > /dev/null 2>&1; then
    echo "✅ Test 4: QEMU started successfully bypassing SeaBIOS checks"
    kill $TEST4_PID 2>/dev/null || true
    wait $TEST4_PID 2>/dev/null || true
else
    echo "❌ Test 4: Failed to start"
fi

echo ""
echo "📋 Test Results Summary:"
echo "========================"
echo "If any test showed ✅, that format should work for you."
echo ""
echo "🎯 Recommended command based on tests:"
echo "qemu-system-i386 -fda build/macos/sage_os_macos.img -boot a -m 128M -display cocoa -no-fd-bootchk"
echo ""
echo "🔍 If all tests failed, the issue might be:"
echo "1. Bootloader code needs debugging"
echo "2. QEMU version compatibility"
echo "3. Host system configuration"