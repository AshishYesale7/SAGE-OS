#!/usr/bin/env python3
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

"""
Enhanced License Header Management Tool for SAGE OS

This tool automatically adds license headers to source files across multiple
programming languages and file formats. It supports a comprehensive range of
file types that could be used in the SAGE OS project.

Features:
- Support for 50+ programming languages and file formats
- Multiple comment styles (C-style, hash-style, HTML-style, etc.)
- Smart detection of existing headers
- Preservation of shebangs and special declarations
- Configurable exclusion patterns
- Dry-run mode for testing
- Detailed logging and reporting
"""

import os
import re
import sys
import argparse
import json
import logging
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Set
from dataclasses import dataclass
from datetime import datetime

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger(__name__)

@dataclass
class CommentStyle:
    """Defines how comments are formatted for a specific style."""
    name: str
    start: str
    middle: str
    end: str
    line_prefix: str = ""
    
    def format_header(self, content: str) -> str:
        """Format the license header content with this comment style."""
        lines = content.strip().split('\n')
        
        if self.start and self.end:
            # Block comment style (e.g., /* ... */)
            formatted_lines = [self.start]
            for line in lines:
                if line.strip():
                    formatted_lines.append(f"{self.middle}{line}")
                else:
                    formatted_lines.append(self.middle.rstrip())
            formatted_lines.append(self.end)
        else:
            # Line comment style (e.g., // or #)
            formatted_lines = []
            for line in lines:
                if line.strip():
                    formatted_lines.append(f"{self.line_prefix}{line}")
                else:
                    formatted_lines.append(self.line_prefix.rstrip())
        
        return '\n'.join(formatted_lines) + '\n'

# Define comment styles
COMMENT_STYLES = {
    'c-style': CommentStyle(
        name='C-style block comments',
        start='/*',
        middle=' * ',
        end=' */',
        line_prefix=''
    ),
    'cpp-style': CommentStyle(
        name='C++ style line comments',
        start='',
        middle='',
        end='',
        line_prefix='// '
    ),
    'hash-style': CommentStyle(
        name='Hash style comments',
        start='',
        middle='',
        end='',
        line_prefix='# '
    ),
    'html-style': CommentStyle(
        name='HTML/XML style comments',
        start='<!--',
        middle='',
        end='-->',
        line_prefix=''
    ),
    'sql-style': CommentStyle(
        name='SQL style comments',
        start='',
        middle='',
        end='',
        line_prefix='-- '
    ),
    'lua-style': CommentStyle(
        name='Lua style comments',
        start='--[[',
        middle='',
        end='--]]',
        line_prefix=''
    ),
    'matlab-style': CommentStyle(
        name='MATLAB style comments',
        start='',
        middle='',
        end='',
        line_prefix='% '
    ),
    'latex-style': CommentStyle(
        name='LaTeX style comments',
        start='',
        middle='',
        end='',
        line_prefix='% '
    ),
    'vim-style': CommentStyle(
        name='Vim script comments',
        start='',
        middle='',
        end='',
        line_prefix='" '
    ),
    'lisp-style': CommentStyle(
        name='Lisp style comments',
        start='',
        middle='',
        end='',
        line_prefix=';; '
    ),
    'haskell-style': CommentStyle(
        name='Haskell style comments',
        start='{-',
        middle='',
        end='-}',
        line_prefix=''
    ),
    'erlang-style': CommentStyle(
        name='Erlang style comments',
        start='',
        middle='',
        end='',
        line_prefix='% '
    ),
    'fortran-style': CommentStyle(
        name='Fortran style comments',
        start='',
        middle='',
        end='',
        line_prefix='! '
    ),
    'ada-style': CommentStyle(
        name='Ada style comments',
        start='',
        middle='',
        end='',
        line_prefix='-- '
    ),
    'pascal-style': CommentStyle(
        name='Pascal style comments',
        start='(*',
        middle='',
        end='*)',
        line_prefix=''
    ),
    'batch-style': CommentStyle(
        name='Batch file comments',
        start='',
        middle='',
        end='',
        line_prefix='REM '
    ),
    'powershell-style': CommentStyle(
        name='PowerShell style comments',
        start='<#',
        middle='',
        end='#>',
        line_prefix=''
    ),
    'markdown-style': CommentStyle(
        name='Markdown style comments',
        start='<!--',
        middle='',
        end='-->',
        line_prefix=''
    ),
    'text-style': CommentStyle(
        name='Plain text style',
        start='',
        middle='',
        end='',
        line_prefix=''
    )
}

# Comprehensive file extension to comment style mapping
FILE_EXTENSIONS = {
    # C/C++ family
    '.c': 'c-style',
    '.h': 'c-style',
    '.cpp': 'c-style',
    '.cxx': 'c-style',
    '.cc': 'c-style',
    '.hpp': 'c-style',
    '.hxx': 'c-style',
    '.hh': 'c-style',
    '.c++': 'c-style',
    '.h++': 'c-style',
    '.inl': 'c-style',
    '.inc': 'c-style',
    '.tcc': 'c-style',
    
    # C# and .NET
    '.cs': 'cpp-style',
    '.csx': 'cpp-style',
    '.vb': 'cpp-style',
    '.fs': 'cpp-style',
    '.fsx': 'cpp-style',
    
    # Java family
    '.java': 'cpp-style',
    '.scala': 'cpp-style',
    '.kt': 'cpp-style',
    '.kts': 'cpp-style',
    '.groovy': 'cpp-style',
    '.gradle': 'cpp-style',
    
    # JavaScript/TypeScript family
    '.js': 'cpp-style',
    '.jsx': 'cpp-style',
    '.ts': 'cpp-style',
    '.tsx': 'cpp-style',
    '.mjs': 'cpp-style',
    '.cjs': 'cpp-style',
    '.vue': 'html-style',
    '.svelte': 'html-style',
    
    # Web technologies
    '.html': 'html-style',
    '.htm': 'html-style',
    '.xhtml': 'html-style',
    '.xml': 'html-style',
    '.svg': 'html-style',
    '.xsl': 'html-style',
    '.xslt': 'html-style',
    '.xaml': 'html-style',
    '.css': 'c-style',
    '.scss': 'cpp-style',
    '.sass': 'cpp-style',
    '.less': 'cpp-style',
    '.styl': 'cpp-style',
    
    # Python family
    '.py': 'hash-style',
    '.pyx': 'hash-style',
    '.pxd': 'hash-style',
    '.pxi': 'hash-style',
    '.pyw': 'hash-style',
    '.py3': 'hash-style',
    '.pyi': 'hash-style',
    
    # Shell scripting
    '.sh': 'hash-style',
    '.bash': 'hash-style',
    '.zsh': 'hash-style',
    '.fish': 'hash-style',
    '.ksh': 'hash-style',
    '.csh': 'hash-style',
    '.tcsh': 'hash-style',
    
    # Ruby family
    '.rb': 'hash-style',
    '.rbw': 'hash-style',
    '.rake': 'hash-style',
    '.gemspec': 'hash-style',
    '.ru': 'hash-style',
    
    # Perl family
    '.pl': 'hash-style',
    '.pm': 'hash-style',
    '.pod': 'hash-style',
    '.t': 'hash-style',
    '.psgi': 'hash-style',
    
    # PHP
    '.php': 'cpp-style',
    '.php3': 'cpp-style',
    '.php4': 'cpp-style',
    '.php5': 'cpp-style',
    '.phtml': 'cpp-style',
    '.phps': 'cpp-style',
    
    # Go
    '.go': 'cpp-style',
    
    # Rust
    '.rs': 'cpp-style',
    
    # Swift
    '.swift': 'cpp-style',
    
    # Objective-C
    '.m': 'cpp-style',
    '.mm': 'cpp-style',
    
    # D language
    '.d': 'cpp-style',
    '.di': 'cpp-style',
    
    # Assembly
    '.s': 'hash-style',
    '.S': 'cpp-style',
    '.asm': 'hash-style',
    '.nasm': 'hash-style',
    '.inc': 'hash-style',
    
    # Configuration files
    '.conf': 'hash-style',
    '.config': 'hash-style',
    '.cfg': 'hash-style',
    '.ini': 'hash-style',
    '.properties': 'hash-style',
    '.env': 'hash-style',
    '.toml': 'hash-style',
    '.yaml': 'hash-style',
    '.yml': 'hash-style',
    '.json': 'cpp-style',
    '.json5': 'cpp-style',
    '.jsonc': 'cpp-style',
    
    # Build systems
    '.mk': 'hash-style',
    '.make': 'hash-style',
    '.cmake': 'hash-style',
    '.am': 'hash-style',
    '.in': 'hash-style',
    '.ac': 'hash-style',
    '.m4': 'hash-style',
    '.scons': 'hash-style',
    '.waf': 'hash-style',
    '.ninja': 'hash-style',
    
    # Documentation
    '.md': 'markdown-style',
    '.markdown': 'markdown-style',
    '.mdown': 'markdown-style',
    '.mkd': 'markdown-style',
    '.rst': 'hash-style',
    '.txt': 'text-style',
    '.text': 'text-style',
    '.rtf': 'text-style',
    
    # LaTeX
    '.tex': 'latex-style',
    '.latex': 'latex-style',
    '.sty': 'latex-style',
    '.cls': 'latex-style',
    '.dtx': 'latex-style',
    '.ins': 'latex-style',
    
    # SQL
    '.sql': 'sql-style',
    '.mysql': 'sql-style',
    '.pgsql': 'sql-style',
    '.plsql': 'sql-style',
    '.tsql': 'sql-style',
    
    # R
    '.r': 'hash-style',
    '.R': 'hash-style',
    '.rmd': 'hash-style',
    '.rnw': 'hash-style',
    
    # MATLAB/Octave
    '.m': 'matlab-style',
    '.mat': 'matlab-style',
    '.fig': 'matlab-style',
    
    # Lua
    '.lua': 'lua-style',
    
    # Haskell
    '.hs': 'haskell-style',
    '.lhs': 'haskell-style',
    
    # Erlang/Elixir
    '.erl': 'erlang-style',
    '.hrl': 'erlang-style',
    '.ex': 'hash-style',
    '.exs': 'hash-style',
    
    # Lisp family
    '.lisp': 'lisp-style',
    '.lsp': 'lisp-style',
    '.cl': 'lisp-style',
    '.el': 'lisp-style',
    '.scm': 'lisp-style',
    '.ss': 'lisp-style',
    '.rkt': 'lisp-style',
    
    # Fortran
    '.f': 'fortran-style',
    '.f77': 'fortran-style',
    '.f90': 'fortran-style',
    '.f95': 'fortran-style',
    '.f03': 'fortran-style',
    '.f08': 'fortran-style',
    '.for': 'fortran-style',
    '.ftn': 'fortran-style',
    
    # Ada
    '.ada': 'ada-style',
    '.adb': 'ada-style',
    '.ads': 'ada-style',
    
    # Pascal
    '.pas': 'pascal-style',
    '.pp': 'pascal-style',
    '.inc': 'pascal-style',
    
    # COBOL
    '.cob': 'hash-style',
    '.cbl': 'hash-style',
    '.cpy': 'hash-style',
    
    # Vim
    '.vim': 'vim-style',
    '.vimrc': 'vim-style',
    
    # Batch/PowerShell
    '.bat': 'batch-style',
    '.cmd': 'batch-style',
    '.ps1': 'powershell-style',
    '.psm1': 'powershell-style',
    '.psd1': 'powershell-style',
    
    # Protocol Buffers
    '.proto': 'cpp-style',
    
    # GraphQL
    '.graphql': 'hash-style',
    '.gql': 'hash-style',
    
    # Docker
    '.dockerfile': 'hash-style',
    
    # Terraform
    '.tf': 'hash-style',
    '.tfvars': 'hash-style',
    
    # Ansible
    '.ansible': 'hash-style',
    
    # Kubernetes
    '.k8s': 'hash-style',
    
    # Other formats
    '.awk': 'hash-style',
    '.sed': 'hash-style',
    '.tcl': 'hash-style',
    '.tk': 'hash-style',
    '.expect': 'hash-style',
    '.jinja': 'hash-style',
    '.j2': 'hash-style',
    '.mustache': 'hash-style',
    '.handlebars': 'hash-style',
    '.hbs': 'hash-style',
}

# Special filename patterns (without extensions)
SPECIAL_FILES = {
    'Makefile': 'hash-style',
    'makefile': 'hash-style',
    'GNUmakefile': 'hash-style',
    'CMakeLists.txt': 'hash-style',
    'Dockerfile': 'hash-style',
    'Vagrantfile': 'hash-style',
    'Rakefile': 'hash-style',
    'Gemfile': 'hash-style',
    'Podfile': 'hash-style',
    'Brewfile': 'hash-style',
    'Procfile': 'hash-style',
    'Jenkinsfile': 'hash-style',
    '.gitignore': 'hash-style',
    '.gitattributes': 'hash-style',
    '.dockerignore': 'hash-style',
    '.eslintrc': 'hash-style',
    '.prettierrc': 'hash-style',
    '.babelrc': 'hash-style',
    '.editorconfig': 'hash-style',
    '.clang-format': 'hash-style',
    '.clang-tidy': 'hash-style',
}

# Directories to exclude from processing
EXCLUDE_DIRS = {
    '.git', '.github', '.svn', '.hg', '.bzr',
    'build', 'builds', 'bin', 'obj', 'out', 'output',
    'dist', 'target', 'release', 'debug',
    'node_modules', 'bower_components',
    'vendor', 'third_party', 'external', 'deps', 'dependencies',
    'venv', 'env', '.venv', '.env', 'virtualenv',
    '__pycache__', '.pytest_cache', '.mypy_cache',
    '.idea', '.vscode', '.vs', '.atom', '.sublime',
    'cmake-build-debug', 'cmake-build-release',
    '.gradle', '.maven',
    'coverage', '.coverage', '.nyc_output',
    'logs', 'log', 'tmp', 'temp', 'cache', '.cache',
    'backup', 'backups', '.backup',
    'test-results', 'test-reports',
    'documentation', 'docs/_build', 'site',
}

# Files to exclude from processing
EXCLUDE_FILES = {
    # License and documentation files
    'LICENSE', 'LICENSE.txt', 'LICENSE.md', 'COPYING', 'COPYRIGHT',
    'README.md', 'README.txt', 'README.rst', 'README',
    'CHANGELOG.md', 'CHANGELOG.txt', 'CHANGELOG.rst', 'CHANGELOG',
    'CONTRIBUTING.md', 'CONTRIBUTING.txt', 'CONTRIBUTING.rst',
    'CODE_OF_CONDUCT.md', 'SECURITY.md', 'SUPPORT.md',
    'AUTHORS', 'AUTHORS.txt', 'AUTHORS.md',
    'CONTRIBUTORS', 'CONTRIBUTORS.txt', 'CONTRIBUTORS.md',
    'MAINTAINERS', 'MAINTAINERS.txt', 'MAINTAINERS.md',
    'NOTICE', 'NOTICE.txt', 'NOTICE.md',
    'COMMERCIAL_TERMS.md', 'USAGE_GUIDE.md',
    
    # Configuration files that shouldn't have headers
    '.gitignore', '.gitattributes', '.gitmodules',
    '.editorconfig', '.prettierrc', '.eslintrc',
    '.npmrc', '.yarnrc', '.bowerrc',
    'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml',
    'Cargo.lock', 'go.sum', 'poetry.lock', 'Pipfile.lock',
    'composer.lock', 'mix.lock',
    
    # System files
    '.DS_Store', 'Thumbs.db', 'desktop.ini',
    
    # Compiled/generated files
    '*.min.js', '*.min.css', '*.bundle.js', '*.bundle.css',
    '*.map', '*.d.ts',
    
    # Binary files (will be detected automatically)
    # Note: These patterns are for reference - binary detection is automatic
}

# Patterns to detect existing license headers
LICENSE_PATTERNS = [
    r'Copyright.*Ashish.*Yesale',
    r'SAGE OS.*Copyright',
    r'SPDX-License-Identifier',
    r'This file is part of the SAGE OS Project',
    r'ashishyesale007@gmail\.com',
    r'Licensed under',
    r'All rights reserved',
    r'Permission is hereby granted',
    r'MIT License',
    r'Apache License',
    r'GNU General Public License',
    r'GPL-[0-9]',
    r'LGPL-[0-9]',
]

class LicenseHeaderProcessor:
    """Main class for processing license headers."""
    
    def __init__(self, template_dir: str = None, verbose: bool = False):
        self.template_dir = template_dir or '.github/license-templates'
        self.verbose = verbose
        self.stats = {
            'processed': 0,
            'modified': 0,
            'skipped': 0,
            'errors': 0,
            'by_type': {}
        }
        
    def has_license_header(self, file_path: str) -> bool:
        """Check if the file already has a license header."""
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                # Read first 5000 chars to check for header
                content = f.read(5000)
                
                # Check for any of the license patterns
                for pattern in LICENSE_PATTERNS:
                    if re.search(pattern, content, re.IGNORECASE):
                        return True
                
                return False
        except (IOError, OSError, UnicodeDecodeError):
            # Can't read the file or it's binary, skip it
            return True
    
    def is_binary_file(self, file_path: str) -> bool:
        """Check if a file is binary."""
        try:
            with open(file_path, 'rb') as f:
                chunk = f.read(1024)
                # Check for null bytes (common in binary files)
                if b'\0' in chunk:
                    return True
                # Check for high percentage of non-printable characters
                printable = sum(1 for byte in chunk if 32 <= byte <= 126 or byte in [9, 10, 13])
                return len(chunk) > 0 and printable / len(chunk) < 0.7
        except (IOError, OSError):
            return True
    
    def should_process_file(self, file_path: str, repo_root: str) -> Optional[str]:
        """Determine if a file should be processed and return the comment style."""
        rel_path = os.path.relpath(file_path, repo_root)
        file_name = os.path.basename(file_path)
        
        # Skip if file is too large (> 10MB)
        try:
            if os.path.getsize(file_path) > 10 * 1024 * 1024:
                if self.verbose:
                    logger.info(f"Skipping large file: {rel_path}")
                return None
        except OSError:
            return None
        
        # Skip binary files
        if self.is_binary_file(file_path):
            if self.verbose:
                logger.debug(f"Skipping binary file: {rel_path}")
            return None
        
        # Skip excluded files by exact name
        if file_name in EXCLUDE_FILES:
            if self.verbose:
                logger.debug(f"Skipping excluded file: {rel_path}")
            return None
        
        # Skip excluded files by pattern
        for pattern in [f for f in EXCLUDE_FILES if '*' in f]:
            if re.match(pattern.replace('*', '.*'), file_name):
                if self.verbose:
                    logger.debug(f"Skipping file matching pattern {pattern}: {rel_path}")
                return None
        
        # Skip files in excluded directories
        path_parts = rel_path.split(os.sep)
        for exclude_dir in EXCLUDE_DIRS:
            if exclude_dir in path_parts:
                if self.verbose:
                    logger.debug(f"Skipping file in excluded directory {exclude_dir}: {rel_path}")
                return None
        
        # Get comment style
        comment_style = self.get_comment_style(file_path)
        if not comment_style:
            if self.verbose:
                logger.debug(f"No comment style found for: {rel_path}")
            return None
        
        # Check if file already has a license header
        if self.has_license_header(file_path):
            if self.verbose:
                logger.debug(f"File already has license header: {rel_path}")
            return None
        
        return comment_style
    
    def get_comment_style(self, file_path: str) -> Optional[str]:
        """Determine the comment style based on file extension or name."""
        file_name = os.path.basename(file_path)
        
        # Check special filenames first
        if file_name in SPECIAL_FILES:
            return SPECIAL_FILES[file_name]
        
        # Check file extension
        ext = os.path.splitext(file_path)[1].lower()
        if ext in FILE_EXTENSIONS:
            return FILE_EXTENSIONS[ext]
        
        # Check for files without extensions that might be scripts
        if not ext and os.access(file_path, os.X_OK):
            # Try to detect shebang
            try:
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                    first_line = f.readline().strip()
                    if first_line.startswith('#!'):
                        if 'python' in first_line:
                            return 'hash-style'
                        elif any(shell in first_line for shell in ['bash', 'sh', 'zsh', 'fish']):
                            return 'hash-style'
                        elif 'node' in first_line:
                            return 'cpp-style'
            except (IOError, OSError):
                pass
        
        return None
    
    def get_license_template(self, comment_style: str) -> Optional[str]:
        """Get the license template content for the given comment style."""
        template_path = os.path.join(self.template_dir, f"{comment_style}.txt")
        
        if not os.path.exists(template_path):
            # Try to generate template from base content
            return self.generate_template(comment_style)
        
        try:
            with open(template_path, 'r', encoding='utf-8') as f:
                return f.read()
        except (IOError, OSError) as e:
            logger.error(f"Error reading template {template_path}: {e}")
            return None
    
    def generate_template(self, comment_style: str) -> Optional[str]:
        """Generate a license template for the given comment style."""
        base_content = """─────────────────────────────────────────────────────────────────────────────
SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
SPDX-License-Identifier: BSD-3-Clause OR Proprietary
SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.

This file is part of the SAGE OS Project.
─────────────────────────────────────────────────────────────────────────────"""
        
        if comment_style in COMMENT_STYLES:
            style = COMMENT_STYLES[comment_style]
            return style.format_header(base_content)
        
        return None
    
    def add_license_header(self, file_path: str, comment_style: str) -> bool:
        """Add license header to the file."""
        try:
            # Get the license template
            header = self.get_license_template(comment_style)
            if not header:
                logger.error(f"No template found for comment style: {comment_style}")
                return False
            
            # Read the file content
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            # Prepare the new content with the license header
            new_content = self.insert_header(content, header, file_path)
            
            # Write the new content back to the file
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            
            logger.info(f"Added license header to {file_path}")
            return True
            
        except Exception as e:
            logger.error(f"Error adding license to {file_path}: {e}")
            return False
    
    def insert_header(self, content: str, header: str, file_path: str) -> str:
        """Insert the license header into the content, preserving special elements."""
        file_ext = os.path.splitext(file_path)[1].lower()
        
        # Handle shebang line
        if content.startswith('#!'):
            shebang_end = content.find('\n') + 1
            return content[:shebang_end] + header + '\n' + content[shebang_end:]
        
        # Handle XML declaration
        if file_ext in ['.xml', '.html', '.xhtml', '.svg'] and content.lstrip().startswith('<?xml'):
            xml_end = content.find('?>') + 2
            return content[:xml_end] + '\n' + header + '\n' + content[xml_end:]
        
        # Handle HTML DOCTYPE
        if file_ext in ['.html', '.htm'] and content.lstrip().startswith('<!DOCTYPE'):
            doctype_end = content.find('>') + 1
            return content[:doctype_end] + '\n' + header + '\n' + content[doctype_end:]
        
        # Handle package.json and other structured files
        if file_ext == '.json':
            return header + '\n' + content
        
        # Default case - prepend the header
        return header + '\n' + content
    
    def process_directory(self, directory: str, recursive: bool = True, dry_run: bool = False) -> List[str]:
        """Process all files in the specified directory."""
        repo_root = os.path.abspath(directory)
        modified_files = []
        
        if not os.path.exists(self.template_dir):
            logger.error(f"Template directory not found: {self.template_dir}")
            return modified_files
        
        # Create missing template files
        self.ensure_templates()
        
        if recursive:
            for root, dirs, files in os.walk(repo_root):
                # Skip excluded directories
                dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS and not d.startswith('.')]
                
                for file in files:
                    file_path = os.path.join(root, file)
                    self.stats['processed'] += 1
                    
                    comment_style = self.should_process_file(file_path, repo_root)
                    
                    if comment_style:
                        rel_path = os.path.relpath(file_path, repo_root)
                        
                        # Update statistics
                        if comment_style not in self.stats['by_type']:
                            self.stats['by_type'][comment_style] = 0
                        self.stats['by_type'][comment_style] += 1
                        
                        if not dry_run:
                            if self.add_license_header(file_path, comment_style):
                                modified_files.append(rel_path)
                                self.stats['modified'] += 1
                            else:
                                self.stats['errors'] += 1
                        else:
                            modified_files.append(rel_path)
                            logger.info(f"Would add license header to {rel_path} ({comment_style})")
                    else:
                        self.stats['skipped'] += 1
        
        return modified_files
    
    def ensure_templates(self):
        """Ensure all required template files exist."""
        os.makedirs(self.template_dir, exist_ok=True)
        
        for style_name in COMMENT_STYLES.keys():
            template_path = os.path.join(self.template_dir, f"{style_name}.txt")
            if not os.path.exists(template_path):
                template_content = self.generate_template(style_name)
                if template_content:
                    try:
                        with open(template_path, 'w', encoding='utf-8') as f:
                            f.write(template_content)
                        logger.info(f"Created template file: {template_path}")
                    except (IOError, OSError) as e:
                        logger.error(f"Error creating template {template_path}: {e}")
    
    def print_statistics(self):
        """Print processing statistics."""
        logger.info("Processing Statistics:")
        logger.info(f"  Files processed: {self.stats['processed']}")
        logger.info(f"  Files modified: {self.stats['modified']}")
        logger.info(f"  Files skipped: {self.stats['skipped']}")
        logger.info(f"  Errors: {self.stats['errors']}")
        
        if self.stats['by_type']:
            logger.info("  By comment style:")
            for style, count in sorted(self.stats['by_type'].items()):
                logger.info(f"    {style}: {count}")

def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description='Enhanced License Header Management Tool for SAGE OS',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --dir . --recursive                    # Add headers to all files recursively
  %(prog)s --check-only --verbose                 # Check for missing headers with details
  %(prog)s --dry-run --dir src                    # Preview changes without modifying files
  %(prog)s --template-dir custom/templates        # Use custom template directory
        """
    )
    
    parser.add_argument('--dir', '-d', default='.', 
                       help='Directory to process (default: current directory)')
    parser.add_argument('--recursive', '-r', action='store_true', default=True,
                       help='Process directories recursively (default: True)')
    parser.add_argument('--template-dir', '-t', 
                       help='Directory containing license templates (default: .github/license-templates)')
    parser.add_argument('--check-only', action='store_true',
                       help='Only check for missing headers, do not modify files')
    parser.add_argument('--dry-run', action='store_true',
                       help='Show what would be done without making changes')
    parser.add_argument('--verbose', '-v', action='store_true',
                       help='Enable verbose output')
    parser.add_argument('--quiet', '-q', action='store_true',
                       help='Suppress all output except errors')
    parser.add_argument('--stats', action='store_true',
                       help='Show detailed statistics')
    parser.add_argument('--list-supported', action='store_true',
                       help='List all supported file types and comment styles')
    
    args = parser.parse_args()
    
    # Configure logging level
    if args.quiet:
        logging.getLogger().setLevel(logging.ERROR)
    elif args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    
    # List supported file types
    if args.list_supported:
        print("Supported File Types and Comment Styles:")
        print("=" * 50)
        
        by_style = {}
        for ext, style in FILE_EXTENSIONS.items():
            if style not in by_style:
                by_style[style] = []
            by_style[style].append(ext)
        
        for style, extensions in sorted(by_style.items()):
            print(f"\n{style.upper()}:")
            print(f"  Extensions: {', '.join(sorted(extensions))}")
            if style in COMMENT_STYLES:
                comment_style = COMMENT_STYLES[style]
                print(f"  Comment format: {comment_style.name}")
        
        print(f"\nSpecial files: {', '.join(sorted(SPECIAL_FILES.keys()))}")
        return 0
    
    # Initialize processor
    processor = LicenseHeaderProcessor(
        template_dir=args.template_dir,
        verbose=args.verbose
    )
    
    try:
        if args.check_only:
            # Check mode - identify files that need headers
            logger.info(f"Checking for files without license headers in {args.dir}...")
            
            missing_files = processor.process_directory(
                args.dir, 
                recursive=args.recursive, 
                dry_run=True
            )
            
            if missing_files:
                logger.warning(f"Found {len(missing_files)} files missing license headers:")
                for file_path in missing_files:
                    print(f"  - {file_path}")
                return 1
            else:
                logger.info("All files have license headers")
                return 0
        
        else:
            # Normal mode - add headers
            logger.info(f"Processing files in {args.dir}...")
            
            modified_files = processor.process_directory(
                args.dir,
                recursive=args.recursive,
                dry_run=args.dry_run
            )
            
            if args.dry_run:
                logger.info(f"Would modify {len(modified_files)} files")
            else:
                logger.info(f"Modified {len(modified_files)} files")
            
            if args.stats or args.verbose:
                processor.print_statistics()
            
            if modified_files and not args.quiet:
                print("\nProcessed files:")
                for file_path in modified_files:
                    print(f"  - {file_path}")
        
        return 0
        
    except KeyboardInterrupt:
        logger.error("Operation cancelled by user")
        return 130
    except Exception as e:
        logger.error(f"Error: {e}")
        if args.verbose:
            import traceback
            traceback.print_exc()
        return 1

if __name__ == "__main__":
    sys.exit(main())