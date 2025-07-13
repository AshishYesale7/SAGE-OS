/* Simple test kernel for ARM64 */

#define UART0_BASE 0x09000000  // QEMU virt machine UART
#define UART_DR_OFFSET  0x00
#define UART_FR_OFFSET  0x18
#define UART_FR_TXFF (1 << 5)

// Alternative addresses to try
#define UART0_ALT1 0x10000000
#define UART0_ALT2 0x3F8

static inline void mmio_write(unsigned long addr, unsigned int value) {
    *(volatile unsigned int*)addr = value;
}

static inline unsigned int mmio_read(unsigned long addr) {
    return *(volatile unsigned int*)addr;
}

void test_putc(char c) {
    // Wait until transmit FIFO is not full
    while (mmio_read(UART0_BASE + UART_FR_OFFSET) & UART_FR_TXFF);
    mmio_write(UART0_BASE + UART_DR_OFFSET, c);
}

void test_puts(const char* str) {
    while (*str) {
        test_putc(*str);
        if (*str == '\n') {
            test_putc('\r');
        }
        str++;
    }
}

void kernel_main() {
    test_puts("SAGE OS Test Kernel Starting...\n");
    test_puts("Hello from ARM64!\n");
    
    // ASCII Art
    test_puts("  ███████╗ █████╗  ██████╗ ███████╗      ██████╗ ███████╗\n");
    test_puts("  ██╔════╝██╔══██╗██╔════╝ ██╔════╝     ██╔═══██╗██╔════╝\n");
    test_puts("  ███████╗███████║██║  ███╗█████╗       ██║   ██║███████╗\n");
    test_puts("  ╚════██║██╔══██║██║   ██║██╔══╝       ██║   ██║╚════██║\n");
    test_puts("  ███████║██║  ██║╚██████╔╝███████╗     ╚██████╔╝███████║\n");
    test_puts("  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝      ╚═════╝ ╚══════╝\n");
    test_puts("\n");
    test_puts("        Self-Aware General Environment Operating System\n");
    test_puts("                    Version 1.0.1\n");
    test_puts("                 Designed by Ashish Yesale\n");
    test_puts("\n");
    test_puts("Test completed successfully!\n");
    
    // Infinite loop
    while (1) {
        __asm__ volatile("wfi");
    }
}