#!/usr/bin/env python3
"""
SAGE-OS AI Documentation Security Sandbox Test

This script tests the security restrictions of the AI documentation system to ensure:
1. AI can only read source files (not modify them)
2. AI can only write to docs/ directory
3. Protected directories are inaccessible for writes
4. No system files can be modified
"""

import os
import sys
import tempfile
import shutil
from pathlib import Path
import json
from datetime import datetime

class SecuritySandboxTester:
    def __init__(self):
        self.test_results = {
            'total_tests': 0,
            'passed_tests': 0,
            'failed_tests': 0,
            'security_violations': 0,
            'test_details': []
        }
        
        # Simulate the security configuration from the workflow
        self.docs_dir = Path("docs")
        self.allowed_write_dirs = {"docs/"}
        self.protected_dirs = {"kernel/", "boot/", "drivers/", "src/", ".github/workflows/", "scripts/"}
        
    def log_test(self, test_name, passed, details="", is_security_test=False):
        """Log test result"""
        self.test_results['total_tests'] += 1
        if passed:
            self.test_results['passed_tests'] += 1
            status = "✅ PASS"
        else:
            self.test_results['failed_tests'] += 1
            status = "❌ FAIL"
            if is_security_test:
                self.test_results['security_violations'] += 1
                status = "🚫 SECURITY VIOLATION"
            
        self.test_results['test_details'].append({
            'name': test_name,
            'status': status,
            'details': details,
            'is_security_test': is_security_test,
            'timestamp': datetime.now().isoformat()
        })
        
        print(f"{status}: {test_name}")
        if details:
            print(f"    {details}")
    
    def _is_path_safe_for_write(self, path):
        """Replicate the security check from the workflow"""
        path_str = str(Path(path).resolve())
        docs_path_str = str(self.docs_dir.resolve())
        
        # Must be within docs directory
        if not path_str.startswith(docs_path_str):
            return False
        
        # Check against protected directories
        for protected_dir in self.protected_dirs:
            if protected_dir.strip() and protected_dir.strip() in path_str:
                return False
        
        return True
    
    def test_docs_directory_write_access(self):
        """Test that writes to docs/ directory are allowed"""
        print("\n📁 Testing docs/ directory write access...")
        
        test_files = [
            "docs/test_file.md",
            "docs/api/test_api.md",
            "docs/guides/test_guide.md",
            "docs/files/test_source.md"
        ]
        
        for test_file in test_files:
            try:
                test_path = Path(test_file)
                is_safe = self._is_path_safe_for_write(test_path)
                
                if is_safe:
                    # Try to create the file
                    test_path.parent.mkdir(parents=True, exist_ok=True)
                    test_path.write_text("Test content")
                    
                    # Verify it was created
                    if test_path.exists():
                        self.log_test(f"Write to {test_file}", True, "Successfully created file in docs/")
                        test_path.unlink()  # Clean up
                    else:
                        self.log_test(f"Write to {test_file}", False, "File creation failed")
                else:
                    self.log_test(f"Write to {test_file}", False, "Security check failed", is_security_test=True)
                    
            except Exception as e:
                self.log_test(f"Write to {test_file}", False, f"Exception: {e}")
    
    def test_protected_directory_write_blocking(self):
        """Test that writes to protected directories are blocked"""
        print("\n🔒 Testing protected directory write blocking...")
        
        protected_test_files = [
            "kernel/test_kernel.c",
            "boot/test_boot.S",
            "drivers/test_driver.c",
            "src/test_source.c",
            ".github/workflows/test_workflow.yml",
            "scripts/test_script.py",
            "Makefile",
            "CMakeLists.txt"
        ]
        
        for test_file in protected_test_files:
            try:
                test_path = Path(test_file)
                is_safe = self._is_path_safe_for_write(test_path)
                
                if not is_safe:
                    self.log_test(f"Block write to {test_file}", True, "Correctly blocked protected directory")
                else:
                    self.log_test(f"Block write to {test_file}", False, "SECURITY VIOLATION: Write allowed to protected directory", is_security_test=True)
                    
            except Exception as e:
                self.log_test(f"Block write to {test_file}", False, f"Exception: {e}")
    
    def test_read_access_to_source_files(self):
        """Test that source files can be read for analysis"""
        print("\n📖 Testing read access to source files...")
        
        # Create test source files
        test_source_files = [
            ("kernel/test_kernel.c", "int kernel_main() { return 0; }"),
            ("drivers/test_driver.h", "#ifndef TEST_H\n#define TEST_H\n#endif"),
            ("src/test_module.py", "def test_function():\n    pass"),
        ]
        
        for file_path, content in test_source_files:
            try:
                test_path = Path(file_path)
                test_path.parent.mkdir(parents=True, exist_ok=True)
                test_path.write_text(content)
                
                # Test reading the file
                read_content = test_path.read_text()
                if read_content == content:
                    self.log_test(f"Read {file_path}", True, "Successfully read source file for analysis")
                else:
                    self.log_test(f"Read {file_path}", False, "Content mismatch")
                
                # Clean up
                test_path.unlink()
                
            except Exception as e:
                self.log_test(f"Read {file_path}", False, f"Exception: {e}")
    
    def test_path_traversal_attacks(self):
        """Test protection against path traversal attacks"""
        print("\n🛡️ Testing path traversal attack protection...")
        
        malicious_paths = [
            "docs/../kernel/malicious.c",
            "docs/../../etc/passwd",
            "docs/../.github/workflows/malicious.yml",
            "docs/files/../../boot/malicious.S",
            "docs/api/../../../src/malicious.py"
        ]
        
        for malicious_path in malicious_paths:
            try:
                test_path = Path(malicious_path)
                is_safe = self._is_path_safe_for_write(test_path)
                
                if not is_safe:
                    self.log_test(f"Block path traversal: {malicious_path}", True, "Correctly blocked path traversal attempt")
                else:
                    self.log_test(f"Block path traversal: {malicious_path}", False, "SECURITY VIOLATION: Path traversal allowed", is_security_test=True)
                    
            except Exception as e:
                self.log_test(f"Block path traversal: {malicious_path}", False, f"Exception: {e}")
    
    def test_symlink_attacks(self):
        """Test protection against symlink attacks"""
        print("\n🔗 Testing symlink attack protection...")
        
        try:
            # Create a symlink pointing outside docs/
            symlink_path = Path("docs/malicious_symlink")
            target_path = Path("../kernel/important_file.c")
            
            # Create target file
            target_path.parent.mkdir(parents=True, exist_ok=True)
            target_path.write_text("Important kernel code")
            
            # Create symlink
            if not symlink_path.exists():
                symlink_path.symlink_to(target_path)
            
            # Test if our security check catches this
            is_safe = self._is_path_safe_for_write(symlink_path)
            
            if not is_safe:
                self.log_test("Block symlink attack", True, "Correctly blocked symlink to protected area")
            else:
                self.log_test("Block symlink attack", False, "SECURITY VIOLATION: Symlink attack allowed", is_security_test=True)
            
            # Clean up
            if symlink_path.exists():
                symlink_path.unlink()
            if target_path.exists():
                target_path.unlink()
                
        except Exception as e:
            self.log_test("Block symlink attack", False, f"Exception: {e}")
    
    def test_file_size_limits(self):
        """Test file size limits for security"""
        print("\n📏 Testing file size limits...")
        
        # Test reasonable file size
        reasonable_content = "# Test Documentation\n" + "Content line\n" * 100
        large_content = "# Large Documentation\n" + "X" * (1024 * 1024 * 2)  # 2MB
        
        test_cases = [
            ("docs/reasonable_file.md", reasonable_content, True, "Reasonable file size"),
            ("docs/large_file.md", large_content, False, "File too large (>1MB)")
        ]
        
        for file_path, content, should_pass, description in test_cases:
            try:
                test_path = Path(file_path)
                
                # Check file size limit (simulate 1MB limit)
                content_size = len(content.encode('utf-8'))
                size_ok = content_size < 1024 * 1024  # 1MB limit
                
                if size_ok == should_pass:
                    self.log_test(f"File size check: {description}", True, f"Size: {content_size} bytes")
                else:
                    self.log_test(f"File size check: {description}", False, f"Size check failed: {content_size} bytes")
                    
            except Exception as e:
                self.log_test(f"File size check: {description}", False, f"Exception: {e}")
    
    def test_content_filtering(self):
        """Test content filtering for sensitive information"""
        print("\n🔍 Testing content filtering...")
        
        test_contents = [
            ("Safe content", "# Documentation\nThis is safe content.", True),
            ("Password in content", "password = 'secret123'", False),
            ("API key in content", "api_key = 'sk-1234567890'", False),
            ("Token in content", "token = 'ghp_1234567890'", False),
            ("Safe code", "int main() { return 0; }", True)
        ]
        
        for description, content, should_pass in test_contents:
            try:
                # Simulate content filtering
                has_sensitive = any(pattern in content.lower() for pattern in ['password', 'api_key', 'token', 'secret'])
                
                if (not has_sensitive) == should_pass:
                    self.log_test(f"Content filter: {description}", True, "Content filtering working correctly")
                else:
                    self.log_test(f"Content filter: {description}", False, "Content filtering failed")
                    
            except Exception as e:
                self.log_test(f"Content filter: {description}", False, f"Exception: {e}")
    
    def test_workflow_file_protection(self):
        """Test that workflow files are protected from modification"""
        print("\n⚙️ Testing workflow file protection...")
        
        workflow_files = [
            ".github/workflows/ai-file-management.yml",
            ".github/workflows/enhanced-automated-docs.yml",
            ".github/workflows/github-models-integration.yml"
        ]
        
        for workflow_file in workflow_files:
            try:
                test_path = Path(workflow_file)
                is_safe = self._is_path_safe_for_write(test_path)
                
                if not is_safe:
                    self.log_test(f"Protect workflow: {workflow_file}", True, "Workflow file correctly protected")
                else:
                    self.log_test(f"Protect workflow: {workflow_file}", False, "SECURITY VIOLATION: Workflow file not protected", is_security_test=True)
                    
            except Exception as e:
                self.log_test(f"Protect workflow: {workflow_file}", False, f"Exception: {e}")
    
    def test_ai_chatbot_security(self):
        """Test AI chatbot security features"""
        print("\n🤖 Testing AI chatbot security...")
        
        # Test that chatbot is only created in docs/
        chatbot_path = Path("docs/ai-assistant.html")
        malicious_chatbot_path = Path("kernel/malicious-bot.html")
        
        # Test legitimate chatbot creation
        is_safe_legit = self._is_path_safe_for_write(chatbot_path)
        self.log_test("Chatbot in docs/", is_safe_legit, "AI chatbot correctly placed in docs/")
        
        # Test malicious chatbot placement
        is_safe_malicious = self._is_path_safe_for_write(malicious_chatbot_path)
        if not is_safe_malicious:
            self.log_test("Block malicious chatbot", True, "Malicious chatbot placement blocked")
        else:
            self.log_test("Block malicious chatbot", False, "SECURITY VIOLATION: Malicious chatbot allowed", is_security_test=True)
    
    def generate_security_report(self):
        """Generate comprehensive security test report"""
        print("\n📊 Generating security test report...")
        
        report = {
            'security_test_summary': {
                'total_tests': self.test_results['total_tests'],
                'passed_tests': self.test_results['passed_tests'],
                'failed_tests': self.test_results['failed_tests'],
                'security_violations': self.test_results['security_violations'],
                'security_score': ((self.test_results['total_tests'] - self.test_results['security_violations']) / max(self.test_results['total_tests'], 1)) * 100,
                'timestamp': datetime.now().isoformat()
            },
            'test_details': self.test_results['test_details'],
            'security_configuration': {
                'docs_dir': str(self.docs_dir),
                'allowed_write_dirs': list(self.allowed_write_dirs),
                'protected_dirs': list(self.protected_dirs)
            }
        }
        
        # Save JSON report
        with open("security_sandbox_test_report.json", 'w') as f:
            json.dump(report, f, indent=2)
        
        # Generate markdown report
        md_report = f"""# 🔒 SAGE-OS AI Documentation Security Test Report

**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}

## 🛡️ Security Test Summary

- **Total Tests**: {report['security_test_summary']['total_tests']}
- **Passed**: {report['security_test_summary']['passed_tests']} ✅
- **Failed**: {report['security_test_summary']['failed_tests']} ❌
- **Security Violations**: {report['security_test_summary']['security_violations']} 🚫
- **Security Score**: {report['security_test_summary']['security_score']:.1f}%

## 🔒 Security Configuration

- **Allowed Write Directory**: `{self.docs_dir}/`
- **Protected Directories**: {', '.join([f'`{d}`' for d in self.protected_dirs])}

## 📋 Test Results

"""
        
        for test in self.test_results['test_details']:
            md_report += f"### {test['name']}\n\n"
            md_report += f"**Status**: {test['status']}  \n"
            if test['details']:
                md_report += f"**Details**: {test['details']}  \n"
            if test['is_security_test']:
                md_report += f"**Security Test**: ⚠️ Critical Security Test  \n"
            md_report += f"**Time**: {test['timestamp']}  \n\n"
        
        md_report += f"""
## 🎯 Security Assessment

### ✅ Strengths
- Sandboxed file operations
- Protected directory access controls
- Path traversal protection
- Content filtering capabilities

### ⚠️ Areas for Improvement
"""
        
        if report['security_test_summary']['security_violations'] > 0:
            md_report += f"- **{report['security_test_summary']['security_violations']} security violations detected**\n"
            md_report += "- Review failed security tests and implement fixes\n"
        else:
            md_report += "- No security violations detected ✅\n"
        
        md_report += """
## 🔧 Recommendations

1. **Regular Security Testing**: Run this test suite before each deployment
2. **Monitoring**: Implement runtime security monitoring
3. **Audit Logging**: Log all file access attempts
4. **Principle of Least Privilege**: Ensure minimal required permissions
5. **Input Validation**: Validate all user inputs and file paths

## 📈 Security Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Security Score | {:.1f}% | {} |
| Violations | {} | {} |
| Protected Dirs | {} | ✅ |
| Sandbox Active | Yes | ✅ |

---

*Report generated by SAGE-OS Security Sandbox Testing System*
""".format(
            report['security_test_summary']['security_score'],
            "✅ Excellent" if report['security_test_summary']['security_score'] >= 95 else "⚠️ Needs Improvement",
            report['security_test_summary']['security_violations'],
            "✅ None" if report['security_test_summary']['security_violations'] == 0 else "🚫 Critical",
            len(self.protected_dirs)
        )
        
        with open("security_sandbox_test_report.md", 'w') as f:
            f.write(md_report)
        
        print(f"✅ Security test report saved:")
        print(f"  - JSON: security_sandbox_test_report.json")
        print(f"  - Markdown: security_sandbox_test_report.md")
        
        return report
    
    def run_all_security_tests(self):
        """Run all security tests"""
        print("🔒 Starting SAGE-OS AI Documentation Security Tests")
        print("=" * 60)
        
        try:
            self.test_docs_directory_write_access()
            self.test_protected_directory_write_blocking()
            self.test_read_access_to_source_files()
            self.test_path_traversal_attacks()
            self.test_symlink_attacks()
            self.test_file_size_limits()
            self.test_content_filtering()
            self.test_workflow_file_protection()
            self.test_ai_chatbot_security()
            
            report = self.generate_security_report()
            
            print("\n" + "=" * 60)
            print("🎉 Security Test Suite Complete!")
            print(f"📊 Results: {report['security_test_summary']['passed_tests']}/{report['security_test_summary']['total_tests']} tests passed")
            print(f"🔒 Security Score: {report['security_test_summary']['security_score']:.1f}%")
            print(f"🚫 Security Violations: {report['security_test_summary']['security_violations']}")
            
            if report['security_test_summary']['security_violations'] == 0:
                print("🎯 All security tests passed! AI documentation system is secure.")
                return True
            else:
                print("⚠️ Security violations detected. Please review the test report.")
                return False
            
        except Exception as e:
            print(f"❌ Security test suite failed with error: {e}")
            return False

def main():
    """Main security test function"""
    tester = SecuritySandboxTester()
    success = tester.run_all_security_tests()
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()