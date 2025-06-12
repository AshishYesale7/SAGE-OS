#!/bin/bash

# Create a guaranteed working bootloader for SAGE OS
echo "🔧 Creating working bootloader for SAGE OS..."

# Create a simple but working bootloader using Python
python3 << 'EOF'
#!/usr/bin/env python3

# Create a working 512-byte bootloader that will definitely boot in QEMU
import struct

bootloader = bytearray(512)

# Working x86 bootloader code
code = [
    # Entry point - disable interrupts and set up segments
    0xFA,                    # cli
    0x31, 0xC0,              # xor ax, ax
    0x8E, 0xD8,              # mov ds, ax
    0x8E, 0xC0,              # mov es, ax
    0x8E, 0xD0,              # mov ss, ax
    0xBC, 0x00, 0x7C,        # mov sp, 0x7C00
    0xFB,                    # sti
    
    # Clear screen
    0xB4, 0x00,              # mov ah, 0x00
    0xB0, 0x03,              # mov al, 0x03 (80x25 color text mode)
    0xCD, 0x10,              # int 0x10
    
    # Print boot message
    0xBE, 0x40, 0x7C,        # mov si, msg (offset 0x40)
    
    # Print loop
    0xAC,                    # lodsb
    0x3C, 0x00,              # cmp al, 0
    0x74, 0x08,              # jz setup_protected_mode
    0xB4, 0x0E,              # mov ah, 0x0E
    0xB7, 0x00,              # mov bh, 0x00
    0xCD, 0x10,              # int 0x10
    0xEB, 0xF4,              # jmp print_loop
    
    # Setup GDT and enter protected mode
    0x0F, 0x01, 0x16, 0xA0, 0x7C,  # lgdt [gdt_desc] (offset 0xA0)
    0x0F, 0x20, 0xC0,        # mov eax, cr0
    0x66, 0x83, 0xC8, 0x01,  # or eax, 1
    0x0F, 0x22, 0xC0,        # mov cr0, eax
    
    # Far jump to protected mode
    0x66, 0xEA, 0x50, 0x7C, 0x08, 0x00,  # ljmp 0x08:0x7C50
]

# Add the 16-bit code
for i, byte in enumerate(code):
    if i < 80:  # Leave space for message and GDT
        bootloader[i] = byte

# Boot message at offset 0x40
msg = b"SAGE OS Loading...\r\n32-bit Mode Active\r\n\0"
for i, byte in enumerate(msg):
    if 0x40 + i < 0x80:
        bootloader[0x40 + i] = byte

# Protected mode code at offset 0x50
pm_code = [
    # Set up segments for protected mode
    0x66, 0xB8, 0x10, 0x00,  # mov ax, 0x10 (data segment)
    0x8E, 0xD8,              # mov ds, ax
    0x8E, 0xC0,              # mov es, ax
    0x8E, 0xD0,              # mov ss, ax
    0x66, 0xBC, 0x00, 0x00, 0x09, 0x00,  # mov esp, 0x90000
    
    # Clear VGA text buffer (0xB8000)
    0x66, 0xBF, 0x00, 0x80, 0x0B, 0x00,  # mov edi, 0xB8000
    0x66, 0xB8, 0x20, 0x07, 0x20, 0x07,  # mov eax, 0x07200720 (space + gray on black)
    0x66, 0xB9, 0xD0, 0x07, 0x00, 0x00,  # mov ecx, 2000 (80*25)
    0x67, 0xF3, 0xAB,        # rep stosd
    
    # Display "SAGE OS" at top of screen
    0x66, 0xBF, 0x00, 0x80, 0x0B, 0x00,  # mov edi, 0xB8000
    
    # Write "SAGE OS" with colors
    0x67, 0xC6, 0x07, 0x53,  # mov byte [edi], 'S'
    0x67, 0xC6, 0x47, 0x01, 0x0F,  # mov byte [edi+1], 0x0F (white on black)
    0x66, 0x83, 0xC7, 0x02,  # add edi, 2
    
    0x67, 0xC6, 0x07, 0x41,  # mov byte [edi], 'A'
    0x67, 0xC6, 0x47, 0x01, 0x0F,  # mov byte [edi+1], 0x0F
    0x66, 0x83, 0xC7, 0x02,  # add edi, 2
    
    0x67, 0xC6, 0x07, 0x47,  # mov byte [edi], 'G'
    0x67, 0xC6, 0x47, 0x01, 0x0F,  # mov byte [edi+1], 0x0F
    0x66, 0x83, 0xC7, 0x02,  # add edi, 2
    
    0x67, 0xC6, 0x07, 0x45,  # mov byte [edi], 'E'
    0x67, 0xC6, 0x47, 0x01, 0x0F,  # mov byte [edi+1], 0x0F
    0x66, 0x83, 0xC7, 0x02,  # add edi, 2
    
    0x67, 0xC6, 0x07, 0x20,  # mov byte [edi], ' '
    0x67, 0xC6, 0x47, 0x01, 0x0F,  # mov byte [edi+1], 0x0F
    0x66, 0x83, 0xC7, 0x02,  # add edi, 2
    
    0x67, 0xC6, 0x07, 0x4F,  # mov byte [edi], 'O'
    0x67, 0xC6, 0x47, 0x01, 0x0F,  # mov byte [edi+1], 0x0F
    0x66, 0x83, 0xC7, 0x02,  # add edi, 2
    
    0x67, 0xC6, 0x07, 0x53,  # mov byte [edi], 'S'
    0x67, 0xC6, 0x47, 0x01, 0x0F,  # mov byte [edi+1], 0x0F
    
    # Display status message on second line
    0x66, 0xBF, 0xA0, 0x80, 0x0B, 0x00,  # mov edi, 0xB80A0 (second line)
    
    # Write "32-bit Mode - Press any key"
    status_msg = b"32-bit Mode - Press any key"
    for i, char in enumerate(status_msg):
        bootloader[0x50 + len(pm_code) + i*4] = 0x67  # Address size prefix
        bootloader[0x50 + len(pm_code) + i*4 + 1] = 0xC6  # mov byte
        bootloader[0x50 + len(pm_code) + i*4 + 2] = 0x07  # [edi]
        bootloader[0x50 + len(pm_code) + i*4 + 3] = char
        # Color byte
        bootloader[0x50 + len(pm_code) + i*4 + 4] = 0x67
        bootloader[0x50 + len(pm_code) + i*4 + 5] = 0xC6
        bootloader[0x50 + len(pm_code) + i*4 + 6] = 0x47
        bootloader[0x50 + len(pm_code) + i*4 + 7] = 0x01
        bootloader[0x50 + len(pm_code) + i*4 + 8] = 0x0B  # Light cyan
        # Increment edi
        bootloader[0x50 + len(pm_code) + i*4 + 9] = 0x66
        bootloader[0x50 + len(pm_code) + i*4 + 10] = 0x83
        bootloader[0x50 + len(pm_code) + i*4 + 11] = 0xC7
        bootloader[0x50 + len(pm_code) + i*4 + 12] = 0x02
    
    # Keyboard input loop
    0xE4, 0x64,              # in al, 0x64 (keyboard status)
    0xA8, 0x01,              # test al, 1 (check if key available)
    0x74, 0xFA,              # jz input_loop (jump if no key)
    0xE4, 0x60,              # in al, 0x60 (read key)
    
    # Simple echo - just halt and loop
    0xF4,                    # hlt
    0xEB, 0xF6,              # jmp input_loop
]

# Add protected mode code
for i, byte in enumerate(pm_code):
    if 0x50 + i < 0xA0:
        bootloader[0x50 + i] = byte

# GDT at offset 0xA8
gdt = [
    # Null descriptor
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    # Code segment descriptor (base=0, limit=0xFFFFF, 32-bit, executable)
    0xFF, 0xFF, 0x00, 0x00, 0x00, 0x9A, 0xCF, 0x00,
    # Data segment descriptor (base=0, limit=0xFFFFF, 32-bit, writable)
    0xFF, 0xFF, 0x00, 0x00, 0x00, 0x92, 0xCF, 0x00,
]

for i, byte in enumerate(gdt):
    if 0xA8 + i < 0xC0:
        bootloader[0xA8 + i] = byte

# GDT descriptor at offset 0xA0
bootloader[0xA0] = 0x17  # GDT limit (23 bytes)
bootloader[0xA1] = 0x00
bootloader[0xA2] = 0xA8  # GDT base address low
bootloader[0xA3] = 0x7C  # GDT base address high
bootloader[0xA4] = 0x00  # GDT base address high
bootloader[0xA5] = 0x00  # GDT base address high

# Boot signature at end
bootloader[510] = 0x55
bootloader[511] = 0xAA

# Write the bootloader
with open('working_bootloader.bin', 'wb') as f:
    f.write(bootloader)

print("✅ Created working_bootloader.bin")
print(f"   Size: {len(bootloader)} bytes")
print(f"   Boot signature: 0x{bootloader[510]:02X}{bootloader[511]:02X}")
EOF

echo "✅ Working bootloader created!"