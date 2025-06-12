/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
 * 
 * This file is part of the SAGE OS Project.
 * ─────────────────────────────────────────────────────────────────────────────
 */

/* Improved i386 Graphics Mode Linker Script */
/* Optimized for QEMU direct kernel loading and multiboot compatibility */

ENTRY(_start)

SECTIONS
{
    /* Kernel starts at 1MB (standard for x86 kernels) */
    . = 0x100000;
    
    /* Kernel start marker */
    __kernel_start = .;
    
    /* Multiboot header must be in first 8KB */
    .multiboot ALIGN(4) : {
        *(.multiboot)
    }
    
    /* Boot code section */
    .text.boot ALIGN(4) : {
        *(.text.boot)
    }
    
    /* Main text section */
    .text ALIGN(4096) : {
        *(.text)
        *(.text.*)
    }
    
    /* Read-only data */
    .rodata ALIGN(4096) : {
        *(.rodata)
        *(.rodata.*)
        *(.gnu.linkonce.r.*)
    }
    
    /* Initialized data */
    .data ALIGN(4096) : {
        *(.data)
        *(.data.*)
        *(.gnu.linkonce.d.*)
    }
    
    /* Small data section (for some compilers) */
    .sdata ALIGN(4) : {
        *(.sdata)
        *(.sdata.*)
    }
    
    /* Uninitialized data (BSS) */
    .bss ALIGN(4096) : {
        __bss_start = .;
        *(.bss)
        *(.bss.*)
        *(.gnu.linkonce.b.*)
        *(COMMON)
        . = ALIGN(4);
        __bss_end = .;
    }
    
    /* Small BSS section */
    .sbss ALIGN(4) : {
        *(.sbss)
        *(.sbss.*)
    }
    
    /* Kernel end marker */
    . = ALIGN(4096);
    __kernel_end = .;
    
    /* Debugging sections (not loaded into memory) */
    .debug_info     0 : { *(.debug_info) }
    .debug_abbrev   0 : { *(.debug_abbrev) }
    .debug_line     0 : { *(.debug_line) }
    .debug_str      0 : { *(.debug_str) }
    .debug_ranges   0 : { *(.debug_ranges) }
    
    /* Discard unnecessary sections */
    /DISCARD/ : {
        *(.comment)
        *(.note)
        *(.note.*)
        *(.eh_frame)
        *(.eh_frame_hdr)
    }
}

/* Provide symbols for kernel size calculation */
__kernel_size = __kernel_end - __kernel_start;