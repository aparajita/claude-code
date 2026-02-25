# worktree.sh — Git worktree manager with interactive shell menus
#
# IMPORTANT: This script must be sourced (not executed) so that `cd` affects
# the calling shell. Add to ~/.zshrc or ~/.bashrc:
#
#   worktree() { source /path/to/worktree.sh "$@"; }

# ── Version ───────────────────────────────────────────────────────────────────
_WT_VERSION="1.4.1"

# ── Script location ───────────────────────────────────────────────────────────
# BASH_SOURCE[0] in bash, $0 in zsh (both give the sourced file's path)
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
  _WT_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
else
  _WT_SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"
fi

# ── Dependencies ──────────────────────────────────────────────────────────────

_wt_check_deps() {
  local ok=true
  if ! command -v git &>/dev/null; then
    echo "worktree: 'git' is required but not found." >&2
    echo "  Install: https://git-scm.com" >&2
    ok=false
  fi
  if ! command -v jq &>/dev/null; then
    echo "worktree: 'jq' is required but not found." >&2
    echo "  Install: brew install jq   (macOS/Linux via Homebrew)" >&2
    echo "           https://jqlang.github.io/jq/" >&2
    ok=false
  fi
  [[ "$ok" == true ]]
}

# Ensure required dependencies are available; offer to install via brew if missing
_wt_ensure_dependencies() {
  local required_deps=("jq")
  local missing_deps=()

  for dep in "${required_deps[@]}"; do
    if ! command -v "$dep" &>/dev/null; then
      missing_deps+=("$dep")
    fi
  done

  # If all dependencies are present, return success
  if [[ ${#missing_deps[@]} -eq 0 ]]; then
    return 0
  fi

  # Check if brew is available
  if ! command -v brew &>/dev/null; then
    echo "The following tools are required but not found:" >&2
    for dep in "${missing_deps[@]}"; do
      echo "  - $dep" >&2
    done
    echo "Install them from: https://brew.sh" >&2
    return 1
  fi

  # Ask user if they want to install missing dependencies
  local deps_list
  deps_list=$(printf '%s\n' "${missing_deps[@]}" | tr '\n' ' ' | sed 's/ $//')

  if _wt_confirm "The following tools are necessary: $deps_list. Install them?"; then
    for dep in "${missing_deps[@]}"; do
      brew install "$dep" || {
        echo "Failed to install $dep." >&2
        return 1
      }
    done
    return 0
  else
    echo "Exiting, the following tools are required: $deps_list"
    return 1
  fi
}

# ── Settings ──────────────────────────────────────────────────────────────────

_wt_load_settings() {
  local settings="$HOME/.worktree-settings"
  # shellcheck source=/dev/null
  [[ -f "$settings" ]] && source "$settings"
}

# ── Interactive helpers ────────────────────────────────────────────────────────

# Y/n confirmation prompt. Returns 0 if user answers "y", 1 otherwise.
_wt_confirm() {
  local prompt="$1" reply
  printf '%s [y/N] ' "$prompt"
  read -r reply
  [[ "${reply,,}" == "y" ]]
}

# Numbered single-select menu. Result stored in _WT_SELECT_RESULT; empty = cancelled.
# Usage: _wt_select_one "Header text" item1 item2 ...
_wt_select_one() {
  local header="$1"; shift
  local -a items=("$@")
  printf '\n%s\n' "$header"
  local i=1
  for item in "${items[@]}"; do
    printf '  %d) %s\n' "$i" "$item"
    (( i++ )) || true
  done
  printf '  0) Cancel\n'
  _WT_SELECT_RESULT=""
  while true; do
    printf 'Enter number: '
    local reply
    read -r reply
    if [[ "$reply" == "0" ]]; then
      _WT_SELECT_RESULT=""
      return 0
    elif [[ "$reply" =~ ^[0-9]+$ ]] && [[ "$reply" -ge 1 ]] && [[ "$reply" -le "${#items[@]}" ]]; then
      if [[ -n "${ZSH_VERSION:-}" ]]; then
        _WT_SELECT_RESULT="${items[$reply]}"
      else
        _WT_SELECT_RESULT="${items[$((reply-1))]}"
      fi
      return 0
    fi
    printf 'Invalid choice.\n' >&2
  done
}

# ── Settings save ─────────────────────────────────────────────────────────────

# Write or update a single KEY=VALUE line in ~/.worktree-settings.
_wt_save_setting() {
  local key="$1" value="$2"
  local settings="$HOME/.worktree-settings"
  if [[ -f "$settings" ]] && grep -q "^${key}=" "$settings"; then
    local tmp
    tmp=$(mktemp)
    sed "s|^${key}=.*|${key}=${value}|" "$settings" > "$tmp" && mv "$tmp" "$settings"
  else
    printf '%s=%s\n' "$key" "$value" >> "$settings"
  fi
}

# ── Step mode ─────────────────────────────────────────────────────────────────
# Set by --step flag. When true, _wt_step pauses after each git operation.
_WT_STEP=false
# Set by --claude flag. When true, opens Claude Code after worktree creation.
_WT_CLAUDE=false

# Print what's about to happen (always), then pause if --step is active.
# Call this BEFORE the corresponding git/cd command.
# Returns 1 if the user chooses Stop (caller should propagate with || return 1).
_wt_step() {
  printf '\033[32m✓ %s\033[0m\n' "$1"
  [[ "$_WT_STEP" != true ]] && return 0
  echo ""
  printf 'Continue? [y/N] '
  local _wt_step_reply
  read -r _wt_step_reply
  [[ "${_wt_step_reply,,}" != "y" ]] && { echo "Stopped." >&2; return 1; }
  return 0
}

# ── Helpers ───────────────────────────────────────────────────────────────────

_wt_slugify() {
  # Lowercase, spaces → hyphens, strip non-alphanumeric except hyphens
  printf '%s' "$*" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-'
}

_wt_project_root() {
  git rev-parse --show-toplevel 2>/dev/null
}

# If the given directory contains a .idea folder, prompt the user to close the
# JetBrains project before proceeding (so the IDE doesn't lock files during
# worktree removal).
_wt_check_jetbrains() {
  local dir="$1"
  if [[ -d "$dir/.idea" ]]; then
    local display_path="${dir/#$HOME/~}"
    printf 'Please close the JetBrains project at %s. Press Enter when done.' "$display_path"
    read -r
  fi
}

# Output one tab-separated line per worktree: path<TAB>branch<TAB>head<TAB>locked
# 'branch' has refs/heads/ stripped; empty string if detached HEAD
_wt_worktree_data() {
  # Capture git output first to avoid process substitution issues in zsh.
  # Also avoids clobbering zsh's special $path array (tied to $PATH).
  local git_out
  git_out=$(git worktree list --porcelain 2>/dev/null) || return 1
  [[ -z "$git_out" ]] && return 1

  local cur_path="" branch="" head="" locked="0" line
  while IFS= read -r line; do
    case "$line" in
      "worktree "*)
        if [[ -n "$cur_path" ]]; then
          printf '%s\t%s\t%s\t%s\n' "$cur_path" "$branch" "$head" "$locked"
        fi
        cur_path="${line#worktree }"
        branch="" head="" locked="0"
        ;;
      "HEAD "*)
        head="${line#HEAD }"
        ;;
      "branch "*)
        branch="${line#branch refs/heads/}"
        ;;
      locked|"locked "*)
        locked="1"
        ;;
    esac
  done <<< "$git_out"
  if [[ -n "$cur_path" ]]; then
    printf '%s\t%s\t%s\t%s\n' "$cur_path" "$branch" "$head" "$locked"
  fi
}

# Detect target worktree for merge/abort commands.
# If CWD is a non-main worktree → auto-selects it.
# If CWD is main → presents a numbered menu.
# Sets (in calling scope via dynamic scoping):
#   _wt_target_path, _wt_target_branch, _wt_main_path, _wt_main_branch
# Returns 1 on error, 0 on success (including user cancellation via empty _wt_target_path).
_wt_detect_context() {
  local verb="${1:-operation}"
  local wt_data
  wt_data=$(_wt_worktree_data)
  if [[ -z "$wt_data" ]]; then
    echo "worktree: not inside a git repository" >&2
    return 1
  fi

  _wt_main_path=$(printf '%s\n' "$wt_data" | head -1 | cut -f1)
  _wt_main_branch=$(printf '%s\n' "$wt_data" | head -1 | cut -f2)

  local current_root
  current_root=$(_wt_project_root)

  if [[ "$current_root" != "$_wt_main_path" ]]; then
    # Inside a non-main worktree — auto-select it
    _wt_target_path="$current_root"
    _wt_target_branch=$(printf '%s\n' "$wt_data" | while IFS=$'\t' read -r p b h l; do
      if [[ "$p" == "$current_root" ]]; then printf '%s' "$b"; break; fi
    done)
  else
    # In main — build list of non-main worktrees for user to choose from
    local non_main=""
    while IFS=$'\t' read -r p b h l; do
      [[ "$p" == "$_wt_main_path" ]] && continue
      non_main+="${b} — ${p}"$'\n'
    done <<< "$wt_data"
    non_main="${non_main%$'\n'}"  # strip trailing newline

    if [[ -z "$non_main" ]]; then
      echo "worktree: no worktrees found to $verb" >&2
      return 1
    fi

    local -a non_main_arr=()
    while IFS= read -r line; do
      [[ -n "$line" ]] && non_main_arr+=("$line")
    done <<< "$non_main"

    _wt_select_one "Select worktree to $verb:" "${non_main_arr[@]}"
    local choice="$_WT_SELECT_RESULT"
    if [[ -z "$choice" ]]; then
      _wt_target_path=""
      return 0
    fi

    # Parse "branch — path" — uses % (shortest suffix) and ## (longest prefix)
    _wt_target_branch="${choice% — *}"
    _wt_target_path="${choice##* — }"
  fi
}

# ── MCP server copy ───────────────────────────────────────────────────────────

_wt_copy_mcp_servers() {
  _wt_ensure_dependencies || return 1

  local project_dir="$1" worktree_path="$2"
  shift 2
  local selected_servers=("$@")
  local claude_json="$HOME/.claude.json"

  local source_count
  source_count=$(jq --arg project "$project_dir" \
    '.projects[$project].mcpServers // {} | length' "$claude_json")
  if [[ "$source_count" == "0" ]]; then
    echo "No MCP servers found for project: $project_dir" >&2
    return 1
  fi

  local server_names
  server_names=$(printf '%s\n' "${selected_servers[@]}" | jq -R . | jq -s .)

  local servers_to_copy
  servers_to_copy=$(jq --arg project "$project_dir" --argjson names "$server_names" \
    '.projects[$project].mcpServers | with_entries(select([.key] | inside($names)))' \
    "$claude_json")
  if [[ "$servers_to_copy" == "{}" ]]; then
    echo "No matching servers found" >&2
    return 1
  fi

  local updated
  updated=$(jq --arg worktree "$worktree_path" --argjson servers "$servers_to_copy" '
    if .projects[$worktree] == null then
      .projects[$worktree] = {
        allowedTools: [],
        mcpContextUris: [],
        mcpServers: {},
        enabledMcpjsonServers: [],
        disabledMcpjsonServers: [],
        hasTrustDialogAccepted: false,
        projectOnboardingSeenCount: 0,
        hasClaudeMdExternalIncludesApproved: false,
        hasClaudeMdExternalIncludesWarningShown: false
      }
    end |
    .projects[$worktree].mcpServers += $servers
  ' "$claude_json")

  echo "$updated" > "$claude_json"

  local copied
  copied=$(jq -r 'keys | join(", ")' <<< "$servers_to_copy")
  echo "Copied MCP servers: $copied"
}

# ── Command: create ───────────────────────────────────────────────────────────

_wt_cmd_create() {
  _wt_load_settings

  local name="$*"

  # Prompt for name if not given
  if [[ -z "$name" ]]; then
    echo ""
    printf 'Worktree name: '
    read -r name
    [[ -z "$name" ]] && return 0
  fi

  # Derive paths
  local root
  root=$(_wt_project_root)
  if [[ -z "$root" ]]; then
    echo "worktree: not inside a git repository" >&2
    return 1
  fi
  local project_name
  project_name=$(basename "$root")
  local slug
  slug=$(_wt_slugify "$name")
  local branch="${slug}"
  local worktree_dir
  worktree_dir="$(cd "$root/.." 2>/dev/null && pwd)/${project_name}-worktrees"
  local worktree_path="${worktree_dir}/${slug}"

  # Check uniqueness against existing worktrees
  local existing_worktrees
  existing_worktrees=$(_wt_worktree_data)
  while IFS=$'\t' read -r wt_path wt_branch wt_head wt_locked; do
    [[ "$wt_path" == "$root" ]] && continue  # skip main worktree
    local existing_name="${wt_path##*/}"
    if [[ "$existing_name" == "$slug" ]] || [[ "$wt_branch" == "$branch" ]]; then
      echo "worktree: name '$name' is already in use (worktree: $wt_path, branch: $wt_branch)" >&2
      return 1
    fi
  done <<< "$existing_worktrees"

  # If branch already exists, ask to overwrite
  if git -C "$root" rev-parse --verify "refs/heads/$branch" &>/dev/null; then
    if ! _wt_confirm "Branch '$branch' already exists. Overwrite it?"; then
      return 0
    fi
    git -C "$root" branch -D "$branch"
  fi

  # Check if worktree directory already exists
  if [[ -d "$worktree_path" ]]; then
    if ! _wt_confirm "Directory '${worktree_path##*/}' already exists. Overwrite it?"; then
      return 0
    fi
    _wt_check_jetbrains "$worktree_path"
    rm -rf "$worktree_path"
  fi

  # Check for uncommitted changes
  local copy_changes=false
  if [[ -n "$(git -C "$root" status --porcelain 2>/dev/null)" ]]; then
    _wt_select_one "There are untracked/uncommitted changes. Copy them to the worktree?" \
      "Yes" "No" "Cancel"
    local changes_action="$_WT_SELECT_RESULT"
    case "$changes_action" in
      "Yes")
        copy_changes=true
        _wt_step "Stashing uncommitted changes (will restore immediately)" || return 1
        git -C "$root" stash --include-untracked
        git -C "$root" stash apply
        ;;
      "No")
        : # proceed without stashing
        ;;
      *)
        return 0  # Cancel
        ;;
    esac
  fi

  # Create worktree directory if needed
  mkdir -p "$worktree_dir"

  # Select base branch
  local branch_list
  branch_list=$(git -C "$root" branch | sed 's/^[* ]*//')
  local num_branches=0
  while IFS= read -r _; do (( num_branches++ )) || true; done <<< "$branch_list"

  local base_branch=""
  if [[ "$num_branches" -eq 1 ]]; then
    base_branch=$(printf '%s\n' "$branch_list" | tr -d ' ')
    echo "Using base branch: $base_branch"
  else
    local -a branch_arr=()
    while IFS= read -r b; do
      b=$(printf '%s' "$b" | tr -d ' ')
      [[ -n "$b" ]] && branch_arr+=("$b")
    done <<< "$branch_list"
    _wt_select_one "Select base branch:" "${branch_arr[@]}"
    base_branch="$_WT_SELECT_RESULT"
    [[ -z "$base_branch" ]] && { [[ "$copy_changes" == true ]] && git -C "$root" stash drop; return 0; }
  fi

  # Create the worktree
  _wt_step "Creating worktree '$branch' based on $base_branch" || {
    [[ "$copy_changes" == true ]] && git -C "$root" stash drop
    return 1
  }
  if ! git -C "$root" worktree add -b "$branch" "$worktree_path" "$base_branch"; then
    [[ "$copy_changes" == true ]] && git -C "$root" stash drop
    echo "worktree: failed to create worktree" >&2
    return 1
  fi

  # Apply stash into new worktree
  if [[ "$copy_changes" == true ]]; then
    _wt_step "Applying stash to new worktree" || return 1
    if ! git -C "$worktree_path" stash pop; then
      echo "Warning: Could not apply changes to the worktree. Your stash is preserved." >&2
      echo "  To apply manually: cd $worktree_path && git stash pop" >&2
      echo "  To drop the stash:  git stash drop" >&2
    fi
  fi

  # Copy MCP servers
  local mcp_copy_succeeded=false
  local serena_copied=false
  if [[ -f "$HOME/.claude.json" ]]; then
    _wt_ensure_dependencies || return 1
    local mcp_json
    mcp_json=$(jq --arg project "$root" '.projects[$project].mcpServers // {}' \
      "$HOME/.claude.json" 2>/dev/null)

    if [[ -n "$mcp_json" && "$mcp_json" != "{}" ]]; then
      local always_copy=()
      local optional=()
      while IFS= read -r srv_name; do
        [[ -z "$srv_name" ]] && continue
        if [[ "$srv_name" == "serena" ]]; then
          always_copy+=("$srv_name")
        else
          optional+=("$srv_name")
        fi
      done <<< "$(jq -r 'keys[]' <<< "$mcp_json")"

      local selected=("${always_copy[@]}")
      if [[ ${#optional[@]} -gt 0 ]]; then
        echo ""
        printf 'Available MCP servers to copy:\n'
        local idx=1
        for srv in "${optional[@]}"; do
          printf '  %d) %s\n' "$idx" "$srv"
          (( idx++ )) || true
        done
        printf '  0) None\n'
        printf 'Enter numbers separated by spaces (or 0 for none): '
        local mcp_choices
        read -r mcp_choices
        for num in $mcp_choices; do
          if [[ "$num" =~ ^[0-9]+$ ]] && [[ "$num" -ge 1 ]] && [[ "$num" -le "${#optional[@]}" ]]; then
            selected+=("${optional[$((num-1))]}")
          fi
        done
      fi

      if [[ ${#selected[@]} -gt 0 ]]; then
        if _wt_copy_mcp_servers "$root" "$worktree_path" "${selected[@]}"; then
          mcp_copy_succeeded=true
          for s in "${selected[@]}"; do
            [[ "$s" == "serena" ]] && serena_copied=true
          done
        else
          echo "Warning: Failed to copy MCP servers." >&2
        fi
      fi
    fi
  fi

  # Open in JetBrains IDE if .idea/ exists
  if [[ -d "$root/.idea" ]]; then
    local open_ide=false
    if [[ "$serena_copied" == true && "$mcp_copy_succeeded" == true ]]; then
      open_ide=true
    elif [[ "${OPEN_JETBRAINS_IDE:-}" == "true" ]]; then
      open_ide=true
    elif [[ "${OPEN_JETBRAINS_IDE:-}" != "false" ]]; then
      echo ""
      if _wt_confirm "Open worktree in JetBrains IDE?"; then
        open_ide=true
      fi
      if _wt_confirm "Save this choice as a preference?"; then
        _wt_save_setting "OPEN_JETBRAINS_IDE" "$open_ide"
      fi
    fi
    if [[ "$open_ide" == true ]]; then
      idea "$worktree_path" 2>/dev/null || echo "Warning: 'idea' command not found; open manually." >&2
    fi
  fi

  # cd into new worktree
  _wt_step "Switching to new worktree ($worktree_path)" || return 1
  cd "$worktree_path" || return 1

  echo ""
  echo "Worktree created:"
  echo "  Path:     $worktree_path"
  echo "  Branch:   $branch"
  echo "  Based on: $base_branch"

  # Open Claude Code
  local open_claude=false
  if [[ "$_WT_CLAUDE" == true ]]; then
    open_claude=true
  elif [[ "${OPEN_CLAUDE:-}" == "true" ]]; then
    open_claude=true
  elif [[ "${OPEN_CLAUDE:-}" == "false" ]]; then
    open_claude=false
  else
    # No saved preference — ask
    echo ""
    if _wt_confirm "Open Claude Code?"; then
      open_claude=true
    fi
    if _wt_confirm "Save this choice as a preference?"; then
      _wt_save_setting "OPEN_CLAUDE" "$open_claude"
    fi
  fi

  if [[ "$open_claude" == true ]]; then
    claude

    # After Claude exits, check for new commits since the base branch
    local commits_since_base
    commits_since_base=$(git -C "$worktree_path" log --oneline "${base_branch}..HEAD" 2>/dev/null | wc -l | tr -d ' ')

    if [[ "$commits_since_base" -gt 0 ]]; then
      echo ""
      _wt_select_one "Merge changes into '$base_branch', or abort this worktree?" \
        "Merge" "Abort" "Cancel"
      case "$_WT_SELECT_RESULT" in
        "Merge") _wt_cmd_merge ;;
        "Abort") _wt_cmd_abort ;;
        *)       ;;  # Cancel — leave worktree as-is
      esac
    else
      echo ""
      _wt_select_one "No commits were made. Abort this worktree?" "Yes" "Leave it"
      case "$_WT_SELECT_RESULT" in
        "Yes") _wt_cmd_abort ;;
        *)     ;;  # Leave it
      esac
    fi
  fi
}

# ── Command: merge ────────────────────────────────────────────────────────────

_wt_cmd_merge() {
  local _wt_target_path="" _wt_target_branch="" _wt_main_path="" _wt_main_branch=""
  _wt_detect_context "merge" || return $?
  [[ -z "$_wt_target_path" ]] && return 0  # user cancelled

  local target_path="$_wt_target_path"
  local target_branch="$_wt_target_branch"
  local main_path="$_wt_main_path"
  local main_branch="$_wt_main_branch"

  _wt_check_jetbrains "$target_path"

  if [[ -z "$target_branch" ]]; then
    echo "worktree: cannot merge a worktree in detached HEAD state" >&2
    return 1
  fi

  # Check for uncommitted changes in target worktree
  if [[ -n "$(git -C "$target_path" status --porcelain 2>/dev/null)" ]]; then
    echo "worktree: the worktree has uncommitted changes or untracked files" >&2
    echo "  Worktree: $target_path" >&2
    echo "  Branch:   $target_branch" >&2
    echo "  Commit, stash, or remove them before merging." >&2
    return 1
  fi

  # Verify main branch is checked out in main directory
  local current_main_branch
  current_main_branch=$(git -C "$main_path" branch --show-current 2>/dev/null)
  if [[ "$current_main_branch" != "$main_branch" ]]; then
    echo "worktree: main directory is not on the expected branch" >&2
    echo "  Expected: $main_branch" >&2
    echo "  Actual:   $current_main_branch" >&2
    echo "  Please check out '$main_branch' and try again." >&2
    return 1
  fi

  # Attempt fast-forward merge
  local merged=false
  _wt_step "Fast-forward merging $target_branch into $main_branch" || return 1
  if git -C "$main_path" merge --ff-only "$target_branch" 2>/dev/null; then
    merged=true
  else
    # Try rebase then retry ff-only
    _wt_step "Fast-forward failed — rebasing $target_branch onto $main_branch" || return 1
    if git -C "$target_path" rebase "$main_branch" 2>/dev/null; then
      _wt_step "Retrying fast-forward merge of $target_branch into $main_branch" || return 1
      if git -C "$main_path" merge --ff-only "$target_branch" 2>/dev/null; then
        merged=true
      fi
    fi
    if [[ "$merged" != true ]]; then
      git -C "$target_path" rebase --abort 2>/dev/null
      echo "worktree: rebase failed due to conflicts." >&2
      echo "  Resolve conflicts manually in the worktree, then run merge again." >&2
      echo "  Worktree: $target_path" >&2
      echo "  Branch:   $target_branch" >&2
      return 1
    fi
  fi

  # Cleanup: remove worktree files
  _wt_step "Removing worktree directory $target_path" || return 1
  git worktree remove --force "$target_path" 2>/dev/null
  rm -rf "$target_path" 2>/dev/null

  if [[ -d "$target_path" ]]; then
    echo "Warning: Could not remove $target_path — please delete it manually." >&2
  fi

  # Delete the branch
  _wt_step "Deleting branch $target_branch" || return 1
  git -C "$main_path" branch -d "$target_branch" 2>/dev/null

  # cd back to main project directory
  _wt_step "Switching to main directory ($main_path)" || return 1
  cd "$main_path" || return 1

  echo ""
  echo "Worktree merged successfully:"
  echo "  Merged:         $target_branch → $main_branch"
  echo "  Removed:        $target_path"
  echo "  Deleted branch: $target_branch"
}

# ── Command: abort ────────────────────────────────────────────────────────────

_wt_cmd_abort() {
  local _wt_target_path="" _wt_target_branch="" _wt_main_path="" _wt_main_branch=""
  _wt_detect_context "abort" || return $?
  [[ -z "$_wt_target_path" ]] && return 0  # user cancelled

  local target_path="$_wt_target_path"
  local target_branch="$_wt_target_branch"
  local main_path="$_wt_main_path"

  local branch_display="${target_branch:-<detached HEAD>}"
  if ! _wt_confirm "Permanently delete worktree and branch '$branch_display'?"; then
    return 0
  fi

  _wt_check_jetbrains "$target_path"

  # Remove worktree (try without --force first, then with)
  _wt_step "Removing worktree directory $target_path" || return 1
  if ! git worktree remove "$target_path" 2>/dev/null; then
    if ! git worktree remove --force "$target_path" 2>/dev/null; then
      echo "worktree: failed to remove worktree '$target_path'" >&2
      return 1
    fi
  fi

  # Force-delete branch (skip for detached HEAD)
  if [[ -n "$target_branch" ]]; then
    _wt_step "Deleting branch $target_branch" || return 1
    git -C "$main_path" branch -D "$target_branch" 2>/dev/null
  fi

  # cd back to main project directory
  _wt_step "Switching to main directory ($main_path)" || return 1
  cd "$main_path" || return 1

  echo ""
  echo "Worktree aborted:"
  echo "  Removed:        $target_path"
  [[ -n "$target_branch" ]] && echo "  Deleted branch: $target_branch"
}

# ── Command: list ─────────────────────────────────────────────────────────────

_wt_cmd_list() {
  local wt_data wt_path branch head locked
  local current_root marker label branch_display
  local i=0

  wt_data=$(_wt_worktree_data)
  if [[ -z "$wt_data" ]]; then
    echo "worktree: not inside a git repository" >&2
    return 1
  fi

  # Check if only one worktree (the main): no embedded newline means single entry
  if [[ "$wt_data" != *$'\n'* ]]; then
    echo "No worktrees found. Use 'worktree create' to create one."
    return 0
  fi

  current_root=$(_wt_project_root)

  printf '\033[4mGit worktrees\033[0m\n'

  while IFS=$'\t' read -r wt_path branch head locked; do
    marker=" "
    [[ "$wt_path" == "$current_root" ]] && marker="*"

    if [[ $i -eq 0 ]]; then
      label="[main]"
      # Main: show tilde-shortened full path + branch
      local display_path="${wt_path/#$HOME/~}"
      if [[ -n "$branch" ]]; then
        branch_display=" ($branch)"
      else
        branch_display=" (${head:0:7})"
      fi
      [[ "$locked" == "1" ]] && branch_display+=" [locked]"
      printf '%s%s %s%s\n' "$marker" "$label" "$display_path" "$branch_display"
    else
      label="[work]"
      # Work: show only the worktree directory name
      local display_name="${wt_path##*/}"
      [[ "$locked" == "1" ]] && display_name+=" [locked]"
      printf '%s%s %s\n' "$marker" "$label" "$display_name"
    fi
    (( i++ )) || true
  done <<< "$wt_data"
}

# ── Command: switch ───────────────────────────────────────────────────────────

_wt_cmd_switch() {
  local partial="${1:-}"
  local wt_data
  wt_data=$(_wt_worktree_data)
  if [[ -z "$wt_data" ]]; then
    echo "worktree: not inside a git repository" >&2
    return 1
  fi

  local current_root
  current_root=$(_wt_project_root)

  # Build list of non-current worktrees as "branch — path" lines
  local candidates=""
  while IFS=$'\t' read -r wt_path branch head locked; do
    [[ "$wt_path" == "$current_root" ]] && continue
    local display_branch="${branch:-${head:0:7}}"
    candidates+="${display_branch} — ${wt_path}"$'\n'
  done <<< "$wt_data"
  candidates="${candidates%$'\n'}"

  if [[ -z "$candidates" ]]; then
    echo "No other worktrees found. Use 'worktree create' to create one."
    return 0
  fi

  local target=""
  if [[ -n "$partial" ]]; then
    # Filter by partial name (case-insensitive)
    local matched
    matched=$(printf '%s\n' "$candidates" | grep -i "$partial" || true)
    local match_count=0
    [[ -n "$matched" ]] && match_count=$(printf '%s\n' "$matched" | grep -c . || echo 0)

    if [[ "$match_count" -eq 1 ]]; then
      target="$matched"
    elif [[ "$match_count" -eq 0 ]]; then
      echo "No worktree matching '$partial' found. Showing all worktrees." >&2
    else
      candidates="$matched"
    fi
  fi

  if [[ -z "$target" ]]; then
    local -a candidates_arr=()
    while IFS= read -r line; do
      [[ -n "$line" ]] && candidates_arr+=("$line")
    done <<< "$candidates"
    _wt_select_one "Select worktree to switch to:" "${candidates_arr[@]}"
    target="$_WT_SELECT_RESULT"
    [[ -z "$target" ]] && return 0
  fi

  local target_branch="${target% — *}"
  local target_path="${target##* — }"

  cd "$target_path" || return 1
  echo "Switched to worktree:"
  echo "  Path:   $target_path"
  echo "  Branch: $target_branch"
}

# ── Command: cleanup ──────────────────────────────────────────────────────────

_wt_cmd_clean() {
  local root
  root=$(_wt_project_root)
  if [[ -z "$root" ]]; then
    echo "worktree: not inside a git repository" >&2
    return 1
  fi

  local wt_data
  wt_data=$(_wt_worktree_data)
  if [[ -z "$wt_data" ]]; then
    echo "worktree: not inside a git repository" >&2
    return 1
  fi

  local main_path main_branch
  main_path=$(printf '%s\n' "$wt_data" | head -1 | cut -f1)
  main_branch=$(printf '%s\n' "$wt_data" | head -1 | cut -f2)

  local current_root
  current_root=$(_wt_project_root)

  local found_issues=false

  # ── 1. Stale git worktree registrations (directory missing) ─────────────────
  local -a stale_entries=()
  while IFS=$'\t' read -r wt_path branch head locked; do
    [[ "$wt_path" == "$main_path" ]] && continue
    [[ -d "$wt_path" ]] && continue
    stale_entries+=("${branch}	${wt_path}")
  done <<< "$wt_data"

  if [[ ${#stale_entries[@]} -gt 0 ]]; then
    found_issues=true
    echo "Stale worktree registrations (directory no longer exists):"
    for entry in "${stale_entries[@]}"; do
      local b="${entry%%	*}" p="${entry##*	}"
      echo "  ${b:-<detached>}  ($p)"
    done
    echo ""
    if _wt_confirm "Prune stale registrations and delete their branches?"; then
      git -C "$main_path" worktree prune
      for entry in "${stale_entries[@]}"; do
        local b="${entry%%	*}"
        [[ -n "$b" ]] && git -C "$main_path" branch -D "$b" 2>/dev/null
      done
      echo "Pruned stale registrations."
      echo ""
    fi
  fi

  # ── 2. Registered worktrees with branches merged into main ──────────────────
  local -a merged_entries=()
  while IFS=$'\t' read -r wt_path branch head locked; do
    [[ "$wt_path" == "$main_path" ]] && continue
    [[ -z "$branch" ]] && continue  # skip detached HEAD
    if git -C "$main_path" merge-base --is-ancestor "$branch" "$main_branch" 2>/dev/null; then
      merged_entries+=("${branch}	${wt_path}")
    fi
  done <<< "$wt_data"

  if [[ ${#merged_entries[@]} -gt 0 ]]; then
    found_issues=true
    echo "Worktrees whose branches are already merged into '$main_branch':"
    for entry in "${merged_entries[@]}"; do
      local b="${entry%%	*}" p="${entry##*	}"
      echo "  $b  ($p)"
    done
    echo ""
    local cwd_removed=false
    for entry in "${merged_entries[@]}"; do
      local branch="${entry%%	*}" wt_path="${entry##*	}"
      echo ""
      if _wt_confirm "Remove worktree and delete branch '$branch'?"; then
        _wt_step "Removing worktree directory $wt_path" || return 1
        git -C "$main_path" worktree remove --force "$wt_path" 2>/dev/null
        rm -rf "$wt_path" 2>/dev/null
        _wt_step "Deleting branch $branch" || return 1
        git -C "$main_path" branch -d "$branch" 2>/dev/null
        echo "Removed: $wt_path, deleted branch: $branch"
        echo ""
        [[ "$wt_path" == "$current_root" ]] && cwd_removed=true
      fi
    done
    if [[ "$cwd_removed" == true ]]; then
      _wt_step "Switching to main directory ($main_path)" || return 1
      cd "$main_path" || return 1
    fi
  fi

  # ── 3. Orphaned directories (not registered with git) ───────────────────────
  local project_name
  project_name=$(basename "$main_path")
  local worktree_base
  worktree_base="$(cd "$main_path/.." 2>/dev/null && pwd)/${project_name}-worktrees"

  if [[ -d "$worktree_base" ]]; then
    # Collect registered worktree paths (excluding main)
    local -a registered_paths=()
    while IFS=$'\t' read -r wt_path branch head locked; do
      [[ "$wt_path" == "$main_path" ]] && continue
      registered_paths+=("$wt_path")
    done <<< "$wt_data"

    local -a orphans=()
    while IFS= read -r dir; do
      [[ -z "$dir" ]] && continue
      local is_registered=false
      for reg in "${registered_paths[@]}"; do
        [[ "$dir" == "$reg" ]] && is_registered=true && break
      done
      [[ "$is_registered" == false ]] && orphans+=("$dir")
    done < <(find "$worktree_base" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)

    if [[ ${#orphans[@]} -gt 0 ]]; then
      found_issues=true
      echo "Orphaned directories in worktree base (not registered with git):"
      for dir in "${orphans[@]}"; do
        echo "  ${dir##*/}  ($dir)"
      done
      echo ""
      for dir in "${orphans[@]}"; do
        echo ""
        if _wt_confirm "Remove orphaned directory '${dir##*/}'?"; then
          _wt_check_jetbrains "$dir"
          rm -rf "$dir" 2>/dev/null
          echo "Removed: $dir"
        fi
      done
      echo ""
    fi
  fi

  if [[ "$found_issues" == false ]]; then
    echo "No worktree issues found. Everything looks clean."
    echo ""
  fi
}

# ── Command: help ─────────────────────────────────────────────────────────────

_wt_cmd_help() {
  cat <<'HELP'
Worktree Commands
═══════════════════════════════════════════════════════════

CREATING
────────
  create [name...]   (default command; alias: start)
    Create a new worktree and branch. Prompts for a name if not given.
    Example: worktree create user-authentication
    Example: worktree user-authentication

MANAGING
────────
  abort
    Remove a worktree and delete its branch without merging.
    If run from inside a worktree, uses it automatically.
    If run from main, presents a list to choose from.
    Example: worktree abort

  merge
    Rebase and merge a worktree branch into main, then clean up.
    If run from inside a worktree, uses it automatically.
    If run from main, presents a list to choose from.
    Example: worktree merge

  clean (alias: cleanup)
    Find and remove worktree leftovers. Checks three things:
      1. Stale git registrations — worktrees git tracks but whose
         directories no longer exist on disk. Offers to prune them.
      2. Merged worktrees — registered worktrees whose branches are
         already merged into main (e.g. via a GitHub PR). Offers to
         remove the directory and delete the branch.
      3. Orphaned directories — directories in the worktree base
         folder that aren't registered with git. Offers to delete.
    Each item requires individual confirmation before removal.
    Example: worktree clean

NAVIGATING
──────────
  list
    Show all worktrees with their paths and branches.
    Example: worktree list

  switch [partial-name]
    Switch to a different worktree (cds into it).
    Example: worktree switch auth

FLAGS
─────
  --step
    Pause after each git operation and ask whether to continue.
    Useful for verifying changes step by step.
    Example: worktree --step merge

  --claude
    Open Claude Code in the new worktree immediately after creation.
    Overrides the OPEN_CLAUDE preference in ~/.worktree-settings.
    Example: worktree --claude create feature my-feature

HELP AND INFO
─────────────
  -h | --help
    Show this command reference.

  --version | -v
    Show the script version.

SETUP
─────
  Add to ~/.zshrc or ~/.bashrc:
    worktree() { source /path/to/worktree.sh "$@"; }

  Optional settings in ~/.worktree-settings:
    OPEN_CLAUDE=true|false   (set automatically when prompted after create)

TIPS
────
  . Worktree directories are siblings of the project: ../<project>-worktrees/
  . Branch names follow the pattern: <slugified-name>
  . abort and merge work from inside a worktree OR from the main directory
HELP
}

# ── Command: version ──────────────────────────────────────────────────────────

_wt_cmd_version() {
  echo "Worktree v${_WT_VERSION}"
}

# ── Main dispatch ─────────────────────────────────────────────────────────────

_wt_check_deps || return 1

# Parse global flags
while true; do
  case "${1:-}" in
    --step)   _WT_STEP=true;   shift ;;
    --claude) _WT_CLAUDE=true; shift ;;
    *) break ;;
  esac
done

_wt_cmd="${1:-create}"
[[ $# -gt 0 ]] && shift

# Normalize aliases
[[ "$_wt_cmd" == "start" ]]   && _wt_cmd="create"
[[ "$_wt_cmd" == "cleanup" ]] && _wt_cmd="clean"

case "$_wt_cmd" in
  create)  _wt_cmd_create "$@" ;;
  merge)   _wt_cmd_merge ;;
  abort)   _wt_cmd_abort ;;
  clean)   _wt_cmd_clean ;;
  list)    _wt_cmd_list ;;
  switch)  _wt_cmd_switch "$@" ;;
  -h|--help) _wt_cmd_help ;;
  --version|-v) _wt_cmd_version ;;
  *)
    echo "worktree: unknown command '$_wt_cmd'" >&2
    echo "Run 'worktree --help' for usage." >&2
    return 1
    ;;
esac

unset _wt_cmd
