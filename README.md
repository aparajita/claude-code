# Claude Code Commands

Shared Claude Code skills and configurations for use across projects.

## Commands

### plan-manager

Manage hierarchical plans with linked sub-plans and branches. Maintains a master plan as the single source of truth while supporting sub-plans for complex phases and branch plans for unexpected issues.

[README](commands/plan-manager/README.md)

### worktree

Manage git worktrees with consistent naming and directory placement conventions. Keeps all worktrees in a sibling directory and enforces a standard branch naming pattern.

[README](commands/worktree/README.md)

## Status Line

`claude-status-line.sh` is a shell script for Claude Code's `statusLine` command integration. It generates a compact, color-coded status line showing key session information at a glance.

![Status line example](status-line.png)

### Features

- **Model name** — Displays the current model (e.g., `Sonnet 4.6`). For Opus/Sonnet 4.6+, appends the active effort level in parentheses (e.g., `Sonnet 4.6 (medium)`).
- **Context usage** — Shows context window usage as a percentage, color-coded: green (≤40%), yellow (≤60%), red (>60%).
- **Working directory** — Displays the current directory with `~` substituted for the home path. Appends a 🌲 indicator when inside a git worktree.
- **Git branch** — Shows the current branch (or short commit hash in detached HEAD state). Appends a red `*` when there are uncommitted changes.

### Installation

Run with `--install` to automatically configure the script in `~/.claude/settings.json` and make it executable:

```bash
bash claude-status-line.sh --install
```

This sets the `statusLine` key in your Claude Code settings to point to the script's full path and runs `chmod +x` on it.

### Manual configuration

Add the following to `~/.claude/settings.json`, replacing the path with the full path to the script:

```json
"statusLine": {
  "type": "command",
  "command": "/path/to/claude-status-line.sh",
  "padding": 0
}
```

## Contributing

Contributions welcome! This is a collection of useful Claude Code skills and configurations.

## License

MIT
