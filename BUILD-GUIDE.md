# 🚀 SAGE OS Build Guide - Simplified

**Clean, simple build instructions for SAGE OS development**

## 📁 Build Files Structure

```
SAGE-OS/
├── 🍎 macos-build.sh              # Main macOS build script (USE THIS)
├── 🐧 build.sh                    # Linux build script  
├── 🧪 test-qemu.sh               # QEMU testing script
├── 🔧 setup-macos.sh             # macOS dependency installer
├── 📋 tools/build/Makefile.multi-arch  # Core build system
└── 📄 BUILD-GUIDE.md             # This file
```

## 🍎 macOS Development (Recommended)

### Quick Start
```bash
# 1. Install dependencies (one time)
./setup-macos.sh

# 2. Build for your target
./macos-build.sh x86_64        # For testing in QEMU
./macos-build.sh aarch64       # For Raspberry Pi 4/5
./macos-build.sh arm           # For Raspberry Pi 2/3
./macos-build.sh all           # Build all architectures

# 3. Test (x86_64 works perfectly)
qemu-system-i386 -kernel build/x86_64/kernel.elf -nographic
```

### Build Options
```bash
./macos-build.sh x86_64 --build-only    # Build without testing
./macos-build.sh aarch64 --test-only     # Test existing build
./macos-build.sh all --clean             # Clean and build all
./macos-build.sh --help                  # Show all options
```

## 🐧 Linux Development

```bash
# Use the multi-arch Makefile directly
make -f tools/build/Makefile.multi-arch ARCH=x86_64
make -f tools/build/Makefile.multi-arch ARCH=aarch64
make -f tools/build/Makefile.multi-arch ARCH=arm
make -f tools/build/Makefile.multi-arch ARCH=riscv64
```

## 🎯 What Works

| Architecture | Build | QEMU Test | Real Hardware | Notes |
|-------------|-------|-----------|---------------|-------|
| **x86_64** | ✅ | ✅ | ✅ | Perfect - shows SAGE OS shell |
| **aarch64** | ✅ | ⚠️ | 🤔 | Builds fine, hangs in QEMU, test on Pi |
| **arm** | ✅ | ⚠️ | 🤔 | Builds fine, hangs in QEMU, test on Pi |
| **riscv64** | ✅ | ⚠️ | ❓ | Builds, OpenSBI loads, kernel hangs |

## 📦 Build Outputs

After building, you'll find:
```
build/
├── x86_64/
│   ├── kernel.elf      # For QEMU testing
│   └── kernel.img      # Raw kernel image
├── aarch64/
│   ├── kernel.elf      # ELF format
│   └── kernel.img      # For Raspberry Pi SD card
└── arm/
    ├── kernel.elf      # ELF format  
    └── kernel.img      # For older Raspberry Pi
```

## 🧪 Testing

### x86_64 (Works Perfectly)
```bash
qemu-system-i386 -kernel build/x86_64/kernel.elf -nographic

# Expected output:
# SAGE OS v0.1.0 - Multi-Architecture Operating System
# Copyright (c) 2025 Ashish Vasant Yesale
# 
# Initializing SAGE OS...
# Memory management initialized
# Shell initialized
# AI subsystem initialized
# 
# sage@localhost:~$ 
```

### ARM64/ARM32 (Builds but hangs in QEMU)
```bash
# ARM64
qemu-system-aarch64 -M virt -kernel build/aarch64/kernel.img -nographic

# ARM32  
qemu-system-arm -M versatilepb -kernel build/arm/kernel.img -nographic
```

**Note:** ARM kernels hang in QEMU but may work on real hardware.

## 🔧 Dependencies

### macOS
```bash
# Essential tools
brew install qemu make

# Cross-compilers (optional, for cross-compilation)
brew tap messense/macos-cross-toolchains
brew install aarch64-unknown-linux-gnu  # For ARM64
```

### Linux
```bash
# Ubuntu/Debian
sudo apt install build-essential qemu-system gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf

# Arch Linux
sudo pacman -S base-devel qemu-system-x86 qemu-system-arm aarch64-linux-gnu-gcc arm-linux-gnueabihf-gcc
```

## 🚫 What NOT to Use

**Avoid these files** (they're old/broken):
- ❌ `make ARCH=i386` (assembly syntax errors on macOS)
- ❌ Old build scripts (removed for clarity)
- ❌ Complex dependency scripts (use simple setup)

## 🎯 Recommended Workflow

### For Raspberry Pi Development
```bash
# 1. Build ARM64 kernel
./macos-build.sh aarch64 --build-only

# 2. Copy to SD card
cp build/aarch64/kernel.img /path/to/sd/card/

# 3. Test on real Raspberry Pi
```

### For Quick Testing/Development
```bash
# 1. Build x86_64 (works perfectly)
./macos-build.sh x86_64

# 2. Test immediately
qemu-system-i386 -kernel build/x86_64/kernel.elf -nographic

# 3. Develop and iterate
```

## 🔍 Troubleshooting

### "Cross-compiler not found"
```bash
# Skip RISC-V if you don't need it
./macos-build.sh x86_64 aarch64 arm  # Build only these

# Or install specific toolchain
brew install aarch64-unknown-linux-gnu
```

### "Assembly syntax error"
```bash
# Use the new build script, not old Makefiles
./macos-build.sh x86_64  # ✅ Works
# NOT: make ARCH=i386    # ❌ Fails on macOS
```

### "QEMU hangs"
- **x86_64**: Should work perfectly, check QEMU installation
- **ARM64/ARM32**: Known issue, try real hardware
- **RISC-V**: Known issue, kernel debugging needed

## 📚 Core Components

SAGE OS includes:
- ✅ **Boot System**: Multi-architecture boot code
- ✅ **Kernel**: Memory management, drivers, shell
- ✅ **Drivers**: UART, VGA, Serial, GPIO, I2C, SPI
- ✅ **Shell**: Interactive command interface
- ✅ **Build System**: Cross-platform compilation

## 🚀 Next Steps

1. **Start with x86_64** - it works perfectly for development
2. **Build ARM64** - for Raspberry Pi deployment  
3. **Test on real hardware** - QEMU limitations don't reflect real performance
4. **Focus on core OS** - ignore AI features for now (as requested)

## 💡 Pro Tips

- Use `./macos-build.sh x86_64` for quick testing
- Use `./macos-build.sh aarch64` for Raspberry Pi
- Keep builds clean with `--clean` option
- Test x86_64 in QEMU, ARM on real hardware