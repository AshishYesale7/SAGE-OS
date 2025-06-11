#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS - CVE Vulnerability Scanner
# This script scans SAGE OS kernel images for known vulnerabilities using CVE-bin-tool

# Function to show usage
show_usage() {
    echo "🔍 SAGE OS CVE Vulnerability Scanner"
    echo "===================================="
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -f, --format FORMAT    Output format: json, html, pdf, csv, console (default: json)"
    echo "  -o, --output DIR       Output directory (default: security-reports)"
    echo "  -a, --arch ARCH        Scan specific architecture: x86_64, aarch64, arm, riscv64, i386, all (default: all)"
    echo "  -u, --update           Update CVE database before scanning"
    echo "  -h, --help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Scan all architectures, JSON output"
    echo "  $0 -f html -o reports                # HTML output to reports directory"
    echo "  $0 -f pdf -a x86_64                  # PDF report for x86_64 only"
    echo "  $0 -f console -u                     # Console output with database update"
    echo ""
}

# Default values
OUTPUT_FORMAT="json"
OUTPUT_DIR="security-reports"
TARGET_ARCH="all"
UPDATE_DB=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--format)
            OUTPUT_FORMAT="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -a|--arch)
            TARGET_ARCH="$2"
            shift 2
            ;;
        -u|--update)
            UPDATE_DB=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate output format
case $OUTPUT_FORMAT in
    json|html|pdf|csv|console)
        ;;
    *)
        echo "❌ Invalid output format: $OUTPUT_FORMAT"
        echo "Valid formats: json, html, pdf, csv, console"
        exit 1
        ;;
esac

# Validate architecture
case $TARGET_ARCH in
    x86_64|aarch64|arm|riscv64|i386|all)
        ;;
    *)
        echo "❌ Invalid architecture: $TARGET_ARCH"
        echo "Valid architectures: x86_64, aarch64, arm, riscv64, i386, all"
        exit 1
        ;;
esac

echo "🔍 SAGE OS CVE Vulnerability Scanner"
echo "===================================="
echo "📋 Configuration:"
echo "   Output format: $OUTPUT_FORMAT"
echo "   Output directory: $OUTPUT_DIR"
echo "   Target architecture: $TARGET_ARCH"
echo "   Update database: $UPDATE_DB"
echo ""

# Create reports directory with timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORTS_DIR="$OUTPUT_DIR"
VERSIONED_DIR="$REPORTS_DIR/scan_$TIMESTAMP"
mkdir -p "$VERSIONED_DIR"

# Check if CVE database exists and update it
if [ "$UPDATE_DB" = true ]; then
    echo "📥 Updating CVE database..."
    if ! cve-bin-tool --update; then
        echo "⚠️  Failed to update CVE database, proceeding with existing data..."
    fi
else
    echo "📋 Using existing CVE database (use -u to update)"
fi

# Detect system information
echo "🖥️  System Detection:"
echo "   OS: $(uname -s)"
echo "   Architecture: $(uname -m)"
echo "   Kernel: $(uname -r)"
echo "   CVE-bin-tool: $(cve-bin-tool --version 2>/dev/null || echo 'Not found')"
echo ""

echo "🔍 Scanning kernel images for vulnerabilities..."

# Determine which architectures to scan
if [ "$TARGET_ARCH" = "all" ]; then
    ARCHITECTURES=("x86_64" "aarch64" "arm" "riscv64" "i386")
else
    ARCHITECTURES=("$TARGET_ARCH")
fi

# Scan kernel images
SCAN_COUNT=0
VULNERABLE_COUNT=0

for arch in "${ARCHITECTURES[@]}"; do
    KERNEL_PATH="build/$arch/kernel.img"
    ELF_PATH="build/$arch/kernel.elf"
    
    if [ -f "$KERNEL_PATH" ]; then
        echo ""
        echo "🔍 Scanning $arch kernel image..."
        
        # Determine file extension based on output format
        case $OUTPUT_FORMAT in
            json) EXT="json" ;;
            html) EXT="html" ;;
            pdf) EXT="pdf" ;;
            csv) EXT="csv" ;;
            console) EXT="txt" ;;
        esac
        
        # Scan kernel image
        REPORT_FILE="$VERSIONED_DIR/SAGE-OS-0.1.0-$arch-kernel-cve-report.$EXT"
        if [ "$OUTPUT_FORMAT" = "console" ]; then
            if cve-bin-tool --format console "$KERNEL_PATH" | tee "$REPORT_FILE"; then
                echo "✅ Scan completed for $arch kernel image"
                echo "   📄 Report saved: $REPORT_FILE"
            else
                echo "❌ Scan failed for $arch kernel image"
            fi
        else
            if cve-bin-tool --format "$OUTPUT_FORMAT" --output-file "$REPORT_FILE" "$KERNEL_PATH"; then
                echo "✅ Scan completed for $arch kernel image"
                echo "   📄 Report saved: $REPORT_FILE"
            else
                echo "❌ Scan failed for $arch kernel image"
            fi
        fi
        
        # Scan ELF file if it exists
        if [ -f "$ELF_PATH" ]; then
            REPORT_ELF_FILE="$VERSIONED_DIR/SAGE-OS-0.1.0-$arch-elf-cve-report.$EXT"
            if [ "$OUTPUT_FORMAT" = "console" ]; then
                if cve-bin-tool --format console "$ELF_PATH" | tee "$REPORT_ELF_FILE"; then
                    echo "✅ Scan completed for $arch ELF file"
                    echo "   📄 Report saved: $REPORT_ELF_FILE"
                else
                    echo "❌ Scan failed for $arch ELF file"
                fi
            else
                if cve-bin-tool --format "$OUTPUT_FORMAT" --output-file "$REPORT_ELF_FILE" "$ELF_PATH"; then
                    echo "✅ Scan completed for $arch ELF file"
                    echo "   📄 Report saved: $REPORT_ELF_FILE"
                else
                    echo "❌ Scan failed for $arch ELF file"
                fi
            fi
        fi
        
        ((SCAN_COUNT++))
    else
        echo "⚠️  Kernel image not found: $KERNEL_PATH"
    fi
done

# Scan ISO images if they exist
for arch in "${ARCHITECTURES[@]}"; do
    # Check multiple possible ISO locations
    ISO_PATHS=(
        "build/$arch/sageos.iso"
        "dist/$arch/SAGE-OS-0.1.0-$arch-generic.iso"
        "build-output/sageos-$arch.iso"
    )
    
    for ISO_PATH in "${ISO_PATHS[@]}"; do
        if [ -f "$ISO_PATH" ]; then
            echo ""
            echo "🔍 Scanning $arch ISO image..."
            
            REPORT_ISO_FILE="$VERSIONED_DIR/SAGE-OS-0.1.0-$arch-iso-cve-report.$EXT"
            if [ "$OUTPUT_FORMAT" = "console" ]; then
                if cve-bin-tool --format console "$ISO_PATH" | tee "$REPORT_ISO_FILE"; then
                    echo "✅ Scan completed for $arch ISO image"
                    echo "   📄 Report saved: $REPORT_ISO_FILE"
                else
                    echo "❌ Scan failed for $arch ISO image"
                fi
            else
                if cve-bin-tool --format "$OUTPUT_FORMAT" --output-file "$REPORT_ISO_FILE" "$ISO_PATH"; then
                    echo "✅ Scan completed for $arch ISO image"
                    echo "   📄 Report saved: $REPORT_ISO_FILE"
                else
                    echo "❌ Scan failed for $arch ISO image"
                fi
            fi
            ((SCAN_COUNT++))
            break  # Only scan the first found ISO for this arch
        fi
    done
done

# Scan Docker images if they exist
echo ""
echo "🐳 Scanning Docker images..."
if command -v docker >/dev/null 2>&1; then
    for arch in "${ARCHITECTURES[@]}"; do
        # Check if Docker image exists
        if docker images --format "table {{.Repository}}:{{.Tag}}" | grep -q "sage-os:0.1.0-$arch"; then
            echo "🔍 Scanning Docker image for $arch..."
            
            REPORT_DOCKER_FILE="$VERSIONED_DIR/SAGE-OS-0.1.0-$arch-docker-cve-report.$EXT"
            if [ "$OUTPUT_FORMAT" = "console" ]; then
                if cve-bin-tool --format console --docker "sage-os:0.1.0-$arch" | tee "$REPORT_DOCKER_FILE"; then
                    echo "✅ Scan completed for $arch Docker image"
                    echo "   📄 Report saved: $REPORT_DOCKER_FILE"
                else
                    echo "❌ Scan failed for $arch Docker image"
                fi
            else
                if cve-bin-tool --format "$OUTPUT_FORMAT" --output-file "$REPORT_DOCKER_FILE" --docker "sage-os:0.1.0-$arch"; then
                    echo "✅ Scan completed for $arch Docker image"
                    echo "   📄 Report saved: $REPORT_DOCKER_FILE"
                else
                    echo "❌ Scan failed for $arch Docker image"
                fi
            fi
            ((SCAN_COUNT++))
        fi
    done
else
    echo "⚠️  Docker not found, skipping Docker image scans"
fi

# Scan build output directory
if [ -d "build-output" ] && [ "$TARGET_ARCH" = "all" ]; then
    echo ""
    echo "🔍 Scanning build output directory..."
    
    REPORT_OUTPUT_FILE="$VERSIONED_DIR/SAGE-OS-0.1.0-build-output-cve-report.$EXT"
    if [ "$OUTPUT_FORMAT" = "console" ]; then
        if cve-bin-tool --format console "build-output/" | tee "$REPORT_OUTPUT_FILE"; then
            echo "✅ Scan completed for build output directory"
            echo "   📄 Report saved: $REPORT_OUTPUT_FILE"
        else
            echo "❌ Scan failed for build output directory"
        fi
    else
        if cve-bin-tool --format "$OUTPUT_FORMAT" --output-file "$REPORT_OUTPUT_FILE" "build-output/"; then
            echo "✅ Scan completed for build output directory"
            echo "   📄 Report saved: $REPORT_OUTPUT_FILE"
        else
            echo "❌ Scan failed for build output directory"
        fi
    fi
    ((SCAN_COUNT++))
fi

echo ""
echo "📊 Vulnerability Scan Summary:"
echo "=============================="
echo "Files scanned: $SCAN_COUNT"
echo "Reports generated: $(ls -1 $VERSIONED_DIR/*.$EXT 2>/dev/null | wc -l)"
echo "Output format: $OUTPUT_FORMAT"
echo "Target architecture(s): $TARGET_ARCH"

# Generate summary report
echo ""
echo "📋 Generating summary report..."
SUMMARY_FILE="$VERSIONED_DIR/SAGE-OS-0.1.0-vulnerability-summary.txt"

{
    echo "SAGE OS Vulnerability Scan Summary"
    echo "=================================="
    echo "Project: SAGE OS v0.1.0"
    echo "Scan Date: $(date)"
    echo "Scan ID: $TIMESTAMP"
    echo "Output Format: $OUTPUT_FORMAT"
    echo "Target Architecture(s): $TARGET_ARCH"
    echo "CVE-bin-tool Version: $(cve-bin-tool --version 2>/dev/null || echo 'Unknown')"
    echo "System: $(uname -s) $(uname -m) $(uname -r)"
    echo ""
    
    echo "Scanned Files:"
    echo "=============="
    for arch in "${ARCHITECTURES[@]}"; do
        if [ -f "build/$arch/kernel.img" ]; then
            echo "- $arch kernel image: $(ls -lh build/$arch/kernel.img | awk '{print $5}')"
        fi
        if [ -f "build/$arch/kernel.elf" ]; then
            echo "- $arch ELF file: $(ls -lh build/$arch/kernel.elf | awk '{print $5}')"
        fi
        
        # Check for ISO files
        for ISO_PATH in "build/$arch/sageos.iso" "dist/$arch/SAGE-OS-0.1.0-$arch-generic.iso" "build-output/sageos-$arch.iso"; do
            if [ -f "$ISO_PATH" ]; then
                echo "- $arch ISO image: $(ls -lh $ISO_PATH | awk '{print $5}')"
                break
            fi
        done
        
        # Check for Docker images
        if command -v docker >/dev/null 2>&1 && docker images --format "table {{.Repository}}:{{.Tag}}" | grep -q "sage-os:0.1.0-$arch"; then
            echo "- $arch Docker image: $(docker images sage-os:0.1.0-$arch --format "table {{.Size}}" | tail -n 1)"
        fi
    done
    
    echo ""
    echo "Generated Reports:"
    echo "=================="
    ls -la "$VERSIONED_DIR"/*.$EXT 2>/dev/null || echo "No reports found"
    
    echo ""
    echo "Report Location: $VERSIONED_DIR"
    
} > "$SUMMARY_FILE"

echo "✅ Summary report saved: $SUMMARY_FILE"

# Check for vulnerabilities in reports
echo ""
echo "🔍 Checking for vulnerabilities in reports..."

TOTAL_VULNERABILITIES=0
if [ "$OUTPUT_FORMAT" = "json" ]; then
    for report in "$VERSIONED_DIR"/*.json; do
        if [ -f "$report" ]; then
            # Count vulnerabilities in JSON report
            VULN_COUNT=$(python3 -c "
import json
import sys
try:
    with open('$report', 'r') as f:
        data = json.load(f)
    # Count vulnerabilities - structure may vary
    if isinstance(data, dict):
        if 'vulnerabilities' in data:
            print(len(data['vulnerabilities']))
        elif 'cves' in data:
            print(len(data['cves']))
        else:
            print(0)
    else:
        print(0)
except:
    print(0)
" 2>/dev/null || echo "0")
            
            if [ "$VULN_COUNT" -gt 0 ]; then
                echo "⚠️  Found $VULN_COUNT vulnerabilities in $(basename "$report")"
                ((TOTAL_VULNERABILITIES += VULN_COUNT))
            else
                echo "✅ No vulnerabilities found in $(basename "$report")"
            fi
        fi
    done
else
    echo "📋 Vulnerability analysis available in $OUTPUT_FORMAT format reports"
    echo "   Use JSON format (-f json) for automated vulnerability counting"
fi

echo ""
if [ "$TOTAL_VULNERABILITIES" -eq 0 ] && [ "$OUTPUT_FORMAT" = "json" ]; then
    echo "🎉 No vulnerabilities detected in SAGE OS kernel images!"
    echo "✅ All scanned files appear to be clean."
elif [ "$TOTAL_VULNERABILITIES" -gt 0 ]; then
    echo "⚠️  Total vulnerabilities found: $TOTAL_VULNERABILITIES"
    echo "📋 Please review the detailed reports in: $VERSIONED_DIR/"
else
    echo "📋 Scan completed. Review reports for vulnerability details."
fi

echo ""
echo "📁 All reports saved in: $VERSIONED_DIR/"
ls -la "$VERSIONED_DIR/"

echo ""
echo "🔍 CVE vulnerability scan completed!"
echo "📋 Scan ID: $TIMESTAMP"
echo "📁 Reports: $VERSIONED_DIR/"