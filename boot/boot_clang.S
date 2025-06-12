/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
 * 
 * This file is part of the SAGE OS Project - Clang/macOS Compatible Version
 * ───────────────────────────────────────────────────────────────────────────── */

#if defined(__x86_64__) || defined(__i386__)

// Multiboot header for x86 - must be at the very beginning
.section __TEXT,__multiboot
.align 4

#define MULTIBOOT_MAGIC         0x1BADB002
#define MULTIBOOT_FLAGS         0x00000003
#define MULTIBOOT_CHECKSUM      -(MULTIBOOT_MAGIC + MULTIBOOT_FLAGS)

multiboot_header:
    .long MULTIBOOT_MAGIC
    .long MULTIBOOT_FLAGS
    .long MULTIBOOT_CHECKSUM

.section __TEXT,__text
.global _start

// Entry point for the kernel
_start:
    // Disable interrupts
    cli
    
    // Set up stack
#ifdef __x86_64__
    movq $stack_top, %rsp
#else
    movl $stack_top, %esp
#endif
    
    // Clear direction flag
    cld
    
    // Call kernel main
    call _kernel_main
    
    // If kernel_main returns, halt
halt_loop:
    hlt
    jmp halt_loop

// Stack space
.section __DATA,__bss
.align 16
stack_bottom:
    .space 16384  // 16KB stack
stack_top:

#elif defined(__aarch64__)

// ARM64 boot code
.section __TEXT,__text
.global _start

_start:
    // Set up stack pointer
    adrp x0, stack_top
    add sp, x0, :lo12:stack_top
    
    // Call kernel main
    bl _kernel_main
    
    // If kernel_main returns, halt
halt_loop:
    wfe
    b halt_loop

.section __DATA,__bss
.align 16
stack_bottom:
    .space 16384  // 16KB stack
stack_top:

#elif defined(__riscv)

// RISC-V boot code
.section .text
.global _start

_start:
    // Set up stack pointer
    la sp, stack_top
    
    // Call kernel main
    call kernel_main
    
    // If kernel_main returns, halt
halt_loop:
    wfi
    j halt_loop

.section .bss
.align 16
stack_bottom:
    .space 16384  // 16KB stack
stack_top:

#else
#error "Unsupported architecture"
#endif