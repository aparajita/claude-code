# Worktree Skill

Manage git worktrees with consistent naming and directory placement conventions. Keeps all worktrees in a sibling directory (`../<project>-worktrees/`) and enforces a standard branch naming pattern.

## Installation

Link the worktree directory to your global commands:

```bash
ln -s "$(pwd)/commands/worktree" ~/.claude/commands/worktree
```

## Key Concepts

**Worktree directory**: a sibling to the project root — `../<project-name>-worktrees/`
- Example: `../claude-code-worktrees/`

**Worktree path**: `<worktree-dir>/<type>-<slugified-description>`
- Example: `../claude-code-worktrees/feature-user-authentication`

**Branch name**: `<type>/<slugified-description>`
- Example: `feature/user-authentication`

**Types**: `feature`, `fix`, `chore`, `refactor`, or any conventional prefix.

**Slugification**: description words joined with hyphens, lowercased, non-alphanumeric characters (except hyphens) stripped.

## Command Reference

### Creating

**`start <type> <description words...>`**
Create a new worktree and branch
- Optionally copies uncommitted changes into the new worktree
- Optionally installs project MCP servers in the new worktree
- Example: `/worktree start feature user authentication`

### Managing

**`abort`**
Remove a worktree and delete its branch without merging
- Must be run from the main project directory
- Example: `/worktree abort`

**`merge`**
Rebase and merge a worktree branch into the main branch, then clean up
- Must be run from the main project directory
- Example: `/worktree merge`

### Navigating

**`list`**
Show all worktrees with their branches and paths
- Example: `/worktree list`

**`switch [partial-name]`**
Switch to a different worktree by partial name match
- Example: `/worktree switch auth`

### Help and Info

**`help`**
Display command reference
- Example: `/worktree help`

**`version`**
Display the skill version
- Example: `/worktree version`

## Tips

- `abort` and `merge` must be run from the main project directory, not from inside a worktree
- When starting a worktree, uncommitted changes can be copied (not moved) to the new worktree
- Project MCP servers (from `~/.claude.json`) can optionally be installed in the new worktree
- Use natural language: "start the feature user authentication", "abort this worktree", "merge this worktree"

## Documentation

- [SKILL.md](SKILL.md) — Skill definition and key concepts
- [commands/](commands/) — Detailed command specifications
