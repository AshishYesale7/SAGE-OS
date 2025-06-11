#!/bin/bash

# Run SAGE-OS i386 graphics build in QEMU (no HVF, no GUI)
QEMU_BIN="qemu-system-i386"
KERNEL_PATH="build/i386-graphics/kernel.elf"
MEMORY="128M"

# Check if kernel exists
if [ ! -f "$KERNEL_PATH" ]; then
  echo "[ERROR] Kernel not found at $KERNEL_PATH"
  exit 1
fi

# Run QEMU
echo "[INFO] Launching QEMU with $KERNEL_PATH"
$QEMU_BIN -kernel "$KERNEL_PATH" -m $MEMORY -nographic
