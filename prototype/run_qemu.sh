#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS QEMU Runner Script
# This script helps run SAGE OS in QEMU for testing

# Check if kernel8.img exists
if [ ! -f "build/kernel8.img" ]; then
    echo "Error: kernel8.img not found. Build the kernel first with 'make'."
    exit 1
fi

# Default QEMU options
QEMU_CMD="qemu-system-aarch64"
QEMU_OPTS="-M raspi3 -kernel build/kernel8.img -serial stdio"

# Platform selection
PLATFORM="raspi3"

# Check if QEMU is installed
if ! command -v $QEMU_CMD &> /dev/null; then
    echo "Error: $QEMU_CMD not found. Please install QEMU."
    echo "On Debian/Ubuntu: sudo apt-get install qemu-system-arm"
    echo "On macOS: brew install qemu"
    exit 1
fi

# Parse command line arguments
DEBUG=0
GRAPHICS=0
MEMORY="1G"
AI_HAT=0
KERNEL_FILE="build/kernel8.img"

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--debug)
            DEBUG=1
            shift
            ;;
        -g|--graphics)
            GRAPHICS=1
            shift
            ;;
        -a|--ai-hat)
            AI_HAT=1
            shift
            ;;
        -p|--platform)
            if [ "$2" = "rpi5" ]; then
                PLATFORM="raspi4"  # Use raspi4 as closest model for rpi5
                KERNEL_FILE="build/kernel8-rpi5.img"
            elif [ "$2" = "rpi4" ]; then
                PLATFORM="raspi4"
                KERNEL_FILE="build/kernel8.img"
            elif [ "$2" = "rpi3" ]; then
                PLATFORM="raspi3"
                KERNEL_FILE="build/kernel8.img"
            else
                echo "Unknown platform: $2"
                echo "Supported platforms: rpi3, rpi4, rpi5"
                exit 1
            fi
            shift 2
            ;;
        -m|--memory)
            MEMORY="$2"
            shift 2
            ;;
        -k|--kernel)
            KERNEL_FILE="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  -d, --debug             Run with GDB server enabled"
            echo "  -g, --graphics          Enable graphical output (not just serial)"
            echo "  -a, --ai-hat            Enable AI HAT+ emulation"
            echo "  -p, --platform PLATFORM Select platform (rpi3, rpi4, rpi5)"
            echo "  -m, --memory SIZE       Set memory size (default: 1G)"
            echo "  -k, --kernel FILE       Specify kernel image file"
            echo "  -h, --help              Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Check if kernel file exists
if [ ! -f "$KERNEL_FILE" ]; then
    echo "Error: Kernel file $KERNEL_FILE not found."
    echo "Build the kernel first with 'make' or specify a different kernel file with -k."
    exit 1
fi

# Add debug options if requested
if [ $DEBUG -eq 1 ]; then
    QEMU_OPTS="$QEMU_OPTS -s -S"
    echo "Debug mode enabled. Connect with:"
    echo "  aarch64-linux-gnu-gdb build/kernel.elf -ex 'target remote localhost:1234'"
fi

# Add graphics options if requested
if [ $GRAPHICS -eq 1 ]; then
    # No special options needed, just don't use -nographic
    echo "Graphics mode enabled"
else
    QEMU_OPTS="$QEMU_OPTS -nographic"
fi

# Update QEMU options with platform and memory
QEMU_OPTS="-M $PLATFORM -kernel $KERNEL_FILE -m $MEMORY -serial stdio"

# Add AI HAT+ emulation if requested
if [ $AI_HAT -eq 1 ]; then
    if [ "$PLATFORM" = "raspi4" ]; then
        # Add I2C and SPI devices for AI HAT+ emulation
        QEMU_OPTS="$QEMU_OPTS -device i2c-gpio,bus=i2c-bus.0,name=i2c-ai-hat"
        QEMU_OPTS="$QEMU_OPTS -device spi-gpio,bus=spi-bus.0,name=spi-ai-hat"
        echo "AI HAT+ emulation enabled"
    else
        echo "Warning: AI HAT+ emulation is only supported on Raspberry Pi 4/5"
    fi
fi

# Add graphics options if requested
if [ $GRAPHICS -eq 1 ]; then
    # No special options needed, just don't use -nographic
    echo "Graphics mode enabled"
else
    QEMU_OPTS="$QEMU_OPTS -nographic"
fi

# Add debug options if requested (again, to ensure they're applied after other options)
if [ $DEBUG -eq 1 ]; then
    QEMU_OPTS="$QEMU_OPTS -s -S"
fi

# Run QEMU
echo "Starting QEMU with:"
echo "  Platform: $PLATFORM"
echo "  Memory: $MEMORY"
echo "  Kernel: $KERNEL_FILE"
if [ $AI_HAT -eq 1 ]; then
    echo "  AI HAT+: Enabled"
fi
if [ $DEBUG -eq 1 ]; then
    echo "  Debug: Enabled (waiting for GDB connection)"
fi
echo "Press Ctrl+A, X to exit QEMU"
echo "-----------------------------------"

$QEMU_CMD $QEMU_OPTS