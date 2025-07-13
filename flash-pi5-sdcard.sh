#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS Raspberry Pi 5 SD Card Flasher
# Automated script to flash SAGE OS ARM64 to SD card

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_header() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}    SAGE OS Raspberry Pi 5 SD Card Flasher${NC}"
    echo -e "${BLUE}================================================${NC}"
}

print_info() {
    echo -e "${GREEN}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Check if running as root for disk operations
check_permissions() {
    if [[ $EUID -eq 0 ]]; then
        print_warning "Running as root - be careful with disk operations!"
    fi
}

# Find SAGE OS image
find_sage_image() {
    local image_path=""
    
    # Look for built images
    if [[ -d "build-output/arm64" ]]; then
        image_path=$(find build-output/arm64 -name "*.img" | head -1)
    fi
    
    if [[ -z "$image_path" ]]; then
        print_error "No SAGE OS ARM64 image found!"
        print_info "Please build the image first with: ./build-core-arm64.sh"
        exit 1
    fi
    
    echo "$image_path"
}

# List available disks
list_disks() {
    print_info "Available storage devices:"
    
    if command -v lsblk >/dev/null 2>&1; then
        # Linux
        lsblk -d -o NAME,SIZE,MODEL | grep -E "(sd|mmcblk)"
    elif command -v diskutil >/dev/null 2>&1; then
        # macOS
        diskutil list | grep -E "(disk[0-9]|external|physical)"
    else
        print_warning "Cannot auto-detect disks. Please specify device manually."
    fi
}

# Validate device
validate_device() {
    local device="$1"
    
    if [[ ! -b "$device" ]]; then
        print_error "Device $device does not exist or is not a block device"
        return 1
    fi
    
    # Check if device is mounted
    if mount | grep -q "$device"; then
        print_warning "Device $device appears to be mounted"
        print_info "Please unmount all partitions before flashing"
        return 1
    fi
    
    return 0
}

# Flash image to device
flash_image() {
    local image="$1"
    local device="$2"
    
    print_info "Flashing SAGE OS to $device..."
    print_warning "This will DESTROY all data on $device!"
    
    read -p "Are you sure you want to continue? (yes/no): " confirm
    if [[ "$confirm" != "yes" ]]; then
        print_info "Aborted by user"
        exit 0
    fi
    
    # Unmount any mounted partitions
    if command -v umount >/dev/null 2>&1; then
        umount "${device}"* 2>/dev/null || true
    fi
    
    # Flash the image
    print_info "Writing image to $device (this may take several minutes)..."
    
    if command -v pv >/dev/null 2>&1; then
        # Use pv for progress if available
        pv "$image" | sudo dd of="$device" bs=4M conv=fsync
    else
        # Use dd with status
        sudo dd if="$image" of="$device" bs=4M status=progress conv=fsync
    fi
    
    # Sync to ensure all data is written
    sync
    
    print_success "Image flashed successfully!"
}

# Create manual boot files
create_boot_files() {
    local device="$1"
    
    print_info "Setting up boot files manually..."
    
    # Find the latest build
    local build_dir=$(find build-output/arm64 -name "SAGE-OS-*-arm64-rpi5-core" -type d | sort | tail -1)
    
    if [[ -z "$build_dir" ]]; then
        print_error "No build directory found"
        return 1
    fi
    
    # Create mount point
    local mount_point="/tmp/sage_boot"
    sudo mkdir -p "$mount_point"
    
    # Try to mount the first partition
    if sudo mount "${device}1" "$mount_point" 2>/dev/null; then
        print_info "Copying boot files to SD card..."
        
        sudo cp "$build_dir/config.txt" "$mount_point/"
        sudo cp "$build_dir/kernel8.img" "$mount_point/"
        sudo cp "$build_dir/kernel.elf" "$mount_point/"
        
        sudo umount "$mount_point"
        sudo rmdir "$mount_point"
        
        print_success "Boot files copied successfully!"
    else
        print_warning "Could not mount boot partition automatically"
        print_info "Please manually copy these files to the SD card boot partition:"
        print_info "  - $build_dir/config.txt"
        print_info "  - $build_dir/kernel8.img"
        print_info "  - $build_dir/kernel.elf"
    fi
}

# Main function
main() {
    print_header
    check_permissions
    
    # Find SAGE OS image
    local image=$(find_sage_image)
    print_info "Found SAGE OS image: $image"
    
    # List available disks
    echo
    list_disks
    echo
    
    # Get target device
    if [[ -n "$1" ]]; then
        local device="$1"
    else
        read -p "Enter target device (e.g., /dev/sdb, /dev/mmcblk0): " device
    fi
    
    # Validate device
    if ! validate_device "$device"; then
        exit 1
    fi
    
    # Show device info
    print_info "Target device: $device"
    if command -v lsblk >/dev/null 2>&1; then
        lsblk "$device"
    fi
    
    echo
    
    # Flash the image
    flash_image "$image" "$device"
    
    # Optional: Set up boot files manually
    read -p "Do you want to set up boot files manually? (y/n): " setup_boot
    if [[ "$setup_boot" == "y" || "$setup_boot" == "Y" ]]; then
        create_boot_files "$device"
    fi
    
    echo
    print_success "SAGE OS has been flashed to $device!"
    print_info "Next steps:"
    print_info "1. Insert SD card into Raspberry Pi 5"
    print_info "2. Connect UART for serial debugging (optional)"
    print_info "3. Power on and enjoy SAGE OS!"
    print_info ""
    print_info "UART Settings: 115200 baud, 8N1"
    print_info "GPIO 14 (Pin 8) → UART RX"
    print_info "GPIO 15 (Pin 10) → UART TX"
    print_info "GND (Pin 6) → UART GND"
}

# Help function
show_help() {
    echo "SAGE OS Raspberry Pi 5 SD Card Flasher"
    echo ""
    echo "Usage: $0 [device]"
    echo ""
    echo "Examples:"
    echo "  $0                    # Interactive mode"
    echo "  $0 /dev/sdb          # Flash to /dev/sdb"
    echo "  $0 /dev/mmcblk0      # Flash to /dev/mmcblk0"
    echo ""
    echo "Options:"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Prerequisites:"
    echo "  - SAGE OS ARM64 image built (run ./build-core-arm64.sh first)"
    echo "  - SD card (32GB+ recommended)"
    echo "  - Root/sudo access for disk operations"
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac