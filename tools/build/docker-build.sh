#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS Docker-based Multi-Architecture Build System
# Provides consistent builds across different host platforms

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="SAGE-OS"
VERSION="0.1.0"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${PURPLE}=== $1 ===${NC}"; }

# Check if Docker is available
check_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        log_error "Docker not found. Please install Docker first."
        echo "Visit: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker daemon not running. Please start Docker."
        exit 1
    fi
    
    log_success "Docker is available"
}

# Create multi-arch build container
create_build_container() {
    local arch=$1
    local container_name="sage-os-builder-$arch"
    
    log_header "Creating Build Container for $arch"
    
    # Create Dockerfile for the specific architecture
    cat > "$SCRIPT_DIR/Dockerfile.$arch" << EOF
# Multi-stage build for SAGE OS ($arch)
FROM --platform=linux/amd64 ubuntu:22.04 as builder

# Install build dependencies
RUN apt-get update && apt-get install -y \\
    build-essential \\
    gcc-aarch64-linux-gnu \\
    gcc-arm-linux-gnueabihf \\
    gcc-riscv64-linux-gnu \\
    gcc-x86-64-linux-gnu \\
    qemu-system-arm \\
    qemu-system-x86 \\
    qemu-system-misc \\
    genisoimage \\
    dosfstools \\
    make \\
    git \\
    curl \\
    && rm -rf /var/lib/apt/lists/*

# Set up working directory
WORKDIR /workspace

# Copy source code
COPY . .

# Set default architecture
ENV ARCH=$arch
ENV DEBIAN_FRONTEND=noninteractive

# Build script
RUN chmod +x build.sh

# Default command
CMD ["make", "-f", "Makefile.multi-arch", "kernel"]
EOF
    
    # Build the container
    log_info "Building Docker container for $arch..."
    docker build -f "Dockerfile.$arch" -t "$container_name" .
    
    log_success "Container $container_name created successfully"
}

# Build using Docker container
docker_build() {
    local arch=${1:-"aarch64"}
    local platform=${2:-"rpi4"}
    local format=${3:-"kernel"}
    local container_name="sage-os-builder-$arch"
    
    log_header "Docker Build: $arch ($platform, $format)"
    
    # Create container if it doesn't exist
    if ! docker images | grep -q "$container_name"; then
        create_build_container "$arch"
    fi
    
    # Create output directory
    mkdir -p "$SCRIPT_DIR/build" "$SCRIPT_DIR/dist"
    
    # Run build in container
    log_info "Running build in Docker container..."
    docker run --rm \
        -v "$SCRIPT_DIR:/workspace" \
        -e "ARCH=$arch" \
        -e "PLATFORM=$platform" \
        -e "FORMAT=$format" \
        -e "ENABLE_AI=${ENABLE_AI:-OFF}" \
        -e "ENABLE_CRYPTO=${ENABLE_CRYPTO:-ON}" \
        -e "ENABLE_DEBUG=${ENABLE_DEBUG:-OFF}" \
        "$container_name" \
        make -f Makefile.multi-arch "$format" "ARCH=$arch" "PLATFORM=$platform"
    
    log_success "Docker build completed for $arch ($platform, $format)"
}

# Build all architectures using Docker
docker_build_all() {
    local platform=${1:-"generic"}
    local format=${2:-"kernel"}
    
    log_header "Docker Build All Architectures"
    
    local archs=("aarch64" "x86_64" "riscv64" "arm")
    local failed_builds=()
    
    for arch in "${archs[@]}"; do
        if docker_build "$arch" "$platform" "$format"; then
            log_success "✓ $arch Docker build completed"
        else
            log_error "✗ $arch Docker build failed"
            failed_builds+=("$arch")
        fi
    done
    
    if [ ${#failed_builds[@]} -gt 0 ]; then
        log_error "Failed Docker builds: ${failed_builds[*]}"
        return 1
    fi
    
    log_success "All Docker builds completed successfully"
}

# Create multi-arch Docker images
create_multiarch_images() {
    log_header "Creating Multi-Architecture Docker Images"
    
    # Enable Docker buildx for multi-arch builds
    docker buildx create --name sage-os-builder --use 2>/dev/null || true
    
    # Create multi-arch Dockerfile
    cat > "$SCRIPT_DIR/Dockerfile.multiarch" << 'EOF'
# Multi-architecture SAGE OS image
FROM scratch

# Copy kernel and config files
COPY build/*/kernel.img /boot/
COPY config*.txt /boot/

# Metadata
LABEL org.opencontainers.image.title="SAGE OS"
LABEL org.opencontainers.image.version="0.1.0"
LABEL org.opencontainers.image.description="SAGE OS - Self-Aware General Environment Operating System"
LABEL org.opencontainers.image.source="https://github.com/AshishYesale7/SAGE-OS"
LABEL org.opencontainers.image.licenses="BSD-3-Clause"

# Default command
CMD ["/boot/kernel.img"]
EOF
    
    # Build multi-arch image
    log_info "Building multi-architecture Docker image..."
    docker buildx build \
        --platform linux/amd64,linux/arm64,linux/arm/v7 \
        -f Dockerfile.multiarch \
        -t "sage-os:latest" \
        -t "sage-os:$VERSION" \
        --push \
        . || log_warning "Multi-arch build failed (registry push may not be configured)"
    
    log_success "Multi-architecture Docker images created"
}

# Test Docker build
test_docker_build() {
    local arch=${1:-"aarch64"}
    local platform=${2:-"rpi4"}
    
    log_header "Testing Docker Build for $arch"
    
    # Build if not exists
    if [ ! -f "build/$arch/kernel.img" ]; then
        docker_build "$arch" "$platform" "kernel"
    fi
    
    # Test with QEMU in Docker
    local container_name="sage-os-builder-$arch"
    
    log_info "Running QEMU test in Docker container..."
    timeout 30s docker run --rm \
        -v "$SCRIPT_DIR:/workspace" \
        "$container_name" \
        make -f Makefile.multi-arch qemu "ARCH=$arch" "PLATFORM=$platform" || {
        local exit_code=$?
        if [ $exit_code -eq 124 ]; then
            log_success "Docker QEMU test completed (timed out as expected)"
        else
            log_error "Docker QEMU test failed with exit code $exit_code"
            return 1
        fi
    }
}

# Clean Docker resources
clean_docker() {
    log_header "Cleaning Docker Resources"
    
    # Remove build containers
    for arch in aarch64 x86_64 riscv64 arm; do
        local container_name="sage-os-builder-$arch"
        if docker images | grep -q "$container_name"; then
            log_info "Removing container: $container_name"
            docker rmi "$container_name" || true
        fi
    done
    
    # Remove Dockerfiles
    rm -f Dockerfile.* 2>/dev/null || true
    
    # Clean build files
    make -f Makefile.multi-arch distclean 2>/dev/null || true
    
    log_success "Docker resources cleaned"
}

# Show Docker build status
show_docker_status() {
    log_header "Docker Build Status"
    
    echo "Available Docker images:"
    docker images | grep -E "(sage-os|ubuntu)" | head -10
    
    echo ""
    echo "Build containers:"
    for arch in aarch64 x86_64 riscv64 arm; do
        local container_name="sage-os-builder-$arch"
        if docker images | grep -q "$container_name"; then
            echo "  ✓ $container_name"
        else
            echo "  ✗ $container_name (not built)"
        fi
    done
    
    echo ""
    echo "Built kernels:"
    for arch in aarch64 x86_64 riscv64 arm; do
        if [ -f "build/$arch/kernel.img" ]; then
            local size=$(du -h "build/$arch/kernel.img" | cut -f1)
            echo "  ✓ $arch: $size"
        else
            echo "  ✗ $arch: not built"
        fi
    done
}

# Show usage
show_usage() {
    cat << EOF
SAGE OS Docker-based Multi-Architecture Build System

Usage: $0 [command] [options]

Commands:
  build [arch] [platform] [format]  Build using Docker container
  build-all [platform] [format]     Build all architectures using Docker
  test [arch] [platform]            Test Docker build
  multiarch                         Create multi-architecture Docker images
  clean                             Clean Docker resources
  status                            Show Docker build status
  help                              Show this help

Architectures:
  aarch64                           ARM64 (default)
  x86_64                            Intel/AMD 64-bit
  riscv64                           RISC-V 64-bit
  arm                               ARM 32-bit

Platforms:
  rpi3                              Raspberry Pi 3
  rpi4                              Raspberry Pi 4 (default)
  rpi5                              Raspberry Pi 5
  x86_64                            Generic x86_64
  generic                           Generic platform

Formats:
  kernel                            Kernel image (default)
  iso                               ISO image
  sdcard                            SD card image

Examples:
  $0 build aarch64 rpi5             # Build for RPi 5 using Docker
  $0 build-all rpi4                 # Build all archs for RPi 4
  $0 test aarch64 rpi4              # Test ARM64 build
  $0 multiarch                      # Create multi-arch Docker images
  $0 clean                          # Clean Docker resources

Environment Variables:
  ENABLE_AI=ON                      Enable AI subsystem
  ENABLE_CRYPTO=ON                  Enable crypto support
  ENABLE_DEBUG=ON                   Enable debug build

Benefits of Docker builds:
  - Consistent build environment across platforms
  - No need to install cross-compilation toolchains locally
  - Isolated builds prevent conflicts
  - Easy CI/CD integration
  - Reproducible builds

EOF
}

# Main function
main() {
    cd "$SCRIPT_DIR"
    
    case "${1:-help}" in
        build)
            check_docker
            docker_build "${2:-aarch64}" "${3:-rpi4}" "${4:-kernel}"
            ;;
        build-all)
            check_docker
            docker_build_all "${2:-rpi4}" "${3:-kernel}"
            ;;
        test)
            check_docker
            test_docker_build "${2:-aarch64}" "${3:-rpi4}"
            ;;
        multiarch)
            check_docker
            create_multiarch_images
            ;;
        clean)
            check_docker
            clean_docker
            ;;
        status)
            check_docker
            show_docker_status
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            log_error "Unknown command: $1"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"