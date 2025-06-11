# 🤖 GitHub Models AI Integration for SAGE-OS

This directory contains AI integration scripts that use GitHub Models API for enhanced code analysis and documentation generation.

## 🚀 GitHub Models API

GitHub Models provides access to state-of-the-art AI models directly through GitHub:

- **Available Models**: GPT-4o, GPT-4o-mini, o1-preview, o1-mini
- **Authentication**: Uses your existing `GITHUB_TOKEN`
- **Endpoint**: `https://models.inference.ai.azure.com`
- **Documentation**: https://github.com/marketplace/models/

## 📁 Files

### `github-models-integration.py`
Main integration script that provides:
- Codebase analysis and insights
- Security vulnerability assessment  
- Documentation gap detection
- Architecture recommendations
- AI-powered code review

## 🔧 Usage

### Local Usage
```bash
# Set your GitHub token
export GITHUB_TOKEN="your_github_token_here"

# Run AI analysis
python3 scripts/ai/github-models-integration.py
```

### GitHub Actions Usage
The script is automatically called by the documentation workflow when:
- Code is pushed to `dev` or `main` branches
- Documentation workflow is manually triggered
- Security scanning workflow runs

## 📊 Output

The script generates:
- `analysis/ai-results/codebase-analysis.json` - Detailed analysis data
- `analysis/ai-results/ai-summary-report.md` - Human-readable report

## 🤖 AI Analysis Features

### Codebase Analysis
- **Complexity Assessment**: Rates project complexity
- **Architecture Strengths**: Identifies key architectural benefits
- **Improvement Suggestions**: Actionable recommendations
- **Embedded Insights**: Embedded systems specific analysis
- **AI Integration Opportunities**: Ways to enhance AI capabilities

### Security Analysis
- **Risk Assessment**: Overall security risk level
- **Vulnerability Analysis**: Critical and high-priority issues
- **Embedded Security**: Kernel hardening and boot security
- **Immediate Actions**: Top priority security tasks
- **Long-term Strategy**: Strategic security improvements

### Documentation Analysis
- **Documentation Priorities**: Most important docs to create
- **User Journey Mapping**: Developer and user workflows
- **API Documentation Strategy**: How to document APIs effectively
- **Content Gaps**: Missing documentation areas

## 🔑 GitHub Token Setup

Your GitHub token needs these permissions:
- `repo` - Repository access
- `read:org` - Organization access (if applicable)

The token is automatically available in GitHub Actions as `GITHUB_TOKEN`.

## 🛠️ Configuration

The script uses these GitHub Models:
- **Primary**: `gpt-4o` - For comprehensive analysis
- **Fallback**: `gpt-4o-mini` - For faster, lighter analysis
- **Timeout**: 60 seconds per API call
- **Temperature**: 0.3 (focused, deterministic responses)

## 📈 Benefits

### For Developers
- ✅ AI-powered code insights
- ✅ Automated architecture analysis
- ✅ Security vulnerability assessment
- ✅ Documentation gap identification

### For Project Management
- ✅ Complexity assessment
- ✅ Risk evaluation
- ✅ Improvement prioritization
- ✅ Technical debt identification

### For Documentation
- ✅ Content strategy recommendations
- ✅ User journey optimization
- ✅ API documentation planning
- ✅ Tutorial suggestions

## 🔄 Fallback Behavior

If GitHub Models API is unavailable:
- Script continues with rule-based analysis
- Generates fallback reports with best practices
- Marks reports as "AI analysis unavailable"
- Provides standard embedded systems recommendations

## 🐛 Troubleshooting

### Common Issues

**"GITHUB_TOKEN not available"**
- Ensure token is set in environment
- Check token permissions
- Verify token hasn't expired

**"API call failed"**
- Check internet connectivity
- Verify GitHub Models API status
- Try again with fallback model

**"JSON parsing error"**
- AI response may not be valid JSON
- Script will use raw response text
- Check model response format

### Debug Mode
```bash
# Enable verbose output
export DEBUG=1
python3 scripts/ai/github-models-integration.py
```

## 🔗 Resources

- [GitHub Models Marketplace](https://github.com/marketplace/models/)
- [GitHub Models Documentation](https://docs.github.com/en/github-models)
- [SAGE-OS Documentation](https://asadzero.github.io/SAGE-OS/)
- [Issue Tracker](https://github.com/Asadzero/SAGE-OS/issues)

---

*This AI integration enhances SAGE-OS development with intelligent analysis and recommendations.*