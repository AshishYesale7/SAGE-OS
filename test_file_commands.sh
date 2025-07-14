#!/bin/bash
# Script to test SAGE OS file management commands

# Start QEMU with SAGE OS
qemu-system-i386 \
  -kernel output/i386/sage-os-v1.0.1-i386-generic-graphics.elf \
  -m 128M \
  -nographic \
  -no-reboot << EOF
help
ls
pwd
touch test_file.txt
ls
save test_file.txt "This is a test file content"
cat test_file.txt
append test_file.txt " - Appended content"
cat test_file.txt
mkdir test_dir
ls
rm test_file.txt
ls
rmdir test_dir
ls
exit
EOF