#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS Docker Deployment Script
# This script builds and runs SAGE OS with graphics and input support using Docker

set -e  # Exit on any error

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SAGE_OS_DIR="$SCRIPT_DIR"
DOCKER_IMAGE_NAME="sage-os"
DOCKER_TAG="latest"
CONTAINER_NAME="sage-os-runtime"

# Default values
ARCH="i386"
MODE="graphics"
MEMORY="128M"
DISPLAY_MODE="vnc"
VNC_PORT="5901"
QEMU_MONITOR_PORT="1234"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Help function
show_help() {
    cat << EOF
SAGE OS Docker Deployment Script

Usage: $0 [OPTIONS] [COMMAND]

Commands:
    build       Build SAGE OS Docker image
    run         Run SAGE OS in Docker container
    deploy      Build and run SAGE OS (default)
    clean       Clean up Docker containers and images
    logs        Show container logs
    shell       Open shell in running container
    stop        Stop running container

Options:
    -a, --arch ARCH         Target architecture (i386, x86_64, aarch64, arm, riscv64) [default: i386]
    -m, --mode MODE         Display mode (graphics, text, vnc) [default: graphics]
    -M, --memory MEMORY     Memory allocation [default: 128M]
    -d, --display DISPLAY   Display type (vnc, x11, none) [default: vnc]
    -p, --vnc-port PORT     VNC port for remote access [default: 5901]
    -q, --qemu-port PORT    QEMU monitor port [default: 1234]
    -v, --verbose           Enable verbose output
    -h, --help              Show this help message

Examples:
    $0 deploy                           # Build and run with default settings
    $0 deploy -a x86_64 -m graphics     # Run x86_64 with graphics mode
    $0 run -d vnc -p 5902               # Run with VNC on port 5902
    $0 build -a aarch64                 # Build for ARM64 architecture
    $0 clean                            # Clean up all containers and images

VNC Access:
    When using VNC mode, connect to: localhost:$VNC_PORT
    Recommended VNC clients: TigerVNC, RealVNC, or built-in macOS Screen Sharing

EOF
}

# Check dependencies
check_dependencies() {
    log_info "Checking dependencies..."
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Check if Docker daemon is running
    if ! docker info &> /dev/null; then
        log_error "Docker daemon is not running. Please start Docker."
        exit 1
    fi
    
    # Check if we're on macOS for X11 forwarding
    if [[ "$OSTYPE" == "darwin"* ]] && [[ "$DISPLAY_MODE" == "x11" ]]; then
        if ! command -v xquartz &> /dev/null; then
            log_warning "XQuartz not found. X11 forwarding may not work on macOS."
            log_info "Consider using VNC mode instead: $0 deploy -d vnc"
        fi
    fi
    
    log_success "Dependencies check passed"
}

# Build Docker image
build_image() {
    log_info "Building SAGE OS Docker image for architecture: $ARCH"
    
    cd "$SAGE_OS_DIR"
    
    # Try to build with Ubuntu first, fallback to Alpine if network issues
    if ! timeout 10 docker pull ubuntu:22.04 >/dev/null 2>&1; then
        log_warning "Cannot pull Ubuntu image, trying Alpine Linux..."
        create_alpine_dockerfile
    else
        create_ubuntu_dockerfile
    fi
    
    # Complete the build process
    complete_build
}

create_ubuntu_dockerfile() {
    # Create enhanced Dockerfile for QEMU with graphics support
    cat > Dockerfile.runtime << 'EOF'
FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install dependencies for QEMU with graphics support
RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends \
    qemu-system-x86 \
    qemu-system-arm \
    qemu-system-misc \
    qemu-utils \
    tigervnc-standalone-server \
    tigervnc-common \
    xvfb \
    x11vnc \
    fluxbox \
    xterm \
    curl \
    wget \
    socat \
    netcat-openbsd \
    build-essential \
    gcc \
    make \
    nasm \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create sage user
RUN useradd -m -s /bin/bash sage && \
    mkdir -p /home/sage/.vnc /home/sage/sage-os

# Set VNC password (default: sageos)
RUN mkdir -p /home/sage/.vnc && \
    echo "sageos" > /home/sage/.vnc/passwd && \
    chmod 600 /home/sage/.vnc/passwd && \
    chown -R sage:sage /home/sage/.vnc

# Copy SAGE OS files
COPY . /home/sage/sage-os/
RUN chown -R sage:sage /home/sage/sage-os

# Copy startup script template
COPY start-sage-os-template.sh /home/sage/start-sage-os.sh


RUN chmod +x /home/sage/start-sage-os.sh && \
    chown sage:sage /home/sage/start-sage-os.sh

# Switch to sage user
USER sage
WORKDIR /home/sage/sage-os

# Expose VNC and monitor ports
EXPOSE 5901 5700 1234

# Default command
CMD ["/home/sage/start-sage-os.sh", "vnc", "i386", "128M", "1234"]
EOF
}

create_alpine_dockerfile() {
    # Create Alpine-based Dockerfile as fallback
    cat > Dockerfile.runtime << 'EOF'
FROM alpine:latest

# Install dependencies for QEMU with graphics support
RUN apk update && apk add --no-cache \
    qemu-system-i386 \
    qemu-system-arm \
    qemu-system-aarch64 \
    qemu-system-x86_64 \
    qemu-system-riscv64 \
    qemu-img \
    tigervnc \
    xvfb \
    fluxbox \
    xterm \
    curl \
    wget \
    socat \
    netcat-openbsd \
    build-base \
    gcc \
    make \
    nasm \
    bash \
    shadow \
    ca-certificates

# Create sage user
RUN adduser -D -s /bin/bash sage && \
    mkdir -p /home/sage/.vnc /home/sage/sage-os

# Set VNC password (default: sageos)
RUN mkdir -p /home/sage/.vnc && \
    echo "sageos" > /home/sage/.vnc/passwd && \
    chmod 600 /home/sage/.vnc/passwd && \
    chown -R sage:sage /home/sage/.vnc

# Copy SAGE OS files
COPY . /home/sage/sage-os/
RUN chown -R sage:sage /home/sage/sage-os

# Create startup script (same as Ubuntu version but with escaped variables)
# Copy startup script template
COPY start-sage-os-template.sh /home/sage/start-sage-os.sh


RUN chmod +x /home/sage/start-sage-os.sh && \
    chown sage:sage /home/sage/start-sage-os.sh

# Switch to sage user
USER sage
WORKDIR /home/sage/sage-os

# Expose VNC and monitor ports
EXPOSE 5901 5700 1234

# Default command
CMD ["/home/sage/start-sage-os.sh", "vnc", "i386", "128M", "1234"]
EOF
}

complete_build() {
    # Build the image
    log_info "Building Docker image..."
    if docker build -f Dockerfile.runtime -t "$DOCKER_IMAGE_NAME:$DOCKER_TAG" .; then
        log_success "Docker image built successfully: $DOCKER_IMAGE_NAME:$DOCKER_TAG"
    else
        log_error "Failed to build Docker image"
        return 1
    fi
}

# Run SAGE OS container
run_container() {
    log_info "Running SAGE OS container with $MODE mode on $ARCH architecture"
    
    # Stop existing container if running
    if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
        log_info "Stopping existing container..."
        docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
        docker rm "$CONTAINER_NAME" >/dev/null 2>&1 || true
    fi
    
    # Prepare Docker run arguments
    DOCKER_ARGS=(
        "--name" "$CONTAINER_NAME"
        "--rm"
        "-it"
        "-p" "$VNC_PORT:5901"
        "-p" "5700:5700"  # WebSocket VNC
        "-p" "$QEMU_MONITOR_PORT:1234"  # QEMU monitor
    )
    
    # Add X11 forwarding for macOS/Linux
    if [[ "$DISPLAY_MODE" == "x11" ]]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS with XQuartz
            DOCKER_ARGS+=("-e" "DISPLAY=host.docker.internal:0")
            DOCKER_ARGS+=("-v" "/tmp/.X11-unix:/tmp/.X11-unix:rw")
        else
            # Linux
            DOCKER_ARGS+=("-e" "DISPLAY=$DISPLAY")
            DOCKER_ARGS+=("-v" "/tmp/.X11-unix:/tmp/.X11-unix:rw")
            DOCKER_ARGS+=("--net=host")
        fi
    fi
    
    # Run the container
    log_info "Starting container with the following configuration:"
    log_info "  Architecture: $ARCH"
    log_info "  Display Mode: $DISPLAY_MODE"
    log_info "  Memory: $MEMORY"
    log_info "  VNC Port: $VNC_PORT"
    log_info "  Monitor Port: $QEMU_MONITOR_PORT"
    
    docker run "${DOCKER_ARGS[@]}" "$DOCKER_IMAGE_NAME:$DOCKER_TAG" \
        /home/sage/start-sage-os.sh "$DISPLAY_MODE" "$ARCH" "$MEMORY" "$QEMU_MONITOR_PORT"
}

# Clean up Docker resources
clean_docker() {
    log_info "Cleaning up Docker resources..."
    
    # Stop and remove container
    if docker ps -aq -f name="$CONTAINER_NAME" | grep -q .; then
        docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
        docker rm "$CONTAINER_NAME" >/dev/null 2>&1 || true
        log_success "Container removed"
    fi
    
    # Remove image
    if docker images -q "$DOCKER_IMAGE_NAME:$DOCKER_TAG" | grep -q .; then
        docker rmi "$DOCKER_IMAGE_NAME:$DOCKER_TAG" >/dev/null 2>&1 || true
        log_success "Image removed"
    fi
    
    # Clean up temporary files
    rm -f "$SAGE_OS_DIR/Dockerfile.runtime"
    
    log_success "Cleanup completed"
}

# Show container logs
show_logs() {
    if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
        docker logs -f "$CONTAINER_NAME"
    else
        log_error "Container $CONTAINER_NAME is not running"
        exit 1
    fi
}

# Open shell in container
open_shell() {
    if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
        docker exec -it "$CONTAINER_NAME" /bin/bash
    else
        log_error "Container $CONTAINER_NAME is not running"
        exit 1
    fi
}

# Stop container
stop_container() {
    if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
        log_info "Stopping container..."
        docker stop "$CONTAINER_NAME"
        log_success "Container stopped"
    else
        log_warning "Container $CONTAINER_NAME is not running"
    fi
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -a|--arch)
                ARCH="$2"
                shift 2
                ;;
            -m|--mode)
                MODE="$2"
                shift 2
                ;;
            -M|--memory)
                MEMORY="$2"
                shift 2
                ;;
            -d|--display)
                DISPLAY_MODE="$2"
                shift 2
                ;;
            -p|--vnc-port)
                VNC_PORT="$2"
                shift 2
                ;;
            -q|--qemu-port)
                QEMU_MONITOR_PORT="$2"
                shift 2
                ;;
            -v|--verbose)
                set -x
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            build|run|deploy|clean|logs|shell|stop)
                COMMAND="$1"
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Main execution
main() {
    # Set default command if none provided
    COMMAND="${COMMAND:-deploy}"
    
    log_info "SAGE OS Docker Deployment Script"
    log_info "================================"
    
    case "$COMMAND" in
        "build")
            check_dependencies
            build_image
            ;;
        "run")
            check_dependencies
            run_container
            ;;
        "deploy")
            check_dependencies
            build_image
            run_container
            ;;
        "clean")
            clean_docker
            ;;
        "logs")
            show_logs
            ;;
        "shell")
            open_shell
            ;;
        "stop")
            stop_container
            ;;
        *)
            log_error "Unknown command: $COMMAND"
            show_help
            exit 1
            ;;
    esac
}

# Parse arguments and run main function
parse_args "$@"
main

# Show connection information
if [[ "$COMMAND" == "run" || "$COMMAND" == "deploy" ]] && [[ "$DISPLAY_MODE" == "vnc" ]]; then
    echo
    log_success "SAGE OS is starting up!"
    log_info "VNC Connection Details:"
    log_info "  Host: localhost"
    log_info "  Port: $VNC_PORT"
    log_info "  Password: sageos"
    log_info "  URL: vnc://localhost:$VNC_PORT"
    echo
    log_info "QEMU Monitor (for debugging):"
    log_info "  telnet localhost $QEMU_MONITOR_PORT"
    echo
    log_info "To stop the container: docker stop $CONTAINER_NAME"
    log_info "To view logs: $0 logs"
    log_info "To open shell: $0 shell"
fi