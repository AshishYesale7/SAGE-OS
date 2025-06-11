#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────────────────────────────

# SAGE OS - Quick Security Check
# This script performs basic security checks on SAGE OS kernel images

echo "🔒 SAGE OS Quick Security Check"
echo "==============================="

# Create security reports directory
SECURITY_DIR="security-reports"
mkdir -p "$SECURITY_DIR"

echo "📋 Checking built kernel files..."

# Check file permissions and basic security properties
for arch in x86_64 aarch64 riscv64; do
    KERNEL_PATH="build/$arch/kernel.img"
    ELF_PATH="build/$arch/kernel.elf"
    
    if [ -f "$KERNEL_PATH" ]; then
        echo ""
        echo "🔍 Analyzing $arch kernel image..."
        
        # File size and permissions
        echo "   📏 Size: $(ls -lh "$KERNEL_PATH" | awk '{print $5}')"
        echo "   🔐 Permissions: $(ls -l "$KERNEL_PATH" | awk '{print $1}')"
        
        # Check for executable stack (basic check)
        if command -v readelf >/dev/null 2>&1 && [ -f "$ELF_PATH" ]; then
            echo "   🔍 ELF Security Analysis:"
            
            # Check for executable stack
            if readelf -l "$ELF_PATH" 2>/dev/null | grep -q "GNU_STACK.*RWE"; then
                echo "   ⚠️  WARNING: Executable stack detected"
            else
                echo "   ✅ No executable stack"
            fi
            
            # Check for RELRO
            if readelf -l "$ELF_PATH" 2>/dev/null | grep -q "GNU_RELRO"; then
                echo "   ✅ RELRO protection enabled"
            else
                echo "   ⚠️  RELRO protection not found"
            fi
            
            # Check for PIE
            if readelf -h "$ELF_PATH" 2>/dev/null | grep -q "Type:.*DYN"; then
                echo "   ✅ Position Independent Executable (PIE)"
            else
                echo "   ℹ️  Static executable (expected for kernel)"
            fi
        fi
        
        # Basic string analysis for potential issues
        echo "   🔍 String Analysis:"
        
        # Check for debug strings
        DEBUG_STRINGS=$(strings "$KERNEL_PATH" 2>/dev/null | grep -i -E "(debug|test|todo|fixme|hack)" | wc -l)
        if [ "$DEBUG_STRINGS" -gt 0 ]; then
            echo "   ⚠️  Found $DEBUG_STRINGS debug-related strings"
        else
            echo "   ✅ No debug strings found"
        fi
        
        # Check for hardcoded paths
        HARDCODED_PATHS=$(strings "$KERNEL_PATH" 2>/dev/null | grep -E "^/[a-zA-Z]" | wc -l)
        if [ "$HARDCODED_PATHS" -gt 0 ]; then
            echo "   ⚠️  Found $HARDCODED_PATHS potential hardcoded paths"
        else
            echo "   ✅ No hardcoded paths found"
        fi
        
        # Check for potential credentials
        CRED_STRINGS=$(strings "$KERNEL_PATH" 2>/dev/null | grep -i -E "(password|secret|key|token|credential)" | wc -l)
        if [ "$CRED_STRINGS" -gt 0 ]; then
            echo "   ⚠️  Found $CRED_STRINGS potential credential strings"
        else
            echo "   ✅ No credential strings found"
        fi
        
    else
        echo "⚠️  Kernel image not found: $KERNEL_PATH"
    fi
done

# Check ISO security if it exists
ISO_PATH="build/x86_64/sageos.iso"
if [ -f "$ISO_PATH" ]; then
    echo ""
    echo "🔍 Analyzing x86_64 ISO image..."
    echo "   📏 Size: $(ls -lh "$ISO_PATH" | awk '{print $5}')"
    echo "   🔐 Permissions: $(ls -l "$ISO_PATH" | awk '{print $1}')"
fi

# Generate security report
REPORT_FILE="$SECURITY_DIR/security-check-$(date +%Y%m%d-%H%M%S).txt"

{
    echo "SAGE OS Security Check Report"
    echo "============================"
    echo "Date: $(date)"
    echo "Host: $(uname -a)"
    echo ""
    
    echo "Checked Files:"
    echo "=============="
    for arch in x86_64 aarch64 riscv64; do
        if [ -f "build/$arch/kernel.img" ]; then
            echo "✅ $arch kernel: $(ls -lh build/$arch/kernel.img | awk '{print $5}')"
        else
            echo "❌ $arch kernel: Not found"
        fi
    done
    
    if [ -f "$ISO_PATH" ]; then
        echo "✅ x86_64 ISO: $(ls -lh "$ISO_PATH" | awk '{print $5}')"
    fi
    
    echo ""
    echo "Security Recommendations:"
    echo "========================="
    echo "1. Regularly update build toolchain"
    echo "2. Enable compiler security flags (-fstack-protector, -D_FORTIFY_SOURCE=2)"
    echo "3. Use static analysis tools"
    echo "4. Implement code signing for release builds"
    echo "5. Regular security audits of kernel code"
    echo "6. Use CVE scanning tools for dependencies"
    
} > "$REPORT_FILE"

echo ""
echo "📄 Security report saved: $REPORT_FILE"

echo ""
echo "🔒 Quick Security Check Summary:"
echo "================================"
echo "✅ File permissions checked"
echo "✅ Basic ELF security analysis performed"
echo "✅ String analysis completed"
echo "✅ Security report generated"

echo ""
echo "💡 Recommendations:"
echo "- Run full CVE scan when network allows: cve-bin-tool build/"
echo "- Use static analysis tools like: clang-static-analyzer, cppcheck"
echo "- Consider implementing kernel ASLR and stack canaries"
echo "- Regular security code reviews"

echo ""
echo "🔒 Security check completed!"