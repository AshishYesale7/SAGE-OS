# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS Prototype Makefile

# Default target platform
TARGET_PLATFORM ?= rpi4

# Build options
ENABLE_AI ?= OFF
ENABLE_CRYPTO ?= ON
ENABLE_AI_HAT_PLUS ?= OFF
MEMORY_SIZE ?= 1024

# Build directory
BUILD_DIR = build

# Output kernel name
ifeq ($(TARGET_PLATFORM),rpi5)
    KERNEL_NAME = kernel8-rpi5.img
else
    KERNEL_NAME = kernel8.img
endif

# Default target
all: kernel

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Configure and build
kernel: $(BUILD_DIR)
	cd $(BUILD_DIR) && cmake .. \
		-DTARGET_PLATFORM=$(TARGET_PLATFORM) \
		-DENABLE_AI=$(ENABLE_AI) \
		-DENABLE_CRYPTO=$(ENABLE_CRYPTO) \
		-DENABLE_AI_HAT_PLUS=$(ENABLE_AI_HAT_PLUS) \
		-DMEMORY_SIZE=$(MEMORY_SIZE)
	cmake --build $(BUILD_DIR)
	@echo "Build complete: $(BUILD_DIR)/$(KERNEL_NAME)"

# Clean build files
clean:
	rm -rf $(BUILD_DIR)
	rm -rf target

# Run in QEMU using the script
qemu: kernel
	./run_qemu.sh -k $(BUILD_DIR)/$(KERNEL_NAME)

# Run Raspberry Pi 5 in QEMU
qemu_rpi5: rpi5
	./run_qemu.sh -p rpi5 -k $(BUILD_DIR)/$(KERNEL_NAME)

# Run with AI HAT+ emulation
qemu_ai: rpi5_ai
	./run_qemu.sh -p rpi5 -a -k $(BUILD_DIR)/$(KERNEL_NAME)

# Debug with QEMU and GDB
debug: kernel
	./run_qemu.sh -d -k $(BUILD_DIR)/$(KERNEL_NAME)

# Debug Raspberry Pi 5 with QEMU and GDB
debug_rpi5: rpi5
	./run_qemu.sh -p rpi5 -d -k $(BUILD_DIR)/$(KERNEL_NAME)

# Debug with AI HAT+ emulation
debug_ai: rpi5_ai
	./run_qemu.sh -p rpi5 -a -d -k $(BUILD_DIR)/$(KERNEL_NAME)

# Generate documentation
docs:
	cargo doc --no-deps

# Install to SD card (assuming mounted at /mnt/sdcard)
install: kernel
	@if [ ! -d "/mnt/sdcard" ]; then \
		echo "Error: /mnt/sdcard not found. Please mount your SD card first."; \
		exit 1; \
	fi
	cp $(BUILD_DIR)/$(KERNEL_NAME) /mnt/sdcard/
	if [ "$(TARGET_PLATFORM)" = "rpi5" ]; then \
		cp config_rpi5.txt /mnt/sdcard/config.txt; \
		echo "Installed for Raspberry Pi 5"; \
	else \
		cp config.txt /mnt/sdcard/; \
		echo "Installed for Raspberry Pi 3/4"; \
	fi

# Raspberry Pi 5 specific targets
rpi5: 
	$(MAKE) kernel TARGET_PLATFORM=rpi5

rpi5_ai:
	$(MAKE) kernel TARGET_PLATFORM=rpi5 ENABLE_AI=ON ENABLE_AI_HAT_PLUS=ON

# Run tests
test: kernel
	cd $(BUILD_DIR) && ctest --verbose

# Create SD card image
sdcard: kernel
	@echo "Creating SD card image..."
	dd if=/dev/zero of=$(BUILD_DIR)/sage_os.img bs=1M count=64
	mkfs.vfat $(BUILD_DIR)/sage_os.img
	mkdir -p $(BUILD_DIR)/mnt
	sudo mount $(BUILD_DIR)/sage_os.img $(BUILD_DIR)/mnt
	sudo cp $(BUILD_DIR)/$(KERNEL_NAME) $(BUILD_DIR)/mnt/kernel8.img
	if [ "$(TARGET_PLATFORM)" = "rpi5" ]; then \
		sudo cp config_rpi5.txt $(BUILD_DIR)/mnt/config.txt; \
	else \
		sudo cp config.txt $(BUILD_DIR)/mnt/config.txt; \
	fi
	sudo umount $(BUILD_DIR)/mnt
	rmdir $(BUILD_DIR)/mnt
	@echo "SD card image created: $(BUILD_DIR)/sage_os.img"

# Phony targets
.PHONY: all kernel clean qemu qemu_rpi5 qemu_ai debug debug_rpi5 debug_ai docs install rpi5 rpi5_ai test sdcard