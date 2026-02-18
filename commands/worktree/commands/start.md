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

4. **Create worktree directory** if it doesn't exist
   - Run `mkdir -p <worktree-dir>`

5. **Ask what branch to base off**
   - Use AskUserQuestion to ask: "What branch should this worktree be based on?"
   - Options: `main`, `master`, current branch (from `git branch --show-current`), Other
   - Default to `main` if it exists, otherwise `master`

6. **Create the worktree and branch**
   - Run `git worktree add -b <branch-name> <worktree-path> <base-branch>`
   - If this fails, show the error and stop

7. **Confirm**
   - Display a summary:
     ```
     Worktree created:
       Path:   <worktree-path>
       Branch: <branch-name>
       Based on: <base-branch>

     To work in this worktree, cd to:
       <worktree-path>
     ```
