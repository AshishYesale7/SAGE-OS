# Boot Issues Troubleshooting Guide

This comprehensive guide helps diagnose and fix boot-related issues in SAGE OS across different architectures.

## Table of Contents

- [Common Boot Issues](#common-boot-issues)
- [Architecture-Specific Issues](#architecture-specific-issues)
- [Diagnostic Tools](#diagnostic-tools)
- [Step-by-Step Troubleshooting](#step-by-step-troubleshooting)
- [Recovery Procedures](#recovery-procedures)

## Common Boot Issues

### 1. System Won't Start

**Symptoms:**
- No output on screen
- System appears dead
- Power LED may or may not be on

**Possible Causes:**
- Corrupted bootloader
- Hardware failure
- Power supply issues
- Memory problems

**Solutions:**

```bash
# Check power connections
# Verify hardware compatibility
# Test with minimal configuration

# For QEMU testing:
qemu-system-x86_64 -m 512M -cdrom sage-os.iso -boot d -serial stdio
```

### 2. Bootloader Not Found

**Symptoms:**
- "No bootable device" error
- "Operating system not found"
- System boots to BIOS/UEFI

**Solutions:**

```bash
# Rebuild bootloader
make clean
make bootloader ARCH=x86_64

# Verify boot sector
hexdump -C build/boot/stage1.bin | head -10

# Check boot signature (should end with 55 AA)
tail -c 2 build/boot/stage1.bin | hexdump -C
```

### 3. Kernel Panic on Boot

**Symptoms:**
- System starts but crashes during kernel initialization
- Error messages about memory, interrupts, or drivers

**Solutions:**

```bash
# Enable debug output
make ARCH=x86_64 DEBUG=1

# Check kernel size and memory layout
objdump -h build/kernel/kernel.elf

# Verify memory map
readelf -l build/kernel/kernel.elf
```

### 4. No Display Output

**Symptoms:**
- System appears to boot but no display
- Cursor may be visible but no text

**Solutions:**

```bash
# Test with serial output
qemu-system-x86_64 -m 512M -kernel build/kernel/kernel.bin \
  -serial stdio -nographic

# Check VGA initialization
# Verify display driver loading
```

## Architecture-Specific Issues

### x86_64 Issues

#### Real Mode to Protected Mode Transition

```assembly
; Check GDT setup
lgdt [gdt_descriptor]

; Verify A20 line is enabled
call enable_a20

; Check protected mode entry
mov eax, cr0
or eax, 1
mov cr0, eax
```

#### Long Mode Setup

```assembly
; Verify CPU supports long mode
mov eax, 0x80000001
cpuid
test edx, (1 << 29)
jz no_long_mode

; Check page tables
mov eax, page_table_l4
mov cr3, eax
```

### ARM64/AArch64 Issues

#### Device Tree Loading

```bash
# Verify device tree blob
dtc -I dtb -O dts -o output.dts input.dtb

# Check memory layout
grep -A 10 "memory@" output.dts
```

#### Exception Level Transitions

```assembly
; Check current exception level
mrs x0, CurrentEL
lsr x0, x0, #2

; Verify EL1 setup
msr SCTLR_EL1, x0
```

### RISC-V Issues

#### Supervisor Mode Setup

```assembly
; Check privilege level
csrr t0, mstatus
li t1, MSTATUS_MPP
and t0, t0, t1
```

#### Memory Management Unit

```bash
# Verify page table setup
riscv64-linux-gnu-objdump -d build/kernel/kernel.elf | grep -A 10 "setup_mmu"
```

## Diagnostic Tools

### 1. QEMU Debugging

```bash
# Start with GDB support
qemu-system-x86_64 -s -S -m 512M -kernel build/kernel/kernel.bin

# In another terminal
gdb build/kernel/kernel.elf
(gdb) target remote :1234
(gdb) break _start
(gdb) continue
```

### 2. Serial Console Debugging

```bash
# Enable serial output in kernel
echo "CONFIG_SERIAL_DEBUG=y" >> config/kernel.config

# Monitor serial output
qemu-system-x86_64 -serial stdio -kernel build/kernel/kernel.bin
```

### 3. Memory Dump Analysis

```bash
# Dump memory at specific address
(gdb) x/32x 0x100000

# Check stack trace
(gdb) bt

# Examine registers
(gdb) info registers
```

### 4. Boot Sector Analysis

```bash
# Disassemble boot sector
ndisasm -b 16 build/boot/stage1.bin

# Check for boot signature
xxd build/boot/stage1.bin | tail -1
```

## Step-by-Step Troubleshooting

### Phase 1: Pre-Boot Verification

1. **Check Build Process**
   ```bash
   make clean
   make ARCH=x86_64 VERBOSE=1
   ```

2. **Verify File Integrity**
   ```bash
   file build/boot/stage1.bin
   file build/kernel/kernel.bin
   ls -la build/
   ```

3. **Test in Emulator**
   ```bash
   qemu-system-x86_64 -m 512M -kernel build/kernel/kernel.bin -serial stdio
   ```

### Phase 2: Boot Sector Debugging

1. **Check Boot Sector Size**
   ```bash
   stat -c%s build/boot/stage1.bin  # Should be 512 bytes
   ```

2. **Verify Boot Signature**
   ```bash
   tail -c 2 build/boot/stage1.bin | hexdump -C  # Should show 55 aa
   ```

3. **Test Boot Sector Loading**
   ```bash
   qemu-system-x86_64 -drive format=raw,file=build/boot/stage1.bin
   ```

### Phase 3: Kernel Loading Issues

1. **Check Kernel Format**
   ```bash
   readelf -h build/kernel/kernel.elf
   objdump -f build/kernel/kernel.bin
   ```

2. **Verify Entry Point**
   ```bash
   readelf -h build/kernel/kernel.elf | grep "Entry point"
   ```

3. **Check Memory Layout**
   ```bash
   readelf -l build/kernel/kernel.elf
   ```

### Phase 4: Runtime Debugging

1. **Enable Debug Output**
   ```c
   // In kernel source
   #define DEBUG 1
   #define SERIAL_DEBUG 1
   ```

2. **Add Debug Prints**
   ```c
   void debug_print(const char* msg) {
       // Serial output implementation
       outb(0x3F8, *msg);
   }
   ```

3. **Check Interrupt Setup**
   ```c
   // Verify IDT is loaded
   asm volatile("sidt %0" : "=m"(idt_descriptor));
   ```

## Recovery Procedures

### 1. Bootloader Recovery

```bash
# Rebuild bootloader from scratch
rm -rf build/boot/
make bootloader ARCH=x86_64

# Create recovery boot disk
dd if=build/boot/stage1.bin of=/dev/sdX bs=512 count=1
```

### 2. Kernel Recovery

```bash
# Build minimal kernel
make kernel ARCH=x86_64 MINIMAL=1

# Test with known good configuration
cp config/kernel.config.minimal config/kernel.config
make clean && make
```

### 3. Emergency Boot

```bash
# Create emergency boot image
make emergency-boot ARCH=x86_64

# Boot from network (if supported)
qemu-system-x86_64 -netdev user,id=net0,tftp=build/ -device e1000,netdev=net0
```

## Common Error Messages

### "Kernel panic - not syncing"

**Cause:** Critical kernel error during initialization

**Solutions:**
1. Check memory layout conflicts
2. Verify interrupt handler setup
3. Review driver initialization order

```bash
# Debug with minimal drivers
make ARCH=x86_64 DRIVERS=minimal
```

### "Invalid opcode"

**Cause:** CPU instruction not supported or corrupted code

**Solutions:**
1. Check target architecture matches CPU
2. Verify compiler flags
3. Check for memory corruption

```bash
# Verify instruction set
objdump -d build/kernel/kernel.elf | grep -A 5 -B 5 "invalid"
```

### "General Protection Fault"

**Cause:** Privilege violation or invalid memory access

**Solutions:**
1. Check segment descriptor setup
2. Verify memory permissions
3. Review pointer arithmetic

```bash
# Check GDT setup
objdump -s -j .gdt build/kernel/kernel.elf
```

### "Page Fault"

**Cause:** Invalid memory access or page table issues

**Solutions:**
1. Verify page table setup
2. Check memory mapping
3. Review virtual address calculations

```bash
# Analyze page tables
gdb build/kernel/kernel.elf
(gdb) x/32x page_directory
```

## Prevention Best Practices

### 1. Build Verification

```bash
# Always verify build artifacts
make verify ARCH=x86_64

# Check for common issues
scripts/check-build.sh
```

### 2. Testing Strategy

```bash
# Test on multiple architectures
for arch in x86_64 aarch64 riscv64; do
    make clean
    make ARCH=$arch
    make test ARCH=$arch
done
```

### 3. Continuous Integration

```yaml
# .github/workflows/boot-test.yml
- name: Test Boot Process
  run: |
    make ARCH=x86_64
    timeout 30 qemu-system-x86_64 -m 512M -kernel build/kernel/kernel.bin -nographic
```

### 4. Documentation

- Keep boot logs for analysis
- Document configuration changes
- Maintain recovery procedures
- Update troubleshooting guides

## Advanced Debugging Techniques

### 1. Hardware Debugging

```bash
# Use hardware debugger (if available)
openocd -f interface/jlink.cfg -f target/cortex_a.cfg

# JTAG debugging
arm-none-eabi-gdb build/kernel/kernel.elf
(gdb) target remote localhost:3333
```

### 2. Firmware Analysis

```bash
# Dump firmware
flashrom -p internal -r firmware.bin

# Analyze UEFI/BIOS
UEFITool firmware.bin
```

### 3. Network Boot Debugging

```bash
# Setup PXE boot server
dnsmasq --enable-tftp --tftp-root=/tftpboot

# Network boot with debugging
qemu-system-x86_64 -netdev user,id=net0,tftp=build/,bootfile=kernel.bin
```

## Getting Help

If you're still experiencing issues:

1. **Check the FAQ**: [docs/FAQ.md](../FAQ.md)
2. **Search Issues**: [GitHub Issues](https://github.com/AshishYesale7/SAGE-OS/issues)
3. **Join Community**: [Discord/Slack channels]
4. **Submit Bug Report**: Include logs, configuration, and steps to reproduce

## Related Documentation

- [Build System Guide](../build/README.md)
- [Architecture Guide](../architecture/README.md)
- [Kernel Development](../kernel/README.md)
- [Testing Guide](../testing/README.md)