# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS Boot Code (x86_64 without multiboot header)

.section ".text"
.global _start

_start:
    // Disable interrupts
    cli
    
    // Set up stack
    mov $stack_top, %rsp
    
    // Clear direction flag
    cld
    
    // Call kernel main
    call kernel_main
    
    // If kernel_main returns, halt
halt_loop:
    hlt
    jmp halt_loop

// Stack space
.section ".bss"
.align 16
stack_bottom:
    .skip 16384  // 16KB stack
stack_top: