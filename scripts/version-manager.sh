#!/bin/bash

# SAGE-OS Version Manager
# This script manages version tracking and build output naming
# Author: Ashish Vasant Yesale
# Email: ashishyesale007@gmail.com

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VERSION_FILE="$PROJECT_ROOT/VERSION"

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to get current version
get_version() {
    if [[ -f "$VERSION_FILE" ]]; then
        cat "$VERSION_FILE"
    else
        echo "1.0.0"
    fi
}

# Function to set version
set_version() {
    local new_version="$1"
    if [[ -z "$new_version" ]]; then
        print_error "Version cannot be empty"
        return 1
    fi
    
    # Validate version format (semantic versioning)
    if [[ ! "$new_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        print_error "Invalid version format. Use semantic versioning (e.g., 1.0.0)"
        return 1
    fi
    
    echo "$new_version" > "$VERSION_FILE"
    print_success "Version set to $new_version"
}

# Function to increment version
increment_version() {
    local version_type="$1"
    local current_version
    current_version=$(get_version)
    
    # Parse current version
    IFS='.' read -r major minor patch <<< "$current_version"
    
    case "$version_type" in
        "major")
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        "minor")
            minor=$((minor + 1))
            patch=0
            ;;
        "patch")
            patch=$((patch + 1))
            ;;
        *)
            print_error "Invalid version type. Use: major, minor, or patch"
            return 1
            ;;
    esac
    
    local new_version="$major.$minor.$patch"
    set_version "$new_version"
    echo "$new_version"
}

# Function to generate build identifier
generate_build_id() {
    local arch="$1"
    local target="${2:-generic}"
    local version
    version=$(get_version)
    
    # Short git hash (if available)
    local git_hash=""
    if git rev-parse --git-dir > /dev/null 2>&1; then
        git_hash="-$(git rev-parse --short HEAD)"
    fi
    
    # Build number (incremental)
    local build_file="$PROJECT_ROOT/.build_number"
    local build_num=1
    if [[ -f "$build_file" ]]; then
        build_num=$(cat "$build_file")
        build_num=$((build_num + 1))
    fi
    echo "$build_num" > "$build_file"
    
    # Format: sage-os-v1.0.1-b123-aarch64-rpi5-a1b2c3d
    echo "sage-os-v${version}-b${build_num}-${arch}-${target}${git_hash}"
}

# Function to get clean output paths
get_output_paths() {
    local arch="$1"
    local target="${2:-generic}"
    local build_id
    build_id=$(generate_build_id "$arch" "$target")
    
    # Clean output directory structure
    local output_dir="$PROJECT_ROOT/output"
    local arch_dir="$output_dir/$arch"
    local build_dir="$PROJECT_ROOT/build/$arch"
    
    echo "BUILD_ID=$build_id"
    echo "OUTPUT_DIR=$output_dir"
    echo "ARCH_DIR=$arch_dir"
    echo "BUILD_DIR=$build_dir"
    echo "KERNEL_IMG=$arch_dir/${build_id}.img"
    echo "KERNEL_ELF=$arch_dir/${build_id}.elf"
    echo "ISO_FILE=$arch_dir/${build_id}.iso"
}

# Function to create output directories
create_output_dirs() {
    local arch="$1"
    local output_dir="$PROJECT_ROOT/output"
    local arch_dir="$output_dir/$arch"
    
    mkdir -p "$arch_dir"
    mkdir -p "$output_dir/logs"
    
    print_info "Created output directories for $arch"
}

# Function to clean old builds (keep last 5)
clean_old_builds() {
    local arch="$1"
    local output_dir="$PROJECT_ROOT/output"
    local arch_dir="$output_dir/$arch"
    
    if [[ -d "$arch_dir" ]]; then
        # Keep only the 5 most recent builds
        find "$arch_dir" -name "sage-os-v*" -type f | sort -V | head -n -5 | xargs -r rm -f
        print_info "Cleaned old builds for $arch (kept last 5)"
    fi
}

# Function to show usage
show_usage() {
    cat << EOF
SAGE-OS Version Manager

Usage: $0 [COMMAND] [OPTIONS]

Commands:
    get                     Get current version
    set <version>          Set version (e.g., 1.0.0)
    increment <type>       Increment version (major|minor|patch)
    build-id <arch> [target]  Generate build identifier
    paths <arch> [target]  Get output paths for build
    clean <arch>           Clean old builds for architecture
    setup <arch>           Setup output directories

Examples:
    $0 get                          # Show current version
    $0 set 1.2.0                   # Set version to 1.2.0
    $0 increment patch             # Increment patch version
    $0 build-id aarch64 rpi5       # Generate build ID
    $0 paths aarch64 rpi5          # Show output paths
    $0 clean aarch64               # Clean old aarch64 builds
    $0 setup aarch64               # Setup aarch64 directories

EOF
}

# Main script logic
main() {
    case "${1:-}" in
        "get")
            get_version
            ;;
        "set")
            set_version "$2"
            ;;
        "increment")
            increment_version "$2"
            ;;
        "build-id")
            generate_build_id "$2" "$3"
            ;;
        "paths")
            get_output_paths "$2" "$3"
            ;;
        "clean")
            clean_old_builds "$2"
            ;;
        "setup")
            create_output_dirs "$2"
            ;;
        "help"|"-h"|"--help")
            show_usage
            ;;
        *)
            print_error "Unknown command: ${1:-}"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"