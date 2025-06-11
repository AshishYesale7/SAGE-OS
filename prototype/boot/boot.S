# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────
.section ".text.boot"
.global _start

// AArch64 mode
.code 64

// Align to 4K page
.align 12

_start:
    // Check processor ID, stop all but core 0
    mrs     x1, mpidr_el1
    and     x1, x1, #3
    cbz     x1, 2f
1:  // CPU ID > 0, stop
    wfe
    b       1b
2:  // CPU ID == 0, continue

    // Set stack pointer
    ldr     x1, =_start
    mov     sp, x1

    // Clear BSS
    ldr     x1, =__bss_start
    ldr     x2, =__bss_end
    cmp     x1, x2
    b.ge    3f
1:  // Zero BSS loop
    str     xzr, [x1], #8
    cmp     x1, x2
    b.lt    1b
3:  // BSS cleared

    // Jump to C code, kernel_init is our entry point
    bl      kernel_init
    
    // If kernel_init returns, halt this core
    // Should never reach here
    b       1b

// Dummy handler for exceptions
.global exception_handler
exception_handler:
    b       exception_handler