# Getting Started with SAGE-OS

Welcome to **SAGE-OS** (Self-Aware General Environment Operating System) - a revolutionary embedded operating system designed for modern AI-enhanced hardware platforms.

## 🚀 What is SAGE-OS?

SAGE-OS is a cutting-edge embedded operating system that combines traditional OS functionality with advanced AI capabilities. Built from the ground up with modern C and featuring comprehensive multi-architecture support, SAGE-OS provides a robust foundation for intelligent embedded systems.

## ✨ Key Features

<div class="grid cards" markdown>

-   **🏗️ Multi-Architecture Support**
    
    Native support for i386, x86_64, ARM, AArch64, and RISC-V architectures

-   **🤖 AI Integration**
    
    Built-in AI subsystem with GitHub Models API and local processing capabilities

-   **🎨 Professional Interface**
    
    Beautiful ASCII art branding and interactive command shell

-   **🔧 Comprehensive Drivers**
    
    VGA graphics, serial communication, keyboard, and AI HAT+ support

-   **🚀 Modern Build System**
    
    CMake-based build system with cross-compilation support

-   **🧪 Extensive Testing**
    
    QEMU integration for all supported architectures

</div>

## 🎯 Architecture Support Matrix

| Architecture | Build Status | QEMU Support | Hardware Support | Notes |
|-------------|-------------|--------------|------------------|-------|
| **i386** | ✅ Perfect | ✅ Excellent | ✅ Full | Primary development target |
| **AArch64** | ✅ Perfect | ✅ Excellent | ✅ Full | ARM 64-bit, Raspberry Pi 4/5 |
| **RISC-V** | ⚠️ Partial | ✅ Good | 🔄 Limited | Needs kernel entry point fix |
| **x86_64** | 🔄 WIP | ⚠️ Limited | 🔄 Planned | Requires multiboot2 support |
| **ARM** | 🔄 Planned | 🔄 Planned | 🔄 Planned | Future release target |

## 🛠️ Prerequisites

Before you begin, ensure you have the following installed on your system:

### For Linux/WSL:
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install build-essential gcc-multilib nasm qemu-system-x86 git cmake

# Fedora/RHEL
sudo dnf install gcc gcc-multilib nasm qemu-system-x86 git cmake

# Arch Linux
sudo pacman -S base-devel nasm qemu git cmake
```

### For macOS:
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install gcc nasm qemu git cmake
```

### For Windows:
- Install WSL2 with Ubuntu
- Follow the Linux instructions above
- Alternatively, use Docker Desktop

## 🚀 Quick Start

1. **Clone the Repository**
   ```bash
   git clone https://github.com/AshishYesale7/SAGE-OS.git
   cd SAGE-OS
   ```

2. **Build SAGE-OS**
   ```bash
   # For i386 (recommended for first-time users)
   make clean && make i386
   
   # Or use the build script
   ./build.sh
   ```

3. **Run in QEMU**
   ```bash
   # Start SAGE-OS in QEMU
   make run-i386
   
   # Or with graphics support
   make run-graphics
   ```

4. **Explore the System**
   - Use the interactive shell commands
   - Try the AI features (if configured)
   - Explore the VGA graphics mode

## 📚 Next Steps

- [Installation Guide](installation.md) - Detailed installation instructions
- [Quick Start](quick-start.md) - Get up and running in 5 minutes
- [First Boot](first-boot.md) - Understanding your first SAGE-OS boot
- [Build Guide](../build-guide/overview.md) - Comprehensive build instructions

## 🆘 Need Help?

- Check our [Troubleshooting Guide](../troubleshooting/common-issues.md)
- Visit our [FAQ](../troubleshooting/faq.md)
- Report issues on [GitHub](https://github.com/AshishYesale7/SAGE-OS/issues)
- Join discussions on [GitHub Discussions](https://github.com/AshishYesale7/SAGE-OS/discussions)

---

*Ready to dive deeper? Continue to the [Installation Guide](installation.md) for detailed setup instructions.*