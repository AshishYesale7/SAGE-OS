#!/bin/bash
# Simple build script for i386 without enhanced VGA

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Building SAGE OS i386 (Simple Version)${NC}"
echo "========================================"

# Create build directory
mkdir -p build/i386
mkdir -p output/i386

# Compiler flags for bare-metal development
CFLAGS="-nostdlib -nostartfiles -ffreestanding -O2 -Wall -Wextra -m32 -D__i386__ -fno-pic -fno-pie"
INCLUDES="-I. -Ikernel -Idrivers"

# Compile boot.S
echo -e "${BLUE}Compiling boot.S...${NC}"
gcc $CFLAGS -c boot/boot_i386.S -o build/i386/boot.o

# Compile kernel_simple.c
echo -e "${BLUE}Compiling kernel_simple.c...${NC}"
gcc $CFLAGS $INCLUDES -c kernel/kernel_simple.c -o build/i386/kernel.o

# Compile shell.c
echo -e "${BLUE}Compiling shell.c...${NC}"
gcc $CFLAGS $INCLUDES -c kernel/shell.c -o build/i386/shell.o

# Compile filesystem.c
echo -e "${BLUE}Compiling filesystem.c...${NC}"
gcc $CFLAGS $INCLUDES -c kernel/filesystem.c -o build/i386/filesystem.o

# Compile memory.c
echo -e "${BLUE}Compiling memory.c...${NC}"
gcc $CFLAGS $INCLUDES -c kernel/memory.c -o build/i386/memory.o

# Compile stdio_simple.c
echo -e "${BLUE}Compiling stdio_simple.c...${NC}"
gcc $CFLAGS $INCLUDES -c kernel/stdio_simple.c -o build/i386/stdio.o

# We don't need utils_simple.c anymore since all functions are in stdio_simple.c

# Compile uart.c
echo -e "${BLUE}Compiling uart.c...${NC}"
gcc $CFLAGS $INCLUDES -c drivers/uart.c -o build/i386/uart.o

# Compile serial.c
echo -e "${BLUE}Compiling serial.c...${NC}"
gcc $CFLAGS $INCLUDES -c drivers/serial.c -o build/i386/serial.o

# Link everything
echo -e "${BLUE}Linking...${NC}"
ld -m elf_i386 -T linker_i386.ld -o build/i386/kernel.elf build/i386/boot.o build/i386/kernel.o build/i386/shell.o build/i386/filesystem.o build/i386/memory.o build/i386/stdio.o build/i386/uart.o build/i386/serial.o

# Copy to output
cp build/i386/kernel.elf output/i386/sage-os-v1.0.1-i386-generic.elf

echo -e "${GREEN}Build completed successfully!${NC}"
echo "Kernel: output/i386/sage-os-v1.0.1-i386-generic.elf"
echo ""
echo -e "${BLUE}To run in QEMU:${NC}"
echo "qemu-system-i386 -kernel output/i386/sage-os-v1.0.1-i386-generic.elf -nographic"