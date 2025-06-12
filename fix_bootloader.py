#!/usr/bin/env python3

# Create a simple working bootloader for SAGE OS
import struct

print("🔧 Creating simple working bootloader...")

bootloader = bytearray(512)

# Simple working bootloader that will definitely boot
code = [
    # Entry point
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
    0xBE, 0x30, 0x7C,        # mov si, msg
    0xAC,                    # lodsb
    0x3C, 0x00,              # cmp al, 0
    0x74, 0x08,              # jz done
    0xB4, 0x0E,              # mov ah, 0x0E
    0xB7, 0x00,              # mov bh, 0x00
    0xCD, 0x10,              # int 0x10
    0xEB, 0xF4,              # jmp print_loop
    
    # Infinite loop
    0xEB, 0xFE,              # jmp $
]

# Add the code
for i, byte in enumerate(code):
    if i < 48:
        bootloader[i] = byte

# Message at offset 0x30
msg = b"SAGE OS - Working!\r\nPress Ctrl+Alt+G then Cmd+Q to quit\r\n\0"
for i, byte in enumerate(msg):
    if 0x30 + i < 510:
        bootloader[0x30 + i] = byte

# Boot signature
bootloader[510] = 0x55
bootloader[511] = 0xAA

# Write the bootloader
with open('working_bootloader.bin', 'wb') as f:
    f.write(bootloader)

print("✅ Created working_bootloader.bin")
print(f"   Size: {len(bootloader)} bytes")
print(f"   Boot signature: 0x{bootloader[510]:02X}{bootloader[511]:02X}")

# Also create a new disk image
print("📀 Creating new disk image...")
with open('sage_os_working.img', 'wb') as f:
    # Write bootloader
    f.write(bootloader)
    # Pad to 1.44MB
    f.write(b'\x00' * (1474560 - 512))

print("✅ Created sage_os_working.img")
print("   Ready to test with QEMU!")