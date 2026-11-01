/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
 * 
 * This file is part of the SAGE OS Project.
 * ───────────────────────────────────────────────────────────────────────────── */
#ifndef AZR_H
#define AZR_H

#include <stdint.h>

int azr_init(const char *model_path);
int azr_translate_syscall(int syscall_num, void *args);
void azr_destroy();

#endif // AZR_H
