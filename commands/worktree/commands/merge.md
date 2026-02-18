# Command: merge

**Usage**: `merge`

Merges the current worktree's branch into the main project branch using a rebase-first strategy, then cleans up the worktree.

## Steps

1. **Get current directory and worktree list**
   - Run `git worktree list --porcelain` to get all worktrees
   - Parse the output to get `{path, branch}` entries
   - The first entry is the main working tree

2. **Check we're in a worktree**
   - Get the current worktree root via `git rev-parse --show-toplevel`
   - Compare against the worktree list — if current path matches the main working tree, error out:
     ```
     Error: You are not in a worktree. Run this command from within a worktree directory.
     ```

3. **Get worktree details**
   - Worktree path: the matched path
   - Worktree branch: the matched branch (strip `refs/heads/` prefix if present)
   - Main project directory: first entry's path
   - Main project branch: first entry's branch (strip `refs/heads/` prefix)

4. **Check for uncommitted changes**
   - Run `git status --porcelain` in the current worktree
   - If there are uncommitted changes, error out:
     ```
     Error: You have uncommitted changes. Commit or stash them before merging.
     ```

5. **Move to main project directory**
   - All subsequent git operations run from the main project directory

6. **Attempt fast-forward merge**
   - Run `git merge --ff-only <worktree-branch>`
   - If this succeeds, jump to step 9 (cleanup)

7. **Attempt rebase if ff-only failed**
   - Run `git rebase <main-branch> <worktree-branch>`
   - If rebase succeeds, retry: `git merge --ff-only <worktree-branch>`
   - If the retry succeeds, jump to step 9 (cleanup)

8. **Handle rebase conflicts**
   - If rebase fails with conflicts, abort the rebase: `git rebase --abort`
   - Inform the user:
     ```
     Error: Rebase failed due to conflicts. Resolve conflicts in the worktree branch manually, then run merge again.
       Worktree: <worktree-path>
       Branch:   <worktree-branch>
     ```
   - Stop — do not force merge

9. **Cleanup**
   - Remove the worktree: `git worktree remove <worktree-path>`
   - Delete the branch: `git branch -d <worktree-branch>`
   - Check if the worktree directory is now empty: `ls <worktree-dir>`
   - If empty, remove it: `rm -rf <worktree-dir>`

10. **Confirm**
    - Display:
      ```
      Worktree merged successfully:
        Merged: <worktree-branch> → <main-branch>
        Removed: <worktree-path>
        Deleted branch: <worktree-branch>
      ```
