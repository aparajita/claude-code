# Plan Manager — Maintain master plan integrity with linked sub-plans

---
name: plan-manager
description: Manage hierarchical plans with linked sub-plans. Use when the user wants to initialize a master plan, branch into a sub-plan, capture an existing tangential plan, mark sub-plans complete, check plan status, audit for orphaned plans, get an overview of all plans, organize/link related plans together, or rename plans to meaningful names. Responds to "/plan-manager" commands and natural language like "capture that plan", "link this to the master plan", "branch from phase 3", "show plan status", "audit the plans", "overview of plans", "what plans do we have", "organize my plans", or "rename that plan".
argument-hint: <command> [args] — Commands: init, branch, capture, complete, status, audit, overview, organize, rename, switch, list-masters
allowed-tools: Bash(git:*), Read, Glob, Write, Edit, AskUserQuestion
model: sonnet
---

## Overview

This skill maintains a single source of truth (master plan) while allowing sub-plans to branch off for handling issues discovered during execution. All sub-plans are bidirectionally linked to the master plan.

## Interaction Guidelines

**Always use the AskUserQuestion tool** for any multiple-choice decisions. Each option must include:
- A concise label (1-5 words)
- A description explaining what that choice does

This provides a consistent, user-friendly interface for all plan management decisions.

## Plans Directory Detection

**Before executing any command**, determine the plans directory by checking sources in priority order:

1. **Check `.claude/settings.local.json`**:
   - If file exists, read `plansDirectory` field
   - This is the local override (gitignored, machine-specific)
   - Takes precedence over settings.json

2. **Check `.claude/settings.json`**:
   - If file exists, read `plansDirectory` field
   - This is the project's shared configuration
   - Example: `{"plansDirectory": "docs/plans"}`
   - **Important**: This is where plan mode stores plans when configured

3. **Check state file** (`.claude/plan-manager-state.json`):
   - If exists, read `plansDirectory` field
   - This was stored from previous initialization

3. **Auto-detect from common locations**:
   - Check these directories in order:
     - `plans/` (most common)
     - `docs/plans/`
     - `.plans/`
   - Use the first directory that exists and contains `.md` files

4. **If no directory found**:
   - For `overview` and `organize`: Ask user via **AskUserQuestion**:
     ```
     Question: "Where are your plans stored?"
     Header: "Plans directory"
     Options:
       - Label: "plans/"
         Description: "Standard plans directory in project root"
       - Label: "docs/plans/"
         Description: "Plans in documentation folder"
       - Label: "Custom path"
         Description: "Enter a custom directory path"
     ```
   - For other commands: Error with message "No plans directory found. Run `/plan-manager overview` first to set up."

5. **Persist in state**:
   - When state file is created (via `init`), store the detected or specified `plansDirectory`
   - Users can override by setting `plansDirectory` in `.claude/settings.json`

## State File

State is stored in the project's `.claude/plan-manager-state.json`:

```json
{
  "plansDirectory": "plans",
  "masterPlans": [
    {
      "path": "plans/layout-engine.md",
      "active": true,
      "created": "2026-01-30",
      "description": "UI layout system redesign"
    },
    {
      "path": "plans/auth-migration.md",
      "active": false,
      "created": "2026-01-29",
      "description": "Migration to OAuth 2.0"
    }
  ],
  "subPlans": [
    {
      "path": "plans/sub-plan-1.md",
      "parentPlan": "plans/layout-engine.md",
      "parentPhase": 3,
      "status": "in_progress",
      "createdAt": "2026-01-30"
    }
  ]
}
```

**Multiple master plans** are supported for projects with parallel initiatives. Commands operate on the "active" master plan by default, but can target specific masters.

This keeps tooling metadata separate from actual plan files.

The `plansDirectory` can be configured per-project. Common locations:
- `plans/` (default)
- `docs/plans/`
- `.plans/`

If the state file doesn't exist, the `overview` command can still scan for plans; other commands will prompt to run `init` first.

## Commands

### `init <path> [--description "text"]`

Initialize or add a master plan to tracking.

1. **Detect plans directory** (see Plans Directory Detection above)
2. Validate the file exists and is a markdown file
3. Check if state file exists:
   - **First master plan**: Create `.claude/plan-manager-state.json` (create `.claude/` directory if needed), mark as active
   - **Additional master plan**: Add to `masterPlans` array
3. If multiple masters exist, ask via **AskUserQuestion**:

```
Question: "You have multiple master plans. Make this the active one?"
Header: "Active master"
Options:
  - Label: "Yes, switch to this"
    Description: "Make this the active master plan for commands"
  - Label: "No, keep current"
    Description: "Add to tracking but keep current master active"
```

4. Extract or ask for a brief description to identify this master plan
5. If the master plan doesn't have a Status Dashboard section, offer to add one:

```markdown
## Status Dashboard

| Phase | Status | Sub-plans |
|-------|--------|-----------|
| 1     | pending | — |
| 2     | pending | — |
...
```

6. Confirm initialization: `✓ Added master plan: {path} (active)` or `✓ Added master plan: {path}`

### `switch <master-plan>`

Switch the active master plan.

1. Read state file to get list of master plans
2. If argument provided, find matching master plan (by path or fuzzy match)
3. If no argument, use **AskUserQuestion** to select:

```
Question: "Which master plan should be active?"
Header: "Switch master"
Options:
  - Label: "layout-engine.md"
    Description: "UI layout system redesign (3/5 phases complete)"
  - Label: "auth-migration.md"
    Description: "Migration to OAuth 2.0 (1/3 phases complete)"
```

4. Update state file to mark selected master as active (others as inactive)
5. Confirm: `✓ Switched to master plan: {path}`

### `list-masters`

Show all master plans being tracked.

1. Read state file
2. Display list with status:

```
Master Plans:

● plans/layout-engine.md (ACTIVE)
  UI layout system redesign
  Status: 3/5 phases complete
  Sub-plans: 4 (2 in progress, 2 completed)

○ plans/auth-migration.md
  Migration to OAuth 2.0
  Status: 1/3 phases complete
  Sub-plans: 1 (1 in progress)
```

### `branch <phase> [--master <path>]`

Proactively create a sub-plan when you see a problem coming.

1. Read the state file to get master plan path (use active master, or specified via --master)
2. Read the master plan to verify the phase exists
3. Ask the user for a brief description of the sub-plan topic
4. **Update the master plan FIRST**:
   - Update the Status Dashboard: change phase status to `🔀 Branching`
   - Add sub-plan reference to the phase section
5. Create the sub-plan file with header:

```markdown
# Sub-plan: {description}

**Parent:** {master-plan-path} → Phase {N}
**Created:** {date}
**Status:** In Progress

---

## Context

{Brief description of the issue/topic that led to this branch}

## Plan

{To be filled in}
```

6. Update state file with new sub-plan entry
7. Confirm: `✓ Created sub-plan: {path} (branched from Phase {N})`

### `capture [file] [--phase N] [--master <path>]`

Retroactively link an existing plan that was created during tangential discussion.

**Context-aware mode** (no file specified):
1. Look at recent conversation context to identify the plan file that was just created
2. If multiple candidates or none found, ask the user which file to capture
3. Proceed to linking

**Explicit mode** (file specified):
1. Validate the file exists

**For both modes:**
1. If `--phase N` not provided, ask which phase this relates to
2. Read the state file to get master plan path (use active master, or specified via --master)
3. **Add parent reference to the sub-plan** (prepend if not present):

```markdown
**Parent:** {master-plan-path} → Phase {N}
**Captured:** {date}
**Status:** In Progress

---

{original content}
```

4. **Update the master plan**:
   - Update Status Dashboard: add sub-plan reference to the phase
   - Update the phase section with link to sub-plan
5. Update state file
6. Confirm: `✓ Captured {file} → linked to Phase {N}`

### `complete <file-or-phase>`

Mark a sub-plan as complete and sync status to master.

1. If argument is a number, find sub-plan for that phase; otherwise use as file path
2. Read the sub-plan and update its status header to `Completed`
3. Read and update the master plan:
   - Update Status Dashboard: change sub-plan status indicator
   - Optionally update phase status based on whether work is done
4. Update state file
5. Use **AskUserQuestion tool** to determine phase status:
   ```
   Question: "Sub-plan completed. What's the status of Phase {N}?"
   Header: "Phase status"
   Options:
     - Label: "Phase complete"
       Description: "All work for Phase {N} is done, mark it ✅ Complete"
     - Label: "Still in progress"
       Description: "More work remains on Phase {N}, keep it 🔄 In Progress"
     - Label: "Blocked"
       Description: "Phase {N} is waiting on something else, mark it ⏸️ Blocked"
   ```
6. Confirm: `✓ Completed sub-plan: {path}`

### `status [--all]`

Display the full plan hierarchy and status.

**Default (active master only):**
1. Read state file to get active master plan
2. Read master plan to extract Status Dashboard
3. For each sub-plan linked to this master, read its status
4. Display formatted output:

```
Master Plan: plans/layout-engine.md (ACTIVE)
UI layout system redesign

Phase 1: ✅ Complete
Phase 2: 🔄 In Progress
  └─ plans/layout-fix.md (In Progress)
Phase 3: ⏸️ Blocked
  └─ plans/api-redesign.md (Completed)
Phase 4: ⏳ Pending

Sub-plans: 2 total (1 in progress, 1 completed)
```

**With --all flag:**
Show status for all master plans:

```
Master Plans: 2

● plans/layout-engine.md (ACTIVE)
  UI layout system redesign

  Phase 1: ✅ Complete
  Phase 2: 🔄 In Progress
    └─ plans/layout-fix.md (In Progress)
  ...
  Sub-plans: 2 total (1 in progress, 1 completed)

○ plans/auth-migration.md
  Migration to OAuth 2.0

  Phase 1: ✅ Complete
  Phase 2: 🔄 In Progress
  ...
  Sub-plans: 1 total (1 in progress)
```

### `audit`

Find orphaned phases, broken links, and stale items.

1. Read state file and master plan
2. Check for issues:
   - **Orphaned sub-plans**: Files in `plans/` that look like sub-plans but aren't in state
   - **Broken links**: Sub-plans in state that no longer exist
   - **Stale phases**: Phases marked "in progress" with no recent activity
   - **Missing back-references**: Sub-plans without proper parent header
   - **Dashboard drift**: Status Dashboard doesn't match actual state
3. Report findings:

```
Audit Results:

⚠️  Orphaned sub-plan: plans/old-idea.md (not linked to master)
⚠️  Broken link: plans/deleted.md (in state but file missing)
⚠️  Missing back-reference: plans/tangent.md (no Parent header)
✓  No stale phases detected

Recommendations:
- Run `/plan-manager capture plans/old-idea.md` to link orphan
- Run `/plan-manager cleanup` to remove broken links
```

### `overview [directory]`

Discover and visualize all plans in the project, regardless of whether they're tracked in state.

**This command works even without initialization** — useful for understanding an existing project's plans.

1. **Determine plans directory**:
   - If `directory` argument provided: use that path
   - Otherwise: use **Plans Directory Detection** (see above)
   - This establishes which directory to scan

2. **Scan all markdown files** in the directory:
   - Read each `.md` file
   - Classify each file by analyzing its content:

   | Classification | Detection Criteria |
   |----------------|-------------------|
   | **Master Plan** | Has phases (## Phase N), may have Status Dashboard |
   | **Sub-plan (linked)** | Has `**Parent:**` header pointing to a master |
   | **Sub-plan (orphaned)** | Looks like a sub-plan but no Parent reference or parent doesn't exist |
   | **Standalone Plan** | Has plan structure but no phase hierarchy |
   | **Completed** | Has `**Status:** Completed` or all phases marked ✅ |
   | **Abandoned** | Old modification date, marked as abandoned, or superseded |
   | **Reference Doc** | Not a plan — just documentation |

3. **Build relationship graph**:
   - Map parent → children relationships
   - Identify which sub-plans link to which master plans
   - Detect circular references or broken links

4. **Display ASCII hierarchy chart**:

```
Plans Overview: plans/
═══════════════════════════════════════════════════════════

ACTIVE HIERARCHIES
──────────────────

📋 layout-engine.md (Master Plan)
│   Status: 3/5 phases complete
│
├── Phase 1: ✅ Complete
├── Phase 2: 🔄 In Progress
│   └── 📄 grid-rethink.md (In Progress)
│       └── 📄 grid-edge-cases.md (In Progress)
├── Phase 3: ⏸️ Blocked
│   └── 📄 api-redesign.md (Completed)
├── Phase 4: ⏳ Pending
└── Phase 5: ⏳ Pending

📋 auth-migration.md (Master Plan)
│   Status: 1/3 phases complete
│
├── Phase 1: ✅ Complete
├── Phase 2: 🔄 In Progress
└── Phase 3: ⏳ Pending


STANDALONE PLANS
────────────────

📄 quick-fix-notes.md — No phases, appears to be notes
📄 performance-ideas.md — Standalone plan, not linked


ORPHANED / UNLINKED
───────────────────

⚠️  old-layout-approach.md
    Claims parent: layout-engine.md → Phase 2
    But not referenced in parent's Status Dashboard

⚠️  experimental-cache.md
    No parent reference, looks like abandoned sub-plan
    Last modified: 45 days ago


COMPLETED (not linked to active work)
─────────────────────────────────────

✅ v1-migration.md — Completed master plan (all phases done)
✅ hotfix-auth.md — Completed, parent plan also complete


SUMMARY
───────

Total plans: 11
├── Master plans: 3 (2 active, 1 completed)
├── Linked sub-plans: 4
├── Standalone: 2
└── Orphaned/Unlinked: 2

```

5. **Interactive cleanup for orphaned/completed**:

If orphaned or unlinked completed plans are found, use the **AskUserQuestion tool** with descriptive options:

```
Question: "Found 2 orphaned plans and 1 completed plan. How would you like to handle them?"
Header: "Cleanup"
Options:
  - Label: "Organize all"
    Description: "Analyze content, suggest links for related plans, then handle completed/orphaned"
  - Label: "Review individually"
    Description: "I'll show a summary of each plan and ask what to do with it one by one"
  - Label: "Archive completed"
    Description: "Move completed unlinked plans to plans/archive/ with datestamp prefix"
  - Label: "Leave as-is"
    Description: "Just show the report, don't take any action"
```

Based on selection:
- **Organize all**: Switch to the `organize` workflow — analyze relationships, suggest links, then cleanup
- **Review individually**: For each orphan, show content summary and use AskUserQuestion again: Link to phase? Archive? Delete? Skip?
- **Archive**: Move completed unlinked plans to `plans/archive/` with datestamp
- **Leave as-is**: Just report, no action

6. **Output state suggestion**:

If no state file exists but master plans were detected:

```
💡 Tip: Run `/plan-manager init plans/layout-engine.md` to start tracking this plan hierarchy.
```

### `organize [directory]`

Automatically analyze and link related plans together, rename poorly-named files, then handle orphaned/completed plans.

**This is the "just fix it" command** — it does everything `overview` does, plus actively organizes.

1. **Run full overview scan** (same as `overview` steps 1-4)

2. **Detect and offer to rename randomly-named plans**:
   - Scan for files with random/meaningless names (see `rename` command for patterns)
   - If found, use **AskUserQuestion tool**:

```
Question: "Found 2 plans with random names. Rename them to something meaningful?"
Header: "Rename"
Options:
  - Label: "Review suggestions"
    Description: "I'll suggest names based on content, you approve each one"
  - Label: "Rename all"
    Description: "Accept all my naming suggestions"
  - Label: "Skip renaming"
    Description: "Keep current names, move on to linking"
```

   - For each rename, suggest meaningful names based on content analysis

3. **Analyze relationships between unlinked plans**:
   - For each standalone or orphaned plan, analyze its content
   - Look for references to phases, topics, or keywords that match master plan phases
   - Build a list of suggested linkages

4. **Present linking suggestions** via AskUserQuestion:

```
Question: "I found 3 plans that appear related to your master plan. Review my suggestions?"
Header: "Auto-link"
Options:
  - Label: "Review suggestions"
    Description: "I'll show each suggestion and you can approve or reject"
  - Label: "Link all"
    Description: "Accept all my linking suggestions without review"
  - Label: "Skip linking"
    Description: "Don't link anything, move on to cleanup"
```

5. **If "Review suggestions" selected**, for each suggested link use AskUserQuestion:

```
Question: "performance-notes.md mentions 'caching' and 'render optimization'. Link to Phase 4 (Performance)?"
Header: "Link suggestion"
Options:
  - Label: "Yes, link it"
    Description: "Add parent reference and update master plan"
  - Label: "Different phase"
    Description: "Link to a different phase instead"
  - Label: "Skip this one"
    Description: "Don't link this plan"
  - Label: "It's not a sub-plan"
    Description: "This is standalone documentation, not a sub-plan"
```

6. **After linking, handle orphaned/completed plans** (same as `overview` step 5):
   - Ask what to do with remaining orphans
   - Ask what to do with completed unlinked plans

7. **Summary output**:

```
Organization Complete
─────────────────────

✓ Renamed 2 plans:
  • lexical-puzzling-emerson.md → grid-edge-cases.md
  • abstract-floating-jenkins.md → performance-notes.md

✓ Linked 2 plans to master:
  • performance-notes.md → Phase 4
  • grid-edge-cases.md → Phase 2

✓ Archived 1 completed plan:
  • hotfix-login.md → plans/archive/2026-01-30-hotfix-login.md

⚠️ 1 plan left unlinked (user skipped):
  • random-ideas.md

Current state:
├── Master plans: 1 active
├── Linked sub-plans: 5
└── Unlinked: 1
```

### `rename <file> [new-name]`

Rename a plan file and update all references to it.

**With new name provided:**
```
/plan-manager rename plans/lexical-puzzling-emerson.md layout-grid-fixes.md
```

1. Validate the source file exists
2. Rename the file to the new name
3. Find and update all references:
   - Master plan Status Dashboard links
   - Master plan phase section links
   - Other sub-plans that reference this file
   - State file entries
4. Update the plan's own header if it has a title
5. Confirm: `✓ Renamed lexical-puzzling-emerson.md → layout-grid-fixes.md (updated 3 references)`

**Without new name (suggest mode):**
```
/plan-manager rename plans/lexical-puzzling-emerson.md
```

1. Read the plan content
2. Analyze the content to understand what it's about
3. Generate a meaningful, descriptive filename based on:
   - The plan's title/heading
   - Key topics and keywords
   - Parent phase context (if linked)
4. Use **AskUserQuestion tool** to confirm:

```
Question: "Suggest a new name for lexical-puzzling-emerson.md?"
Header: "Rename"
Options:
  - Label: "layout-grid-edge-cases.md"
    Description: "Based on content about grid layout edge case handling"
  - Label: "phase2-grid-fixes.md"
    Description: "Includes parent phase reference (Phase 2)"
  - Label: "Enter custom name"
    Description: "Type your own filename"
  - Label: "Keep current name"
    Description: "Don't rename this file"
```

5. If confirmed, proceed with rename and reference updates

**Detecting random/meaningless names:**

Names are considered "random" if they match patterns like:
- `{adjective}-{adjective}-{noun}.md` (e.g., lexical-puzzling-emerson.md)
- `{word}-{word}-{word}.md` with no semantic connection to content
- UUID-style names
- Generic names like `plan-1.md`, `new-plan.md`, `untitled.md`

## Master Plan Conventions

### Status Dashboard Format

The Status Dashboard should be near the top of the master plan:

```markdown
## Status Dashboard

| Phase | Status | Sub-plans |
|-------|--------|-----------|
| 1     | ✅ Complete | — |
| 2     | 🔄 In Progress | [layout-fix.md](./layout-fix.md) |
| 3     | 🔀 Branching | [api-redesign.md](./api-redesign.md) |
| 4     | ⏸️ Blocked by 3 | — |
| 5     | ⏳ Pending | — |
```

### Status Icons

- ⏳ Pending — Not started
- 🔄 In Progress — Active work
- 🔀 Branching — Sub-plan created, diverging
- ⏸️ Blocked — Waiting on another phase or sub-plan
- ✅ Complete — Done

### Phase Section Format

Each phase section should have a sub-plans subsection when applicable:

```markdown
## Phase 3: Layout Engine

### Status: In Progress

### Sub-plans
- [layout-fix.md](./layout-fix.md) — Addressing edge case in grid layout

### Tasks
1. Implement base layout algorithm
2. Add responsive breakpoints
...
```

## Multiple Master Plans

For projects with multiple parallel initiatives, you can track multiple master plans:

- Each master plan has its own phases and sub-plans
- One master plan is marked as "active" at a time
- Commands operate on the active master by default
- Use `--master <path>` flag to target a specific master
- Use `/plan-manager switch` to change the active master
- Use `/plan-manager list-masters` to see all tracked masters
- Use `/plan-manager status --all` to see all hierarchies

**Common scenarios:**
- Large refactoring + bug fix initiative running in parallel
- Frontend redesign + backend API migration
- Multiple team members working on different features
- Different Claude Code sessions for different parts of the project

## Natural Language Triggers

This skill responds to:
- "/plan-manager {command}"
- "use /plan-manager to capture..."
- "capture that plan" / "capture the plan you just created"
- "link this to the master plan" / "link this back to phase 3"
- "branch from phase 3" / "we need to branch here"
- "show plan status" / "what's the plan status"
- "audit the plans" / "check for orphaned plans"
- "overview of plans" / "what plans do we have" / "show me all plans"
- "scan the plans directory" / "discover plans"
- "organize my plans" / "organize the plans" / "link related plans" / "clean up plans"
- "rename that plan" / "rename plan X" / "give that plan a better name"
- "switch master plan" / "switch to different master" / "list master plans"

## Error Handling

- If `.claude/plan-manager-state.json` doesn't exist: "No master plan initialized. Run `/plan-manager init <path>` first."
- If master plan file missing: "Master plan not found at {path}. Run `/plan-manager init` to set a new one."
- If phase number invalid: "Phase {N} not found in master plan. Valid phases: 1-{max}"
- If sub-plan already linked: "This file is already linked to Phase {N}. Use `/plan-manager status` to see current state."

## Example Workflows

### Starting Fresh

```
User: "Let's implement the new layout engine"
Claude: *Creates plans/layout-engine.md with 5 phases*

User: "/plan-manager init plans/layout-engine.md"
Claude: ✓ Initialized master plan: plans/layout-engine.md
        ✓ Added Status Dashboard with 5 phases

User: *Working on Phase 2...*
User: "Wait, we need to rethink the grid system"
Claude: *Creates plans/grid-rethink.md*

User: "/plan-manager capture"
Claude: I see you just created plans/grid-rethink.md. Which phase does this relate to?
User: "Phase 2"
Claude: ✓ Captured plans/grid-rethink.md → linked to Phase 2
        ✓ Updated master plan Status Dashboard

User: "/plan-manager status"
Claude: Master Plan: plans/layout-engine.md

        Phase 1: ✅ Complete
        Phase 2: 🔄 In Progress
          └─ plans/grid-rethink.md (In Progress)
        Phase 3: ⏳ Pending
        ...
```

### Joining Existing Project / New Session

```
User: "What plans do we have?"
Claude: *Runs /plan-manager overview*

        Plans Overview: plans/
        ═══════════════════════════════════════════════════════════

        ACTIVE HIERARCHIES
        ──────────────────

        📋 layout-engine.md (Master Plan)
        │   Status: 2/5 phases complete
        │
        ├── Phase 1: ✅ Complete
        ├── Phase 2: 🔄 In Progress
        │   └── 📄 grid-rethink.md (In Progress)
        ...

        ORPHANED / UNLINKED
        ───────────────────

        ⚠️  performance-notes.md
            No parent reference, created 3 days ago

Claude: *Uses AskUserQuestion tool*
        ┌─────────────────────────────────────────────────────────┐
        │ Found 1 orphaned plan. How would you like to handle it? │
        │                                                         │
        │ ○ Review it                                             │
        │   Show content summary and decide what to do            │
        │                                                         │
        │ ○ Link to a phase                                       │
        │   Connect this plan to a phase in the master plan       │
        │                                                         │
        │ ○ Archive it                                            │
        │   Move to plans/archive/ to get it out of the way       │
        │                                                         │
        │ ○ Leave as-is                                           │
        │   Don't take any action right now                       │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Link to a phase"*
Claude: *Uses AskUserQuestion tool*
        ┌─────────────────────────────────────────────────────────┐
        │ Which phase should performance-notes.md link to?        │
        │                                                         │
        │ ○ Phase 2: Layout Engine                                │
        │ ○ Phase 3: Rendering Pipeline                           │
        │ ○ Phase 4: Performance Optimization                     │
        │ ○ Phase 5: Testing                                      │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Phase 4: Performance Optimization"*
Claude: ✓ Captured performance-notes.md → linked to Phase 4
```

### Cleaning Up After Long Work Session

```
User: "/plan-manager overview"
Claude: *Shows full hierarchy with 2 completed sub-plans not linked to active work*

        COMPLETED (not linked to active work)
        ─────────────────────────────────────

        ✅ hotfix-login.md — Completed, standalone
        ✅ cache-optimization.md — Completed, parent phase also done

Claude: *Uses AskUserQuestion tool*
        ┌─────────────────────────────────────────────────────────┐
        │ Found 2 completed plans not linked to active work.      │
        │ How would you like to handle them?                      │
        │                                                         │
        │ ○ Archive completed                                     │
        │   Move to plans/archive/ with datestamp prefix          │
        │                                                         │
        │ ○ Review individually                                   │
        │   Show each plan and decide one by one                  │
        │                                                         │
        │ ○ Leave as-is                                           │
        │   Keep them where they are                              │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Archive completed"*
Claude: ✓ Moved hotfix-login.md → plans/archive/2026-01-30-hotfix-login.md
        ✓ Moved cache-optimization.md → plans/archive/2026-01-30-cache-optimization.md
```

### Organizing Messy Plans

```
User: "Organize my plans"
Claude: *Runs /plan-manager organize*

        Plans Overview: plans/
        ═══════════════════════════════════════════════════════════

        [... displays hierarchy ...]

        STANDALONE PLANS
        ────────────────

        📄 performance-notes.md — mentions "caching", "render optimization"
        📄 edge-cases.md — mentions "grid", "layout edge cases"
        📄 random-ideas.md — miscellaneous notes

Claude: *Uses AskUserQuestion tool*
        ┌─────────────────────────────────────────────────────────┐
        │ I found 3 unlinked plans that may relate to your       │
        │ master plan. Review my linking suggestions?            │
        │                                                         │
        │ ○ Review suggestions                                    │
        │   I'll show each suggestion and you approve or reject   │
        │                                                         │
        │ ○ Link all                                              │
        │   Accept all my linking suggestions without review      │
        │                                                         │
        │ ○ Skip linking                                          │
        │   Don't link anything, move on to cleanup               │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Review suggestions"*

Claude: *Uses AskUserQuestion tool*
        ┌─────────────────────────────────────────────────────────┐
        │ performance-notes.md mentions "caching" and "render     │
        │ optimization". Link to Phase 4 (Performance)?           │
        │                                                         │
        │ ○ Yes, link it                                          │
        │   Add parent reference and update master plan           │
        │                                                         │
        │ ○ Different phase                                       │
        │   Link to a different phase instead                     │
        │                                                         │
        │ ○ Skip this one                                         │
        │   Don't link this plan                                  │
        │                                                         │
        │ ○ It's not a sub-plan                                   │
        │   This is standalone documentation, not a sub-plan      │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Yes, link it"*
Claude: ✓ Linked performance-notes.md → Phase 4

        [... continues for remaining plans ...]

Claude: Organization Complete
        ─────────────────────

        ✓ Linked 2 plans to master:
          • performance-notes.md → Phase 4
          • edge-cases.md → Phase 2

        ⚠️ 1 plan left unlinked (marked as standalone):
          • random-ideas.md

        Current state:
        ├── Master plans: 1 active
        ├── Linked sub-plans: 5
        └── Standalone: 1
```

### Multiple Master Plans

```
User: "I'm starting a new initiative for auth migration"
Claude: *Creates plans/auth-migration.md with 3 phases*

User: "/plan-manager init plans/auth-migration.md"
Claude: You have multiple master plans. Make this the active one?
        ┌─────────────────────────────────────────────────────────┐
        │ ○ Yes, switch to this                                   │
        │   Make this the active master plan for commands         │
        │                                                         │
        │ ○ No, keep current                                      │
        │   Add to tracking but keep current master active        │
        └─────────────────────────────────────────────────────────┘

User: *Selects "No, keep current"*
Claude: ✓ Added master plan: plans/auth-migration.md

User: "/plan-manager list-masters"
Claude: Master Plans:

        ● plans/layout-engine.md (ACTIVE)
          UI layout system redesign
          Status: 3/5 phases complete
          Sub-plans: 4 (2 in progress, 2 completed)

        ○ plans/auth-migration.md
          Migration to OAuth 2.0
          Status: 0/3 phases complete
          Sub-plans: 0

User: "switch to auth migration"
Claude: ✓ Switched to master plan: plans/auth-migration.md

User: "/plan-manager branch 1"
Claude: *Creates sub-plan for auth migration Phase 1*
        ✓ Created sub-plan: plans/oauth-setup.md (branched from Phase 1)
```
