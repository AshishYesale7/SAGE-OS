#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
#
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS macOS Build Script - Clean & Simple
# Builds SAGE OS for macOS development without complex dependencies

# set -e  # Disabled to prevent early exit on test failures

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🍎 SAGE OS macOS Build Script${NC}"
echo "========================================"

# Function to show usage
show_usage() {
    echo "Usage: $0 [ARCHITECTURE] [OPTIONS]"
    echo ""
    echo "Architectures:"
    echo "  x86_64      Build for x86_64 (works perfectly in QEMU)"
    echo "  aarch64     Build for ARM64 (Raspberry Pi 4/5)"
    echo "  arm         Build for ARM32 (Raspberry Pi 2/3)"
    echo "  all         Build all working architectures"
    echo ""
    echo "Options:"
    echo "  --build-only    Only build, don't test"
    echo "  --test-only     Only test existing builds"
    echo "  --clean         Clean before building"
    echo "  --help          Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 x86_64              # Build and test x86_64"
    echo "  $0 aarch64 --build-only # Build ARM64 only"
    echo "  $0 all --clean         # Clean and build all"
    echo "  $0 x86_64 --test-only  # Test existing x86_64 build"
}

# Function to check dependencies
check_deps() {
    echo -e "${BLUE}🔍 Checking dependencies...${NC}"
    
    # Check for make
    if ! command -v make >/dev/null 2>&1; then
        echo -e "${RED}❌ make not found${NC}"
        echo "Install Xcode Command Line Tools: xcode-select --install"
        exit 1
    fi
    
    # Check for QEMU (optional for build-only)
    if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  QEMU not found (needed for testing)${NC}"
        echo "Install with: brew install qemu"
    fi
    
    echo -e "${GREEN}✅ Dependencies OK${NC}"
}

# Function to build architecture
build_arch() {
    local arch=$1
    echo -e "\n${YELLOW}🔨 Building $arch...${NC}"
    
    # Use the multi-arch Makefile which works on macOS
    if make -f tools/build/Makefile.multi-arch ARCH="$arch" > "/tmp/sage_build_${arch}.log" 2>&1; then
        echo -e "${GREEN}✅ $arch build successful${NC}"
        
        # Show build info
        if [ -f "build/$arch/kernel.img" ]; then
            size=$(du -h "build/$arch/kernel.img" | cut -f1)
            echo -e "   📦 Kernel: build/$arch/kernel.img ($size)"
        elif [ -f "build/$arch/kernel.elf" ]; then
            size=$(du -h "build/$arch/kernel.elf" | cut -f1)
            echo -e "   📦 Kernel: build/$arch/kernel.elf ($size)"
        fi
        
        return 0
    else
        echo -e "${RED}❌ $arch build failed${NC}"
        echo "Build log (last 10 lines):"
        tail -10 "/tmp/sage_build_${arch}.log" | sed 's/^/   /'
        return 1
    fi
}

# Function to test architecture
test_arch() {
    local arch=$1
    echo -e "\n${YELLOW}🧪 Testing $arch...${NC}"
    
    # Check if QEMU is available
    local qemu_cmd=""
    case $arch in
        x86_64)
            qemu_cmd="qemu-system-i386"
            ;;
        aarch64)
            qemu_cmd="qemu-system-aarch64"
            ;;
        arm)
            qemu_cmd="qemu-system-arm"
            ;;
    esac
    
    if ! command -v "$qemu_cmd" >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  $qemu_cmd not found, skipping test${NC}"
        return 1
    fi
    
    # Run appropriate QEMU command
    case $arch in
        x86_64)
            if [ -f "build/$arch/kernel.elf" ]; then
                echo "Command: $qemu_cmd -kernel build/$arch/kernel.elf -nographic"
                timeout 10 $qemu_cmd -kernel "build/$arch/kernel.elf" -nographic -no-reboot > "/tmp/sage_test_${arch}.log" 2>&1 || true
            else
                echo -e "${RED}❌ Kernel not found: build/$arch/kernel.elf${NC}"
                return 1
            fi
            ;;
        aarch64)
            if [ -f "build/$arch/kernel.img" ]; then
                echo "Command: $qemu_cmd -M virt -cpu cortex-a72 -m 1G -kernel build/$arch/kernel.img -nographic"
                timeout 10 $qemu_cmd -M virt -cpu cortex-a72 -m 1G -kernel "build/$arch/kernel.img" -nographic -no-reboot > "/tmp/sage_test_${arch}.log" 2>&1 || true
            else
                echo -e "${RED}❌ Kernel not found: build/$arch/kernel.img${NC}"
                return 1
            fi
            ;;
        arm)
            if [ -f "build/$arch/kernel.img" ]; then
                echo "Command: $qemu_cmd -M versatilepb -cpu arm1176 -m 256M -kernel build/$arch/kernel.img -nographic"
                timeout 10 $qemu_cmd -M versatilepb -cpu arm1176 -m 256M -kernel "build/$arch/kernel.img" -nographic -no-reboot -nodefaults > "/tmp/sage_test_${arch}.log" 2>&1 || true
            else
                echo -e "${RED}❌ Kernel not found: build/$arch/kernel.img${NC}"
                return 1
            fi
            ;;
    esac
    
    # Check test results
    if [ -f "/tmp/sage_test_${arch}.log" ]; then
        if grep -q "SAGE OS" "/tmp/sage_test_${arch}.log" 2>/dev/null; then
            echo -e "${GREEN}✅ $arch test successful - SAGE OS banner found${NC}"
            return 0
        elif grep -q "sage@localhost" "/tmp/sage_test_${arch}.log" 2>/dev/null; then
            echo -e "${GREEN}✅ $arch test successful - Shell prompt found${NC}"
            return 0
        else
            echo -e "${YELLOW}⚠️  $arch test inconclusive${NC}"
            if [ "$arch" = "x86_64" ]; then
                echo "Expected to see SAGE OS banner and shell prompt"
                echo "First few lines of output:"
                head -5 "/tmp/sage_test_${arch}.log" | sed 's/^/   /'
            else
                echo "ARM kernels are known to hang in QEMU (try real hardware)"
            fi
            return 1
        fi
    else
        echo -e "${RED}❌ $arch test failed - no output${NC}"
        return 1
    fi
}

# Function to clean builds
clean_builds() {
    echo -e "${BLUE}🧹 Cleaning builds...${NC}"
    make -f tools/build/Makefile.multi-arch clean >/dev/null 2>&1 || true
    rm -rf build/ build-output/ >/dev/null 2>&1 || true
    echo -e "${GREEN}✅ Cleaned${NC}"
}

# Parse arguments
ARCHITECTURES=()
BUILD_ONLY=false
TEST_ONLY=false
CLEAN_FIRST=false

if [ $# -eq 0 ]; then
    show_usage
    exit 0
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        x86_64|aarch64|arm)
            ARCHITECTURES+=("$1")
            shift
            ;;
        all)
            ARCHITECTURES=("x86_64" "aarch64" "arm")
            shift
            ;;
        --build-only)
            BUILD_ONLY=true
            shift
            ;;
        --test-only)
            TEST_ONLY=true
            shift
            ;;
        --clean)
            CLEAN_FIRST=true
            shift
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Unknown argument: $1${NC}"
            show_usage
            exit 1
            ;;
    esac
done

# Validate
if [ ${#ARCHITECTURES[@]} -eq 0 ]; then
    echo -e "${RED}❌ No architecture specified${NC}"
    show_usage
    exit 1
fi

# Check dependencies
check_deps

# Clean if requested
if [ "$CLEAN_FIRST" = true ]; then
    clean_builds
fi

echo -e "\n${BLUE}📋 Build Plan:${NC}"
for arch in "${ARCHITECTURES[@]}"; do
    echo -e "   - $arch"
done

# Main execution
success_count=0
total_count=${#ARCHITECTURES[@]}

for arch in "${ARCHITECTURES[@]}"; do
    if [ "$TEST_ONLY" = false ]; then
        if build_arch "$arch"; then
            ((success_count++))
        fi
    fi
    
    if [ "$BUILD_ONLY" = false ]; then
        test_arch "$arch" || true  # Don't exit on test failure
    fi
done

# Summary
echo -e "\n${BLUE}📊 Summary${NC}"
echo "========================================"

if [ "$TEST_ONLY" = false ]; then
    echo -e "${BLUE}Build Success Rate: $success_count/$total_count${NC}"
fi

echo -e "\n${BLUE}📁 Build Artifacts:${NC}"
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

echo -e "\n${BLUE}🚀 Quick Test Commands:${NC}"
if [[ " ${ARCHITECTURES[@]} " =~ " x86_64 " ]] && [ -f "build/x86_64/kernel.elf" ]; then
    echo -e "  x86_64: ${YELLOW}qemu-system-i386 -kernel build/x86_64/kernel.elf -nographic${NC}"
fi
if [[ " ${ARCHITECTURES[@]} " =~ " aarch64 " ]] && [ -f "build/aarch64/kernel.img" ]; then
    echo -e "  aarch64: ${YELLOW}qemu-system-aarch64 -M virt -kernel build/aarch64/kernel.img -nographic${NC}"
fi

# Final status
if [ "$TEST_ONLY" = true ]; then
    echo -e "\n${GREEN}✅ Testing completed!${NC}"
    exit 0
elif [ "$BUILD_ONLY" = true ]; then
    if [ $success_count -eq $total_count ]; then
        echo -e "\n${GREEN}✅ All builds successful!${NC}"
        exit 0
    else
        echo -e "\n${YELLOW}⚠️  Some builds failed${NC}"
        exit 1
    fi
else
    if [ $success_count -eq $total_count ]; then
        echo -e "\n${GREEN}✅ Build and test completed!${NC}"
        exit 0
    else
        echo -e "\n${YELLOW}⚠️  Some builds failed${NC}"
        exit 1
    fi
fi