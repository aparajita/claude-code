# Command: organize

## Usage

```
organize [directory] [--nested]
```

Automatically analyze and link related plans together, rename poorly-named files, then handle orphaned/completed plans.

**This is the "just fix it" command** — it does everything `overview` does, plus actively organizes.

## Steps

### Phase 1: Scan Everything (no changes yet)

1. **Run full overview scan** (same as `overview` steps 1-4)

2. **Load category organization settings**:
   - Check for `~/.claude/plan-manager-settings.json` (user global)
   - Check for `<project>/.claude/plan-manager-settings.json` (project-specific, overrides user)
   - If neither exists, use default category directories (docs, migrations, designs, features, reference, misc)
   - **Note**: Settings file is optional and will NOT be auto-created
   - If `enableCategoryOrganization` is false in settings, skip category organization steps

3. **Detect solo nested master plans** (unless `--nested` flag is passed):
   - Scan for master plans that are in a subdirectory (`subdirectory` field is non-null) but have **no linked sub-plans** — i.e., the master is the only file in its subdirectory and nesting serves no purpose
   - Skip master plans that have sub-plans (nesting is justified — leave them alone)
   - For each, compute the flatten target: move **up one directory level** (to the parent of its current subdirectory). Examples:
     - `plans/layout-engine/layout-engine.md` → `plans/layout-engine.md`
     - `plans/migrations/auth/auth.md` → `plans/migrations/auth.md`

4. **Detect randomly-named plans**:
   - Scan for files with random/meaningless names (see `rename` command for patterns)
   - For each, analyze content and propose a meaningful name

5. **Detect category organization opportunities** (if `enableCategoryOrganization` is true):
   - Identify standalone plans that match category patterns
   - Group by detected category (docs, migrations, designs, features, etc.)
   - Use custom category directory names from settings if available, otherwise defaults

6. **Analyze relationships between unlinked plans**:
   - For each standalone or orphaned plan, analyze content
   - Look for references to phases, topics, or keywords that match master plan phases
   - Build a list of suggested linkages
   - Plans in category directories can still be linked to master plan phases if appropriate

7. **Detect broken state entries**:
   - Scan state file for entries referencing files that no longer exist on disk
   - Scan state file for entries with invalid or inconsistent data (e.g., sub-plan listed under wrong master, circular links)
   - These will be listed under FIX for removal or correction

8. **Identify orphaned/completed plans**:
   - Remaining orphans with no obvious link suggestion
   - Completed unlinked plans that could move to `plans/completed/`

---

### Phase 2: Present the Full Plan

After scanning, present **all proposed changes in one consolidated view** before doing anything. Output this as plain text (not via AskUserQuestion):

```
Organization Plan
─────────────────

FLATTEN (2 solo nested masters)
  plans/layout-engine/layout-engine.md → plans/layout-engine.md
  plans/migrations/auth/auth.md        → plans/migrations/auth.md

RENAME (2 randomly-named files)
  lexical-puzzling-emerson.md → grid-edge-cases.md   (based on content: grid edge case test notes)
  abstract-floating-jenkins.md → performance-notes.md (based on content: render performance analysis)

CATEGORIZE (5 standalone plans → category subdirs)
  database-schema-v2.md  → migrations/
  api-v3-migration.md    → migrations/
  auth-upgrade.md        → migrations/
  api-overview.md        → docs/
  architecture.md        → docs/

LINK (2 plans → master plan phases)
  performance-notes.md → Phase 4: Performance Optimization
  grid-edge-cases.md   → Phase 2: Grid Engine

FIX (2 broken state entries)
  ghost-refactor.md — file not found on disk, remove from state
  auth-overhaul.md  — listed as sub-plan of both master-a and master-b, unlink from master-b

ARCHIVE (1 completed unlinked plan)
  hotfix-login.md → plans/completed/hotfix-login.md

NO ACTION (1 plan — no clear category or phase match)
  random-ideas.md
```

If nothing was found, output:
```
Nothing to organize — all plans are already structured.
```
and stop.

Then ask for approval via **AskUserQuestion**:

```
Question: "Proceed with this organization plan?"
Header: "Organize"
Options:
  - Label: "Apply all (Recommended)"
    Description: "Execute every change listed above"
  - Label: "Review each section"
    Description: "I'll walk through each category of changes and you approve or skip"
  - Label: "Cancel"
    Description: "Don't make any changes"
```

---

### Phase 3: Execute

**If "Apply all"**: Execute all proposed changes in order: fix, flatten, rename, categorize, link, archive. Update all references (state file, links in plans) after each move. Output the summary (see below).

**If "Review each section"**: Walk through each section that has proposed changes, one at a time, using **AskUserQuestion**:

For FIX:
```
Question: "Fix 2 broken state entries?"
Header: "Fix"
Options:
  - Label: "Fix all"
    Description: "Remove ghost entries and correct inconsistent links"
  - Label: "Review individually"
    Description: "Ask about each broken entry separately"
  - Label: "Skip fixing"
    Description: "Leave the state file as-is"
```

For FLATTEN:
```
Question: "Flatten 2 solo nested masters (no sub-plans)?"
Header: "Flatten"
Options:
  - Label: "Flatten all"
    Description: "plans/layout-engine/layout-engine.md → plans/layout-engine.md, ..."
  - Label: "Review individually"
    Description: "Ask about each one separately"
  - Label: "Skip flattening"
    Description: "Leave them nested"
```

For RENAME:
```
Question: "Rename 2 randomly-named plans?"
Header: "Rename"
Options:
  - Label: "Rename all"
    Description: "Accept all suggested names"
  - Label: "Review individually"
    Description: "Approve each rename separately"
  - Label: "Skip renaming"
    Description: "Keep current names"
```

For CATEGORIZE:
```
Question: "Move 5 plans to category subdirectories?"
Header: "Categorize"
Options:
  - Label: "Move all"
    Description: "migrations/ (3), docs/ (2)"
  - Label: "Review by category"
    Description: "Approve each category separately"
  - Label: "Skip categorizing"
    Description: "Leave plans where they are"
```

For LINK:
```
Question: "Link 2 plans to master plan phases?"
Header: "Link"
Options:
  - Label: "Link all"
    Description: "performance-notes.md → Phase 4, grid-edge-cases.md → Phase 2"
  - Label: "Review individually"
    Description: "Approve each link separately"
  - Label: "Skip linking"
    Description: "Leave them unlinked"
```

For ARCHIVE:
```
Question: "Archive 1 completed unlinked plan?"
Header: "Archive"
Options:
  - Label: "Archive it"
    Description: "hotfix-login.md → plans/completed/hotfix-login.md"
  - Label: "Skip"
    Description: "Leave it in place"
```

When reviewing individually within any section, use a per-item **AskUserQuestion** with "Yes" / "Skip" options and the specific move/rename/link shown in the description.

**When executing LINK**: For each plan being linked, follow the **capture command** steps to normalize the file and add the parent header block (skipping capture's file-detection and phase-selection steps, since those are already determined). This delegates to the **normalize command** internally, same as capture does.

---

### Phase 4: Summary

After all changes are applied:

```
Organization Complete
─────────────────────

✓ Flattened 2 solo nested masters:
  • plans/layout-engine/layout-engine.md → plans/layout-engine.md
  • plans/migrations/auth/auth.md → plans/migrations/auth.md

✓ Renamed 2 plans:
  • lexical-puzzling-emerson.md → grid-edge-cases.md
  • abstract-floating-jenkins.md → performance-notes.md

✓ Organized by category:
  • 3 migration plans → migrations/
  • 2 documentation plans → docs/

✓ Linked 2 plans to master:
  • performance-notes.md → Phase 4: Performance Optimization
  • grid-edge-cases.md → Phase 2: Grid Engine

✓ Fixed 2 broken state entries:
  • ghost-refactor.md — removed missing file from state
  • auth-overhaul.md — unlinked from duplicate master

✓ Archived 1 completed plan:
  • hotfix-login.md → plans/completed/hotfix-login.md

⚠️ 1 plan left unchanged (no clear category or phase match):
  • random-ideas.md

Current state:
├── Master plans: 1 active (flat)
├── Linked sub-plans: 5
├── Category-organized: 5
└── Unlinked: 1
```

Omit any section that had no changes.
