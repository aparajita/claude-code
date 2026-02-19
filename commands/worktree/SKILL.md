---
name: worktree
description: |
  Manage git worktrees with conventions for naming and directory placement.
  Triggers: "create the feature ...", "start the feature ...", "create a fix for ...", "start a fix for ...", "abort this worktree",
  "merge this worktree", "list worktrees", "show worktrees", "switch to worktree ...",
  "switch worktree", "/worktree create", "/worktree start", "/worktree abort", "/worktree merge",
  "/worktree list", "/worktree switch", "/worktree help", "/worktree version"
argument-hint: "[command] [args] — Commands: create (alias: start), abort, merge, list, switch, help, version"
allowed-tools: "Bash(git *), Bash(python3 *), Bash(idea *), Read(~/.claude.json), Read, Glob, AskUserQuestion"
---

# Worktree Skill

Parse the first argument as the command name. Normalize aliases before looking up the command file: `start` → `create`. Then find the matching command file in `commands/worktree/commands/<command>.md`, read it, and execute its steps exactly.

## Key Concepts

**Main project directory**: the git repository root (output of `git rev-parse --show-toplevel`).

**Project name**: `basename` of the project directory (e.g., `claude-code`).

**Worktree directory**: sibling to the project directory — `../<project-name>-worktrees/` relative to the project root (e.g., `../claude-code-worktrees/`).

**Worktree path naming**: `<worktree-dir>/<type>-<slugified-description>`
- Example: `../claude-code-worktrees/feature-remove-update-mechanism`

**Branch naming**: `<type>/<slugified-description>`
- Example: `feature/remove-update-mechanism`

**Slugification**: join description words with hyphens, convert to lowercase, strip non-alphanumeric characters except hyphens.

**Current worktree detection**: compare the current working directory against the list of worktree paths from `git worktree list`. The main working tree is the first entry.

## Commands

- `create <type> <description words...>` — Create a new worktree and branch (`start` is an alias)
- `abort` — Remove a worktree and delete its branch (no merge); must run from main directory
- `merge` — Rebase and merge a worktree branch into the main branch, then clean up; must run from main directory
- `list` — Show all worktrees with their branches
- `switch [partial-name]` — Switch to a different worktree
- `help` — Display command reference
- `version` — Display the skill version
