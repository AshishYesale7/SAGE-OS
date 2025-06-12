#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS Cross-Compilation Setup Script
# This script installs the necessary cross-compilation toolchains for building SAGE OS

set -e

echo "🔧 SAGE OS Cross-Compilation Setup"
echo "=================================="
echo ""

# Detect host architecture
HOST_ARCH=$(uname -m)
echo "🖥️  Host Architecture: $HOST_ARCH"

# Detect OS
if [ -f /etc/debian_version ]; then
    OS="debian"
    echo "🐧 OS: Debian/Ubuntu"
elif [ -f /etc/arch-release ]; then
    OS="arch"
    echo "🐧 OS: Arch Linux"
else
    echo "❌ Unsupported OS. This script supports Debian/Ubuntu and Arch Linux."
    exit 1
fi

echo ""

# Function to install packages on Debian/Ubuntu
install_debian() {
    echo "📦 Installing cross-compilation toolchains..."
    
    # Update package list
    sudo apt-get update
    
    # Install basic build tools
    sudo apt-get install -y build-essential
    
    # Install multilib support for x86
    sudo apt-get install -y gcc-multilib g++-multilib
    
    # Install cross-compilers for different architectures
    case $HOST_ARCH in
        x86_64)
            echo "✅ Native x86_64 - installing i386 multilib support"
            # Already installed above
            ;;
        aarch64|arm64)
            echo "🔄 ARM64 host - installing x86 cross-compilers"
            sudo apt-get install -y gcc-i686-linux-gnu g++-i686-linux-gnu
            sudo apt-get install -y gcc-x86-64-linux-gnu g++-x86-64-linux-gnu
            ;;
        *)
            echo "⚠️  Unknown host architecture, installing all cross-compilers"
            sudo apt-get install -y gcc-i686-linux-gnu g++-i686-linux-gnu
            sudo apt-get install -y gcc-x86-64-linux-gnu g++-x86-64-linux-gnu
            sudo apt-get install -y gcc-aarch64-linux-gnu g++-aarch64-linux-gnu
            sudo apt-get install -y gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf
            sudo apt-get install -y gcc-riscv64-linux-gnu g++-riscv64-linux-gnu
            ;;
    esac
    
    # Install QEMU for testing
    sudo apt-get install -y qemu-system-x86 qemu-system-arm qemu-system-misc
    
    # Install additional tools
    sudo apt-get install -y binutils-multiarch
}

# Function to install packages on Arch Linux
install_arch() {
    echo "📦 Installing cross-compilation toolchains..."
    
    # Update package database
    sudo pacman -Sy
    
    # Install basic build tools
    sudo pacman -S --needed base-devel
    
    # Install multilib support
    sudo pacman -S --needed lib32-gcc-libs
    
    # Install cross-compilers (from AUR - requires yay or similar)
    if command -v yay &> /dev/null; then
        case $HOST_ARCH in
            x86_64)
                echo "✅ Native x86_64 - multilib already available"
                ;;
            aarch64|arm64)
                echo "🔄 ARM64 host - installing x86 cross-compilers"
                yay -S --needed i686-linux-gnu-gcc
                yay -S --needed x86_64-linux-gnu-gcc
                ;;
        esac
    else
        echo "⚠️  AUR helper (yay) not found. Please install cross-compilers manually."
    fi
    
    # Install QEMU
    sudo pacman -S --needed qemu-system-x86 qemu-system-arm qemu-system-riscv
}

# Install based on OS
case $OS in
    debian)
        install_debian
        ;;
    arch)
        install_arch
        ;;
esac

echo ""
echo "✅ Cross-compilation setup completed!"
echo ""
echo "🧪 Testing installation..."

# Test cross-compilers
echo "📋 Available cross-compilers:"
for compiler in gcc i686-linux-gnu-gcc x86_64-linux-gnu-gcc aarch64-linux-gnu-gcc arm-linux-gnueabihf-gcc riscv64-linux-gnu-gcc; do
    if command -v $compiler &> /dev/null; then
        echo "  ✅ $compiler"
    else
        echo "  ❌ $compiler (not found)"
    fi
done

echo ""
echo "🎯 Next steps:"
echo "  1. Build SAGE OS: make ARCH=i386 TARGET=generic"
echo "  2. Test in graphics mode: ./scripts/testing/test-graphics-mode.sh i386"
echo "  3. For other architectures: make ARCH=<arch> TARGET=generic"
echo ""
echo "📖 Supported architectures: i386, x86_64, aarch64, arm, riscv64"