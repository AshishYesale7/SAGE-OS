# 🍎 Installing QEMU with Cocoa Support on Mac M1

## 🎯 **Quick Solution**

Cocoa display is **already built into macOS** - you just need QEMU compiled with Cocoa support.

## 🔧 **Method 1: Homebrew Installation (Recommended)**

### **Step 1: Install/Update Homebrew**
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Update Homebrew
brew update
```

### **Step 2: Install QEMU with Cocoa Support**
```bash
# Remove existing QEMU if installed
brew uninstall qemu 2>/dev/null || true

# Install QEMU (includes Cocoa support on macOS)
brew install qemu

# Verify Cocoa support
qemu-system-i386 -display help | grep cocoa
```

### **Step 3: Test Cocoa Display**
```bash
# Test with SAGE OS
./sage-os-macos.sh
# Should now work with Cocoa display on Intel Macs
```

## 🔧 **Method 2: MacPorts Installation**

### **Install via MacPorts**
```bash
# Install MacPorts first (if not installed)
# Download from: https://www.macports.org/install.php

# Install QEMU
sudo port install qemu +cocoa

# Verify installation
qemu-system-i386 -display help | grep cocoa
```

## 🔧 **Method 3: Compile from Source (Advanced)**

### **Prerequisites**
```bash
# Install Xcode Command Line Tools
xcode-select --install

# Install dependencies
brew install pkg-config glib pixman ninja meson
```

### **Compile QEMU**
```bash
# Download QEMU source
wget https://download.qemu.org/qemu-8.2.0.tar.xz
tar xf qemu-8.2.0.tar.xz
cd qemu-8.2.0

# Configure with Cocoa support
./configure --target-list=i386-softmmu,x86_64-softmmu,aarch64-softmmu \
            --enable-cocoa \
            --disable-werror

# Compile and install
make -j$(nproc)
sudo make install
```

## 🎮 **Why VNC is Better on Apple Silicon**

### **Apple Silicon (M1/M2) Reality:**
- **Cocoa display often has issues** with x86 emulation on ARM Macs
- **VNC is more reliable** for cross-architecture emulation
- **Graphics performance** is better with VNC on M1/M2

### **SAGE OS Recommendation:**
```bash
# Use VNC on Apple Silicon (M1/M2)
./sage-os-macos.sh  # Automatically uses VNC on Apple Silicon

# Use Cocoa on Intel Macs
./sage-os-macos.sh  # Automatically uses Cocoa on Intel
```

## 🔍 **Verify Your Installation**

### **Check QEMU Display Options**
```bash
qemu-system-i386 -display help
```

**Expected output should include:**
```
Available display backends:
cocoa            (macOS Cocoa UI)
vnc              (VNC server)
none             (No display)
```

### **Test Cocoa Display**
```bash
# Test with minimal command
qemu-system-i386 \
    -drive file=build/macos/sage_os_macos.img,format=raw,if=floppy,readonly=on \
    -boot a \
    -m 128M \
    -display cocoa \
    -no-fd-bootchk
```

## 🚨 **Common Issues & Solutions**

### **Issue 1: "cocoa display backend not available"**
**Solution:** Reinstall QEMU via Homebrew
```bash
brew uninstall qemu
brew install qemu
```

### **Issue 2: Cocoa window doesn't appear**
**Solution:** Check macOS permissions
```bash
# System Preferences > Security & Privacy > Privacy
# Allow QEMU in "Screen Recording" and "Accessibility"
```

### **Issue 3: Black screen with Cocoa**
**Solution:** Use VNC instead (more reliable on M1)
```bash
# SAGE OS automatically handles this
./sage-os-macos.sh  # Will use VNC on Apple Silicon
```

## 🎯 **SAGE OS Automatic Detection**

The SAGE OS scripts automatically detect your Mac type:

### **Apple Silicon (M1/M2):**
- **Primary:** VNC display (more reliable)
- **Fallback:** Cocoa display

### **Intel Macs:**
- **Primary:** Cocoa display (native performance)
- **Fallback:** VNC display

## ✅ **Verification Commands**

```bash
# Check your Mac architecture
uname -m
# arm64 = Apple Silicon (M1/M2)
# x86_64 = Intel Mac

# Check QEMU version and features
qemu-system-i386 --version
qemu-system-i386 -display help

# Test SAGE OS
./quick_test_sage_os.sh
```

## 🎉 **Success Indicators**

✅ **QEMU shows Cocoa in display help**  
✅ **Cocoa window opens when testing**  
✅ **SAGE OS displays correctly**  
✅ **No "backend not available" errors**  

**Note:** On Apple Silicon, VNC is still recommended for better compatibility!