# Command: init

## Usage

```
init <path> [--description "text"] [--flat]
```

Initialize or add a master plan to tracking.

## Steps

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
   - Read all phase headings from the plan (e.g., `## Phase 1: Foundation`, `## Phase 2: Layout Engine`)
   - For each phase, extract the description/title (the part after the colon)
   - For each phase, create an anchor link by converting the full heading to lowercase and replacing spaces with hyphens
   - Create the Status Dashboard table with linked description entries:

```markdown
## Status Dashboard

| Phase | Description | Status | Sub-plan |
|-------|-------------|--------|----------|
| 1 | [Foundation](#phase-1--foundation) | ⏳ Pending | — |
| 2 | [Layout Engine](#phase-2--layout-engine) | ⏳ Pending | — |
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
