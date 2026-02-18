# Command: start

**Usage**: `start <type> <description words...>`

Creates a new git worktree with a branch following the naming conventions.

## Steps

1. **Get project info**
   - Run `git rev-parse --show-toplevel` to get the project directory (absolute path)
   - Extract the project name: `basename <project-dir>` (e.g., `claude-code`)

2. **Construct paths**
   - Worktree directory: `<project-dir>/../<project-name>-worktrees` (resolve to absolute path with `realpath --canonicalize-missing`)
   - Slugify the description: join all description words with hyphens, lowercase, strip non-alphanumeric chars except hyphens
   - Branch name: `<type>/<slug>` (e.g., `feature/remove-update-mechanism`)
   - Worktree path: `<worktree-dir>/<type>-<slug>` (e.g., `../claude-code-worktrees/feature-remove-update-mechanism`)

3. **Validate**
   - If no type or description provided, show usage and stop
   - If a branch named `<type>/<slug>` already exists, error out

4. **Check for uncommitted changes**
   - Run `git status --porcelain` to detect staged and untracked files
   - If there are any staged files (lines starting with `A`, `M`, `D`, `R`, `C`) or untracked files (lines starting with `??`), use `AskUserQuestion` to ask:
     "You have uncommitted changes. Move them into the new worktree?"
   - Options: Yes (stash and restore in worktree), No (leave them here)
   - Store the user's answer as `stash_changes` (true/false)
   - If `stash_changes` is true, run `git stash --include-untracked` and capture the stash ref (e.g., `stash@{0}`)

5. **Create worktree directory** if it doesn't exist
   - Run `mkdir -p <worktree-dir>`

6. **Ask what branch to base off**
   - Use AskUserQuestion to ask: "What branch should this worktree be based on?"
   - Options: `main`, `master`, current branch (from `git branch --show-current`), Other
   - Default to `main` if it exists, otherwise `master`

7. **Create the worktree and branch**
   - Run `git worktree add -b <branch-name> <worktree-path> <base-branch>`
   - If this fails:
     - If `stash_changes` is true, restore the stash to the main project: `git stash pop`
     - Show the error and stop

8. **Restore stash into worktree** (only if `stash_changes` is true)
   - Run `git -C <worktree-path> stash pop`
   - If this fails, warn the user:
     ```
     Warning: Could not apply stashed changes to the worktree. Your changes are still in the stash.
     To apply manually: cd <worktree-path> && git stash pop
     ```

9. **Confirm**
   - Display a summary:
     ```
     Worktree created:
       Path:   <worktree-path>
       Branch: <branch-name>
       Based on: <base-branch>

     To work in this worktree, cd to:
       <worktree-path>
     ```
