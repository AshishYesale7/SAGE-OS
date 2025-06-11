#!/bin/bash
# SAGE OS macOS Environment Setup
# Source this file to set up the build environment

# Add Homebrew paths
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Add cross-compiler paths
export PATH="/opt/homebrew/bin:$PATH"

# Set GNU tools as default
export SED="gsed"
export GREP="ggrep"
export FIND="gfind"
export TAR="gtar"

# QEMU paths
export QEMU_SYSTEM_I386="qemu-system-i386"
export QEMU_SYSTEM_X86_64="qemu-system-x86_64"
export QEMU_SYSTEM_AARCH64="qemu-system-aarch64"
export QEMU_SYSTEM_ARM="qemu-system-arm"
export QEMU_SYSTEM_RISCV64="qemu-system-riscv64"

echo "🍎 SAGE OS macOS environment loaded"
echo "Available cross-compilers:"
echo "  aarch64-unknown-linux-gnu-gcc"
echo "  x86_64-unknown-linux-gnu-gcc"
echo "  riscv64-unknown-linux-gnu-gcc"
echo "  arm-unknown-linux-gnueabihf-gcc"
