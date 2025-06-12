# SAGE-OS Developer Guide

## 📋 Table of Contents
- [System Requirements](#system-requirements)
- [Installation & Setup](#installation--setup)
- [Build System](#build-system)
- [QEMU Testing](#qemu-testing)
- [Docker Integration](#docker-integration)
- [Security Scanning](#security-scanning)
- [Development Workflow](#development-workflow)
- [Troubleshooting](#troubleshooting)

## 🖥️ System Requirements

### Supported Host Systems
- **Linux**: Ubuntu 20.04+, Debian 11+, Fedora 35+, Arch Linux
- **macOS**: 11.0+ (Big Sur) with Homebrew
- **Windows**: WSL2 with Ubuntu 20.04+

### Hardware Requirements
- **CPU**: x86_64 with virtualization support (VT-x/AMD-V)
- **RAM**: Minimum 4GB, Recommended 8GB+
- **Storage**: 10GB free space
- **Network**: Internet connection for dependency installation

## 🚀 Installation & Setup

### 1. Clone Repository
```bash
git clone //github.com/AshishYesale7/SAGE-OS.git
cd SAGE-OS
git checkout dev
```

### 2. Install Dependencies by Platform

#### Ubuntu/Debian
```bash
# Update package manager
sudo apt update && sudo apt upgrade -y

# Install build essentials
sudo apt install -y build-essential git curl wget

# Install cross-compilation toolchains
sudo apt install -y gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-riscv64-linux-gnu

# Install x86 multilib support
sudo apt install -y gcc-multilib

# Install image creation tools
sudo apt install -y genisoimage dosfstools mtools

# Install QEMU emulators
sudo apt install -y qemu-system-x86 qemu-system-arm qemu-system-misc

# Install Docker
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Install security scanning tools
sudo apt install -y python3-pip
pip3 install cve-bin-tool

# Install development tools
sudo apt install -y tmux tree htop
```

#### macOS (Homebrew)
```bash
# Install Homebrew if not present
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install cross-compilation toolchains
brew install aarch64-elf-gcc arm-none-eabi-gcc riscv64-elf-gcc

# Install build tools
brew install make cmake autoconf automake

# Install image creation tools
brew install cdrtools dosfstools

# Install QEMU
brew install qemu

# Install Docker Desktop
brew install --cask docker

# Install security tools
brew install python3
pip3 install cve-bin-tool

# Install development tools
brew install tmux tree htop
```

#### Fedora/RHEL/CentOS
```bash
# Install development tools
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y git curl wget

# Install cross-compilation toolchains
sudo dnf install -y gcc-aarch64-linux-gnu gcc-arm-linux-gnu gcc-riscv64-linux-gnu

# Install image tools
sudo dnf install -y genisoimage dosfstools mtools

# Install QEMU
sudo dnf install -y qemu-system-x86 qemu-system-arm qemu-system-riscv

# Install Docker
sudo dnf install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Install security tools
sudo dnf install -y python3-pip
pip3 install cve-bin-tool
```

### 3. Verify Installation
```bash
# Check toolchains
aarch64-linux-gnu-gcc --version
arm-linux-gnueabihf-gcc --version
riscv64-linux-gnu-gcc --version
x86_64-linux-gnu-gcc --version || gcc --version

# Check QEMU
qemu-system-x86_64 --version
qemu-system-aarch64 --version

# Check Docker
docker --version
docker run hello-world

# Check security tools
cve-bin-tool --version
```

## 🔨 Build System

### Build Script Usage
```bash
# Interactive build menu
./build.sh

# Direct architecture builds
./build.sh build i386
./build.sh build x86_64
./build.sh build aarch64
./build.sh build arm
./build.sh build riscv64

# Build all architectures
./build.sh build-all

# Clean builds
./build.sh clean
./build.sh clean-all
```

### macOS Build System
```bash
# Interactive macOS build menu
./build-macos.sh

# Available options:
# 1) Install build dependencies
# 2) Build for Raspberry Pi 4 (ARM64)
# 3) Build for Raspberry Pi 5 (ARM64)
# 4) Build for x86_64
# 5) Build for all architectures
# 6) Create SD card image for Raspberry Pi
# 7) Create ISO image for x86_64
# 8) Test build with QEMU
# 9) Build with Docker
# 10) Show build status
# 11) Clean build files
# 12) Show detailed help
```

### Manual Build Commands
```bash
# Build specific architecture manually
make ARCH=i386 clean
make ARCH=i386 all

# Available architectures
make ARCH=x86_64 all    # 64-bit x86
make ARCH=i386 all      # 32-bit x86
make ARCH=aarch64 all   # 64-bit ARM
make ARCH=arm all       # 32-bit ARM
make ARCH=riscv64 all   # 64-bit RISC-V

# Create ISO images
make ARCH=x86_64 iso
make ARCH=i386 iso

# Create SD card images (ARM)
make ARCH=aarch64 sdcard
make ARCH=arm sdcard
```

### Build Output Structure
```
build/
├── i386/
│   ├── kernel.img          # Kernel binary
│   ├── kernel.elf          # ELF executable
│   ├── kernel.map          # Memory map
│   └── objects/            # Object files
├── x86_64/
├── aarch64/
├── arm/
├── riscv64/
├── iso/
│   ├── sage-os-i386.iso
│   └── sage-os-x86_64.iso
└── sdcard/
    ├── sage-os-aarch64.img
    └── sage-os-arm.img
```

## 🖥️ QEMU Testing

### Safe QEMU Testing with tmux
```bash
# Create tmux wrapper for safe testing
cat > test-qemu-safe.sh << 'EOF'
#!/bin/bash
ARCH=${1:-i386}
SESSION_NAME="qemu-test-$ARCH"

echo "Starting QEMU test for $ARCH in tmux session: $SESSION_NAME"
tmux new-session -d -s "$SESSION_NAME"
tmux send-keys -t "$SESSION_NAME" "cd $(pwd)" Enter
tmux send-keys -t "$SESSION_NAME" "timeout 30s ./build.sh" Enter

echo "Session created. Commands:"
echo "  Attach: tmux attach -t $SESSION_NAME"
echo "  Kill:   tmux kill-session -t $SESSION_NAME"
echo "  List:   tmux list-sessions"
EOF
chmod +x test-qemu-safe.sh

# Test specific architecture
./test-qemu-safe.sh i386
./test-qemu-safe.sh x86_64
./test-qemu-safe.sh aarch64
```

### Manual QEMU Commands
```bash
# x86_64 testing
qemu-system-x86_64 \
    -machine q35 \
    -cpu qemu64 \
    -m 512M \
    -kernel build/x86_64/kernel.elf \
    -serial stdio \
    -display none

# i386 testing
qemu-system-i386 \
    -machine pc \
    -cpu pentium3 \
    -m 256M \
    -kernel build/i386/kernel.elf \
    -serial stdio \
    -display none

# ARM64 testing
qemu-system-aarch64 \
    -machine virt \
    -cpu cortex-a57 \
    -m 512M \
    -kernel build/aarch64/kernel.img \
    -serial stdio \
    -display none

# ARM32 testing
qemu-system-arm \
    -machine virt \
    -cpu cortex-a15 \
    -m 256M \
    -kernel build/arm/kernel.img \
    -serial stdio \
    -display none

# RISC-V testing
qemu-system-riscv64 \
    -machine virt \
    -cpu rv64 \
    -m 512M \
    -kernel build/riscv64/kernel.img \
    -serial stdio \
    -display none
```

### QEMU Exit Commands
```bash
# Standard exit sequence
Ctrl+A, then X

# Alternative methods
Ctrl+Alt+Q          # Quick exit
Ctrl+Alt+2          # Switch to monitor
(qemu) quit         # Type in monitor

# Emergency kill (from another terminal)
pkill -f qemu-system
tmux kill-session -t qemu-test-*
```

### ISO Testing
```bash
# Test x86_64 ISO
qemu-system-x86_64 \
    -machine q35 \
    -m 512M \
    -cdrom build/iso/sage-os-x86_64.iso \
    -boot d \
    -serial stdio

# Test i386 ISO
qemu-system-i386 \
    -machine pc \
    -m 256M \
    -cdrom build/iso/sage-os-i386.iso \
    -boot d \
    -serial stdio
```

## 🐳 Docker Integration

### Build Docker Images
```bash
# Build for specific architecture
make docker-build ARCH=i386
make docker-build ARCH=x86_64
make docker-build ARCH=aarch64

# Build all Docker images
make docker-build-all

# List created images
docker images | grep sage-os
```

### Docker Image Usage
```bash
# Run SAGE-OS container
docker run -it sage-os:0.1.0-i386

# Run with volume mounting
docker run -it -v $(pwd):/workspace sage-os:0.1.0-x86_64

# Run specific architecture
docker run --platform linux/amd64 sage-os:0.1.0-x86_64
docker run --platform linux/arm64 sage-os:0.1.0-aarch64
```

### Docker Development
```bash
# Build development image
docker build -t sage-os-dev:latest -f Dockerfile.dev .

# Run development container
docker run -it --rm \
    -v $(pwd):/workspace \
    -w /workspace \
    sage-os-dev:latest bash

# Multi-architecture build
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 -t sage-os:multi .
```

## 🔒 Security Scanning

### CVE Scanner Usage
```bash
# Show help and options
./scan-vulnerabilities.sh --help

# Basic vulnerability scan
./scan-vulnerabilities.sh --arch i386

# Comprehensive scan with multiple formats
./scan-vulnerabilities.sh \
    --format html \
    --arch x86_64 \
    --output /tmp/security-reports \
    --scan-docker \
    --scan-iso

# Generate PDF report
./scan-vulnerabilities.sh \
    --format pdf \
    --arch aarch64 \
    --output ./security-reports

# JSON output for automation
./scan-vulnerabilities.sh \
    --format json \
    --arch riscv64 \
    --output ./reports

# CSV for spreadsheet analysis
./scan-vulnerabilities.sh \
    --format csv \
    --arch arm \
    --output ./csv-reports
```

### CVE Scanner Options
```bash
# Available formats
--format json       # Machine-readable JSON
--format html       # Web-viewable HTML report
--format pdf        # Printable PDF report
--format csv        # Spreadsheet-compatible CSV
--format console    # Terminal output (default)

# Architecture selection
--arch i386         # 32-bit x86
--arch x86_64       # 64-bit x86
--arch aarch64      # 64-bit ARM
--arch arm          # 32-bit ARM
--arch riscv64      # 64-bit RISC-V

# Scan targets
--scan-build-output # Scan build directory
--scan-docker       # Scan Docker images
--scan-iso          # Scan ISO files
--scan-all          # Scan everything

# Output options
--output DIR        # Output directory
--verbose           # Detailed output
--quiet             # Minimal output
```

### Security Report Analysis
```bash
# View HTML reports
firefox security-reports/SAGE-OS-0.1.0-*-cve-report.html

# Analyze JSON reports
jq '.vulnerabilities[] | select(.severity=="HIGH")' report.json

# Check PDF reports
evince security-reports/SAGE-OS-0.1.0-*-cve-report.pdf

# Process CSV data
csvtool col 1,3,5 report.csv | head -20
```

### Custom Security Scans
```bash
# Scan specific binary
cve-bin-tool build/x86_64/kernel.elf

# Scan with specific database
cve-bin-tool --update
cve-bin-tool --database /path/to/cve.db build/

# Generate detailed report
cve-bin-tool --html-file report.html --json-file report.json build/
```

## 🔄 Development Workflow

### Git Configuration
```bash
# Set up git credentials
git config user.name "Ashish Vasant Yesale"
git config user.email "ashishyesale007@gmail.com"

# Configure git for development
git config core.autocrlf input
git config pull.rebase false
git config init.defaultBranch main
```

### Branch Management
```bash
# Work on dev branch
git checkout dev
git pull origin dev

# Create feature branch
git checkout -b feature/new-functionality
git push -u origin feature/new-functionality

# Merge back to dev
git checkout dev
git merge feature/new-functionality
git push origin dev
```

### Testing Workflow
```bash
# 1. Build all architectures
./build.sh build-all

# 2. Test with QEMU (safely)
for arch in i386 x86_64 aarch64 arm riscv64; do
    echo "Testing $arch..."
    ./test-qemu-safe.sh $arch
    sleep 5
    tmux kill-session -t "qemu-test-$arch" 2>/dev/null
done

# 3. Create Docker images
make docker-build-all

# 4. Run security scans
./scan-vulnerabilities.sh --format html --arch i386 --output ./reports

# 5. Commit changes
git add .
git commit -m "Description of changes"
git push origin dev
```

### Continuous Integration
```bash
# CI/CD pipeline script
cat > .github/workflows/ci.yml << 'EOF'
name: SAGE-OS CI
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        arch: [i386, x86_64, aarch64, arm, riscv64]
    steps:
    - uses: actions/checkout@v3
    - name: Install dependencies
      run: |
        sudo apt update
        sudo apt install -y gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-riscv64-linux-gnu gcc-multilib
    - name: Build ${{ matrix.arch }}
      run: ./build.sh build ${{ matrix.arch }}
    - name: Test with QEMU
      run: timeout 30s ./build.sh test ${{ matrix.arch }} || true
EOF
```

## 🐛 Troubleshooting

### Common Build Issues
```bash
# Missing toolchain
sudo apt install gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-riscv64-linux-gnu

# Multilib conflicts
sudo apt remove gcc-multilib
sudo apt install gcc-multilib

# Permission issues
sudo chown -R $USER:$USER /workspace/SAGE-OS
chmod +x build.sh build-macos.sh scan-vulnerabilities.sh
```

### QEMU Issues
```bash
# Kill stuck QEMU processes
pkill -f qemu-system
ps aux | grep qemu

# Fix KVM permissions
sudo usermod -aG kvm $USER
sudo chmod 666 /dev/kvm

# QEMU not found
sudo apt install qemu-system-x86 qemu-system-arm qemu-system-misc
```

### Docker Issues
```bash
# Docker permission denied
sudo usermod -aG docker $USER
newgrp docker

# Docker daemon not running
sudo systemctl start docker
sudo systemctl enable docker

# Clean Docker cache
docker system prune -a
```

### CVE Scanner Issues
```bash
# Update CVE database
cve-bin-tool --update

# Python dependencies
pip3 install --upgrade cve-bin-tool

# Permission issues
sudo chown -R $USER:$USER ~/.cache/cve-bin-tool
```

### Performance Optimization
```bash
# Parallel builds
make -j$(nproc) ARCH=x86_64

# Use ccache for faster rebuilds
sudo apt install ccache
export CC="ccache gcc"

# RAM disk for faster builds
sudo mount -t tmpfs -o size=2G tmpfs /tmp/sage-build
```

## 📚 Additional Resources

### Documentation
- [Architecture Guide](ARCHITECTURE.md)
- [API Reference](API.md)
- [Security Guide](SECURITY.md)
- [Contributing Guidelines](CONTRIBUTING.md)

### External Links
- [QEMU Documentation](https://www.qemu.org/docs/master/)
- [Docker Documentation](https://docs.docker.com/)
- [CVE Database](https://cve.mitre.org/)
- [Cross-compilation Guide](https://wiki.osdev.org/Cross-Compiler)

### Support
- GitHub Issues: //github.com/AshishYesale7/SAGE-OS/issues
- Discussions: //github.com/AshishYesale7/SAGE-OS/discussions
- Wiki: //github.com/AshishYesale7/SAGE-OS/wiki

---
**Last Updated**: 2025-05-28
**Version**: 0.1.0
**Maintainer**: Ashish Vasant Yesale <ashishyesale007@gmail.com>