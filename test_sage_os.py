#!/usr/bin/env python3
import pexpect
import time
import sys

# Start QEMU with SAGE OS
child = pexpect.spawn('qemu-system-i386 -kernel output/i386/sage-os-v1.0.1-i386-generic-graphics.elf -m 128M -nographic -no-reboot')
child.logfile = sys.stdout.buffer

# Wait for the prompt
child.expect('sage@localhost:~\\$', timeout=10)
print("\n\n--- SAGE OS booted successfully ---\n")

# Test commands
commands = [
    "help",
    "ls",
    "pwd",
    "touch test_file.txt",
    "ls",
    "save test_file.txt This is a test file content",
    "cat test_file.txt",
    "append test_file.txt More content appended",
    "cat test_file.txt",
    "mkdir test_dir",
    "ls",
    "rm test_file.txt",
    "ls",
    "rmdir test_dir",
    "ls",
    "version"
]

# Execute each command and wait for the prompt
for cmd in commands:
    print(f"\n\n--- Executing: {cmd} ---\n")
    child.sendline(cmd)
    child.expect('sage@localhost:~\\$', timeout=5)
    time.sleep(1)

# Exit QEMU
print("\n\n--- Exiting SAGE OS ---\n")
child.sendline("exit")
child.expect(pexpect.EOF, timeout=5)

print("\n\n--- Test completed ---\n")