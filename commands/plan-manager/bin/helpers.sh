#!/usr/bin/env bash
# helpers.sh — Shared library sourced by all pm-* scripts
# Source this file: source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

set -euo pipefail

# ---------------------------------------------------------------------------
# Core utilities
# ---------------------------------------------------------------------------

die() {
  echo "Error: $*" >&2
  exit 1
}

require_jq() {
  command -v jq >/dev/null 2>&1 || die "jq is required but not installed. Run: brew install jq"
}

# ---------------------------------------------------------------------------
# Path resolution
# ---------------------------------------------------------------------------

# Resolve the directory containing the calling script (follows symlinks)
pm_script_dir() {
  local source="${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}"
  local dir
  while [ -L "$source" ]; do
    dir="$(cd -P "$(dirname "$source")" && pwd)"
    source="$(readlink "$source")"
    [[ "$source" != /* ]] && source="$dir/$source"
  done
  cd -P "$(dirname "$source")" && pwd
}

# Resolve project root by walking up from cwd looking for .claude/
project_root() {
  local dir
  dir="$(pwd)"
  while [ "$dir" != "/" ]; do
    if [ -d "$dir/.claude" ]; then
      echo "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  # Fall back to cwd if no .claude/ found
  pwd
}

# Return the state file path (relative to project root)
state_file_path() {
  echo ".claude/plan-manager-state.json"
}

# Return the absolute state file path
state_file_abs() {
  local root
  root="$(project_root)"
  echo "$root/.claude/plan-manager-state.json"
}

# ---------------------------------------------------------------------------
# State file I/O
# ---------------------------------------------------------------------------

# Read state JSON, outputting empty-state fallback if file missing
read_state() {
  local sf
  sf="$(state_file_abs)"
  if [ -f "$sf" ]; then
    jq '.' "$sf"
  else
    echo '{"version":"1.0.0","plansDirectory":null,"masterPlans":[],"subPlans":[]}'
  fi
}

# Atomic write of state JSON (accepts JSON on stdin or as $1)
write_state() {
  local sf
  sf="$(state_file_abs)"
  local dir
  dir="$(dirname "$sf")"
  mkdir -p "$dir"

  local json="${1:-}"
  if [ -n "$json" ]; then
    echo "$json" | jq '.' > "${sf}.tmp" && mv "${sf}.tmp" "$sf"
  else
    jq '.' > "${sf}.tmp" && mv "${sf}.tmp" "$sf"
  fi
}

# ---------------------------------------------------------------------------
# Date helpers
# ---------------------------------------------------------------------------

today_iso() {
  date +%Y-%m-%d
}

# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------

# Output compact JSON (no extra whitespace)
compact_json() {
  jq -c '.'
}

require_jq
