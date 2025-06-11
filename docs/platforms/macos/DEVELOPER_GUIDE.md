# SAGE-OS Developer Guide for macOS

## Overview

This guide provides comprehensive instructions for setting up SAGE-OS development environment on macOS, building the OS for all supported architectures, and testing in QEMU.

## Prerequisites

- macOS 10.15 (Catalina) or later
- Xcode Command Line Tools
- Homebrew package manager
- At least 4GB of free disk space

## Quick Setup

### 1. Install Homebrew (if not already installed)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install Xcode Command Line Tools

```bash
xcode-select --install
```

### 3. Clone SAGE-OS Repository

```bash
git clone https://github.com/Asadzero/SAGE-OS.git
cd SAGE-OS
```

### 4. Automated Setup

```bash
# Make the build script executable
chmod +x build.sh

# Install all dependencies automatically
./build.sh install-deps
```

## Manual Setup (Alternative)

If you prefer manual installation:

### Install Base Tools

```bash
# Install essential tools
brew install make cmake git

# Install QEMU for testing
brew install qemu

# Install ISO creation tools
brew install cdrtools
```

### Install Cross-Compilation Toolchains

```bash
# Add cross-compilation toolchain tap
brew tap messense/macos-cross-toolchains

# Install all architecture toolchains
brew install aarch64-unknown-linux-gnu    # ARM64
brew install x86_64-unknown-linux-gnu     # x86_64
brew install riscv64-unknown-linux-gnu    # RISC-V 64-bit
brew install arm-unknown-linux-gnueabihf  # ARM 32-bit
```

## Building SAGE-OS

### Build All Architectures

```bash
# Build for all supported architectures
./build.sh build-all

# Or use the comprehensive build script
./build-all-architectures-macos.sh
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

#### i386 (32-bit x86)
```bash
qemu-system-i386 -kernel build/i386/kernel.img -nographic
```

#### x86_64 (64-bit x86) - ISO
```bash
qemu-system-x86_64 -cdrom build-output/sageos-x86_64.iso -nographic
```

#### AArch64 (ARM64)
```bash
qemu-system-aarch64 -M virt -cpu cortex-a72 -kernel build/aarch64/kernel.img -nographic
```

#### RISC-V 64-bit
```bash
qemu-system-riscv64 -M virt -kernel build/riscv64/kernel.img -nographic
```

### Exit QEMU

- Press `Ctrl+A`, then `X` to exit QEMU
- Or type `exit` in the SAGE-OS shell

## Architecture-Specific Notes

### ARM64 (AArch64)
- **Status**: ✅ Working
- **Target**: Raspberry Pi 4/5, QEMU virt machine
- **QEMU Command**: `qemu-system-aarch64 -M virt -cpu cortex-a72`

### x86_64
- **Status**: ⚠️ Partial (GRUB boots, kernel needs debugging)
- **Target**: Modern PCs, VMs
- **QEMU Command**: `qemu-system-x86_64 -cdrom sageos.iso`

### i386
- **Status**: ✅ Working
- **Target**: Legacy PCs, VMs
- **QEMU Command**: `qemu-system-i386 -kernel kernel.img`

### RISC-V 64-bit
- **Status**: ⚠️ Builds, OpenSBI loads, kernel hangs
- **Target**: RISC-V development boards, QEMU
- **QEMU Command**: `qemu-system-riscv64 -M virt`

## Troubleshooting

### Common Issues

#### 1. Cross-compiler not found
```bash
# Check if toolchains are installed
which aarch64-unknown-linux-gnu-gcc
which x86_64-unknown-linux-gnu-gcc

# If missing, reinstall
brew reinstall aarch64-unknown-linux-gnu
```

#### 2. QEMU not found
```bash
# Install QEMU
brew install qemu

# Verify installation
qemu-system-aarch64 --version
```

#### 3. Permission denied on scripts
```bash
# Make scripts executable
chmod +x build.sh
chmod +x build-all-architectures-macos.sh
chmod +x run_qemu.sh
```

#### 4. Build fails with linker errors
```bash
# Clean and rebuild
make clean
./build.sh build aarch64
```

### macOS-Specific Issues

#### 1. Rosetta 2 (Apple Silicon Macs)
If you're on Apple Silicon and need x86_64 tools:
```bash
# Install Rosetta 2
softwareupdate --install-rosetta
```

#### 2. Homebrew Path Issues
```bash
# Add Homebrew to PATH (Apple Silicon)
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Add Homebrew to PATH (Intel)
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## Development Workflow

### 1. Edit Code
```bash
# Edit kernel code
nano kernel/kernel.c

# Edit drivers
nano drivers/uart.c
```

### 2. Build and Test
```bash
# Quick build and test
make ARCH=aarch64 && qemu-system-aarch64 -M virt -cpu cortex-a72 -kernel build/aarch64/kernel.img -nographic
```

### 3. Debug
```bash
# Build with debug symbols
make ARCH=aarch64 CFLAGS="-g -O0"

# Run with GDB
qemu-system-aarch64 -M virt -cpu cortex-a72 -kernel build/aarch64/kernel.img -nographic -s -S &
aarch64-unknown-linux-gnu-gdb build/aarch64/kernel.elf
(gdb) target remote localhost:1234
(gdb) continue
```

## UTM Setup (Alternative to QEMU)

For a GUI-based approach, you can use UTM:

### 1. Install UTM
```bash
brew install --cask utm
```

### 2. Create VM
1. Open UTM
2. Create new VM
3. Choose "Emulate"
4. Select architecture (ARM64, x86_64, etc.)
5. Load SAGE-OS kernel or ISO

### 3. Configure VM
- **Memory**: 512MB - 2GB
- **Storage**: Not needed for kernel testing
- **Network**: Disabled for basic testing

## Performance Tips

### 1. Parallel Builds
```bash
# Use multiple cores for building
make -j$(nproc) ARCH=aarch64
```

### 2. Incremental Builds
```bash
# Only rebuild changed files
make ARCH=aarch64
```

### 3. Build Caching
```bash
# Use ccache for faster rebuilds
brew install ccache
export CC="ccache gcc"
```

## Advanced Features

### 1. Docker Builds
```bash
# Build using Docker (if Docker is installed)
make docker-build-all
```

### 2. ISO Creation
```bash
# Create bootable ISO
./build.sh build x86_64 generic iso
```

### 3. Security Scanning
```bash
# Run security scans
./scan-vulnerabilities.sh --format html --arch aarch64
```

## Next Steps

1. **Explore the Code**: Start with `kernel/kernel.c` and `kernel/shell.c`
2. **Add Features**: Implement new shell commands or drivers
3. **Test on Hardware**: Deploy to actual Raspberry Pi
4. **Contribute**: Submit pull requests with improvements

## Support

- **Documentation**: Check `docs/` directory
- **Issues**: Report bugs on GitHub
- **Community**: Join development discussions

## Useful Commands Reference

```bash
# Quick commands for daily development
./build.sh status                    # Check build status
./build.sh clean                     # Clean all builds
./build.sh build aarch64 rpi5        # Build for RPi 5
./build.sh test aarch64 rpi5         # Test in QEMU
make ARCH=aarch64 info              # Show build info
```

This guide should get you up and running with SAGE-OS development on macOS. The automated setup scripts handle most of the complexity, but the manual steps are provided for those who prefer more control over their development environment.