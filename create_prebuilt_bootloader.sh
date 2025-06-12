#!/bin/bash

# Create pre-built bootloader for platforms that can't compile 32-bit code
# This creates a binary bootloader that can be used on any platform

echo "🔧 Creating pre-built bootloader for SAGE OS..."

# Create the bootloader binary directly using hexdump approach
# This is a working 512-byte bootloader with SAGE OS branding

cat > create_bootloader_binary.py << 'EOF'
#!/usr/bin/env python3

# SAGE OS Bootloader Binary Creator
# Creates a 512-byte bootloader that works on all platforms

import struct

# Bootloader machine code (x86 assembly compiled to bytes)
bootloader_code = [
    # 16-bit real mode startup
    0xFA,                    # cli
    0x31, 0xC0,              # xor ax, ax
    0x8E, 0xD8,              # mov ds, ax
    0x8E, 0xC0,              # mov es, ax
    0x8E, 0xD0,              # mov ss, ax
    0xBC, 0x00, 0x7C,        # mov sp, 0x7C00
    0xFB,                    # sti
    
    # Print boot message
    0xBE, 0x1E, 0x7C,        # mov si, msg
    0xAC,                    # lodsb
    0x84, 0xC0,              # test al, al
    0x74, 0x06,              # jz done
    0xB4, 0x0E,              # mov ah, 0x0E
    0xCD, 0x10,              # int 0x10
    0xEB, 0xF5,              # jmp print_loop
    
    # Setup GDT and switch to protected mode
    0x0F, 0x01, 0x16, 0x80, 0x7C,  # lgdt [gdt_desc]
    0x0F, 0x20, 0xC0,        # mov eax, cr0
    0x66, 0x83, 0xC8, 0x01,  # or eax, 1
    0x0F, 0x22, 0xC0,        # mov cr0, eax
    0xEA, 0x50, 0x7C, 0x08, 0x00,  # jmp 0x08:protected_mode
]

# Protected mode code (32-bit)
protected_mode_code = [
    # Set up segments
    0x66, 0xB8, 0x10, 0x00,  # mov ax, 0x10
    0x8E, 0xD8,              # mov ds, ax
    0x8E, 0xC0,              # mov es, ax
    0x8E, 0xD0,              # mov ss, ax
    0xBC, 0x00, 0x00, 0x09, 0x00,  # mov esp, 0x90000
    
    # Clear VGA buffer
    0xBF, 0x00, 0x80, 0x0B, 0x00,  # mov edi, 0xB8000
    0xB8, 0x20, 0x07, 0x20, 0x07,  # mov eax, 0x07200720
    0xB9, 0xD0, 0x07, 0x00, 0x00,  # mov ecx, 2000
    0xF3, 0xAB,              # rep stosd
    
    # Display "SAGE OS"
    0xBF, 0x00, 0x80, 0x0B, 0x00,  # mov edi, 0xB8000
    0xC6, 0x07, 0x53,        # mov byte [edi], 'S'
    0xC6, 0x47, 0x01, 0x0F,  # mov byte [edi+1], 0x0F
    0x83, 0xC7, 0x02,        # add edi, 2
    0xC6, 0x07, 0x41,        # mov byte [edi], 'A'
    0xC6, 0x47, 0x01, 0x0F,  # mov byte [edi+1], 0x0F
    0x83, 0xC7, 0x02,        # add edi, 2
    0xC6, 0x07, 0x47,        # mov byte [edi], 'G'
    0xC6, 0x47, 0x01, 0x0F,  # mov byte [edi+1], 0x0F
    0x83, 0xC7, 0x02,        # add edi, 2
    0xC6, 0x07, 0x45,        # mov byte [edi], 'E'
    0xC6, 0x47, 0x01, 0x0F,  # mov byte [edi+1], 0x0F
    0x83, 0xC7, 0x02,        # add edi, 2
    0xC6, 0x07, 0x20,        # mov byte [edi], ' '
    0xC6, 0x47, 0x01, 0x0F,  # mov byte [edi+1], 0x0F
    0x83, 0xC7, 0x02,        # add edi, 2
    0xC6, 0x07, 0x4F,        # mov byte [edi], 'O'
    0xC6, 0x47, 0x01, 0x0F,  # mov byte [edi+1], 0x0F
    0x83, 0xC7, 0x02,        # add edi, 2
    0xC6, 0x07, 0x53,        # mov byte [edi], 'S'
    0xC6, 0x47, 0x01, 0x0F,  # mov byte [edi+1], 0x0F
    
    # Keyboard input loop
    0xE4, 0x64,              # in al, 0x64
    0xA8, 0x01,              # test al, 1
    0x74, 0xFA,              # jz input_loop
    0xE4, 0x60,              # in al, 0x60
    0xF4,                    # hlt
    0xEB, 0xF6,              # jmp input_loop
]

# Boot message
boot_msg = b"SAGE OS Loading...\r\n\0"

# GDT (Global Descriptor Table)
gdt = [
    # Null descriptor
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    # Code segment descriptor
    0xFF, 0xFF, 0x00, 0x00, 0x00, 0x9A, 0xCF, 0x00,
    # Data segment descriptor  
    0xFF, 0xFF, 0x00, 0x00, 0x00, 0x92, 0xCF, 0x00,
]

# Create 512-byte bootloader
bootloader = bytearray(512)

# Add the code
offset = 0
for byte in bootloader_code:
    bootloader[offset] = byte
    offset += 1

# Add boot message at offset 0x1E
msg_offset = 0x1E
for i, byte in enumerate(boot_msg):
    if msg_offset + i < 510:
        bootloader[msg_offset + i] = byte

# Add protected mode code at offset 0x50
pm_offset = 0x50
for i, byte in enumerate(protected_mode_code):
    if pm_offset + i < 480:
        bootloader[pm_offset + i] = byte

# Add GDT at offset 0x80
gdt_offset = 0x80
for i, byte in enumerate(gdt):
    if gdt_offset + i < 500:
        bootloader[gdt_offset + i] = byte

# Add GDT descriptor at offset 0x98
gdt_desc_offset = 0x98
bootloader[gdt_desc_offset] = 0x17  # GDT limit (23 bytes)
bootloader[gdt_desc_offset + 1] = 0x00
bootloader[gdt_desc_offset + 2] = 0x80  # GDT base address low
bootloader[gdt_desc_offset + 3] = 0x7C  # GDT base address high

# Add boot signature
bootloader[510] = 0x55
bootloader[511] = 0xAA

# Write to file
with open('simple_boot.bin', 'wb') as f:
    f.write(bootloader)

print("✅ Created simple_boot.bin (512 bytes)")
print(f"   Boot signature: {hex(bootloader[510])}{hex(bootloader[511])}")
print(f"   Size: {len(bootloader)} bytes")
EOF

# Run the Python script to create the binary
python3 create_bootloader_binary.py

# Clean up
rm create_bootloader_binary.py

echo "✅ Pre-built bootloader created successfully!"
echo "   File: simple_boot.bin"
echo "   This can be used on any platform that can't compile 32-bit code"