
# SAGE OS 🌱🧠

<img src="https://github.com/user-attachments/assets/e9f364ed-df0e-4f65-8557-c6c783848907" width="400" height="400" />

**Self-Aware General Environment**  
An experimental, bare-metal operating system designed from scratch to learn, adapt, and evolve — starting on Raspberry Pi.

![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)
---
 
  ## 🔭 Vision 

**SAGE OS** is not just another operating system. It is a living, evolving system designed to:

- Think autonomously
- Learn from usage patterns
- Optimize itself through artificial intelligence
- Rebuild and evolve its components as needed

This is an experiment at the intersection of **kernel engineering**, **embedded systems**, and **machine intelligence** — pushing the boundaries of what an operating system can become.

<img src="https://github.com/user-attachments/assets/a5aeda94-147c-483f-8378-cca4ba023a13" width="600" height="500">


 
<details>
  <summary>🎯 Objectives</summary>

- Build a fully bootable, bare-metal operating system from scratch
- Integrate basic AI/ML models to inform system-level decisions
- Enable self-monitoring and self-optimization over time
- Keep the codebase portable across architectures (starting with ARM/RPi)
  
<img src="https://github.com/user-attachments/assets/a726baa8-dca4-4097-ab31-54b8cd819287" width="600" height="700">

  This image illustrates the **"Self-Evolving, AI-Driven OS Lifecycle"** — a conceptual flow for how your SAGE OS can autonomously detect hardware, build itself, and evolve across platforms.

---

### 🔍 Step-by-Step Breakdown:

1. **AI Detects Architecture and Hardware**

   * On boot or install, SAGE OS's embedded AI analyzes the CPU type, memory, buses, I/O interfaces, and connected devices.

2. **Generate Platform-Specific Kernel and Drivers**

   * Based on the detected architecture (ARM, x86, RISC-V, etc.), the AI compiles or adapts the kernel and drivers tailored to the platform.

3. **Build Disk Image or Container**

   * The AI assembles a bootable `.img`, `.iso`, or container that includes the new kernel, drivers, and shell environment.

4. **Boot Automatically**

   * The new OS version is booted directly, either on the device or inside a VM/emulator (like QEMU) for testing.

5. **Monitor Performance and Stability**

   * AI continuously checks system behavior: uptime, crashes, latency, driver responses, etc.

6. **Stable → Keep New Image**

   * If everything runs well, the system promotes this version as the active build.

7. **Unstable → Roll Back**

   * If issues are found, the AI automatically rolls back to the previous known-good state.

 
---

This workflow allows **SAGE OS to evolve, rebuild, and test itself across any platform** — moving toward true autonomy and architectural universality.
 


</details>

<details>
  <summary>⚙️ Functional Goals</summary>

- [x] Custom bootloader for Raspberry Pi
- [x] Basic kernel with memory & process management
- [ ] Custom command-line shell (SAGE Shell)
- [ ] Integrated AI agent (TinyML / rule-based to start)
- [ ] Self-tuning task scheduler and memory allocator
- [ ] Support for minimal file system
- [ ] Ability to evolve through version-aware updates

</details>

<details>
  <summary>🧠 AI & Machine Learning Integration</summary>

SAGE OS will include embedded, resource-efficient AI components that can:
- Perform local inference (TinyML)
- Observe usage and optimize scheduling
- Trigger self-diagnostics and reconfiguration
- Eventually, enable modular regeneration of subsystems

</details>

<details>
  <summary>🧰 Tech Stack</summary>

- **Languages**: ARM Assembly, C (kernel), Python (tools & ML prototyping)
- **Platform**: Raspberry Pi 4B (64-bit ARMv8)
- **Toolchain**: `arm-none-eabi-gcc`, `QEMU`, `Make`, TinyML (TFLM, uTensor)
- **Build Environment**: macOS M1 (cross-compilation)

</details>

<details>
  <summary>🔐 License</summary>

This project is licensed under the [CC BY-NC 4.0 License](https://creativecommons.org/licenses/by-nc/4.0/).  
You're free to use, modify, and share the code for non-commercial purposes with attribution.  
All rights reserved to the original author.

</details>

<details>
  <summary>📦 Folder Structure</summary>
  
- `boot/` - Architecture-specific boot code
- `kernel/` - Core kernel functionality
- `drivers/` - Hardware drivers
- `scripts/` - Utility scripts for building and testing

</details>

<details>
  <summary>🚀 Building and Running SAGE OS</summary>

## Prerequisites

To build and run SAGE OS, you need the following tools:

- GCC cross-compilers for your target architectures:
  - `x86_64-linux-gnu-gcc` for x86_64
  - `aarch64-linux-gnu-gcc` for ARM64/AArch64
  - `riscv64-linux-gnu-gcc` for RISC-V 64-bit

- QEMU for emulation:
  - `qemu-system-x86_64` for x86_64
  - `qemu-system-aarch64` for ARM64/AArch64
  - `qemu-system-riscv64` for RISC-V 64-bit

### Installing Prerequisites

On Debian/Ubuntu:

```bash
# Install cross-compilers
sudo apt-get install gcc-x86-64-linux-gnu gcc-aarch64-linux-gnu gcc-riscv64-linux-gnu

# Install QEMU
sudo apt-get install qemu-system-x86 qemu-system-arm qemu-system-misc
```

## Building SAGE OS

To build SAGE OS for a specific architecture:

```bash
# Clean previous build artifacts
make clean

# Build for x86_64
make ARCH=x86_64

# Build for ARM64/AArch64
make ARCH=aarch64

# Build for RISC-V 64-bit
make ARCH=riscv64
```

The build process creates:
- Object files for each source file
- `kernel.elf` - The linked ELF executable
- `kernel8.img` - The raw binary image

## Running SAGE OS

### Using QEMU

You can run SAGE OS in QEMU using the provided script:

```bash
# Run on x86_64
./scripts/test_emulated.sh x86_64

# Run on ARM64/AArch64
./scripts/test_emulated.sh aarch64

# Run on RISC-V 64-bit
./scripts/test_emulated.sh riscv64
```

### Running on Real Hardware

For Raspberry Pi (ARM64):
1. Copy `kernel8.img` to the boot partition of your SD card
2. Make sure `config.txt` contains `arm_64bit=1`
3. Boot your Raspberry Pi

## Development

### Adding New Features

1. Add your source files to the appropriate directory
2. Update the Makefile if necessary
3. Build and test using the commands above

### License Compliance

All source files must include the BSD 3-Clause License header. You can check for compliance using:

```bash
./license-checker.py
```

If you need to add license headers to new files:

```bash
./add_license_headers.py
```

## Troubleshooting

### Build Errors

- **Missing compiler**: Make sure you have installed the appropriate cross-compiler for your target architecture
- **Linker errors**: Check that all required object files are being included in the link step

### Runtime Errors

- **Kernel doesn't boot**: Verify that the boot code for your architecture is correctly implemented
- **QEMU crashes**: Make sure you're using the correct QEMU parameters for your architecture

</details>



```md
## 🧑‍💻 Contributing

SAGE OS is open to contributions from developers, researchers, and hardware hackers.

- 📜 [License (BSD 3-Clause)](./LICENSE)
- ⚖️ [Commercial Use Terms](./COMMERCIAL_TERMS.md)
- 🧠 [AI Safety & Ethics Manifesto](./AI_Safety_And_Ethics.md)
- 🛠️ [How to Contribute](./CONTRIBUTING.md)

By contributing, you agree to the above terms.
## License

SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.

You may use this project under the terms of the BSD 3-Clause License as stated in the LICENSE file.  
Alternatively, commercial use with extended rights is available — contact the author for commercial licensing.

See the [LICENSE](./LICENSE) file for details.


