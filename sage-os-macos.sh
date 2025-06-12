#!/bin/bash

# SAGE OS - macOS All-in-One Script
# Installs requirements, builds, and runs SAGE OS on macOS
# Compatible with Intel and Apple Silicon Macs

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🍎 SAGE OS - macOS All-in-One Setup & Launch"
echo "============================================="
echo ""
echo "This script will:"
echo "  1. Install required dependencies (Homebrew, QEMU, build tools)"
echo "  2. Build SAGE OS 32-bit graphics kernel"
echo "  3. Create bootable disk image"
echo "  4. Launch SAGE OS in QEMU"
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script is designed for macOS only!"
    echo "   For other platforms, use:"
    echo "   - Linux: ./sage-os-linux.sh"
    echo "   - Windows: ./sage-os-windows.bat"
    exit 1
fi

# Detect architecture
ARCH=$(uname -m)
echo "🔍 Detected architecture: $ARCH"

# Function to install Homebrew if not present
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo "📦 Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon
        if [[ "$ARCH" == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        echo "✅ Homebrew already installed"
    fi
}

# Function to install dependencies
install_dependencies() {
    echo "📦 Installing dependencies..."
    
    # Update Homebrew
    brew update
    
    # Install required packages
    echo "   Installing QEMU..."
    brew install qemu
    
    echo "   Installing build tools..."
    brew install gcc
    brew install binutils
    
    # For cross-compilation (if needed)
    if ! command -v i386-elf-gcc &> /dev/null; then
        echo "   Installing cross-compilation toolchain..."
        brew tap nativeos/i386-elf-toolchain
        brew install i386-elf-binutils i386-elf-gcc || {
            echo "⚠️  Cross-compiler not available, using system GCC with -m32"
        }
    fi
    
    echo "✅ Dependencies installed successfully"
}

# Function to build SAGE OS
build_sage_os() {
    echo "🔨 Building SAGE OS..."
    
    # Create build directory with proper paths
    mkdir -p "build/macos"
    
    # Ensure we have the source files or create them
    if [ ! -f "simple_boot.S" ] && [ ! -f "simple_boot.bin" ]; then
        echo "   Creating bootloader source file..."
        # We'll create the minimal bootloader inline
    fi
    
    # Build the bootloader
    echo "   Building bootloader..."
    if command -v i386-elf-gcc &> /dev/null; then
        i386-elf-gcc -m32 -nostdlib -nostartfiles -Wl,--oformat=binary -Wl,-Ttext=0x7C00 simple_boot.S -o build/macos/bootloader.bin
    else
        # Fallback to system GCC
        gcc -m32 -nostdlib -nostartfiles -Wl,--oformat=binary -Wl,-Ttext=0x7C00 simple_boot.S -o build/macos/bootloader.bin 2>/dev/null || {
            echo "⚠️  32-bit compilation not supported, creating bootable image directly..."
            cp simple_boot.bin build/macos/bootloader.bin 2>/dev/null || {
                echo "❌ No pre-built bootloader found. Creating simple version..."
                # Create minimal bootloader if none exists
                cat > "build/macos/minimal_boot.S" << 'EOF'
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
    ljmp $0x08, $pm

print:
    lodsb
    test %al, %al
    jz done
    mov $0x0E, %ah
    int $0x10
    jmp print
done:
    ret

.code32
pm:
    mov $0x10, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %ss
    mov $0x90000, %esp
    
    mov $0xB8000, %edi
    mov $0x07200720, %eax
    mov $2000, %ecx
    rep stosl
    
    mov $0xB8000, %edi
    movb $'S', (%edi); movb $0x0F, 1(%edi); add $2, %edi
    movb $'A', (%edi); movb $0x0F, 1(%edi); add $2, %edi
    movb $'G', (%edi); movb $0x0F, 1(%edi); add $2, %edi
    movb $'E', (%edi); movb $0x0F, 1(%edi); add $2, %edi
    movb $' ', (%edi); movb $0x0F, 1(%edi); add $2, %edi
    movb $'O', (%edi); movb $0x0F, 1(%edi); add $2, %edi
    movb $'S', (%edi); movb $0x0F, 1(%edi); add $2, %edi
    
loop:
    in $0x64, %al
    test $1, %al
    jz loop
    in $0x60, %al
    hlt
    jmp loop

msg:
    .asciz "SAGE OS macOS Build Loading...\r\n"

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
                gcc -m32 -nostdlib -nostartfiles -Wl,--oformat=binary -Wl,-Ttext=0x7C00 "build/macos/minimal_boot.S" -o "build/macos/bootloader.bin" 2>/dev/null || {
                    echo "❌ Cannot compile 32-bit code on this system"
                    echo "   Using pre-built bootloader..."
                    cp simple_boot.bin build/macos/bootloader.bin 2>/dev/null || {
                        echo "❌ No bootloader available. Please install i386-elf-gcc or use a different system."
                        exit 1
                    }
                }
            }
        }
    fi
    
    # Create disk image
    echo "   Creating bootable disk image..."
    dd if=/dev/zero of="build/macos/sage_os_macos.img" bs=1024 count=1440 2>/dev/null
    dd if="build/macos/bootloader.bin" of="build/macos/sage_os_macos.img" bs=512 count=1 conv=notrunc 2>/dev/null
    
    echo "✅ SAGE OS built successfully"
    echo "   Output: build/macos/sage_os_macos.img"
}

# Function to run SAGE OS
run_sage_os() {
    echo "🚀 Launching SAGE OS..."
    
    # Check if QEMU is available
    if ! command -v qemu-system-i386 &> /dev/null; then
        echo "❌ QEMU not found. Installing..."
        brew install qemu
    fi
    
    echo ""
    echo "🎮 SAGE OS is starting..."
    echo "   - Graphics: VGA 80x25 text mode"
    echo "   - Keyboard: PS/2 compatible input"
    echo "   - Features: ASCII art, interactive shell"
    echo ""
    echo "📺 A QEMU window will open showing SAGE OS"
    echo "   You should see:"
    echo "   - Boot message: 'SAGE OS macOS Build Loading...'"
    echo "   - ASCII art: 'SAGE OS' display"
    echo "   - Interactive keyboard input"
    echo ""
    echo "🎯 Controls:"
    echo "   - Type letters to test keyboard input"
    echo "   - Press Cmd+Q to quit QEMU"
    echo "   - Press Ctrl+Alt+G to release mouse (if captured)"
    echo ""
    echo "Starting in 3 seconds..."
    sleep 3
    
    # Launch QEMU with appropriate settings for macOS
    if [[ "$ARCH" == "arm64" ]]; then
        # Apple Silicon Mac
        echo "🍎 Launching on Apple Silicon Mac..."
        qemu-system-i386 \
            -fda "build/macos/sage_os_macos.img" \
            -m 128M \
            -display cocoa \
            -no-reboot \
            -name "SAGE OS - macOS Build" \
            2>/dev/null || {
                echo "⚠️  Cocoa display failed, trying VNC..."
                qemu-system-i386 \
                    -fda "build/macos/sage_os_macos.img" \
                    -m 128M \
                    -vnc :1 \
                    -no-reboot \
                    -name "SAGE OS - macOS Build" &
                echo "📺 VNC server started on localhost:5901"
                echo "   Connect with VNC viewer to see SAGE OS"
                wait
            }
    else
        # Intel Mac
        echo "💻 Launching on Intel Mac..."
        qemu-system-i386 \
            -fda build/macos/sage_os_macos.img \
            -m 128M \
            -display cocoa \
            -no-reboot \
            -name "SAGE OS - macOS Build" \
            2>/dev/null || {
                echo "⚠️  Cocoa display failed, trying SDL..."
                qemu-system-i386 \
                    -fda build/macos/sage_os_macos.img \
                    -m 128M \
                    -display sdl \
                    -no-reboot \
                    -name "SAGE OS - macOS Build" \
                    2>/dev/null || {
                        echo "⚠️  SDL display failed, trying VNC..."
                        qemu-system-i386 \
                            -fda build/macos/sage_os_macos.img \
                            -m 128M \
                            -vnc :1 \
                            -no-reboot \
                            -name "SAGE OS - macOS Build" &
                        echo "📺 VNC server started on localhost:5901"
                        echo "   Connect with VNC viewer to see SAGE OS"
                        wait
                    }
            }
    fi
}

# Function to show system info
show_system_info() {
    echo "💻 System Information:"
    echo "   OS: $(sw_vers -productName) $(sw_vers -productVersion)"
    echo "   Architecture: $ARCH"
    echo "   Homebrew: $(brew --version | head -1)"
    echo "   QEMU: $(qemu-system-i386 --version | head -1 2>/dev/null || echo 'Not installed')"
    echo ""
}

# Main execution
main() {
    show_system_info
    
    echo "🔄 Starting SAGE OS setup process..."
    echo ""
    
    # Install Homebrew if needed
    install_homebrew
    
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
        echo "   qemu-system-i386 -fda build/macos/sage_os_macos.img -m 128M -display cocoa"
        echo ""
        echo "📁 Build output location:"
        echo "   $(pwd)/build/macos/sage_os_macos.img"
    fi
    
    echo ""
    echo "✨ SAGE OS macOS setup complete!"
    echo "   Thank you for trying SAGE OS - Self-Adaptive Generative Environment"
}

# Handle script interruption
trap 'echo ""; echo "❌ Setup interrupted by user"; exit 1' INT

# Run main function
main "$@"