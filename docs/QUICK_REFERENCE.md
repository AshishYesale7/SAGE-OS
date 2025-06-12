# SAGE-OS Quick Reference Guide

## 🚀 Quick Start Commands

### 1. Initial Setup
```bash
# Clone and setup
git clone //github.com/AshishYesale7/SAGE-OS.git
cd SAGE-OS
git checkout dev

# Install all dependencies automatically
chmod +x scripts/install-dependencies.sh
./scripts/install-dependencies.sh

# Verify installation
./scripts/install-dependencies.sh --verify
```

### 2. Build Commands
```bash
# Interactive build menu
./build.sh

# Build specific architecture
./build.sh build i386
./build.sh build x86_64
./build.sh build aarch64

# Build all architectures
./build.sh build-all

# Clean builds
./build.sh clean
./build.sh clean-all
```

### 3. Testing Commands
```bash
# Safe QEMU testing (recommended)
tmux new-session -d -s qemu-test
tmux send-keys -t qemu-test "./build.sh" Enter
# Choose option 8 for QEMU testing
# To exit: tmux kill-session -t qemu-test

# Comprehensive testing
chmod +x scripts/test-all-features.sh
./scripts/test-all-features.sh

# Quick tests only
./scripts/test-all-features.sh --quick
```

### 4. Docker Commands
```bash
# Build Docker images
make docker-build ARCH=i386
make docker-build-all

# Run SAGE-OS container
docker run -it sage-os:0.1.0-i386

# List images
docker images | grep sage-os
```

### 5. Security Scanning
```bash
# Basic CVE scan
./scan-vulnerabilities.sh --arch i386

# HTML report
./scan-vulnerabilities.sh --format html --arch x86_64 --output ./reports

# PDF report
./scan-vulnerabilities.sh --format pdf --arch aarch64 --output ./reports

# Scan Docker images
./scan-vulnerabilities.sh --format json --scan-docker --output ./reports
```

## 📁 Project Structure

```
SAGE-OS/
├── build.sh                    # Main build script
├── build-macos.sh             # macOS-specific build script
├── scan-vulnerabilities.sh    # CVE security scanner
├── Makefile                   # Main makefile
├── Makefile.multi-arch        # Multi-architecture makefile
├── boot/                      # Boot assembly files
│   ├── boot_with_multiboot.S  # x86 multiboot boot
│   ├── boot_i386.S           # i386-specific boot
│   ├── boot_aarch64.S        # ARM64 boot
│   ├── boot_arm.S            # ARM32 boot
│   └── boot_riscv64.S        # RISC-V boot
├── kernel/                    # Kernel source code
│   ├── kernel.c              # Main kernel
│   ├── uart.c                # UART driver
│   ├── vga.c                 # VGA driver (x86)
│   └── serial.c              # Serial driver (x86)
├── linker/                    # Linker scripts
│   ├── linker.ld             # Generic linker script
│   └── linker_i386.ld        # i386-specific linker
├── build/                     # Build output
│   ├── i386/                 # i386 build files
│   ├── x86_64/               # x86_64 build files
│   ├── aarch64/              # ARM64 build files
│   ├── arm/                  # ARM32 build files
│   ├── riscv64/              # RISC-V build files
│   ├── iso/                  # ISO images
│   └── sdcard/               # SD card images
├── scripts/                   # Utility scripts
│   ├── install-dependencies.sh # Dependency installer
│   └── test-all-features.sh   # Comprehensive tester
└── docs/                      # Documentation
    ├── DEVELOPER_GUIDE.md     # Detailed developer guide
    └── QUICK_REFERENCE.md     # This file
```

## 🏗️ Architecture Support

| Architecture | Status | QEMU Command | Notes |
|-------------|--------|--------------|-------|
| i386 | ✅ Working | `qemu-system-i386` | 32-bit x86, VGA output |
| x86_64 | ✅ Working | `qemu-system-x86_64` | 64-bit x86, VGA output |
| aarch64 | ✅ Working | `qemu-system-aarch64` | 64-bit ARM, UART output |
| arm | ✅ Working | `qemu-system-arm` | 32-bit ARM, UART output |
| riscv64 | ✅ Working | `qemu-system-riscv64` | 64-bit RISC-V, UART output |

## 🔧 Common Commands

### Build System
```bash
# Manual build for specific architecture
make ARCH=i386 clean all

# Create ISO image
make ARCH=x86_64 iso

# Create SD card image (ARM)
make ARCH=aarch64 sdcard

# Check build status
ls -la build/*/kernel.*
```

### QEMU Testing (Safe Method)
```bash
# Create tmux session for testing
tmux new-session -d -s "qemu-i386"
tmux send-keys -t "qemu-i386" "qemu-system-i386 -machine pc -m 256M -kernel build/i386/kernel.elf -serial stdio -display none" Enter

# Attach to see output
tmux attach -t "qemu-i386"

# Kill if stuck (from another terminal)
tmux kill-session -t "qemu-i386"
```

### Docker Operations
```bash
# Build and tag image
docker build -t sage-os:custom .

# Run with volume mount
docker run -it -v $(pwd):/workspace sage-os:0.1.0-i386

# Clean up images
docker rmi $(docker images -q sage-os)
```

### CVE Scanning
```bash
# Update CVE database
cve-bin-tool --update

# Scan specific binary
cve-bin-tool build/i386/kernel.elf

# Generate multiple format reports
./scan-vulnerabilities.sh --format html --format pdf --arch x86_64
```

## 🐛 Troubleshooting

### Build Issues
```bash
# Missing toolchain
sudo apt install gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-riscv64-linux-gnu

# Multilib conflicts
sudo apt remove gcc-multilib && sudo apt install gcc-multilib

# Permission issues
chmod +x build.sh build-macos.sh scan-vulnerabilities.sh
```

### QEMU Issues
```bash
# Kill stuck processes
pkill -f qemu-system
tmux kill-server

# Missing QEMU
sudo apt install qemu-system-x86 qemu-system-arm qemu-system-misc
```

### Docker Issues
```bash
# Docker permission
sudo usermod -aG docker $USER
newgrp docker

# Start Docker daemon
sudo systemctl start docker
```

## 📊 Output Files

### Build Outputs
- `build/ARCH/kernel.img` - Raw kernel binary
- `build/ARCH/kernel.elf` - ELF executable
- `build/ARCH/kernel.map` - Memory map

### Images
- `build/iso/sage-os-ARCH.iso` - Bootable ISO
- `build/sdcard/sage-os-ARCH.img` - SD card image

### Docker Images
- `sage-os:0.1.0-ARCH` - Architecture-specific images

### Security Reports
- `SAGE-OS-0.1.0-YYYYMMDD-ARCH-cve-report.html`
- `SAGE-OS-0.1.0-YYYYMMDD-ARCH-cve-report.pdf`
- `SAGE-OS-0.1.0-YYYYMMDD-ARCH-cve-report.json`

## 🔄 Git Workflow

### Setup
```bash
git config user.name "Ashish Vasant Yesale"
git config user.email "ashishyesale007@gmail.com"
```

### Development
```bash
# Work on dev branch
git checkout dev
git pull origin dev

# Make changes and commit
git add .
git commit -m "Description of changes"
git push origin dev
```

### Testing Before Commit
```bash
# Run comprehensive tests
./scripts/test-all-features.sh

# Build all architectures
./build.sh build-all

# Generate security reports
./scan-vulnerabilities.sh --format html --arch i386
```

## 🎯 Performance Tips

### Faster Builds
```bash
# Use parallel compilation
make -j$(nproc) ARCH=x86_64

# Use ccache
export CC="ccache gcc"

# RAM disk for builds
sudo mount -t tmpfs -o size=2G tmpfs /tmp/sage-build
```

### Efficient Testing
```bash
# Test specific functionality only
./scripts/test-all-features.sh --build-only
./scripts/test-all-features.sh --qemu-only

# Skip slow tests
SKIP_QEMU=true SKIP_DOCKER=true ./scripts/test-all-features.sh
```

## 📞 Getting Help

### Documentation
- [Developer Guide](DEVELOPER_GUIDE.md) - Comprehensive guide
- [Architecture Guide](ARCHITECTURE.md) - System architecture
- [Contributing](../CONTRIBUTING.md) - Contribution guidelines

### Commands
```bash
# Script help
./build.sh --help
./scan-vulnerabilities.sh --help
./scripts/install-dependencies.sh --help
./scripts/test-all-features.sh --help

# Verify installation
./scripts/install-dependencies.sh --verify
```

### Support
- GitHub Issues: Report bugs and request features
- GitHub Discussions: Ask questions and share ideas
- Wiki: Additional documentation and examples

---
**Quick Reference Version**: 1.0  
**Last Updated**: 2025-05-28  
**Compatible with**: SAGE-OS 0.1.0+