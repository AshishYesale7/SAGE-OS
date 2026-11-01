<!--
─────────────────────────────────────────────────────────────────────────────
SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
SPDX-License-Identifier: BSD-3-Clause OR Proprietary
SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.

This file is part of the SAGE OS Project.
─────────────────────────────────────────────────────────────────────────────
-->
# 🧰 SAGE OS SDK Overview

Welcome to the **SAGE OS Software Development Kit (SDK)** — a comprehensive toolkit that empowers developers, researchers, and hardware vendors to build secure, cross-architecture, AI-integrated applications and modules for the SAGE OS ecosystem.

## 🚀 Purpose of the SDK

The SAGE SDK serves as the **interface layer between developers and the core of SAGE OS**, enabling:

- Native application development
- AI model integration (e.g., for AZR modules)
- Custom kernel extensions and drivers
- Cross-platform compilation and binary translation
- Hardware accelerator (e.g., AI Hat) integration

## 🧩 SDK Structure

```
sage-sdk/
├── include/            # Header files for APIs (AZR, memory, syscalls)
├── lib/                # Precompiled libraries (.a/.so)
├── tools/              # CLI tools for packaging, testing, and model building
├── examples/           # Sample programs and AZR modules
├── docs/               # Developer documentation
├── toolchains/         # Cross-compiler toolchains (optional)
└── CMakeLists.txt      # Build system
```

## 📚 Key Components

### ✅ Libraries

| Library | Purpose |
|--------|---------|
| `libazr` | Core AZR syscall, ABI, binary translation interfaces |
| `libaihat` | AI accelerator (e.g., Raspberry Pi AI Hat) driver interface |
| `libsys` | Basic OS services (I/O, memory, shell, FS, etc.) |

### 🛠️ Tools

| Tool | Description |
|------|-------------|
| `azr-model-builder` | Package and validate AZR modules (AI reasoners) |
| `sage-package` | Create signed SAGE modules/apps |
| `qemu-test` | Run apps inside QEMU SAGE OS instance |
| `nas-train` (future) | Interface to neural architecture search tooling for SAGE |

## 🌐 Architecture Support

The SDK supports all platforms supported by SAGE OS:

- `x86_64`
- `ARM` and `ARM64` (Raspberry Pi 4 & 5)
- `RISC-V` (via optional toolchain)
- All AZR-compatible ABIs

## 🔐 Security & Signing

- All SDK output (binaries, AZR models, kernel modules) must be **signed** using the `sage-package` tool to be accepted by SAGE OS.

## 💡 Typical Workflow

```sh
# 1. Install SDK + toolchains
$ ./install-sdk.sh

# 2. Create or modify your app/module
$ edit examples/hello_world.c

# 3. Build against SAGE SDK
$ make TARGET=aarch64

# 4. Test in QEMU
$ ./tools/qemu-test build/kernel.img examples/hello_world.elf

# 5. Package for deployment
$ ./tools/sage-package examples/hello_world.elf --out out.pkg --sign dev.key
```

## 🔬 Integration with AI Systems

| Integration | Format | Description |
|-------------|--------|-------------|
| AZR Modules | ONNX/FlatBuffers | Reasoners used for syscall analysis, binary prediction |
| NAS Models | PyTorch/ONNX | Neural architecture search output |
| AI Accelerators | TVM/C API | Interface to hardware like Pi AI Hat+ |

## 📦 Example Use Cases

- Create a new system call monitor using an AZR module
- Train and deploy a NAS-evolved instruction predictor
- Build an AI-powered binary translator plug-in
- Develop custom drivers for sensors or AI modules

## 📎 See Also

- [AZR Model Integration Guide](AZR-Module-Integration.md)
- [SAGE OS Architecture](SAGE-OS-Architecture.md)
- [NAS for SAGE OS](Neural-Architecture-Search.md)
- [AI HAT API Reference](AI-HAT-Reference.md)
