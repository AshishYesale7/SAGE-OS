#!/bin/bash

# SAGE OS macOS Graphics Mode Setup Script
# For Apple Silicon (M1/M2/M3) Macs

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🍎 SAGE OS macOS Graphics Mode Setup${NC}"
echo "========================================"
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ This script is for macOS only${NC}"
    exit 1
fi

# Check if running on Apple Silicon
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
    echo -e "${GREEN}✅ Apple Silicon detected: $ARCH${NC}"
else
    echo -e "${YELLOW}⚠️  Intel Mac detected: $ARCH${NC}"
fi

echo ""

# Check if Homebrew is installed
if ! command -v brew >/dev/null 2>&1; then
    echo -e "${RED}❌ Homebrew not found${NC}"
    echo "Please install Homebrew first:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

echo -e "${GREEN}✅ Homebrew found${NC}"

# Check if cross-compiler is installed
if command -v x86_64-unknown-linux-gnu-gcc >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Cross-compiler already installed${NC}"
    CC_PATH=$(which x86_64-unknown-linux-gnu-gcc)
    echo "   Path: $CC_PATH"
else
    echo -e "${YELLOW}⚠️  Cross-compiler not found, installing...${NC}"
    echo ""
    echo "Installing x86_64 cross-compilation toolchain..."
    brew install x86_64-unknown-linux-gnu
    
    if command -v x86_64-unknown-linux-gnu-gcc >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Cross-compiler installed successfully${NC}"
        CC_PATH=$(which x86_64-unknown-linux-gnu-gcc)
        echo "   Path: $CC_PATH"
    else
        echo -e "${RED}❌ Cross-compiler installation failed${NC}"
        exit 1
    fi
fi

echo ""

# Check if QEMU is installed
if command -v qemu-system-i386 >/dev/null 2>&1; then
    echo -e "${GREEN}✅ QEMU already installed${NC}"
    QEMU_PATH=$(which qemu-system-i386)
    echo "   Path: $QEMU_PATH"
else
    echo -e "${YELLOW}⚠️  QEMU not found, installing...${NC}"
    echo ""
    echo "Installing QEMU..."
    brew install qemu
    
    if command -v qemu-system-i386 >/dev/null 2>&1; then
        echo -e "${GREEN}✅ QEMU installed successfully${NC}"
        QEMU_PATH=$(which qemu-system-i386)
        echo "   Path: $QEMU_PATH"
    else
        echo -e "${RED}❌ QEMU installation failed${NC}"
        exit 1
    fi
fi

echo ""

# Test the graphics build
echo -e "${MAGENTA}🧪 Testing graphics build...${NC}"
echo ""

if ./build-graphics.sh i386 build; then
    echo ""
    echo -e "${GREEN}🎉 Graphics build test successful!${NC}"
    echo ""
    echo -e "${CYAN}🎮 Ready to run graphics mode:${NC}"
    echo ""
    echo "  # Test graphics mode (10-second demo)"
    echo "  ./build.sh test-graphics"
    echo ""
    echo "  # Run interactive graphics mode"
    echo "  qemu-system-i386 -kernel build/i386-graphics/kernel.elf -m 128M"
    echo ""
    echo "  # Run with VNC (for remote access)"
    echo "  qemu-system-i386 -kernel build/i386-graphics/kernel.elf -m 128M -vnc :0"
    echo ""
    echo -e "${YELLOW}💡 Note for Apple Silicon Macs:${NC}"
    echo "  QEMU will emulate x86 on your ARM processor"
    echo "  Performance may be slower than native execution"
    echo "  Graphics mode will work perfectly despite emulation"
    echo ""
else
    echo ""
    echo -e "${RED}❌ Graphics build test failed${NC}"
    echo ""
    echo "Please check the error messages above and try:"
    echo "  1. Restart your terminal"
    echo "  2. Run: export PATH=\"/opt/homebrew/bin:\$PATH\""
    echo "  3. Run this setup script again"
    echo ""
    exit 1
fi

echo -e "${GREEN}✅ macOS Graphics Mode Setup Complete!${NC}"
echo ""
echo -e "${CYAN}🚀 SAGE OS Graphics Mode is ready to use on your Mac!${NC}"