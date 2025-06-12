# SAGE OS Troubleshooting Guide for macOS M1 + UTM

## 🔍 **Problem Analysis**

### Issue Summary
When building SAGE OS for i386 architecture on macOS M1 using UTM with Kali Linux (ARM64), the build fails due to cross-compilation toolchain issues.

### Root Causes Identified

1. **Cross-Compilation Toolchain Missing**
   - ARM64 host trying to build i386 code
   - System gcc defaults to ARM64 assembly syntax
   - Missing i686-linux-gnu cross-compiler

2. **QEMU Graphics Mode Confusion**
   - User expects GUI window but uses `-nographic` flag
   - Missing proper graphics mode configuration

## 🛠️ **Solutions Implemented**

### 1. Fixed Makefile Cross-Compilation
**File**: `Makefile`
**Changes**:
- Added host architecture detection for i386 builds
- Automatically uses `i686-linux-gnu-gcc` on non-x86 hosts
- Uses dedicated `boot/boot_i386.S` for better compatibility

### 2. Created Cross-Compilation Setup Script
**File**: `scripts/setup-cross-compilation.sh`
**Purpose**: Automatically installs required cross-compilation toolchains
**Usage**: `./scripts/setup-cross-compilation.sh`

### 3. Enhanced Graphics Mode Testing
**File**: `scripts/testing/test-graphics-mode.sh`
**Purpose**: Launches SAGE OS in proper graphics mode with keyboard support
**Usage**: `./scripts/testing/test-graphics-mode.sh i386`

## 📋 **Step-by-Step Solution**

### Step 1: Setup Cross-Compilation Environment
```bash
# Run the setup script to install cross-compilers
./scripts/setup-cross-compilation.sh

# Or manually install (on Debian/Ubuntu):
sudo apt-get update
sudo apt-get install gcc-multilib g++-multilib
sudo apt-get install gcc-i686-linux-gnu g++-i686-linux-gnu
sudo apt-get install qemu-system-x86
```

### Step 2: Build SAGE OS for i386
```bash
# Clean previous builds
make clean

# Build for i386
make ARCH=i386 TARGET=generic

# Verify build
ls -la build/i386/kernel.elf
```

### Step 3: Test in Graphics Mode
```bash
# Launch in graphics mode with keyboard support
make test-i386-graphics

# Or use the script directly
./scripts/testing/test-graphics-mode.sh i386
```

## 🎯 **Expected Results**

### Successful Build Output
```
✅ Build completed successfully!
📁 Architecture: i386
🎯 Target: generic
📦 Version: 1.0.1
🔧 Build ID: sage-os-v1.0.1-i386-generic
📄 Kernel Image: output/i386/sage-os-v1.0.1-i386-generic.img
🔍 Debug ELF: output/i386/sage-os-v1.0.1-i386-generic.elf
```

### QEMU Graphics Mode
- QEMU window opens with VGA display
- SAGE OS boots and shows ASCII art logo
- Interactive shell with keyboard input
- Commands: `help`, `version`, `clear`, etc.

## 🔧 **Architecture-Specific Commands**

### For i386 (32-bit x86)
```bash
make ARCH=i386 TARGET=generic                    # Build
make test-i386                                   # Test (console)
make test-i386-graphics                          # Test (graphics)
./scripts/testing/test-graphics-mode.sh i386    # Enhanced graphics
```

### For x86_64 (64-bit x86)
```bash
make ARCH=x86_64 TARGET=generic                  # Build
make test-x86_64                                 # Test (console)
make test-x86_64-graphics                        # Test (graphics)
```

### For ARM64 (native on M1)
```bash
make ARCH=aarch64 TARGET=generic                 # Build
make test-aarch64                                # Test
```

## 🐛 **Common Issues and Fixes**

### Issue: "invalid instruction cli"
**Cause**: Wrong assembler being used
**Fix**: Install cross-compilation tools and rebuild

### Issue: "qemu: could not open kernel file"
**Cause**: Build failed, kernel.elf doesn't exist
**Fix**: Fix build errors first, then test

### Issue: QEMU doesn't show graphics
**Cause**: Using `-nographic` flag
**Fix**: Use graphics mode script or remove `-nographic`

### Issue: "command not found: i686-linux-gnu-gcc"
**Cause**: Cross-compiler not installed
**Fix**: Run `./scripts/setup-cross-compilation.sh`

## 📖 **Additional Resources**

### Build System Documentation
- `BUILD_README.md` - Comprehensive build guide
- `MACOS_GRAPHICS_GUIDE.md` - Graphics mode specifics
- `FINAL_MACOS_M1_SETUP_COMPLETE.md` - M1 setup guide

### Testing Scripts
- `scripts/testing/test-qemu.sh` - Legacy testing
- `scripts/testing/test-graphics-mode.sh` - Enhanced graphics
- `test-qemu.sh` - Root level testing script

### Make Targets
```bash
make help                    # Show all available targets
make list-arch              # Show supported architectures
make info                   # Show current build configuration
make clean                  # Clean build files
```

## 🚀 **Quick Start for M1 Users**

```bash
# 1. Setup environment
./scripts/setup-cross-compilation.sh

# 2. Build SAGE OS
make ARCH=i386 TARGET=generic

# 3. Test in graphics mode
make test-i386-graphics

# 4. Enjoy SAGE OS! 🎉
```

## 💡 **Pro Tips**

1. **Always clean before switching architectures**: `make clean`
2. **Use graphics mode for interactive testing**: `make test-i386-graphics`
3. **Check build logs for specific errors**: Look for compiler/linker messages
4. **Verify cross-compilers are installed**: `i686-linux-gnu-gcc --version`
5. **Use UTM with sufficient RAM**: Allocate at least 2GB for smooth operation