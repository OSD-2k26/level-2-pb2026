#!/bin/bash
set -euo pipefail

FLAG="flag.txt"

echo "🔍 Fetching all remote branches..."
git fetch --all --quiet

# Get remote branches, ignore HEAD pointers
REMOTE_BRANCHES=$(git branch -r | grep -v -- '->' | tr '[:upper:]' '[:lower:]')

LEFT_BRANCH=$(echo "$REMOTE_BRANCHES" | grep 'left' | head -n 1 || true)
RIGHT_BRANCH=$(echo "$REMOTE_BRANCHES" | grep 'right' | head -n 1 || true)

if [ -z "$LEFT_BRANCH" ]; then
  echo "❌ No branch containing 'left' found"
  exit 1
fi

if [ -z "$RIGHT_BRANCH" ]; then
  echo "❌ No branch containing 'right' found"
  exit 1
fi

echo "✅ Found branches:"
echo "   LEFT  → $LEFT_BRANCH"
echo "   RIGHT → $RIGHT_BRANCH"

# Convert to full ref names
LEFT_REF="refs/remotes/${LEFT_BRANCH}"
RIGHT_REF="refs/remotes/${RIGHT_BRANCH}"
MAIN_REF="refs/remotes/origin/main"

# Helper
has_flag () {
  git ls-tree -r "$1" --name-only | grep -qx "$FLAG" && echo 1 || echo 0
}

LEFT_HAS=$(has_flag "$LEFT_REF")
RIGHT_HAS=$(has_flag "$RIGHT_REF")

if [ $((LEFT_HAS + RIGHT_HAS)) -ne 1 ]; then
  echo "❌ flag.txt must exist in EXACTLY ONE of left/right branches"
  exit 1
fi

MAIN_HAS=$(has_flag "$MAIN_REF")

if [ "$MAIN_HAS" -ne 0 ]; then
  echo "❌ flag.txt must NOT exist in main"
  exit 1
fi

echo "✅ LEVEL 2 PASSED"
