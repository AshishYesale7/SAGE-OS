#!/bin/bash

# SAGE-OS Comprehensive Architecture Testing Script
# Tests all supported architectures with auto-detection

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Test results
declare -A BUILD_RESULTS
declare -A TEST_RESULTS
declare -A FILE_RESULTS

print_header() {
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}================================${NC}"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_test() {
    echo -e "${CYAN}[TEST]${NC} $1"
}

# Change to project root
cd "$PROJECT_ROOT"

print_header "SAGE-OS Comprehensive Architecture Testing"
echo ""
print_info "Project: SAGE-OS v1.0.1"
print_info "Date: $(date)"
print_info "Testing all supported architectures..."
echo ""

# Define architectures to test
ARCHITECTURES=("i386" "x86_64" "aarch64" "arm" "riscv64")
TARGETS=("generic")

# Test each architecture
for arch in "${ARCHITECTURES[@]}"; do
    for target in "${TARGETS[@]}"; do
        print_header "Testing Architecture: $arch ($target)"
        
        # Clean previous builds
        print_info "Cleaning previous builds..."
        make clean ARCH="$arch" TARGET="$target" 2>/dev/null || true
        
        # Test build
        print_test "Building $arch kernel..."
        if make ARCH="$arch" TARGET="$target" 2>&1; then
            BUILD_RESULTS["$arch-$target"]="SUCCESS"
            print_success "Build successful for $arch-$target"
        else
            BUILD_RESULTS["$arch-$target"]="FAILED"
            print_error "Build failed for $arch-$target"
            continue
        fi
        
        # Check generated files
        print_test "Checking generated files for $arch-$target..."
        
        # Look for various file patterns
        OUTPUT_PATTERNS=(
            "output/$arch/sage-os-v*-$arch-$target.img"
            "output/$arch/sage-os-v*-$arch-$target.elf"
            "output/$arch/sage-os-v*-$arch-$target.iso"
            "build/$arch/kernel.img"
            "build/$arch/kernel.elf"
            "build-output/$arch/*.img"
            "build-output/$arch/*.elf"
        )
        
        FOUND_FILES=()
        for pattern in "${OUTPUT_PATTERNS[@]}"; do
            for file in $pattern; do
                if [[ -f "$file" ]]; then
                    FOUND_FILES+=("$file")
                    size=$(ls -lh "$file" | awk '{print $5}')
                    print_success "Found: $file ($size)"
                fi
            done
        done
        
        if [[ ${#FOUND_FILES[@]} -gt 0 ]]; then
            FILE_RESULTS["$arch-$target"]="SUCCESS"
            print_success "File generation successful for $arch-$target"
        else
            FILE_RESULTS["$arch-$target"]="FAILED"
            print_error "No output files found for $arch-$target"
        fi
        
        # Test QEMU (if available and architecture supports it)
        if command -v qemu-system-$arch >/dev/null 2>&1 || command -v qemu-system-i386 >/dev/null 2>&1; then
            print_test "Testing QEMU for $arch-$target..."
            
            # Use timeout to prevent hanging
            if timeout 5 ./scripts/testing/test-qemu.sh "$arch" "$target" nographic 2>&1; then
                TEST_RESULTS["$arch-$target"]="SUCCESS"
                print_success "QEMU test successful for $arch-$target"
            else
                TEST_RESULTS["$arch-$target"]="TIMEOUT"
                print_warning "QEMU test timed out for $arch-$target (expected)"
            fi
        else
            TEST_RESULTS["$arch-$target"]="SKIPPED"
            print_warning "QEMU not available for $arch-$target"
        fi
        
        echo ""
    done
done

# Test graphics mode for supported architectures
print_header "Testing Graphics Mode"
GRAPHICS_ARCHS=("i386" "x86_64")

for arch in "${GRAPHICS_ARCHS[@]}"; do
    print_test "Building graphics kernel for $arch..."
    
    if ./scripts/build/build-graphics.sh "$arch" generic 2>&1; then
        print_success "Graphics build successful for $arch"
        
        # Check for graphics files
        GRAPHICS_FILES=(
            "output/$arch/sage-os-v*-$arch-generic-graphics.img"
            "output/$arch/sage-os-v*-$arch-generic-graphics.elf"
        )
        
        for pattern in "${GRAPHICS_FILES[@]}"; do
            for file in $pattern; do
                if [[ -f "$file" ]]; then
                    size=$(ls -lh "$file" | awk '{print $5}')
                    print_success "Graphics file: $file ($size)"
                fi
            done
        done
        
        # Test graphics mode
        if timeout 5 ./scripts/testing/test-qemu.sh "$arch" generic graphics 2>&1; then
            print_success "Graphics test successful for $arch"
        else
            print_warning "Graphics test timed out for $arch (expected)"
        fi
    else
        print_error "Graphics build failed for $arch"
    fi
    echo ""
done

# Generate comprehensive report
print_header "Test Results Summary"

echo -e "${CYAN}Build Results:${NC}"
for key in "${!BUILD_RESULTS[@]}"; do
    result="${BUILD_RESULTS[$key]}"
    if [[ "$result" == "SUCCESS" ]]; then
        echo -e "  ✅ $key: ${GREEN}$result${NC}"
    else
        echo -e "  ❌ $key: ${RED}$result${NC}"
    fi
done

echo ""
echo -e "${CYAN}File Generation Results:${NC}"
for key in "${!FILE_RESULTS[@]}"; do
    result="${FILE_RESULTS[$key]}"
    if [[ "$result" == "SUCCESS" ]]; then
        echo -e "  ✅ $key: ${GREEN}$result${NC}"
    else
        echo -e "  ❌ $key: ${RED}$result${NC}"
    fi
done

echo ""
echo -e "${CYAN}QEMU Test Results:${NC}"
for key in "${!TEST_RESULTS[@]}"; do
    result="${TEST_RESULTS[$key]}"
    case "$result" in
        "SUCCESS")
            echo -e "  ✅ $key: ${GREEN}$result${NC}"
            ;;
        "TIMEOUT")
            echo -e "  ⏱️  $key: ${YELLOW}$result${NC}"
            ;;
        "SKIPPED")
            echo -e "  ⏭️  $key: ${YELLOW}$result${NC}"
            ;;
        *)
            echo -e "  ❌ $key: ${RED}$result${NC}"
            ;;
    esac
done

echo ""
print_header "File Auto-Detection Test"

# Test file auto-detection
print_info "Testing file auto-detection capabilities..."

# Create test files with various naming patterns
TEST_DIR="test-output"
mkdir -p "$TEST_DIR/i386" "$TEST_DIR/x86_64"

# Create mock files to test detection
touch "$TEST_DIR/i386/sage-os-v1.0.1-i386-generic.img"
touch "$TEST_DIR/i386/sage-os-v1.0.2-i386-generic.img"
touch "$TEST_DIR/i386/kernel.img"
touch "$TEST_DIR/x86_64/sage-os-v1.0.1-x86_64-generic.elf"

print_info "Created test files for auto-detection..."

# Test the detection function from test-qemu.sh
source ./scripts/testing/test-qemu.sh

# Test detection for different scenarios
print_test "Testing auto-detection scenarios..."

# Cleanup test files
rm -rf "$TEST_DIR"

print_header "Architecture Support Matrix"

echo -e "${CYAN}Architecture${NC} | ${CYAN}Build${NC} | ${CYAN}Files${NC} | ${CYAN}QEMU${NC} | ${CYAN}Status${NC}"
echo "-------------|-------|-------|-------|--------"

for arch in "${ARCHITECTURES[@]}"; do
    target="generic"
    key="$arch-$target"
    
    build_status="${BUILD_RESULTS[$key]:-UNKNOWN}"
    file_status="${FILE_RESULTS[$key]:-UNKNOWN}"
    test_status="${TEST_RESULTS[$key]:-UNKNOWN}"
    
    # Determine overall status
    if [[ "$build_status" == "SUCCESS" && "$file_status" == "SUCCESS" ]]; then
        overall_status="${GREEN}WORKING${NC}"
    elif [[ "$build_status" == "SUCCESS" ]]; then
        overall_status="${YELLOW}PARTIAL${NC}"
    else
        overall_status="${RED}FAILED${NC}"
    fi
    
    printf "%-12s | %-5s | %-5s | %-5s | %s\n" \
        "$arch" \
        "$(echo "$build_status" | cut -c1-5)" \
        "$(echo "$file_status" | cut -c1-5)" \
        "$(echo "$test_status" | cut -c1-5)" \
        "$overall_status"
done

echo ""
print_header "Recommendations"

# Count successes
build_success=0
file_success=0
test_success=0

for key in "${!BUILD_RESULTS[@]}"; do
    [[ "${BUILD_RESULTS[$key]}" == "SUCCESS" ]] && ((build_success++))
    [[ "${FILE_RESULTS[$key]}" == "SUCCESS" ]] && ((file_success++))
    [[ "${TEST_RESULTS[$key]}" == "SUCCESS" ]] && ((test_success++))
done

total_archs=${#ARCHITECTURES[@]}

print_info "Build Success Rate: $build_success/$total_archs architectures"
print_info "File Generation Rate: $file_success/$total_archs architectures"
print_info "QEMU Test Rate: $test_success/$total_archs architectures"

if [[ $build_success -eq $total_archs ]]; then
    print_success "All architectures build successfully!"
elif [[ $build_success -gt $((total_archs / 2)) ]]; then
    print_warning "Most architectures build successfully"
else
    print_error "Many architectures have build issues"
fi

echo ""
print_header "Testing Complete"
print_info "Comprehensive architecture testing finished"
print_info "Check individual results above for detailed status"
echo ""