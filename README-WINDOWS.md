# 🪟 SAGE OS for Windows

## 🚀 **Quick Start for Windows Users**

### **One-Click Setup (Recommended)**
1. **Download** or clone SAGE OS repository
2. **Right-click** Command Prompt → "Run as administrator"
3. **Navigate** to SAGE OS directory
4. **Run**: `scripts\windows\sage-os-installer.bat`
5. **Follow** the prompts
6. **Double-click** "🚀 Quick Launch SAGE OS" on desktop

### **Manual Setup**
```cmd
# Install dependencies (as Administrator)
scripts\windows\install-dependencies.bat

# Build and launch
scripts\windows\quick-launch.bat
```

## 🖥️ **Your System Compatibility**

Based on your system specifications:
- **OS**: Windows 10 Pro Build 19045 ✅
- **CPU**: Intel Core i5-3380M @ 2.90GHz ✅
- **RAM**: 4GB ✅
- **Architecture**: x64 ✅

**✅ Your system is fully compatible with SAGE OS!**

## 📋 **Available Scripts**

### **Setup Scripts**
- `scripts\windows\sage-os-installer.bat` - Complete installer
- `scripts\windows\install-dependencies.bat` - Install dependencies only
- `scripts\windows\create-shortcuts.bat` - Create desktop shortcuts

### **Build Scripts**
- `scripts\windows\build-sage-os.bat` - Build SAGE OS kernel
- `scripts\windows\build-sage-os.bat i386` - Build for i386 (recommended)

### **Launch Scripts**
- `scripts\windows\quick-launch.bat` - One-click build and launch
- `scripts\windows\launch-sage-os-graphics.bat` - Graphics mode
- `scripts\windows\launch-sage-os-console.bat` - Console mode

## 🎯 **Optimized for Your System**

### **Recommended Settings**
```cmd
# Best performance for Intel i5-3380M with 4GB RAM
scripts\windows\launch-sage-os-graphics.bat i386 256M
```

### **Architecture Options**
- **i386** (Recommended) - Best performance on your CPU
- **x86_64** - 64-bit support (experimental)

## 🖥️ **Graphics Mode Features**

- **VGA Display** with GTK backend
- **Keyboard Input** - Full interactive shell
- **Mouse Support** - Window controls
- **SAGE OS Commands**: `help`, `version`, `clear`, `echo`, `ai info`

### **Keyboard Shortcuts**
- **Ctrl+Alt+G** - Release mouse cursor
- **Ctrl+Alt+F** - Toggle fullscreen
- **Ctrl+Alt+Q** - Quit QEMU

## 🔧 **Build Methods**

### **1. WSL2 (Recommended)**
- ✅ Best compatibility
- ✅ Native Linux toolchain
- ✅ Cross-compilation support

### **2. Native Windows**
- ✅ No WSL2 required
- ⚠️ Limited cross-compilation

### **3. Docker**
- ✅ Isolated environment
- ✅ Consistent builds

## 🛠️ **Troubleshooting**

### **Common Issues**

#### **"QEMU not found"**
```cmd
choco install qemu -y
```

#### **"Make not found"**
```cmd
# Use WSL2 build method
scripts\windows\build-sage-os.bat i386 generic wsl
```

#### **"Build failed"**
```cmd
# Try different build method
scripts\windows\build-sage-os.bat i386 generic wsl

# Or install dependencies
scripts\windows\install-dependencies.bat
```

#### **"Graphics not working"**
```cmd
# Try console mode
scripts\windows\launch-sage-os-console.bat i386
```

### **Performance Issues**
```cmd
# For 4GB RAM systems
scripts\windows\launch-sage-os-graphics.bat i386 128M

# Close other applications
# Use i386 instead of x86_64
```

## 📁 **Desktop Shortcuts**

After running the installer, you'll have these shortcuts:
- 🚀 **Quick Launch SAGE OS** - One-click build and launch
- 🔨 **Build SAGE OS** - Build kernel only
- 🖥️ **SAGE OS Graphics** - Launch in graphics mode
- 💻 **SAGE OS Console** - Launch in console mode
- 📦 **Install Dependencies** - Setup development environment
- 📖 **Documentation** - Windows deployment guide

## 🎯 **Development Workflow**

### **Daily Development**
1. **Edit Code** - Use VS Code with WSL extension
2. **Build** - Double-click "🔨 Build SAGE OS"
3. **Test** - Double-click "🖥️ SAGE OS Graphics"

### **Quick Testing**
```cmd
# One command to build and launch
scripts\windows\quick-launch.bat
```

## 📖 **Documentation**

- **Complete Guide**: `docs\platforms\windows\WINDOWS_DEPLOYMENT_GUIDE.md`
- **Developer Guide**: `docs\platforms\windows\DEVELOPER_GUIDE.md`
- **Troubleshooting**: See guides above

## 🔒 **Security**

- Scripts require Administrator privileges for installation only
- QEMU runs in user mode (safe)
- No network access by default
- All source code is open and auditable

## 🎉 **Success Indicators**

You'll know everything is working when:
- ✅ Build completes without errors
- ✅ QEMU opens graphics window
- ✅ SAGE OS boots and shows ASCII logo
- ✅ Interactive shell responds to keyboard
- ✅ Commands like `help` and `version` work

## 💡 **Tips for Your System**

- **Intel i5-3380M** works best with i386 builds
- **4GB RAM** is sufficient but close other applications
- **Legacy BIOS** mode is fully supported
- **Hyper-V** detection indicates good virtualization support

## 🚀 **Next Steps**

1. **Run Installer**: `scripts\windows\sage-os-installer.bat`
2. **First Launch**: Double-click "🚀 Quick Launch SAGE OS"
3. **Explore Commands**: Try `help`, `version`, `ai info`
4. **Development**: Use VS Code with WSL extension
5. **Contribute**: Report Windows-specific issues

## 📞 **Support**

- **Windows Guide**: `docs\platforms\windows\WINDOWS_DEPLOYMENT_GUIDE.md`
- **Issues**: Report Windows-specific problems on GitHub
- **Community**: Join development discussions

---

**🎉 Enjoy SAGE OS on Windows!**

Your Windows 10 Pro system with Intel i5-3380M is perfectly suited for SAGE OS development and testing.