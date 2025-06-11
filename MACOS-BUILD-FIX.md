# 🍎 SAGE OS macOS Build Fix Guide

**For macOS developers who want to build SAGE OS without installing all cross-compilers**

## 🚨 Current Issues on macOS

You're experiencing these problems:
1. ❌ `Missing cross-compilers: riscv64-unknown-linux-gnu-gcc`
2. ❌ Assembly syntax errors with clang
3. ❌ Multiple build scripts causing confusion
4. ❌ QEMU tests failing/timing out

## ✅ Quick Fix Solution

### Step 1: Install Only Essential Tools

```bash
# Install only what you need
brew install qemu make

# Install working cross-compilers (skip RISC-V)
brew tap messense/macos-cross-toolchains
brew install aarch64-unknown-linux-gnu  # For ARM64
brew install x86_64-unknown-linux-gnu   # For x86_64 (optional)
```

### Step 2: Use the Working Build Method

**Skip the problematic scripts and use the multi-arch Makefile directly:**

```bash
# Build x86_64 (this works!)
make -f tools/build/Makefile.multi-arch ARCH=x86_64

# Build ARM64 (this works!)
make -f tools/build/Makefile.multi-arch ARCH=aarch64

# Build ARM32 (this works!)
make -f tools/build/Makefile.multi-arch ARCH=arm

# Skip RISC-V for now (don't install the toolchain)
```

### Step 3: Test with QEMU

```bash
# Test x86_64 (this should work and show SAGE OS)
qemu-system-i386 -kernel build/x86_64/kernel.elf -nographic

# Test ARM64 (builds but may hang)
qemu-system-aarch64 -M virt -cpu cortex-a72 -m 1G -kernel build/aarch64/kernel.img -nographic

# Test ARM32 (builds but may hang)
qemu-system-arm -M versatilepb -cpu arm1176 -m 256M -kernel build/arm/kernel.img -nographic -nodefaults
```

## 🔧 Fix for Assembly Issues

The `make ARCH=i386` error you're seeing is because the main Makefile tries to use `boot/boot.S` which has x86 assembly syntax that clang doesn't like.

**Solution: Use the multi-arch Makefile instead:**

```bash
# DON'T use this (causes assembly errors):
make ARCH=i386 TARGET=generic

# USE this instead:
make -f tools/build/Makefile.multi-arch ARCH=x86_64
```

## 📋 Simplified macOS Workflow

### 1. One-time Setup
```bash
# Install essential tools
brew install qemu make

# Install ARM64 cross-compiler (for Raspberry Pi)
brew tap messense/macos-cross-toolchains
brew install aarch64-unknown-linux-gnu

# Optional: Install x86_64 cross-compiler
brew install x86_64-unknown-linux-gnu
```

### 2. Daily Development
```bash
# Clean previous builds
make -f tools/build/Makefile.multi-arch clean

# Build your target architecture
make -f tools/build/Makefile.multi-arch ARCH=aarch64  # For Raspberry Pi
# OR
make -f tools/build/Makefile.multi-arch ARCH=x86_64   # For x86_64

# Test with QEMU
qemu-system-i386 -kernel build/x86_64/kernel.elf -nographic  # x86_64
qemu-system-aarch64 -M virt -kernel build/aarch64/kernel.img -nographic  # ARM64
```

### 3. Expected Results

**x86_64 (Working):**
```
SAGE OS v0.1.0 - Multi-Architecture Operating System
Copyright (c) 2025 Ashish Vasant Yesale

Initializing SAGE OS...
Memory management initialized
Shell initialized
AI subsystem initialized

sage@localhost:~$ 
```

**ARM64/ARM32 (Builds but hangs):**
- Kernel builds successfully
- QEMU loads but hangs (known issue, needs debugging)

## 🚫 What to Avoid on macOS

1. **Don't use these scripts** (they have dependency issues):
   - `./build-macos.sh`
   - `./build-all-architectures-macos.sh`
   - `./build_all.sh`

2. **Don't try to install RISC-V toolchain** (unless you really need it):
   - It's complex to install on macOS
   - The kernel hangs anyway
   - Focus on ARM64 for Raspberry Pi

3. **Don't use the main Makefile for i386**:
   - `make ARCH=i386` causes assembly syntax errors
   - Use `make -f tools/build/Makefile.multi-arch ARCH=x86_64` instead

## 🎯 Recommended macOS Development Focus

**For Raspberry Pi Development:**
```bash
# This is what you should focus on
make -f tools/build/Makefile.multi-arch ARCH=aarch64
```

**For x86_64 Testing:**
```bash
# This works perfectly for testing
make -f tools/build/Makefile.multi-arch ARCH=x86_64
qemu-system-i386 -kernel build/x86_64/kernel.elf -nographic
```

## 🔍 Debugging ARM64/ARM32 Boot Issues

The ARM kernels build successfully but hang during boot. To debug:

1. **Check serial output initialization**
2. **Verify memory layout**
3. **Test on real Raspberry Pi hardware**

This is a kernel-level issue, not a build system issue.

## 📁 Your Build Artifacts

After successful builds, you'll have:
```
build/
├── x86_64/
│   ├── kernel.elf      # Working x86_64 kernel
│   └── kernel.img      # Raw image
├── aarch64/
│   ├── kernel.elf      # ARM64 kernel (builds, hangs in QEMU)
│   └── kernel.img      # For Raspberry Pi
└── arm/
    ├── kernel.elf      # ARM32 kernel (builds, hangs in QEMU)
    └── kernel.img      # For older Raspberry Pi
```

## 🚀 Next Steps

1. **Focus on ARM64 for Raspberry Pi** - this is your main target
2. **Test on real Raspberry Pi hardware** - QEMU hanging doesn't mean the kernel is broken
3. **Use x86_64 for development/testing** - it works perfectly in QEMU
4. **Skip RISC-V for now** - avoid the toolchain complexity

## 💡 Pro Tips

- Use `make -f tools/build/Makefile.multi-arch` for all builds
- Test x86_64 in QEMU for quick feedback
- Build ARM64 for real hardware testing
- Keep it simple - don't install unnecessary toolchains