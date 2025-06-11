#!/bin/bash

# Docker Builder for SAGE OS
# Author: Ashish Vasant Yesale <ashishyesale007@gmail.com>
# Version: 1.0.0
# Description: Build Docker images for SAGE OS with multiple architectures

set -euo pipefail

# Script configuration
SCRIPT_NAME="SAGE OS Docker Builder"
SCRIPT_VERSION="1.0.0"
PROJECT_NAME="SAGE-OS"
PROJECT_VERSION="0.1.0"

# Default values
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCKER_REGISTRY=""
DOCKER_TAG_PREFIX="sage-os"
BUILD_ARCHITECTURES=""
PUSH_IMAGES=false
VERBOSE=false
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

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

log_debug() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${PURPLE}[DEBUG]${NC} $1"
    fi
}

# Help function
show_help() {
    cat << EOF
${SCRIPT_NAME} v${SCRIPT_VERSION}
Build Docker images for SAGE OS with multiple architectures

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -h, --help              Show this help message
    -v, --verbose           Enable verbose output
    --version               Show version information
    
    BUILD OPTIONS:
    --project-root DIR      Project root directory (default: auto-detected)
    --arch ARCH             Build specific architecture(s) (comma-separated)
                           Available: i386,x86_64,aarch64,arm,riscv64
                           Default: all available
    --registry REGISTRY     Docker registry to use (e.g., docker.io/username)
    --tag-prefix PREFIX     Docker tag prefix (default: sage-os)
    --push                  Push images to registry after building
    
EXAMPLES:
    # Build Docker images for all architectures
    $0
    
    # Build for specific architectures
    $0 --arch i386,x86_64
    
    # Build and push to registry
    $0 --registry docker.io/myuser --push
    
    # Build with custom tag prefix
    $0 --tag-prefix my-sage-os --arch i386

DOCKER IMAGES CREATED:
    The script creates Docker images with the following naming convention:
    [REGISTRY/]TAG-PREFIX:VERSION-ARCH-PLATFORM
    
    Examples:
    - sage-os:0.1.0-i386-generic
    - sage-os:0.1.0-x86_64-generic
    - docker.io/user/sage-os:0.1.0-aarch64-rpi4

DOCKERFILE STRUCTURE:
    The script automatically generates Dockerfiles for each architecture
    with the following features:
    - Multi-stage builds for optimization
    - Architecture-specific base images
    - SAGE OS kernel and ISO inclusion
    - Metadata labels
    - Health checks
    - Security best practices

EOF
}

# Version information
show_version() {
    cat << EOF
${SCRIPT_NAME} v${SCRIPT_VERSION}
Project: ${PROJECT_NAME} v${PROJECT_VERSION}
Author: Ashish Vasant Yesale <ashishyesale007@gmail.com>
License: MIT
EOF
}

# Check Docker availability
check_docker() {
    log_info "Checking Docker availability..."
    
    if ! command -v docker >/dev/null 2>&1; then
        log_error "Docker not found. Please install Docker first."
        return 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker daemon not running. Please start Docker."
        return 1
    fi
    
    log_success "Docker is available and running"
}

# Get available architectures
get_available_architectures() {
    local archs=()
    
    # Check build directories
    if [ -d "$PROJECT_ROOT/build" ]; then
        for arch_dir in "$PROJECT_ROOT/build"/*; do
            if [ -d "$arch_dir" ]; then
                archs+=($(basename "$arch_dir"))
            fi
        done
    fi
    
    # Check dist directories
    if [ -d "$PROJECT_ROOT/dist" ]; then
        for arch_dir in "$PROJECT_ROOT/dist"/*; do
            if [ -d "$arch_dir" ]; then
                local arch=$(basename "$arch_dir")
                if [[ ! " ${archs[@]} " =~ " ${arch} " ]]; then
                    archs+=("$arch")
                fi
            fi
        done
    fi
    
    # Check build-output files
    if [ -d "$PROJECT_ROOT/build-output" ]; then
        for file in "$PROJECT_ROOT/build-output"/*.img; do
            if [ -f "$file" ]; then
                local filename=$(basename "$file")
                if [[ "$filename" =~ SAGE-OS-[0-9.]+-([^-]+)- ]]; then
                    local arch="${BASH_REMATCH[1]}"
                    if [[ ! " ${archs[@]} " =~ " ${arch} " ]]; then
                        archs+=("$arch")
                    fi
                fi
            fi
        done
    fi
    
    echo "${archs[@]}"
}

# Generate Dockerfile for architecture
generate_dockerfile() {
    local arch="$1"
    local dockerfile_dir="$2"
    
    log_info "Generating Dockerfile for $arch..."
    
    # Determine base image based on architecture
    local base_image=""
    case "$arch" in
        "i386")
            base_image="i386/alpine:latest"
            ;;
        "x86_64")
            base_image="alpine:latest"
            ;;
        "aarch64")
            base_image="arm64v8/alpine:latest"
            ;;
        "arm")
            base_image="arm32v7/alpine:latest"
            ;;
        "riscv64")
            base_image="riscv64/alpine:edge"
            ;;
        *)
            base_image="alpine:latest"
            ;;
    esac
    
    # Find kernel and ISO files for this architecture
    local kernel_file=""
    local iso_file=""
    
    # Check build-output first
    for file in "$PROJECT_ROOT/build-output"/*"$arch"*.img; do
        if [ -f "$file" ]; then
            kernel_file="$file"
            break
        fi
    done
    
    # Check dist directory for ISO
    if [ -d "$PROJECT_ROOT/dist/$arch" ]; then
        for file in "$PROJECT_ROOT/dist/$arch"/*.iso; do
            if [ -f "$file" ]; then
                iso_file="$file"
                break
            fi
        done
    fi
    
    # Check build directory for kernel
    if [ -z "$kernel_file" ] && [ -d "$PROJECT_ROOT/build/$arch" ]; then
        for file in "$PROJECT_ROOT/build/$arch"/*.img; do
            if [ -f "$file" ]; then
                kernel_file="$file"
                break
            fi
        done
    fi
    
    if [ -z "$kernel_file" ]; then
        log_warning "No kernel file found for $arch"
        return 1
    fi
    
    # Create Dockerfile
    cat > "$dockerfile_dir/Dockerfile" << EOF
# SAGE OS Docker Image for $arch
# Generated by: ${SCRIPT_NAME} v${SCRIPT_VERSION}
# Build date: $(date -Iseconds)

# Multi-stage build for optimization
FROM $base_image AS base

# Install required packages
RUN apk add --no-cache \\
    qemu-system-$arch \\
    qemu-img \\
    socat \\
    curl \\
    bash \\
    util-linux

# Create sage user
RUN addgroup -g 1000 sage && \\
    adduser -D -s /bin/bash -G sage -u 1000 sage

# Create directories
RUN mkdir -p /opt/sage-os/{kernel,iso,scripts} && \\
    chown -R sage:sage /opt/sage-os

# Copy SAGE OS files
COPY --chown=sage:sage $(basename "$kernel_file") /opt/sage-os/kernel/
$([ -n "$iso_file" ] && echo "COPY --chown=sage:sage $(basename "$iso_file") /opt/sage-os/iso/")

# Copy scripts
COPY --chown=sage:sage scripts/ /opt/sage-os/scripts/

# Create startup script
RUN cat > /opt/sage-os/start-sage.sh << 'SCRIPT_EOF'
#!/bin/bash
set -euo pipefail

ARCH="$arch"
KERNEL_FILE="/opt/sage-os/kernel/$(basename "$kernel_file")"
$([ -n "$iso_file" ] && echo "ISO_FILE=\"/opt/sage-os/iso/$(basename "$iso_file")\"")

echo "Starting SAGE OS (\$ARCH)..."
echo "Kernel: \$KERNEL_FILE"
$([ -n "$iso_file" ] && echo "echo \"ISO: \$ISO_FILE\"")

# Default QEMU options
QEMU_OPTS="-m 256M -nographic -serial stdio"

# Architecture-specific QEMU command
case "\$ARCH" in
    "i386")
        QEMU_CMD="qemu-system-i386"
        ;;
    "x86_64")
        QEMU_CMD="qemu-system-x86_64"
        ;;
    "aarch64")
        QEMU_CMD="qemu-system-aarch64"
        QEMU_OPTS="\$QEMU_OPTS -machine virt -cpu cortex-a57"
        ;;
    "arm")
        QEMU_CMD="qemu-system-arm"
        QEMU_OPTS="\$QEMU_OPTS -machine virt -cpu cortex-a15"
        ;;
    "riscv64")
        QEMU_CMD="qemu-system-riscv64"
        QEMU_OPTS="\$QEMU_OPTS -machine virt"
        ;;
    *)
        echo "Unsupported architecture: \$ARCH"
        exit 1
        ;;
esac

# Boot from ISO if available, otherwise from kernel
$(if [ -n "$iso_file" ]; then
    echo "exec \$QEMU_CMD \$QEMU_OPTS -cdrom \$ISO_FILE -boot d"
else
    echo "exec \$QEMU_CMD \$QEMU_OPTS -kernel \$KERNEL_FILE"
fi)
SCRIPT_EOF

RUN chmod +x /opt/sage-os/start-sage.sh && \\
    chown sage:sage /opt/sage-os/start-sage.sh

# Switch to sage user
USER sage
WORKDIR /opt/sage-os

# Expose common ports
EXPOSE 5900 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \\
    CMD pgrep qemu || exit 1

# Labels
LABEL org.opencontainers.image.title="SAGE OS ($arch)"
LABEL org.opencontainers.image.description="SAGE Operating System for $arch architecture"
LABEL org.opencontainers.image.version="$PROJECT_VERSION"
LABEL org.opencontainers.image.authors="Ashish Vasant Yesale <ashishyesale007@gmail.com>"
LABEL org.opencontainers.image.source="https://github.com/SAGE-OS/SAGE-OS"
LABEL org.opencontainers.image.architecture="$arch"
LABEL sage.os.architecture="$arch"
LABEL sage.os.kernel="$(basename "$kernel_file")"
$([ -n "$iso_file" ] && echo "LABEL sage.os.iso=\"$(basename "$iso_file")\"")

# Default command
CMD ["/opt/sage-os/start-sage.sh"]
EOF
    
    log_success "Dockerfile generated for $arch"
}

# Build Docker image for architecture
build_docker_image() {
    local arch="$1"
    local build_dir="$2"
    
    log_info "Building Docker image for $arch..."
    
    # Create build directory
    local dockerfile_dir="$build_dir/$arch"
    mkdir -p "$dockerfile_dir"
    
    # Generate Dockerfile
    if ! generate_dockerfile "$arch" "$dockerfile_dir"; then
        log_error "Failed to generate Dockerfile for $arch"
        return 1
    fi
    
    # Copy required files to build context
    local kernel_file=""
    local iso_file=""
    
    # Find and copy kernel file
    for file in "$PROJECT_ROOT/build-output"/*"$arch"*.img; do
        if [ -f "$file" ]; then
            kernel_file="$file"
            cp "$file" "$dockerfile_dir/"
            break
        fi
    done
    
    if [ -z "$kernel_file" ]; then
        for file in "$PROJECT_ROOT/build/$arch"/*.img; do
            if [ -f "$file" ]; then
                kernel_file="$file"
                cp "$file" "$dockerfile_dir/"
                break
            fi
        done
    fi
    
    # Find and copy ISO file
    if [ -d "$PROJECT_ROOT/dist/$arch" ]; then
        for file in "$PROJECT_ROOT/dist/$arch"/*.iso; do
            if [ -f "$file" ]; then
                iso_file="$file"
                cp "$file" "$dockerfile_dir/"
                break
            fi
        done
    fi
    
    # Copy scripts directory
    if [ -d "$PROJECT_ROOT/scripts" ]; then
        cp -r "$PROJECT_ROOT/scripts" "$dockerfile_dir/"
    fi
    
    # Build image
    local image_tag="${DOCKER_TAG_PREFIX}:${PROJECT_VERSION}-${arch}-generic"
    if [ -n "$DOCKER_REGISTRY" ]; then
        image_tag="${DOCKER_REGISTRY}/${image_tag}"
    fi
    
    log_info "Building image: $image_tag"
    
    if docker build -t "$image_tag" "$dockerfile_dir"; then
        log_success "Docker image built: $image_tag"
        
        # Tag with latest for this architecture
        local latest_tag="${DOCKER_TAG_PREFIX}:latest-${arch}"
        if [ -n "$DOCKER_REGISTRY" ]; then
            latest_tag="${DOCKER_REGISTRY}/${latest_tag}"
        fi
        docker tag "$image_tag" "$latest_tag"
        
        # Push if requested
        if [ "$PUSH_IMAGES" = true ]; then
            log_info "Pushing image: $image_tag"
            docker push "$image_tag"
            docker push "$latest_tag"
            log_success "Image pushed: $image_tag"
        fi
        
        return 0
    else
        log_error "Failed to build Docker image for $arch"
        return 1
    fi
}

# Main build function
build_docker_images() {
    log_info "Starting Docker image build process..."
    log_info "Project: $PROJECT_NAME v$PROJECT_VERSION"
    
    # Check Docker
    check_docker
    
    # Get architectures to build
    local available_archs=($(get_available_architectures))
    local build_archs=()
    
    if [ -n "$BUILD_ARCHITECTURES" ]; then
        IFS=',' read -ra requested_archs <<< "$BUILD_ARCHITECTURES"
        for arch in "${requested_archs[@]}"; do
            if [[ " ${available_archs[@]} " =~ " ${arch} " ]]; then
                build_archs+=("$arch")
            else
                log_warning "Architecture not available: $arch"
            fi
        done
    else
        build_archs=("${available_archs[@]}")
    fi
    
    if [ ${#build_archs[@]} -eq 0 ]; then
        log_error "No architectures available for building"
        return 1
    fi
    
    log_info "Building Docker images for architectures: ${build_archs[*]}"
    
    # Create temporary build directory
    local build_dir=$(mktemp -d)
    log_debug "Using build directory: $build_dir"
    
    # Build images for each architecture
    local success_count=0
    local total_count=${#build_archs[@]}
    
    for arch in "${build_archs[@]}"; do
        if build_docker_image "$arch" "$build_dir"; then
            ((success_count++))
        fi
    done
    
    # Cleanup
    rm -rf "$build_dir"
    
    # Summary
    log_info "Docker build summary:"
    log_info "  Total architectures: $total_count"
    log_info "  Successful builds: $success_count"
    log_info "  Failed builds: $((total_count - success_count))"
    
    if [ $success_count -eq $total_count ]; then
        log_success "All Docker images built successfully!"
    elif [ $success_count -gt 0 ]; then
        log_warning "Some Docker images failed to build"
    else
        log_error "All Docker image builds failed"
        return 1
    fi
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            --version)
                show_version
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            --project-root)
                PROJECT_ROOT="$2"
                shift 2
                ;;
            --arch)
                BUILD_ARCHITECTURES="$2"
                shift 2
                ;;
            --registry)
                DOCKER_REGISTRY="$2"
                shift 2
                ;;
            --tag-prefix)
                DOCKER_TAG_PREFIX="$2"
                shift 2
                ;;
            --push)
                PUSH_IMAGES=true
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
}

# Main function
main() {
    # Validate project root
    if [ ! -d "$PROJECT_ROOT" ]; then
        log_error "Project root directory not found: $PROJECT_ROOT"
        exit 1
    fi
    
    # Change to project root
    cd "$PROJECT_ROOT"
    
    # Build Docker images
    build_docker_images
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_arguments "$@"
    main
fi