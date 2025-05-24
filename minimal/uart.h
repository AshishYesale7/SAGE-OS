/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
 * 
 * This file is part of the SAGE OS Project.
 * ───────────────────────────────────────────────────────────────────────────── */

#ifndef UART_H
#define UART_H

// Initialize UART
void uart_init();

// Send a character
void uart_putc(unsigned char c);

// Receive a character
unsigned char uart_getc();

// Send a string
void uart_puts(const char* str);

#endif // UART_H