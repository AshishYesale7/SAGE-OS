# 🍎 SAGE OS Graphics Mode - macOS Guide

**Complete guide for running SAGE OS Graphics Mode on macOS (Intel & Apple Silicon)**

---

## 🎯 Quick Start

### **1. Automated Setup (Recommended)**
```bash
# Run the automated setup script
./setup-macos-graphics.sh

# Test graphics mode
./build.sh test-graphics
```

### **2. Manual Setup**
```bash
# Install dependencies
brew install x86_64-unknown-linux-gnu qemu

# Build graphics kernel
./build-graphics.sh i386 build

# Run graphics mode
qemu-system-i386 -kernel build/i386-graphics/kernel.elf -m 128M
```

---

## 🔧 Prerequisites

### **Required Tools**
- **Homebrew**: Package manager for macOS
- **Cross-compiler**: `x86_64-unknown-linux-gnu` toolchain
- **QEMU**: System emulator for running x86 code

### **Installation Commands**
```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install cross-compilation toolchain
brew install x86_64-unknown-linux-gnu

# Install QEMU emulator
brew install qemu
```

---

## 🚨 Common Issues & Solutions

### **Issue 1: Cross-compiler not found**
```
❌ Cross-compiler not found: i386-unknown-linux-gnu-gcc
```

**Solution:**
```bash
# Install the correct toolchain
brew install x86_64-unknown-linux-gnu

# Add to PATH
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/usr/local/bin:$PATH"

# Verify installation
which x86_64-unknown-linux-gnu-gcc
```

### **Issue 2: Assembly syntax errors**
```
error: unexpected token in '.section' directive
error: invalid instruction
```

**Cause:** Apple Clang trying to compile x86 assembly for ARM

**Solution:** The build script now automatically detects and uses the correct cross-compiler

### **Issue 3: Kernel file not found**
```
qemu: could not open kernel file 'build/i386-graphics/kernel.elf'
```

**Solution:**
```bash
# Build the graphics kernel first
./build-graphics.sh i386 build

# Verify the kernel exists
ls -la build/i386-graphics/kernel.elf

# Then run QEMU
qemu-system-i386 -kernel build/i386-graphics/kernel.elf -m 128M
```

### **Issue 4: QEMU not found**
```
qemu-system-i386: command not found
```

**Solution:**
```bash
# Install QEMU
brew install qemu

# Verify installation
which qemu-system-i386
```

---

## 🎮 Running Graphics Mode

### **Method 1: Build Script (Recommended)**
```bash
# Test graphics mode (10-second demo)
./build.sh test-graphics

# Interactive graphics mode with VNC
./build.sh graphics
```

### **Method 2: Direct QEMU**
```bash
# Basic graphics mode
qemu-system-i386 -kernel build/i386-graphics/kernel.elf -m 128M

# With VNC for remote access
qemu-system-i386 -kernel build/i386-graphics/kernel.elf -m 128M -vnc :0

# With performance optimization (Apple Silicon)
qemu-system-i386 -kernel build/i386-graphics/kernel.elf -m 128M -accel hvf
```

### **Method 3: Build and Test**
```bash
# Build graphics kernel
./build-graphics.sh i386 build

# Test the kernel
./build-graphics.sh i386 test
```

---

## 🖥️ Apple Silicon (M1/M2/M3) Specific

### **Performance Notes**
- QEMU emulates x86 on ARM processor
- Performance is slower than native execution
- Graphics mode works perfectly despite emulation
- Use `-accel hvf` for better performance

### **Optimized Commands**
```bash
# Best performance on Apple Silicon
qemu-system-i386 -kernel build/i386-graphics/kernel.elf -m 128M -accel hvf

# With VNC and optimization
qemu-system-i386 -kernel build/i386-graphics/kernel.elf -m 128M -accel hvf -vnc :0
```

### **Memory Recommendations**
- **Minimum**: 128MB (`-m 128M`)
- **Recommended**: 256MB (`-m 256M`)
- **Maximum tested**: 512MB (`-m 512M`)

---

## 🎨 Graphics Mode Features

### **Visual Interface**
- **80x25 VGA text mode** with 16 colors
- **Beautiful ASCII art** SAGE OS logo
- **Interactive shell** with real-time input
- **Professional layout** with color coding

### **Available Commands**
```bash
help     # Show all commands
version  # System information
clear    # Clear screen
colors   # Test all 16 VGA colors
demo     # Run demo sequence
reboot   # Restart system
exit     # Shutdown
```

### **Keyboard Support**
- **Real-time input processing**
- **Standard QEMU keyboard mapping**
- **Arrow keys, Enter, Backspace**
- **All printable characters**

---

## 🔍 Troubleshooting Steps

### **Step 1: Verify Dependencies**
```bash
# Check Homebrew
brew --version

# Check cross-compiler
which x86_64-unknown-linux-gnu-gcc
x86_64-unknown-linux-gnu-gcc --version

# Check QEMU
which qemu-system-i386
qemu-system-i386 --version
```

### **Step 2: Check PATH**
```bash
# Show current PATH
echo $PATH

# Add Homebrew paths
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/usr/local/bin:$PATH"

# Make permanent (add to ~/.zshrc or ~/.bash_profile)
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
```

### **Step 3: Clean Build**
```bash
# Clean previous builds
./build-graphics.sh i386 clean

# Fresh build
./build-graphics.sh i386 build

# Verify kernel
ls -la build/i386-graphics/kernel.elf
```

### **Step 4: Test Build System**
```bash
# Test the build system
./build.sh test-graphics

# If successful, you should see:
# ✅ Graphics kernel built successfully!
# Beautiful SAGE OS ASCII art
# Interactive shell prompt
```

---

## 📊 Performance Optimization

### **QEMU Acceleration**
```bash
# Apple Silicon Macs (M1/M2/M3)
qemu-system-i386 -kernel build/i386-graphics/kernel.elf -m 256M -accel hvf

# Intel Macs
qemu-system-i386 -kernel build/i386-graphics/kernel.elf -m 256M -accel kvm
```

### **Memory Tuning**
```bash
# Low memory (minimal)
qemu-system-i386 -kernel build/i386-graphics/kernel.elf -m 64M

# Standard (recommended)
qemu-system-i386 -kernel build/i386-graphics/kernel.elf -m 128M

# High memory (for development)
qemu-system-i386 -kernel build/i386-graphics/kernel.elf -m 512M
```

### **Display Options**
```bash
# Full screen graphics
qemu-system-i386 -kernel build/i386-graphics/kernel.elf -m 128M -full-screen

# VNC for remote access
qemu-system-i386 -kernel build/i386-graphics/kernel.elf -m 128M -vnc :0

# No graphics (text only)
qemu-system-i386 -kernel build/i386-graphics/kernel.elf -m 128M -nographic
```

---

## 🎯 Expected Output

### **Successful Boot Sequence**
```
SeaBIOS (version 1.16.2-debian-1)
iPXE (http://ipxe.org) 00:03.0 CA00 PCI2.10 PnP PMM
Booting from ROM..

SAGE OS: Kernel starting (Graphics Mode)...
SAGE OS: VGA and Serial initialized

  ███████╗ █████╗  ██████╗ ███████╗      ██████╗ ███████╗
  ██╔════╝██╔══██╗██╔════╝ ██╔════╝     ██╔═══██╗██╔════╝
  ███████╗███████║██║  ███╗█████╗       ██║   ██║███████╗
  ╚════██║██╔══██║██║   ██║██╔══╝       ██║   ██║╚════██║
  ███████║██║  ██║╚██████╔╝███████╗     ╚██████╔╝███████║
  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝      ╚═════╝ ╚══════╝

        Self-Aware General Environment Operating System
                    Version 1.0.1
                 Designed by Ashish Yesale

================================================================
  Welcome to SAGE OS - The Future of Self-Evolving Systems
================================================================

Initializing system components...
VGA Graphics Mode: ENABLED
Keyboard Input: ENABLED
System ready!

=== SAGE OS Interactive Mode ===
Type commands and press Enter. Type 'help' for available commands.
This interactive mode works with keyboard input in QEMU graphics mode.

sage@localhost:~$ 
```

---

## 🆘 Getting Help

### **If You're Still Having Issues:**

1. **Run the automated setup:**
   ```bash
   ./setup-macos-graphics.sh
   ```

2. **Check the build logs:**
   ```bash
   ./build-graphics.sh i386 build 2>&1 | tee build.log
   ```

3. **Verify your system:**
   ```bash
   uname -a
   brew --version
   which x86_64-unknown-linux-gnu-gcc
   which qemu-system-i386
   ```

4. **Try a clean build:**
   ```bash
   ./build-graphics.sh i386 clean
   ./build-graphics.sh i386 build
   ```

### **Common Success Indicators:**
- ✅ Cross-compiler found and working
- ✅ Graphics kernel builds (20KB)
- ✅ QEMU starts without errors
- ✅ SAGE OS logo displays
- ✅ Interactive shell responds

---

## 🎉 Success!

**Once everything is working, you'll have:**

- **Beautiful graphics mode** with SAGE OS branding
- **Interactive shell** with real-time keyboard input
- **Professional interface** perfect for demonstrations
- **Cross-platform compatibility** on your Mac

**🚀 Enjoy your SAGE OS graphics experience on macOS!**

---

**Author**: Ashish Vasant Yesale  
**Platform**: macOS (Intel & Apple Silicon)  
**Status**: Production Ready  
**Last Updated**: June 2024