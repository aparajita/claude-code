# Command: merge

**Usage**: `merge`

Merges the current worktree's branch into the main project branch using a rebase-first strategy, then cleans up the worktree.

## Steps

1. **Get current directory and worktree list**
   - Run `git worktree list --porcelain` to get all worktrees
   - Parse the output to get `{path, branch}` entries
   - The first entry is the main working tree

2. **Check we're in the main directory**
   - Get the current worktree root via `git rev-parse --show-toplevel`
   - Compare against the worktree list — if the current path does **not** match the main working tree, error out:
     ```
     Sorry, this command must be run from the main project directory, not from a worktree.
     Main directory: <main-path>
     ```
   - Build a list of non-main worktrees from the parsed entries. If the list is empty, error out:
     ```
     No worktrees found to merge.
     ```

3. **Select a worktree**
   - If there are **3 or fewer** worktrees, use `AskUserQuestion` with each worktree as an option (label: branch name, description: worktree path) plus a Cancel option. If the user selects Cancel, stop.
   - If there are **more than 3** worktrees, display a numbered list of worktrees (branch name and path for each) and ask the user to enter a number or "cancel". If the user cancels, stop.

4. **Get worktree details**
   - Worktree path: the selected worktree's path
   - Worktree branch: the selected worktree's branch (strip `refs/heads/` prefix if present)
   - Main project directory: first entry's path
   - Main project branch: first entry's branch (strip `refs/heads/` prefix)

5. **Check for uncommitted changes**
   - Run `git -C <worktree-path> status --porcelain` to check the selected worktree
   - If there are uncommitted changes, error out:
     ```
     Sorry, the worktree has uncommitted changes. Commit or stash them before merging.
       Worktree: <worktree-path>
       Branch:   <worktree-branch>
     ```

6. **Attempt fast-forward merge**
   - All git operations run from the main project directory
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
     Sorry, the rebase failed due to conflicts. Resolve conflicts in the worktree branch manually, then run merge again.
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
