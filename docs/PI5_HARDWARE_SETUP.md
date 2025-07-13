# Raspberry Pi 5 Hardware Setup Guide

## 🔧 Hardware Requirements

### Essential Components
- **Raspberry Pi 5** (4GB or 8GB RAM)
- **MicroSD Card** (32GB+, Class 10, U3 recommended)
- **USB-C Power Supply** (Official Pi 5 adapter: 5V/5A)
- **UART PCB/USB-to-Serial Adapter** (for debugging)

### Optional Components
- **Heat Sink/Fan** (for sustained performance)
- **GPIO Breakout Board** (easier UART connections)
- **HDMI Cable** (for display output)
- **USB Keyboard/Mouse** (if using display)

## 🔌 UART Connection Diagram

```
Raspberry Pi 5 GPIO Layout (Top View)
                    USB-C Power
                         |
    3V3  [ 1] [ 2] 5V    |
   GPIO2 [ 3] [ 4] 5V    |
   GPIO3 [ 5] [ 6] GND   |
   GPIO4 [ 7] [ 8] GPIO14 (UART TX) ← Connect to UART RX
    GND  [ 9] [10] GPIO15 (UART RX) ← Connect to UART TX
  GPIO17 [11] [12] GPIO18
  GPIO27 [13] [14] GND ← Connect to UART GND
  GPIO22 [15] [16] GPIO23
    3V3  [17] [18] GPIO24
  GPIO10 [19] [20] GND
   GPIO9 [21] [22] GPIO25
  GPIO11 [23] [24] GPIO8
    GND  [25] [26] GPIO7
   GPIO0 [27] [28] GPIO1 (Alternative UART)
   GPIO5 [29] [30] GND
   GPIO6 [31] [32] GPIO12
  GPIO13 [33] [34] GND
  GPIO19 [35] [36] GPIO16
  GPIO26 [37] [38] GPIO20
    GND  [39] [40] GPIO21
```

### UART Wiring
```
Pi 5 Pin    Pi 5 GPIO    UART PCB    Wire Color (typical)
--------    ---------    --------    -------------------
Pin 8       GPIO 14      RX          Yellow/Orange
Pin 10      GPIO 15      TX          Green/Blue  
Pin 6       GND          GND         Black
```

## 📱 UART PCB Types

### USB-to-Serial Adapters
1. **CP2102 Module** (Recommended)
   - Voltage: 3.3V/5V selectable
   - Drivers: Usually auto-detected
   - Price: ~$5-10

2. **FTDI FT232RL**
   - Voltage: 3.3V/5V jumper
   - Excellent driver support
   - Price: ~$10-15

3. **CH340G Module**
   - Budget option
   - May need driver installation
   - Price: ~$2-5

### Connection Example (CP2102)
```
CP2102 Module    Pi 5 Connection
-------------    ---------------
VCC (3.3V)      Not connected (Pi 5 powered separately)
GND             Pin 6 (GND)
TXD             Pin 10 (GPIO 15 - RX)
RXD             Pin 8 (GPIO 14 - TX)
```

## 💾 SD Card Preparation

### Recommended SD Cards
- **SanDisk Ultra** (32GB/64GB)
- **Samsung EVO Select** (32GB/64GB)
- **Kingston Canvas Select Plus** (32GB/64GB)

### Speed Requirements
- **Minimum**: Class 10
- **Recommended**: U3 (UHS Speed Class 3)
- **Read Speed**: 90MB/s+
- **Write Speed**: 30MB/s+

### Formatting
```bash
# Linux - Format as FAT32
sudo mkfs.vfat -F 32 /dev/sdX1

# macOS - Format as FAT32
sudo diskutil eraseDisk FAT32 SAGEOS /dev/diskX

# Windows - Use Disk Management
# Right-click → Format → FAT32
```

## ⚡ Power Requirements

### Official Pi 5 Power Supply
- **Voltage**: 5V DC
- **Current**: 5A (25W)
- **Connector**: USB-C
- **Cable**: Integrated USB-C cable

### Power Consumption
- **Idle**: ~3-4W
- **Normal Load**: ~5-8W
- **Peak Load**: ~12-15W
- **With Peripherals**: Up to 25W

### Power Quality
- **Voltage Tolerance**: ±5% (4.75V - 5.25V)
- **Ripple**: <50mV
- **Stability**: Critical for reliable operation

## 🌡️ Thermal Management

### Heat Dissipation
- **Passive Cooling**: Heat sink required for sustained loads
- **Active Cooling**: Fan recommended for continuous operation
- **Thermal Throttling**: Starts at 80°C

### Cooling Solutions
1. **Official Pi 5 Case with Fan**
   - Integrated cooling
   - GPIO access
   - Price: ~$15-20

2. **Third-party Heat Sinks**
   - Aluminum/copper fins
   - Thermal adhesive
   - Price: ~$5-10

3. **Custom Cooling**
   - 5V fan on GPIO pins
   - Temperature-controlled
   - DIY solutions

## 🔍 Testing Hardware

### Power-On Self Test
1. **Red LED**: Power indicator (should be solid)
2. **Green LED**: Activity indicator (should blink during boot)
3. **No Smoke**: Verify all connections before power-on

### UART Test
```bash
# Connect UART and open terminal at 115200 baud
# You should see boot messages immediately

# Test command
echo "test" > /dev/ttyUSB0
```

### GPIO Test
```bash
# Test GPIO functionality (if needed)
# Use multimeter to verify 3.3V on GPIO pins
```

## 🛠️ Troubleshooting Hardware

### Power Issues
| Symptom | Cause | Solution |
|---------|-------|----------|
| No power LED | Insufficient power | Use official 5A adapter |
| Random reboots | Power fluctuation | Check cable/adapter |
| Won't boot | SD card issue | Reformat/reflash SD card |

### UART Issues
| Symptom | Cause | Solution |
|---------|-------|----------|
| No serial output | Wrong wiring | Check TX/RX swap |
| Garbled text | Wrong baud rate | Set to 115200 |
| No connection | Driver issue | Install UART drivers |

### SD Card Issues
| Symptom | Cause | Solution |
|---------|-------|----------|
| Won't boot | Corrupt image | Reflash with new image |
| Slow performance | Slow SD card | Use Class 10+ card |
| Read errors | Worn SD card | Replace SD card |

## 📋 Pre-Installation Checklist

### Hardware Verification
- [ ] Pi 5 board (check for damage)
- [ ] Official 5A USB-C power supply
- [ ] Quality SD card (32GB+, Class 10+)
- [ ] UART adapter (3.3V compatible)
- [ ] Proper jumper wires
- [ ] Heat sink/cooling solution

### Software Preparation
- [ ] SAGE OS ARM64 image built
- [ ] SD card flashing tool ready
- [ ] Serial terminal software installed
- [ ] UART drivers installed (if needed)

### Connection Verification
- [ ] UART wiring correct (TX→RX, RX→TX, GND→GND)
- [ ] No short circuits
- [ ] 3.3V logic levels (not 5V)
- [ ] Secure connections

## 🚀 Installation Process

### Step-by-Step
1. **Prepare SD Card**
   ```bash
   ./flash-pi5-sdcard.sh /dev/sdX
   ```

2. **Insert SD Card** into Pi 5

3. **Connect UART** (optional but recommended)

4. **Apply Power** - Pi 5 boots automatically

5. **Monitor Serial** at 115200 baud

6. **Verify Boot** - Look for SAGE OS logo

### Expected Timeline
- **SD Card Flash**: 5-10 minutes
- **First Boot**: 10-15 seconds
- **System Ready**: 20-30 seconds total

## 📞 Support

### Hardware Issues
- Check connections with multimeter
- Verify power supply voltage/current
- Test SD card on another device
- Try different UART adapter

### Software Issues
- Check serial output for error messages
- Verify image integrity
- Try rebuilding SAGE OS image
- Check SD card filesystem

---

**Ready to install SAGE OS on your Pi 5!** 🎉

For detailed software installation, see: `docs/RASPBERRY_PI_5_INSTALLATION_GUIDE.md`