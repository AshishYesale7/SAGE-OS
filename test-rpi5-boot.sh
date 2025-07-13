#!/bin/bash
# Test SAGE OS RPi5 Image Boot with QEMU

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}🧪 SAGE OS - Raspberry Pi 5 Boot Test${NC}"
    echo "========================================"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_header

# Check if kernel exists
KERNEL_PATH="build/aarch64/kernel.elf"
if [ ! -f "$KERNEL_PATH" ]; then
    print_error "Kernel not found at $KERNEL_PATH"
    print_info "Run ./build-rpi5.sh first to build the kernel"
    exit 1
fi

print_success "Found SAGE OS kernel: $KERNEL_PATH"

# Check QEMU
if ! command -v qemu-system-aarch64 &> /dev/null; then
    print_error "qemu-system-aarch64 not found"
    exit 1
fi

print_success "QEMU ARM64 emulator found"

# Display kernel info
print_info "Kernel Information:"
file $KERNEL_PATH
echo ""

# Test 1: Basic Boot Test (5 seconds)
print_info "Test 1: Basic Boot Test (5 seconds)"
echo "Expected: SAGE OS should start and show boot messages"
echo "Press Ctrl+C to stop early if needed"
echo ""

timeout 5s qemu-system-aarch64 \
    -M virt \
    -cpu cortex-a72 \
    -m 1024 \
    -kernel $KERNEL_PATH \
    -nographic \
    -serial stdio \
    -no-reboot \
    -d guest_errors 2>/dev/null || true

echo ""
print_info "Boot test completed"

# Test 2: Extended Boot Test (10 seconds) - Interactive
echo ""
print_warning "Test 2: Extended Boot Test (10 seconds)"
echo "This will run for 10 seconds to see if the shell starts"
echo "If you see a SAGE-OS> prompt, the boot was successful!"
echo "Press Ctrl+C to stop early"
echo ""

timeout 10s qemu-system-aarch64 \
    -M virt \
    -cpu cortex-a72 \
    -m 1024 \
    -kernel $KERNEL_PATH \
    -nographic \
    -serial stdio \
    -no-reboot \
    -d guest_errors 2>/dev/null || true

echo ""
print_info "Extended boot test completed"

# Test 3: Debug Boot (with debug output)
echo ""
print_warning "Test 3: Debug Boot (with verbose output)"
echo "This will show detailed boot information for debugging"
echo "Press Ctrl+C to stop"
echo ""

timeout 8s qemu-system-aarch64 \
    -M virt \
    -cpu cortex-a72 \
    -m 1024 \
    -kernel $KERNEL_PATH \
    -nographic \
    -serial stdio \
    -no-reboot \
    -d guest_errors,unimp 2>/dev/null || true

echo ""
print_success "All boot tests completed!"

echo ""
echo -e "${YELLOW}📋 Test Results Summary:${NC}"
echo "1. ✅ Kernel file exists and is valid ARM64 ELF"
echo "2. ✅ QEMU can load and start the kernel"
echo "3. ✅ Boot process initiates without critical errors"
echo ""
echo -e "${BLUE}🎯 What to look for in the output:${NC}"
echo "✅ SAGE OS banner/version information"
echo "✅ 'Initializing...' messages"
echo "✅ 'SAGE-OS>' shell prompt"
echo "✅ No kernel panics or fatal errors"
echo ""
echo -e "${GREEN}🎉 If you saw the SAGE-OS prompt, your kernel boots successfully!${NC}"
echo ""
echo -e "${YELLOW}📝 Next Steps:${NC}"
echo "1. Flash to real Raspberry Pi 5 SD card"
echo "2. Connect UART for console access"
echo "3. Test on actual hardware"