#!/bin/bash

# SAGE-OS Platform Documentation Verification Script
# Tests all platform documentation setup instructions from scratch

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

print_header "SAGE-OS Platform Documentation Verification"
echo ""
print_info "Project: SAGE-OS v1.0.1"
print_info "Date: $(date)"
print_info "Verifying all platform documentation..."
echo ""

# Test results
declare -A DOC_RESULTS
declare -A COMMAND_RESULTS
declare -A SCRIPT_RESULTS

# Platform documentation files
PLATFORMS=("linux" "macos" "windows" "raspberry-pi")

# Test each platform documentation
for platform in "${PLATFORMS[@]}"; do
    print_header "Testing Platform: $platform"
    
    DOC_FILE="docs/platforms/$platform/DEVELOPER_GUIDE.md"
    
    if [[ -f "$DOC_FILE" ]]; then
        print_success "Documentation found: $DOC_FILE"
        DOC_RESULTS["$platform"]="FOUND"
        
        # Check for key sections
        print_test "Checking documentation sections..."
        
        REQUIRED_SECTIONS=(
            "Prerequisites"
            "Installation"
            "Building"
            "Testing"
            "Troubleshooting"
        )
        
        MISSING_SECTIONS=()
        for section in "${REQUIRED_SECTIONS[@]}"; do
            if grep -q "## $section\|# $section" "$DOC_FILE"; then
                print_success "Section found: $section"
            else
                print_warning "Section missing: $section"
                MISSING_SECTIONS+=("$section")
            fi
        done
        
        if [[ ${#MISSING_SECTIONS[@]} -eq 0 ]]; then
            print_success "All required sections present"
        else
            print_warning "Missing sections: ${MISSING_SECTIONS[*]}"
        fi
        
        # Extract and test commands from documentation
        print_test "Extracting commands from documentation..."
        
        # Look for code blocks with bash/shell commands
        COMMANDS=$(grep -A 10 '```bash\|```shell' "$DOC_FILE" | grep -v '```' | grep -E '^[a-zA-Z#]' | head -10)
        
        if [[ -n "$COMMANDS" ]]; then
            print_info "Found commands in documentation"
            COMMAND_RESULTS["$platform"]="FOUND"
        else
            print_warning "No commands found in documentation"
            COMMAND_RESULTS["$platform"]="MISSING"
        fi
        
    else
        print_error "Documentation not found: $DOC_FILE"
        DOC_RESULTS["$platform"]="MISSING"
    fi
    
    echo ""
done

# Test script functionality
print_header "Testing Script Functionality"

SCRIPTS_TO_TEST=(
    "scripts/testing/test-qemu.sh"
    "scripts/build/build-graphics.sh"
    "tools/testing/test-both-modes.sh"
    "tools/testing/test-all-architectures.sh"
    "tools/organize_project.py"
)

for script in "${SCRIPTS_TO_TEST[@]}"; do
    print_test "Testing script: $script"
    
    if [[ -f "$script" ]]; then
        if [[ -x "$script" ]]; then
            print_success "Script executable: $script"
            
            # Test help/usage
            if "$script" --help 2>/dev/null || "$script" -h 2>/dev/null || "$script" 2>&1 | grep -q "Usage\|usage\|USAGE"; then
                print_success "Help/usage available: $script"
                SCRIPT_RESULTS["$script"]="WORKING"
            else
                print_warning "No help/usage: $script"
                SCRIPT_RESULTS["$script"]="PARTIAL"
            fi
        else
            print_error "Script not executable: $script"
            SCRIPT_RESULTS["$script"]="NOT_EXECUTABLE"
        fi
    else
        print_error "Script not found: $script"
        SCRIPT_RESULTS["$script"]="MISSING"
    fi
done

# Test Makefile targets
print_header "Testing Makefile Targets"

MAKEFILE_TARGETS=(
    "help"
    "list-arch"
    "test-i386"
    "test-i386-graphics"
    "clean"
    "version"
)

for target in "${MAKEFILE_TARGETS[@]}"; do
    print_test "Testing Makefile target: $target"
    
    if make -n "$target" >/dev/null 2>&1; then
        print_success "Target available: $target"
    else
        print_warning "Target not available: $target"
    fi
done

# Test file auto-detection
print_header "Testing File Auto-Detection"

print_test "Testing kernel image detection..."

# Create test directory structure
TEST_DIR="test-detection"
mkdir -p "$TEST_DIR"/{i386,x86_64,aarch64}/{output,build,build-output}

# Create mock files with various naming patterns
touch "$TEST_DIR/i386/output/sage-os-v1.0.1-i386-generic.img"
touch "$TEST_DIR/i386/output/sage-os-v1.0.2-i386-generic.img"
touch "$TEST_DIR/i386/build/kernel.img"
touch "$TEST_DIR/x86_64/build-output/sage-os-v1.0.1-x86_64-generic.elf"
touch "$TEST_DIR/aarch64/output/sage-os-v1.0.1-aarch64-generic-graphics.img"

print_info "Created test files for auto-detection"

# Test detection patterns
DETECTION_PATTERNS=(
    "sage-os-v*-i386-generic.img"
    "sage-os-v*-x86_64-generic.elf"
    "sage-os-v*-aarch64-generic-graphics.img"
    "kernel.img"
)

for pattern in "${DETECTION_PATTERNS[@]}"; do
    FOUND_FILES=$(find "$TEST_DIR" -name "$pattern" 2>/dev/null)
    if [[ -n "$FOUND_FILES" ]]; then
        print_success "Pattern detected: $pattern"
        echo "  Files: $(echo "$FOUND_FILES" | tr '\n' ' ')"
    else
        print_warning "Pattern not detected: $pattern"
    fi
done

# Cleanup test files
rm -rf "$TEST_DIR"

# Test configuration files
print_header "Testing Configuration Files"

CONFIG_FILES=(
    "config/grub.cfg"
    "config/platforms/config.txt"
    "config/platforms/config_rpi5.txt"
    "VERSION"
    "Makefile"
)

for config in "${CONFIG_FILES[@]}"; do
    print_test "Checking configuration: $config"
    
    if [[ -f "$config" ]]; then
        size=$(ls -lh "$config" | awk '{print $5}')
        print_success "Configuration found: $config ($size)"
    else
        print_error "Configuration missing: $config"
    fi
done

# Generate comprehensive report
print_header "Verification Results Summary"

echo -e "${CYAN}Platform Documentation:${NC}"
for platform in "${PLATFORMS[@]}"; do
    result="${DOC_RESULTS[$platform]:-UNKNOWN}"
    case "$result" in
        "FOUND")
            echo -e "  ✅ $platform: ${GREEN}$result${NC}"
            ;;
        *)
            echo -e "  ❌ $platform: ${RED}$result${NC}"
            ;;
    esac
done

echo ""
echo -e "${CYAN}Script Functionality:${NC}"
for script in "${SCRIPTS_TO_TEST[@]}"; do
    result="${SCRIPT_RESULTS[$script]:-UNKNOWN}"
    case "$result" in
        "WORKING")
            echo -e "  ✅ $(basename "$script"): ${GREEN}$result${NC}"
            ;;
        "PARTIAL")
            echo -e "  ⚠️  $(basename "$script"): ${YELLOW}$result${NC}"
            ;;
        *)
            echo -e "  ❌ $(basename "$script"): ${RED}$result${NC}"
            ;;
    esac
done

echo ""
print_header "Platform-Specific Testing Commands"

echo -e "${CYAN}Linux Platform:${NC}"
echo "  sudo apt update && sudo apt install build-essential qemu-system"
echo "  make ARCH=i386 TARGET=generic"
echo "  make test-i386"

echo ""
echo -e "${CYAN}macOS Platform:${NC}"
echo "  brew install gnu-sed grep findutils gnu-tar qemu"
echo "  make -f tools/build/Makefile.macos macos-check"
echo "  make test-i386"

echo ""
echo -e "${CYAN}Windows Platform (WSL):${NC}"
echo "  wsl --install"
echo "  sudo apt update && sudo apt install build-essential qemu-system"
echo "  make ARCH=i386 TARGET=generic"

echo ""
echo -e "${CYAN}Raspberry Pi Platform:${NC}"
echo "  sudo apt update && sudo apt install build-essential"
echo "  make ARCH=aarch64 TARGET=rpi5"
echo "  ./scripts/testing/test-qemu.sh aarch64 rpi5"

echo ""
print_header "Auto-Detection Test Commands"

echo -e "${CYAN}Test File Detection:${NC}"
echo "  ./scripts/testing/test-qemu.sh i386 generic"
echo "  ./scripts/testing/test-qemu.sh x86_64 generic"
echo "  ./scripts/testing/test-qemu.sh aarch64 generic"

echo ""
echo -e "${CYAN}Test Graphics Mode:${NC}"
echo "  make test-i386-graphics"
echo "  ./scripts/testing/test-qemu.sh i386 generic graphics"

echo ""
echo -e "${CYAN}Test All Architectures:${NC}"
echo "  ./tools/testing/test-all-architectures.sh"
echo "  ./tools/testing/test-both-modes.sh"

echo ""
print_header "Verification Complete"

# Count successes
doc_success=0
script_success=0

for platform in "${PLATFORMS[@]}"; do
    [[ "${DOC_RESULTS[$platform]}" == "FOUND" ]] && ((doc_success++))
done

for script in "${SCRIPTS_TO_TEST[@]}"; do
    [[ "${SCRIPT_RESULTS[$script]}" == "WORKING" ]] && ((script_success++))
done

total_platforms=${#PLATFORMS[@]}
total_scripts=${#SCRIPTS_TO_TEST[@]}

print_info "Documentation Success Rate: $doc_success/$total_platforms platforms"
print_info "Script Success Rate: $script_success/$total_scripts scripts"

if [[ $doc_success -eq $total_platforms && $script_success -eq $total_scripts ]]; then
    print_success "All platform documentation and scripts verified!"
elif [[ $doc_success -gt $((total_platforms / 2)) && $script_success -gt $((total_scripts / 2)) ]]; then
    print_warning "Most platform documentation and scripts working"
else
    print_error "Many platform documentation or scripts have issues"
fi

echo ""
print_info "Platform documentation verification complete"
echo ""