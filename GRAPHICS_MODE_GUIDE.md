# 🖥️ SAGE-OS Graphics Mode Guide

**Experience SAGE-OS with full graphics and keyboard interaction!**

## 🎯 **What is Graphics Mode?**

SAGE-OS Graphics Mode provides:
- ✅ **VGA text mode graphics** with colors and formatting
- ✅ **Interactive keyboard input** for real-time shell interaction
- ✅ **Beautiful ASCII art boot screen**
- ✅ **Full command shell** with 7+ interactive commands
- ✅ **Color-coded output** for better visual experience
- ✅ **Real keyboard interaction** (not just simulated)

## 🚀 **Quick Start**

### **Option 1: Using build.sh (Recommended)**
```bash
# Test graphics mode (15-second demo)
./build.sh test-graphics

# Run full graphics mode with VNC
./build.sh graphics
```

### **Option 2: Using dedicated script**
```bash
# Run demo
./run-graphics-mode.sh demo

# Run with VNC (remote access)
./run-graphics-mode.sh vnc

# Run with local graphics (macOS/Linux)
./run-graphics-mode.sh local
```

### **Option 3: Manual QEMU**
```bash
# Build graphics kernel first
./scripts/graphics/build-graphics.sh i386

# Run with VNC
qemu-system-i386 -kernel output/i386/sage-os-v1.0.1-i386-generic-graphics.img -vnc :0

# Run with local graphics
qemu-system-i386 -kernel output/i386/sage-os-v1.0.1-i386-generic-graphics.img
```

## 🖥️ **Graphics Modes Explained**

### **1. VNC Mode (Remote Access)**
- **Best for**: Remote development, headless servers, cloud environments
- **Access**: Connect VNC client to `localhost:5900`
- **Advantages**: Works anywhere, no local display needed
- **Command**: `./build.sh graphics` or `./run-graphics-mode.sh vnc`

### **2. Local Graphics Mode**
- **Best for**: Local development on macOS/Linux with display
- **Access**: Direct graphics window opens
- **Advantages**: Native performance, direct interaction
- **Command**: `./run-graphics-mode.sh local`

### **3. Demo Mode**
- **Best for**: Quick testing, CI/CD, verification
- **Access**: Text output in terminal
- **Advantages**: Fast, no graphics setup needed
- **Command**: `./build.sh test-graphics` or `./run-graphics-mode.sh demo`

## 🎮 **Interactive Commands**

Once SAGE-OS boots in graphics mode, you can use these commands:

| Command | Description | Example Output |
|---------|-------------|----------------|
| `help` | Show all available commands | Lists all commands with descriptions |
| `version` | Show system information | SAGE OS Version 1.0.1, Architecture: i386 |
| `clear` | Clear the screen | Clears VGA display |
| `colors` | Test color display | Shows all 16 VGA colors |
| `demo` | Run system demo | File system, memory, AI subsystem demo |
| `reboot` | Restart the system | Reboots via keyboard controller |
| `exit` | Shutdown system | Clean shutdown with halt |

## 🎨 **Graphics Features**

### **Boot Screen**
```
  ███████╗ █████╗  ██████╗ ███████╗      ██████╗ ███████╗
  ██╔════╝██╔══██╗██╔════╝ ██╔════╝     ██╔═══██╗██╔════╝
  ███████╗███████║██║  ███╗█████╗       ██║   ██║███████╗
  ╚════██║██╔══██║██║   ██║██╔══╝       ██║   ██║╚════██║
  ███████║██║  ██║╚██████╔╝███████╗     ╚██████╔╝███████║
  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝      ╚═════╝ ╚══════╝

        Self-Aware General Environment Operating System
                    Version 1.0.1
                 Designed by Ashish Yesale
```

### **Interactive Shell**
```
sage@localhost:~$ help
Available commands:
  help     - Show this help message
  version  - Show system version
  clear    - Clear screen
  colors   - Test color display
  reboot   - Restart system
  demo     - Run demo sequence
  exit     - Shutdown system

sage@localhost:~$ colors
Color test:
Color 00 Color 01 Color 02 Color 03 Color 04 Color 05 Color 06 Color 07 
Color 08 Color 09 Color 10 Color 11 Color 12 Color 13 Color 14 Color 15 

sage@localhost:~$ demo
Running SAGE OS Demo Sequence...

1. File System Operations:
   Creating directory: /home/sage/documents
   Creating file: welcome.txt
   Writing content to file...
   File operations completed successfully!

2. Memory Management:
   Total Memory: 128 MB
   Used Memory: 4 MB
   Free Memory: 124 MB
   Memory allocation test: PASSED

3. AI Subsystem:
   Initializing neural networks...
   Loading AI models...
   AI subsystem ready for self-learning!

Demo completed successfully!
```

## 🍎 **macOS M1 Usage**

### **Quick Start on M1 Mac**
```bash
# Clone and setup
git clone https://github.com/AshishYesale7/SAGE-OS.git
cd SAGE-OS
./build.sh setup-macos

# Run graphics mode
./build.sh graphics
```

### **VNC Connection on macOS**
```bash
# Option 1: Built-in Screen Sharing
open vnc://localhost:5900

# Option 2: VNC Viewer app
brew install --cask vnc-viewer
# Then connect to localhost:5900

# Option 3: Command line
open -a "Screen Sharing" vnc://localhost:5900
```

### **Local Graphics on macOS**
```bash
# Run with native macOS graphics window
./run-graphics-mode.sh local

# Graphics window opens directly
# Use keyboard to interact with SAGE-OS
```

## 🔧 **Technical Details**

### **Graphics Kernel Architecture**
- **Kernel**: `kernel/kernel_graphics.c` - Standalone graphics-enabled kernel
- **VGA Driver**: `drivers/vga.c` - VGA text mode with color support
- **Keyboard Driver**: Built-in PS/2 keyboard support with scancode mapping
- **Serial Output**: Dual output to both VGA and serial for debugging

### **Build Process**
1. **Compile graphics kernel**: `kernel_graphics.c` with VGA and keyboard support
2. **Link with VGA driver**: `drivers/vga.c` for display output
3. **Create bootable image**: Multiboot-compliant kernel image
4. **Output**: `output/i386/sage-os-v1.0.1-i386-generic-graphics.img`

## 🐛 **Troubleshooting**

### **Common Issues**

#### **"Graphics kernel not found"**
```bash
# Solution: Build graphics kernel
./scripts/graphics/build-graphics.sh i386
```

#### **"VNC connection refused"**
```bash
# Check if QEMU is running
ps aux | grep qemu

# Restart with VNC
./build.sh graphics
```

#### **"No keyboard input"**
- **VNC**: Make sure VNC viewer has focus
- **Local**: Click on QEMU window to focus
- **Commands**: Type commands and press Enter

## 📞 **Quick Reference**

### **Essential Commands**
```bash
# Build and test graphics
./build.sh test-graphics

# Run interactive graphics
./build.sh graphics

# Connect VNC (macOS)
open vnc://localhost:5900

# Manual run
qemu-system-i386 -kernel output/i386/sage-os-v1.0.1-i386-generic-graphics.img -vnc :0
```

### **SAGE-OS Shell Commands**
```
help      # Show commands
version   # System info
colors    # Color test
demo      # Run demo
clear     # Clear screen
exit      # Shutdown
```

**Your SAGE-OS graphics experience starts now! 🖥️✨**