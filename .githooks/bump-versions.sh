#!/bin/bash
# Bump plugin versions in marketplace.json based on staged/changed files

set -e

MARKETPLACE_FILE=".claude-plugin/marketplace.json"

# In CI, ensure this is a merge commit (only allowed merge strategy for main)
if [ "$GITHUB_ACTIONS" = "true" ] && ! git rev-parse HEAD^2 &>/dev/null; then
  exit 0
fi

# Get changed files
if [ -z "$STAGED_FILES" ]; then
  STAGED_FILES=$(git diff --cached --name-only)
fi

if [ -z "$STAGED_FILES" ]; then
  changed_files=$(git diff --name-only HEAD~1 HEAD 2>/dev/null || echo "")
else
  changed_files="$STAGED_FILES"
fi

plugins_to_bump=$(echo "$changed_files" | grep '^plugins/' | cut -d'/' -f2 | sort -u)

[ -z "$plugins_to_bump" ] && exit 0

# Determine base commit: workflow uses HEAD~1, local hook uses branch divergence point
base_commit=$([ "$GITHUB_ACTIONS" = "true" ] && echo "HEAD~1" || git merge-base HEAD main)

# Get base versions for skip logic
# Compare against the base of the branch, ensuring we skip if version was bumped
# anywhere in the feature branch or PR (not just the immediately previous commit)
base_versions=$(git show "$base_commit:$MARKETPLACE_FILE" 2>/dev/null | jq '[.plugins[] | {(.name): .version}] | add' || echo '{}')

# Bump versions
for plugin_name in $plugins_to_bump; do
  [ -z "$plugin_name" ] && continue

  current=$(jq --raw-output --arg n "$plugin_name" '.plugins[] | select(.name==$n) | .version' "$MARKETPLACE_FILE")
  [ -z "$current" ] && continue

  # Skip if already bumped, or if the plugin is new since the base commit (its
  # initial version is the release version — nothing to bump yet)
  base=$(echo "$base_versions" | jq --raw-output --arg n "$plugin_name" '.[$n] // ""')
  [ -z "$base" ] && continue
  [ "$current" != "$base" ] && continue

  IFS='.' read -r maj min patch <<< "$current"
  new="$maj.$min.$((patch + 1))"

  jq --indent 4 --arg n "$plugin_name" --arg v "$new" \
    '.plugins |= map(if .name==$n then .version=$v else . end)' \
    "$MARKETPLACE_FILE" > "$MARKETPLACE_FILE.tmp"

  mv "$MARKETPLACE_FILE.tmp" "$MARKETPLACE_FILE"
done

# Stage if AUTO_STAGE is true
if [ "$AUTO_STAGE" = "true" ]; then
  git add "$MARKETPLACE_FILE"
fi
