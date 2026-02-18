# Command: help

## Usage

```
help
```

Display command reference with descriptions and usage.

## Output

Show a formatted list of all available commands:

```
Worktree Commands
═══════════════════════════════════════════════════════════

CREATING
────────
  start <type> <description words...>
    Create a new worktree and branch
    Types: feature, fix, chore, refactor, etc.
    Example: /worktree start feature user authentication

MANAGING
────────
  abort
    Remove a worktree and delete its branch (no merge)
    Must be run from the main project directory
    Example: /worktree abort

  merge
    Rebase and merge a worktree branch into the main branch, then clean up
    Must be run from the main project directory
    Example: /worktree merge

NAVIGATING
──────────
  list
    Show all worktrees with their branches
    Example: /worktree list

  switch [partial-name]
    Switch to a different worktree
    Example: /worktree switch auth

HELP AND INFO
─────────────
  help
    Show this command reference
    Example: /worktree help

  version
    Show the skill version
    Example: /worktree version

TIPS
────
  . abort and merge must be run from the main project directory, not from a worktree
  . Worktree directories are created as siblings: ../<project>-worktrees/
  . Branch names follow the pattern: <type>/<slugified-description>
```
