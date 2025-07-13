# 🍓 SAGE OS - Raspberry Pi 5 + UART Setup Guide

## 🎯 Your Hardware Setup
- **Raspberry Pi 5 4GB** ✅
- **Waveshare CP2102 USB UART Board (Type C)** ✅
- **Female-Female Dupont Wires (x3)** ✅
- **Official Raspberry Pi 5 Active Cooler** ✅
- **16GB SD Card** ✅
- **MacBook M1** ✅

## 🚀 Quick Start

### Step 1: Prepare SD Card
```bash
# Format your 16GB SD card as FAT32
# On macOS:
diskutil list
diskutil eraseDisk FAT32 SAGE_OS /dev/diskX  # Replace X with your SD card number
```

### Step 2: Install SAGE OS
```bash
# Copy the built files to your SD card
cp output/aarch64/SAGE-OS-1.0.1-*/kernel8.img /Volumes/SAGE_OS/
cp output/aarch64/SAGE-OS-1.0.1-*/config.txt /Volumes/SAGE_OS/
```

### Step 3: UART Wiring (CP2102 ↔ Raspberry Pi 5)

#### Pin Connections
| CP2102 USB UART | Raspberry Pi 5 | Wire Color (Suggested) |
|-----------------|----------------|------------------------|
| **RXD**         | **Pin 8** (GPIO14/TXD) | Red |
| **TXD**         | **Pin 10** (GPIO15/RXD) | Yellow |
| **GND**         | **Pin 6** (GND) | Black |

#### Raspberry Pi 5 GPIO Pinout Reference
```
     3V3  (1) (2)  5V
   GPIO2  (3) (4)  5V
   GPIO3  (5) (6)  GND     ← Connect to CP2102 GND
   GPIO4  (7) (8)  GPIO14  ← Connect to CP2102 RXD (UART TX)
     GND  (9) (10) GPIO15  ← Connect to CP2102 TXD (UART RX)
  GPIO17 (11) (12) GPIO18
  GPIO27 (13) (14) GND
  GPIO22 (15) (16) GPIO23
     3V3 (17) (18) GPIO24
  GPIO10 (19) (20) GND
   GPIO9 (21) (22) GPIO25
  GPIO11 (23) (24) GPIO8
     GND (25) (26) GPIO7
   GPIO0 (27) (28) GPIO1
   GPIO5 (29) (30) GND
   GPIO6 (31) (32) GPIO12
  GPIO13 (33) (34) GND
  GPIO19 (35) (36) GPIO16
  GPIO26 (37) (38) GPIO20
     GND (39) (40) GPIO21
```

### Step 4: Connect to Mac Terminal

#### Option 1: Using `screen` (Built-in)
```bash
# Find your CP2102 device
ls /dev/tty.usbserial-*

# Connect (replace with your actual device)
screen /dev/tty.usbserial-0001 115200

# To exit screen: Ctrl+A, then K, then Y
```

#### Option 2: Using `minicom` (Install via Homebrew)
```bash
# Install minicom
brew install minicom

# Connect
minicom -D /dev/tty.usbserial-0001 -b 115200

# To exit minicom: Ctrl+A, then X
```

#### Option 3: Using `cu` (Built-in)
```bash
# Connect
cu -l /dev/tty.usbserial-0001 -s 115200

# To exit cu: ~.
```

## 🔧 Configuration Details

### SAGE OS Configuration (config.txt)
```ini
# SAGE OS Configuration for Raspberry Pi 5
arm_64bit=1
arm_freq=2400
gpu_mem=128
disable_splash=1
boot_delay=0

# UART settings for console
enable_uart=1
uart_2ndstage=1

# Kernel filename
kernel=kernel8.img

# Device tree settings
device_tree_address=0x03000000
device_tree_end=0x03100000

# Enable I2C and SPI for AI HAT+
dtparam=i2c_arm=on
dtparam=spi=on
dtparam=i2c_arm_baudrate=400000
dtparam=spi_clk_freq=20000000

# Disable Bluetooth to free up UART
dtoverlay=disable-bt

# Enable hardware-accelerated graphics
dtoverlay=vc4-kms-v3d
```

### UART Settings
- **Baud Rate**: 115200
- **Data Bits**: 8
- **Stop Bits**: 1
- **Parity**: None
- **Flow Control**: None

## 🎮 Expected Boot Sequence

### 1. Power On
- Insert SD card into RPi5
- Connect USB-C power
- Active cooler should start

### 2. UART Output
You should see:
```
SAGE OS v1.0.1 - Self-Aware General Environment
Booting on Raspberry Pi 5 (aarch64)...

Initializing UART...
Initializing memory management...
Initializing AI subsystem...
Starting shell...

SAGE-OS> _
```

### 3. Available Commands
```bash
help        # Show available commands
version     # Show OS version
meminfo     # Display memory information
clear       # Clear screen
echo [text] # Echo text
reboot      # Reboot system
ai info     # AI subsystem information
ai temp     # AI HAT+ temperature (if connected)
ai power    # AI HAT+ power status
```

## 🔍 Troubleshooting

### No UART Output
1. **Check Wiring**: Ensure RX/TX are not swapped
2. **Check Device**: `ls /dev/tty.usbserial-*`
3. **Check Permissions**: `sudo chmod 666 /dev/tty.usbserial-*`
4. **Check Config**: Ensure `enable_uart=1` in config.txt

### Boot Issues
1. **Check SD Card**: Ensure FAT32 format
2. **Check Files**: Ensure kernel8.img and config.txt are in root
3. **Check Power**: Use official RPi5 power supply
4. **Check Cooler**: Ensure active cooler is connected

### Connection Issues
1. **Driver Issues**: Install CP2102 drivers if needed
2. **Terminal Settings**: Ensure 115200 baud, 8N1
3. **Multiple Connections**: Only one terminal can connect at a time

## 🧪 Testing Your Setup

### Basic Test
```bash
# In SAGE OS shell
SAGE-OS> version
SAGE OS v1.0.1 - Self-Aware General Environment
Architecture: aarch64
Target: Raspberry Pi 5
Build: 20250713-195052

SAGE-OS> meminfo
Memory Information:
Total Memory: 4096 MB
Available Memory: 4000 MB
Kernel Memory: 96 MB

SAGE-OS> ai info
AI Subsystem Status: Initialized
AI HAT+ Status: Not Connected
Supported Precisions: FP32, FP16, INT8, INT4
```

### Interactive Test
```bash
SAGE-OS> echo Hello from SAGE OS!
Hello from SAGE OS!

SAGE-OS> help
Available commands:
  help     - Show this help message
  version  - Show OS version
  meminfo  - Display memory information
  clear    - Clear the screen
  echo     - Echo text to console
  reboot   - Reboot the system
  ai       - AI subsystem commands
```

## 🎯 Next Steps

### 1. Basic Usage
- Explore all shell commands
- Test memory management
- Monitor system status

### 2. AI HAT+ Integration (Optional)
- Connect AI HAT+ to RPi5
- Test AI acceleration features
- Load and run AI models

### 3. Development
- Modify kernel code
- Add new shell commands
- Implement custom drivers

### 4. Advanced Features
- Network connectivity
- File system support
- Graphics mode

## 📞 Support

### Common Issues
- **No output**: Check wiring and baud rate
- **Garbled text**: Check baud rate (should be 115200)
- **Boot loop**: Check SD card and power supply
- **Permission denied**: Use `sudo` for device access

### Getting Help
- Check the main README.md for general information
- Review the DEVELOPER_GUIDE.md for development setup
- Check the troubleshooting section in docs/

## 🎉 Success!

If you see the SAGE OS prompt and can execute commands, congratulations! You now have a fully functional AI-capable operating system running on your Raspberry Pi 5 with UART console access from your MacBook M1.

Your setup demonstrates:
- ✅ Custom OS kernel running on ARM64
- ✅ UART communication working
- ✅ Shell interface functional
- ✅ AI subsystem initialized
- ✅ Cross-platform development (Mac → RPi5)

This is a significant achievement in embedded systems and OS development!