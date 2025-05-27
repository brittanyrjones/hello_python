#!/bin/bash
set -eu
set -o pipefail

# Usage: ./scripts/release/create-tag.sh <branch-name>
# Example: ./scripts/release/create-tag.sh release-v1.2.3

if [ -z "${1:-}" ]; then
  echo "❌ Error: Branch name is required"
  echo "Usage: $0 <branch-name>"
  exit 1
fi

BRANCH_NAME="$1"

# Extract version from branch name
VERSION=${BRANCH_NAME#release-v}
VERSION=${VERSION#release/}
VERSION=${VERSION#release-}

if [ -z "$VERSION" ]; then
  echo "❌ Failed to extract version from branch name: $BRANCH_NAME"
  exit 1
fi

TAG_NAME="v$VERSION"

# Check if tag already exists
if git rev-parse "$TAG_NAME" >/dev/null 2>&1; then
  echo "❌ Tag $TAG_NAME already exists"
  exit 1
fi

# Create the tag
if ! git tag "$TAG_NAME" -m "Release $TAG_NAME"; then
  echo "❌ Failed to create tag $TAG_NAME"
  exit 1
fi

# Push the tag with retries
MAX_RETRIES=3
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  if git push origin "$TAG_NAME"; then
    echo "✅ Successfully pushed tag $TAG_NAME"
    exit 0
  fi
  RETRY_COUNT=$((RETRY_COUNT + 1))
  if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
    echo "⚠️ Failed to push tag, retrying in 5 seconds... (Attempt $RETRY_COUNT of $MAX_RETRIES)"
    sleep 5
  fi
done

echo "❌ Failed to push tag $TAG_NAME after $MAX_RETRIES attempts"
exit 1 