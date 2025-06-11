<!--
─────────────────────────────────────────────────────────────────────────────
SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
SPDX-License-Identifier: BSD-3-Clause OR Proprietary
SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.

This file is part of the SAGE OS Project.
─────────────────────────────────────────────────────────────────────────────
-->
# SAGE OS Multi-Architecture Build System

This document describes the comprehensive multi-architecture build system for SAGE OS, designed to work seamlessly on macOS, Linux, and through Docker containers.

## Overview

The SAGE OS build system supports:

- **Multiple Architectures**: aarch64 (ARM64), x86_64, riscv64, arm (ARM32)
- **Multiple Platforms**: Raspberry Pi 3/4/5, x86_64, generic platforms
- **Multiple Image Formats**: Kernel images, ISO images, SD card images, Docker images
- **Cross-Platform Development**: Native builds on macOS and Linux, Docker-based builds for consistency
- **Automated CI/CD**: GitHub Actions workflows for automated testing and releases

## Quick Start

### Prerequisites

#### macOS
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
./build.sh install-deps
```

#### Linux (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install -y gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-riscv64-linux-gnu \
                        qemu-system-arm qemu-system-x86 qemu-system-misc \
                        genisoimage dosfstools make

# Note: The build script can also install dependencies automatically
./tools/build/build.sh install-deps
```

### Basic Usage

```bash
# Build for Raspberry Pi 4 (ARM64)
./build.sh build aarch64 rpi4

# Build for all architectures
./build.sh build-all

# Build all image formats for ARM64
./build.sh build-formats aarch64

# Test the build
./build.sh test aarch64 rpi4

# Check build status
./build.sh status
```

## Build System Components

### 1. Enhanced Makefile (`Makefile.multi-arch`)

The core build system with support for:
- Cross-compilation for multiple architectures
- Platform-specific optimizations
- Multiple output formats
- Dependency checking
- Automated testing

#### Key Targets

```bash
# Build kernel image
make -f Makefile.multi-arch kernel ARCH=aarch64 PLATFORM=rpi5

# Build ISO image
make -f Makefile.multi-arch iso ARCH=x86_64

# Build SD card image
make -f Makefile.multi-arch sdcard ARCH=aarch64 PLATFORM=rpi4

# Build for all architectures
make -f Makefile.multi-arch all-arch

# Run in QEMU
make -f Makefile.multi-arch qemu ARCH=aarch64 PLATFORM=rpi4

# Debug with GDB
make -f Makefile.multi-arch debug ARCH=aarch64 PLATFORM=rpi4
```

### 2. Build Script (`build.sh`)

High-level build automation script with:
- Dependency installation and checking
- Cross-platform compatibility
- Colored output and logging
- Error handling and recovery
- Build status reporting

#### Commands

```bash
./build.sh install-deps              # Install build dependencies
./build.sh check-deps               # Check build dependencies
./build.sh build [arch] [platform]  # Build for specific architecture
./build.sh build-all [platform]     # Build for all architectures
./build.sh build-formats [arch]     # Build all formats for architecture
./build.sh test [arch] [platform]   # Run tests
./build.sh clean                    # Clean build files
./build.sh status                   # Show build status
```

### 3. Docker Build System (`docker-build.sh`)

Container-based builds for consistency across platforms:
- Isolated build environments
- No local toolchain installation required
- Reproducible builds
- Multi-architecture Docker images

#### Commands

```bash
./docker-build.sh build aarch64 rpi5        # Build using Docker
./docker-build.sh build-all rpi4            # Build all archs with Docker
./docker-build.sh test aarch64 rpi4         # Test Docker build
./docker-build.sh multiarch                 # Create multi-arch Docker images
./docker-build.sh clean                     # Clean Docker resources
```

### 4. GitHub Actions Workflow

Automated CI/CD pipeline with:
- Matrix builds for all architecture/platform combinations
- Artifact generation and storage
- Docker image publishing
- Automated releases
- Build status reporting

## Supported Configurations

### Architectures

| Architecture | Description | Toolchain | QEMU Support |
|--------------|-------------|-----------|--------------|
| `aarch64` | ARM64 (64-bit ARM) | `aarch64-linux-gnu-` | ✅ |
| `x86_64` | Intel/AMD 64-bit | `x86_64-linux-gnu-` | ✅ |
| `riscv64` | RISC-V 64-bit | `riscv64-linux-gnu-` | ✅ |
| `arm` | ARM32 (32-bit ARM) | `arm-linux-gnueabihf-` | ✅ |

### Platforms

| Platform | Architecture | Description | Config File |
|----------|--------------|-------------|-------------|
| `rpi3` | aarch64, arm | Raspberry Pi 3 | `config.txt` |
| `rpi4` | aarch64 | Raspberry Pi 4 | `config.txt` |
| `rpi5` | aarch64 | Raspberry Pi 5 | `config_rpi5.txt` |
| `x86_64` | x86_64 | Generic x86_64 | N/A |
| `generic` | any | Generic platform | N/A |

### Image Formats

| Format | Extension | Description | Use Case |
|--------|-----------|-------------|----------|
| `kernel` | `.img` | Raw kernel binary | Direct boot, SD card |
| `iso` | `.iso` | ISO 9660 image | CD/DVD, USB boot |
| `sdcard` | `-sdcard.img` | Complete SD card image | Raspberry Pi |
| `docker` | N/A | Docker container | Containerized deployment |

## Build Options

### Environment Variables

```bash
# Architecture and platform
export ARCH=aarch64
export PLATFORM=rpi5

# Feature flags
export ENABLE_AI=ON          # Enable AI subsystem
export ENABLE_CRYPTO=ON      # Enable cryptographic support
export ENABLE_DEBUG=ON       # Enable debug build
export MEMORY_SIZE=1024      # Set memory size in MB

# Build with options
./build.sh build aarch64 rpi5
```

### Makefile Variables

```bash
# Build with specific options
make -f Makefile.multi-arch kernel \
    ARCH=aarch64 \
    PLATFORM=rpi5 \
    ENABLE_AI=ON \
    ENABLE_DEBUG=ON \
    MEMORY_SIZE=2048
```

## Advanced Usage

### Custom Toolchain Paths

```bash
# Override toolchain paths
export TOOLCHAIN_PATH=/opt/cross-tools/bin
make -f Makefile.multi-arch kernel ARCH=aarch64
```

### Cross-Compilation on macOS

The build system automatically detects macOS and uses Homebrew-installed toolchains:

```bash
# Install cross-compilation toolchains
brew tap messense/macos-cross-toolchains
brew install aarch64-unknown-linux-gnu
brew install x86_64-unknown-linux-gnu
brew install riscv64-unknown-linux-gnu
brew install arm-unknown-linux-gnueabihf
```

### Docker Multi-Architecture Images

```bash
# Create multi-arch Docker images
./docker-build.sh multiarch

# Run SAGE OS in Docker
docker run --rm -it sage-os:latest
```

## Testing and Debugging

### QEMU Testing

```bash
# Test with QEMU
./build.sh test aarch64 rpi4

# Debug with GDB
make -f Makefile.multi-arch debug ARCH=aarch64 PLATFORM=rpi4

# In another terminal, connect with GDB
aarch64-linux-gnu-gdb build/aarch64/kernel.elf -ex 'target remote localhost:1234'
```

### Hardware Testing

#### Raspberry Pi

1. Build SD card image:
   ```bash
   ./build.sh build aarch64 rpi5
   make -f Makefile.multi-arch sdcard ARCH=aarch64 PLATFORM=rpi5
   ```

2. Flash to SD card:
   ```bash
   # macOS
   diskutil list
   diskutil unmountDisk /dev/diskN
   sudo dd if=dist/aarch64/SAGE-OS-0.1.0-aarch64-rpi5-sdcard.img of=/dev/rdiskN bs=1m
   
   # Linux
   sudo dd if=dist/aarch64/SAGE-OS-0.1.0-aarch64-rpi5-sdcard.img of=/dev/sdX bs=1M
   ```

#### x86_64 Systems

1. Build ISO image:
   ```bash
   ./build.sh build x86_64 x86_64
   make -f Makefile.multi-arch iso ARCH=x86_64
   ```

2. Create bootable USB:
   ```bash
   # macOS
   sudo dd if=dist/x86_64/SAGE-OS-0.1.0-x86_64-x86_64.iso of=/dev/rdiskN bs=1m
   
   # Linux
   sudo dd if=dist/x86_64/SAGE-OS-0.1.0-x86_64-x86_64.iso of=/dev/sdX bs=1M
   ```

## Troubleshooting

### Common Issues

#### Missing Cross-Compiler

**Error**: `aarch64-linux-gnu-gcc: command not found`

**Solution**:
```bash
# macOS
./build.sh install-deps

# Linux
sudo apt-get install gcc-aarch64-linux-gnu
```

#### QEMU Not Found

**Error**: `qemu-system-aarch64: command not found`

**Solution**:
```bash
# macOS
brew install qemu

# Linux
sudo apt-get install qemu-system-arm
```

#### Docker Permission Denied

**Error**: `permission denied while trying to connect to the Docker daemon`

**Solution**:
```bash
# Add user to docker group
sudo usermod -aG docker $USER
# Log out and log back in
```

#### Build Fails on macOS

**Issue**: Cross-compilation toolchain not found

**Solution**:
```bash
# Ensure Homebrew is properly configured
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Reinstall toolchains
./build.sh install-deps
```

### Debug Build Issues

1. **Enable verbose output**:
   ```bash
   make -f Makefile.multi-arch kernel ARCH=aarch64 PLATFORM=rpi4 V=1
   ```

2. **Check build configuration**:
   ```bash
   make -f Makefile.multi-arch info ARCH=aarch64 PLATFORM=rpi4
   ```

3. **Clean and rebuild**:
   ```bash
   ./build.sh clean
   ./build.sh build aarch64 rpi4
   ```

## Performance Optimization

### Parallel Builds

```bash
# Use multiple CPU cores
make -f Makefile.multi-arch -j$(nproc) kernel ARCH=aarch64
```

### Build Caching

The build system supports caching for faster rebuilds:

```bash
# Enable ccache (if available)
export CC="ccache aarch64-linux-gnu-gcc"
make -f Makefile.multi-arch kernel ARCH=aarch64
```

### Docker Build Optimization

```bash
# Use BuildKit for faster Docker builds
export DOCKER_BUILDKIT=1
./docker-build.sh build aarch64 rpi5
```

## Integration with IDEs

### Visual Studio Code

Create `.vscode/tasks.json`:

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Build SAGE OS (ARM64)",
            "type": "shell",
            "command": "./build.sh",
            "args": ["build", "aarch64", "rpi4"],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        },
        {
            "label": "Test SAGE OS (ARM64)",
            "type": "shell",
            "command": "./build.sh",
            "args": ["test", "aarch64", "rpi4"],
            "group": "test"
        }
    ]
}
```

### CLion/IntelliJ

Configure CMake toolchain for cross-compilation in Settings → Build → Toolchains.

## Contributing

When contributing to the build system:

1. **Test all architectures**: Ensure changes work across all supported architectures
2. **Update documentation**: Keep this document updated with any changes
3. **Maintain compatibility**: Ensure changes work on both macOS and Linux
4. **Add tests**: Include appropriate tests for new features

## Troubleshooting

### Recent Fixes (June 2025)

The following issues have been resolved in the latest version:

#### Serial Function Redefinition Conflicts
**Problem**: Multiple definitions of `serial_putc` and `serial_puts` functions causing linker errors.

**Solution**: 
- Moved serial function implementations from `kernel/kernel.c` to `drivers/serial.c`
- Added architecture-specific implementations for x86_64, aarch64, RISC-V, and ARM
- Updated `kernel/kernel.c` to use forward declarations only

#### Kernel Main Function Conflicts
**Problem**: Both `kernel.c` and `kernel_graphics.c` defined `kernel_main` function.

**Solution**: 
- Modified `tools/build/Makefile.multi-arch` to exclude `kernel_graphics.c` from normal builds
- Added `KERNEL_SOURCES_FILTERED` variable to filter out conflicting files

#### Missing Cross-Compiler Dependencies
**Problem**: Build failing due to missing cross-compilation toolchains.

**Solution**: 
- Added automatic installation of required cross-compilers:
  - `gcc-aarch64-linux-gnu` for ARM64
  - `gcc-arm-linux-gnueabihf` for ARM32
  - `gcc-riscv64-linux-gnu` for RISC-V 64-bit
- Updated dependency check scripts

### Build Status Verification

All architectures now build successfully:

```bash
# Verify all builds work
./tools/build/build.sh build-all generic

# Expected output: 8/8 successful builds
# - aarch64 (ARM64): RPi 3/4/5 and generic
# - arm (ARM32): RPi 3/4/5 and generic  
# - x86_64: generic
# - riscv64: generic
```

### Common Issues

#### Missing Dependencies
```bash
# Error: "No such file or directory: aarch64-linux-gnu-gcc"
# Solution: Install cross-compilers
sudo apt-get install gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-riscv64-linux-gnu
```

#### Permission Errors
```bash
# Error: Permission denied when writing to build-output/
# Solution: Check directory permissions
chmod 755 build-output/
```

#### QEMU Not Found Warnings
```bash
# Warning: "QEMU for aarch64 not found"
# Solution: Install QEMU (optional for building, required for testing)
sudo apt-get install qemu-system-arm qemu-system-x86 qemu-system-misc
```

## Future Enhancements

Planned improvements to the build system:

- [ ] Support for additional architectures (ARM64 variants, RISC-V 32-bit)
- [ ] Integration with package managers (Homebrew, APT)
- [ ] Automated performance benchmarking
- [ ] Support for custom bootloaders
- [ ] Integration with hardware-in-the-loop testing
- [ ] Cloud-based build acceleration

## References

- [Cross-compilation Guide](https://www.kernel.org/doc/Documentation/kbuild/kconfig-language.txt)
- [QEMU Documentation](https://www.qemu.org/docs/master/)
- [Docker Multi-platform Builds](https://docs.docker.com/build/building/multi-platform/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Raspberry Pi Documentation](https://www.raspberrypi.org/documentation/)

---

For questions or issues with the build system, please open an issue in the repository or consult the troubleshooting section above.