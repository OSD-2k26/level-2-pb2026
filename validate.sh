#!/bin/bash
set -e

# Fetch all refs (CRITICAL)
git fetch --all --quiet

# Get remote branches only, clean format
REMOTE_BRANCHES=$(git for-each-ref --format='%(refname:short)' refs/remotes | tr '[:upper:]' '[:lower:]')

LEFT_REF=$(echo "$REMOTE_BRANCHES" | grep -E '/.*left' | head -n 1 || true)
RIGHT_REF=$(echo "$REMOTE_BRANCHES" | grep -E '/.*right' | head -n 1 || true)

# Validate branches
[ -n "$LEFT_REF" ] || {
  echo "❌ No branch containing 'left' found"
  exit 1
}

[ -n "$RIGHT_REF" ] || {
  echo "❌ No branch containing 'right' found"
  exit 1
}

# Check flag.txt exists in at least one branch
LEFT_HAS_FLAG=$(git ls-tree -r "$LEFT_REF" --name-only | grep -c "^flag.txt$" || true)
RIGHT_HAS_FLAG=$(git ls-tree -r "$RIGHT_REF" --name-only | grep -c "^flag.txt$" || true)

if [ $((LEFT_HAS_FLAG + RIGHT_HAS_FLAG)) -lt 1 ]; then
  echo "❌ flag.txt not found in any left/right branch"
  exit 1
fi

# Ensure flag.txt NOT in main
MAIN_HAS_FLAG=$(git ls-tree -r main --name-only | grep -c "^flag.txt$" || true)

if [ "$MAIN_HAS_FLAG" -ne 0 ]; then
  echo "❌ flag.txt must NOT exist in main"
  exit 1
fi

echo "✅ Level 2 Passed"
