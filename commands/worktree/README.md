# Worktree Skill

Manage git worktrees with consistent naming and directory placement conventions. Keeps all worktrees in a sibling directory (`../<project>-worktrees/`) and enforces a standard branch naming pattern.

## Features

- **Consistent naming** — worktrees and branches follow a `<type>/<description>` convention, keeping things organized and predictable
- **Sibling directory layout** — all worktrees live in `../<project>-worktrees/`, out of the project root
- **Uncommitted change copying** — when creating a worktree, optionally copies all uncommitted changes (staged, unstaged, and untracked files) into the new worktree using `git stash`, leaving the original directory clean
- **MCP server installation** — reads project MCP server config from `~/.claude.json` and offers to install them in the new worktree; `serena` is always auto-installed if present
- **JetBrains IDE integration** — automatically opens the worktree in the IDE when a `.idea` directory is detected
- **Rebase-first merge** — attempts a fast-forward merge, falls back to rebase if needed, and aborts cleanly on conflicts rather than forcing a merge
- **Natural language triggers** — responds to phrases like "start the feature ...", "merge this worktree", "abort this worktree"

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
