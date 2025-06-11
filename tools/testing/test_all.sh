#!/bin/bash

# SAGE OS Test Script - All Architectures
# Author: Ashish Vasant Yesale
# Email: ashishyesale007@gmail.com

set -e

VERSION="v1.0.0"
DATE=$(date +%Y%m%d)
BUILD_DIR="build"

echo "🧪 Testing SAGE OS ${VERSION} - ${DATE}"
echo "=================================================="

# Test i386 architecture
echo ""
echo "🔍 Testing i386 architecture..."
echo "----------------------------------------"
if [[ -f "${BUILD_DIR}/i386/sage-os-i386-${VERSION}-${DATE}.iso" ]]; then
    echo "Starting i386 test in tmux session..."
    tmux kill-session -t sage-test-i386 2>/dev/null || true
    tmux new-session -d -s sage-test-i386
    tmux send-keys -t sage-test-i386 "cd /workspace/SAGE-OS && timeout 30 qemu-system-i386 -M pc -cdrom ${BUILD_DIR}/i386/sage-os-i386-${VERSION}-${DATE}.iso -m 1024 -nographic -serial mon:stdio" Enter
    
    echo "Waiting for boot sequence..."
    sleep 15
    
    echo "Capturing output..."
    tmux capture-pane -t sage-test-i386 -p > test_output_i386.log
    
    if grep -q "SAGE OS" test_output_i386.log; then
        echo "✅ i386: Boot successful - SAGE OS detected"
    else
        echo "❌ i386: Boot failed or incomplete"
    fi
    
    tmux kill-session -t sage-test-i386 2>/dev/null || true
else
    echo "❌ i386: ISO file not found"
fi

# Test x86_64 architecture
echo ""
echo "🔍 Testing x86_64 architecture..."
echo "----------------------------------------"
if [[ -f "${BUILD_DIR}/x86_64/sage-os-x86_64-${VERSION}-${DATE}.iso" ]]; then
    echo "Starting x86_64 test in tmux session..."
    tmux kill-session -t sage-test-x64 2>/dev/null || true
    tmux new-session -d -s sage-test-x64
    tmux send-keys -t sage-test-x64 "cd /workspace/SAGE-OS && timeout 30 qemu-system-x86_64 -M pc -cdrom ${BUILD_DIR}/x86_64/sage-os-x86_64-${VERSION}-${DATE}.iso -m 1024 -nographic -serial mon:stdio" Enter
    
    echo "Waiting for boot sequence..."
    sleep 15
    
    echo "Capturing output..."
    tmux capture-pane -t sage-test-x64 -p > test_output_x86_64.log
    
    if grep -q "SAGE OS" test_output_x86_64.log; then
        echo "✅ x86_64: Boot successful - SAGE OS detected"
    else
        echo "❌ x86_64: Boot failed or incomplete"
    fi
    
    tmux kill-session -t sage-test-x64 2>/dev/null || true
else
    echo "❌ x86_64: ISO file not found"
fi

# Test aarch64 architecture
echo ""
echo "🔍 Testing aarch64 architecture..."
echo "----------------------------------------"
if [[ -f "${BUILD_DIR}/aarch64/sage-os-aarch64-${VERSION}-${DATE}.img" ]]; then
    echo "Starting aarch64 test in tmux session..."
    tmux kill-session -t sage-test-arm64 2>/dev/null || true
    tmux new-session -d -s sage-test-arm64
    tmux send-keys -t sage-test-arm64 "cd /workspace/SAGE-OS && timeout 30 qemu-system-aarch64 -M virt -cpu cortex-a57 -kernel ${BUILD_DIR}/aarch64/sage-os-aarch64-${VERSION}-${DATE}.img -m 1024 -nographic -serial mon:stdio" Enter
    
    echo "Waiting for boot sequence..."
    sleep 15
    
    echo "Capturing output..."
    tmux capture-pane -t sage-test-arm64 -p > test_output_aarch64.log
    
    if grep -q "SAGE OS" test_output_aarch64.log; then
        echo "✅ aarch64: Boot successful - SAGE OS detected"
    else
        echo "❌ aarch64: Boot failed or incomplete"
    fi
    
    tmux kill-session -t sage-test-arm64 2>/dev/null || true
else
    echo "❌ aarch64: Kernel image not found"
fi

# Test riscv64 architecture
echo ""
echo "🔍 Testing riscv64 architecture..."
echo "----------------------------------------"
if [[ -f "${BUILD_DIR}/riscv64/sage-os-riscv64-${VERSION}-${DATE}.img" ]]; then
    echo "Starting riscv64 test in tmux session..."
    tmux kill-session -t sage-test-riscv 2>/dev/null || true
    tmux new-session -d -s sage-test-riscv
    tmux send-keys -t sage-test-riscv "cd /workspace/SAGE-OS && timeout 30 qemu-system-riscv64 -M virt -kernel ${BUILD_DIR}/riscv64/sage-os-riscv64-${VERSION}-${DATE}.img -m 1024 -nographic -serial mon:stdio" Enter
    
    echo "Waiting for boot sequence..."
    sleep 15
    
    echo "Capturing output..."
    tmux capture-pane -t sage-test-riscv -p > test_output_riscv64.log
    
    if grep -q "SAGE OS" test_output_riscv64.log; then
        echo "✅ riscv64: Boot successful - SAGE OS detected"
    else
        echo "❌ riscv64: Boot failed or incomplete"
    fi
    
    tmux kill-session -t sage-test-riscv 2>/dev/null || true
else
    echo "❌ riscv64: Kernel image not found"
fi

echo ""
echo "📊 Test Summary"
echo "=================================================="
echo "Test logs generated:"
for arch in i386 x86_64 aarch64 riscv64; do
    if [[ -f "test_output_${arch}.log" ]]; then
        echo "  📄 test_output_${arch}.log"
    fi
done

echo ""
echo "🎯 Test completed!"
echo "=================================================="