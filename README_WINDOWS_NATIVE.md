# 🪟 SAGE OS Native Windows Deployment

## 🚫 **WSL-Free Native Windows Development**

**Perfect for your system**: Intel i5-3380M, 4GB RAM, Windows 10 Pro, Legacy BIOS

This guide provides **100% native Windows deployment** without any WSL dependency, optimized specifically for your hardware configuration.

## ⚡ **One-Command Setup**

```cmd
# Download SAGE OS
git clone https://github.com/AshishYesale7/SAGE-OS.git
cd SAGE-OS

# Install all dependencies and launch (as Administrator)
scripts\windows\install-native-dependencies.bat

# Quick launch
scripts\windows\quick-launch.bat
```

**That's it!** 🎉 Everything installs natively on Windows.

## 🎯 **System Optimization**

### **Your Hardware Profile**
- **CPU**: Intel Core i5-3380M @ 2.90GHz (2 cores, 4 threads)
- **RAM**: 4GB (3.70GB available)
- **BIOS**: Legacy BIOS (perfect for SAGE OS)
- **OS**: Windows 10 Pro Build 19045
- **Architecture**: x64-based PC

### **Optimized Configuration**
```cmd
# QEMU Settings for your system
Architecture: i386 (optimal for dual-core i5)
Memory: 128MB (perfect for 4GB system)
CPU: Nehalem (matches your Intel architecture)
Cores: 2 (utilizes both CPU cores)
Graphics: VGA + GTK (full compatibility)
```

## 🛠️ **Native Build Environment**

### **Primary Tools (No WSL)**
- **MSYS2**: Native Windows build environment
- **MinGW-w64**: Cross-compilation toolchain
- **QEMU**: Native Windows emulation
- **GTK/SDL**: Graphics libraries
- **Git**: Version control

### **Build Process**
```cmd
# Native compilation using MSYS2
C:\msys64\usr\bin\bash.exe -c "make ARCH=i386 TARGET=generic"

# Or use build script
scripts\windows\build-sage-os.bat i386
```

## 📦 **Dependencies Included**

### **Core Development**
- ✅ **MSYS2**: Complete POSIX environment
- ✅ **MinGW-w64**: i686 and x86_64 cross-compilers
- ✅ **Make**: Build automation
- ✅ **Git**: Source control
- ✅ **GCC**: Native compilation

### **Graphics Support**
- ✅ **QEMU**: Full graphics emulation
- ✅ **GTK Runtime**: Native Windows display
- ✅ **SDL2**: Fallback graphics library
- ✅ **VGA Standard**: Universal compatibility
- ✅ **USB Input**: Keyboard and mouse support

### **System Libraries**
- ✅ **Visual C++ Redistributables**: Runtime support
- ✅ **DirectX**: Graphics acceleration
- ✅ **OpenGL**: 3D graphics support
- ✅ **GDI32/User32**: Windows graphics APIs

## 🚀 **Usage Examples**

### **Quick Start**
```cmd
# Navigate to SAGE OS
cd C:\Users\lenovo\Downloads\SAGE-OS

# One-click launch
scripts\windows\quick-launch.bat

# Choose option 1 (Graphics Mode)
```

### **Manual Build & Launch**
```cmd
# Build for i386
scripts\windows\build-sage-os.bat i386

# Launch in graphics mode
scripts\windows\launch-sage-os-graphics.bat i386 128M

# Launch in console mode
scripts\windows\launch-sage-os-console.bat i386 128M
```

### **Advanced Options**
```cmd
# PowerShell launcher with custom settings
scripts\windows\launch-sage-os.ps1 -Arch i386 -Memory 128M

# Direct QEMU command
qemu-system-i386 -kernel build\i386\kernel.elf -m 128M -vga std -display gtk
```

## 🎮 **Graphics Mode Features**

### **Display Configuration**
```cmd
# Optimized for Intel i5-3380M
-vga std              # Standard VGA (universal compatibility)
-display gtk          # Native Windows integration
-cpu Nehalem          # Matches your CPU architecture
-smp 2                # Uses both CPU cores
-rtc base=localtime   # Syncs with Windows time
```

### **Input Support**
- ✅ **Full Keyboard**: All keys supported
- ✅ **Mouse Input**: Click, scroll, drag
- ✅ **Copy/Paste**: Windows clipboard integration
- ✅ **Window Controls**: Resize, minimize, close

### **Performance Optimizations**
- 🚀 **Memory**: 128MB allocation (optimal for 4GB)
- 🚀 **CPU**: Dual-core utilization
- 🚀 **Graphics**: Hardware-accelerated when available
- 🚀 **I/O**: Native Windows file system access

## 🔧 **Build Methods**

### **Method 1: MSYS2 (Recommended)**
```cmd
# Automatic detection and build
scripts\windows\build-sage-os.bat i386

# Manual MSYS2 build
C:\msys64\usr\bin\bash.exe -c "cd '%CD%' && make ARCH=i386 TARGET=generic"
```

### **Method 2: MinGW**
```cmd
# Using MinGW make
mingw32-make ARCH=i386 TARGET=generic
```

### **Method 3: Native Make**
```cmd
# If make is in PATH
make ARCH=i386 TARGET=generic
```

## 🐛 **Troubleshooting**

### **Build Issues**

#### **"make: command not found"**
```cmd
# Use MSYS2 make
C:\msys64\usr\bin\make.exe ARCH=i386 TARGET=generic

# Or install dependencies
scripts\windows\install-native-dependencies.bat
```

#### **"gcc: command not found"**
```cmd
# Install MSYS2 toolchain
C:\msys64\usr\bin\pacman.exe -S mingw-w64-i686-gcc

# Or run full setup
scripts\windows\install-native-dependencies.bat
```

### **Graphics Issues**

#### **"QEMU window doesn't open"**
```cmd
# Try SDL fallback
qemu-system-i386 -kernel build\i386\kernel.elf -m 128M -display sdl

# Or console mode
scripts\windows\launch-sage-os-console.bat i386
```

#### **"Slow graphics performance"**
```cmd
# Reduce memory for 4GB system
scripts\windows\launch-sage-os-graphics.bat i386 64M

# Use console mode (faster)
scripts\windows\launch-sage-os-console.bat i386
```

### **Memory Issues**

#### **"Out of memory"**
```cmd
# Close other applications
# Use Task Manager to free RAM

# Reduce QEMU memory
qemu-system-i386 -kernel build\i386\kernel.elf -m 64M -vga std
```

## 📊 **Performance Benchmarks**

### **Expected Performance on Intel i5-3380M**

| Metric | Value | Notes |
|--------|-------|-------|
| Build Time | 30-60 seconds | MSYS2 native compilation |
| Boot Time | 2-5 seconds | QEMU startup |
| Memory Usage | 150-200MB | QEMU + SAGE OS |
| CPU Usage | 10-30% | During normal operation |
| Graphics FPS | 30-60 FPS | VGA text mode |

### **Memory Allocation**

| Component | Memory | Percentage |
|-----------|--------|------------|
| Windows OS | ~2.5GB | 67% |
| QEMU Process | 128MB | 3% |
| SAGE OS Kernel | 64MB | 2% |
| Available | ~1.1GB | 28% |

## 🔍 **System Verification**

### **Check Installation**
```cmd
# Verify QEMU
qemu-system-i386 --version

# Verify MSYS2
C:\msys64\usr\bin\bash.exe --version

# Verify GCC
C:\msys64\usr\bin\bash.exe -c "gcc --version"

# Test build environment
scripts\windows\build-sage-os.bat i386 test
```

### **Graphics Test**
```cmd
# Test graphics libraries
where gtk-query-immodules-2.0
where sdl2-config

# Test QEMU graphics
qemu-system-i386 -display gtk -monitor stdio
```

## 📋 **File Structure**

```
SAGE-OS/
├── scripts/windows/
│   ├── install-native-dependencies.bat    # Complete setup
│   ├── quick-launch.bat                   # One-click launch
│   ├── build-sage-os.bat                  # Native build
│   ├── launch-sage-os-graphics.bat        # Graphics mode
│   ├── launch-sage-os-console.bat         # Console mode
│   ├── launch-sage-os.ps1                 # PowerShell launcher
│   └── setup-windows-environment.ps1      # Environment setup
├── build/i386/
│   └── kernel.elf                         # Built kernel
└── README_WINDOWS_NATIVE.md               # This file
```

## 🎯 **Why Native Windows?**

### **Advantages**
- ✅ **No WSL dependency**: Pure Windows environment
- ✅ **Better performance**: Native compilation and execution
- ✅ **Simpler setup**: No virtualization overhead
- ✅ **Full hardware access**: Direct system integration
- ✅ **Legacy BIOS support**: Perfect for your system

### **Perfect for Your System**
- 🎯 **Intel i5-3380M**: Optimized CPU settings
- 🎯 **4GB RAM**: Efficient memory allocation
- 🎯 **Legacy BIOS**: No UEFI complications
- 🎯 **Windows 10**: Full compatibility

## 🚀 **Quick Commands Reference**

```cmd
# Complete setup (run once as Administrator)
scripts\windows\install-native-dependencies.bat

# Daily usage
scripts\windows\quick-launch.bat

# Build only
scripts\windows\build-sage-os.bat i386

# Graphics mode
scripts\windows\launch-sage-os-graphics.bat i386

# Console mode
scripts\windows\launch-sage-os-console.bat i386

# PowerShell advanced
scripts\windows\launch-sage-os.ps1 -Arch i386 -Memory 128M
```

## 🎉 **Success Indicators**

You know everything is working when:

1. ✅ **Dependencies installed**: All tools available
2. ✅ **Build succeeds**: `build\i386\kernel.elf` created
3. ✅ **QEMU launches**: Graphics window opens
4. ✅ **SAGE OS boots**: ASCII logo appears
5. ✅ **Shell responds**: Commands work properly
6. ✅ **Performance good**: Smooth interaction

**Your Intel i5-3380M system is perfect for native SAGE OS development!** 🚀

---

**Get started now**: `scripts\windows\install-native-dependencies.bat` (as Administrator)