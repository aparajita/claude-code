# Command: organize

## Usage

```
organize [directory] [--nested]
```

Automatically analyze and link related plans together, rename poorly-named files, then handle orphaned/completed plans.

**This is the "just fix it" command** — it does everything `overview` does, plus actively organizes.

## Steps

1. **Detect plans directory**:
   ```bash
   PLANS_DIR=$(commands/plan-manager/bin/pm-state get-plans-dir)
   ```

2. **Load category organization settings**:
   ```bash
   commands/plan-manager/bin/pm-settings load
   ```
   If `enableCategoryOrganization` is false in settings, skip category organization steps.

3. **Detect solo nested master plans and offer flattening** (unless `--nested` flag is passed):
   ```bash
   commands/plan-manager/bin/pm-files detect-solo-nested --plans-dir "$PLANS_DIR"
   ```
   If solo nested masters found, use **AskUserQuestion tool**:
   ```
   Question: "Found N master plans nested in subdirectories with no sub-plans. Flatten them?"
   Header: "Structure"
   Options:
     - Label: "Flatten all (Recommended)"
       Description: "Move each lone master plan to the plans root and remove its empty subdirectory"
     - Label: "Review individually"
       Description: "I'll ask about each master plan separately"
     - Label: "Keep nested"
       Description: "Leave them in their subdirectories"
   ```
   - **If "Flatten all"**: For each solo nested master:
     ```bash
     commands/plan-manager/bin/pm-files flatten-master --master "$MASTER_PATH" --plans-dir "$PLANS_DIR"
     # Returns JSON with oldPath and newPath
     # Update links in any files that referenced the old path:
     # (scan all plans and update references using pm-md update-links)
     ```
   - **If "Review individually"**: Ask per master, then flatten each accepted one.

4. **Detect and offer to rename randomly-named plans**:
   ```bash
   # For each .md file found by pm-files scan:
   commands/plan-manager/bin/pm-md detect-random-name --filename "$(basename $FILE)"
   ```
   If found, use **AskUserQuestion tool** to suggest meaningful renames based on content analysis.

5. **Organize standalone plans by category** (if `enableCategoryOrganization` is true):
   - For each untracked plan:
     ```bash
     commands/plan-manager/bin/pm-md classify --file "$FILE"
     ```
   - Group by detected category.
   - Use **AskUserQuestion** to offer organizing:
     ```
     Question: "Found N standalone plans that can be organized by category. Organize them?"
     Header: "Categories"
     Options:
       - Label: "Organize all (Recommended)"
         Description: "Move plans to category subdirectories (migrations/, docs/, designs/, features/, etc.)"
       - Label: "Review by category"
         Description: "I'll show each category and you approve or skip"
       - Label: "Skip categories"
         Description: "Don't organize by category, move on to linking"
     ```
   - For each plan to organize:
     ```bash
     # Determine category dir from settings
     CATEGORY_DIR="$PLANS_DIR/$CATEGORY_SUBDIR"
     mkdir -p "$CATEGORY_DIR"
     commands/plan-manager/bin/pm-files move-to-subdir \
       --file "$FILE" --subdirectory "$CATEGORY_SUBDIR" --plans-dir "$PLANS_DIR"
     ```

6. **Analyze relationships between unlinked plans** — read each plan, analyze content, build suggested linkages to master plan phases.

7. **Present linking suggestions** via AskUserQuestion; for approved links, add parent header and update master:
   ```bash
   commands/plan-manager/bin/pm-md add-parent-header --file "$PLAN" --type "Sub-plan" --parent "$MASTER" --phase <N>
   commands/plan-manager/bin/pm-md update-phase-icon --file "$MASTER" --phase <N> --icon "📋"
   commands/plan-manager/bin/pm-md update-dashboard-row --file "$MASTER" --phase <N> --status "📋 Sub-plan" --subplan-link "..."
   commands/plan-manager/bin/pm-state add-subplan --path "$PLAN" --parent-plan "$MASTER" --phase <N> --type "sub-plan"
   ```

8. **Find orphaned/completed plans**:
   ```bash
   commands/plan-manager/bin/pm-files find-orphans --plans-dir "$PLANS_DIR"
   ```
   For remaining orphans, use **AskUserQuestion** to offer: link to a phase, move to a category directory, archive, delete, or skip.

9. **Summary output**:
   ```
   Organization Complete
   ─────────────────────

   ✓ Flattened solo nested masters:
     • layout-engine/layout-engine.md → layout-engine.md

   ✓ Organized by category (using defaults):
     • 3 migration plans → migrations/
     • 2 documentation plans → docs/

   ✓ Renamed 2 plans:
     • lexical-puzzling-emerson.md → grid-edge-cases.md

   ✓ Linked 2 plans to master:
     • performance-notes.md → Phase 4

   Current state:
   ├── Master plans: 1 active
   ├── Linked sub-plans: 5
   ├── Category-organized: 6
   └── Unlinked: 1
   ```
