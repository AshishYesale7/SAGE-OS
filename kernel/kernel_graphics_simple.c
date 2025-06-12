/* SAGE OS Kernel - Simple Graphics Mode Version */
/* Simplified version without conflicts for i386 builds */

// VGA text mode constants
#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define VGA_MEMORY 0xB8000

// VGA colors
typedef enum {
    VGA_COLOR_BLACK = 0,
    VGA_COLOR_BLUE = 1,
    VGA_COLOR_GREEN = 2,
    VGA_COLOR_CYAN = 3,
    VGA_COLOR_RED = 4,
    VGA_COLOR_MAGENTA = 5,
    VGA_COLOR_BROWN = 6,
    VGA_COLOR_LIGHT_GREY = 7,
    VGA_COLOR_DARK_GREY = 8,
    VGA_COLOR_LIGHT_BLUE = 9,
    VGA_COLOR_LIGHT_GREEN = 10,
    VGA_COLOR_LIGHT_CYAN = 11,
    VGA_COLOR_LIGHT_RED = 12,
    VGA_COLOR_LIGHT_MAGENTA = 13,
    VGA_COLOR_LIGHT_BROWN = 14,
    VGA_COLOR_WHITE = 15,
} vga_color;

// Global variables
static unsigned short* vga_buffer = (unsigned short*)VGA_MEMORY;
static int vga_row = 0;
static int vga_column = 0;
static unsigned char vga_color_attr = 0x07; // Light grey on black

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

// Serial port functions
void serial_init() {
    outb(0x3F8 + 1, 0x00);    // Disable all interrupts
    outb(0x3F8 + 3, 0x80);    // Enable DLAB (set baud rate divisor)
    outb(0x3F8 + 0, 0x03);    // Set divisor to 3 (lo byte) 38400 baud
    outb(0x3F8 + 1, 0x00);    //                  (hi byte)
    outb(0x3F8 + 3, 0x03);    // 8 bits, no parity, one stop bit
    outb(0x3F8 + 2, 0xC7);    // Enable FIFO, clear them, with 14-byte threshold
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
#endif

// VGA functions
static inline unsigned char vga_entry_color(vga_color fg, vga_color bg) {
    return fg | bg << 4;
}

static inline unsigned short vga_entry(unsigned char uc, unsigned char color) {
    return (unsigned short) uc | (unsigned short) color << 8;
}

void vga_init() {
    vga_row = 0;
    vga_column = 0;
    vga_color_attr = vga_entry_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
    
    for (int y = 0; y < VGA_HEIGHT; y++) {
        for (int x = 0; x < VGA_WIDTH; x++) {
            const int index = y * VGA_WIDTH + x;
            vga_buffer[index] = vga_entry(' ', vga_color_attr);
        }
    }
}

void vga_scroll() {
    // Move all lines up by one
    for (int y = 0; y < VGA_HEIGHT - 1; y++) {
        for (int x = 0; x < VGA_WIDTH; x++) {
            vga_buffer[y * VGA_WIDTH + x] = vga_buffer[(y + 1) * VGA_WIDTH + x];
        }
    }
    
    // Clear the last line
    for (int x = 0; x < VGA_WIDTH; x++) {
        vga_buffer[(VGA_HEIGHT - 1) * VGA_WIDTH + x] = vga_entry(' ', vga_color_attr);
    }
    
    vga_row = VGA_HEIGHT - 1;
}

void vga_putc(char c) {
    if (c == '\n') {
        vga_column = 0;
        if (++vga_row == VGA_HEIGHT) {
            vga_scroll();
        }
        return;
    }
    
    if (c == '\b') {
        if (vga_column > 0) {
            vga_column--;
            vga_buffer[vga_row * VGA_WIDTH + vga_column] = vga_entry(' ', vga_color_attr);
        }
        return;
    }
    
    vga_buffer[vga_row * VGA_WIDTH + vga_column] = vga_entry(c, vga_color_attr);
    
    if (++vga_column == VGA_WIDTH) {
        vga_column = 0;
        if (++vga_row == VGA_HEIGHT) {
            vga_scroll();
        }
    }
}

void vga_puts(const char* str) {
    while (*str) {
        vga_putc(*str++);
    }
}

// Unified output functions
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

// Simple string comparison
int strcmp(const char* str1, const char* str2) {
    while (*str1 && (*str1 == *str2)) {
        str1++;
        str2++;
    }
    return *(unsigned char*)str1 - *(unsigned char*)str2;
}

// Command processing
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
        console_puts("Built on: 2025-06-12\n");
        console_puts("Kernel: SAGE Kernel v1.0.1 (Graphics Mode)\n");
        console_puts("Architecture: i386 (32-bit x86)\n");
    } else if (strcmp(cmd, "clear") == 0) {
        vga_init(); // Clear VGA screen
        console_puts("Screen cleared.\n");
    } else if (strcmp(cmd, "demo") == 0) {
        console_puts("=== SAGE OS Graphics Demo ===\n");
        console_puts("Welcome to SAGE OS graphics mode!\n");
        console_puts("This is a demonstration of VGA text output.\n");
        console_puts("You can type commands and see them on screen.\n");
        console_puts("Demo completed.\n");
    } else if (strcmp(cmd, "reboot") == 0) {
        console_puts("Rebooting system...\n");
#if defined(__x86_64__) || defined(__i386__)
        // Simple reboot via keyboard controller
        outb(0x64, 0xFE);
#endif
    } else if (strcmp(cmd, "exit") == 0) {
        console_puts("Shutting down SAGE OS...\n");
        console_puts("Thank you for using SAGE OS!\n");
        console_puts("System halted.\n");
        while (1) { 
#if defined(__x86_64__) || defined(__i386__)
            __asm__ volatile ("hlt"); 
#endif
        }
    } else {
        console_puts("Unknown command: ");
        console_puts(cmd);
        console_puts("\nType 'help' for available commands.\n");
    }
}

#if defined(__x86_64__) || defined(__i386__)
// Interactive shell function (only for x86 with keyboard support)
void interactive_shell() {
    char input_buffer[256];
    int buffer_pos = 0;
    char c;
    
    console_puts("\n=== SAGE OS Interactive Graphics Mode ===\n");
    console_puts("Type commands and press Enter. Type 'help' for available commands.\n");
    console_puts("Graphics mode: VGA text 80x25, keyboard input enabled.\n\n");
    
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
#endif

// Display ASCII art welcome message
void display_welcome_message() {
    console_puts("  ███████╗ █████╗  ██████╗ ███████╗      ██████╗ ███████╗\n");
    console_puts("  ██╔════╝██╔══██╗██╔════╝ ██╔════╝     ██╔═══██╗██╔════╝\n");
    console_puts("  ███████╗███████║██║  ███╗█████╗       ██║   ██║███████╗\n");
    console_puts("  ╚════██║██╔══██║██║   ██║██╔══╝       ██║   ██║╚════██║\n");
    console_puts("  ███████║██║  ██║╚██████╔╝███████╗     ╚██████╔╝███████║\n");
    console_puts("  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝      ╚═════╝ ╚══════╝\n");
    console_puts("\n");
    console_puts("        Self-Aware General Environment Operating System\n");
    console_puts("                    Version 1.0.1 (Graphics Mode)\n");
    console_puts("                 Designed by Ashish Yesale\n");
    console_puts("\n");
    console_puts("================================================================\n");
    console_puts("  Welcome to SAGE OS - The Future of Self-Evolving Systems\n");
    console_puts("================================================================\n\n");
    
    console_puts("Initializing system components...\n");
    console_puts("VGA Graphics Mode: ENABLED\n");
    console_puts("Keyboard Input: ENABLED\n");
    console_puts("System ready!\n\n");
}

// Kernel entry point
void kernel_main() {
    // Initialize serial port
    serial_init();
    
    // Initialize VGA
    vga_init();
    
    console_puts("SAGE OS: Kernel starting (Graphics Mode)...\n");
    console_puts("SAGE OS: VGA and Serial initialized\n");
    
    // Display ASCII art welcome message
    display_welcome_message();
    
#if defined(__x86_64__) || defined(__i386__)
    // Start interactive shell
    interactive_shell();
#else
    // For non-x86 architectures, just show a message and halt
    console_puts("Interactive shell not available on this architecture.\n");
    console_puts("System halted.\n");
    while (1) {
        // Generic halt - just loop
        continue;
    }
#endif
    
    // Should never reach here
    while (1) {
#if defined(__x86_64__) || defined(__i386__)
        __asm__ volatile("hlt");
#else
        // Generic halt - just loop
        continue;
#endif
    }
}