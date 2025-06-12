# Minimal multiboot kernel for testing
.code32

# Multiboot header
.section .multiboot
.align 4
.long 0x1BADB002    # Magic number
.long 0x00000003    # Flags (ALIGN + MEMINFO)
.long -(0x1BADB002 + 0x00000003)  # Checksum

# Entry point
.section .text
.global _start
_start:
    # Set up stack
    movl $stack_top, %esp
    
    # Clear screen and write message
    movl $0xB8000, %edi    # VGA text buffer
    movl $0x07200720, %eax # Space with gray background
    movl $2000, %ecx       # 80*25 characters
    rep stosl              # Clear screen
    
    # Write "SAGE OS WORKS!" message
    movl $0xB8000, %edi
    movb $'S', (%edi)
    movb $0x0F, 1(%edi)    # Bright white
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
    movb $'W', 16(%edi)
    movb $0x0F, 17(%edi)
    movb $'O', 18(%edi)
    movb $0x0F, 19(%edi)
    movb $'R', 20(%edi)
    movb $0x0F, 21(%edi)
    movb $'K', 22(%edi)
    movb $0x0F, 23(%edi)
    movb $'S', 24(%edi)
    movb $0x0F, 25(%edi)
    movb $'!', 26(%edi)
    movb $0x0F, 27(%edi)
    
    # Write second line
    movl $0xB80A0, %edi    # Second line (160 bytes offset)
    movb $'3', (%edi)
    movb $0x0A, 1(%edi)    # Green
    movb $'2', 2(%edi)
    movb $0x0A, 3(%edi)
    movb $'-', 4(%edi)
    movb $0x0A, 5(%edi)
    movb $'b', 6(%edi)
    movb $0x0A, 7(%edi)
    movb $'i', 8(%edi)
    movb $0x0A, 9(%edi)
    movb $'t', 10(%edi)
    movb $0x0A, 11(%edi)
    movb $' ', 12(%edi)
    movb $0x0A, 13(%edi)
    movb $'G', 14(%edi)
    movb $0x0A, 15(%edi)
    movb $'r', 16(%edi)
    movb $0x0A, 17(%edi)
    movb $'a', 18(%edi)
    movb $0x0A, 19(%edi)
    movb $'p', 20(%edi)
    movb $0x0A, 21(%edi)
    movb $'h', 22(%edi)
    movb $0x0A, 23(%edi)
    movb $'i', 24(%edi)
    movb $0x0A, 25(%edi)
    movb $'c', 26(%edi)
    movb $0x0A, 27(%edi)
    movb $'s', 28(%edi)
    movb $0x0A, 29(%edi)
    
    # Infinite loop
halt_loop:
    hlt
    jmp halt_loop

# Stack
.section .bss
.align 16
stack_bottom:
.skip 16384  # 16KB stack
stack_top: