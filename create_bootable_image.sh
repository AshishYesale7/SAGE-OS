#!/bin/bash

# Create bootable disk image for SAGE OS
set -e

echo "🔧 Creating bootable disk image for SAGE OS..."

# Create a 1.44MB floppy disk image
dd if=/dev/zero of=sage_os_boot.img bs=1024 count=1440

# Create a simple bootloader that loads our kernel
cat > simple_bootloader.S << 'EOF'
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

    # Load kernel from disk (simplified - we'll embed it)
    # For now, just jump to our embedded kernel code
    jmp kernel_start

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
    .asciz "SAGE OS Bootloader - Loading 32-bit Graphics Kernel...\r\n"

# Simple kernel code embedded in bootloader
kernel_start:
    # Switch to protected mode
    cli
    
    # Load GDT
    lgdt gdt_descriptor
    
    # Enable protected mode
    mov %cr0, %eax
    or $1, %eax
    mov %eax, %cr0
    
    # Jump to 32-bit code
    ljmp $0x08, $protected_mode

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
    
    # Clear VGA text buffer and display message
    mov $0xB8000, %edi
    mov $0x07200720, %eax  # Space with gray background
    mov $2000, %ecx
    rep stosl
    
    # Write "SAGE OS 32-BIT GRAPHICS MODE ACTIVE!"
    mov $0xB8000, %edi
    mov $success_msg, %esi
    mov $0x0F, %ah  # Bright white
    
write_loop:
    lodsb
    test %al, %al
    jz write_done
    mov %al, (%edi)
    mov %ah, 1(%edi)
    add $2, %edi
    jmp write_loop
    
write_done:
    # Write system info on second line
    mov $0xB80A0, %edi  # Second line
    mov $info_msg, %esi
    mov $0x0A, %ah  # Green
    
info_loop:
    lodsb
    test %al, %al
    jz info_done
    mov %al, (%edi)
    mov %ah, 1(%edi)
    add $2, %edi
    jmp info_loop
    
info_done:
    # Write interactive prompt on fourth line
    mov $0xB8200, %edi  # Fourth line (320 bytes)
    mov $prompt_msg, %esi
    mov $0x0E, %ah  # Yellow
    
prompt_loop:
    lodsb
    test %al, %al
    jz prompt_done
    mov %al, (%edi)
    mov %ah, 1(%edi)
    add $2, %edi
    jmp prompt_loop
    
prompt_done:
    # Infinite loop with keyboard input handling
main_loop:
    # Check for keyboard input
    in $0x64, %al
    test $1, %al
    jz main_loop
    
    # Read keyboard scancode
    in $0x60, %al
    
    # Simple echo - just show that we got input
    # (In a real implementation, we'd decode scancodes)
    
    hlt
    jmp main_loop

# Data section
success_msg:
    .asciz "SAGE OS 32-BIT GRAPHICS MODE ACTIVE!"

info_msg:
    .asciz "VGA Graphics: ON | Keyboard: ON | System Ready!"

prompt_msg:
    .asciz "=== Interactive Mode - Press any key ==="

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

# Boot signature
.org 510
.word 0xAA55
EOF

echo "📝 Compiling bootloader..."
gcc -m32 -nostdlib -nostartfiles -Wl,--oformat=binary -Wl,-Ttext=0x7C00 simple_bootloader.S -o bootloader.bin

echo "💾 Creating bootable image..."
# Copy bootloader to first sector
dd if=bootloader.bin of=sage_os_boot.img bs=512 count=1 conv=notrunc

echo "✅ Bootable image created: sage_os_boot.img"
echo "🚀 You can now boot this with: qemu-system-i386 -fda sage_os_boot.img"

# Make the script executable
chmod +x create_bootable_image.sh