# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS Boot Code for ARM64/AArch64

.section ".text"
.global _start

_start:
    # Disable interrupts
    msr daifset, #0xf
    
    # Set up stack pointer
    ldr x0, =stack_top
    mov sp, x0
    
    # Call kernel main directly (skip BSS clearing for now)
    bl kernel_main
    
    # If kernel_main returns, halt
halt_loop:
    wfi  // Wait for interrupt (ARM64 halt equivalent)
    b halt_loop

# Stack space
.section ".bss"
.align 16
stack_bottom:
    .skip 16384  // 16KB stack
stack_top:

# BSS markers (will be defined by linker script)
.weak __bss_start
.weak __bss_end
__bss_start:
__bss_end: