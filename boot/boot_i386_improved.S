# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# Improved i386 Boot Loader with Enhanced Multiboot Support
# This boot loader provides better compatibility with QEMU and multiboot loaders

.code32

# Multiboot header constants
.set MULTIBOOT_MAGIC,       0x1BADB002
.set MULTIBOOT_FLAGS,       0x00000003  # ALIGN + MEMINFO
.set MULTIBOOT_CHECKSUM,    -(MULTIBOOT_MAGIC + MULTIBOOT_FLAGS)

# Stack size
.set STACK_SIZE, 0x4000  # 16KB stack

# Multiboot header - must be in first 8KB of kernel
.section .multiboot, "a", @progbits
.align 4
multiboot_header:
    .long MULTIBOOT_MAGIC
    .long MULTIBOOT_FLAGS
    .long MULTIBOOT_CHECKSUM

# Boot code section
.section .text.boot, "ax", @progbits
.global _start
.type _start, @function

_start:
    # Disable interrupts immediately
    cli
    
    # Check if we were loaded by a multiboot-compliant loader
    cmpl $0x36d76289, %eax
    jne not_multiboot
    
    # Save multiboot info pointer (in %ebx)
    movl %ebx, multiboot_info_ptr
    
    # Set up stack pointer
    movl $stack_top, %esp
    
    # Clear direction flag (for string operations)
    cld
    
    # Clear EFLAGS
    pushl $0
    popfl
    
    # Initialize BSS section to zero
    call clear_bss
    
    # Set up basic GDT (Global Descriptor Table)
    call setup_gdt
    
    # Enable A20 line (for accessing memory above 1MB)
    call enable_a20
    
    # Call kernel main function
    call kernel_main
    
    # If kernel_main returns, halt the system
    jmp halt_system

not_multiboot:
    # If not loaded by multiboot loader, try to continue anyway
    # This allows direct kernel loading by QEMU
    movl $0, multiboot_info_ptr
    movl $stack_top, %esp
    cld
    call clear_bss
    call setup_gdt
    call enable_a20
    call kernel_main
    jmp halt_system

# Clear BSS section
clear_bss:
    movl $__bss_start, %edi
    movl $__bss_end, %ecx
    subl %edi, %ecx
    xorl %eax, %eax
    rep stosb
    ret

# Set up basic GDT
setup_gdt:
    lgdt gdt_descriptor
    
    # Reload segment registers
    movw $0x10, %ax  # Data segment selector
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs
    movw %ax, %ss
    
    # Far jump to reload CS
    ljmp $0x08, $gdt_flush
gdt_flush:
    ret

# Enable A20 line using keyboard controller method
enable_a20:
    # Check if A20 is already enabled
    call check_a20
    testl %eax, %eax
    jnz a20_enabled
    
    # Try keyboard controller method
    call wait_8042
    movb $0xAD, %al
    outb %al, $0x64
    
    call wait_8042
    movb $0xD0, %al
    outb %al, $0x64
    
    call wait_8042_data
    inb $0x60, %al
    pushl %eax
    
    call wait_8042
    movb $0xD1, %al
    outb %al, $0x64
    
    call wait_8042
    popl %eax
    orb $2, %al
    outb %al, $0x60
    
    call wait_8042
    movb $0xAE, %al
    outb %al, $0x64
    
    call wait_8042
    
a20_enabled:
    ret

# Wait for keyboard controller
wait_8042:
    inb $0x64, %al
    testb $2, %al
    jnz wait_8042
    ret

wait_8042_data:
    inb $0x64, %al
    testb $1, %al
    jz wait_8042_data
    ret

# Check if A20 line is enabled
check_a20:
    pushfl
    pushl %esi
    pushl %edi
    
    movl $0x112345, %esi
    movl $0x012345, %edi
    movl (%esi), %eax
    pushl %eax
    movl (%edi), %eax
    pushl %eax
    
    movl $0x00, (%esi)
    movl $0xFF, (%edi)
    cmpl $0xFF, (%esi)
    
    popl %eax
    movl %eax, (%edi)
    popl %eax
    movl %eax, (%esi)
    
    movl $0, %eax
    je check_a20_exit
    movl $1, %eax
    
check_a20_exit:
    popl %edi
    popl %esi
    popfl
    ret

# System halt with proper cleanup
halt_system:
    cli
    
    # Try ACPI shutdown first (for QEMU)
    movw $0x2000, %ax
    movw $0x604, %dx
    outw %ax, %dx
    
    # If ACPI fails, use traditional halt
halt_loop:
    hlt
    jmp halt_loop

# Global Descriptor Table
.section .data
.align 8
gdt_start:
    # Null descriptor
    .quad 0x0000000000000000
    
    # Code segment descriptor (0x08)
    .quad 0x00CF9A000000FFFF
    
    # Data segment descriptor (0x10)
    .quad 0x00CF92000000FFFF

gdt_end:

gdt_descriptor:
    .word gdt_end - gdt_start - 1
    .long gdt_start

# Multiboot information pointer storage
.section .bss
.align 4
multiboot_info_ptr:
    .skip 4

# Stack space
.align 16
stack_bottom:
    .skip STACK_SIZE
stack_top:

# Make symbols available to linker
.global multiboot_info_ptr
.global __bss_start
.global __bss_end