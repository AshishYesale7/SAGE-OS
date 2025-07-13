/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
 * 
 * This file is part of the SAGE OS Project.
 * ───────────────────────────────────────────────────────────────────────────── */

#include "serial.h"

#if defined(__x86_64__) || defined(__i386__)

// COM1 port base address
#define COM1_PORT 0x3F8

// Port offsets
#define DATA_PORT        0  // Data register
#define INT_ENABLE_PORT  1  // Interrupt enable register
#define FIFO_CTRL_PORT   2  // FIFO control register
#define LINE_CTRL_PORT   3  // Line control register
#define MODEM_CTRL_PORT  4  // Modem control register
#define LINE_STATUS_PORT 5  // Line status register

// I/O port functions
static inline void outb(uint16_t port, uint8_t value) {
    __asm__ volatile ("outb %0, %1" : : "a"(value), "Nd"(port));
}

static inline uint8_t inb(uint16_t port) {
    uint8_t ret;
    __asm__ volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

void serial_init(void) {
    // Disable interrupts
    outb(COM1_PORT + INT_ENABLE_PORT, 0x00);
    
    // Enable DLAB (set baud rate divisor)
    outb(COM1_PORT + LINE_CTRL_PORT, 0x80);
    
    // Set divisor to 3 (38400 baud)
    outb(COM1_PORT + DATA_PORT, 0x03);
    outb(COM1_PORT + INT_ENABLE_PORT, 0x00);
    
    // 8 bits, no parity, one stop bit
    outb(COM1_PORT + LINE_CTRL_PORT, 0x03);
    
    // Enable FIFO, clear them, with 14-byte threshold
    outb(COM1_PORT + FIFO_CTRL_PORT, 0xC7);
    
    // IRQs enabled, RTS/DSR set
    outb(COM1_PORT + MODEM_CTRL_PORT, 0x0B);
}

static int is_transmit_empty(void) {
    return inb(COM1_PORT + LINE_STATUS_PORT) & 0x20;
}

void serial_putc(char c) {
    while (is_transmit_empty() == 0);
    outb(COM1_PORT + DATA_PORT, c);
}

void serial_puts(const char* str) {
    while (*str) {
        serial_putc(*str);
        if (*str == '\n') {
            serial_putc('\r');
        }
        str++;
    }
}

#elif defined(__aarch64__)
// AArch64 UART functions for Raspberry Pi and QEMU
// Multiple UART base addresses for different hardware
#define UART0_BASE_QEMU    0x09000000  // QEMU virt machine PL011
#define UART0_BASE_RPI4    0xFE201000  // Raspberry Pi 4 (BCM2711)
#define UART0_BASE_RPI5    0x107D001000 // Raspberry Pi 5 (BCM2712) - Primary UART
#define UART1_BASE_RPI5    0x107D050000 // Raspberry Pi 5 (BCM2712) - Secondary UART
#define UART_DR_OFFSET     0x00        // Data register
#define UART_FR_OFFSET     0x18        // Flag register
#define UART_FR_TXFF       (1 << 5)    // Transmit FIFO full
#define UART_FR_RXFE       (1 << 4)    // Receive FIFO empty

static unsigned long uart_base = 0;
static int uart_detected = 0;

static inline void mmio_write(unsigned long addr, unsigned int value) {
    *(volatile unsigned int*)addr = value;
}

static inline unsigned int mmio_read(unsigned long addr) {
    return *(volatile unsigned int*)addr;
}

// Test if a UART address is valid by checking if we can read from it
static int test_uart_address(unsigned long addr) {
    // For QEMU, we'll be less strict about the test
    // Just check if the address doesn't cause a fault
    volatile unsigned int test_val = mmio_read(addr + UART_FR_OFFSET);
    // Accept any value that's not all 1s (which usually indicates unmapped memory)
    return (test_val != 0xFFFFFFFF);
}

void serial_init(void) {
    // Try QEMU first for testing, then real hardware
    unsigned long uart_addresses[] = {
        UART0_BASE_QEMU,    // QEMU virt machine for testing (try first)
        UART0_BASE_RPI5,    // Raspberry Pi 5 primary (your target hardware)
        UART1_BASE_RPI5,    // Raspberry Pi 5 secondary
        UART0_BASE_RPI4,    // Raspberry Pi 4 fallback
        0                   // End marker
    };
    
    // Try each UART address
    for (int i = 0; uart_addresses[i] != 0; i++) {
        uart_base = uart_addresses[i];
        
        // Simple test: try to write and see if it works
        // For QEMU and real hardware, this should work without issues
        uart_detected = 1;
        break; // Use the first address for now
    }
    
    // If somehow we get here without setting anything, default to QEMU
    if (!uart_detected) {
        uart_base = UART0_BASE_QEMU;
        uart_detected = 1;
    }
}

void serial_putc(char c) {
    if (uart_base == 0) return; // Safety check
    
    // Wait until transmit FIFO is not full (with timeout)
    int timeout = 10000;
    while ((mmio_read(uart_base + UART_FR_OFFSET) & UART_FR_TXFF) && timeout-- > 0);
    
    if (timeout > 0) {
        mmio_write(uart_base + UART_DR_OFFSET, c);
    }
}

void serial_puts(const char* str) {
    while (*str) {
        serial_putc(*str);
        if (*str == '\n') {
            serial_putc('\r');
        }
        str++;
    }
}

// Function to get UART info for debugging
const char* serial_get_uart_info(void) {
    if (uart_base == UART0_BASE_RPI5) return "Raspberry Pi 5 Primary UART (0x107D001000)";
    if (uart_base == UART1_BASE_RPI5) return "Raspberry Pi 5 Secondary UART (0x107D050000)";
    if (uart_base == UART0_BASE_RPI4) return "Raspberry Pi 4 UART (0xFE201000)";
    if (uart_base == UART0_BASE_QEMU) return "QEMU Virtual UART (0x09000000)";
    return "Unknown UART";
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

void serial_init(void) {
    // UART is already initialized by QEMU
}

void serial_putc(char c) {
    // Wait until transmit holding register is empty
    while (!(mmio_read_8(UART_LSR) & UART_LSR_THRE));
    mmio_write_8(UART_THR, c);
}

void serial_puts(const char* str) {
    while (*str) {
        serial_putc(*str);
        if (*str == '\n') {
            serial_putc('\r');
        }
        str++;
    }
}

#else
// Generic ARM/other architectures - placeholder
void serial_init(void) {
    // Generic serial initialization - do nothing for now
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