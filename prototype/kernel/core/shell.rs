// ─────────────────────────────────────────────────────────────────────────────
// SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
// SPDX-License-Identifier: BSD-3-Clause OR Proprietary
// SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
// 
// This file is part of the SAGE OS Project.
// ─────────────────────────────────────────────────────────────────────────────
//! Interactive shell for SAGE OS
//!
//! This module provides a simple command-line interface for interacting with the OS.

use alloc::string::{String, ToString};
use alloc::vec::Vec;
use core::fmt::Write;
use crate::console;
use crate::hal::uart;

/// Shell command function type
pub type CommandFn = fn(&[&str]) -> Result<(), &'static str>;

/// Shell command structure
pub struct Command {
    /// Command name
    pub name: &'static str,
    /// Command description
    pub description: &'static str,
    /// Command function
    pub function: CommandFn,
}

/// Shell state
pub struct Shell {
    /// Command buffer
    buffer: String,
    /// Command history
    history: Vec<String>,
    /// Available commands
    commands: Vec<Command>,
    /// Prompt string
    prompt: &'static str,
}

impl Shell {
    /// Create a new shell
    pub fn new() -> Self {
        let mut shell = Shell {
            buffer: String::with_capacity(256),
            history: Vec::new(),
            commands: Vec::new(),
            prompt: "sage> ",
        };
        
        // Add built-in commands
        shell.add_command(Command {
            name: "help",
            description: "Display available commands",
            function: Self::cmd_help,
        });
        
        shell.add_command(Command {
            name: "echo",
            description: "Echo text to the console",
            function: Self::cmd_echo,
        });
        
        shell.add_command(Command {
            name: "clear",
            description: "Clear the screen",
            function: Self::cmd_clear,
        });
        
        shell.add_command(Command {
            name: "meminfo",
            description: "Display memory information",
            function: Self::cmd_meminfo,
        });
        
        shell.add_command(Command {
            name: "reboot",
            description: "Reboot the system",
            function: Self::cmd_reboot,
        });
        
        shell.add_command(Command {
            name: "version",
            description: "Display OS version information",
            function: Self::cmd_version,
        });
        
        shell
    }
    
    /// Add a command to the shell
    pub fn add_command(&mut self, command: Command) {
        self.commands.push(command);
    }
    
    /// Start the shell
    pub fn run(&mut self) {
        console::println!("SAGE OS Shell");
        console::println!("Type 'help' for a list of commands");
        
        self.display_prompt();
        
        loop {
            if let Some(byte) = uart::receive() {
                match byte {
                    // Enter
                    b'\r' | b'\n' => {
                        console::println!("");
                        self.execute_command();
                        self.buffer.clear();
                        self.display_prompt();
                    },
                    
                    // Backspace
                    8 | 127 => {
                        if !self.buffer.is_empty() {
                            self.buffer.pop();
                            console::print!("\x08 \x08");
                        }
                    },
                    
                    // Printable character
                    32..=126 => {
                        if self.buffer.len() < 255 {
                            self.buffer.push(byte as char);
                            console::print!("{}", byte as char);
                        }
                    },
                    
                    // Ignore other characters
                    _ => {}
                }
            }
        }
    }
    
    /// Display the prompt
    fn display_prompt(&self) {
        console::print!("{}", self.prompt);
    }
    
    /// Execute a command
    fn execute_command(&mut self) {
        if self.buffer.is_empty() {
            return;
        }
        
        // Add to history
        self.history.push(self.buffer.clone());
        
        // Parse the command
        let parts: Vec<&str> = self.buffer.split_whitespace().collect();
        if parts.is_empty() {
            return;
        }
        
        let command_name = parts[0];
        let args = &parts[1..];
        
        // Find and execute the command
        let mut found = false;
        for cmd in &self.commands {
            if cmd.name == command_name {
                found = true;
                match (cmd.function)(args) {
                    Ok(_) => {},
                    Err(e) => console::println!("Error: {}", e),
                }
                break;
            }
        }
        
        if !found {
            console::println!("Unknown command: {}", command_name);
            console::println!("Type 'help' for a list of commands");
        }
    }
    
    /// Help command
    fn cmd_help(_args: &[&str]) -> Result<(), &'static str> {
        console::println!("Available commands:");
        
        // Get a reference to the shell
        let shell = unsafe { SHELL.as_ref().unwrap() };
        
        for cmd in &shell.commands {
            console::println!("  {:10} - {}", cmd.name, cmd.description);
        }
        
        Ok(())
    }
    
    /// Echo command
    fn cmd_echo(args: &[&str]) -> Result<(), &'static str> {
        if args.is_empty() {
            console::println!("");
        } else {
            console::println!("{}", args.join(" "));
        }
        
        Ok(())
    }
    
    /// Clear command
    fn cmd_clear(_args: &[&str]) -> Result<(), &'static str> {
        // ANSI escape sequence to clear the screen and move cursor to top-left
        console::print!("\x1b[2J\x1b[H");
        
        Ok(())
    }
    
    /// Memory information command
    fn cmd_meminfo(_args: &[&str]) -> Result<(), &'static str> {
        // TODO: Implement memory information
        console::println!("Memory information not implemented yet");
        
        Ok(())
    }
    
    /// Reboot command
    fn cmd_reboot(_args: &[&str]) -> Result<(), &'static str> {
        console::println!("Rebooting...");
        
        // TODO: Implement reboot
        
        Ok(())
    }
    
    /// Version command
    fn cmd_version(_args: &[&str]) -> Result<(), &'static str> {
        console::println!("SAGE OS v{}", env!("CARGO_PKG_VERSION"));
        console::println!("Built with Rust {}", env!("RUSTC_VERSION"));
        
        Ok(())
    }
}

// Global shell instance
static mut SHELL: Option<Shell> = None;

/// Initialize the shell
pub fn init() {
    unsafe {
        SHELL = Some(Shell::new());
    }
}

/// Run the shell
pub fn run() {
    unsafe {
        if let Some(shell) = SHELL.as_mut() {
            shell.run();
        }
    }
}

/// Add a command to the shell
pub fn add_command(command: Command) {
    unsafe {
        if let Some(shell) = SHELL.as_mut() {
            shell.add_command(command);
        }
    }
}