# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# Build Configuration
# Default architecture is aarch64, target is generic
ARCH ?= aarch64
TARGET ?= generic

# Version and Build Management
# Get version from VERSION file or use default
VERSION := $(shell cat VERSION 2>/dev/null || echo "1.0.0")

# Generate simple build identifier
BUILD_ID := sage-os-v$(VERSION)-$(ARCH)-$(TARGET)

# Clean output directory structure
OUTPUT_DIR := output
BUILD_DIR := build/$(ARCH)
ARCH_OUTPUT_DIR := $(OUTPUT_DIR)/$(ARCH)

# Set up cross-compilation toolchain based on architecture
ifeq ($(ARCH),x86_64)
    CROSS_COMPILE=x86_64-linux-gnu-
else ifeq ($(ARCH),i386)
    # Use proper cross-compiler for i386 on non-x86 hosts
    ifeq ($(shell uname -m),x86_64)
        CROSS_COMPILE=
    else
        CROSS_COMPILE=i686-linux-gnu-
    endif
    CFLAGS += -m32
    LDFLAGS += -m elf_i386
else ifeq ($(ARCH),arm64)
    CROSS_COMPILE=aarch64-linux-gnu-
else ifeq ($(ARCH),aarch64)
    CROSS_COMPILE=aarch64-linux-gnu-
else ifeq ($(ARCH),arm)
    CROSS_COMPILE=arm-linux-gnueabihf-
else ifeq ($(ARCH),riscv64)
    CROSS_COMPILE=riscv64-linux-gnu-
else
    $(error Unsupported architecture: $(ARCH))
endif

CC=$(CROSS_COMPILE)gcc
LD=$(CROSS_COMPILE)ld
OBJCOPY=$(CROSS_COMPILE)objcopy

# Handle macOS clang masquerading as gcc
ifeq ($(shell uname),Darwin)
    # On macOS, use clang directly with proper flags
    ifeq ($(ARCH),i386)
        CC=clang
        ASFLAGS=-target i386-pc-none-elf -integrated-as
        CFLAGS += -target i386-pc-none-elf
    endif
else
    ASFLAGS=
endif

# Include paths
INCLUDES=-I. -Ikernel -Idrivers

# Base CFLAGS
CFLAGS=-nostdlib -nostartfiles -ffreestanding -O2 -Wall -Wextra $(INCLUDES)

# Architecture-specific flags and defines
ifeq ($(ARCH),x86_64)
    CFLAGS += -m64 -D__x86_64__
else ifeq ($(ARCH),i386)
    CFLAGS += -m32 -D__i386__ -fno-pic -fno-pie
else ifeq ($(ARCH),arm64)
    CFLAGS += -D__aarch64__
else ifeq ($(ARCH),aarch64)
    CFLAGS += -D__aarch64__
else ifeq ($(ARCH),riscv64)
    CFLAGS += -D__riscv -D__riscv_xlen=64
endif

# Architecture-specific linker script
ifeq ($(ARCH),x86_64)
    LDFLAGS=-T linker_x86_64.ld
else ifeq ($(ARCH),i386)
    LDFLAGS=-T linker_x86.ld -m elf_i386
else
    LDFLAGS=-T linker.ld
endif

# Create build directory for architecture
BUILD_DIR=build/$(ARCH)

# Source files (exclude graphics kernel by default)
KERNEL_SOURCES = $(filter-out kernel/kernel_graphics.c, $(wildcard kernel/*.c)) $(wildcard kernel/*/*.c)
DRIVER_SOURCES = $(wildcard drivers/*.c) $(wildcard drivers/*/*.c)

# Architecture-specific boot files
ifeq ($(ARCH),x86_64)
    BOOT_SOURCES = boot/boot_no_multiboot.S
    BOOT_OBJECTS = $(BUILD_DIR)/boot/boot_no_multiboot.o
else ifeq ($(ARCH),i386)
    BOOT_SOURCES = boot/boot_i386.S
    BOOT_OBJECTS = $(BUILD_DIR)/boot/boot_i386.o
else
    BOOT_SOURCES = boot/boot.S
    BOOT_OBJECTS = $(BUILD_DIR)/boot/boot.o
endif

SOURCES = $(BOOT_SOURCES) $(KERNEL_SOURCES) $(DRIVER_SOURCES)

KERNEL_OBJECTS = $(patsubst %.c,$(BUILD_DIR)/%.o,$(filter %.c,$(KERNEL_SOURCES) $(DRIVER_SOURCES)))
OBJECTS = $(BOOT_OBJECTS) $(KERNEL_OBJECTS)

all: $(BUILD_DIR)/kernel.img

# Create build directories
$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.S
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

# Special rule for x86_64 boot with multiboot
$(BUILD_DIR)/boot/boot_with_multiboot.o: boot/boot_with_multiboot.S
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

# Special rule for x86_64 boot without multiboot (legacy)
$(BUILD_DIR)/boot/boot_no_multiboot.o: boot/boot_no_multiboot.S
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/kernel.elf: $(OBJECTS)
	@mkdir -p $(dir $@)
	$(LD) $(LDFLAGS) -o $@ $(OBJECTS)

$(BUILD_DIR)/kernel.img: $(BUILD_DIR)/kernel.elf
	@echo "Creating kernel image for $(ARCH) architecture..."
	@mkdir -p $(ARCH_OUTPUT_DIR)
ifeq ($(ARCH),x86_64)
	# For x86_64, create multiboot header and concatenate with kernel binary, then wrap in ELF
	python3 create_multiboot_header.py
	$(OBJCOPY) -O binary $< $(BUILD_DIR)/kernel_no_multiboot.bin
	cat multiboot_header.bin $(BUILD_DIR)/kernel_no_multiboot.bin > $(BUILD_DIR)/kernel_binary.img
	python3 create_elf_wrapper.py $(BUILD_DIR)/kernel_binary.img $@
	@echo "Build completed for $(ARCH) architecture with ELF multiboot wrapper"
else ifeq ($(ARCH),i386)
	# For i386, the kernel already has multiboot header in boot.S, just copy the ELF
	cp $< $@
	@echo "Build completed for $(ARCH) architecture with multiboot ELF"
else
	$(OBJCOPY) -O binary $< $@
	@echo "Build completed for $(ARCH) architecture"
endif
	# Copy to clean output directory with versioned name
	@cp $@ $(ARCH_OUTPUT_DIR)/$(BUILD_ID).img
	@cp $(BUILD_DIR)/kernel.elf $(ARCH_OUTPUT_DIR)/$(BUILD_ID).elf
	@echo "✅ Build completed successfully!"
	@echo "📁 Architecture: $(ARCH)"
	@echo "🎯 Target: $(TARGET)"
	@echo "📦 Version: $(VERSION)"
	@echo "🔧 Build ID: $(BUILD_ID)"
	@echo "📄 Kernel Image: $(ARCH_OUTPUT_DIR)/$(BUILD_ID).img"
	@echo "🔍 Debug ELF: $(ARCH_OUTPUT_DIR)/$(BUILD_ID).elf"

# Clean build directories
clean:
	@echo "🧹 Cleaning build directories..."
	rm -rf build/
	@echo "✅ Build directories cleaned"

# Clean output directories
clean-output:
	@echo "🧹 Cleaning output files..."
	rm -rf $(OUTPUT_DIR)/
	@echo "✅ Output files cleaned"

# Full clean (everything)
clean-all: clean clean-output
	@echo "✅ Full clean completed"

# Create ISO image (x86_64 only)
iso: $(BUILD_DIR)/kernel.img
ifeq ($(ARCH),x86_64)
	@echo "Creating bootable ISO for x86_64..."
	@mkdir -p $(BUILD_DIR)/iso/boot/grub
	@cp $< $(BUILD_DIR)/iso/boot/kernel.img
	@echo 'set timeout=5' > $(BUILD_DIR)/iso/boot/grub/grub.cfg
	@echo 'set default=0' >> $(BUILD_DIR)/iso/boot/grub/grub.cfg
	@echo '' >> $(BUILD_DIR)/iso/boot/grub/grub.cfg
	@echo 'menuentry "SAGE OS $(VERSION) ($(ARCH))" {' >> $(BUILD_DIR)/iso/boot/grub/grub.cfg
	@echo '    multiboot /boot/kernel.img' >> $(BUILD_DIR)/iso/boot/grub/grub.cfg
	@echo '    boot' >> $(BUILD_DIR)/iso/boot/grub/grub.cfg
	@echo '}' >> $(BUILD_DIR)/iso/boot/grub/grub.cfg
	grub-mkrescue -o $(BUILD_DIR)/sageos.iso $(BUILD_DIR)/iso
	# Copy to clean output directory with versioned name
	@cp $(BUILD_DIR)/sageos.iso $(ARCH_OUTPUT_DIR)/$(BUILD_ID).iso
	@echo "✅ ISO created successfully!"
	@echo "💿 ISO File: $(ARCH_OUTPUT_DIR)/$(BUILD_ID).iso"
	@echo "🚀 Ready to boot on x86_64 systems"
else
	@echo "❌ ISO creation only supported for x86_64 architecture"
endif

# Information targets
info:
	@echo "📋 SAGE-OS Build Information"
	@echo "=========================="
	@echo "📦 Version: $(VERSION)"
	@echo "🏗️  Architecture: $(ARCH)"
	@echo "🎯 Target: $(TARGET)"
	@echo "🔧 Build ID: $(BUILD_ID)"
	@echo "📁 Build Directory: $(BUILD_DIR)"
	@echo "📂 Output Directory: $(ARCH_OUTPUT_DIR)"
	@echo "🛠️  Cross Compiler: $(CC)"
	@echo ""
	@echo "📄 Output Files:"
	@echo "  Kernel Image: $(ARCH_OUTPUT_DIR)/$(BUILD_ID).img"
	@echo "  Debug ELF: $(ARCH_OUTPUT_DIR)/$(BUILD_ID).elf"
ifeq ($(ARCH),x86_64)
	@echo "  Bootable ISO: $(ARCH_OUTPUT_DIR)/$(BUILD_ID).iso"
endif

# Show current version
version:
	@echo "$(VERSION)"

# List available architectures
list-arch:
	@echo "🏗️  Supported Architectures:"
	@echo "  • i386     - 32-bit x86 (fully working)"
	@echo "  • x86_64   - 64-bit x86 (partial - GRUB boots)"
	@echo "  • aarch64  - 64-bit ARM (fully working)"
	@echo "  • arm      - 32-bit ARM (builds successfully)"
	@echo "  • riscv64  - 64-bit RISC-V (builds, OpenSBI loads)"

# Create all architecture builds
all-arch:
	@echo "🏗️  Building for all architectures..."
	$(MAKE) ARCH=i386 TARGET=generic
	$(MAKE) ARCH=aarch64 TARGET=generic
	$(MAKE) ARCH=x86_64 TARGET=generic
	$(MAKE) ARCH=riscv64 TARGET=generic
	@echo "✅ All architectures built successfully!"

# Quick test targets using unified script
test:
	@echo "🧪 Testing $(ARCH) build in QEMU..."
	@./scripts/testing/test-qemu.sh $(ARCH) $(TARGET)

test-i386:
	@./scripts/testing/test-qemu.sh i386 generic

test-aarch64:
	@./scripts/testing/test-qemu.sh aarch64 generic

test-x86_64:
	@./scripts/testing/test-qemu.sh x86_64 generic

test-riscv64:
	@./scripts/testing/test-qemu.sh riscv64 generic

# Graphics mode testing (x86 only)
test-graphics:
	@echo "🖥️ Testing $(ARCH) build in QEMU graphics mode..."
	@./scripts/testing/test-graphics-mode.sh $(ARCH) $(TARGET)

test-i386-graphics:
	@./scripts/testing/test-graphics-mode.sh i386 generic

test-x86_64-graphics:
	@./scripts/testing/test-graphics-mode.sh x86_64 generic

# Legacy graphics testing (using old script)
test-graphics-legacy:
	@echo "🖥️ Testing $(ARCH) build in QEMU graphics mode (legacy)..."
	@./scripts/testing/test-qemu.sh $(ARCH) $(TARGET) graphics

# Windows-specific targets
windows-setup:
	@echo "🪟 Setting up Windows development environment..."
	@echo "💡 Run this in Windows Command Prompt as Administrator:"
	@echo "   scripts\\windows\\sage-os-installer.bat"

windows-build:
	@echo "🪟 Building SAGE OS on Windows..."
	@echo "💡 Run this in Windows Command Prompt:"
	@echo "   scripts\\windows\\build-sage-os.bat $(ARCH) $(TARGET)"

windows-launch:
	@echo "🪟 Launching SAGE OS on Windows..."
	@echo "💡 Run this in Windows Command Prompt:"
	@echo "   scripts\\windows\\quick-launch.bat"

windows-help:
	@echo "🪟 SAGE OS Windows Commands"
	@echo "=========================="
	@echo ""
	@echo "📦 Setup:"
	@echo "  scripts\\windows\\sage-os-installer.bat   - Complete setup"
	@echo "  scripts\\windows\\install-dependencies.bat - Dependencies only"
	@echo "  scripts\\windows\\create-shortcuts.bat    - Desktop shortcuts"
	@echo ""
	@echo "🔨 Building:"
	@echo "  scripts\\windows\\build-sage-os.bat       - Build kernel"
	@echo "  scripts\\windows\\build-sage-os.bat i386  - Build for i386"
	@echo ""
	@echo "🚀 Launching:"
	@echo "  scripts\\windows\\quick-launch.bat        - One-click launch"
	@echo "  scripts\\windows\\launch-sage-os-graphics.bat - Graphics mode"
	@echo "  scripts\\windows\\launch-sage-os-console.bat  - Console mode"
	@echo ""
	@echo "💡 All scripts should be run in Windows Command Prompt"
	@echo "⚠️  Some scripts require Administrator privileges"

# Help target
help:
	@echo "🚀 SAGE-OS Build System"
	@echo "======================"
	@echo ""
	@echo "📋 Main Targets:"
	@echo "  make [ARCH=arch] [TARGET=target]  - Build kernel for specified architecture"
	@echo "  make iso                          - Create bootable ISO (x86_64 only)"
	@echo "  make all-arch                     - Build for all architectures"
	@echo ""
	@echo "🧹 Cleaning:"
	@echo "  make clean                        - Clean build directories"
	@echo "  make clean-output                 - Clean output files"
	@echo "  make clean-all                    - Full clean (everything)"
	@echo ""
	@echo "ℹ️  Information:"
	@echo "  make info                         - Show build configuration"
	@echo "  make version                      - Show current version"
	@echo "  make list-arch                    - List supported architectures"
	@echo ""
	@echo "🧪 Testing:"
	@echo "  make test                         - Test current ARCH/TARGET in QEMU"
	@echo "  make test-i386                    - Test i386 build in QEMU"
	@echo "  make test-aarch64                 - Test aarch64 build in QEMU"
	@echo "  make test-x86_64                  - Test x86_64 build in QEMU"
	@echo "  make test-riscv64                 - Test riscv64 build in QEMU"
	@echo ""
	@echo "🖥️ Graphics Mode Testing (x86 only):"
	@echo "  make test-graphics                - Test current ARCH in graphics mode"
	@echo "  make test-i386-graphics           - Test i386 in graphics mode"
	@echo "  make test-x86_64-graphics         - Test x86_64 in graphics mode"
	@echo ""
	@echo "🔧 Direct Script Usage:"
	@echo "  ./scripts/testing/test-qemu.sh <arch>     - Serial console mode"
	@echo "  ./scripts/testing/test-qemu.sh <arch> <target> graphics - Graphics mode"
	@echo "  ./scripts/testing/test-graphics-mode.sh <arch> - Enhanced graphics mode"
	@echo "  ./scripts/setup-cross-compilation.sh     - Setup cross-compilation tools"
	@echo ""
	@echo "🪟 Windows Scripts:"
	@echo "  scripts\\windows\\quick-launch.bat       - One-click build and launch"
	@echo "  scripts\\windows\\build-sage-os.bat      - Windows build script"
	@echo "  scripts\\windows\\launch-sage-os-graphics.bat - Graphics mode launcher"
	@echo "  scripts\\windows\\setup-windows-environment.ps1 - Windows setup"
	@echo ""
	@echo "📝 Examples:"
	@echo "  make ARCH=aarch64 TARGET=rpi5     - Build for Raspberry Pi 5"
	@echo "  make ARCH=i386 TARGET=generic     - Build for generic i386"
	@echo "  make test-i386-graphics           - Test i386 with VGA graphics and keyboard"
	@echo ""
	@echo "📖 Documentation:"
	@echo "  See GRAPHICS_MODE_GUIDE.md for VGA graphics mode details"
	@echo "  See PROJECT_STRUCTURE.md for project organization"
	@echo "  make ARCH=x86_64 iso              - Build x86_64 and create ISO"

# Alias targets
kernel: $(BUILD_DIR)/kernel.elf
image: $(BUILD_DIR)/kernel.img

.PHONY: all clean clean-output clean-all all-arch info version list-arch help kernel image iso test test-i386 test-aarch64 test-x86_64 test-riscv64 test-graphics test-i386-graphics test-x86_64-graphics test-graphics-legacy windows-setup windows-build windows-launch windows-help