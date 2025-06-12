# 🤖 GitHub Models Guide for SAGE OS

This guide explains how to use GitHub Models for AI-powered documentation generation in SAGE OS.

## 🌟 What is GitHub Models?

GitHub Models provides access to state-of-the-art AI models directly within GitHub Actions workflows. No external API keys needed - it uses your GitHub token with the `models: read` permission.

## 📋 Available Models (56 Total)

### 🔥 OpenAI Models (12 models)

#### GPT-4.1 Series (Latest & Most Capable)
- **`openai/gpt-4.1`** - Latest GPT-4.1 (most capable, best for complex tasks)
- **`openai/gpt-4.1-mini`** - GPT-4.1 Mini (faster, cost-effective)
- **`openai/gpt-4.1-nano`** - GPT-4.1 Nano (ultra-fast, lightweight)

#### GPT-4o Series (Multimodal)
- **`openai/gpt-4o`** - GPT-4o (text, image, audio support)
- **`openai/gpt-4o-mini`** - GPT-4o Mini (default choice, balanced)

#### O-Series (Reasoning Models)
- **`openai/o1`** - O1 (advanced reasoning)
- **`openai/o1-mini`** - O1 Mini (efficient reasoning)
- **`openai/o1-preview`** - O1 Preview
- **`openai/o3`** - O3 (latest reasoning model)
- **`openai/o3-mini`** - O3 Mini
- **`openai/o4-mini`** - O4 Mini (newest)

#### Embedding Models
- **`openai/text-embedding-3-large`** - Large embeddings
- **`openai/text-embedding-3-small`** - Small embeddings

### 🔬 Microsoft Models (12 models)

#### Phi-4 Series (Latest)
- **`microsoft/phi-4`** - Phi-4 (latest, high performance)
- **`microsoft/phi-4-mini-instruct`** - Phi-4 Mini (efficient)
- **`microsoft/phi-4-mini-reasoning`** - Phi-4 Mini with reasoning
- **`microsoft/phi-4-multimodal-instruct`** - Phi-4 Multimodal
- **`microsoft/phi-4-reasoning`** - Phi-4 with advanced reasoning

#### Phi-3.5 Series
- **`microsoft/phi-3.5-mini-instruct`** - Phi-3.5 Mini
- **`microsoft/phi-3.5-moe-instruct`** - Phi-3.5 MoE (Mixture of Experts)
- **`microsoft/phi-3.5-vision-instruct`** - Phi-3.5 Vision

#### Phi-3 Series
- **`microsoft/phi-3-medium-128k-instruct`** - Phi-3 Medium (128k context)
- **`microsoft/phi-3-medium-4k-instruct`** - Phi-3 Medium (4k context)
- **`microsoft/phi-3-mini-128k-instruct`** - Phi-3 Mini (128k context)
- **`microsoft/phi-3-mini-4k-instruct`** - Phi-3 Mini (4k context)
- **`microsoft/phi-3-small-128k-instruct`** - Phi-3 Small (128k context)
- **`microsoft/phi-3-small-8k-instruct`** - Phi-3 Small (8k context)

#### MAI Series
- **`microsoft/mai-ds-r1`** - MAI DS R1

### 🦙 Meta Models (11 models)

#### Llama 4 Series (Latest)
- **`meta/llama-4-maverick-17b-128e-instruct-fp8`** - Llama 4 Maverick
- **`meta/llama-4-scout-17b-16e-instruct`** - Llama 4 Scout

#### Llama 3.3 Series
- **`meta/llama-3.3-70b-instruct`** - Llama 3.3 70B (recommended)

#### Llama 3.2 Series (Vision)
- **`meta/llama-3.2-11b-vision-instruct`** - Llama 3.2 11B Vision
- **`meta/llama-3.2-90b-vision-instruct`** - Llama 3.2 90B Vision

#### Llama 3.1 Series
- **`meta/meta-llama-3.1-405b-instruct`** - Llama 3.1 405B (largest)
- **`meta/meta-llama-3.1-70b-instruct`** - Llama 3.1 70B
- **`meta/meta-llama-3.1-8b-instruct`** - Llama 3.1 8B (efficient)

#### Llama 3 Series
- **`meta/meta-llama-3-70b-instruct`** - Llama 3 70B
- **`meta/meta-llama-3-8b-instruct`** - Llama 3 8B

### 🌟 Mistral AI Models (6 models)

- **`mistral-ai/mistral-large-2411`** - Mistral Large (latest)
- **`mistral-ai/mistral-medium-2505`** - Mistral Medium
- **`mistral-ai/mistral-small-2503`** - Mistral Small
- **`mistral-ai/mistral-nemo`** - Mistral Nemo
- **`mistral-ai/codestral-2501`** - Codestral (code-focused)
- **`mistral-ai/ministral-3b`** - Ministral 3B

### 🔮 xAI Models (2 models)

- **`xai/grok-3`** - Grok 3 (latest from xAI)
- **`xai/grok-3-mini`** - Grok 3 Mini

### 🧠 Cohere Models (6 models)

#### Command Series
- **`cohere/cohere-command-r-plus-08-2024`** - Command R+ (latest)
- **`cohere/cohere-command-r-plus`** - Command R+
- **`cohere/cohere-command-r-08-2024`** - Command R (latest)
- **`cohere/cohere-command-r`** - Command R
- **`cohere/cohere-command-a`** - Command A

#### Embedding Models
- **`cohere/cohere-embed-v3-english`** - English embeddings
- **`cohere/cohere-embed-v3-multilingual`** - Multilingual embeddings

### 🚀 DeepSeek Models (3 models)

- **`deepseek/deepseek-v3-0324`** - DeepSeek V3 (latest)
- **`deepseek/deepseek-r1`** - DeepSeek R1 (reasoning)
- **`deepseek/deepseek-r1-0528`** - DeepSeek R1 (May 2024)

### 🌍 AI21 Labs Models (2 models)

- **`ai21-labs/ai21-jamba-1.5-large`** - Jamba 1.5 Large
- **`ai21-labs/ai21-jamba-1.5-mini`** - Jamba 1.5 Mini

### 🏛️ Core42 Models (1 model)

- **`core42/jais-30b-chat`** - JAIS 30B Chat (Arabic-focused)

## 🎯 Recommended Models for SAGE OS

### For Documentation Generation:
1. **`openai/gpt-4.1-mini`** - Best balance of quality and speed
2. **`openai/gpt-4o-mini`** - Default choice, reliable
3. **`microsoft/phi-4`** - Excellent for technical content
4. **`meta/llama-3.3-70b-instruct`** - High quality, open source

### For Code Analysis:
1. **`mistral-ai/codestral-2501`** - Specialized for code
2. **`openai/gpt-4.1`** - Best overall code understanding
3. **`deepseek/deepseek-v3-0324`** - Strong coding capabilities

### For Reasoning Tasks:
1. **`openai/o1-mini`** - Advanced reasoning, efficient
2. **`openai/o3-mini`** - Latest reasoning model
3. **`microsoft/phi-4-reasoning`** - Microsoft's reasoning model

## 🚀 How to Use GitHub Models in SAGE OS

### 1. Using the Workflow

The AI documentation workflow supports all GitHub Models:

```yaml
# Manual trigger with model selection
workflow_dispatch:
  inputs:
    model_id:
      description: 'AI Model to use'
      type: choice
      options:
        - 'openai/gpt-4o-mini'      # Default
        - 'openai/gpt-4.1-mini'     # Latest mini
        - 'microsoft/phi-4'         # Microsoft latest
        - 'meta/llama-3.3-70b-instruct'  # Meta latest
        # ... and many more
```

### 2. API Usage Example

```python
import requests

def call_github_models_api(prompt, model_id='openai/gpt-4o-mini'):
    headers = {
        'Authorization': f'Bearer {GITHUB_TOKEN}',
        'Content-Type': 'application/json'
    }
    
    data = {
        'model': model_id,
        'messages': [
            {'role': 'user', 'content': prompt}
        ],
        'max_tokens': 2000,
        'temperature': 0.3
    }
    
    response = requests.post(
        'https://models.github.ai/chat/completions',
        headers=headers,
        json=data
    )
    
    return response.json()['choices'][0]['message']['content']
```

### 3. Required Permissions

```yaml
permissions:
  contents: write    # To commit generated docs
  models: read      # To access GitHub Models
  id-token: write   # For authentication
```

## 🔧 Setup Instructions

### 1. No API Keys Required!

Unlike external AI services, GitHub Models uses your GitHub token automatically. No need to set up `AI_API_KEY` or any other secrets.

### 2. Enable the Workflow

1. The workflow is already configured in `.github/workflows/github-models-ai-docs.yml`
2. It triggers automatically on code changes
3. You can also run it manually with model selection

### 3. Manual Trigger

1. Go to **Actions** tab in your repository
2. Select "🤖 GitHub Models AI Documentation Generator"
3. Click "Run workflow"
4. Choose your preferred model
5. Click "Run workflow"

## 📊 Model Comparison

| Model | Publisher | Best For | Speed | Quality | Context |
|-------|-----------|----------|-------|---------|---------|
| `openai/gpt-4.1-mini` | OpenAI | General docs | ⚡⚡⚡ | ⭐⭐⭐⭐ | 128k |
| `openai/gpt-4o-mini` | OpenAI | Default choice | ⚡⚡⚡ | ⭐⭐⭐⭐ | 128k |
| `microsoft/phi-4` | Microsoft | Technical content | ⚡⚡ | ⭐⭐⭐⭐⭐ | 128k |
| `meta/llama-3.3-70b-instruct` | Meta | High quality | ⚡ | ⭐⭐⭐⭐⭐ | 128k |
| `mistral-ai/codestral-2501` | Mistral | Code analysis | ⚡⚡ | ⭐⭐⭐⭐ | 32k |
| `openai/o1-mini` | OpenAI | Reasoning | ⚡ | ⭐⭐⭐⭐⭐ | 128k |

## 🎉 Benefits of GitHub Models

### ✅ Advantages:
- **No API keys needed** - Uses GitHub token
- **56 models available** - Huge selection
- **Latest models** - GPT-4.1, Phi-4, Llama 4, etc.
- **Built into GitHub** - Seamless integration
- **Free tier available** - Great for open source
- **Enterprise ready** - Secure and compliant

### 🔄 Automatic Updates:
- New models added regularly
- Always access to latest versions
- No need to update API endpoints

## 🛠️ Troubleshooting

### Issue: "models: read permission required"
**Solution**: Add `models: read` to workflow permissions

### Issue: Model not found
**Solution**: Check available models with:
```bash
curl -H "Authorization: Bearer $GITHUB_TOKEN" \
     https://models.github.ai/catalog/models
```

### Issue: Rate limits
**Solution**: Use smaller models like `-mini` variants or add delays

## 📈 Usage Analytics

The workflow automatically tracks:
- Model used for each generation
- Generation time and success rate
- Documentation quality metrics
- File sizes and content analysis

## 🔮 Future Features

- **Model auto-selection** based on task type
- **A/B testing** between different models
- **Quality scoring** and model comparison
- **Custom model fine-tuning** for SAGE OS

---

**🎉 GitHub Models provides the most comprehensive AI model access directly in GitHub - perfect for SAGE OS documentation generation!**

*Last updated: 2025-06-12*