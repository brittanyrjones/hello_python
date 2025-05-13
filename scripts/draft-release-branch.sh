#!/usr/bin/env bash

set -e -o pipefail

# Function to display usage
usage() {
    echo "Usage: $0 <bump_type> <release_type> [version]"
    echo "  bump_type: major, minor, or patch"
    echo "  release_type: beta or stable"
    echo "  version: optional specific version (e.g., 0.3.24-beta)"
    exit 1
}

# Check if required arguments are provided
if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    usage
fi

BUMP_TYPE=$1
RELEASE_TYPE=$2
SPECIFIC_VERSION=$3

# Validate bump type
if [[ ! "$BUMP_TYPE" =~ ^(major|minor|patch)$ ]]; then
    echo "Error: bump_type must be one of: major, minor, patch"
    usage
fi

# Validate release type
if [[ ! "$RELEASE_TYPE" =~ ^(beta|stable)$ ]]; then
    echo "Error: release_type must be one of: beta, stable"
    usage
fi

# Get current version from pyproject.toml or use specific version
if [ -n "$SPECIFIC_VERSION" ]; then
    CURRENT_VERSION=$SPECIFIC_VERSION
else
    CURRENT_VERSION=$(grep '^version = ' pyproject.toml | sed 's/version = "\(.*\)"/\1/')
fi

# Split version into components, handling beta/alpha versions
if [[ $CURRENT_VERSION =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)([a-z]+[0-9]*)?$ ]]; then
    MAJOR="${BASH_REMATCH[1]}"
    MINOR="${BASH_REMATCH[2]}"
    PATCH="${BASH_REMATCH[3]}"
    SUFFIX="${BASH_REMATCH[4]}"
else
    echo "Error: Invalid version format: $CURRENT_VERSION"
    exit 1
fi

# Generate new version based on bump type
case "$BUMP_TYPE" in
    major)
        NEW_VERSION="$((MAJOR + 1)).0.0"
        ;;
    minor)
        NEW_VERSION="$MAJOR.$((MINOR + 1)).0"
        ;;
    patch)
        NEW_VERSION="$MAJOR.$MINOR.$((PATCH + 1))"
        ;;
esac

# Add release type suffix if needed
if [ "$RELEASE_TYPE" != "stable" ]; then
    NEW_VERSION="${NEW_VERSION}-${RELEASE_TYPE}"
fi

echo "Current version: $CURRENT_VERSION"
echo "New version: $NEW_VERSION"
echo "Bump type: $BUMP_TYPE"
echo "Release type: $RELEASE_TYPE"

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed"
    exit 1
fi

# Check if user is authenticated with GitHub
if ! gh auth status &> /dev/null; then
    echo "Error: Not authenticated with GitHub. Please run 'gh auth login'"
    exit 1
fi

# Trigger the workflow
echo "Triggering release branch workflow..."
gh workflow run draft-release-branch.yml \
    -f previous_version="$CURRENT_VERSION" \
    -f release_type="$RELEASE_TYPE" \
    -f bump_type="$BUMP_TYPE"

echo "Workflow triggered! Check GitHub Actions for progress."

