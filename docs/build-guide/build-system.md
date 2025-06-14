# Build System Guide

Complete guide to building SAGE-OS from source code across all supported architectures.

*Last updated: 2025-06-14*

## Quick Start

```bash
# Clone repository
git clone https://github.com/AshishYesale7/SAGE-OS.git
cd SAGE-OS

# Build for i386 (recommended)
make clean && make i386

# Run in QEMU
make run-i386
```

## Supported Architectures

| Architecture | Status | Command | Notes |
|-------------|--------|---------|-------|
| i386 | ✅ Stable | `make i386` | Primary target |
| AArch64 | ✅ Stable | `make aarch64` | Raspberry Pi 4/5 |
| RISC-V | ⚠️ Beta | `make riscv64` | Experimental |
| x86_64 | 🔄 WIP | `make x86_64` | In development |

## Build Requirements

### Linux/WSL
```bash
sudo apt update
sudo apt install build-essential gcc-multilib nasm qemu-system-x86 git cmake

# Cross-compilation tools
sudo apt install gcc-aarch64-linux-gnu gcc-riscv64-linux-gnu
```

### macOS
```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install gcc nasm qemu git cmake
brew install aarch64-elf-gcc riscv64-elf-gcc
```

### Windows
Use WSL2 with Ubuntu and follow Linux instructions.

## Advanced Build Options

```bash
# Debug build
make i386 DEBUG=1

# Graphics support
make i386-graphics

# Cross-compilation
make aarch64 CROSS_COMPILE=aarch64-linux-gnu-

# Parallel build
make -j$(nproc) i386

# Optimized build
make i386 OPTIMIZE=3
```

## Build Targets

### Standard Builds
```bash
make i386          # Standard i386 build
make aarch64       # ARM 64-bit build
make riscv64       # RISC-V 64-bit build
make x86_64        # x86_64 build (WIP)
```

### Specialized Builds
```bash
make i386-graphics    # i386 with VGA graphics
make aarch64-graphics # ARM64 with graphics
make i386-debug      # Debug symbols included
make aarch64-debug   # ARM64 debug build
make i386-release    # Optimized for performance
```

### Testing Builds
```bash
make test-i386       # Build and test i386
make test-aarch64    # Build and test ARM64
make test-all        # Test all architectures
```

## Build Configuration

### Makefile Variables
```bash
ARCH=i386              # Target architecture
DEBUG=1                # Enable debug build
GRAPHICS=1             # Enable graphics support
OPTIMIZE=2             # Optimization level (0-3)
CROSS_COMPILE=aarch64-linux-gnu-  # Toolchain prefix
VERBOSE=1              # Verbose build output
PARALLEL=4             # Parallel build jobs
```

### Environment Variables
```bash
export SAGE_OS_ARCH=i386
export SAGE_OS_DEBUG=1
export SAGE_OS_GRAPHICS=1
export CROSS_COMPILE=aarch64-linux-gnu-
```

## Build Output Structure

```
build-output/
├── i386/
│   ├── sage-os.bin          # Kernel binary
│   ├── sage-os.img          # Bootable image
│   ├── bootloader.bin       # Bootloader
│   └── symbols.map          # Debug symbols
├── aarch64/
│   ├── sage-os.bin
│   ├── sage-os.img
│   └── device-tree.dtb      # Device tree blob
├── riscv64/
│   ├── sage-os.bin
│   └── sage-os.img
└── logs/
    ├── build.log            # Build output
    ├── test.log             # Test results
    └── errors.log           # Error messages
```

## Testing Your Build

### QEMU Testing
```bash
# Basic test
make run-i386

# Graphics test
make run-graphics

# Network test
make run-network

# Debug mode
make run-debug
```

### Hardware Testing
```bash
# Create bootable image for Raspberry Pi
./create_bootable_image.sh

# Flash to SD card
sudo dd if=sage-os.img of=/dev/sdX bs=4M status=progress
```

## Troubleshooting

### Common Issues

1. **Missing dependencies**
   ```bash
   ./scripts/check-dependencies.sh
   ```

2. **Build failures**
   ```bash
   make clean && make i386
   ```

3. **QEMU issues**
   ```bash
   qemu-system-i386 --version
   ```

4. **Cross-compilation errors**
   ```bash
   # Verify toolchain
   aarch64-linux-gnu-gcc --version
   ```

### Debug Build Issues

#### Enable Verbose Output
```bash
make V=1 i386          # Verbose Makefile
make VERBOSE=1 i386    # Verbose compiler
```

#### Check Build Logs
```bash
cat build-output/logs/build.log
grep -i error build-output/logs/build.log
```

#### Validate Build Output
```bash
file sage-os.bin       # Check binary format
nm sage-os.bin | grep main  # Verify symbols
ls -lh sage-os.bin    # Check size
```

## Performance Optimization

### Parallel Builds
```bash
# Use all CPU cores
make -j$(nproc) i386

# Limit parallel jobs
make -j4 i386
```

### RAM Disk Builds
```bash
# Create RAM disk (Linux)
sudo mkdir /mnt/ramdisk
sudo mount -t tmpfs -o size=2G tmpfs /mnt/ramdisk
cp -r SAGE-OS /mnt/ramdisk/
cd /mnt/ramdisk/SAGE-OS
make i386
```

### Compiler Optimization
```bash
# Optimize for speed
make i386 OPTIMIZE=3

# Optimize for size
make i386 OPTIMIZE=s

# Debug build (no optimization)
make i386 DEBUG=1
```

## Build Time Benchmarks

| Architecture | Clean Build | Incremental | With Tests |
|-------------|-------------|-------------|------------|
| i386 | 2-3 minutes | 30 seconds | 5-7 minutes |
| AArch64 | 3-4 minutes | 45 seconds | 6-8 minutes |
| RISC-V | 4-5 minutes | 1 minute | 8-10 minutes |

## Docker Builds

### Basic Docker Build
```bash
# Build Docker image
docker build -t sage-os .

# Run in container
docker run -it --rm sage-os
```

### Multi-Architecture Docker
```bash
# Multi-platform build
docker buildx build --platform linux/amd64,linux/arm64 -t sage-os .
```

## Continuous Integration

### GitHub Actions
The project includes comprehensive CI/CD pipelines:

- **Build Kernel**: Tests all architectures
- **Multi-Arch Build**: Cross-compilation testing
- **QEMU Testing**: Automated boot testing
- **Documentation**: Auto-generated docs

### Local CI Simulation
```bash
# Run CI tests locally
./scripts/ci-build.sh

# Test specific architecture
./scripts/test-architecture.sh i386
```

## Custom Configurations

### Kernel Configuration
```bash
# Configure kernel features
make menuconfig

# Available options:
# - Memory management settings
# - Driver selection
# - AI subsystem configuration
# - Graphics options
# - Security features
```

### Bootloader Customization
```bash
# Build custom bootloader
make bootloader BOOTLOADER_CONFIG=custom

# Options:
# - Boot splash screen
# - Memory layout
# - Hardware detection
# - Security features
```

### Driver Selection
```bash
# Build with specific drivers
make i386 DRIVERS="vga,serial,keyboard,ai_hat"

# Available drivers:
# - vga: VGA graphics driver
# - serial: Serial communication
# - keyboard: PS/2 keyboard
# - ai_hat: AI HAT+ support
# - ethernet: Network support
```

## Platform-Specific Instructions

### Raspberry Pi 4/5
```bash
# Build for Raspberry Pi
make aarch64 RPI=1

# Create SD card image
./scripts/create-rpi-image.sh

# Boot configuration
# Add to config.txt:
# kernel=sage-os.bin
# arm_64bit=1
```

### QEMU Emulation
```bash
# i386 emulation
qemu-system-i386 -m 256M -kernel sage-os.bin

# ARM64 emulation
qemu-system-aarch64 -M virt -cpu cortex-a57 -m 256M -kernel sage-os.bin

# RISC-V emulation
qemu-system-riscv64 -M virt -m 256M -kernel sage-os.bin
```

### Real Hardware
```bash
# Create bootable USB
sudo dd if=sage-os.img of=/dev/sdX bs=4M status=progress

# Network boot setup
./scripts/setup-netboot.sh
```

## Next Steps

After successfully building SAGE-OS:

1. **Test Your Build**
   - [Testing Guide](../development/testing.md)
   - [QEMU Testing](../development/debugging.md)

2. **Customize the Build**
   - [Cross Compilation](cross-compilation.md)
   - [Platform Specific](platform-specific.md)

3. **Deploy to Hardware**
   - [Raspberry Pi Guide](../platforms/raspberry-pi/DEVELOPER_GUIDE.md)
   - [Hardware Testing](../development/testing.md)

4. **Contribute to Development**
   - [Development Setup](../development/setup.md)
   - [Contributing Guide](../development/contributing.md)

---

*Need help? Check our [Troubleshooting Guide](../troubleshooting/common-issues.md) or [report an issue](https://github.com/AshishYesale7/SAGE-OS/issues).*