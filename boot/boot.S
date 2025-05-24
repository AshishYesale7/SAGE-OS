/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
 * 
 * This file is part of the SAGE OS Project.
 * ───────────────────────────────────────────────────────────────────────────── */

.section ".text.boot"
.globl _start

// Entry point for the kernel
_start:
#if defined(__aarch64__) || defined(__arm64__)
    // AArch64 specific code
    // Check processor ID, stop all but core 0
    mrs     x1, mpidr_el1
    and     x1, x1, #3
    cbz     x1, 2f
    // CPU ID > 0, stop
1:  wfe
    b       1b
2:  // CPU ID == 0

    // Set stack pointer
    ldr     x1, =stack_top
    mov     sp, x1

    // Clear BSS
    ldr     x1, =__bss_start
    ldr     x2, =__bss_end
    cmp     x1, x2
    beq     3f
    
    // Clear loop
    mov     x3, #0
1:  str     x3, [x1], #8
    cmp     x1, x2
    blo     1b
    
3:  // Jump to C code
    bl      kernel_main
    
    // If kernel_main returns, halt the CPU
hang_aarch64:
    wfe
    b       hang_aarch64

#elif defined(__x86_64__)
    // x86_64 specific code
    // Set up stack
    movq    $stack_top, %rsp
    
    // Clear BSS
    movq    $__bss_start, %rdi
    movq    $__bss_end, %rcx
    subq    %rdi, %rcx
    xorq    %rax, %rax
    shrq    $3, %rcx
    rep stosq
    
    // Call kernel_main
    call    kernel_main
    
    // If kernel_main returns, halt the CPU
hang_x86_64:
    hlt
    jmp     hang_x86_64

#elif defined(__riscv) && __riscv_xlen == 64
    // RISC-V 64-bit specific code
    // Set up stack
    la      sp, stack_top
    
    // Clear BSS
    la      t0, __bss_start
    la      t1, __bss_end
    bgeu    t0, t1, 2f
1:
    sd      zero, 0(t0)
    addi    t0, t0, 8
    bltu    t0, t1, 1b
2:
    // Call kernel_main
    call    kernel_main
    
    // If kernel_main returns, halt the CPU
hang_riscv:
    wfi
    j       hang_riscv

#else
    #error "Unsupported architecture"
#endif

.section ".bss"
.align 16
.space 4096
stack_top:
