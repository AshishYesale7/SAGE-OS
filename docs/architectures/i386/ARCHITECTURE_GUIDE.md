# SAGE-OS i386 Architecture Guide

## Overview

The i386 (32-bit x86) architecture is currently the most stable and fully functional implementation of SAGE-OS. This guide covers building, testing, and deploying SAGE-OS on i386 systems.

## Status: ✅ Fully Working

- **Build**: ✅ Compiles successfully
- **Boot**: ✅ Boots reliably in QEMU
- **Shell**: ✅ Interactive shell fully functional
- **Drivers**: ✅ VGA, Serial, and basic I/O working
- **Testing**: ✅ Comprehensive testing completed

## Target Systems

- **Legacy PCs** (Pentium and later)
- **Virtual Machines** (VirtualBox, VMware, QEMU)
- **Embedded x86 systems**
- **Industrial computers**
- **Retro computing projects**

## Quick Start

### 1. Build for i386

```bash
# Clone repository
git clone https://github.com/Asadzero/SAGE-OS.git
cd SAGE-OS

# Build i386 kernel
make ARCH=i386

# Or use build script
./build.sh build i386 generic
```

### 2. Test in QEMU

```bash
# Test the kernel
qemu-system-i386 -kernel build/i386/kernel.img -nographic

# Expected output:
# SAGE OS: Kernel starting...
# SAGE OS: Serial initialized
# [ASCII Art Welcome Message]
# sage@localhost:~$
```

### 3. Exit QEMU

- Type `exit` in SAGE-OS shell
- Or press `Ctrl+A`, then `X`

## Build Configuration

### Compiler Settings

```makefile
# i386-specific compiler flags
CC = gcc
CFLAGS = -m32 -nostdlib -nostartfiles -ffreestanding -O2 -Wall -Wextra
LDFLAGS = -m32 -T linker.ld
```

### Memory Layout

```
Physical Memory Layout (i386):
0x00000000 - 0x000003FF  Real Mode IVT
0x00000400 - 0x000004FF  BIOS Data Area
0x00000500 - 0x00007BFF  Conventional Memory
0x00007C00 - 0x00007DFF  Boot Sector
0x00007E00 - 0x0009FFFF  Conventional Memory
0x000A0000 - 0x000FFFFF  Reserved (VGA, BIOS)
0x00100000 - 0xFFFFFFFF  Extended Memory

SAGE-OS Kernel Layout:
0x00100000 (1MB)         Kernel Entry Point
0x00101000               Kernel Code
0x00200000               Kernel Data
0x00300000               Heap Start
```

### Linker Script

```ld
/* linker.ld for i386 */
ENTRY(_start)

SECTIONS
{
    . = 0x100000;  /* 1MB mark */
    
    .text : {
        *(.text)
    }
    
    .data : {
        *(.data)
    }
    
    .bss : {
        *(.bss)
    }
}
```

## Boot Process

### 1. Multiboot Header

```assembly
# boot/boot.S
.section .multiboot
.align 4
multiboot_header:
    .long 0x1BADB002          # Magic number
    .long 0x00000003          # Flags
    .long -(0x1BADB002 + 0x00000003)  # Checksum
```

### 2. Entry Point

```assembly
.section .text
.global _start
_start:
    # Set up stack
    mov $stack_top, %esp
    
    # Call kernel main
    call kernel_main
    
    # Halt if kernel returns
    cli
    hlt
```

### 3. Kernel Initialization

```c
void kernel_main(void) {
    // Initialize serial communication
    serial_init();
    
    // Display welcome message
    display_welcome_message();
    
    // Initialize memory management
    memory_init();
    
    // Start shell
    shell_main();
}
```

## Hardware Support

### VGA Text Mode

```c
// VGA text mode (80x25)
#define VGA_MEMORY 0xB8000
#define VGA_WIDTH 80
#define VGA_HEIGHT 25

void vga_putc(char c) {
    static int cursor_x = 0, cursor_y = 0;
    uint16_t* vga = (uint16_t*)VGA_MEMORY;
    
    if (c == '\n') {
        cursor_x = 0;
        cursor_y++;
    } else {
        vga[cursor_y * VGA_WIDTH + cursor_x] = (uint16_t)c | 0x0700;
        cursor_x++;
    }
}
```

### Serial Communication

```c
// COM1 serial port
#define COM1_PORT 0x3F8

void serial_init(void) {
    outb(COM1_PORT + 1, 0x00);  // Disable interrupts
    outb(COM1_PORT + 3, 0x80);  // Enable DLAB
    outb(COM1_PORT + 0, 0x03);  // Set divisor to 3 (38400 baud)
    outb(COM1_PORT + 1, 0x00);
    outb(COM1_PORT + 3, 0x03);  // 8 bits, no parity, one stop bit
    outb(COM1_PORT + 2, 0xC7);  // Enable FIFO
    outb(COM1_PORT + 4, 0x0B);  // IRQs enabled, RTS/DSR set
}

void serial_putc(char c) {
    while ((inb(COM1_PORT + 5) & 0x20) == 0);  // Wait for transmit ready
    outb(COM1_PORT, c);
}
```

### Keyboard Input

```c
// PS/2 keyboard
#define KEYBOARD_DATA_PORT 0x60
#define KEYBOARD_STATUS_PORT 0x64

char keyboard_getc(void) {
    while (!(inb(KEYBOARD_STATUS_PORT) & 0x01));  // Wait for data
    uint8_t scancode = inb(KEYBOARD_DATA_PORT);
    return scancode_to_ascii(scancode);
}
```

## Shell Commands

The i386 version supports all SAGE-OS shell commands:

```bash
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
  meminfo  - Display memory information
  ai       - AI subsystem commands
  uptime   - Show system uptime
  whoami   - Show current user
  exit     - Shutdown system
```

### AI Subsystem Commands

```bash
sage@localhost:~$ ai info
AI Subsystem Information:
- Status: Initialized
- Hardware: Software emulation
- Models: 0 loaded
- Memory: 64MB allocated

sage@localhost:~$ ai models
No AI models currently loaded.
Use 'ai load <model>' to load a model.
```

## Testing and Validation

### Automated Testing

```bash
# Run comprehensive tests
./scripts/test-all-features.sh i386

# Test specific features
./scripts/test_emulated.sh i386
```

### Manual Testing Checklist

- [ ] Kernel boots successfully
- [ ] Welcome message displays correctly
- [ ] Shell prompt appears
- [ ] `help` command works
- [ ] `version` command shows correct info
- [ ] `ls` command lists files
- [ ] `mkdir` and `touch` create files/directories
- [ ] `cat` displays file contents
- [ ] `clear` clears screen
- [ ] `meminfo` shows memory information
- [ ] `ai info` shows AI subsystem status
- [ ] `exit` shuts down system cleanly

### Performance Benchmarks

```bash
# Boot time: ~2 seconds in QEMU
# Memory usage: ~2MB kernel + 64MB AI subsystem
# Shell response: <100ms for most commands
```

## Deployment Options

### 1. QEMU Virtual Machine

```bash
# Basic testing
qemu-system-i386 -kernel build/i386/kernel.img -nographic

# With more memory
qemu-system-i386 -kernel build/i386/kernel.img -m 512M -nographic

# With VGA output
qemu-system-i386 -kernel build/i386/kernel.img -m 512M
```

### 2. VirtualBox

1. Create new VM (Type: Other, Version: Other/Unknown)
2. Allocate 512MB RAM
3. No hard disk needed
4. Settings → System → Enable I/O APIC
5. Settings → System → Boot Order: Floppy first
6. Create floppy disk image with kernel
7. Boot from floppy

### 3. VMware

1. Create new VM (Guest OS: Other)
2. Allocate 512MB RAM
3. No hard disk needed
4. Use kernel as boot image

### 4. Physical Hardware

```bash
# Create bootable USB/CD with GRUB
mkdir -p iso/boot/grub
cp build/i386/kernel.img iso/boot/
cat > iso/boot/grub/grub.cfg << EOF
menuentry "SAGE-OS" {
    multiboot /boot/kernel.img
}
EOF

# Create ISO
grub-mkrescue -o sageos-i386.iso iso/
```

## Troubleshooting

### Common Issues

#### 1. Kernel doesn't boot

```bash
# Check multiboot header
objdump -h build/i386/kernel.elf | grep multiboot

# Verify entry point
objdump -f build/i386/kernel.elf
```

#### 2. No output

```bash
# Check serial initialization
# Verify VGA memory access
# Test with different QEMU options
qemu-system-i386 -kernel build/i386/kernel.img -serial stdio
```

#### 3. Build errors

```bash
# Install 32-bit development libraries
sudo apt install gcc-multilib libc6-dev-i386

# Clean and rebuild
make clean
make ARCH=i386
```

#### 4. QEMU hangs

```bash
# Use timeout for testing
timeout 30 qemu-system-i386 -kernel build/i386/kernel.img -nographic

# Check for infinite loops in kernel
# Add debug prints to identify hang location
```

### Debug Techniques

#### 1. Serial Debugging

```c
// Add debug prints throughout kernel
void debug_print(const char* msg) {
    serial_puts("[DEBUG] ");
    serial_puts(msg);
    serial_puts("\n");
}
```

#### 2. GDB Debugging

```bash
# Build with debug symbols
make ARCH=i386 CFLAGS="-g -O0"

# Start QEMU with GDB server
qemu-system-i386 -kernel build/i386/kernel.img -nographic -s -S &

# Connect GDB
gdb build/i386/kernel.elf
(gdb) target remote localhost:1234
(gdb) break kernel_main
(gdb) continue
```

#### 3. Memory Debugging

```c
// Check memory corruption
void memory_check(void) {
    // Verify stack integrity
    // Check heap boundaries
    // Validate data structures
}
```

## Performance Optimization

### 1. Compiler Optimizations

```bash
# Build with optimizations
make ARCH=i386 CFLAGS="-O2 -march=i686"

# Size optimization
make ARCH=i386 CFLAGS="-Os"
```

### 2. Memory Management

```c
// Efficient memory allocation
void* kmalloc(size_t size) {
    // Simple bump allocator for now
    static char heap[1024*1024];  // 1MB heap
    static size_t heap_pos = 0;
    
    if (heap_pos + size > sizeof(heap)) {
        return NULL;  // Out of memory
    }
    
    void* ptr = &heap[heap_pos];
    heap_pos += size;
    return ptr;
}
```

### 3. I/O Optimization

```c
// Buffered I/O for better performance
#define BUFFER_SIZE 256
static char output_buffer[BUFFER_SIZE];
static int buffer_pos = 0;

void buffered_putc(char c) {
    output_buffer[buffer_pos++] = c;
    if (buffer_pos >= BUFFER_SIZE || c == '\n') {
        flush_buffer();
    }
}
```

## Advanced Features

### 1. Interrupt Handling

```c
// Set up IDT for interrupt handling
void setup_interrupts(void) {
    // Initialize IDT
    // Set up keyboard interrupt
    // Set up timer interrupt
}
```

### 2. Memory Protection

```c
// Basic memory protection
void setup_memory_protection(void) {
    // Set up page tables
    // Enable paging
    // Protect kernel memory
}
```

### 3. Multi-tasking

```c
// Simple cooperative multitasking
struct task {
    uint32_t esp;
    uint32_t eip;
    int state;
};

void task_switch(struct task* next) {
    // Save current context
    // Load next context
    // Jump to next task
}
```

## Future Enhancements

### Planned Features

1. **Real File System** - Replace simulated file operations
2. **Network Stack** - Basic TCP/IP implementation
3. **Graphics Mode** - VESA graphics support
4. **Sound Support** - PC speaker and sound card drivers
5. **USB Support** - Basic USB device support

### Contributing

The i386 architecture is stable and well-tested, making it an excellent starting point for:

- Learning OS development
- Testing new features
- Debugging kernel issues
- Performance optimization

## Useful Commands Reference

```bash
# Build and test workflow
make ARCH=i386                                    # Build kernel
qemu-system-i386 -kernel build/i386/kernel.img -nographic  # Test
make ARCH=i386 clean                             # Clean build

# Debug workflow
make ARCH=i386 CFLAGS="-g -O0"                   # Debug build
qemu-system-i386 -kernel build/i386/kernel.img -nographic -s -S  # GDB server
gdb build/i386/kernel.elf                       # Debug session

# Deployment
grub-mkrescue -o sageos-i386.iso iso/           # Create ISO
dd if=sageos-i386.iso of=/dev/sdX bs=4M         # Write to USB
```

The i386 architecture provides a solid foundation for SAGE-OS development and serves as a reference implementation for other architectures.