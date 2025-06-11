# SAGE-OS macOS Developer Guide (Updated 2025-06-11)

This guide provides comprehensive instructions for developing SAGE-OS on macOS systems with the latest updates including VGA Graphics Mode support and organized project structure.

## 🚀 Quick Start

### Automated Setup
```bash
# Clone the repository
git clone https://github.com/Asadzero/SAGE-OS.git
cd SAGE-OS

# Run automated macOS setup
make -f tools/build/Makefile.macos macos-setup

# Test both modes
make test-i386                # Serial console mode
make test-i386-graphics       # VGA graphics mode (NEW!)
```

## 📋 Prerequisites

### System Requirements
- macOS 10.15 (Catalina) or later
- Xcode Command Line Tools
- Homebrew package manager
- At least 4GB of free disk space

### Installing Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## 🛠️ Installation

### 1. Development Tools
```bash
# Install Xcode Command Line Tools
xcode-select --install

# Install GNU tools (required for compatibility)
brew install gnu-sed grep findutils gnu-tar

# Install cross-compilation toolchain
brew install i386-elf-gcc x86_64-elf-gcc aarch64-elf-gcc

# Install QEMU for testing
brew install qemu
```

### 2. Additional Dependencies
```bash
# Install build tools
brew install make cmake ninja

# Install documentation tools
brew install mkdocs

# Install development utilities
brew install git-lfs tree htop

# Install VNC viewer for graphics mode
brew install --cask vnc-viewer
```

## 🏗️ Building SAGE-OS

### Environment Check
```bash
make -f tools/build/Makefile.macos macos-check
```

### Build Commands

#### Serial Console Mode (Default)
```bash
# Build for i386 (recommended)
make ARCH=i386 TARGET=generic

# Build for x86_64
make ARCH=x86_64 TARGET=generic

# Build for ARM64 (experimental)
make ARCH=aarch64 TARGET=generic
```

#### VGA Graphics Mode (New!)
```bash
# Build graphics kernel
./scripts/build/build-graphics.sh i386 generic

# Or use Makefile target
make build-graphics ARCH=i386 TARGET=generic
```

### Organized Project Structure
The project is now properly organized:
```
SAGE-OS/
├── tools/
│   ├── build/           # Build tools and Makefiles
│   ├── testing/         # Testing utilities
│   └── development/     # Development tools
├── scripts/
│   ├── build/           # Build scripts (build-graphics.sh)
│   ├── testing/         # Test scripts (test-qemu.sh)
│   └── deployment/      # Deployment scripts
├── config/
│   ├── platforms/       # Platform configs (config.txt, config_rpi5.txt)
│   └── grub.cfg         # Boot configuration
├── prototype/           # Restored prototype code
├── examples/            # Example code and demos
├── kernel/
│   ├── kernel.c         # Serial mode kernel
│   └── kernel_graphics.c # Graphics mode kernel (NEW!)
└── drivers/
    └── vga.c            # VGA text mode driver (ENHANCED!)
```

## 🧪 Testing

### Serial Console Mode
```bash
# Test i386 build
make test-i386

# Test with custom parameters
./scripts/testing/test-qemu.sh i386 generic nographic
```

### VGA Graphics Mode (New!)
```bash
# Test graphics mode with VNC
make test-i386-graphics

# Manual QEMU launch with VNC
qemu-system-i386 \
  -kernel output/i386/sage-os-v1.0.1-i386-generic-graphics.img \
  -vnc :1

# Connect with VNC viewer
open vnc://localhost:5901
```

### Auto-Detection Features
The testing system now automatically detects kernel images in multiple locations:
- `output/` directory (default)
- `build-output/` directory
- `build/` directory
- Various naming conventions

## 🖥️ Graphics Mode Features

### VGA Text Mode
- **Resolution**: 80x25 characters
- **Colors**: 16 foreground, 8 background colors
- **Real-time keyboard input** via PS/2 controller
- **Color-coded interface** with visual feedback

### Interactive Shell
- **Color-coded prompts**: Green prompt, white input
- **Command highlighting**: Different colors for different types
- **Backspace support**: Visual character deletion
- **Enhanced commands**: help, version, clear, colors, demo, reboot

### Testing Options
```bash
# VNC mode (recommended for headless)
./scripts/testing/test-qemu.sh i386 generic graphics

# Direct display (local only)
qemu-system-i386 -kernel output/i386/sage-os-v1.0.1-i386-generic-graphics.img

# Debug mode (serial + graphics)
qemu-system-i386 \
  -kernel output/i386/sage-os-v1.0.1-i386-generic-graphics.img \
  -serial stdio \
  -vnc :1
```

## 🍎 macOS-Specific Considerations

### Apple Silicon vs Intel
```bash
# Check your architecture
uname -m  # arm64 for Apple Silicon, x86_64 for Intel

# Cross-compile for x86 on Apple Silicon
make ARCH=i386 TARGET=generic CC=i386-elf-gcc
```

### GNU vs BSD Tools
macOS ships with BSD tools, but SAGE-OS requires GNU versions:
```bash
# Verify GNU tools installation
which gsed   # Should be /opt/homebrew/bin/gsed
which ggrep  # Should be /opt/homebrew/bin/ggrep
which gfind  # Should be /opt/homebrew/bin/gfind
```

### File System Considerations
- macOS uses case-insensitive file system by default
- Be aware of cross-platform compatibility issues
- Git case sensitivity may cause conflicts

## 🔧 Development Workflow

### Recommended IDE Setup
1. **Visual Studio Code**
   ```bash
   brew install --cask visual-studio-code
   ```
   
   Extensions:
   - C/C++ Extension Pack
   - Assembly (MASM)
   - GitLens
   - Makefile Tools

2. **Xcode** (for debugging)
   ```bash
   xcode-select --install
   ```

### Build Optimization
```bash
# Parallel builds
make -j$(sysctl -n hw.ncpu) ARCH=i386 TARGET=generic

# Debug builds
make ARCH=i386 TARGET=generic DEBUG=1

# Release builds
make ARCH=i386 TARGET=generic RELEASE=1
```

## 🐛 Troubleshooting

### Common Issues

#### GNU Tools Missing
```bash
# Error: gsed: command not found
brew install gnu-sed grep findutils gnu-tar
```

#### Cross-Compiler Missing
```bash
# Error: i386-elf-gcc: command not found
brew install i386-elf-gcc
# Or use system clang:
make ARCH=i386 TARGET=generic CC=clang
```

#### QEMU Issues
```bash
# QEMU not found
brew install qemu

# Graphics not working
# Use VNC mode instead:
./scripts/testing/test-qemu.sh i386 generic graphics
```

#### Permission Errors
```bash
# Fix script permissions
chmod +x scripts/testing/test-qemu.sh
chmod +x scripts/build/build-graphics.sh
chmod +x tools/organize_project.py
```

### Performance Optimization

#### Faster Builds
```bash
# Use ccache
brew install ccache
export CC="ccache gcc"

# Parallel compilation
make -j$(sysctl -n hw.ncpu)
```

#### QEMU Performance
```bash
# Hardware acceleration (if available)
qemu-system-i386 -accel hvf -kernel kernel.img

# More memory
qemu-system-i386 -m 512M -kernel kernel.img
```

## 🚀 Advanced Features

### UTM Integration
```bash
# Install UTM for GUI virtualization
brew install --cask utm
# See docs/UTM_MACOS_SETUP_GUIDE.md
```

### Docker Development
```bash
# Build in container
docker build -t sage-os-build .
docker run -v $(pwd):/workspace sage-os-build make ARCH=i386
```

### Continuous Integration
GitHub Actions workflow supports macOS builds automatically.

## 📚 Documentation

### Updated Guides
- [Graphics Mode Guide](../../../GRAPHICS_MODE_GUIDE.md) - **New!**
- [Build System Guide](../../build/BUILD_SYSTEM.md)
- [UTM Setup Guide](../../UTM_MACOS_SETUP_GUIDE.md)
- [Project Structure](../../../PROJECT_STRUCTURE.md)

### Key Files
- `tools/build/Makefile.macos` - macOS-specific Makefile
- `scripts/testing/test-qemu.sh` - Enhanced testing script
- `scripts/build/build-graphics.sh` - Graphics mode builder
- `config/platforms/` - Platform configurations

## 🤝 Contributing

### Development Guidelines
1. Follow coding standards in `CONTRIBUTING.md`
2. Test both serial and graphics modes
3. Update documentation for macOS-specific changes
4. Use organized project structure

### Submitting Changes
```bash
# Create feature branch
git checkout -b feature/macos-improvement

# Test thoroughly
make test-i386
make test-i386-graphics

# Commit with proper message
git add .
git commit -m "feat: improve macOS graphics support"
git push origin feature/macos-improvement
```

## 📞 Support

### Getting Help
1. Check this updated guide
2. Review [Graphics Mode Guide](../../../GRAPHICS_MODE_GUIDE.md)
3. Search GitHub issues
4. Create new issue with:
   - macOS version (Intel/Apple Silicon)
   - Error messages
   - Steps to reproduce

### Community Resources
- [GitHub Issues](https://github.com/Asadzero/SAGE-OS/issues)
- [Discussions](https://github.com/Asadzero/SAGE-OS/discussions)
- [Contributing Guidelines](../../../CONTRIBUTING.md)

---

**Latest Updates (2025-06-11)**:
- ✅ VGA Graphics Mode with keyboard input
- ✅ Organized project structure
- ✅ Enhanced testing system with auto-detection
- ✅ macOS-specific build improvements
- ✅ Restored prototype directory
- ✅ Updated documentation and guides

For the most current information, visit the [GitHub repository](https://github.com/Asadzero/SAGE-OS).