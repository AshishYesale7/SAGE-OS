#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
#
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS Graphics Mode Local Test Script
# Run this on your local machine with graphics support

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🎮 SAGE OS Graphics Mode - Local Test${NC}"
echo "=============================================="

# Check if graphics kernel exists
GRAPHICS_KERNEL="build/x86_64-graphics/kernel.elf"

if [[ ! -f "$GRAPHICS_KERNEL" ]]; then
    echo -e "${RED}❌ Graphics kernel not found: $GRAPHICS_KERNEL${NC}"
    echo ""
    echo "Please build the graphics kernel first:"
    echo "  ./build-graphics.sh x86_64 build"
    exit 1
fi

echo -e "${GREEN}✅ Graphics kernel found: $GRAPHICS_KERNEL${NC}"

# Get kernel size
KERNEL_SIZE=$(du -h "$GRAPHICS_KERNEL" | cut -f1)
echo "Kernel size: $KERNEL_SIZE"

echo ""
echo -e "${BLUE}🎯 Graphics Mode Features${NC}"
echo "----------------------------------------"
echo "✅ VGA text mode (80x25 characters)"
echo "✅ 16-color display support"
echo "✅ Keyboard input handling"
echo "✅ Interactive shell with commands:"
echo "   • help     - Show available commands"
echo "   • version  - Show system information"
echo "   • clear    - Clear the screen"
echo "   • colors   - Test color display"
echo "   • demo     - Run demo sequence"
echo "   • reboot   - Restart system"
echo "   • exit     - Shutdown system"

echo ""
echo -e "${YELLOW}🚀 How to Run Graphics Mode${NC}"
echo "----------------------------------------"
echo ""
echo -e "${CYAN}Option 1: Basic Graphics Mode${NC}"
echo "qemu-system-i386 -kernel $GRAPHICS_KERNEL -m 128M"
echo ""
echo -e "${CYAN}Option 2: With Better Performance${NC}"
echo "qemu-system-i386 -kernel $GRAPHICS_KERNEL -m 128M -enable-kvm"
echo ""
echo -e "${CYAN}Option 3: With VNC (for remote access)${NC}"
echo "qemu-system-i386 -kernel $GRAPHICS_KERNEL -m 128M -vnc :1"
echo "Then connect with VNC viewer to localhost:5901"
echo ""
echo -e "${CYAN}Option 4: With SDL (if available)${NC}"
echo "qemu-system-i386 -kernel $GRAPHICS_KERNEL -m 128M -display sdl"

echo ""
echo -e "${MAGENTA}🎮 Interactive Experience${NC}"
echo "----------------------------------------"
echo "When SAGE OS boots in graphics mode, you'll see:"
echo ""
echo "1. 🎨 Beautiful ASCII art SAGE OS logo"
echo "2. 🌈 Colorful welcome message"
echo "3. 💻 Interactive shell prompt: sage@localhost:~$"
echo "4. ⌨️  Full keyboard support for typing commands"
echo "5. 🎯 Real-time command execution"

echo ""
echo -e "${GREEN}🔥 Key Advantages of Graphics Mode${NC}"
echo "----------------------------------------"
echo "✅ No more -nographic flag needed"
echo "✅ Visual feedback with colors"
echo "✅ Better user experience"
echo "✅ Keyboard input works naturally"
echo "✅ Can see the full SAGE OS interface"
echo "✅ Perfect for demonstrations"

echo ""
echo -e "${YELLOW}📋 Quick Start Commands${NC}"
echo "----------------------------------------"
echo "After booting, try these commands:"
echo ""
echo "sage@localhost:~$ help      # See all commands"
echo "sage@localhost:~$ version   # System information"
echo "sage@localhost:~$ colors    # Test color display"
echo "sage@localhost:~$ demo      # Run demo sequence"
echo "sage@localhost:~$ clear     # Clear screen"
echo "sage@localhost:~$ exit      # Shutdown"

echo ""
echo -e "${CYAN}🎉 Ready to Experience SAGE OS Graphics Mode!${NC}"
echo ""
echo -e "${GREEN}Copy and paste one of the QEMU commands above to start.${NC}"
echo ""

# If running on macOS, provide macOS-specific instructions
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "${BLUE}🍎 macOS Users${NC}"
    echo "----------------------------------------"
    echo "Make sure you have QEMU installed:"
    echo "  brew install qemu"
    echo ""
    echo "For best performance on Apple Silicon:"
    echo "  qemu-system-i386 -kernel $GRAPHICS_KERNEL -m 128M -accel hvf"
    echo ""
fi

echo -e "${MAGENTA}Enjoy the full SAGE OS graphics experience! 🚀${NC}"