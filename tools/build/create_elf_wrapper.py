#!/usr/bin/env python3
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
#
# ─────────────────────────────────────────────────────────────────────────────
# Licensing:
# -----------
#                                 
#                                                                             
#   Licensed under the BSD 3-Clause License or a Commercial License.          
#   You may use this file under the terms of either license as specified in: 
#                                                                             
#      - BSD 3-Clause License (see ./LICENSE)                           
#      - Commercial License (see ./COMMERCIAL_TERMS.md or contact legal@your.org)  
#                                                                             
#   Redistribution and use in source and binary forms, with or without       
#   modification, are permitted under the BSD license provided that the      
#   following conditions are met:                                            
#                                                                             
#     * Redistributions of source code must retain the above copyright       
#       notice, this list of conditions and the following disclaimer.       
#     * Redistributions in binary form must reproduce the above copyright    
#       notice, this list of conditions and the following disclaimer in the  
#       documentation and/or other materials provided with the distribution. 
#     * Neither the name of the project nor the names of its contributors    
#       may be used to endorse or promote products derived from this         
#       software without specific prior written permission.                  
#                                                                             
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS  
#   IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED    
#   TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A          
#   PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER 
#   OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
#   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,      
#   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR       
#   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF   
#   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     
#   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS       
#   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  
#
# By using this software, you agree to be bound by the terms of either license.
#
# Alternatively, commercial use with extended rights is available — contact the author for commercial licensing.
#
# ─────────────────────────────────────────────────────────────────────────────
# Contributor Guidelines:
# ------------------------
# Contributions are welcome under the terms of the Developer Certificate of Origin (DCO).
# All contributors must certify that they have the right to submit the code and agree to
# release it under the above license terms.
#
# Contributions must:
#   - Be original or appropriately attributed
#   - Include clear documentation and test cases where applicable
#   - Respect the coding and security guidelines defined in CONTRIBUTING.md
#
# ─────────────────────────────────────────────────────────────────────────────
# Terms of Use and Disclaimer:
# -----------------------------
# This software is provided "as is", without any express or implied warranty.
# In no event shall the authors, contributors, or copyright holders
# be held liable for any damages arising from the use of this software.
#
# Use of this software in critical systems (e.g., medical, nuclear, safety)
# is entirely at your own risk unless specifically licensed for such purposes.
#
# ─────────────────────────────────────────────────────────────────────────────


import struct
import sys

def create_elf_wrapper(binary_file, output_file):
    # Read the binary file
    with open(binary_file, 'rb') as f:
        binary_data = f.read()
    
    # ELF header for x86_64
    elf_header = bytearray(64)
    
    # ELF magic number
    elf_header[0:4] = b'\x7fELF'
    
    # 64-bit
    elf_header[4] = 2
    
    # Little endian
    elf_header[5] = 1
    
    # ELF version
    elf_header[6] = 1
    
    # System V ABI
    elf_header[7] = 0
    
    # ABI version
    elf_header[8] = 0
    
    # Padding
    elf_header[9:16] = b'\x00' * 7
    
    # Executable file
    elf_header[16:18] = struct.pack('<H', 2)
    
    # x86_64 machine type
    elf_header[18:20] = struct.pack('<H', 0x3e)
    
    # ELF version
    elf_header[20:24] = struct.pack('<I', 1)
    
    # Entry point (0x100000 + multiboot header size)
    elf_header[24:32] = struct.pack('<Q', 0x100000 + 12)
    
    # Program header offset
    elf_header[32:40] = struct.pack('<Q', 64)
    
    # Section header offset (we'll put it after the program)
    section_header_offset = 64 + 56  # ELF header + program header
    elf_header[40:48] = struct.pack('<Q', section_header_offset)
    
    # Flags
    elf_header[48:52] = struct.pack('<I', 0)
    
    # ELF header size
    elf_header[52:54] = struct.pack('<H', 64)
    
    # Program header entry size
    elf_header[54:56] = struct.pack('<H', 56)
    
    # Number of program header entries
    elf_header[56:58] = struct.pack('<H', 1)
    
    # Section header entry size
    elf_header[58:60] = struct.pack('<H', 64)
    
    # Number of section header entries
    elf_header[60:62] = struct.pack('<H', 0)
    
    # Section header string table index
    elf_header[62:64] = struct.pack('<H', 0)
    
    # Program header
    program_header = bytearray(56)
    
    # Loadable segment
    program_header[0:4] = struct.pack('<I', 1)
    
    # Flags (read + execute)
    program_header[4:8] = struct.pack('<I', 5)
    
    # Offset in file (right after headers)
    file_offset = 64 + 56
    program_header[8:16] = struct.pack('<Q', file_offset)
    
    # Virtual address
    program_header[16:24] = struct.pack('<Q', 0x100000)
    
    # Physical address
    program_header[24:32] = struct.pack('<Q', 0x100000)
    
    # Size in file
    program_header[32:40] = struct.pack('<Q', len(binary_data))
    
    # Size in memory
    program_header[40:48] = struct.pack('<Q', len(binary_data))
    
    # Alignment
    program_header[48:56] = struct.pack('<Q', 0x1000)
    
    # Write the ELF file
    with open(output_file, 'wb') as f:
        f.write(elf_header)
        f.write(program_header)
        f.write(binary_data)
    
    print(f"Created ELF wrapper: {output_file}")
    print(f"Binary size: {len(binary_data)} bytes")
    print(f"ELF file size: {len(elf_header) + len(program_header) + len(binary_data)} bytes")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 create_elf_wrapper.py <binary_file> <output_elf>")
        sys.exit(1)
    
    create_elf_wrapper(sys.argv[1], sys.argv[2])