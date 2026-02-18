# Command: switch

**Usage**: `switch [partial-name]`

Switches to a different git worktree by presenting available worktrees to choose from.

## Steps

1. **Get worktree list**
   - Run `git worktree list --porcelain` to get all worktrees
   - Parse into `{path, branch}` entries
   - Exclude the current worktree (determined by `git rev-parse --show-toplevel`)

2. **Check available worktrees**
   - If no other worktrees exist (only the main), display:
     ```
     No other worktrees found. Use `/worktree start` to create one.
     ```
   - Stop

3. **Filter by partial name (if provided)**
   - If a partial name argument was given, filter the list to worktrees whose path or branch name contains the partial name (case-insensitive)
   - If filtering yields exactly one match, select it directly (skip to step 5)
   - If filtering yields no matches, show:
     ```
     No worktree matching "<partial-name>" found.
     ```
   - Then continue to step 4 to show all worktrees

4. **Ask user to select**
   - Use AskUserQuestion to present the list of available worktrees plus a Cancel option
   - Format each option as: `<branch-name> — <path>`
   - Question: "Which worktree do you want to switch to?"
   - If the user selects Cancel, stop

5. **Display switch instructions**
   - Since Claude Code cannot change the user's shell directory, display instructions:
     ```
     Switch to this worktree by running:
       cd <selected-worktree-path>

     Branch: <branch-name>
     ```

   Note: Do NOT attempt to `cd` using Bash — shell `cd` commands don't affect the user's terminal session. Just provide the path for the user to cd into.
