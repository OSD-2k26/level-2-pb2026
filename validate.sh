#!/bin/bash
set -e

ARTIFACT="artifact.txt"

# Fetch everything (CRITICAL)
git fetch --all --quiet

# Required REMOTE branches
REQUIRED=("alpha" "beta" "gamma" "main")

for b in "${REQUIRED[@]}"; do
  git show-ref --verify --quiet "refs/remotes/origin/$b" || {
    echo "❌ Required branch '$b' not found"
    exit 1
  }
done

# Helper: commit where artifact is ADDED in a branch
intro_commit () {
  git log "origin/$1" --diff-filter=A --pretty=format:%H -- "$ARTIFACT" | tail -n 1
}

# Artifact must exist in main (final state)
git show "origin/main:$ARTIFACT" >/dev/null 2>&1 || {
  echo "❌ artifact.txt not found in main"
  exit 1
}

# Must be created in alpha
ALPHA_COMMIT=$(intro_commit alpha)
[ -n "$ALPHA_COMMIT" ] || {
  echo "❌ artifact not created in alpha"
  exit 1
}

# Must appear in beta, gamma, main
BETA_COMMIT=$(intro_commit beta)
GAMMA_COMMIT=$(intro_commit gamma)
MAIN_COMMIT=$(intro_commit main)

for c in "$BETA_COMMIT" "$GAMMA_COMMIT" "$MAIN_COMMIT"; do
  [ -n "$c" ] || {
    echo "❌ artifact missing in one or more branches"
    exit 1
  }
done

# Validate cherry-pick (identical patches)
PATCH_ALPHA=$(git show "$ALPHA_COMMIT" --pretty=format: -- "$ARTIFACT")
PATCH_BETA=$(git show "$BETA_COMMIT" --pretty=format: -- "$ARTIFACT")
PATCH_GAMMA=$(git show "$GAMMA_COMMIT" --pretty=format: -- "$ARTIFACT")
PATCH_MAIN=$(git show "$MAIN_COMMIT" --pretty=format: -- "$ARTIFACT")

[ "$PATCH_ALPHA" = "$PATCH_BETA" ] || {
  echo "❌ alpha → beta not cherry-picked"
  exit 1
}

[ "$PATCH_BETA" = "$PATCH_GAMMA" ] || {
  echo "❌ beta → gamma not cherry-picked"
  exit 1
}

[ "$PATCH_GAMMA" = "$PATCH_MAIN" ] || {
  echo "❌ gamma → main not cherry-picked"
  exit 1
}

# No merges allowed anywhere
git log origin/main --merges | grep . && {
  echo "❌ merge used (not allowed)"
  exit 1
}

echo "✅ HARD LEVEL Ω PASSED"
