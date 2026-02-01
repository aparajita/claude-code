# Command: organize

## Usage

```
organize [directory]
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
  • hotfix-login.md → plans/completed/hotfix-login.md

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
