# Plan Organization

This document covers how plans are organized in directories, including subdirectories, categories, and completed plans.

## Subdirectory Organization

### Master Plan Subdirectories

**New master plans automatically use subdirectory organization** to keep related plans together:

- Master plan `layout-engine.md` → creates `plans/layout-engine/` subdirectory
- Master and all sub-plans live in the same subdirectory: `plans/layout-engine/layout-engine.md`, `plans/layout-engine/sub-plan-1.md`, etc.
- Completed plans mirror this structure: `plans/completed/layout-engine/sub-plan-1.md`
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
    "feature": "features",
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

- If no settings file exists, commands use default category directories (docs, migrations, designs, features, etc.)
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

## Completed Plans Directory

Completed plans can be moved to a `completed/` subdirectory within the plans directory to keep the working plans directory clean:

- If `plansDirectory` is `plans/`, completed plans move to `plans/completed/`
- If `plansDirectory` is `docs/plans/`, completed plans move to `docs/plans/completed/`
- The directory is created as a subdirectory of the plans directory
- **Subdirectory structure is mirrored**:
  - Master plan subdirectories: `plans/layout-engine/sub-plan.md` → `plans/completed/layout-engine/sub-plan.md`
  - Category subdirectories: `plans/migrations/db-upgrade.md` → `plans/completed/migrations/db-upgrade.md`
  - Flat plans: `plans/sub-plan.md` → `plans/completed/sub-plan.md`
- Completed plans retain their original filename (no datestamp prefix needed)
- Subdirectories in completed/ are created automatically as needed
- This preserves the organizational structure even after completion, making it easy to find old plans

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
     → Asks about moving to plans/completed/
```

**Important:**
- Don't wait for the user to manually invoke the command
- Invoke it in the SAME response where you declare completion
- This keeps plan state automatically synchronized with actual work
- The user never needs to manually track completions
