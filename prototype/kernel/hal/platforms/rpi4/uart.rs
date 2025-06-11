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
// ─────────────────────────────────────────────────────────────────────────────//! Raspberry Pi 4 UART driver
//!
//! This module implements UART functionality for the Raspberry Pi 4.

use core::fmt;
use spin::Mutex;
use lazy_static::lazy_static;

// MMIO base address for BCM2711 (Raspberry Pi 4)
const MMIO_BASE: usize = 0xFE000000;

// UART registers
const UART0_BASE: usize = MMIO_BASE + 0x201000;
const UART0_DR: *mut u32 = (UART0_BASE + 0x00) as *mut u32;
const UART0_FR: *mut u32 = (UART0_BASE + 0x18) as *mut u32;
const UART0_IBRD: *mut u32 = (UART0_BASE + 0x24) as *mut u32;
const UART0_FBRD: *mut u32 = (UART0_BASE + 0x28) as *mut u32;
const UART0_LCRH: *mut u32 = (UART0_BASE + 0x2C) as *mut u32;
const UART0_CR: *mut u32 = (UART0_BASE + 0x30) as *mut u32;
const UART0_IMSC: *mut u32 = (UART0_BASE + 0x38) as *mut u32;
const UART0_ICR: *mut u32 = (UART0_BASE + 0x44) as *mut u32;

// Flag register bits
const FR_RXFE: u32 = 0x10; // Receive FIFO empty
const FR_TXFF: u32 = 0x20; // Transmit FIFO full

// Line control register bits
const LCRH_WLEN_8BIT: u32 = 0x60; // 8 bits
const LCRH_FEN: u32 = 0x10;       // Enable FIFOs

// Control register bits
const CR_UARTEN: u32 = 0x01; // UART enable
const CR_TXE: u32 = 0x100;   // Transmit enable
const CR_RXE: u32 = 0x200;   // Receive enable

/// UART driver for Raspberry Pi 4
pub struct Uart;

impl Uart {
    /// Initialize the UART
    pub fn init(&self) {
        unsafe {
            // Disable UART
            core::ptr::write_volatile(UART0_CR, 0);
            
            // Clear interrupts
            core::ptr::write_volatile(UART0_ICR, 0x7FF);
            
            // Set baud rate (115200)
            // UART clock is 48MHz
            // 48000000 / (16 * 115200) = 26.0416...
            // Integer part = 26
            // Fractional part = 0.0416... * 64 = 2.66... ~ 3
            core::ptr::write_volatile(UART0_IBRD, 26);
            core::ptr::write_volatile(UART0_FBRD, 3);
            
            // 8 bits, FIFO enabled
            core::ptr::write_volatile(UART0_LCRH, LCRH_WLEN_8BIT | LCRH_FEN);
            
            // Enable UART, transmit and receive
            core::ptr::write_volatile(UART0_CR, CR_UARTEN | CR_TXE | CR_RXE);
        }
    }
    
    /// Send a byte
    pub fn send(&self, byte: u8) {
        unsafe {
            // Wait until transmit FIFO is not full
            while (core::ptr::read_volatile(UART0_FR) & FR_TXFF) != 0 {}
            
            // Write the byte
            core::ptr::write_volatile(UART0_DR, byte as u32);
        }
    }
    
    /// Receive a byte
    pub fn receive(&self) -> Option<u8> {
        unsafe {
            // Check if receive FIFO is empty
            if (core::ptr::read_volatile(UART0_FR) & FR_RXFE) != 0 {
                None
            } else {
                // Read the byte
                Some((core::ptr::read_volatile(UART0_DR) & 0xFF) as u8)
            }
        }
    }
    
    /// Write a string
    pub fn write_string(&self, s: &str) {
        for byte in s.bytes() {
            self.send(byte);
        }
    }
}

// Implement Write trait for UART
impl fmt::Write for Uart {
    fn write_str(&mut self, s: &str) -> fmt::Result {
        self.write_string(s);
        Ok(())
    }
}

// Global UART instance
lazy_static! {
    pub static ref UART: Mutex<Uart> = Mutex::new(Uart);
}

// Public interface

/// Initialize the UART
pub fn init() {
    UART.lock().init();
}

/// Send a byte
pub fn send(byte: u8) {
    UART.lock().send(byte);
}

/// Receive a byte
pub fn receive() -> Option<u8> {
    UART.lock().receive()
}

/// Write a string
pub fn write_string(s: &str) {
    UART.lock().write_string(s);
}

/// Print formatted text
#[macro_export]
macro_rules! print {
    ($($arg:tt)*) => ({
        use core::fmt::Write;
        let _ = write!($crate::hal::uart::UART.lock(), $($arg)*);
    });
}

/// Print formatted text with newline
#[macro_export]
macro_rules! println {
    () => ($crate::print!("\r\n"));
    ($($arg:tt)*) => ({
        $crate::print!($($arg)*);
        $crate::print!("\r\n");
    });
}