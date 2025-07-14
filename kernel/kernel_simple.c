/* SAGE OS Kernel - Simple Version */

#include "../drivers/vga.h"
#include "../drivers/serial.h"
#include "../drivers/uart.h"
#include "shell.h"
#include "filesystem.h"
#include "types.h"

// Kernel entry point
void kernel_main(void) {
    // Initialize serial port for debugging
    serial_init();
    
    // Print welcome message
    serial_puts("SAGE OS: Kernel starting...\n");
    serial_puts("SAGE OS: Serial initialized\n");
    
    // Initialize shell (which also initializes the filesystem)
    shell_init();
    
    // Print welcome message
    serial_puts("\n");
    serial_puts("  ███████╗ █████╗  ██████╗ ███████╗      ██████╗ ███████╗\n");
    serial_puts("  ██╔════╝██╔══██╗██╔════╝ ██╔════╝     ██╔═══██╗██╔════╝\n");
    serial_puts("  ███████╗███████║██║  ███╗█████╗       ██║   ██║███████╗\n");
    serial_puts("  ╚════██║██╔══██║██║   ██║██╔══╝       ██║   ██║╚════██║\n");
    serial_puts("  ███████║██║  ██║╚██████╔╝███████╗     ╚██████╔╝███████║\n");
    serial_puts("  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝      ╚═════╝ ╚══════╝\n");
    serial_puts("\n");
    serial_puts("        Self-Aware General Environment Operating System\n");
    serial_puts("                    Version 1.0.1 (Simple Mode)\n");
    serial_puts("                 Designed by Ashish Yesale\n");
    serial_puts("\n");
    serial_puts("================================================================\n");
    serial_puts("  Welcome to SAGE OS - The Future of Self-Evolving Systems\n");
    serial_puts("================================================================\n");
    serial_puts("\n");
    
    // Run the shell
    shell_run();
    
    // We should never get here
    serial_puts("SAGE OS: Kernel halted\n");
    while (1) {
        // Halt
    }
}