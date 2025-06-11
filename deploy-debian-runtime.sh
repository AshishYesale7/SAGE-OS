#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS Debian Runtime Deployment Script
# Matches the exact runtime environment: Debian GNU/Linux 12 (bookworm) x86_64
# ─────────────────────────────────────────────────────────────────────────────

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SAGE_OS_DIR="$SCRIPT_DIR"

# Docker configuration
DOCKER_IMAGE_NAME="sage-os-debian"
DOCKER_TAG="bookworm"
CONTAINER_NAME="sage-os-runtime"

# Default values
ARCH="i386"
MEMORY="128M"
DISPLAY_MODE="vnc"
VNC_PORT="5901"
QEMU_MONITOR_PORT="1234"

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

log_header() {
    echo -e "${PURPLE}$1${NC}"
}

# Show help
show_help() {
    cat << EOF
SAGE OS Debian Runtime Deployment Script

This script creates a Docker environment that matches the exact runtime:
- Debian GNU/Linux 12 (bookworm)
- x86_64 architecture
- AMD EPYC processor emulation
- 4 CPU cores, 16GB RAM simulation

Usage: $0 [COMMAND] [OPTIONS]

Commands:
    build       Build the Debian runtime Docker image
    run         Run SAGE OS in the Debian runtime
    deploy      Build and run (default)
    shell       Open shell in running container
    logs        Show container logs
    stop        Stop running container
    clean       Remove container and image
    env         Show environment information
    test        Test the deployment

Options:
    -a, --arch ARCH         Target architecture (i386, x86_64, aarch64, arm, riscv64) [default: i386]
    -m, --memory MEMORY     Memory allocation [default: 128M]
    -d, --display MODE      Display mode (vnc, text, graphics) [default: vnc]
    -p, --vnc-port PORT     VNC port [default: 5901]
    -q, --qemu-port PORT    QEMU monitor port [default: 1234]
    -v, --verbose           Enable verbose output
    -h, --help              Show this help message

Examples:
    $0 deploy                           # Build and run with defaults
    $0 run -a x86_64 -m 256M           # Run x86_64 with 256MB RAM
    $0 deploy -d vnc -p 5902           # Deploy with VNC on port 5902
    $0 shell                           # Open shell in running container
    $0 env                             # Show environment information

VNC Connection:
    Host: localhost
    Port: $VNC_PORT
    Password: sageos
    URL: vnc://localhost:$VNC_PORT

EOF
}

# Check dependencies
check_dependencies() {
    log_info "Checking dependencies..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install Docker first."
        return 1
    fi
    
    # Check if Docker daemon is running
    if ! docker info &> /dev/null; then
        log_error "Docker daemon is not running. Please start Docker."
        return 1
    fi
    
    log_success "Dependencies check passed"
}

# Build Debian runtime image
build_image() {
    log_info "Building SAGE OS Debian Runtime image..."
    log_info "Target environment: Debian GNU/Linux 12 (bookworm) x86_64"
    
    cd "$SAGE_OS_DIR"
    
    # Build the image
    log_info "Building Docker image with Debian 12 base..."
    if docker build -f Dockerfile.debian -t "$DOCKER_IMAGE_NAME:$DOCKER_TAG" .; then
        log_success "Docker image built successfully: $DOCKER_IMAGE_NAME:$DOCKER_TAG"
        
        # Show image information
        log_info "Image details:"
        docker images "$DOCKER_IMAGE_NAME:$DOCKER_TAG" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
    else
        log_error "Failed to build Docker image"
        return 1
    fi
}

# Run SAGE OS container
run_container() {
    log_info "Running SAGE OS in Debian runtime environment"
    log_info "Architecture: $ARCH, Memory: $MEMORY, Display: $DISPLAY_MODE"
    
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
        "--cap-add" "SYS_PTRACE"  # For debugging
        "--security-opt" "seccomp=unconfined"  # For QEMU
    )
    
    # Add volume mounts for development
    if [[ -d "$SAGE_OS_DIR" ]]; then
        DOCKER_ARGS+=("-v" "$SAGE_OS_DIR:/workspace/sage-os:rw")
    fi
    
    # Add environment variables to match runtime
    DOCKER_ARGS+=(
        "-e" "DEBIAN_FRONTEND=noninteractive"
        "-e" "TZ=UTC"
        "-e" "LANG=C.UTF-8"
        "-e" "LC_ALL=C.UTF-8"
    )
    
    # Run the container
    log_info "Starting container with the following configuration:"
    log_info "  Container: $CONTAINER_NAME"
    log_info "  Image: $DOCKER_IMAGE_NAME:$DOCKER_TAG"
    log_info "  Architecture: $ARCH"
    log_info "  Memory: $MEMORY"
    log_info "  Display Mode: $DISPLAY_MODE"
    log_info "  VNC Port: $VNC_PORT"
    log_info "  Monitor Port: $QEMU_MONITOR_PORT"
    echo
    
    # Execute container
    docker run "${DOCKER_ARGS[@]}" "$DOCKER_IMAGE_NAME:$DOCKER_TAG" \
        /usr/local/bin/sage-os-runner "$ARCH" "$MEMORY" "$DISPLAY_MODE"
}

# Show environment information
show_environment() {
    log_header "SAGE OS Debian Runtime Environment"
    echo
    
    if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
        log_info "Container is running. Environment details:"
        docker exec "$CONTAINER_NAME" /usr/local/bin/show-env
    else
        log_info "Container is not running. Expected environment:"
        echo "OS: Debian GNU/Linux 12 (bookworm)"
        echo "Architecture: x86_64"
        echo "Kernel: Linux 5.15+ (container)"
        echo "CPU: AMD EPYC emulation"
        echo "Memory: Configurable (default 128M for SAGE OS)"
        echo "Storage: Container filesystem + mounted volumes"
        echo
        log_info "To see live environment, start the container first:"
        log_info "  $0 run"
    fi
}

# Open shell in container
open_shell() {
    if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
        log_info "Opening shell in container..."
        docker exec -it "$CONTAINER_NAME" /bin/bash
    else
        log_error "Container $CONTAINER_NAME is not running"
        log_info "Start the container first: $0 run"
        exit 1
    fi
}

# Show container logs
show_logs() {
    if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
        log_info "Showing container logs..."
        docker logs -f "$CONTAINER_NAME"
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
    
    log_success "Cleanup completed"
}

# Test deployment
test_deployment() {
    log_info "Testing SAGE OS Debian runtime deployment..."
    
    # Test Docker
    if ! check_dependencies; then
        return 1
    fi
    
    # Test image build
    log_info "Testing image build..."
    if build_image; then
        log_success "Image build test passed"
    else
        log_error "Image build test failed"
        return 1
    fi
    
    # Test container startup (quick test)
    log_info "Testing container startup..."
    if docker run --rm "$DOCKER_IMAGE_NAME:$DOCKER_TAG" /usr/local/bin/show-env; then
        log_success "Container startup test passed"
    else
        log_error "Container startup test failed"
        return 1
    fi
    
    log_success "All tests passed!"
    echo
    log_info "You can now deploy SAGE OS with:"
    log_info "  $0 deploy"
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -a|--arch)
                ARCH="$2"
                shift 2
                ;;
            -m|--memory)
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
            build|run|deploy|shell|logs|stop|clean|env|test)
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
    
    log_header "SAGE OS Debian Runtime Deployment"
    log_info "Targeting: Debian GNU/Linux 12 (bookworm) x86_64"
    log_info "=================================="
    
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
        "shell")
            open_shell
            ;;
        "logs")
            show_logs
            ;;
        "stop")
            stop_container
            ;;
        "clean")
            clean_docker
            ;;
        "env")
            show_environment
            ;;
        "test")
            test_deployment
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
    log_success "SAGE OS is starting in Debian runtime environment!"
    echo
    log_header "🔗 Connection Details:"
    log_info "VNC Connection:"
    log_info "  Host: localhost"
    log_info "  Port: $VNC_PORT"
    log_info "  Password: sageos"
    log_info "  URL: vnc://localhost:$VNC_PORT"
    echo
    log_info "QEMU Monitor (for debugging):"
    log_info "  telnet localhost $QEMU_MONITOR_PORT"
    echo
    log_info "Container Management:"
    log_info "  View logs: $0 logs"
    log_info "  Open shell: $0 shell"
    log_info "  Stop container: $0 stop"
    log_info "  Environment info: $0 env"
    echo
    log_info "Environment matches your runtime:"
    log_info "  OS: Debian GNU/Linux 12 (bookworm)"
    log_info "  Arch: x86_64"
    log_info "  Kernel: Linux 5.15+ (containerized)"
fi