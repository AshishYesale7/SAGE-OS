/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
 * 
 * This file is part of the SAGE OS Project.
 * ───────────────────────────────────────────────────────────────────────────── */
#ifndef AI_HAT_H
#define AI_HAT_H

int ai_hat_init();
int ai_hat_run_model(const char *model_name, void *input, void *output);
void ai_hat_shutdown();

#endif // AI_HAT_H
