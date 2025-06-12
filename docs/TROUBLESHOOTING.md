# 🔧 SAGE OS Troubleshooting Guide

This guide addresses common issues when building and running SAGE OS, especially on macOS M1 systems.

## 🍎 macOS M1 Specific Issues

### Problem 1: Assembly Syntax Errors with Clang

**Symptoms:**
```
boot/boot.S:11:22: error: unexpected token in '.section' directive
.section ".multiboot"
```

**Root Cause:**
- macOS uses Clang by default, which has different assembly syntax than GCC
- Clang expects Mach-O section names, not ELF section names
- AT&T syntax differences between Clang and GCC

**Solutions:**

#### Option 1: Use macOS-Compatible Makefile
```bash
# Use the macOS-specific Makefile
make -f Makefile.macos ARCH=i386 TARGET=generic

# Or copy it as the main Makefile
cp Makefile.macos Makefile
make ARCH=i386 TARGET=generic
```

#### Option 2: Install Cross-Compiler
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install cross-compilers
brew install x86_64-elf-gcc i386-elf-gcc

# Then build normally
make ARCH=i386 TARGET=generic
```

#### Option 3: Use Clang-Compatible Boot File
```bash
# The boot_clang.S file is designed for Clang
# Modify Makefile to use it:
sed -i '' 's/boot\/boot.S/boot\/boot_clang.S/' Makefile
make ARCH=i386 TARGET=generic
```

### Problem 2: QEMU Not Opening GUI Window

**Symptoms:**
- QEMU starts but no window appears
- Console output shows boot messages but no graphics
- System appears to hang after boot

**Root Cause:**
- macOS M1 doesn't support HVF acceleration for x86 guests
- Default QEMU display might not work on macOS
- Missing graphics drivers or wrong display backend

**Solutions:**

#### Option 1: Use TCG Acceleration (Recommended for M1)
```bash
# Force TCG acceleration instead of HVF
qemu-system-i386 -kernel build/i386/kernel.elf -m 128M -accel tcg -nographic

# For graphics mode with Cocoa display (macOS native)
qemu-system-i386 -kernel build/i386/kernel.elf -m 256M -vga std -display cocoa -accel tcg
```

#### Option 2: Use Different Display Backends
```bash
# Try different display options
qemu-system-i386 -kernel build/i386/kernel.elf -m 256M -vga std -display gtk
qemu-system-i386 -kernel build/i386/kernel.elf -m 256M -vga std -display sdl
qemu-system-i386 -kernel build/i386/kernel.elf -m 256M -vga std -display vnc=:1
```

#### Option 3: Use UTM (Recommended Alternative)
```bash
# Install UTM (QEMU frontend for macOS)
brew install --cask utm

# Create new VM in UTM:
# 1. Architecture: x86_64
# 2. System: Other
# 3. Boot: Direct kernel boot
# 4. Kernel: build/i386/kernel.elf
# 5. Memory: 256MB
# 6. Display: VGA
```

### Problem 3: Build Dependencies Missing

**Symptoms:**
```
make: gcc: No such file or directory
make: qemu-system-i386: command not found
```

**Solution:**
```bash
# Install all dependencies at once
make -f Makefile.macos install-deps-macos

# Or manually:
brew install qemu gcc make
brew install x86_64-elf-gcc i386-elf-gcc  # Cross-compilers
```

## 🐧 Linux Issues

### Problem 1: 32-bit Libraries Missing

**Symptoms:**
```
fatal error: bits/libc-header-start.h: No such file or directory
```

**Solution:**
```bash
# Ubuntu/Debian
sudo apt install gcc-multilib libc6-dev-i386

# Fedora/RHEL
sudo dnf install glibc-devel.i686 libgcc.i686

# Arch Linux
sudo pacman -S lib32-glibc lib32-gcc-libs
```

### Problem 2: Cross-Compiler Not Found

**Solution:**
```bash
# Ubuntu/Debian
sudo apt install gcc-i686-linux-gnu gcc-x86-64-linux-gnu

# Build from source (if packages not available)
wget https://github.com/lordmilko/i686-elf-tools/releases/download/7.1.0/i686-elf-tools-linux.zip
unzip i686-elf-tools-linux.zip
export PATH=$PATH:$(pwd)/i686-elf-tools-linux/bin
```

## 🪟 Windows Issues

### Problem 1: MSYS2/MinGW Build Errors

**Solution:**
```bash
# Install MSYS2
# Download from https://www.msys2.org/

# In MSYS2 terminal:
pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-qemu
pacman -S make git

# Use Windows-specific commands
make ARCH=i386 TARGET=generic CC=gcc
```

## 🚀 QEMU Issues

### Problem 1: Kernel Doesn't Boot

**Symptoms:**
- QEMU starts but shows only BIOS messages
- "Booting from ROM..." but kernel doesn't load
- System hangs at SeaBIOS

**Diagnosis:**
```bash
# Check if kernel file exists and is valid
ls -la build/i386/kernel.elf
file build/i386/kernel.elf

# Should show: ELF 32-bit LSB executable, Intel 80386
```

**Solutions:**

#### Option 1: Verify Kernel Format
```bash
# Check if kernel is properly linked
objdump -h build/i386/kernel.elf | grep -E "(multiboot|text)"

# Should show .multiboot and .text sections
```

#### Option 2: Use Correct QEMU Command
```bash
# Ensure you're using the right architecture
qemu-system-i386 -kernel build/i386/kernel.elf -m 128M -nographic

# NOT qemu-system-x86_64 for i386 kernels
```

#### Option 3: Check Multiboot Header
```bash
# Verify multiboot header is present
hexdump -C build/i386/kernel.elf | head -20 | grep "02 b0 ad 1b"

# Should find the multiboot magic number
```

### Problem 2: No Keyboard/Mouse Input

**Solution:**
```bash
# Add USB input devices
qemu-system-i386 -kernel build/i386/kernel.elf -m 256M \
  -vga std -display gtk \
  -device usb-kbd -device usb-mouse

# Or use PS/2 devices (more compatible)
qemu-system-i386 -kernel build/i386/kernel.elf -m 256M \
  -vga std -display gtk
```

### Problem 3: Graphics Mode Not Working

**Solution:**
```bash
# Try different VGA modes
qemu-system-i386 -kernel build/i386/kernel.elf -m 256M -vga std
qemu-system-i386 -kernel build/i386/kernel.elf -m 256M -vga cirrus
qemu-system-i386 -kernel build/i386/kernel.elf -m 256M -vga vmware

# Or use framebuffer
qemu-system-i386 -kernel build/i386/kernel.elf -m 256M -device VGA
```

## 🔍 Debugging Tools

### GDB Debugging
```bash
# Start QEMU with GDB server
qemu-system-i386 -kernel build/i386/kernel.elf -m 128M -s -S -nographic

# In another terminal
gdb build/i386/kernel.elf
(gdb) target remote localhost:1234
(gdb) continue
```

### QEMU Monitor
```bash
# Access QEMU monitor
# Press Ctrl+Alt+2 in QEMU window
# Or use -monitor stdio for console access

# Useful monitor commands:
info registers    # Show CPU registers
info mem         # Show memory mapping
info pic         # Show interrupt controller
```

### Kernel Debugging
```c
// Add debug prints to kernel
void debug_print(const char* msg) {
    // Output to serial port (QEMU console)
    for (int i = 0; msg[i]; i++) {
        outb(0x3F8, msg[i]);  // COM1 port
    }
}
```

## 📋 Quick Reference

### Working Commands for macOS M1

```bash
# Build
make -f Makefile.macos ARCH=i386 TARGET=generic

# Test (console)
qemu-system-i386 -kernel build/i386/kernel.elf -m 128M -nographic -accel tcg

# Test (graphics)
qemu-system-i386 -kernel build/i386/kernel.elf -m 256M -vga std -display cocoa -accel tcg

# Debug
qemu-system-i386 -kernel build/i386/kernel.elf -m 128M -nographic -accel tcg -s -S
```

### Working Commands for Linux

```bash
# Build
make ARCH=i386 TARGET=generic

# Test
qemu-system-i386 -kernel build/i386/kernel.elf -m 128M -nographic

# Graphics
qemu-system-i386 -kernel build/i386/kernel.elf -m 256M -vga std -display gtk
```

### Working Commands for Windows (MSYS2)

```bash
# Build
make ARCH=i386 TARGET=generic

# Test
qemu-system-i386.exe -kernel build/i386/kernel.elf -m 128M -nographic
```

## 🆘 Getting Help

If you're still having issues:

1. **Check Dependencies**: Run `make check-deps` to verify your setup
2. **Clean Build**: Run `make clean && make` to ensure a fresh build
3. **Verbose Output**: Use `make VERBOSE=1` to see detailed build commands
4. **Check Logs**: Look at QEMU output and kernel messages
5. **Ask for Help**: Open an issue with your system details and error messages

### System Information to Include

```bash
# Gather system information
uname -a                    # System info
gcc --version              # Compiler version
qemu-system-i386 --version # QEMU version
make --version             # Make version

# On macOS
system_profiler SPSoftwareDataType | grep "System Version"
brew --version
```

---

**Remember**: SAGE OS is designed to work on multiple platforms. If one approach doesn't work, try the alternatives provided above!