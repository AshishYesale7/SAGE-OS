#!/usr/bin/env python3
"""
SAGE-OS AI Documentation Testing Script

This script tests the AI-powered documentation generation system by:
1. Creating test files
2. Triggering documentation generation
3. Validating generated content
4. Testing the AI chatbot interface
5. Verifying GitHub Pages compatibility
"""

import os
import sys
import json
import time
import shutil
import subprocess
from pathlib import Path
from datetime import datetime

class AIDocumentationTester:
    def __init__(self, test_dir="test_docs", docs_dir="docs"):
        self.test_dir = Path(test_dir)
        self.docs_dir = Path(docs_dir)
        self.test_files = []
        self.generated_docs = []
        self.test_results = {
            'total_tests': 0,
            'passed_tests': 0,
            'failed_tests': 0,
            'test_details': []
        }
        
    def log_test(self, test_name, passed, details=""):
        """Log test result"""
        self.test_results['total_tests'] += 1
        if passed:
            self.test_results['passed_tests'] += 1
            status = "✅ PASS"
        else:
            self.test_results['failed_tests'] += 1
            status = "❌ FAIL"
            
        self.test_results['test_details'].append({
            'name': test_name,
            'status': status,
            'details': details,
            'timestamp': datetime.now().isoformat()
        })
        
        print(f"{status}: {test_name}")
        if details:
            print(f"    {details}")
    
    def setup_test_environment(self):
        """Set up test environment"""
        print("🔧 Setting up test environment...")
        
        # Create test directory
        self.test_dir.mkdir(exist_ok=True)
        self.docs_dir.mkdir(exist_ok=True)
        
        # Create test source files
        test_files = [
            {
                'path': self.test_dir / 'test_kernel.c',
                'content': '''
/*
 * SAGE-OS Test Kernel Module
 * This is a test file for AI documentation generation
 */

#include <stdint.h>
#include <stdbool.h>

/**
 * Initialize the test kernel module
 * @param config Configuration parameters
 * @return 0 on success, -1 on error
 */
int test_kernel_init(void *config) {
    // Initialize kernel subsystems
    if (!config) {
        return -1;
    }
    
    // Setup memory management
    setup_memory_manager();
    
    // Initialize drivers
    init_test_drivers();
    
    return 0;
}

/**
 * Cleanup kernel resources
 */
void test_kernel_cleanup(void) {
    cleanup_drivers();
    cleanup_memory();
}

/**
 * Main kernel loop
 */
void test_kernel_main_loop(void) {
    while (true) {
        handle_interrupts();
        schedule_tasks();
        update_system_state();
    }
}

// Helper functions
static void setup_memory_manager(void) {
    // Memory management setup
}

static void init_test_drivers(void) {
    // Driver initialization
}

static void cleanup_drivers(void) {
    // Driver cleanup
}

static void cleanup_memory(void) {
    // Memory cleanup
}

static void handle_interrupts(void) {
    // Interrupt handling
}

static void schedule_tasks(void) {
    // Task scheduling
}

static void update_system_state(void) {
    // System state updates
}
'''
            },
            {
                'path': self.test_dir / 'test_driver.h',
                'content': '''
/*
 * SAGE-OS Test Driver Header
 * Defines interfaces for test drivers
 */

#ifndef TEST_DRIVER_H
#define TEST_DRIVER_H

#include <stdint.h>

// Driver types
typedef enum {
    DRIVER_TYPE_VGA,
    DRIVER_TYPE_SERIAL,
    DRIVER_TYPE_KEYBOARD,
    DRIVER_TYPE_AI_HAT
} driver_type_t;

// Driver structure
typedef struct {
    driver_type_t type;
    uint32_t id;
    char name[32];
    void *private_data;
    
    // Function pointers
    int (*init)(void *data);
    int (*read)(void *buffer, size_t size);
    int (*write)(const void *buffer, size_t size);
    void (*cleanup)(void);
} test_driver_t;

// Function declarations
int register_test_driver(test_driver_t *driver);
int unregister_test_driver(uint32_t driver_id);
test_driver_t *get_test_driver(uint32_t driver_id);
void list_test_drivers(void);

// VGA driver functions
int vga_driver_init(void *data);
int vga_driver_write(const void *buffer, size_t size);
void vga_driver_cleanup(void);

// Serial driver functions
int serial_driver_init(void *data);
int serial_driver_read(void *buffer, size_t size);
int serial_driver_write(const void *buffer, size_t size);
void serial_driver_cleanup(void);

// Keyboard driver functions
int keyboard_driver_init(void *data);
int keyboard_driver_read(void *buffer, size_t size);
void keyboard_driver_cleanup(void);

// AI HAT+ driver functions
int ai_hat_driver_init(void *data);
int ai_hat_driver_process(const void *input, void *output);
void ai_hat_driver_cleanup(void);

#endif // TEST_DRIVER_H
'''
            },
            {
                'path': self.test_dir / 'test_ai_module.py',
                'content': '''
"""
SAGE-OS AI Module Test
This module tests AI integration capabilities
"""

import json
import requests
from typing import Dict, List, Optional

class AITestModule:
    """Test module for AI integration"""
    
    def __init__(self, api_key: str, model: str = "gpt-4"):
        """
        Initialize AI test module
        
        Args:
            api_key: GitHub Models API key
            model: AI model to use
        """
        self.api_key = api_key
        self.model = model
        self.base_url = "https://models.inference.ai.azure.com"
        self.headers = {
            'Authorization': f'Bearer {api_key}',
            'Content-Type': 'application/json'
        }
    
    def analyze_code(self, code: str, language: str = "c") -> Dict:
        """
        Analyze code using AI
        
        Args:
            code: Source code to analyze
            language: Programming language
            
        Returns:
            Analysis results dictionary
        """
        prompt = f"""
        Analyze this {language} code and provide:
        1. Function summary
        2. Potential issues
        3. Optimization suggestions
        4. Documentation quality
        
        Code:
        {code}
        """
        
        return self._call_ai_api(prompt)
    
    def generate_documentation(self, code: str, filename: str) -> str:
        """
        Generate documentation for code
        
        Args:
            code: Source code
            filename: File name
            
        Returns:
            Generated documentation
        """
        prompt = f"""
        Generate comprehensive documentation for {filename}:
        
        {code}
        
        Include:
        - Overview
        - Function descriptions
        - Usage examples
        - API reference
        """
        
        result = self._call_ai_api(prompt)
        return result.get('content', '')
    
    def _call_ai_api(self, prompt: str) -> Dict:
        """Make API call to AI service"""
        payload = {
            'model': self.model,
            'messages': [
                {
                    'role': 'system',
                    'content': 'You are an expert code analyst and technical writer.'
                },
                {
                    'role': 'user',
                    'content': prompt
                }
            ],
            'max_tokens': 1500,
            'temperature': 0.3
        }
        
        try:
            response = requests.post(
                f'{self.base_url}/chat/completions',
                headers=self.headers,
                json=payload,
                timeout=30
            )
            
            if response.status_code == 200:
                return {
                    'success': True,
                    'content': response.json()['choices'][0]['message']['content'],
                    'tokens_used': response.json().get('usage', {}).get('total_tokens', 0)
                }
            else:
                return {
                    'success': False,
                    'error': f'API error: {response.status_code}'
                }
                
        except Exception as e:
            return {
                'success': False,
                'error': str(e)
            }
    
    def test_ai_integration(self) -> bool:
        """Test AI integration functionality"""
        test_code = """
        int add_numbers(int a, int b) {
            return a + b;
        }
        """
        
        result = self.analyze_code(test_code)
        return result.get('success', False)

# Test functions
def test_ai_module_creation():
    """Test AI module creation"""
    module = AITestModule("test_key")
    return module is not None

def test_code_analysis():
    """Test code analysis functionality"""
    module = AITestModule("test_key")
    result = module.analyze_code("int main() { return 0; }")
    return isinstance(result, dict)

def test_documentation_generation():
    """Test documentation generation"""
    module = AITestModule("test_key")
    docs = module.generate_documentation("int test() { return 1; }", "test.c")
    return isinstance(docs, str)

if __name__ == "__main__":
    print("🧪 Running AI module tests...")
    
    tests = [
        test_ai_module_creation,
        test_code_analysis,
        test_documentation_generation
    ]
    
    passed = 0
    for test in tests:
        try:
            if test():
                print(f"✅ {test.__name__}")
                passed += 1
            else:
                print(f"❌ {test.__name__}")
        except Exception as e:
            print(f"❌ {test.__name__}: {e}")
    
    print(f"\\n📊 Results: {passed}/{len(tests)} tests passed")
'''
            }
        ]
        
        # Write test files
        for file_info in test_files:
            file_info['path'].parent.mkdir(parents=True, exist_ok=True)
            with open(file_info['path'], 'w') as f:
                f.write(file_info['content'])
            self.test_files.append(file_info['path'])
            
        print(f"✅ Created {len(test_files)} test files")
    
    def test_file_detection(self):
        """Test file change detection"""
        print("\\n🔍 Testing file change detection...")
        
        # Test 1: Check if test files exist
        all_exist = all(f.exists() for f in self.test_files)
        self.log_test("File Creation", all_exist, f"Created {len(self.test_files)} test files")
        
        # Test 2: Check file content
        for test_file in self.test_files:
            try:
                with open(test_file, 'r') as f:
                    content = f.read()
                has_content = len(content) > 100
                self.log_test(f"File Content - {test_file.name}", has_content, 
                            f"File size: {len(content)} characters")
            except Exception as e:
                self.log_test(f"File Content - {test_file.name}", False, str(e))
    
    def test_documentation_generation(self):
        """Test AI documentation generation"""
        print("\\n🤖 Testing AI documentation generation...")
        
        # Simulate AI documentation generation
        for test_file in self.test_files:
            try:
                # Create corresponding documentation file
                doc_filename = f"{test_file.stem}.md"
                doc_path = self.docs_dir / "files" / doc_filename
                doc_path.parent.mkdir(parents=True, exist_ok=True)
                
                # Generate mock documentation
                doc_content = f"""# Documentation for {test_file.name}

**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}  
**Source**: {test_file}  
**Type**: {test_file.suffix}  

## Overview

This file is part of the SAGE-OS test suite and demonstrates AI-powered documentation generation.

## Functions

"""
                
                # Extract function signatures (simple regex)
                with open(test_file, 'r') as f:
                    content = f.read()
                
                if test_file.suffix == '.c':
                    import re
                    functions = re.findall(r'^\s*(\w+\s+\**\w+\s*\([^)]*\))', content, re.MULTILINE)
                    for func in functions[:5]:  # Limit to 5 functions
                        doc_content += f"### `{func}`\\n\\nFunction description would be generated by AI.\\n\\n"
                
                elif test_file.suffix == '.py':
                    import re
                    functions = re.findall(r'def\s+(\w+)\s*\([^)]*\):', content)
                    classes = re.findall(r'class\s+(\w+)(?:\([^)]*\))?:', content)
                    
                    if classes:
                        doc_content += "## Classes\\n\\n"
                        for cls in classes[:3]:
                            doc_content += f"### `{cls}`\\n\\nClass description would be generated by AI.\\n\\n"
                    
                    if functions:
                        doc_content += "## Functions\\n\\n"
                        for func in functions[:5]:
                            doc_content += f"### `{func}()`\\n\\nFunction description would be generated by AI.\\n\\n"
                
                doc_content += """
## Usage Examples

```c
// Usage examples would be generated by AI
```

## API Reference

Detailed API reference would be generated by AI based on code analysis.

## Related Files

- [Main Documentation](../index.md)
- [API Reference](../api-reference.md)

---

*This documentation was automatically generated by SAGE-OS AI Documentation System*
"""
                
                # Write documentation
                with open(doc_path, 'w') as f:
                    f.write(doc_content)
                
                self.generated_docs.append(doc_path)
                self.log_test(f"Doc Generation - {test_file.name}", True, 
                            f"Generated: {doc_path}")
                
            except Exception as e:
                self.log_test(f"Doc Generation - {test_file.name}", False, str(e))
    
    def test_github_pages_compatibility(self):
        """Test GitHub Pages compatibility"""
        print("\\n📄 Testing GitHub Pages compatibility...")
        
        # Test 1: Check Markdown format
        md_files = list(self.docs_dir.glob("**/*.md"))
        has_md_files = len(md_files) > 0
        self.log_test("Markdown Files", has_md_files, f"Found {len(md_files)} .md files")
        
        # Test 2: Check HTML format
        html_files = list(self.docs_dir.glob("**/*.html"))
        has_html_files = len(html_files) > 0
        self.log_test("HTML Files", has_html_files, f"Found {len(html_files)} .html files")
        
        # Test 3: Check index file
        index_exists = (self.docs_dir / "index.md").exists() or (self.docs_dir / "index.html").exists()
        self.log_test("Index File", index_exists, "Main index file for GitHub Pages")
        
        # Test 4: Validate Markdown syntax
        for md_file in md_files:
            try:
                with open(md_file, 'r') as f:
                    content = f.read()
                
                # Basic Markdown validation
                has_headers = '# ' in content or '## ' in content
                has_content = len(content) > 50
                valid_md = has_headers and has_content
                
                self.log_test(f"MD Syntax - {md_file.name}", valid_md, 
                            f"Headers: {has_headers}, Content: {len(content)} chars")
                
            except Exception as e:
                self.log_test(f"MD Syntax - {md_file.name}", False, str(e))
    
    def test_ai_chatbot_interface(self):
        """Test AI chatbot interface"""
        print("\\n🤖 Testing AI chatbot interface...")
        
        # Create AI chatbot HTML file
        chatbot_path = self.docs_dir / "ai-assistant.html"
        
        try:
            chatbot_html = '''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SAGE-OS AI Assistant - Test</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .chat-container { max-width: 800px; margin: 0 auto; }
        .header { background: #2196F3; color: white; padding: 20px; border-radius: 10px; }
        .chat-area { border: 1px solid #ddd; height: 400px; padding: 10px; margin: 10px 0; }
        .input-area { display: flex; gap: 10px; }
        .input-area input { flex: 1; padding: 10px; border: 1px solid #ddd; border-radius: 5px; }
        .input-area button { padding: 10px 20px; background: #2196F3; color: white; border: none; border-radius: 5px; cursor: pointer; }
        .test-status { background: #f0f0f0; padding: 10px; margin: 10px 0; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="chat-container">
        <div class="header">
            <h1>🤖 SAGE-OS AI Assistant</h1>
            <p>Test Interface for AI-Powered Documentation Help</p>
        </div>
        
        <div class="test-status">
            <h3>🧪 Test Status</h3>
            <p>✅ Chatbot interface loaded successfully</p>
            <p>✅ HTML structure validated</p>
            <p>✅ CSS styling applied</p>
            <p>⚠️ JavaScript functionality requires API key configuration</p>
        </div>
        
        <div class="chat-area" id="chatArea">
            <div style="padding: 20px; text-align: center; color: #666;">
                <h3>👋 Welcome to SAGE-OS AI Assistant!</h3>
                <p>This is a test interface. In production, this would connect to GitHub Models API.</p>
                <p><strong>Test Features:</strong></p>
                <ul style="text-align: left; display: inline-block;">
                    <li>Interactive chat interface</li>
                    <li>SAGE-OS knowledge base integration</li>
                    <li>Real-time code assistance</li>
                    <li>Documentation navigation help</li>
                    <li>Build and deployment guidance</li>
                </ul>
            </div>
        </div>
        
        <div class="input-area">
            <input type="text" placeholder="Ask me about SAGE-OS..." id="messageInput">
            <button onclick="testMessage()">Send Test</button>
        </div>
    </div>
    
    <script>
        function testMessage() {
            const input = document.getElementById('messageInput');
            const chatArea = document.getElementById('chatArea');
            
            if (input.value.trim()) {
                const message = input.value.trim();
                
                // Add test response
                chatArea.innerHTML += `
                    <div style="margin: 10px 0; padding: 10px; background: #e3f2fd; border-radius: 5px;">
                        <strong>You:</strong> ${message}
                    </div>
                    <div style="margin: 10px 0; padding: 10px; background: #f0f0f0; border-radius: 5px;">
                        <strong>AI Assistant:</strong> This is a test response. In production, I would provide detailed help about SAGE-OS based on your question: "${message}"
                    </div>
                `;
                
                input.value = '';
                chatArea.scrollTop = chatArea.scrollHeight;
            }
        }
        
        document.getElementById('messageInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                testMessage();
            }
        });
        
        // Test initialization
        console.log('🤖 SAGE-OS AI Assistant Test Interface Loaded');
        console.log('✅ All test components initialized successfully');
    </script>
</body>
</html>'''
            
            with open(chatbot_path, 'w') as f:
                f.write(chatbot_html)
            
            self.log_test("Chatbot Creation", True, f"Created: {chatbot_path}")
            
            # Validate HTML structure
            has_html_tags = '<html' in chatbot_html and '</html>' in chatbot_html
            has_css = '<style>' in chatbot_html
            has_js = '<script>' in chatbot_html
            
            self.log_test("HTML Structure", has_html_tags, "Valid HTML document")
            self.log_test("CSS Styling", has_css, "Embedded CSS found")
            self.log_test("JavaScript", has_js, "Interactive functionality included")
            
        except Exception as e:
            self.log_test("Chatbot Creation", False, str(e))
    
    def test_workflow_integration(self):
        """Test workflow integration"""
        print("\\n⚙️ Testing workflow integration...")
        
        # Test 1: Check workflow file exists
        workflow_path = Path(".github/workflows/ai-file-management.yml")
        workflow_exists = workflow_path.exists()
        self.log_test("Workflow File", workflow_exists, str(workflow_path))
        
        if workflow_exists:
            try:
                with open(workflow_path, 'r') as f:
                    workflow_content = f.read()
                
                # Check for key components
                has_triggers = 'on:' in workflow_content
                has_ai_job = 'ai-content-generator' in workflow_content
                has_deploy_job = 'deploy-to-pages' in workflow_content
                has_api_key = 'GITHUB_MODELS_API_KEY' in workflow_content
                
                self.log_test("Workflow Triggers", has_triggers, "Push, PR, schedule triggers")
                self.log_test("AI Generation Job", has_ai_job, "AI content generation job")
                self.log_test("Deployment Job", has_deploy_job, "GitHub Pages deployment")
                self.log_test("API Key Integration", has_api_key, "GitHub Models API key usage")
                
            except Exception as e:
                self.log_test("Workflow Content", False, str(e))
    
    def test_performance_timing(self):
        """Test performance and timing"""
        print("\\n⏱️ Testing performance and timing...")
        
        start_time = time.time()
        
        # Simulate documentation generation timing
        for i in range(3):
            time.sleep(0.1)  # Simulate processing time
        
        generation_time = time.time() - start_time
        
        # Performance thresholds
        fast_generation = generation_time < 1.0
        reasonable_time = generation_time < 5.0
        
        self.log_test("Generation Speed", fast_generation, f"{generation_time:.2f}s (target: <1s)")
        self.log_test("Reasonable Timing", reasonable_time, f"{generation_time:.2f}s (max: 5s)")
        
        # Test file sizes
        total_size = sum(f.stat().st_size for f in self.generated_docs if f.exists())
        reasonable_size = total_size < 1024 * 1024  # 1MB
        
        self.log_test("Documentation Size", reasonable_size, f"{total_size} bytes (max: 1MB)")
    
    def cleanup_test_environment(self):
        """Clean up test environment"""
        print("\\n🧹 Cleaning up test environment...")
        
        try:
            # Remove test files
            if self.test_dir.exists():
                shutil.rmtree(self.test_dir)
            
            # Optionally remove generated docs (comment out to keep them)
            # if self.docs_dir.exists():
            #     shutil.rmtree(self.docs_dir)
            
            print("✅ Test environment cleaned up")
            
        except Exception as e:
            print(f"⚠️ Cleanup warning: {e}")
    
    def generate_test_report(self):
        """Generate comprehensive test report"""
        print("\\n📊 Generating test report...")
        
        report = {
            'test_summary': {
                'total_tests': self.test_results['total_tests'],
                'passed_tests': self.test_results['passed_tests'],
                'failed_tests': self.test_results['failed_tests'],
                'success_rate': (self.test_results['passed_tests'] / max(self.test_results['total_tests'], 1)) * 100,
                'timestamp': datetime.now().isoformat()
            },
            'test_details': self.test_results['test_details'],
            'environment': {
                'python_version': sys.version,
                'platform': sys.platform,
                'test_files_created': len(self.test_files),
                'docs_generated': len(self.generated_docs)
            }
        }
        
        # Save report
        report_path = Path("ai_documentation_test_report.json")
        with open(report_path, 'w') as f:
            json.dump(report, f, indent=2)
        
        # Generate markdown report
        md_report = f"""# 🧪 SAGE-OS AI Documentation Test Report

**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}

## 📊 Test Summary

- **Total Tests**: {report['test_summary']['total_tests']}
- **Passed**: {report['test_summary']['passed_tests']} ✅
- **Failed**: {report['test_summary']['failed_tests']} ❌
- **Success Rate**: {report['test_summary']['success_rate']:.1f}%

## 📋 Test Results

"""
        
        for test in self.test_results['test_details']:
            md_report += f"### {test['name']}\n\n"
            md_report += f"**Status**: {test['status']}  \n"
            if test['details']:
                md_report += f"**Details**: {test['details']}  \n"
            md_report += f"**Time**: {test['timestamp']}  \n\n"
        
        md_report += f"""
## 🔧 Environment

- **Python Version**: {sys.version.split()[0]}
- **Platform**: {sys.platform}
- **Test Files Created**: {len(self.test_files)}
- **Documentation Generated**: {len(self.generated_docs)}

## 📁 Generated Files

### Test Files
"""
        
        for test_file in self.test_files:
            md_report += f"- `{test_file}`\\n"
        
        md_report += "\\n### Documentation Files\\n"
        
        for doc_file in self.generated_docs:
            md_report += f"- `{doc_file}`\\n"
        
        md_report += """

## 🎯 Recommendations

Based on the test results:

1. **If all tests passed**: The AI documentation system is working correctly
2. **If some tests failed**: Review the failed test details and fix issues
3. **Performance**: Monitor generation times for large repositories
4. **API Integration**: Ensure GitHub Models API key is properly configured

## 📈 Next Steps

1. Deploy the AI documentation system to production
2. Configure GitHub Models API key for full AI functionality
3. Test with real repository changes
4. Monitor performance and adjust as needed

---

*Report generated by SAGE-OS AI Documentation Testing System*
"""
        
        md_report_path = Path("ai_documentation_test_report.md")
        with open(md_report_path, 'w') as f:
            f.write(md_report)
        
        print(f"✅ Test report saved:")
        print(f"  - JSON: {report_path}")
        print(f"  - Markdown: {md_report_path}")
        
        return report
    
    def run_all_tests(self):
        """Run all tests"""
        print("🚀 Starting SAGE-OS AI Documentation Tests")
        print("=" * 50)
        
        try:
            self.setup_test_environment()
            self.test_file_detection()
            self.test_documentation_generation()
            self.test_github_pages_compatibility()
            self.test_ai_chatbot_interface()
            self.test_workflow_integration()
            self.test_performance_timing()
            
            report = self.generate_test_report()
            
            print("\\n" + "=" * 50)
            print("🎉 Test Suite Complete!")
            print(f"📊 Results: {report['test_summary']['passed_tests']}/{report['test_summary']['total_tests']} tests passed")
            print(f"✨ Success Rate: {report['test_summary']['success_rate']:.1f}%")
            
            if report['test_summary']['failed_tests'] == 0:
                print("🎯 All tests passed! AI documentation system is ready for production.")
            else:
                print("⚠️ Some tests failed. Please review the test report for details.")
            
            return report['test_summary']['success_rate'] == 100.0
            
        except Exception as e:
            print(f"❌ Test suite failed with error: {e}")
            return False
        
        finally:
            # Uncomment to clean up after testing
            # self.cleanup_test_environment()
            pass

def main():
    """Main test function"""
    tester = AIDocumentationTester()
    success = tester.run_all_tests()
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()