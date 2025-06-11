# SAGE-OS Graphics Mode Guide

## Overview

SAGE-OS now supports both **Serial Console Mode** and **VGA Graphics Mode** for x86 architectures (i386 and x86_64). The graphics mode provides a colorful VGA text interface with full keyboard input support.

## Features

### Serial Console Mode (Default)
- Text-based interface via serial console
- Works on all architectures (i386, aarch64, x86_64, riscv64)
- Ideal for headless systems and debugging
- Full shell with file system simulation

### VGA Graphics Mode (x86 only)
- Colorful VGA text mode (80x25 characters)
- Real keyboard input support
- Interactive shell with color-coded output
- Visual feedback and enhanced user experience
- Supports both local display and VNC

## Building and Testing

### Quick Start

```bash
# Test serial mode (default)
make test-i386

# Test graphics mode
make test-i386-graphics

# Or use the script directly
./scripts/test-qemu.sh i386 generic graphics
```

### Manual Building

```bash
# Build regular kernel (serial mode)
make ARCH=i386 TARGET=generic

# Build graphics kernel
./scripts/build-graphics.sh i386 generic
```

## Available Commands

Both modes support the same command set, but graphics mode provides enhanced visual feedback:

### Basic Commands
- `help` - Show available commands (color-coded in graphics mode)
- `version` - Display system information
- `clear` - Clear screen (VGA clear in graphics mode)
- `colors` - Test color display (graphics mode only)

### System Commands
- `reboot` - Restart the system
- `exit` - Shutdown the system
- `demo` - Run demonstration sequence (enhanced in graphics mode)

### Interactive Features

#### Graphics Mode Enhancements
- **Color-coded prompts**: Green prompt, white input text
- **Syntax highlighting**: Different colors for commands, output, errors
- **Visual feedback**: Color changes for different types of information
- **Backspace support**: Visual character deletion
- **Real keyboard input**: Direct PS/2 keyboard support

## Technical Details

### Architecture Support

| Architecture | Serial Mode | Graphics Mode |
|--------------|-------------|---------------|
| i386         | ✅ Full     | ✅ Full       |
| x86_64       | ✅ Full     | ✅ Full       |
| aarch64      | ✅ Full     | ❌ N/A        |
| riscv64      | ✅ Partial  | ❌ N/A        |

### Graphics Mode Implementation

#### VGA Text Mode
- **Resolution**: 80x25 characters
- **Colors**: 16 foreground, 8 background colors
- **Memory**: Direct VGA buffer access at 0xB8000
- **Scrolling**: Automatic scroll when screen is full

#### Keyboard Input
- **Interface**: PS/2 keyboard controller
- **Ports**: Data (0x60), Status (0x64)
- **Mapping**: US QWERTY scancode to ASCII
- **Features**: Key press/release detection, special key handling

#### Color Scheme
- **Prompt**: Light Green
- **Input**: White
- **Headers**: Light Cyan
- **Warnings**: Light Brown/Yellow
- **Errors**: Light Red
- **Success**: Light Green

## QEMU Testing Options

### Serial Mode (Headless)
```bash
# Standard serial console
./scripts/test-qemu.sh i386

# Direct QEMU command
qemu-system-i386 -kernel output/i386/sage-os-v1.0.1-i386-generic.img -nographic
```

### Graphics Mode

#### Option 1: VNC (Recommended for remote)
```bash
# Start with VNC server
./scripts/test-qemu.sh i386 generic graphics

# Connect with VNC viewer
vncviewer localhost:5901
```

#### Option 2: Direct Display (Local only)
```bash
# Direct graphics output
qemu-system-i386 -kernel output/i386/sage-os-v1.0.1-i386-generic-graphics.img
```

#### Option 3: Serial + Graphics (Debug)
```bash
# Both serial and graphics output
qemu-system-i386 \
  -kernel output/i386/sage-os-v1.0.1-i386-generic-graphics.img \
  -serial stdio \
  -vnc :1
```

## File Structure

```
SAGE-OS/
├── kernel/
│   ├── kernel.c              # Serial mode kernel
│   └── kernel_graphics.c     # Graphics mode kernel
├── drivers/
│   └── vga.c                 # VGA text mode driver
├── scripts/
│   ├── test-qemu.sh          # Unified testing script
│   └── build-graphics.sh     # Graphics kernel builder
└── output/
    └── i386/
        ├── sage-os-v1.0.1-i386-generic.img          # Serial mode
        └── sage-os-v1.0.1-i386-generic-graphics.img # Graphics mode
```

## Troubleshooting

### Graphics Mode Issues

#### No Display Output
- Ensure VNC viewer is connected to correct port (5901)
- Check that graphics kernel was built correctly
- Verify x86 architecture (graphics not supported on ARM/RISC-V)

#### Keyboard Not Working
- Make sure you're using the graphics kernel build
- Check that QEMU has focus (click in QEMU window)
- Verify PS/2 keyboard emulation is enabled

#### Colors Not Showing
- Confirm VGA driver is compiled and linked
- Check terminal/VNC client color support
- Verify VGA text mode initialization

### Build Issues

#### Graphics Kernel Build Fails
```bash
# Clean and rebuild
make clean
./scripts/build-graphics.sh i386 generic
```

#### Missing Dependencies
```bash
# Install QEMU
sudo apt-get install qemu-system-x86

# Install VNC viewer
sudo apt-get install vncviewer
```

## Development Notes

### Adding New Graphics Features

1. **Extend VGA driver** (`drivers/vga.c`)
2. **Modify graphics kernel** (`kernel/kernel_graphics.c`)
3. **Update build script** (`scripts/build-graphics.sh`)
4. **Test both modes** to ensure compatibility

### Color Customization

Colors can be modified in `kernel/kernel_graphics.c`:
```c
vga_set_color(VGA_COLOR_LIGHT_GREEN | (VGA_COLOR_BLACK << 4));
```

Available colors defined in `drivers/vga.h`:
- VGA_COLOR_BLACK, VGA_COLOR_BLUE, VGA_COLOR_GREEN
- VGA_COLOR_CYAN, VGA_COLOR_RED, VGA_COLOR_MAGENTA
- VGA_COLOR_BROWN, VGA_COLOR_LIGHT_GREY, etc.

## Future Enhancements

- [ ] Mouse support
- [ ] Higher resolution graphics modes
- [ ] Window management
- [ ] Graphics primitives (lines, rectangles)
- [ ] Bitmap font rendering
- [ ] Multiple virtual terminals

## Conclusion

SAGE-OS graphics mode provides an enhanced user experience while maintaining compatibility with the serial console mode. The dual-mode approach ensures the OS works in both embedded/headless environments and desktop/development scenarios.

For questions or issues, refer to the main project documentation or create an issue in the repository.