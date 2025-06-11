#!/usr/bin/env python3
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
#
# ─────────────────────────────────────────────────────────────────────────────
# Licensing:
# -----------
#                                 
#                                                                             
#   Licensed under the BSD 3-Clause License or a Commercial License.          
#   You may use this file under the terms of either license as specified in: 
#                                                                             
#      - BSD 3-Clause License (see ./LICENSE)                           
#      - Commercial License (see ./COMMERCIAL_TERMS.md or contact legal@your.org)  
#                                                                             
#   Redistribution and use in source and binary forms, with or without       
#   modification, are permitted under the BSD license provided that the      
#   following conditions are met:                                            
#                                                                             
#     * Redistributions of source code must retain the above copyright       
#       notice, this list of conditions and the following disclaimer.       
#     * Redistributions in binary form must reproduce the above copyright    
#       notice, this list of conditions and the following disclaimer in the  
#       documentation and/or other materials provided with the distribution. 
#     * Neither the name of the project nor the names of its contributors    
#       may be used to endorse or promote products derived from this         
#       software without specific prior written permission.                  
#                                                                             
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS  
#   IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED    
#   TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A          
#   PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER 
#   OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
#   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,      
#   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR       
#   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF   
#   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     
#   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS       
#   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  
#
# By using this software, you agree to be bound by the terms of either license.
#
# Alternatively, commercial use with extended rights is available — contact the author for commercial licensing.
#
# ─────────────────────────────────────────────────────────────────────────────
# Contributor Guidelines:
# ------------------------
# Contributions are welcome under the terms of the Developer Certificate of Origin (DCO).
# All contributors must certify that they have the right to submit the code and agree to
# release it under the above license terms.
#
# Contributions must:
#   - Be original or appropriately attributed
#   - Include clear documentation and test cases where applicable
#   - Respect the coding and security guidelines defined in CONTRIBUTING.md
#
# ─────────────────────────────────────────────────────────────────────────────
# Terms of Use and Disclaimer:
# -----------------------------
# This software is provided "as is", without any express or implied warranty.
# In no event shall the authors, contributors, or copyright holders
# be held liable for any damages arising from the use of this software.
#
# Use of this software in critical systems (e.g., medical, nuclear, safety)
# is entirely at your own risk unless specifically licensed for such purposes.
#
# ─────────────────────────────────────────────────────────────────────────────

"""
Enhanced License Header Tool for SAGE OS
Supports 50+ file formats with proper license headers
"""

import os
import sys
import re
import argparse
from pathlib import Path
from typing import Dict, List, Tuple, Optional
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# License header template
LICENSE_TEMPLATE = """─────────────────────────────────────────────────────────────────────────────
SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
SPDX-License-Identifier: BSD-3-Clause OR Proprietary
SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.

This file is part of the SAGE OS Project.

─────────────────────────────────────────────────────────────────────────────
Licensing:
-----------
                                
                                                                            
  Licensed under the BSD 3-Clause License or a Commercial License.          
  You may use this file under the terms of either license as specified in: 
                                                                            
     - BSD 3-Clause License (see ./LICENSE)                           
     - Commercial License (see ./COMMERCIAL_TERMS.md or contact legal@your.org)  
                                                                            
  Redistribution and use in source and binary forms, with or without       
  modification, are permitted under the BSD license provided that the      
  following conditions are met:                                            
                                                                            
    * Redistributions of source code must retain the above copyright       
      notice, this list of conditions and the following disclaimer.       
    * Redistributions in binary form must reproduce the above copyright    
      notice, this list of conditions and the following disclaimer in the  
      documentation and/or other materials provided with the distribution. 
    * Neither the name of the project nor the names of its contributors    
      may be used to endorse or promote products derived from this         
      software without specific prior written permission.                  
                                                                            
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS  
  IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED    
  TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A          
  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER 
  OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,      
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR       
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF   
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS       
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  

By using this software, you agree to be bound by the terms of either license.

Alternatively, commercial use with extended rights is available — contact the author for commercial licensing.

─────────────────────────────────────────────────────────────────────────────
Contributor Guidelines:
------------------------
Contributions are welcome under the terms of the Developer Certificate of Origin (DCO).
All contributors must certify that they have the right to submit the code and agree to
release it under the above license terms.

Contributions must:
  - Be original or appropriately attributed
  - Include clear documentation and test cases where applicable
  - Respect the coding and security guidelines defined in CONTRIBUTING.md

─────────────────────────────────────────────────────────────────────────────
Terms of Use and Disclaimer:
-----------------------------
This software is provided "as is", without any express or implied warranty.
In no event shall the authors, contributors, or copyright holders
be held liable for any damages arising from the use of this software.

Use of this software in critical systems (e.g., medical, nuclear, safety)
is entirely at your own risk unless specifically licensed for such purposes.

─────────────────────────────────────────────────────────────────────────────"""

class LicenseHeaderManager:
    """Manages license headers for multiple file formats"""
    
    def __init__(self):
        self.file_patterns = {
            # C-style comments
            'c_style': {
                'extensions': ['.c', '.h', '.cpp', '.hpp', '.cc', '.cxx', '.c++', '.h++', '.hh', '.hxx',
                             '.java', '.js', '.jsx', '.ts', '.tsx', '.cs', '.php', '.go', '.rs', '.swift',
                             '.kt', '.kts', '.scala', '.groovy', '.dart', '.ino', '.pde'],
                'start': '/*',
                'prefix': ' *',
                'end': ' */',
                'shebang_aware': True
            },
            
            # Hash-style comments
            'hash_style': {
                'extensions': ['.py', '.rb', '.pl', '.sh', '.bash', '.zsh', '.fish', '.tcl', '.r', '.R',
                             '.yaml', '.yml', '.toml', '.cfg', '.conf', '.ini', '.properties', '.env',
                             '.dockerfile', '.gitignore', '.gitattributes', '.editorconfig'],
                'start': '#',
                'prefix': '#',
                'end': '#',
                'shebang_aware': True
            },
            
            # Double slash comments
            'double_slash': {
                'extensions': ['.cpp', '.hpp', '.cc', '.cxx', '.c++', '.h++', '.hh', '.hxx',
                             '.java', '.js', '.jsx', '.ts', '.tsx', '.cs', '.php', '.go', '.rs', '.swift',
                             '.kt', '.kts', '.scala', '.groovy', '.dart'],
                'start': '//',
                'prefix': '//',
                'end': '//',
                'shebang_aware': False
            },
            
            # HTML/XML style
            'html_style': {
                'extensions': ['.html', '.htm', '.xml', '.xhtml', '.svg', '.xaml', '.xsl', '.xslt'],
                'start': '<!--',
                'prefix': '  ',
                'end': '-->',
                'shebang_aware': False
            },
            
            # SQL style
            'sql_style': {
                'extensions': ['.sql', '.psql', '.mysql', '.sqlite'],
                'start': '--',
                'prefix': '--',
                'end': '--',
                'shebang_aware': False
            },
            
            # Lisp style
            'lisp_style': {
                'extensions': ['.lisp', '.lsp', '.cl', '.el', '.scm', '.ss', '.clj', '.cljs', '.cljc'],
                'start': ';;',
                'prefix': ';;',
                'end': ';;',
                'shebang_aware': False
            },
            
            # Haskell style
            'haskell_style': {
                'extensions': ['.hs', '.lhs'],
                'start': '--',
                'prefix': '--',
                'end': '--',
                'shebang_aware': False
            },
            
            # Lua style
            'lua_style': {
                'extensions': ['.lua'],
                'start': '--',
                'prefix': '--',
                'end': '--',
                'shebang_aware': True
            },
            
            # MATLAB style
            'matlab_style': {
                'extensions': ['.m', '.matlab'],
                'start': '%',
                'prefix': '%',
                'end': '%',
                'shebang_aware': False
            },
            
            # LaTeX style
            'latex_style': {
                'extensions': ['.tex', '.latex', '.sty', '.cls'],
                'start': '%',
                'prefix': '%',
                'end': '%',
                'shebang_aware': False
            },
            
            # Assembly style
            'assembly_style': {
                'extensions': ['.s', '.S', '.asm', '.nasm'],
                'start': ';',
                'prefix': ';',
                'end': ';',
                'shebang_aware': False
            },
            
            # Fortran style
            'fortran_style': {
                'extensions': ['.f', '.f90', '.f95', '.f03', '.f08', '.for', '.ftn'],
                'start': '!',
                'prefix': '!',
                'end': '!',
                'shebang_aware': False
            },
            
            # Ada style
            'ada_style': {
                'extensions': ['.ada', '.adb', '.ads'],
                'start': '--',
                'prefix': '--',
                'end': '--',
                'shebang_aware': False
            },
            
            # Pascal style
            'pascal_style': {
                'extensions': ['.pas', '.pp', '.inc'],
                'start': '(*',
                'prefix': ' *',
                'end': ' *)',
                'shebang_aware': False
            },
            
            # Erlang style
            'erlang_style': {
                'extensions': ['.erl', '.hrl'],
                'start': '%',
                'prefix': '%',
                'end': '%',
                'shebang_aware': False
            },
            
            # PowerShell style
            'powershell_style': {
                'extensions': ['.ps1', '.psm1', '.psd1'],
                'start': '<#',
                'prefix': ' #',
                'end': ' #>',
                'shebang_aware': False
            },
            
            # Batch style
            'batch_style': {
                'extensions': ['.bat', '.cmd'],
                'start': 'REM',
                'prefix': 'REM',
                'end': 'REM',
                'shebang_aware': False
            },
            
            # VimScript style
            'vim_style': {
                'extensions': ['.vim', '.vimrc'],
                'start': '"',
                'prefix': '"',
                'end': '"',
                'shebang_aware': False
            },
            
            # Markdown style
            'markdown_style': {
                'extensions': ['.md', '.markdown', '.mdown', '.mkd', '.mkdn'],
                'start': '<!--',
                'prefix': '  ',
                'end': '-->',
                'shebang_aware': False
            },
            
            # CSS style
            'css_style': {
                'extensions': ['.css', '.scss', '.sass', '.less', '.styl'],
                'start': '/*',
                'prefix': ' *',
                'end': ' */',
                'shebang_aware': False
            }
        }
        
    def get_file_style(self, file_path: Path) -> Optional[Dict]:
        """Determine the comment style for a file based on its extension"""
        extension = file_path.suffix.lower()
        
        for style_name, style_info in self.file_patterns.items():
            if extension in style_info['extensions']:
                return style_info
                
        return None
        
    def format_license_header(self, style: Dict) -> str:
        """Format the license header according to the comment style"""
        lines = LICENSE_TEMPLATE.strip().split('\n')
        formatted_lines = []
        
        # Add start comment
        if style['start'] != style['prefix']:
            formatted_lines.append(style['start'] + ' ' + lines[0])
        else:
            formatted_lines.append(style['prefix'] + ' ' + lines[0])
            
        # Add middle lines
        for line in lines[1:]:
            if line.strip():
                formatted_lines.append(style['prefix'] + ' ' + line)
            else:
                formatted_lines.append(style['prefix'])
                
        # Add end comment
        if style['end'] != style['prefix']:
            formatted_lines.append(style['end'])
        else:
            formatted_lines.append(style['prefix'])
            
        return '\n'.join(formatted_lines) + '\n\n'
        
    def has_license_header(self, content: str) -> bool:
        """Check if content already has a SAGE OS license header"""
        return 'SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale' in content
        
    def remove_existing_header(self, content: str, style: Dict) -> str:
        """Remove existing license header if present"""
        lines = content.split('\n')
        
        # Skip shebang if present
        start_idx = 0
        if style.get('shebang_aware', False) and lines and lines[0].startswith('#!'):
            start_idx = 1
            
        # Find and remove existing header
        in_header = False
        header_end = start_idx
        
        for i in range(start_idx, len(lines)):
            line = lines[i].strip()
            
            if 'SAGE OS — Copyright' in line or 'SPDX-License-Identifier' in line:
                in_header = True
                
            if in_header:
                if (line.startswith(style['start'].strip()) or 
                    line.startswith(style['prefix'].strip()) or
                    line.startswith(style['end'].strip()) or
                    not line):
                    header_end = i + 1
                else:
                    break
                    
        # Remove header lines
        if in_header:
            lines = lines[:start_idx] + lines[header_end:]
            
        return '\n'.join(lines)
        
    def add_license_header(self, file_path: Path) -> bool:
        """Add license header to a file"""
        try:
            style = self.get_file_style(file_path)
            if not style:
                logger.warning(f"No comment style found for {file_path}")
                return False
                
            # Read file content
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                
            # Check if header already exists
            if self.has_license_header(content):
                logger.debug(f"License header already exists in {file_path}")
                return True
                
            # Remove any existing header
            content = self.remove_existing_header(content, style)
            
            # Format new header
            header = self.format_license_header(style)
            
            # Handle shebang
            lines = content.split('\n')
            if style.get('shebang_aware', False) and lines and lines[0].startswith('#!'):
                # Insert header after shebang
                new_content = lines[0] + '\n' + header + '\n'.join(lines[1:])
            else:
                # Insert header at the beginning
                new_content = header + content
                
            # Write back to file
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
                
            logger.info(f"Added license header to {file_path}")
            return True
            
        except Exception as e:
            logger.error(f"Error processing {file_path}: {e}")
            return False
            
    def process_directory(self, directory: Path, recursive: bool = True) -> Tuple[int, int]:
        """Process all files in a directory"""
        processed = 0
        successful = 0
        
        pattern = "**/*" if recursive else "*"
        
        for file_path in directory.glob(pattern):
            if file_path.is_file() and self.get_file_style(file_path):
                processed += 1
                if self.add_license_header(file_path):
                    successful += 1
                    
        return processed, successful

def main():
    parser = argparse.ArgumentParser(description="Enhanced License Header Tool for SAGE OS")
    parser.add_argument("path", help="File or directory to process")
    parser.add_argument("--recursive", "-r", action="store_true", help="Process directories recursively")
    parser.add_argument("--verbose", "-v", action="store_true", help="Verbose output")
    
    args = parser.parse_args()
    
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
        
    manager = LicenseHeaderManager()
    path = Path(args.path)
    
    if not path.exists():
        logger.error(f"Path {path} does not exist")
        sys.exit(1)
        
    if path.is_file():
        success = manager.add_license_header(path)
        sys.exit(0 if success else 1)
    elif path.is_dir():
        processed, successful = manager.process_directory(path, args.recursive)
        logger.info(f"Processed {processed} files, {successful} successful")
        sys.exit(0 if successful == processed else 1)
    else:
        logger.error(f"Invalid path: {path}")
        sys.exit(1)

if __name__ == "__main__":
    main()