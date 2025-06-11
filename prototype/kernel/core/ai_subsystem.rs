// ─────────────────────────────────────────────────────────────────────────────
// SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
// SPDX-License-Identifier: BSD-3-Clause OR Proprietary
// SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
// 
// This file is part of the SAGE OS Project.
// ─────────────────────────────────────────────────────────────────────────────
//! AI Subsystem for SAGE OS
//!
//! This module provides a high-level interface to the AI capabilities of the system,
//! including the AI HAT+ with up to 26 TOPS of neural processing power.

use alloc::string::{String, ToString};
use alloc::vec::Vec;
use alloc::boxed::Box;
use core::ffi::{c_void, c_char, c_float, c_uint, c_uchar};
use crate::console;

// FFI declarations for the AI HAT+ driver
extern "C" {
    fn ai_hat_init() -> i32;
    fn ai_hat_get_version(version: *mut c_char, max_len: usize) -> i32;
    fn ai_hat_get_capabilities(tops: *mut c_float, memory_mb: *mut c_uint) -> i32;
    fn ai_hat_load_model(model_data: *const c_void, model_size: usize, model: *mut AiHatModel) -> i32;
    fn ai_hat_unload_model(model: *mut AiHatModel) -> i32;
    fn ai_hat_run_inference(model: *const AiHatModel, 
                           input_data: *const c_void, input_size: usize,
                           result: *mut AiHatResult) -> i32;
    fn ai_hat_free_result(result: *mut AiHatResult) -> i32;
    fn ai_hat_get_power(power_mw: *mut c_uint) -> i32;
    fn ai_hat_set_power_mode(power_mode: c_uchar) -> i32;
    fn ai_hat_get_temperature(temperature_c: *mut c_float) -> i32;
}

// Model types
#[repr(C)]
#[derive(Debug, Clone, Copy)]
pub enum AiModelType {
    Unknown = 0,
    Classification = 1,
    Detection = 2,
    Segmentation = 3,
    Generation = 4,
    Custom = 5,
}

// Precision types
#[repr(C)]
#[derive(Debug, Clone, Copy)]
pub enum AiPrecision {
    Unknown = 0,
    FP32 = 1,
    FP16 = 2,
    INT8 = 3,
    INT4 = 4,
}

// AI HAT+ model handle
#[repr(C)]
pub struct AiHatModel {
    pub id: u32,
    pub model_type: AiModelType,
    pub precision: AiPrecision,
    pub input_size: usize,
    pub output_size: usize,
    pub private_data: *mut c_void,
}

// AI HAT+ inference result
#[repr(C)]
pub struct AiHatResult {
    pub data: *mut c_void,
    pub size: usize,
    pub inference_time_us: u64,
    pub confidence: f32,
}

// Safe Rust wrapper for AI HAT+ model
pub struct AiModel {
    inner: Box<AiHatModel>,
}

impl AiModel {
    // Create a new AI model from raw data
    pub fn new(model_data: &[u8]) -> Result<Self, &'static str> {
        let mut inner = Box::new(AiHatModel {
            id: 0,
            model_type: AiModelType::Unknown,
            precision: AiPrecision::Unknown,
            input_size: 0,
            output_size: 0,
            private_data: core::ptr::null_mut(),
        });
        
        let result = unsafe {
            ai_hat_load_model(
                model_data.as_ptr() as *const c_void,
                model_data.len(),
                inner.as_mut() as *mut AiHatModel
            )
        };
        
        if result != 0 {
            return Err("Failed to load AI model");
        }
        
        Ok(Self { inner })
    }
    
    // Run inference on the model
    pub fn run_inference(&self, input_data: &[u8]) -> Result<Vec<u8>, &'static str> {
        if input_data.len() != self.inner.input_size {
            return Err("Input data size mismatch");
        }
        
        let mut result = AiHatResult {
            data: core::ptr::null_mut(),
            size: 0,
            inference_time_us: 0,
            confidence: 0.0,
        };
        
        let ret = unsafe {
            ai_hat_run_inference(
                self.inner.as_ref() as *const AiHatModel,
                input_data.as_ptr() as *const c_void,
                input_data.len(),
                &mut result
            )
        };
        
        if ret != 0 {
            return Err("Inference failed");
        }
        
        // Copy the result data
        let mut output = Vec::with_capacity(result.size);
        unsafe {
            let slice = core::slice::from_raw_parts(result.data as *const u8, result.size);
            output.extend_from_slice(slice);
            
            // Free the result
            ai_hat_free_result(&mut result);
        }
        
        Ok(output)
    }
    
    // Get the model type
    pub fn model_type(&self) -> AiModelType {
        self.inner.model_type
    }
    
    // Get the model precision
    pub fn precision(&self) -> AiPrecision {
        self.inner.precision
    }
    
    // Get the input size
    pub fn input_size(&self) -> usize {
        self.inner.input_size
    }
    
    // Get the output size
    pub fn output_size(&self) -> usize {
        self.inner.output_size
    }
}

impl Drop for AiModel {
    fn drop(&mut self) {
        unsafe {
            ai_hat_unload_model(self.inner.as_mut() as *mut AiHatModel);
        }
    }
}

// AI subsystem state
pub struct AiSubsystem {
    initialized: bool,
    version: String,
    tops: f32,
    memory_mb: u32,
}

impl AiSubsystem {
    // Create a new AI subsystem
    pub fn new() -> Self {
        Self {
            initialized: false,
            version: String::new(),
            tops: 0.0,
            memory_mb: 0,
        }
    }
    
    // Initialize the AI subsystem
    pub fn init(&mut self) -> Result<(), &'static str> {
        if self.initialized {
            return Ok(());
        }
        
        let result = unsafe { ai_hat_init() };
        if result != 0 {
            return Err("Failed to initialize AI HAT+");
        }
        
        // Get version
        let mut version = [0u8; 64];
        let result = unsafe {
            ai_hat_get_version(version.as_mut_ptr() as *mut c_char, version.len())
        };
        
        if result == 0 {
            // Find null terminator
            let len = version.iter().position(|&c| c == 0).unwrap_or(version.len());
            self.version = String::from_utf8_lossy(&version[..len]).to_string();
        } else {
            self.version = "Unknown".to_string();
        }
        
        // Get capabilities
        let mut tops = 0.0f32;
        let mut memory_mb = 0u32;
        let result = unsafe {
            ai_hat_get_capabilities(&mut tops as *mut f32, &mut memory_mb as *mut u32)
        };
        
        if result == 0 {
            self.tops = tops;
            self.memory_mb = memory_mb;
        }
        
        self.initialized = true;
        Ok(())
    }
    
    // Get the AI HAT+ version
    pub fn version(&self) -> &str {
        &self.version
    }
    
    // Get the AI HAT+ TOPS
    pub fn tops(&self) -> f32 {
        self.tops
    }
    
    // Get the AI HAT+ memory in MB
    pub fn memory_mb(&self) -> u32 {
        self.memory_mb
    }
    
    // Set the power mode
    pub fn set_power_mode(&self, mode: u8) -> Result<(), &'static str> {
        if !self.initialized {
            return Err("AI subsystem not initialized");
        }
        
        let result = unsafe { ai_hat_set_power_mode(mode as c_uchar) };
        if result != 0 {
            return Err("Failed to set power mode");
        }
        
        Ok(())
    }
    
    // Get the current power consumption
    pub fn get_power(&self) -> Result<u32, &'static str> {
        if !self.initialized {
            return Err("AI subsystem not initialized");
        }
        
        let mut power_mw = 0u32;
        let result = unsafe { ai_hat_get_power(&mut power_mw as *mut c_uint) };
        if result != 0 {
            return Err("Failed to get power consumption");
        }
        
        Ok(power_mw)
    }
    
    // Get the current temperature
    pub fn get_temperature(&self) -> Result<f32, &'static str> {
        if !self.initialized {
            return Err("AI subsystem not initialized");
        }
        
        let mut temp = 0.0f32;
        let result = unsafe { ai_hat_get_temperature(&mut temp as *mut c_float) };
        if result != 0 {
            return Err("Failed to get temperature");
        }
        
        Ok(temp)
    }
}

// Global AI subsystem instance
static mut AI_SUBSYSTEM: Option<AiSubsystem> = None;

// Initialize the AI subsystem
pub fn init() -> Result<(), &'static str> {
    unsafe {
        AI_SUBSYSTEM = Some(AiSubsystem::new());
        if let Some(subsystem) = AI_SUBSYSTEM.as_mut() {
            let result = subsystem.init();
            if result.is_ok() {
                console::println!("AI Subsystem initialized:");
                console::println!("  Version: {}", subsystem.version());
                console::println!("  Performance: {:.1} TOPS", subsystem.tops());
                console::println!("  Memory: {} MB", subsystem.memory_mb());
            }
            result
        } else {
            Err("Failed to create AI subsystem")
        }
    }
}

// Get a reference to the AI subsystem
pub fn subsystem() -> Result<&'static AiSubsystem, &'static str> {
    unsafe {
        if let Some(ref subsystem) = AI_SUBSYSTEM {
            Ok(subsystem)
        } else {
            Err("AI subsystem not initialized")
        }
    }
}

// Load an AI model
pub fn load_model(model_data: &[u8]) -> Result<AiModel, &'static str> {
    // Ensure the subsystem is initialized
    let _ = subsystem()?;
    
    // Load the model
    AiModel::new(model_data)
}