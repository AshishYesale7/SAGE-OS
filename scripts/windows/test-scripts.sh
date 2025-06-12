#!/bin/bash
# Test script to validate Windows batch files

echo "🧪 Testing SAGE OS Windows Scripts"
echo "=================================="
echo

# Function to test batch file syntax
test_batch_syntax() {
    local file="$1"
    echo "📝 Testing: $file"
    
    # Check for common batch file syntax issues
    local issues=0
    
    # Check for proper @echo off
    if ! head -1 "$file" | grep -q "@echo off"; then
        echo "  ⚠️  Missing @echo off at start"
        ((issues++))
    fi
    
    # Check for unmatched parentheses
    local open_parens=$(grep -o "(" "$file" | wc -l)
    local close_parens=$(grep -o ")" "$file" | wc -l)
    if [ "$open_parens" -ne "$close_parens" ]; then
        echo "  ⚠️  Unmatched parentheses: $open_parens open, $close_parens close"
        ((issues++))
    fi
    
    # Check for proper if statements
    if grep -q "if.*(" "$file" && ! grep -q "if.*)" "$file"; then
        echo "  ⚠️  Potential if statement syntax issues"
        ((issues++))
    fi
    
    # Check for goto labels
    local gotos=$(grep -c "goto :" "$file" 2>/dev/null || echo 0)
    local labels=$(grep -c "^:" "$file" 2>/dev/null || echo 0)
    if [ "$gotos" -gt "$labels" ]; then
        echo "  ⚠️  More goto statements than labels"
        ((issues++))
    fi
    
    # Check for proper variable syntax
    if grep -q "%[^%]*[^%]$" "$file"; then
        echo "  ⚠️  Potential unclosed variable references"
        ((issues++))
    fi
    
    if [ "$issues" -eq 0 ]; then
        echo "  ✅ Syntax looks good"
    else
        echo "  ❌ Found $issues potential issues"
    fi
    
    echo
}

# Function to test PowerShell syntax
test_powershell_syntax() {
    local file="$1"
    echo "📝 Testing PowerShell: $file"
    
    # Basic PowerShell syntax checks
    local issues=0
    
    # Check for proper param block
    if grep -q "param(" "$file" && ! grep -q ")" "$file"; then
        echo "  ⚠️  Unclosed param block"
        ((issues++))
    fi
    
    # Check for unmatched braces
    local open_braces=$(grep -o "{" "$file" | wc -l)
    local close_braces=$(grep -o "}" "$file" | wc -l)
    if [ "$open_braces" -ne "$close_braces" ]; then
        echo "  ⚠️  Unmatched braces: $open_braces open, $close_braces close"
        ((issues++))
    fi
    
    if [ "$issues" -eq 0 ]; then
        echo "  ✅ Syntax looks good"
    else
        echo "  ❌ Found $issues potential issues"
    fi
    
    echo
}

# Test all batch files
echo "🔍 Testing Batch Files:"
echo "----------------------"
for file in scripts/windows/*.bat; do
    if [ -f "$file" ]; then
        test_batch_syntax "$file"
    fi
done

# Test PowerShell files
echo "🔍 Testing PowerShell Files:"
echo "----------------------------"
for file in scripts/windows/*.ps1; do
    if [ -f "$file" ]; then
        test_powershell_syntax "$file"
    fi
done

# Test file permissions
echo "🔍 Testing File Permissions:"
echo "----------------------------"
for file in scripts/windows/*; do
    if [ -f "$file" ]; then
        if [ -r "$file" ]; then
            echo "  ✅ $(basename "$file") - readable"
        else
            echo "  ❌ $(basename "$file") - not readable"
        fi
    fi
done

echo
echo "🧪 Script Testing Complete!"