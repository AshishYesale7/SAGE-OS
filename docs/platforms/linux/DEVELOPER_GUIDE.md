# SAGE-OS Developer Guide for Linux (Updated 2025-06-11)

## Overview

This guide provides comprehensive instructions for setting up SAGE-OS development environment on Linux distributions, building the OS for all supported architectures, and testing both serial console and VGA graphics modes.

## 🚀 Quick Start

```bash
# Clone and setup
git clone https://github.com/AshishYesale7/SAGE-OS.git
cd SAGE-OS

# Install dependencies (auto-detects distribution)
./tools/build/install-deps.sh

# Test both modes
make test-i386                # Serial console mode
make test-i386-graphics       # VGA graphics mode (NEW!)
```

## Supported Distributions

- **Ubuntu/Debian** (apt-based) - Fully supported
- **Fedora/RHEL/CentOS** (yum/dnf-based) - Fully supported
- **Arch Linux** (pacman-based) - Fully supported
- **Other distributions** (manual installation) - Partial support

## Prerequisites

- Linux kernel 4.0 or later
- At least 4GB of free disk space
- Internet connection for package installation
- sudo/root access for package installation

## 🏗️ Project Structure

The project is now organized for better maintainability:
```
SAGE-OS/
├── tools/
│   ├── build/           # Build tools and scripts
│   ├── testing/         # Testing utilities
│   └── development/     # Development tools
├── scripts/
│   ├── build/           # Build scripts (build-graphics.sh)
│   ├── testing/         # Test scripts (test-qemu.sh)
│   └── deployment/      # Deployment scripts
├── config/
│   ├── platforms/       # Platform configurations
│   └── grub.cfg         # Boot configuration
├── prototype/           # Restored prototype code
├── examples/            # Example code and demos
├── kernel/
│   ├── kernel.c         # Serial mode kernel
│   └── kernel_graphics.c # Graphics mode kernel (NEW!)
└── drivers/
    └── vga.c            # VGA text mode driver (ENHANCED!)
```

## Manual Setup by Distribution

### Ubuntu/Debian

```bash
# Update package list
sudo apt update

# Install essential build tools
sudo apt install -y build-essential git make cmake

# Install cross-compilation toolchains
sudo apt install -y \
    gcc-aarch64-linux-gnu \
    gcc-arm-linux-gnueabihf \
    gcc-riscv64-linux-gnu

# Install QEMU for testing
sudo apt install -y \
    qemu-system-arm \
    qemu-system-x86 \
    qemu-system-misc

# Install ISO creation tools
sudo apt install -y genisoimage dosfstools
```

### Fedora/RHEL/CentOS

```bash
# Install essential build tools
sudo dnf install -y gcc gcc-c++ git make cmake

# Install cross-compilation toolchains
sudo dnf install -y \
    gcc-aarch64-linux-gnu \
    gcc-arm-linux-gnueabihf

# Install QEMU for testing
sudo dnf install -y \
    qemu-system-aarch64 \
    qemu-system-arm \
    qemu-system-x86

# Install ISO creation tools
sudo dnf install -y genisoimage dosfstools
```

### Arch Linux

```bash
# Install essential build tools
sudo pacman -S --noconfirm base-devel git make cmake

# Install cross-compilation toolchains
sudo pacman -S --noconfirm \
    aarch64-linux-gnu-gcc \
    arm-linux-gnueabihf-gcc

# Install QEMU for testing
sudo pacman -S --noconfirm qemu-arch-extra

# Install ISO creation tools
sudo pacman -S --noconfirm cdrtools dosfstools
```

## Building SAGE-OS

### Build All Architectures

```bash
# Build for all supported architectures
./build.sh build-all

# Or use the comprehensive build script
./build-all-architectures.sh
```

### Build Specific Architecture

```bash
# Build for specific architecture
./build.sh build aarch64 rpi5    # ARM64 for Raspberry Pi 5
./build.sh build x86_64 generic  # x86_64 for generic PC
./build.sh build i386 generic    # i386 for older PCs
./build.sh build riscv64 generic # RISC-V 64-bit
```

### Build with Make

```bash
# Traditional make approach
make ARCH=aarch64  # ARM64
make ARCH=x86_64   # x86_64
make ARCH=i386     # i386
make ARCH=riscv64  # RISC-V
```

## Testing in QEMU

### Quick Testing

```bash
# Test specific architecture
./build.sh test aarch64 rpi5
./build.sh test x86_64 generic
./build.sh test i386 generic
```

### Manual QEMU Testing

#### i386 (32-bit x86) - ✅ Working
```bash
qemu-system-i386 -kernel build/i386/kernel.img -nographic
```

#### x86_64 (64-bit x86) - ISO
```bash
qemu-system-x86_64 -cdrom build-output/sageos-x86_64.iso -nographic
```

#### AArch64 (ARM64) - ✅ Working
```bash
qemu-system-aarch64 -M virt -cpu cortex-a72 -kernel build/aarch64/kernel.img -nographic
```

#### RISC-V 64-bit
```bash
qemu-system-riscv64 -M virt -kernel build/riscv64/kernel.img -nographic
```

### Safe QEMU Testing (Recommended)

To prevent terminal lockups, use tmux:

```bash
# Start tmux session
tmux new-session -d -s sage-test

# Run QEMU in tmux
tmux send-keys -t sage-test "qemu-system-aarch64 -M virt -cpu cortex-a72 -kernel build/aarch64/kernel.img -nographic" Enter

# Attach to session
tmux attach -t sage-test

# To exit: Ctrl+A, X (in QEMU) or Ctrl+B, D (detach tmux)
# To kill session: tmux kill-session -t sage-test
```

## Architecture Status and Commands

### i386 (32-bit x86)
- **Status**: ✅ Fully Working
- **Target**: Legacy PCs, VMs
- **Build**: `make ARCH=i386`
- **Test**: `qemu-system-i386 -kernel build/i386/kernel.img -nographic`

### x86_64 (64-bit x86)
- **Status**: ⚠️ Partial (GRUB boots, kernel debugging needed)
- **Target**: Modern PCs, VMs
- **Build**: `make ARCH=x86_64`
- **Test**: `qemu-system-x86_64 -cdrom build-output/sageos-x86_64.iso -nographic`

### AArch64 (ARM64)
- **Status**: ✅ Fully Working
- **Target**: Raspberry Pi 4/5, ARM servers
- **Build**: `make ARCH=aarch64`
- **Test**: `qemu-system-aarch64 -M virt -cpu cortex-a72 -kernel build/aarch64/kernel.img -nographic`

### ARM (32-bit)
- **Status**: ✅ Builds Successfully
- **Target**: Raspberry Pi 3, older ARM devices
- **Build**: `make ARCH=arm`
- **Test**: `qemu-system-arm -M virt -kernel build/arm/kernel.img -nographic`

### RISC-V 64-bit
- **Status**: ⚠️ Builds, OpenSBI loads, kernel hangs
- **Target**: RISC-V development boards
- **Build**: `make ARCH=riscv64`
- **Test**: `qemu-system-riscv64 -M virt -kernel build/riscv64/kernel.img -nographic`

## Development Workflow

### 1. Edit Code
```bash
# Edit kernel code
nano kernel/kernel.c

# Edit shell commands
nano kernel/shell.c

# Edit drivers
nano drivers/uart.c
```

### 2. Build and Test Cycle
```bash
# Quick build and test for ARM64
make ARCH=aarch64 && qemu-system-aarch64 -M virt -cpu cortex-a72 -kernel build/aarch64/kernel.img -nographic

# Quick build and test for i386
make ARCH=i386 && qemu-system-i386 -kernel build/i386/kernel.img -nographic
```

### 3. Debug with GDB
```bash
# Build with debug symbols
make ARCH=aarch64 CFLAGS="-g -O0"

# Start QEMU with GDB server
qemu-system-aarch64 -M virt -cpu cortex-a72 -kernel build/aarch64/kernel.img -nographic -s -S &

# Connect GDB
aarch64-linux-gnu-gdb build/aarch64/kernel.elf
(gdb) target remote localhost:1234
(gdb) continue
```

## Troubleshooting

### Common Issues

#### 1. Cross-compiler not found
```bash
# Check if toolchains are installed
which aarch64-linux-gnu-gcc
which riscv64-linux-gnu-gcc

# Install missing toolchains (Ubuntu/Debian)
sudo apt install gcc-aarch64-linux-gnu gcc-riscv64-linux-gnu
```

#### 2. QEMU not found
```bash
# Install QEMU (Ubuntu/Debian)
sudo apt install qemu-system-arm qemu-system-x86 qemu-system-misc

# Verify installation
qemu-system-aarch64 --version
```

#### 3. Permission denied on scripts
```bash
# Make scripts executable
chmod +x build.sh
chmod +x build-all-architectures.sh
chmod +x run_qemu.sh
```

#### 4. Build fails with missing headers
```bash
# Install development headers (Ubuntu/Debian)
sudo apt install linux-libc-dev

# For cross-compilation
sudo apt install libc6-dev-arm64-cross libc6-dev-armel-cross
```

### Distribution-Specific Issues

#### Ubuntu/Debian
```bash
# If repositories are missing
sudo apt update
sudo apt install software-properties-common

# Add universe repository
sudo add-apt-repository universe
```

#### Fedora/RHEL
```bash
# Enable EPEL repository (RHEL/CentOS)
sudo dnf install epel-release

# Install development tools
sudo dnf groupinstall "Development Tools"
```

#### Arch Linux
```bash
# Update package database
sudo pacman -Sy

# Install base development group
sudo pacman -S base-devel
```

## Performance Optimization

### 1. Parallel Builds
```bash
# Use all CPU cores
make -j$(nproc) ARCH=aarch64

# Or specify core count
make -j4 ARCH=aarch64
```

### 2. Build Caching
```bash
# Install ccache for faster rebuilds
sudo apt install ccache  # Ubuntu/Debian
sudo dnf install ccache  # Fedora
sudo pacman -S ccache    # Arch

# Use ccache
export CC="ccache gcc"
export CXX="ccache g++"
```

### 3. RAM Disk for Builds
```bash
# Create RAM disk for faster builds
sudo mkdir /mnt/ramdisk
sudo mount -t tmpfs -o size=2G tmpfs /mnt/ramdisk

# Build in RAM disk
cp -r SAGE-OS /mnt/ramdisk/
cd /mnt/ramdisk/SAGE-OS
make ARCH=aarch64
```

## Docker Development

### 1. Build with Docker
```bash
# Build all architectures in Docker
make docker-build-all

# Build specific architecture
docker run --rm -v $(pwd):/workspace sage-os:build make ARCH=aarch64
```

### 2. Create Development Container
```bash
# Build development image
docker build -t sage-os:dev -f Dockerfile.aarch64 .

# Run development container
docker run -it --rm -v $(pwd):/workspace sage-os:dev bash
```

## Advanced Features

### 1. ISO Creation
```bash
# Create bootable ISO for x86_64
./build.sh build x86_64 generic iso

# Manual ISO creation
make ARCH=x86_64 iso
```

### 2. Security Scanning
```bash
# Run comprehensive security scan
./scan-vulnerabilities.sh --format html --arch aarch64

# Quick security check
./quick-security-check.sh
```

### 3. Automated Testing
```bash
# Run all tests
./scripts/test-all-features.sh

# Test specific architecture
./scripts/test_emulated.sh aarch64
```

## Hardware Deployment

### Raspberry Pi Deployment

#### 1. Prepare SD Card
```bash
# Format SD card (replace /dev/sdX with your SD card)
sudo fdisk /dev/sdX
# Create FAT32 partition

sudo mkfs.vfat /dev/sdX1
```

#### 2. Copy Files
```bash
# Mount SD card
sudo mkdir /mnt/sdcard
sudo mount /dev/sdX1 /mnt/sdcard

# Copy kernel and config
sudo cp build/aarch64/kernel.img /mnt/sdcard/kernel8.img
sudo cp config_rpi5.txt /mnt/sdcard/config.txt

# Copy Raspberry Pi firmware (download from official repo)
# https://github.com/raspberrypi/firmware/tree/master/boot
sudo cp firmware/* /mnt/sdcard/

sudo umount /mnt/sdcard
```

## Useful Commands Reference

```bash
# Development workflow
./build.sh status                    # Check build status
./build.sh clean                     # Clean all builds
./build.sh build aarch64 rpi5        # Build for RPi 5
./build.sh test aarch64 rpi5         # Test in QEMU
make ARCH=aarch64 info              # Show build info

# Quick testing
make ARCH=i386 && qemu-system-i386 -kernel build/i386/kernel.img -nographic
make ARCH=aarch64 && qemu-system-aarch64 -M virt -cpu cortex-a72 -kernel build/aarch64/kernel.img -nographic

# Debugging
make ARCH=aarch64 CFLAGS="-g -O0"
qemu-system-aarch64 -M virt -cpu cortex-a72 -kernel build/aarch64/kernel.img -nographic -s -S

# Cleanup
make clean
rm -rf build/ build-output/
```

## Next Steps

1. **Start with Working Architectures**: Begin with i386 or aarch64
2. **Explore the Shell**: Try commands like `help`, `version`, `ai info`
3. **Modify Code**: Add new shell commands or drivers
4. **Test on Hardware**: Deploy to Raspberry Pi
5. **Debug Issues**: Help fix x86_64 and RISC-V boot problems
6. **Contribute**: Submit improvements and bug fixes

## Support and Community

- **Documentation**: Comprehensive docs in `docs/` directory
- **Issues**: Report bugs on GitHub repository
- **Discussions**: Join development discussions
- **Wiki**: Check project wiki for additional resources

This guide provides everything needed to develop SAGE-OS on Linux. The automated scripts handle most complexity, but manual steps are provided for customization and troubleshooting.