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


# SAGE OS Documentation

<div align="center">
  <h1>🚀 SAGE OS</h1>
  <p><strong>A Modern, Secure, Multi-Architecture Operating System</strong></p>
  
  [![Build Status](https://github.com/AshishYesale7/SAGE-OS/workflows/CI/badge.svg)](https://github.com/AshishYesale7/SAGE-OS/actions)
  [![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](LICENSE)
  [![Documentation](https://img.shields.io/badge/docs-latest-brightgreen.svg)](//github.com/AshishYesale7.github.io/SAGE-OS/)
  [![Security](https://img.shields.io/badge/security-CVE%20scanned-green.svg)](security/cve-scanning.md)
</div>

---

## 🌟 Welcome to SAGE OS

SAGE OS is a cutting-edge operating system designed from the ground up with modern computing principles. Built for the future of computing, it combines security, performance, and multi-architecture support in a clean, modular design.

### 🎯 Key Features

=== "🔒 Security First"
    - **Memory Safety**: Built with Rust for memory-safe system programming
    - **CVE Scanning**: Automated vulnerability detection and management
    - **Secure Boot**: Hardware-backed boot chain verification
    - **Isolation**: Strong process and memory isolation

=== "🏗️ Multi-Architecture"
    - **x86_64**: Full support for Intel/AMD 64-bit processors
    - **ARM64**: Native support for ARM64/AArch64 platforms
    - **RISC-V**: Cutting-edge RISC-V 64-bit support
    - **Cross-Compilation**: Unified build system for all architectures

=== "⚡ Performance"
    - **Zero-Copy I/O**: Efficient data handling
    - **NUMA Awareness**: Optimized for modern multi-core systems
    - **Real-Time Capabilities**: Low-latency scheduling
    - **Hardware Acceleration**: GPU and specialized processor support

=== "🔧 Developer Friendly"
    - **Modern Toolchain**: Rust-based development with C interop
    - **Comprehensive Testing**: Automated testing across all platforms
    - **Documentation**: Extensive documentation with examples
    - **CI/CD**: Robust continuous integration and deployment

---

## 🚀 Quick Start

Get up and running with SAGE OS in minutes:

```bash
# Clone the repository
git clone https://github.com/AshishYesale7/SAGE-OS.git
cd SAGE-OS

# Build for your architecture
make build ARCH=x86_64

# Create bootable ISO
make iso ARCH=x86_64

# Run in emulator
make run ARCH=x86_64
```

[📖 Detailed Installation Guide →](getting-started/installation.md){ .md-button .md-button--primary }

---

## 🏛️ Architecture Overview

```mermaid
graph TB
    subgraph "User Space"
        A[Applications]
        B[System Services]
        C[Libraries]
    end
    
    subgraph "Kernel Space"
        D[System Call Interface]
        E[Process Manager]
        F[Memory Manager]
        G[File System]
        H[Device Drivers]
        I[Network Stack]
    end
    
    subgraph "Hardware"
        J[CPU]
        K[Memory]
        L[Storage]
        M[Network]
        N[Peripherals]
    end
    
    A --> D
    B --> D
    C --> D
    D --> E
    D --> F
    D --> G
    E --> H
    F --> H
    G --> H
    H --> J
    H --> K
    H --> L
    I --> M
    H --> N
```

[🏗️ Detailed Architecture →](architecture/overview.md){ .md-button }

---

## 📁 Project Structure

The SAGE OS project is organized into logical components:

```
SAGE-OS/
├── 🥾 bootloader/          # Multi-stage bootloader
│   ├── stage1/            # Initial boot stage
│   ├── stage2/            # Extended bootloader
│   └── uefi/              # UEFI boot support
├── 🧠 kernel/             # Kernel implementation
│   ├── arch/              # Architecture-specific code
│   ├── drivers/           # Device drivers
│   ├── fs/                # File systems
│   ├── mm/                # Memory management
│   └── proc/              # Process management
├── 👥 userspace/          # User space components
│   ├── init/              # Init system
│   ├── shell/             # Command shell
│   └── utils/             # System utilities
├── 🔧 tools/              # Development tools
├── 📚 docs/               # Documentation
├── 🧪 tests/              # Test suites
└── 📦 scripts/            # Build scripts
```

[📂 Complete File Reference →](files/project-structure.md){ .md-button }

---

## 🛠️ Development Workflow

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant Git as Git Repository
    participant CI as GitHub Actions
    participant Test as Test Suite
    participant Deploy as Deployment
    
    Dev->>Git: Push changes
    Git->>CI: Trigger workflow
    CI->>Test: Run tests
    Test->>CI: Test results
    CI->>Deploy: Build artifacts
    Deploy->>Dev: Feedback
```

### Development Process

1. **🔀 Fork & Clone**: Start with your own fork
2. **🌿 Branch**: Create feature branches
3. **💻 Develop**: Write code following our standards
4. **🧪 Test**: Run comprehensive test suites
5. **📝 Document**: Update documentation
6. **🔍 Review**: Submit pull requests
7. **🚀 Deploy**: Automated deployment

[👨‍💻 Contributing Guide →](development/contributing.md){ .md-button }

---

## 🔒 Security & Compliance

SAGE OS takes security seriously with multiple layers of protection:

### Security Features

| Feature | Description | Status |
|---------|-------------|--------|
| 🛡️ Memory Safety | Rust-based memory management | ✅ Active |
| 🔐 Secure Boot | Hardware-backed verification | ✅ Active |
| 🔍 CVE Scanning | Automated vulnerability detection | ✅ Active |
| 🚫 ASLR | Address Space Layout Randomization | ✅ Active |
| 🔒 DEP/NX | Data Execution Prevention | ✅ Active |
| 🛡️ Stack Protection | Stack canaries and guards | ✅ Active |

### Vulnerability Management

We use automated tools to continuously monitor for security vulnerabilities:

- **CVE Binary Tool**: Scans all binaries for known vulnerabilities
- **Dependency Scanning**: Monitors third-party dependencies
- **Static Analysis**: Code analysis for security issues
- **Penetration Testing**: Regular security assessments

[🔒 Security Documentation →](security/overview.md){ .md-button }

---

## 📊 Platform Support

| Architecture | Status | Bootloader | Kernel | Userspace | Testing |
|--------------|--------|------------|--------|-----------|---------|
| x86_64 | ✅ Stable | ✅ GRUB/UEFI | ✅ Full | ✅ Complete | ✅ CI/CD |
| ARM64 | ✅ Stable | ✅ U-Boot | ✅ Full | ✅ Complete | ✅ CI/CD |
| RISC-V | 🚧 Beta | ✅ OpenSBI | ✅ Core | 🚧 Partial | ✅ CI/CD |

[🏗️ Multi-Architecture Guide →](architecture/multi-arch.md){ .md-button }

---

## 📚 Documentation Sections

<div class="grid cards" markdown>

-   :material-rocket-launch: **Getting Started**
    
    ---
    
    Quick setup and installation guides
    
    [:octicons-arrow-right-24: Installation](getting-started/installation.md)
    [:octicons-arrow-right-24: Building](getting-started/building.md)
    [:octicons-arrow-right-24: First Boot](getting-started/first-boot.md)

-   :material-cog: **Architecture**
    
    ---
    
    Deep dive into system design
    
    [:octicons-arrow-right-24: Overview](architecture/overview.md)
    [:octicons-arrow-right-24: Kernel](architecture/kernel.md)
    [:octicons-arrow-right-24: Memory](architecture/memory.md)

-   :material-code-braces: **Development**
    
    ---
    
    Developer resources and guides
    
    [:octicons-arrow-right-24: Contributing](development/contributing.md)
    [:octicons-arrow-right-24: Testing](development/testing.md)
    [:octicons-arrow-right-24: Debugging](development/debugging.md)

-   :material-shield-check: **Security**
    
    ---
    
    Security features and best practices
    
    [:octicons-arrow-right-24: Overview](security/overview.md)
    [:octicons-arrow-right-24: CVE Scanning](security/cve-scanning.md)
    [:octicons-arrow-right-24: Best Practices](security/best-practices.md)

</div>

---

## 🤝 Community & Support

### Get Involved

- **💬 Discussions**: Join our [GitHub Discussions](https://github.com/AshishYesale7/SAGE-OS/discussions)
- **🐛 Issues**: Report bugs on [GitHub Issues](https://github.com/AshishYesale7/SAGE-OS/issues)
- **📧 Contact**: Reach out to [ashishyesale007@gmail.com](mailto:ashishyesale007@gmail.com)

### Contributing

We welcome contributions of all kinds:

- 🐛 Bug reports and fixes
- ✨ New features and enhancements
- 📚 Documentation improvements
- 🧪 Test coverage expansion
- 🎨 UI/UX improvements

[🤝 How to Contribute →](development/contributing.md){ .md-button .md-button--primary }

---

## 📄 License

SAGE OS is dual-licensed to provide flexibility for different use cases:

- **🆓 Open Source**: BSD 3-Clause License for open source projects
- **💼 Commercial**: Commercial license for proprietary applications

[📄 License Details →](home/license.md){ .md-button }

---

<div align="center">
  <p><strong>Built with ❤️ by the SAGE OS Team</strong></p>
  <p>Copyright © 2025 Ashish Vasant Yesale</p>
</div>