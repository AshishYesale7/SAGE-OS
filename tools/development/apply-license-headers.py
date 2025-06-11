#!/usr/bin/env python3
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

"""
SAGE OS License Header Application Tool
This script applies appropriate license headers to source files based on their extensions.
"""

import os
import sys
import glob
import argparse
from pathlib import Path

# File extension to template mapping
EXTENSION_TEMPLATES = {
    '.c': 'c-style.txt',
    '.h': 'c-style.txt',
    '.cpp': 'cpp-style.txt',
    '.cxx': 'cpp-style.txt',
    '.cc': 'cpp-style.txt',
    '.hpp': 'cpp-style.txt',
    '.hxx': 'cpp-style.txt',
    '.py': 'python-style.txt',
    '.sh': 'hash-style.txt',
    '.bash': 'hash-style.txt',
    '.rb': 'ruby-style.txt',
    '.pl': 'perl-style.txt',
    '.pm': 'perl-style.txt',
    '.js': 'javascript-style.txt',
    '.ts': 'typescript-style.txt',
    '.jsx': 'javascript-style.txt',
    '.tsx': 'typescript-style.txt',
    '.S': 'assembly-style.txt',
    '.s': 'assembly-style.txt',
    '.asm': 'assembly-style.txt',
    '.java': 'java-style.txt',
    '.go': 'go-style.txt',
    '.rs': 'rust-style.txt',
    '.php': 'php-style.txt',
    '.yaml': 'yaml-style.txt',
    '.yml': 'yaml-style.txt',
    '.toml': 'toml-style.txt',
    '.ini': 'ini-style.txt',
    '.cfg': 'ini-style.txt',
    '.conf': 'ini-style.txt',
    '.css': 'css-style.txt',
    '.scss': 'scss-style.txt',
    '.kt': 'kotlin-style.txt',
    '.scala': 'scala-style.txt',
    '.cs': 'csharp-style.txt',
    '.swift': 'swift-style.txt',
    '.dart': 'dart-style.txt',
    '.ex': 'elixir-style.txt',
    '.exs': 'elixir-style.txt',
    '.clj': 'clojure-style.txt',
    '.cljs': 'clojure-style.txt',
    '.r': 'r-style.txt',
    '.R': 'r-style.txt',
    '.groovy': 'groovy-style.txt',
    '.gradle': 'gradle-style.txt',
}

# Special file names
SPECIAL_FILES = {
    'Makefile': 'makefile-style.txt',
    'makefile': 'makefile-style.txt',
    'GNUmakefile': 'makefile-style.txt',
    'CMakeLists.txt': 'cmake-style.txt',
    'Dockerfile': 'dockerfile-style.txt',
}

# Files to skip
SKIP_FILES = {
    '.gitignore',
    '.gitmodules',
    'LICENSE',
    'README.md',
    'CHANGELOG.md',
    'CONTRIBUTING.md',
    'COMMERCIAL_TERMS.md',
}

# Directories to skip
SKIP_DIRS = {
    '.git',
    'build',
    'build-output',
    'security-reports',
    'node_modules',
    '__pycache__',
    '.pytest_cache',
    'dist',
    'target',
}

def get_template_for_file(file_path):
    """Get the appropriate license template for a file."""
    file_name = os.path.basename(file_path)
    
    # Check special file names first
    if file_name in SPECIAL_FILES:
        return SPECIAL_FILES[file_name]
    
    # Check file extension
    _, ext = os.path.splitext(file_path)
    if ext.lower() in EXTENSION_TEMPLATES:
        return EXTENSION_TEMPLATES[ext.lower()]
    
    return None

def load_template(template_name):
    """Load a license template from the templates directory."""
    template_path = os.path.join('.github', 'license-templates', template_name)
    if not os.path.exists(template_path):
        print(f"Warning: Template not found: {template_path}")
        return None
    
    with open(template_path, 'r', encoding='utf-8') as f:
        return f.read()

def has_license_header(file_path):
    """Check if a file already has a SAGE OS license header."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read(2000)  # Read first 2000 characters
            return 'SAGE OS —' in content and 'Ashish Vasant Yesale' in content
    except (UnicodeDecodeError, IOError):
        return False

def apply_license_header(file_path, template_content, dry_run=False):
    """Apply license header to a file."""
    if has_license_header(file_path):
        print(f"  ✅ Already has license: {file_path}")
        return True
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            original_content = f.read()
    except (UnicodeDecodeError, IOError) as e:
        print(f"  ❌ Cannot read file: {file_path} ({e})")
        return False
    
    # Handle shebang lines
    lines = original_content.split('\n')
    shebang = ""
    content_start = 0
    
    if lines and lines[0].startswith('#!'):
        shebang = lines[0] + '\n'
        content_start = 1
    
    # Combine shebang + license + original content
    new_content = shebang + template_content + '\n\n' + '\n'.join(lines[content_start:])
    
    if dry_run:
        print(f"  📝 Would add license: {file_path}")
        return True
    
    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"  ✅ Added license: {file_path}")
        return True
    except IOError as e:
        print(f"  ❌ Cannot write file: {file_path} ({e})")
        return False

def should_skip_file(file_path):
    """Check if a file should be skipped."""
    file_name = os.path.basename(file_path)
    
    # Skip specific files
    if file_name in SKIP_FILES:
        return True
    
    # Skip binary files and other extensions
    if file_name.endswith(('.img', '.elf', '.bin', '.iso', '.o', '.a', '.so', '.exe', '.dll')):
        return True
    
    # Skip hidden files (except specific ones we want to process)
    if file_name.startswith('.') and file_name not in {'.gitignore'}:
        return True
    
    return False

def should_skip_dir(dir_path):
    """Check if a directory should be skipped."""
    dir_name = os.path.basename(dir_path)
    return dir_name in SKIP_DIRS

def find_source_files(root_dir):
    """Find all source files that need license headers."""
    source_files = []
    
    for root, dirs, files in os.walk(root_dir):
        # Skip certain directories
        dirs[:] = [d for d in dirs if not should_skip_dir(os.path.join(root, d))]
        
        for file in files:
            file_path = os.path.join(root, file)
            
            if should_skip_file(file_path):
                continue
            
            template = get_template_for_file(file_path)
            if template:
                source_files.append((file_path, template))
    
    return source_files

def main():
    parser = argparse.ArgumentParser(description='Apply SAGE OS license headers to source files')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be done without making changes')
    parser.add_argument('--directory', default='.', help='Directory to process (default: current directory)')
    parser.add_argument('--force', action='store_true', help='Overwrite existing license headers')
    
    args = parser.parse_args()
    
    print("🏷️  SAGE OS License Header Application Tool")
    print("==========================================")
    
    if args.dry_run:
        print("🔍 DRY RUN MODE - No files will be modified")
    
    print(f"📁 Processing directory: {args.directory}")
    print("")
    
    # Find all source files
    source_files = find_source_files(args.directory)
    
    if not source_files:
        print("❌ No source files found to process")
        return 1
    
    print(f"📋 Found {len(source_files)} source files to process")
    print("")
    
    # Group files by template
    template_groups = {}
    for file_path, template_name in source_files:
        if template_name not in template_groups:
            template_groups[template_name] = []
        template_groups[template_name].append(file_path)
    
    # Process each template group
    total_processed = 0
    total_success = 0
    
    for template_name, files in template_groups.items():
        print(f"📄 Processing {len(files)} files with template: {template_name}")
        
        template_content = load_template(template_name)
        if not template_content:
            print(f"  ❌ Skipping files due to missing template")
            continue
        
        for file_path in files:
            if apply_license_header(file_path, template_content, args.dry_run):
                total_success += 1
            total_processed += 1
        
        print("")
    
    # Summary
    print("📊 Summary:")
    print("===========")
    print(f"Files processed: {total_processed}")
    print(f"Successfully updated: {total_success}")
    print(f"Failed: {total_processed - total_success}")
    
    if args.dry_run:
        print("")
        print("💡 Run without --dry-run to apply changes")
    
    return 0 if total_success == total_processed else 1

if __name__ == '__main__':
    sys.exit(main())