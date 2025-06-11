#!/usr/bin/env python3
"""
SAGE-OS Project Organization Tool
Reorganizes the project structure for better maintainability
"""

import os
import shutil
import sys
from pathlib import Path

def create_directory_structure():
    """Create the proper directory structure"""
    base_dirs = {
        'build/': 'Build artifacts and temporary files',
        'tools/': 'Development and build tools',
        'tools/build/': 'Build-related tools and scripts',
        'tools/testing/': 'Testing tools and scripts',
        'tools/development/': 'Development utilities',
        'docs/platforms/': 'Platform-specific documentation',
        'docs/guides/': 'User and developer guides',
        'docs/api/': 'API documentation',
        'docs/architecture/': 'Architecture documentation',
        'scripts/build/': 'Build scripts',
        'scripts/testing/': 'Testing scripts',
        'scripts/deployment/': 'Deployment scripts',
        'config/': 'Configuration files',
        'config/platforms/': 'Platform-specific configs',
        'examples/': 'Example code and demos',
        'prototype/': 'Prototype and experimental code'
    }
    
    for dir_path, description in base_dirs.items():
        os.makedirs(dir_path, exist_ok=True)
        print(f"✅ Created: {dir_path} - {description}")

def organize_makefiles():
    """Organize Makefiles into proper structure"""
    makefiles = {
        'Makefile.multi-arch': 'tools/build/',
        'build-all-architectures.sh': 'tools/build/',
        'build-all-architectures-macos.sh': 'tools/build/',
        'build-macos.sh': 'tools/build/',
        'build.sh': 'tools/build/',
        'build_all.sh': 'tools/build/',
        'docker-build.sh': 'tools/build/',
        'benchmark-builds.sh': 'tools/testing/',
        'test_all.sh': 'tools/testing/',
    }
    
    for file, dest_dir in makefiles.items():
        if os.path.exists(file):
            os.makedirs(dest_dir, exist_ok=True)
            shutil.move(file, os.path.join(dest_dir, file))
            print(f"📁 Moved: {file} → {dest_dir}")

def organize_scripts():
    """Organize scripts into proper categories"""
    script_moves = {
        # Build scripts
        'scripts/build-graphics.sh': 'scripts/build/',
        'scripts/create_iso.sh': 'scripts/build/',
        'scripts/docker-builder.sh': 'scripts/build/',
        
        # Testing scripts  
        'scripts/test-qemu.sh': 'scripts/testing/',
        'scripts/test-all-features.sh': 'scripts/testing/',
        'scripts/test_emulated.sh': 'scripts/testing/',
        'scripts/test_qemu_tmux.sh': 'scripts/testing/',
        
        # Development tools
        'scripts/enhanced_license_tool.py': 'tools/development/',
        'scripts/version-manager.sh': 'tools/development/',
        'scripts/fix-assembly-headers.sh': 'tools/development/',
        
        # Security tools
        'scripts/security-scan.sh': 'tools/development/',
        'scripts/enhanced-cve-scanner.sh': 'tools/development/',
        'scripts/cve_scanner.py': 'tools/development/',
        'scripts/parse-cve-report.py': 'tools/development/',
    }
    
    for src, dest in script_moves.items():
        if os.path.exists(src):
            os.makedirs(dest, exist_ok=True)
            shutil.move(src, dest)
            print(f"📁 Moved: {src} → {dest}")

def organize_configs():
    """Organize configuration files"""
    config_files = {
        'config.txt': 'config/platforms/',
        'config_rpi5.txt': 'config/platforms/',
        'grub.cfg': 'config/',
        'mkdocs.yml': 'config/',
    }
    
    for file, dest_dir in config_files.items():
        if os.path.exists(file):
            os.makedirs(dest_dir, exist_ok=True)
            shutil.move(file, os.path.join(dest_dir, file))
            print(f"📁 Moved: {file} → {dest_dir}")

def organize_tools():
    """Organize development tools"""
    tools = {
        'add_license_headers.py': 'tools/development/',
        'apply-license-headers.py': 'tools/development/',
        'enhanced_license_headers.py': 'tools/development/',
        'license-checker.py': 'tools/development/',
        'create_elf_wrapper.py': 'tools/build/',
        'comprehensive-security-analysis.py': 'tools/development/',
        'quick-security-check.sh': 'tools/development/',
        'scan-vulnerabilities.sh': 'tools/development/',
        'VERIFY_BUILD_SYSTEM.sh': 'tools/testing/',
    }
    
    for file, dest_dir in tools.items():
        if os.path.exists(file):
            os.makedirs(dest_dir, exist_ok=True)
            shutil.move(file, os.path.join(dest_dir, file))
            print(f"📁 Moved: {file} → {dest_dir}")

def create_index_files():
    """Create index files for each directory"""
    directories = [
        'tools/', 'tools/build/', 'tools/testing/', 'tools/development/',
        'scripts/build/', 'scripts/testing/', 'scripts/deployment/',
        'config/', 'config/platforms/', 'examples/'
    ]
    
    for dir_path in directories:
        if os.path.exists(dir_path):
            index_file = os.path.join(dir_path, 'README.md')
            if not os.path.exists(index_file):
                with open(index_file, 'w') as f:
                    f.write(f"# {dir_path.replace('/', '').title()}\n\n")
                    f.write(f"This directory contains files related to {dir_path.replace('/', '').lower()}.\n\n")
                    f.write("## Contents\n\n")
                    
                    # List files in directory
                    try:
                        files = [f for f in os.listdir(dir_path) if f != 'README.md']
                        for file in sorted(files):
                            f.write(f"- `{file}`\n")
                    except:
                        pass
                    
                print(f"📄 Created: {index_file}")

def main():
    """Main organization function"""
    print("🚀 SAGE-OS Project Organization Tool")
    print("=" * 50)
    
    # Change to project root
    os.chdir('/workspace/SAGE-OS')
    
    print("\n📁 Creating directory structure...")
    create_directory_structure()
    
    print("\n📁 Organizing Makefiles...")
    organize_makefiles()
    
    print("\n📁 Organizing scripts...")
    organize_scripts()
    
    print("\n📁 Organizing configuration files...")
    organize_configs()
    
    print("\n📁 Organizing development tools...")
    organize_tools()
    
    print("\n📄 Creating index files...")
    create_index_files()
    
    print("\n✅ Project organization complete!")
    print("\nNew structure:")
    print("- tools/          - Development and build tools")
    print("- scripts/        - Organized scripts by category")
    print("- config/         - Configuration files")
    print("- examples/       - Example code and demos")
    print("- prototype/      - Restored prototype code")

if __name__ == "__main__":
    main()