# SAGE OS Graphics Troubleshooting for macOS M1/Intel

This guide addresses common graphics and VNC issues when running SAGE OS on macOS, particularly on Apple Silicon (M1/M2) systems.

## 🚨 Common Issues and Solutions

### Issue 1: "You can't control your own screen" VNC Error

**Problem:** macOS Screen Sharing blocks local VNC connections with this error message.

**Root Cause:** macOS's built-in Screen Sharing service conflicts with QEMU's VNC server.

**Solutions:**

#### Option A: Use Third-Party VNC Client (Recommended)
```bash
# Install a third-party VNC client
brew install --cask tiger-vnc
# or
brew install --cask vnc-viewer

# Then connect to localhost:5901 (or whatever port QEMU shows)
```

#### Option B: Use Native Cocoa Display (Best for Development)
```bash
# Use our native macOS script
./run-cocoa-macos.sh
```

#### Option C: Disable macOS Screen Sharing (Advanced)
```bash
# Only if you don't need remote access to your Mac
sudo systemsetup -setremotelogin off
sudo launchctl bootout system /System/Library/LaunchDaemons/com.apple.screensharing.plist
```

### Issue 2: VNC Port 5900 Already in Use

**Problem:** QEMU fails with "Failed to find an available port: Address already in use"

**Diagnosis:**
```bash
# Check what's using port 5900
sudo lsof -nP -iTCP:5900 -sTCP:LISTEN
```

**Solution:** Use our enhanced VNC script that automatically finds free ports:
```bash
./run-vnc-macos.sh  # Automatically uses ports 5901-5909
```

### Issue 3: QEMU Takes Too Long to Load

**Problem:** QEMU appears to hang or load very slowly on Apple Silicon.

**Causes:**
- Software emulation overhead on Apple Silicon
- Insufficient memory allocation
- VNC connection waiting for client

**Solutions:**

#### Increase Memory and Use Native Display:
```bash
# Use Cocoa for better performance
./run-cocoa-macos.sh

# Or manually with more memory
qemu-system-i386 \
  -kernel output/i386/sage-os-v1.0.1-i386-generic-graphics.elf \
  -m 256M \
  -display cocoa \
  -vga std \
  -no-reboot
```

#### Enable Hardware Acceleration (if available):
```bash
# Check if Hypervisor.framework is available
qemu-system-i386 -accel help

# Use with acceleration (x86_64 only)
qemu-system-x86_64 \
  -kernel output/x86_64/kernel.elf \
  -m 256M \
  -accel hvf \
  -display cocoa
```

### Issue 4: No Graphics Output in VNC

**Problem:** VNC connects but shows black screen or no output.

**Solutions:**

#### Check VGA Configuration:
```bash
qemu-system-i386 \
  -kernel output/i386/sage-os-v1.0.1-i386-generic-graphics.elf \
  -m 128M \
  -vga std \
  -vnc :1,password=off \
  -no-reboot
```

#### Verify Kernel Build:
```bash
# Rebuild graphics kernel
./build.sh clean
./build.sh graphics

# Check if graphics kernel exists
ls -la output/i386/sage-os-v1.0.1-i386-generic-graphics.elf
```

### Issue 5: Keyboard Input Not Working

**Problem:** Can see graphics but keyboard doesn't respond.

**Solutions:**

#### For VNC Mode:
- Ensure VNC client has focus
- Try different VNC clients (TigerVNC, RealVNC)
- Check if Caps Lock or other modifiers are stuck

#### For Cocoa Mode:
- Click in the QEMU window to capture input
- Press Escape to release mouse capture
- Use Cmd+Q to exit cleanly

## 🛠️ Recommended Setup for macOS Development

### 1. Install Dependencies
```bash
# Install QEMU via Homebrew
brew install qemu

# Install a good VNC client
brew install --cask tiger-vnc
```

### 2. Use Our Optimized Scripts

#### For Native macOS Window (Recommended):
```bash
chmod +x run-cocoa-macos.sh
./run-cocoa-macos.sh
```

#### For VNC with Automatic Port Detection:
```bash
chmod +x run-vnc-macos.sh
./run-vnc-macos.sh
```

### 3. Build Graphics Kernel
```bash
# Clean build for graphics mode
./build.sh clean
./build.sh graphics
```

## 🔧 Advanced Configuration

### Custom QEMU Options for macOS
```bash
# High-performance configuration
qemu-system-i386 \
  -kernel output/i386/sage-os-v1.0.1-i386-generic-graphics.elf \
  -m 256M \
  -smp 2 \
  -vga std \
  -display cocoa,show-cursor=on \
  -serial stdio \
  -no-reboot \
  -name "SAGE OS Development"
```

### VNC with Custom Settings
```bash
# VNC with specific options
qemu-system-i386 \
  -kernel output/i386/sage-os-v1.0.1-i386-generic-graphics.elf \
  -m 128M \
  -vga std \
  -vnc 127.0.0.1:1,password=off,websocket=5701 \
  -monitor stdio \
  -no-reboot
```

## 🧪 Testing Different Architectures

### i386 (32-bit x86) - Primary Target
```bash
./run-cocoa-macos.sh -a i386 -k output/i386/sage-os-v1.0.1-i386-generic-graphics.elf
```

### x86_64 (64-bit x86) - With Hardware Acceleration
```bash
# Build x86_64 graphics kernel first
make ARCH=x86_64 TARGET=generic

# Run with hardware acceleration
qemu-system-x86_64 \
  -kernel output/x86_64/sage-os-v1.0.1-x86_64-generic.elf \
  -m 256M \
  -accel hvf \
  -display cocoa \
  -vga std
```

### ARM64 (AArch64) - For Raspberry Pi Testing
```bash
# Build ARM64 kernel
make ARCH=aarch64 TARGET=generic

# Test in QEMU
qemu-system-aarch64 \
  -machine virt \
  -cpu cortex-a72 \
  -kernel output/aarch64/sage-os-v1.0.1-aarch64-generic.elf \
  -m 256M \
  -display cocoa \
  -serial stdio
```

## 📊 Performance Optimization

### For Apple Silicon (M1/M2):
- Use native Cocoa display instead of VNC when possible
- Allocate sufficient memory (256M recommended)
- Avoid x86_64 emulation unless necessary (use i386 or ARM64)

### For Intel Macs:
- Hardware acceleration available for x86_64
- VNC performance is generally better
- Can use larger memory allocations

## 🔍 Debugging Tips

### Enable QEMU Debug Output:
```bash
qemu-system-i386 \
  -kernel output/i386/sage-os-v1.0.1-i386-generic-graphics.elf \
  -m 128M \
  -display cocoa \
  -serial stdio \
  -d cpu_reset,guest_errors \
  -no-reboot
```

### Monitor QEMU Console:
```bash
# Add monitor for debugging
qemu-system-i386 \
  -kernel output/i386/sage-os-v1.0.1-i386-generic-graphics.elf \
  -m 128M \
  -display cocoa \
  -monitor stdio \
  -no-reboot
```

### Check Kernel Output:
```bash
# Serial output shows kernel messages
tail -f /tmp/sage-os-serial.log &
qemu-system-i386 \
  -kernel output/i386/sage-os-v1.0.1-i386-generic-graphics.elf \
  -m 128M \
  -display cocoa \
  -serial file:/tmp/sage-os-serial.log \
  -no-reboot
```

## 🆘 Getting Help

If you're still experiencing issues:

1. **Check the build**: Ensure graphics kernel builds successfully
2. **Try Cocoa mode**: Use `./run-cocoa-macos.sh` for simplest setup
3. **Update QEMU**: `brew upgrade qemu`
4. **Check logs**: Look at QEMU output and kernel messages
5. **Report issues**: Include QEMU version, macOS version, and error messages

## 📚 Related Documentation

- [macOS Setup Guide](../README.md)
- [QEMU Testing Guide](../../QEMU_MACOS_M1_COMPLETE_GUIDE.md)
- [Build System Guide](../../BUILD_SYSTEM.md)
- [Troubleshooting Guide](../../TROUBLESHOOTING.md)