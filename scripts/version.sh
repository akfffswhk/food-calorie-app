#!/bin/bash

# Version Management Script for Food Calorie App
# This script helps manage version numbers and releases

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PUBSPEC_FILE="frontend/pubspec.yaml"
VERSION_FILE="frontend/lib/utils/app_version.dart"
CHANGELOG_FILE="CHANGELOG.md"

# Get current version from pubspec.yaml
get_current_version() {
    grep "^version:" "$PUBSPEC_FILE" | sed 's/version: //' | sed 's/+.*//'
}

# Get current build number from pubspec.yaml
get_current_build_number() {
    grep "^version:" "$PUBSPEC_FILE" | sed 's/.*+//' || echo "1"
}

# Bump version
bump_version() {
    local type=$1
    local current_version=$(get_current_version)
    local current_build=$(get_current_build_number)

    IFS='.' read -r major minor patch <<< "$current_version"

    case $type in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            build=1
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            build=1
            ;;
        patch)
            patch=$((patch + 1))
            build=$((current_build + 1))
            ;;
        build)
            build=$((current_build + 1))
            ;;
        *)
            echo -e "${RED}Invalid version type: $type${NC}"
            echo "Usage: $0 bump [major|minor|patch|build]"
            exit 1
            ;;
    esac

    local new_version="$major.$minor.$patch+$build"

    echo -e "${GREEN}Bumping version from $current_version+$current_build to $new_version${NC}"

    # Update pubspec.yaml
    sed -i "s/^version: .*/version: $new_version/" "$PUBSPEC_FILE"

    # Update app_version.dart
    sed -i "s/static const String version = '.*';/static const String version = '$major.$minor.$patch';/" "$VERSION_FILE"
    sed -i "s/static const int buildNumber = .*/static const int buildNumber = $build;/" "$VERSION_FILE"

    echo -e "${GREEN}Version updated successfully!${NC}"
    echo -e "${BLUE}New version: $new_version${NC}"
}

# Create release
create_release() {
    local version=$(get_current_version)
    local build=$(get_current_build_number)

    echo -e "${BLUE}Creating release for version $version+$build${NC}"

    # Check if there are uncommitted changes
    if [ -n "$(git status --porcelain)" ]; then
        echo -e "${YELLOW}Warning: You have uncommitted changes${NC}"
        read -p "Do you want to continue? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    # Update CHANGELOG.md
    echo -e "${BLUE}Updating CHANGELOG.md${NC}"
    read -p "Enter release notes for this version: " notes

    # Add new version to CHANGELOG
    sed -i "/## \[Unreleased\]/a\\
\\
## [$version] - $(date +%Y-%m-%d)\\
\\
### Added\\
- $notes" "$CHANGELOG_FILE"

    # Commit changes
    echo -e "${BLUE}Committing changes${NC}"
    git add "$PUBSPEC_FILE" "$VERSION_FILE" "$CHANGELOG_FILE"
    git commit -m "chore: release v$version"

    # Create tag
    echo -e "${BLUE}Creating git tag${NC}"
    git tag -a "v$version" -m "Release version $version"

    echo -e "${GREEN}Release created successfully!${NC}"
    echo -e "${BLUE}To push the release, run:${NC}"
    echo -e "${YELLOW}git push origin main${NC}"
    echo -e "${YELLOW}git push origin v$version${NC}"
}

# Show current version
show_version() {
    local version=$(get_current_version)
    local build=$(get_current_build_number)

    echo -e "${BLUE}Current Version:${NC}"
    echo -e "${GREEN}$version+$build${NC}"
}

# Show help
show_help() {
    echo "Version Management Script for Food Calorie App"
    echo ""
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  show              Show current version"
    echo "  bump [type]       Bump version (major, minor, patch, or build)"
    echo "  release           Create a new release"
    echo "  help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 show"
    echo "  $0 bump minor"
    echo "  $0 release"
}

# Main script logic
case "${1:-}" in
    show)
        show_version
        ;;
    bump)
        bump_version "${2:-}"
        ;;
    release)
        create_release
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: ${1:-}${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
