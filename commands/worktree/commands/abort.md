# Command: abort

**Usage**: `abort`

Removes the current worktree and deletes its branch without merging. Use when abandoning work.

## Steps

1. **Get current directory and worktree list**
   - Run `git worktree list --porcelain` to get all worktrees with their paths and branches
   - Parse the output to get a list of `{path, branch}` entries
   - The first entry is the main working tree

2. **Check we're in a worktree**
   - Get the current working directory (via `git rev-parse --show-toplevel` to get the worktree root)
   - Compare against the worktree list — if the current path matches the main working tree, error out:
     ```
     Error: You are not in a worktree. Run this command from within a worktree directory.
     ```

3. **Get worktree details**
   - Worktree path: the matched path from the worktree list
   - Branch name: the matched branch (strip leading `refs/heads/` if present)
   - Main project directory: the first entry's path from `git worktree list`

4. **Confirm with user**
   - Use AskUserQuestion to ask: "This will permanently delete the worktree and branch `<branch>`. Continue?"
   - Options: Yes (proceed), No (cancel)
   - If No, stop

5. **Remove the worktree**
   - Run `git worktree remove <worktree-path>` from the main project directory
   - If this fails (e.g., uncommitted changes), try `git worktree remove --force <worktree-path>`
   - If still fails, show the error and stop

6. **Delete the branch**
   - Run `git branch -D <branch-name>` (force delete since we're intentionally aborting)

7. **Clean up empty worktree directory**
   - Get the worktree directory (parent of the worktree path)
   - Check if it's empty: `ls <worktree-dir>`
   - If empty, remove it: `rm -rf <worktree-dir>`

8. **Confirm**
   - Display:
     ```
     Worktree aborted:
       Removed: <worktree-path>
       Deleted branch: <branch-name>
     ```
   - Note: Since we removed the worktree, remind the user they are now back in the main project if they need to cd there.
