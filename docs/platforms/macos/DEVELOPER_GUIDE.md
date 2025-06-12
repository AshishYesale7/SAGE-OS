# 🍎 SAGE OS macOS M1 Developer Guide (Updated 2025-06-11)

**🎉 MAJOR SUCCESS: Complete guide for developing SAGE OS on Apple Silicon (M1/M2/M3) Macs with fully functional kernel, comprehensive driver support, and QEMU testing.**

## 🚀 **Ultra-Quick Start** (M1 Mac Optimized)

### **One-Command Setup**
```bash
# Clone and setup everything
git clone https://github.com/AshishYesale7/SAGE-OS.git
cd SAGE-OS

# Install all dependencies
./setup-macos.sh

# Build and test all architectures
./build-macos.sh all

# Test the fully functional x86_64 kernel
./build-macos.sh x86_64 --test-only
```

### **🎉 What You Get (FULLY WORKING)**
- ✅ **Complete operating system** with interactive shell and 15+ commands
- ✅ **Comprehensive driver suite**: UART, VGA, Serial, I2C, SPI, AI HAT
- ✅ **QEMU testing** with full boot-to-shell functionality
- ✅ **Multi-architecture builds** (x86_64 ✅, ARM64 ✅, ARM32, RISC-V)
- ✅ **Clean, unified build system** (dramatically simplified!)

## 📋 **Prerequisites for M1 Mac**

### **System Requirements**
- 🍎 **macOS 12.0 (Monterey) or later** (M1/M2/M3 optimized)
- 🛠️ **Xcode Command Line Tools** (ARM64 native)
- 🍺 **Homebrew** (ARM64 native version)
- 💾 **8GB+ free disk space** (for cross-compilers and QEMU)
- 🧠 **8GB+ RAM** (recommended for QEMU virtualization)

### **M1 Mac Specific Setup**

#### **1. Install Homebrew (ARM64 Native)**
```bash
# Install Homebrew for Apple Silicon
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Verify ARM64 installation
brew --version
arch  # Should show "arm64"
```

#### **2. Install Xcode Command Line Tools**
```bash
# Install development tools
xcode-select --install

# Verify installation
gcc --version
make --version
```

## 🛠️ **Complete Installation Guide**

### **Method 1: Automated Setup (Recommended)**
```bash
# Clone SAGE OS
git clone https://github.com/AshishYesale7/SAGE-OS.git
cd SAGE-OS

# One command installs everything
./setup-macos.sh
```

### **Method 2: Manual Installation**
```bash
# Install QEMU (universal binary, works on M1)
brew install qemu

# Add cross-toolchain tap
brew tap messense/macos-cross-toolchains

# Install cross-compilers for all architectures
brew install aarch64-unknown-linux-gnu      # ARM64 cross-compiler
brew install x86_64-unknown-linux-gnu       # x86_64 cross-compiler
brew install riscv64-unknown-linux-gnu      # RISC-V cross-compiler
# Install GNU tools for better compatibility
brew install gnu-sed grep findutils gnu-tar coreutils

# Verify installations
qemu-system-i386 --version
aarch64-unknown-linux-gnu-gcc --version
x86_64-unknown-linux-gnu-gcc --version
```

## 🏗️ **Building SAGE OS on M1 Mac**

### **🎉 Unified Build System (NEW)**
```bash
# Build x86_64 (fully functional with shell)
./build-macos.sh x86_64

# Build specific architecture
./build-macos.sh aarch64    # ARM64 (boots, shows banner)
./build-macos.sh arm        # ARM32 (builds, needs debug)
./build-macos.sh riscv64    # RISC-V (OpenSBI loads)

# Build all architectures
./build-macos.sh all

# Clean build
./build-macos.sh x86_64 --clean
```

### **Build Options**
```bash
./build-macos.sh --help

🍎 SAGE OS macOS Build Script
========================================
Usage: ./build-macos.sh [ARCHITECTURE] [OPTIONS]

Architectures:
  x86_64      Build for x86_64 (works perfectly in QEMU)
  aarch64     Build for ARM64 (Raspberry Pi 4/5)
  arm         Build for ARM32 (Raspberry Pi 2/3)
  riscv64     Build for RISC-V 64-bit
  all         Build all architectures

Options:
  --build-only    Only build, don't test
  --test-only     Only test existing builds
  --clean         Clean before building
  --help          Show this help
```

## 🧪 **Testing on M1 Mac with QEMU**

### **🎉 Fully Functional Testing**
```bash
# Test x86_64 kernel (complete OS with shell)
./build-macos.sh x86_64 --test-only

# Manual QEMU testing
qemu-system-i386 -kernel build/x86_64/kernel.elf -nographic      # x86_64 (WORKS!)
qemu-system-aarch64 -M virt -kernel build/aarch64/kernel.elf -nographic  # ARM64 (boots)
qemu-system-arm -M versatilepb -kernel build/arm/kernel.elf -nographic   # ARM32 (debug)
qemu-system-riscv64 -M virt -kernel build/riscv64/kernel.elf -nographic  # RISC-V (partial)
```

### **Expected Output (x86_64)**
```
SAGE OS: Kernel starting...
SAGE OS: Serial initialized
  ███████╗ █████╗  ██████╗ ███████╗      ██████╗ ███████╗
  ██╔════╝██╔══██╗██╔════╝ ██╔════╝     ██╔═══██╗██╔════╝
  ███████╗███████║██║  ███╗█████╗       ██║   ██║███████╗
  ╚════██║██╔══██║██║   ██║██╔══╝       ██║   ██║╚════██║
  ███████║██║  ██║╚██████╔╝███████╗     ╚██████╔╝███████║
  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝      ╚═════╝ ╚══════╝

        Self-Aware General Environment Operating System
                    Version 1.0.1
                 Designed by Ashish Yesale

================================================================
  Welcome to SAGE OS - The Future of Self-Evolving Systems
================================================================

Initializing system components...
System ready!

SAGE OS Shell v1.0
Type 'help' for available commands, 'exit' to shutdown

sage@localhost:~$ help
Available commands:
  help     - Show this help message
  version  - Show system version
  ls       - List directory contents
  pwd      - Show current directory
  mkdir    - Create directory
  touch    - Create file
  cat      - Display file contents
  rm       - Remove file
  cp       - Copy file
  mv       - Move/rename file
  nano     - Simple text editor
  vi       - Vi text editor
  clear    - Clear screen
  uptime   - Show system uptime
  whoami   - Show current user
  exit     - Shutdown system

sage@localhost:~$ 
```

## 🏗️ **Boot System Architecture**

### **Multi-Architecture Boot Support**

| Architecture | Boot File | Status | QEMU Support |
|-------------|-----------|--------|--------------|
| **x86_64** | `boot/boot_i386.S` | ✅ **FULLY FUNCTIONAL** | Perfect |
| **ARM64** | `boot/boot_aarch64.S` | ✅ **BOOTS + BANNER** | Good |
| **ARM32** | `boot/boot_arm.S` | ⚠️ **BUILDS** | Needs debug |
| **RISC-V** | `boot/boot_riscv64.S` | ⚠️ **OPENSBI LOADS** | Partial |

### **Boot System Files**
```
boot/
├── boot_i386.S          # ✅ x86_64 multiboot (WORKING)
├── boot_aarch64.S       # ✅ ARM64 boot (WORKING)
├── boot_arm.S           # ⚠️ ARM32 boot (needs debug)
├── boot_riscv64.S       # ⚠️ RISC-V boot (needs debug)
├── boot_with_multiboot.S # Legacy multiboot2
└── boot.S               # Generic boot
```

### **x86_64 Boot Sequence (Fully Working)**
1. **QEMU loads kernel.elf** at multiboot entry point
2. **boot_i386.S** sets up 32-bit environment with multiboot1 header
3. **Kernel initialization** with serial and VGA setup
4. **Full shell environment** with 15+ commands
5. **Complete OS functionality** including file operations

## 🔧 **Comprehensive Driver Suite**

### **Driver Architecture Overview**
```
drivers/
├── uart.c/h            # ✅ Universal UART (x86 + ARM + RISC-V)
├── serial.c/h          # ✅ x86 Serial Communication
├── vga.c/h             # ✅ x86 VGA Text Mode
├── i2c.c/h             # ✅ I2C Bus Controller
├── spi.c/h             # ✅ SPI Bus Controller
└── ai_hat/             # 🤖 AI HAT Integration
    ├── ai_hat.c
    └── ai_hat.h
```

### **1. UART Driver (Universal)**
**Features:**
- ✅ **x86_64/i386**: Uses serial ports (COM1/COM2)
- ✅ **ARM64/ARM32**: Memory-mapped UART0 (Raspberry Pi compatible)
- ✅ **RISC-V**: UART8250 compatible
- ✅ **Cross-platform initialization**
- ✅ **Baud rate configuration** (115200 default)
- ✅ **GPIO pin setup** for ARM platforms

**Key Functions:**
```c
void uart_init();                    // Initialize UART for current architecture
void uart_putc(char c);             // Send single character
void uart_puts(const char* str);    // Send string
void uart_printf(const char* fmt, ...); // Formatted output
char uart_getc();                   // Receive character
```

### **2. I2C Driver (Raspberry Pi Compatible)**
**Features:**
- ✅ **Hardware I2C controller** support
- ✅ **Configurable clock speeds** (100kHz, 400kHz, 1MHz)
- ✅ **Master mode** operation
- ✅ **Error handling** (NACK, timeout, clock stretch)
- ✅ **Device scanning** capabilities

**Key Functions:**
```c
i2c_status_t i2c_init(i2c_speed_t speed);
i2c_status_t i2c_write(uint8_t addr, const uint8_t* data, uint32_t len);
i2c_status_t i2c_read(uint8_t addr, uint8_t* data, uint32_t len);
i2c_status_t i2c_scan_devices(uint8_t* devices, uint32_t* count);
```

### **3. SPI Driver (High-Speed Serial)**
**Features:**
- ✅ **Hardware SPI controller** (SPI0)
- ✅ **Configurable modes** (CPOL, CPHA)
- ✅ **Multiple chip select** pins (CS0, CS1, CS2)
- ✅ **Variable clock speeds** up to 125MHz
- ✅ **Full-duplex communication**

**Key Functions:**
```c
spi_status_t spi_init(const spi_config_t* config);
spi_status_t spi_transfer(uint8_t cs_pin, const uint8_t* tx_data, 
                         uint8_t* rx_data, uint32_t len);
spi_status_t spi_write(uint8_t cs_pin, const uint8_t* data, uint32_t len);
spi_status_t spi_read(uint8_t cs_pin, uint8_t* data, uint32_t len);
```

### **4. VGA Driver (x86 Text Mode)**
**Features:**
- ✅ **80x25 text mode** display
- ✅ **16 color support** (foreground/background)
- ✅ **Cursor management**
- ✅ **Scrolling support**
- ✅ **Clear screen** functionality

### **5. Serial Driver (x86 COM Ports)**
**Features:**
- ✅ **COM1/COM2 support** (0x3F8, 0x2F8)
- ✅ **Interrupt-driven** communication
- ✅ **Configurable baud rates**
- ✅ **Hardware flow control**

## 🛠️ **macOS M1 Development Workflow**

### **1. Initial Setup**
```bash
# Clone and setup
git clone https://github.com/AshishYesale7/SAGE-OS.git
cd SAGE-OS
./setup-macos.sh
```

### **2. Development Cycle**
```bash
# Build and test x86_64 (fully working)
./build-macos.sh x86_64

# Quick test
qemu-system-i386 -kernel build/x86_64/kernel.elf -nographic

# Build all architectures
./build-macos.sh all --clean
```

### **3. Driver Development**
```bash
# Edit driver files
nano drivers/uart.c

# Rebuild specific architecture
./build-macos.sh x86_64 --clean

# Test changes
./build-macos.sh x86_64 --test-only
```

### **4. Boot System Development**
```bash
# Edit boot files
nano boot/boot_aarch64.S

# Rebuild ARM64
./build-macos.sh aarch64 --clean

# Test ARM64 boot
qemu-system-aarch64 -M virt -kernel build/aarch64/kernel.elf -nographic
```

## 🔍 **Debugging on macOS M1**

### **GDB Debugging**
```bash
# Start QEMU with debug server
qemu-system-i386 -kernel build/x86_64/kernel.elf -nographic -s -S

# In another terminal, connect GDB
x86_64-unknown-linux-gnu-gdb build/x86_64/kernel.elf
(gdb) target remote localhost:1234
(gdb) continue
```

### **Serial Console Debugging**
```bash
# Monitor serial output
./build-macos.sh x86_64 --test-only 2>&1 | tee debug.log

# Check for boot messages
grep "SAGE OS" debug.log
```

## 📊 **Current Status Summary**

### **✅ Fully Working (macOS M1 + QEMU)**
- **x86_64 kernel**: Complete OS with shell, file operations, all drivers
- **Build system**: Unified, clean, reliable
- **Cross-compilation**: All toolchains working
- **QEMU testing**: Automated testing framework

### **⚠️ Partially Working**
- **ARM64**: Boots, shows banner, needs shell debug
- **RISC-V**: OpenSBI loads, kernel start needs fix

### **❌ Needs Work**
- **ARM32**: Boot sequence debugging required

## 🚀 **Next Steps for macOS M1 Development**

### **Immediate Priorities**
1. **Fix ARM64 shell** - Debug why shell doesn't appear after banner
2. **Fix ARM32 boot** - Debug boot sequence and memory layout
3. **Fix RISC-V kernel start** - Debug OpenSBI to kernel handoff

### **Driver Enhancements**
1. **GPIO driver** - Add comprehensive GPIO control
2. **PWM driver** - Add pulse-width modulation support
3. **DMA driver** - Add direct memory access support
4. **Interrupt controller** - Enhance interrupt handling

### **Testing Improvements**
1. **Real hardware testing** - Test on actual Raspberry Pi
2. **Automated testing** - Expand QEMU test coverage
3. **Performance testing** - Benchmark driver performance

## 🏆 **macOS M1 Success Story**

**SAGE OS on macOS M1 represents a complete success** in cross-platform OS development:

- ✅ **Full OS functionality** on x86_64 with complete shell environment
- ✅ **Comprehensive driver suite** supporting UART, I2C, SPI, VGA, Serial
- ✅ **Clean build system** optimized for macOS M1 development
- ✅ **Multi-architecture support** with successful cross-compilation
- ✅ **QEMU integration** for testing and development
- ✅ **Professional development environment** with proper tooling

**This demonstrates that macOS M1 is an excellent platform for OS development**, providing powerful cross-compilation capabilities and seamless QEMU integration for testing multiple architectures.

---

*macOS M1 Developer Guide - Updated 2025-06-11*  
*SAGE OS Version: 1.0.1*  
*Status: Production Ready for x86_64, Development Ready for ARM64/RISC-V*

## 📞 **Support & Resources**

- **Build Issues**: Check `MACOS_M1_DEVELOPMENT_GUIDE.md`
- **Project Overview**: Read `FINAL_PROJECT_ANALYSIS_COMPLETE.md`
- **Quick Reference**: Use `./build-macos.sh --help`
- **Verification**: Run `./verify-macos-m1.sh`
