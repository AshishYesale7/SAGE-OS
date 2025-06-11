# 🍎 SAGE OS - macOS Build Guide

This guide helps you build and test SAGE OS on macOS with proper cross-compilation support.

## 🚀 Quick Start

### 1. Prerequisites

- **macOS 10.15+** (Catalina or later)
- **Homebrew** package manager
- **Xcode Command Line Tools**

Install Xcode Command Line Tools:
```bash
xcode-select --install
```

Install Homebrew (if not already installed):
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Setup Dependencies

Run the automated setup script:
```bash
./setup-macos.sh
```

This will install:
- QEMU (for testing)
- Cross-compilation toolchains for all architectures
- GNU tools for better compatibility
- Development tools (make, cmake, git)

### 3. Build SAGE OS

#### Option A: Interactive Build (Recommended)
```bash
./build-macos.sh
```

#### Option B: Command Line Build
```bash
# Build all architectures
./build-macos.sh

# Build specific architecture
./build-macos.sh --arch x86_64

# Build only (no testing)
./build-macos.sh --build-only

# Test only (no building)
./build-macos.sh --test-only
```

#### Option C: Direct Make Commands
```bash
# Build for ARM64 (Raspberry Pi)
make -f tools/build/Makefile.multi-arch ARCH=aarch64

# Build for x86_64
make -f tools/build/Makefile.multi-arch ARCH=x86_64

# Build for ARM 32-bit
make -f tools/build/Makefile.multi-arch ARCH=arm

# Build for RISC-V 64-bit
make -f tools/build/Makefile.multi-arch ARCH=riscv64
```

### 4. Test with QEMU

```bash
# Test all architectures
./test-qemu.sh

# Test specific architecture
qemu-system-i386 -kernel build/x86_64/kernel.elf -nographic
```

## 🏗️ Architecture Support

| Architecture | Status | Cross-Compiler | QEMU Support | Notes |
|-------------|--------|----------------|--------------|-------|
| **x86_64** | ✅ Working | `x86_64-unknown-linux-gnu-gcc` | ✅ Full | 32-bit multiboot, boots successfully |
| **aarch64** | ⚠️ Partial | `aarch64-unknown-linux-gnu-gcc` | ⚠️ Hangs | Builds but hangs in QEMU |
| **arm** | ⚠️ Partial | `arm-unknown-linux-gnueabihf-gcc` | ⚠️ Hangs | Builds but hangs in QEMU |
| **riscv64** | ⚠️ Partial | `riscv64-unknown-linux-gnu-gcc` | ⚠️ Hangs | Builds, OpenSBI loads but kernel hangs |

## 🔧 Troubleshooting

### Common Issues

#### 1. "make: No rule to make target 'macos-install-deps'"
**Solution:** Use the new build scripts instead of the old Makefile targets:
```bash
./setup-macos.sh      # Instead of make macos-setup
./build-macos.sh      # Instead of make macos-build
```

#### 2. Cross-compiler not found
**Solution:** Install the missing toolchain:
```bash
brew tap messense/macos-cross-toolchains
brew install aarch64-unknown-linux-gnu
brew install x86_64-unknown-linux-gnu
brew install riscv64-unknown-linux-gnu
brew install arm-unknown-linux-gnueabihf
```

#### 3. QEMU not found
**Solution:** Install QEMU:
```bash
brew install qemu
```

#### 4. GNU tools not found
**Solution:** Install GNU tools:
```bash
brew install gnu-sed grep findutils gnu-tar coreutils
```

### Environment Setup

If you need to manually set up the environment:
```bash
# Source the environment setup
source setup-env-macos.sh

# Or set manually
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
export SED="gsed"
export GREP="ggrep"
export FIND="gfind"
export TAR="gtar"
```

## 📁 Build Artifacts

After successful builds, you'll find:

```
build/
├── x86_64/
│   ├── kernel.elf      # x86_64 kernel (32-bit multiboot)
│   └── kernel.img      # Raw kernel image
├── aarch64/
│   ├── kernel.elf      # ARM64 kernel
│   └── kernel.img      # Raw kernel image
├── arm/
│   ├── kernel.elf      # ARM 32-bit kernel
│   └── kernel.img      # Raw kernel image
└── riscv64/
    ├── kernel.elf      # RISC-V 64-bit kernel
    └── kernel.img      # Raw kernel image

build-output/
└── SAGE-OS-0.1.0-YYYYMMDD-HHMMSS-{arch}-{platform}.img
```

## 🧪 Testing

### QEMU Testing

The x86_64 kernel boots successfully and shows:
```
SAGE OS v0.1.0 - Multi-Architecture Operating System
Copyright (c) 2025 Ashish Vasant Yesale

Initializing SAGE OS...
Memory management initialized
Shell initialized
AI subsystem initialized

sage@localhost:~$ 
```

### Manual QEMU Commands

```bash
# x86_64 (working)
qemu-system-i386 -kernel build/x86_64/kernel.elf -nographic

# ARM64 (hangs)
qemu-system-aarch64 -M virt -cpu cortex-a72 -m 1G -kernel build/aarch64/kernel.img -nographic

# ARM 32-bit (hangs)
qemu-system-arm -M versatilepb -cpu arm1176 -m 256M -kernel build/arm/kernel.img -nographic

# RISC-V 64-bit (hangs after OpenSBI)
qemu-system-riscv64 -M virt -cpu rv64 -m 1G -kernel build/riscv64/kernel.img -nographic
```

## 🔍 Known Issues

1. **ARM64/ARM32 kernels hang**: The kernels build successfully but hang during boot in QEMU. This appears to be related to serial driver initialization or BSS clearing.

2. **RISC-V kernel hangs**: OpenSBI loads successfully but the kernel doesn't start. This may be related to the entry point or memory layout.

3. **Serial output issues**: Some architectures don't produce serial output in QEMU, making debugging difficult.

## 🚀 Next Steps

1. **Fix ARM64/ARM32 boot issues**: Debug the hanging kernels
2. **Fix RISC-V entry point**: Ensure proper kernel loading after OpenSBI
3. **Improve serial drivers**: Add proper serial output for all architectures
4. **Add real hardware testing**: Test on actual Raspberry Pi hardware

## 📚 Additional Resources

- [SAGE OS Main README](README.md)
- [Build System Documentation](docs/build-system.md)
- [Architecture Support](docs/architectures.md)
- [QEMU Testing Guide](docs/qemu-testing.md)

## 🤝 Contributing

If you encounter issues or have improvements for macOS support:

1. Check existing issues in the repository
2. Create a detailed bug report with:
   - macOS version
   - Homebrew version
   - Build logs
   - QEMU output
3. Submit a pull request with fixes

## 📄 License

SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
See [LICENSE](LICENSE) for details.