# Command: list

**Usage**: `list`

Shows all git worktrees with their paths and branches.

## Steps

1. **Get worktree list**
   - Run `git worktree list --porcelain` to get detailed worktree info
   - Parse the output into entries of `{path, head, branch, bare, locked, prunable}`

2. **Get current worktree**
   - Run `git rev-parse --show-toplevel` to find which worktree the user is currently in

3. **Format and display output**

   Display a formatted list. The main working tree is listed first and labeled. Mark the currently active worktree with `*`.

   Format:
   ```
   Git Worktrees:

   * [main]  /path/to/project                    (main)
     [work]  /path/to/project-worktrees/proj-...  (feature/my-feature)
   ```

   - `*` marks the currently active worktree
   - `[main]` label for the main working tree, `[work]` for others
   - Show the full path and branch name
   - If a worktree has no branch (detached HEAD), show the short commit hash instead
   - If a worktree is locked, add `[locked]` after the branch name

4. **If only one worktree (the main)**
   - Display: `No worktrees found. Use \`/worktree start\` to create one.`
