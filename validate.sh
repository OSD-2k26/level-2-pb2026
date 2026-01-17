#!/bin/bash
set -e

# 1. Fetch everything from the server
git fetch --all --quiet

echo "--- GIT DIAGNOSTICS ---"
# List all remote branches for debugging visibility
git branch -r
echo "-----------------------"

# 2. Check MAIN branch (Strict)
# We check origin/main because the runner might be on a different branch
MAIN_FLAG=$(git ls-tree -r origin/main --name-only | grep -x "flag.txt" || true)
if [ -n "$MAIN_FLAG" ]; then
    echo "❌ FAIL: flag.txt is inside the 'main' branch."
    echo "The instructions say 'The truth is not shared.' It must be removed from main."
    exit 1
fi

# 3. Find side branches and check for the flag
LEFT_BRANCH=$(git branch -r | grep -i "left" | head -n 1 | sed 's/origin\///;s/ //g' || true)
RIGHT_BRANCH=$(git branch -r | grep -i "right" | head -n 1 | sed 's/origin\///;s/ //g' || true)

if [ -z "$LEFT_BRANCH" ] || [ -z "$RIGHT_BRANCH" ]; then
    echo "❌ FAIL: Could not find both a 'left' and 'right' branch."
    exit 1
fi

# 4. Check contents of the side branches
HAS_FLAG_LEFT=$(git ls-tree -r "origin/$LEFT_BRANCH" --name-only | grep -x "flag.txt" || true)
HAS_FLAG_RIGHT=$(git ls-tree -r "origin/$RIGHT_BRANCH" --name-only | grep -x "flag.txt" || true)

echo "Check: '$LEFT_BRANCH' has flag? -> $HAS_FLAG_LEFT"
echo "Check: '$RIGHT_BRANCH' has flag? -> $HAS_FLAG_RIGHT"

# 5. Logical Validation
if [ -n "$HAS_FLAG_LEFT" ] && [ -n "$HAS_FLAG_RIGHT" ]; then
    echo "❌ FAIL: flag.txt found in BOTH branches. Only one path carries the mark."
    exit 1
elif [ -z "$HAS_FLAG_LEFT" ] && [ -z "$HAS_FLAG_RIGHT" ]; then
    echo "❌ FAIL: flag.txt not found in either branch."
    exit 1
fi

echo "✅ SUCCESS: Level 2 Passed!"
