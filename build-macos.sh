#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS macOS Build Script
# ==========================
# Simplified build interface specifically designed for macOS users
# Handles dependency installation and cross-compilation setup

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

# Function to install dependencies
install_deps() {
    echo -e "${BLUE}🔧 Installing build dependencies...${NC}"
    
    # Check for Homebrew
    if ! command -v brew >/dev/null 2>&1; then
        echo -e "${RED}❌ Homebrew not found${NC}"
        echo "Please install Homebrew first:"
        echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
    
    echo "Installing cross-compilation toolchains..."
    
    # Install essential tools
    brew install make cmake qemu nasm
    
    # Install cross-compilation toolchains
    echo "Installing ARM64 toolchain..."
    brew install aarch64-elf-gcc || brew install --cask gcc-aarch64-elf || {
        echo -e "${YELLOW}⚠️  ARM64 toolchain not available via Homebrew${NC}"
        echo "You may need to install it manually or use Docker"
    }
    
    echo "Installing x86_64 toolchain..."
    brew install x86_64-elf-gcc || {
        echo -e "${YELLOW}⚠️  x86_64 toolchain not available via Homebrew${NC}"
        echo "Using system GCC for x86_64 builds"
    }
    
    echo "Installing RISC-V toolchain..."
    brew install riscv64-elf-gcc || {
        echo -e "${YELLOW}⚠️  RISC-V toolchain not available via Homebrew${NC}"
        echo "RISC-V builds will be skipped"
    }
    
    echo -e "${GREEN}✅ Dependencies installation completed${NC}"
}

# Function to build for specific architecture
build_arch() {
    local arch="$1"
    local platform="${2:-generic}"
    
    echo -e "${BLUE}🏗️  Building SAGE OS for $arch ($platform)...${NC}"
    
    # Use the main build script
    if ./build.sh build "$arch" "$platform"; then
        echo -e "${GREEN}✅ Build completed for $arch${NC}"
        return 0
    else
        echo -e "${RED}❌ Build failed for $arch${NC}"
        return 1
    fi
}

# Function to test with QEMU
test_qemu() {
    local arch="$1"
    local platform="${2:-generic}"
    
    echo -e "${BLUE}🧪 Testing SAGE OS ($arch) with QEMU...${NC}"
    
    if ./build.sh test "$arch" "$platform"; then
        echo -e "${GREEN}✅ QEMU test completed for $arch${NC}"
    else
        echo -e "${RED}❌ QEMU test failed for $arch${NC}"
    fi
}

# Function to show menu
show_menu() {
    echo ""
    echo -e "${BLUE}What would you like to do?${NC}"
    echo "1) 🔧 Install build dependencies"
    echo "2) 🏗️  Build for ARM64 (aarch64) - Raspberry Pi"
    echo "3) 🏗️  Build for x86_64"
    echo "4) 🏗️  Build for all supported architectures"
    echo "5) 🧪 Test ARM64 build with QEMU"
    echo "6) 🧪 Test x86_64 build with QEMU"
    echo "7) 📋 Show build status"
    echo "8) 🧹 Clean build files"
    echo "9) ❓ Help"
    echo "0) 🚪 Exit"
    echo ""
    echo -n "Enter your choice [0-9]: "
}

# Function to show build status
show_status() {
    echo -e "${BLUE}📋 Build Status${NC}"
    echo "==============="
    
    for arch in aarch64 x86_64 arm riscv64; do
        if [[ -f "output/$arch/kernel.img" ]]; then
            echo -e "  $arch: ${GREEN}✅ Built${NC}"
        else
            echo -e "  $arch: ${RED}❌ Not built${NC}"
        fi
    done
}

# Function to clean build files
clean_build() {
    echo -e "${BLUE}🧹 Cleaning build files...${NC}"
    rm -rf build/ output/ *.img *.iso *.elf
    echo -e "${GREEN}✅ Build files cleaned${NC}"
}

# Function to show help
show_help() {
    echo -e "${BLUE}📖 SAGE OS macOS Build Help${NC}"
    echo "============================"
    echo ""
    echo "This script helps you build SAGE OS on macOS with proper cross-compilation support."
    echo ""
    echo "Prerequisites:"
    echo "  - macOS 10.15+ (Catalina or later)"
    echo "  - Homebrew package manager"
    echo "  - Xcode Command Line Tools"
    echo ""
    echo "Quick Start:"
    echo "  1. Run option 1 to install dependencies"
    echo "  2. Run option 2 to build for ARM64 (recommended)"
    echo "  3. Run option 5 to test with QEMU"
    echo ""
    echo "Supported Architectures:"
    echo "  - aarch64 (ARM64) - Fully supported, works on Raspberry Pi 4/5"
    echo "  - x86_64 (Intel)  - Partial support, GRUB boots"
    echo "  - arm (ARM32)     - Builds successfully"
    echo "  - riscv64         - Experimental support"
    echo ""
    echo "For advanced usage, use: ./build.sh --help"
}

# Main menu loop
main() {
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            1)
                install_deps
                ;;
            2)
                build_arch "aarch64" "generic"
                ;;
            3)
                build_arch "x86_64" "generic"
                ;;
            4)
                echo -e "${BLUE}🏗️  Building all architectures...${NC}"
                for arch in aarch64 x86_64 arm; do
                    echo -e "\n${BLUE}Building $arch...${NC}"
                    build_arch "$arch" "generic" || echo -e "${RED}❌ $arch build failed${NC}"
                done
                ;;
            5)
                test_qemu "aarch64" "generic"
                ;;
            6)
                test_qemu "x86_64" "generic"
                ;;
            7)
                show_status
                ;;
            8)
                clean_build
                ;;
            9)
                show_help
                ;;
            0)
                echo -e "${GREEN}👋 Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Invalid choice. Please try again.${NC}"
                ;;
        esac
        
        echo ""
        echo -n "Press Enter to continue..."
        read -r
    done
}

# Check if arguments were provided
if [[ $# -gt 0 ]]; then
    case "$1" in
        "install-deps")
            install_deps
            ;;
        "build")
            arch="${2:-aarch64}"
            platform="${3:-generic}"
            build_arch "$arch" "$platform"
            ;;
        "test")
            arch="${2:-aarch64}"
            platform="${3:-generic}"
            test_qemu "$arch" "$platform"
            ;;
        "clean")
            clean_build
            ;;
        "status")
            show_status
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            echo -e "${RED}❌ Unknown command: $1${NC}"
            echo "Use: $0 help for available commands"
            exit 1
            ;;
    esac
else
    # Interactive mode
    main
fi