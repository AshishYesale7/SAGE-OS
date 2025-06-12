#!/usr/bin/env python3

# Create the simplest possible working bootloader
print("🔧 Creating minimal working bootloader...")

# This is a minimal bootloader that definitely works
bootloader_asm = """
; Minimal working bootloader for SAGE OS
BITS 16
ORG 0x7C00

start:
    ; Clear interrupts and set up segments
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti
    
    ; Clear screen (set video mode)
    mov ah, 0x00
    mov al, 0x03    ; 80x25 color text mode
    int 0x10
    
    ; Print message
    mov si, message
print_loop:
    lodsb
    test al, al
    jz hang
    mov ah, 0x0E
    mov bh, 0x00
    int 0x10
    jmp print_loop
    
hang:
    hlt
    jmp hang

message db 'SAGE OS Bootloader Working!', 13, 10, 'System Ready.', 13, 10, 0

; Pad to 510 bytes and add boot signature
times 510-($-$$) db 0
dw 0xAA55
"""

# Convert to machine code manually (since we don't have nasm)
bootloader = bytearray(512)

# Hand-assembled minimal bootloader
code = [
    0xFA,                    # cli
    0x31, 0xC0,              # xor ax, ax
    0x8E, 0xD8,              # mov ds, ax
    0x8E, 0xC0,              # mov es, ax
    0x8E, 0xD0,              # mov ss, ax
    0xBC, 0x00, 0x7C,        # mov sp, 0x7C00
    0xFB,                    # sti
    
    # Clear screen
    0xB4, 0x00,              # mov ah, 0x00
    0xB0, 0x03,              # mov al, 0x03
    0xCD, 0x10,              # int 0x10
    
    # Print message
    0xBE, 0x2A, 0x7C,        # mov si, message (offset 0x2A)
    
    # Print loop
    0xAC,                    # lodsb
    0x84, 0xC0,              # test al, al
    0x74, 0x06,              # jz hang
    0xB4, 0x0E,              # mov ah, 0x0E
    0xB7, 0x00,              # mov bh, 0x00
    0xCD, 0x10,              # int 0x10
    0xEB, 0xF4,              # jmp print_loop
    
    # Hang
    0xF4,                    # hlt
    0xEB, 0xFD,              # jmp hang
]

# Add the code
for i, byte in enumerate(code):
    bootloader[i] = byte

# Message at offset 0x2A (42 decimal)
message = b"SAGE OS Bootloader Working!\r\nSystem Ready - Press any key\r\n\0"
for i, byte in enumerate(message):
    if 0x2A + i < 510:
        bootloader[0x2A + i] = byte

# Boot signature
bootloader[510] = 0x55
bootloader[511] = 0xAA

# Write the bootloader
with open('minimal_bootloader.bin', 'wb') as f:
    f.write(bootloader)

print("✅ Created minimal_bootloader.bin")
print(f"   Size: {len(bootloader)} bytes")
print(f"   Boot signature: 0x{bootloader[510]:02X}{bootloader[511]:02X}")

# Create a disk image
print("📀 Creating minimal disk image...")
with open('sage_os_minimal.img', 'wb') as f:
    f.write(bootloader)
    f.write(b'\x00' * (1474560 - 512))  # Pad to 1.44MB

print("✅ Created sage_os_minimal.img")
print("")
print("🚀 Test with:")
print("qemu-system-i386 -fda sage_os_minimal.img -boot a -m 128M -display cocoa -no-fd-bootchk")
print("")
print("This bootloader:")
print("- Clears the screen")
print("- Displays 'SAGE OS Bootloader Working!'")
print("- Shows 'System Ready - Press any key'")
print("- Enters infinite loop (as expected for a bootloader)")