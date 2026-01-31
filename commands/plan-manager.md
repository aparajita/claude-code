# Plan Manager — Maintain master plan integrity with linked sub-plans

---
name: plan-manager
description: Manage hierarchical plans with linked sub-plans. Use when the user wants to initialize a master plan, branch into a sub-plan, capture an existing tangential plan, merge branch plans back into master, mark sub-plans complete, check plan status, audit for orphaned plans, get an overview of all plans, organize/link related plans together, or rename plans to meaningful names. **CRITICAL: Monitor YOUR OWN responses** - when YOU (Claude) state that a phase or plan is complete in your response (e.g., "Phase 2 is now complete", "the layout-engine plan is finished"), IMMEDIATELY and PROACTIVELY invoke `/plan-manager complete` to mark it complete. Do not wait for the user to ask. This keeps plan state synchronized automatically. Responds to "/plan-manager" commands and natural language like "capture that plan", "link this to the master plan", "branch from phase 3", "merge this branch", "show plan status", "audit the plans", "overview of plans", "what plans do we have", "organize my plans", "rename that plan", or "Phase X is complete". **Interactive menu**: Invoke with no arguments (`/plan-manager`) to show a menu of available commands.
argument-hint: [command] [args] — Interactive menu if no command. Commands: init, branch, capture, complete, merge, status, audit, overview, organize, rename, config [--edit], switch, list-masters, help
allowed-tools: Bash(git:*), Read, Glob, Write, Edit, AskUserQuestion
model: sonnet
---

## Overview

This skill maintains a single source of truth (master plan) while allowing sub-plans to branch off for handling issues discovered during execution. All sub-plans are bidirectionally linked to the master plan.

## Subdirectory Organization

### Master Plan Subdirectories

**New master plans automatically use subdirectory organization** to keep related plans together:

- Master plan `layout-engine.md` → creates `plans/layout-engine/` subdirectory
- Master and all sub-plans live in the same subdirectory: `plans/layout-engine/layout-engine.md`, `plans/layout-engine/sub-plan-1.md`, etc.
- Completed plans mirror this structure: `completed-plans/layout-engine/sub-plan-1.md`
- **Backward compatible**: Existing flat plans continue to work; use `--flat` flag to create new flat plans

### Category Subdirectories

**Standalone plans can be organized by type** into category subdirectories:

- Documentation plans → `plans/docs/` (configurable)
- Migration plans → `plans/migrations/` (configurable)
- Design plans → `plans/designs/` (configurable)
- Reference docs → `plans/reference/` (configurable)
- Miscellaneous → `plans/misc/` (configurable)

**Configuration**: Category directories are configured in `plan-manager-settings.json`:

Priority order (later overrides earlier):
1. `~/.claude/plan-manager-settings.json` (user global defaults)
2. `<project>/.claude/plan-manager-settings.json` (project-specific)

**Important notes**:
- Category-organized plans can still be linked to master plan phases if they turn out to be sub-plans
- When a plan in a category directory is linked to a master plan, you'll be asked whether to move it to the master's subdirectory
- Category directories and master plan subdirectories are independent organizational axes

**Default settings** (if no config file exists):
```json
{
  "categoryDirectories": {
    "documentation": "docs",
    "migration": "migrations",
    "design": "designs",
    "reference": "reference",
    "standalone": "misc"
  },
  "enableCategoryOrganization": true
}
```

**Customization examples**:
```json
{
  "categoryDirectories": {
    "documentation": "documentation",
    "migration": "db-migrations",
    "design": "design-docs",
    "reference": "refs",
    "feature": "features",
    "bugfix": "bug-fixes",
    "standalone": "other"
  },
  "enableCategoryOrganization": true
}
```

To disable category organization:
```json
{
  "enableCategoryOrganization": false
}
```

**Benefits**:
  - Visual grouping of related plans in file browser
  - Clean separation between different master plan hierarchies and plan types
  - Easier to archive/move entire plan hierarchies
  - Reduces clutter in root plans directory
  - Customizable to match your project's workflow

**Migration**: The `organize` command can migrate existing plans to subdirectories.

### Settings File Behavior

**The settings file is optional.** Commands work fine without it using built-in defaults:

- If no settings file exists, commands use default category directories (docs, migrations, designs, etc.)
- Commands will NOT automatically create the settings file
- Category organization is enabled by default (can be disabled in settings)

**To customize category directories or disable category organization**, create a settings file manually or use the helper command.

### Creating Settings File

**Recommended: Use the interactive editor**

The easiest way to configure category directories is to use the interactive editor:

```bash
/plan-manager config --edit
```

This will:
- Walk you through all settings interactively
- Let you choose directory names with suggestions
- Show a preview before saving
- Ask whether to save to user-wide or project-specific settings

**Quick view: Just see current config**

```bash
/plan-manager config
```

This displays the active configuration and offers actions (edit, toggle, etc.)

**Manual creation** (if you prefer to edit files directly):

To manually customize category directories, create a settings file:

**User-wide settings** (applies to all projects):
```bash
# Create ~/.claude/plan-manager-settings.json
mkdir -p ~/.claude
cat > ~/.claude/plan-manager-settings.json << 'EOF'
{
  "categoryDirectories": {
    "documentation": "docs",
    "migration": "migrations",
    "design": "designs",
    "reference": "reference",
    "feature": "features",
    "bugfix": "bug-fixes",
    "standalone": "misc"
  },
  "enableCategoryOrganization": true
}
EOF
```

**Project-specific settings** (overrides user-wide):
```bash
# Create .claude/plan-manager-settings.json in your project
mkdir -p .claude
cat > .claude/plan-manager-settings.json << 'EOF'
{
  "categoryDirectories": {
    "documentation": "documentation",
    "migration": "db-migrations",
    "design": "design-proposals"
  },
  "enableCategoryOrganization": true
}
EOF
```

**To disable category organization**:
```json
{
  "enableCategoryOrganization": false
}
```

When settings exist, the `organize` command will use them automatically.

**To view your current configuration**, run:
```bash
/plan-manager config
```

This shows which settings file is active (user-wide, project-specific, or built-in defaults) and displays all category directory mappings in a readable format.

## Interaction Guidelines

**Always use the AskUserQuestion tool** for any multiple-choice decisions. Each option must include:
- A concise label (1-5 words)
- A description explaining what that choice does

This provides a consistent, user-friendly interface for all plan management decisions.

## Proactive Completion Detection

**CRITICAL: Self-monitor YOUR OWN responses (Claude's responses) for completion statements.**

When YOU (the assistant) state in your response that a phase or plan is complete, **immediately and automatically** invoke `/plan-manager complete <plan-or-phase>` in the same response.

**Watch for YOUR OWN phrases like:**
- "Phase 2 is now complete" / "Step 3 is done"
- "Phase 4.1 is finished" / "Step 2.3 completed"
- "The layout-engine plan is finished"
- "That's complete"
- "Phase X implementation is done"
- "Completed the [plan name] work"

**Terminology support:**
- Recognizes both "Phase" and "Step" (used interchangeably)
- Supports subphases/substeps: "Phase 4.1", "Step 2.3", etc.

**Example workflow:**
```
User: "Implement Phase 4"
You: [does implementation work]
You: "✓ Phase 4 is now complete. All components have been updated."
You: [IMMEDIATELY invokes /plan-manager complete 4]
     → Checks if Phase 4 is the last phase
     → If last phase and others aren't complete, asks if entire plan is done
     → Marks Phase 4 as completed
     → Updates master plan
     → Asks about moving to completed-plans/
```

**Important:**
- Don't wait for the user to manually invoke the command
- Invoke it in the SAME response where you declare completion
- This keeps plan state automatically synchronized with actual work
- The user never needs to manually track completions

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
      "path": "plans/layout-engine/layout-engine.md",
      "subdirectory": "layout-engine",
      "active": true,
      "created": "2026-01-30",
      "description": "UI layout system redesign"
    },
    {
      "path": "plans/auth-migration.md",
      "subdirectory": null,
      "active": false,
      "created": "2026-01-29",
      "description": "Migration to OAuth 2.0"
    }
  ],
  "subPlans": [
    {
      "path": "plans/layout-engine/sub-plan-1.md",
      "parentPlan": "plans/layout-engine/layout-engine.md",
      "parentPhase": 3,
      "status": "in_progress",
      "createdAt": "2026-01-30"
    }
  ]
}
```

**Multiple master plans** are supported for projects with parallel initiatives. Commands operate on the "active" master plan by default, but can target specific masters.

**Subdirectory organization** is supported for better organization:
- New master plans automatically get their own subdirectory (e.g., `plans/layout-engine/`)
- Sub-plans are created in the same subdirectory as their master plan
- Flat structure (no subdirectory) is still supported for backward compatibility
- The `subdirectory` field tracks whether a master uses subdirectory organization (null = flat)
- **Category organization**: Standalone plans can be organized into category subdirectories (migrations/, docs/, designs/, etc.)
  - Category-organized plans are not tracked in state file (they're not linked to any master)
  - Category directories are configured in `plan-manager-settings.json`

This keeps tooling metadata separate from actual plan files.

The `plansDirectory` can be configured per-project. Common locations:
- `plans/` (default)
- `docs/plans/`
- `.plans/`

If the state file doesn't exist, the `overview` command can still scan for plans; other commands will prompt to run `init` first.

## Completed Plans Directory

Completed plans can be moved to a `completed-plans/` directory to keep the working plans directory clean:

- If `plansDirectory` is `plans/`, completed plans move to `completed-plans/`
- If `plansDirectory` is `docs/plans/`, completed plans move to `docs/completed-plans/`
- The directory is created as a sibling to the plans directory
- **Subdirectory structure is mirrored**:
  - Master plan subdirectories: `plans/layout-engine/sub-plan.md` → `completed-plans/layout-engine/sub-plan.md`
  - Category subdirectories: `plans/migrations/db-upgrade.md` → `completed-plans/migrations/db-upgrade.md`
  - Flat plans: `plans/sub-plan.md` → `completed-plans/sub-plan.md`
- Completed plans retain their original filename (no datestamp prefix needed)
- Subdirectories in completed-plans are created automatically as needed
- This preserves the organizational structure even after completion, making it easy to find old plans

## Commands

### No command (interactive menu)

When invoked without any command (`/plan-manager`), display an interactive menu of available commands using regular text output.

**Display this menu:**

```
Plan Manager — Available Commands
══════════════════════════════════════════════════════════════

VIEWING & STATUS
────────────────
  1. status        Show master plan hierarchy and sub-plan status
  2. overview      Discover all plans in the project and their relationships
  3. list-masters  Show all tracked master plans

GETTING STARTED
───────────────
  4. init          Initialize or add a master plan
  5. config        View/edit category organization settings

WORKING WITH PLANS
──────────────────
  6. branch        Create a sub-plan for the current phase
  7. capture       Link an existing plan to a master plan phase
  8. complete      Mark a sub-plan or phase as complete
  9. merge         Merge a branch plan's content into the master plan

ORGANIZATION
────────────
  10. organize     Auto-organize, link, and clean up plans
  11. rename       Rename a plan and update all references
  12. audit        Find orphaned plans and broken links

MULTI-MASTER
────────────
  13. switch       Change which master plan is active

HELP
────
  14. help         Show detailed command reference and examples

══════════════════════════════════════════════════════════════

Please respond with the number or name of the command you'd like to use.
```

After the user responds with their choice, parse it (accepting either number or command name), then prompt for any required arguments for that command and execute it.

**Examples:**

```
User: "/plan-manager"
Claude: *Shows text menu*

        Plan Manager — Available Commands
        ══════════════════════════════════════════════════════════════

        VIEWING & STATUS
        ────────────────
          1. status        Show master plan hierarchy and sub-plan status
          2. overview      Discover all plans in the project and their relationships
          ...

        Please respond with the number or name of the command you'd like to use.

User: "1" (or "status")
Claude: *Uses AskUserQuestion to ask about scope*
        Do you want to see all master plans or just the active one?
        ┌─────────────────────────────────────────────────────────┐
        │ Status scope                                            │
        │                                                         │
        │ ○ Active master only                                    │
        │   Show status for the currently active master plan      │
        │                                                         │
        │ ○ All master plans                                      │
        │   Show status for all tracked master plans              │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Active master only"*
Claude: *Runs `/plan-manager status` and shows output*
```

```
User: "/plan-manager"
Claude: *Shows text menu*

User: "init" (or "4")
Claude: Which plan file should I initialize as a master plan?
User: "plans/new-feature.md"
Claude: *Runs `/plan-manager init plans/new-feature.md`*
```

```
User: "/plan-manager"
Claude: *Shows text menu*

User: "help" (or "13")
Claude: *Runs `/plan-manager help` and shows command reference*

        Plan Manager Commands
        ═══════════════════════════════════════════════════════════

        GETTING STARTED
        ───────────────

          init <path>              Initialize or add a master plan
          config                   View/edit category organization settings

        WORKING WITH PLANS
        ──────────────────

          branch <phase>           Create a sub-plan for a phase
          capture [file]           Link an existing plan to a phase
          complete <plan>          Mark a sub-plan or phase as complete

        [... full command reference ...]
```

This makes the skill discoverable for new users and provides quick access to common operations without memorizing command names.

### `init <path> [--description "text"] [--flat]`

Initialize or add a master plan to tracking.

1. **Detect plans directory** (see Plans Directory Detection above)
2. **Determine subdirectory organization**:
   - By default, new master plans use subdirectory organization (automatic)
   - Use `--flat` flag to keep the plan in the root of the plans directory (backward compatibility)
   - If the plan file already exists, preserve its current location
3. **Set up subdirectory structure** (if not using --flat):
   - Extract base name from plan filename (e.g., `layout-engine.md` → `layout-engine`)
   - Create subdirectory: `{plansDirectory}/{baseName}/`
   - If plan file exists at root level, move it to subdirectory:
     - `plans/layout-engine.md` → `plans/layout-engine/layout-engine.md`
   - If plan doesn't exist yet, will be created in subdirectory when user creates it
   - Update all references to the old path (if moved)
4. Check if state file exists:
   - **First master plan**: Create `.claude/plan-manager-state.json` (create `.claude/` directory if needed), mark as active
   - **Additional master plan**: Add to `masterPlans` array
5. If multiple masters exist, ask via **AskUserQuestion**:

```
Question: "You have multiple master plans. Make this the active one?"
Header: "Active master"
Options:
  - Label: "Yes, switch to this"
    Description: "Make this the active master plan for commands"
  - Label: "No, keep current"
    Description: "Add to tracking but keep current master active"
```

6. Extract or ask for a brief description to identify this master plan
7. If the master plan doesn't have a Status Dashboard section, offer to add one:

```markdown
## Status Dashboard

| Phase | Status | Sub-plans |
|-------|--------|-----------|
| 1     | pending | — |
| 2     | pending | — |
...
```

8. Record subdirectory usage in state:
   - If using subdirectory: `"subdirectory": "layout-engine"`
   - If flat structure: `"subdirectory": null`

9. **Offer configuration setup** (only if this is the first master plan and no settings exist):
   - Check if `~/.claude/plan-manager-settings.json` or `.claude/plan-manager-settings.json` exists
   - If neither exists, use **AskUserQuestion**:

```
Question: "Configure category organization for standalone plans?"
Header: "Setup"
Options:
  - Label: "Configure now (Recommended)"
    Description: "Set up category directories (migrations/, docs/, etc.)"
  - Label: "Use defaults"
    Description: "Use built-in defaults (migrations, docs, designs, etc.)"
  - Label: "Skip for now"
    Description: "Don't set up categories yet, I'll configure later"
```

   - If "Configure now", run the `config` command interactively
   - If "Use defaults" or "Skip for now", continue without creating settings file

10. Confirm initialization:
   - `✓ Added master plan: {path} (active)` or `✓ Added master plan: {path}`
   - If subdirectory created: `✓ Created subdirectory: plans/{baseName}/`

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

● plans/layout-engine/layout-engine.md (ACTIVE)
  Subdirectory: layout-engine/
  UI layout system redesign
  Status: 3/5 phases complete
  Sub-plans: 4 (2 in progress, 2 completed)

○ plans/auth-migration.md
  Flat structure
  Migration to OAuth 2.0
  Status: 1/3 phases complete
  Sub-plans: 1 (1 in progress)
```

### `branch <phase> [--master <path>]`

Proactively create a sub-plan when you see a problem coming.

1. Read the state file to get master plan path (use active master, or specified via --master)
2. Read the master plan to verify the phase exists
3. Ask the user for a brief description of the sub-plan topic
4. **Determine sub-plan location**:
   - Check if master plan uses subdirectory organization (from state file)
   - If master is in subdirectory (e.g., `plans/layout-engine/layout-engine.md`):
     - Create sub-plan in same subdirectory: `plans/layout-engine/{sub-plan-name}.md`
   - If master is flat (e.g., `plans/legacy-plan.md`):
     - Create sub-plan at root: `plans/{sub-plan-name}.md`
5. **Update the master plan FIRST**:
   - Update the Status Dashboard: change phase status to `🔀 Branching`
   - Add sub-plan reference to the phase section
   - Use relative path for link if in same subdirectory (e.g., `[sub-plan.md](./sub-plan.md)`)
6. Create the sub-plan file with header:

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

7. Update state file with new sub-plan entry
8. Confirm: `✓ Created sub-plan: {path} (branched from Phase {N})`

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
3. **Move to subdirectory if needed**:
   - If master plan uses subdirectory and captured plan is not in it, move the plan
   - If master plan is flat and captured plan is in a subdirectory, ask whether to move or keep
4. **Add parent reference to the sub-plan** (prepend if not present):

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

**Accepts:** phase numbers (3), subphases (4.1), step numbers (2), substeps (2.3), or file paths

1. If argument is a number/subphase, find sub-plan for that phase/step; otherwise use as file path
2. Read the sub-plan and update its status header to `Completed`
3. **Ask about merge vs mark complete** using **AskUserQuestion**:
   ```
   Question: "This branch plan is complete. How should it be integrated?"
   Header: "Integration"
   Options:
     - Label: "Merge into master (Recommended)"
       Description: "Merge branch content into the master plan's phase section"
     - Label: "Just mark complete"
       Description: "Update Status Dashboard only, keep branch separate"
   ```
   - If "Merge into master": Run the merge workflow (see `merge` command)
   - If "Just mark complete": Continue with steps below

4. Read and update the master plan:
   - Update Status Dashboard: change sub-plan status indicator
   - Update phase/step status based on user choice

5. Update state file

6. **Check if entire plan is complete**:
   - Count total phases/steps in master plan
   - Check how many are marked ✅ Complete
   - If this is the LAST phase/step AND no other phases are marked complete:
     - Use **AskUserQuestion**: "This is the last phase but no others are marked complete. Is the entire plan actually complete?"
     - Options: "Yes, all done" / "No, just this phase"
   - If "Yes, all done", mark ALL phases as complete

7. **Ask about branch cleanup** using **AskUserQuestion**:
   ```
   Question: "What should happen to the completed branch plan?"
   Header: "Branch cleanup"
   Options:
     - Label: "Archive it"
       Description: "Move to completed-plans/ directory to keep it for reference"
     - Label: "Delete it"
       Description: "Remove the file entirely (content is in master plan)"
     - Label: "Leave in place"
       Description: "Keep in current location for now"
   ```
   - If "Archive it", move the file mirroring subdirectory structure:
     - If plan is in `plans/layout-engine/sub-plan.md`, move to `completed-plans/layout-engine/sub-plan.md`
     - If plan is in `plans/sub-plan.md` (flat), move to `completed-plans/sub-plan.md`
     - Create subdirectory in completed-plans if needed
   - If "Delete it", delete the file
   - If "Leave in place", do nothing
   - Update all references in master plan and state file

8. Use **AskUserQuestion tool** to determine phase status:
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

9. Confirm: `✓ Completed sub-plan: {path}`

### `merge [file-or-phase]`

Merge a branch plan's content into the master plan.

**Purpose**: Branch plans often contain updates, refinements, or extensions to the master plan's phase content. This command integrates that work back into the master plan instead of keeping it as a separate document.

**Accepts:** phase numbers (3), subphases (4.1), step numbers (2), substeps (2.3), file paths, or no argument (interactive selection)

**Without argument (interactive mode):**
1. Read state file to get active master plan
2. List all sub-plans linked to the active master
3. Use **AskUserQuestion** to select which branch to merge:
   ```
   Question: "Which branch plan do you want to merge into the master?"
   Header: "Select branch"
   Options:
     - Label: "{branch-1-name}.md"
       Description: "Phase {N}: {brief-description} (Status: {status})"
     - Label: "{branch-2-name}.md"
       Description: "Phase {M}: {brief-description} (Status: {status})"
     [... up to 4 most recent branches, use "Other" for text input if more]
   ```

**With argument:**
1. If argument is a number/subphase, find sub-plan for that phase/step; otherwise use as file path
2. Validate the branch plan exists and is linked to the active master

**Merge workflow:**

1. **Read the branch plan content**
2. **Identify the target phase** in the master plan (from the branch's Parent header)
3. **Use AskUserQuestion to confirm merge approach**:
   ```
   Question: "How should this branch content be merged?"
   Header: "Merge strategy"
   Options:
     - Label: "Append to phase (Recommended)"
       Description: "Add branch content to the end of Phase {N} section"
     - Label: "Replace phase content"
       Description: "Replace Phase {N} content entirely with branch content"
     - Label: "Manual review"
       Description: "Show me both and I'll decide what to keep"
   ```

4. **Perform the merge**:
   - If "Append to phase":
     - Extract the main content from the branch plan (excluding the Parent header and metadata)
     - Add a subsection to the master plan's phase: `### Merged from {branch-name}.md`
     - Append the branch content under that subsection
   - If "Replace phase content":
     - Replace the entire phase section with the branch content
     - Preserve the phase heading (`## Phase {N}: {title}`)
   - If "Manual review":
     - Display both the current phase content and branch content
     - Ask user to indicate what should be kept/combined

5. **Update master plan metadata**:
   - Update Status Dashboard: remove the sub-plan reference
   - Add a note in the phase section: `✓ Merged from [{branch-name}.md](path) on {date}`

6. **Update state file**: Mark the branch as merged (add `"merged": true, "mergedAt": "{date}"`)

7. **Ask about branch cleanup** using **AskUserQuestion**:
   ```
   Question: "Branch merged successfully. What should happen to the branch file?"
   Header: "Branch cleanup"
   Options:
     - Label: "Delete it (Recommended)"
       Description: "Remove the file (content is now in master plan)"
     - Label: "Archive it"
       Description: "Move to completed-plans/ directory for reference"
     - Label: "Leave in place"
       Description: "Keep in current location"
   ```
   - If "Delete it": Delete the branch file and remove from state
   - If "Archive it": Move to completed-plans/ mirroring subdirectory structure
   - If "Leave in place": Do nothing

8. **Ask about phase status** using **AskUserQuestion**:
   ```
   Question: "Branch merged. What's the status of Phase {N}?"
   Header: "Phase status"
   Options:
     - Label: "Phase complete"
       Description: "All work for Phase {N} is done, mark it ✅ Complete"
     - Label: "Still in progress"
       Description: "More work remains on Phase {N}, keep it 🔄 In Progress"
   ```

9. **Confirm**: `✓ Merged {branch-name}.md into Phase {N} of master plan`

**Example:**

```
User: "/plan-manager merge grid-edge-cases.md"
Claude: *Reads branch plan content*

        How should this branch content be merged?
        ┌─────────────────────────────────────────────────────────┐
        │ Merge strategy                                          │
        │                                                         │
        │ ○ Append to phase (Recommended)                         │
        │   Add branch content to the end of Phase 2 section      │
        │                                                         │
        │ ○ Replace phase content                                 │
        │   Replace Phase 2 content entirely with branch content  │
        │                                                         │
        │ ○ Manual review                                         │
        │   Show me both and I'll decide what to keep             │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Append to phase"*
Claude: ✓ Appended grid-edge-cases.md content to Phase 2

        Branch merged successfully. What should happen to the branch file?
        [cleanup options...]

User: *Selects "Delete it"*
Claude: ✓ Deleted grid-edge-cases.md
        ✓ Merged grid-edge-cases.md into Phase 2 of master plan
```

### `status [--all]`

Display the full plan hierarchy and status.

**Default (active master only):**
1. Read state file to get active master plan
2. Read master plan to extract Status Dashboard
3. For each sub-plan linked to this master, read its status
4. Display formatted output:

```
Master Plan: plans/layout-engine/layout-engine.md (ACTIVE)
Subdirectory: layout-engine/
UI layout system redesign

Phase 1: ✅ Complete
Phase 2: 🔄 In Progress
  └─ layout-fix.md (In Progress)
Phase 3: ⏸️ Blocked
  └─ api-redesign.md (Completed)
Phase 4: ⏳ Pending

Sub-plans: 2 total (1 in progress, 1 completed)
```

**With --all flag:**
Show status for all master plans:

```
Master Plans: 2

● plans/layout-engine/layout-engine.md (ACTIVE)
  Subdirectory: layout-engine/
  UI layout system redesign

  Phase 1: ✅ Complete
  Phase 2: 🔄 In Progress
    └─ layout-fix.md (In Progress)
  ...
  Sub-plans: 2 total (1 in progress, 1 completed)

○ plans/auth-migration.md
  Flat structure
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

2. **Scan all markdown files** in the directory and subdirectories:
   - Recursively scan the plans directory for `.md` files
   - Include files in subdirectories (e.g., `plans/layout-engine/*.md`)
   - Read each `.md` file
   - Classify each file by analyzing its content:

   | Classification | Detection Criteria |
   |----------------|-------------------|
   | **Master Plan** | Has phases/steps (## Phase N or ## Step N), may have Status Dashboard |
   | **Sub-plan (linked)** | Has `**Parent:**` header pointing to a master |
   | **Sub-plan (orphaned)** | Looks like a sub-plan but no Parent reference or parent doesn't exist |
   | **Standalone Plan** | Has plan structure but no phase/step hierarchy |
   | **Completed** | Has `**Status:** Completed` or all phases/steps marked ✅ |
   | **Abandoned** | Old modification date, marked as abandoned, or superseded |
   | **Reference Doc** | Not a plan — just documentation |

   **Additionally, classify standalone plans by category** for organization:

   | Category | Detection Criteria |
   |----------|-------------------|
   | **Documentation** | Titles/content include "docs", "documentation", "guide", "manual", "how-to", "reference" |
   | **Migration** | Titles/content include "migration", "migrate", "upgrade", "transition", "port" |
   | **Design** | Titles/content include "design", "architecture", "proposal", "RFC", "spec" |
   | **Feature** | Titles/content include "feature", "enhancement", "new", "add" |
   | **Bugfix** | Titles/content include "bug", "fix", "issue", "problem", "error" |
   | **Reference** | Pure reference material, glossaries, decision logs |
   | **Standalone** | Doesn't match other categories |

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

📋 layout-engine/ (Subdirectory)
│  └── layout-engine.md (Master Plan)
│      Status: 3/5 phases complete
│
│  ├── Phase 1: ✅ Complete
│  ├── Phase 2: 🔄 In Progress
│  │   └── 📄 grid-rethink.md (In Progress)
│  │       └── 📄 grid-edge-cases.md (In Progress)
│  ├── Phase 3: ⏸️ Blocked
│  │   └── 📄 api-redesign.md (Completed)
│  ├── Phase 4: ⏳ Pending
│  └── Phase 5: ⏳ Pending

📋 auth-migration.md (Master Plan, flat structure)
│   Status: 1/3 phases complete
│
├── Phase 1: ✅ Complete
├── Phase 2: 🔄 In Progress
└── Phase 3: ⏳ Pending


BY CATEGORY (with suggested organization)
──────────────────────────────────────────

📂 migrations/ (suggested category dir)
   📄 database-schema-v2.md — Migration plan
   📄 api-v3-migration.md — Migration plan

📂 docs/ (suggested category dir)
   📄 quick-fix-notes.md — Documentation
   📄 onboarding-guide.md — Documentation

📂 designs/ (suggested category dir)
   📄 performance-ideas.md — Design proposal
   📄 new-api-design.md — Architecture design


UNCATEGORIZED STANDALONE
─────────────────────────

📄 random-ideas.md — Standalone, no clear category


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

Total plans: 16
├── Master plans: 3 (2 active, 1 completed)
├── Linked sub-plans: 4
├── Category-organized: 5 (migrations: 2, docs: 2, designs: 1)
├── Uncategorized standalone: 1
└── Orphaned/Unlinked: 2

```

5. **Interactive cleanup for orphaned/completed**:

If orphaned, unlinked completed, or uncategorized standalone plans are found, use the **AskUserQuestion tool** with descriptive options:

```
Question: "Found 2 orphaned plans, 1 completed plan, and 5 uncategorized standalone plans. How would you like to handle them?"
Header: "Cleanup"
Options:
  - Label: "Organize all"
    Description: "Categorize standalone plans, analyze content, suggest links for related plans, then handle completed/orphaned"
  - Label: "Review individually"
    Description: "I'll show a summary of each plan and ask what to do with it one by one"
  - Label: "Move completed"
    Description: "Move completed unlinked plans to completed-plans/ directory"
  - Label: "Leave as-is"
    Description: "Just show the report, don't take any action"
```

Based on selection:
- **Organize all**: Switch to the `organize` workflow — organize by category, analyze relationships, suggest links, then cleanup
- **Review individually**: For each plan, show content summary and use AskUserQuestion again: Organize by category? Link to phase? Move to completed? Delete? Skip?
- **Move completed**: Move completed unlinked plans to `completed-plans/` (sibling to plans directory)
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

2. **Load category organization settings**:
   - Check for `~/.claude/plan-manager-settings.json` (user global)
   - Check for `<project>/.claude/plan-manager-settings.json` (project-specific, overrides user)
   - If neither exists, use default category directories (docs, migrations, designs, reference, misc)
   - **Note**: Settings file is optional and will NOT be auto-created
   - If `enableCategoryOrganization` is false in settings, skip category organization steps

3. **Detect flat master plans and offer subdirectory migration**:
   - Scan for master plans at the root of plans directory (not in subdirectories)
   - If found, use **AskUserQuestion tool**:

```
Question: "Found 2 master plans using flat structure. Migrate them to subdirectories?"
Header: "Subdirectories"
Options:
  - Label: "Migrate all"
    Description: "Move each master plan and its sub-plans into a subdirectory"
  - Label: "Review individually"
    Description: "I'll ask about each master plan separately"
  - Label: "Leave flat"
    Description: "Keep current flat structure, skip migration"
```

   - **If "Migrate all"**: For each flat master plan:
     - Create subdirectory: `plans/{master-basename}/`
     - Move master plan: `plans/layout-engine.md` → `plans/layout-engine/layout-engine.md`
     - Move all linked sub-plans to the same subdirectory
     - Update all references (state file, links in plans)
     - Update state file `subdirectory` field

   - **If "Review individually"**: For each flat master, use **AskUserQuestion**:
     ```
     Question: "Migrate 'layout-engine.md' and its 3 sub-plans to a subdirectory?"
     Header: "Migrate master"
     Options:
       - Label: "Yes, migrate"
         Description: "Create plans/layout-engine/ and move master + sub-plans"
       - Label: "Leave flat"
         Description: "Keep this master plan in flat structure"
     ```

4. **Detect and offer to rename randomly-named plans**:
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
    Description: "Keep current names, move on to category organization"
```

   - For each rename, suggest meaningful names based on content analysis

5. **Organize standalone plans by category** (if `enableCategoryOrganization` is true):
   - Identify standalone plans that match category patterns (from classification)
   - Group by detected category (documentation, migration, design, etc.)
   - Use default category directories (docs, migrations, designs, etc.) unless custom settings exist
   - If categorized plans found, use **AskUserQuestion tool**:

```
Question: "Found 8 standalone plans that can be organized by category. Organize them?"
Header: "Categories"
Options:
  - Label: "Organize all (Recommended)"
    Description: "Move plans to category subdirectories (migrations/, docs/, designs/, etc.)"
  - Label: "Review by category"
    Description: "I'll show each category and you approve or skip"
  - Label: "Skip categories"
    Description: "Don't organize by category, move on to linking"
```

   - **If "Organize all"**: For each categorized plan:
     - Create category subdirectory if needed (e.g., `plans/migrations/`)
     - Move plan to category directory
     - Update all references

   - **If "Review by category"**: For each category with plans, use **AskUserQuestion**:
     ```
     Question: "Move 3 migration plans to plans/migrations/?"
     Header: "Organize category"
     Options:
       - Label: "Yes, move them"
         Description: "database-schema-v2.md, api-v3-migration.md, auth-upgrade.md"
       - Label: "Review individually"
         Description: "Ask about each plan separately"
       - Label: "Skip this category"
         Description: "Leave these plans where they are"
     ```

6. **Analyze relationships between unlinked plans**:
   - For each standalone or orphaned plan, analyze its content
   - Look for references to phases, topics, or keywords that match master plan phases
   - Build a list of suggested linkages
   - **Important**: Plans organized into category directories can still be linked to master plan phases if appropriate

7. **Present linking suggestions** via AskUserQuestion:

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

8. **If "Review suggestions" selected**, for each suggested link use AskUserQuestion:

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

9. **After linking, handle orphaned/completed plans** (same as `overview` step 5):
   - Ask what to do with remaining orphans
   - Ask what to do with completed unlinked plans

10. **Summary output**:

```
Organization Complete
─────────────────────

✓ Migrated to subdirectories:
  • layout-engine.md → layout-engine/layout-engine.md (+ 3 sub-plans)

✓ Organized by category (using defaults):
  • 3 migration plans → migrations/
  • 2 documentation plans → docs/
  • 1 design plan → designs/

✓ Renamed 2 plans:
  • lexical-puzzling-emerson.md → grid-edge-cases.md
  • abstract-floating-jenkins.md → performance-notes.md

✓ Linked 2 plans to master:
  • performance-notes.md → Phase 4
  • grid-edge-cases.md → Phase 2

✓ Moved 1 completed plan:
  • hotfix-login.md → completed-plans/hotfix-login.md

⚠️ 1 plan left unlinked (user skipped):
  • random-ideas.md

Current state:
├── Master plans: 1 active (using subdirectory)
├── Linked sub-plans: 5
├── Category-organized: 6
└── Unlinked: 1

💡 Tip: Run `/plan-manager config` to customize category directory names
```

**If custom settings were used**, the output shows:
```
✓ Organized by category (using custom settings from .claude/plan-manager-settings.json):
  • 3 migration plans → db-migrations/
  • 2 documentation plans → documentation/
  • 1 design plan → design-proposals/
```

### `config [--user|--project] [--edit]`

Display and configure category organization settings interactively.

**Without flags** (show current configuration):
1. Load and display current configuration from all sources:

```
Plan Manager Configuration
══════════════════════════

Source Priority (highest to lowest):
  1. Project settings: .claude/plan-manager-settings.json [NOT FOUND]
  2. User settings: ~/.claude/plan-manager-settings.json [ACTIVE]
  3. Built-in defaults [FALLBACK]

Active Configuration (from user settings):
──────────────────────────────────────────

Category Organization: ENABLED

Category Directories:
  documentation  → docs/
  migration      → db-migrations/
  design         → designs/
  reference      → reference/
  feature        → features/
  bugfix         → bug-fixes/
  standalone     → misc/

File Location: ~/.claude/plan-manager-settings.json
```

2. Use **AskUserQuestion** to offer actions:

```
Question: "What would you like to do?"
Header: "Config actions"
Options:
  - Label: "Edit categories"
    Description: "Modify category directory names interactively"
  - Label: "Toggle organization"
    Description: "Enable/disable category organization"
  - Label: "Create project config"
    Description: "Create project-specific settings to override user settings"
  - Label: "Edit file directly"
    Description: "Open the settings file for manual editing"
  - Label: "Done"
    Description: "Exit configuration"
```

**With --edit flag** (interactive editor):
1. Load current settings (or defaults if none exist)
2. If no settings file exists, ask which scope to create (user or project)
3. Enter interactive editing mode using **AskUserQuestion** for each setting:

**Step 1: Enable/disable category organization**
```
Question: "Enable category organization for standalone plans?"
Header: "Organization"
Options:
  - Label: "Enabled (Recommended)"
    Description: "Organize standalone plans by category (migrations/, docs/, etc.)"
  - Label: "Disabled"
    Description: "Don't organize standalone plans by category"
```

**Step 2: Edit each category** (if enabled):
For each category, use **AskUserQuestion**:

```
Question: "Directory name for migration plans? (current: migrations)"
Header: "Migration plans"
Options:
  - Label: "migrations (current)"
    Description: "Use 'migrations' directory"
  - Label: "db-migrations"
    Description: "Use 'db-migrations' directory"
  - Label: "migration"
    Description: "Use 'migration' directory (singular)"
  - Label: "Custom..."
    Description: "Enter a custom directory name"
```

Repeat for: documentation, design, reference, feature, bugfix, standalone

**Step 3: Add custom categories** (optional)
```
Question: "Add custom category types?"
Header: "Custom categories"
Options:
  - Label: "Add one"
    Description: "Define a new category (e.g., 'infrastructure', 'api')"
  - Label: "Done"
    Description: "No more categories, save configuration"
```

If "Add one", ask for:
- Category type (e.g., "infrastructure")
- Directory name (e.g., "infra")
- Keywords for detection (e.g., "infrastructure, infra, k8s, docker")

**Step 4: Save**
4. Show preview of configuration
5. Use **AskUserQuestion** to confirm:

```
Question: "Save this configuration?"
Header: "Confirm"
Options:
  - Label: "Save to project"
    Description: "Save to .claude/plan-manager-settings.json"
  - Label: "Save to user settings"
    Description: "Save to ~/.claude/plan-manager-settings.json"
  - Label: "Discard changes"
    Description: "Don't save, exit without changes"
```

6. Write settings to selected file
7. Confirm: `✓ Saved configuration to <path>`

**With --user flag**:
- Show/edit `~/.claude/plan-manager-settings.json` (user-wide) only

**With --project flag**:
- Show/edit `.claude/plan-manager-settings.json` (project-specific) only

**Examples:**

```bash
/plan-manager config              # Show current config
/plan-manager config --edit       # Interactive editor
/plan-manager config --user       # Show user-wide config
/plan-manager config --project --edit  # Edit project config
```

### `help`

Display command reference with descriptions and examples.

Show a formatted list of all available commands:

```
Plan Manager Commands
═══════════════════════════════════════════════════════════

GETTING STARTED
───────────────
  init <path>
    Initialize or add a master plan
    Options: --flat, --description "text"
    Example: /plan-manager init plans/feature.md

  config
    View/edit category organization settings
    Options: --edit, --user, --project
    Example: /plan-manager config --edit

WORKING WITH PLANS
──────────────────
  branch <phase>
    Create a sub-plan for a phase
    Options: --master <path>
    Example: /plan-manager branch 3

  capture [file]
    Link an existing plan to a phase
    Options: --phase N, --master <path>
    Example: /plan-manager capture plans/fix.md --phase 2

  complete <plan>
    Mark a sub-plan or phase as complete
    Example: /plan-manager complete 3

  merge [file]
    Merge a branch plan's content into the master plan
    Example: /plan-manager merge grid-fixes.md

VIEWING STATUS
──────────────
  status
    Show master plan hierarchy and status
    Options: --all (show all masters)
    Example: /plan-manager status

  overview [directory]
    Discover and visualize all plans
    Example: /plan-manager overview

  list-masters
    Show all tracked master plans
    Example: /plan-manager list-masters

ORGANIZATION
────────────
  organize [directory]
    Auto-organize, link, and clean up plans
    Example: /plan-manager organize

  rename <file> [name]
    Rename a plan and update references
    Example: /plan-manager rename plans/old.md new-name.md

  audit
    Find orphaned plans and broken links
    Example: /plan-manager audit

MULTI-MASTER
────────────
  switch [master]
    Change which master plan is active
    Example: /plan-manager switch

TIPS
────
  • Run '/plan-manager' with no command for interactive menu
  • Use natural language: "capture that plan", "organize my plans"
  • Phase completion is auto-detected when you say "Phase X is complete"
  • Merge branch plans back into master to consolidate updates
  • Category organization keeps different plan types separated
  • Subdirectories keep master plans and sub-plans together

For detailed documentation, see the full plan-manager guide.
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
- "/plan-manager" (no command - shows interactive menu)
- "/plan-manager {command}"
- "use /plan-manager to capture..."
- "show me the plan-manager menu" / "what can plan-manager do"
- "capture that plan" / "capture the plan you just created"
- "link this to the master plan" / "link this back to phase 3"
- "branch from phase 3" / "we need to branch here"
- "merge this branch" / "merge the branch plan" / "merge into master" / "integrate this back"
- "show plan status" / "what's the plan status"
- "audit the plans" / "check for orphaned plans"
- "overview of plans" / "what plans do we have" / "show me all plans"
- "scan the plans directory" / "discover plans"
- "organize my plans" / "organize the plans" / "link related plans" / "clean up plans"
- "migrate plans to subdirectories" / "organize into folders"
- "organize plans by category" / "categorize my plans" / "group plans by type"
- "customize category directories" / "configure plan categories" / "setup plan-manager config"
- "create plan-manager settings" / "configure plan-manager" / "edit plan-manager config"
- "show plan-manager config" / "view configuration" / "what are my category settings"
- "rename that plan" / "rename plan X" / "give that plan a better name"
- "switch master plan" / "switch to different master" / "list master plans"
- "Phase X is complete" / "Step Y is done" / "Phase 4.1 finished" / "completed Step 2.3"
- "plan-manager help" / "show plan-manager commands" / "how do I use plan-manager"

## Error Handling

- If `.claude/plan-manager-state.json` doesn't exist: "No master plan initialized. Run `/plan-manager init <path>` first."
- If master plan file missing: "Master plan not found at {path}. Run `/plan-manager init` to set a new one."
- If phase number invalid: "Phase {N} not found in master plan. Valid phases: 1-{max}"
- If sub-plan already linked: "This file is already linked to Phase {N}. Use `/plan-manager status` to see current state."

## Example Workflows

### Using the Interactive Menu

```
User: "/plan-manager"
Claude: *Shows text-based menu*

        Plan Manager — Available Commands
        ══════════════════════════════════════════════════════════════

        VIEWING & STATUS
        ────────────────
          1. status        Show master plan hierarchy and sub-plan status
          2. overview      Discover all plans in the project and their relationships
          3. list-masters  Show all tracked master plans

        GETTING STARTED
        ───────────────
          4. init          Initialize or add a master plan
          5. config        View/edit category organization settings

        WORKING WITH PLANS
        ──────────────────
          6. branch        Create a sub-plan for the current phase
          7. capture       Link an existing plan to a master plan phase
          8. complete      Mark a sub-plan or phase as complete

        ORGANIZATION
        ────────────
          9. organize      Auto-organize, link, and clean up plans
          10. rename       Rename a plan and update all references
          11. audit        Find orphaned plans and broken links

        MULTI-MASTER
        ────────────
          12. switch       Change which master plan is active

        HELP
        ────
          13. help         Show detailed command reference and examples

        ══════════════════════════════════════════════════════════════

        Please respond with the number or name of the command you'd like to use.

User: "2" (or "overview")
Claude: *Runs overview command and shows plan hierarchy*

        Plans Overview: plans/
        ═══════════════════════════════════════════════════════════

        ACTIVE HIERARCHIES
        ──────────────────

        📋 layout-engine/ (Subdirectory)
        │  └── layout-engine.md (Master Plan)
        │      Status: 3/5 phases complete
        ...
```

```
User: "I'm not sure what to do next with my plans"
Claude: "Let me show you the plan-manager menu."

User: "/plan-manager"
Claude: *Shows text-based menu*

User: "organize" (or "9")
Claude: *Runs organize command, offers to migrate to subdirectories, organize by category, etc.*
```

### Starting Fresh (with Config Setup)

```
User: "Let's implement the new layout engine"
Claude: *Creates plans/layout-engine.md with 5 phases*

User: "/plan-manager init plans/layout-engine.md"
Claude: ✓ Created subdirectory: plans/layout-engine/
        ✓ Moved plans/layout-engine.md → plans/layout-engine/layout-engine.md
        ✓ Initialized master plan: plans/layout-engine/layout-engine.md
        ✓ Added Status Dashboard with 5 phases

        Configure category organization for standalone plans?
        ┌─────────────────────────────────────────────────────────┐
        │ Setup                                                   │
        │                                                         │
        │ ○ Configure now (Recommended)                           │
        │   Set up category directories (migrations/, docs/, etc.)│
        │                                                         │
        │ ○ Use defaults                                          │
        │   Use built-in defaults (migrations, docs, designs,     │
        │   etc.)                                                 │
        │                                                         │
        │ ○ Skip for now                                          │
        │   Don't set up categories yet, I'll configure later     │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Use defaults"*
Claude: ✓ Will use default category directories

        Initialization complete! You can customize category directories
        later by running `/plan-manager config --edit`

User: *Working on Phase 2...*
User: "Wait, we need to rethink the grid system"
Claude: *Creates plans/layout-engine/grid-rethink.md*

User: "/plan-manager capture"
Claude: I see you just created plans/layout-engine/grid-rethink.md. Which phase does this relate to?
User: "Phase 2"
Claude: ✓ Captured plans/layout-engine/grid-rethink.md → linked to Phase 2
        ✓ Updated master plan Status Dashboard

User: "/plan-manager status"
Claude: Master Plan: plans/layout-engine/layout-engine.md (subdirectory: layout-engine/)

        Phase 1: ✅ Complete
        Phase 2: 🔄 In Progress
          └─ plans/layout-engine/grid-rethink.md (In Progress)
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

### Using Flat Structure (Backward Compatibility)

```
User: "I prefer to keep my plans flat in the plans directory"
Claude: "No problem! Use the --flat flag to skip subdirectory creation"

User: "/plan-manager init plans/simple-feature.md --flat"
Claude: ✓ Initialized master plan: plans/simple-feature.md (flat structure)
        ✓ Added Status Dashboard with 3 phases

User: "/plan-manager branch 2"
Claude: *Creates plans/feature-branch.md (in root, not in subdirectory)*
        ✓ Created sub-plan: plans/feature-branch.md (branched from Phase 2)
```

### Organizing by Category

```
User: "I have a lot of migration and design docs mixed in with my plans. Can we organize them?"
Claude: "Absolutely! Let me run the organize command."

User: "/plan-manager organize"
Claude: *Scans plans directory*

        BY CATEGORY (with suggested organization)
        ──────────────────────────────────────────

        📂 migrations/ (suggested category dir)
           📄 database-schema-v2.md — Migration plan
           📄 api-v3-migration.md — Migration plan
           📄 auth-upgrade.md — Migration plan

        📂 docs/ (suggested category dir)
           📄 onboarding-guide.md — Documentation
           📄 api-reference.md — Documentation

        📂 designs/ (suggested category dir)
           📄 new-cache-design.md — Design proposal

Claude: *Uses AskUserQuestion tool*
        ┌─────────────────────────────────────────────────────────┐
        │ Found 6 standalone plans that can be organized by       │
        │ category. Organize them?                                │
        │                                                         │
        │ ○ Organize all (Recommended)                            │
        │   Move plans to category subdirs (migrations/, docs/,   │
        │   designs/)                                             │
        │                                                         │
        │ ○ Review by category                                    │
        │   I'll show each category and you approve or skip       │
        │                                                         │
        │ ○ Skip categories                                       │
        │   Don't organize by category, move on to linking        │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Organize all"*
Claude: ✓ Created plans/migrations/
        ✓ Moved 3 migration plans → plans/migrations/
        ✓ Created plans/docs/
        ✓ Moved 2 documentation plans → plans/docs/
        ✓ Created plans/designs/
        ✓ Moved 1 design plan → plans/designs/

        Organization Complete
        ─────────────────────

        ✓ Organized by category:
          • 3 migration plans → migrations/
          • 2 documentation plans → docs/
          • 1 design plan → designs/

        Current state:
        ├── Master plans: 1 active (using subdirectory)
        ├── Linked sub-plans: 4
        ├── Category-organized: 6
        └── Unlinked: 0
```

### Customizing Category Directories (Interactive Editor)

```
User: "I want my migration plans to go in 'db-migrations' instead of 'migrations'"
Claude: "No problem! Let me open the interactive configuration editor."

User: "/plan-manager config --edit"
Claude: *Runs config command in edit mode*

        Enable category organization for standalone plans?
        ┌─────────────────────────────────────────────────────────┐
        │ Organization                                            │
        │                                                         │
        │ ○ Enabled (Recommended)                                 │
        │   Organize standalone plans by category (migrations/,   │
        │   docs/, etc.)                                          │
        │                                                         │
        │ ○ Disabled                                              │
        │   Don't organize standalone plans by category           │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Enabled"*
Claude: *Asks about each category directory*

        Directory name for migration plans? (current: migrations)
        ┌─────────────────────────────────────────────────────────┐
        │ Migration plans                                         │
        │                                                         │
        │ ○ migrations (current)                                  │
        │   Use 'migrations' directory                            │
        │                                                         │
        │ ○ db-migrations                                         │
        │   Use 'db-migrations' directory                         │
        │                                                         │
        │ ○ migration                                             │
        │   Use 'migration' directory (singular)                  │
        │                                                         │
        │ ○ Custom...                                             │
        │   Enter a custom directory name                         │
        └─────────────────────────────────────────────────────────┘

User: *Selects "db-migrations"*
Claude: *Continues for other categories...*

        [After configuring all categories]

        Configuration Preview:
        ═════════════════════

        Category Organization: ENABLED

        Category Directories:
          documentation  → docs/
          migration      → db-migrations/
          design         → designs/
          reference      → reference/
          feature        → features/
          bugfix         → bug-fixes/
          standalone     → misc/

        Save this configuration?
        ┌─────────────────────────────────────────────────────────┐
        │ Confirm                                                 │
        │                                                         │
        │ ○ Save to project                                       │
        │   Save to .claude/plan-manager-settings.json            │
        │                                                         │
        │ ○ Save to user settings                                 │
        │   Save to ~/.claude/plan-manager-settings.json          │
        │                                                         │
        │ ○ Discard changes                                       │
        │   Don't save, exit without changes                      │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Save to project"*
Claude: ✓ Saved configuration to .claude/plan-manager-settings.json

        Now when you run `/plan-manager organize`, migration plans will be
        moved to plans/db-migrations/ instead of plans/migrations/.
```

### Viewing Current Configuration

```
User: "/plan-manager config"
Claude: *Shows current configuration*

        Plan Manager Configuration
        ══════════════════════════

        Source Priority (highest to lowest):
          1. Project settings: .claude/plan-manager-settings.json [ACTIVE]
          2. User settings: ~/.claude/plan-manager-settings.json [NOT FOUND]
          3. Built-in defaults [FALLBACK]

        Active Configuration (from project settings):
        ─────────────────────────────────────────────

        Category Organization: ENABLED

        Category Directories:
          documentation  → docs/
          migration      → db-migrations/
          design         → designs/
          reference      → reference/
          feature        → features/
          bugfix         → bug-fixes/
          standalone     → misc/

        File Location: .claude/plan-manager-settings.json

        What would you like to do?
        ┌─────────────────────────────────────────────────────────┐
        │ Config actions                                          │
        │                                                         │
        │ ○ Edit categories                                       │
        │   Modify category directory names interactively         │
        │                                                         │
        │ ○ Toggle organization                                   │
        │   Enable/disable category organization                  │
        │                                                         │
        │ ○ Create project config                                 │
        │   Create project-specific settings to override user     │
        │   settings                                              │
        │                                                         │
        │ ○ Edit file directly                                    │
        │   Open the settings file for manual editing             │
        │                                                         │
        │ ○ Done                                                  │
        │   Exit configuration                                    │
        └─────────────────────────────────────────────────────────┘
```

### Adding Custom Categories

```
User: "I have a lot of infrastructure plans. Can I create a custom category for them?"
Claude: "Absolutely! Use the interactive editor to add custom categories."

User: "/plan-manager config --edit"
Claude: *After configuring standard categories...*

        Add custom category types?
        ┌─────────────────────────────────────────────────────────┐
        │ Custom categories                                       │
        │                                                         │
        │ ○ Add one                                               │
        │   Define a new category (e.g., 'infrastructure', 'api') │
        │                                                         │
        │ ○ Done                                                  │
        │   No more categories, save configuration                │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Add one"*
Claude: What type of plans is this category for? (e.g., "infrastructure", "api", "testing")

User: "infrastructure"
Claude: What directory name should be used? (e.g., "infra", "infrastructure")

User: "infra"
Claude: ✓ Added custom category: infrastructure → infra/

        This category will match plans with keywords like "infrastructure",
        "infra", "k8s", "kubernetes", "docker", "deployment"

        Add custom category types?
        [Same options as before...]

User: *Selects "Done"*
Claude: *Shows preview with custom category included*

        Configuration Preview:
        ═════════════════════

        Category Organization: ENABLED

        Category Directories:
          documentation    → docs/
          migration        → migrations/
          design           → designs/
          infrastructure   → infra/        [CUSTOM]
          reference        → reference/
          feature          → features/
          bugfix           → bug-fixes/
          standalone       → misc/

        [Saves configuration...]
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

User: *Selects "Move completed"*
Claude: ✓ Moved hotfix-login.md → completed-plans/hotfix-login.md
        ✓ Moved cache-optimization.md → completed-plans/cache-optimization.md
```

### Organizing Messy Plans

```
User: "Organize my plans"
Claude: *Runs /plan-manager organize*

        Plans Overview: plans/
        ═══════════════════════════════════════════════════════════

        [... displays hierarchy ...]

        Found 1 master plan using flat structure: layout-engine.md

Claude: *Uses AskUserQuestion tool*
        ┌─────────────────────────────────────────────────────────┐
        │ Found 1 master plan using flat structure. Migrate to   │
        │ subdirectories?                                         │
        │                                                         │
        │ ○ Migrate all                                           │
        │   Move each master plan and its sub-plans to subdir     │
        │                                                         │
        │ ○ Review individually                                   │
        │   Ask about each master plan separately                 │
        │                                                         │
        │ ○ Leave flat                                            │
        │   Keep current flat structure, skip migration           │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Migrate all"*
Claude: ✓ Created subdirectory: plans/layout-engine/
        ✓ Moved layout-engine.md → layout-engine/layout-engine.md
        ✓ Moved 3 sub-plans to layout-engine/ subdirectory
        ✓ Updated all references

        BY CATEGORY (with suggested organization)
        ──────────────────────────────────────────

        📂 migrations/ (suggested)
           📄 database-schema-v2.md — Migration plan
           📄 api-v3-migration.md — Migration plan

        📂 docs/ (suggested)
           📄 onboarding-guide.md — Documentation

        STANDALONE PLANS
        ────────────────

        📄 performance-notes.md — mentions "caching", "render optimization"
        📄 edge-cases.md — mentions "grid", "layout edge cases"
        📄 random-ideas.md — miscellaneous notes

Claude: *Uses AskUserQuestion tool*
        ┌─────────────────────────────────────────────────────────┐
        │ Found 3 standalone plans that can be organized by       │
        │ category. Organize them?                                │
        │                                                         │
        │ ○ Organize all (Recommended)                            │
        │   Move plans to category subdirs (migrations/, docs/)   │
        │                                                         │
        │ ○ Review by category                                    │
        │   I'll show each category and you approve or skip       │
        │                                                         │
        │ ○ Skip categories                                       │
        │   Don't organize by category, move on to linking        │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Organize all"*
Claude: ✓ Created category subdirectories
        ✓ Moved 2 migration plans → plans/migrations/
        ✓ Moved 1 documentation plan → plans/docs/

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
