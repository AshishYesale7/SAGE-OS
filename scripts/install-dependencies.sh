#!/bin/bash

# SAGE-OS Dependency Installation Script
# Automatically installs all required dependencies for SAGE-OS development

set -e

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

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/debian_version ]; then
            OS="debian"
            if grep -q "Ubuntu" /etc/os-release; then
                OS="ubuntu"
            fi
        elif [ -f /etc/redhat-release ]; then
            OS="redhat"
        elif [ -f /etc/arch-release ]; then
            OS="arch"
        else
            OS="linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        OS="windows"
    else
        OS="unknown"
    fi
    
    log_info "Detected OS: $OS"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install dependencies for Ubuntu/Debian
install_debian_deps() {
    log_info "Installing dependencies for Debian/Ubuntu..."
    
    # Update package manager
    sudo apt update
    
    # Install build essentials
    sudo apt install -y \
        build-essential \
        git \
        curl \
        wget \
        make \
        cmake \
        autoconf \
        automake \
        libtool \
        pkg-config
    
    # Install cross-compilation toolchains
    sudo apt install -y \
        gcc-aarch64-linux-gnu \
        gcc-arm-linux-gnueabihf \
        gcc-riscv64-linux-gnu \
        gcc-multilib \
        binutils-aarch64-linux-gnu \
        binutils-arm-linux-gnueabihf \
        binutils-riscv64-linux-gnu
    
    # Install image creation tools
    sudo apt install -y \
        genisoimage \
        dosfstools \
        mtools \
        xorriso \
        isolinux \
        syslinux-utils
    
    # Install QEMU emulators
    sudo apt install -y \
        qemu-system-x86 \
        qemu-system-arm \
        qemu-system-misc \
        qemu-utils
    
    # Install Docker
    if ! command_exists docker; then
        log_info "Installing Docker..."
        sudo apt install -y docker.io
        sudo systemctl start docker
        sudo systemctl enable docker
        sudo usermod -aG docker $USER
        log_warning "Please log out and back in for Docker group membership to take effect"
    fi
    
    # Install Python and security tools
    sudo apt install -y \
        python3 \
        python3-pip \
        python3-venv
    
    pip3 install --user cve-bin-tool
    
    # Install development tools
    sudo apt install -y \
        tmux \
        tree \
        htop \
        vim \
        nano \
        jq \
        csvtool
    
    log_success "Debian/Ubuntu dependencies installed successfully"
}

# Install dependencies for macOS
install_macos_deps() {
    log_info "Installing dependencies for macOS..."
    
    # Check if Homebrew is installed
    if ! command_exists brew; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Install cross-compilation toolchains
    brew install \
        aarch64-elf-gcc \
        arm-none-eabi-gcc \
        riscv64-elf-gcc
    
    # Install build tools
    brew install \
        make \
        cmake \
        autoconf \
        automake \
        libtool \
        pkg-config
    
    # Install image creation tools
    brew install \
        cdrtools \
        dosfstools
    
    # Install QEMU
    brew install qemu
    
    # Install Docker Desktop
    if ! command_exists docker; then
        log_info "Installing Docker Desktop..."
        brew install --cask docker
        log_warning "Please start Docker Desktop application manually"
    fi
    
    # Install Python and security tools
    brew install python3
    pip3 install cve-bin-tool
    
    # Install development tools
    brew install \
        tmux \
        tree \
        htop \
        vim \
        jq
    
    log_success "macOS dependencies installed successfully"
}

# Install dependencies for Red Hat/Fedora/CentOS
install_redhat_deps() {
    log_info "Installing dependencies for Red Hat/Fedora/CentOS..."
    
    # Install development tools
    sudo dnf groupinstall -y "Development Tools"
    sudo dnf install -y \
        git \
        curl \
        wget \
        make \
        cmake \
        autoconf \
        automake \
        libtool \
        pkg-config
    
    # Install cross-compilation toolchains
    sudo dnf install -y \
        gcc-aarch64-linux-gnu \
        gcc-arm-linux-gnu \
        gcc-riscv64-linux-gnu \
        binutils-aarch64-linux-gnu \
        binutils-arm-linux-gnu \
        binutils-riscv64-linux-gnu
    
    # Install image tools
    sudo dnf install -y \
        genisoimage \
        dosfstools \
        mtools
    
    # Install QEMU
    sudo dnf install -y \
        qemu-system-x86 \
        qemu-system-arm \
        qemu-system-riscv
    
    # Install Docker
    if ! command_exists docker; then
        log_info "Installing Docker..."
        sudo dnf install -y docker
        sudo systemctl start docker
        sudo systemctl enable docker
        sudo usermod -aG docker $USER
    fi
    
    # Install Python and security tools
    sudo dnf install -y \
        python3 \
        python3-pip
    
    pip3 install --user cve-bin-tool
    
    # Install development tools
    sudo dnf install -y \
        tmux \
        tree \
        htop \
        vim \
        jq
    
    log_success "Red Hat/Fedora/CentOS dependencies installed successfully"
}

# Install dependencies for Arch Linux
install_arch_deps() {
    log_info "Installing dependencies for Arch Linux..."
    
    # Update package database
    sudo pacman -Syu --noconfirm
    
    # Install base development tools
    sudo pacman -S --noconfirm \
        base-devel \
        git \
        curl \
        wget \
        make \
        cmake \
        autoconf \
        automake \
        libtool \
        pkg-config
    
    # Install cross-compilation toolchains
    sudo pacman -S --noconfirm \
        aarch64-linux-gnu-gcc \
        arm-linux-gnueabihf-gcc \
        riscv64-linux-gnu-gcc
    
    # Install image tools
    sudo pacman -S --noconfirm \
        cdrtools \
        dosfstools \
        mtools
    
    # Install QEMU
    sudo pacman -S --noconfirm \
        qemu-system-x86 \
        qemu-system-arm \
        qemu-system-riscv
    
    # Install Docker
    if ! command_exists docker; then
        log_info "Installing Docker..."
        sudo pacman -S --noconfirm docker
        sudo systemctl start docker
        sudo systemctl enable docker
        sudo usermod -aG docker $USER
    fi
    
    # Install Python and security tools
    sudo pacman -S --noconfirm \
        python \
        python-pip
    
    pip install --user cve-bin-tool
    
    # Install development tools
    sudo pacman -S --noconfirm \
        tmux \
        tree \
        htop \
        vim \
        jq
    
    log_success "Arch Linux dependencies installed successfully"
}

# Verify installations
verify_installation() {
    log_info "Verifying installations..."
    
    local errors=0
    
    # Check cross-compilation toolchains
    for tool in aarch64-linux-gnu-gcc arm-linux-gnueabihf-gcc riscv64-linux-gnu-gcc; do
        if command_exists $tool; then
            log_success "$tool: $(${tool} --version | head -n1)"
        else
            log_error "$tool: Not found"
            ((errors++))
        fi
    done
    
    # Check QEMU
    for qemu in qemu-system-x86_64 qemu-system-aarch64 qemu-system-arm qemu-system-riscv64; do
        if command_exists $qemu; then
            log_success "$qemu: $(${qemu} --version | head -n1)"
        else
            log_error "$qemu: Not found"
            ((errors++))
        fi
    done
    
    # Check Docker
    if command_exists docker; then
        log_success "Docker: $(docker --version)"
        if docker run hello-world >/dev/null 2>&1; then
            log_success "Docker: hello-world test passed"
        else
            log_warning "Docker: hello-world test failed (may need to restart session)"
        fi
    else
        log_error "Docker: Not found"
        ((errors++))
    fi
    
    # Check security tools
    if command_exists cve-bin-tool; then
        log_success "CVE-bin-tool: $(cve-bin-tool --version 2>/dev/null | head -n1 || echo 'Installed')"
    else
        log_error "CVE-bin-tool: Not found"
        ((errors++))
    fi
    
    # Check development tools
    for tool in tmux tree htop jq; do
        if command_exists $tool; then
            log_success "$tool: Available"
        else
            log_warning "$tool: Not found (optional)"
        fi
    done
    
    if [ $errors -eq 0 ]; then
        log_success "All critical dependencies verified successfully!"
        return 0
    else
        log_error "$errors critical dependencies missing"
        return 1
    fi
}

# Create development environment setup
setup_dev_environment() {
    log_info "Setting up development environment..."
    
    # Create necessary directories
    mkdir -p build/{i386,x86_64,aarch64,arm,riscv64}
    mkdir -p build/{iso,sdcard}
    mkdir -p docs
    mkdir -p scripts
    mkdir -p security-reports
    
    # Set up git hooks (if in git repository)
    if [ -d .git ]; then
        log_info "Setting up git hooks..."
        cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Pre-commit hook for SAGE-OS
echo "Running pre-commit checks..."

# Check for build errors
if ! ./build.sh build-all >/dev/null 2>&1; then
    echo "Build failed! Please fix build errors before committing."
    exit 1
fi

echo "Pre-commit checks passed."
EOF
        chmod +x .git/hooks/pre-commit
    fi
    
    # Create tmux configuration for development
    cat > ~/.tmux-sage-os.conf << 'EOF'
# SAGE-OS tmux configuration
set -g prefix C-a
unbind C-b
bind C-a send-prefix

# Split panes
bind | split-window -h
bind - split-window -v

# Reload config
bind r source-file ~/.tmux.conf \; display "Config reloaded!"

# Mouse support
set -g mouse on

# Status bar
set -g status-bg blue
set -g status-fg white
set -g status-left '#[fg=green]#H '
set -g status-right '#[fg=yellow]%Y-%m-%d %H:%M'
EOF
    
    log_success "Development environment setup complete"
}

# Update CVE database
update_cve_database() {
    log_info "Updating CVE database..."
    if command_exists cve-bin-tool; then
        cve-bin-tool --update || log_warning "CVE database update failed"
        log_success "CVE database updated"
    else
        log_warning "CVE-bin-tool not found, skipping database update"
    fi
}

# Main installation function
main() {
    echo "🚀 SAGE-OS Dependency Installation Script"
    echo "=========================================="
    
    detect_os
    
    case $OS in
        ubuntu|debian)
            install_debian_deps
            ;;
        macos)
            install_macos_deps
            ;;
        redhat)
            install_redhat_deps
            ;;
        arch)
            install_arch_deps
            ;;
        *)
            log_error "Unsupported operating system: $OS"
            log_info "Please install dependencies manually using the Developer Guide"
            exit 1
            ;;
    esac
    
    setup_dev_environment
    update_cve_database
    
    echo ""
    echo "🔍 Verification Results:"
    echo "========================"
    if verify_installation; then
        echo ""
        log_success "🎉 Installation completed successfully!"
        echo ""
        echo "Next steps:"
        echo "1. If Docker was installed, log out and back in for group membership"
        echo "2. Run './build.sh' to start building SAGE-OS"
        echo "3. Run './scan-vulnerabilities.sh --help' for security scanning"
        echo "4. Check docs/DEVELOPER_GUIDE.md for detailed usage instructions"
        echo ""
    else
        echo ""
        log_error "❌ Installation completed with errors"
        echo "Please check the error messages above and install missing dependencies manually"
        echo "Refer to docs/DEVELOPER_GUIDE.md for troubleshooting"
        exit 1
    fi
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "SAGE-OS Dependency Installation Script"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --verify       Only verify existing installations"
        echo "  --update-cve   Only update CVE database"
        echo ""
        echo "This script automatically detects your operating system and installs"
        echo "all required dependencies for SAGE-OS development including:"
        echo "  - Cross-compilation toolchains (ARM, RISC-V, x86)"
        echo "  - QEMU emulators"
        echo "  - Docker"
        echo "  - Security scanning tools"
        echo "  - Development utilities"
        exit 0
        ;;
    --verify)
        detect_os
        verify_installation
        exit $?
        ;;
    --update-cve)
        update_cve_database
        exit 0
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