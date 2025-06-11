# SAGE OS Docker Deployment Guide

This guide explains how to deploy and run SAGE OS with graphics and input support using Docker.

## 🚀 Quick Start

### Option 1: Interactive Quick Start (Recommended)
```bash
./quick-start.sh
```

### Option 2: Direct VNC Deployment
```bash
./deploy-sage-os.sh deploy -d vnc -a i386 -p 5901
```

### Option 3: Graphics Mode (Linux/Windows)
```bash
./deploy-sage-os.sh deploy -d graphics -a i386
```

## 📋 Prerequisites

- **Docker**: Ensure Docker is installed and running
- **VNC Client** (for VNC mode): 
  - macOS: Built-in Screen Sharing
  - Windows: TigerVNC, RealVNC
  - Linux: Remmina, TigerVNC

## 🛠️ Available Scripts

### 1. `deploy-sage-os.sh` - Main Deployment Script

**Full Command Syntax:**
```bash
./deploy-sage-os.sh [COMMAND] [OPTIONS]
```

**Commands:**
- `build` - Build SAGE OS Docker image only
- `run` - Run existing Docker image
- `deploy` - Build and run (default)
- `clean` - Clean up containers and images
- `logs` - Show container logs
- `shell` - Open shell in running container
- `stop` - Stop running container

**Options:**
- `-a, --arch ARCH` - Target architecture (i386, x86_64, aarch64, arm, riscv64)
- `-d, --display MODE` - Display type (vnc, graphics, text)
- `-M, --memory SIZE` - Memory allocation (default: 128M)
- `-p, --vnc-port PORT` - VNC port (default: 5901)
- `-q, --qemu-port PORT` - QEMU monitor port (default: 1234)
- `-v, --verbose` - Enable verbose output
- `-h, --help` - Show help

### 2. `quick-start.sh` - Interactive Setup

Simple interactive script that guides you through the deployment process.

## 🖥️ Display Modes

### VNC Mode (Recommended for macOS)
```bash
./deploy-sage-os.sh deploy -d vnc -p 5901
```
- **Access**: Connect VNC client to `localhost:5901`
- **Password**: `sageos`
- **Benefits**: Works on all platforms, remote access capability

### Graphics Mode (Direct QEMU Window)
```bash
./deploy-sage-os.sh deploy -d graphics
```
- **Access**: Direct QEMU window opens
- **Benefits**: Native performance, direct interaction
- **Note**: May require X11 forwarding on macOS

### Text Mode (Terminal Only)
```bash
./deploy-sage-os.sh deploy -d text
```
- **Access**: Terminal output only
- **Benefits**: Lightweight, good for debugging
- **Note**: Limited interaction capabilities

## 🏗️ Architecture Support

| Architecture | Status | QEMU System | Notes |
|-------------|--------|-------------|-------|
| i386 | ✅ Supported | qemu-system-i386 | Default, best compatibility |
| x86_64 | ✅ Supported | qemu-system-i386 | 64-bit x86 |
| aarch64 | ✅ Supported | qemu-system-aarch64 | ARM 64-bit |
| arm | ✅ Supported | qemu-system-arm | ARM 32-bit |
| riscv64 | ✅ Supported | qemu-system-riscv64 | RISC-V 64-bit |

## 📱 Connection Examples

### macOS with Built-in Screen Sharing
```bash
# Start SAGE OS
./deploy-sage-os.sh deploy -d vnc -p 5901

# Connect via Finder
# Go to: Go > Connect to Server > vnc://localhost:5901
# Password: sageos
```

### Linux with Remmina
```bash
# Start SAGE OS
./deploy-sage-os.sh deploy -d vnc -p 5901

# Connect with Remmina
remmina vnc://localhost:5901
```

### Windows with TigerVNC
```bash
# Start SAGE OS
./deploy-sage-os.sh deploy -d vnc -p 5901

# Open TigerVNC Viewer
# Server: localhost:5901
# Password: sageos
```

## 🔧 Advanced Usage

### Custom Architecture and Memory
```bash
./deploy-sage-os.sh deploy -a aarch64 -M 256M -d vnc -p 5902
```

### Multiple Instances
```bash
# Instance 1 (i386)
./deploy-sage-os.sh deploy -a i386 -p 5901

# Instance 2 (x86_64) - in another terminal
./deploy-sage-os.sh deploy -a x86_64 -p 5902
```

### Development Mode with Shell Access
```bash
# Start container
./deploy-sage-os.sh deploy -d vnc

# Open shell in another terminal
./deploy-sage-os.sh shell

# View logs
./deploy-sage-os.sh logs
```

## 🐛 Debugging

### QEMU Monitor Access
```bash
# Connect to QEMU monitor
telnet localhost 1234

# Useful QEMU monitor commands:
# info registers    - Show CPU registers
# info memory       - Show memory mapping
# system_reset      - Reset the system
# quit              - Exit QEMU
```

### Container Debugging
```bash
# View container logs
./deploy-sage-os.sh logs

# Open shell in container
./deploy-sage-os.sh shell

# Check running processes
docker exec sage-os-runtime ps aux

# Check QEMU process
docker exec sage-os-runtime pgrep -f qemu
```

### Common Issues and Solutions

#### 1. VNC Connection Refused
```bash
# Check if container is running
docker ps | grep sage-os-runtime

# Check VNC server status
./deploy-sage-os.sh shell
ps aux | grep vnc
```

#### 2. QEMU Fails to Start
```bash
# Check kernel file exists
./deploy-sage-os.sh shell
ls -la /home/sage/sage-os/output/*/
```

#### 3. Graphics Mode Hangs
```bash
# Try VNC mode instead
./deploy-sage-os.sh stop
./deploy-sage-os.sh deploy -d vnc
```

## 🧹 Cleanup

### Stop and Remove Container
```bash
./deploy-sage-os.sh stop
```

### Complete Cleanup
```bash
./deploy-sage-os.sh clean
```

### Manual Cleanup
```bash
# Stop all SAGE OS containers
docker stop $(docker ps -q -f name=sage-os)

# Remove all SAGE OS containers
docker rm $(docker ps -aq -f name=sage-os)

# Remove SAGE OS images
docker rmi sage-os:latest
```

## 📊 Performance Tips

### Memory Allocation
- **Minimum**: 64M (basic functionality)
- **Recommended**: 128M (default)
- **Development**: 256M+ (better performance)

### Architecture Selection
- **i386**: Best compatibility, slower performance
- **x86_64**: Better performance on 64-bit hosts
- **aarch64**: Native performance on ARM Macs

### Display Mode Selection
- **VNC**: Best for remote access and macOS
- **Graphics**: Best performance for local use
- **Text**: Fastest, debugging only

## 🔐 Security Notes

- Default VNC password is `sageos` - change for production use
- Container runs as non-root user `sage`
- QEMU monitor is exposed on localhost only
- No persistent storage by default

## 📝 Examples

### Example 1: Development Setup
```bash
# High memory, VNC access, ARM64
./deploy-sage-os.sh deploy -a aarch64 -M 512M -d vnc -p 5901
```

### Example 2: Testing Multiple Architectures
```bash
# Terminal 1: i386
./deploy-sage-os.sh deploy -a i386 -p 5901

# Terminal 2: ARM64
./deploy-sage-os.sh deploy -a aarch64 -p 5902

# Terminal 3: RISC-V
./deploy-sage-os.sh deploy -a riscv64 -p 5903
```

### Example 3: Continuous Integration
```bash
# Build only
./deploy-sage-os.sh build -a i386

# Run tests in text mode
./deploy-sage-os.sh run -d text -a i386

# Cleanup
./deploy-sage-os.sh clean
```

## 🆘 Support

If you encounter issues:

1. Check the logs: `./deploy-sage-os.sh logs`
2. Try different display mode: `-d vnc` or `-d text`
3. Verify Docker is running: `docker info`
4. Clean and rebuild: `./deploy-sage-os.sh clean && ./deploy-sage-os.sh build`

For more help, run: `./deploy-sage-os.sh --help`