# 🚀 SAGE OS Deployment Guide

This guide provides multiple ways to deploy and run SAGE OS with graphics and input support across different platforms.

## 📦 Available Deployment Methods

### 1. **Docker-based Deployment** (Recommended)
- **File**: `deploy-sage-os.sh`
- **Best for**: Cross-platform deployment with consistent environment
- **Supports**: VNC, Graphics, Text modes
- **Architectures**: i386, x86_64, aarch64, arm, riscv64

### 2. **macOS M1 Optimized** (macOS Users)
- **File**: `quick-start-macos.sh`
- **Best for**: macOS M1/M2 users with Docker Desktop
- **Features**: Native ARM64 support, Screen Sharing integration
- **Optimized**: Apple Silicon performance

### 3. **Local QEMU Deployment** (No Docker)
- **File**: `deploy-sage-os-local.sh`
- **Best for**: Direct QEMU execution without Docker
- **Requirements**: QEMU installed locally
- **Lightweight**: No container overhead

### 4. **Interactive Setup** (Beginners)
- **File**: `quick-start.sh`
- **Best for**: First-time users and guided setup
- **Features**: Step-by-step deployment wizard

## 🎯 Quick Start

### For macOS M1/M2 Users:
```bash
./quick-start-macos.sh
```

### For Docker Users (All Platforms):
```bash
# VNC Mode (Recommended)
./deploy-sage-os.sh deploy -d vnc -a aarch64 -p 5901

# Graphics Mode
./deploy-sage-os.sh deploy -d graphics -a i386

# Text Mode
./deploy-sage-os.sh deploy -d text -a i386
```

### For Local QEMU (No Docker):
```bash
# Test setup first
./deploy-sage-os-local.sh test

# Run with graphics
./deploy-sage-os-local.sh run -m graphics

# Run in text mode
./deploy-sage-os-local.sh run -m text
```

## 🖥️ Platform-Specific Instructions

### macOS M1/M2 with Docker Desktop

**Recommended Approach**: Use `quick-start-macos.sh`

1. **Install Docker Desktop**:
   ```bash
   # Download from: https://www.docker.com/products/docker-desktop
   ```

2. **Start SAGE OS**:
   ```bash
   ./quick-start-macos.sh
   # Choose option 1 (VNC Mode) or 2 (ARM64 Native)
   ```

3. **Connect via VNC**:
   - **Built-in Screen Sharing**: `vnc://localhost:5901`
   - **Safari/Chrome**: Navigate to `vnc://localhost:5901`
   - **Command**: `open vnc://localhost:5901`
   - **Password**: `sageos`

**Architecture Options**:
- **aarch64**: Native ARM64 (fastest on M1/M2)
- **i386**: x86 emulation (compatible but slower)

### Linux with Docker

1. **Install Docker**:
   ```bash
   sudo apt-get update
   sudo apt-get install docker.io
   sudo systemctl start docker
   ```

2. **Deploy SAGE OS**:
   ```bash
   # VNC Mode
   ./deploy-sage-os.sh deploy -d vnc -a x86_64 -p 5901
   
   # Graphics Mode (direct window)
   ./deploy-sage-os.sh deploy -d graphics -a x86_64
   ```

3. **Connect**:
   - **VNC**: Use Remmina, vncviewer, or any VNC client to `localhost:5901`
   - **Graphics**: QEMU window opens directly

### Windows with Docker Desktop

1. **Install Docker Desktop**:
   - Download from Docker website
   - Enable WSL2 backend

2. **Deploy SAGE OS**:
   ```bash
   # VNC Mode (recommended for Windows)
   ./deploy-sage-os.sh deploy -d vnc -a i386 -p 5901
   ```

3. **Connect via VNC**:
   - Use TigerVNC, RealVNC, or Windows built-in VNC client
   - Connect to `localhost:5901`
   - Password: `sageos`

## 🏗️ Architecture Support

| Architecture | Description | Best For | Performance |
|-------------|-------------|----------|-------------|
| **aarch64** | ARM 64-bit | M1/M2 Macs, ARM servers | Native on ARM |
| **i386** | x86 32-bit | Legacy compatibility | Good emulation |
| **x86_64** | x86 64-bit | Intel/AMD systems | Native on x86 |
| **arm** | ARM 32-bit | Embedded systems | Emulated |
| **riscv64** | RISC-V 64-bit | RISC-V development | Emulated |

## 🎮 Display Modes

### VNC Mode (Recommended)
- **Best for**: Remote access, macOS, Windows
- **Features**: Full keyboard/mouse support, network accessible
- **Connection**: VNC client to `localhost:5901`
- **Password**: `sageos`

### Graphics Mode
- **Best for**: Linux desktop, direct interaction
- **Features**: Native QEMU window, direct display
- **Requirements**: X11 display server

### Text Mode
- **Best for**: Headless servers, debugging
- **Features**: Terminal-only interface, lightweight
- **Access**: Direct terminal output

## 🔧 Advanced Usage

### Multiple Instances
```bash
# Instance 1: ARM64 on port 5901
./deploy-sage-os.sh deploy -a aarch64 -p 5901

# Instance 2: i386 on port 5902  
./deploy-sage-os.sh deploy -a i386 -p 5902
```

### Custom Memory Allocation
```bash
./deploy-sage-os.sh deploy -a i386 -M 256M -d vnc
```

### Container Management
```bash
# View logs
./deploy-sage-os.sh logs

# Open shell in container
./deploy-sage-os.sh shell

# Stop container
./deploy-sage-os.sh stop

# Clean up everything
./deploy-sage-os.sh clean
```

### QEMU Monitor Access
```bash
# Connect to QEMU monitor for debugging
telnet localhost 1234
```

## 🐛 Troubleshooting

### Docker Issues

**Problem**: Docker build fails with network errors
```bash
# Solution: Script automatically falls back to Alpine Linux
# Or manually pull base image:
docker pull ubuntu:22.04
```

**Problem**: Container won't start
```bash
# Check Docker status
docker info

# View container logs
./deploy-sage-os.sh logs

# Clean and rebuild
./deploy-sage-os.sh clean
./deploy-sage-os.sh build
```

### VNC Connection Issues

**Problem**: Can't connect to VNC
```bash
# Check if container is running
docker ps

# Check port binding
docker port sage-os-container

# Test VNC port
telnet localhost 5901
```

**Problem**: VNC password not working
- Default password is `sageos`
- Try connecting without password first
- Check container logs for VNC server status

### macOS Specific Issues

**Problem**: Screen Sharing won't connect
```bash
# Try alternative VNC clients
brew install tiger-vnc
vncviewer localhost:5901

# Or use browser
open vnc://localhost:5901
```

**Problem**: Performance issues on M1
- Use `aarch64` architecture for native ARM64
- Increase memory allocation: `-M 512M`
- Close other Docker containers

### QEMU Issues

**Problem**: No kernel file found
```bash
# Check available kernel files
find . -name "*.elf" -o -name "*.img"

# Build SAGE OS first
make ARCH=i386

# Specify kernel manually
./deploy-sage-os-local.sh run -k path/to/kernel.elf
```

## 📊 Performance Tips

### For macOS M1/M2:
1. Use `aarch64` architecture for native performance
2. Allocate sufficient memory: `-M 256M` or higher
3. Use VNC mode for best compatibility
4. Close unnecessary applications

### For Linux:
1. Use `x86_64` architecture on Intel/AMD systems
2. Graphics mode for direct display
3. Enable hardware acceleration if available

### For Windows:
1. Use VNC mode for best compatibility
2. Ensure WSL2 is enabled for Docker Desktop
3. Use `i386` or `x86_64` architecture

## 🔐 Security Notes

- VNC password is `sageos` (change in production)
- Containers run as non-root user `sage`
- QEMU monitor is bound to localhost only
- No external network access by default

## 📚 Additional Resources

- **Full Documentation**: `DOCKER_DEPLOYMENT.md`
- **Test Suite**: `test-deployment.sh`
- **SAGE OS Repository**: [GitHub](https://github.com/AshishYesale7/SAGE-OS)
- **Docker Hub**: [sage-os](https://hub.docker.com/r/ashishyesale/sage-os)

## 🆘 Getting Help

1. **Test your setup**: `./test-deployment.sh`
2. **Check logs**: `./deploy-sage-os.sh logs`
3. **Try local mode**: `./deploy-sage-os-local.sh test`
4. **Open an issue**: [GitHub Issues](https://github.com/AshishYesale7/SAGE-OS/issues)

---

**Happy SAGE OS Development! 🎉**