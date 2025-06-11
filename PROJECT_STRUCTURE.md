# SAGE-OS Project Structure

This document explains the simplified and organized structure of SAGE-OS.

## 📁 Directory Structure

```
SAGE-OS/
├── 🏗️ Core Build System
│   ├── Makefile                    # Main build system
│   ├── VERSION                     # Current version (1.0.1)
│   └── scripts/
│       ├── version-manager.sh      # Version management
│       └── test-qemu.sh           # Unified QEMU testing
│
├── 💾 Source Code
│   ├── boot/                      # Boot loaders for all architectures
│   │   ├── boot.S                 # Main boot loader
│   │   ├── boot_aarch64.S         # AArch64 specific
│   │   ├── boot_i386.S            # i386 specific
│   │   └── boot_riscv64.S         # RISC-V specific
│   │
│   ├── kernel/                    # Kernel source code
│   │   ├── kernel.c               # Main kernel with UART support
│   │   ├── memory.c               # Memory management
│   │   ├── shell.c                # Interactive shell
│   │   └── ai/                    # AI subsystem
│   │
│   └── drivers/                   # Hardware drivers
│       ├── uart.c                 # UART driver
│       ├── vga.c                  # VGA driver
│       └── ai_hat/                # AI HAT support
│
├── 🔧 Build Outputs
│   ├── build/                     # Temporary build files
│   │   ├── i386/                  # i386 build artifacts
│   │   ├── aarch64/               # AArch64 build artifacts
│   │   └── x86_64/                # x86_64 build artifacts
│   │
│   └── output/                    # Final kernel images
│       ├── i386/
│       │   ├── sage-os-v1.0.1-i386-generic.img
│       │   └── sage-os-v1.0.1-i386-generic.elf
│       ├── aarch64/
│       │   ├── sage-os-v1.0.1-aarch64-generic.img
│       │   └── sage-os-v1.0.1-aarch64-rpi5.img
│       └── x86_64/
│           └── sage-os-v1.0.1-x86_64-generic.iso
│
└── 📚 Documentation
    ├── docs/
    │   ├── platforms/             # Platform-specific guides
    │   │   ├── linux/             # Linux development
    │   │   ├── macos/             # macOS development
    │   │   ├── windows/           # Windows development
    │   │   └── raspberry-pi/      # Raspberry Pi deployment
    │   │
    │   └── architectures/         # Architecture-specific guides
    │       ├── i386/              # i386 architecture
    │       ├── aarch64/           # AArch64 architecture
    │       ├── x86_64/            # x86_64 architecture
    │       └── riscv64/           # RISC-V architecture
    │
    └── README.md                  # Main project documentation
```

## 🚀 Quick Start

### 1. Build for Your Architecture
```bash
# Build for i386 (fully working)
make ARCH=i386

# Build for AArch64 (fully working)
make ARCH=aarch64

# Build for Raspberry Pi 5
make ARCH=aarch64 TARGET=rpi5
```

### 2. Test in QEMU
```bash
# Test current build
make test

# Test specific architecture
./scripts/test-qemu.sh i386
./scripts/test-qemu.sh aarch64
```

### 3. Get Information
```bash
# Show help
make help

# Show build info
make info

# Show supported architectures
make list-arch
```

## 🏗️ Architecture Support

| Architecture | Status | QEMU Command | Notes |
|--------------|--------|--------------|-------|
| **i386** | ✅ **Fully Working** | `qemu-system-i386` | Complete shell, all features |
| **AArch64** | ✅ **Fully Working** | `qemu-system-aarch64 -M virt` | UART fixed, Raspberry Pi ready |
| **x86_64** | ⚠️ **Partial** | `qemu-system-x86_64` | GRUB boots, kernel debugging needed |
| **RISC-V** | ⚠️ **Partial** | `qemu-system-riscv64 -M virt` | OpenSBI loads, kernel hangs |

## 🔧 Build System Features

### Simple Version Management
- Version stored in `VERSION` file
- Simple naming: `sage-os-v1.0.1-aarch64-generic.img`
- No confusing build numbers or git hashes

### Unified Testing
- Single script: `./scripts/test-qemu.sh <arch>`
- Automatic build if needed
- Consistent QEMU settings per architecture

### Clean Output Structure
- `build/` - Temporary compilation files
- `output/` - Final kernel images and ELF files
- Clear separation by architecture

## 🧹 Cleaning

```bash
# Clean build files only
make clean

# Clean output files
make clean-output

# Clean everything
make clean-all
```

## 📝 File Naming Convention

### Kernel Images
- Format: `sage-os-v{VERSION}-{ARCH}-{TARGET}.img`
- Examples:
  - `sage-os-v1.0.1-i386-generic.img`
  - `sage-os-v1.0.1-aarch64-rpi5.img`
  - `sage-os-v1.0.1-x86_64-generic.iso`

### Debug Files
- Format: `sage-os-v{VERSION}-{ARCH}-{TARGET}.elf`
- Contains debug symbols for development

## 🎯 Targets

- **generic** - Standard target for QEMU and generic hardware
- **rpi4** - Raspberry Pi 4 specific optimizations
- **rpi5** - Raspberry Pi 5 specific optimizations

## 🔍 Key Features

1. **Consistent UART Output** - All architectures show the same boot sequence
2. **Interactive Shell Demo** - Simulated shell with common commands
3. **Architecture Detection** - Kernel shows correct architecture in version info
4. **Unified Build System** - Same commands work across all platforms
5. **Simple Testing** - One script to test any architecture

---

**Author:** Ashish Vasant Yesale <ashishyesale007@gmail.com>  
**Version:** 1.0.1  
**Last Updated:** June 11, 2025