/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
 * 
 * This file is part of the SAGE OS Project.
 * Fixed version compatible with both GNU as and clang
 * ───────────────────────────────────────────────────────────────────────────── */

#if defined(__x86_64__) || defined(__i386__)

/* Multiboot header for x86 - must be at the very beginning */
.section .multiboot,"a",@progbits
.align 4

#define MULTIBOOT_MAGIC         0x1BADB002
#define MULTIBOOT_FLAGS         0x00000003
#define MULTIBOOT_CHECKSUM      -(MULTIBOOT_MAGIC + MULTIBOOT_FLAGS)

multiboot_header:
    .long MULTIBOOT_MAGIC
    .long MULTIBOOT_FLAGS
    .long MULTIBOOT_CHECKSUM

.section .text,"ax",@progbits
.global _start

/* Entry point for the kernel */
_start:
    /* Disable interrupts */
    cli
    
    /* Set up stack */
#ifdef __x86_64__
    movq $stack_top, %rsp
#else
    movl $stack_top, %esp
#endif
    
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

#elif defined(__aarch64__) || defined(__arm64__)

.section .text,"ax",@progbits
.global _start

_start:
    /* Check processor ID, stop all but core 0 */
    mrs     x1, mpidr_el1
    and     x1, x1, #3
    cbz     x1, 2f
    /* CPU ID > 0, stop */
1:  wfe
    b       1b
2:  /* CPU ID == 0 */

    /* Set stack pointer */
    ldr     x1, =stack_top
    mov     sp, x1

    /* Jump to kernel main */
    bl      kernel_main
    /* Should never return */
4:  wfe
    b       4b

/* Stack space */
.section .bss,"aw",@nobits
.align 16
stack_bottom:
    .skip 16384  /* 16KB stack */
stack_top:

#elif defined(__riscv) && (__riscv_xlen == 64)

.section .text,"ax",@progbits
.global _start

_start:
    /* Set stack pointer */
    la      sp, stack_top

    /* Jump to kernel main */
    call    kernel_main
    /* Should never return */
2:  wfi
    j       2b

/* Stack space */
.section .bss,"aw",@nobits
.align 16
stack_bottom:
    .skip 16384  /* 16KB stack */
stack_top:

#else
    #error "Unsupported architecture"
#endif