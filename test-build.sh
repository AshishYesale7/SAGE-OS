#!/bin/bash
# Test script to verify the build works correctly

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}SAGE OS Build Test${NC}"
echo "=================="

# Test 1: Check if build script exists and is executable
echo -e "${BLUE}Test 1: Checking build script...${NC}"
if [ -x "./build-simple-i386.sh" ]; then
    echo -e "${GREEN}✓ build-simple-i386.sh is executable${NC}"
else
    echo -e "${RED}✗ build-simple-i386.sh not found or not executable${NC}"
    exit 1
fi

# Test 2: Check if all required source files exist
echo -e "${BLUE}Test 2: Checking source files...${NC}"
REQUIRED_FILES=(
    "boot/boot_i386.S"
    "kernel/kernel_simple.c"
    "kernel/shell.c"
    "kernel/filesystem.c"
    "kernel/memory.c"
    "kernel/stdio_simple.c"
    "drivers/uart.c"
    "drivers/serial.c"
    "linker_i386.ld"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓ $file exists${NC}"
    else
        echo -e "${RED}✗ $file missing${NC}"
        exit 1
    fi
done

# Test 3: Run the build
echo -e "${BLUE}Test 3: Running build...${NC}"
if ./build-simple-i386.sh; then
    echo -e "${GREEN}✓ Build completed successfully${NC}"
else
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi

# Test 4: Check if output file was created
echo -e "${BLUE}Test 4: Checking output file...${NC}"
OUTPUT_FILE="output/i386/sage-os-v1.0.1-i386-generic.elf"
if [ -f "$OUTPUT_FILE" ]; then
    FILE_SIZE=$(ls -lh "$OUTPUT_FILE" | awk '{print $5}')
    echo -e "${GREEN}✓ Output file created: $OUTPUT_FILE ($FILE_SIZE)${NC}"
else
    echo -e "${RED}✗ Output file not created${NC}"
    exit 1
fi

# Test 5: Basic file validation
echo -e "${BLUE}Test 5: Validating output file...${NC}"
if [ -s "$OUTPUT_FILE" ]; then
    echo -e "${GREEN}✓ Output file is not empty${NC}"
else
    echo -e "${RED}✗ Output file is empty${NC}"
    exit 1
fi

# Check file type if 'file' command is available
if command -v file &> /dev/null; then
    FILE_TYPE=$(file "$OUTPUT_FILE")
    echo -e "${BLUE}File type: $FILE_TYPE${NC}"
fi

# Test 6: Check build artifacts
echo -e "${BLUE}Test 6: Checking build artifacts...${NC}"
BUILD_FILES=(
    "build/i386/boot.o"
    "build/i386/kernel.o"
    "build/i386/shell.o"
    "build/i386/filesystem.o"
    "build/i386/memory.o"
    "build/i386/stdio.o"
    "build/i386/uart.o"
    "build/i386/serial.o"
)

for file in "${BUILD_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓ $file created${NC}"
    else
        echo -e "${YELLOW}⚠ $file missing (may be normal)${NC}"
    fi
done

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}All tests passed! Build is working correctly.${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Output file:${NC} $OUTPUT_FILE"
echo -e "${BLUE}File size:${NC} $(ls -lh "$OUTPUT_FILE" | awk '{print $5}')"
echo ""
echo -e "${BLUE}To test with QEMU (if available):${NC}"
echo "qemu-system-i386 -kernel $OUTPUT_FILE -nographic"
echo ""
echo -e "${BLUE}On macOS, install QEMU with:${NC}"
echo "brew install qemu"