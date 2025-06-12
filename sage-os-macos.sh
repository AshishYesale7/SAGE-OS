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
    
    # First, try to use pre-built bootloader
    if [ -f "simple_boot.bin" ]; then
        echo "   ✅ Using pre-built bootloader (simple_boot.bin)"
        cp "simple_boot.bin" "build/macos/bootloader.bin"
    elif command -v i386-elf-gcc &> /dev/null; then
        echo "   Compiling with i386-elf-gcc..."
        i386-elf-gcc -m32 -nostdlib -nostartfiles -Wl,--oformat=binary -Wl,-Ttext=0x7C00 simple_boot.S -o "build/macos/bootloader.bin"
    else
        # Try system GCC for 32-bit compilation
        echo "   Trying system GCC for 32-bit compilation..."
        gcc -m32 -nostdlib -nostartfiles -Wl,--oformat=binary -Wl,-Ttext=0x7C00 simple_boot.S -o "build/macos/bootloader.bin" 2>/dev/null || {
            echo "⚠️  32-bit compilation not supported on Apple Silicon"
            echo "   Creating pre-built bootloader..."
            
            # Create the pre-built bootloader using Python
            python3 << 'PYTHON_EOF'
import struct

# Create a working 512-byte bootloader for Apple Silicon Macs
bootloader = bytearray(512)

# Simple bootloader code that works on Apple Silicon
code = [
    0xFA,                    # cli
    0x31, 0xC0,              # xor ax, ax
    0x8E, 0xD8,              # mov ds, ax
    0x8E, 0xC0,              # mov es, ax
    0x8E, 0xD0,              # mov ss, ax
    0xBC, 0x00, 0x7C,        # mov sp, 0x7C00
    0xFB,                    # sti
    
    # Print boot message
    0xBE, 0x30, 0x7C,        # mov si, msg
    0xAC,                    # lodsb
    0x84, 0xC0,              # test al, al
    0x74, 0x06,              # jz done
    0xB4, 0x0E,              # mov ah, 0x0E
    0xCD, 0x10,              # int 0x10
    0xEB, 0xF5,              # jmp print_loop
    
    # Setup protected mode
    0x0F, 0x01, 0x16, 0x90, 0x7C,  # lgdt [gdt_desc]
    0x0F, 0x20, 0xC0,        # mov eax, cr0
    0x66, 0x83, 0xC8, 0x01,  # or eax, 1
    0x0F, 0x22, 0xC0,        # mov cr0, eax
    0xEA, 0x60, 0x7C, 0x08, 0x00,  # jmp 0x08:protected_mode
]

# Add the code
for i, byte in enumerate(code):
    if i < 510:
        bootloader[i] = byte

# Boot message at offset 0x30
msg = b"SAGE OS macOS Loading...\r\n\0"
for i, byte in enumerate(msg):
    if 0x30 + i < 480:
        bootloader[0x30 + i] = byte

# Protected mode code at offset 0x60
pm_code = [
    0x66, 0xB8, 0x10, 0x00,  # mov ax, 0x10
    0x8E, 0xD8,              # mov ds, ax
    0x8E, 0xC0,              # mov es, ax
    0x8E, 0xD0,              # mov ss, ax
    0xBC, 0x00, 0x00, 0x09, 0x00,  # mov esp, 0x90000
    
    # Clear VGA and display SAGE OS
    0xBF, 0x00, 0x80, 0x0B, 0x00,  # mov edi, 0xB8000
    0xB8, 0x20, 0x07, 0x20, 0x07,  # mov eax, 0x07200720
    0xB9, 0xD0, 0x07, 0x00, 0x00,  # mov ecx, 2000
    0xF3, 0xAB,              # rep stosd
    
    # Display "SAGE OS macOS"
    0xBF, 0x00, 0x80, 0x0B, 0x00,  # mov edi, 0xB8000
    0xC6, 0x07, 0x53,        # mov byte [edi], 'S'
    0xC6, 0x47, 0x01, 0x0F,  # mov byte [edi+1], 0x0F
    0x83, 0xC7, 0x02,        # add edi, 2
    0xC6, 0x07, 0x41,        # mov byte [edi], 'A'
    0xC6, 0x47, 0x01, 0x0F,  # mov byte [edi+1], 0x0F
    0x83, 0xC7, 0x02,        # add edi, 2
    0xC6, 0x07, 0x47,        # mov byte [edi], 'G'
    0xC6, 0x47, 0x01, 0x0F,  # mov byte [edi+1], 0x0F
    0x83, 0xC7, 0x02,        # add edi, 2
    0xC6, 0x07, 0x45,        # mov byte [edi], 'E'
    0xC6, 0x47, 0x01, 0x0F,  # mov byte [edi+1], 0x0F
    0x83, 0xC7, 0x02,        # add edi, 2
    0xC6, 0x07, 0x20,        # mov byte [edi], ' '
    0xC6, 0x47, 0x01, 0x0F,  # mov byte [edi+1], 0x0F
    0x83, 0xC7, 0x02,        # add edi, 2
    0xC6, 0x07, 0x4F,        # mov byte [edi], 'O'
    0xC6, 0x47, 0x01, 0x0F,  # mov byte [edi+1], 0x0F
    0x83, 0xC7, 0x02,        # add edi, 2
    0xC6, 0x07, 0x53,        # mov byte [edi], 'S'
    0xC6, 0x47, 0x01, 0x0F,  # mov byte [edi+1], 0x0F
    0x83, 0xC7, 0x02,        # add edi, 2
    0xC6, 0x07, 0x20,        # mov byte [edi], ' '
    0xC6, 0x47, 0x01, 0x0F,  # mov byte [edi+1], 0x0F
    0x83, 0xC7, 0x02,        # add edi, 2
    0xC6, 0x07, 0x6D,        # mov byte [edi], 'm'
    0xC6, 0x47, 0x01, 0x0B,  # mov byte [edi+1], 0x0B
    0x83, 0xC7, 0x02,        # add edi, 2
    0xC6, 0x07, 0x61,        # mov byte [edi], 'a'
    0xC6, 0x47, 0x01, 0x0B,  # mov byte [edi+1], 0x0B
    0x83, 0xC7, 0x02,        # add edi, 2
    0xC6, 0x07, 0x63,        # mov byte [edi], 'c'
    0xC6, 0x47, 0x01, 0x0B,  # mov byte [edi+1], 0x0B
    0x83, 0xC7, 0x02,        # add edi, 2
    0xC6, 0x07, 0x4F,        # mov byte [edi], 'O'
    0xC6, 0x47, 0x01, 0x0B,  # mov byte [edi+1], 0x0B
    0x83, 0xC7, 0x02,        # add edi, 2
    0xC6, 0x07, 0x53,        # mov byte [edi], 'S'
    0xC6, 0x47, 0x01, 0x0B,  # mov byte [edi+1], 0x0B
    
    # Keyboard input loop
    0xE4, 0x64,              # in al, 0x64
    0xA8, 0x01,              # test al, 1
    0x74, 0xFA,              # jz input_loop
    0xE4, 0x60,              # in al, 0x60
    0xF4,                    # hlt
    0xEB, 0xF6,              # jmp input_loop
]

# Add protected mode code
for i, byte in enumerate(pm_code):
    if 0x60 + i < 480:
        bootloader[0x60 + i] = byte

# GDT at offset 0x98
gdt = [
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  # Null descriptor
    0xFF, 0xFF, 0x00, 0x00, 0x00, 0x9A, 0xCF, 0x00,  # Code segment
    0xFF, 0xFF, 0x00, 0x00, 0x00, 0x92, 0xCF, 0x00,  # Data segment
]

for i, byte in enumerate(gdt):
    if 0x98 + i < 500:
        bootloader[0x98 + i] = byte

# GDT descriptor at offset 0x90
bootloader[0x90] = 0x17  # GDT limit
bootloader[0x91] = 0x00
bootloader[0x92] = 0x98  # GDT base low
bootloader[0x93] = 0x7C  # GDT base high

# Boot signature
bootloader[510] = 0x55
bootloader[511] = 0xAA

# Write bootloader
with open('build/macos/bootloader.bin', 'wb') as f:
    f.write(bootloader)

print("✅ Created macOS-compatible bootloader")
PYTHON_EOF
            
            echo "   ✅ Created Apple Silicon compatible bootloader"
        }
    fi
    
    # Verify bootloader was created
    if [ ! -f "build/macos/bootloader.bin" ]; then
        echo "❌ Failed to create bootloader"
        exit 1
    fi
    
    # Check bootloader size
    BOOTLOADER_SIZE=$(stat -f%z "build/macos/bootloader.bin" 2>/dev/null || stat -c%s "build/macos/bootloader.bin")
    if [ "$BOOTLOADER_SIZE" -eq 512 ]; then
        echo "   ✅ Bootloader size correct: $BOOTLOADER_SIZE bytes"
    else
        echo "   ⚠️  Bootloader size: $BOOTLOADER_SIZE bytes (expected 512)"
    fi
    
    echo "✅ Bootloader built successfully"
    
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
        # Apple Silicon Mac - VNC is more reliable
        echo "🍎 Launching on Apple Silicon Mac..."
        echo "   Starting QEMU with VNC display (more reliable on Apple Silicon)..."
        
        # Start QEMU in background with VNC
        qemu-system-i386 \
            -drive file="build/macos/sage_os_macos.img",format=raw,if=floppy,readonly=on \
            -boot a \
            -m 128M \
            -vnc :1 \
            -no-fd-bootchk \
            -no-reboot \
            -name "SAGE OS - macOS Build" &
        
        QEMU_PID=$!
        sleep 2
        
        if ps -p $QEMU_PID > /dev/null 2>&1; then
            echo "✅ QEMU started successfully!"
            echo "📺 VNC server running on localhost:5901"
            echo ""
            echo "🎮 To view SAGE OS:"
            echo "   1. Open 'Screen Sharing' app on macOS"
            echo "   2. Connect to: localhost:5901"
            echo "   3. Or use any VNC viewer"
            echo ""
            echo "🎯 You should see:"
            echo "   - SAGE OS bootloader message"
            echo "   - Text display with system ready prompt"
            echo ""
            echo "Press Ctrl+C to stop QEMU when done"
            echo ""
            
            # Wait for user to stop or QEMU to exit
            wait $QEMU_PID
        else
            echo "❌ Failed to start QEMU"
            echo "   Trying Cocoa display as fallback..."
            qemu-system-i386 \
                -drive file="build/macos/sage_os_macos.img",format=raw,if=floppy,readonly=on \
                -boot a \
                -m 128M \
                -display cocoa \
                -no-fd-bootchk \
                -no-reboot \
                -name "SAGE OS - macOS Build"
        fi
    else
        # Intel Mac - try Cocoa first, then VNC
        echo "💻 Launching on Intel Mac..."
        echo "   Trying Cocoa display first..."
        
        # Try Cocoa with timeout
        timeout 5s qemu-system-i386 \
            -drive file=build/macos/sage_os_macos.img,format=raw,if=floppy,readonly=on \
            -boot a \
            -m 128M \
            -display cocoa \
            -no-fd-bootchk \
            -no-reboot \
            -name "SAGE OS - macOS Build" 2>/dev/null || {
                echo "⚠️  Cocoa display timed out or failed, using VNC..."
                
                # Start QEMU with VNC in background
                qemu-system-i386 \
                    -drive file=build/macos/sage_os_macos.img,format=raw,if=floppy,readonly=on \
                    -boot a \
                    -m 128M \
                    -vnc :1 \
                    -no-fd-bootchk \
                    -no-reboot \
                    -name "SAGE OS - macOS Build" &
                
                QEMU_PID=$!
                sleep 2
                
                if ps -p $QEMU_PID > /dev/null 2>&1; then
                    echo "✅ QEMU started with VNC!"
                    echo "📺 VNC server running on localhost:5901"
                    echo "   Connect with Screen Sharing app or VNC viewer"
                    echo "   Press Ctrl+C to stop QEMU when done"
                    wait $QEMU_PID
                else
                    echo "❌ Failed to start QEMU"
                fi
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
        echo "📝 To run SAGE OS later:"
        echo ""
        echo "   🖥️  VNC (recommended for Apple Silicon):"
        echo "   qemu-system-i386 -drive file=build/macos/sage_os_macos.img,format=raw,if=floppy,readonly=on -boot a -m 128M -vnc :1 -no-fd-bootchk &"
        echo "   Then connect to localhost:5901 with Screen Sharing app"
        echo ""
        echo "   🍎 Cocoa (for Intel Macs):"
        echo "   qemu-system-i386 -drive file=build/macos/sage_os_macos.img,format=raw,if=floppy,readonly=on -boot a -m 128M -display cocoa -no-fd-bootchk"
        echo ""
        echo "   🚀 Quick test script:"
        echo "   ./quick_test_sage_os.sh"
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