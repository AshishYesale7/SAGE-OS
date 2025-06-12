# SAGE OS Windows Deployment Guide

## 🖥️ **Your System Specifications**

Based on your `msinfo32` output:
- **OS**: Microsoft Windows 10 Pro Build 19045 ✅
- **CPU**: Intel Core i5-3380M @ 2.90GHz (2 cores, 4 logical processors) ✅
- **RAM**: 4.00 GB ✅
- **Architecture**: x64-based PC ✅
- **BIOS**: Legacy Mode ✅
- **Virtualization**: Hyper-V detected ✅

**✅ Your system is fully compatible with SAGE OS!**

## 🚀 **Quick Start (One-Click Setup)**

### **Option 1: Automated Setup (Recommended)**
```cmd
# Run as Administrator
scripts\windows\install-dependencies.bat
scripts\windows\quick-launch.bat
```

### **Option 2: Manual PowerShell Setup**
```powershell
# Run as Administrator
.\scripts\windows\setup-windows-environment.ps1
.\scripts\windows\quick-launch.bat
```

## 📋 **Step-by-Step Setup**

### **Step 1: Install Dependencies**

#### **Method A: Automated (Recommended)**
1. Right-click Command Prompt → "Run as administrator"
2. Navigate to SAGE OS directory
3. Run: `scripts\windows\install-dependencies.bat`
4. Follow prompts (restart if required)

#### **Method B: Manual Installation**
```cmd
# Install Chocolatey (as Administrator)
powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"

# Install packages
choco install git qemu make mingw msys2 vscode -y

# Enable WSL2
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Restart Windows
shutdown /r /t 0
```

### **Step 2: Setup WSL2 (After Restart)**
```cmd
# Set WSL2 as default
wsl --set-default-version 2

# Install Ubuntu
wsl --install -d Ubuntu-22.04
# OR from Microsoft Store: search "Ubuntu 22.04 LTS"
```

### **Step 3: Build and Launch SAGE OS**

#### **Quick Launch (Recommended)**
```cmd
scripts\windows\quick-launch.bat
```

#### **Manual Build and Launch**
```cmd
# Build SAGE OS
scripts\windows\build-sage-os.bat i386

# Launch in graphics mode
scripts\windows\launch-sage-os-graphics.bat i386
```

## 🎯 **Optimized Settings for Your System**

### **Recommended Configuration**
- **Architecture**: `i386` (best performance on your CPU)
- **Memory**: `256M` (optimal for 4GB system RAM)
- **Build Method**: WSL2 (best compatibility)
- **Display**: Graphics mode with VGA

### **Performance Tuning**
```cmd
# For your Intel i5-3380M with 4GB RAM
scripts\windows\launch-sage-os-graphics.bat i386 256M

# If performance is slow, try console mode
scripts\windows\launch-sage-os-console.bat i386 128M
```

## 🛠️ **Build Methods**

### **Method 1: WSL2 (Recommended)**
- ✅ Best compatibility
- ✅ Native Linux toolchain
- ✅ Cross-compilation support
- ✅ Fastest builds

```cmd
# Build using WSL2
scripts\windows\build-sage-os.bat i386 generic wsl
```

### **Method 2: Native Windows**
- ✅ No WSL2 required
- ⚠️ Limited cross-compilation
- ⚠️ May need additional setup

```cmd
# Build natively
scripts\windows\build-sage-os.bat i386 generic native
```

### **Method 3: Docker**
- ✅ Isolated environment
- ✅ Consistent builds
- ⚠️ Requires Docker Desktop

```cmd
# Build with Docker
scripts\windows\build-sage-os.bat i386 generic docker
```

## 🖥️ **Graphics Mode Features**

### **QEMU Graphics Configuration**
- **Display**: VGA with GTK backend
- **Resolution**: 640x480 (expandable)
- **Input**: USB keyboard and mouse
- **Features**: Window controls, copy/paste

### **Keyboard Shortcuts**
- **Ctrl+Alt+G**: Release mouse cursor
- **Ctrl+Alt+F**: Toggle fullscreen
- **Ctrl+Alt+Q**: Quit QEMU
- **Ctrl+Alt+R**: Reset system

### **SAGE OS Commands**
```
help        - Show available commands
version     - Display SAGE OS version
clear       - Clear the screen
echo <text> - Display text
ai info     - Show AI system status
reboot      - Restart the system
halt        - Shutdown the system
```

## 🔧 **Troubleshooting**

### **Common Issues**

#### **1. "QEMU not found"**
```cmd
# Install QEMU
choco install qemu -y

# Or add to PATH manually
set PATH=%PATH%;C:\Program Files\qemu
```

#### **2. "Make not found"**
```cmd
# Install build tools
choco install make mingw msys2 -y

# Or use WSL2
scripts\windows\build-sage-os.bat i386 generic wsl
```

#### **3. "WSL2 not working"**
```cmd
# Check WSL status
wsl --status

# Restart WSL
wsl --shutdown
wsl

# Reinstall if needed
wsl --unregister Ubuntu-22.04
wsl --install -d Ubuntu-22.04
```

#### **4. "Build failed"**
```cmd
# Try different build method
scripts\windows\build-sage-os.bat i386 generic wsl

# Check dependencies
scripts\windows\install-dependencies.bat

# Clean and rebuild
make clean
scripts\windows\build-sage-os.bat i386
```

#### **5. "Graphics not working"**
```cmd
# Try console mode
scripts\windows\launch-sage-os-console.bat i386

# Update graphics drivers
# Check Windows updates

# Try different display option
qemu-system-i386 -kernel build\i386\kernel.elf -m 256M -display sdl
```

### **Performance Issues**

#### **For Your 4GB System**
```cmd
# Reduce QEMU memory
scripts\windows\launch-sage-os-graphics.bat i386 128M

# Close unnecessary applications
# Use i386 instead of x86_64

# Configure WSL2 memory limit
echo [wsl2] > %USERPROFILE%\.wslconfig
echo memory=2GB >> %USERPROFILE%\.wslconfig
echo processors=2 >> %USERPROFILE%\.wslconfig
wsl --shutdown
```

## 📁 **File Structure**

```
SAGE-OS/
├── scripts/windows/
│   ├── install-dependencies.bat      # Automated dependency installer
│   ├── build-sage-os.bat            # Multi-method build script
│   ├── launch-sage-os-graphics.bat  # Graphics mode launcher
│   ├── launch-sage-os-console.bat   # Console mode launcher
│   ├── quick-launch.bat             # One-click build and launch
│   └── setup-windows-environment.ps1 # PowerShell setup script
├── build/i386/
│   └── kernel.elf                   # Built kernel
└── docs/platforms/windows/
    ├── DEVELOPER_GUIDE.md           # Detailed development guide
    └── WINDOWS_DEPLOYMENT_GUIDE.md  # This guide
```

## 🎯 **Recommended Workflow**

### **Daily Development**
1. **Edit Code**: Use VS Code with WSL extension
2. **Build**: `scripts\windows\build-sage-os.bat i386`
3. **Test**: `scripts\windows\launch-sage-os-graphics.bat i386`
4. **Debug**: Use console mode for detailed output

### **Quick Testing**
```cmd
# One command to build and launch
scripts\windows\quick-launch.bat
```

### **Performance Testing**
```cmd
# Test different memory configurations
scripts\windows\launch-sage-os-graphics.bat i386 128M
scripts\windows\launch-sage-os-graphics.bat i386 256M
scripts\windows\launch-sage-os-graphics.bat i386 512M
```

## 🔒 **Security Considerations**

- Scripts require Administrator privileges for installation only
- QEMU runs in user mode (safe)
- No network access by default in QEMU
- WSL2 provides isolated Linux environment
- All source code is open and auditable

## 📞 **Support**

### **Getting Help**
1. Check this troubleshooting guide
2. Review build logs for specific errors
3. Try different build methods (WSL2 vs native)
4. Ensure all dependencies are installed

### **System-Specific Tips**
- Your Intel i5-3380M works best with i386 builds
- 4GB RAM is sufficient but close other applications
- Legacy BIOS mode is fully supported
- Hyper-V detection indicates good virtualization support

## 🎉 **Success Indicators**

You'll know everything is working when:
- ✅ Build completes without errors
- ✅ QEMU opens graphics window
- ✅ SAGE OS boots and shows ASCII logo
- ✅ Interactive shell responds to keyboard
- ✅ Commands like `help` and `version` work

## 🚀 **Next Steps**

1. **Complete Setup**: Run `scripts\windows\install-dependencies.bat`
2. **First Build**: Run `scripts\windows\quick-launch.bat`
3. **Explore SAGE OS**: Try different commands in the shell
4. **Development**: Use VS Code with WSL extension
5. **Contribute**: Report Windows-specific issues or improvements

Your Windows 10 Pro system with Intel i5-3380M is well-suited for SAGE OS development and testing!