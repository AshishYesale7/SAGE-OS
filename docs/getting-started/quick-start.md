# Quick Start Guide

Get SAGE-OS running in just 5 minutes! This guide will help you build and run SAGE-OS quickly.

## 🚀 5-Minute Setup

### Step 1: Clone and Enter Directory
```bash
git clone https://github.com/AshishYesale7/SAGE-OS.git
cd SAGE-OS
```

### Step 2: Quick Build
```bash
# One-command build for i386 (most compatible)
make clean && make i386

# Alternative: Use the automated build script
./build.sh
```

### Step 3: Run in QEMU
```bash
# Start SAGE-OS
make run-i386

# Or with VGA graphics
make run-graphics
```

## 🎯 What You'll See

When SAGE-OS boots successfully, you'll see:

1. **Boot Sequence**
   ```
   SAGE-OS Bootloader v1.0
   Loading kernel...
   Initializing system...
   ```

2. **ASCII Art Logo**
   ```
   ███████╗ █████╗  ██████╗ ███████╗      ██████╗ ███████╗
   ██╔════╝██╔══██╗██╔════╝ ██╔════╝     ██╔═══██╗██╔════╝
   ███████╗███████║██║  ███╗█████╗       ██║   ██║███████╗
   ╚════██║██╔══██║██║   ██║██╔══╝       ██║   ██║╚════██║
   ███████║██║  ██║╚██████╔╝███████╗     ╚██████╔╝███████║
   ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝      ╚═════╝ ╚══════╝
   ```

3. **Interactive Shell**
   ```
   SAGE-OS> help
   Available commands:
   - help: Show this help message
   - clear: Clear the screen
   - info: Show system information
   - ai: AI assistant commands
   - graphics: Switch to graphics mode
   ```

## 🔧 Quick Commands to Try

Once SAGE-OS is running, try these commands:

```bash
# Show system information
SAGE-OS> info

# Clear the screen
SAGE-OS> clear

# Get help
SAGE-OS> help

# Try AI features (if configured)
SAGE-OS> ai status

# Switch to graphics mode
SAGE-OS> graphics
```

## 🏗️ Architecture-Specific Builds

### i386 (Recommended for beginners)
```bash
make clean && make i386
make run-i386
```

### AArch64 (ARM 64-bit)
```bash
make clean && make aarch64
make run-aarch64
```

### RISC-V
```bash
make clean && make riscv64
make run-riscv64
```

## 🖥️ Display Modes

### Serial Console (Default)
- Text-based interface
- Works in all environments
- Best for development

### VGA Graphics Mode
```bash
# Build with graphics support
make clean && make i386-graphics

# Run with VGA output
make run-graphics
```

## 🐳 Docker Quick Start

If you prefer using Docker:

```bash
# Build Docker image
docker build -t sage-os .

# Run SAGE-OS in container
docker run -it --rm sage-os
```

## 🍓 Raspberry Pi Quick Start

For Raspberry Pi 4/5:

```bash
# Build for ARM64
make clean && make aarch64

# Create bootable image
./create_bootable_image.sh

# Flash to SD card (replace /dev/sdX with your SD card)
sudo dd if=sage-os.img of=/dev/sdX bs=4M status=progress
```

## ⚡ Performance Tips

1. **Use RAM Disk for Faster Builds**
   ```bash
   # Create RAM disk (Linux)
   sudo mkdir /mnt/ramdisk
   sudo mount -t tmpfs -o size=1G tmpfs /mnt/ramdisk
   cp -r SAGE-OS /mnt/ramdisk/
   cd /mnt/ramdisk/SAGE-OS
   ```

2. **Parallel Builds**
   ```bash
   # Use all CPU cores
   make -j$(nproc) i386
   ```

3. **Optimized QEMU Settings**
   ```bash
   # Run with more memory and CPU cores
   qemu-system-i386 -m 256M -smp 2 -kernel sage-os.bin
   ```

## 🔍 Verification

To verify your build is working correctly:

1. **Check Build Output**
   ```bash
   ls -la *.bin *.img
   # Should show sage-os.bin and other build artifacts
   ```

2. **Test Boot Sequence**
   - SAGE-OS logo appears
   - No kernel panics or errors
   - Interactive shell responds to commands

3. **Test Basic Functionality**
   ```bash
   SAGE-OS> info
   # Should display system information
   
   SAGE-OS> help
   # Should list available commands
   ```

## 🚨 Common Issues

### Build Fails
```bash
# Clean and retry
make clean
make i386

# Check dependencies
./scripts/check-dependencies.sh
```

### QEMU Won't Start
```bash
# Check QEMU installation
qemu-system-i386 --version

# Try with different options
qemu-system-i386 -nographic -kernel sage-os.bin
```

### No Output in QEMU
```bash
# Use serial console
qemu-system-i386 -nographic -serial stdio -kernel sage-os.bin
```

## 📚 Next Steps

Now that you have SAGE-OS running:

1. **Explore Features**
   - [Architecture Overview](../architecture/overview.md)
   - [API Reference](../api/kernel.md)
   - [Development Guide](../development/setup.md)

2. **Customize Your Build**
   - [Build Guide](../build-guide/overview.md)
   - [Cross Compilation](../build-guide/cross-compilation.md)

3. **Deploy to Hardware**
   - [Raspberry Pi Guide](../platforms/raspberry-pi/DEVELOPER_GUIDE.md)
   - [Hardware Deployment](../development/testing.md)

## 🎉 Success!

Congratulations! You now have SAGE-OS running. The system is ready for development, testing, and exploration.

---

*Having issues? Check our [Troubleshooting Guide](../troubleshooting/common-issues.md) or [report a bug](https://github.com/AshishYesale7/SAGE-OS/issues).*