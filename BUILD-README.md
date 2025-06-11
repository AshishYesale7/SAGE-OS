# 🚀 SAGE OS - Simple Build System

**One build system to rule them all!** No more confusion with multiple build scripts.

## 🎯 **Quick Start**

### **Option 1: Simple Script (Recommended)**
```bash
# Build x86_64 (fully working)
./build.sh build

# Build and test in QEMU
./build.sh test

# Build all architectures
./build.sh all

# Clean everything
./build.sh clean

# Setup macOS dependencies
./build.sh setup-macos
```

### **Option 2: Direct Makefile**
```bash
# Build specific architecture
make -f Makefile.simple ARCH=x86_64
make -f Makefile.simple ARCH=aarch64
make -f Makefile.simple ARCH=arm

# Test in QEMU
make -f Makefile.simple test ARCH=x86_64

# Build all
make -f Makefile.simple all-arch

# Clean
make -f Makefile.simple clean
```

## 📁 **File Organization**

### **Main Build Files** (Use These!)
- `build.sh` - **Main build script** (colorful, user-friendly)
- `Makefile.simple` - **Main Makefile** (clean, organized)

### **Specialized Tools** (Keep These!)
- `scripts/build/build-graphics.sh` - Graphics mode builds
- `scripts/build/docker-builder.sh` - Docker builds  
- `tools/testing/benchmark-builds.sh` - Performance testing
- `sage-sdk/tools/azr-model-builder` - AI model packaging

### **Legacy Files** (Ignore These!)
- `tools/build/Makefile.multi-arch` - Old complex Makefile
- `tools/build/Makefile.macos` - Old macOS Makefile

### **Build Outputs**
- `build/` - Architecture-specific builds
- `build-output/` - Versioned releases (currently empty)

## ✅ **What Works**

| Architecture | Build Status | QEMU Test | Real Hardware |
|-------------|-------------|-----------|---------------|
| **x86_64**  | ✅ Perfect   | ✅ Works  | ✅ Should work |
| **aarch64** | ✅ Builds    | ❌ Hangs  | ❓ Unknown     |
| **arm**     | ✅ Builds    | ❌ Hangs  | ❓ Unknown     |
| **riscv64** | ⚠️ Needs toolchain | ❌ Hangs | ❓ Unknown |

## 🎮 **Test the Working Kernel**

```bash
# Build and test x86_64 (fully functional!)
./build.sh test

# Or manually:
make -f Makefile.simple ARCH=x86_64
qemu-system-i386 -kernel build/x86_64/kernel.elf -nographic
```

**You'll get a fully interactive shell with:**
- File operations (ls, mkdir, touch, cat, rm, cp, mv)
- Text editors (nano, vi)
- System commands (help, version, uptime, whoami)
- Beautiful ASCII art boot screen!

## 🍎 **macOS Setup**

```bash
# Install all dependencies
./build.sh setup-macos

# Or manually:
brew install qemu x86_64-elf-gcc aarch64-elf-gcc arm-none-eabi-gcc
```

## 🧹 **Clean Slate**

If you want to start fresh:
```bash
./build.sh clean
```

## 🆘 **Help**

```bash
./build.sh help
make -f Makefile.simple help
```

---

**🎉 Your SAGE OS is already impressive with a fully working x86_64 kernel!**