#!/bin/bash
# 🔧 SAGE-OS Quick Fix & Run Script for macOS M1
# This script fixes build issues and launches SAGE-OS in QEMU

set -e  # Exit on any error

echo "🔧 SAGE-OS Quick Fix & Run Script for macOS M1"
echo "=============================================="

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "⚠️  This script is designed for macOS. You may need to adjust commands for your OS."
fi

# Check if QEMU is installed
if ! command -v qemu-system-i386 &> /dev/null; then
    echo "❌ QEMU not found. Installing via Homebrew..."
    if command -v brew &> /dev/null; then
        brew install qemu
    else
        echo "❌ Homebrew not found. Please install QEMU manually:"
        echo "   Visit: https://www.qemu.org/download/"
        exit 1
    fi
fi

echo "✅ QEMU found: $(qemu-system-i386 --version | head -1)"

# Clean and build
echo ""
echo "📦 Building SAGE-OS for i386..."
echo "--------------------------------"
make clean
make ARCH=i386 TARGET=generic

# Check build success
if [ -f "build/i386/kernel.img" ]; then
    echo ""
    echo "✅ Build successful!"
    echo "📄 Kernel: build/i386/kernel.img ($(stat -f%z build/i386/kernel.img) bytes)"
    echo "📦 Output: output/i386/sage-os-v1.0.1-i386-generic.img"
    
    echo ""
    echo "🚀 Choose QEMU mode:"
    echo "1) Graphics mode (recommended) - Full GUI with keyboard"
    echo "2) Serial console mode - Text only in terminal"
    echo "3) Debug mode - Graphics + debug output"
    echo "4) Exit without running"
    
    while true; do
        read -p "Enter choice (1-4): " choice
        case $choice in
            1)
                echo ""
                echo "🖥️ Starting SAGE-OS in Graphics Mode..."
                echo "💡 Click inside the QEMU window to capture keyboard input"
                echo "💡 Press Ctrl+Alt+G to release mouse/keyboard from QEMU"
                echo ""
                qemu-system-i386 \
                  -kernel build/i386/kernel.img \
                  -m 128M \
                  -vga std \
                  -display cocoa \
                  -no-reboot \
                  -boot n \
                  -accel tcg \
                  -name "SAGE-OS v1.0.1" \
                  -rtc base=localtime
                break
                ;;
            2)
                echo ""
                echo "📟 Starting SAGE-OS in Serial Console Mode..."
                echo "💡 Press Ctrl+A then X to exit QEMU"
                echo ""
                qemu-system-i386 \
                  -kernel build/i386/kernel.img \
                  -m 128M \
                  -nographic \
                  -no-reboot \
                  -boot n \
                  -accel tcg
                break
                ;;
            3)
                echo ""
                echo "🔍 Starting SAGE-OS in Debug Mode..."
                echo "💡 Monitor console available in terminal"
                echo ""
                qemu-system-i386 \
                  -kernel build/i386/kernel.img \
                  -m 128M \
                  -vga std \
                  -display cocoa \
                  -monitor stdio \
                  -no-reboot \
                  -boot n \
                  -accel tcg \
                  -d guest_errors \
                  -name "SAGE-OS Debug"
                break
                ;;
            4)
                echo "👋 Exiting without running QEMU"
                exit 0
                ;;
            *)
                echo "❌ Invalid choice. Please enter 1, 2, 3, or 4."
                ;;
        esac
    done
    
    echo ""
    echo "✅ SAGE-OS session ended"
    echo ""
    echo "🧪 Available commands in SAGE-OS:"
    echo "   help      - Show all commands"
    echo "   version   - Show OS version"
    echo "   meminfo   - Memory information"
    echo "   clear     - Clear screen"
    echo "   ls        - List files"
    echo "   pwd       - Current directory"
    echo "   whoami    - Current user"
    echo "   uptime    - System uptime"
    
else
    echo ""
    echo "❌ Build failed!"
    echo "🔍 Check the error messages above for details."
    echo ""
    echo "🛠️ Common fixes:"
    echo "   1. Make sure you have GCC or Clang installed"
    echo "   2. Check that all source files are present"
    echo "   3. Try: make clean && make ARCH=i386 TARGET=generic"
    exit 1
fi

echo ""
echo "🎉 Script completed successfully!"