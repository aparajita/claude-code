# Command: start

**Usage**: `start <type> <description words...>`

Creates a new git worktree with a branch following the naming conventions.

## Steps

1. **Get project info**
   - Run `git rev-parse --show-toplevel` to get the project directory (absolute path)
   - Extract the project name: `basename <project-dir>` (e.g., `claude-code`)

2. **Construct paths**
   - Worktree directory: `<project-dir>/../<project-name>-worktrees` (resolve to absolute path with `python3 -c 'import os,sys; print(os.path.abspath(os.path.expanduser(sys.argv[1])))' <path>`)
   - Slugify the description: join all description words with hyphens, lowercase, strip non-alphanumeric chars except hyphens
   - Branch name: `<type>/<slug>` (e.g., `feature/remove-update-mechanism`)
   - Worktree path: `<worktree-dir>/<type>-<slug>` (e.g., `../claude-code-worktrees/feature-remove-update-mechanism`)

3. **Validate**
   - If no type or description provided, show usage and stop
   - If a branch named `<type>/<slug>` already exists, error out

4. **Check for uncommitted changes**
   - Run `git status --porcelain` to detect any changes (staged, unstaged, or untracked)
   - If the output is non-empty, use `AskUserQuestion` to ask:
     "You have uncommitted changes. Copy them into the new worktree?"
   - Options: Yes (copy to worktree), No (leave them here only)
   - Store the user's answer as `copy_changes` (true/false)
   - If `copy_changes` is true, run `git stash --include-untracked` then immediately `git stash apply` to restore the files in the original directory (the stash remains in the reflog for the worktree to use)

5. **Create worktree directory** if it doesn't exist
   - Run `mkdir -p <worktree-dir>`

6. **Ask what branch to base off**
   - Use AskUserQuestion to ask: "What branch should this worktree be based on?"
   - Options: `main`, `master`, current branch (from `git branch --show-current`), Other
   - Default to `main` if it exists, otherwise `master`
   - If the user selects Other, prompt them to enter a branch name. If the branch does not exist, error out.

7. **Create the worktree and branch**
   - Run `git worktree add -b <branch-name> <worktree-path> <base-branch>`
   - If this fails:
     - If `copy_changes` is true, drop the stash: `git stash drop`
     - Show the error and stop

8. **Apply stash into worktree** (only if `copy_changes` is true)
   - Run `git -C <worktree-path> stash pop`
   - If this fails, warn the user:
     ```
     Warning: Could not apply changes to the worktree. Your changes are still in the stash.
     To apply manually: cd <worktree-path> && git stash pop
     ```

9. **Offer to install project MCP servers** (only if the source project has MCP servers configured)
   - Read `~/.claude.json` and look up `projects.<project-dir>.mcpServers` (where `<project-dir>` is the absolute path from step 1)
   - If the `mcpServers` object is missing or empty, skip this step silently
   - Otherwise, present the list of server names using `AskUserQuestion` with `multiSelect: true`:
     - Question: "Which MCP servers should be installed in the new worktree?"
     - Options: one option per server name (e.g., "serena", "4d-mcp"), with the server's command as the description
     - If the user selects "None", skip installation
   - For each selected server, collect its full config object from the source
   - Write the selected servers to `<worktree-path>/.claude/worktree-settings.json` under the key `mcpServers` (create the file and directory if needed; if the file already exists, merge into it)
   - Also write the selected servers into `~/.claude.json` under `projects.<worktree-path>.mcpServers` (merge into the existing project entry, or create one if needed)

10. **Confirm**
   - Display a summary:
     ```
     Worktree created:
       Path:   <worktree-path>
       Branch: <branch-name>
       Based on: <base-branch>

     To work in this worktree, cd to:
       <worktree-path>
     ```
