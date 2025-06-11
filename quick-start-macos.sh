#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS Quick Start for macOS M1 with Docker Desktop
# ─────────────────────────────────────────────────────────────────────────────

set -e

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

# ASCII Art Header
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

                    macOS M1 Quick Start
EOF
    echo -e "${NC}"
    echo
    log_header "Welcome to SAGE OS Docker Deployment for macOS M1!"
    echo
}

# Check macOS and Docker Desktop
check_macos_setup() {
    log_info "Checking macOS M1 setup..."
    
    # Check if running on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "This script is designed for macOS. Use the regular quick-start.sh instead."
        exit 1
    fi
    
    # Check if running on Apple Silicon
    if [[ $(uname -m) != "arm64" ]]; then
        log_warning "This script is optimized for Apple Silicon (M1/M2). It may work on Intel Macs too."
    else
        log_success "Running on Apple Silicon (M1/M2)"
    fi
    
    # Check Docker Desktop
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed or not in PATH"
        log_info "Please install Docker Desktop for Mac from: https://www.docker.com/products/docker-desktop"
        exit 1
    fi
    
    # Check if Docker Desktop is running
    if ! docker info &> /dev/null; then
        log_error "Docker Desktop is not running"
        log_info "Please start Docker Desktop and try again"
        exit 1
    fi
    
    log_success "Docker Desktop is running"
    
    # Check for VNC viewer
    if command -v open &> /dev/null; then
        log_success "Built-in Screen Sharing available"
    else
        log_warning "Consider installing a VNC viewer like RealVNC or TigerVNC"
    fi
}

# Show deployment options
show_deployment_options() {
    echo
    log_header "Deployment Options for macOS M1:"
    echo
    echo "1) 🖥️  VNC Mode (Recommended) - Best for macOS with built-in Screen Sharing"
    echo "2) 🏗️  ARM64 Native - Run on native Apple Silicon architecture"
    echo "3) 🔧 i386 Emulation - Traditional x86 emulation (slower but compatible)"
    echo "4) 📱 Text Mode - Terminal-only interface"
    echo "5) ⚙️  Custom Configuration"
    echo "6) 🧪 Test Setup"
    echo "7) ❌ Exit"
    echo
}

# VNC Mode deployment
deploy_vnc_mode() {
    local arch="${1:-aarch64}"
    local port="${2:-5901}"
    
    log_info "Deploying SAGE OS in VNC mode..."
    log_info "Architecture: $arch"
    log_info "VNC Port: $port"
    
    # Run the deployment
    ./deploy-sage-os.sh deploy -d vnc -a "$arch" -p "$port"
    
    if [[ $? -eq 0 ]]; then
        echo
        log_success "SAGE OS is starting up!"
        echo
        log_header "🔗 Connection Instructions:"
        echo
        log_info "Method 1 - Built-in Screen Sharing (Recommended):"
        log_info "  1. Press Cmd+Space and type 'Screen Sharing'"
        log_info "  2. Enter: vnc://localhost:$port"
        log_info "  3. Password: sageos"
        echo
        log_info "Method 2 - Safari/Chrome:"
        log_info "  1. Open browser and go to: vnc://localhost:$port"
        log_info "  2. Password: sageos"
        echo
        log_info "Method 3 - Command Line:"
        log_info "  open vnc://localhost:$port"
        echo
        log_warning "Wait 30-60 seconds for SAGE OS to fully boot before connecting"
        echo
        
        # Ask if user wants to auto-open VNC
        read -p "Would you like to automatically open Screen Sharing? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Opening Screen Sharing..."
            sleep 5  # Give container time to start
            open "vnc://localhost:$port" || log_warning "Could not auto-open VNC. Please connect manually."
        fi
    fi
}

# ARM64 Native deployment
deploy_arm64_native() {
    log_info "Deploying SAGE OS with ARM64 native architecture..."
    log_info "This runs natively on your Apple Silicon processor"
    
    deploy_vnc_mode "aarch64" "5901"
}

# i386 Emulation deployment
deploy_i386_emulation() {
    log_info "Deploying SAGE OS with i386 emulation..."
    log_info "This emulates x86 architecture (may be slower)"
    
    deploy_vnc_mode "i386" "5902"
}

# Text mode deployment
deploy_text_mode() {
    log_info "Deploying SAGE OS in text mode..."
    log_warning "This will run in terminal only - no graphics"
    
    read -p "Continue with text mode? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./deploy-sage-os.sh deploy -d text -a aarch64
    fi
}

# Custom configuration
deploy_custom() {
    echo
    log_header "Custom Configuration:"
    echo
    
    # Architecture selection
    echo "Select architecture:"
    echo "1) aarch64 (ARM64 - Native on M1)"
    echo "2) i386 (x86 - Emulated)"
    echo "3) x86_64 (x86_64 - Emulated)"
    echo "4) arm (ARM32 - Emulated)"
    echo "5) riscv64 (RISC-V - Emulated)"
    read -p "Choose architecture (1-5): " arch_choice
    
    case $arch_choice in
        1) ARCH="aarch64" ;;
        2) ARCH="i386" ;;
        3) ARCH="x86_64" ;;
        4) ARCH="arm" ;;
        5) ARCH="riscv64" ;;
        *) ARCH="aarch64" ;;
    esac
    
    # Display mode selection
    echo
    echo "Select display mode:"
    echo "1) VNC (Recommended for macOS)"
    echo "2) Text (Terminal only)"
    read -p "Choose display mode (1-2): " display_choice
    
    case $display_choice in
        1) DISPLAY_MODE="vnc" ;;
        2) DISPLAY_MODE="text" ;;
        *) DISPLAY_MODE="vnc" ;;
    esac
    
    # VNC port selection (if VNC mode)
    if [[ "$DISPLAY_MODE" == "vnc" ]]; then
        read -p "Enter VNC port (default 5901): " vnc_port
        VNC_PORT="${vnc_port:-5901}"
    fi
    
    # Memory selection
    read -p "Enter memory allocation (default 128M): " memory
    MEMORY="${memory:-128M}"
    
    echo
    log_info "Configuration Summary:"
    log_info "  Architecture: $ARCH"
    log_info "  Display Mode: $DISPLAY_MODE"
    if [[ "$DISPLAY_MODE" == "vnc" ]]; then
        log_info "  VNC Port: $VNC_PORT"
    fi
    log_info "  Memory: $MEMORY"
    echo
    
    read -p "Proceed with this configuration? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [[ "$DISPLAY_MODE" == "vnc" ]]; then
            ./deploy-sage-os.sh deploy -d vnc -a "$ARCH" -p "$VNC_PORT" -M "$MEMORY"
        else
            ./deploy-sage-os.sh deploy -d text -a "$ARCH" -M "$MEMORY"
        fi
    fi
}

# Test setup
test_setup() {
    log_info "Testing SAGE OS setup..."
    
    # Test Docker
    log_info "Testing Docker..."
    if docker run --rm hello-world &> /dev/null; then
        log_success "Docker is working correctly"
    else
        log_error "Docker test failed"
        return 1
    fi
    
    # Test deployment script
    log_info "Testing deployment script..."
    if [[ -x "./deploy-sage-os.sh" ]]; then
        log_success "Deployment script is executable"
    else
        log_error "Deployment script not found or not executable"
        return 1
    fi
    
    # Test local script
    log_info "Testing local deployment script..."
    if [[ -x "./deploy-sage-os-local.sh" ]]; then
        log_success "Local deployment script is available"
        
        # Test QEMU availability
        if ./deploy-sage-os-local.sh test &> /dev/null; then
            log_success "QEMU is available for local testing"
        else
            log_warning "QEMU not available locally (Docker mode only)"
        fi
    else
        log_warning "Local deployment script not found"
    fi
    
    log_success "Setup test completed!"
    echo
    log_info "You can now deploy SAGE OS using the menu options."
}

# Show management options
show_management_menu() {
    echo
    log_header "SAGE OS Management:"
    echo
    echo "1) 📊 View Container Logs"
    echo "2) 🐚 Open Container Shell"
    echo "3) ⏹️  Stop Container"
    echo "4) 🧹 Clean Up (Remove containers and images)"
    echo "5) 🔙 Back to Main Menu"
    echo
}

# Management functions
manage_containers() {
    while true; do
        show_management_menu
        read -p "Choose an option (1-5): " mgmt_choice
        
        case $mgmt_choice in
            1)
                log_info "Showing container logs..."
                ./deploy-sage-os.sh logs
                ;;
            2)
                log_info "Opening container shell..."
                ./deploy-sage-os.sh shell
                ;;
            3)
                log_info "Stopping container..."
                ./deploy-sage-os.sh stop
                ;;
            4)
                log_warning "This will remove all SAGE OS containers and images"
                read -p "Are you sure? (y/n): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    ./deploy-sage-os.sh clean
                fi
                ;;
            5)
                break
                ;;
            *)
                log_error "Invalid option. Please choose 1-5."
                ;;
        esac
        echo
        read -p "Press Enter to continue..."
    done
}

# Main menu loop
main_menu() {
    while true; do
        show_header
        show_deployment_options
        
        read -p "Choose an option (1-7): " choice
        
        case $choice in
            1)
                deploy_vnc_mode "aarch64" "5901"
                ;;
            2)
                deploy_arm64_native
                ;;
            3)
                deploy_i386_emulation
                ;;
            4)
                deploy_text_mode
                ;;
            5)
                deploy_custom
                ;;
            6)
                test_setup
                ;;
            7)
                log_info "Thank you for using SAGE OS!"
                exit 0
                ;;
            8)
                manage_containers
                ;;
            *)
                log_error "Invalid option. Please choose 1-7."
                ;;
        esac
        
        echo
        read -p "Press Enter to return to main menu..."
    done
}

# Main execution
main() {
    # Check if we're in the right directory
    if [[ ! -f "./deploy-sage-os.sh" ]]; then
        log_error "deploy-sage-os.sh not found in current directory"
        log_info "Please run this script from the SAGE-OS directory"
        exit 1
    fi
    
    # Make sure scripts are executable
    chmod +x ./deploy-sage-os.sh 2>/dev/null || true
    chmod +x ./deploy-sage-os-local.sh 2>/dev/null || true
    
    # Check macOS setup
    check_macos_setup
    
    # Show main menu
    main_menu
}

# Run main function
main "$@"