# Plan: commit-reviewer Skill

## Context

Add a new `/commit-reviewer` skill to this repo that runs as a separate Claude Code instance
(via `claude --dangerously-skip-permissions`), polls for new commits every 30 seconds, reviews
changed files against a project-level `REVIEW_CRITERIA.md`, auto-fixes issues, and pushes
corrections to a `review/auto` branch in a dedicated git worktree. Solo workflow — fixes land
on the review branch for selective cherry-pick back to main.

---

## Files to Create

```
commands/commit-reviewer/
├── SKILL.md
├── version.txt
└── commands/
    ├── start.md
    ├── stop.md
    └── version.md
```

`REVIEW_CRITERIA.md` lives at the **project root of whichever repo the skill runs against**,
not in this repo. The skill creates it on first `start` if absent.

---

## 1. `commands/commit-reviewer/version.txt`

```
1.0.0
```

---

## 2. `commands/commit-reviewer/SKILL.md`

```yaml
---
name: commit-reviewer
description: |
  Automated commit review loop. Watches a branch for new commits, applies fixes per
  REVIEW_CRITERIA.md, and pushes corrected commits to a dedicated review branch.
  Intended to run in a separate terminal: claude --dangerously-skip-permissions
  Triggers: "/commit-reviewer start", "/commit-reviewer stop", "/commit-reviewer version",
  "start commit review", "stop commit review", "start the reviewer", "stop the reviewer"
argument-hint: "[command] [args] — Commands: start [--interval <seconds>], stop, version"
allowed-tools: "Bash(git:*, sleep:*, rm:*, mkdir:*, touch:*, basename:*, realpath:*), Read, Write, Edit, Glob"
---

# Commit Reviewer Skill

Parse the first argument as the command name. Find the matching command file in
`commands/commit-reviewer/commands/<command>.md`, read it, and execute its steps exactly.

## Key Concepts

- **Project root**: `git rev-parse --show-toplevel`
- **Project name**: `basename` of project root
- **Watched branch**: branch active in main worktree when `start` is invoked
- **Review worktree**: `<project-root>/../<project-name>-review/` (sibling directory)
- **Review branch**: `review/auto`
- **State file**: `<project-root>/.claude/commit-reviewer-state.json`
- **Stop sentinel**: `<project-root>/.claude/commit-reviewer-stop`
- **Review criteria**: `<project-root>/REVIEW_CRITERIA.md`

## Commands

- `start [--interval <seconds>]` — Set up worktree and run the polling review loop (default: 30s)
- `stop` — Write the stop sentinel to halt a running loop
- `version` — Display the skill version
```

---

## 3. `commands/commit-reviewer/commands/version.md`

```markdown
# Command: version

## Usage
version

## Implementation

Read the version from `commands/commit-reviewer/version.txt` and output:

  Commit Reviewer v{version}
```

---

## 4. `commands/commit-reviewer/commands/stop.md`

```markdown
# Command: stop

## Usage
stop

Signal a running `commit-reviewer start` loop to halt by writing a sentinel file.
The loop checks for this at the top of each poll cycle and exits cleanly when found.

## Steps

1. Run `git rev-parse --show-toplevel` → `project_root`
2. Run `mkdir -p <project_root>/.claude`
3. Run `touch <project_root>/.claude/commit-reviewer-stop`
4. Output:
   ```
   Stop signal sent. The commit-reviewer loop will halt after its current poll cycle.
   Sentinel: <project_root>/.claude/commit-reviewer-stop
   ```
   Note: if no loop is currently running, the sentinel will be cleared automatically
   by the next `start` invocation.
```

---

## 5. `commands/commit-reviewer/commands/start.md`

```markdown
# Command: start

## Usage
start [--interval <seconds>]

Set up a review worktree and run an infinite polling loop that detects new commits,
applies fixes per REVIEW_CRITERIA.md, and pushes corrections to `review/auto`.

Designed to run in a dedicated terminal with `--dangerously-skip-permissions`.
Loops until `.claude/commit-reviewer-stop` is present.

---

## Phase 1: Parse Arguments and Get Project Info

1. Scan arguments for `--interval <N>`. If found, set `interval=N`. Otherwise `interval=30`.
2. Run `git rev-parse --show-toplevel` → `project_root`
3. Run `basename <project_root>` → `project_name`
4. Run `git rev-parse --abbrev-ref HEAD` → `watched_branch`
5. Resolve worktree path:
   `realpath --canonicalize-missing <project_root>/../<project_name>-review` → `worktree_path`
6. Derive:
   - `state_file`: `<project_root>/.claude/commit-reviewer-state.json`
   - `stop_sentinel`: `<project_root>/.claude/commit-reviewer-stop`
   - `review_branch`: `review/auto`
7. Run `mkdir -p <project_root>/.claude`
8. Run `rm -f <stop_sentinel>` (clear any stale sentinel from a previous run)

---

## Phase 2: Worktree and Branch Setup

9. Check if `review/auto` branch exists:
   `git show-ref --verify --quiet refs/heads/review/auto`
   - If exit code non-zero: run `git branch review/auto HEAD`

10. Check if worktree already exists:
    `git worktree list --porcelain | grep -F "worktree <worktree_path>"`
    - If NOT found: run `git worktree add <worktree_path> review/auto`
    - If found: skip (idempotent)

11. Verify the worktree is on `review/auto`:
    `git -C <worktree_path> rev-parse --abbrev-ref HEAD`
    - If not `review/auto`, output a warning but proceed.

---

## Phase 3: REVIEW_CRITERIA.md Check

12. Check if `<project_root>/REVIEW_CRITERIA.md` exists.
    - If NOT: create it with the template below and output:
      ```
      Created REVIEW_CRITERIA.md at project root with a default template.
      Edit it to add project-specific rules.
      ```
    - If found: proceed without modification.

**REVIEW_CRITERIA.md template:**

```markdown
# Review Criteria

This file defines automated review rules applied by the `commit-reviewer` skill.
Edit this file to match your project's conventions.

---

## Scope Constraint

**CRITICAL**: Only modify lines within files listed by `git diff`. Do not touch other
files, other functions, or sections of changed files not touched by the original commit.

---

## Formatting
- Remove trailing whitespace from all lines.
- Ensure files end with a single newline.
- Fix inconsistent indentation on lines touched by the commit (do not reformat the whole file).

## Correctness
- Fix obvious typos in string literals, comments, and documentation.
- Fix broken markdown (unclosed code fences, malformed links).
- Remove debug logging (`console.log`, `print`, `debugger`, etc.) left in non-test code.

## Code Quality (within changed lines only)
- Replace magic numbers with named constants only if the constant already exists in scope.
- Do not introduce new abstractions, refactors, or renames.

---

## Project-Specific Rules

<!-- Add project-specific rules here. Examples:
- Language/framework conventions
- Naming patterns
- Required file headers or license blocks
- Forbidden patterns
-->
```

---

## Phase 4: Initialize State

13. Run `git rev-parse HEAD` → `last_reviewed_hash`
    (Starting point — loop will look for commits AFTER this.)

14. Write `<state_file>` (full JSON overwrite):
    ```json
    {
      "version": "1.0.0",
      "watched_branch": "<watched_branch>",
      "review_branch": "review/auto",
      "worktree_path": "<worktree_path>",
      "interval": <interval>,
      "last_reviewed_hash": "<last_reviewed_hash>",
      "started_at": "<ISO 8601 UTC timestamp>",
      "loop_count": 0
    }
    ```

15. Output startup banner:
    ```
    Commit Reviewer v1.0.0 started.
    ─────────────────────────────────────────
    Watching branch : <watched_branch>
    Review branch   : review/auto
    Worktree        : <worktree_path>
    Poll interval   : <interval>s
    Starting hash   : <first 8 chars of last_reviewed_hash>
    Stop with       : /commit-reviewer stop  (from main session)
    ─────────────────────────────────────────
    Polling...
    ```

---

## Phase 5: Polling Loop

Repeat the following steps indefinitely.

### Step A — Check Stop Sentinel

- Test if `<stop_sentinel>` exists: `test -f <stop_sentinel>`
- If yes:
  - Output: `Stop sentinel detected. Shutting down.`
  - Run `rm -f <stop_sentinel>`
  - Output: `Commit reviewer stopped.`
  - **Exit the loop.**

### Step B — Check for New Commits

- Run `git -C <project_root> rev-parse <watched_branch>` → `current_hash`
- If `current_hash == last_reviewed_hash`:
  - Output: `[<HH:MM:SS>] No new commits. Sleeping <interval>s...`
  - Run `sleep <interval>`
  - Go to Step A.

### Step C — Identify Changed Files

- Run:
  `git -C <project_root> log <last_reviewed_hash>..<current_hash> --format="%h %s" --reverse`
  → `new_commits_summary`
- Run:
  `git -C <project_root> diff <last_reviewed_hash>..<current_hash> --name-only`
  → `changed_files` (newline-separated list)
- Output:
  ```
  [<HH:MM:SS>] New commits detected.
    Commits : <first line of new_commits_summary>[ ... and N more]
    Files   : <count> file(s) changed
  ```

### Step D — Update Worktree

- Run `git -C <worktree_path> rebase <current_hash>`
  - If exit code 0: proceed to Step E.
  - If non-zero (conflict):
    - Run `git -C <worktree_path> rebase --abort`
    - Run `git -C <worktree_path> merge <current_hash> --no-edit`
    - If merge also fails:
      - Run `git -C <worktree_path> merge --abort`
      - Output warning:
        ```
        [<HH:MM:SS>] WARNING: Could not update worktree to <current_hash>.
        Skipping this cycle. Manual fix may be needed at: <worktree_path>
        ```
      - Update `last_reviewed_hash` to `current_hash` in state file.
      - Run `sleep <interval>` and go to Step A.

### Step E — Review and Fix Changed Files

For each file path in `changed_files`:

1. Check `test -f <worktree_path>/<file>` — if absent (deleted), skip.
2. Read `<worktree_path>/<file>` content.
3. Read `<project_root>/REVIEW_CRITERIA.md`.
4. Apply fixes per criteria. **Only modify lines that correspond to the commit's diff hunks.**
   Do not touch surrounding code.
5. If fixes were made: write corrected content back to `<worktree_path>/<file>` using Edit.
6. If no fixes needed: skip (do not write unchanged content).

After all files: check for actual changes:
`git -C <worktree_path> status --porcelain`
- If output is empty: no fixes made → skip to Step G (no commit needed).

### Step F — Commit and Push Fixes

- Stage each modified file individually:
  `git -C <worktree_path> add <file>` for each file that was edited.
- Get commit message summary from original commits:
  `git -C <project_root> log <last_reviewed_hash>..<current_hash> --format="%s" | head -1`
  Truncate to 60 chars if needed. → `summary`
- Commit:
  `git -C <worktree_path> commit -m "review: <summary> [auto]"`
- Push (best-effort — do not halt loop on failure):
  `git -C <worktree_path> push origin review/auto`
  - If push fails: output `[<HH:MM:SS>] WARNING: Push failed. Continuing.`
- Output:
  ```
  [<HH:MM:SS>] Fix commit pushed: review: <summary> [auto]
    Fixed: <list of modified files>
  ```

### Step G — Update State and Sleep

- Update `last_reviewed_hash` to `current_hash`.
- Increment `loop_count` by 1.
- Write updated state file (full JSON overwrite).
- Run `sleep <interval>`
- Go to Step A.
```

---

## Touch SKILL.md

Per project convention, after creating the skill files, touch `commands/commit-reviewer/SKILL.md`
to ensure cache invalidation. Since SKILL.md is being created (not modified), the act of creation
is sufficient — no explicit `touch` needed.

---

## Verification

1. In a test repo with a remote:
   - Run `/commit-reviewer start` via `claude --dangerously-skip-permissions` in a terminal
   - Verify startup banner appears and `review/auto` worktree is created
   - Make a commit with a trailing whitespace issue or debug log
   - Wait up to 30 seconds
   - Verify `git log review/auto` shows a `review: ... [auto]` commit
   - Verify `git diff main..review/auto` shows only the fix changes
   - From the main session: run `/commit-reviewer stop`
   - Verify the loop outputs shutdown message and exits

2. Idempotency: run `/commit-reviewer start` twice — second invocation should not error on
   existing branch/worktree.

3. Missing `REVIEW_CRITERIA.md`: delete it and re-run `start` — verify template is created.
