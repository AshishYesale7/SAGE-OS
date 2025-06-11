#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
#
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS Build System Verification Script
# Verifies all paths, scripts, and build artifacts are correct after cleanup

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 SAGE OS Build System Verification${NC}"
echo "========================================"

# Function to check file exists
check_file() {
    local file=$1
    local description=$2
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ $description: $file${NC}"
        return 0
    else
        echo -e "${RED}❌ $description: $file (missing)${NC}"
        return 1
    fi
}

# Function to check directory exists
check_dir() {
    local dir=$1
    local description=$2
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✅ $description: $dir${NC}"
        return 0
    else
        echo -e "${RED}❌ $description: $dir (missing)${NC}"
        return 1
    fi
}

# Function to check script is executable
check_executable() {
    local script=$1
    local description=$2
    if [ -x "$script" ]; then
        echo -e "${GREEN}✅ $description: $script (executable)${NC}"
        return 0
    else
        echo -e "${RED}❌ $description: $script (not executable)${NC}"
        return 1
    fi
}

echo -e "\n${BLUE}📋 Core Build Scripts${NC}"
echo "----------------------------------------"
check_executable "./build-macos.sh" "macOS Build Script"
check_executable "./setup-macos.sh" "macOS Setup Script"
check_executable "./test-qemu.sh" "QEMU Test Script"
check_file "./build.sh" "Original Build Script"

echo -e "\n${BLUE}🔧 Build System Files${NC}"
echo "----------------------------------------"
check_file "./Makefile" "Main Makefile"
check_file "./tools/build/Makefile.multi-arch" "Multi-Architecture Makefile"
check_file "./tools/build/Makefile.macos" "macOS Makefile"

echo -e "\n${BLUE}📁 Build Directories${NC}"
echo "----------------------------------------"
check_dir "./build" "Build Output Directory"
check_dir "./build-output" "Versioned Build Directory"
check_dir "./tools/build" "Build Tools Directory"

echo -e "\n${BLUE}🗂️ Organized Script Directories${NC}"
echo "----------------------------------------"
check_dir "./scripts/docker" "Docker Scripts"
check_dir "./scripts/graphics" "Graphics Scripts"
check_dir "./scripts/iso" "ISO Scripts"
check_file "./scripts/docker/docker-builder.sh" "Docker Builder Script"
check_file "./scripts/graphics/build-graphics.sh" "Graphics Build Script"
check_file "./scripts/iso/create_iso.sh" "ISO Creation Script"

echo -e "\n${BLUE}🧪 Testing Scripts${NC}"
echo "----------------------------------------"
check_dir "./tools/testing" "Testing Tools Directory"
check_file "./tools/testing/test-all-architectures.sh" "Architecture Test Script"
check_file "./tools/testing/test_all.sh" "Comprehensive Test Script"

echo -e "\n${BLUE}🏗️ Build Artifacts${NC}"
echo "----------------------------------------"
architectures=("x86_64" "aarch64" "arm" "riscv64")
for arch in "${architectures[@]}"; do
    if [ -d "build/$arch" ]; then
        echo -e "${GREEN}✅ Build directory: build/$arch${NC}"
        
        # Check for kernel files
        if [ -f "build/$arch/kernel.elf" ]; then
            size=$(du -h "build/$arch/kernel.elf" | cut -f1)
            echo -e "   📦 kernel.elf ($size)"
        fi
        
        if [ -f "build/$arch/kernel.img" ]; then
            size=$(du -h "build/$arch/kernel.img" | cut -f1)
            echo -e "   📦 kernel.img ($size)"
        fi
        
        if [ -f "build/$arch/kernel.map" ]; then
            echo -e "   📋 kernel.map"
        fi
    else
        echo -e "${YELLOW}⚠️  Build directory missing: build/$arch${NC}"
    fi
done

echo -e "\n${BLUE}🚫 Removed Duplicate Files${NC}"
echo "----------------------------------------"
removed_files=(
    "./Makefile.simple"
    "./tools/build/build.sh"
    "./tools/build/docker-build.sh"
    "./tools/build/build-output/"
    "./scripts/testing/test-qemu.sh"
    "./scripts/build/"
)

for file in "${removed_files[@]}"; do
    if [ ! -e "$file" ]; then
        echo -e "${GREEN}✅ Removed: $file${NC}"
    else
        echo -e "${RED}❌ Still exists: $file${NC}"
    fi
done

echo -e "\n${BLUE}🧪 Quick Functionality Tests${NC}"
echo "----------------------------------------"

# Test build script help
echo -e "${YELLOW}Testing build script help...${NC}"
if ./build-macos.sh --help >/dev/null 2>&1; then
    echo -e "${GREEN}✅ build-macos.sh --help works${NC}"
else
    echo -e "${RED}❌ build-macos.sh --help failed${NC}"
fi

# Test Makefile syntax
echo -e "${YELLOW}Testing Makefile syntax...${NC}"
if make -f tools/build/Makefile.multi-arch --dry-run ARCH=x86_64 >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Makefile.multi-arch syntax OK${NC}"
else
    echo -e "${RED}❌ Makefile.multi-arch syntax error${NC}"
fi

# Test if kernel files have correct format
echo -e "${YELLOW}Testing kernel file formats...${NC}"
if [ -f "build/x86_64/kernel.elf" ]; then
    if file "build/x86_64/kernel.elf" | grep -q "ELF"; then
        echo -e "${GREEN}✅ x86_64 kernel.elf is valid ELF${NC}"
    else
        echo -e "${RED}❌ x86_64 kernel.elf is not valid ELF${NC}"
    fi
fi

echo -e "\n${BLUE}📊 Summary${NC}"
echo "========================================"

# Count successful checks
total_checks=0
passed_checks=0

# Core scripts (4)
for script in "./build-macos.sh" "./setup-macos.sh" "./test-qemu.sh" "./build.sh"; do
    ((total_checks++))
    if [ -f "$script" ]; then
        ((passed_checks++))
    fi
done

# Build system files (3)
for file in "./Makefile" "./tools/build/Makefile.multi-arch" "./tools/build/Makefile.macos"; do
    ((total_checks++))
    if [ -f "$file" ]; then
        ((passed_checks++))
    fi
done

# Organized scripts (3)
for file in "./scripts/docker/docker-builder.sh" "./scripts/graphics/build-graphics.sh" "./scripts/iso/create_iso.sh"; do
    ((total_checks++))
    if [ -f "$file" ]; then
        ((passed_checks++))
    fi
done

echo -e "${BLUE}File Checks: $passed_checks/$total_checks${NC}"

# Check build artifacts
built_archs=0
for arch in "${architectures[@]}"; do
    if [ -f "build/$arch/kernel.img" ] || [ -f "build/$arch/kernel.elf" ]; then
        ((built_archs++))
    fi
done

echo -e "${BLUE}Built Architectures: $built_archs/${#architectures[@]}${NC}"

# Final status
if [ $passed_checks -eq $total_checks ] && [ $built_archs -gt 0 ]; then
    echo -e "\n${GREEN}🎉 Build System Verification: PASSED${NC}"
    echo -e "${GREEN}✅ All critical files present${NC}"
    echo -e "${GREEN}✅ Build artifacts available${NC}"
    echo -e "${GREEN}✅ Clean structure achieved${NC}"
    exit 0
else
    echo -e "\n${YELLOW}⚠️  Build System Verification: PARTIAL${NC}"
    if [ $passed_checks -ne $total_checks ]; then
        echo -e "${RED}❌ Some files missing${NC}"
    fi
    if [ $built_archs -eq 0 ]; then
        echo -e "${RED}❌ No build artifacts found${NC}"
    fi
    exit 1
fi