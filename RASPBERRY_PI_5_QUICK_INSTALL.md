# SAGE OS Pi 5 - Quick Installation Reference

## 🚀 Quick Start (5 Minutes)

### 1. Build Image
```bash
git clone https://github.com/aashuyesale/SAGE-OS.git
cd SAGE-OS && git checkout dev
./build-core-arm64.sh
```

### 2. Flash SD Card
```bash
# Use Raspberry Pi Imager with custom image:
# build-output/arm64/SAGE-OS-*.img
```

### 3. UART Setup (Optional but Recommended)
```
Pi 5 GPIO 14 (Pin 8)  → UART RX
Pi 5 GPIO 15 (Pin 10) → UART TX  
Pi 5 GND (Pin 6)      → UART GND
```

### 4. Boot & Test
```bash
# Serial: 115200 baud, 8N1
# Expected: ASCII logo + shell prompt
sage@rpi5:~$ help
```

## 📁 File Management Commands

| Command | Description | Example |
|---------|-------------|---------|
| `save <file> <content>` | Create file | `save test.txt "Hello Pi 5!"` |
| `cat <file>` | Show content | `cat test.txt` |
| `ls` | List files | `ls` |
| `append <file> <text>` | Add to file | `append test.txt "More text"` |
| `delete <file>` | Remove file | `delete test.txt` |
| `fileinfo <file>` | File details | `fileinfo test.txt` |
| `pwd` | Current dir | `pwd` |

## 🔧 System Commands

| Command | Description |
|---------|-------------|
| `help` | Show all commands |
| `version` | OS version info |
| `meminfo` | Memory status |
| `uptime` | System uptime |
| `clear` | Clear screen |
| `reboot` | Restart system |

## 🔌 UART Addresses (Auto-detected)

- **Primary**: `0x107D001000` (Pi 5 default)
- **Secondary**: `0x107D050000` (Pi 5 alt)
- **Fallback**: `0xFE201000` (Pi 4 compat)

## 📋 Boot Files

```
SD Card Root:
├── config.txt      # Pi 5 configuration
├── kernel8.img     # ARM64 kernel
└── kernel.elf      # Debug symbols
```

## ⚡ Expected Boot Output

```
SAGE OS: Kernel entry point reached
SAGE OS: Pi 5 Primary UART detected
[ASCII LOGO]
sage@rpi5:~$ 
```

## 🛠️ Troubleshooting

| Issue | Solution |
|-------|----------|
| No serial output | Check UART wiring, 115200 baud |
| Won't boot | Verify SD card format, kernel8.img present |
| Garbled text | Wrong baud rate or loose connections |
| No files saving | Normal - in-memory filesystem |

---
**Ready to run SAGE OS on your Pi 5!** 🎉