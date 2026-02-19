# Command: merge

**Usage**: `merge`

Merges a worktree's branch into the main branch using a rebase-first strategy, then cleans up the worktree.

## Steps

1. **Get current directory and worktree list**
   - Run `git worktree list --porcelain` as a separate Bash call (do not chain with other commands) to get all worktrees
   - Parse the output to get `{path, branch}` entries
   - The first entry is the main working tree

2. **Check we're in the main directory**
   - Get the current worktree root via `git rev-parse --show-toplevel` as a separate Bash call (do not chain with other commands)
   - Compare against the worktree list — if the current path does **not** match the main working tree, error out:
     ```
     Sorry, this command must be run from the main project directory, not from a worktree.
     Main project directory: <main-path>
     ```
   - Build a list of non-main worktrees from the parsed entries. If the list is empty, error out:
     ```
     No worktrees found to merge.
     ```

3. **Select a worktree**
   - If there are **3 or fewer non-main worktrees**, use `AskUserQuestion` with each worktree as an option (label: branch name, description: worktree path) plus a Cancel option. If the user selects Cancel, stop.
   - If there are **more than 3 non-main worktrees**, display a numbered list of all worktrees (branch name and path for each), then use `AskUserQuestion` with a single "Cancel" option; instruct the user to select "Other" to type a worktree number or name. If the user cancels, stop.

4. **Get worktree details**
   - Worktree path: the selected worktree's path
   - Worktree branch: the selected worktree's branch (strip `refs/heads/` prefix if present). If the worktree is in detached HEAD state (no branch), error out: "Cannot merge a worktree in detached HEAD state."
   - Main project directory: first entry's path
   - Main branch: first entry's branch (strip `refs/heads/` prefix)

5. **Check for uncommitted changes**
   - Run `git -C <worktree-path> status --porcelain` to check the selected worktree
   - If there are uncommitted changes or untracked files, error out:
     ```
     Sorry, the worktree has uncommitted changes or untracked files. Commit, stash, or remove them before merging.
       Worktree: <worktree-path>
       Branch:   <worktree-branch>
     ```

6. **Verify main branch is checked out**
   - Run `git branch --show-current` as a separate Bash call (do not chain with other commands) from the main project directory
   - If the current branch is not `<main-branch>`, error out:
     ```
     Sorry, the main project directory is not on the expected branch.
       Expected: <main-branch>
       Actual:   <current-branch>
     Please check out <main-branch> and try again.
     ```

7. **Attempt fast-forward merge**
   - Run `git merge --ff-only <worktree-branch>` from the main project directory
   - If this succeeds, jump to step 10 (cleanup)

8. **Attempt rebase if ff-only failed**
   - Run `git -C <worktree-path> rebase <main-branch>` (rebase from within the worktree)
   - If rebase succeeds, retry from the main project directory: `git merge --ff-only <worktree-branch>`
   - If the retry succeeds, jump to step 10 (cleanup)

9. **Handle rebase conflicts**
   - If rebase fails with conflicts, abort the rebase: `git -C <worktree-path> rebase --abort`
   - Inform the user:
     ```
     Sorry, the rebase failed due to conflicts. Resolve conflicts in the worktree branch manually, then run merge again.
       Worktree: <worktree-path>
       Branch:   <worktree-branch>
     ```
   - Stop — do not force merge

10. **Cleanup**
    - Remove the worktree: `git worktree remove --force <worktree-path>`
    - If this fails, use python3 to remove the directory: `python3 -c "import shutil; shutil.rmtree('<worktree-path>')"`
    - Delete the branch: `git branch -d <worktree-branch>`

11. **Confirm**
    - Display:
      ```
      Worktree merged successfully:
        Merged: <worktree-branch> → <main-branch>
        Removed: <worktree-path>
        Deleted branch: <worktree-branch>
      ```
