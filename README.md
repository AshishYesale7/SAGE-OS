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
 


# SAGE OS 🌱🧠

[![Documentation](https://img.shields.io/badge/docs-auto--generated-blue?style=for-the-badge&logo=github)](https://asadzero.github.io/SAGE-OS/) [![AI-Enhanced](https://img.shields.io/badge/AI-enhanced-green?style=for-the-badge&logo=openai)](https://github.com/marketplace/models/)


<img src="https://github.com/user-attachments/assets/e9f364ed-df0e-4f65-8557-c6c783848907" width="400" height="400" />

**Self-Aware General Environment**  
An experimental, bare-metal operating system designed from scratch to learn, adapt, and evolve — starting on Raspberry Pi.

> For detailed usage instructions, see [USAGE_GUIDE.md](./USAGE_GUIDE.md)

![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)

## 🔭 Vision 

**SAGE OS** is not just another operating system. It is a living, evolving system designed to:

- Think autonomously
- Learn from usage patterns
- Optimize itself through artificial intelligence
- Rebuild and evolve its components as needed

This is an experiment at the intersection of **kernel engineering**, **embedded systems**, and **machine intelligence** — pushing the boundaries of what an operating system can become.

## 🚀 Features

- **Multi-Architecture Support**: Full support for i386, x86_64, aarch64, arm, and riscv64
- **Custom Bootloaders**: Architecture-specific boot code with multiboot support
- **Bare-Metal Kernel**: Written in C and assembly for maximum performance
- **AI Subsystem**: Integrated AI capabilities with the AI HAT+ accelerator
- **Memory Management**: Efficient memory allocation and management
- **Shell Interface**: Interactive command-line interface with VGA/UART output
- **Hardware Abstraction**: Support for Raspberry Pi 3, 4, 5, and x86 systems
- **Device Drivers**: UART, VGA, Serial, GPIO, I2C, SPI, and AI HAT+ drivers
- **QEMU Emulation**: Full testing support with safe tmux-based testing
- **Docker Integration**: Containerized builds and deployment
- **Security Scanning**: Comprehensive CVE vulnerability scanning
- **Build System**: Automated multi-architecture builds with macOS support

## 🧠 AI & Machine Learning Integration

SAGE OS includes embedded, resource-efficient AI components that can:
- Perform local inference using the AI HAT+ with up to 26 TOPS
- Support multiple model formats and precisions (FP32, FP16, INT8, INT4)
- Observe usage and optimize scheduling
- Trigger self-diagnostics and reconfiguration
- Dynamically adjust power consumption based on workload
- Monitor system health and performance
- Eventually, enable modular regeneration of subsystems

The AI HAT+ provides hardware acceleration for neural networks with:
- Up to 26 TOPS of neural processing power
- 4GB of dedicated memory for AI models
- Support for various model types (classification, detection, segmentation, generation)
- Power-efficient operation with multiple power modes
- Temperature monitoring and thermal management
- High-speed data transfer using SPI and control via I2C

## 🧰 Tech Stack

- **Languages**: ARM Assembly, C (kernel), Rust (core components), Python (tools & ML prototyping)
- **Platform**: Raspberry Pi 4B/5 (64-bit ARMv8/ARMv9)
- **Toolchain**: `aarch64-linux-gnu-gcc`, `rustc`, `QEMU`, `CMake`, TinyML (TFLM, uTensor)
- **Build Environment**: Cross-compilation (Linux, macOS)
- **AI Acceleration**: AI HAT+ with up to 26 TOPS neural processing

## 📦 Project Structure

<details>
  <summary>📦 Folder Structure</summary>
  
- `boot/` - Architecture-specific boot code
- `kernel/` - Core kernel functionality
- `drivers/` - Hardware drivers
- `scripts/` - Utility scripts for building and testing

</details>

```
SAGE-OS/
├── boot/                  # Boot code
│   └── boot.S             # ARM64 boot assembly
├── kernel/                # Kernel components
│   ├── kernel.c           # Kernel main entry point
│   ├── memory.c           # Memory management
│   ├── shell.c            # Interactive shell
│   ├── stdio.c            # Standard I/O functions
│   └── ai/                # AI subsystem
│       └── ai_subsystem.c # AI subsystem implementation
├── drivers/               # Hardware drivers
│   ├── uart.c             # UART driver
│   ├── i2c.c              # I2C driver
│   ├── spi.c              # SPI driver
│   └── ai_hat/            # AI HAT+ driver
│       ├── ai_hat.c       # AI HAT+ implementation
│       └── ai_hat.h       # AI HAT+ interface
├── config.txt             # Raspberry Pi 3/4 configuration
├── config_rpi5.txt        # Raspberry Pi 5 configuration
├── linker.ld              # Linker script
├── Makefile               # Build system
└── run_qemu.sh            # QEMU runner script
```

## 🚀 Getting Started

### 🔧 Quick Setup (Automated)

```bash
# Clone repository
git clone https://github.com/SAGE-OS/SAGE-OS.git
cd SAGE-OS
git checkout dev

# Install all dependencies automatically
chmod +x scripts/install-dependencies.sh
./scripts/install-dependencies.sh

# Build all architectures
./build.sh build-all

# Test with QEMU (safe method)
./build.sh  # Choose option 8 for QEMU testing

# Run comprehensive tests
chmod +x scripts/test-all-features.sh
./scripts/test-all-features.sh
```

### 📚 Documentation

- **[Developer Guide](docs/DEVELOPER_GUIDE.md)** - Comprehensive setup and usage guide
- **[Quick Reference](docs/QUICK_REFERENCE.md)** - Essential commands and troubleshooting
- **[Architecture Guide](docs/ARCHITECTURE.md)** - System architecture details

### 🏗️ Supported Architectures

| Architecture | Status | QEMU Support | Real Hardware |
|-------------|--------|--------------|---------------|
| **i386** | ✅ Working | ✅ Full | ✅ PC/VM |
| **x86_64** | ✅ Working | ✅ Full | ✅ PC/VM |
| **aarch64** | ✅ Working | ✅ Full | ✅ RPi 4/5 |
| **arm** | ✅ Working | ✅ Full | ✅ RPi 3/4 |
| **riscv64** | ✅ Working | ✅ Full | ⚠️ Limited |

### 🎯 Quick Commands

```bash
# Build specific architecture
./build.sh build i386
./build.sh build x86_64

# Create ISO images
./build.sh  # Choose option 7

# Docker builds
make docker-build-all

# Security scanning
./scan-vulnerabilities.sh --format html --arch i386

# Safe QEMU testing (recommended)
tmux new-session -d -s qemu-test
tmux send-keys -t qemu-test "./build.sh" Enter
# Choose option 8, then your architecture
# To exit: tmux kill-session -t qemu-test
```

### 🔍 What's New in This Version

- ✅ **Fixed QEMU Emulation**: All architectures now boot successfully
- ✅ **Enhanced Build System**: Automated dependency installation
- ✅ **Docker Integration**: Containerized builds and deployment
- ✅ **Security Scanning**: CVE vulnerability scanning with multiple output formats
- ✅ **Safe Testing**: tmux-based QEMU testing to prevent terminal lockups
- ✅ **Comprehensive Documentation**: Developer guides and quick references
- ✅ **Multi-Platform Support**: Linux, macOS, and Windows (WSL2) compatibility

### Shell Commands

Once booted, SAGE OS provides a shell with the following commands:

- `help` - Display available commands
- `echo [text]` - Echo text to the console
- `clear` - Clear the screen
- `meminfo` - Display memory information
- `reboot` - Reboot the system
- `version` - Display OS version information
- `ai info` - Display AI subsystem information (if enabled)
- `ai temp` - Show AI HAT+ temperature (if available)
- `ai power` - Show AI HAT+ power consumption (if available)
- `ai models` - List loaded AI models (if any)

## 🧑‍💻 Contributing

SAGE OS is open to contributions from developers, researchers, and hardware hackers.

- 📜 [License (BSD 3-Clause)](./LICENSE)
- ⚖️ [Commercial Use Terms](./COMMERCIAL_TERMS.md)
- 🧠 [AI Safety & Ethics Manifesto](./AI_Safety_And_Ethics.md)
- 🛠️ [How to Contribute](./CONTRIBUTING.md)

By contributing, you agree to the above terms.

## 🔍 Current Development Status

### ✅ Completed Features
- [x] **Multi-Architecture Support**: i386, x86_64, aarch64, arm, riscv64
- [x] **Custom Bootloaders**: Architecture-specific boot code with multiboot support
- [x] **Kernel Core**: Memory management, process handling, and shell interface
- [x] **Device Drivers**: UART, VGA, Serial, GPIO drivers
- [x] **QEMU Emulation**: Full testing support for all architectures
- [x] **Build System**: Automated builds with dependency management
- [x] **Docker Integration**: Containerized builds and deployment
- [x] **Security Scanning**: CVE vulnerability scanning with multiple formats
- [x] **Documentation**: Comprehensive developer guides and references
- [x] **AI HAT+ Support**: Neural processing acceleration for Raspberry Pi
- [x] **Cross-Platform**: Linux, macOS, Windows (WSL2) support

### 🚧 In Progress
- [ ] **Enhanced File System**: Minimal file system implementation
- [ ] **Network Stack**: Basic networking capabilities
- [ ] **Process Scheduling**: Advanced multi-tasking support
- [ ] **Power Management**: Dynamic power optimization

### 🔮 Future Plans
- [ ] **Self-Tuning Scheduler**: AI-driven task optimization
- [ ] **Evolutionary Updates**: Self-modifying system capabilities
- [ ] **Full AI Pipeline**: Complete model loading and inference
- [ ] **Distributed Computing**: Multi-node cluster support

## 📝 License

SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.

You may use this project under the terms of the BSD 3-Clause License as stated in the LICENSE file.  
Alternatively, commercial use with extended rights is available — contact the author for commercial licensing.

See the [LICENSE](./LICENSE) file for details.
