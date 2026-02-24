# Command: init

## Usage

```
init <path> [--description "text"] [--nested]
```

Initialize or add a master plan to tracking.

## Steps

> **Terminology:** Throughout this document, "Phase" also includes "Milestone" or "Step" when used as section headers. Detect which term the plan uses and preserve it. See SKILL.md § Terminology.

1. **Detect plans directory root**:
   - Try reading `.claude/settings.local.json` in the project root, look for `plansDirectory` field
   - If not found, try reading `.claude/settings.json` in the project root, look for `plansDirectory` field
   - If not found, try reading `.claude/plan-manager-state.json`, look for `plansDirectory` field
   - If not found, auto-detect by checking these directories (use first that exists with .md files):
     - `plans/` (relative to project root)
     - `docs/plans/` (relative to project root)
     - `.plans/` (relative to project root)
   - If no directory found and this is a new initialization, ask user via AskUserQuestion which directory to use
   - **CRITICAL**: All plan paths are relative to the project root, NOT to `~/.claude/`
   - **CRITICAL**: Never create plans in `~/.claude/plans/` - that's a fallback location only for plans mode, not for plan-manager
   - Store the detected directory (e.g., "plans", "docs/plans") for use in subsequent steps and in the state file
2. **Detect and rename random/meaningless plan filename** (only if the plan file already exists):
   - Check whether the filename matches random/meaningless name patterns (see `rename.md` § Detecting random/meaningless names), e.g. `giggly-swimming-finch.md`, `lexical-puzzling-emerson.md`, `plan-1.md`
   - If a random name is detected:
     - Read the plan content
     - Analyze to generate 2–3 meaningful filename suggestions based on the title, key topics, and context
     - Use **AskUserQuestion** to offer choices (same flow as `rename` suggest mode):
       ```
       Question: "giggly-swimming-finch.md looks like an auto-generated name. Rename it?"
       Header: "Rename plan"
       Options:
         - Label: "{suggestion-1}.md"
           Description: "Based on {reason}"
         - Label: "{suggestion-2}.md"
           Description: "Based on {reason}"
         - Label: "Enter custom name"
           Description: "Type your own filename"
         - Label: "Keep current name"
           Description: "Don't rename"
       ```
     - If a new name is chosen: rename the file now, before any further steps, and use the new filename throughout all subsequent steps (subdirectory name, state file path, etc.)
3. **Determine subdirectory organization**:
   - By default, new master plans are placed flat in the root of the plans directory (no subdirectory)
   - Use `--nested` flag to immediately create a subdirectory and place the plan inside it
   - If the plan file already exists, preserve its current location
4. **Set up subdirectory structure** (only if `--nested` flag was provided):
   - Extract base name from plan filename (e.g., `layout-engine.md` → `layout-engine`)
   - Create subdirectory: `{plansDirectory}/{baseName}/`
   - If plan file exists at root level, move it to subdirectory:
     - `plans/layout-engine.md` → `plans/layout-engine/layout-engine.md`
   - If plan doesn't exist yet, will be created in subdirectory when user creates it
   - Update all references to the old path (if moved)
5. Check if state file exists:
   - **First master plan**: Create `.claude/plan-manager-state.json` (create `.claude/` directory if needed), mark as active
   - **Additional master plan**: Add to `masterPlans` array
   - **CRITICAL**: Always ensure the state file has a `plansDirectory` field set to the directory detected in step 1
   - If the state file already exists but lacks `plansDirectory`, add it now
6. If multiple masters exist, ask via **AskUserQuestion**:

```
Question: "You have multiple master plans. Make this the active one?"
Header: "Active master"
Options:
  - Label: "Yes, switch to this"
    Description: "Make this the active master plan for commands"
  - Label: "No, keep current"
    Description: "Add to tracking but keep current master active"
```

7. Extract or ask for a brief description to identify this master plan
8. If the plan file already exists and is not in standard format (non-standard headings, missing status icons, missing Status Dashboard, etc.), normalize it:
   - Follow the **normalize command** steps with `--type master`
   - Skip normalize's type-detection step (type is already known: master) and its tracking-offer step (init handles tracking)
   - After normalization the file will have standard `## ⏳ Phase N:` headings and a Status Dashboard
   - If the file is already in standard format but missing only the Status Dashboard, add it directly:

```markdown
## Status Dashboard

| Phase | Description | Status | Sub-plan |
|-------|-------------|--------|----------|
| 1 | [Foundation](#-phase-1-foundation) | ⏳ Pending | — |
| 2 | [Layout Engine](#-phase-2-layout-engine) | ⏳ Pending | — |
...
```

9. Record subdirectory usage in state:
   - If using `--nested` flag: `"subdirectory": "layout-engine"`
   - If flat (default): `"subdirectory": null`

10. **Offer configuration setup** (only if this is the first master plan and no settings exist):
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
  - Label: "Disable categories"
    Description: "Don't use category subdirectories at all — all standalone plans go in the root"
  - Label: "Skip for now"
    Description: "Don't set up categories yet, I'll configure later"
```

   - If "Configure now", run the `config` command interactively
   - If "Use defaults" or "Skip for now", continue without creating settings file
   - If "Disable categories", create `~/.claude/plan-manager-settings.json` with `{"enableCategoryOrganization": false}` and confirm: `✓ Category organization disabled in user settings (~/.claude/plan-manager-settings.json)`

11. Confirm initialization:
   - `✓ Added master plan: {path} (active)` or `✓ Added master plan: {path}`
   - If subdirectory created: `✓ Created subdirectory: plans/{baseName}/`
