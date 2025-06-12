#!/bin/bash

# OpenHands Runtime Environment Deployment Script

set -e

# Configuration
IMAGE_NAME="sage-os-runtime-env"
CONTAINER_NAME="sage-os-runtime"
VNC_PORT="5901"
QEMU_PORT="1234"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

show_help() {
    cat << EOF
OpenHands Runtime Environment for SAGE OS

Usage: $0 [COMMAND] [OPTIONS]

Commands:
    build       Build the runtime environment image
    run         Run SAGE OS in the runtime environment
    deploy      Build and run (default)
    shell       Open shell in running container
    logs        Show container logs
    stop        Stop the container
    clean       Remove container and image
    info        Show environment information

Options:
    -a, --arch ARCH     Architecture (i386, x86_64, aarch64, arm, riscv64)
    -m, --memory MEM    Memory allocation (128M, 256M, 512M, etc.)
    -d, --display MODE  Display mode (vnc, graphics, text)
    -p, --port PORT     VNC port (default: 5901)
    -v, --verbose       Verbose output
    -h, --help          Show this help

Examples:
    $0 deploy                    # Build and run with defaults
    $0 run -a x86_64 -m 256M    # Run x86_64 with 256MB RAM
    $0 shell                    # Open shell in container
    $0 info                     # Show environment info

Connection:
    VNC: vnc://localhost:5901 (password: sageos)
    Monitor: telnet localhost:1234

EOF
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        log_error "Docker is not running"
        exit 1
    fi
}

build_image() {
    log_info "Building OpenHands runtime environment image..."
    
    if docker build -f Dockerfile.runtime-env -t "$IMAGE_NAME" .; then
        log_success "Image built successfully: $IMAGE_NAME"
        docker images "$IMAGE_NAME" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
    else
        log_error "Failed to build image"
        exit 1
    fi
}

run_container() {
    local arch="${ARCH:-i386}"
    local memory="${MEMORY:-128M}"
    local display="${DISPLAY_MODE:-vnc}"
    
    log_info "Running SAGE OS in OpenHands runtime environment"
    log_info "Architecture: $arch, Memory: $memory, Display: $display"
    
    # Stop existing container
    docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
    docker rm "$CONTAINER_NAME" >/dev/null 2>&1 || true
    
    # Prepare arguments
    local docker_args=(
        "--name" "$CONTAINER_NAME"
        "--rm"
        "-it"
        "-p" "$VNC_PORT:5901"
        "-p" "5700:5700"
        "-p" "$QEMU_PORT:1234"
        "--cap-add" "SYS_PTRACE"
        "--security-opt" "seccomp=unconfined"
    )
    
    # Mount SAGE-OS source if available
    if [[ -d "./SAGE-OS" ]]; then
        docker_args+=("-v" "$(pwd)/SAGE-OS:/workspace/SAGE-OS:rw")
        log_info "Mounting SAGE-OS source code"
    elif [[ -d "." ]] && [[ -f "./Makefile" || -f "./deploy-sage-os.sh" ]]; then
        docker_args+=("-v" "$(pwd):/workspace/SAGE-OS:rw")
        log_info "Mounting current directory as SAGE-OS"
    else
        log_warning "No SAGE-OS source found. Container will run without source code."
    fi
    
    log_info "Starting container..."
    docker run "${docker_args[@]}" "$IMAGE_NAME" \
        /usr/local/bin/run-sage-os "$arch" "$memory" "$display"
}

# Parse arguments
ARCH=""
MEMORY=""
DISPLAY_MODE=""
COMMAND="deploy"

while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--arch) ARCH="$2"; shift 2 ;;
        -m|--memory) MEMORY="$2"; shift 2 ;;
        -d|--display) DISPLAY_MODE="$2"; shift 2 ;;
        -p|--port) VNC_PORT="$2"; shift 2 ;;
        -v|--verbose) set -x; shift ;;
        -h|--help) show_help; exit 0 ;;
        build|run|deploy|shell|logs|stop|clean|info) COMMAND="$1"; shift ;;
        *) log_error "Unknown option: $1"; show_help; exit 1 ;;
    esac
done

# Main execution
check_docker

case "$COMMAND" in
    "build")
        build_image
        ;;
    "run")
        run_container
        ;;
    "deploy")
        build_image
        run_container
        ;;
    "shell")
        if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
            docker exec -it "$CONTAINER_NAME" /bin/bash
        else
            log_error "Container not running. Start with: $0 run"
        fi
        ;;
    "logs")
        docker logs -f "$CONTAINER_NAME" 2>/dev/null || log_error "Container not found"
        ;;
    "stop")
        docker stop "$CONTAINER_NAME" >/dev/null 2>&1 && log_success "Container stopped" || log_warning "Container not running"
        ;;
    "clean")
        docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
        docker rm "$CONTAINER_NAME" >/dev/null 2>&1 || true
        docker rmi "$IMAGE_NAME" >/dev/null 2>&1 && log_success "Cleaned up" || log_warning "Nothing to clean"
        ;;
    "info")
        if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
            docker exec "$CONTAINER_NAME" /usr/local/bin/show-runtime-info
        else
            log_info "Container not running. Expected environment:"
            echo "OS: Debian GNU/Linux 12 (bookworm)"
            echo "Architecture: x86_64"
            echo "CPU: AMD EPYC 9B14 (simulated)"
            echo "Memory: 16GB (host), configurable for SAGE OS"
        fi
        ;;
    *)
        log_error "Unknown command: $COMMAND"
        show_help
        exit 1
        ;;
esac

# Show connection info for deploy/run
if [[ "$COMMAND" == "deploy" || "$COMMAND" == "run" ]]; then
    echo
    log_success "OpenHands Runtime Environment is ready!"
    echo
    log_info "Environment Details:"
    log_info "  OS: Debian GNU/Linux 12 (bookworm)"
    log_info "  Architecture: x86_64"
    log_info "  CPU: AMD EPYC 9B14 (simulated)"
    log_info "  Container: $CONTAINER_NAME"
    echo
    log_info "VNC Connection:"
    log_info "  URL: vnc://localhost:$VNC_PORT"
    log_info "  Password: sageos"
    echo
    log_info "Management:"
    log_info "  Shell: $0 shell"
    log_info "  Logs: $0 logs"
    log_info "  Stop: $0 stop"
    log_info "  Info: $0 info"
fi
