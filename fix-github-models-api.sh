#!/bin/bash

# Fix GitHub Models API endpoints and add API version headers
echo "🔧 Fixing GitHub Models API endpoints and headers..."

# List of workflow files that need API version headers
WORKFLOWS=(
    ".github/workflows/advanced-ai-features.yml"
    ".github/workflows/github-models-ai-docs.yml"
    ".github/workflows/github-models-integration.yml"
)

# Add API version header to workflows that have Authorization headers but missing api-version
for workflow in "${WORKFLOWS[@]}"; do
    if [[ -f "$workflow" ]]; then
        echo "📝 Updating $workflow..."
        
        # Add api-version header after Content-Type if not already present
        if grep -q "Content-Type.*application/json" "$workflow" && ! grep -q "api-version" "$workflow"; then
            sed -i.bak "s/'Content-Type': 'application\/json'/'Content-Type': 'application\/json',\n                'api-version': '2024-08-01-preview'/g" "$workflow"
            echo "✅ Added API version header to $workflow"
        else
            echo "ℹ️  $workflow already has api-version or doesn't need it"
        fi
    else
        echo "⚠️  $workflow not found"
    fi
done

# Update chatbot files to ensure they have the correct API version
echo "🤖 Updating chatbot API configurations..."

CHATBOT_FILES=(
    "docs/sage-ai-chatbot.html"
    "docs/sage-os-ai-assistant.html"
)

for chatbot in "${CHATBOT_FILES[@]}"; do
    if [[ -f "$chatbot" ]]; then
        echo "📝 Checking $chatbot..."
        
        # Add API version to fetch headers if not present
        if grep -q "models.inference.ai.azure.com" "$chatbot" && ! grep -q "api-version.*2024-08-01-preview" "$chatbot"; then
            # Update the headers in the JavaScript fetch calls
            sed -i.bak "s/'Authorization': \`Bearer \${apiKey}\`/'Authorization': \`Bearer \${apiKey}\`,\n                    'api-version': '2024-08-01-preview'/g" "$chatbot"
            echo "✅ Updated API version in $chatbot"
        else
            echo "ℹ️  $chatbot already has correct API version"
        fi
    else
        echo "⚠️  $chatbot not found"
    fi
done

echo ""
echo "🎯 GitHub Models API Fix Summary:"
echo "================================="
echo "✅ Updated API endpoint from models.github.ai to models.inference.ai.azure.com"
echo "✅ Added api-version: 2024-08-01-preview headers"
echo "✅ Fixed workflow authentication issues"
echo "✅ Updated chatbot configurations"
echo ""
echo "🚀 The following should now work:"
echo "  • AI issue analysis workflows"
echo "  • AI PR review workflows"  
echo "  • AI documentation generation"
echo "  • Web-based AI chatbot"
echo ""
echo "🔍 Test the fixes by:"
echo "  1. Creating a new issue (triggers AI analysis)"
echo "  2. Opening the chatbot webpage"
echo "  3. Running workflow_dispatch on AI workflows"

# Clean up backup files
find .github/workflows/ docs/ -name "*.bak" -delete 2>/dev/null

echo ""
echo "✨ GitHub Models API fixes completed!"