#!/bin/bash
set -e

# Get branch names
BRANCHES=$(git branch --format='%(refname:short)')

LEFT_BRANCH=$(echo "$BRANCHES" | grep -i 'left' | head -n 1 || true)
RIGHT_BRANCH=$(echo "$BRANCHES" | grep -i 'right' | head -n 1 || true)

if [ -z "$LEFT_BRANCH" ]; then
  echo "❌ No branch containing 'left' found"
  exit 1
fi

if [ -z "$RIGHT_BRANCH" ]; then
  echo "❌ No branch containing 'right' found"
  exit 1
fi

LEFT_HAS_FLAG=$(git ls-tree -r "$LEFT_BRANCH" --name-only | grep -qi '^flag.txt$' && echo 1 || echo 0)
RIGHT_HAS_FLAG=$(git ls-tree -r "$RIGHT_BRANCH" --name-only | grep -qi '^flag.txt$' && echo 1 || echo 0)

TOTAL=$((LEFT_HAS_FLAG + RIGHT_HAS_FLAG))

if [ "$TOTAL" -ne 1 ]; then
  echo "❌ flag.txt must exist in EXACTLY ONE of the left/right branches"
  exit 1
fi

if git ls-tree -r main --name-only | grep -qi '^flag.txt$'; then
  echo "❌ flag.txt must NOT exist in main"
  exit 1
fi

echo "✅ Level 2 Passed"
