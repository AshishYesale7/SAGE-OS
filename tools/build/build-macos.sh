#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS macOS Build Wrapper
# Simplified build interface for macOS users

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🍎 SAGE OS macOS Build System${NC}"
echo "================================"

# Check if we're on macOS
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo -e "${RED}❌ This script is designed for macOS only${NC}"
    echo "Use ./build.sh for other platforms"
    exit 1
fi

# Check for Homebrew
if ! command -v brew >/dev/null 2>&1; then
    echo -e "${RED}❌ Homebrew not found${NC}"
    echo "Please install Homebrew first:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

# Function to show menu
show_menu() {
    echo ""
    echo -e "${BLUE}What would you like to do?${NC}"
    echo "1) 🔧 Install build dependencies"
    echo "2) 🏗️  Build for Raspberry Pi 4 (ARM64)"
    echo "3) 🏗️  Build for Raspberry Pi 5 (ARM64)"
    echo "4) 🏗️  Build for x86_64"
    echo "5) 🏗️  Build for all architectures"
    echo "6) 💿 Create SD card image for Raspberry Pi"
    echo "7) 💿 Create ISO image for x86_64"
    echo "8) 🧪 Test build with QEMU"
    echo "9) 🐳 Build with Docker"
    echo "10) 📊 Show build status"
    echo "11) 🧹 Clean build files"
    echo "12) ❓ Show detailed help"
    echo "0) 🚪 Exit"
    echo ""
    echo -n "Enter your choice [0-12]: "
}

# Function to install dependencies
install_deps() {
    echo -e "${YELLOW}📦 Installing build dependencies...${NC}"
    ./build.sh install-deps
    echo -e "${GREEN}✅ Dependencies installed successfully${NC}"
}

# Function to build for specific target
build_target() {
    local arch=$1
    local platform=$2
    local description=$3
    
    echo -e "${YELLOW}🏗️  Building SAGE OS for $description...${NC}"
    ./build.sh build "$arch" "$platform"
    echo -e "${GREEN}✅ Build completed for $description${NC}"
    
    # Show output location
    local kernel_path="build/$arch/kernel.img"
    if [[ -f "$kernel_path" ]]; then
        local size=$(du -h "$kernel_path" | cut -f1)
        echo -e "${BLUE}📁 Kernel image: $kernel_path ($size)${NC}"
    fi
}

# Function to create SD card image
create_sdcard() {
    echo -e "${YELLOW}💿 Creating SD card image for Raspberry Pi...${NC}"
    
    # Ask for Pi version
    echo "Which Raspberry Pi version?"
    echo "1) Raspberry Pi 4"
    echo "2) Raspberry Pi 5"
    echo -n "Enter choice [1-2]: "
    read -r pi_choice
    
    case $pi_choice in
        1)
            platform="rpi4"
            description="Raspberry Pi 4"
            ;;
        2)
            platform="rpi5"
            description="Raspberry Pi 5"
            ;;
        *)
            echo -e "${RED}❌ Invalid choice${NC}"
            return 1
            ;;
    esac
    
    # Build kernel if not exists
    if [[ ! -f "build/aarch64/kernel.img" ]]; then
        echo -e "${YELLOW}🏗️  Building kernel first...${NC}"
        ./build.sh build aarch64 "$platform"
    fi
    
    # Create SD card image
    make -f Makefile.multi-arch sdcard ARCH=aarch64 PLATFORM="$platform"
    
    local sdcard_path="dist/aarch64/SAGE-OS-0.1.0-aarch64-$platform-sdcard.img"
    if [[ -f "$sdcard_path" ]]; then
        local size=$(du -h "$sdcard_path" | cut -f1)
        echo -e "${GREEN}✅ SD card image created: $sdcard_path ($size)${NC}"
        echo ""
        echo -e "${BLUE}📝 To flash to SD card:${NC}"
        echo "1. Insert SD card"
        echo "2. Run: diskutil list"
        echo "3. Identify your SD card (e.g., /dev/disk2)"
        echo "4. Unmount: diskutil unmountDisk /dev/diskN"
        echo "5. Flash: sudo dd if=$sdcard_path of=/dev/rdiskN bs=1m"
    fi
}

# Function to create ISO image
create_iso() {
    echo -e "${YELLOW}💿 Creating ISO image for x86_64...${NC}"
    
    # Build kernel if not exists
    if [[ ! -f "build/x86_64/kernel.img" ]]; then
        echo -e "${YELLOW}🏗️  Building kernel first...${NC}"
        ./build.sh build x86_64 x86_64
    fi
    
    # Create ISO image
    make -f Makefile.multi-arch iso ARCH=x86_64 PLATFORM=x86_64
    
    local iso_path="dist/x86_64/SAGE-OS-0.1.0-x86_64-x86_64.iso"
    if [[ -f "$iso_path" ]]; then
        local size=$(du -h "$iso_path" | cut -f1)
        echo -e "${GREEN}✅ ISO image created: $iso_path ($size)${NC}"
        echo ""
        echo -e "${BLUE}📝 To create bootable USB:${NC}"
        echo "1. Insert USB drive"
        echo "2. Run: diskutil list"
        echo "3. Identify your USB drive (e.g., /dev/disk2)"
        echo "4. Unmount: diskutil unmountDisk /dev/diskN"
        echo "5. Flash: sudo dd if=$iso_path of=/dev/rdiskN bs=1m"
    fi
}

# Function to test with QEMU
test_qemu() {
    echo -e "${YELLOW}🧪 Testing with QEMU...${NC}"
    
    echo "Which architecture to test?"
    echo "1) ARM64 (Raspberry Pi 4)"
    echo "2) ARM64 (Raspberry Pi 5)"
    echo "3) x86_64"
    echo -n "Enter choice [1-3]: "
    read -r test_choice
    
    case $test_choice in
        1)
            arch="aarch64"
            platform="rpi4"
            ;;
        2)
            arch="aarch64"
            platform="rpi5"
            ;;
        3)
            arch="x86_64"
            platform="x86_64"
            ;;
        *)
            echo -e "${RED}❌ Invalid choice${NC}"
            return 1
            ;;
    esac
    
    echo -e "${BLUE}🚀 Starting QEMU test (will timeout after 30 seconds)${NC}"
    echo "Press Ctrl+A, X to exit QEMU manually"
    echo ""
    
    ./build.sh test "$arch" "$platform"
}

# Function to build with Docker
build_docker() {
    echo -e "${YELLOW}🐳 Building with Docker...${NC}"
    
    # Check if Docker is available
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker not found${NC}"
        echo "Please install Docker Desktop for Mac first:"
        echo "  https://docs.docker.com/desktop/mac/install/"
        return 1
    fi
    
    echo "Which architecture to build?"
    echo "1) ARM64 (Raspberry Pi)"
    echo "2) x86_64"
    echo "3) All architectures"
    echo -n "Enter choice [1-3]: "
    read -r docker_choice
    
    case $docker_choice in
        1)
            ./docker-build.sh build aarch64 rpi4
            ;;
        2)
            ./docker-build.sh build x86_64 x86_64
            ;;
        3)
            ./docker-build.sh build-all
            ;;
        *)
            echo -e "${RED}❌ Invalid choice${NC}"
            return 1
            ;;
    esac
    
    echo -e "${GREEN}✅ Docker build completed${NC}"
}

# Main menu loop
while true; do
    show_menu
    read -r choice
    
    case $choice in
        1)
            install_deps
            ;;
        2)
            build_target "aarch64" "rpi4" "Raspberry Pi 4 (ARM64)"
            ;;
        3)
            build_target "aarch64" "rpi5" "Raspberry Pi 5 (ARM64)"
            ;;
        4)
            build_target "x86_64" "x86_64" "x86_64"
            ;;
        5)
            echo -e "${YELLOW}🏗️  Building for all architectures...${NC}"
            if [ -f "./build-all-architectures-macos.sh" ]; then
                ./build-all-architectures-macos.sh
            else
                ./build.sh build-all
            fi
            echo -e "${GREEN}✅ All builds completed${NC}"
            ;;
        6)
            create_sdcard
            ;;
        7)
            create_iso
            ;;
        8)
            test_qemu
            ;;
        9)
            build_docker
            ;;
        10)
            echo -e "${BLUE}📊 Build Status:${NC}"
            ./build.sh status
            ;;
        11)
            echo -e "${YELLOW}🧹 Cleaning build files...${NC}"
            ./build.sh clean
            echo -e "${GREEN}✅ Build files cleaned${NC}"
            ;;
        12)
            echo -e "${BLUE}📖 For detailed help, see:${NC}"
            echo "  - ./build.sh help"
            echo "  - ./docker-build.sh help"
            echo "  - docs/BUILD_SYSTEM.md"
            ;;
        0)
            echo -e "${GREEN}👋 Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Invalid choice. Please enter 0-12.${NC}"
            ;;
    esac
    
    echo ""
    echo -e "${BLUE}Press Enter to continue...${NC}"
    read -r
done