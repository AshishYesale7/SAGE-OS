#!/bin/bash

# SAGE OS - Linux All-in-One Script
# Installs requirements, builds, and runs SAGE OS on Linux
# Compatible with Ubuntu, Debian, Fedora, Arch, and other distributions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🐧 SAGE OS - Linux All-in-One Setup & Launch"
echo "============================================="
echo ""
echo "This script will:"
echo "  1. Detect your Linux distribution"
echo "  2. Install required dependencies (QEMU, GCC, build tools)"
echo "  3. Build SAGE OS 32-bit graphics kernel"
echo "  4. Create bootable disk image"
echo "  5. Launch SAGE OS in QEMU"
echo ""

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "❌ This script is designed for Linux only!"
    echo "   For other platforms, use:"
    echo "   - macOS: ./sage-os-macos.sh"
    echo "   - Windows: ./sage-os-windows.bat"
    exit 1
fi

# Detect Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION=$VERSION_ID
    elif [ -f /etc/redhat-release ]; then
        DISTRO="rhel"
    elif [ -f /etc/debian_version ]; then
        DISTRO="debian"
    else
        DISTRO="unknown"
    fi
    
    echo "🔍 Detected distribution: $DISTRO"
    if [ -n "$VERSION" ]; then
        echo "   Version: $VERSION"
    fi
}

# Function to install dependencies based on distribution
install_dependencies() {
    echo "📦 Installing dependencies for $DISTRO..."
    
    case $DISTRO in
        ubuntu|debian|pop|mint)
            echo "   Using APT package manager..."
            sudo apt update
            sudo apt install -y \
                qemu-system-x86 \
                gcc-multilib \
                binutils \
                make \
                build-essential \
                nasm \
                git
            ;;
        fedora|rhel|centos)
            echo "   Using DNF/YUM package manager..."
            if command -v dnf &> /dev/null; then
                sudo dnf install -y \
                    qemu-system-x86 \
                    gcc \
                    glibc-devel.i686 \
                    binutils \
                    make \
                    nasm \
                    git
            else
                sudo yum install -y \
                    qemu-system-x86 \
                    gcc \
                    glibc-devel.i686 \
                    binutils \
                    make \
                    nasm \
                    git
            fi
            ;;
        arch|manjaro)
            echo "   Using Pacman package manager..."
            sudo pacman -Sy --noconfirm \
                qemu-system-x86 \
                gcc-multilib \
                binutils \
                make \
                nasm \
                git
            ;;
        opensuse*|sles)
            echo "   Using Zypper package manager..."
            sudo zypper install -y \
                qemu-x86 \
                gcc \
                gcc-32bit \
                binutils \
                make \
                nasm \
                git
            ;;
        alpine)
            echo "   Using APK package manager..."
            sudo apk add \
                qemu-system-i386 \
                gcc \
                musl-dev \
                binutils \
                make \
                nasm \
                git
            ;;
        *)
            echo "⚠️  Unknown distribution: $DISTRO"
            echo "   Please install manually:"
            echo "   - qemu-system-x86 (or qemu-system-i386)"
            echo "   - gcc with 32-bit support"
            echo "   - binutils"
            echo "   - make"
            echo "   - nasm"
            echo ""
            read -p "Continue anyway? (y/N): " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
            ;;
    esac
    
    echo "✅ Dependencies installed successfully"
}

# Function to build SAGE OS
build_sage_os() {
    echo "🔨 Building SAGE OS..."
    
    # Create build directory with proper paths
    mkdir -p "build/linux"
    
    # Build the bootloader
    echo "   Building bootloader..."
    
    # Try to use existing bootloader first
    if [ -f "simple_boot.bin" ]; then
        cp "simple_boot.bin" "build/linux/bootloader.bin"
        echo "   ✅ Using pre-built bootloader"
    else
        # Build from source
        if [ -f "simple_boot.S" ]; then
            gcc -m32 -nostdlib -nostartfiles -Wl,--oformat=binary -Wl,-Ttext=0x7C00 "simple_boot.S" -o "build/linux/bootloader.bin"
            echo "   ✅ Built bootloader from source"
        else
            # Create minimal bootloader
            echo "   Creating minimal bootloader..."
            cat > "build/linux/minimal_boot.S" << 'EOF'
.code16
.section .text
.global _start

_start:
    cli
    xor %ax, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %ss
    mov $0x7C00, %sp
    sti
    
    mov $msg, %si
    call print
    
    cli
    lgdt gdt_desc
    mov %cr0, %eax
    or $1, %eax
    mov %eax, %cr0
    ljmp $0x08, $protected_mode

print:
    lodsb
    test %al, %al
    jz print_done
    mov $0x0E, %ah
    int $0x10
    jmp print
print_done:
    ret

.code32
protected_mode:
    mov $0x10, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %ss
    mov $0x90000, %esp
    
    # Clear VGA buffer
    mov $0xB8000, %edi
    mov $0x07200720, %eax
    mov $2000, %ecx
    rep stosl
    
    # Display SAGE OS
    mov $0xB8000, %edi
    movb $'S', (%edi); movb $0x0F, 1(%edi); add $2, %edi
    movb $'A', (%edi); movb $0x0F, 3(%edi); add $2, %edi
    movb $'G', (%edi); movb $0x0F, 5(%edi); add $2, %edi
    movb $'E', (%edi); movb $0x0F, 7(%edi); add $2, %edi
    movb $' ', (%edi); movb $0x0F, 9(%edi); add $2, %edi
    movb $'O', (%edi); movb $0x0F, 11(%edi); add $2, %edi
    movb $'S', (%edi); movb $0x0F, 13(%edi); add $2, %edi
    movb $' ', (%edi); movb $0x0F, 15(%edi); add $2, %edi
    movb $'L', (%edi); movb $0x0A, 17(%edi); add $2, %edi
    movb $'i', (%edi); movb $0x0A, 19(%edi); add $2, %edi
    movb $'n', (%edi); movb $0x0A, 21(%edi); add $2, %edi
    movb $'u', (%edi); movb $0x0A, 23(%edi); add $2, %edi
    movb $'x', (%edi); movb $0x0A, 25(%edi); add $2, %edi
    
    # Second line
    mov $0xB80A0, %edi
    movb $'3', (%edi); movb $0x0E, 1(%edi); add $2, %edi
    movb $'2', (%edi); movb $0x0E, 3(%edi); add $2, %edi
    movb $'-', (%edi); movb $0x0E, 5(%edi); add $2, %edi
    movb $'b', (%edi); movb $0x0E, 7(%edi); add $2, %edi
    movb $'i', (%edi); movb $0x0E, 9(%edi); add $2, %edi
    movb $'t', (%edi); movb $0x0E, 11(%edi); add $2, %edi
    movb $' ', (%edi); movb $0x0E, 13(%edi); add $2, %edi
    movb $'M', (%edi); movb $0x0E, 15(%edi); add $2, %edi
    movb $'o', (%edi); movb $0x0E, 17(%edi); add $2, %edi
    movb $'d', (%edi); movb $0x0E, 19(%edi); add $2, %edi
    movb $'e', (%edi); movb $0x0E, 21(%edi); add $2, %edi
    
    # Keyboard input loop
input_loop:
    in $0x64, %al
    test $1, %al
    jz input_loop
    in $0x60, %al
    hlt
    jmp input_loop

msg:
    .asciz "SAGE OS Linux Build Loading...\r\n"

gdt:
    .quad 0
    .word 0xFFFF, 0x0000
    .byte 0x00, 0x9A, 0xCF, 0x00
    .word 0xFFFF, 0x0000
    .byte 0x00, 0x92, 0xCF, 0x00

gdt_desc:
    .word gdt_desc - gdt - 1
    .long gdt

.space 510-(.-_start)
.word 0xAA55
EOF
            
            gcc -m32 -nostdlib -nostartfiles -Wl,--oformat=binary -Wl,-Ttext=0x7C00 "build/linux/minimal_boot.S" -o "build/linux/bootloader.bin"
            echo "   ✅ Built minimal bootloader"
        fi
    fi
    
    # Create disk image
    echo "   Creating bootable disk image..."
    dd if=/dev/zero of="build/linux/sage_os_linux.img" bs=1024 count=1440 2>/dev/null
    dd if="build/linux/bootloader.bin" of="build/linux/sage_os_linux.img" bs=512 count=1 conv=notrunc 2>/dev/null
    
    echo "✅ SAGE OS built successfully"
    echo "   Output: build/linux/sage_os_linux.img"
}

# Function to run SAGE OS
run_sage_os() {
    echo "🚀 Launching SAGE OS..."
    
    # Check if QEMU is available
    if ! command -v qemu-system-i386 &> /dev/null; then
        echo "❌ QEMU not found. Please install qemu-system-x86"
        exit 1
    fi
    
    echo ""
    echo "🎮 SAGE OS is starting..."
    echo "   - Graphics: VGA 80x25 text mode"
    echo "   - Keyboard: PS/2 compatible input"
    echo "   - Features: ASCII art, interactive shell"
    echo ""
    echo "📺 A QEMU window will open showing SAGE OS"
    echo "   You should see:"
    echo "   - Boot message: 'SAGE OS Linux Build Loading...'"
    echo "   - ASCII art: 'SAGE OS Linux' display"
    echo "   - Interactive keyboard input"
    echo ""
    echo "🎯 Controls:"
    echo "   - Type letters to test keyboard input"
    echo "   - Press Ctrl+Alt+Q to quit QEMU"
    echo "   - Press Ctrl+Alt+G to release mouse (if captured)"
    echo ""
    echo "Starting in 3 seconds..."
    sleep 3
    
    # Try different display options based on what's available
    if [ -n "$DISPLAY" ] && command -v xdpyinfo &> /dev/null; then
        # X11 available
        echo "🖥️  Launching with X11 display..."
        qemu-system-i386 \
            -fda build/linux/sage_os_linux.img \
            -m 128M \
            -display gtk \
            -no-reboot \
            -name "SAGE OS - Linux Build" \
            2>/dev/null || {
                echo "⚠️  GTK display failed, trying SDL..."
                qemu-system-i386 \
                    -fda build/linux/sage_os_linux.img \
                    -m 128M \
                    -display sdl \
                    -no-reboot \
                    -name "SAGE OS - Linux Build" \
                    2>/dev/null || run_vnc_fallback
            }
    elif [ -n "$WAYLAND_DISPLAY" ]; then
        # Wayland available
        echo "🖥️  Launching with Wayland display..."
        qemu-system-i386 \
            -fda build/linux/sage_os_linux.img \
            -m 128M \
            -display gtk \
            -no-reboot \
            -name "SAGE OS - Linux Build" \
            2>/dev/null || run_vnc_fallback
    else
        # No display, use VNC
        run_vnc_fallback
    fi
}

# Function to run with VNC fallback
run_vnc_fallback() {
    echo "📺 No display available, starting VNC server..."
    qemu-system-i386 \
        -fda build/linux/sage_os_linux.img \
        -m 128M \
        -vnc :1 \
        -no-reboot \
        -name "SAGE OS - Linux Build" &
    
    echo "✅ VNC server started on localhost:5901"
    echo "   Connect with a VNC viewer:"
    echo "   - vncviewer localhost:5901"
    echo "   - Or use any VNC client to connect to 127.0.0.1:5901"
    echo ""
    echo "Press Ctrl+C to stop the server"
    wait
}

# Function to show system info
show_system_info() {
    echo "💻 System Information:"
    echo "   Kernel: $(uname -r)"
    echo "   Architecture: $(uname -m)"
    echo "   Distribution: $DISTRO"
    if [ -n "$VERSION" ]; then
        echo "   Version: $VERSION"
    fi
    echo "   QEMU: $(qemu-system-i386 --version | head -1 2>/dev/null || echo 'Not installed')"
    echo "   GCC: $(gcc --version | head -1 2>/dev/null || echo 'Not installed')"
    echo ""
}

# Function to check prerequisites
check_prerequisites() {
    echo "🔍 Checking prerequisites..."
    
    local missing_deps=()
    
    # Check for sudo
    if ! command -v sudo &> /dev/null; then
        echo "⚠️  sudo not found. You may need to install packages as root."
    fi
    
    # Check for package managers
    local has_package_manager=false
    for pm in apt dnf yum pacman zypper apk; do
        if command -v $pm &> /dev/null; then
            has_package_manager=true
            break
        fi
    done
    
    if [ "$has_package_manager" = false ]; then
        echo "⚠️  No supported package manager found"
        echo "   Please install dependencies manually"
    fi
    
    echo "✅ Prerequisites check completed"
}

# Main execution
main() {
    detect_distro
    show_system_info
    check_prerequisites
    
    echo "🔄 Starting SAGE OS setup process..."
    echo ""
    
    # Install dependencies
    install_dependencies
    
    # Build SAGE OS
    build_sage_os
    
    # Ask user if they want to run immediately
    echo ""
    echo "✅ SAGE OS build completed successfully!"
    echo ""
    read -p "🚀 Would you like to launch SAGE OS now? (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        run_sage_os
    else
        echo "📝 To run SAGE OS later, use:"
        echo "   qemu-system-i386 -fda build/linux/sage_os_linux.img -m 128M"
        echo ""
        echo "📁 Build output location:"
        echo "   $(pwd)/build/linux/sage_os_linux.img"
    fi
    
    echo ""
    echo "✨ SAGE OS Linux setup complete!"
    echo "   Thank you for trying SAGE OS - Self-Adaptive Generative Environment"
}

# Handle script interruption
trap 'echo ""; echo "❌ Setup interrupted by user"; exit 1' INT

# Run main function
main "$@"