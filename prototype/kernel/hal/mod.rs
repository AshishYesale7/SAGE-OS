// ─────────────────────────────────────────────────────────────────────────────
// SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
// SPDX-License-Identifier: BSD-3-Clause OR Proprietary
// SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
// 
// This file is part of the SAGE OS Project.
//
// ─────────────────────────────────────────────────────────────────────────────
// Licensing:
// -----------
//                                 
//                                                                             
//   Licensed under the BSD 3-Clause License or a Commercial License.          
//   You may use this file under the terms of either license as specified in: 
//                                                                             
//      - BSD 3-Clause License (see ./LICENSE)                           
//      - Commercial License (see ./COMMERCIAL_TERMS.md or contact legal@your.org)  
//                                                                             
//   Redistribution and use in source and binary forms, with or without       
//   modification, are permitted under the BSD license provided that the      
//   following conditions are met:                                            
//                                                                             
//     * Redistributions of source code must retain the above copyright       
//       notice, this list of conditions and the following disclaimer.       
//     * Redistributions in binary form must reproduce the above copyright    
//       notice, this list of conditions and the following disclaimer in the  
//       documentation and/or other materials provided with the distribution. 
//     * Neither the name of the project nor the names of its contributors    
//       may be used to endorse or promote products derived from this         
//       software without specific prior written permission.                  
//                                                                             
//   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS  
//   IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED    
//   TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A          
//   PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER 
//   OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
//   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,      
//   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR       
//   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF   
//   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     
//   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS       
//   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  
//
// By using this software, you agree to be bound by the terms of either license.
//
// Alternatively, commercial use with extended rights is available — contact the author for commercial licensing.
//
// ─────────────────────────────────────────────────────────────────────────────
// Contributor Guidelines:
// ------------------------
// Contributions are welcome under the terms of the Developer Certificate of Origin (DCO).
// All contributors must certify that they have the right to submit the code and agree to
// release it under the above license terms.
//
// Contributions must:
//   - Be original or appropriately attributed
//   - Include clear documentation and test cases where applicable
//   - Respect the coding and security guidelines defined in CONTRIBUTING.md
//
// ─────────────────────────────────────────────────────────────────────────────
// Terms of Use and Disclaimer:
// -----------------------------
// This software is provided "as is", without any express or implied warranty.
// In no event shall the authors, contributors, or copyright holders
// be held liable for any damages arising from the use of this software.
//
// Use of this software in critical systems (e.g., medical, nuclear, safety)
// is entirely at your own risk unless specifically licensed for such purposes.
//
// ─────────────────────────────────────────────────────────────────────────────//! Hardware Abstraction Layer
//!
//! This module provides a platform-independent interface to hardware.

use core::sync::atomic::{AtomicBool, Ordering};

// Modules
pub mod uart;
pub mod gpio;
pub mod timer;
pub mod interrupt;
pub mod mmu;

// Platform detection
#[cfg(feature = "platform_rpi4")]
pub mod platforms {
    pub mod rpi4;
    pub use self::rpi4 as platform;
}

#[cfg(feature = "platform_riscv")]
pub mod platforms {
    pub mod riscv;
    pub use self::riscv as platform;
}

#[cfg(feature = "platform_x86_64")]
pub mod platforms {
    pub mod x86_64;
    pub use self::x86_64 as platform;
}

// Re-export platform-specific implementations
pub use self::platforms::platform::*;

// Initialization status
static INITIALIZED: AtomicBool = AtomicBool::new(false);

/// Initialize the hardware
pub fn init() {
    if INITIALIZED.load(Ordering::SeqCst) {
        return;
    }
    
    // Initialize platform-specific hardware
    unsafe {
        // Memory Management Unit
        mmu::init();
        
        // Interrupt controller
        interrupt::init();
        
        // Timer
        timer::init();
        
        // UART
        uart::init();
        
        // GPIO
        gpio::init();
    }
    
    INITIALIZED.store(true, Ordering::SeqCst);
}

/// Halt the CPU
pub fn halt() -> ! {
    loop {
        unsafe {
            #[cfg(any(target_arch = "aarch64", target_arch = "arm"))]
            core::arch::asm!("wfe");
            
            #[cfg(target_arch = "riscv64")]
            core::arch::asm!("wfi");
            
            #[cfg(target_arch = "x86_64")]
            core::arch::asm!("hlt");
        }
    }
}