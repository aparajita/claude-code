# Command: abort

**Usage**: `abort`

Removes the current worktree and deletes its branch without merging. Use when abandoning work.

## Steps

1. **Get current directory and worktree list**
   - Run `git worktree list --porcelain` to get all worktrees with their paths and branches
   - Parse the output to get a list of `{path, branch}` entries
   - The first entry is the main working tree

2. **Check we're in the main directory**
   - Get the current worktree root via `git rev-parse --show-toplevel`
   - Compare against the worktree list — if the current path does **not** match the main working tree, error out:
     ```
     Sorry, this command must be run from the main project directory, not from a worktree.
     Main project directory: <main-path>
     ```
   - Build a list of non-main worktrees from the parsed entries. If the list is empty, error out:
     ```
     No worktrees found to abort.
     ```

3. **Select a worktree**
   - If there are **3 or fewer non-main worktrees**, use `AskUserQuestion` with each worktree as an option (label: branch name, description: worktree path) plus a Cancel option. If the user selects Cancel, stop.
   - If there are **more than 3 non-main worktrees**, display a numbered list of worktrees (branch name and path for each) and ask the user to enter a number or "cancel". If the user cancels, stop.

4. **Get worktree details**
   - Worktree path: the selected worktree's path
   - Branch name: the selected worktree's branch (strip leading `refs/heads/` if present)

5. **Confirm with user**
   - Use AskUserQuestion to ask: "This will permanently delete the worktree and branch `<branch>`. Continue?"
   - Options: Yes (proceed), No (cancel)
   - If No, stop

6. **Remove the worktree**
   - Run `git worktree remove <worktree-path>` from the main project directory
   - If this fails (e.g., uncommitted changes), try `git worktree remove --force <worktree-path>`
   - If still fails, show the error and stop

7. **Delete the branch**
   - Run `git branch -D <branch-name>` (force delete since we're intentionally aborting)

8. **Confirm**
   - Display:
     ```
     Worktree aborted:
       Removed: <worktree-path>
       Deleted branch: <branch-name>
     ```
