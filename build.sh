#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS Build Wrapper Script
# Redirects to the actual build system in tools/build/

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_SCRIPT="$SCRIPT_DIR/tools/build/build.sh"

# Check if the actual build script exists
if [[ ! -f "$BUILD_SCRIPT" ]]; then
    echo "❌ Build script not found at: $BUILD_SCRIPT"
    echo "Please ensure the project structure is intact."
    exit 1
fi

# Pass all arguments to the actual build script
exec "$BUILD_SCRIPT" "$@"