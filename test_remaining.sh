#!/bin/bash

echo "Testing remaining SAGE OS commands..."

# Test exit command
cat > test_exit.txt << 'EOF'
help
exit
EOF

echo "Testing exit command:"
timeout 30 qemu-system-i386 -kernel output/i386/sage-os-v1.0.1-i386-generic.elf -nographic < test_exit.txt

echo ""
echo "Testing shutdown command:"

# Test shutdown command  
cat > test_shutdown.txt << 'EOF'
help
shutdown
EOF

timeout 30 qemu-system-i386 -kernel output/i386/sage-os-v1.0.1-i386-generic.elf -nographic < test_shutdown.txt

echo ""
echo "All tests completed!"