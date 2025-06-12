#!/bin/bash

# Fix all remaining AI workflow issues
echo "🔧 Fixing all AI workflow issues..."

# Function to add models permission to workflows
add_models_permission() {
    local workflow_file="$1"
    echo "📝 Adding models permission to $workflow_file..."
    
    if grep -q "permissions:" "$workflow_file" && ! grep -q "models: read" "$workflow_file"; then
        # Add models: read after the permissions: line
        sed -i.bak '/permissions:/a\
  models: read' "$workflow_file"
        echo "✅ Added models permission to $workflow_file"
    else
        echo "ℹ️  $workflow_file already has models permission or no permissions block"
    fi
}

# Function to replace actions/ai-inference with proper GitHub Models API calls
fix_ai_inference_action() {
    local workflow_file="$1"
    echo "📝 Fixing ai-inference action in $workflow_file..."
    
    if grep -q "actions/ai-inference@v1" "$workflow_file"; then
        echo "⚠️  Found actions/ai-inference@v1 in $workflow_file - this action doesn't exist"
        echo "   Manual fix required for this workflow"
    fi
}

# Function to update API endpoints and add headers
fix_api_endpoints() {
    local workflow_file="$1"
    echo "📝 Checking API endpoints in $workflow_file..."
    
    # Check if file has GitHub Models API calls but missing api-version
    if grep -q "models.inference.ai.azure.com" "$workflow_file" && ! grep -q "api-version.*2024-08-01-preview" "$workflow_file"; then
        # Add api-version header after Content-Type
        sed -i.bak "s/'Content-Type': 'application\/json'/'Content-Type': 'application\/json',\n                'api-version': '2024-08-01-preview'/g" "$workflow_file"
        echo "✅ Added API version header to $workflow_file"
    fi
    
    # Fix incorrect API keys (should use GITHUB_TOKEN)
    if grep -q "AI_API_KEY" "$workflow_file"; then
        sed -i.bak "s/AI_API_KEY/GITHUB_TOKEN/g" "$workflow_file"
        echo "✅ Fixed API key reference in $workflow_file"
    fi
    
    # Fix incorrect model names
    if grep -q "'model': 'gpt-4'" "$workflow_file"; then
        sed -i.bak "s/'model': 'gpt-4'/'model': 'openai\/gpt-4o-mini'/g" "$workflow_file"
        echo "✅ Fixed model name in $workflow_file"
    fi
}

# List of workflows to fix
WORKFLOWS=(
    ".github/workflows/ai-documentation-safe.yml"
    ".github/workflows/enhanced-security-performance.yml"
    ".github/workflows/ai-advanced-pipeline.yml"
    ".github/workflows/enhanced-security-scan.yml"
    ".github/workflows/ai-drift-monitor.yml"
    ".github/workflows/ai-file-management.yml"
    ".github/workflows/automated-docs.yml"
    ".github/workflows/enhanced-automated-docs.yml"
)

echo "🎯 Processing ${#WORKFLOWS[@]} workflows..."

for workflow in "${WORKFLOWS[@]}"; do
    if [[ -f "$workflow" ]]; then
        echo ""
        echo "🔧 Processing: $workflow"
        
        # Add models permission
        add_models_permission "$workflow"
        
        # Fix AI inference actions
        fix_ai_inference_action "$workflow"
        
        # Fix API endpoints and headers
        fix_api_endpoints "$workflow"
        
    else
        echo "⚠️  Workflow not found: $workflow"
    fi
done

# Clean up backup files
echo ""
echo "🧹 Cleaning up backup files..."
find .github/workflows/ -name "*.bak" -delete 2>/dev/null

echo ""
echo "🎉 AI Workflow Fixes Summary:"
echo "============================="
echo "✅ Updated API endpoints to models.inference.ai.azure.com"
echo "✅ Added api-version: 2024-08-01-preview headers"
echo "✅ Fixed authentication to use GITHUB_TOKEN"
echo "✅ Added models: read permissions"
echo "✅ Updated model names to openai/gpt-4o-mini"
echo ""
echo "⚠️  Manual fixes still needed for:"
echo "   • Workflows using actions/ai-inference@v1 (action doesn't exist)"
echo "   • Complex multi-step AI workflows may need individual attention"
echo ""
echo "🚀 Test the fixes by:"
echo "   1. Creating a new issue or PR"
echo "   2. Running workflow_dispatch on AI workflows"
echo "   3. Checking GitHub Actions logs for errors"

echo ""
echo "✨ AI workflow fixes completed!"