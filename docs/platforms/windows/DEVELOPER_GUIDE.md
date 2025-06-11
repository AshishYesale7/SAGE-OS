# SAGE-OS Developer Guide for Windows

## Overview

This guide provides comprehensive instructions for setting up SAGE-OS development environment on Windows using WSL2 (Windows Subsystem for Linux), building the OS for all supported architectures, and testing in QEMU.

## Prerequisites

- Windows 10 version 2004 or later, or Windows 11
- WSL2 enabled
- At least 8GB of RAM (4GB for WSL2)
- At least 10GB of free disk space
- Administrator privileges for initial setup

## Setup Methods

We recommend **WSL2** for the best development experience, but also provide alternatives:

1. **WSL2 (Recommended)** - Native Linux environment in Windows
2. **Docker Desktop** - Containerized development
3. **MSYS2/MinGW** - Native Windows toolchain (limited support)

## Method 1: WSL2 Setup (Recommended)

### 1. Enable WSL2

Open PowerShell as Administrator and run:

```powershell
# Enable WSL and Virtual Machine Platform
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Restart Windows
Restart-Computer
```

After restart, set WSL2 as default:

```powershell
wsl --set-default-version 2
```

### 2. Install Ubuntu on WSL2

```powershell
# Install Ubuntu 22.04 LTS
wsl --install -d Ubuntu-22.04

# Or from Microsoft Store: search for "Ubuntu 22.04 LTS"
```

### 3. Setup Ubuntu Environment

Launch Ubuntu from Start Menu and run:

```bash
# Update package list
sudo apt update && sudo apt upgrade -y

# Install essential tools
sudo apt install -y git curl wget build-essential
```

### 4. Clone and Setup SAGE-OS

```bash
# Clone repository
git clone https://github.com/Asadzero/SAGE-OS.git
cd SAGE-OS

# Make scripts executable
chmod +x build.sh

# Install all dependencies automatically
./build.sh install-deps
```

## Method 2: Docker Desktop Setup

### 1. Install Docker Desktop

1. Download Docker Desktop from [docker.com](https://www.docker.com/products/docker-desktop)
2. Install with WSL2 backend enabled
3. Restart Windows

### 2. Setup SAGE-OS with Docker

```powershell
# Clone repository (in PowerShell or Command Prompt)
git clone https://github.com/Asadzero/SAGE-OS.git
cd SAGE-OS

# Build using Docker
docker build -t sage-os:dev -f Dockerfile.x86_64 .

# Run development container
docker run -it --rm -v ${PWD}:/workspace sage-os:dev bash
```

Inside the container:
```bash
cd /workspace
./build.sh build-all
```

## Method 3: MSYS2/MinGW Setup (Limited)

### 1. Install MSYS2

1. Download MSYS2 from [msys2.org](https://www.msys2.org/)
2. Install to default location (`C:\msys64`)
3. Update package database:

```bash
pacman -Syu
```

### 2. Install Development Tools

```bash
# Install base development tools
pacman -S base-devel git

# Install cross-compilation tools (limited availability)
pacman -S mingw-w64-x86_64-gcc
```

**Note**: Cross-compilation toolchains for ARM/RISC-V are limited on Windows. WSL2 is strongly recommended.

## Building SAGE-OS

### Using WSL2 (Recommended)

```bash
# In Ubuntu WSL2 terminal
cd SAGE-OS

# Build all architectures
./build.sh build-all

# Build specific architecture
./build.sh build aarch64 rpi5    # ARM64 for Raspberry Pi 5
./build.sh build x86_64 generic  # x86_64 for generic PC
./build.sh build i386 generic    # i386 for older PCs
```

### Using Docker

```powershell
# In PowerShell/Command Prompt
cd SAGE-OS

# Build all architectures
docker run --rm -v ${PWD}:/workspace sage-os:dev ./build.sh build-all

# Build specific architecture
docker run --rm -v ${PWD}:/workspace sage-os:dev ./build.sh build aarch64 rpi5
```

## Testing in QEMU

### WSL2 with GUI (Recommended)

#### 1. Install VcXsrv (X11 Server)

1. Download VcXsrv from [sourceforge.net](https://sourceforge.net/projects/vcxsrv/)
2. Install and launch XLaunch
3. Configure:
   - Display settings: Multiple windows
   - Client startup: Start no client
   - Extra settings: ✅ Disable access control

#### 2. Configure WSL2 for GUI

```bash
# In Ubuntu WSL2
echo 'export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk "{print \$2}"):0' >> ~/.bashrc
source ~/.bashrc

# Install QEMU
sudo apt install -y qemu-system-arm qemu-system-x86 qemu-system-misc
```

#### 3. Test SAGE-OS

```bash
# Test i386 (works best)
qemu-system-i386 -kernel build/i386/kernel.img -nographic

# Test ARM64
qemu-system-aarch64 -M virt -cpu cortex-a72 -kernel build/aarch64/kernel.img -nographic

# Test x86_64 ISO
qemu-system-x86_64 -cdrom build-output/sageos-x86_64.iso -nographic
```

### WSL2 without GUI (Text-only)

```bash
# All QEMU commands work in text mode with -nographic flag
qemu-system-i386 -kernel build/i386/kernel.img -nographic
qemu-system-aarch64 -M virt -cpu cortex-a72 -kernel build/aarch64/kernel.img -nographic
```

### Docker Testing

```powershell
# Run QEMU in Docker container
docker run --rm -it -v ${PWD}:/workspace sage-os:dev bash -c "
cd /workspace && 
qemu-system-i386 -kernel build/i386/kernel.img -nographic
"
```

## Architecture Status on Windows

### i386 (32-bit x86)
- **Status**: ✅ Fully Working
- **WSL2**: ✅ Perfect
- **Docker**: ✅ Perfect
- **MSYS2**: ⚠️ Limited

### x86_64 (64-bit x86)
- **Status**: ⚠️ Partial (GRUB boots, kernel debugging needed)
- **WSL2**: ✅ Builds and runs
- **Docker**: ✅ Builds and runs
- **MSYS2**: ⚠️ Limited

### AArch64 (ARM64)
- **Status**: ✅ Fully Working
- **WSL2**: ✅ Perfect
- **Docker**: ✅ Perfect
- **MSYS2**: ❌ Not supported

### RISC-V 64-bit
- **Status**: ⚠️ Builds, OpenSBI loads, kernel hangs
- **WSL2**: ✅ Builds and runs
- **Docker**: ✅ Builds and runs
- **MSYS2**: ❌ Not supported

## Development Workflow

### 1. Code Editing

#### Visual Studio Code (Recommended)
```powershell
# Install VS Code with WSL extension
# Open project in WSL2
code .
```

#### Other Editors
- **Notepad++**: For simple edits
- **Vim/Nano**: In WSL2 terminal
- **CLion**: Professional IDE with WSL2 support

### 2. Build and Test Cycle

```bash
# In WSL2 Ubuntu terminal
cd SAGE-OS

# Edit code
code kernel/kernel.c

# Build and test
make ARCH=i386 && qemu-system-i386 -kernel build/i386/kernel.img -nographic
```

### 3. Debugging

```bash
# Build with debug symbols
make ARCH=aarch64 CFLAGS="-g -O0"

# Start QEMU with GDB server
qemu-system-aarch64 -M virt -cpu cortex-a72 -kernel build/aarch64/kernel.img -nographic -s -S &

# Connect GDB (in another terminal)
aarch64-linux-gnu-gdb build/aarch64/kernel.elf
(gdb) target remote localhost:1234
(gdb) continue
```

## Troubleshooting

### WSL2 Issues

#### 1. WSL2 not starting
```powershell
# Check WSL status
wsl --status

# Restart WSL
wsl --shutdown
wsl
```

#### 2. Out of memory
```powershell
# Create .wslconfig in %USERPROFILE%
echo "[wsl2]" > %USERPROFILE%\.wslconfig
echo "memory=4GB" >> %USERPROFILE%\.wslconfig
echo "processors=4" >> %USERPROFILE%\.wslconfig

# Restart WSL
wsl --shutdown
```

#### 3. File permissions
```bash
# Fix file permissions in WSL2
sudo chmod +x build.sh
sudo chmod +x *.sh
```

### QEMU Issues

#### 1. QEMU not found
```bash
# Install QEMU in WSL2
sudo apt update
sudo apt install qemu-system-arm qemu-system-x86 qemu-system-misc
```

#### 2. Display issues
```bash
# For GUI applications, ensure X11 forwarding is set up
export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0

# Test X11
sudo apt install x11-apps
xclock  # Should show a clock window
```

#### 3. Performance issues
```bash
# Enable KVM acceleration (if supported)
sudo apt install qemu-kvm
# Note: KVM may not work in WSL2, use software emulation
```

### Docker Issues

#### 1. Docker not starting
```powershell
# Restart Docker Desktop
# Check WSL2 integration in Docker Desktop settings
```

#### 2. Volume mounting issues
```powershell
# Use absolute paths
docker run --rm -v C:\path\to\SAGE-OS:/workspace sage-os:dev
```

## Performance Optimization

### 1. WSL2 Performance
```bash
# Use WSL2 file system for better performance
# Keep source code in /home/username/ not /mnt/c/
cp -r /mnt/c/SAGE-OS ~/SAGE-OS
cd ~/SAGE-OS
```

### 2. Parallel Builds
```bash
# Use multiple cores
make -j$(nproc) ARCH=aarch64
```

### 3. Build Caching
```bash
# Install ccache
sudo apt install ccache
export CC="ccache gcc"
```

## Windows-Specific Features

### 1. Windows Terminal Integration

Install Windows Terminal for better experience:
```powershell
# Install from Microsoft Store or GitHub
# Configure profiles for WSL2, PowerShell, etc.
```

### 2. File System Integration

```bash
# Access Windows files from WSL2
ls /mnt/c/Users/YourUsername/

# Access WSL2 files from Windows
# In File Explorer: \\wsl$\Ubuntu-22.04\home\username\
```

### 3. VS Code Integration

```bash
# Install VS Code extensions for WSL2
code --install-extension ms-vscode-remote.remote-wsl
code --install-extension ms-vscode.cpptools
```

## Useful Commands Reference

```bash
# WSL2 management (PowerShell)
wsl --list --verbose          # List WSL distributions
wsl --shutdown               # Shutdown all WSL instances
wsl --export Ubuntu-22.04 backup.tar  # Backup WSL

# Development workflow (WSL2 Ubuntu)
./build.sh status            # Check build status
./build.sh clean             # Clean all builds
./build.sh build i386        # Build for i386
./build.sh test i386         # Test in QEMU

# Quick testing
make ARCH=i386 && qemu-system-i386 -kernel build/i386/kernel.img -nographic
make ARCH=aarch64 && qemu-system-aarch64 -M virt -cpu cortex-a72 -kernel build/aarch64/kernel.img -nographic
```

## Next Steps

1. **Start with WSL2**: Most compatible and feature-complete
2. **Test i386 First**: Most stable architecture
3. **Explore the Shell**: Try `help`, `version`, `ai info` commands
4. **Use VS Code**: Best development experience on Windows
5. **Join Community**: Contribute to fixing Windows-specific issues

## Support

- **WSL2 Documentation**: [Microsoft WSL Docs](https://docs.microsoft.com/en-us/windows/wsl/)
- **Docker Documentation**: [Docker Desktop for Windows](https://docs.docker.com/desktop/windows/)
- **SAGE-OS Issues**: Report Windows-specific issues on GitHub
- **Community**: Join development discussions

This guide provides multiple paths for Windows development, with WSL2 being the recommended approach for the best compatibility and performance.