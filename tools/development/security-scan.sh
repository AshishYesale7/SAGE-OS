#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS Security Scanning Script
# This script performs comprehensive security scanning using multiple tools

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SECURITY_DIR="$PROJECT_ROOT/security"
REPORTS_DIR="$SECURITY_DIR/reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Create security directories
setup_directories() {
    log "Setting up security directories..."
    mkdir -p "$SECURITY_DIR"
    mkdir -p "$REPORTS_DIR"
    mkdir -p "$SECURITY_DIR/templates"
    mkdir -p "$SECURITY_DIR/configs"
}

# Install security tools
install_tools() {
    log "Installing security scanning tools..."
    
    # Install cve-bin-tool
    if ! command -v cve-bin-tool &> /dev/null; then
        log "Installing cve-bin-tool..."
        pip3 install --user cve-bin-tool
    else
        log "cve-bin-tool already installed"
    fi
    
    # Install other security tools
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y \
            clang-tools \
            cppcheck \
            valgrind \
            binutils \
            file \
            strings \
            objdump \
            readelf \
            nm \
            ldd || warning "Some tools failed to install"
    fi
}

# Update CVE database
update_cve_database() {
    log "Updating CVE database..."
    if command -v cve-bin-tool &> /dev/null; then
        cve-bin-tool --update || warning "CVE database update failed"
    else
        warning "cve-bin-tool not found, skipping database update"
    fi
}

# Scan for CVEs in binaries
scan_cve_binaries() {
    log "Scanning binaries for CVEs..."
    
    local output_file="$REPORTS_DIR/cve-binary-scan-$TIMESTAMP.json"
    local html_file="$REPORTS_DIR/cve-binary-scan-$TIMESTAMP.html"
    
    if command -v cve-bin-tool &> /dev/null; then
        # Scan build artifacts
        if [ -d "$PROJECT_ROOT/build" ]; then
            log "Scanning build directory..."
            cve-bin-tool \
                --config "$PROJECT_ROOT/.cve-bin-tool.toml" \
                --format json \
                --output-file "$output_file" \
                "$PROJECT_ROOT/build" || warning "CVE binary scan failed"
        fi
        
        # Scan distribution artifacts
        if [ -d "$PROJECT_ROOT/dist" ]; then
            log "Scanning dist directory..."
            cve-bin-tool \
                --config "$PROJECT_ROOT/.cve-bin-tool.toml" \
                --format html \
                --output-file "$html_file" \
                "$PROJECT_ROOT/dist" || warning "CVE dist scan failed"
        fi
        
        success "CVE binary scan completed"
    else
        error "cve-bin-tool not available"
        return 1
    fi
}

# Static code analysis
static_analysis() {
    log "Running static code analysis..."
    
    local report_file="$REPORTS_DIR/static-analysis-$TIMESTAMP.txt"
    
    {
        echo "SAGE OS Static Code Analysis Report"
        echo "Generated: $(date)"
        echo "======================================="
        echo
        
        # Cppcheck analysis
        if command -v cppcheck &> /dev/null; then
            echo "=== CPPCHECK ANALYSIS ==="
            cppcheck \
                --enable=all \
                --inconclusive \
                --xml \
                --xml-version=2 \
                "$PROJECT_ROOT/kernel" \
                "$PROJECT_ROOT/boot" \
                "$PROJECT_ROOT/drivers" 2>&1 || true
            echo
        fi
        
        # Clang static analyzer
        if command -v scan-build &> /dev/null; then
            echo "=== CLANG STATIC ANALYZER ==="
            cd "$PROJECT_ROOT"
            scan-build make clean || true
            scan-build make ARCH=x86_64 || true
            echo
        fi
        
        # Find potential security issues
        echo "=== SECURITY PATTERN ANALYSIS ==="
        echo "Searching for potentially unsafe functions..."
        
        # Unsafe C functions
        grep -r -n \
            -E "(strcpy|strcat|sprintf|gets|scanf|strncpy|strncat)" \
            "$PROJECT_ROOT/kernel" \
            "$PROJECT_ROOT/boot" \
            "$PROJECT_ROOT/drivers" 2>/dev/null || true
        
        echo
        echo "Searching for hardcoded credentials..."
        grep -r -n -i \
            -E "(password|passwd|secret|key|token)" \
            "$PROJECT_ROOT" \
            --exclude-dir=.git \
            --exclude-dir=docs \
            --exclude-dir=security \
            --exclude="*.md" 2>/dev/null || true
        
    } > "$report_file"
    
    success "Static analysis completed: $report_file"
}

# Binary analysis
binary_analysis() {
    log "Running binary analysis..."
    
    local report_file="$REPORTS_DIR/binary-analysis-$TIMESTAMP.txt"
    
    {
        echo "SAGE OS Binary Analysis Report"
        echo "Generated: $(date)"
        echo "=============================="
        echo
        
        # Find all binaries
        find "$PROJECT_ROOT" -type f \
            \( -name "*.bin" -o -name "*.elf" -o -name "*.img" -o -name "*.iso" \) \
            -not -path "*/.git/*" \
            -not -path "*/docs/*" | while read -r binary; do
            
            echo "=== ANALYZING: $binary ==="
            
            # File type
            echo "File type:"
            file "$binary" 2>/dev/null || true
            echo
            
            # Security features (if ELF)
            if file "$binary" | grep -q "ELF"; then
                echo "Security features:"
                
                # Check for stack canaries
                if readelf -s "$binary" 2>/dev/null | grep -q "__stack_chk_fail"; then
                    echo "  ✓ Stack canaries: ENABLED"
                else
                    echo "  ✗ Stack canaries: DISABLED"
                fi
                
                # Check for NX bit
                if readelf -l "$binary" 2>/dev/null | grep -q "GNU_STACK.*RWE"; then
                    echo "  ✗ NX bit: DISABLED (executable stack)"
                else
                    echo "  ✓ NX bit: ENABLED"
                fi
                
                # Check for PIE
                if readelf -h "$binary" 2>/dev/null | grep -q "Type:.*DYN"; then
                    echo "  ✓ PIE: ENABLED"
                else
                    echo "  ✗ PIE: DISABLED"
                fi
                
                # Check for RELRO
                if readelf -l "$binary" 2>/dev/null | grep -q "GNU_RELRO"; then
                    echo "  ✓ RELRO: ENABLED"
                else
                    echo "  ✗ RELRO: DISABLED"
                fi
                
                echo
                
                # Symbols
                echo "Exported symbols:"
                nm -D "$binary" 2>/dev/null | head -20 || true
                echo
                
                # Strings analysis
                echo "Interesting strings:"
                strings "$binary" | grep -E "(password|secret|key|debug|test)" | head -10 || true
                echo
            fi
            
            echo "----------------------------------------"
            echo
        done
        
    } > "$report_file"
    
    success "Binary analysis completed: $report_file"
}

# Dependency analysis
dependency_analysis() {
    log "Running dependency analysis..."
    
    local report_file="$REPORTS_DIR/dependency-analysis-$TIMESTAMP.txt"
    
    {
        echo "SAGE OS Dependency Analysis Report"
        echo "Generated: $(date)"
        echo "=================================="
        echo
        
        # Analyze Makefile dependencies
        echo "=== MAKEFILE DEPENDENCIES ==="
        if [ -f "$PROJECT_ROOT/Makefile" ]; then
            grep -E "^[A-Z_]+\s*=" "$PROJECT_ROOT/Makefile" | head -20
        fi
        echo
        
        # Find all shared libraries
        echo "=== SHARED LIBRARY DEPENDENCIES ==="
        find "$PROJECT_ROOT" -name "*.so*" -type f | while read -r lib; do
            echo "Library: $lib"
            ldd "$lib" 2>/dev/null || true
            echo
        done
        
        # Check for embedded libraries
        echo "=== EMBEDDED LIBRARIES ==="
        find "$PROJECT_ROOT" -type f -name "*.c" -o -name "*.h" | \
        xargs grep -l "Copyright.*[0-9][0-9][0-9][0-9]" | \
        head -10 || true
        
    } > "$report_file"
    
    success "Dependency analysis completed: $report_file"
}

# Generate security summary
generate_summary() {
    log "Generating security summary..."
    
    local summary_file="$REPORTS_DIR/security-summary-$TIMESTAMP.md"
    
    {
        echo "# SAGE OS Security Scan Summary"
        echo
        echo "**Generated:** $(date)"
        echo "**Scan ID:** $TIMESTAMP"
        echo
        
        echo "## Scan Results"
        echo
        
        # Count reports
        local cve_reports=$(find "$REPORTS_DIR" -name "cve-*-$TIMESTAMP.*" | wc -l)
        local static_reports=$(find "$REPORTS_DIR" -name "static-*-$TIMESTAMP.*" | wc -l)
        local binary_reports=$(find "$REPORTS_DIR" -name "binary-*-$TIMESTAMP.*" | wc -l)
        local dep_reports=$(find "$REPORTS_DIR" -name "dependency-*-$TIMESTAMP.*" | wc -l)
        
        echo "- CVE Scans: $cve_reports"
        echo "- Static Analysis: $static_reports"
        echo "- Binary Analysis: $binary_reports"
        echo "- Dependency Analysis: $dep_reports"
        echo
        
        echo "## Report Files"
        echo
        find "$REPORTS_DIR" -name "*-$TIMESTAMP.*" | while read -r report; do
            echo "- [$(basename "$report")]($report)"
        done
        echo
        
        echo "## Recommendations"
        echo
        echo "1. Review all CVE scan results for critical and high severity vulnerabilities"
        echo "2. Address any unsafe function usage identified in static analysis"
        echo "3. Enable security features (stack canaries, NX bit, PIE, RELRO) for all binaries"
        echo "4. Regularly update dependencies and monitor for new vulnerabilities"
        echo "5. Implement automated security scanning in CI/CD pipeline"
        echo
        
        echo "## Next Steps"
        echo
        echo "1. Prioritize fixing critical and high severity issues"
        echo "2. Implement security hardening measures"
        echo "3. Set up continuous security monitoring"
        echo "4. Create incident response procedures"
        echo
        
    } > "$summary_file"
    
    success "Security summary generated: $summary_file"
}

# Main execution
main() {
    log "Starting SAGE OS security scan..."
    
    # Setup
    setup_directories
    
    # Install tools if needed
    if [[ "${INSTALL_TOOLS:-false}" == "true" ]]; then
        install_tools
    fi
    
    # Update CVE database
    update_cve_database
    
    # Run scans
    scan_cve_binaries
    static_analysis
    binary_analysis
    dependency_analysis
    
    # Generate summary
    generate_summary
    
    success "Security scan completed successfully!"
    log "Reports available in: $REPORTS_DIR"
}

# Handle command line arguments
case "${1:-all}" in
    "cve")
        setup_directories
        update_cve_database
        scan_cve_binaries
        ;;
    "static")
        setup_directories
        static_analysis
        ;;
    "binary")
        setup_directories
        binary_analysis
        ;;
    "deps")
        setup_directories
        dependency_analysis
        ;;
    "install")
        install_tools
        ;;
    "all"|*)
        main
        ;;
esac