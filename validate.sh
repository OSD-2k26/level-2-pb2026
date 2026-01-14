#!/bin/bash
set -e

# Fetch all branches (important for CI)
git fetch --all --quiet

# Get branch names
BRANCHES=$(git branch --format='%(refname:short)')

LEFT_BRANCH=$(echo "$BRANCHES" | grep -i 'left' | head -n 1 || true)
RIGHT_BRANCH=$(echo "$BRANCHES" | grep -i 'right' | head -n 1 || true)

# Check branches exist
if [ -z "$LEFT_BRANCH" ]; then
  echo "❌ No branch containing 'left' found"
  exit 1
fi

if [ -z "$RIGHT_BRANCH" ]; then
  echo "❌ No branch containing 'right' found"
  exit 1
fi

# Check flag.txt in left/right branches (at least one)
LEFT_HAS_FLAG=$(git ls-tree -r "$LEFT_BRANCH" --name-only | grep -c "^flag.txt$" || true)
RIGHT_HAS_FLAG=$(git ls-tree -r "$RIGHT_BRANCH" --name-only | grep -c "^flag.txt$" || true)

TOTAL=$((LEFT_HAS_FLAG + RIGHT_HAS_FLAG))

if [ "$TOTAL" -lt 1 ]; then
  echo "❌ flag.txt not found in any left/right branch"
  exit 1
fi

# Ensure flag.txt is NOT in main
MAIN_HAS_FLAG=$(git ls-tree -r main --name-only | grep -c "^flag.txt$" || true)

if [ "$MAIN_HAS_FLAG" -ne 0 ]; then
  echo "❌ flag.txt must NOT exist in main"
  exit 1
fi

echo "✅ Level 2 Passed"

