# SAGE OS UART Configuration Guide

## Raspberry Pi 5 UART Setup

SAGE OS automatically detects and configures the correct UART for your hardware. Here are the supported configurations:

### Raspberry Pi 5 (BCM2712) UART Addresses
- **Primary UART**: `0x107D001000` (Default for Pi 5)
- **Secondary UART**: `0x107D050000` (Alternative for Pi 5)

### Raspberry Pi 4 (BCM2711) UART Address
- **Primary UART**: `0xFE201000` (Fallback for Pi 4)

### QEMU Virtual Machine UART Address
- **Virtual UART**: `0x09000000` (For testing with QEMU)

## UART PCB Connection Guide

For your external UART PCB connection to Raspberry Pi 5:

### GPIO Pin Mapping (Pi 5)
- **GPIO 14 (TXD)**: Pin 8 - Connect to RX on your UART PCB
- **GPIO 15 (RXD)**: Pin 10 - Connect to TX on your UART PCB
- **Ground**: Pin 6 or 14 - Connect to GND on your UART PCB
- **3.3V Power**: Pin 1 or 17 - Connect to VCC on your UART PCB (if needed)

### Serial Settings
- **Baud Rate**: 115200
- **Data Bits**: 8
- **Stop Bits**: 1
- **Parity**: None
- **Flow Control**: None

### config.txt Settings for Pi 5

Add these lines to your `config.txt` file on the SD card:

```
# Enable UART
enable_uart=1

# Set UART clock frequency (optional, for stable baud rates)
init_uart_clock=48000000

# Disable Bluetooth to free up primary UART (recommended)
dtoverlay=disable-bt

# Alternative: Use mini UART for Bluetooth and primary UART for console
# dtoverlay=miniuart-bt
```

## Auto-Detection Process

SAGE OS will automatically:

1. **Test Raspberry Pi 5 Primary UART** (`0x107D001000`) first
2. **Test Raspberry Pi 5 Secondary UART** (`0x107D050000`) if primary fails
3. **Test Raspberry Pi 4 UART** (`0xFE201000`) for backward compatibility
4. **Test QEMU Virtual UART** (`0x09000000`) for emulation testing
5. **Default to Pi 5 Primary** if all tests fail

## Testing Your Setup

### On Real Hardware (Raspberry Pi 5)
1. Flash the SAGE OS image to SD card
2. Connect your UART PCB to GPIO pins 8, 10, and ground
3. Connect UART PCB to your computer via USB
4. Open serial terminal (115200 baud)
5. Power on Pi 5
6. You should see: `SAGE OS: Serial initialized - Raspberry Pi 5 Primary UART (0x107D001000)`

### On QEMU (for development/testing)
```bash
qemu-system-aarch64 -M virt -cpu cortex-a76 -m 4096 \
  -kernel build/arm64/kernel.elf -nographic -no-reboot
```
You should see: `SAGE OS: Serial initialized - QEMU Virtual UART (0x09000000)`

## Troubleshooting

### No Output on UART PCB
1. Check wiring: TX→RX, RX→TX, GND→GND
2. Verify baud rate is set to 115200
3. Ensure `enable_uart=1` is in config.txt
4. Try disabling Bluetooth with `dtoverlay=disable-bt`

### Wrong UART Detected
The kernel will report which UART it's using. If it detects the wrong one:
1. Check your Pi model (Pi 4 vs Pi 5)
2. Verify GPIO connections
3. Check for hardware conflicts

### QEMU Testing vs Real Hardware
- QEMU uses virtual UART at `0x09000000`
- Real Pi 5 uses physical UART at `0x107D001000`
- The same kernel binary works on both due to auto-detection

## Hardware Compatibility

✅ **Raspberry Pi 5** - Primary target, fully supported
✅ **Raspberry Pi 4** - Backward compatible
✅ **QEMU ARM64 virt** - For development and testing
✅ **External UART PCBs** - Standard 3.3V TTL serial