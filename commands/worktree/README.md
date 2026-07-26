# Worktree

Manage git worktrees with consistent naming and directory placement conventions. Keeps all worktrees in a sibling directory (`../<project>-worktrees/`) and enforces a standard branch naming pattern.

## Features

- **Consistent naming** — worktrees and branches follow a `<slugified-name>` convention
- **Sibling directory layout** — all worktrees live in `../<project>-worktrees/`, out of the project root
- **Interactive menus** — numbered shell menus and Y/n prompts, no external dependencies beyond `git` and `jq`
- **Uniqueness validation** — rejects names that conflict with an existing worktree or branch
- **Uncommitted change copying** — optionally copies all uncommitted changes into the new worktree via `git stash`, while leaving the original directory unchanged
- **MCP server copying** — reads project MCP server config from `~/.claude.json` and offers to copy servers to the new worktree; `serena` is always copied automatically if present
- **JetBrains IDE integration** — automatically opens the worktree in the IDE when a `.idea` directory is detected
- **Tested merges** — rebases onto the main branch, runs the project's tests on the rebased tree, and merges only if they pass
- **Mid-development updates** — `update` applies the same rebase-and-test gate without merging
- **Context-aware abort/update/merge** — auto-detects the current worktree; shows a selection list when run from the main directory

## Requirements

- `git`
- `jq` — `brew install jq`

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

### Optional preferences

Create `~/.worktree-settings` to set persistent preferences:

```bash
# ~/.worktree-settings
OPEN_CLAUDE=true         # always open Claude Code after creating a worktree
OPEN_JETBRAINS_IDE=true  # always open JetBrains IDE after creating a worktree
WT_TEST_CMD='make test'  # test command for update and merge, in every project
```

These are also set automatically when you answer the post-create prompts.

## Key Concepts

**Worktree directory**: a sibling to the project root — `../<project-name>-worktrees/`
- Example: `../claude-code-worktrees/`

**Worktree path**: `<worktree-dir>/<slugified-name>`
- Example: `../claude-code-worktrees/user-authentication`

**Branch name**: `<slugified-name>`
- Example: `user-authentication`

**Slugification**: name joined with hyphens, lowercased, non-alphanumeric characters (except hyphens) stripped.

## Command Reference

### Creating

**`create [name...]`** (alias: `start`; default when no command given)

Create a new worktree and branch. Prompts interactively for a name if not provided on the command line.

- Validates that the name is unique before proceeding
- Optionally copies uncommitted changes into the new worktree
- Selects base branch automatically when only one exists; shows a numbered menu otherwise
- Optionally copies project MCP servers to the new worktree
- **cds into the new worktree on completion**

```bash
worktree create feat/user authentication  # directory: ../claude-code-worktrees/feat-user-authentication, branch: feat/user-authentication
worktree feat/user-authentication   # same — create is the default
worktree create  # fully interactive
worktree  # same — create is the default
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

**`update`** (alias: `rebase`)

Bring a worktree branch up to date: rebase it onto the main branch and run the project's [test gate](#test-gate) on the result. Does not merge.

- If run from inside a worktree, uses it automatically
- If run from the main directory, presents a selection list
- Rebases, then tests; a failure leaves the rebase in place so you can fix forward
- Leaves the worktree and branch alone — nothing is merged or removed

Run it whenever the main branch has moved. A branch cut before another branch landed can be green on its own and red once rebased, and updating regularly means that surfaces while its cause is still just the rebase.

```bash
worktree update
```

**`merge`**

Rebase a worktree branch onto the main branch, run the [test gate](#test-gate) on the rebased tree, and merge only if it passes — then clean up.

- If run from inside a worktree, uses it automatically
- If run from the main directory, presents a selection list
- Rebases first (a no-op when already current), aborts on conflicts
- Tests the rebased tree; on failure nothing is merged and nothing is removed
- Removes the worktree directory and deletes the branch on success
- **cds back to the main directory on completion**

```bash
worktree merge
```

**`cleanup`**

Find and remove worktree leftovers. Checks three things:

1. **Stale git registrations** — worktrees git tracks but whose directories no longer exist on disk. Offers to run `git worktree prune`.
2. **Merged worktrees** — registered worktrees whose branches are already merged into main (e.g. merged via a GitHub PR). Offers to remove the directory and delete the branch.
3. **Orphaned directories** — directories inside the worktree base folder (`../<project>-worktrees/`) that aren't registered with git. Offers to delete them.

Each item requires individual confirmation before removal. If run from inside a worktree that gets cleaned up, automatically cds to the main directory.

```bash
worktree cleanup
```

### Test gate

`update` and `merge` both run the project's tests on the rebased tree before doing anything irreversible.

This exists because the merge is a fast-forward, so the tree that lands on the main branch is the *post-rebase* tree — and nothing else tests that. Two branches can each be green alone and red once they share a tree, with no textual conflict for git to report. Git's own `pre-merge-commit` hook cannot cover it either: it only fires when a merge commit is created, and a fast-forward creates none.

The test command is resolved in this order:

1. `WT_TEST_CMD` in the environment or `~/.worktree-settings`
2. a `.worktree-test` file holding the command

A project with neither configured skips the tests and says so, so this is opt-in per project and changes nothing for projects that ignore it.

`.worktree-test` is read from the worktree being **tested**, not from the main one — it is part of the tree under test, so a branch that changes how the project is tested is honoured by its own gate. Commit it to the base branch so every worktree gets it.

```bash
# .worktree-test
./scripts/test.sh unit
```

The command runs from the worktree's own directory, via `bash`. It is trusted shell code, exactly like `~/.worktree-settings`, which is sourced.

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
worktree --step create my-feature
worktree --step abort
```

### Help and Info

**`-h` / `--help`** — Display command reference

**`--version` / `-v`** — Display the script version

## Tips

- `abort`, `update` and `merge` work from inside a worktree **or** from the main directory
- When creating a worktree, uncommitted changes are copied (not moved) — the original directory is left unchanged
- Project MCP servers (from `~/.claude.json`) can optionally be copied to the new worktree
