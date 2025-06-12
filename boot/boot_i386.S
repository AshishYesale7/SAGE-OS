# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

/* Multiboot header for i386 */
.section .multiboot,"a",@progbits
.align 4
multiboot_header:
    .long 0x1BADB002          /* magic */
    .long 0x00000000          /* flags */
    .long -(0x1BADB002 + 0x00000000)  /* checksum */

.section .text,"ax",@progbits
.global _start

_start:
    /* Disable interrupts */
    cli
    
    /* Set up stack */
    movl $stack_top, %esp
    
    /* Clear direction flag */
    cld
    
    /* Call kernel main */
    call kernel_main
    
    /* If kernel_main returns, halt */
halt_loop:
    hlt
    jmp halt_loop

/* Stack space */
.section .bss,"aw",@nobits
.align 16
stack_bottom:
    .skip 16384  /* 16KB stack */
stack_top: