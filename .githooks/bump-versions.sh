#!/bin/bash
# Bump plugin versions in marketplace.json based on staged/changed files

set -e

MARKETPLACE_FILE=".claude-plugin/marketplace.json"

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

# Get base versions for skip logic
base_ref="origin/main"
git rev-parse "$base_ref" &>/dev/null || base_ref="HEAD~1"
merge_base=$(git merge-base HEAD "$base_ref" 2>/dev/null || echo "HEAD")
base_versions=$(git show "$merge_base:$MARKETPLACE_FILE" 2>/dev/null | jq '[.plugins[] | {(.name): .version}] | add' || echo '{}')

# Bump versions
for plugin_name in $plugins_to_bump; do
  [ -z "$plugin_name" ] && continue

  current=$(jq --raw-output --arg n "$plugin_name" '.plugins[] | select(.name==$n) | .version' "$MARKETPLACE_FILE")
  [ -z "$current" ] && continue

  # Skip if already bumped
  base=$(echo "$base_versions" | jq --raw-output --arg n "$plugin_name" '.[$n] // ""')
  [ -n "$base" ] && [ "$current" != "$base" ] && continue

  IFS='.' read -r maj min patch <<< "$current"
  new="$maj.$min.$((patch + 1))"

  jq --arg n "$plugin_name" --arg v "$new" \
    '.plugins |= map(if .name==$n then .version=$v else . end)' \
    "$MARKETPLACE_FILE" > "$MARKETPLACE_FILE.tmp"

  mv "$MARKETPLACE_FILE.tmp" "$MARKETPLACE_FILE"
done

# Stage if AUTO_STAGE is true
if [ "$AUTO_STAGE" = "true" ]; then
  git add "$MARKETPLACE_FILE"
fi
