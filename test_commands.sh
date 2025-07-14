#!/bin/bash

# SAGE OS Command Testing Script
# This script tests all 23 commands systematically

echo "SAGE OS Command Testing Script"
echo "=============================="
echo ""

# Create test input file
cat > test_input.txt << 'EOF'
help
version
pwd
ls
meminfo
uptime
whoami
uname
echo Hello World
clear
save test.txt Hello from SAGE OS
cat test.txt
append test.txt Additional content
cat test.txt
ls
fileinfo test.txt
touch newfile.txt
ls
rm newfile.txt
ls
mkdir testdir
ls
rmdir testdir
ls
nano test2.txt
This is line 1
This is line 2
.
cat test2.txt
delete test.txt
ls
reboot
EOF

echo "Testing SAGE OS with all commands..."
echo "Input commands:"
cat test_input.txt
echo ""
echo "Running test..."

# Run QEMU with input redirection
timeout 120 qemu-system-i386 -kernel output/i386/sage-os-v1.0.1-i386-generic.elf -nographic < test_input.txt

echo ""
echo "Test completed!"