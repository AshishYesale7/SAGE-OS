# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# macOS-compatible i386 boot assembly
# This version uses macOS-specific assembly syntax and sections

.intel_syntax noprefix

# Text section for code
.section __TEXT,__text
.globl _start

# Multiboot header - must be at the beginning
.align 4
multiboot_header:
    .long 0x1BADB002          # magic number
    .long 0x00000000          # flags
    .long -(0x1BADB002 + 0x00000000)  # checksum

# Entry point
_start:
    # Disable interrupts
    cli
    
    # Set up stack pointer
    mov esp, offset stack_top
    
    # Clear direction flag for string operations
    cld
    
    # Call the kernel main function
    call _kernel_main
    
    # If kernel_main returns, halt the system
halt_loop:
    hlt
    jmp halt_loop

# BSS section for uninitialized data
.section __DATA,__bss
.align 16
stack_bottom:
    .space 16384  # 16KB stack space
stack_top: