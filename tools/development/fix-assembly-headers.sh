#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# Script to fix assembly file headers to use proper comment syntax
# This ensures assembly files compile correctly while preserving copyright headers

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🔧 Fixing assembly file headers..."

# Function to convert semicolon comments to hash comments in assembly files
fix_assembly_file() {
    local file="$1"
    echo "  Processing: $file"
    
    # Create a temporary file
    local temp_file=$(mktemp)
    
    # Convert semicolon comments to hash comments, but only for header lines
    # This preserves inline assembly comments that might use semicolons
    sed 's/^; /# /g' "$file" > "$temp_file"
    
    # Move the fixed file back
    mv "$temp_file" "$file"
}

# Find and fix all assembly files
find "$PROJECT_ROOT" -name "*.S" -type f | while read -r file; do
    # Check if file has semicolon comments at the beginning (header section)
    if head -20 "$file" | grep -q "^; "; then
        fix_assembly_file "$file"
    fi
done

echo "✅ Assembly file headers fixed!"