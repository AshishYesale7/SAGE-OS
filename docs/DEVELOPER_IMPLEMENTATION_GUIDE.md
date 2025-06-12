# SAGE OS Developer Implementation Guide

**Version:** 1.0.0  
**Author:** Ashish Vasant Yesale <ashishyesale007@gmail.com>  
**Last Updated:** 2025-05-28  

## Table of Contents

1. [Quick Start](#quick-start)
2. [System Requirements](#system-requirements)
3. [Installation & Setup](#installation--setup)
4. [Build System](#build-system)
5. [Testing & Emulation](#testing--emulation)
6. [Security & Vulnerability Scanning](#security--vulnerability-scanning)
7. [Docker Integration](#docker-integration)
8. [Development Workflow](#development-workflow)
9. [Troubleshooting](#troubleshooting)
10. [Advanced Features](#advanced-features)

---

## Quick Start

### 🚀 Get SAGE OS Running in 5 Minutes

```bash
# 1. Clone the repository
git clone //github.com/AshishYesale7/SAGE-OS.git
cd SAGE-OS

# 2. Switch to development branch
git checkout dev

# 3. Install dependencies (Ubuntu/Debian)
sudo apt update && sudo apt install -y \
    gcc-multilib gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf \
    gcc-riscv64-linux-gnu qemu-system tmux genisoimage \
    grub-common grub-pc-bin xorriso docker.io

# 4. Build for your architecture
make -f Makefile.multi-arch kernel ARCH=x86_64 PLATFORM=generic

# 5. Test in QEMU
make -f Makefile.multi-arch qemu-test ARCH=x86_64 PLATFORM=generic

# 6. Create bootable ISO
make -f Makefile.multi-arch iso ARCH=x86_64 PLATFORM=generic
```

---

## System Requirements

### Minimum Requirements
- **OS:** Ubuntu 20.04+, Debian 11+, macOS 12+, or compatible Linux distribution
- **RAM:** 4GB (8GB recommended for multi-architecture builds)
- **Storage:** 10GB free space
- **CPU:** x86_64 or ARM64 with virtualization support

### Supported Host Architectures
- **x86_64** (Intel/AMD 64-bit)
- **aarch64** (ARM 64-bit)
- **arm** (ARM 32-bit)

### Target Architectures
- **i386** (Intel 32-bit)
- **x86_64** (Intel/AMD 64-bit)
- **aarch64** (ARM 64-bit - Raspberry Pi 4/5, generic)
- **arm** (ARM 32-bit - Raspberry Pi 4/5, generic)
- **riscv64** (RISC-V 64-bit)

---

## Installation & Setup

### Ubuntu/Debian Installation

```bash
#!/bin/bash
# Complete dependency installation script

# Update package lists
sudo apt update

# Install cross-compilation toolchains
sudo apt install -y \
    build-essential \
    gcc-multilib \
    gcc-aarch64-linux-gnu \
    gcc-arm-linux-gnueabihf \
    gcc-riscv64-linux-gnu \
    binutils-aarch64-linux-gnu \
    binutils-arm-linux-gnueabihf \
    binutils-riscv64-linux-gnu

# Install emulation and testing tools
sudo apt install -y \
    qemu-system-x86 \
    qemu-system-arm \
    qemu-system-misc \
    tmux \
    screen

# Install image creation tools
sudo apt install -y \
    genisoimage \
    xorriso \
    grub-common \
    grub-pc-bin \
    dosfstools \
    mtools

# Install security and analysis tools
sudo apt install -y \
    docker.io \
    python3-pip \
    curl \
    wget

# Install Python packages
pip3 install cve-bin-tool

# Configure Docker (optional)
sudo usermod -aG docker $USER
sudo systemctl enable docker
sudo systemctl start docker

echo "✅ Installation complete! Please log out and back in for Docker permissions."
```

### macOS Installation

```bash
#!/bin/bash
# macOS dependency installation using Homebrew

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install cross-compilation toolchains
brew install \
    aarch64-elf-gcc \
    arm-none-eabi-gcc \
    riscv64-elf-gcc \
    x86_64-elf-gcc

# Install emulation tools
brew install \
    qemu \
    tmux

# Install image creation tools
brew install \
    cdrtools \
    grub \
    dosfstools

# Install security tools
brew install \
    docker \
    python3

# Install Python packages
pip3 install cve-bin-tool

echo "✅ macOS installation complete!"
```

### Manual Toolchain Setup

If package managers don't have the required toolchains:

```bash
# Download and build custom toolchains
mkdir -p ~/toolchains && cd ~/toolchains

# Example: Building RISC-V toolchain
git clone https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain
./configure --prefix=$HOME/toolchains/riscv64
make

# Add to PATH
echo 'export PATH=$HOME/toolchains/riscv64/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

---

## Build System

### Architecture Overview

SAGE OS uses a multi-architecture build system with the following components:

```
SAGE-OS/
├── Makefile.multi-arch     # Main build system
├── build.sh               # Build orchestration script
├── build-macos.sh         # macOS-specific build script
├── boot/                  # Architecture-specific bootloaders
├── kernel/                # Core kernel source
├── drivers/               # Hardware drivers
├── build/                 # Build artifacts (per-architecture)
├── dist/                  # Distribution files (ISOs, images)
└── build-output/          # Versioned output files
```

### Build Commands Reference

#### Single Architecture Build

```bash
# Build kernel for specific architecture
make -f Makefile.multi-arch kernel ARCH=x86_64 PLATFORM=generic

# Build with debug symbols
make -f Makefile.multi-arch kernel ARCH=x86_64 PLATFORM=generic DEBUG=1

# Build with verbose output
make -f Makefile.multi-arch kernel ARCH=x86_64 PLATFORM=generic VERBOSE=1

# Clean build artifacts
make -f Makefile.multi-arch clean ARCH=x86_64
```

#### Multi-Architecture Build

```bash
# Build all supported architectures
./build.sh --all

# Build specific architectures
./build.sh --arch i386,x86_64,aarch64

# Build with parallel jobs
./build.sh --all --jobs 4

# Build on macOS
./build-macos.sh
```

#### Platform-Specific Builds

```bash
# Raspberry Pi 4 (ARM64)
make -f Makefile.multi-arch kernel ARCH=aarch64 PLATFORM=rpi4

# Raspberry Pi 5 (ARM64)
make -f Makefile.multi-arch kernel ARCH=aarch64 PLATFORM=rpi5

# Generic x86_64
make -f Makefile.multi-arch kernel ARCH=x86_64 PLATFORM=generic

# Intel i386
make -f Makefile.multi-arch kernel ARCH=i386 PLATFORM=generic
```

#### ISO Creation

```bash
# Create bootable ISO
make -f Makefile.multi-arch iso ARCH=x86_64 PLATFORM=generic

# Create ISO with GRUB bootloader
make -f Makefile.multi-arch iso ARCH=i386 PLATFORM=generic

# Create SD card image for Raspberry Pi
make -f Makefile.multi-arch sdcard ARCH=aarch64 PLATFORM=rpi4
```

### Build Configuration

#### Environment Variables

```bash
# Compiler settings
export CC_i386="gcc -m32"
export CC_x86_64="gcc -m64"
export CC_aarch64="aarch64-linux-gnu-gcc"
export CC_arm="arm-linux-gnueabihf-gcc"
export CC_riscv64="riscv64-linux-gnu-gcc"

# Build options
export DEBUG=1              # Enable debug symbols
export VERBOSE=1            # Verbose build output
export PARALLEL_JOBS=4      # Number of parallel build jobs
export OUTPUT_DIR="custom"  # Custom output directory
```

#### Custom Build Targets

```bash
# Add custom build target to Makefile.multi-arch
custom-target:
	@echo "Building custom target for $(ARCH)"
	$(CC) $(CFLAGS) -o $(BUILD_DIR)/custom.o custom.c

# Use custom target
make -f Makefile.multi-arch custom-target ARCH=x86_64
```

---

## Testing & Emulation

### QEMU Testing

#### Basic QEMU Testing

```bash
# Test kernel in QEMU (automatic timeout)
make -f Makefile.multi-arch qemu-test ARCH=x86_64 PLATFORM=generic

# Test with custom timeout
make -f Makefile.multi-arch qemu-test ARCH=x86_64 PLATFORM=generic TIMEOUT=60

# Test ISO in QEMU
make -f Makefile.multi-arch qemu-iso ARCH=x86_64 PLATFORM=generic
```

#### Manual QEMU Testing

```bash
# Start QEMU manually for x86_64
qemu-system-x86_64 \
    -kernel build-output/SAGE-OS-0.1.0-x86_64-generic.img \
    -m 256M \
    -nographic \
    -serial stdio

# Start QEMU for ARM64 (Raspberry Pi 4)
qemu-system-aarch64 \
    -machine virt \
    -cpu cortex-a57 \
    -kernel build-output/SAGE-OS-0.1.0-aarch64-rpi4.img \
    -m 256M \
    -nographic \
    -serial stdio

# Start QEMU with ISO
qemu-system-x86_64 \
    -cdrom dist/x86_64/SAGE-OS-0.1.0-x86_64-generic.iso \
    -boot d \
    -m 256M \
    -nographic \
    -serial stdio
```

#### TMUX-Based Testing (Recommended)

```bash
# Start QEMU in tmux session (prevents hanging)
tmux new-session -d -s sage-test \
    "qemu-system-x86_64 -kernel build-output/SAGE-OS-0.1.0-x86_64-generic.img -nographic"

# Attach to session
tmux attach-session -t sage-test

# Kill session
tmux kill-session -t sage-test
```

### Hardware Testing

#### Raspberry Pi Testing

```bash
# Create SD card image
make -f Makefile.multi-arch sdcard ARCH=aarch64 PLATFORM=rpi4

# Flash to SD card (replace /dev/sdX with your SD card)
sudo dd if=dist/aarch64/SAGE-OS-0.1.0-aarch64-rpi4.img of=/dev/sdX bs=4M status=progress
sudo sync

# Boot Raspberry Pi with SD card
```

#### Real Hardware Testing

```bash
# Create bootable USB for x86_64
sudo dd if=dist/x86_64/SAGE-OS-0.1.0-x86_64-generic.iso of=/dev/sdX bs=4M status=progress

# Boot from USB on target hardware
```

---

## Security & Vulnerability Scanning

### Enhanced CVE Scanner

#### Basic Usage

```bash
# Run comprehensive security scan
./scripts/enhanced-cve-scanner.sh

# Scan specific architecture
./scripts/enhanced-cve-scanner.sh --arch x86_64

# Generate multiple report formats
./scripts/enhanced-cve-scanner.sh --format json,html,pdf,csv

# Verbose scanning
./scripts/enhanced-cve-scanner.sh --verbose --arch i386,x86_64
```

#### Advanced Scanning Options

```bash
# Scan specific binary
./scripts/enhanced-cve-scanner.sh --binary build-output/SAGE-OS-0.1.0-x86_64-generic.img --format json

# Skip Docker scanning
./scripts/enhanced-cve-scanner.sh --no-docker --arch x86_64

# Custom output directory
./scripts/enhanced-cve-scanner.sh --output-dir my-security-scan --format html,pdf

# Summary report only
./scripts/enhanced-cve-scanner.sh --summary-only --format html
```

#### Report Analysis

```bash
# View HTML report in browser
firefox security-reports/scan_*/summary.html

# Parse JSON report programmatically
python3 -c "
import json
with open('security-reports/scan_*/summary.json', 'r') as f:
    data = json.load(f)
    print(f'Total vulnerabilities: {data[\"statistics\"][\"total_vulnerabilities\"]}')
    print(f'Critical: {data[\"statistics\"][\"critical\"]}')
"

# Convert reports to other formats
pandoc security-reports/scan_*/summary.html -o report.docx
```

### Security Best Practices

```bash
# Regular security scanning (weekly)
crontab -e
# Add: 0 2 * * 1 /path/to/SAGE-OS/scripts/enhanced-cve-scanner.sh --format html,json

# Automated vulnerability monitoring
./scripts/enhanced-cve-scanner.sh --format json | \
    python3 -c "
import json, sys
data = json.load(sys.stdin)
if data['statistics']['critical'] > 0:
    print('CRITICAL vulnerabilities found!')
    sys.exit(1)
"
```

---

## Docker Integration

### Docker Builder

#### Basic Docker Operations

```bash
# Build Docker images for all architectures
./scripts/docker-builder.sh

# Build for specific architectures
./scripts/docker-builder.sh --arch x86_64,aarch64

# Build with custom registry
./scripts/docker-builder.sh --registry docker.io/myusername

# Build and push to registry
./scripts/docker-builder.sh --registry docker.io/myusername --push
```

#### Running SAGE OS in Docker

```bash
# Run SAGE OS container
docker run -it sage-os:0.1.0-x86_64-generic

# Run with port forwarding
docker run -it -p 5900:5900 -p 8080:8080 sage-os:0.1.0-x86_64-generic

# Run with volume mounting
docker run -it -v $(pwd)/data:/opt/sage-os/data sage-os:0.1.0-x86_64-generic

# Run in background
docker run -d --name sage-os-instance sage-os:0.1.0-x86_64-generic
```

#### Docker Development Workflow

```bash
# Build development image
docker build -t sage-os:dev .

# Run development container with source mounting
docker run -it -v $(pwd):/workspace sage-os:dev bash

# Multi-stage Docker build
docker build --target development -t sage-os:dev-env .
docker build --target production -t sage-os:prod .
```

---

## Development Workflow

### Git Workflow

```bash
# Setup development environment
git clone //github.com/AshishYesale7/SAGE-OS.git
cd SAGE-OS
git checkout dev

# Configure git credentials
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Create feature branch
git checkout -b feature/new-feature

# Make changes and commit
git add .
git commit -m "feat: add new feature"

# Push changes
git push origin feature/new-feature

# Create pull request (via GitHub web interface)
```

### Code Quality Checks

```bash
# Run license header checks
python3 scripts/enhanced_license_tool.py --check

# Fix license headers
python3 scripts/enhanced_license_tool.py --fix

# Run security analysis
./scripts/security-scan.sh

# Validate build system
./VERIFY_BUILD_SYSTEM.sh
```

### Testing Workflow

```bash
# Run all tests
./test-all-builds.sh

# Test specific architecture
make -f Makefile.multi-arch test ARCH=x86_64

# Benchmark builds
./benchmark-builds.sh

# Integration testing
cd tests && python3 -m pytest integration_tests/
```

### Continuous Integration

```yaml
# .github/workflows/ci.yml example
name: CI
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        arch: [i386, x86_64, aarch64]
    steps:
      - uses: actions/checkout@v3
      - name: Install dependencies
        run: |
          sudo apt update
          sudo apt install -y gcc-multilib gcc-aarch64-linux-gnu
      - name: Build
        run: make -f Makefile.multi-arch kernel ARCH=${{ matrix.arch }}
      - name: Test
        run: make -f Makefile.multi-arch qemu-test ARCH=${{ matrix.arch }}
```

---

## Troubleshooting

### Common Build Issues

#### Toolchain Problems

```bash
# Check available toolchains
which gcc
which aarch64-linux-gnu-gcc
which arm-linux-gnueabihf-gcc

# Install missing toolchains
sudo apt install gcc-aarch64-linux-gnu

# Verify toolchain versions
gcc --version
aarch64-linux-gnu-gcc --version
```

#### Build Failures

```bash
# Clean build and retry
make -f Makefile.multi-arch clean ARCH=x86_64
make -f Makefile.multi-arch kernel ARCH=x86_64 VERBOSE=1

# Check build logs
tail -f build/x86_64/build.log

# Debug linker issues
objdump -h build/x86_64/kernel.elf
readelf -l build/x86_64/kernel.elf
```

#### QEMU Issues

```bash
# Check QEMU installation
qemu-system-x86_64 --version
qemu-system-aarch64 --version

# Test QEMU manually
qemu-system-x86_64 -kernel /boot/vmlinuz -nographic

# Kill stuck QEMU processes
pkill -f qemu-system
tmux kill-server
```

### Performance Optimization

```bash
# Parallel builds
make -f Makefile.multi-arch kernel ARCH=x86_64 -j$(nproc)

# Use ccache for faster rebuilds
export CC="ccache gcc"
make -f Makefile.multi-arch kernel ARCH=x86_64

# Optimize for size
make -f Makefile.multi-arch kernel ARCH=x86_64 OPTIMIZE=size

# Profile build times
time make -f Makefile.multi-arch kernel ARCH=x86_64
```

### Debugging Techniques

```bash
# Enable debug symbols
make -f Makefile.multi-arch kernel ARCH=x86_64 DEBUG=1

# Use GDB with QEMU
qemu-system-x86_64 -kernel build/x86_64/kernel.elf -s -S &
gdb build/x86_64/kernel.elf
(gdb) target remote :1234
(gdb) continue

# Analyze memory layout
objdump -t build/x86_64/kernel.elf | grep -E "(text|data|bss)"

# Check for undefined symbols
nm build/x86_64/kernel.elf | grep " U "
```

---

## Advanced Features

### Custom Architecture Support

```bash
# Add new architecture support
mkdir -p boot/boot_newarch.S
mkdir -p drivers/newarch/

# Update Makefile.multi-arch
# Add newarch to SUPPORTED_ARCHITECTURES
# Add newarch-specific compiler settings

# Test new architecture
make -f Makefile.multi-arch kernel ARCH=newarch PLATFORM=generic
```

### Kernel Modules

```bash
# Build kernel modules
make -f Makefile.multi-arch modules ARCH=x86_64

# Load modules at runtime
insmod build/x86_64/modules/example.ko

# Create module package
make -f Makefile.multi-arch modules-package ARCH=x86_64
```

### Cross-Platform Development

```bash
# Build on macOS for Linux targets
./build-macos.sh --target linux --arch x86_64

# Build on Linux for macOS targets
./build.sh --target macos --arch x86_64

# Universal binary creation
lipo -create build/x86_64/kernel.elf build/aarch64/kernel.elf -output kernel-universal
```

### Performance Monitoring

```bash
# Profile kernel boot time
qemu-system-x86_64 -kernel build/x86_64/kernel.elf -nographic -monitor stdio
(qemu) info registers
(qemu) info memory

# Memory usage analysis
valgrind --tool=memcheck qemu-system-x86_64 -kernel build/x86_64/kernel.elf

# CPU profiling
perf record qemu-system-x86_64 -kernel build/x86_64/kernel.elf
perf report
```

---

## Command Reference

### Quick Command Cheatsheet

```bash
# Essential Commands
make -f Makefile.multi-arch kernel ARCH=x86_64 PLATFORM=generic  # Build kernel
make -f Makefile.multi-arch qemu-test ARCH=x86_64                # Test in QEMU
make -f Makefile.multi-arch iso ARCH=x86_64                      # Create ISO
./scripts/enhanced-cve-scanner.sh --arch x86_64                  # Security scan
./scripts/docker-builder.sh --arch x86_64                        # Build Docker image

# Build System
./build.sh --all                                                 # Build all architectures
./build.sh --arch i386,x86_64                                   # Build specific architectures
make -f Makefile.multi-arch clean ARCH=x86_64                   # Clean build
make -f Makefile.multi-arch help                                # Show help

# Testing
tmux new -d -s test "qemu-system-x86_64 -kernel kernel.img"     # TMUX QEMU test
make -f Makefile.multi-arch qemu-iso ARCH=x86_64                # Test ISO
./test-all-builds.sh                                            # Test all builds

# Security
./scripts/enhanced-cve-scanner.sh --format html,pdf             # Multi-format scan
./scripts/security-scan.sh                                      # Quick security check
python3 scripts/enhanced_license_tool.py --check               # License check

# Docker
docker run -it sage-os:0.1.0-x86_64-generic                    # Run SAGE OS
./scripts/docker-builder.sh --push --registry docker.io/user   # Build and push
docker build -t sage-os:custom .                                # Custom build
```

### Environment Setup Scripts

```bash
# Create development environment setup script
cat > setup-dev-env.sh << 'EOF'
#!/bin/bash
set -euo pipefail

echo "🔧 Setting up SAGE OS development environment..."

# Install dependencies
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt update
    sudo apt install -y gcc-multilib gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf \
        gcc-riscv64-linux-gnu qemu-system tmux genisoimage grub-common \
        grub-pc-bin xorriso docker.io python3-pip
    pip3 install cve-bin-tool
elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install aarch64-elf-gcc arm-none-eabi-gcc riscv64-elf-gcc \
        qemu tmux cdrtools grub docker python3
    pip3 install cve-bin-tool
fi

# Configure git
read -p "Enter your name: " name
read -p "Enter your email: " email
git config user.name "$name"
git config user.email "$email"

# Set up aliases
echo "alias sage-build='make -f Makefile.multi-arch kernel'" >> ~/.bashrc
echo "alias sage-test='make -f Makefile.multi-arch qemu-test'" >> ~/.bashrc
echo "alias sage-scan='./scripts/enhanced-cve-scanner.sh'" >> ~/.bashrc

echo "✅ Development environment setup complete!"
echo "Please run 'source ~/.bashrc' to load aliases."
EOF

chmod +x setup-dev-env.sh
```

---

## Support & Resources

### Documentation Links
- [Build System Guide](BUILD_SYSTEM.md)
- [Security Documentation](SECURITY.md)
- [Contributing Guidelines](CONTRIBUTING.md)
- [API Documentation](docs/api/)
- [Architecture Overview](docs/architecture/)

### Community Resources
- **GitHub Issues:** [Report bugs and request features](//github.com/AshishYesale7/SAGE-OS/issues)
- **Discussions:** [Community discussions](//github.com/AshishYesale7/SAGE-OS/discussions)
- **Wiki:** [Additional documentation](//github.com/AshishYesale7/SAGE-OS/wiki)

### Getting Help

```bash
# Show build system help
make -f Makefile.multi-arch help

# Show script help
./scripts/enhanced-cve-scanner.sh --help
./scripts/docker-builder.sh --help
./build.sh --help

# Check system compatibility
./VERIFY_BUILD_SYSTEM.sh

# Run diagnostics
./scripts/test_emulated.sh
```

---

**Last Updated:** 2025-05-28  
**Version:** 1.0.0  
**Maintainer:** Ashish Vasant Yesale <ashishyesale007@gmail.com>

For the latest updates and detailed technical documentation, visit the [SAGE OS Documentation](docs/) directory.