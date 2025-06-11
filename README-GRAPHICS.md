# 🎨 SAGE OS Graphics Mode - Quick Guide

**Interactive graphics mode for SAGE OS with full keyboard support**

---

## 🚀 **Quick Start**

### **1. Build Graphics Kernel**
```bash
./build-graphics.sh x86_64 build
```

### **2. Run with Graphics**
```bash
qemu-system-i386 -kernel build/x86_64-graphics/kernel.elf -m 128M
```

### **3. Interact with Shell**
```
sage@localhost:~$ help
sage@localhost:~$ colors
sage@localhost:~$ demo
sage@localhost:~$ exit
```

---

## 🎯 **Key Features**

✅ **VGA Graphics**: 80x25 text mode with 16 colors  
✅ **Keyboard Input**: Full keyboard support  
✅ **Interactive Shell**: Real-time command processing  
✅ **Visual Interface**: Beautiful ASCII art and colors  
✅ **No nographic**: Full GUI experience in QEMU  

---

## 📋 **Available Commands**

- `help` - Show all commands
- `version` - System information  
- `clear` - Clear screen
- `colors` - Test color display
- `demo` - Run demo sequence
- `reboot` - Restart system
- `exit` - Shutdown

---

## 🎮 **QEMU Options**

```bash
# Basic (recommended)
qemu-system-i386 -kernel build/x86_64-graphics/kernel.elf -m 128M

# With acceleration (Linux)
qemu-system-i386 -kernel build/x86_64-graphics/kernel.elf -m 128M -enable-kvm

# With acceleration (macOS)
qemu-system-i386 -kernel build/x86_64-graphics/kernel.elf -m 128M -accel hvf

# With VNC (remote)
qemu-system-i386 -kernel build/x86_64-graphics/kernel.elf -m 128M -vnc :1
```

---

## 🔧 **Build Scripts**

- `./build-graphics.sh` - Build graphics kernel
- `./test-graphics-local.sh` - Show local test instructions
- `./build-graphics.sh help` - Show build help

---

## 🎉 **Experience**

When you run SAGE OS in graphics mode, you'll see:

1. 🎨 **Beautiful ASCII art SAGE OS logo**
2. 🌈 **Colorful welcome message**  
3. 💻 **Interactive shell prompt**
4. ⌨️ **Real keyboard input**
5. 🎯 **Visual command feedback**

**No more `-nographic` needed - enjoy the full SAGE OS visual experience!**

---

*For complete documentation, see: `GRAPHICS_MODE_GUIDE.md`*