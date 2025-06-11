<!--
─────────────────────────────────────────────────────────────────────────────
SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
SPDX-License-Identifier: BSD-3-Clause OR Proprietary
SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.

This file is part of the SAGE OS Project.
─────────────────────────────────────────────────────────────────────────────
-->

# SAGE OS Build System Fixes - June 2025

This document details the comprehensive fixes applied to the SAGE OS build system to resolve critical compilation issues and enable successful multi-architecture builds.

## Summary

**Status**: ✅ **RESOLVED** - All build issues fixed  
**Date**: June 11, 2025  
**Affected Architectures**: All (aarch64, arm, x86_64, riscv64)  
**Build Success Rate**: 8/8 (100%)

## Issues Resolved

### 1. Serial Function Redefinition Conflicts

**Problem**: 
```
error: redefinition of 'serial_putc'
error: redefinition of 'serial_puts'
```

**Root Cause**: 
Multiple files (`kernel/kernel.c`, `drivers/serial.c`, `kernel/kernel_graphics.c`) were defining the same serial functions, causing linker conflicts.

**Solution Applied**:
- **Centralized Implementation**: Moved all serial function implementations to `drivers/serial.c`
- **Architecture-Specific Code**: Added proper `#ifdef` blocks for different architectures:
  - x86_64/i386: Port-based I/O using `outb`/`inb`
  - aarch64: Memory-mapped I/O for QEMU virt machine
  - riscv64: UART register access for QEMU virt machine
  - arm/generic: Placeholder implementations
- **Forward Declarations**: Updated `kernel/kernel.c` to use forward declarations only

**Files Modified**:
- `drivers/serial.c`: Added comprehensive architecture-specific implementations
- `kernel/kernel.c`: Removed implementations, kept forward declarations
- `drivers/serial.h`: Updated function declarations

### 2. Kernel Main Function Conflicts

**Problem**:
```
error: multiple definition of 'kernel_main'
```

**Root Cause**: 
Both `kernel/kernel.c` and `kernel/kernel_graphics.c` defined `kernel_main` function, causing linker conflicts.

**Solution Applied**:
- **Makefile Fix**: Modified `tools/build/Makefile.multi-arch` to exclude `kernel_graphics.c`
- **Source Filtering**: Added `KERNEL_SOURCES_FILTERED` variable to filter out conflicting files
- **Build Logic**: Updated source file selection to avoid duplicate main functions

**Files Modified**:
- `tools/build/Makefile.multi-arch`: Added filtering logic

### 3. Missing Cross-Compiler Dependencies

**Problem**:
```
make: /usr/bin/aarch64-linux-gnu-gcc: No such file or directory
```

**Root Cause**: 
Cross-compilation toolchains were not installed on the build system.

**Solution Applied**:
- **Dependency Installation**: Installed required cross-compilers:
  ```bash
  apt-get install gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-riscv64-linux-gnu
  ```
- **QEMU Installation**: Added QEMU for testing (optional):
  ```bash
  apt-get install qemu-system-arm qemu-system-x86 qemu-system-misc
  ```

## Build Verification

### Test Results

All architectures now build successfully:

```bash
$ ./tools/build/build.sh build-all generic

🏗️  SAGE OS Multi-Architecture Build
====================================
📋 Build Plan:
   - aarch64 (rpi4)     ✅ SUCCESS
   - aarch64 (rpi5)     ✅ SUCCESS  
   - aarch64 (generic)  ✅ SUCCESS
   - riscv64 (generic)  ✅ SUCCESS
   - arm (rpi4)         ✅ SUCCESS
   - arm (rpi5)         ✅ SUCCESS
   - arm (generic)      ✅ SUCCESS
   - x86_64 (generic)   ✅ SUCCESS

📊 Build Summary:
==================
Total builds:      8
Successful builds: 8
Failed builds:     0
```

### Generated Artifacts

Build outputs are now successfully generated in `build-output/`:

```
SAGE-OS-0.1.0-20250611-134743-aarch64-generic.img  (24KB)
SAGE-OS-0.1.0-20250611-134743-aarch64-rpi4.img     (24KB)
SAGE-OS-0.1.0-20250611-134743-aarch64-rpi5.img     (24KB)
SAGE-OS-0.1.0-20250611-134743-arm-generic.img      (16KB)
SAGE-OS-0.1.0-20250611-134743-arm-rpi4.img         (16KB)
SAGE-OS-0.1.0-20250611-134743-arm-rpi5.img         (16KB)
SAGE-OS-0.1.0-20250611-134743-riscv64-generic.img  (18KB)
SAGE-OS-0.1.0-20250611-134743-x86_64-generic.img   (26KB)
```

## Technical Details

### Architecture-Specific Serial Implementation

The new serial driver properly handles different architectures:

#### x86_64/i386
```c
// Port-based I/O
static inline void outb(unsigned short port, unsigned char value) {
    __asm__ volatile ("outb %0, %1" : : "a"(value), "Nd"(port));
}

void serial_putc(char c) {
    while ((inb(COM1_PORT + 5) & 0x20) == 0);
    outb(COM1_PORT, c);
}
```

#### aarch64
```c
// Memory-mapped I/O for QEMU virt machine
#define UART0_BASE 0x09000000
#define UART_DR    (UART0_BASE + 0x00)
#define UART_FR    (UART0_BASE + 0x18)

void serial_putc(char c) {
    while (mmio_read(UART_FR) & UART_FR_TXFF);
    mmio_write(UART_DR, c);
}
```

#### riscv64
```c
// UART register access for QEMU virt machine
#define UART0_BASE 0x10000000
#define UART_THR   (UART0_BASE + 0x00)
#define UART_LSR   (UART0_BASE + 0x05)

void serial_putc(char c) {
    while (!(mmio_read_8(UART_LSR) & UART_LSR_THRE));
    mmio_write_8(UART_THR, c);
}
```

### Build System Improvements

#### Makefile Source Filtering
```makefile
# Exclude kernel_graphics.c to avoid conflicts with kernel.c
KERNEL_SOURCES_FILTERED = $(filter-out kernel/kernel_graphics.c,$(KERNEL_SOURCES_ALL))
KERNEL_SOURCES = $(if $(filter ON,$(ENABLE_AI)),$(filter-out $(wildcard kernel/ai/*.c),$(KERNEL_SOURCES_FILTERED)),$(KERNEL_SOURCES_FILTERED))
```

## Validation Steps

To verify the fixes work on your system:

1. **Clean Previous Builds**:
   ```bash
   make -f tools/build/Makefile.multi-arch clean
   ```

2. **Install Dependencies** (if needed):
   ```bash
   sudo apt-get install gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-riscv64-linux-gnu
   ```

3. **Test Single Architecture**:
   ```bash
   ./tools/build/build.sh build aarch64 generic
   ```

4. **Test All Architectures**:
   ```bash
   ./tools/build/build.sh build-all generic
   ```

5. **Verify Output**:
   ```bash
   ls -la build-output/
   ```

## Impact

### Before Fixes
- ❌ 0/8 architectures building successfully
- ❌ Serial function redefinition errors
- ❌ Kernel main function conflicts  
- ❌ Missing cross-compiler dependencies
- ❌ No usable kernel images generated

### After Fixes
- ✅ 8/8 architectures building successfully
- ✅ Clean compilation with no redefinition errors
- ✅ Proper source file organization
- ✅ All dependencies resolved
- ✅ Versioned kernel images generated for all platforms

## Future Maintenance

To prevent similar issues:

1. **Code Organization**: Keep function implementations in appropriate driver files
2. **Build Testing**: Test all architectures before committing changes
3. **Dependency Management**: Document and automate dependency installation
4. **CI/CD**: Implement automated build testing for all architectures

## Related Documentation

- [BUILD_SYSTEM.md](../BUILD_SYSTEM.md) - Updated with troubleshooting section
- [MULTI_ARCHITECTURE_GUIDE.md](../MULTI_ARCHITECTURE_GUIDE.md) - Architecture-specific details
- [DEPENDENCY_INSTALLATION_GUIDE.md](../DEPENDENCY_INSTALLATION_GUIDE.md) - Dependency setup

---

**Commit**: `5134fa3` - Fix build system issues and enable multi-architecture builds  
**Author**: openhands <openhands@all-hands.dev>  
**Date**: June 11, 2025