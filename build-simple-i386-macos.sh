#!/bin/bash
# macOS-compatible build script for i386 SAGE OS
# Designed to work with macOS clang and native tools

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Building SAGE OS i386 (macOS Compatible)${NC}"
echo "========================================"

# Detect macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${YELLOW}Warning: This script is optimized for macOS${NC}"
fi

# Create build directories
mkdir -p build/i386
mkdir -p output/i386

# Check for required tools
echo -e "${BLUE}Checking build tools...${NC}"

# Check for clang (should be available on macOS)
if ! command -v clang &> /dev/null; then
    echo -e "${RED}Error: clang not found. Please install Xcode Command Line Tools:${NC}"
    echo "xcode-select --install"
    exit 1
fi

# Check for ld (should be available on macOS)
if ! command -v ld &> /dev/null; then
    echo -e "${RED}Error: ld not found. Please install Xcode Command Line Tools${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Build tools found${NC}"

# Compiler and linker settings for macOS
CC="clang"
LD="ld"

# macOS-specific compiler flags
CFLAGS="-target i386-pc-none-elf -nostdlib -ffreestanding -O2 -Wall -Wextra -m32 -D__i386__ -fno-pic -fno-pie -fno-stack-protector"
ASFLAGS="-target i386-pc-none-elf -m32 -D__i386__"
INCLUDES="-I. -Ikernel -Idrivers"

# macOS-specific linker flags
LDFLAGS="-arch i386 -static -nostdlib"

echo -e "${BLUE}Compiler: $CC${NC}"
echo -e "${BLUE}Linker: $LD${NC}"

# Step 1: Compile boot assembly
echo -e "${BLUE}Step 1: Compiling boot assembly...${NC}"
if $CC $ASFLAGS -c boot/boot_i386.S -o build/i386/boot.o; then
    echo -e "${GREEN}✓ Boot assembly compiled${NC}"
else
    echo -e "${RED}✗ Boot assembly compilation failed${NC}"
    echo -e "${YELLOW}Trying alternative assembly compilation...${NC}"
    
    # Try with different flags for macOS
    if $CC -target i386-unknown-none -m32 -c boot/boot_i386.S -o build/i386/boot.o; then
        echo -e "${GREEN}✓ Boot assembly compiled (alternative method)${NC}"
    else
        echo -e "${RED}✗ Boot assembly compilation failed completely${NC}"
        echo -e "${YELLOW}Creating a macOS-compatible boot file...${NC}"
        
        # Create a macOS-compatible boot assembly file
        cat > build/i386/boot_macos.S << 'EOF'
# macOS-compatible i386 boot assembly
.section __TEXT,__text
.globl _start

# Multiboot header
.align 4
multiboot_header:
    .long 0x1BADB002          # magic
    .long 0x00000000          # flags  
    .long -(0x1BADB002 + 0x00000000)  # checksum

_start:
    # Disable interrupts
    cli
    
    # Set up stack
    movl $stack_top, %esp
    
    # Clear direction flag
    cld
    
    # Call kernel main
    call _kernel_main
    
    # If kernel_main returns, halt
halt_loop:
    hlt
    jmp halt_loop

# Stack space
.section __DATA,__bss
.align 16
stack_bottom:
    .space 16384  # 16KB stack
stack_top:
EOF
        
        if $CC -target i386-unknown-none -m32 -c build/i386/boot_macos.S -o build/i386/boot.o; then
            echo -e "${GREEN}✓ macOS-compatible boot assembly compiled${NC}"
        else
            echo -e "${RED}✗ All boot assembly compilation methods failed${NC}"
            exit 1
        fi
    fi
fi

# Step 2: Compile kernel
echo -e "${BLUE}Step 2: Compiling kernel...${NC}"
if [ -f "kernel/kernel_simple.c" ]; then
    if $CC $CFLAGS $INCLUDES -c kernel/kernel_simple.c -o build/i386/kernel.o; then
        echo -e "${GREEN}✓ Kernel compiled${NC}"
    else
        echo -e "${RED}✗ Kernel compilation failed${NC}"
        exit 1
    fi
else
    echo -e "${RED}✗ kernel/kernel_simple.c not found${NC}"
    exit 1
fi

# Step 3: Compile shell
echo -e "${BLUE}Step 3: Compiling shell...${NC}"
if [ -f "kernel/shell.c" ]; then
    if $CC $CFLAGS $INCLUDES -c kernel/shell.c -o build/i386/shell.o; then
        echo -e "${GREEN}✓ Shell compiled${NC}"
    else
        echo -e "${RED}✗ Shell compilation failed${NC}"
        exit 1
    fi
else
    echo -e "${RED}✗ kernel/shell.c not found${NC}"
    exit 1
fi

# Step 4: Compile filesystem
echo -e "${BLUE}Step 4: Compiling filesystem...${NC}"
if [ -f "kernel/filesystem.c" ]; then
    if $CC $CFLAGS $INCLUDES -c kernel/filesystem.c -o build/i386/filesystem.o; then
        echo -e "${GREEN}✓ Filesystem compiled${NC}"
    else
        echo -e "${RED}✗ Filesystem compilation failed${NC}"
        exit 1
    fi
else
    echo -e "${RED}✗ kernel/filesystem.c not found${NC}"
    exit 1
fi

# Step 5: Compile memory management
echo -e "${BLUE}Step 5: Compiling memory management...${NC}"
if [ -f "kernel/memory.c" ]; then
    if $CC $CFLAGS $INCLUDES -c kernel/memory.c -o build/i386/memory.o; then
        echo -e "${GREEN}✓ Memory management compiled${NC}"
    else
        echo -e "${RED}✗ Memory management compilation failed${NC}"
        exit 1
    fi
else
    echo -e "${RED}✗ kernel/memory.c not found${NC}"
    exit 1
fi

# Step 6: Compile stdio
echo -e "${BLUE}Step 6: Compiling stdio...${NC}"
if [ -f "kernel/stdio_simple.c" ]; then
    if $CC $CFLAGS $INCLUDES -c kernel/stdio_simple.c -o build/i386/stdio.o; then
        echo -e "${GREEN}✓ Stdio compiled${NC}"
    else
        echo -e "${RED}✗ Stdio compilation failed${NC}"
        exit 1
    fi
else
    echo -e "${RED}✗ kernel/stdio_simple.c not found${NC}"
    exit 1
fi

# Step 7: Compile UART driver
echo -e "${BLUE}Step 7: Compiling UART driver...${NC}"
if [ -f "drivers/uart.c" ]; then
    if $CC $CFLAGS $INCLUDES -c drivers/uart.c -o build/i386/uart.o; then
        echo -e "${GREEN}✓ UART driver compiled${NC}"
    else
        echo -e "${RED}✗ UART driver compilation failed${NC}"
        exit 1
    fi
else
    echo -e "${RED}✗ drivers/uart.c not found${NC}"
    exit 1
fi

# Step 8: Compile serial driver
echo -e "${BLUE}Step 8: Compiling serial driver...${NC}"
if [ -f "drivers/serial.c" ]; then
    if $CC $CFLAGS $INCLUDES -c drivers/serial.c -o build/i386/serial.o; then
        echo -e "${GREEN}✓ Serial driver compiled${NC}"
    else
        echo -e "${RED}✗ Serial driver compilation failed${NC}"
        exit 1
    fi
else
    echo -e "${RED}✗ drivers/serial.c not found${NC}"
    exit 1
fi

# Step 9: Create macOS-compatible linker script
echo -e "${BLUE}Step 9: Creating linker script...${NC}"
cat > build/i386/linker_macos.ld << 'EOF'
ENTRY(_start)

SECTIONS
{
    . = 0x100000;
    
    .text : {
        *(.text)
    }
    
    .rodata : {
        *(.rodata)
    }
    
    .data : {
        *(.data)
    }
    
    .bss : {
        *(.bss)
    }
}
EOF

# Step 10: Link everything
echo -e "${BLUE}Step 10: Linking...${NC}"

# Try different linking approaches for macOS
LINK_SUCCESS=false

# Method 1: Try with macOS ld
if $LD $LDFLAGS -T build/i386/linker_macos.ld -o build/i386/kernel.elf \
    build/i386/boot.o \
    build/i386/kernel.o \
    build/i386/shell.o \
    build/i386/filesystem.o \
    build/i386/memory.o \
    build/i386/stdio.o \
    build/i386/uart.o \
    build/i386/serial.o 2>/dev/null; then
    echo -e "${GREEN}✓ Linking successful (method 1)${NC}"
    LINK_SUCCESS=true
fi

# Method 2: Try with clang as linker
if [ "$LINK_SUCCESS" = false ]; then
    echo -e "${YELLOW}Trying alternative linking method...${NC}"
    if $CC -target i386-unknown-none -nostdlib -Wl,-T,build/i386/linker_macos.ld -o build/i386/kernel.elf \
        build/i386/boot.o \
        build/i386/kernel.o \
        build/i386/shell.o \
        build/i386/filesystem.o \
        build/i386/memory.o \
        build/i386/stdio.o \
        build/i386/uart.o \
        build/i386/serial.o; then
        echo -e "${GREEN}✓ Linking successful (method 2)${NC}"
        LINK_SUCCESS=true
    fi
fi

# Method 3: Try without linker script
if [ "$LINK_SUCCESS" = false ]; then
    echo -e "${YELLOW}Trying linking without custom linker script...${NC}"
    if $CC -target i386-unknown-none -nostdlib -o build/i386/kernel.elf \
        build/i386/boot.o \
        build/i386/kernel.o \
        build/i386/shell.o \
        build/i386/filesystem.o \
        build/i386/memory.o \
        build/i386/stdio.o \
        build/i386/uart.o \
        build/i386/serial.o; then
        echo -e "${GREEN}✓ Linking successful (method 3)${NC}"
        LINK_SUCCESS=true
    fi
fi

if [ "$LINK_SUCCESS" = false ]; then
    echo -e "${RED}✗ All linking methods failed${NC}"
    exit 1
fi

# Step 11: Copy to output
echo -e "${BLUE}Step 11: Copying to output directory...${NC}"
cp build/i386/kernel.elf output/i386/sage-os-v1.0.1-i386-macos.elf

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Build completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Output file:${NC} output/i386/sage-os-v1.0.1-i386-macos.elf"
echo -e "${BLUE}File size:${NC} $(ls -lh output/i386/sage-os-v1.0.1-i386-macos.elf | awk '{print $5}')"
echo ""
echo -e "${BLUE}To test with QEMU (if available):${NC}"
echo "qemu-system-i386 -kernel output/i386/sage-os-v1.0.1-i386-macos.elf -nographic"
echo ""
echo -e "${BLUE}To install QEMU on macOS:${NC}"
echo "brew install qemu"