#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# Build System Integration Script
# Ensures all components work together and updates main build system

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[1;36m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}🔧 SAGE OS Build System Integration${NC}"
    echo "===================================="
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_section() {
    echo
    echo -e "${BLUE}📋 $1${NC}"
    echo "$(printf '─%.0s' {1..50})"
}

# Update main build script to include i386 graphics
update_main_build_script() {
    print_section "Updating Main Build Script"
    
    # Check if build.sh needs i386 graphics integration
    if ! grep -q "build-i386-graphics.sh" build.sh 2>/dev/null; then
        print_info "Adding i386 graphics support to main build script..."
        
        # Create backup
        cp build.sh build.sh.backup
        
        # Add i386 graphics option to build.sh
        sed -i.tmp '/graphics.*Build and run graphics mode with VNC/a\
  graphics-i386    Build and run i386 graphics mode (macOS optimized)' build.sh
        
        # Add case for graphics-i386
        sed -i.tmp '/graphics)/a\
    graphics-i386)\
        print_info "Building i386 graphics mode..."\
        ./build-i386-graphics.sh\
        print_success "i386 graphics build completed!"\
        print_info "Run with: ./run-i386-graphics.sh cocoa"\
        ;;' build.sh
        
        rm -f build.sh.tmp
        print_success "Main build script updated"
    else
        print_success "Main build script already integrated"
    fi
}

# Update Makefile to include i386 graphics
update_makefile() {
    print_section "Updating Makefile"
    
    if ! grep -q "graphics-i386" Makefile 2>/dev/null; then
        print_info "Adding i386 graphics target to Makefile..."
        
        # Add i386 graphics target
        cat >> Makefile << 'EOF'

# i386 Graphics Mode Target
.PHONY: graphics-i386
graphics-i386:
	@echo "Building i386 graphics kernel..."
	./build-i386-graphics.sh
	@echo "i386 graphics kernel ready!"
	@echo "Run with: ./run-i386-graphics.sh cocoa"

.PHONY: test-i386
test-i386: graphics-i386
	@echo "Testing i386 graphics build..."
	./test-i386-build.sh

.PHONY: run-i386
run-i386: graphics-i386
	@echo "Running i386 graphics mode..."
	./run-i386-graphics.sh cocoa
EOF
        
        print_success "Makefile updated with i386 targets"
    else
        print_success "Makefile already has i386 targets"
    fi
}

# Create unified launcher script
create_unified_launcher() {
    print_section "Creating Unified Launcher"
    
    cat > sage-os-launcher.sh << 'EOF'
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
EOF
    
    chmod +x sage-os-launcher.sh
    print_success "Unified launcher created: sage-os-launcher.sh"
}

# Update documentation
update_documentation() {
    print_section "Updating Documentation"
    
    # Update main README with new build options
    if [[ -f "README.md" ]]; then
        if ! grep -q "build-i386-graphics.sh" README.md; then
            print_info "Adding i386 graphics documentation to README..."
            
            # Add section about i386 graphics
            cat >> README.md << 'EOF'

## 🎨 Graphics Mode (macOS Optimized)

### Quick Start for macOS
```bash
# Build and run i386 graphics (recommended for macOS)
./build-i386-graphics.sh
./run-i386-graphics.sh cocoa

# Or use unified launcher
./sage-os-launcher.sh
```

### Build Options
- `./build-i386-graphics.sh` - Dedicated i386 graphics builder
- `./build-graphics-smart.sh` - Smart architecture detection
- `make graphics-i386` - Makefile target

### Run Options
- `./run-i386-graphics.sh cocoa` - Native macOS window
- `./run-i386-graphics.sh vnc` - VNC mode
- `./quick-graphics-macos.sh` - Interactive menu

### Verification
```bash
./verify-build-system.sh  # Comprehensive verification
./test-i386-build.sh      # Quick build test
```
EOF
            
            print_success "README updated with i386 graphics documentation"
        else
            print_success "README already has i386 graphics documentation"
        fi
    fi
}

# Test integration
test_integration() {
    print_section "Testing Integration"
    
    # Test main build script
    if bash -n build.sh; then
        print_success "Main build script syntax valid"
    else
        print_error "Main build script has syntax errors"
    fi
    
    # Test Makefile
    if make -n graphics-i386 >/dev/null 2>&1; then
        print_success "Makefile i386 target valid"
    else
        print_error "Makefile i386 target has issues"
    fi
    
    # Test unified launcher
    if bash -n sage-os-launcher.sh; then
        print_success "Unified launcher syntax valid"
    else
        print_error "Unified launcher has syntax errors"
    fi
    
    # Test actual build
    print_info "Testing actual i386 build..."
    if ./build-i386-graphics.sh >/dev/null 2>&1; then
        print_success "i386 graphics build works"
    else
        print_error "i386 graphics build failed"
    fi
}

# Create summary
create_summary() {
    print_section "Integration Summary"
    
    echo
    echo -e "${GREEN}🎉 Build System Integration Complete!${NC}"
    echo
    echo -e "${CYAN}Available Commands:${NC}"
    echo "  ./build-i386-graphics.sh     # Build i386 graphics kernel"
    echo "  ./run-i386-graphics.sh       # Run i386 graphics mode"
    echo "  ./sage-os-launcher.sh        # Unified launcher menu"
    echo "  ./quick-graphics-macos.sh    # Interactive graphics menu"
    echo "  ./verify-build-system.sh     # Comprehensive verification"
    echo
    echo -e "${CYAN}Makefile Targets:${NC}"
    echo "  make graphics-i386           # Build i386 graphics"
    echo "  make test-i386               # Build and test i386"
    echo "  make run-i386                # Build and run i386"
    echo
    echo -e "${CYAN}Build Script Options:${NC}"
    echo "  ./build.sh graphics-i386     # i386 graphics via main script"
    echo
    echo -e "${YELLOW}Recommended Workflow for macOS:${NC}"
    echo "  1. ./sage-os-launcher.sh     # Use unified launcher"
    echo "  2. Choose option 1 (i386 Graphics)"
    echo "  3. Enjoy SAGE OS! 🚀"
    echo
}

# Main execution
main() {
    print_header
    echo
    
    update_main_build_script
    update_makefile
    create_unified_launcher
    update_documentation
    test_integration
    create_summary
}

# Run integration
main "$@"