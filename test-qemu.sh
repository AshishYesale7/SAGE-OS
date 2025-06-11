#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
#
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS QEMU Testing Script
# Comprehensive testing for all architectures on macOS and Linux

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TIMEOUT=15
BUILD_DIR="build"
RESULTS_FILE="qemu-test-results.txt"

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    HOST_OS="macos"
else
    HOST_OS="linux"
fi

echo -e "${BLUE}SAGE OS QEMU Testing Suite${NC}"
echo -e "${BLUE}Host OS: $HOST_OS${NC}"
echo "========================================"

# Clear previous results
> $RESULTS_FILE

# Test function
test_architecture() {
    local arch=$1
    local qemu_cmd=$2
    local kernel_path=$3
    local description=$4
    
    echo -e "\n${YELLOW}Testing $arch ($description)...${NC}"
    
    if [ ! -f "$kernel_path" ]; then
        echo -e "${RED}❌ Kernel not found: $kernel_path${NC}"
        echo "$arch: KERNEL_NOT_FOUND" >> $RESULTS_FILE
        return 1
    fi
    
    echo "Command: $qemu_cmd"
    echo "Kernel: $kernel_path"
    
    # Run QEMU with timeout
    if timeout $TIMEOUT $qemu_cmd > /tmp/qemu_output_$arch.log 2>&1; then
        echo -e "${GREEN}✅ $arch: Boot successful${NC}"
        echo "$arch: SUCCESS" >> $RESULTS_FILE
        
        # Check if we got expected output
        if grep -q "SAGE OS" /tmp/qemu_output_$arch.log; then
            echo -e "${GREEN}   ✅ SAGE OS banner found${NC}"
        fi
        
        if grep -q "sage@localhost" /tmp/qemu_output_$arch.log; then
            echo -e "${GREEN}   ✅ Shell prompt found${NC}"
        fi
        
    else
        echo -e "${RED}❌ $arch: Boot failed or timeout${NC}"
        echo "$arch: FAILED" >> $RESULTS_FILE
        
        # Show last few lines of output for debugging
        echo "Last output:"
        tail -5 /tmp/qemu_output_$arch.log | sed 's/^/   /'
    fi
}

# Build all architectures first
echo -e "\n${BLUE}Building all architectures...${NC}"
for arch in x86_64 aarch64 arm riscv64; do
    echo "Building $arch..."
    if make -f tools/build/Makefile.multi-arch ARCH=$arch > /tmp/build_$arch.log 2>&1; then
        echo -e "${GREEN}✅ $arch build successful${NC}"
    else
        echo -e "${RED}❌ $arch build failed${NC}"
        echo "Build error for $arch:"
        tail -5 /tmp/build_$arch.log | sed 's/^/   /'
    fi
done

echo -e "\n${BLUE}Starting QEMU tests...${NC}"

# Test x86_64 (32-bit multiboot)
test_architecture "x86_64" \
    "qemu-system-i386 -kernel $BUILD_DIR/x86_64/kernel.elf -nographic -no-reboot" \
    "$BUILD_DIR/x86_64/kernel.elf" \
    "32-bit multiboot on i386 emulator"

# Test ARM64 (AArch64)
test_architecture "aarch64" \
    "qemu-system-aarch64 -M virt -cpu cortex-a72 -m 1G -kernel $BUILD_DIR/aarch64/kernel.img -nographic -no-reboot" \
    "$BUILD_DIR/aarch64/kernel.img" \
    "ARM64 on virt machine"

# Test ARM64 on Raspberry Pi 3
test_architecture "aarch64-rpi" \
    "qemu-system-aarch64 -M raspi3b -cpu cortex-a72 -m 1G -kernel $BUILD_DIR/aarch64/kernel.img -nographic -no-reboot" \
    "$BUILD_DIR/aarch64/kernel.img" \
    "ARM64 on Raspberry Pi 3"

# Test ARM 32-bit
test_architecture "arm" \
    "qemu-system-arm -M versatilepb -cpu arm1176 -m 256M -kernel $BUILD_DIR/arm/kernel.img -nographic -no-reboot -nodefaults" \
    "$BUILD_DIR/arm/kernel.img" \
    "ARM 32-bit on VersatilePB"

# Test ARM on Raspberry Pi 2
test_architecture "arm-rpi" \
    "qemu-system-arm -M raspi2b -cpu cortex-a7 -m 1G -kernel $BUILD_DIR/arm/kernel.img -nographic -no-reboot -nodefaults" \
    "$BUILD_DIR/arm/kernel.img" \
    "ARM 32-bit on Raspberry Pi 2"

# Test RISC-V 64-bit
test_architecture "riscv64" \
    "qemu-system-riscv64 -M virt -cpu rv64 -m 1G -kernel $BUILD_DIR/riscv64/kernel.img -nographic -no-reboot" \
    "$BUILD_DIR/riscv64/kernel.img" \
    "RISC-V 64-bit on virt machine"

# Summary
echo -e "\n${BLUE}Test Results Summary:${NC}"
echo "========================================"

success_count=0
total_count=0

while IFS=': ' read -r arch result; do
    total_count=$((total_count + 1))
    if [ "$result" = "SUCCESS" ]; then
        echo -e "${GREEN}✅ $arch: $result${NC}"
        success_count=$((success_count + 1))
    elif [ "$result" = "KERNEL_NOT_FOUND" ]; then
        echo -e "${YELLOW}⚠️  $arch: $result${NC}"
    else
        echo -e "${RED}❌ $arch: $result${NC}"
    fi
done < $RESULTS_FILE

echo "========================================"
echo -e "${BLUE}Success Rate: $success_count/$total_count${NC}"

if [ $success_count -eq $total_count ]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    exit 0
elif [ $success_count -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Some tests failed${NC}"
    exit 1
else
    echo -e "${RED}❌ All tests failed${NC}"
    exit 2
fi