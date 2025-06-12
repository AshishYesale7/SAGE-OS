
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
    
    print(f"\n📊 Results: {passed}/{len(tests)} tests passed")
