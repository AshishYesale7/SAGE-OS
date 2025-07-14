/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Simple Enhanced Kernel
 * Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * ───────────────────────────────────────────────────────────────────────────── */

#include "../drivers/vga.h"
#include "../drivers/serial.h"
#include "shell.h"
#include "filesystem.h"

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

#else
// Stub for non-x86 architectures
char keyboard_getchar() {
    return 0;
}
#endif

// Enhanced welcome message
void show_enhanced_welcome() {
    serial_puts("\n");
    serial_puts("  ███████╗ █████╗  ██████╗ ███████╗      ██████╗ ███████╗\n");
    serial_puts("  ██╔════╝██╔══██╗██╔════╝ ██╔════╝     ██╔═══██╗██╔════╝\n");
    serial_puts("  ███████╗███████║██║  ███╗█████╗       ██║   ██║███████╗\n");
    serial_puts("  ╚════██║██╔══██║██║   ██║██╔══╝       ██║   ██║╚════██║\n");
    serial_puts("  ███████║██║  ██║╚██████╔╝███████╗     ╚██████╔╝███████║\n");
    serial_puts("  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝      ╚═════╝ ╚══════╝\n");
    serial_puts("\n");
    serial_puts("    Self-Aware General Environment Operating System\n");
    serial_puts("                Enhanced Version 1.0.1\n");
    serial_puts("            Designed by Ashish Yesale\n");
    serial_puts("\n");
    serial_puts("Enhanced Features:\n");
    serial_puts("- File Management with persistent storage\n");
    serial_puts("- Advanced shell commands (save, cat, ls, cp, mv, rm)\n");
    serial_puts("- Command history and improved input handling\n");
    serial_puts("- VGA graphics support with enhanced display\n");
    serial_puts("- Multi-architecture support (i386, x86_64, ARM64)\n");
    serial_puts("\n");
    
    serial_puts("Architecture: ");
    #if defined(__i386__)
    serial_puts("i386 (32-bit x86)");
    #elif defined(__x86_64__)
    serial_puts("x86_64 (64-bit x86)");
    #elif defined(__aarch64__)
    serial_puts("aarch64 (64-bit ARM)");
    #else
    serial_puts("unknown");
    #endif
    serial_puts("\n\n");
    
    serial_puts("Type 'help' for available commands.\n");
    serial_puts("Use Ctrl+A then X to exit QEMU.\n\n");
}

// Enhanced shell with better command handling
void enhanced_shell() {
    char command[256];
    int pos = 0;
    char c;
    
    show_enhanced_welcome();
    
    while (1) {
        serial_puts("sage> ");
        pos = 0;
        
        // Read command with enhanced input handling
        while (1) {
            c = keyboard_getchar();
            
            if (c == 0) continue; // No key or key release
            
            if (c == '\n') {
                serial_puts("\n");
                break;
            } else if (c == '\b') {
                if (pos > 0) {
                    pos--;
                    serial_puts("\b \b"); // Backspace, space, backspace
                }
            } else if (c >= ' ' && c <= '~' && pos < 255) {
                command[pos++] = c;
                serial_putc(c);
            }
        }
        
        command[pos] = '\0';
        
        // Skip empty commands
        if (pos == 0) continue;
        
        // Process enhanced commands
        if (command[0] == 'h' && command[1] == 'e' && command[2] == 'l' && command[3] == 'p' && command[4] == '\0') {
            serial_puts("SAGE OS Enhanced Shell - Available Commands:\n");
            serial_puts("==========================================\n");
            serial_puts("  help      - Show this help message\n");
            serial_puts("  echo      - Echo text to console\n");
            serial_puts("  clear     - Clear the screen\n");
            serial_puts("  version   - Show OS version information\n");
            serial_puts("  meminfo   - Show memory information\n");
            serial_puts("  reboot    - Reboot the system\n");
            serial_puts("  exit      - Exit SAGE OS\n");
            serial_puts("  ls        - List files\n");
            serial_puts("  cat       - Display file contents\n");
            serial_puts("  save      - Save text to file\n");
            serial_puts("  rm        - Remove file\n");
            serial_puts("  pwd       - Show current directory\n");
            serial_puts("\nFile Management Examples:\n");
            serial_puts("  save test.txt Hello World  - Save text to file\n");
            serial_puts("  cat test.txt               - Display file contents\n");
            serial_puts("  rm test.txt                - Delete file\n");
            serial_puts("  ls                         - List all files\n");
        } else if (command[0] == 'v' && command[1] == 'e' && command[2] == 'r' && command[3] == 's' && command[4] == 'i' && command[5] == 'o' && command[6] == 'n' && command[7] == '\0') {
            serial_puts("SAGE OS Enhanced Shell v1.0.1\n");
            serial_puts("Self-Aware General Environment Operating System\n");
            serial_puts("Copyright (c) 2025 Ashish Vasant Yesale\n");
            serial_puts("Designed by Ashish Yesale (ashishyesale007@gmail.com)\n");
            serial_puts("\nEnhanced Features:\n");
            serial_puts("- File management with persistent storage\n");
            serial_puts("- Advanced shell commands\n");
            serial_puts("- Improved keyboard input handling\n");
            serial_puts("- VGA graphics support\n");
            serial_puts("- Multi-architecture support\n");
        } else if (command[0] == 'c' && command[1] == 'l' && command[2] == 'e' && command[3] == 'a' && command[4] == 'r' && command[5] == '\0') {
            // Clear screen
            serial_puts("\033[2J\033[H");
            serial_puts("SAGE OS Enhanced Shell - Screen Cleared\n");
            serial_puts("Type 'help' for available commands.\n");
        } else if (command[0] == 'e' && command[1] == 'x' && command[2] == 'i' && command[3] == 't' && command[4] == '\0') {
            serial_puts("Shutting down SAGE OS Enhanced...\n");
            serial_puts("Thank you for using SAGE OS!\n");
            
            // Exit QEMU
            #if defined(__i386__) || defined(__x86_64__)
            __asm__ volatile("outw %%ax, %%dx" : : "a"(0x2000), "d"(0x604));
            #endif
            
            // Fallback: halt
            while (1) {
                __asm__ volatile("hlt");
            }
        } else if (command[0] == 'r' && command[1] == 'e' && command[2] == 'b' && command[3] == 'o' && command[4] == 'o' && command[5] == 't' && command[6] == '\0') {
            serial_puts("Rebooting SAGE OS Enhanced...\n");
            
            // Simple reboot
            #if defined(__i386__) || defined(__x86_64__)
            __asm__ volatile("cli");
            while (1) {
                __asm__ volatile("hlt");
            }
            #endif
        } else {
            // Use existing shell for other commands
            shell_process_command(command);
        }
    }
}

// Main kernel entry point
void kernel_main(void) {
    // Initialize VGA
    vga_init();
    
    // Initialize serial communication
    serial_init();
    
    // Initialize file system
    fs_init();
    
    // Create some default files
    fs_save("welcome.txt", "Welcome to SAGE OS Enhanced!\n\nThis enhanced operating system features:\n- Persistent file storage\n- Advanced shell commands\n- Improved keyboard input\n- VGA graphics support\n\nType 'help' for available commands.\n");
    fs_save("readme.txt", "SAGE OS Enhanced v1.0.1\n========================\n\nSelf-Aware General Environment Operating System\nDesigned by Ashish Vasant Yesale\n\nFeatures:\n- File management (save, cat, ls, rm)\n- Enhanced shell with command history\n- Multi-architecture support\n- VGA graphics capabilities\n- Persistent memory storage\n\nFor more information, visit the project repository.\n");
    
    // Start enhanced shell
    enhanced_shell();
    
    // Should never reach here
    while (1) {
        __asm__ volatile("hlt");
    }
}