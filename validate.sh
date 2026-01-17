#!/bin/bash
set -e

# Sync with remote to see all branches
git fetch --all --quiet

# Find branches that contain 'left' and 'right' in their names
# This searches local and remote (origin/...) branches
LEFT_REF=$(git branch -a | grep -i "left" | head -n 1 | sed 's/[* ]//g' | sed 's/remotes\///' || true)
RIGHT_REF=$(git branch -a | grep -i "right" | head -n 1 | sed 's/[* ]//g' | sed 's/remotes\///' || true)

echo "--- Debugging Branch Discovery ---"
echo "Left-style branch found:  $LEFT_REF"
echo "Right-style branch found: $RIGHT_REF"
echo "----------------------------------"

# 1. Check if both paths exist
if [ -z "$LEFT_REF" ]; then
  echo "❌ Error: Could not find any branch containing 'left'"
  exit 1
fi

if [ -z "$RIGHT_REF" ]; then
  echo "❌ Error: Could not find any branch containing 'right'"
  exit 1
fi

# 2. Check for flag.txt existence
# We use 'git ls-tree' which works on the branch pointer without switching branches
LEFT_HAS_FLAG=$(git ls-tree -r "$LEFT_REF" --name-only | grep -c "^flag.txt$" || true)
RIGHT_HAS_FLAG=$(git ls-tree -r "$RIGHT_REF" --name-only | grep -c "^flag.txt$" || true)

if [ $((LEFT_HAS_FLAG + RIGHT_HAS_FLAG)) -eq 0 ]; then
  echo "❌ Error: flag.txt was not found in either the left or right branch."
  exit 1
fi

# 3. Verify the "Truth is not shared" rule (Only one path carries the mark)
if [ "$LEFT_HAS_FLAG" -eq 1 ] && [ "$RIGHT_HAS_FLAG" -eq 1 ]; then
  echo "❌ Error: The truth is not shared. flag.txt found in BOTH branches, but should only be in one."
  exit 1
fi

# 4. Ensure flag.txt is NOT in the main branch
# In GitHub Actions, 'main' is the default checkout
MAIN_HAS_FLAG=$(git ls-tree -r HEAD --name-only | grep -c "^flag.txt$" || true)
if [ "$MAIN_HAS_FLAG" -ne 0 ]; then
  echo "❌ Error: flag.txt must NOT exist in the main branch."
  exit 1
fi

echo "✅ Level 2 Passed: Paths verified and flag location is correct."
