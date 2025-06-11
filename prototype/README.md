<!-- ─────────────────────────────────────────────────────────────────────────────
   SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
   SPDX-License-Identifier: BSD-3-Clause OR Proprietary
   SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
  
   This file is part of the SAGE OS Project.
  
   ─────────────────────────────────────────────────────────────────────────────
   Licensing:
   -----------
  
  
     Licensed under the BSD 3-Clause License or a Commercial License.          
     You may use this file under the terms of either license as specified in: 
  
        - BSD 3-Clause License (see ./LICENSE)                           
        - Commercial License (see ./COMMERCIAL_TERMS.md or contact legal@your.org)  
  
     Redistribution and use in source and binary forms, with or without       
     modification, are permitted under the BSD license provided that the      
     following conditions are met:                                            
  
       * Redistributions of source code must retain the above copyright       
         notice, this list of conditions and the following disclaimer.       
       * Redistributions in binary form must reproduce the above copyright    
         notice, this list of conditions and the following disclaimer in the  
         documentation and/or other materials provided with the distribution. 
       * Neither the name of the project nor the names of its contributors    
         may be used to endorse or promote products derived from this         
         software without specific prior written permission.                  
  
     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS  
     IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED    
     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A          
     PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER 
     OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
     EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,      
     PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR       
     PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF   
     LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     
     NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS       
     SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  
  
   By using this software, you agree to be bound by the terms of either license.
  
   Alternatively, commercial use with extended rights is available — contact the author for commercial licensing.
  
   ─────────────────────────────────────────────────────────────────────────────
   Contributor Guidelines:
   ------------------------
   Contributions are welcome under the terms of the Developer Certificate of Origin (DCO).
   All contributors must certify that they have the right to submit the code and agree to
   release it under the above license terms.
  
   Contributions must:
     - Be original or appropriately attributed
     - Include clear documentation and test cases where applicable
     - Respect the coding and security guidelines defined in CONTRIBUTING.md
  
   ─────────────────────────────────────────────────────────────────────────────
   Terms of Use and Disclaimer:
   -----------------------------
   This software is provided "as is", without any express or implied warranty.
   In no event shall the authors, contributors, or copyright holders
   be held liable for any damages arising from the use of this software.
  
   Use of this software in critical systems (e.g., medical, nuclear, safety)
   is entirely at your own risk unless specifically licensed for such purposes.
  
   ─────────────────────────────────────────────────────────────────────────────
-->

# SAGE OS Prototype

This prototype demonstrates a future-proof implementation of SAGE OS core components using the recommended technology stack from the CONTRIBUTING.md guidelines, with special support for Raspberry Pi 5 and AI HAT+ accelerator.

## Overview

This prototype implements:

1. A Rust-based kernel core with C FFI for hardware interaction
2. A simple AI inference engine using TensorFlow Lite Micro with AI HAT+ support (up to 26 TOPS)
3. A hardware abstraction layer (HAL) for cross-platform support, including Raspberry Pi 5
4. Secure communication using modern cryptography
5. Interactive shell with command processing
6. Memory management with allocation/deallocation capabilities

## Raspberry Pi 5 Support

SAGE OS includes specific support for Raspberry Pi 5 hardware:
- Updated peripheral addresses for RPi5
- Optimized performance for the new CPU
- Support for PCIe and other RPi5-specific features
- Configuration file optimized for RPi5 (`config_rpi5.txt`)

## AI HAT+ Integration

The AI HAT+ accelerator with up to 26 TOPS of neural processing power is fully supported:
- Dedicated driver for communication with the AI HAT+
- High-level Rust API for AI model loading and inference
- Power management for the AI accelerator
- Temperature monitoring
- Support for various model types and precisions

## Directory Structure

```
prototype/
├── boot/               # Boot code and startup assembly
├── kernel/             # Kernel components in Rust
│   ├── core/           # Core kernel functionality
│   │   ├── main.rs     # Kernel entry point
│   │   ├── shell.rs    # Interactive shell
│   │   └── ai_subsystem.rs # AI subsystem interface
│   ├── hal/            # Hardware Abstraction Layer
│   │   └── rpi5.h      # Raspberry Pi 5 hardware definitions
│   └── drivers/        # Platform-specific drivers
│       └── ai_hat.c    # AI HAT+ driver
├── ai/                 # AI components
│   ├── models/         # TFLite models
│   └── inference/      # Inference engine
├── security/           # Cryptography and security
│   ├── crypto.h        # Cryptography interface
│   └── crypto.c        # Cryptography implementation
├── config.txt          # Raspberry Pi 4 configuration
├── config_rpi5.txt     # Raspberry Pi 5 configuration
├── linker.ld           # Linker script
├── Makefile            # Build system
├── run_qemu.sh         # Script for running in QEMU
└── BUILD.md            # Build instructions
```

## Technology Stack

- **Languages**: Rust + C
- **Build System**: Cargo + CMake
- **AI Framework**: TensorFlow Lite Micro + AI HAT+ API
- **Cryptography**: libsodium/RustCrypto
- **Cross-compilation**: LLVM/Clang
- **Target Platforms**: Raspberry Pi 4/5, RISC-V, x86_64

## Getting Started

See the [BUILD.md](BUILD.md) file for instructions on building and running the prototype.

### Quick Start for Raspberry Pi 5

1. Build the kernel:
   ```bash
   make TARGET_PLATFORM=rpi5 ENABLE_AI=ON
   ```

2. Copy files to SD card:
   ```bash
   cp build/kernel8.img /path/to/sdcard/
   cp config_rpi5.txt /path/to/sdcard/config.txt
   ```

3. Insert SD card into Raspberry Pi 5 and power on

### Testing with QEMU

For testing without hardware:
```bash
./run_qemu.sh
```