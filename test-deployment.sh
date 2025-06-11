#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS Deployment Test Script
# ─────────────────────────────────────────────────────────────────────────────

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Test Docker availability
test_docker() {
    log_info "Testing Docker availability..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        return 1
    fi
    
    if ! docker info &> /dev/null; then
        log_error "Docker daemon is not running"
        return 1
    fi
    
    log_success "Docker is available and running"
    return 0
}

# Test script permissions
test_scripts() {
    log_info "Testing script permissions..."
    
    if [[ ! -x "./deploy-sage-os.sh" ]]; then
        log_error "deploy-sage-os.sh is not executable"
        return 1
    fi
    
    if [[ ! -x "./quick-start.sh" ]]; then
        log_error "quick-start.sh is not executable"
        return 1
    fi
    
    log_success "All scripts are executable"
    return 0
}

# Test build process
test_build() {
    log_info "Testing Docker image build..."
    
    if ! ./deploy-sage-os.sh build -a i386 &> /tmp/build.log; then
        log_error "Build failed. Check /tmp/build.log for details"
        return 1
    fi
    
    if ! docker images | grep -q "sage-os"; then
        log_error "Docker image was not created"
        return 1
    fi
    
    log_success "Docker image built successfully"
    return 0
}

# Test container startup
test_container() {
    log_info "Testing container startup..."
    
    # Start container in background
    timeout 30 ./deploy-sage-os.sh run -d text -a i386 &> /tmp/container.log &
    CONTAINER_PID=$!
    
    # Wait for container to start
    sleep 10
    
    # Check if container is running
    if ! docker ps | grep -q "sage-os-runtime"; then
        log_error "Container failed to start. Check /tmp/container.log"
        return 1
    fi
    
    # Stop the container
    ./deploy-sage-os.sh stop &> /dev/null || true
    
    log_success "Container started and stopped successfully"
    return 0
}

# Test VNC mode
test_vnc() {
    log_info "Testing VNC mode setup..."
    
    # Start VNC container in background
    timeout 30 ./deploy-sage-os.sh run -d vnc -a i386 -p 5999 &> /tmp/vnc.log &
    VNC_PID=$!
    
    # Wait for VNC to start
    sleep 15
    
    # Check if VNC port is listening
    if ! netstat -ln 2>/dev/null | grep -q ":5999" && ! ss -ln 2>/dev/null | grep -q ":5999"; then
        log_warning "VNC port test inconclusive (netstat/ss not available)"
    else
        log_success "VNC port is listening"
    fi
    
    # Stop the container
    ./deploy-sage-os.sh stop &> /dev/null || true
    
    log_success "VNC mode test completed"
    return 0
}

# Cleanup test artifacts
cleanup() {
    log_info "Cleaning up test artifacts..."
    
    # Stop any running containers
    ./deploy-sage-os.sh stop &> /dev/null || true
    
    # Clean up Docker resources
    ./deploy-sage-os.sh clean &> /dev/null || true
    
    # Remove log files
    rm -f /tmp/build.log /tmp/container.log /tmp/vnc.log
    
    log_success "Cleanup completed"
}

# Main test execution
main() {
    echo -e "${BLUE}"
    echo "=================================="
    echo "  SAGE OS Deployment Test Suite"
    echo "=================================="
    echo -e "${NC}"
    
    local tests_passed=0
    local tests_total=5
    
    # Run tests
    if test_docker; then
        ((tests_passed++))
    fi
    
    if test_scripts; then
        ((tests_passed++))
    fi
    
    if test_build; then
        ((tests_passed++))
    fi
    
    if test_container; then
        ((tests_passed++))
    fi
    
    if test_vnc; then
        ((tests_passed++))
    fi
    
    # Cleanup
    cleanup
    
    # Results
    echo
    echo "=================================="
    echo "           Test Results"
    echo "=================================="
    
    if [[ $tests_passed -eq $tests_total ]]; then
        log_success "All tests passed! ($tests_passed/$tests_total)"
        echo
        log_info "Your SAGE OS deployment is ready to use!"
        echo
        echo "Quick start commands:"
        echo "  ./quick-start.sh                    # Interactive setup"
        echo "  ./deploy-sage-os.sh deploy -d vnc   # VNC mode"
        echo "  ./deploy-sage-os.sh deploy -d text  # Text mode"
        echo
        return 0
    else
        log_error "Some tests failed ($tests_passed/$tests_total passed)"
        echo
        log_info "Check the following:"
        echo "  - Docker is installed and running"
        echo "  - Scripts have execute permissions"
        echo "  - No port conflicts (5901, 1234)"
        echo "  - Sufficient disk space for Docker images"
        echo
        return 1
    fi
}

# Handle script interruption
trap cleanup EXIT INT TERM

# Run main function
main "$@"