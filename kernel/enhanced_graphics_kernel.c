/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Enhanced Graphics Kernel
 * Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * ───────────────────────────────────────────────────────────────────────────── */

#include "../drivers/vga.h"
#include "../drivers/serial.h"
#include "enhanced_shell.h"
#include "filesystem.h"
#include "memory.h"

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

// Enhanced scancode to ASCII mapping for US keyboard
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

// Enhanced interactive shell function with better input handling
void enhanced_interactive_shell() {
    char input_buffer[256];
    int buffer_pos = 0;
    char c;
    
    serial_puts("\n=== SAGE OS Enhanced Interactive Graphics Mode ===\n");
    serial_puts("Enhanced file management with persistent storage\n");
    serial_puts("Type 'help' for available commands.\n");
    serial_puts("Features: save/load files, copy/move, search, history\n\n");
    
    while (1) {
        serial_puts("sage> ");
        vga_puts("sage> ");
        buffer_pos = 0;
        
        // Read input character by character
        while (1) {
            c = keyboard_getchar();
            
            if (c == 0) continue; // Ignore key releases and unmapped keys
            
            if (c == '\n') {
                serial_putc('\n');
                vga_putc('\n');
                input_buffer[buffer_pos] = '\0';
                break;
            } else if (c == '\b') {
                // Backspace
                if (buffer_pos > 0) {
                    buffer_pos--;
                    serial_puts("\b \b"); // Move back, print space, move back again
                    vga_puts("\b \b");
                }
            } else if (c >= 32 && c <= 126 && buffer_pos < 255) {
                // Printable character
                input_buffer[buffer_pos++] = c;
                serial_putc(c);
                vga_putc(c);
            }
        }
        
        // Process command using enhanced shell
        if (buffer_pos > 0) {
            enhanced_shell_process_command(input_buffer);
        }
    }
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

// Display enhanced ASCII art welcome message
void display_enhanced_welcome_message() {
    serial_puts("  ███████╗ █████╗  ██████╗ ███████╗      ██████╗ ███████╗\n");
    serial_puts("  ██╔════╝██╔══██╗██╔════╝ ██╔════╝     ██╔═══██╗██╔════╝\n");
    serial_puts("  ███████╗███████║██║  ███╗█████╗       ██║   ██║███████╗\n");
    serial_puts("  ╚════██║██╔══██║██║   ██║██╔══╝       ██║   ██║╚════██║\n");
    serial_puts("  ███████║██║  ██║╚██████╔╝███████╗     ╚██████╔╝███████║\n");
    serial_puts("  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝      ╚═════╝ ╚══════╝\n");
    serial_puts("\n");
    console_puts("        Self-Aware General Environment Operating System\n");
    serial_puts("                    Enhanced Version 1.0.1\n");
    serial_puts("                 Designed by Ashish Yesale\n");
    serial_puts("\n");
    serial_puts("================================================================\n");
    serial_puts("  Welcome to SAGE OS Enhanced - Advanced File Management\n");
    serial_puts("================================================================\n\n");
    
    serial_puts("Enhanced Features:\n");
    serial_puts("- Persistent file storage in memory\n");
    serial_puts("- Advanced file operations (cp, mv, find, grep, wc)\n");
    serial_puts("- Command history\n");
    serial_puts("- Enhanced VGA graphics support\n");
    serial_puts("- Improved keyboard input handling\n\n");
    
    serial_puts("Initializing enhanced system components...\n");
}

// Enhanced kernel entry point
void enhanced_kernel_main() {
    // Initialize serial port
    serial_init();
    
    serial_puts("SAGE OS Enhanced: Kernel starting...\n");
    serial_puts("SAGE OS Enhanced: Serial initialized - ");
    serial_puts(serial_get_uart_info());
    serial_puts("\n");
    
    // Initialize VGA
#if defined(__x86_64__) || defined(__i386__)
    vga_init();
    serial_puts("SAGE OS Enhanced: VGA initialized\n");
#endif
    
    // Initialize memory management
    memory_init();
    serial_puts("SAGE OS Enhanced: Memory management initialized\n");
    
    // Display enhanced ASCII art welcome message
    display_enhanced_welcome_message();
    
    // Initialize and start enhanced shell
    enhanced_shell_init();
    serial_puts("SAGE OS Enhanced: Enhanced shell initialized\n");
    
#if defined(__x86_64__) || defined(__i386__)
    // Start enhanced interactive mode for x86 with keyboard support
    enhanced_interactive_shell();
#else
    // For other architectures, use the enhanced shell directly
    enhanced_shell_run();
#endif
    
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