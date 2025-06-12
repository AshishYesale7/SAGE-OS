# SAGE OS Windows Setup Guide

## 🖥️ **System Compatibility**

**Your System Specifications:**
- **OS**: Microsoft Windows 10 Pro (Build 19045)
- **CPU**: Intel Core i5-3380M @ 2.90GHz (2 cores, 4 threads)
- **RAM**: 4.00 GB
- **Architecture**: x64-based PC
- **BIOS**: Legacy BIOS (UEFI not supported)

**SAGE OS Compatibility**: ✅ **Fully Compatible**
- Your system is perfect for running SAGE OS in QEMU
- i386 architecture recommended for best performance
- Legacy BIOS is actually preferred for SAGE OS testing

## 🚀 **Quick Start (Recommended)**

### **Option 1: One-Click Setup & Launch**

1. **Download and extract SAGE OS** (if not already done)
2. **Open PowerShell as Administrator**
3. **Run the setup script:**
   ```powershell
   cd path\to\SAGE-OS
   .\scripts\windows\setup-windows-environment.ps1
   ```
4. **Launch SAGE OS:**
   ```cmd
   scripts\windows\quick-launch.bat
   ```

That's it! The scripts will automatically:
- Install required tools (QEMU, build tools)
- Build SAGE OS for your system
- Launch in graphics mode with keyboard support

### **Option 2: Manual Quick Launch**

If you already have the repository:

```cmd
# Navigate to SAGE OS directory
cd C:\path\to\SAGE-OS

# Quick launch (builds automatically if needed)
scripts\windows\quick-launch.bat
```

## 🛠️ **Detailed Setup Methods**

### **Method 1: WSL2 Setup (Best Performance)**

#### **Step 1: Enable WSL2**
```powershell
# Run as Administrator
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Restart Windows
Restart-Computer
```

#### **Step 2: Install Ubuntu**
```powershell
# After restart
wsl --set-default-version 2
wsl --install -d Ubuntu-22.04
```

#### **Step 3: Setup Build Environment**
```bash
# In Ubuntu WSL2 terminal
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential gcc-multilib qemu-system-x86
```

#### **Step 4: Build and Run**
```bash
# Clone and build
git clone https://github.com/AshishYesale7/SAGE-OS.git
cd SAGE-OS
make ARCH=i386 TARGET=generic

# Test in QEMU
qemu-system-i386 -kernel build/i386/kernel.elf -m 128M -vga std -display gtk
```

### **Method 2: Native Windows with Chocolatey**

#### **Step 1: Install Chocolatey**
```powershell
# Run as Administrator
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

#### **Step 2: Install Tools**
```powershell
choco install git qemu make mingw msys2 -y
```

#### **Step 3: Build and Run**
```cmd
# Clone repository
git clone https://github.com/AshishYesale7/SAGE-OS.git
cd SAGE-OS

# Build using Windows scripts
scripts\windows\build-sage-os.bat i386

# Launch in graphics mode
scripts\windows\launch-sage-os-graphics.bat i386
```

## 🎮 **Graphics Mode Setup**

### **For Your System (Intel i5-3380M)**

**Recommended QEMU Settings:**
```cmd
qemu-system-i386 ^
    -kernel build\i386\kernel.elf ^
    -m 128M ^
    -vga std ^
    -display gtk ^
    -device usb-kbd ^
    -device usb-mouse ^
    -name "SAGE OS" ^
    -no-reboot
```

**Why these settings work best:**
- **i386**: Perfect for your dual-core i5
- **128M RAM**: Optimal for 4GB system
- **VGA std**: Compatible with all graphics
- **GTK display**: Native Windows graphics

### **Launch Scripts Available**

1. **Quick Launch**: `scripts\windows\quick-launch.bat`
   - Auto-builds if needed
   - Interactive mode selection
   - Optimized for your hardware

2. **Graphics Mode**: `scripts\windows\launch-sage-os-graphics.bat`
   - Direct graphics launch
   - Full keyboard/mouse support

3. **Console Mode**: `scripts\windows\launch-sage-os-console.bat`
   - Text-only interface
   - Lower resource usage

4. **PowerShell**: `scripts\windows\launch-sage-os.ps1`
   - Advanced options
   - Customizable parameters

## 🔧 **System-Specific Optimizations**

### **For Intel i5-3380M (Your CPU)**

```cmd
REM Optimized launch command for your system
qemu-system-i386 ^
    -kernel build\i386\kernel.elf ^
    -m 128M ^
    -cpu host ^
    -smp 2 ^
    -vga std ^
    -display gtk ^
    -device usb-kbd ^
    -device usb-mouse ^
    -rtc base=localtime ^
    -no-reboot
```

**Optimization Explanation:**
- **-cpu host**: Uses your actual CPU features
- **-smp 2**: Utilizes both CPU cores
- **-m 128M**: Perfect for 4GB system
- **-rtc base=localtime**: Matches Windows time

### **Memory Recommendations**

| QEMU Memory | System Impact | Performance |
|-------------|---------------|-------------|
| 64M         | Minimal       | Basic       |
| 128M        | Low           | **Optimal** |
| 256M        | Moderate      | Enhanced    |
| 512M        | High          | Overkill    |

**Recommended**: 128M (perfect balance for your 4GB system)

## 📋 **Step-by-Step Usage**

### **First Time Setup**

1. **Open Command Prompt as Administrator**
2. **Navigate to SAGE OS directory**
   ```cmd
   cd C:\Users\lenovo\Downloads\SAGE-OS
   ```
3. **Run setup script**
   ```cmd
   scripts\windows\setup-windows-environment.ps1
   ```
4. **Wait for installation to complete**
5. **Restart if prompted**

### **Daily Usage**

1. **Open Command Prompt** (normal user)
2. **Navigate to SAGE OS**
   ```cmd
   cd C:\Users\lenovo\Downloads\SAGE-OS
   ```
3. **Quick launch**
   ```cmd
   scripts\windows\quick-launch.bat
   ```
4. **Choose graphics mode (option 1)**
5. **Enjoy SAGE OS!**

## 🎯 **What to Expect**

### **Boot Sequence**
1. **QEMU window opens**
2. **SeaBIOS loads** (normal for QEMU)
3. **SAGE OS boots** with ASCII art logo
4. **Interactive shell appears**

### **Available Commands**
```
sage@localhost:~$ help
Available commands:
  help     - Show this help message
  version  - Show SAGE OS version
  clear    - Clear screen
  ai       - AI system information
  exit     - Exit shell
```

### **Graphics Mode Features**
- ✅ **VGA Graphics**: 80x25 text mode with colors
- ✅ **Keyboard Input**: Full keyboard support
- ✅ **Mouse Support**: Basic mouse functionality
- ✅ **Window Controls**: Resize, minimize, close
- ✅ **Copy/Paste**: Ctrl+C/Ctrl+V support

## 🐛 **Troubleshooting**

### **Common Issues & Solutions**

#### **1. "QEMU not found"**
```cmd
# Install QEMU
choco install qemu -y

# Or download manually from: https://www.qemu.org/download/#windows
```

#### **2. "Build failed"**
```cmd
# Try WSL2 build
wsl make ARCH=i386 TARGET=generic

# Or use Docker
docker run --rm -v %cd%:/workspace sage-os:dev make ARCH=i386
```

#### **3. "Graphics window doesn't open"**
```cmd
# Try console mode instead
scripts\windows\launch-sage-os-console.bat

# Or check display settings
qemu-system-i386 -kernel build\i386\kernel.elf -m 128M -nographic
```

#### **4. "Slow performance"**
```cmd
# Reduce memory usage
scripts\windows\launch-sage-os-graphics.bat i386 64M

# Or use console mode
scripts\windows\launch-sage-os-console.bat
```

### **System-Specific Fixes**

#### **For Legacy BIOS Systems (Like Yours)**
```cmd
# SAGE OS works perfectly with Legacy BIOS
# No special configuration needed
# i386 architecture is optimal
```

#### **For 4GB RAM Systems**
```cmd
# Optimal memory allocation
set QEMU_MEMORY=128M

# Close other applications for best performance
# SAGE OS + QEMU will use ~200MB total
```

## 🚀 **Advanced Usage**

### **Custom Launch Parameters**

```cmd
# Custom memory
scripts\windows\launch-sage-os-graphics.bat i386 256M

# Different architecture
scripts\windows\launch-sage-os-graphics.bat x86_64 128M

# PowerShell with options
scripts\windows\launch-sage-os.ps1 -Arch i386 -Memory 128M -Console
```

### **Development Workflow**

```cmd
# 1. Edit code (use VS Code or any editor)
code kernel\kernel.c

# 2. Build
scripts\windows\build-sage-os.bat i386

# 3. Test
scripts\windows\launch-sage-os-graphics.bat i386

# 4. Repeat
```

## 📖 **Additional Resources**

- **Windows Developer Guide**: `docs\platforms\windows\DEVELOPER_GUIDE.md`
- **Build System**: `BUILD_README.md`
- **Architecture Guide**: `docs\architectures\`
- **Troubleshooting**: `TROUBLESHOOTING_WINDOWS.md`

## 🎉 **Ready to Go!**

Your Intel i5-3380M system with 4GB RAM and Legacy BIOS is **perfect** for SAGE OS development and testing. The i386 architecture will run smoothly with excellent performance.

**Quick Start Command:**
```cmd
scripts\windows\quick-launch.bat
```

**Enjoy exploring SAGE OS - The Future of Self-Evolving Systems!** 🚀