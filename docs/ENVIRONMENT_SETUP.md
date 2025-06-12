# 🔧 Environment Setup Guide for SAGE OS

This guide explains how to properly set up environment variables and secrets for the SAGE OS AI documentation system.

## 🔐 Required Secrets

### 1. AI_API_KEY (Required for AI Documentation)

**What it is**: API key for GitHub Models or other AI services used for documentation generation.

**How to set it up**:

1. Go to your repository settings: `https://github.com/YOUR_USERNAME/YOUR_REPO/settings`
2. Navigate to **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `AI_API_KEY`
5. Value: Your GitHub Models API key or other AI service API key

**Getting the API Key**:
- For GitHub Models: Visit [GitHub Models](https://github.com/marketplace/models) and generate an API key
- For OpenAI: Visit [OpenAI API](https://platform.openai.com/api-keys)
- For other services: Check their respective documentation

### 2. GITHUB_TOKEN (Automatically provided)

**What it is**: GitHub automatically provides this token for workflow authentication.

**Setup**: No action required - GitHub provides this automatically.

## 🌍 Environment Variables

### Repository Variables

Go to **Settings** → **Secrets and variables** → **Actions** → **Variables** tab:

| Variable Name | Value | Description |
|---------------|-------|-------------|
| `DOCS_ENABLED` | `true` | Enable AI documentation generation |
| `AI_MODEL` | `gpt-4` | AI model to use for documentation |
| `DOCS_FORMAT` | `markdown` | Output format for documentation |

### Environment-Specific Variables

For production deployment, you may want to set up environment-specific variables:

1. Go to **Settings** → **Environments**
2. Create environments: `development`, `staging`, `production`
3. Add environment-specific variables and secrets

## ⚠️ Common Issues and Solutions

### Issue 1: "Variable names must not start with GITHUB_"

**Problem**: Trying to create variables like `GITHUB_MODELS_API_KEY`

**Solution**: Use alternative names:
- ❌ `GITHUB_MODELS_API_KEY`
- ✅ `AI_API_KEY`
- ✅ `MODELS_API_KEY`
- ✅ `OPENAI_API_KEY`

### Issue 2: Workflows not triggering

**Problem**: AI documentation workflows don't run

**Solution**: 
1. Check that `AI_API_KEY` secret is set
2. Verify workflow files are in `.github/workflows/`
3. Ensure branch protection rules allow workflow runs

### Issue 3: API key not working

**Problem**: AI API calls fail with authentication errors

**Solution**:
1. Verify the API key is valid and not expired
2. Check API key permissions and quotas
3. Ensure the key is correctly copied (no extra spaces)

## 🚀 Quick Setup Script

You can use the GitHub CLI to set up secrets quickly:

```bash
# Install GitHub CLI if not already installed
# macOS: brew install gh
# Linux: sudo apt install gh
# Windows: winget install GitHub.cli

# Login to GitHub
gh auth login

# Set the AI API key
gh secret set AI_API_KEY --body "your-api-key-here"

# Set repository variables
gh variable set DOCS_ENABLED --body "true"
gh variable set AI_MODEL --body "gpt-4"
gh variable set DOCS_FORMAT --body "markdown"
```

## 🔍 Verification

### Check if secrets are set correctly:

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. You should see:
   - **Secrets**: `AI_API_KEY`
   - **Variables**: `DOCS_ENABLED`, `AI_MODEL`, `DOCS_FORMAT`

### Test the setup:

1. Make a small change to any file in `docs/`, `kernel/`, or `drivers/`
2. Commit and push the change
3. Check **Actions** tab to see if workflows trigger
4. Look for the "🤖 AI Documentation Generator" workflow

## 📋 Environment Configuration Examples

### For GitHub Models API:
```yaml
# Repository Secret
AI_API_KEY: "ghp_xxxxxxxxxxxxxxxxxxxx"

# Repository Variables
AI_MODEL: "gpt-4"
DOCS_ENABLED: "true"
```

### For OpenAI API:
```yaml
# Repository Secret
AI_API_KEY: "sk-xxxxxxxxxxxxxxxxxxxx"

# Repository Variables
AI_MODEL: "gpt-4"
DOCS_ENABLED: "true"
```

### For Local Development:
```bash
# .env file (never commit this!)
AI_API_KEY=your-api-key-here
AI_MODEL=gpt-4
DOCS_ENABLED=true
```

## 🛡️ Security Best Practices

1. **Never commit API keys** to your repository
2. **Use repository secrets** for sensitive data
3. **Use variables** for non-sensitive configuration
4. **Rotate API keys** regularly
5. **Limit API key permissions** to minimum required
6. **Monitor API usage** to detect unauthorized access

## 🔄 Updating Configuration

### To update secrets:
1. Go to repository **Settings** → **Secrets and variables** → **Actions**
2. Click on the secret name
3. Click **Update secret**
4. Enter new value and save

### To update variables:
1. Go to repository **Settings** → **Secrets and variables** → **Actions** → **Variables**
2. Click on the variable name
3. Update the value and save

## 📞 Getting Help

If you're still having issues:

1. **Check workflow logs**: Go to **Actions** tab and click on failed workflows
2. **Verify API key**: Test your API key with a simple curl request
3. **Check quotas**: Ensure you haven't exceeded API rate limits
4. **Review permissions**: Make sure the API key has necessary permissions

### Example API Key Test:

```bash
# Test GitHub Models API
curl -H "Authorization: Bearer YOUR_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{"model":"gpt-4","messages":[{"role":"user","content":"Hello"}]}' \
     https://models.inference.ai.azure.com/chat/completions

# Test OpenAI API
curl -H "Authorization: Bearer YOUR_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{"model":"gpt-4","messages":[{"role":"user","content":"Hello"}]}' \
     https://api.openai.com/v1/chat/completions
```

---

**Remember**: Keep your API keys secure and never share them publicly!