# 🔐 GitHub Secrets Management for SAGE-OS

This document provides comprehensive guidance on securely managing secrets and tokens in the SAGE-OS project.

## 🔑 Required Secrets

### GitHub Models API Integration

To enable AI-powered features in SAGE-OS workflows, configure the following secret:

```
Name: GITHUB_MODELS_API_KEY
Description: API key for GitHub Models integration
Required for: AI analysis, documentation generation, security scanning
```

### GitHub Token (Automatic)

GitHub automatically provides `GITHUB_TOKEN` for workflow operations:

```
Name: GITHUB_TOKEN
Description: Automatically generated token for GitHub API access
Scope: Repository-specific operations
Permissions: Configured per workflow
```

## 🛡️ Security Best Practices

### 1. Secret Configuration

**✅ DO:**
- Use GitHub repository secrets for sensitive data
- Configure secrets at the repository level
- Use environment-specific secrets when needed
- Regularly rotate API keys and tokens

**❌ DON'T:**
- Store secrets in code or configuration files
- Use personal access tokens for production workflows
- Share secrets across multiple repositories unnecessarily
- Use overly broad permissions

### 2. Token Permissions

Configure minimal required permissions for each token:

```yaml
permissions:
  contents: read          # Read repository content
  pages: write           # Deploy to GitHub Pages
  id-token: write        # OIDC token for secure authentication
  pull-requests: write   # Comment on PRs
  security-events: write # Upload security scan results
```

### 3. Secret Validation

All workflows include automatic secret validation:

```bash
# Example validation check
if [ -z "$GITHUB_MODELS_API_KEY" ]; then
  echo "❌ GitHub Models API key not configured"
  exit 1
fi

# Validate token format
if [[ ! "$GITHUB_MODELS_API_KEY" =~ ^[a-zA-Z0-9_-]{20,}$ ]]; then
  echo "⚠️  API key format appears invalid"
  exit 1
fi
```

## 🔧 Configuration Steps

### Step 1: Configure GitHub Models API Key

1. **Obtain API Key:**
   - Visit [GitHub Models](https://github.com/marketplace/models)
   - Generate a new API key
   - Copy the key securely

2. **Add to Repository Secrets:**
   ```
   Repository Settings → Secrets and variables → Actions → New repository secret
   
   Name: GITHUB_MODELS_API_KEY
   Value: [your-api-key-here]
   ```

3. **Verify Configuration:**
   - Run the "GitHub Models Integration" workflow
   - Check for successful API validation

### Step 2: Configure Additional Secrets (Optional)

For enhanced features, you may configure:

```
GOOGLE_ANALYTICS_KEY    # For documentation analytics
CODECOV_TOKEN          # For code coverage reporting
SLACK_WEBHOOK_URL      # For notifications
```

## 🔍 Security Monitoring

### Automatic Secret Scanning

SAGE-OS workflows include comprehensive secret scanning:

- **Pattern Detection:** Scans for exposed tokens in code
- **Format Validation:** Validates secret formats
- **Usage Monitoring:** Tracks secret usage patterns
- **Rotation Alerts:** Notifies when secrets need rotation

### Security Alerts

The system monitors for:

```yaml
Security Issues:
  - Exposed GitHub tokens (ghp_*, ghs_*)
  - API keys in code
  - Private keys in repository
  - Database credentials
  - AWS access keys
```

## 🚨 Incident Response

### If Secrets Are Exposed

1. **Immediate Actions:**
   ```bash
   # Revoke the exposed secret immediately
   # Generate new secret
   # Update repository configuration
   # Audit recent usage
   ```

2. **Investigation:**
   - Check git history for exposure duration
   - Review access logs
   - Identify potential unauthorized usage
   - Document incident details

3. **Recovery:**
   - Update all affected systems
   - Rotate related credentials
   - Implement additional monitoring
   - Review security practices

## 📊 Monitoring Dashboard

### Secret Health Check

```yaml
Status Indicators:
  ✅ All secrets configured
  ✅ API access validated
  ✅ No exposed secrets detected
  ✅ Permissions properly scoped
  ⚠️  Secret rotation due
  ❌ Invalid secret format
```

### Usage Metrics

Track secret usage across workflows:

- API call frequency
- Token permission usage
- Error rates
- Performance impact

## 🔄 Rotation Schedule

### Recommended Rotation Frequency

```yaml
GitHub Models API Key: Every 90 days
Personal Access Tokens: Every 60 days
Service Account Keys: Every 30 days
Webhook Secrets: Every 180 days
```

### Automated Rotation

Consider implementing automated rotation for:

- Non-critical API keys
- Service-to-service authentication
- Development environment secrets

## 🧪 Testing Secret Configuration

### Validation Workflow

Use the provided validation workflow to test secret configuration:

```bash
# Manual validation
.github/workflows/github-models-integration.yml

# Automated validation (runs on schedule)
.github/workflows/enhanced-security-performance.yml
```

### Test Checklist

- [ ] API key format validation
- [ ] Connectivity test
- [ ] Permission verification
- [ ] Rate limit check
- [ ] Error handling test

## 📚 Additional Resources

### GitHub Documentation

- [GitHub Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [GitHub Models API](https://github.com/marketplace/models)
- [Security Best Practices](https://docs.github.com/en/actions/security-guides)

### SAGE-OS Security

- [Security Model](security-model.md)
- [Vulnerability Reporting](vulnerability-reporting.md)
- [Security Audit Logs](security-audit.md)

## 🆘 Support

### Getting Help

If you encounter issues with secret configuration:

1. **Check Workflow Logs:** Review failed workflow runs
2. **Validate Configuration:** Use provided validation tools
3. **Contact Team:** Open an issue with security label
4. **Emergency:** Use security contact for critical issues

### Common Issues

```yaml
Issue: "API key not configured"
Solution: Add GITHUB_MODELS_API_KEY to repository secrets

Issue: "Invalid token format"
Solution: Verify API key format and regenerate if needed

Issue: "Permission denied"
Solution: Check token permissions and workflow configuration

Issue: "Rate limit exceeded"
Solution: Implement rate limiting and retry logic
```

---

**⚠️ Security Notice:** Never commit secrets to version control. Always use GitHub's encrypted secrets feature for sensitive data.

*Last Updated: 2025-06-12*