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
# Licensed under the BSD 3-Clause License or a Commercial License.
# You may use this file under the terms of either license as specified in:
# 
#    - BSD 3-Clause License (see ./LICENSE)
#    - Commercial License (see ./COMMERCIAL_TERMS.md or contact legal@your.org)
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted under the BSD license provided that the
# following conditions are met:
# 
#   * Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#   * Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#   * Neither the name of the project nor the names of its contributors
#     may be used to endorse or promote products derived from this
#     software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
# OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
# ─────────────────────────────────────────────────────────────────────────────


"""
SAGE OS Comprehensive Security Analysis Tool
Analyzes the codebase for common security vulnerabilities
"""

import os
import re
import json
import subprocess
from pathlib import Path
from datetime import datetime

class SecurityAnalyzer:
    def __init__(self, project_root):
        self.project_root = Path(project_root)
        self.vulnerabilities = []
        self.security_issues = {
            'critical': [],
            'high': [],
            'medium': [],
            'low': [],
            'info': []
        }
        
    def analyze_buffer_overflows(self, file_path, content):
        """Check for potential buffer overflow vulnerabilities"""
        issues = []
        dangerous_functions = [
            'strcpy', 'strcat', 'sprintf', 'gets', 'scanf',
            'strncpy', 'strncat', 'snprintf'
        ]
        
        for line_num, line in enumerate(content.split('\n'), 1):
            for func in dangerous_functions:
                if func in line and not line.strip().startswith('//'):
                    issues.append({
                        'type': 'Buffer Overflow Risk',
                        'severity': 'high' if func in ['strcpy', 'strcat', 'gets'] else 'medium',
                        'file': str(file_path),
                        'line': line_num,
                        'description': f'Use of potentially unsafe function: {func}',
                        'code': line.strip()
                    })
        return issues
    
    def analyze_memory_management(self, file_path, content):
        """Check for memory management issues"""
        issues = []
        lines = content.split('\n')
        
        malloc_lines = []
        free_lines = []
        
        for line_num, line in enumerate(lines, 1):
            if 'malloc(' in line or 'calloc(' in line or 'realloc(' in line:
                malloc_lines.append((line_num, line.strip()))
            if 'free(' in line:
                free_lines.append((line_num, line.strip()))
                
        # Simple heuristic: if more mallocs than frees, potential memory leak
        if len(malloc_lines) > len(free_lines):
            issues.append({
                'type': 'Memory Leak Risk',
                'severity': 'medium',
                'file': str(file_path),
                'line': 0,
                'description': f'Potential memory leak: {len(malloc_lines)} allocations vs {len(free_lines)} frees',
                'code': f'malloc calls: {len(malloc_lines)}, free calls: {len(free_lines)}'
            })
            
        return issues
    
    def analyze_input_validation(self, file_path, content):
        """Check for input validation issues"""
        issues = []
        
        # Check for direct user input usage without validation
        risky_patterns = [
            (r'scanf\s*\([^)]*\)', 'Unsafe input reading with scanf'),
            (r'gets\s*\([^)]*\)', 'Extremely unsafe gets() function'),
            (r'system\s*\([^)]*\)', 'Potential command injection with system()'),
        ]
        
        for line_num, line in enumerate(content.split('\n'), 1):
            for pattern, desc in risky_patterns:
                if re.search(pattern, line) and not line.strip().startswith('//'):
                    issues.append({
                        'type': 'Input Validation',
                        'severity': 'high',
                        'file': str(file_path),
                        'line': line_num,
                        'description': desc,
                        'code': line.strip()
                    })
        return issues
    
    def analyze_privilege_escalation(self, file_path, content):
        """Check for potential privilege escalation issues"""
        issues = []
        
        # Check for setuid/setgid usage
        privilege_patterns = [
            (r'setuid\s*\(', 'setuid usage - potential privilege escalation'),
            (r'setgid\s*\(', 'setgid usage - potential privilege escalation'),
            (r'seteuid\s*\(', 'seteuid usage - check for proper validation'),
        ]
        
        for line_num, line in enumerate(content.split('\n'), 1):
            for pattern, desc in privilege_patterns:
                if re.search(pattern, line) and not line.strip().startswith('//'):
                    issues.append({
                        'type': 'Privilege Escalation Risk',
                        'severity': 'critical',
                        'file': str(file_path),
                        'line': line_num,
                        'description': desc,
                        'code': line.strip()
                    })
        return issues
    
    def analyze_assembly_security(self, file_path, content):
        """Check assembly files for security issues"""
        issues = []
        
        # Check for stack manipulation without proper bounds checking
        asm_patterns = [
            (r'mov\s+%esp', 'Direct stack pointer manipulation'),
            (r'jmp\s+\*', 'Indirect jump - potential ROP gadget'),
            (r'call\s+\*', 'Indirect call - potential security risk'),
        ]
        
        for line_num, line in enumerate(content.split('\n'), 1):
            for pattern, desc in asm_patterns:
                if re.search(pattern, line, re.IGNORECASE) and not line.strip().startswith('#'):
                    issues.append({
                        'type': 'Assembly Security',
                        'severity': 'medium',
                        'file': str(file_path),
                        'line': line_num,
                        'description': desc,
                        'code': line.strip()
                    })
        return issues
    
    def analyze_file(self, file_path):
        """Analyze a single file for security issues"""
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
        except Exception as e:
            return []
        
        issues = []
        
        # Run different analyzers based on file type
        if file_path.suffix in ['.c', '.h']:
            issues.extend(self.analyze_buffer_overflows(file_path, content))
            issues.extend(self.analyze_memory_management(file_path, content))
            issues.extend(self.analyze_input_validation(file_path, content))
            issues.extend(self.analyze_privilege_escalation(file_path, content))
        elif file_path.suffix in ['.S', '.s']:
            issues.extend(self.analyze_assembly_security(file_path, content))
            
        return issues
    
    def scan_project(self):
        """Scan the entire project for security issues"""
        print("🔍 Starting comprehensive security analysis...")
        
        # File types to analyze
        file_patterns = ['**/*.c', '**/*.h', '**/*.S', '**/*.s']
        
        total_files = 0
        for pattern in file_patterns:
            for file_path in self.project_root.glob(pattern):
                if file_path.is_file():
                    total_files += 1
                    print(f"Analyzing: {file_path.relative_to(self.project_root)}")
                    issues = self.analyze_file(file_path)
                    
                    for issue in issues:
                        self.security_issues[issue['severity']].append(issue)
        
        print(f"\n✅ Analysis complete! Scanned {total_files} files.")
        return self.security_issues
    
    def generate_report(self):
        """Generate a comprehensive security report"""
        report = {
            'scan_date': datetime.now().isoformat(),
            'project': 'SAGE OS',
            'total_issues': sum(len(issues) for issues in self.security_issues.values()),
            'issues_by_severity': {
                severity: len(issues) for severity, issues in self.security_issues.items()
            },
            'detailed_findings': self.security_issues
        }
        
        # Save JSON report
        with open('security-analysis-report.json', 'w') as f:
            json.dump(report, f, indent=2)
        
        # Generate human-readable report
        self.generate_markdown_report(report)
        
        return report
    
    def generate_markdown_report(self, report):
        """Generate a markdown security report"""
        md_content = f"""# SAGE OS Security Analysis Report

**Scan Date:** {report['scan_date']}
**Total Issues Found:** {report['total_issues']}

## Summary by Severity

| Severity | Count |
|----------|-------|
| Critical | {report['issues_by_severity']['critical']} |
| High     | {report['issues_by_severity']['high']} |
| Medium   | {report['issues_by_severity']['medium']} |
| Low      | {report['issues_by_severity']['low']} |
| Info     | {report['issues_by_severity']['info']} |

## Detailed Findings

"""
        
        for severity in ['critical', 'high', 'medium', 'low', 'info']:
            issues = self.security_issues[severity]
            if issues:
                md_content += f"\n### {severity.upper()} Severity Issues ({len(issues)})\n\n"
                
                for i, issue in enumerate(issues, 1):
                    md_content += f"""#### {i}. {issue['type']}

**File:** `{issue['file']}`
**Line:** {issue['line']}
**Description:** {issue['description']}

```
{issue['code']}
```

---

"""
        
        md_content += """
## Recommendations

### Critical Issues
- Address all critical issues immediately
- Review privilege escalation risks
- Implement proper input validation

### High Priority
- Fix buffer overflow vulnerabilities
- Implement bounds checking
- Use safe string functions

### Medium Priority
- Review memory management
- Add proper error handling
- Implement security best practices

### Security Hardening
- Enable stack protection (-fstack-protector)
- Use ASLR (Address Space Layout Randomization)
- Implement DEP (Data Execution Prevention)
- Add security-focused compiler flags

## Next Steps

1. Review and fix critical and high severity issues
2. Implement automated security testing
3. Add security-focused unit tests
4. Regular security audits
5. Consider using static analysis tools like:
   - Clang Static Analyzer
   - Cppcheck
   - PVS-Studio
   - Coverity

"""
        
        with open('SECURITY_ANALYSIS_REPORT.md', 'w') as f:
            f.write(md_content)

def main():
    analyzer = SecurityAnalyzer('.')
    issues = analyzer.scan_project()
    report = analyzer.generate_report()
    
    print(f"\n📊 Security Analysis Summary:")
    print(f"   Critical: {len(issues['critical'])}")
    print(f"   High:     {len(issues['high'])}")
    print(f"   Medium:   {len(issues['medium'])}")
    print(f"   Low:      {len(issues['low'])}")
    print(f"   Info:     {len(issues['info'])}")
    print(f"\n📄 Reports generated:")
    print(f"   - security-analysis-report.json")
    print(f"   - SECURITY_ANALYSIS_REPORT.md")

if __name__ == "__main__":
    main()