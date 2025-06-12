# SAGE OS Platform-Specific All-in-One Scripts

This directory contains comprehensive all-in-one scripts that automatically install dependencies, build SAGE OS, and launch it on different platforms.

## 🚀 Quick Start

Choose your platform and run the appropriate script:

### macOS (Intel & Apple Silicon)
```bash
./sage-os-macos.sh
```

### Linux (All Distributions)
```bash
./sage-os-linux.sh
```

### Windows (Native)
```cmd
sage-os-windows.bat
```

### Windows (WSL/WSL2)
```bash
./sage-os-windows-wsl.sh
```

## 📋 What Each Script Does

### 1. **Dependency Installation**
- Automatically detects your system
- Installs required packages (QEMU, GCC, build tools)
- Sets up cross-compilation toolchain if needed

### 2. **SAGE OS Build**
- Creates platform-specific bootloader
- Compiles 32-bit protected mode kernel
- Generates bootable disk image
- Handles path and permission issues

### 3. **Launch & Test**
- Starts QEMU with optimal settings
- Displays ASCII art and system info
- Enables interactive keyboard input
- Provides VNC fallback if needed

## 🖥️ Platform-Specific Features

### macOS Script (`sage-os-macos.sh`)
- **Homebrew Integration**: Auto-installs Homebrew if missing
- **Architecture Detection**: Handles Intel and Apple Silicon Macs
- **Display Options**: Cocoa → SDL → VNC fallback
- **Cross-Compilation**: Uses i386-elf-gcc or system GCC

### Linux Script (`sage-os-linux.sh`)
- **Multi-Distro Support**: Ubuntu, Debian, Fedora, Arch, openSUSE, Alpine
- **Package Manager Detection**: APT, DNF, Pacman, Zypper, APK
- **Display Detection**: X11, Wayland, VNC fallback
- **32-bit Support**: Handles multilib packages

### Windows Native Script (`sage-os-windows.bat`)
- **Chocolatey Integration**: Auto-installs package manager
- **MinGW Toolchain**: Sets up GCC for Windows
- **PowerShell Helpers**: Uses PowerShell for binary operations
- **Admin Privileges**: Handles UAC requirements

### WSL Script (`sage-os-windows-wsl.sh`)
- **WSL Detection**: Identifies WSL1 vs WSL2
- **X11 Forwarding**: Supports VcXsrv/Xming integration
- **Windows Interop**: Copies files to Windows desktop
- **Distribution Support**: Works with Ubuntu, Debian, etc. on WSL

## 📁 Build Output Locations

Each script creates platform-specific build directories:

```
build/
├── macos/
│   ├── bootloader.bin
│   └── sage_os_macos.img
├── linux/
│   ├── bootloader.bin
│   └── sage_os_linux.img
├── windows/
│   ├── bootloader.bin
│   └── sage_os_windows.img
└── wsl/
    ├── bootloader.bin
    └── sage_os_wsl.img
```

## 🎮 What You'll See

When SAGE OS boots successfully, you should see:

1. **Boot Message**: Platform-specific loading message
2. **ASCII Art**: "SAGE OS [Platform]" display
3. **System Info**: "32-bit Mode" and status
4. **Interactive Input**: Real-time keyboard processing

## 🔧 Troubleshooting

### Common Issues

**macOS:**
- If 32-bit compilation fails: Install i386-elf-gcc via Homebrew
- If Cocoa display fails: Install XQuartz for X11 support

**Linux:**
- If multilib missing: Install gcc-multilib package
- If QEMU missing: Install qemu-system-x86 package

**Windows:**
- If admin required: Run as Administrator
- If MinGW fails: Install MSYS2 manually

**WSL:**
- If X11 fails: Install VcXsrv on Windows
- If compilation fails: Install build-essential

### Manual Installation

If automatic dependency installation fails:

**Required packages:**
- QEMU (qemu-system-i386)
- GCC with 32-bit support
- Binutils
- Make
- Git

## 🎯 Advanced Usage

### Custom QEMU Options

You can modify the QEMU launch commands in each script:

```bash
# Example: Add more memory
qemu-system-i386 -fda sage_os.img -m 256M

# Example: Enable networking
qemu-system-i386 -fda sage_os.img -netdev user,id=net0

# Example: Save VM state
qemu-system-i386 -fda sage_os.img -snapshot
```

### Build Customization

Each script supports customization:

1. **Bootloader**: Modify the minimal_boot.S creation
2. **Disk Size**: Change the dd count parameter
3. **Display**: Adjust QEMU display options

## 🚀 Next Steps

After successfully running SAGE OS:

1. **Explore the Code**: Check `boot/` and `kernel/` directories
2. **Modify Features**: Add new functionality to the kernel
3. **Test Changes**: Rebuild with the same script
4. **Contribute**: Submit improvements via pull request

## 📞 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Verify your system meets the requirements
3. Try the manual installation steps
4. Open an issue on GitHub with your platform details

---

**SAGE OS**: Self-Adaptive Generative Environment Operating System
**Version**: 0.1.0
**License**: MIT