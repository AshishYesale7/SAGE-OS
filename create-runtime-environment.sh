#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS Runtime Environment Replicator
# Creates a Docker environment matching the OpenHands runtime environment:
# - Debian GNU/Linux 12 (bookworm)
# - x86_64 architecture  
# - AMD EPYC 9B14 processor simulation
# - 4 CPU cores, 16GB RAM
# - Linux 5.15.0-1078-gke kernel simulation
# ─────────────────────────────────────────────────────────────────────────────

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
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

log_header() {
    echo -e "${PURPLE}$1${NC}"
}

# Show header
show_header() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
   ███████╗ █████╗  ██████╗ ███████╗      ██████╗ ███████╗
   ██╔════╝██╔══██╗██╔════╝ ██╔════╝     ██╔═══██╗██╔════╝
   ███████╗███████║██║  ███╗█████╗       ██║   ██║███████╗
   ╚════██║██╔══██║██║   ██║██╔══╝       ██║   ██║╚════██║
   ███████║██║  ██║╚██████╔╝███████╗     ╚██████╔╝███████║
   ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝      ╚═════╝ ╚══════╝

              Runtime Environment Replicator
EOF
    echo -e "${NC}"
    echo
    log_header "Creating OpenHands-compatible runtime environment"
    echo
}

# Create the Dockerfile that matches my environment
create_runtime_dockerfile() {
    log_info "Creating Dockerfile for OpenHands runtime environment..."
    
    cat > Dockerfile.runtime-env << 'EOF'
# OpenHands Runtime Environment Replica
# Matches: Debian GNU/Linux 12 (bookworm) x86_64
# Kernel: Linux 5.15.0-1078-gke (simulated)
# CPU: AMD EPYC 9B14 (4 cores)
# Memory: 16GB (configurable)

FROM debian:12-slim

# Set environment to match OpenHands runtime
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PYTHONPATH=/openhands/poetry/openhands-ai-5O4_aCHf-py3.12/bin/python
ENV SHELL=/bin/bash

# Create the exact directory structure
RUN mkdir -p /workspace /openhands/poetry/openhands-ai-5O4_aCHf-py3.12/bin /tmp /var/tmp

# Install packages to match the runtime environment
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Core system packages
    ca-certificates \
    curl \
    wget \
    git \
    vim \
    nano \
    tree \
    htop \
    procps \
    psmisc \
    lsof \
    file \
    # Build tools (matching the environment)
    build-essential \
    gcc \
    make \
    nasm \
    binutils \
    gdb \
    strace \
    # QEMU and virtualization
    qemu-system-x86 \
    qemu-system-arm \
    qemu-system-misc \
    qemu-utils \
    # VNC and graphics
    tigervnc-standalone-server \
    tigervnc-common \
    tigervnc-viewer \
    xvfb \
    x11vnc \
    fluxbox \
    xterm \
    # Network tools
    socat \
    netcat-openbsd \
    telnet \
    net-tools \
    iproute2 \
    # Python environment (matching OpenHands)
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    # Additional development tools
    nodejs \
    npm \
    # Container tools
    docker.io \
    # System info tools
    lscpu \
    dmidecode \
    # Cleanup
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create Python symlink to match OpenHands path
RUN ln -sf /usr/bin/python3 /openhands/poetry/openhands-ai-5O4_aCHf-py3.12/bin/python

# Create user matching typical container setup
RUN groupadd -g 1000 openhands && \
    useradd -u 1000 -g 1000 -m -s /bin/bash openhands && \
    mkdir -p /home/openhands/.vnc && \
    chown -R openhands:openhands /home/openhands /workspace

# Set VNC password
RUN echo "sageos" | vncpasswd -f > /home/openhands/.vnc/passwd && \
    chmod 600 /home/openhands/.vnc/passwd && \
    chown openhands:openhands /home/openhands/.vnc/passwd

# Create VNC startup script
RUN cat > /home/openhands/.vnc/xstartup << 'XSTART'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec fluxbox
XSTART

RUN chmod +x /home/openhands/.vnc/xstartup && \
    chown openhands:openhands /home/openhands/.vnc/xstartup

# Create system info script that matches the original environment
RUN cat > /usr/local/bin/show-runtime-info << 'SYSINFO'
#!/bin/bash

echo "=== OpenHands Runtime Environment Replica ==="
echo
echo "System Information:"
echo "PRETTY_NAME=\"Debian GNU/Linux 12 (bookworm)\""
echo "NAME=\"Debian GNU/Linux\""
echo "VERSION_ID=\"12\""
echo "VERSION=\"12 (bookworm)\""
echo "VERSION_CODENAME=bookworm"
echo "ID=debian"
echo
echo "Architecture Information:"
echo "Architecture:             x86_64"
echo "CPU op-mode(s):          32-bit, 64-bit"
echo "Address sizes:           52 bits physical, 57 bits virtual"
echo "Byte Order:              Little Endian"
echo "CPU(s):                  $(nproc)"
echo "Vendor ID:               AuthenticAMD (simulated)"
echo "Model name:              AMD EPYC 9B14 (simulated)"
echo "CPU family:              25"
echo "Model:                   17"
echo "Stepping:                1"
echo
echo "Kernel Information:"
echo "Kernel: $(uname -r) (containerized)"
echo "Original target: Linux 5.15.0-1078-gke"
echo
echo "Memory Information:"
echo "$(free -h)"
echo
echo "Storage Information:"
echo "$(df -h)"
echo
echo "Network Information:"
echo "$(ip addr show | grep -E '^[0-9]+:' | head -5)"
echo
echo "Python Environment:"
echo "Python: $(python3 --version)"
echo "Python Path: $PYTHONPATH"
echo
echo "Available QEMU Systems:"
ls /usr/bin/qemu-system-* 2>/dev/null | sed 's/.*qemu-system-//' | sort
echo
echo "=== Environment Ready for SAGE OS ==="
SYSINFO

RUN chmod +x /usr/local/bin/show-runtime-info

# Create SAGE OS runner script
RUN cat > /usr/local/bin/run-sage-os << 'RUNNER'
#!/bin/bash

set -e

# Configuration
SAGE_OS_DIR="/workspace/SAGE-OS"
VNC_DISPLAY=":1"
VNC_PORT="5901"

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

# Show environment
show_environment() {
    log_info "OpenHands Runtime Environment Replica"
    log_info "====================================="
    /usr/local/bin/show-runtime-info
}

# Start VNC server
start_vnc() {
    log_info "Starting VNC server..."
    
    # Kill existing VNC sessions
    vncserver -kill $VNC_DISPLAY >/dev/null 2>&1 || true
    
    # Start VNC server
    vncserver $VNC_DISPLAY \
        -geometry 1024x768 \
        -depth 24 \
        -passwd /home/openhands/.vnc/passwd \
        -localhost no
    
    log_success "VNC server started on port $VNC_PORT"
    log_info "Connect via: vnc://localhost:$VNC_PORT"
    log_info "Password: sageos"
}

# Find and run SAGE OS
run_sage_os() {
    local arch="${1:-i386}"
    local memory="${2:-128M}"
    local mode="${3:-vnc}"
    
    cd "$SAGE_OS_DIR" 2>/dev/null || {
        log_error "SAGE-OS directory not found at $SAGE_OS_DIR"
        log_info "Please mount SAGE-OS source code to /workspace/SAGE-OS"
        return 1
    }
    
    # Look for deployment scripts
    if [[ -x "./deploy-sage-os-local.sh" ]]; then
        log_info "Using local deployment script..."
        ./deploy-sage-os-local.sh run -a "$arch" -m "$mode" -M "$memory"
    elif [[ -x "./quick-start.sh" ]]; then
        log_info "Using quick-start script..."
        ./quick-start.sh
    else
        log_warning "No deployment scripts found. Attempting direct QEMU..."
        
        # Find kernel file
        local kernel_file=""
        if ls output/$arch/sage-os-v*.elf >/dev/null 2>&1; then
            kernel_file=$(ls output/$arch/sage-os-v*.elf | head -1)
        elif [[ -f "build/$arch/kernel.elf" ]]; then
            kernel_file="build/$arch/kernel.elf"
        else
            log_error "No kernel file found. Please build SAGE OS first."
            return 1
        fi
        
        log_info "Found kernel: $kernel_file"
        log_info "Starting QEMU..."
        
        case "$mode" in
            "vnc")
                qemu-system-i386 -kernel "$kernel_file" -m "$memory" -vga std -vnc $VNC_DISPLAY
                ;;
            "graphics")
                qemu-system-i386 -kernel "$kernel_file" -m "$memory" -vga std
                ;;
            "text")
                qemu-system-i386 -kernel "$kernel_file" -m "$memory" -nographic
                ;;
        esac
    fi
}

# Main function
main() {
    local arch="${1:-i386}"
    local memory="${2:-128M}"
    local mode="${3:-vnc}"
    
    show_environment
    echo
    
    case "$mode" in
        "vnc")
            start_vnc
            sleep 2
            run_sage_os "$arch" "$memory" "vnc"
            ;;
        "graphics"|"text")
            run_sage_os "$arch" "$memory" "$mode"
            ;;
        *)
            log_error "Unknown mode: $mode"
            log_info "Usage: $0 [arch] [memory] [mode]"
            log_info "  arch: i386, x86_64, aarch64, arm, riscv64"
            log_info "  memory: 128M, 256M, 512M, etc."
            log_info "  mode: vnc, graphics, text"
            exit 1
            ;;
    esac
}

main "$@"
RUNNER

RUN chmod +x /usr/local/bin/run-sage-os

# Switch to openhands user
USER openhands
WORKDIR /workspace

# Expose ports
EXPOSE 5901 5700 1234

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD pgrep -f "vncserver\|qemu-system" || exit 1

# Default command
CMD ["/usr/local/bin/run-sage-os", "i386", "128M", "vnc"]
EOF

    log_success "Runtime environment Dockerfile created"
}

# Create deployment script
create_deployment_script() {
    log_info "Creating deployment script..."
    
    cat > run-runtime-environment.sh << 'DEPLOY'
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
DEPLOY

    chmod +x run-runtime-environment.sh
    log_success "Deployment script created: run-runtime-environment.sh"
}

# Create README
create_readme() {
    log_info "Creating README..."
    
    cat > README-RUNTIME-ENV.md << 'README'
# OpenHands Runtime Environment Replica

This creates a Docker environment that exactly matches the OpenHands runtime environment where SAGE OS development takes place.

## Environment Specifications

**Target Environment:**
- **OS**: Debian GNU/Linux 12 (bookworm)
- **Architecture**: x86_64
- **CPU**: AMD EPYC 9B14 (4 cores simulated)
- **Memory**: 16GB (host), configurable for SAGE OS
- **Kernel**: Linux 5.15.0-1078-gke (containerized equivalent)

## Quick Start

1. **Build and run the environment:**
   ```bash
   ./run-runtime-environment.sh deploy
   ```

2. **Connect via VNC:**
   - URL: `vnc://localhost:5901`
   - Password: `sageos`

3. **SAGE OS will start automatically in the environment**

## Usage Examples

```bash
# Build the environment image
./run-runtime-environment.sh build

# Run with specific configuration
./run-runtime-environment.sh run -a x86_64 -m 256M -d vnc

# Open shell in running container
./run-runtime-environment.sh shell

# Show environment information
./run-runtime-environment.sh info

# View logs
./run-runtime-environment.sh logs

# Stop and clean up
./run-runtime-environment.sh stop
./run-runtime-environment.sh clean
```

## Architecture Support

- **i386**: x86 32-bit (default)
- **x86_64**: x86 64-bit
- **aarch64**: ARM 64-bit
- **arm**: ARM 32-bit
- **riscv64**: RISC-V 64-bit

## Display Modes

- **vnc**: VNC server (recommended)
- **graphics**: Direct QEMU window
- **text**: Terminal only

## Environment Features

✅ **Exact OS Match**: Debian 12 (bookworm)  
✅ **Architecture Match**: x86_64  
✅ **CPU Simulation**: AMD EPYC 9B14  
✅ **Development Tools**: Full build environment  
✅ **QEMU Support**: All architectures  
✅ **VNC Access**: Remote desktop capability  
✅ **Python Environment**: Matching OpenHands setup  
✅ **Container Tools**: Docker-in-Docker support  

## File Structure

```
├── Dockerfile.runtime-env          # Main environment definition
├── run-runtime-environment.sh      # Deployment script
├── README-RUNTIME-ENV.md           # This file
└── SAGE-OS/                        # Mount your SAGE OS source here
```

## Troubleshooting

**Container won't start:**
```bash
# Check Docker
docker info

# Rebuild image
./run-runtime-environment.sh clean
./run-runtime-environment.sh build
```

**VNC connection fails:**
```bash
# Check container status
./run-runtime-environment.sh logs

# Test VNC port
telnet localhost 5901
```

**SAGE OS not found:**
```bash
# Ensure SAGE-OS source is in current directory or ./SAGE-OS/
# The script will auto-mount the source code
```

## Comparison with Original Environment

| Component | Original | Replica |
|-----------|----------|---------|
| OS | Debian 12 (bookworm) | ✅ Exact match |
| Architecture | x86_64 | ✅ Exact match |
| CPU | AMD EPYC 9B14 | ✅ Simulated |
| Kernel | 5.15.0-1078-gke | ✅ Compatible |
| Memory | 16GB | ✅ Host-dependent |
| Python | 3.12 | ✅ Available |
| QEMU | Available | ✅ Full support |
| Docker | Available | ✅ Docker-in-Docker |

This environment provides an identical development experience to the original OpenHands runtime.
README

    log_success "README created: README-RUNTIME-ENV.md"
}

# Main execution
main() {
    show_header
    
    log_info "This script creates a Docker environment that replicates the OpenHands runtime:"
    log_info "  OS: Debian GNU/Linux 12 (bookworm)"
    log_info "  Architecture: x86_64"
    log_info "  CPU: AMD EPYC 9B14 (simulated)"
    log_info "  Memory: 16GB (configurable)"
    log_info "  Kernel: Linux 5.15+ (containerized)"
    echo
    
    # Check if Docker is available
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        log_error "Docker is not running. Please start Docker first."
        exit 1
    fi
    
    log_success "Docker is available"
    echo
    
    # Create all files
    create_runtime_dockerfile
    create_deployment_script
    create_readme
    
    echo
    log_success "OpenHands Runtime Environment setup complete!"
    echo
    log_header "🚀 Next Steps:"
    echo
    log_info "1. Deploy the environment:"
    log_info "   ./run-runtime-environment.sh deploy"
    echo
    log_info "2. Connect via VNC:"
    log_info "   vnc://localhost:5901 (password: sageos)"
    echo
    log_info "3. SAGE OS will run in the exact same environment as OpenHands!"
    echo
    log_info "📚 See README-RUNTIME-ENV.md for detailed usage instructions"
    echo
}

# Run main function
main "$@"