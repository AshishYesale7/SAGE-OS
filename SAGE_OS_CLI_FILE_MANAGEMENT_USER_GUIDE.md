# 📚 SAGE OS Enhanced - CLI File Management User Guide

**Version:** Enhanced 1.0.1  
**Architecture:** i386 (32-bit x86)  
**Date:** 2025-07-14  
**Author:** Ashish Vasant Yesale  

---

## 🚀 Quick Start Guide

### Prerequisites
- Linux/macOS/Windows WSL2 environment
- QEMU emulator installed
- GCC cross-compiler for i386
- Git for cloning the repository

### Installation & Setup
```bash
# Clone the repository
git clone https://github.com/thunderkings123/SAGE-OS.git
cd SAGE-OS

# Switch to dev branch
git checkout dev

# Build enhanced SAGE OS
./build-enhanced.sh build i386

# Test in QEMU emulator
./build-enhanced.sh test i386 interactive
```

---

## 🖥️ Running SAGE OS

### Starting the System
```bash
# Method 1: Using build script (recommended)
./build-enhanced.sh test i386 interactive

# Method 2: Direct QEMU command
qemu-system-i386 \
    -kernel build-output/sage-os-enhanced-1.0.1-enhanced-i386-graphics.elf \
    -m 128M \
    -nographic \
    -no-reboot \
    -monitor none
```

### Boot Sequence
When SAGE OS starts, you'll see:
```
  ███████╗ █████╗  ██████╗ ███████╗      ██████╗ ███████╗
  ██╔════╝██╔══██╗██╔════╝ ██╔════╝     ██╔═══██╗██╔════╝
  ███████╗███████║██║  ███╗█████╗       ██║   ██║███████╗
  ╚════██║██╔══██║██║   ██║██╔══╝       ██║   ██║╚════██║
  ███████║██║  ██║╚██████╔╝███████╗     ╚██████╔╝███████║
  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝      ╚═════╝ ╚══════╝

    Self-Aware General Environment Operating System
                Enhanced Version 1.0.1
            Designed by Ashish Yesale

Enhanced Features:
- File Management with persistent storage
- Advanced shell commands (save, cat, ls, cp, mv, rm)
- Command history and improved input handling
- VGA graphics support with enhanced display
- Multi-architecture support (i386, x86_64, ARM64)

Architecture: i386 (32-bit x86)

Type 'help' for available commands.
Use Ctrl+A then X to exit QEMU.

sage>
```

### Exiting SAGE OS
- **Method 1**: Type `exit` command in SAGE OS shell
- **Method 2**: Press `Ctrl+A`, release, then press `X` (QEMU exit sequence)
- **Method 3**: Press `Ctrl+C` in terminal (force quit)

---

## 📋 Complete Command Reference

### 💡 Getting Help
```bash
sage> help
# Shows all available commands with descriptions

sage> version
# Shows SAGE OS version and system information
```

### 📁 Basic File Operations

#### Creating Files
```bash
# Save text to a file
sage> save filename.txt Your content goes here

# Create empty file
sage> touch empty.txt

# Examples
sage> save welcome.txt Hello World from SAGE OS!
sage> save config.txt debug=true
log_level=info
verbose=false
```

#### Reading Files
```bash
# Display entire file content
sage> cat filename.txt

# Show first 10 lines (default)
sage> head filename.txt

# Show first 5 lines
sage> head -n 5 filename.txt

# Show last 10 lines (default)
sage> tail filename.txt

# Show last 3 lines
sage> tail -n 3 filename.txt

# Examples
sage> cat welcome.txt
sage> head -n 2 config.txt
sage> tail -n 1 config.txt
```

#### Listing Files
```bash
# List all files with details
sage> ls

# Example output:
# Files in current directory:
#   welcome.txt - 25 bytes
#   config.txt - 45 bytes
#   empty.txt - 0 bytes
```

#### File Management
```bash
# Copy file
sage> cp source.txt destination.txt

# Move/rename file
sage> mv oldname.txt newname.txt

# Delete file
sage> rm filename.txt

# Examples
sage> cp welcome.txt backup.txt
sage> mv backup.txt welcome_backup.txt
sage> rm empty.txt
```

### 🔍 Advanced File Operations

#### File Analysis
```bash
# Count lines, words, and characters
sage> wc filename.txt

# Example output:
#   4 lines, 12 words, 52 characters in 'filename.txt'

# Show detailed file statistics
sage> stat filename.txt

# Example output:
# File: filename.txt
# Size: 52 bytes
# Lines: 4
# Type: Regular file
# Permissions: rw-r--r--
```

#### Search Operations
```bash
# Find files by name pattern
sage> find pattern

# Search for text in file
sage> grep pattern filename.txt

# Examples
sage> find config          # Finds files containing 'config'
sage> grep debug config.txt # Searches for 'debug' in config.txt
```

### 📂 Directory Operations
```bash
# Show current directory
sage> pwd

# Create directory placeholder
sage> mkdir dirname

# Note: Full directory support is planned for future versions
```

### 💻 System Commands
```bash
# Clear screen
sage> clear

# Echo text
sage> echo Hello World

# Show memory information
sage> meminfo

# Show system uptime
sage> uptime

# Show current user
sage> whoami

# Reboot system
sage> reboot

# Exit SAGE OS
sage> exit
```

---

## 🎯 Practical Examples

### Example 1: Creating and Managing Documents
```bash
# Start SAGE OS
sage> help

# Create a document
sage> save document.txt This is my first document in SAGE OS.
It supports multiple lines and various content types.
You can save configuration files, notes, and more!

# Verify the file was created
sage> ls

# Read the document
sage> cat document.txt

# Get file statistics
sage> stat document.txt
sage> wc document.txt

# Create a backup
sage> cp document.txt document_backup.txt

# Verify both files exist
sage> ls
```

### Example 2: Configuration File Management
```bash
# Create a configuration file
sage> save app.conf # Application Configuration
debug=true
log_level=info
max_connections=100
timeout=30

# View the configuration
sage> cat app.conf

# Search for specific settings
sage> grep debug app.conf
sage> grep timeout app.conf

# Create different environment configs
sage> cp app.conf app_dev.conf
sage> cp app.conf app_prod.conf

# Modify production config (manual editing in SAGE OS)
sage> save app_prod.conf # Production Configuration
debug=false
log_level=error
max_connections=1000
timeout=60

# Compare configurations
sage> cat app_dev.conf
sage> cat app_prod.conf
```

### Example 3: Log File Analysis
```bash
# Create a sample log file
sage> save system.log 2025-07-14 10:00:01 INFO System started
2025-07-14 10:00:02 INFO Loading configuration
2025-07-14 10:00:03 WARN Configuration file not found, using defaults
2025-07-14 10:00:04 INFO System ready
2025-07-14 10:01:00 ERROR Connection failed
2025-07-14 10:01:01 INFO Retrying connection
2025-07-14 10:01:02 INFO Connection established

# Analyze the log file
sage> wc system.log
sage> head -n 3 system.log
sage> tail -n 2 system.log

# Search for specific log levels
sage> grep ERROR system.log
sage> grep INFO system.log
sage> grep WARN system.log

# Find entries with specific patterns
sage> grep connection system.log
sage> grep 10:01 system.log
```

### Example 4: File Organization
```bash
# Create multiple files
sage> save readme.txt Welcome to SAGE OS Enhanced!
sage> save changelog.txt Version 1.0.1 - Added file management
sage> save license.txt BSD 3-Clause License
sage> touch notes.txt

# List all files
sage> ls

# Find specific files
sage> find readme
sage> find .txt

# Create organized copies
sage> cp readme.txt docs_readme.txt
sage> cp changelog.txt docs_changelog.txt
sage> cp license.txt docs_license.txt

# Verify organization
sage> ls
sage> find docs
```

---

## 🔧 Advanced Usage Tips

### File Content Best Practices
1. **Multi-line files**: Use the `save` command with natural line breaks
2. **Configuration files**: Use key=value format for easy parsing
3. **Documentation**: Create structured text files with clear sections
4. **Logs**: Use timestamp prefixes for chronological ordering

### Command Combinations
```bash
# Quick file inspection workflow
sage> ls                    # See what files exist
sage> stat filename.txt     # Get file details
sage> head -n 5 filename.txt # Preview content
sage> wc filename.txt       # Get size statistics

# File backup workflow
sage> cp important.txt important_backup.txt
sage> stat important.txt
sage> stat important_backup.txt
sage> ls

# Search and analysis workflow
sage> find config           # Find config files
sage> grep debug *.conf     # Search in config files
sage> wc *.txt             # Analyze text files
```

### Error Handling
- **File not found**: Check filename spelling with `ls`
- **Command not recognized**: Use `help` to see available commands
- **Empty output**: File might be empty, check with `stat filename`
- **System unresponsive**: Use `Ctrl+A` then `X` to exit QEMU

---

## 🚨 Troubleshooting

### Common Issues and Solutions

#### QEMU Won't Start
```bash
# Check if kernel file exists
ls -la build-output/sage-os-enhanced-1.0.1-enhanced-i386-graphics.elf

# Rebuild if necessary
./build-enhanced.sh build i386

# Try alternative QEMU command
qemu-system-i386 -kernel build-output/sage-os-enhanced-1.0.1-enhanced-i386-graphics.elf -m 128M -nographic
```

#### Commands Not Working
```bash
# Verify you're at the sage> prompt
# Type 'help' to see available commands
# Check command syntax in this guide
```

#### Can't Exit QEMU
```bash
# Method 1: Type 'exit' in SAGE OS
sage> exit

# Method 2: QEMU exit sequence
# Press Ctrl+A (hold both keys)
# Release both keys
# Press X (single key)

# Method 3: Force quit from terminal
# Press Ctrl+C in the terminal running QEMU
```

#### File Operations Failing
```bash
# Check available files
sage> ls

# Verify file exists before operations
sage> stat filename.txt

# Check file content
sage> cat filename.txt

# Ensure proper command syntax
sage> save test.txt Hello World  # Correct
sage> save test.txt "Hello World" # Also works
```

### Build Issues
```bash
# Clean build
rm -rf build/
./build-enhanced.sh build i386

# Check dependencies
./build-enhanced.sh build i386 2>&1 | grep -i error

# Verify GCC cross-compiler
i686-elf-gcc --version
# or
gcc -m32 --version
```

---

## 📊 Performance Guidelines

### File Size Limits
- **Maximum file size**: 4KB per file
- **Maximum files**: Limited by available memory (~100 files)
- **Filename length**: Up to 255 characters
- **Content**: Text files work best

### Memory Usage
- **System RAM**: 128MB allocated to QEMU
- **Kernel size**: 32KB
- **Available for files**: ~127MB
- **Per-file overhead**: ~64 bytes

### Performance Tips
1. **Keep files small**: Under 1KB for best performance
2. **Use descriptive names**: Easy to find with `find` command
3. **Regular cleanup**: Use `rm` to delete unused files
4. **Backup important files**: Use `cp` for safety

---

## 🔮 Future Features (Planned)

### Coming Soon
- **Real directory support**: Full directory tree navigation
- **File permissions**: Read/write/execute permissions
- **Pipe operations**: Command chaining with `|`
- **Redirection**: Output redirection with `>` and `>>`
- **Wildcards**: Pattern matching with `*` and `?`
- **Text editor**: Built-in file editor
- **Archive support**: tar/zip file operations

### Advanced Features
- **Network file transfer**: FTP/HTTP file operations
- **Database integration**: Simple file-based database
- **Scripting support**: Bash-like scripting
- **Package manager**: Install/remove applications
- **Multi-user support**: User accounts and permissions

---

## 📞 Support and Resources

### Getting Help
- **Built-in help**: Type `help` in SAGE OS
- **Command syntax**: Refer to this guide
- **Error messages**: Read carefully for troubleshooting hints

### Developer Information
- **Designer**: Ashish Vasant Yesale
- **Email**: ashishyesale007@gmail.com
- **Repository**: https://github.com/thunderkings123/SAGE-OS
- **Branch**: dev (for enhanced features)
- **License**: BSD 3-Clause OR Commercial

### Community Resources
- **GitHub Issues**: Report bugs and request features
- **Documentation**: Check `/docs` directory in repository
- **Examples**: See `/examples` directory for sample files
- **Build Scripts**: Examine build system in repository root

---

## 🏆 Conclusion

SAGE OS Enhanced provides a powerful CLI-based file management system that brings Unix-like file operations to a custom operating system. With 24 commands and comprehensive file management capabilities, it's suitable for:

- **Educational purposes**: Learning OS development
- **Embedded systems**: Lightweight file management
- **Research projects**: Custom OS experimentation
- **Development testing**: File system prototyping

### Key Benefits
✅ **Complete file management suite**  
✅ **Persistent storage across sessions**  
✅ **Advanced text processing capabilities**  
✅ **Professional command-line interface**  
✅ **Comprehensive documentation and examples**  
✅ **Active development and support**  

**Start exploring SAGE OS Enhanced today and experience the power of custom operating system development!**

---

*User Guide created on 2025-07-14*  
*SAGE OS Enhanced Version 1.0.1*  
*© 2025 Ashish Vasant Yesale - All Rights Reserved*