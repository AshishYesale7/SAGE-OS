/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
 * 
 * This file is part of the SAGE OS Project.
 * ───────────────────────────────────────────────────────────────────────────── */

#ifndef SERIAL_H
#define SERIAL_H

#include <stdint.h>

// Serial communication functions
// Implementations are architecture-specific and defined in serial.c
void serial_init(void);
void serial_putc(char c);
void serial_puts(const char* str);
const char* serial_get_uart_info(void);

#endif // SERIAL_H