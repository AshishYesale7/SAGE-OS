#!/bin/bash

# Install QEMU with Cocoa Support on Mac M1
echo "🍎 Installing QEMU with Cocoa Support for Mac M1"
echo "================================================"

# Detect Mac architecture
ARCH=$(uname -m)
echo "🔍 Detected architecture: $ARCH"

if [[ "$ARCH" == "arm64" ]]; then
    echo "✅ Apple Silicon Mac detected (M1/M2)"
    echo "📝 Note: VNC is more reliable than Cocoa on Apple Silicon"
else
    echo "✅ Intel Mac detected"
    echo "📝 Note: Cocoa works well on Intel Macs"
fi

echo ""

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew not found. Installing Homebrew first..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon
    if [[ "$ARCH" == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "✅ Homebrew found"
fi

echo ""
echo "🔄 Updating Homebrew..."
brew update

echo ""
echo "🔍 Checking current QEMU installation..."

# Check if QEMU is already installed
if command -v qemu-system-i386 &> /dev/null; then
    echo "📦 QEMU is already installed"
    
    # Check if it has Cocoa support
    if qemu-system-i386 -display help 2>/dev/null | grep -q cocoa; then
        echo "✅ QEMU already has Cocoa support!"
        echo ""
        echo "🎮 You can now use Cocoa display with:"
        echo "   ./sage-os-macos.sh"
        echo ""
        echo "🔍 Available display backends:"
        qemu-system-i386 -display help 2>/dev/null
        exit 0
    else
        echo "❌ Current QEMU doesn't have Cocoa support"
        echo "🔄 Reinstalling QEMU with Cocoa support..."
        brew uninstall qemu 2>/dev/null || true
    fi
else
    echo "📦 QEMU not found, installing..."
fi

echo ""
echo "⬇️  Installing QEMU with Cocoa support..."
brew install qemu

echo ""
echo "🔍 Verifying installation..."

if command -v qemu-system-i386 &> /dev/null; then
    echo "✅ QEMU installed successfully!"
    
    # Check Cocoa support
    if qemu-system-i386 -display help 2>/dev/null | grep -q cocoa; then
        echo "✅ Cocoa support confirmed!"
        echo ""
        echo "🎮 Available display backends:"
        qemu-system-i386 -display help 2>/dev/null | grep -E "(cocoa|vnc|none)"
        echo ""
        
        if [[ "$ARCH" == "arm64" ]]; then
            echo "🍎 Apple Silicon Recommendations:"
            echo "   • Primary: Use VNC display (more reliable)"
            echo "   • Backup: Use Cocoa display"
            echo "   • Command: ./sage-os-macos.sh (auto-detects best option)"
        else
            echo "🍎 Intel Mac Recommendations:"
            echo "   • Primary: Use Cocoa display (native performance)"
            echo "   • Backup: Use VNC display"
            echo "   • Command: ./sage-os-macos.sh (auto-detects best option)"
        fi
        
        echo ""
        echo "🚀 Test SAGE OS now:"
        echo "   ./sage-os-macos.sh"
        echo "   ./quick_test_sage_os.sh"
        
    else
        echo "❌ Cocoa support not found in installed QEMU"
        echo "🔧 Try manual installation or use VNC instead"
    fi
else
    echo "❌ QEMU installation failed"
    echo "🔧 Try manual installation:"
    echo "   brew install qemu"
fi

echo ""
echo "📋 Installation Summary:"
echo "========================"
echo "Architecture: $ARCH"
echo "QEMU Version: $(qemu-system-i386 --version 2>/dev/null | head -1 || echo 'Not installed')"
echo "Cocoa Support: $(qemu-system-i386 -display help 2>/dev/null | grep -q cocoa && echo 'Yes' || echo 'No')"
echo "VNC Support: $(qemu-system-i386 -display help 2>/dev/null | grep -q vnc && echo 'Yes' || echo 'No')"
echo ""
echo "🎉 Setup complete! You can now run SAGE OS with display support."