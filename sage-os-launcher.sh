#!/bin/bash
# SAGE OS Unified Launcher
# One script to launch SAGE OS in any mode

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}🚀 SAGE OS Unified Launcher${NC}"
    echo "============================"
}

show_menu() {
    print_header
    echo
    echo -e "${YELLOW}Choose your SAGE OS experience:${NC}"
    echo
    echo "1) i386 Graphics (macOS Optimized)"
    echo "   • Best for macOS M1/Intel"
    echo "   • Native Cocoa window"
    echo "   • 32-bit compatibility"
    echo
    echo "2) i386 Graphics with VNC"
    echo "   • Remote desktop access"
    echo "   • Cross-platform compatibility"
    echo
    echo "3) Auto-detect and Build"
    echo "   • Smart architecture detection"
    echo "   • Automatic optimization"
    echo
    echo "4) Interactive Graphics Menu"
    echo "   • Full-featured launcher"
    echo "   • All options available"
    echo
    echo "5) Build Only"
    echo "   • Just build, don't run"
    echo
    echo "q) Quit"
    echo
}

handle_choice() {
    local choice="$1"
    
    case $choice in
        1)
            echo -e "${CYAN}Launching i386 Graphics (Cocoa)...${NC}"
            ./run-i386-graphics.sh cocoa
            ;;
        2)
            echo -e "${CYAN}Launching i386 Graphics (VNC)...${NC}"
            ./run-i386-graphics.sh vnc
            ;;
        3)
            echo -e "${CYAN}Auto-detecting and building...${NC}"
            ./build-graphics-smart.sh auto
            ./quick-graphics-macos.sh
            ;;
        4)
            echo -e "${CYAN}Opening interactive menu...${NC}"
            ./quick-graphics-macos.sh
            ;;
        5)
            echo -e "${CYAN}Building i386 graphics kernel...${NC}"
            ./build-i386-graphics.sh
            ;;
        q|Q)
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo "Invalid choice: $choice"
            ;;
    esac
}

# Main execution
while true; do
    show_menu
    echo -n "Enter your choice [1-5, q]: "
    read -r choice
    echo
    handle_choice "$choice"
    
    if [[ "$choice" != "5" ]]; then
        break
    fi
done
