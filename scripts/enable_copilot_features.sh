#!/usr/bin/env bash
set -euo pipefail

# enable_copilot_features.sh
# Usage: enable_copilot_features.sh [--dry-run] [--commit]
#
# Idempotently enable a predefined set of Copilot-like features for roles
# "admin" and "premium" inside the repository-local .bithub file (JSON or YAML).
#
# - Creates a backup of the original .bithub as .bithub.bak.TIMESTAMP
# - Requires jq for JSON edits and yq for YAML edits (if available)
# - --dry-run shows what would change (prints resulting file to stdout)
# - --commit will `git add` and commit the change (requires git repo & permissions)

DRY_RUN=0
DO_COMMIT=0

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --commit) DO_COMMIT=1 ;;
    -h|--help)
      cat <<EOF
Usage: $0 [--dry-run] [--commit]
--dry-run   Print resulting config instead of overwriting file.
--commit    Commit the changed .bithub file to git (after writing).
EOF
      exit 0
    ;;
    *) echo "Unknown arg: $arg"; exit 2 ;;
  esac
done

# feature set to enable (adjust as required)
read -r -d '' FEATURES_JSON <<'JSON' || true
{
  "code_completion": true,
  "chat_assistant": true,
  "copilot_x": true,
  "pair_programming": true,
  "repo_insights": true,
  "security_audit": true,
  "explain_code": true,
  "generate_tests": true,
  "refactorings": true,
  "copilot_status_ui": true
}
JSON

TIMESTAMP=$(date -u +"%Y%m%dT%H%M%SZ")
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo .)"
TARGET="$ROOT/.bithub"

echo "Repo root: $ROOT"
echo "Target config: $TARGET"

# ensure backup directory
BACKUP="${TARGET}.bak.${TIMESTAMP}"

# Prepare JSON block to inject if needed
read -r -d '' INJECT_JSON <<JSON || true
{
  "copilot": {
    "enabled_for_roles": ["admin","premium"],
    "features": $FEATURES_JSON
  }
}
JSON

# helper: show and exit for dry-run
function finish_dryrun {
  echo "----- DRY RUN OUTPUT -----"
  cat "$1"
  echo "----- END DRY RUN -----"
  exit 0
}

# If target doesn't exist -> create JSON file
if [ ! -f "$TARGET" ]; then
  echo "No .bithub found; creating JSON .bithub with copilot settings."
  echo "$INJECT_JSON" > "${TARGET}.tmp"
  if [ "$DRY_RUN" -eq 1 ]; then
    finish_dryrun "${TARGET}.tmp"
  fi
  mv "${TARGET}.tmp" "$TARGET"
  echo "Created $TARGET"
  echo "Backup saved as $BACKUP (original absent; empty file written)" > /dev/null || true
else
  # detect file type by first non-whitespace character
  firstchar=$(sed -n '1{/^[[:space:]]*$/!{p;q;}}' "$TARGET" | head -n1 | sed -E 's/^[[:space:]]*([^\n]).*/\1/')
  # make a safe backup
  cp -a "$TARGET" "$BACKUP"
  echo "Backup written to $BACKUP"

  if command -v jq >/dev/null 2>&1 && { [ "$firstchar" = "{" ] || [ "$firstchar" = "[" ]; }; then
    echo "Detected JSON .bithub and jq is available -> editing with jq"
    # Build jq filter to set .copilot.enabled_for_roles and .copilot.features
    jq_filter='
      .copilot = ( .copilot // {} )
      | .copilot.enabled_for_roles = ["admin","premium"]
      | .copilot.features = '"$FEATURES_JSON"
    jq --null-input >/dev/null 2>&1 || true
    tmp="$(mktemp)"
    jq "$jq_filter" "$TARGET" > "$tmp"
    if [ "$DRY_RUN" -eq 1 ]; then
      finish_dryrun "$tmp"
    fi
    mv "$tmp" "$TARGET"
    echo "Updated $TARGET (JSON)"
  elif command -v yq >/dev/null 2>&1; then
    echo "yq available -> assuming YAML and editing with yq"
    # Create yq script to set values
    tmp="$(mktemp)"
    # Write the features as YAML inline via a temporary file
    python3 - <<PY >"$tmp" || true
import sys, json, yaml
features = $FEATURES_JSON
out = {
  "copilot": {
    "enabled_for_roles": ["admin","premium"],
    "features": features
  }
}
print(yaml.safe_dump(out, sort_keys=False))
PY
    if [ "$DRY_RUN" -eq 1 ]; then
      echo "----- DRY RUN YAML MERGE -----"
      cat "$TARGET"
      echo "----- MERGED (new block) -----"
      cat "$tmp"
      exit 0
    fi
    # Merge: append/merge copilot block using yq
    # Note: Here we simply overlay the block onto the existing YAML
    yq eval-all 'select(fileIndex==0) * select(fileIndex==1)' "$TARGET" "$tmp" > "${TARGET}.new"
    mv "${TARGET}.new" "$TARGET"
    rm -f "$tmp"
    echo "Updated $TARGET (YAML)"
  else
    # fallback: append JSON block and warn
    echo "Could not detect JSON (jq missing) or YAML (yq missing). Appending JSON block to $TARGET as fallback."
    echo "" >> "$TARGET"
    echo "# appended copilot settings (fallback)" >> "$TARGET"
    echo "$INJECT_JSON" >> "$TARGET"
    if [ "$DRY_RUN" -eq 1 ]; then
      finish_dryrun "$TARGET"
    fi
    echo "Appended copilot settings to $TARGET (fallback)"
  fi
fi

# Optional commit
if [ "$DO_COMMIT" -eq 1 ]; then
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not in a git repo: cannot commit. Exiting."
    exit 2
  fi
  git add "$TARGET"
  git commit -m "Enable copilot features for roles: admin,premium (automated)" || {
    echo "git commit failed (maybe no changes); continuing."
  }
  echo "Committed changes."
fi

echo "Done. Current .bithub content (first 200 lines):"
sed -n '1,200p' "$TARGET" || true
exit 0
chmod +x scripts/enable_copilot_features.sh
