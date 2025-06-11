/* SAGE OS Kernel - Standalone Version */

#include "../drivers/vga.h"

#if defined(__x86_64__) || defined(__i386__)
// I/O port functions for x86
static inline void outb(unsigned short port, unsigned char value) {
    __asm__ volatile ("outb %0, %1" : : "a"(value), "Nd"(port));
}

static inline unsigned char inb(unsigned short port) {
    unsigned char ret;
    __asm__ volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

// Keyboard support
#define KEYBOARD_DATA_PORT 0x60
#define KEYBOARD_STATUS_PORT 0x64

// Simple scancode to ASCII mapping for US keyboard
static char scancode_to_ascii[128] = {
    0,  27, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '\b',
    '\t', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n',
    0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`',
    0, '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0,
    '*', 0, ' ', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

char keyboard_getchar() {
    unsigned char scancode;
    
    // Wait for keyboard data
    while (!(inb(KEYBOARD_STATUS_PORT) & 1));
    
    scancode = inb(KEYBOARD_DATA_PORT);
    
    // Only handle key press events (bit 7 clear)
    if (scancode & 0x80) {
        return 0; // Key release, ignore
    }
    
    return scancode_to_ascii[scancode];
}

// Serial port functions for x86
void serial_init() {
    outb(0x3F8 + 1, 0x00);    // Disable interrupts
    outb(0x3F8 + 3, 0x80);    // Enable DLAB
    outb(0x3F8 + 0, 0x03);    // Set divisor to 3 (38400 baud)
    outb(0x3F8 + 1, 0x00);    // High byte
    outb(0x3F8 + 3, 0x03);    // 8 bits, no parity, one stop bit
    outb(0x3F8 + 2, 0xC7);    // Enable FIFO
    outb(0x3F8 + 4, 0x0B);    // IRQs enabled, RTS/DSR set
}

void serial_putc(char c) {
    while ((inb(0x3F8 + 5) & 0x20) == 0);
    outb(0x3F8, c);
}

void serial_puts(const char* str) {
    while (*str) {
        serial_putc(*str++);
    }
}

#elif defined(__aarch64__)
// AArch64 UART functions for QEMU virt machine
#define UART0_BASE 0x09000000
#define UART_DR    (UART0_BASE + 0x00)
#define UART_FR    (UART0_BASE + 0x18)
#define UART_FR_TXFF (1 << 5)

static inline void mmio_write(unsigned long addr, unsigned int value) {
    *(volatile unsigned int*)addr = value;
}

static inline unsigned int mmio_read(unsigned long addr) {
    return *(volatile unsigned int*)addr;
}

void serial_init() {
    // UART is already initialized by QEMU
}

void serial_putc(char c) {
    // Wait until transmit FIFO is not full
    while (mmio_read(UART_FR) & UART_FR_TXFF);
    mmio_write(UART_DR, c);
}

void serial_puts(const char* str) {
    while (*str) {
        serial_putc(*str++);
    }
}

#elif defined(__riscv)
// RISC-V UART functions for QEMU virt machine
#define UART0_BASE 0x10000000
#define UART_THR   (UART0_BASE + 0x00)
#define UART_LSR   (UART0_BASE + 0x05)
#define UART_LSR_THRE (1 << 5)

static inline void mmio_write_8(unsigned long addr, unsigned char value) {
    *(volatile unsigned char*)addr = value;
}

static inline unsigned char mmio_read_8(unsigned long addr) {
    return *(volatile unsigned char*)addr;
}

void serial_init() {
    // UART is already initialized by QEMU
}

void serial_putc(char c) {
    // Wait until transmit holding register is empty
    while (!(mmio_read_8(UART_LSR) & UART_LSR_THRE));
    mmio_write_8(UART_THR, c);
}

void serial_puts(const char* str) {
    while (*str) {
        serial_putc(*str++);
    }
}

#else
// Generic ARM/other architectures - placeholder
void serial_init() {
    // Generic serial initialization
}

void serial_putc(char c) {
    // Generic serial output - do nothing for now
    (void)c;
}

void serial_puts(const char* str) {
    // Generic serial output - do nothing for now
    (void)str;
}
#endif

// Unified output functions that write to both VGA and serial
void console_putc(char c) {
    serial_putc(c);  // Always write to serial
#if defined(__x86_64__) || defined(__i386__)
    vga_putc(c);     // Also write to VGA if available
#endif
}

void console_puts(const char* str) {
    while (*str) {
        console_putc(*str++);
    }
}

// Simple string comparison (removed - using stdio.c version)

// Forward declarations
void process_command(const char* cmd);
int strcmp(const char* str1, const char* str2); // From stdio.c

#if defined(__x86_64__) || defined(__i386__)
// Interactive shell function (only for x86 with keyboard support)
void interactive_shell() {
    char input_buffer[256];
    int buffer_pos = 0;
    char c;
    
    console_puts("\n=== SAGE OS Interactive Mode ===\n");
    console_puts("Type commands and press Enter. Type 'help' for available commands.\n");
    console_puts("Note: This interactive mode works in graphical QEMU mode.\n\n");
    
    while (1) {
        console_puts("sage@localhost:~$ ");
        buffer_pos = 0;
        
        // Read input character by character
        while (1) {
            c = keyboard_getchar();
            
            if (c == 0) continue; // Ignore key releases and unmapped keys
            
            if (c == '\n') {
                console_putc('\n');
                input_buffer[buffer_pos] = '\0';
                break;
            } else if (c == '\b') {
                // Backspace
                if (buffer_pos > 0) {
                    buffer_pos--;
                    console_puts("\b \b"); // Move back, print space, move back again
                }
            } else if (c >= 32 && c <= 126 && buffer_pos < 255) {
                // Printable character
                input_buffer[buffer_pos++] = c;
                console_putc(c);
            }
        }
        
        // Process command
        if (buffer_pos > 0) {
            process_command(input_buffer);
        }
    }
}

void process_command(const char* cmd) {
    if (strcmp(cmd, "help") == 0) {
        console_puts("Available commands:\n");
        console_puts("  help     - Show this help message\n");
        console_puts("  version  - Show system version\n");
        console_puts("  clear    - Clear screen\n");
        console_puts("  reboot   - Restart system\n");
        console_puts("  demo     - Run demo sequence\n");
        console_puts("  exit     - Shutdown system\n");
    } else if (strcmp(cmd, "version") == 0) {
        console_puts("SAGE OS Version 1.0.1\n");
        console_puts("Built on: 2025-06-11\n");
        console_puts("Kernel: SAGE Kernel v1.0.1\n");
        console_puts("Architecture: ");
#if defined(__x86_64__)
        console_puts("x86_64");
#elif defined(__i386__)
        console_puts("i386");
#elif defined(__aarch64__)
        console_puts("aarch64");
#elif defined(__riscv) && (__riscv_xlen == 64)
        console_puts("riscv64");
#else
        console_puts("unknown");
#endif
        console_puts("\n");
    } else if (strcmp(cmd, "clear") == 0) {
        vga_init(); // Clear VGA screen
        console_puts("Screen cleared.\n");
    } else if (strcmp(cmd, "demo") == 0) {
        console_puts("Demo sequence not implemented in serial mode.\n");
        console_puts("Use graphics mode for full demo experience.\n");
    } else if (strcmp(cmd, "reboot") == 0) {
        console_puts("Rebooting system...\n");
        // Simple reboot via keyboard controller
        outb(0x64, 0xFE);
    } else if (strcmp(cmd, "exit") == 0) {
        console_puts("Shutting down SAGE OS...\n");
        console_puts("Thank you for using SAGE OS!\n");
        console_puts("System halted.\n");
        while (1) { __asm__ volatile ("hlt"); }
    } else {
        console_puts("Unknown command: ");
        console_puts(cmd);
        console_puts("\nType 'help' for available commands.\n");
    }
}
#endif

// Display ASCII art welcome message
void display_welcome_message() {
    serial_puts("  ███████╗ █████╗  ██████╗ ███████╗      ██████╗ ███████╗\n");
    serial_puts("  ██╔════╝██╔══██╗██╔════╝ ██╔════╝     ██╔═══██╗██╔════╝\n");
    serial_puts("  ███████╗███████║██║  ███╗█████╗       ██║   ██║███████╗\n");
    serial_puts("  ╚════██║██╔══██║██║   ██║██╔══╝       ██║   ██║╚════██║\n");
    serial_puts("  ███████║██║  ██║╚██████╔╝███████╗     ╚██████╔╝███████║\n");
    serial_puts("  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝      ╚═════╝ ╚══════╝\n");
    serial_puts("\n");
    console_puts("        Self-Aware General Environment Operating System\n");
    serial_puts("                    Version 1.0.1\n");
    serial_puts("                 Designed by Ashish Yesale\n");
    serial_puts("\n");
    serial_puts("================================================================\n");
    serial_puts("  Welcome to SAGE OS - The Future of Self-Evolving Systems\n");
    serial_puts("================================================================\n\n");
    
    serial_puts("Initializing system components...\n");
    serial_puts("System ready!\n\n");
}

// Simple shell prompt
void simple_shell() {
    serial_puts("SAGE OS Shell v1.0\n");
    serial_puts("Type 'help' for available commands, 'exit' to shutdown\n\n");
    
    // Demo commands
    serial_puts("sage@localhost:~$ help\n");
    serial_puts("Available commands:\n");
    serial_puts("  help     - Show this help message\n");
    serial_puts("  version  - Show system version\n");
    serial_puts("  ls       - List directory contents\n");
    serial_puts("  pwd      - Show current directory\n");
    serial_puts("  mkdir    - Create directory\n");
    serial_puts("  touch    - Create file\n");
    serial_puts("  cat      - Display file contents\n");
    serial_puts("  rm       - Remove file\n");
    serial_puts("  cp       - Copy file\n");
    serial_puts("  mv       - Move/rename file\n");
    serial_puts("  nano     - Simple text editor\n");
    serial_puts("  vi       - Vi text editor\n");
    serial_puts("  clear    - Clear screen\n");
    serial_puts("  uptime   - Show system uptime\n");
    serial_puts("  whoami   - Show current user\n");
    serial_puts("  exit     - Shutdown system\n\n");
    
    serial_puts("sage@localhost:~$ version\n");
    serial_puts("SAGE OS Version 1.0.1\n");
    serial_puts("Built on: 2025-06-11\n");
    serial_puts("Kernel: SAGE Kernel v1.0.1\n");
    serial_puts("Architecture: ");
#if defined(__x86_64__)
    serial_puts("x86_64");
#elif defined(__i386__)
    serial_puts("i386");
#elif defined(__aarch64__)
    serial_puts("aarch64");
#elif defined(__riscv) && (__riscv_xlen == 64)
    serial_puts("riscv64");
#else
    serial_puts("unknown");
#endif
    serial_puts("\n\n");
    
    serial_puts("sage@localhost:~$ ls\n");
    serial_puts("total 8\n");
    serial_puts("drwxr-xr-x  2 sage sage 4096 May 28 12:00 Documents\n");
    serial_puts("drwxr-xr-x  2 sage sage 4096 May 28 12:00 Downloads\n");
    serial_puts("-rw-r--r--  1 sage sage   42 May 28 12:00 welcome.txt\n\n");
    
    serial_puts("sage@localhost:~$ cat welcome.txt\n");
    serial_puts("Welcome to SAGE OS - Your AI-powered future!\n\n");
    
    serial_puts("sage@localhost:~$ mkdir test_dir\n");
    serial_puts("Directory 'test_dir' created successfully.\n\n");
    
    serial_puts("sage@localhost:~$ touch test_file.txt\n");
    serial_puts("File 'test_file.txt' created successfully.\n\n");
    
    serial_puts("sage@localhost:~$ nano test_file.txt\n");
    serial_puts("GNU nano 6.2    test_file.txt\n");
    serial_puts("\n");
    serial_puts("Hello from SAGE OS!\n");
    serial_puts("This is a demonstration of the nano editor.\n");
    serial_puts("In a real implementation, this would be interactive.\n");
    serial_puts("\n");
    serial_puts("^X Exit  ^O Write Out  ^R Read File  ^Y Prev Page\n");
    serial_puts("File saved successfully.\n\n");
    
    serial_puts("sage@localhost:~$ exit\n");
    serial_puts("Shutting down SAGE OS...\n");
    serial_puts("Thank you for using SAGE OS!\n");
    serial_puts("System halted.\n");
    
    // Halt the system
    while (1) {
#if defined(__x86_64__) || defined(__i386__)
        __asm__ volatile("hlt");
#elif defined(__aarch64__)
        __asm__ volatile("wfi");  // Wait for interrupt on ARM
#elif defined(__riscv)
        __asm__ volatile("wfi");  // Wait for interrupt on RISC-V
#else
        // Generic halt - just loop
        continue;
#endif
    }
}

// Kernel entry point
void kernel_main() {
    // Initialize serial port
    serial_init();
    
    serial_puts("SAGE OS: Kernel starting...\n");
    serial_puts("SAGE OS: Serial initialized\n");
    
    // Display ASCII art welcome message
    display_welcome_message();
    
    // Start simple shell demonstration
    simple_shell();
    
    // Should never reach here
    while (1) {
#if defined(__x86_64__) || defined(__i386__)
        __asm__ volatile("hlt");
#elif defined(__aarch64__)
        __asm__ volatile("wfi");  // Wait for interrupt on ARM
#elif defined(__riscv)
        __asm__ volatile("wfi");  // Wait for interrupt on RISC-V
#else
        // Generic halt - just loop
        continue;
#endif
    }
}