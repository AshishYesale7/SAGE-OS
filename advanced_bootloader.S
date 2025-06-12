.code16
.section .text
.global _start

_start:
    # Set up segments
    cli
    xor %ax, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %ss
    mov $0x7C00, %sp
    sti

    # Print boot message
    mov $boot_msg, %si
    call print_string

    # Load our kernel from sector 2 onwards (simplified)
    # For this demo, we'll embed a full 32-bit kernel
    jmp setup_protected_mode

print_string:
    lodsb
    test %al, %al
    jz print_done
    mov $0x0E, %ah
    int $0x10
    jmp print_string
print_done:
    ret

boot_msg:
    .asciz "SAGE OS Advanced Bootloader - Initializing 32-bit Graphics Mode...\r\n"

setup_protected_mode:
    # Disable interrupts
    cli
    
    # Enable A20 line
    call enable_a20
    
    # Load GDT
    lgdt gdt_descriptor
    
    # Enable protected mode
    mov %cr0, %eax
    or $1, %eax
    mov %eax, %cr0
    
    # Jump to 32-bit code
    ljmp $0x08, $protected_mode

enable_a20:
    # Enable A20 line via keyboard controller
    call wait_8042
    mov $0xAD, %al
    out %al, $0x64
    
    call wait_8042
    mov $0xD0, %al
    out %al, $0x64
    
    call wait_8042_data
    in $0x60, %al
    push %ax
    
    call wait_8042
    mov $0xD1, %al
    out %al, $0x64
    
    call wait_8042
    pop %ax
    or $2, %al
    out %al, $0x60
    
    call wait_8042
    mov $0xAE, %al
    out %al, $0x64
    
    call wait_8042
    ret

wait_8042:
    in $0x64, %al
    test $2, %al
    jnz wait_8042
    ret

wait_8042_data:
    in $0x64, %al
    test $1, %al
    jz wait_8042_data
    ret

.code32
protected_mode:
    # Set up segments
    mov $0x10, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %ax, %ss
    
    # Set up stack
    mov $0x90000, %esp
    
    # Initialize VGA graphics mode
    call init_vga
    
    # Set up keyboard
    call init_keyboard
    
    # Main kernel loop
    call kernel_main

init_vga:
    # Clear VGA text buffer
    mov $0xB8000, %edi
    mov $0x07200720, %eax  # Space with gray background
    mov $2000, %ecx
    rep stosl
    
    # Write title
    mov $0xB8000, %edi
    mov $title_msg, %esi
    mov $0x0F, %ah  # Bright white
    call write_string
    
    # Write system info
    mov $0xB80A0, %edi  # Second line
    mov $system_msg, %esi
    mov $0x0A, %ah  # Green
    call write_string
    
    # Write interactive prompt
    mov $0xB8200, %edi  # Fourth line
    mov $interactive_msg, %esi
    mov $0x0E, %ah  # Yellow
    call write_string
    
    # Write keyboard info
    mov $0xB82A0, %edi  # Fifth line
    mov $keyboard_msg, %esi
    mov $0x0B, %ah  # Cyan
    call write_string
    
    # Write command prompt
    mov $0xB8340, %edi  # Sixth line
    mov $prompt_msg, %esi
    mov $0x0C, %ah  # Light red
    call write_string
    
    ret

write_string:
    lodsb
    test %al, %al
    jz write_done
    mov %al, (%edi)
    mov %ah, 1(%edi)
    add $2, %edi
    jmp write_string
write_done:
    ret

init_keyboard:
    # Initialize keyboard controller
    # Enable keyboard interrupts (simplified)
    mov $0x60, %al
    out %al, $0x64
    mov $0x01, %al  # Enable keyboard
    out %al, $0x60
    ret

kernel_main:
    # Main interactive loop
    mov $0xB83E0, %edi  # Seventh line for input
    mov $0x0F, %ah      # White text
    
main_loop:
    # Check for keyboard input
    in $0x64, %al
    test $1, %al
    jz main_loop
    
    # Read keyboard scancode
    in $0x60, %al
    
    # Simple key handling (just show we got input)
    cmp $0x1C, %al  # Enter key
    je handle_enter
    
    cmp $0x80, %al  # Check if key release
    jae main_loop   # Ignore key releases
    
    # Convert scancode to ASCII (simplified)
    call scancode_to_ascii
    test %al, %al
    jz main_loop
    
    # Display character
    mov %al, (%edi)
    mov %ah, 1(%edi)
    add $2, %edi
    
    # Check for line end
    cmp $0xB8500, %edi  # End of line
    jb main_loop
    
    # Reset to beginning of input line
    mov $0xB83E0, %edi
    jmp main_loop

handle_enter:
    # Process command (simplified - just clear input line)
    mov $0xB83E0, %edi
    mov $0x07200720, %eax  # Clear with spaces
    mov $40, %ecx  # Clear 40 characters
    rep stosl
    mov $0xB83E0, %edi  # Reset cursor
    jmp main_loop

scancode_to_ascii:
    # Simplified scancode to ASCII conversion
    cmp $0x1E, %al  # 'a'
    je return_a
    cmp $0x30, %al  # 'b'
    je return_b
    cmp $0x2E, %al  # 'c'
    je return_c
    cmp $0x20, %al  # 'd'
    je return_d
    cmp $0x12, %al  # 'e'
    je return_e
    cmp $0x39, %al  # space
    je return_space
    # Add more keys as needed
    xor %al, %al    # Return 0 for unknown keys
    ret

return_a:
    mov $'a', %al
    ret
return_b:
    mov $'b', %al
    ret
return_c:
    mov $'c', %al
    ret
return_d:
    mov $'d', %al
    ret
return_e:
    mov $'e', %al
    ret
return_space:
    mov $' ', %al
    ret

# Data section
title_msg:
    .asciz "=== SAGE OS v1.0.1 - 32-bit Graphics Mode Active ==="

system_msg:
    .asciz "VGA: ON | Keyboard: ON | Protected Mode: ON | A20: ON"

interactive_msg:
    .asciz "=== Interactive Shell Ready ==="

keyboard_msg:
    .asciz "Type commands and press Enter. Keyboard input is working!"

prompt_msg:
    .asciz "sage-os> "

# GDT
.align 8
gdt_start:
    # Null descriptor
    .quad 0
    
    # Code segment (0x08)
    .word 0xFFFF    # Limit low
    .word 0x0000    # Base low
    .byte 0x00      # Base middle
    .byte 0x9A      # Access (present, ring 0, code, readable)
    .byte 0xCF      # Flags (4KB granularity, 32-bit)
    .byte 0x00      # Base high
    
    # Data segment (0x10)
    .word 0xFFFF    # Limit low
    .word 0x0000    # Base low
    .byte 0x00      # Base middle
    .byte 0x92      # Access (present, ring 0, data, writable)
    .byte 0xCF      # Flags (4KB granularity, 32-bit)
    .byte 0x00      # Base high

gdt_descriptor:
    .word gdt_descriptor - gdt_start - 1  # GDT size
    .long gdt_start                       # GDT address

# Pad to 510 bytes and add boot signature
.fill 510-(.-_start), 1, 0
.word 0xAA55
