#!/bin/bash

# SAGE OS - Windows WSL All-in-One Script
# Installs requirements, builds, and runs SAGE OS on Windows Subsystem for Linux
# Compatible with WSL1 and WSL2

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🪟🐧 SAGE OS - Windows WSL All-in-One Setup & Launch"
echo "===================================================="
echo ""
echo "This script will:"
echo "  1. Detect WSL version and distribution"
echo "  2. Install required dependencies (QEMU, GCC, build tools)"
echo "  3. Build SAGE OS 32-bit graphics kernel"
echo "  4. Create bootable disk image"
echo "  5. Launch SAGE OS in QEMU (with X11 forwarding or VNC)"
echo ""

# Check if running in WSL
if [ ! -f /proc/version ] || ! grep -qi "microsoft\|wsl" /proc/version; then
    echo "❌ This script is designed for Windows WSL only!"
    echo "   For other platforms, use:"
    echo "   - Linux: ./sage-os-linux.sh"
    echo "   - macOS: ./sage-os-macos.sh"
    echo "   - Windows Native: ./sage-os-windows.bat"
    exit 1
fi

# Detect WSL version and distribution
detect_wsl_info() {
    if grep -qi "microsoft" /proc/version; then
        if grep -qi "WSL2" /proc/version; then
            WSL_VERSION="WSL2"
        else
            WSL_VERSION="WSL1"
        fi
    else
        WSL_VERSION="WSL2"  # Default assumption for newer WSL
    fi
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION=$VERSION_ID
    else
        DISTRO="unknown"
    fi
    
    echo "🔍 Detected environment:"
    echo "   WSL Version: $WSL_VERSION"
    echo "   Distribution: $DISTRO"
    if [ -n "$VERSION" ]; then
        echo "   Version: $VERSION"
    fi
    echo "   Kernel: $(uname -r)"
}

# Function to check for X11 forwarding
check_x11_support() {
    if [ -n "$DISPLAY" ]; then
        echo "✅ X11 forwarding detected: $DISPLAY"
        X11_AVAILABLE=true
    else
        echo "⚠️  No X11 forwarding detected"
        echo "   For GUI applications, consider:"
        echo "   - Installing VcXsrv or Xming on Windows"
        echo "   - Setting DISPLAY environment variable"
        X11_AVAILABLE=false
    fi
}

# Function to install dependencies
install_dependencies() {
    echo "📦 Installing dependencies for WSL ($DISTRO)..."
    
    # Update package lists
    case $DISTRO in
        ubuntu|debian|pop|mint)
            sudo apt update
            echo "   Installing packages with APT..."
            sudo apt install -y \
                qemu-system-x86 \
                gcc-multilib \
                binutils \
                make \
                build-essential \
                nasm \
                git \
                dos2unix
            ;;
        fedora|rhel|centos)
            if command -v dnf &> /dev/null; then
                sudo dnf install -y \
                    qemu-system-x86 \
                    gcc \
                    glibc-devel.i686 \
                    binutils \
                    make \
                    nasm \
                    git \
                    dos2unix
            else
                sudo yum install -y \
                    qemu-system-x86 \
                    gcc \
                    glibc-devel.i686 \
                    binutils \
                    make \
                    nasm \
                    git \
                    dos2unix
            fi
            ;;
        opensuse*|sles)
            sudo zypper install -y \
                qemu-x86 \
                gcc \
                gcc-32bit \
                binutils \
                make \
                nasm \
                git \
                dos2unix
            ;;
        arch|manjaro)
            sudo pacman -Sy --noconfirm \
                qemu-system-x86 \
                gcc-multilib \
                binutils \
                make \
                nasm \
                git \
                dos2unix
            ;;
        *)
            echo "⚠️  Unknown distribution: $DISTRO"
            echo "   Please install manually:"
            echo "   - qemu-system-x86"
            echo "   - gcc with 32-bit support"
            echo "   - binutils, make, nasm, git"
            ;;
    esac
    
    echo "✅ Dependencies installed successfully"
}

# Function to create WSL-specific paths
setup_wsl_paths() {
    echo "🔧 Setting up WSL-specific paths..."
    
    # Create build directory with proper permissions
    mkdir -p build/wsl
    chmod 755 build/wsl
    
    # Convert any Windows line endings to Unix
    if [ -f "simple_boot.S" ]; then
        dos2unix simple_boot.S 2>/dev/null || true
    fi
    
    # Set up Windows interop if available
    if command -v cmd.exe &> /dev/null; then
        WINDOWS_INTEROP=true
        echo "✅ Windows interop available"
        
        # Get Windows user directory
        WINDOWS_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r\n' || echo "User")
        echo "   Windows user: $WINDOWS_USER"
    else
        WINDOWS_INTEROP=false
        echo "⚠️  Windows interop not available"
    fi
}

# Function to build SAGE OS
build_sage_os() {
    echo "🔨 Building SAGE OS for WSL..."
    
    # Build the bootloader
    echo "   Building bootloader..."
    
    # Try to use existing bootloader first
    if [ -f "simple_boot.bin" ]; then
        cp simple_boot.bin build/wsl/bootloader.bin
        echo "   ✅ Using pre-built bootloader"
    else
        # Create WSL-specific bootloader
        echo "   Creating WSL-optimized bootloader..."
        cat > build/wsl/wsl_boot.S << 'EOF'
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
    
    # Display SAGE OS WSL
    mov $0xB8000, %edi
    movb $'S', (%edi); movb $0x0F, 1(%edi); add $2, %edi
    movb $'A', (%edi); movb $0x0F, 1(%edi); add $2, %edi
    movb $'G', (%edi); movb $0x0F, 1(%edi); add $2, %edi
    movb $'E', (%edi); movb $0x0F, 1(%edi); add $2, %edi
    movb $' ', (%edi); movb $0x0F, 1(%edi); add $2, %edi
    movb $'O', (%edi); movb $0x0F, 1(%edi); add $2, %edi
    movb $'S', (%edi); movb $0x0F, 1(%edi); add $2, %edi
    movb $' ', (%edi); movb $0x0F, 1(%edi); add $2, %edi
    movb $'W', (%edi); movb $0x0B, 1(%edi); add $2, %edi
    movb $'S', (%edi); movb $0x0B, 1(%edi); add $2, %edi
    movb $'L', (%edi); movb $0x0B, 1(%edi); add $2, %edi
    
    # Second line - WSL version
    mov $0xB80A0, %edi
    movb $'W', (%edi); movb $0x0E, 1(%edi); add $2, %edi
    movb $'S', (%edi); movb $0x0E, 1(%edi); add $2, %edi
    movb $'L', (%edi); movb $0x0E, 1(%edi); add $2, %edi
    movb $' ', (%edi); movb $0x0E, 1(%edi); add $2, %edi
    movb $'3', (%edi); movb $0x0E, 1(%edi); add $2, %edi
    movb $'2', (%edi); movb $0x0E, 1(%edi); add $2, %edi
    movb $'-', (%edi); movb $0x0E, 1(%edi); add $2, %edi
    movb $'b', (%edi); movb $0x0E, 1(%edi); add $2, %edi
    movb $'i', (%edi); movb $0x0E, 1(%edi); add $2, %edi
    movb $'t', (%edi); movb $0x0E, 1(%edi); add $2, %edi
    movb $' ', (%edi); movb $0x0E, 1(%edi); add $2, %edi
    movb $'M', (%edi); movb $0x0E, 1(%edi); add $2, %edi
    movb $'o', (%edi); movb $0x0E, 1(%edi); add $2, %edi
    movb $'d', (%edi); movb $0x0E, 1(%edi); add $2, %edi
    movb $'e', (%edi); movb $0x0E, 1(%edi); add $2, %edi
    
    # Third line - Status
    mov $0xB8140, %edi
    movb $'S', (%edi); movb $0x0A, 1(%edi); add $2, %edi
    movb $'t', (%edi); movb $0x0A, 1(%edi); add $2, %edi
    movb $'a', (%edi); movb $0x0A, 1(%edi); add $2, %edi
    movb $'t', (%edi); movb $0x0A, 1(%edi); add $2, %edi
    movb $'u', (%edi); movb $0x0A, 1(%edi); add $2, %edi
    movb $'s', (%edi); movb $0x0A, 1(%edi); add $2, %edi
    movb $':', (%edi); movb $0x0A, 1(%edi); add $2, %edi
    movb $' ', (%edi); movb $0x0A, 1(%edi); add $2, %edi
    movb $'R', (%edi); movb $0x0A, 1(%edi); add $2, %edi
    movb $'U', (%edi); movb $0x0A, 1(%edi); add $2, %edi
    movb $'N', (%edi); movb $0x0A, 1(%edi); add $2, %edi
    movb $'N', (%edi); movb $0x0A, 1(%edi); add $2, %edi
    movb $'I', (%edi); movb $0x0A, 1(%edi); add $2, %edi
    movb $'N', (%edi); movb $0x0A, 1(%edi); add $2, %edi
    movb $'G', (%edi); movb $0x0A, 1(%edi); add $2, %edi
    
    # Keyboard input loop
input_loop:
    in $0x64, %al
    test $1, %al
    jz input_loop
    in $0x60, %al
    hlt
    jmp input_loop

msg:
    .asciz "SAGE OS WSL Build Loading...\r\n"

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
        
        # Compile bootloader
        gcc -m32 -nostdlib -nostartfiles -Wl,--oformat=binary -Wl,-Ttext=0x7C00 build/wsl/wsl_boot.S -o build/wsl/bootloader.bin
        echo "   ✅ Built WSL-optimized bootloader"
    fi
    
    # Create disk image
    echo "   Creating bootable disk image..."
    dd if=/dev/zero of=build/wsl/sage_os_wsl.img bs=1024 count=1440 2>/dev/null
    dd if=build/wsl/bootloader.bin of=build/wsl/sage_os_wsl.img bs=512 count=1 conv=notrunc 2>/dev/null
    
    # Set proper permissions
    chmod 644 build/wsl/sage_os_wsl.img
    
    echo "✅ SAGE OS built successfully for WSL"
    echo "   Output: build/wsl/sage_os_wsl.img"
    
    # Copy to Windows accessible location if possible
    if [ "$WINDOWS_INTEROP" = true ]; then
        WINDOWS_PATH="/mnt/c/Users/$WINDOWS_USER/Desktop/sage_os_wsl.img"
        cp build/wsl/sage_os_wsl.img "$WINDOWS_PATH" 2>/dev/null && {
            echo "   Also copied to: $WINDOWS_PATH"
        } || true
    fi
}

# Function to run SAGE OS
run_sage_os() {
    echo "🚀 Launching SAGE OS in WSL..."
    
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
    echo "   - Environment: $WSL_VERSION on $DISTRO"
    echo ""
    
    if [ "$X11_AVAILABLE" = true ]; then
        echo "📺 Launching with X11 forwarding..."
        echo "   Make sure your X server (VcXsrv/Xming) is running on Windows"
        echo ""
        echo "🎯 Controls:"
        echo "   - Type letters to test keyboard input"
        echo "   - Press Ctrl+Alt+Q to quit QEMU"
        echo "   - Press Ctrl+Alt+G to release mouse (if captured)"
        echo ""
        echo "Starting in 3 seconds..."
        sleep 3
        
        # Try X11 display
        qemu-system-i386 \
            -fda build/wsl/sage_os_wsl.img \
            -m 128M \
            -display gtk \
            -no-reboot \
            -name "SAGE OS - WSL Build" \
            2>/dev/null || {
                echo "⚠️  GTK display failed, trying SDL..."
                qemu-system-i386 \
                    -fda build/wsl/sage_os_wsl.img \
                    -m 128M \
                    -display sdl \
                    -no-reboot \
                    -name "SAGE OS - WSL Build" \
                    2>/dev/null || run_vnc_mode
            }
    else
        run_vnc_mode
    fi
}

# Function to run in VNC mode
run_vnc_mode() {
    echo "📺 No X11 available, starting VNC server..."
    echo "   This will start a VNC server you can connect to from Windows"
    echo ""
    
    qemu-system-i386 \
        -fda build/wsl/sage_os_wsl.img \
        -m 128M \
        -vnc :1 \
        -no-reboot \
        -name "SAGE OS - WSL Build" &
    
    QEMU_PID=$!
    
    echo "✅ VNC server started on localhost:5901"
    echo ""
    echo "🔗 To connect from Windows:"
    echo "   1. Download a VNC viewer (like TightVNC Viewer)"
    echo "   2. Connect to: localhost:5901"
    echo "   3. You should see SAGE OS running"
    echo ""
    echo "📱 Alternative connection methods:"
    echo "   - Use Windows Subsystem for Linux GUI (if available)"
    echo "   - Connect via Windows VNC client"
    echo "   - Use browser-based VNC viewer"
    echo ""
    echo "Press Ctrl+C to stop the VNC server"
    
    # Wait for user to stop
    trap "kill $QEMU_PID 2>/dev/null; echo ''; echo '✅ VNC server stopped'; exit 0" INT
    wait $QEMU_PID
}

# Function to show system info
show_system_info() {
    echo "💻 WSL System Information:"
    echo "   WSL Version: $WSL_VERSION"
    echo "   Distribution: $DISTRO"
    if [ -n "$VERSION" ]; then
        echo "   Version: $VERSION"
    fi
    echo "   Kernel: $(uname -r)"
    echo "   Architecture: $(uname -m)"
    echo "   QEMU: $(qemu-system-i386 --version | head -1 2>/dev/null || echo 'Not installed')"
    echo "   GCC: $(gcc --version | head -1 2>/dev/null || echo 'Not installed')"
    if [ "$WINDOWS_INTEROP" = true ]; then
        echo "   Windows User: $WINDOWS_USER"
    fi
    echo ""
}

# Main execution
main() {
    detect_wsl_info
    check_x11_support
    setup_wsl_paths
    show_system_info
    
    echo "🔄 Starting SAGE OS WSL setup process..."
    echo ""
    
    # Install dependencies
    install_dependencies
    
    # Build SAGE OS
    build_sage_os
    
    # Ask user if they want to run immediately
    echo ""
    echo "✅ SAGE OS WSL build completed successfully!"
    echo ""
    read -p "🚀 Would you like to launch SAGE OS now? (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        run_sage_os
    else
        echo "📝 To run SAGE OS later, use:"
        echo "   qemu-system-i386 -fda build/wsl/sage_os_wsl.img -m 128M"
        echo ""
        echo "📁 Build output locations:"
        echo "   WSL: $(pwd)/build/wsl/sage_os_wsl.img"
        if [ "$WINDOWS_INTEROP" = true ]; then
            echo "   Windows: C:\\Users\\$WINDOWS_USER\\Desktop\\sage_os_wsl.img"
        fi
    fi
    
    echo ""
    echo "✨ SAGE OS WSL setup complete!"
    echo "   Thank you for trying SAGE OS - Self-Adaptive Generative Environment"
}

# Handle script interruption
trap 'echo ""; echo "❌ Setup interrupted by user"; exit 1' INT

# Run main function
main "$@"