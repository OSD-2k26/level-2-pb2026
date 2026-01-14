#!/bin/bash
set -e

# Get all local branch names (without *)
BRANCHES=$(git branch --format='%(refname:short)')

# Find branches containing left and right
LEFT_BRANCH=$(echo "$BRANCHES" | grep -i 'left' | head -n 1 || true)
RIGHT_BRANCH=$(echo "$BRANCHES" | grep -i 'right' | head -n 1 || true)

# Validate presence
if [ -z "$LEFT_BRANCH" ]; then
  echo "❌ No branch containing 'left' found"
  exit 1
fi

if [ -z "$RIGHT_BRANCH" ]; then
  echo "❌ No branch containing 'right' found"
  exit 1
fi

# Check flag.txt existence in each branch
LEFT_HAS_FLAG=$(git ls-tree -r "$LEFT_BRANCH" --name-only | grep -c "^flag.txt$" || true)
RIGHT_HAS_FLAG=$(git ls-tree -r "$RIGHT_BRANCH" --name-only | grep -c "^flag.txt$" || true)

TOTAL=$((LEFT_HAS_FLAG + RIGHT_HAS_FLAG))

if [ "$TOTAL" -ne 1 ]; then
  echo "❌ flag.txt must exist in exactly ONE of the left/right branches"
  exit 1
fi

echo "✅ Level 3 Passed"
