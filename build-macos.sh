#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
#
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS macOS Build Script
# Builds SAGE OS for all architectures on macOS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🍎 SAGE OS macOS Build Script${NC}"
echo "========================================"

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ This script is for macOS only${NC}"
    echo "For Linux, use: make -f tools/build/Makefile.multi-arch"
    exit 1
fi

# Check for required tools
echo -e "${BLUE}🔍 Checking build environment...${NC}"

# Check for Homebrew
if ! command -v brew >/dev/null 2>&1; then
    echo -e "${RED}❌ Homebrew not found${NC}"
    echo "Please run: ./setup-macos.sh"
    exit 1
fi

# Check for QEMU
if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  QEMU not found. Installing...${NC}"
    brew install qemu
fi

# Check for cross-compilers
declare -a required_compilers=(
    "aarch64-unknown-linux-gnu-gcc"
    "x86_64-unknown-linux-gnu-gcc"
    "riscv64-unknown-linux-gnu-gcc"
    "arm-unknown-linux-gnueabihf-gcc"
)

missing_compilers=()
for compiler in "${required_compilers[@]}"; do
    if ! command -v "$compiler" >/dev/null 2>&1; then
        missing_compilers+=("$compiler")
    fi
done

if [ ${#missing_compilers[@]} -ne 0 ]; then
    echo -e "${YELLOW}⚠️  Missing cross-compilers: ${missing_compilers[*]}${NC}"
    echo "Please run: ./setup-macos.sh"
    exit 1
fi

echo -e "${GREEN}✅ Build environment ready${NC}"

# Build function
build_arch() {
    local arch=$1
    echo -e "\n${YELLOW}🔨 Building $arch...${NC}"
    
    if make -f tools/build/Makefile.multi-arch ARCH="$arch" > "/tmp/build_${arch}.log" 2>&1; then
        echo -e "${GREEN}✅ $arch build successful${NC}"
        
        # Show kernel size
        if [ -f "build/$arch/kernel.img" ]; then
            size=$(du -h "build/$arch/kernel.img" | cut -f1)
            echo -e "   📦 Kernel size: $size"
        fi
        
        return 0
    else
        echo -e "${RED}❌ $arch build failed${NC}"
        echo "Build log:"
        tail -10 "/tmp/build_${arch}.log" | sed 's/^/   /'
        return 1
    fi
}

# Test function
test_arch() {
    local arch=$1
    echo -e "\n${YELLOW}🧪 Testing $arch...${NC}"
    
    case $arch in
        x86_64)
            timeout 10 qemu-system-i386 -kernel "build/$arch/kernel.elf" -nographic -no-reboot > "/tmp/test_${arch}.log" 2>&1 || true
            ;;
        aarch64)
            timeout 10 qemu-system-aarch64 -M virt -cpu cortex-a72 -m 1G -kernel "build/$arch/kernel.img" -nographic -no-reboot > "/tmp/test_${arch}.log" 2>&1 || true
            ;;
        arm)
            timeout 10 qemu-system-arm -M versatilepb -cpu arm1176 -m 256M -kernel "build/$arch/kernel.img" -nographic -no-reboot -nodefaults > "/tmp/test_${arch}.log" 2>&1 || true
            ;;
        riscv64)
            timeout 10 qemu-system-riscv64 -M virt -cpu rv64 -m 1G -kernel "build/$arch/kernel.img" -nographic -no-reboot > "/tmp/test_${arch}.log" 2>&1 || true
            ;;
    esac
    
    if grep -q "SAGE OS" "/tmp/test_${arch}.log" 2>/dev/null; then
        echo -e "${GREEN}✅ $arch test successful - SAGE OS banner found${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  $arch test inconclusive - no clear output${NC}"
        return 1
    fi
}

# Parse command line arguments
ARCHITECTURES=("x86_64" "aarch64" "arm" "riscv64")
BUILD_ONLY=false
TEST_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --arch)
            ARCHITECTURES=("$2")
            shift 2
            ;;
        --build-only)
            BUILD_ONLY=true
            shift
            ;;
        --test-only)
            TEST_ONLY=true
            shift
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --arch ARCH     Build specific architecture (x86_64, aarch64, arm, riscv64)"
            echo "  --build-only    Only build, don't test"
            echo "  --test-only     Only test, don't build"
            echo "  --help          Show this help"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Main build loop
success_count=0
total_count=${#ARCHITECTURES[@]}

for arch in "${ARCHITECTURES[@]}"; do
    if [ "$TEST_ONLY" = false ]; then
        if build_arch "$arch"; then
            ((success_count++))
        fi
    fi
    
    if [ "$BUILD_ONLY" = false ] && [ -f "build/$arch/kernel.img" -o -f "build/$arch/kernel.elf" ]; then
        test_arch "$arch"
    fi
done

# Summary
echo -e "\n${BLUE}📊 Build Summary${NC}"
echo "========================================"
if [ "$TEST_ONLY" = false ]; then
    echo -e "${BLUE}Success Rate: $success_count/$total_count${NC}"
    
    if [ $success_count -eq $total_count ]; then
        echo -e "${GREEN}🎉 All builds successful!${NC}"
    elif [ $success_count -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Some builds failed${NC}"
    else
        echo -e "${RED}❌ All builds failed${NC}"
    fi
fi

echo -e "\n${BLUE}📁 Build artifacts:${NC}"
for arch in "${ARCHITECTURES[@]}"; do
    if [ -f "build/$arch/kernel.img" ]; then
        size=$(du -h "build/$arch/kernel.img" | cut -f1)
        echo -e "${GREEN}✅ build/$arch/kernel.img ($size)${NC}"
    elif [ -f "build/$arch/kernel.elf" ]; then
        size=$(du -h "build/$arch/kernel.elf" | cut -f1)
        echo -e "${GREEN}✅ build/$arch/kernel.elf ($size)${NC}"
    else
        echo -e "${RED}❌ build/$arch/kernel.* (not found)${NC}"
    fi
done

echo -e "\n${BLUE}🚀 Next steps:${NC}"
echo "  Test manually: ${YELLOW}./test-qemu.sh${NC}"
echo "  Clean builds:  ${YELLOW}make -f tools/build/Makefile.multi-arch clean${NC}"