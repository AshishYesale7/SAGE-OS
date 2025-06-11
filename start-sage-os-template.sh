#!/bin/bash

# Function to start VNC server
start_vnc() {
    echo "Starting VNC server on display :1"
    export DISPLAY=:1
    vncserver :1 -geometry 1024x768 -depth 24 -passwd /home/sage/.vnc/passwd
    
    # Start window manager
    DISPLAY=:1 fluxbox &
    
    echo "VNC server started. Connect to localhost:5901"
    echo "VNC password: sageos"
}

# Function to run SAGE OS
run_sage_os() {
    cd /home/sage/sage-os
    
    # Find the kernel file
    KERNEL_FILE=""
    if [ -f "output/$1/sage-os-v*.elf" ]; then
        KERNEL_FILE=$(ls output/$1/sage-os-v*.elf | head -1)
    elif [ -f "build/$1/kernel.elf" ]; then
        KERNEL_FILE="build/$1/kernel.elf"
    elif [ -f "build/$1/kernel.img" ]; then
        KERNEL_FILE="build/$1/kernel.img"
    elif ls build-output/*-$1-*.img >/dev/null 2>&1; then
        KERNEL_FILE=$(ls build-output/*-$1-*.img | head -1)
    else
        echo "Error: No kernel file found for architecture $1"
        echo "Available files:"
        find . -name "*.elf" -o -name "*.img" | head -10
        exit 1
    fi
    
    echo "Using kernel file: $KERNEL_FILE"
    
    # QEMU command based on architecture and mode
    case "$1" in
        "i386"|"x86_64")
            QEMU_CMD="qemu-system-i386"
            QEMU_ARGS="-kernel $KERNEL_FILE -m $2"
            ;;
        "aarch64")
            QEMU_CMD="qemu-system-aarch64"
            QEMU_ARGS="-M virt -cpu cortex-a57 -kernel $KERNEL_FILE -m $2"
            ;;
        "arm")
            QEMU_CMD="qemu-system-arm"
            QEMU_ARGS="-M versatilepb -kernel $KERNEL_FILE -m $2"
            ;;
        "riscv64")
            QEMU_CMD="qemu-system-riscv64"
            QEMU_ARGS="-M virt -kernel $KERNEL_FILE -m $2"
            ;;
        *)
            echo "Unsupported architecture: $1"
            exit 1
            ;;
    esac
    
    # Display mode configuration
    case "$3" in
        "graphics")
            DISPLAY_ARGS="-vga std -display vnc=:1"
            ;;
        "vnc")
            DISPLAY_ARGS="-vga std -display vnc=:1,websocket=5700"
            ;;
        "text")
            DISPLAY_ARGS="-nographic"
            ;;
        "x11")
            DISPLAY_ARGS="-vga std -display gtk"
            ;;
        *)
            DISPLAY_ARGS="-vga std -display vnc=:1"
            ;;
    esac
    
    # Additional QEMU arguments
    EXTRA_ARGS="-no-reboot -boot n -monitor telnet:127.0.0.1:$4,server,nowait"
    
    echo "Starting SAGE OS with command:"
    echo "$QEMU_CMD $QEMU_ARGS $DISPLAY_ARGS $EXTRA_ARGS"
    
    # Start QEMU
    exec $QEMU_CMD $QEMU_ARGS $DISPLAY_ARGS $EXTRA_ARGS
}

# Main execution
case "$1" in
    "vnc")
        start_vnc
        sleep 2
        run_sage_os "$2" "$3" "vnc" "$4"
        ;;
    "graphics")
        export DISPLAY=:0
        run_sage_os "$2" "$3" "graphics" "$4"
        ;;
    "text")
        run_sage_os "$2" "$3" "text" "$4"
        ;;
    *)
        echo "Usage: $0 {vnc|graphics|text} <arch> <memory> <monitor_port>"
        exit 1
        ;;
esac