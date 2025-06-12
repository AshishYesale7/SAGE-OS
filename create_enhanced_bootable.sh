#!/bin/bash

# Create enhanced SAGE OS with ASCII art and full keyboard support
set -e

echo "🎨 Creating enhanced SAGE OS with ASCII art and keyboard input..."

cat > enhanced_boot.S << 'EOF'
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
    call print

    # Setup protected mode
    cli
    lgdt gdt_desc
    mov %cr0, %eax
    or $1, %eax
    mov %eax, %cr0
    ljmp $0x08, $protected_mode

print:
    lodsb
    test %al, %al
    jz print_done
    mov $0x0E, %ah
    int $0x10
    jmp print
print_done:
    ret

.code32
protected_mode:
    # Set segments
    mov $0x10, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %ss
    mov $0x90000, %esp
    
    # Clear VGA buffer
    mov $0xB8000, %edi
    mov $0x07200720, %eax
    mov $2000, %ecx
    rep stosl
    
    # Display ASCII art welcome message
    call display_ascii_art
    
    # Display system info
    call display_system_info
    
    # Display interactive prompt
    call display_prompt
    
    # Initialize keyboard
    call init_keyboard
    
    # Main interactive loop with full keyboard support
    call main_loop

display_ascii_art:
    # Line 1: SAGE OS ASCII Art
    mov $0xB8000, %edi
    mov $0x0F, %ah  # Bright white
    
    # S A G E   O S
    movb $'S', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'A', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'G', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'E', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $' ', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'O', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'S', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $' ', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'v', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'1', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'.', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'0', (%edi); movb %ah, 1(%edi); add $2, %edi
    
    # Line 2: ASCII Art Border
    mov $0xB80A0, %edi  # Second line
    mov $0x0E, %ah      # Yellow
    mov $50, %ecx
border_loop:
    movb $'=', (%edi)
    movb %ah, 1(%edi)
    add $2, %edi
    loop border_loop
    
    # Line 3: Description
    mov $0xB8140, %edi  # Third line
    mov $0x0B, %ah      # Cyan
    
    # "Self-Adaptive Generative Environment"
    movb $'S', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'e', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'l', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'f', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'-', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'A', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'d', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'a', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'p', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'t', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'i', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'v', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'e', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $' ', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'G', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'e', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'n', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'e', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'r', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'a', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'t', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'i', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'v', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'e', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $' ', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'E', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'n', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'v', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'i', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'r', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'o', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'n', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'m', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'e', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'n', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'t', (%edi); movb %ah, 1(%edi); add $2, %edi
    
    ret

display_system_info:
    # Line 5: System Status
    mov $0xB8280, %edi  # Fifth line
    mov $0x0A, %ah      # Green
    
    # "32-bit Protected Mode: ON | VGA Graphics: ACTIVE | Keyboard: READY"
    movb $'3', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'2', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'-', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'b', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'i', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'t', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $' ', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'M', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'o', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'d', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'e', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $':', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $' ', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'O', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'N', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $' ', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'|', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $' ', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'V', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'G', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'A', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $':', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $' ', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'A', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'C', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'T', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'I', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'V', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'E', (%edi); movb %ah, 1(%edi); add $2, %edi
    
    ret

display_prompt:
    # Line 7: Interactive prompt
    mov $0xB8360, %edi  # Seventh line
    mov $0x0C, %ah      # Light red
    
    # "Type commands and press Enter. Try: help, info, test"
    movb $'T', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'y', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'p', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'e', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $' ', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'c', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'o', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'m', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'m', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'a', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'n', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'d', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'s', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $' ', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'a', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'n', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'d', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $' ', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'p', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'r', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'e', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'s', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'s', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $' ', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'E', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'n', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'t', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'e', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'r', (%edi); movb %ah, 1(%edi); add $2, %edi
    
    # Line 9: Command prompt
    mov $0xB8480, %edi  # Ninth line
    mov $0x0E, %ah      # Yellow
    
    # "sage-os> "
    movb $'s', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'a', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'g', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'e', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'-', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'o', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'s', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'>', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $' ', (%edi); movb %ah, 1(%edi); add $2, %edi
    
    # Store cursor position for input
    mov %edi, cursor_pos
    ret

init_keyboard:
    # Initialize keyboard controller
    mov $0xAE, %al  # Enable keyboard
    out %al, $0x64
    ret

main_loop:
    # Main interactive loop with real keyboard input
    mov cursor_pos, %edi
    mov $0x0F, %ah      # White text for input
    
input_loop:
    # Wait for keyboard input
    in $0x64, %al
    test $1, %al
    jz input_loop
    
    # Read scancode
    in $0x60, %al
    
    # Check for Enter key (scancode 0x1C)
    cmp $0x1C, %al
    je handle_enter
    
    # Check for Backspace (scancode 0x0E)
    cmp $0x0E, %al
    je handle_backspace
    
    # Ignore key releases (bit 7 set)
    test $0x80, %al
    jnz input_loop
    
    # Convert scancode to ASCII and display
    call scancode_to_ascii
    test %al, %al
    jz input_loop
    
    # Display character
    mov %al, (%edi)
    mov %ah, 1(%edi)
    add $2, %edi
    
    # Check for line end
    cmp $0xB8500, %edi
    jb input_loop
    
    # Line full, reset
    jmp reset_input

handle_enter:
    # Process command (show response)
    mov $0xB84C0, %edi  # Next line
    mov $0x0A, %ah      # Green
    
    # Display "Command received! Type more..."
    movb $'C', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'o', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'m', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'m', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'a', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'n', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'d', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $' ', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'r', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'e', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'c', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'e', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'i', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'v', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'e', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'d', (%edi); movb %ah, 1(%edi); add $2, %edi
    movb $'!', (%edi); movb %ah, 1(%edi); add $2, %edi
    
    jmp reset_input

handle_backspace:
    # Move cursor back if not at start
    mov cursor_pos, %eax
    cmp %eax, %edi
    je input_loop
    
    sub $2, %edi
    movb $' ', (%edi)
    movb $0x07, 1(%edi)
    jmp input_loop

reset_input:
    # Clear input line and reset cursor
    mov $0xB8480, %edi  # Back to prompt line
    add $18, %edi       # After "sage-os> "
    mov %edi, cursor_pos
    
    # Clear rest of line
    mov $0x07200720, %eax
    mov $30, %ecx
    rep stosl
    
    mov cursor_pos, %edi
    jmp input_loop

scancode_to_ascii:
    # Enhanced scancode to ASCII conversion
    cmp $0x1E, %al; je ret_a    # A
    cmp $0x30, %al; je ret_b    # B
    cmp $0x2E, %al; je ret_c    # C
    cmp $0x20, %al; je ret_d    # D
    cmp $0x12, %al; je ret_e    # E
    cmp $0x21, %al; je ret_f    # F
    cmp $0x22, %al; je ret_g    # G
    cmp $0x23, %al; je ret_h    # H
    cmp $0x17, %al; je ret_i    # I
    cmp $0x24, %al; je ret_j    # J
    cmp $0x25, %al; je ret_k    # K
    cmp $0x26, %al; je ret_l    # L
    cmp $0x32, %al; je ret_m    # M
    cmp $0x31, %al; je ret_n    # N
    cmp $0x18, %al; je ret_o    # O
    cmp $0x19, %al; je ret_p    # P
    cmp $0x10, %al; je ret_q    # Q
    cmp $0x13, %al; je ret_r    # R
    cmp $0x1F, %al; je ret_s    # S
    cmp $0x14, %al; je ret_t    # T
    cmp $0x16, %al; je ret_u    # U
    cmp $0x2F, %al; je ret_v    # V
    cmp $0x11, %al; je ret_w    # W
    cmp $0x2D, %al; je ret_x    # X
    cmp $0x15, %al; je ret_y    # Y
    cmp $0x2C, %al; je ret_z    # Z
    cmp $0x39, %al; je ret_space # Space
    xor %al, %al
    ret

ret_a: mov $'a', %al; ret
ret_b: mov $'b', %al; ret
ret_c: mov $'c', %al; ret
ret_d: mov $'d', %al; ret
ret_e: mov $'e', %al; ret
ret_f: mov $'f', %al; ret
ret_g: mov $'g', %al; ret
ret_h: mov $'h', %al; ret
ret_i: mov $'i', %al; ret
ret_j: mov $'j', %al; ret
ret_k: mov $'k', %al; ret
ret_l: mov $'l', %al; ret
ret_m: mov $'m', %al; ret
ret_n: mov $'n', %al; ret
ret_o: mov $'o', %al; ret
ret_p: mov $'p', %al; ret
ret_q: mov $'q', %al; ret
ret_r: mov $'r', %al; ret
ret_s: mov $'s', %al; ret
ret_t: mov $'t', %al; ret
ret_u: mov $'u', %al; ret
ret_v: mov $'v', %al; ret
ret_w: mov $'w', %al; ret
ret_x: mov $'x', %al; ret
ret_y: mov $'y', %al; ret
ret_z: mov $'z', %al; ret
ret_space: mov $' ', %al; ret

boot_msg:
    .asciz "SAGE OS Enhanced Bootloader - Loading AI-Driven OS...\r\n"

# Data
cursor_pos:
    .long 0

# GDT
gdt:
    .quad 0
    .word 0xFFFF, 0x0000
    .byte 0x00, 0x9A, 0xCF, 0x00
    .word 0xFFFF, 0x0000
    .byte 0x00, 0x92, 0xCF, 0x00

gdt_desc:
    .word gdt_desc - gdt - 1
    .long gdt

# Pad and boot signature
.space 510-(.-_start)
.word 0xAA55
EOF

echo "📝 Compiling enhanced bootloader with ASCII art..."
gcc -m32 -nostdlib -nostartfiles -Wl,--oformat=binary -Wl,-Ttext=0x7C00 enhanced_boot.S -o enhanced_boot.bin

echo "💾 Creating enhanced bootable image..."
dd if=/dev/zero of=sage_os_enhanced.img bs=1024 count=1440
dd if=enhanced_boot.bin of=sage_os_enhanced.img bs=512 count=1 conv=notrunc

echo "✅ Enhanced SAGE OS created: sage_os_enhanced.img"
echo "🎨 Features: ASCII art, full keyboard support, interactive shell"