#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
#
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS macOS M1 Development Verification Script

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🍎 SAGE OS macOS M1 Development Verification${NC}"
echo "=============================================="

# Check macOS version
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "${GREEN}✅ Running on macOS: $(sw_vers -productName) $(sw_vers -productVersion)${NC}"
    
    # Check for Apple Silicon
    if [[ $(uname -m) == "arm64" ]]; then
        echo -e "${GREEN}✅ Apple Silicon (M1/M2/M3) detected${NC}"
    else
        echo -e "${YELLOW}⚠️  Intel Mac detected (M1 optimizations may not apply)${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Not running on macOS (simulating macOS environment)${NC}"
fi

echo ""
echo -e "${BLUE}🔧 Build System Verification${NC}"
echo "----------------------------------------"

# Check core scripts
if [[ -x "./build-macos.sh" ]]; then
    echo -e "${GREEN}✅ macOS build script: ./build-macos.sh${NC}"
else
    echo -e "${RED}❌ Missing: ./build-macos.sh${NC}"
fi

if [[ -x "./setup-macos.sh" ]]; then
    echo -e "${GREEN}✅ macOS setup script: ./setup-macos.sh${NC}"
else
    echo -e "${RED}❌ Missing: ./setup-macos.sh${NC}"
fi

if [[ -x "./test-qemu.sh" ]]; then
    echo -e "${GREEN}✅ QEMU test script: ./test-qemu.sh${NC}"
else
    echo -e "${RED}❌ Missing: ./test-qemu.sh${NC}"
fi

echo ""
echo -e "${BLUE}🏗️ Boot System Analysis${NC}"
echo "----------------------------------------"

# Check boot files
declare -a boot_files=(
    "boot/boot_i386.S:x86_64 multiboot (WORKING)"
    "boot/boot_aarch64.S:ARM64 boot (WORKING)"
    "boot/boot_arm.S:ARM32 boot (needs debug)"
    "boot/boot_riscv64.S:RISC-V boot (needs debug)"
)

for entry in "${boot_files[@]}"; do
    file="${entry%%:*}"
    desc="${entry##*:}"
    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✅ $file${NC} - $desc"
    else
        echo -e "${RED}❌ Missing: $file${NC}"
    fi
done

echo ""
echo -e "${BLUE}🔧 Driver Suite Analysis${NC}"
echo "----------------------------------------"

# Check driver files
declare -a drivers=(
    "drivers/uart.c:Universal UART driver"
    "drivers/uart.h:UART header"
    "drivers/serial.c:x86 Serial driver"
    "drivers/serial.h:Serial header"
    "drivers/vga.c:x86 VGA driver"
    "drivers/vga.h:VGA header"
    "drivers/i2c.c:I2C bus controller"
    "drivers/i2c.h:I2C header"
    "drivers/spi.c:SPI bus controller"
    "drivers/spi.h:SPI header"
    "drivers/ai_hat/ai_hat.c:AI HAT integration"
    "drivers/ai_hat/ai_hat.h:AI HAT header"
)

for entry in "${drivers[@]}"; do
    file="${entry%%:*}"
    desc="${entry##*:}"
    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✅ $file${NC} - $desc"
    else
        echo -e "${RED}❌ Missing: $file${NC}"
    fi
done

echo ""
echo -e "${BLUE}🧪 QEMU Compatibility Check${NC}"
echo "----------------------------------------"

# Check QEMU installations
declare -a qemu_systems=(
    "qemu-system-i386:x86_64 emulation"
    "qemu-system-aarch64:ARM64 emulation"
    "qemu-system-arm:ARM32 emulation"
    "qemu-system-riscv64:RISC-V emulation"
)

for entry in "${qemu_systems[@]}"; do
    cmd="${entry%%:*}"
    desc="${entry##*:}"
    if command -v "$cmd" >/dev/null 2>&1; then
        version=$($cmd --version | head -1)
        echo -e "${GREEN}✅ $cmd${NC} - $desc ($version)"
    else
        echo -e "${YELLOW}⚠️  $cmd not found${NC} - $desc (install with setup-macos.sh)"
    fi
done

echo ""
echo -e "${BLUE}📦 Build Artifacts Check${NC}"
echo "----------------------------------------"

# Check build directories and artifacts
declare -a architectures=("x86_64" "aarch64" "arm" "riscv64")

for arch in "${architectures[@]}"; do
    if [[ -d "build/$arch" ]]; then
        echo -e "${GREEN}✅ build/$arch/${NC}"
        
        # Check for kernel files
        if [[ -f "build/$arch/kernel.elf" ]]; then
            size=$(du -h "build/$arch/kernel.elf" | cut -f1)
            echo -e "   📦 kernel.elf ($size)"
        fi
        
        if [[ -f "build/$arch/kernel.img" ]]; then
            size=$(du -h "build/$arch/kernel.img" | cut -f1)
            echo -e "   📦 kernel.img ($size)"
        fi
        
        if [[ -f "build/$arch/kernel.map" ]]; then
            echo -e "   📋 kernel.map"
        fi
    else
        echo -e "${YELLOW}⚠️  build/$arch/ not found${NC} (run ./build-macos.sh $arch)"
    fi
done

echo ""
echo -e "${BLUE}🎯 Functionality Test${NC}"
echo "----------------------------------------"

# Test x86_64 kernel if available
if [[ -f "build/x86_64/kernel.elf" ]] && command -v qemu-system-i386 >/dev/null 2>&1; then
    echo -e "${GREEN}✅ x86_64 kernel ready for testing${NC}"
    echo "   Test command: qemu-system-i386 -kernel build/x86_64/kernel.elf -nographic"
    echo "   Expected: Full SAGE OS with shell and 15+ commands"
else
    echo -e "${YELLOW}⚠️  x86_64 kernel not ready for testing${NC}"
fi

# Test ARM64 kernel if available
if [[ -f "build/aarch64/kernel.elf" ]] && command -v qemu-system-aarch64 >/dev/null 2>&1; then
    echo -e "${GREEN}✅ ARM64 kernel ready for testing${NC}"
    echo "   Test command: qemu-system-aarch64 -M virt -kernel build/aarch64/kernel.elf -nographic"
    echo "   Expected: SAGE OS banner and system ready message"
else
    echo -e "${YELLOW}⚠️  ARM64 kernel not ready for testing${NC}"
fi

echo ""
echo -e "${BLUE}📊 Development Environment Summary${NC}"
echo "=============================================="

# Count available features
script_count=0
boot_count=0
driver_count=0
qemu_count=0
build_count=0

[[ -x "./build-macos.sh" ]] && ((script_count++))
[[ -x "./setup-macos.sh" ]] && ((script_count++))
[[ -x "./test-qemu.sh" ]] && ((script_count++))

for file in boot/boot_*.S; do
    [[ -f "$file" ]] && ((boot_count++))
done

for file in drivers/*.c drivers/*/*.c; do
    [[ -f "$file" ]] && ((driver_count++))
done

for cmd in qemu-system-i386 qemu-system-aarch64 qemu-system-arm qemu-system-riscv64; do
    command -v "$cmd" >/dev/null 2>&1 && ((qemu_count++))
done

for arch in x86_64 aarch64 arm riscv64; do
    [[ -d "build/$arch" ]] && ((build_count++))
done

echo "Core Scripts: $script_count/3"
echo "Boot Files: $boot_count"
echo "Driver Files: $driver_count"
echo "QEMU Systems: $qemu_count/4"
echo "Built Architectures: $build_count/4"

echo ""
if [[ $script_count -eq 3 ]] && [[ $boot_count -ge 4 ]] && [[ $driver_count -ge 6 ]]; then
    echo -e "${GREEN}🎉 macOS M1 Development Environment: READY${NC}"
    echo -e "${GREEN}✅ All core components available${NC}"
    echo -e "${GREEN}✅ Comprehensive driver suite present${NC}"
    echo -e "${GREEN}✅ Multi-architecture boot system ready${NC}"
    
    if [[ $qemu_count -ge 2 ]]; then
        echo -e "${GREEN}✅ QEMU testing environment ready${NC}"
    fi
    
    if [[ $build_count -ge 1 ]]; then
        echo -e "${GREEN}✅ Build artifacts available${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}🚀 Quick Start Commands:${NC}"
    echo "  ./setup-macos.sh              # Install dependencies"
    echo "  ./build-macos.sh all          # Build all architectures"
    echo "  ./build-macos.sh x86_64 --test-only  # Test x86_64 kernel"
    
else
    echo -e "${YELLOW}⚠️  macOS M1 Development Environment: INCOMPLETE${NC}"
    echo "Run ./setup-macos.sh to install missing dependencies"
fi

echo ""
echo -e "${BLUE}📚 Documentation Available:${NC}"
echo "  MACOS_M1_DEVELOPMENT_GUIDE.md  # Complete macOS M1 guide"
echo "  FINAL_PROJECT_ANALYSIS_COMPLETE.md  # Project status"
echo "  README.md                      # General documentation"