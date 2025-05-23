// ─────────────────────────────────────────────────────────────────────────────
// SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
// SPDX-License-Identifier: BSD-3-Clause OR Proprietary
// SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
// 
// This file is part of the SAGE OS Project.
//
// ─────────────────────────────────────────────────────────────────────────────
// Licensing:
// -----------
//                                 
//                                                                             
//   Licensed under the BSD 3-Clause License or a Commercial License.          
//   You may use this file under the terms of either license as specified in: 
//                                                                             
//      - BSD 3-Clause License (see ./LICENSE)                           
//      - Commercial License (see ./COMMERCIAL_TERMS.md or contact legal@your.org)  
//                                                                             
//   Redistribution and use in source and binary forms, with or without       
//   modification, are permitted under the BSD license provided that the      
//   following conditions are met:                                            
//                                                                             
//     * Redistributions of source code must retain the above copyright       
//       notice, this list of conditions and the following disclaimer.       
//     * Redistributions in binary form must reproduce the above copyright    
//       notice, this list of conditions and the following disclaimer in the  
//       documentation and/or other materials provided with the distribution. 
//     * Neither the name of the project nor the names of its contributors    
//       may be used to endorse or promote products derived from this         
//       software without specific prior written permission.                  
//                                                                             
//   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS  
//   IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED    
//   TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A          
//   PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER 
//   OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
//   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,      
//   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR       
//   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF   
//   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     
//   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS       
//   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  
//
// By using this software, you agree to be bound by the terms of either license.
//
// Alternatively, commercial use with extended rights is available — contact the author for commercial licensing.
//
// ─────────────────────────────────────────────────────────────────────────────
// Contributor Guidelines:
// ------------------------
// Contributions are welcome under the terms of the Developer Certificate of Origin (DCO).
// All contributors must certify that they have the right to submit the code and agree to
// release it under the above license terms.
//
// Contributions must:
//   - Be original or appropriately attributed
//   - Include clear documentation and test cases where applicable
//   - Respect the coding and security guidelines defined in CONTRIBUTING.md
//
// ─────────────────────────────────────────────────────────────────────────────
// Terms of Use and Disclaimer:
// -----------------------------
// This software is provided "as is", without any express or implied warranty.
// In no event shall the authors, contributors, or copyright holders
// be held liable for any damages arising from the use of this software.
//
// Use of this software in critical systems (e.g., medical, nuclear, safety)
// is entirely at your own risk unless specifically licensed for such purposes.
//
// ─────────────────────────────────────────────────────────────────────────────

#include "uart.h"
#include <stdarg.h>
#include <stdint.h>

// Raspberry Pi 3/4 UART0 registers
// Base address for BCM2835/BCM2836/BCM2837 (Raspberry Pi 2/3)
#define PERIPHERAL_BASE     0x3F000000
// For Raspberry Pi 4, use 0xFE000000 instead

// GPIO registers
#define GPIO_BASE           (PERIPHERAL_BASE + 0x200000)
#define GPFSEL1             ((volatile uint32_t*)(GPIO_BASE + 0x04))
#define GPPUD               ((volatile uint32_t*)(GPIO_BASE + 0x94))
#define GPPUDCLK0           ((volatile uint32_t*)(GPIO_BASE + 0x98))

// UART0 registers
#define UART0_BASE          (PERIPHERAL_BASE + 0x201000)
#define UART0_DR            ((volatile uint32_t*)(UART0_BASE + 0x00))
#define UART0_FR            ((volatile uint32_t*)(UART0_BASE + 0x18))
#define UART0_IBRD          ((volatile uint32_t*)(UART0_BASE + 0x24))
#define UART0_FBRD          ((volatile uint32_t*)(UART0_BASE + 0x28))
#define UART0_LCRH          ((volatile uint32_t*)(UART0_BASE + 0x2C))
#define UART0_CR            ((volatile uint32_t*)(UART0_BASE + 0x30))
#define UART0_IMSC          ((volatile uint32_t*)(UART0_BASE + 0x38))
#define UART0_ICR           ((volatile uint32_t*)(UART0_BASE + 0x44))

// UART0 FR register bits
#define FR_RXFE             0x10    // Receive FIFO empty
#define FR_TXFF             0x20    // Transmit FIFO full

// UART0 LCRH register bits
#define LCRH_WLEN_8BIT      0x60    // 8 bits
#define LCRH_FEN            0x10    // Enable FIFOs

// UART0 CR register bits
#define CR_UARTEN           0x01    // UART enable
#define CR_TXE              0x0100  // Transmit enable
#define CR_RXE              0x0200  // Receive enable

// Delay function - simple busy wait
static void delay(int32_t count) {
    while (count--) {
        asm volatile("nop");
    }
}

// Initialize UART0 for console I/O
void uart_init() {
    // Disable UART0
    *UART0_CR = 0;
    
    // Setup GPIO pins 14 and 15 for UART0
    uint32_t selector = *GPFSEL1;
    selector &= ~((7 << 12) | (7 << 15)); // Clear bits 12-14 (GPIO14) and 15-17 (GPIO15)
    selector |= (4 << 12) | (4 << 15);    // Set bits 12-14 (GPIO14) and 15-17 (GPIO15) to alt0 (UART)
    *GPFSEL1 = selector;
    
    // Disable pull-up/down for GPIO pins
    *GPPUD = 0;
    delay(150);
    *GPPUDCLK0 = (1 << 14) | (1 << 15);
    delay(150);
    *GPPUDCLK0 = 0;
    
    // Clear pending interrupts
    *UART0_ICR = 0x7FF;
    
    // Set baud rate to 115200
    // Divisor = UART_CLOCK / (16 * baud_rate)
    // UART_CLOCK = 48MHz for Raspberry Pi
    // Divisor = 48000000 / (16 * 115200) = 26.0416...
    // Integer part = 26
    // Fractional part = 0.0416... * 64 = 2.66... ~ 3
    *UART0_IBRD = 26;
    *UART0_FBRD = 3;
    
    // Enable 8-bit mode, FIFO, and UART
    *UART0_LCRH = LCRH_WLEN_8BIT | LCRH_FEN;
    *UART0_CR = CR_UARTEN | CR_TXE | CR_RXE;
}

// Check if UART is ready to send
int uart_is_write_ready() {
    return !(*UART0_FR & FR_TXFF);
}

// Check if data is available to read
int uart_is_read_ready() {
    return !(*UART0_FR & FR_RXFE);
}

// Send a single character
void uart_putc(unsigned char c) {
    // Wait until UART is ready to transmit
    while (!uart_is_write_ready());
    
    // Handle newline by sending CR+LF
    if (c == '\n') {
        *UART0_DR = '\r';
        while (!uart_is_write_ready());
    }
    
    // Send the character
    *UART0_DR = c;
}

// Get a single character (blocking)
unsigned char uart_getc() {
    // Wait until data is available
    while (!uart_is_read_ready());
    
    // Read and return the character
    return *UART0_DR;
}

// Send a string
void uart_puts(const char* str) {
    while (*str) {
        uart_putc(*str++);
    }
}

// Simple implementation of printf-like functionality
void uart_printf(const char* fmt, ...) {
    char buffer[256];
    va_list args;
    va_start(args, fmt);
    
    // Very simple implementation - only handles %s, %d, %x
    char* bp = buffer;
    char* p = (char*)fmt;
    
    while (*p) {
        if (*p != '%') {
            *bp++ = *p++;
            continue;
        }
        
        p++; // Skip '%'
        
        switch (*p) {
            case 's': {
                char* s = va_arg(args, char*);
                while (*s) {
                    *bp++ = *s++;
                }
                break;
            }
            case 'd': {
                int val = va_arg(args, int);
                if (val < 0) {
                    *bp++ = '-';
                    val = -val;
                }
                
                // Convert to string (reversed)
                char temp[12];
                int i = 0;
                do {
                    temp[i++] = '0' + (val % 10);
                    val /= 10;
                } while (val > 0);
                
                // Copy in correct order
                while (i > 0) {
                    *bp++ = temp[--i];
                }
                break;
            }
            case 'x': {
                unsigned int val = va_arg(args, unsigned int);
                
                // Convert to hex string (reversed)
                char temp[12];
                int i = 0;
                do {
                    int digit = val & 0xF;
                    temp[i++] = digit < 10 ? '0' + digit : 'a' + digit - 10;
                    val >>= 4;
                } while (val > 0);
                
                // Add 0x prefix
                *bp++ = '0';
                *bp++ = 'x';
                
                // Copy in correct order
                while (i > 0) {
                    *bp++ = temp[--i];
                }
                break;
            }
            default:
                *bp++ = *p;
                break;
        }
        
        p++;
    }
    
    // Null terminate
    *bp = 0;
    
    va_end(args);
    
    // Output the formatted string
    uart_puts(buffer);
}
