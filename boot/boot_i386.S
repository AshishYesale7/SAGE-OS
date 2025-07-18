# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# Cross-platform i386 boot assembly
# Compatible with both Linux GAS and macOS clang

# Use AT&T syntax (default for GAS)
.att_syntax prefix

# Multiboot header section
.section .multiboot
.align 4
multiboot_header:
    .long 0x1BADB002          # magic number
    .long 0x00000000          # flags
    .long -(0x1BADB002 + 0x00000000)  # checksum

# Text section for code
.section .text
.global _start

_start:
    # Disable interrupts
    cli
    
    # Set up stack pointer
    movl $stack_top, %esp
    
    # Clear direction flag for string operations
    cld
    
    # Call the kernel main function
    call kernel_main
    
    # If kernel_main returns, halt the system
halt_loop:
    hlt
    jmp halt_loop

# BSS section for uninitialized data
.section .bss
.align 16
stack_bottom:
    .skip 16384  # 16KB stack space
stack_top: