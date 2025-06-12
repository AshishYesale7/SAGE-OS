# 🖥️ Complete QEMU Setup Guide for macOS M1 - SAGE-OS

## 🔍 Problem Analysis

You're experiencing issues with QEMU on macOS M1 because:

1. **Assembly Build Issues**: Fixed ✅ (assembly syntax now compatible with clang)
2. **QEMU Window Issues**: QEMU opens but doesn't load SAGE-OS properly
3. **Architecture Emulation**: M1 ARM64 emulating i386 requires specific setup

## 🛠️ Complete Solution

### Step 1: Install Proper QEMU on macOS M1

```bash
# Install QEMU with full system emulation support
brew install qemu

# Verify installation
qemu-system-i386 --version
qemu-system-x86_64 --version
```

### Step 2: Build SAGE-OS (Now Fixed!)

```bash
# Clone and build (assembly issues are now fixed)
cd /path/to/SAGE-OS
make clean
make ARCH=i386 TARGET=generic

# Verify build
ls -la build/i386/kernel.img
ls -la output/i386/
```

### Step 3: QEMU Commands That Work on M1

#### 🖥️ Graphics Mode (Recommended)
```bash
# Full graphics mode with keyboard support
qemu-system-i386 \
  -kernel build/i386/kernel.img \
  -m 128M \
  -vga std \
  -display cocoa \
  -no-reboot \
  -boot n \
  -accel tcg

# Alternative with SDL display
qemu-system-i386 \
  -kernel build/i386/kernel.img \
  -m 128M \
  -vga std \
  -display sdl \
  -no-reboot \
  -boot n
```

#### 📟 Serial Console Mode
```bash
# Serial console (what you were using)
qemu-system-i386 \
  -kernel build/i386/kernel.img \
  -m 128M \
  -nographic \
  -no-reboot \
  -boot n \
  -accel tcg
```

#### 🔧 Debug Mode
```bash
# Debug mode with monitor
qemu-system-i386 \
  -kernel build/i386/kernel.img \
  -m 128M \
  -vga std \
  -display cocoa \
  -monitor stdio \
  -no-reboot \
  -boot n \
  -d guest_errors
```

### Step 4: Why Your Previous Command Didn't Work

Your command:
```bash
qemu-system-i386 -kernel build/i386-graphics/kernel.elf -m 128M -nographic
```

**Issues:**
1. ❌ **Wrong path**: `build/i386-graphics/kernel.elf` doesn't exist
2. ❌ **Wrong file**: Should be `kernel.img`, not `kernel.elf`
3. ❌ **Missing boot flag**: Need `-boot n` to boot from kernel
4. ❌ **Missing acceleration**: Should specify `-accel tcg` on M1

**Correct command:**
```bash
qemu-system-i386 -kernel build/i386/kernel.img -m 128M -nographic -boot n -accel tcg
```

### Step 5: Graphics Mode Setup

For the full graphics experience with keyboard input:

```bash
# Create a script for easy launching
cat > run-sage-os-graphics.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting SAGE-OS in Graphics Mode..."

# Check if kernel exists
if [ ! -f "build/i386/kernel.img" ]; then
    echo "❌ Kernel not found. Building..."
    make ARCH=i386 TARGET=generic
fi

# Launch QEMU with graphics
qemu-system-i386 \
  -kernel build/i386/kernel.img \
  -m 128M \
  -vga std \
  -display cocoa \
  -no-reboot \
  -boot n \
  -accel tcg \
  -name "SAGE-OS v1.0.1"

echo "✅ SAGE-OS session ended"
EOF

chmod +x run-sage-os-graphics.sh
```

### Step 6: Troubleshooting Common Issues

#### Issue 1: "SeaBIOS" appears but SAGE-OS doesn't load
**Solution**: Use `-boot n` flag to boot directly from kernel

#### Issue 2: QEMU window opens but is black
**Solution**: 
```bash
# Try different display options
-display cocoa    # Native macOS (recommended)
-display sdl      # Cross-platform
-display gtk      # Alternative
```

#### Issue 3: No keyboard input in graphics mode
**Solution**: Click inside the QEMU window to capture input

#### Issue 4: Slow performance on M1
**Solution**: 
```bash
# Use TCG acceleration (software emulation)
-accel tcg

# Increase memory
-m 256M

# Use multiple cores
-smp 2
```

### Step 7: Advanced QEMU Configuration

#### Full-Featured Launch
```bash
qemu-system-i386 \
  -kernel build/i386/kernel.img \
  -m 256M \
  -vga std \
  -display cocoa \
  -no-reboot \
  -boot n \
  -accel tcg \
  -smp 2 \
  -name "SAGE-OS" \
  -rtc base=localtime \
  -no-hpet \
  -no-acpi
```

#### With Virtual Disk (Future)
```bash
# Create a virtual disk for file system
qemu-img create -f qcow2 sage-os-disk.qcow2 100M

qemu-system-i386 \
  -kernel build/i386/kernel.img \
  -m 256M \
  -vga std \
  -display cocoa \
  -drive file=sage-os-disk.qcow2,format=qcow2 \
  -no-reboot \
  -boot n \
  -accel tcg
```

## 🎯 Expected Results

When you run the correct command, you should see:

1. **QEMU window opens** (graphics mode) or terminal output (nographic)
2. **SAGE-OS banner** appears
3. **Interactive shell** with `sage@localhost:~$` prompt
4. **Keyboard input works** (in graphics mode)

## 🧪 Test Commands

Once SAGE-OS is running, try these commands:
```
help          # Show available commands
version       # Show SAGE-OS version
meminfo       # Show memory information
clear         # Clear screen
ls            # List files (simulated)
pwd           # Show current directory
whoami        # Show current user
uptime        # Show system uptime
```

## 🔧 Quick Fix Script

```bash
# Save this as fix-and-run.sh
#!/bin/bash
echo "🔧 SAGE-OS Quick Fix & Run Script"

# Build the kernel
echo "📦 Building SAGE-OS..."
make clean
make ARCH=i386 TARGET=generic

# Check build success
if [ -f "build/i386/kernel.img" ]; then
    echo "✅ Build successful!"
    
    # Ask user for mode
    echo "Choose mode:"
    echo "1) Graphics mode (recommended)"
    echo "2) Serial console mode"
    read -p "Enter choice (1 or 2): " choice
    
    if [ "$choice" = "1" ]; then
        echo "🖥️ Starting graphics mode..."
        qemu-system-i386 \
          -kernel build/i386/kernel.img \
          -m 128M \
          -vga std \
          -display cocoa \
          -no-reboot \
          -boot n \
          -accel tcg
    else
        echo "📟 Starting serial console mode..."
        qemu-system-i386 \
          -kernel build/i386/kernel.img \
          -m 128M \
          -nographic \
          -no-reboot \
          -boot n \
          -accel tcg
    fi
else
    echo "❌ Build failed!"
    exit 1
fi
```

## 🎉 Summary

The main issues were:
1. ✅ **Assembly syntax fixed** - Now builds properly on macOS M1
2. ✅ **Correct QEMU commands** - Added proper flags for M1
3. ✅ **Graphics mode support** - Full keyboard interaction
4. ✅ **Path corrections** - Using correct kernel.img path

Your SAGE-OS should now boot properly in QEMU on macOS M1! 🚀