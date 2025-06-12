# SAGE OS Windows Troubleshooting Guide

## 🖥️ **System-Specific Troubleshooting**

**Your System**: Intel i5-3380M, 4GB RAM, Windows 10 Pro, Legacy BIOS

This guide addresses common issues specific to your hardware configuration and Windows setup.

## 🚨 **Common Issues & Quick Fixes**

### **1. Build Issues**

#### **Problem**: "make: command not found"
```cmd
❌ Error: 'make' is not recognized as an internal or external command
```

**Solutions**:
```cmd
# Option 1: Use WSL2 (Recommended)
wsl make ARCH=i386 TARGET=generic

# Option 2: Install MSYS2
choco install msys2 -y

# Option 3: Use build script
scripts\windows\build-sage-os.bat i386
```

#### **Problem**: Cross-compilation errors
```cmd
❌ Error: i686-linux-gnu-gcc: command not found
```

**Solutions**:
```bash
# In WSL2 Ubuntu
sudo apt update
sudo apt install gcc-multilib gcc-i686-linux-gnu

# Or use native Windows build
scripts\windows\build-sage-os.bat i386 generic native
```

### **2. QEMU Issues**

#### **Problem**: "QEMU not found"
```cmd
❌ Error: qemu-system-i386 is not recognized
```

**Solutions**:
```cmd
# Install via Chocolatey
choco install qemu -y

# Or download manually
# https://www.qemu.org/download/#windows

# Add to PATH manually
set PATH=%PATH%;C:\Program Files\qemu
```

#### **Problem**: Graphics window doesn't open
```cmd
❌ QEMU starts but no window appears
```

**Solutions**:
```cmd
# Try different display options
qemu-system-i386 -kernel build\i386\kernel.elf -m 128M -display sdl
qemu-system-i386 -kernel build\i386\kernel.elf -m 128M -display gtk
qemu-system-i386 -kernel build\i386\kernel.elf -m 128M -display vnc=:1

# Use console mode as fallback
scripts\windows\launch-sage-os-console.bat
```

#### **Problem**: Slow performance
```cmd
⚠️ QEMU runs very slowly
```

**Solutions for your 4GB system**:
```cmd
# Reduce memory allocation
qemu-system-i386 -kernel build\i386\kernel.elf -m 64M -vga std

# Close other applications
# Use Task Manager to free up RAM

# Try console mode (faster)
qemu-system-i386 -kernel build\i386\kernel.elf -m 128M -nographic
```

### **3. WSL2 Issues**

#### **Problem**: WSL2 not installing
```powershell
❌ Error: WSL feature cannot be enabled
```

**Solutions**:
```powershell
# Check Windows version
winver
# Need Windows 10 version 2004 or later

# Enable features manually
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Restart Windows
Restart-Computer
```

#### **Problem**: WSL2 out of memory
```bash
❌ Error: Cannot allocate memory
```

**Solutions**:
```powershell
# Create .wslconfig in %USERPROFILE%
echo [wsl2] > %USERPROFILE%\.wslconfig
echo memory=2GB >> %USERPROFILE%\.wslconfig
echo processors=2 >> %USERPROFILE%\.wslconfig

# Restart WSL
wsl --shutdown
wsl
```

### **4. Legacy BIOS Specific Issues**

#### **Problem**: UEFI-related errors
```cmd
❌ Error: UEFI boot not supported
```

**Solution**: ✅ **Not a problem for SAGE OS!**
```cmd
# SAGE OS works perfectly with Legacy BIOS
# Your system is actually ideal for SAGE OS testing
# No UEFI configuration needed
```

#### **Problem**: Secure Boot warnings
```cmd
⚠️ Warning: Secure Boot not supported
```

**Solution**: ✅ **This is normal and expected**
```cmd
# SAGE OS doesn't require Secure Boot
# Legacy BIOS systems don't have Secure Boot
# This is the preferred configuration for OS development
```

## 🔧 **Hardware-Specific Optimizations**

### **For Intel i5-3380M (Your CPU)**

#### **Optimal QEMU Settings**:
```cmd
qemu-system-i386 ^
    -kernel build\i386\kernel.elf ^
    -m 128M ^
    -cpu Nehalem ^
    -smp 2 ^
    -vga std ^
    -display gtk ^
    -device usb-kbd ^
    -device usb-mouse ^
    -rtc base=localtime
```

**Why these settings**:
- **-cpu Nehalem**: Matches your CPU architecture
- **-smp 2**: Uses both CPU cores
- **-m 128M**: Perfect for 4GB system
- **-rtc base=localtime**: Syncs with Windows time

#### **Performance Tuning**:
```cmd
# For best performance on your system
set QEMU_OPTS=-m 128M -cpu Nehalem -smp 2

# Memory-constrained mode (if needed)
set QEMU_OPTS=-m 64M -cpu qemu32 -smp 1

# Maximum performance mode
set QEMU_OPTS=-m 256M -cpu Nehalem -smp 2 -enable-kvm
```

### **For 4GB RAM Systems**

#### **Memory Management**:
```cmd
# Check available memory
wmic OS get TotalVisibleMemorySize,FreePhysicalMemory

# Optimal allocation for your system:
# Windows: ~2.5GB
# QEMU: 128MB
# Other apps: ~1.4GB
```

#### **Resource Monitoring**:
```cmd
# Monitor QEMU resource usage
tasklist /fi "imagename eq qemu-system-i386.exe"

# If memory usage is high, reduce QEMU memory:
scripts\windows\launch-sage-os-graphics.bat i386 64M
```

## 🛠️ **Advanced Troubleshooting**

### **Debug Mode**

#### **Enable QEMU Debug Output**:
```cmd
qemu-system-i386 ^
    -kernel build\i386\kernel.elf ^
    -m 128M ^
    -d int,cpu_reset ^
    -D qemu-debug.log ^
    -monitor stdio
```

#### **SAGE OS Debug Build**:
```cmd
# Build with debug symbols
wsl make ARCH=i386 TARGET=generic CFLAGS="-g -O0"

# Launch with GDB support
qemu-system-i386 -kernel build\i386\kernel.elf -m 128M -s -S
```

### **Network Troubleshooting**

#### **If downloads fail during setup**:
```powershell
# Check internet connection
Test-NetConnection google.com -Port 80

# Use different package source
choco source add -n chocolatey-backup -s https://chocolatey.org/api/v2/

# Manual downloads
# QEMU: https://www.qemu.org/download/#windows
# Git: https://git-scm.com/download/win
```

### **File System Issues**

#### **Path length limitations**:
```cmd
# Enable long paths in Windows 10
reg add HKLM\SYSTEM\CurrentControlSet\Control\FileSystem /v LongPathsEnabled /t REG_DWORD /d 1

# Or use shorter paths
move SAGE-OS C:\SAGE
cd C:\SAGE
```

#### **Permission issues**:
```cmd
# Run as Administrator
runas /user:Administrator cmd

# Or fix permissions
icacls C:\path\to\SAGE-OS /grant Users:F /T
```

## 📊 **Performance Benchmarks**

### **Expected Performance on Your System**

| Component | Expected Performance |
|-----------|---------------------|
| Build Time (i386) | 30-60 seconds |
| QEMU Boot Time | 2-5 seconds |
| Memory Usage | 150-200MB total |
| CPU Usage | 10-30% during operation |

### **Performance Comparison**

| Mode | Boot Time | Memory | CPU | Responsiveness |
|------|-----------|--------|-----|----------------|
| Graphics | 3-5s | 180MB | 15% | Excellent |
| Console | 2-3s | 120MB | 10% | Very Good |
| Debug | 5-8s | 220MB | 25% | Good |

## 🔍 **Diagnostic Commands**

### **System Information**:
```cmd
# Check system specs
systeminfo | findstr /C:"Total Physical Memory" /C:"Processor"

# Check Windows version
ver

# Check available disk space
dir C:\ /-c
```

### **SAGE OS Status**:
```cmd
# Check build status
dir build\i386\

# Check kernel size
dir build\i386\kernel.elf

# Test QEMU installation
qemu-system-i386 --version
```

### **WSL2 Diagnostics**:
```powershell
# Check WSL status
wsl --status

# List installed distributions
wsl --list --verbose

# Check WSL version
wsl --version
```

## 🆘 **Emergency Recovery**

### **If SAGE OS won't build**:
```cmd
# Clean everything
scripts\windows\build-sage-os.bat clean

# Try different build method
scripts\windows\build-sage-os.bat i386 generic wsl
scripts\windows\build-sage-os.bat i386 generic native
scripts\windows\build-sage-os.bat i386 generic docker
```

### **If QEMU won't start**:
```cmd
# Try minimal command
qemu-system-i386 --version

# Test with simple kernel
qemu-system-i386 -kernel build\i386\kernel.elf -nographic

# Use alternative emulator
# VirtualBox, VMware, or Hyper-V as fallback
```

### **If Windows becomes unstable**:
```cmd
# Disable WSL2 temporarily
wsl --shutdown

# Check system health
sfc /scannow

# Restart Windows
shutdown /r /t 0
```

## 📞 **Getting Help**

### **Log Collection**:
```cmd
# Collect system info
systeminfo > sage-os-system-info.txt

# Collect build logs
scripts\windows\build-sage-os.bat i386 > build-log.txt 2>&1

# Collect QEMU logs
qemu-system-i386 -kernel build\i386\kernel.elf -m 128M -d int > qemu-log.txt 2>&1
```

### **Support Channels**:
- **GitHub Issues**: Report Windows-specific bugs
- **Documentation**: Check `docs\platforms\windows\`
- **Community**: Join development discussions

## ✅ **Success Indicators**

You know everything is working when:

1. ✅ **Build completes**: `build\i386\kernel.elf` exists
2. ✅ **QEMU starts**: Graphics window opens
3. ✅ **SAGE OS boots**: ASCII logo appears
4. ✅ **Shell works**: Commands respond
5. ✅ **Performance good**: Responsive interaction

**Your Intel i5-3380M system is perfect for SAGE OS development!** 🚀