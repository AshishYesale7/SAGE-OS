#!/usr/bin/env python3
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────
"""
License checker script to verify that all source files have the correct license header.
"""

import os
import sys
import argparse
import re

def check_license_header(file_path, license_type):
    """Check if a file has the correct license header."""
    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read(500)  # Read first 500 chars to check for header
        
        # Check for BSD 3-Clause License
        if license_type == "BSD-3-Clause":
            if "BSD 3-Clause License" in content and "Copyright" in content:
                return True
        
        # Add more license types as needed
        
        return False

def find_source_files(directory):
    """Find all source files that should have license headers."""
    source_files = []
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith(('.c', '.h', '.cpp', '.hpp', '.cc', '.S')):
                source_files.append(os.path.join(root, file))
    return source_files

def main():
    parser = argparse.ArgumentParser(description='Check license headers in source files')
    parser.add_argument('--license', default='BSD-3-Clause', help='License type to check for')
    args = parser.parse_args()
    
    source_files = find_source_files('.')
    missing_headers = []
    
    for file_path in source_files:
        if not check_license_header(file_path, args.license):
            missing_headers.append(file_path)
    
    if missing_headers:
        print(f"Found {len(missing_headers)} files missing {args.license} license headers:")
        for file in missing_headers:
            print(f"- {file}")
        sys.exit(1)
    else:
        print(f"All source files have {args.license} license headers.")
        sys.exit(0)

if __name__ == "__main__":
    main()