# Raspberry Pi 5 Installation Guide - SAGE OS ARM64

## Overview
This guide provides step-by-step instructions for installing SAGE OS ARM64 on your Raspberry Pi 5 hardware, including UART setup for serial communication and debugging.

## Prerequisites

### Hardware Requirements
- **Raspberry Pi 5** (4GB or 8GB RAM recommended)
- **MicroSD Card** (32GB or larger, Class 10 or better)
- **UART PCB/USB-to-Serial Adapter** for debugging (recommended)
- **Power Supply** (Official Pi 5 USB-C adapter recommended)
- **Computer** for flashing the SD card

### Software Requirements
- **SD Card Flashing Tool**: 
  - Raspberry Pi Imager (recommended)
  - Or Balena Etcher
  - Or `dd` command on Linux/macOS
- **Serial Terminal** (for UART debugging):
  - PuTTY (Windows)
  - Screen/Minicom (Linux/macOS)
  - Arduino IDE Serial Monitor

## Step 1: Build SAGE OS ARM64 Image

First, build the latest ARM64 image:

```bash
# Clone the repository (if not already done)
git clone https://github.com/aashuyesale/SAGE-OS.git
cd SAGE-OS

# Switch to dev branch
git checkout dev

# Build ARM64 core kernel
./build-core-arm64.sh
```

The build will create:
- `build/arm64/kernel.elf` - Main kernel file
- `build/arm64/kernel8.img` - Pi 5 kernel image
- `build/arm64/boot_files/config.txt` - Boot configuration
- `build-output/arm64/SAGE-OS-*.tar.gz` - Complete bootable package

## Step 2: Prepare SD Card

### Method 1: Using Raspberry Pi Imager (Recommended)

1. **Download and Install Raspberry Pi Imager**
   - Download from: https://www.raspberrypi.org/software/
   - Install on your computer

2. **Flash Custom Image**
   - Insert SD card into your computer
   - Open Raspberry Pi Imager
   - Click "CHOOSE OS" → "Use custom image"
   - Select the `.img` file from `build-output/arm64/`
   - Click "CHOOSE STORAGE" and select your SD card
   - Click "WRITE" and wait for completion

### Method 2: Manual Installation

1. **Format SD Card**
   ```bash
   # Linux/macOS - replace /dev/sdX with your SD card device
   sudo fdisk /dev/sdX
   # Create FAT32 partition for boot files
   
   # Windows - use Disk Management or diskpart
   ```

2. **Extract Boot Files**
   ```bash
   # Extract the built package
   cd build-output/arm64/
   tar -xzf SAGE-OS-1.0.1-*-arm64-rpi5-core.tar.gz
   
   # Copy files to SD card boot partition
   cp SAGE-OS-*/config.txt /media/boot/
   cp SAGE-OS-*/kernel8.img /media/boot/
   cp SAGE-OS-*/kernel.elf /media/boot/
   ```

### Method 3: Using dd Command (Linux/macOS)

```bash
# Find your SD card device
lsblk  # or diskutil list on macOS

# Flash the image (replace /dev/sdX with your SD card)
sudo dd if=build-output/arm64/SAGE-OS-*.img of=/dev/sdX bs=4M status=progress
sudo sync
```

## Step 3: UART Setup for Serial Communication

### Hardware Connections

**Raspberry Pi 5 GPIO UART Pins:**
- **GPIO 14 (Pin 8)** - UART TX (Primary UART: 0x107D001000)
- **GPIO 15 (Pin 10)** - UART RX (Primary UART: 0x107D001000)
- **GPIO 0 (Pin 27)** - UART TX (Secondary UART: 0x107D050000)
- **GPIO 1 (Pin 28)** - UART RX (Secondary UART: 0x107D050000)
- **Pin 6 or 9** - Ground (GND)

**UART PCB Connection:**
```
Pi 5 GPIO    UART PCB
---------    --------
GPIO 14  →   RX
GPIO 15  →   TX  
GND      →   GND
```

### UART Configuration

The SAGE OS kernel automatically detects UART hardware:
- **Primary UART**: 0x107D001000 (Pi 5 default)
- **Secondary UART**: 0x107D050000 (Pi 5 alternative)
- **Fallback UART**: 0xFE201000 (Pi 4 compatibility)

**Serial Settings:**
- **Baud Rate**: 115200
- **Data Bits**: 8
- **Parity**: None
- **Stop Bits**: 1
- **Flow Control**: None

## Step 4: Boot Configuration

### config.txt Settings

The build automatically creates an optimized `config.txt`:

```ini
# SAGE OS Raspberry Pi 5 Configuration
# Generated automatically by build system

# Basic Pi 5 settings
arm_64bit=1
kernel=kernel8.img

# Memory settings
gpu_mem=64
arm_freq=2400

# UART settings for debugging
enable_uart=1
uart_2ndstage=1

# USB and boot settings
usb_max_current_enable=1
boot_delay=1

# Display settings (if using HDMI)
hdmi_force_hotplug=1
hdmi_drive=2

# Performance settings
over_voltage=2
arm_freq_min=1000

# SAGE OS specific settings
# Enable all UARTs for debugging
dtparam=uart0=on
dtparam=uart1=on
```

## Step 5: First Boot

### Insert SD Card and Power On

1. **Insert SD Card** into Raspberry Pi 5
2. **Connect UART** (if using serial debugging)
3. **Connect Power** - Pi 5 will boot automatically

### Expected Boot Sequence

**Serial Output (115200 baud):**
```
SAGE OS: Kernel entry point reached
SAGE OS: Serial initialized
SAGE OS: Multi-UART detection starting...
SAGE OS: Testing UART at 0x107D001000... SUCCESS
SAGE OS: Pi 5 Primary UART detected and configured
SAGE OS: Kernel starting...

  ███████╗ █████╗  ██████╗ ███████╗      ██████╗ ███████╗
  ██╔════╝██╔══██╗██╔════╝ ██╔════╝     ██╔═══██╗██╔════╝
  ███████╗███████║██║  ███╗█████╗       ██║   ██║███████╗
  ╚════██║██╔══██║██║   ██║██╔══╝       ██║   ██║╚════██║
  ███████║██║  ██║╚██████╔╝███████╗     ╚██████╔╝███████║
  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝      ╚═════╝ ╚══════╝

        Self-Aware General Environment Operating System
                    Version 1.0.1 (ARM64)
                 Designed by Ashish Yesale

================================================================
  Welcome to SAGE OS - The Future of Self-Evolving Systems
================================================================

Initializing system components...
File system: READY
Memory management: READY
Shell: READY

sage@rpi5:~$ 
```

## Step 6: Testing File Management Commands

Once booted, test the file management system:

### Basic Commands
```bash
# Display help
help

# Show current directory
pwd

# List files
ls

# Create a file
save hello.txt "Hello from SAGE OS on Pi 5!"

# Display file contents
cat hello.txt

# Append to file
append hello.txt "This is running on real hardware!"

# Show file information
fileinfo hello.txt

# List files again
ls

# Show memory information
meminfo

# Show system version
version

# Show uptime
uptime
```

### Advanced File Operations
```bash
# Create multiple files
save config.cfg "debug=true\nverbose=true"
save readme.md "# SAGE OS on Pi 5\nRunning successfully!"

# List all files
ls

# Display different file contents
cat config.cfg
cat readme.md

# Delete a file
delete hello.txt

# Verify deletion
ls
```

## Step 7: Serial Terminal Setup

### Windows (PuTTY)
1. Download PuTTY from https://putty.org/
2. Open PuTTY
3. Connection type: Serial
4. Serial line: COM3 (or your UART port)
5. Speed: 115200
6. Click "Open"

### Linux/macOS (Screen)
```bash
# Find UART device
ls /dev/tty*

# Connect with screen
screen /dev/ttyUSB0 115200

# Or use minicom
minicom -D /dev/ttyUSB0 -b 115200
```

### Arduino IDE Serial Monitor
1. Open Arduino IDE
2. Tools → Port → Select your UART port
3. Tools → Serial Monitor
4. Set baud rate to 115200

## Troubleshooting

### Boot Issues

**Problem**: No serial output
**Solution**: 
- Check UART connections (TX/RX might be swapped)
- Verify baud rate is 115200
- Ensure `enable_uart=1` in config.txt

**Problem**: Kernel doesn't load
**Solution**:
- Check SD card formatting (FAT32 for boot partition)
- Verify kernel8.img is present
- Check config.txt syntax

**Problem**: System hangs during boot
**Solution**:
- Try different SD card
- Check power supply (Pi 5 needs adequate power)
- Verify ARM64 build completed successfully

### UART Issues

**Problem**: Garbled serial output
**Solution**:
- Check baud rate (must be 115200)
- Verify ground connection
- Try different UART pins (GPIO 0/1 instead of 14/15)

**Problem**: No UART detection
**Solution**:
- SAGE OS will automatically fallback to different UART addresses
- Check serial output for UART detection messages
- Verify UART PCB is working

### File System Issues

**Problem**: Files not saving
**Solution**:
- SAGE OS uses in-memory file system
- Files are lost on reboot (this is normal)
- Check available memory with `meminfo`

## Hardware Compatibility

### Tested Configurations
- ✅ Raspberry Pi 5 (4GB/8GB)
- ✅ Official Pi 5 Power Supply
- ✅ SanDisk Ultra 32GB microSD
- ✅ Generic USB-to-Serial UART adapters
- ✅ Official Pi GPIO UART PCBs

### Performance Expectations
- **Boot Time**: ~3-5 seconds
- **Shell Response**: Immediate
- **File Operations**: <1ms for small files
- **Memory Usage**: ~2-4MB kernel footprint

## Next Steps

1. **Explore Commands**: Try all available shell commands
2. **File Management**: Create, edit, and manage files
3. **Development**: Use UART for kernel debugging
4. **Customization**: Modify kernel and rebuild for specific needs

## Support

For issues or questions:
- Check the main SAGE OS documentation
- Review troubleshooting section above
- Verify hardware connections
- Check serial output for error messages

---

**SAGE OS ARM64 for Raspberry Pi 5**  
Version 1.0.1 | Build Date: 2025-07-13  
Copyright © 2025 Ashish Vasant Yesale  
Licensed under BSD-3-Clause OR Proprietary