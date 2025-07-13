/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
 * 
 * This file is part of the SAGE OS Project.
 * ───────────────────────────────────────────────────────────────────────────── */

#ifndef UTILS_H
#define UTILS_H

#include "types.h"

// Function declarations
int utoa_base(unsigned int value, char* buffer, int base);
int my_itoa(int value, char* buffer, int base);
size_t my_strlen(const char* str);
char* my_strcat(char* dest, const char* src);
char* strcat(char* dest, const char* src);

#endif // UTILS_H