# SAGE-OS Developer Guide for Raspberry Pi

## Overview

This guide provides comprehensive instructions for developing, building, and deploying SAGE-OS on Raspberry Pi devices. SAGE-OS supports Raspberry Pi 3, 4, and 5 with both development and deployment workflows.

## Supported Raspberry Pi Models

- **Raspberry Pi 5** (2023) - ARM Cortex-A76 (AArch64) ✅ **Primary Target**
- **Raspberry Pi 4** (2019) - ARM Cortex-A72 (AArch64) ✅ **Fully Supported**
- **Raspberry Pi 3** (2016) - ARM Cortex-A53 (AArch64/ARM) ✅ **Supported**
- **Raspberry Pi Zero 2 W** - ARM Cortex-A53 (AArch64) ✅ **Supported**

## Development Approaches

1. **Cross-Compilation** - Develop on PC, deploy to Pi
2. **Native Development** - Develop directly on Raspberry Pi
3. **Hybrid Approach** - Develop on PC, test on Pi

## Method 1: Cross-Compilation (Recommended)

### Prerequisites

- Development machine (Linux, macOS, or Windows with WSL2)
- Raspberry Pi device
- MicroSD card (16GB+ recommended)
- SD card reader
- Network connection for both devices

### 1. Setup Development Environment

#### On Linux/WSL2:
```bash
# Clone SAGE-OS
git clone https://github.com/Asadzero/SAGE-OS.git
cd SAGE-OS

# Install cross-compilation tools
sudo apt update
sudo apt install -y \
    gcc-aarch64-linux-gnu \
    gcc-arm-linux-gnueabihf \
    qemu-system-arm \
    qemu-user-static

# Automated setup
chmod +x build.sh
./build.sh install-deps
```

#### On macOS:
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install cross-compilation tools
brew tap messense/macos-cross-toolchains
brew install aarch64-unknown-linux-gnu
brew install arm-unknown-linux-gnueabihf
brew install qemu

# Clone and setup
git clone https://github.com/Asadzero/SAGE-OS.git
cd SAGE-OS
chmod +x build.sh
./build.sh install-deps
```

### 2. Build for Raspberry Pi

```bash
# Build for Raspberry Pi 5 (AArch64)
./build.sh build aarch64 rpi5

# Build for Raspberry Pi 4 (AArch64)
./build.sh build aarch64 rpi4

# Build for Raspberry Pi 3 (ARM 32-bit)
./build.sh build arm rpi3

# Or use make directly
make ARCH=aarch64 TARGET=rpi5
make ARCH=aarch64 TARGET=rpi4
make ARCH=arm TARGET=rpi3
```

### 3. Test in QEMU (Before Hardware Deployment)

```bash
# Test ARM64 build
qemu-system-aarch64 -M virt -cpu cortex-a72 -kernel build/aarch64/kernel.img -nographic

# Test ARM 32-bit build
qemu-system-arm -M virt -kernel build/arm/kernel.img -nographic
```

## Method 2: Native Development on Raspberry Pi

### Prerequisites

- Raspberry Pi 4 or 5 (recommended for performance)
- 32GB+ SD card
- Raspberry Pi OS (64-bit recommended)
- Internet connection

### 1. Setup Raspberry Pi OS

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install development tools
sudo apt install -y \
    build-essential \
    git \
    make \
    cmake \
    qemu-system-arm

# Clone SAGE-OS
git clone https://github.com/Asadzero/SAGE-OS.git
cd SAGE-OS
```

### 2. Build Natively

```bash
# Build for current architecture
make ARCH=aarch64

# Or use build script
./build.sh build aarch64 rpi5
```

### 3. Test Locally

```bash
# Test in QEMU on Pi
qemu-system-aarch64 -M virt -cpu cortex-a72 -kernel build/aarch64/kernel.img -nographic
```

## Hardware Deployment

### 1. Prepare SD Card

#### Automatic Method (Recommended):
```bash
# Use the deployment script
./scripts/deploy-to-pi.sh /dev/sdX aarch64 rpi5

# Where /dev/sdX is your SD card device
```

#### Manual Method:

```bash
# 1. Partition SD card
sudo fdisk /dev/sdX  # Replace X with your SD card letter

# Create partition table:
# - Delete all partitions (d)
# - Create new primary partition (n, p, 1, default, default)
# - Set partition type to FAT32 (t, c)
# - Write changes (w)

# 2. Format partition
sudo mkfs.vfat -F 32 /dev/sdX1

# 3. Mount SD card
sudo mkdir -p /mnt/sdcard
sudo mount /dev/sdX1 /mnt/sdcard
```

### 2. Install Raspberry Pi Firmware

```bash
# Download Raspberry Pi firmware
wget https://github.com/raspberrypi/firmware/archive/refs/heads/master.zip
unzip master.zip
cd firmware-master/boot

# Copy essential firmware files
sudo cp start*.elf /mnt/sdcard/
sudo cp fixup*.dat /mnt/sdcard/
sudo cp bootcode.bin /mnt/sdcard/  # For Pi 3 and earlier
```

### 3. Copy SAGE-OS Kernel

```bash
# Copy kernel image
sudo cp build/aarch64/kernel.img /mnt/sdcard/kernel8.img  # For Pi 4/5
# OR
sudo cp build/arm/kernel.img /mnt/sdcard/kernel7.img     # For Pi 3

# Copy configuration
sudo cp config_rpi5.txt /mnt/sdcard/config.txt  # For Pi 5
# OR
sudo cp config.txt /mnt/sdcard/config.txt        # For Pi 4/3
```

### 4. Configure Boot

Create or edit `/mnt/sdcard/config.txt`:

#### For Raspberry Pi 5:
```ini
# Raspberry Pi 5 Configuration
arm_64bit=1
kernel=kernel8.img
disable_overscan=1
enable_uart=1
uart_2ndstage=1

# GPU memory split
gpu_mem=64

# Enable SAGE-OS specific features
dtparam=spi=on
dtparam=i2c_arm=on

# AI HAT+ support (if available)
dtoverlay=ai-hat-plus
```

#### For Raspberry Pi 4:
```ini
# Raspberry Pi 4 Configuration
arm_64bit=1
kernel=kernel8.img
disable_overscan=1
enable_uart=1

# GPU memory split
gpu_mem=64

# Enable peripherals
dtparam=spi=on
dtparam=i2c_arm=on
```

#### For Raspberry Pi 3:
```ini
# Raspberry Pi 3 Configuration
kernel=kernel7.img
disable_overscan=1
enable_uart=1

# GPU memory split
gpu_mem=64

# Enable peripherals
dtparam=spi=on
dtparam=i2c_arm=on
```

### 5. Finalize Deployment

```bash
# Unmount SD card
sudo umount /mnt/sdcard

# Safely remove SD card
sudo eject /dev/sdX
```

## Testing on Hardware

### 1. Boot Raspberry Pi

1. Insert SD card into Raspberry Pi
2. Connect UART cable (optional, for serial console)
3. Connect power
4. Watch for boot messages

### 2. Serial Console Access

#### Hardware Setup:
- Connect USB-to-UART adapter to Pi's GPIO pins:
  - GND (Pin 6) → GND
  - GPIO 14 (Pin 8) → RX
  - GPIO 15 (Pin 10) → TX

#### Software Setup:
```bash
# On development machine
sudo apt install minicom

# Connect to serial console
sudo minicom -D /dev/ttyUSB0 -b 115200

# Or use screen
sudo screen /dev/ttyUSB0 115200
```

### 3. Expected Boot Sequence

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
                    Version 1.0.0
                 Designed by Ashish Yesale

================================================================
  Welcome to SAGE OS - The Future of Self-Evolving Systems
================================================================

Initializing system components...
System ready!

SAGE OS Shell v1.0
Type 'help' for available commands, 'exit' to shutdown

sage@localhost:~$
```

## Development Workflow

### 1. Edit-Build-Deploy Cycle

```bash
# 1. Edit code on development machine
nano kernel/kernel.c

# 2. Build for target Pi
make ARCH=aarch64 TARGET=rpi5

# 3. Test in QEMU first
qemu-system-aarch64 -M virt -cpu cortex-a72 -kernel build/aarch64/kernel.img -nographic

# 4. Deploy to SD card
sudo cp build/aarch64/kernel.img /mnt/sdcard/kernel8.img
sudo umount /mnt/sdcard

# 5. Test on hardware
# Insert SD card and boot Pi
```

### 2. Remote Development

#### Setup SSH Access (if using Raspberry Pi OS for development):
```bash
# On Raspberry Pi
sudo systemctl enable ssh
sudo systemctl start ssh

# On development machine
ssh pi@raspberrypi.local
cd SAGE-OS
```

#### Use VS Code Remote Development:
```bash
# Install VS Code with Remote-SSH extension
code --install-extension ms-vscode-remote.remote-ssh

# Connect to Pi
# Ctrl+Shift+P → "Remote-SSH: Connect to Host"
# Enter: pi@raspberrypi.local
```

## Raspberry Pi Specific Features

### 1. GPIO Access

SAGE-OS includes GPIO drivers for Raspberry Pi:

```c
// In kernel code
#include "drivers/gpio.h"

// Set GPIO pin as output
gpio_set_function(18, GPIO_OUTPUT);

// Set pin high
gpio_set(18);

// Set pin low
gpio_clear(18);
```

### 2. I2C Communication

```c
// In kernel code
#include "drivers/i2c.h"

// Initialize I2C
i2c_init();

// Read from I2C device
uint8_t data = i2c_read(0x48, 0x00);  // Read from address 0x48, register 0x00
```

### 3. SPI Communication

```c
// In kernel code
#include "drivers/spi.h"

// Initialize SPI
spi_init();

// Send data via SPI
uint8_t response = spi_transfer(0xAB);
```

### 4. AI HAT+ Integration (Raspberry Pi 5)

```bash
# In SAGE-OS shell
sage@localhost:~$ ai info
AI Subsystem Information:
- AI HAT+ Status: Connected
- Processing Power: 26 TOPS
- Memory: 8GB LPDDR5
- Temperature: 45°C
- Power Consumption: 12W

sage@localhost:~$ ai models
Loaded AI Models:
1. Classification Model (ResNet-50) - FP16
2. Object Detection (YOLO-v8) - INT8
3. Text Generation (GPT-2) - FP32
```

## Troubleshooting

### Common Issues

#### 1. Pi doesn't boot
```bash
# Check SD card formatting
sudo fsck /dev/sdX1

# Verify firmware files are present
ls /mnt/sdcard/
# Should see: start*.elf, fixup*.dat, config.txt, kernel*.img
```

#### 2. No serial output
```bash
# Check config.txt has:
enable_uart=1

# Check UART connections
# Verify baud rate (115200)
```

#### 3. Kernel panic
```bash
# Check kernel size
ls -la build/aarch64/kernel.img
# Should be reasonable size (< 10MB for basic kernel)

# Check linker script
cat linker.ld
# Verify memory layout matches Pi's memory map
```

#### 4. GPIO not working
```bash
# Check device tree overlays in config.txt
dtparam=spi=on
dtparam=i2c_arm=on

# Verify GPIO driver initialization in kernel
```

### Raspberry Pi Specific Issues

#### 1. Raspberry Pi 5 specific
```bash
# Ensure using correct firmware
# Pi 5 requires newer firmware than Pi 4

# Check config.txt for Pi 5 specific settings
arm_64bit=1
kernel=kernel8.img
```

#### 2. Power issues
```bash
# Use official Pi power supply
# Check for undervoltage warnings
# Add to config.txt if needed:
over_voltage=2
```

#### 3. SD card corruption
```bash
# Use high-quality SD card (Class 10 or better)
# Properly unmount before removing
sudo umount /mnt/sdcard
sudo eject /dev/sdX
```

## Performance Optimization

### 1. Kernel Optimization

```bash
# Build with optimizations
make ARCH=aarch64 CFLAGS="-O2 -mcpu=cortex-a72"

# For Pi 5
make ARCH=aarch64 CFLAGS="-O2 -mcpu=cortex-a76"
```

### 2. Memory Configuration

```ini
# In config.txt - optimize GPU memory split
gpu_mem=64  # Minimal for headless operation
gpu_mem=128 # For graphics applications
```

### 3. CPU Configuration

```ini
# In config.txt - CPU frequency
arm_freq=2000  # Pi 4: up to 2000MHz
arm_freq=2400  # Pi 5: up to 2400MHz

# Temperature monitoring
temp_limit=80
```

## Advanced Features

### 1. Custom Device Tree

```bash
# Create custom device tree overlay
nano sage-os-overlay.dts

# Compile device tree
dtc -@ -I dts -O dtb -o sage-os-overlay.dtbo sage-os-overlay.dts

# Copy to SD card
sudo cp sage-os-overlay.dtbo /mnt/sdcard/overlays/

# Enable in config.txt
echo "dtoverlay=sage-os-overlay" >> /mnt/sdcard/config.txt
```

### 2. Multi-Core Support

```c
// In kernel code - enable all cores
void enable_secondary_cores() {
    // Implementation for multi-core startup
    // Pi 4/5 have 4 cores available
}
```

### 3. Hardware Acceleration

```c
// Use Pi's hardware features
// - GPU for graphics/compute
// - Hardware crypto engine
// - DMA controllers
```

## Useful Commands Reference

```bash
# Development workflow
./build.sh build aarch64 rpi5     # Build for Pi 5
./build.sh build aarch64 rpi4     # Build for Pi 4
./build.sh build arm rpi3         # Build for Pi 3

# Testing
qemu-system-aarch64 -M virt -cpu cortex-a72 -kernel build/aarch64/kernel.img -nographic

# Deployment
sudo cp build/aarch64/kernel.img /mnt/sdcard/kernel8.img
sudo cp config_rpi5.txt /mnt/sdcard/config.txt

# Serial console
sudo minicom -D /dev/ttyUSB0 -b 115200
sudo screen /dev/ttyUSB0 115200

# SD card management
sudo fdisk -l                     # List storage devices
sudo mount /dev/sdX1 /mnt/sdcard  # Mount SD card
sudo umount /mnt/sdcard           # Unmount SD card
```

## Next Steps

1. **Start with QEMU**: Test builds before hardware deployment
2. **Use Pi 4/5**: Best performance for development
3. **Setup Serial Console**: Essential for debugging
4. **Explore GPIO**: Take advantage of Pi's hardware features
5. **Join Community**: Share Pi-specific improvements

## Support and Resources

- **Raspberry Pi Documentation**: [rpi.org](https://www.raspberrypi.org/documentation/)
- **SAGE-OS Pi Issues**: Report Pi-specific issues on GitHub
- **Community Forums**: Join Raspberry Pi and SAGE-OS communities
- **Hardware Datasheets**: Available on Raspberry Pi website

This guide provides comprehensive coverage of SAGE-OS development and deployment on Raspberry Pi platforms, from cross-compilation to hardware-specific features.