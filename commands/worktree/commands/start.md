# Command: start

**Usage**: `start <type> <description words...>`

Creates a new git worktree with a branch following the naming conventions.

## Steps

1. **Get project info**
   - Run `git rev-parse --show-toplevel` as a separate Bash call (do not chain with other commands) to get the project directory (absolute path)
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
   - Run `python3 -c 'import os,sys; os.makedirs(sys.argv[1], exist_ok=True)' <worktree-dir>`

6. **Ask what branch to base off**
   - Run `git branch` as a separate Bash call to get the list of all local branches
   - Parse the output: strip the leading `* ` marker and whitespace from each line to get a clean list of branch names
   - **If exactly 1 branch**: use it automatically as `base_branch` without asking — skip to step 7
   - **If 2–3 branches**: use `AskUserQuestion` with one option per branch (label: branch name; description: "current branch" if it matches the current branch, otherwise blank). The built-in "Other" option lets the user type a custom branch name.
   - **If more than 3 branches**: display a numbered list of all branches, then use `AskUserQuestion` with a single "Cancel" option; instruct the user to select "Other" to type a branch number or name
   - After the user responds:
     - If they typed a number, look up the corresponding branch from the list
     - Otherwise treat the value as a branch name
     - Validate: if the branch is not in the local list, error out with "Branch not found: <name>"
   - If the user cancels, stop

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

9. **Install project MCP servers** (only if the source project has MCP servers configured)
   - Use the Read tool to read `~/.claude.json` and look up `projects.<project-dir>.mcpServers` (where `<project-dir>` is the absolute path from step 1)
   - If the `mcpServers` object is missing or empty, skip this step silently
   - Separate the servers into two groups:
     - **Auto-install**: `serena` (always installed silently if present)
     - **Optional**: all other servers
   - If there are optional servers, present them using `AskUserQuestion` with `multiSelect: true`:
     - Question: "Which MCP servers should be installed in the new worktree?"
     - Options: one option per server name, with the server's command as the description
     - If the user selects "None", only the auto-install servers are installed
   - Collect the final list: auto-install servers + any user-selected servers
   - Run the install script with all servers to install:
     `python3 <skill-dir>/scripts/install-mcp-servers.py <project-dir> <worktree-path> <server1> [<server2> ...]`
   - Where `<skill-dir>` is the directory containing this command file's parent (i.e., the `commands/worktree/` directory)

10. **Open in JetBrains IDE** (only if `.idea` directory exists at `<project-dir>`)
   - Use the `Glob` tool with pattern `<project-dir>/.idea` to check for a JetBrains project (do NOT use a Bash test command)
   - If the Glob returns no match, skip this step
   - If Serena was installed in step 9: run `idea <worktree-path>` automatically (required for Serena to connect)
   - If Serena was NOT installed: use `AskUserQuestion` to ask "Open the worktree in the JetBrains IDE?" with options Yes / No. Only run `idea <worktree-path>` if the user selects Yes.
   - If the `idea` command is not found, warn the user but continue

11. **Confirm**
   - Display a summary:
     ```
     Worktree created:
       Path:   <worktree-path>
       Branch: <branch-name>
       Based on: <base-branch>

     To work in this worktree, cd to:
       <worktree-path>
     ```
