#!/bin/bash
# Claude Code status line generator
# Reads context from stdin and outputs formatted status line

# Handle --install flag
if [ "$1" = "--install" ]; then
    script_path="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
    settings="$HOME/.claude/settings.json"

    chmod +x "$script_path"

    # Create settings file if it doesn't exist
    if [ ! -f "$settings" ]; then
        echo '{}' > "$settings"
    fi

    # Update statusLine in settings.json
    tmp=$(mktemp)
    jq --arg cmd "$script_path" '.statusLine = {"type": "command", "command": $cmd, "padding": 0}' "$settings" > "$tmp" && mv "$tmp" "$settings"
    echo "Installed status line: $script_path"
    echo "Updated: $settings"
    exit 0
fi

input=$(cat)

# DEBUG: log raw input JSON per process
echo "$input" > "/tmp/claude-status-line-$$.json"

# Extract values from input JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
model_id=$(echo "$input" | jq -r '.model.id')
# effort_level is not in status line JSON; read from settings
effort_level=$(jq -r '.effortLevel // empty' ~/.claude/settings.json 2>/dev/null)
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Initialize git variables
branch=""
dirty=""

# Get git branch and dirty status if in a repo
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null || \
             git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)

    if [ -n "$branch" ]; then
        # Check if there are uncommitted changes
        if ! git -C "$cwd" --no-optional-locks diff --quiet 2>/dev/null || \
           ! git -C "$cwd" --no-optional-locks diff --cached --quiet 2>/dev/null; then
            dirty=$(printf '\033[31m*\033[0m')  # Red asterisk
        fi
    fi
fi

# Replace home directory with tilde
cwd_display="${cwd/#$HOME/~}"

# Check if in a git worktree
worktree_indicator=""
if [ -f "$cwd/.git" ]; then
    # .git is a file (not a directory), indicating this is a worktree
    worktree_indicator="🌲"
fi

# Output: model name (cyan) with effort level for Opus/Sonnet 4.6+
model_display="$model"
if [[ "$model_id" == *"opus-4-6"* || "$model_id" == *"sonnet-4-6"* ]]; then
    # Default to "high" if effort level is empty
    if [ -z "$effort_level" ]; then
        effort_level="high"
    fi
    model_display="$model ($effort_level)"
fi
printf '\033[36m%s\033[0m' "$model_display"
printf '\033[90m | \033[0m'

# Output: context percentage (color-coded)
if [ -n "$used_pct" ]; then
    used_int=$(printf "%.0f" "$used_pct")
    if [ "$used_int" -le 40 ]; then
        printf '\033[32m%d%%\033[0m' "$used_int"  # Green
    elif [ "$used_int" -le 60 ]; then
        printf '\033[33m%d%%\033[0m' "$used_int"  # Yellow
    else
        printf '\033[31m%d%%\033[0m' "$used_int"  # Red
    fi
else
    printf '\033[32m0%%\033[0m'  # Green
fi
printf '\033[90m | \033[0m'

# Output: working directory (blue) with worktree indicator if applicable
printf '\033[34m%s%s\033[0m' "$cwd_display" "$worktree_indicator"

# Output: git branch (magenta) if in a repo
if [ -n "$branch" ]; then
    printf '\033[90m | \033[0m'
    printf '\033[35m%s%s\033[0m' "$branch" "$dirty"
fi
