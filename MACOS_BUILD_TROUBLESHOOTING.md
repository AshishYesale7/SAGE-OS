# macOS Build Troubleshooting Guide for SAGE OS i386

This guide helps resolve common build issues when compiling SAGE OS on macOS.

## Quick Fix for Your Error

The error you're seeing:
```
boot/boot_i386.S:22:5: error: invalid instruction
    cli
    ^
```

This happens because macOS clang doesn't recognize x86 assembly by default. Here are the solutions:

## Solution 1: Use the Updated Build Script

Use the updated `build-simple-i386.sh` which automatically detects macOS:

```bash
./build-simple-i386.sh
```

## Solution 2: Use the macOS-Specific Build Script

Use the dedicated macOS build script:

```bash
./build-simple-i386-macos.sh
```

## Solution 3: Manual Fix

If you want to fix the original script manually, replace the compiler line:

**Original (broken on macOS):**
```bash
gcc $CFLAGS -c boot/boot_i386.S -o build/i386/boot.o
```

**Fixed for macOS:**
```bash
clang -target i386-pc-none-elf -m32 -c boot/boot_i386.S -o build/i386/boot.o
```

## Prerequisites for macOS

1. **Install Xcode Command Line Tools:**
   ```bash
   xcode-select --install
   ```

2. **Verify clang is available:**
   ```bash
   clang --version
   ```

3. **Install QEMU for testing (optional):**
   ```bash
   brew install qemu
   ```

## Common macOS Build Issues and Fixes

### Issue 1: "invalid instruction" errors in assembly
**Cause:** macOS clang needs explicit target specification for x86 assembly
**Fix:** Use `-target i386-pc-none-elf` flag

### Issue 2: Linker errors
**Cause:** macOS uses different linker than Linux
**Fix:** Use clang as linker with `-nostdlib` instead of direct `ld` calls

### Issue 3: "unknown argument" warnings
**Cause:** Some GCC flags aren't supported by clang
**Fix:** Use macOS-specific flags like `-fno-stack-protector`

## Step-by-Step Manual Build (macOS)

If the scripts don't work, try building manually:

```bash
# 1. Create directories
mkdir -p build/i386 output/i386

# 2. Compile boot assembly
clang -target i386-pc-none-elf -m32 -c boot/boot_i386.S -o build/i386/boot.o

# 3. Compile kernel
clang -target i386-pc-none-elf -nostdlib -ffreestanding -O2 -Wall -m32 -D__i386__ -fno-pic -fno-pie -fno-stack-protector -I. -Ikernel -Idrivers -c kernel/kernel_simple.c -o build/i386/kernel.o

# 4. Compile other components
clang -target i386-pc-none-elf -nostdlib -ffreestanding -O2 -Wall -m32 -D__i386__ -fno-pic -fno-pie -fno-stack-protector -I. -Ikernel -Idrivers -c kernel/shell.c -o build/i386/shell.o

clang -target i386-pc-none-elf -nostdlib -ffreestanding -O2 -Wall -m32 -D__i386__ -fno-pic -fno-pie -fno-stack-protector -I. -Ikernel -Idrivers -c kernel/filesystem.c -o build/i386/filesystem.o

clang -target i386-pc-none-elf -nostdlib -ffreestanding -O2 -Wall -m32 -D__i386__ -fno-pic -fno-pie -fno-stack-protector -I. -Ikernel -Idrivers -c kernel/memory.c -o build/i386/memory.o

clang -target i386-pc-none-elf -nostdlib -ffreestanding -O2 -Wall -m32 -D__i386__ -fno-pic -fno-pie -fno-stack-protector -I. -Ikernel -Idrivers -c kernel/stdio_simple.c -o build/i386/stdio.o

clang -target i386-pc-none-elf -nostdlib -ffreestanding -O2 -Wall -m32 -D__i386__ -fno-pic -fno-pie -fno-stack-protector -I. -Ikernel -Idrivers -c drivers/uart.c -o build/i386/uart.o

clang -target i386-pc-none-elf -nostdlib -ffreestanding -O2 -Wall -m32 -D__i386__ -fno-pic -fno-pie -fno-stack-protector -I. -Ikernel -Idrivers -c drivers/serial.c -o build/i386/serial.o

# 5. Link everything
clang -target i386-unknown-none -nostdlib -Wl,-T,linker_i386.ld -o build/i386/kernel.elf build/i386/boot.o build/i386/kernel.o build/i386/shell.o build/i386/filesystem.o build/i386/memory.o build/i386/stdio.o build/i386/uart.o build/i386/serial.o

# 6. Copy to output
cp build/i386/kernel.elf output/i386/sage-os-v1.0.1-i386-macos.elf
```

## Testing the Build

Once built successfully, test with QEMU:

```bash
qemu-system-i386 -kernel output/i386/sage-os-v1.0.1-i386-macos.elf -nographic
```

To exit QEMU: Press `Ctrl+A` then `X`

## Alternative: Use Docker

If native macOS building continues to fail, use Docker:

```bash
# Build using Docker (Linux environment)
docker run --rm -v $(pwd):/workspace -w /workspace gcc:latest ./build-simple-i386.sh
```

## Verification Steps

After a successful build:

1. **Check file exists:**
   ```bash
   ls -la output/i386/sage-os-v1.0.1-i386-*.elf
   ```

2. **Check file type:**
   ```bash
   file output/i386/sage-os-v1.0.1-i386-*.elf
   ```

3. **Check size (should be reasonable, not empty):**
   ```bash
   ls -lh output/i386/sage-os-v1.0.1-i386-*.elf
   ```

## Getting Help

If you continue to have issues:

1. Check that all source files exist
2. Verify Xcode Command Line Tools are installed
3. Try the Docker approach as a fallback
4. Check the build output for specific error messages

## Files Modified for macOS Compatibility

- `build-simple-i386.sh` - Updated with macOS detection
- `build-simple-i386-macos.sh` - macOS-specific build script
- `boot/boot_i386.S` - Updated assembly syntax
- `boot/boot_i386_macos.S` - macOS-specific assembly version