#!/bin/bash

# SAGE-OS Graphics Mode Runner
# This script runs SAGE-OS in graphics mode with VNC access

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_header() {
    echo -e "${CYAN}"
    echo "🖥️  SAGE-OS Graphics Mode"
    echo "=========================="
    echo -e "${NC}"
}

# Get project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

print_header

# Check if graphics kernel exists
GRAPHICS_KERNEL="output/i386/sage-os-v1.0.1-i386-generic-graphics.img"

if [ ! -f "$GRAPHICS_KERNEL" ]; then
    print_info "Graphics kernel not found. Building..."
    ./scripts/graphics/build-graphics.sh i386
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Graphics build failed${NC}"
        exit 1
    fi
fi

print_success "Graphics kernel ready!"
echo ""

# Parse command line arguments
MODE="${1:-vnc}"

case "$MODE" in
    "vnc")
        print_info "🖥️  Starting SAGE-OS in VNC graphics mode..."
        print_info "🔗  VNC server will be available on localhost:5900"
        print_info "📱  Connect with VNC viewer to see the graphics interface"
        print_info "⌨️  Use keyboard in VNC to interact with SAGE-OS shell"
        print_info "🛑  Press Ctrl+C to stop the server"
        echo ""
        print_warning "Note: In headless environment, use VNC client to connect"
        echo ""
        
        # Start QEMU with VNC
        qemu-system-i386 -kernel "$GRAPHICS_KERNEL" -vnc :0 -no-reboot
        ;;
        
    "local")
        print_info "🖥️  Starting SAGE-OS in local graphics mode..."
        print_info "🪟  Graphics window will open directly"
        print_info "⌨️  Use keyboard to interact with SAGE-OS shell"
        print_info "🛑  Close window or press Ctrl+Alt+Q to quit"
        echo ""
        
        # Start QEMU with local graphics
        qemu-system-i386 -kernel "$GRAPHICS_KERNEL" -no-reboot
        ;;
        
    "demo")
        print_info "🎬  Running SAGE-OS graphics demo (15 seconds)..."
        print_info "📺  This shows the text output of the graphics kernel"
        echo ""
        
        # Run demo with timeout
        timeout 15s qemu-system-i386 -kernel "$GRAPHICS_KERNEL" -nographic -no-reboot || true
        
        echo ""
        print_success "Demo completed!"
        echo ""
        print_info "💡 To run interactive graphics mode:"
        print_info "   ./run-graphics-mode.sh vnc    # VNC mode"
        print_info "   ./run-graphics-mode.sh local  # Local graphics"
        ;;
        
    "help"|"-h"|"--help")
        echo "Usage: $0 [MODE]"
        echo ""
        echo "Modes:"
        echo "  vnc      Start with VNC server (default, works remotely)"
        echo "  local    Start with local graphics window (macOS/Linux)"
        echo "  demo     Run 15-second demo showing text output"
        echo "  help     Show this help"
        echo ""
        echo "Examples:"
        echo "  $0              # Start VNC mode"
        echo "  $0 vnc          # Start VNC mode"
        echo "  $0 local        # Start local graphics"
        echo "  $0 demo         # Run demo"
        echo ""
        echo "VNC Connection:"
        echo "  Host: localhost"
        echo "  Port: 5900"
        echo "  Display: :0"
        echo ""
        echo "Available Commands in SAGE-OS:"
        echo "  help     - Show available commands"
        echo "  version  - Show system version"
        echo "  clear    - Clear screen"
        echo "  colors   - Test color display"
        echo "  demo     - Run demo sequence"
        echo "  reboot   - Restart system"
        echo "  exit     - Shutdown system"
        ;;
        
    *)
        echo -e "${RED}❌ Unknown mode: $MODE${NC}"
        echo ""
        echo "Run: $0 help"
        exit 1
        ;;
esac