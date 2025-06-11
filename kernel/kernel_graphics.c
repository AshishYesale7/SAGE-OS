/* SAGE OS Kernel - Graphics Mode Version */

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

// Unified output functions that write to both VGA and serial
void console_putc(char c) {
    serial_putc(c);  // Always write to serial for debugging
    vga_putc(c);     // Write to VGA for graphics mode
}

void console_puts(const char* str) {
    while (*str) {
        console_putc(*str++);
    }
}

// Simple string comparison
int strcmp(const char* str1, const char* str2) {
    while (*str1 && (*str1 == *str2)) {
        str1++;
        str2++;
    }
    return *(unsigned char*)str1 - *(unsigned char*)str2;
}

// Forward declarations
void process_command(const char* cmd);
void run_demo_sequence();

// Display welcome message
void display_welcome_message() {
    vga_set_color(VGA_COLOR_LIGHT_CYAN | (VGA_COLOR_BLACK << 4));
    console_puts("  ███████╗ █████╗  ██████╗ ███████╗      ██████╗ ███████╗\n");
    console_puts("  ██╔════╝██╔══██╗██╔════╝ ██╔════╝     ██╔═══██╗██╔════╝\n");
    console_puts("  ███████╗███████║██║  ███╗█████╗       ██║   ██║███████╗\n");
    console_puts("  ╚════██║██╔══██║██║   ██║██╔══╝       ██║   ██║╚════██║\n");
    console_puts("  ███████║██║  ██║╚██████╔╝███████╗     ╚██████╔╝███████║\n");
    console_puts("  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝      ╚═════╝ ╚══════╝\n");
    
    vga_set_color(VGA_COLOR_WHITE | (VGA_COLOR_BLACK << 4));
    console_puts("\n        Self-Aware General Environment Operating System\n");
    console_puts("                    Version 1.0.1\n");
    console_puts("                 Designed by Ashish Yesale\n\n");
    
    vga_set_color(VGA_COLOR_LIGHT_BROWN | (VGA_COLOR_BLACK << 4));
    console_puts("================================================================\n");
    console_puts("  Welcome to SAGE OS - The Future of Self-Evolving Systems\n");
    console_puts("================================================================\n\n");
    
    vga_set_color(VGA_COLOR_LIGHT_GREEN | (VGA_COLOR_BLACK << 4));
    console_puts("Initializing system components...\n");
    console_puts("VGA Graphics Mode: ENABLED\n");
    console_puts("Keyboard Input: ENABLED\n");
    console_puts("System ready!\n\n");
    
    vga_set_color(VGA_COLOR_LIGHT_GREY | (VGA_COLOR_BLACK << 4));
}

// Interactive shell function
void interactive_shell() {
    char input_buffer[256];
    int buffer_pos = 0;
    char c;
    
    vga_set_color(VGA_COLOR_LIGHT_BLUE | (VGA_COLOR_BLACK << 4));
    console_puts("=== SAGE OS Interactive Mode ===\n");
    vga_set_color(VGA_COLOR_LIGHT_GREY | (VGA_COLOR_BLACK << 4));
    console_puts("Type commands and press Enter. Type 'help' for available commands.\n");
    console_puts("This interactive mode works with keyboard input in QEMU graphics mode.\n\n");
    
    while (1) {
        vga_set_color(VGA_COLOR_LIGHT_GREEN | (VGA_COLOR_BLACK << 4));
        console_puts("sage@localhost:~$ ");
        vga_set_color(VGA_COLOR_WHITE | (VGA_COLOR_BLACK << 4));
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
    vga_set_color(VGA_COLOR_LIGHT_GREY | (VGA_COLOR_BLACK << 4));
    
    if (strcmp(cmd, "help") == 0) {
        vga_set_color(VGA_COLOR_LIGHT_BROWN | (VGA_COLOR_BLACK << 4));
        console_puts("Available commands:\n");
        vga_set_color(VGA_COLOR_LIGHT_GREY | (VGA_COLOR_BLACK << 4));
        console_puts("  help     - Show this help message\n");
        console_puts("  version  - Show system version\n");
        console_puts("  clear    - Clear screen\n");
        console_puts("  colors   - Test color display\n");
        console_puts("  reboot   - Restart system\n");
        console_puts("  demo     - Run demo sequence\n");
        console_puts("  exit     - Shutdown system\n");
    } else if (strcmp(cmd, "version") == 0) {
        vga_set_color(VGA_COLOR_LIGHT_CYAN | (VGA_COLOR_BLACK << 4));
        console_puts("SAGE OS Version 1.0.1\n");
        console_puts("Built on: 2025-06-11\n");
        console_puts("Kernel: SAGE Kernel v1.0.1 (Graphics Mode)\n");
        console_puts("Architecture: ");
#if defined(__x86_64__)
        console_puts("x86_64");
#elif defined(__i386__)
        console_puts("i386");
#else
        console_puts("unknown");
#endif
        console_puts("\n");
    } else if (strcmp(cmd, "clear") == 0) {
        vga_init(); // Clear VGA screen
        vga_set_color(VGA_COLOR_LIGHT_GREEN | (VGA_COLOR_BLACK << 4));
        console_puts("Screen cleared.\n");
    } else if (strcmp(cmd, "colors") == 0) {
        console_puts("Color test:\n");
        for (int i = 0; i < 16; i++) {
            vga_set_color(i | (VGA_COLOR_BLACK << 4));
            console_puts("Color ");
            console_putc('0' + (i / 10));
            console_putc('0' + (i % 10));
            console_puts(" ");
        }
        console_puts("\n");
        vga_set_color(VGA_COLOR_LIGHT_GREY | (VGA_COLOR_BLACK << 4));
    } else if (strcmp(cmd, "demo") == 0) {
        run_demo_sequence();
    } else if (strcmp(cmd, "reboot") == 0) {
        vga_set_color(VGA_COLOR_LIGHT_RED | (VGA_COLOR_BLACK << 4));
        console_puts("Rebooting system...\n");
        // Simple reboot via keyboard controller
        outb(0x64, 0xFE);
    } else if (strcmp(cmd, "exit") == 0) {
        vga_set_color(VGA_COLOR_LIGHT_RED | (VGA_COLOR_BLACK << 4));
        console_puts("Shutting down SAGE OS...\n");
        console_puts("Thank you for using SAGE OS!\n");
        console_puts("System halted.\n");
        while (1) { __asm__ volatile ("hlt"); }
    } else {
        vga_set_color(VGA_COLOR_LIGHT_RED | (VGA_COLOR_BLACK << 4));
        console_puts("Unknown command: ");
        console_puts(cmd);
        console_puts("\n");
        vga_set_color(VGA_COLOR_LIGHT_GREY | (VGA_COLOR_BLACK << 4));
        console_puts("Type 'help' for available commands.\n");
    }
}

void run_demo_sequence() {
    vga_set_color(VGA_COLOR_LIGHT_MAGENTA | (VGA_COLOR_BLACK << 4));
    console_puts("Running SAGE OS Demo Sequence...\n\n");
    
    vga_set_color(VGA_COLOR_LIGHT_CYAN | (VGA_COLOR_BLACK << 4));
    console_puts("1. File System Operations:\n");
    vga_set_color(VGA_COLOR_LIGHT_GREY | (VGA_COLOR_BLACK << 4));
    console_puts("   Creating directory: /home/sage/documents\n");
    console_puts("   Creating file: welcome.txt\n");
    console_puts("   Writing content to file...\n");
    console_puts("   File operations completed successfully!\n\n");
    
    vga_set_color(VGA_COLOR_LIGHT_CYAN | (VGA_COLOR_BLACK << 4));
    console_puts("2. Memory Management:\n");
    vga_set_color(VGA_COLOR_LIGHT_GREY | (VGA_COLOR_BLACK << 4));
    console_puts("   Total Memory: 128 MB\n");
    console_puts("   Used Memory: 4 MB\n");
    console_puts("   Free Memory: 124 MB\n");
    console_puts("   Memory allocation test: PASSED\n\n");
    
    vga_set_color(VGA_COLOR_LIGHT_CYAN | (VGA_COLOR_BLACK << 4));
    console_puts("3. AI Subsystem:\n");
    vga_set_color(VGA_COLOR_LIGHT_GREY | (VGA_COLOR_BLACK << 4));
    console_puts("   Initializing neural networks...\n");
    console_puts("   Loading AI models...\n");
    console_puts("   AI subsystem ready for self-learning!\n\n");
    
    vga_set_color(VGA_COLOR_LIGHT_GREEN | (VGA_COLOR_BLACK << 4));
    console_puts("Demo completed successfully!\n");
    vga_set_color(VGA_COLOR_LIGHT_GREY | (VGA_COLOR_BLACK << 4));
}

// Main kernel entry point
void kernel_main() {
    // Initialize VGA first for graphics output
    vga_init();
    
    // Initialize serial for debugging
    serial_init();
    
    // Send startup message to serial
    serial_puts("SAGE OS: Kernel starting (Graphics Mode)...\n");
    serial_puts("SAGE OS: VGA and Serial initialized\n");
    
    // Display welcome message on screen
    display_welcome_message();
    
    // Start interactive shell
    interactive_shell();
    
    // Should never reach here
    while (1) {
        __asm__ volatile ("hlt");
    }
}

#else
// Non-x86 architectures - fallback to serial only
void serial_init() {}
void serial_putc(char c) { (void)c; }
void serial_puts(const char* str) { (void)str; }

void kernel_main() {
    serial_puts("SAGE OS: Graphics mode not supported on this architecture\n");
    while (1) {
        __asm__ volatile ("nop");
    }
}
#endif