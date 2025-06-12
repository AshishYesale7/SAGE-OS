#!/bin/bash

# Create simple but working bootable disk image
set -e

echo "🔧 Creating simple SAGE OS bootable disk image..."

# Create bootloader that fits in 512 bytes
cat > simple_boot.S << 'EOF'
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
    mov $msg, %si
    call print

    # Simple protected mode setup
    cli
    lgdt gdt_desc
    mov %cr0, %eax
    or $1, %eax
    mov %eax, %cr0
    ljmp $0x08, $pm

print:
    lodsb
    test %al, %al
    jz done
    mov $0x0E, %ah
    int $0x10
    jmp print
done:
    ret

.code32
pm:
    # Set segments
    mov $0x10, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %ss
    mov $0x90000, %esp
    
    # Clear VGA and show message
    mov $0xB8000, %edi
    mov $0x07200720, %eax
    mov $2000, %ecx
    rep stosl
    
    # Write success message
    mov $0xB8000, %edi
    movb $'S', (%edi)
    movb $0x0F, 1(%edi)
    movb $'A', 2(%edi)
    movb $0x0F, 3(%edi)
    movb $'G', 4(%edi)
    movb $0x0F, 5(%edi)
    movb $'E', 6(%edi)
    movb $0x0F, 7(%edi)
    movb $' ', 8(%edi)
    movb $0x0F, 9(%edi)
    movb $'O', 10(%edi)
    movb $0x0F, 11(%edi)
    movb $'S', 12(%edi)
    movb $0x0F, 13(%edi)
    movb $' ', 14(%edi)
    movb $0x0F, 15(%edi)
    movb $'3', 16(%edi)
    movb $0x0A, 17(%edi)
    movb $'2', 18(%edi)
    movb $0x0A, 19(%edi)
    movb $'-', 20(%edi)
    movb $0x0A, 21(%edi)
    movb $'B', 22(%edi)
    movb $0x0A, 23(%edi)
    movb $'I', 24(%edi)
    movb $0x0A, 25(%edi)
    movb $'T', 26(%edi)
    movb $0x0A, 27(%edi)
    
    # Second line - system info
    mov $0xB80A0, %edi
    movb $'G', (%edi)
    movb $0x0E, 1(%edi)
    movb $'r', 2(%edi)
    movb $0x0E, 3(%edi)
    movb $'a', 4(%edi)
    movb $0x0E, 5(%edi)
    movb $'p', 6(%edi)
    movb $0x0E, 7(%edi)
    movb $'h', 8(%edi)
    movb $0x0E, 9(%edi)
    movb $'i', 10(%edi)
    movb $0x0E, 11(%edi)
    movb $'c', 12(%edi)
    movb $0x0E, 13(%edi)
    movb $'s', 14(%edi)
    movb $0x0E, 15(%edi)
    movb $':', 16(%edi)
    movb $0x0E, 17(%edi)
    movb $' ', 18(%edi)
    movb $0x0E, 19(%edi)
    movb $'O', 20(%edi)
    movb $0x0E, 21(%edi)
    movb $'N', 22(%edi)
    movb $0x0E, 23(%edi)
    
    # Keyboard input loop
loop:
    in $0x64, %al
    test $1, %al
    jz loop
    in $0x60, %al
    hlt
    jmp loop

msg:
    .asciz "SAGE OS Bootloader Loading...\r\n"

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

echo "📝 Compiling simple bootloader..."
gcc -m32 -nostdlib -nostartfiles -Wl,--oformat=binary -Wl,-Ttext=0x7C00 simple_boot.S -o simple_boot.bin

echo "💾 Creating bootable image..."
dd if=/dev/zero of=sage_os_simple.img bs=1024 count=1440
dd if=simple_boot.bin of=sage_os_simple.img bs=512 count=1 conv=notrunc

echo "✅ Simple bootable image created: sage_os_simple.img"
echo "📏 Bootloader size: $(stat -c%s simple_boot.bin) bytes"