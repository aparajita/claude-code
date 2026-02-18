---
name: worktree
description: |
  Manage git worktrees with conventions for naming and directory placement.
  Triggers: "start the feature ...", "start a fix for ...", "abort this worktree",
  "merge this worktree", "list worktrees", "show worktrees", "switch to worktree ...",
  "switch worktree", "/worktree start", "/worktree abort", "/worktree merge",
  "/worktree list", "/worktree switch"
argument-hint: "[command] [args] — Commands: start, abort, merge, list, switch"
allowed-tools: "Bash(git:*, mkdir:*, rm:*, ls:*, realpath:*, basename:*, dirname:*), Read, Glob, AskUserQuestion"
---

# Worktree Skill

Parse the first argument as the command name, find the matching command file in `commands/worktree/commands/<command>.md`, read it, and execute its steps exactly.

## Key Concepts

**Project directory**: the git repository root (output of `git rev-parse --show-toplevel`).

**Project name**: `basename` of the project directory (e.g., `claude-code`).

**Worktree directory**: sibling to the project directory — `../<project-name>-worktrees/` relative to the project root (e.g., `../claude-code-worktrees/`).

**Worktree path naming**: `<worktree-dir>/<project-name>-<type>-<slugified-description>`
- Example: `../claude-code-worktrees/claude-code-feature-remove-update-mechanism`

**Branch naming**: `<type>/<slugified-description>`
- Example: `feature/remove-update-mechanism`

**Slugification**: join description words with hyphens, convert to lowercase, strip non-alphanumeric characters except hyphens.

**Current worktree detection**: compare the current working directory against the list of worktree paths from `git worktree list`. The main working tree is the first entry.

## Commands

- `start <type> <description words...>` — Create a new worktree and branch
- `abort` — Remove the current worktree and delete its branch (no merge)
- `merge` — Rebase and merge the current worktree branch into the main branch, then clean up
- `list` — Show all worktrees with their branches
- `switch [partial-name]` — Switch to a different worktree
