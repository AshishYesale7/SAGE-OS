# SAGE OS Build Guide for Arch Linux

**Author:** Ashish Vasant Yesale <ashishyesale007@gmail.com>  
**Date:** 2025-05-28  
**Target:** Arch Linux / Unix Systems  

## Overview

This guide provides comprehensive instructions for building SAGE OS on Arch Linux and Unix-based systems, addressing the specific requirements and package management for Arch-based distributions.

---

## Arch Linux Dependency Installation

### Core Build Dependencies

```bash
# Update system
sudo pacman -Syu

# Install base development tools
sudo pacman -S base-devel git

# Install cross-compilation toolchains
sudo pacman -S \
    gcc \
    gcc-multilib \
    aarch64-linux-gnu-gcc \
    arm-linux-gnueabihf-gcc \
    riscv64-linux-gnu-gcc

# Install emulation and testing tools
sudo pacman -S \
    qemu-full \
    qemu-system-x86 \
    qemu-system-arm \
    qemu-system-aarch64 \
    qemu-system-riscv \
    tmux

# Install image creation tools
sudo pacman -S \
    cdrtools \
    dosfstools \
    mtools \
    grub \
    xorriso

# Install security and analysis tools
sudo pacman -S \
    docker \
    python-pip

# Install CVE scanning tools via pip
pip install --user cve-bin-tool
```

### AUR Packages (if needed)

```bash
# Install yay AUR helper if not present
sudo pacman -S yay

# Additional cross-compilers from AUR (if needed)
yay -S \
    riscv64-elf-gcc \
    arm-none-eabi-gcc
```

---

## Arch-Specific Build Process

### 1. Clone and Setup

```bash
# Clone repository
git clone //github.com/AshishYesale7/SAGE-OS.git
cd SAGE-OS

# Switch to development branch
git checkout dev

# Verify dependencies
./scripts/install-dependencies.sh --check-arch
```

### 2. Architecture-Specific Builds

#### For x86_64 (Intel/AMD 64-bit)
```bash
# Build kernel
make -f Makefile.multi-arch kernel ARCH=x86_64 PLATFORM=generic

# Create ISO
make -f Makefile.multi-arch iso ARCH=x86_64 PLATFORM=generic

# Test with QEMU
make -f Makefile.multi-arch qemu-test ARCH=x86_64 PLATFORM=generic
```

#### For i386 (Intel/AMD 32-bit)
```bash
# Build kernel
make -f Makefile.multi-arch kernel ARCH=i386 PLATFORM=generic

# Create ISO
make -f Makefile.multi-arch iso ARCH=i386 PLATFORM=generic

# Test with QEMU
make -f Makefile.multi-arch qemu-test ARCH=i386 PLATFORM=generic
```

#### For ARM64 (aarch64)
```bash
# Build kernel
make -f Makefile.multi-arch kernel ARCH=aarch64 PLATFORM=generic

# Create SD card image
make -f Makefile.multi-arch sdcard ARCH=aarch64 PLATFORM=generic

# Test with QEMU
make -f Makefile.multi-arch qemu-test ARCH=aarch64 PLATFORM=generic
```

### 3. Arch Linux Optimizations

#### Compiler Optimizations
```bash
# Use Arch-specific compiler flags
export CFLAGS="-march=native -O2 -pipe"
export CXXFLAGS="${CFLAGS}"
export MAKEFLAGS="-j$(nproc)"

# Build with optimizations
make -f Makefile.multi-arch kernel ARCH=x86_64 PLATFORM=generic CFLAGS="${CFLAGS}"
```

#### Package Cache Integration
```bash
# Use ccache for faster rebuilds
sudo pacman -S ccache
export PATH="/usr/lib/ccache/bin:$PATH"
export CCACHE_DIR="$HOME/.ccache"
```

---

## Arch Linux Troubleshooting

### Common Issues and Solutions

#### 1. Missing Cross-Compilers
```bash
# If cross-compilers are missing, install from AUR
yay -S aarch64-linux-gnu-gcc arm-linux-gnueabihf-gcc

# Or use multilib repository
sudo pacman -S gcc-multilib
```

#### 2. QEMU Permission Issues
```bash
# Add user to kvm group for hardware acceleration
sudo usermod -a -G kvm $USER
newgrp kvm

# Enable KVM acceleration
echo 'KERNEL=="kvm", GROUP="kvm", MODE="0666"' | sudo tee /etc/udev/rules.d/99-kvm.rules
sudo udevadm control --reload-rules
```

#### 3. Docker Issues
```bash
# Start Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Add user to docker group
sudo usermod -a -G docker $USER
newgrp docker
```

---

## Performance Tuning for Arch Linux

### Build Performance
```bash
# Use all CPU cores
export MAKEFLAGS="-j$(nproc)"

# Enable ccache
export CCACHE_DIR="$HOME/.ccache"
export PATH="/usr/lib/ccache/bin:$PATH"

# Optimize for native architecture
export CFLAGS="-march=native -O2 -pipe"
```

### QEMU Performance
```bash
# Enable KVM acceleration
qemu-system-x86_64 -enable-kvm -cpu host -smp $(nproc) -m 2G

# Use virtio drivers for better performance
qemu-system-x86_64 -netdev user,id=net0 -device virtio-net,netdev=net0
```

---

## Arch Linux Specific Features

### Pacman Integration
```bash
# Create PKGBUILD for SAGE OS
cat > PKGBUILD << 'EOF'
pkgname=sage-os
pkgver=0.1.0
pkgrel=1
pkgdesc="SAGE OS - Self-Aware General Evolution Operating System"
arch=('x86_64' 'i686' 'aarch64')
url="//github.com/AshishYesale7/SAGE-OS"
license=('MIT')
depends=('qemu' 'grub' 'xorriso')
makedepends=('gcc' 'make' 'git')
source=("git+//github.com/AshishYesale7/SAGE-OS.git")
sha256sums=('SKIP')

build() {
    cd "$srcdir/SAGE-OS"
    make -f Makefile.multi-arch kernel ARCH=x86_64 PLATFORM=generic
}

package() {
    cd "$srcdir/SAGE-OS"
    install -Dm644 build-output/SAGE-OS-0.1.0-x86_64-generic.img \
        "$pkgdir/usr/share/sage-os/sage-os.img"
}
EOF

# Build package
makepkg -si
```

### Systemd Integration
```bash
# Create systemd service for SAGE OS testing
sudo tee /etc/systemd/system/sage-os-test.service << 'EOF'
[Unit]
Description=SAGE OS QEMU Test Service
After=network.target

[Service]
Type=simple
User=sage
ExecStart=/usr/bin/qemu-system-x86_64 -kernel /usr/share/sage-os/sage-os.img -nographic
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
sudo systemctl enable sage-os-test
sudo systemctl start sage-os-test
```

---

## Advanced Arch Linux Configuration

### Custom Kernel Modules
```bash
# Build custom kernel modules for Arch
cd kernel/modules
make ARCH=x86_64 KERNEL_DIR=/lib/modules/$(uname -r)/build

# Install modules
sudo make modules_install
sudo depmod -a
```

### Arch Linux Testing
```bash
# Run comprehensive tests on Arch
./scripts/test-all-features.sh --arch-linux

# Performance benchmarking
./scripts/benchmark-arch.sh
```

---

## Conclusion

SAGE OS is fully compatible with Arch Linux and provides optimized build processes for Arch-based systems. The build system takes advantage of Arch's rolling release model and cutting-edge toolchains for optimal performance.

For additional support on Arch Linux, refer to the [Arch Wiki](https://wiki.archlinux.org/) and the SAGE OS documentation.