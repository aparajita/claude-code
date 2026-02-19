# Worktree

Manage git worktrees with consistent naming and directory placement conventions. Keeps all worktrees in a sibling directory (`../<project>-worktrees/`) and enforces a standard branch naming pattern.

## Features

- **Consistent naming** — worktrees and branches follow a `<type>/<description>` convention
- **Sibling directory layout** — all worktrees live in `../<project>-worktrees/`, out of the project root
- **Interactive menus** — `gum`-powered type/branch selection, confirmations, and fuzzy filtering
- **Uncommitted change copying** — optionally copies all uncommitted changes into the new worktree via `git stash`, while leaving the original directory unchanged
- **MCP server copying** — reads project MCP server config from `~/.claude.json` and offers to copy servers to the new worktree; `serena` is always copied automatically if present
- **JetBrains IDE integration** — automatically opens the worktree in the IDE when a `.idea` directory is detected
- **Rebase-first merge** — attempts a fast-forward merge, falls back to rebase if needed, aborts cleanly on conflicts
- **Context-aware abort/merge** — auto-detects the current worktree; shows a selection list when run from the main directory

## Requirements

- `git`
- [`gum`](https://github.com/charmbracelet/gum) — `brew install gum`

## Installation

1. Add the shell function to your `~/.zshrc` or `~/.bashrc`:

   ```bash
   worktree() { source /path/to/commands/worktree/worktree.sh "$@"; }
   ```

   Replace `/path/to/commands/worktree/worktree.sh` with the actual absolute path.

2. Reload your shell:

   ```bash
   source ~/.zshrc   # or ~/.bashrc
   ```

### Optional: custom types

Create `~/.worktree-settings` to override the default type list:

```bash
# ~/.worktree-settings
WORKTREE_TYPES=(feature fix refactor migration chore spike)
```

The `other` option is always appended to this list regardless of the setting.

## Key Concepts

**Worktree directory**: a sibling to the project root — `../<project-name>-worktrees/`
- Example: `../claude-code-worktrees/`

**Worktree path**: `<worktree-dir>/<type>-<slugified-description>`
- Example: `../claude-code-worktrees/feature-user-authentication`

**Branch name**: `<type>/<slugified-description>`
- Example: `feature/user-authentication`

**Slugification**: description joined with hyphens, lowercased, non-alphanumeric characters (except hyphens) stripped.

## Command Reference

### Creating

**`create [type] [description...]`** (alias: `start`; default when no command given)

Create a new worktree and branch. Prompts interactively for any missing arguments.

- Prompts for type via `gum choose` if not provided; `other` allows arbitrary input
- Prompts for description via `gum input` if not provided
- Optionally copies uncommitted changes into the new worktree
- Selects base branch automatically (1 branch), via `gum choose` (2–10), or `gum filter` (>10)
- Optionally copies project MCP servers to the new worktree
- **cds into the new worktree on completion**

```bash
worktree create feature user-authentication
worktree feature user-authentication   # same — create is the default
worktree create                        # fully interactive
```

### Managing

**`abort`**

Remove a worktree and delete its branch without merging.

- If run from inside a worktree, uses it automatically
- If run from the main directory, presents a selection list
- Prompts for confirmation before deleting
- **cds back to the main directory on completion**

```bash
worktree abort
```

**`merge`**

Rebase and merge a worktree branch into the main branch, then clean up.

- If run from inside a worktree, uses it automatically
- If run from the main directory, presents a selection list
- Attempts fast-forward merge, falls back to rebase; aborts on conflicts
- Removes the worktree directory and deletes the branch
- **cds back to the main directory on completion**

```bash
worktree merge
```

### Navigating

**`list`**

Show all worktrees with their paths and branches.

```bash
worktree list
```

**`switch [partial-name]`**

Switch to a different worktree. Filters by partial name if provided; falls back to full list. **cds into the selected worktree.**

```bash
worktree switch auth
worktree switch       # show full list
```

### Flags

**`--step`**

Pause after each git operation and ask whether to continue. Pass it before the command name.

- Prints a green status line before each operation regardless of whether `--step` is active
- When active, shows a `Continue / Stop` prompt after each step
- Stopping mid-operation leaves the repository in whatever state the last completed step produced

```bash
worktree --step merge
worktree --step create feature my-feature
worktree --step abort
```

### Help and Info

**`-h` / `--help`** — Display command reference

**`version`** — Display the script version

## Tips

- `abort` and `merge` work from inside a worktree **or** from the main directory
- When creating a worktree, uncommitted changes are copied (not moved) — the original directory is left unchanged
- Project MCP servers (from `~/.claude.json`) can optionally be copied to the new worktree
