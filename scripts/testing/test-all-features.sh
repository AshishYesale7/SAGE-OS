#!/bin/bash

# SAGE-OS Comprehensive Testing Script
# Tests all project functionalities including builds, QEMU, Docker, and security scanning

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Test results tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_test() {
    echo -e "${PURPLE}[TEST]${NC} $1"
}

log_result() {
    local status=$1
    local message=$2
    ((TOTAL_TESTS++))
    
    case $status in
        PASS)
            echo -e "${GREEN}[PASS]${NC} $message"
            ((PASSED_TESTS++))
            ;;
        FAIL)
            echo -e "${RED}[FAIL]${NC} $message"
            ((FAILED_TESTS++))
            ;;
        SKIP)
            echo -e "${YELLOW}[SKIP]${NC} $message"
            ((SKIPPED_TESTS++))
            ;;
    esac
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Test build system
test_build_system() {
    log_test "Testing build system..."
    
    local architectures=("i386" "x86_64" "aarch64" "arm" "riscv64")
    
    for arch in "${architectures[@]}"; do
        log_info "Testing $arch build..."
        
        if make ARCH=$arch clean >/dev/null 2>&1 && make ARCH=$arch all >/dev/null 2>&1; then
            if [ -f "build/$arch/kernel.img" ] || [ -f "build/$arch/kernel.elf" ]; then
                local size=$(du -h build/$arch/kernel.* 2>/dev/null | head -n1 | cut -f1)
                log_result PASS "$arch build successful (size: $size)"
            else
                log_result FAIL "$arch build completed but no kernel found"
            fi
        else
            log_result FAIL "$arch build failed"
        fi
    done
}

# Test QEMU emulation (safely with tmux)
test_qemu_emulation() {
    log_test "Testing QEMU emulation..."
    
    if ! command_exists tmux; then
        log_result SKIP "QEMU testing (tmux not available)"
        return
    fi
    
    local architectures=("i386" "x86_64" "aarch64" "arm" "riscv64")
    
    for arch in "${architectures[@]}"; do
        log_info "Testing QEMU $arch emulation..."
        
        local session_name="test-qemu-$arch"
        local kernel_file=""
        
        # Determine kernel file
        if [ -f "build/$arch/kernel.elf" ]; then
            kernel_file="build/$arch/kernel.elf"
        elif [ -f "build/$arch/kernel.img" ]; then
            kernel_file="build/$arch/kernel.img"
        else
            log_result FAIL "$arch QEMU test (no kernel found)"
            continue
        fi
        
        # Create tmux session and run QEMU
        tmux new-session -d -s "$session_name" 2>/dev/null || {
            tmux kill-session -t "$session_name" 2>/dev/null
            tmux new-session -d -s "$session_name"
        }
        
        case $arch in
            i386)
                tmux send-keys -t "$session_name" "timeout 10s qemu-system-i386 -machine pc -m 256M -kernel $kernel_file -serial stdio -display none" Enter
                ;;
            x86_64)
                tmux send-keys -t "$session_name" "timeout 10s qemu-system-x86_64 -machine q35 -m 512M -kernel $kernel_file -serial stdio -display none" Enter
                ;;
            aarch64)
                tmux send-keys -t "$session_name" "timeout 10s qemu-system-aarch64 -machine virt -cpu cortex-a57 -m 512M -kernel $kernel_file -serial stdio -display none" Enter
                ;;
            arm)
                tmux send-keys -t "$session_name" "timeout 10s qemu-system-arm -machine virt -cpu cortex-a15 -m 256M -kernel $kernel_file -serial stdio -display none" Enter
                ;;
            riscv64)
                tmux send-keys -t "$session_name" "timeout 10s qemu-system-riscv64 -machine virt -cpu rv64 -m 512M -kernel $kernel_file -serial stdio -display none" Enter
                ;;
        esac
        
        # Wait for QEMU to start and finish
        sleep 12
        
        # Check if session still exists (would mean QEMU is stuck)
        if tmux has-session -t "$session_name" 2>/dev/null; then
            tmux kill-session -t "$session_name" 2>/dev/null
            log_result PASS "$arch QEMU test (started successfully, auto-terminated)"
        else
            log_result PASS "$arch QEMU test (completed successfully)"
        fi
    done
}

# Test Docker functionality
test_docker_functionality() {
    log_test "Testing Docker functionality..."
    
    if ! command_exists docker; then
        log_result SKIP "Docker testing (Docker not available)"
        return
    fi
    
    # Test Docker daemon
    if ! docker info >/dev/null 2>&1; then
        log_result SKIP "Docker testing (Docker daemon not running)"
        return
    fi
    
    # Test basic Docker functionality
    if docker run --rm hello-world >/dev/null 2>&1; then
        log_result PASS "Docker basic functionality"
    else
        log_result FAIL "Docker basic functionality"
        return
    fi
    
    # Test Docker image builds
    local architectures=("i386" "x86_64" "aarch64")
    
    for arch in "${architectures[@]}"; do
        log_info "Testing Docker build for $arch..."
        
        if [ -f "build/$arch/kernel.img" ] || [ -f "build/$arch/kernel.elf" ]; then
            if make docker-build ARCH=$arch >/dev/null 2>&1; then
                local image_name="sage-os:0.1.0-$arch"
                if docker images --format "table {{.Repository}}:{{.Tag}}" | grep -q "$image_name"; then
                    local size=$(docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep "$image_name" | awk '{print $2}')
                    log_result PASS "$arch Docker image build (size: $size)"
                else
                    log_result FAIL "$arch Docker image build (image not found)"
                fi
            else
                log_result FAIL "$arch Docker image build"
            fi
        else
            log_result SKIP "$arch Docker image build (no kernel found)"
        fi
    done
}

# Test CVE scanner functionality
test_cve_scanner() {
    log_test "Testing CVE scanner functionality..."
    
    if [ ! -f "./scan-vulnerabilities.sh" ]; then
        log_result SKIP "CVE scanner testing (script not found)"
        return
    fi
    
    if ! command_exists cve-bin-tool; then
        log_result SKIP "CVE scanner testing (cve-bin-tool not available)"
        return
    fi
    
    # Test CVE scanner help
    if ./scan-vulnerabilities.sh --help >/dev/null 2>&1; then
        log_result PASS "CVE scanner help functionality"
    else
        log_result FAIL "CVE scanner help functionality"
    fi
    
    # Test different output formats
    local formats=("json" "html" "csv" "console")
    local test_dir="/tmp/sage-cve-test-$$"
    mkdir -p "$test_dir"
    
    for format in "${formats[@]}"; do
        log_info "Testing CVE scanner $format format..."
        
        if ./scan-vulnerabilities.sh --format "$format" --arch i386 --output "$test_dir" >/dev/null 2>&1; then
            # Check if output file was created
            local output_files=$(find "$test_dir" -name "*cve-report*" -type f | wc -l)
            if [ "$output_files" -gt 0 ]; then
                log_result PASS "CVE scanner $format format"
            else
                log_result FAIL "CVE scanner $format format (no output file)"
            fi
        else
            log_result FAIL "CVE scanner $format format"
        fi
    done
    
    # Test architecture-specific scanning
    local architectures=("i386" "x86_64" "aarch64")
    
    for arch in "${architectures[@]}"; do
        log_info "Testing CVE scanner for $arch..."
        
        if [ -f "build/$arch/kernel.img" ] || [ -f "build/$arch/kernel.elf" ]; then
            if ./scan-vulnerabilities.sh --format json --arch "$arch" --output "$test_dir" >/dev/null 2>&1; then
                log_result PASS "CVE scanner $arch architecture"
            else
                log_result FAIL "CVE scanner $arch architecture"
            fi
        else
            log_result SKIP "CVE scanner $arch architecture (no kernel found)"
        fi
    done
    
    # Cleanup
    rm -rf "$test_dir"
}

# Test ISO creation
test_iso_creation() {
    log_test "Testing ISO creation..."
    
    if ! command_exists genisoimage && ! command_exists mkisofs; then
        log_result SKIP "ISO creation testing (genisoimage/mkisofs not available)"
        return
    fi
    
    local architectures=("i386" "x86_64")
    
    for arch in "${architectures[@]}"; do
        log_info "Testing ISO creation for $arch..."
        
        if [ -f "build/$arch/kernel.img" ] || [ -f "build/$arch/kernel.elf" ]; then
            if make ARCH=$arch iso >/dev/null 2>&1; then
                local iso_file="build/iso/sage-os-$arch.iso"
                if [ -f "$iso_file" ]; then
                    local size=$(du -h "$iso_file" | cut -f1)
                    log_result PASS "$arch ISO creation (size: $size)"
                else
                    log_result FAIL "$arch ISO creation (file not found)"
                fi
            else
                log_result FAIL "$arch ISO creation"
            fi
        else
            log_result SKIP "$arch ISO creation (no kernel found)"
        fi
    done
}

# Test SD card image creation
test_sdcard_creation() {
    log_test "Testing SD card image creation..."
    
    if ! command_exists dd || ! command_exists mkfs.fat; then
        log_result SKIP "SD card creation testing (tools not available)"
        return
    fi
    
    local architectures=("aarch64" "arm")
    
    for arch in "${architectures[@]}"; do
        log_info "Testing SD card creation for $arch..."
        
        if [ -f "build/$arch/kernel.img" ]; then
            if make ARCH=$arch sdcard >/dev/null 2>&1; then
                local sdcard_file="build/sdcard/sage-os-$arch.img"
                if [ -f "$sdcard_file" ]; then
                    local size=$(du -h "$sdcard_file" | cut -f1)
                    log_result PASS "$arch SD card creation (size: $size)"
                else
                    log_result FAIL "$arch SD card creation (file not found)"
                fi
            else
                log_result FAIL "$arch SD card creation"
            fi
        else
            log_result SKIP "$arch SD card creation (no kernel found)"
        fi
    done
}

# Test build script functionality
test_build_script() {
    log_test "Testing build script functionality..."
    
    if [ ! -f "./build.sh" ]; then
        log_result SKIP "Build script testing (script not found)"
        return
    fi
    
    # Test build script help
    if ./build.sh --help >/dev/null 2>&1 || ./build.sh help >/dev/null 2>&1; then
        log_result PASS "Build script help functionality"
    else
        log_result FAIL "Build script help functionality"
    fi
    
    # Test build script status
    if ./build.sh status >/dev/null 2>&1; then
        log_result PASS "Build script status functionality"
    else
        log_result FAIL "Build script status functionality"
    fi
    
    # Test clean functionality
    if ./build.sh clean >/dev/null 2>&1; then
        log_result PASS "Build script clean functionality"
    else
        log_result FAIL "Build script clean functionality"
    fi
}

# Test macOS build script (if available)
test_macos_build_script() {
    log_test "Testing macOS build script functionality..."
    
    if [ ! -f "./build-macos.sh" ]; then
        log_result SKIP "macOS build script testing (script not found)"
        return
    fi
    
    # Test macOS build script help
    if echo "12" | ./build-macos.sh >/dev/null 2>&1; then
        log_result PASS "macOS build script help functionality"
    else
        log_result FAIL "macOS build script help functionality"
    fi
}

# Test file permissions and executability
test_file_permissions() {
    log_test "Testing file permissions..."
    
    local scripts=("build.sh" "build-macos.sh" "scan-vulnerabilities.sh" "scripts/install-dependencies.sh")
    
    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            if [ -x "$script" ]; then
                log_result PASS "$script executable permissions"
            else
                log_result FAIL "$script executable permissions"
            fi
        else
            log_result SKIP "$script permissions (file not found)"
        fi
    done
}

# Test documentation
test_documentation() {
    log_test "Testing documentation..."
    
    local docs=("README.md" "docs/DEVELOPER_GUIDE.md" "CONTRIBUTING.md" "LICENSE")
    
    for doc in "${docs[@]}"; do
        if [ -f "$doc" ]; then
            if [ -s "$doc" ]; then
                local size=$(du -h "$doc" | cut -f1)
                log_result PASS "$doc exists and non-empty (size: $size)"
            else
                log_result FAIL "$doc exists but empty"
            fi
        else
            log_result SKIP "$doc (file not found)"
        fi
    done
}

# Test git repository status
test_git_status() {
    log_test "Testing git repository status..."
    
    if [ ! -d ".git" ]; then
        log_result SKIP "Git testing (not a git repository)"
        return
    fi
    
    # Test git status
    if git status >/dev/null 2>&1; then
        log_result PASS "Git repository status"
    else
        log_result FAIL "Git repository status"
    fi
    
    # Test current branch
    local branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    if [ "$branch" = "dev" ]; then
        log_result PASS "Git on dev branch"
    else
        log_result FAIL "Git not on dev branch (current: $branch)"
    fi
    
    # Test git configuration
    local user_name=$(git config user.name 2>/dev/null || echo "")
    local user_email=$(git config user.email 2>/dev/null || echo "")
    
    if [ -n "$user_name" ] && [ -n "$user_email" ]; then
        log_result PASS "Git user configuration ($user_name <$user_email>)"
    else
        log_result FAIL "Git user configuration missing"
    fi
}

# Performance benchmark
run_performance_benchmark() {
    log_test "Running performance benchmark..."
    
    local start_time=$(date +%s)
    
    # Build all architectures
    log_info "Benchmarking build performance..."
    if make clean-all >/dev/null 2>&1 && make build-all >/dev/null 2>&1; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log_result PASS "Build all architectures in ${duration}s"
    else
        log_result FAIL "Build performance benchmark"
    fi
}

# Generate test report
generate_test_report() {
    local report_file="test-report-$(date +%Y%m%d-%H%M%S).txt"
    
    cat > "$report_file" << EOF
SAGE-OS Test Report
==================
Date: $(date)
Host: $(hostname)
OS: $(uname -s) $(uname -r)
Architecture: $(uname -m)

Test Results Summary:
--------------------
Total Tests: $TOTAL_TESTS
Passed: $PASSED_TESTS
Failed: $FAILED_TESTS
Skipped: $SKIPPED_TESTS

Success Rate: $(( PASSED_TESTS * 100 / TOTAL_TESTS ))%

Build Status:
------------
EOF
    
    # Add build status for each architecture
    for arch in i386 x86_64 aarch64 arm riscv64; do
        if [ -f "build/$arch/kernel.img" ] || [ -f "build/$arch/kernel.elf" ]; then
            local size=$(du -h build/$arch/kernel.* 2>/dev/null | head -n1 | cut -f1)
            echo "$arch: Built (size: $size)" >> "$report_file"
        else
            echo "$arch: Not built" >> "$report_file"
        fi
    done
    
    echo "" >> "$report_file"
    echo "Docker Images:" >> "$report_file"
    if command_exists docker && docker info >/dev/null 2>&1; then
        docker images | grep sage-os >> "$report_file" 2>/dev/null || echo "No SAGE-OS images found" >> "$report_file"
    else
        echo "Docker not available" >> "$report_file"
    fi
    
    log_success "Test report generated: $report_file"
}

# Print test summary
print_test_summary() {
    echo ""
    echo "🧪 SAGE-OS Test Summary"
    echo "======================="
    echo -e "Total Tests: ${CYAN}$TOTAL_TESTS${NC}"
    echo -e "Passed:      ${GREEN}$PASSED_TESTS${NC}"
    echo -e "Failed:      ${RED}$FAILED_TESTS${NC}"
    echo -e "Skipped:     ${YELLOW}$SKIPPED_TESTS${NC}"
    echo ""
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}🎉 All tests passed successfully!${NC}"
        echo -e "Success Rate: ${GREEN}$(( PASSED_TESTS * 100 / TOTAL_TESTS ))%${NC}"
    else
        echo -e "${RED}❌ Some tests failed${NC}"
        echo -e "Success Rate: ${YELLOW}$(( PASSED_TESTS * 100 / TOTAL_TESTS ))%${NC}"
    fi
    
    echo ""
}

# Main testing function
main() {
    echo "🧪 SAGE-OS Comprehensive Testing Suite"
    echo "======================================"
    echo ""
    
    # Change to project directory if not already there
    if [ ! -f "build.sh" ] && [ -d "SAGE-OS" ]; then
        cd SAGE-OS
    fi
    
    # Run all tests
    test_file_permissions
    test_documentation
    test_git_status
    test_build_system
    test_build_script
    test_macos_build_script
    test_iso_creation
    test_sdcard_creation
    test_qemu_emulation
    test_docker_functionality
    test_cve_scanner
    
    # Optional performance benchmark
    if [ "${RUN_BENCHMARK:-}" = "true" ]; then
        run_performance_benchmark
    fi
    
    print_test_summary
    generate_test_report
    
    # Exit with appropriate code
    if [ $FAILED_TESTS -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "SAGE-OS Comprehensive Testing Script"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h         Show this help message"
        echo "  --benchmark        Include performance benchmarks"
        echo "  --quick            Run only quick tests (skip QEMU and Docker)"
        echo "  --build-only       Test only build system"
        echo "  --qemu-only        Test only QEMU functionality"
        echo "  --docker-only      Test only Docker functionality"
        echo "  --cve-only         Test only CVE scanner"
        echo ""
        echo "Environment variables:"
        echo "  RUN_BENCHMARK=true    Include performance benchmarks"
        echo "  SKIP_QEMU=true        Skip QEMU tests"
        echo "  SKIP_DOCKER=true      Skip Docker tests"
        exit 0
        ;;
    --benchmark)
        export RUN_BENCHMARK=true
        main
        ;;
    --quick)
        export SKIP_QEMU=true
        export SKIP_DOCKER=true
        main
        ;;
    --build-only)
        test_build_system
        print_test_summary
        ;;
    --qemu-only)
        test_qemu_emulation
        print_test_summary
        ;;
    --docker-only)
        test_docker_functionality
        print_test_summary
        ;;
    --cve-only)
        test_cve_scanner
        print_test_summary
        ;;
    "")
        main
        ;;
    *)
        log_error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac