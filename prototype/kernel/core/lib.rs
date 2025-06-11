#![no_std]
// ─────────────────────────────────────────────────────────────────────────────
// SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
// SPDX-License-Identifier: BSD-3-Clause OR Proprietary
// SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
// 
// This file is part of the SAGE OS Project.
// ─────────────────────────────────────────────────────────────────────────────
#![feature(alloc_error_handler)]
#![feature(asm_const)]

extern crate alloc;
extern crate spin;
extern crate volatile;
extern crate lazy_static;

use core::panic::PanicInfo;
use core::alloc::{GlobalAlloc, Layout};
use linked_list_allocator::LockedHeap;

// Modules
pub mod memory;
pub mod process;
pub mod sync;
pub mod console;

// Hardware Abstraction Layer
pub mod hal;

// FFI exports for C code
pub mod ffi;

// Global allocator
#[global_allocator]
static ALLOCATOR: LockedHeap = LockedHeap::empty();

// Memory region for the heap
static mut HEAP_SPACE: [u8; 1024 * 1024] = [0; 1024 * 1024];

// Initialize the kernel
pub fn init() {
    // Initialize the heap
    unsafe {
        ALLOCATOR.lock().init(
            HEAP_SPACE.as_ptr() as usize,
            HEAP_SPACE.len(),
        );
    }
    
    // Initialize hardware
    hal::init();
    
    // Initialize console
    console::init();
    
    // Print welcome message
    console::println!("SAGE OS Kernel initialized");
    console::println!("Running on Rust {}", core::env!("CARGO_PKG_VERSION"));
}

// Panic handler
#[panic_handler]
fn panic(info: &PanicInfo) -> ! {
    console::println!("KERNEL PANIC: {}", info);
    loop {
        // Halt the CPU
        unsafe { core::arch::asm!("wfe") };
    }
}

// Out of memory handler
#[alloc_error_handler]
fn alloc_error_handler(layout: Layout) -> ! {
    console::println!("ALLOCATION ERROR: {:?}", layout);
    loop {
        // Halt the CPU
        unsafe { core::arch::asm!("wfe") };
    }
}