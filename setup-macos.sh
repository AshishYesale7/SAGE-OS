#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
#
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS macOS Setup Script
# Installs all dependencies needed to build and test SAGE OS on macOS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🍎 SAGE OS macOS Setup${NC}"
echo "========================================"

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ This script is for macOS only${NC}"
    exit 1
fi

echo -e "${BLUE}Detected macOS: $(sw_vers -productName) $(sw_vers -productVersion)${NC}"

# Check for Homebrew
if ! command -v brew >/dev/null 2>&1; then
    echo -e "${RED}❌ Homebrew not found${NC}"
    echo "Please install Homebrew first:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

echo -e "${GREEN}✅ Homebrew found: $(brew --version | head -1)${NC}"

# Update Homebrew
echo -e "${YELLOW}📦 Updating Homebrew...${NC}"
brew update

# Install QEMU
echo -e "${YELLOW}📦 Installing QEMU...${NC}"
if brew list qemu >/dev/null 2>&1; then
    echo -e "${GREEN}✅ QEMU already installed${NC}"
else
    brew install qemu
fi

# Install cross-compilation toolchains
echo -e "${YELLOW}📦 Installing cross-compilation toolchains...${NC}"

# Add the cross-toolchain tap
if ! brew tap | grep -q messense/macos-cross-toolchains; then
    echo "Adding cross-toolchain tap..."
    brew tap messense/macos-cross-toolchains
fi

# Install toolchains
declare -a toolchains=(
    "aarch64-unknown-linux-gnu"
    "x86_64-unknown-linux-gnu" 
    "riscv64-unknown-linux-gnu"
    "arm-unknown-linux-gnueabihf"
)

for toolchain in "${toolchains[@]}"; do
    if brew list "$toolchain" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $toolchain already installed${NC}"
    else
        echo "Installing $toolchain..."
        brew install "$toolchain" || echo -e "${YELLOW}⚠️  Failed to install $toolchain${NC}"
    fi
done

# Install GNU tools (for better compatibility)
echo -e "${YELLOW}📦 Installing GNU tools...${NC}"
declare -a gnu_tools=(
    "gnu-sed"
    "grep"
    "findutils"
    "gnu-tar"
    "coreutils"
)

for tool in "${gnu_tools[@]}"; do
    if brew list "$tool" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $tool already installed${NC}"
    else
        echo "Installing $tool..."
        brew install "$tool" || echo -e "${YELLOW}⚠️  Failed to install $tool${NC}"
    fi
done

# Install additional development tools
echo -e "${YELLOW}📦 Installing development tools...${NC}"
declare -a dev_tools=(
    "make"
    "cmake"
    "git"
)

for tool in "${dev_tools[@]}"; do
    if brew list "$tool" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $tool already installed${NC}"
    else
        echo "Installing $tool..."
        brew install "$tool" || echo -e "${YELLOW}⚠️  Failed to install $tool${NC}"
    fi
done

# Verify installations
echo -e "\n${BLUE}🔍 Verifying installations...${NC}"
echo "========================================"

# Check QEMU
echo -e "${BLUE}QEMU versions:${NC}"
for qemu in qemu-system-i386 qemu-system-x86_64 qemu-system-aarch64 qemu-system-arm qemu-system-riscv64; do
    if command -v "$qemu" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $qemu: $($qemu --version | head -1)${NC}"
    else
        echo -e "${RED}❌ $qemu not found${NC}"
    fi
done

# Check cross-compilers
echo -e "\n${BLUE}Cross-compilers:${NC}"
for compiler in aarch64-unknown-linux-gnu-gcc x86_64-unknown-linux-gnu-gcc riscv64-unknown-linux-gnu-gcc arm-unknown-linux-gnueabihf-gcc; do
    if command -v "$compiler" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $compiler: $($compiler --version | head -1)${NC}"
    else
        echo -e "${RED}❌ $compiler not found${NC}"
    fi
done

# Create environment setup script
echo -e "\n${YELLOW}📝 Creating environment setup script...${NC}"
cat > setup-env-macos.sh << 'EOF'
#!/bin/bash
# SAGE OS macOS Environment Setup
# Source this file to set up the build environment

# Add Homebrew paths
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Add cross-compiler paths
export PATH="/opt/homebrew/bin:$PATH"

# Set GNU tools as default
export SED="gsed"
export GREP="ggrep"
export FIND="gfind"
export TAR="gtar"

# QEMU paths
export QEMU_SYSTEM_I386="qemu-system-i386"
export QEMU_SYSTEM_X86_64="qemu-system-x86_64"
export QEMU_SYSTEM_AARCH64="qemu-system-aarch64"
export QEMU_SYSTEM_ARM="qemu-system-arm"
export QEMU_SYSTEM_RISCV64="qemu-system-riscv64"

echo "🍎 SAGE OS macOS environment loaded"
echo "Available cross-compilers:"
echo "  aarch64-unknown-linux-gnu-gcc"
echo "  x86_64-unknown-linux-gnu-gcc"
echo "  riscv64-unknown-linux-gnu-gcc"
echo "  arm-unknown-linux-gnueabihf-gcc"
EOF

chmod +x setup-env-macos.sh

echo -e "\n${GREEN}🎉 macOS setup complete!${NC}"
echo "========================================"
echo -e "${BLUE}Next steps:${NC}"
echo "1. Source the environment: ${YELLOW}source setup-env-macos.sh${NC}"
echo "2. Build for all architectures: ${YELLOW}make all-arch${NC}"
echo "3. Test with QEMU: ${YELLOW}./test-qemu.sh${NC}"
echo ""
echo -e "${BLUE}Build examples:${NC}"
echo "  ${YELLOW}make -f tools/build/Makefile.multi-arch ARCH=x86_64${NC}"
echo "  ${YELLOW}make -f tools/build/Makefile.multi-arch ARCH=aarch64${NC}"
echo "  ${YELLOW}make -f tools/build/Makefile.multi-arch ARCH=arm${NC}"
echo "  ${YELLOW}make -f tools/build/Makefile.multi-arch ARCH=riscv64${NC}"