# Command: organize

## Usage

```
organize [directory] [--nested]
```

Automatically analyze and link related plans together, rename poorly-named files, then handle orphaned/completed plans.

**This is the "just fix it" command** — it does everything `overview` does, plus actively organizes.

## Steps

1. **Run full overview scan** (same as `overview` steps 1-4)

2. **Load category organization settings**:
   - Check for `~/.claude/plan-manager-settings.json` (user global)
   - Check for `<project>/.claude/plan-manager-settings.json` (project-specific, overrides user)
   - If neither exists, use default category directories (docs, migrations, designs, features, reference, misc)
   - **Note**: Settings file is optional and will NOT be auto-created
   - If `enableCategoryOrganization` is false in settings, skip category organization steps

3. **Detect solo nested master plans and offer flattening** (unless `--nested` flag is passed):
   - Scan for master plans that are in a subdirectory (`subdirectory` field is non-null) but have **no linked sub-plans** — i.e., the master is the only file in its subdirectory and nesting serves no purpose
   - Skip master plans that have sub-plans (nesting is justified — leave them alone)
   - If `--nested` flag is passed, skip this step entirely
   - If solo nested masters found, use **AskUserQuestion tool**:

```
Question: "Found 2 master plans nested in subdirectories with no sub-plans. Flatten them?"
Header: "Structure"
Options:
  - Label: "Flatten all (Recommended)"
    Description: "Move each lone master plan to the plans root and remove its empty subdirectory"
  - Label: "Review individually"
    Description: "I'll ask about each master plan separately"
  - Label: "Keep nested"
    Description: "Leave them in their subdirectories"
```

   - **If "Flatten all"**: For each solo nested master plan:
     - Move master plan to root: `plans/layout-engine/layout-engine.md` → `plans/layout-engine.md`
     - Remove now-empty subdirectory
     - Update all references (state file, links in plans)
     - Set state file `subdirectory` field to `null`

   - **If "Review individually"**: For each, use **AskUserQuestion**:
     ```
     Question: "Flatten 'layout-engine' to the plans root? (no sub-plans)"
     Header: "Flatten master"
     Options:
       - Label: "Yes, flatten"
         Description: "Move plans/layout-engine/layout-engine.md → plans/layout-engine.md"
       - Label: "Keep nested"
         Description: "Leave this master plan in its subdirectory"
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
   - Group by detected category (documentation, migration, design, feature, etc.)
   - Use default category directories (docs, migrations, designs, features, etc.) unless custom settings exist
   - If categorized plans found, use **AskUserQuestion tool**:

```
Question: "Found 8 standalone plans that can be organized by category. Organize them?"
Header: "Categories"
Options:
  - Label: "Organize all (Recommended)"
    Description: "Move plans to category subdirectories (migrations/, docs/, designs/, features/, etc.)"
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

9. **After linking, handle orphaned/completed plans**:
   - For remaining orphans, use **AskUserQuestion** to offer: link to a phase, move to a category directory, archive, delete, or skip
   - For completed unlinked plans, use **AskUserQuestion** to offer: move to `plans/completed/`, delete, or leave in place

10. **Summary output**:

```
Organization Complete
─────────────────────

✓ Flattened solo nested masters:
  • layout-engine/layout-engine.md → layout-engine.md

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
  • hotfix-login.md → plans/completed/hotfix-login.md

⚠️ 1 plan left unlinked (user skipped):
  • random-ideas.md

Current state:
├── Master plans: 1 active (flat)
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
