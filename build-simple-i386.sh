#!/bin/bash
# Simple build script for i386 - Cross-platform compatible

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Building SAGE OS i386 (Simple Version)${NC}"
echo "========================================"

# Detect operating system
OS_TYPE=$(uname -s)
echo -e "${BLUE}Detected OS: $OS_TYPE${NC}"

# Create build directory
mkdir -p build/i386
mkdir -p build-output

# Set compiler based on OS
if [[ "$OS_TYPE" == "Darwin" ]]; then
    # macOS
    CC="clang"
    CFLAGS="-target i386-pc-none-elf -nostdlib -ffreestanding -O2 -Wall -Wextra -m32 -D__i386__ -fno-pic -fno-pie -fno-stack-protector"
    ASFLAGS="-target i386-pc-none-elf -m32 -D__i386__"
    echo -e "${YELLOW}Using macOS clang compiler${NC}"
else
    # Linux and others
    CC="gcc"
    CFLAGS="-nostdlib -nostartfiles -ffreestanding -O2 -Wall -Wextra -m32 -D__i386__ -fno-pic -fno-pie"
    ASFLAGS="$CFLAGS"
    echo -e "${YELLOW}Using GCC compiler${NC}"
fi

INCLUDES="-I. -Ikernel -Idrivers"

# Compile boot.S
echo -e "${BLUE}Compiling boot.S...${NC}"
if ! $CC $ASFLAGS -c boot/boot_i386.S -o build/i386/boot.o; then
    echo -e "${RED}Boot assembly compilation failed${NC}"
    exit 1
fi

# Compile kernel_simple.c
echo -e "${BLUE}Compiling kernel_simple.c...${NC}"
if ! $CC $CFLAGS $INCLUDES -c kernel/kernel_simple.c -o build/i386/kernel.o; then
    echo -e "${RED}Kernel compilation failed${NC}"
    exit 1
fi

# Compile shell.c
echo -e "${BLUE}Compiling shell.c...${NC}"
if ! $CC $CFLAGS $INCLUDES -c kernel/shell.c -o build/i386/shell.o; then
    echo -e "${RED}Shell compilation failed${NC}"
    exit 1
fi

# Compile filesystem.c
echo -e "${BLUE}Compiling filesystem.c...${NC}"
if ! $CC $CFLAGS $INCLUDES -c kernel/filesystem.c -o build/i386/filesystem.o; then
    echo -e "${RED}Filesystem compilation failed${NC}"
    exit 1
fi

# Compile memory.c
echo -e "${BLUE}Compiling memory.c...${NC}"
if ! $CC $CFLAGS $INCLUDES -c kernel/memory.c -o build/i386/memory.o; then
    echo -e "${RED}Memory management compilation failed${NC}"
    exit 1
fi

# Compile stdio_simple.c
echo -e "${BLUE}Compiling stdio_simple.c...${NC}"
if ! $CC $CFLAGS $INCLUDES -c kernel/stdio_simple.c -o build/i386/stdio.o; then
    echo -e "${RED}Stdio compilation failed${NC}"
    exit 1
fi

# Compile uart.c
echo -e "${BLUE}Compiling uart.c...${NC}"
if ! $CC $CFLAGS $INCLUDES -c drivers/uart.c -o build/i386/uart.o; then
    echo -e "${RED}UART driver compilation failed${NC}"
    exit 1
fi

# Compile serial.c
echo -e "${BLUE}Compiling serial.c...${NC}"
if ! $CC $CFLAGS $INCLUDES -c drivers/serial.c -o build/i386/serial.o; then
    echo -e "${RED}Serial driver compilation failed${NC}"
    exit 1
fi

# Link everything
echo -e "${BLUE}Linking...${NC}"
if [[ "$OS_TYPE" == "Darwin" ]]; then
    # macOS linking - use ld directly with proper flags
    if ! ld -arch i386 -T linker_i386.ld -o build/i386/kernel.elf \
        build/i386/boot.o build/i386/kernel.o build/i386/shell.o build/i386/filesystem.o \
        build/i386/memory.o build/i386/stdio.o build/i386/uart.o build/i386/serial.o; then
        echo -e "${RED}Linking failed${NC}"
        exit 1
    fi
else
    # Linux linking
    if ! ld -m elf_i386 -T linker_i386.ld -o build/i386/kernel.elf \
        build/i386/boot.o build/i386/kernel.o build/i386/shell.o build/i386/filesystem.o \
        build/i386/memory.o build/i386/stdio.o build/i386/uart.o build/i386/serial.o; then
        echo -e "${RED}Linking failed${NC}"
        exit 1
    fi
fi

# Get current timestamp for unique naming
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
VERSION=$(cat VERSION 2>/dev/null || echo "1.0.2")

# Copy to build-output with new naming convention
OUTPUT_NAME="sage-os-v${VERSION}-${TIMESTAMP}-i386-enhanced.elf"
cp build/i386/kernel.elf build-output/${OUTPUT_NAME}

echo -e "${GREEN}Build completed successfully!${NC}"
echo "Kernel: build-output/${OUTPUT_NAME}"
echo ""
echo -e "${BLUE}To run in QEMU:${NC}"
echo "qemu-system-i386 -kernel build-output/${OUTPUT_NAME} -nographic"