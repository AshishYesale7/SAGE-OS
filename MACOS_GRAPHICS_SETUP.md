# SAGE OS Graphics Setup for macOS M1/Intel

This guide provides complete setup instructions for running SAGE OS with graphics support on macOS, addressing common VNC and architecture issues.

## 🚨 Key Issue: Architecture Mismatch

**Problem:** Using `qemu-system-i386` with 64-bit kernels causes "format not recognized" errors.

**Solution:** Our new scripts automatically match QEMU binary with kernel architecture.

## 🚀 Quick Start (Recommended)

### 1. One-Command Setup
```bash
# Interactive launcher with auto-detection
./quick-graphics-macos.sh
```

### 2. Direct Launch Options
```bash
# Native macOS window (best performance)
./run-cocoa-macos.sh

# VNC mode (for remote access)
./run-vnc-macos.sh

# Smart build (auto-detects best architecture)
./build-graphics-smart.sh
```

## 🔧 Architecture-Specific Commands

### For 32-bit x86 (i386) - Recommended for macOS
```bash
# Build
./build-graphics-smart.sh i386

# Run with native window
./run-cocoa-macos.sh i386

# Run with VNC
./run-vnc-macos.sh i386
```

### For 64-bit x86 (x86_64)
```bash
# Build
./build-graphics-smart.sh x86_64

# Run with native window
./run-cocoa-macos.sh x86_64

# Run with VNC
./run-vnc-macos.sh x86_64
```

## 🛠️ Manual Setup

### 1. Install Dependencies
```bash
# Install QEMU
brew install qemu

# Install VNC client (optional)
brew install --cask tiger-vnc
```

### 2. Build Graphics Kernel
```bash
# Clean build
make clean

# Build for specific architecture
make ARCH=i386 TARGET=generic

# Or use smart builder
./build-graphics-smart.sh auto
```

### 3. Verify Build
```bash
# Check kernel file
file output/i386/sage-os-v1.0.1-i386-generic-graphics.elf

# Should show: ELF 32-bit LSB executable, Intel 80386
```

## 🔍 Troubleshooting Common Issues

### Issue 1: "Format not recognized" Error
**Cause:** Architecture mismatch between QEMU and kernel

**Solution:**
```bash
# Check kernel architecture
file output/*/sage-os-*.elf

# Use matching QEMU binary:
# - 32-bit kernel → qemu-system-i386
# - 64-bit kernel → qemu-system-x86_64

# Or rebuild with correct architecture
./build-graphics-smart.sh i386
```

### Issue 2: VNC "Can't control your own screen"
**Cause:** macOS Screen Sharing conflicts

**Solutions:**
```bash
# Option A: Use native Cocoa (recommended)
./run-cocoa-macos.sh

# Option B: Install third-party VNC client
brew install --cask tiger-vnc

# Option C: Use different VNC port
./run-vnc-macos.sh  # Auto-uses ports 5901+
```

### Issue 3: VNC Port Already in Use
**Cause:** macOS Screen Sharing uses port 5900

**Solution:** Our scripts automatically skip port 5900 and use 5901+
```bash
# Check what's using port 5900
sudo lsof -nP -iTCP:5900 -sTCP:LISTEN

# Our scripts automatically find free ports
./run-vnc-macos.sh
```

### Issue 4: QEMU Takes Too Long
**Cause:** Software emulation overhead on Apple Silicon

**Solutions:**
```bash
# Use native Cocoa for better performance
./run-cocoa-macos.sh

# Use i386 instead of x86_64 (faster emulation)
./build-graphics-smart.sh i386

# Increase memory allocation
qemu-system-i386 -m 256M -kernel kernel.elf -display cocoa
```

## 📊 Performance Comparison

| Mode | Performance | Setup | Best For |
|------|-------------|-------|----------|
| **Cocoa Native** | ⭐⭐⭐⭐⭐ | Easy | Development |
| **VNC (3rd party)** | ⭐⭐⭐⭐ | Medium | Remote access |
| **VNC (macOS)** | ⭐⭐⭐ | Hard | Not recommended |

## 🎯 Recommended Workflow

### For Development (Best Experience):
```bash
# 1. Build with smart detection
./build-graphics-smart.sh

# 2. Use native Cocoa window
./run-cocoa-macos.sh

# 3. Or use interactive launcher
./quick-graphics-macos.sh
```

### For Remote Access:
```bash
# 1. Build graphics kernel
./build-graphics-smart.sh i386

# 2. Install VNC client
brew install --cask tiger-vnc

# 3. Run VNC mode
./run-vnc-macos.sh i386

# 4. Connect with TigerVNC to localhost:5901
```

## 🔧 Advanced Configuration

### Custom QEMU Options
```bash
# High-performance setup
qemu-system-i386 \
  -kernel output/i386/sage-os-v1.0.1-i386-generic-graphics.elf \
  -m 256M \
  -smp 2 \
  -vga std \
  -display cocoa,show-cursor=on \
  -serial stdio \
  -no-reboot
```

### VNC with Custom Settings
```bash
# VNC with WebSocket support
qemu-system-i386 \
  -kernel output/i386/sage-os-v1.0.1-i386-generic-graphics.elf \
  -m 128M \
  -vnc 127.0.0.1:1,password=off,websocket=5701 \
  -display none
```

### Hardware Acceleration (x86_64 only)
```bash
# On Intel Macs with x86_64 kernel
qemu-system-x86_64 \
  -kernel output/x86_64/sage-os-v1.0.1-x86_64-generic.elf \
  -m 256M \
  -accel hvf \
  -display cocoa
```

## 📁 File Structure

```
SAGE-OS/
├── run-cocoa-macos.sh          # Native macOS window launcher
├── run-vnc-macos.sh            # VNC launcher with port detection
├── build-graphics-smart.sh     # Smart architecture builder
├── quick-graphics-macos.sh     # Interactive launcher
├── output/
│   ├── i386/                   # 32-bit x86 builds
│   ├── x86_64/                 # 64-bit x86 builds
│   ├── aarch64/                # ARM64 builds
│   └── ...
└── docs/platforms/macos/
    └── GRAPHICS_TROUBLESHOOTING_M1.md
```

## 🧪 Testing Different Architectures

### i386 (32-bit x86) - Recommended
```bash
./build-graphics-smart.sh i386
./run-cocoa-macos.sh i386
```

### x86_64 (64-bit x86)
```bash
./build-graphics-smart.sh x86_64
./run-cocoa-macos.sh x86_64
```

### ARM64 (for Raspberry Pi testing)
```bash
./build-graphics-smart.sh aarch64
qemu-system-aarch64 \
  -machine virt \
  -cpu cortex-a72 \
  -kernel output/aarch64/sage-os-v1.0.1-aarch64-generic.elf \
  -m 256M \
  -display cocoa
```

## 🆘 Getting Help

If you encounter issues:

1. **Check architecture match**: Ensure QEMU binary matches kernel architecture
2. **Use Cocoa mode**: Try `./run-cocoa-macos.sh` for simplest setup
3. **Update QEMU**: `brew upgrade qemu`
4. **Check build logs**: Look for compilation errors
5. **Use smart builder**: `./build-graphics-smart.sh auto`

## 📚 Related Files

- `run-cocoa-macos.sh` - Native macOS window launcher
- `run-vnc-macos.sh` - VNC launcher with auto port detection
- `build-graphics-smart.sh` - Smart architecture builder
- `quick-graphics-macos.sh` - Interactive launcher menu
- `docs/platforms/macos/GRAPHICS_TROUBLESHOOTING_M1.md` - Detailed troubleshooting

## 🎉 Success Indicators

When everything works correctly, you should see:

1. **Build Success:**
   ```
   ✅ Graphics kernel built successfully!
   ✅ Kernel architecture verified: i386
   ```

2. **Launch Success:**
   ```
   ✅ Found QEMU: QEMU emulator version 8.x.x
   ✅ Kernel architecture verified: i386
   ```

3. **SAGE OS Boot:**
   ```
   SAGE OS: Kernel starting (Graphics Mode)...
   === SAGE OS Interactive Mode ===
   sage@localhost:~$
   ```

Enjoy your SAGE OS graphics experience on macOS! 🚀