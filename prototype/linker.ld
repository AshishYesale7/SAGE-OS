ENTRY(_start)

SECTIONS
{
    /* Kernel starts at 0x80000 for Raspberry Pi */
    . = 0x80000;
    
    /* Boot code section */
    .text.boot : {
        *(.text.boot)
    }
    
    /* Text section */
    .text : {
        *(.text)
    }
    
    /* Read-only data section */
    .rodata : {
        *(.rodata)
    }
    
    /* Data section */
    .data : {
        *(.data)
    }
    
    /* BSS section */
    __bss_start = .;
    .bss : {
        *(.bss)
    }
    __bss_end = .;
    
    /* End of kernel */
    . = ALIGN(8);
    __end = .;
}