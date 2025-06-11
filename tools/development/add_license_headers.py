#!/usr/bin/env python3
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

import os
import re
import sys
import argparse
from pathlib import Path

# File extensions and their comment styles
COMMENT_STYLES = {
    # C-style comments
    '.c': 'c-style',
    '.h': 'c-style',
    '.cpp': 'c-style',
    '.hpp': 'c-style',
    '.cc': 'c-style',
    '.cxx': 'c-style',
    '.rs': 'c-style',
    '.java': 'c-style',
    '.js': 'c-style',
    '.jsx': 'c-style',
    '.ts': 'c-style',
    '.tsx': 'c-style',
    '.css': 'c-style',
    '.scss': 'c-style',
    '.swift': 'c-style',
    '.go': 'c-style',
    '.kt': 'c-style',
    '.kts': 'c-style',
    '.scala': 'c-style',
    '.S': 'c-style',  # Assembly
    '.asm': 'c-style',
    '.json': 'c-style',
    '.proto': 'c-style',
    '.m': 'c-style',  # Objective-C
    '.mm': 'c-style', # Objective-C++
    '.cs': 'c-style', # C#
    '.fs': 'c-style', # F#
    '.d': 'c-style',  # D
    '.php': 'c-style',
    
    # Hash-style comments
    '.py': 'hash-style',
    '.sh': 'hash-style',
    '.bash': 'hash-style',
    '.zsh': 'hash-style',
    '.rb': 'hash-style',
    '.pl': 'hash-style',
    '.pm': 'hash-style',
    '.tcl': 'hash-style',
    '.yaml': 'hash-style',
    '.yml': 'hash-style',
    '.toml': 'hash-style',
    '.mk': 'hash-style',
    '.Makefile': 'hash-style',
    '.makefile': 'hash-style',
    '.cmake': 'hash-style',
    '.r': 'hash-style',
    '.R': 'hash-style',
    '.perl': 'hash-style',
    '.conf': 'hash-style',
    '.ini': 'hash-style',
    '.dockerfile': 'hash-style',
    'Dockerfile': 'hash-style',
    
    # HTML/XML-style comments
    '.html': 'html-style',
    '.htm': 'html-style',
    '.xml': 'html-style',
    '.svg': 'html-style',
    '.md': 'html-style',
    '.markdown': 'html-style',
    '.rst': 'html-style',
    '.xhtml': 'html-style',
    '.vue': 'html-style',
    '.jsx': 'html-style',  # JSX can use both HTML and C-style
    '.tsx': 'html-style',  # TSX can use both HTML and C-style
}

# Directories to exclude
EXCLUDE_DIRS = [
    '.git',
    '.github',
    'build',
    'bin',
    'obj',
    'node_modules',
    'vendor',
    'third_party',
    'external',
    'deps',
    'dist',
    'out',
    'target',
    'venv',
    'env',
    '.venv',
    '.env',
    '__pycache__',
    '.idea',
    '.vscode',
    '.vs',
    'cmake-build-*',
]

# Files to exclude
EXCLUDE_FILES = [
    'LICENSE',
    'LICENSE.txt',
    'LICENSE.md',
    'README.md',
    'README.txt',
    'CONTRIBUTING.md',
    'CHANGELOG.md',
    'COMMERCIAL_TERMS.md',
    'USAGE_GUIDE.md',
    '.gitignore',
    '.gitattributes',
    '.editorconfig',
    '.prettierrc',
    '.eslintrc',
    '.npmrc',
    'package-lock.json',
    'yarn.lock',
    'Cargo.lock',
    'go.sum',
    'poetry.lock',
    'Pipfile.lock',
    '.DS_Store',
    'Thumbs.db',
    '*.min.js',
    '*.min.css',
]

# Patterns to detect existing license headers
LICENSE_PATTERNS = [
    r'Copyright.*Ashish',
    r'SAGE OS',
    r'BSD-3-Clause',
    r'SPDX-License-Identifier',
    r'This file is part of the SAGE OS Project',
    r'ashishyesale007@gmail\.com',
]

def has_license_header(file_path):
    """Check if the file already has a license header."""
    try:
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            try:
                # Read first 3000 chars to check for header
                # This should be enough for most files, even with large headers
                content = f.read(3000)
                
                # Check for any of the license patterns
                for pattern in LICENSE_PATTERNS:
                    if re.search(pattern, content, re.IGNORECASE):
                        return True
                
                return False
            except UnicodeDecodeError:
                # Binary file or non-text file
                return True  # Skip binary files
    except (IOError, OSError):
        # Can't read the file, skip it
        return True

def get_comment_style(file_path):
    """Determine the comment style based on file extension."""
    ext = os.path.splitext(file_path)[1].lower()
    
    # Special case for Makefile without extension
    if os.path.basename(file_path).lower() in ['makefile']:
        return 'hash-style'
        
    return COMMENT_STYLES.get(ext)

def add_license_header(file_path, template_path):
    """Add license header to the file."""
    try:
        # Read the license template
        with open(template_path, 'r', encoding='utf-8') as template_file:
            header = template_file.read()
        
        # Read the file content
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        # Prepare the new content with the license header
        new_content = ""
        
        # Handle special cases based on file type
        file_ext = os.path.splitext(file_path)[1].lower()
        file_name = os.path.basename(file_path)
        
        # Check for shebang line
        if content.startswith('#!'):
            shebang_end = content.find('\n') + 1
            new_content = content[:shebang_end] + '\n' + header + content[shebang_end:]
        
        # Handle package.json and other JSON files
        elif file_ext == '.json':
            # For JSON files, we need to add the header as a comment before the JSON content
            new_content = header + '\n' + content
        
        # Handle XML files with XML declaration
        elif file_ext in ['.xml', '.html', '.xhtml', '.svg'] and content.lstrip().startswith('<?xml'):
            xml_end = content.find('?>') + 2
            new_content = content[:xml_end] + '\n' + header + content[xml_end:]
        
        # Handle HTML files with DOCTYPE
        elif file_ext in ['.html', '.htm'] and content.lstrip().startswith('<!DOCTYPE'):
            doctype_end = content.find('>') + 1
            new_content = content[:doctype_end] + '\n' + header + content[doctype_end:]
        
        # Default case - just prepend the header
        else:
            new_content = header + content
        
        # Write the new content back to the file
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        
        print(f"Added license header to {file_path}")
        return True
    except Exception as e:
        print(f"Error adding license to {file_path}: {e}")
        return False

def should_process_file(file_path, repo_root):
    """Determine if a file should be processed for license header addition."""
    rel_path = os.path.relpath(file_path, repo_root)
    file_name = os.path.basename(file_path)
    
    # Skip excluded files by exact name
    if file_name in EXCLUDE_FILES:
        return False
    
    # Skip excluded files by pattern
    for pattern in [f for f in EXCLUDE_FILES if '*' in f]:
        if re.match(pattern.replace('*', '.*'), file_name):
            return False
        
    # Skip files in excluded directories
    path_parts = rel_path.split(os.sep)
    for exclude_dir in EXCLUDE_DIRS:
        if '*' in exclude_dir:
            # Handle wildcard patterns in directory names
            pattern = exclude_dir.replace('*', '.*')
            if any(re.match(pattern, part) for part in path_parts):
                return False
        elif exclude_dir in path_parts:
            return False
    
    # Skip binary files and very large files
    try:
        if os.path.getsize(file_path) > 1024 * 1024:  # Skip files larger than 1MB
            return False
            
        # Try to read the first few bytes to check if it's a binary file
        with open(file_path, 'rb') as f:
            chunk = f.read(1024)
            if b'\0' in chunk:  # Binary files often contain null bytes
                return False
    except (IOError, OSError):
        return False
    
    # Get comment style
    comment_style = get_comment_style(file_path)
    if not comment_style:
        return False  # Skip files with unknown comment style
    
    # Check if file already has a license header
    try:
        if has_license_header(file_path):
            return False
    except (IOError, OSError):
        return False
    
    return comment_style

def process_files(directory='.', recursive=True):
    """Process all files in the specified directory."""
    repo_root = os.path.abspath(directory)
    template_dir = os.path.join(repo_root, '.github', 'license-templates')
    
    if not os.path.exists(template_dir):
        print(f"Error: Template directory not found at {template_dir}")
        return []
    
    modified_files = []
    
    if recursive:
        # Process all files recursively
        for root, dirs, files in os.walk(repo_root):
            # Skip excluded directories
            dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS and not d.startswith('.')]
            
            for file in files:
                file_path = os.path.join(root, file)
                comment_style = should_process_file(file_path, repo_root)
                
                if comment_style:
                    # Add license header
                    template_path = os.path.join(template_dir, f"{comment_style}.txt")
                    if add_license_header(file_path, template_path):
                        modified_files.append(os.path.relpath(file_path, repo_root))
    else:
        # Process only files in the specified directory (non-recursive)
        for file in os.listdir(repo_root):
            file_path = os.path.join(repo_root, file)
            
            # Skip directories
            if os.path.isdir(file_path):
                continue
                
            comment_style = should_process_file(file_path, repo_root)
            
            if comment_style:
                # Add license header
                template_path = os.path.join(template_dir, f"{comment_style}.txt")
                if add_license_header(file_path, template_path):
                    modified_files.append(os.path.relpath(file_path, repo_root))
    
    return modified_files

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Add license headers to source files')
    parser.add_argument('--dir', '-d', default='.', help='Directory to process')
    parser.add_argument('--recursive', '-r', action='store_true', help='Process directories recursively')
    parser.add_argument('--check-only', action='store_true', help='Only check for missing headers, do not modify files')
    parser.add_argument('--verbose', '-v', action='store_true', help='Enable verbose output')
    parser.add_argument('--quiet', '-q', action='store_true', help='Suppress all output except errors')
    
    args = parser.parse_args()
    
    # Validate template directory
    repo_root = os.path.abspath(args.dir)
    template_dir = os.path.join(repo_root, '.github', 'license-templates')
    
    if not os.path.exists(template_dir):
        print(f"Error: License template directory not found at {template_dir}")
        print("Please create the directory and add template files for each comment style:")
        print("  - c-style.txt: For C-style comments (/* ... */)")
        print("  - hash-style.txt: For hash-style comments (# ...)")
        print("  - html-style.txt: For HTML-style comments (<!-- ... -->)")
        sys.exit(1)
    
    # Check if template files exist
    required_templates = ['c-style.txt', 'hash-style.txt', 'html-style.txt']
    missing_templates = [t for t in required_templates if not os.path.exists(os.path.join(template_dir, t))]
    
    if missing_templates:
        print(f"Error: Missing license template files in {template_dir}:")
        for template in missing_templates:
            print(f"  - {template}")
        sys.exit(1)
    
    try:
        if args.check_only:
            # Check mode - just identify files that need headers
            missing_headers = []
            
            if not args.quiet:
                print(f"Checking for files without license headers in {repo_root}...")
            
            for root, dirs, files in os.walk(repo_root):
                # Skip excluded directories
                dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS and not d.startswith('.')]
                
                for file in files:
                    file_path = os.path.join(root, file)
                    comment_style = should_process_file(file_path, repo_root)
                    
                    if comment_style:
                        missing_headers.append((os.path.relpath(file_path, repo_root), comment_style))
            
            if missing_headers:
                if not args.quiet:
                    print(f"\nFound {len(missing_headers)} files missing license headers:")
                    for file, style in missing_headers:
                        print(f"  - {file} ({style})")
                sys.exit(1)
            else:
                if not args.quiet:
                    print("All files have license headers")
                sys.exit(0)
        else:
            # Normal mode - add headers
            if not args.quiet:
                print(f"Adding license headers to files in {repo_root}...")
            
            modified_files = process_files(args.dir, args.recursive)
            
            if not args.quiet:
                print(f"\nAdded license headers to {len(modified_files)} files")
                
                if modified_files:
                    print("\nModified files:")
                    for file in modified_files:
                        print(f"  - {file}")
                else:
                    print("No files needed license headers")
    except KeyboardInterrupt:
        print("\nOperation cancelled by user")
        sys.exit(130)
    except Exception as e:
        print(f"Error: {e}")
        if args.verbose:
            import traceback
            traceback.print_exc()
        sys.exit(1)