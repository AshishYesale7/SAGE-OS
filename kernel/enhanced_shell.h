/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Enhanced Shell Header
 * Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * ───────────────────────────────────────────────────────────────────────────── */

#ifndef ENHANCED_SHELL_H
#define ENHANCED_SHELL_H

#include "types.h"

// Initialize the enhanced shell
void enhanced_shell_init(void);

// Process a command
void enhanced_shell_process_command(const char* command);

// Run the enhanced shell (main loop)
void enhanced_shell_run(void);

#endif // ENHANCED_SHELL_H