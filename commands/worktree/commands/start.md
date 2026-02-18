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
   - If `copy_changes` is true, run `git stash --include-untracked` then immediately `git stash apply` to restore the files in the original directory (the stash entry remains in the stash stack — `stash@{0}` — for the worktree to use in step 8)

5. **Create worktree directory** if it doesn't exist
   - Run `python3 -c 'import os,sys; os.makedirs(sys.argv[1], exist_ok=True)' <worktree-dir>`

6. **Ask what branch to base off**
   - Run `git branch` as a separate Bash call to get the list of all local branches
   - Parse the output: strip the leading `* ` marker and whitespace from each line to get a clean list of branch names
   - **If exactly 1 branch**: use it automatically as `base_branch` without asking — skip to step 7
   - **If 2–3 branches**: use `AskUserQuestion` with one option per branch (label: branch name; description: "current branch" if it matches the current branch, otherwise blank) plus a Cancel option. The built-in "Other" option lets the user type a custom branch name.
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
     To clean up the stash entry afterward: git stash drop
     ```

9. **Copy project MCP servers to worktree** (only if the source project has MCP servers configured)
   - Use the Read tool to read `~/.claude.json` and look up `projects.<project-dir>.mcpServers` (where `<project-dir>` is the absolute path from step 1)
   - If the `mcpServers` object is missing or empty, skip this step silently (set `mcp_copy_succeeded` to false)
   - Separate the servers into two groups:
     - **Always copy**: `serena` (always copied silently if present)
     - **Optional**: all other servers
   - If there are optional servers, present them using `AskUserQuestion` with `multiSelect: true`:
     - Question: "Which MCP servers should be copied to the new worktree?"
     - Options: one option per server name, with the server's `command` as the description (or `url` if it is an SSE server with no `command` field)
     - If the user selects "None", only the always-copy servers are included
   - Build the final server list: always-copy servers (e.g., `serena` if present) + any user-selected servers. If the final list is empty, skip the rest of this step silently (set `mcp_copy_succeeded` to false).
   - Derive the script path from the path of this command file: replace the last two path components (`commands/start.md`) with `scripts/copy-mcp-servers.py`
     - Example: if this file is `/home/user/.claude/commands/worktree/commands/start.md`, the script is `/home/user/.claude/commands/worktree/scripts/copy-mcp-servers.py`
   - Run the script to copy the MCP server config entries into `~/.claude.json` for the worktree project:
     `python3 <script-path> <project-dir> <worktree-path> <server1> [<server2> ...]`
   - This script copies the config from the source project's entry to the worktree's entry in `~/.claude.json` — it does not install any software
   - Store whether the script exited with code 0 as `mcp_copy_succeeded` (true/false)
   - If the script exits with a non-zero code, warn the user but continue (do not abort worktree creation)

10. **Open in JetBrains IDE** (only if `.idea` directory exists at `<project-dir>`)
   - Use the `Glob` tool with pattern `<project-dir>/.idea` to check for a JetBrains project (do NOT use a Bash test command)
   - If the Glob returns no match, skip this step
   - If `serena` was in the always-copy list and `mcp_copy_succeeded` is true: run `idea <worktree-path>` automatically (required for Serena to connect)
   - Otherwise (serena was not present, step 9 was skipped, or the script failed): use `AskUserQuestion` to ask "Open the worktree in the JetBrains IDE?" with options Yes / No. Only run `idea <worktree-path>` if the user selects Yes.
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
