/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
 * 
 * This file is part of the SAGE OS Project.
 * ───────────────────────────────────────────────────────────────────────────── */

#include "uart.h"

// Memory-Mapped I/O addresses for Raspberry Pi
#define MMIO_BASE       0x3F000000  // For Raspberry Pi 3/4
// #define MMIO_BASE     0xFE000000  // For Raspberry Pi 5

// UART registers
#define UART0_DR        ((volatile unsigned int*)(MMIO_BASE + 0x00201000))
#define UART0_FR        ((volatile unsigned int*)(MMIO_BASE + 0x00201018))
#define UART0_IBRD      ((volatile unsigned int*)(MMIO_BASE + 0x00201024))
#define UART0_FBRD      ((volatile unsigned int*)(MMIO_BASE + 0x00201028))
#define UART0_LCRH      ((volatile unsigned int*)(MMIO_BASE + 0x0020102C))
#define UART0_CR        ((volatile unsigned int*)(MMIO_BASE + 0x00201030))
#define UART0_IMSC      ((volatile unsigned int*)(MMIO_BASE + 0x00201038))
#define UART0_ICR       ((volatile unsigned int*)(MMIO_BASE + 0x00201044))

// GPIO registers
#define GPFSEL1         ((volatile unsigned int*)(MMIO_BASE + 0x00200004))
#define GPPUD           ((volatile unsigned int*)(MMIO_BASE + 0x00200094))
#define GPPUDCLK0       ((volatile unsigned int*)(MMIO_BASE + 0x00200098))

// Initialize UART
void uart_init() {
    // Disable UART0
    *UART0_CR = 0;

    // Setup GPIO pins 14 and 15
    unsigned int selector = *GPFSEL1;
    selector &= ~((7 << 12) | (7 << 15)); // Clear bits 12-14 (GPIO14) and 15-17 (GPIO15)
    selector |= (4 << 12) | (4 << 15);    // Set bits 12-14 (GPIO14) and 15-17 (GPIO15) to alternative function 0 (UART)
    *GPFSEL1 = selector;

    // Disable pull-up/down
    *GPPUD = 0;
    
    // Wait 150 cycles
    for (volatile int i = 0; i < 150; i++) { }
    
    // Clock the control signal into the GPIO pads
    *GPPUDCLK0 = (1 << 14) | (1 << 15);
    
    // Wait 150 cycles
    for (volatile int i = 0; i < 150; i++) { }
    
    // Remove the clock
    *GPPUDCLK0 = 0;

    // Clear interrupts
    *UART0_ICR = 0x7FF;

    // Set baud rate to 115200
    // Baud rate divisor = UART clock / (16 * baud rate)
    // UART clock = 48MHz, baud rate = 115200
    // Divisor = 48000000 / (16 * 115200) = 26.0416...
    // Integer part = 26
    // Fractional part = 0.0416... * 64 = 2.66... ~ 3
    *UART0_IBRD = 26;
    *UART0_FBRD = 3;

    // Enable FIFO, 8-bit data, 1 stop bit, no parity
    *UART0_LCRH = (1 << 4) | (1 << 5) | (1 << 6);

    // Enable UART0, receive and transmit
    *UART0_CR = (1 << 0) | (1 << 8) | (1 << 9);
}

// Send a character
void uart_putc(unsigned char c) {
    // Wait until transmit FIFO is not full
    while (*UART0_FR & (1 << 5)) { }
    
    // Write the character to the data register
    *UART0_DR = c;
    
    // If it's a newline, also send a carriage return
    if (c == '\n') {
        uart_putc('\r');
    }
}

// Receive a character
unsigned char uart_getc() {
    // Wait until receive FIFO is not empty
    while (*UART0_FR & (1 << 4)) { }
    
    // Read the character from the data register
    return *UART0_DR;
}

// Send a string
void uart_puts(const char* str) {
    while (*str) {
        uart_putc(*str++);
    }
}