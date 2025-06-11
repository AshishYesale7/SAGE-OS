# 🔧 RISC-V Boot Fix Guide for SAGE-OS

## 🎯 Issue Analysis

**Current Status**: RISC-V kernel boots OpenSBI successfully but doesn't reach SAGE-OS kernel.

**Root Cause**: The kernel entry point needs to be configured for OpenSBI's S-mode handoff.

## 🛠️ Required Fixes

### 1. Update RISC-V Boot Code

The current `boot/boot_riscv64.S` needs modification for OpenSBI compatibility:

```assembly
# Add to boot/boot_riscv64.S at the beginning:

.section ".text.init"
.global _start
.align 2

_start:
    # OpenSBI hands control in S-mode
    # a0 = hartid, a1 = device tree blob address
    
    # Save hartid and dtb
    mv s0, a0  # hartid
    mv s1, a1  # device tree blob
    
    # Set up supervisor mode
    li t0, 0x100  # SPP bit for S-mode
    csrs sstatus, t0
    
    # Disable interrupts in S-mode
    csrw sie, zero
    
    # Set up stack pointer (use hartid for SMP later)
    la sp, stack_top
    li t0, 0x10000  # 64KB stack per hart
    mul t1, s0, t0
    sub sp, sp, t1
    
    # Clear BSS section
    la t0, __bss_start
    la t1, __bss_end
clear_bss:
    bge t0, t1, bss_cleared
    sd zero, 0(t0)
    addi t0, t0, 8
    j clear_bss

bss_cleared:
    # Jump to kernel main with hartid and dtb
    mv a0, s0  # hartid
    mv a1, s1  # device tree blob
    call kernel_main
    
    # Should never reach here
halt:
    wfi
    j halt
```

### 2. Update Linker Script

Modify `linker.ld` for RISC-V to set proper entry point:

```ld
/* Add RISC-V specific sections */
ENTRY(_start)

MEMORY
{
    RAM : ORIGIN = 0x80200000, LENGTH = 128M
}

SECTIONS
{
    . = 0x80200000;  /* OpenSBI loads kernel here */
    
    .text.init : {
        *(.text.init)
    } > RAM
    
    .text : {
        *(.text)
    } > RAM
    
    /* Rest of sections... */
}
```

### 3. Update Kernel Entry

Modify `kernel/kernel.c` to handle RISC-V parameters:

```c
#ifdef __riscv
void kernel_main(unsigned long hartid, void *dtb) {
    // Initialize with hartid and device tree
    riscv_init(hartid, dtb);
    
    // Continue with normal kernel initialization
    kernel_init();
}
#endif
```

## 🚀 Quick Test Command

After applying fixes:

```bash
# Build RISC-V kernel
make ARCH=riscv64 clean
make ARCH=riscv64

# Test in QEMU
qemu-system-riscv64 -M virt -kernel output/riscv64/sage-os-v1.0.1-riscv64-generic.img -nographic -m 256M
```

## 📋 Expected Result

After fixes, you should see:

```
OpenSBI v1.1
[OpenSBI boot messages...]

SAGE OS: Kernel starting...
SAGE OS: RISC-V hartid: 0
SAGE OS: Device tree at: 0x8fe00000
SAGE OS: Serial initialized
[SAGE OS ASCII art and shell]
```

## 🔧 Alternative: Use Pre-built OpenSBI

If the above doesn't work, try using a pre-built OpenSBI:

```bash
# Download OpenSBI firmware
wget https://github.com/riscv/opensbi/releases/download/v1.1/opensbi-1.1-rv-bin.tar.xz
tar -xf opensbi-1.1-rv-bin.tar.xz

# Use with QEMU
qemu-system-riscv64 -M virt \
    -bios opensbi-1.1-rv-bin/share/opensbi/lp64/generic/firmware/fw_jump.elf \
    -kernel output/riscv64/sage-os-v1.0.1-riscv64-generic.img \
    -nographic -m 256M
```

## 📊 Implementation Priority

1. **High Priority**: Fix kernel entry point for OpenSBI S-mode
2. **Medium Priority**: Add device tree parsing
3. **Low Priority**: SMP support for multiple harts

This fix will complete SAGE-OS's excellent multi-architecture support!