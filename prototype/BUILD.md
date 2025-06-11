<!--
─────────────────────────────────────────────────────────────────────────────
SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
SPDX-License-Identifier: BSD-3-Clause OR Proprietary
SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.

This file is part of the SAGE OS Project.
─────────────────────────────────────────────────────────────────────────────
-->
# Building SAGE OS Prototype

This document provides instructions for building the SAGE OS prototype.

## Prerequisites

### Required Tools

- Rust toolchain (rustc, cargo)
- CMake (3.16 or newer)
- Cross-compilation toolchain for your target platform
- Git

### Optional Tools

- QEMU (for testing without hardware)
- GDB (for debugging)

## Installing Dependencies

### Ubuntu/Debian

```bash
# Install basic tools
sudo apt update
sudo apt install build-essential cmake git

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

# Install cross-compilation toolchain for ARM64 (Raspberry Pi 4)
sudo apt install gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu

# Install QEMU (optional)
sudo apt install qemu-system-arm

# Install GDB (optional)
sudo apt install gdb-multiarch
```

### macOS

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install basic tools
brew install cmake git

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

# Install cross-compilation toolchain for ARM64 (Raspberry Pi 4)
brew install arm-none-eabi-gcc

# Install QEMU (optional)
brew install qemu

# Install GDB (optional)
brew install gdb
```

## Building the Prototype

### 1. Clone the Repository

```bash
git clone https://github.com/AshishYesale7/SAGE-OS.git
cd SAGE-OS/prototype
```

### 2. Configure Rust

```bash
# Add the target for Raspberry Pi 4
rustup target add aarch64-unknown-none

# Add the nightly toolchain (required for some features)
rustup toolchain install nightly
rustup default nightly
```

### 3. Configure the Build

```bash
# Create a build directory
mkdir -p build
cd build

# Configure CMake
cmake .. -DTARGET_PLATFORM=rpi4 -DENABLE_CRYPTO=ON -DENABLE_AI=OFF
```

### 4. Build the Prototype

```bash
# Build the prototype
cmake --build .
```

The build will produce a `kernel8.img` file that can be copied to a Raspberry Pi SD card.

## Running on Hardware

### Raspberry Pi 4

1. Format an SD card with FAT32
2. Copy `kernel8.img` to the SD card
3. Create a `config.txt` file on the SD card with the following content:

```
arm_64bit=1
init_uart_clock=48000000
```

4. Insert the SD card into the Raspberry Pi 4
5. Connect a serial console (115200 baud, 8N1)
6. Power on the Raspberry Pi 4

## Running in QEMU

```bash
# Run in QEMU
qemu-system-aarch64 -M raspi3 -kernel kernel8.img -serial stdio -nographic
```

## Debugging

```bash
# Start QEMU with GDB server
qemu-system-aarch64 -M raspi3 -kernel kernel8.img -serial stdio -nographic -s -S

# In another terminal, start GDB
gdb-multiarch kernel.elf -ex "target remote localhost:1234"
```

## Building with Different Options

### Enable AI Support

```bash
cmake .. -DTARGET_PLATFORM=rpi4 -DENABLE_CRYPTO=ON -DENABLE_AI=ON
```

### Target Different Platforms

```bash
# For RISC-V
cmake .. -DTARGET_PLATFORM=riscv -DENABLE_CRYPTO=ON -DENABLE_AI=OFF

# For x86_64
cmake .. -DTARGET_PLATFORM=x86_64 -DENABLE_CRYPTO=ON -DENABLE_AI=OFF
```

## Troubleshooting

### Common Issues

#### Missing Rust Target

```
error: target aarch64-unknown-none is not installed
```

Solution: Run `rustup target add aarch64-unknown-none`

#### Missing Cross-Compiler

```
CMake Error: Could not find aarch64-linux-gnu-gcc
```

Solution: Install the appropriate cross-compiler for your target platform

#### TensorFlow Lite Micro Not Found

```
Could not find a package configuration file provided by "TensorFlowLiteMicro"
```

Solution: Enable AI support only if you have TensorFlow Lite Micro installed, or disable it with `-DENABLE_AI=OFF`