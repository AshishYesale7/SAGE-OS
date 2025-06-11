#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS Performance Benchmarking

echo "📈 SAGE OS Performance Benchmarks"
echo "================================="

# Check if build outputs exist
if [ ! -d "build-output" ]; then
    echo "❌ build-output directory not found. Run ./build-all-architectures.sh first."
    exit 1
fi

for arch in aarch64 arm x86_64 riscv64; do
    if [ -f "build-output/kernel-$arch-generic.img" ]; then
        echo "Testing $arch architecture..."
        
        # Boot time test
        start_time=$(date +%s%N)
        
        # Determine QEMU system based on architecture
        case $arch in
            aarch64)
                qemu_system="qemu-system-aarch64"
                machine="virt"
                cpu="cortex-a57"
                ;;
            arm)
                qemu_system="qemu-system-arm"
                machine="virt"
                cpu="cortex-a15"
                ;;
            x86_64)
                qemu_system="qemu-system-x86_64"
                machine="pc"
                cpu="qemu64"
                ;;
            riscv64)
                qemu_system="qemu-system-riscv64"
                machine="virt"
                cpu="rv64"
                ;;
        esac
        
        timeout 10 $qemu_system \
            -M $machine \
            -cpu $cpu \
            -m 1024 \
            -kernel build-output/kernel-$arch-generic.img \
            -serial stdio \
            -display none > /tmp/boot_$arch.log 2>&1 || true
        end_time=$(date +%s%N)
        
        boot_time=$(( (end_time - start_time) / 1000000 ))
        echo "  Boot time: ${boot_time}ms"
        
        # Kernel size
        size=$(stat -c%s build-output/kernel-$arch-generic.img 2>/dev/null || stat -f%z build-output/kernel-$arch-generic.img)
        echo "  Kernel size: $((size / 1024))KB"
        
        # ELF size (if available)
        if [ -f "build-output/kernel-$arch-generic.elf" ]; then
            elf_size=$(stat -c%s build-output/kernel-$arch-generic.elf 2>/dev/null || stat -f%z build-output/kernel-$arch-generic.elf)
            echo "  ELF size: $((elf_size / 1024))KB"
        fi
        
        echo
    else
        echo "❌ $arch kernel not found, skipping..."
    fi
done

echo "📊 Summary of all builds:"
echo "========================="
ls -lh build-output/ | grep -E '\.(img|elf)$'