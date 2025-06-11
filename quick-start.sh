#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS Quick Start Script
# ─────────────────────────────────────────────────────────────────────────────

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}"
cat << 'EOF'
   ███████╗ █████╗  ██████╗ ███████╗      ██████╗ ███████╗
   ██╔════╝██╔══██╗██╔════╝ ██╔════╝     ██╔═══██╗██╔════╝
   ███████╗███████║██║  ███╗█████╗       ██║   ██║███████╗
   ╚════██║██╔══██║██║   ██║██╔══╝       ██║   ██║╚════██║
   ███████║██║  ██║╚██████╔╝███████╗     ╚██████╔╝███████║
   ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝      ╚═════╝ ╚══════╝

                    SAGE OS Quick Start
EOF
echo -e "${NC}"

echo -e "${GREEN}Welcome to SAGE OS Docker Deployment!${NC}"
echo
echo "This script will help you quickly deploy SAGE OS with graphics support."
echo

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Menu selection
echo "Please select your preferred deployment mode:"
echo
echo "1) VNC Mode (Recommended for macOS) - Access via VNC client"
echo "2) Graphics Mode - Direct QEMU window (Linux/Windows)"
echo "3) Text Mode - Terminal only"
echo "4) Custom deployment with options"
echo

read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        echo -e "${GREEN}Starting SAGE OS in VNC mode...${NC}"
        ./deploy-sage-os.sh deploy -d vnc -a i386 -p 5901
        ;;
    2)
        echo -e "${GREEN}Starting SAGE OS in Graphics mode...${NC}"
        ./deploy-sage-os.sh deploy -d graphics -a i386
        ;;
    3)
        echo -e "${GREEN}Starting SAGE OS in Text mode...${NC}"
        ./deploy-sage-os.sh deploy -d text -a i386
        ;;
    4)
        echo
        echo "Available architectures: i386, x86_64, aarch64, arm, riscv64"
        read -p "Enter architecture (default: i386): " arch
        arch=${arch:-i386}
        
        echo "Available display modes: vnc, graphics, text"
        read -p "Enter display mode (default: vnc): " display
        display=${display:-vnc}
        
        read -p "Enter memory size (default: 128M): " memory
        memory=${memory:-128M}
        
        read -p "Enter VNC port (default: 5901): " port
        port=${port:-5901}
        
        echo -e "${GREEN}Starting SAGE OS with custom settings...${NC}"
        ./deploy-sage-os.sh deploy -a "$arch" -d "$display" -M "$memory" -p "$port"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo
echo -e "${GREEN}SAGE OS deployment initiated!${NC}"

if [[ "$choice" == "1" || "$display" == "vnc" ]]; then
    echo
    echo -e "${YELLOW}VNC Connection Information:${NC}"
    echo "  Host: localhost"
    echo "  Port: ${port:-5901}"
    echo "  Password: sageos"
    echo
    echo "Connect using any VNC client:"
    echo "  - macOS: Built-in Screen Sharing (vnc://localhost:${port:-5901})"
    echo "  - Windows: TigerVNC, RealVNC"
    echo "  - Linux: Remmina, TigerVNC"
fi

echo
echo "Useful commands:"
echo "  View logs: ./deploy-sage-os.sh logs"
echo "  Open shell: ./deploy-sage-os.sh shell"
echo "  Stop container: ./deploy-sage-os.sh stop"
echo "  Clean up: ./deploy-sage-os.sh clean"