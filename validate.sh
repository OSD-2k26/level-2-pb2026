#!/bin/bash
set -e

# Fetch all refs to ensure we see remote branches
git fetch --all --quiet

# Get all remote branches and normalize to lowercase
# We look specifically in refs/remotes/origin
REMOTE_BRANCHES=$(git branch -r | tr '[:upper:]' '[:lower:]')

# Improved detection: Look for the word 'left' or 'right' in the remote list
LEFT_REF=$(echo "$REMOTE_BRANCHES" | grep -i "left" | head -n 1 | xargs || true)
RIGHT_REF=$(echo "$REMOTE_BRANCHES" | grep -i "right" | head -n 1 | xargs || true)

# Validate branches exist
if [ -z "$LEFT_REF" ]; then
  echo "❌ No branch containing 'left' found. Branches found: $REMOTE_BRANCHES"
  exit 1
fi

if [ -z "$RIGHT_REF" ]; then
  echo "❌ No branch containing 'right' found. Branches found: $REMOTE_BRANCHES"
  exit 1
fi

echo "Found branches: $LEFT_REF and $RIGHT_REF"

# Check flag.txt exists in exactly one of the branches (not both, per your README)
LEFT_HAS_FLAG=$(git ls-tree -r "$LEFT_REF" --name-only | grep -c "^flag.txt$" || true)
RIGHT_HAS_FLAG=$(git ls-tree -r "$RIGHT_REF" --name-only | grep -c "^flag.txt$" || true)

if [ $((LEFT_HAS_FLAG + RIGHT_HAS_FLAG)) -eq 0 ]; then
  echo "❌ flag.txt not found in either branch"
  exit 1
fi

# Ensure flag.txt NOT in main (default branch)
# Note: GitHub Actions usually checks out the current branch as 'HEAD'
MAIN_HAS_FLAG=$(git ls-tree -r HEAD --name-only | grep -c "^flag.txt$" || true)

if [ "$MAIN_HAS_FLAG" -ne 0 ]; then
  echo "❌ flag.txt must NOT exist in the main/current branch"
  exit 1
fi

echo "✅ Level 2 Passed"
