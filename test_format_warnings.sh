#!/bin/bash

echo "🧪 Testing QEMU Format Warning Fix"
echo "=================================="

cd /workspace/SAGE-OS

echo ""
echo "🔧 Test 1: Old format (should show warning)"
echo "Command: qemu-system-i386 -fda sage_os_minimal.img -boot a -m 128M -vnc :16"
timeout 2s qemu-system-i386 -fda sage_os_minimal.img -boot a -m 128M -vnc :16 -no-fd-bootchk -name "Old Format Test" 2>&1 | head -5

echo ""
echo "🔧 Test 2: New format (should be clean)"
echo "Command: qemu-system-i386 -drive file=sage_os_minimal.img,format=raw,if=floppy -boot a -m 128M -vnc :17"
timeout 2s qemu-system-i386 -drive file=sage_os_minimal.img,format=raw,if=floppy -boot a -m 128M -vnc :17 -no-fd-bootchk -name "New Format Test" 2>&1 | head -5

echo ""
echo "✅ **SOLUTION SUMMARY:**"
echo "========================"
echo ""
echo "❌ OLD (shows warning):"
echo "qemu-system-i386 -fda sage_os.img -boot a -m 128M -display cocoa -no-fd-bootchk"
echo ""
echo "✅ NEW (no warnings):"
echo "qemu-system-i386 -drive file=sage_os.img,format=raw,if=floppy -boot a -m 128M -display cocoa -no-fd-bootchk"
echo ""
echo "🎯 The macOS script has been updated to use the new format!"