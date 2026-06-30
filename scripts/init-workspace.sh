#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

copy_if_missing() {
  local source="$1"
  local target="$2"

  if [[ ! -f "$source" ]]; then
    echo "Missing template: $source" >&2
    return 1
  fi

  if [[ -e "$target" ]]; then
    echo "Skip existing: $target"
  else
    cp "$source" "$target"
    echo "Created: $target"
  fi
}

echo "Initializing Agent Content Workspace..."

copy_if_missing "AGENTS.template.md" "AGENTS.md"
copy_if_missing "Learning.template.md" "Learning.md"

copy_if_missing "config/creator-profile.template.md" "config/creator-profile.md"
copy_if_missing "config/content-pillars.template.md" "config/content-pillars.md"
copy_if_missing "config/platform-a-rules.template.md" "config/platform-a-rules.md"
copy_if_missing "config/platform-b-rules.template.md" "config/platform-b-rules.md"
copy_if_missing "config/platform-c-rules.template.md" "config/platform-c-rules.md"
copy_if_missing "config/style-preferences.template.md" "config/style-preferences.md"
copy_if_missing "config/visual-rules.template.md" "config/visual-rules.md"
copy_if_missing "config/privacy-rules.template.md" "config/privacy-rules.md"
copy_if_missing "config/agent-prompt.template.md" "config/agent-prompt.md"

mkdir -p \
  platforms/platform-a/{drafts,final,assets,retros,samples,scripts,predictions} \
  platforms/platform-b/{drafts,final,assets,retros,samples,scripts,predictions} \
  platforms/platform-c/{drafts,final,assets,retros,samples,scripts,predictions}

echo
echo "Next steps:"
echo "1. Fill config/creator-profile.md"
echo "2. Fill config/content-pillars.md"
echo "3. Fill platform rules in config/platform-*-rules.md"
echo "4. Fill config/style-preferences.md, config/visual-rules.md, and config/privacy-rules.md"
echo "5. Review AGENTS.md and Learning.md before production use"

