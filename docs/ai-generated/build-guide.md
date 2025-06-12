# 🔨 SAGE OS Build Guide

**Generated**: 2025-06-12T22:04:30.045243

## Prerequisites

### Required Tools

- **Compiler**: GCC 9+ or Clang 10+
- **Build System**: GNU Make or CMake
- **Emulator**: QEMU 5.0+
- **Python**: 3.8+ (for build scripts)
- **Git**: For version control

### Platform-Specific Requirements

#### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install build-essential gcc-multilib qemu-system-x86 python3 git
```

#### macOS
```bash
brew install gcc qemu python3 git
# For cross-compilation
brew install x86_64-elf-gcc i386-elf-gcc
```

#### Windows (MSYS2)
```bash
pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-qemu python3 git
```

## Build Process

### 1. Clone Repository

```bash
git clone https://github.com/AshishYesale7/SAGE-OS.git
cd SAGE-OS
```

### 2. Configure Build

```bash
# Set target architecture
export ARCH=i386          # or x86_64, arm64, riscv
export TARGET=generic     # or specific target

# Configure build options
make menuconfig           # Interactive configuration (if available)
```

### 3. Build Kernel

```bash
# Clean build
make clean

# Build kernel
make ARCH=i386 TARGET=generic

# Build with debug symbols
make ARCH=i386 TARGET=generic DEBUG=1

# Parallel build
make -j$(nproc) ARCH=i386 TARGET=generic
```

### 4. Build Output

After successful build, you'll find:

```
build/
├── i386/
│   ├── kernel.elf       # Main kernel binary
│   ├── kernel.img       # Disk image (if created)
│   ├── boot/           # Boot components
│   └── drivers/        # Compiled drivers
```

## Testing

### QEMU Testing

```bash
# Basic console mode
qemu-system-i386 -kernel build/i386/kernel.elf -m 128M -nographic

# Graphics mode with keyboard/mouse
qemu-system-i386 -kernel build/i386/kernel.elf -m 256M -vga std -display gtk

# With USB input devices
qemu-system-i386 -kernel build/i386/kernel.elf -m 256M -device usb-kbd -device usb-mouse

# Debug mode with GDB
qemu-system-i386 -kernel build/i386/kernel.elf -m 128M -s -S
```

### Hardware Testing

```bash
# Create bootable USB (Linux)
sudo dd if=build/i386/kernel.img of=/dev/sdX bs=1M

# Create bootable USB (Windows)
# Use tools like Rufus or Win32DiskImager
```

## Troubleshooting

### Common Build Issues

#### 1. Compiler Not Found
```bash
# Install cross-compiler
sudo apt install gcc-multilib
# or
brew install x86_64-elf-gcc
```

#### 2. QEMU Not Working
```bash
# Check QEMU installation
qemu-system-i386 --version

# Install QEMU
sudo apt install qemu-system-x86
```

#### 3. Build Errors
```bash
# Clean and rebuild
make clean
make ARCH=i386 TARGET=generic VERBOSE=1

# Check dependencies
make check-deps
```

### macOS M1 Specific Issues

```bash
# Use TCG acceleration instead of HVF
qemu-system-i386 -kernel build/i386/kernel.elf -m 128M -accel tcg

# Install x86 cross-compiler
brew install x86_64-elf-gcc i386-elf-gcc
```

## Advanced Build Options

### Custom Configuration

```bash
# Enable specific features
make ARCH=i386 FEATURES="ai,graphics,networking" TARGET=generic

# Disable features
make ARCH=i386 DISABLE="debug,verbose" TARGET=generic

# Custom compiler
make ARCH=i386 CC=clang TARGET=generic
```

### Cross-Compilation

```bash
# For ARM64
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- TARGET=generic

# For RISC-V
make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- TARGET=generic
```

## Continuous Integration

The project includes GitHub Actions workflows for automated building and testing:

- **Multi-Architecture Build**: Tests all supported architectures
- **QEMU Testing**: Automated boot testing
- **Security Scanning**: Code security analysis
- **Documentation**: Automatic documentation generation

---

*For more detailed information, see the individual component documentation.*
