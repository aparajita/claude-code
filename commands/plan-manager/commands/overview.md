# Command: overview

## Usage

```
overview [directory]
```

Discover and visualize all plans in the project, regardless of whether they're tracked in state.

**This command works even without initialization** — useful for understanding an existing project's plans.

## Steps

1. **Determine plans directory**:
   - If `directory` argument provided: use that path.
   - Otherwise:
     ```bash
     PLANS_DIR=$(commands/plan-manager/bin/pm-state get-plans-dir)
     ```

2. **Scan all markdown files**:
   ```bash
   commands/plan-manager/bin/pm-files scan --plans-dir "$PLANS_DIR"
   ```
   Returns JSON array of `{path, name}` entries.

3. **Read state and classify each file**:
   ```bash
   STATE=$(commands/plan-manager/bin/pm-state read)
   # For each file:
   commands/plan-manager/bin/pm-md classify --file "$FILE_PATH"
   ```
   Classify each file:

   | Classification | Detection Criteria |
   |----------------|-------------------|
   | **Master Plan** | Has phases/steps (## Phase N or ## Step N), may have Status Dashboard |
   | **Sub-plan (linked)** | Has `**Parent:**` header pointing to a master |
   | **Sub-plan (orphaned)** | Looks like a sub-plan but no Parent reference or parent doesn't exist |
   | **Standalone Plan** | Has plan structure but no phase/step hierarchy |
   | **Completed** | Has `**Status:** Completed` or all phases/steps marked ✅ |
   | **Reference Doc** | Not a plan — just documentation |

4. **Build relationship graph** using state data:
   - Map parent → children relationships from `pm-state read`.
   - Detect orphaned/broken links by comparing state to scanned files.

5. **Display ASCII hierarchy chart** (see below for format).

6. **Interactive cleanup for orphaned/completed**:

   If orphaned, unlinked completed, or uncategorized standalone plans are found, use the **AskUserQuestion tool**:
   ```
   Question: "Found N orphaned plans, M completed plans, and K uncategorized standalone plans. How would you like to handle them?"
   Header: "Cleanup"
   Options:
     - Label: "Organize all"
       Description: "Categorize standalone plans, analyze content, suggest links for related plans, then handle completed/orphaned"
     - Label: "Review individually"
       Description: "I'll show a summary of each plan and ask what to do with it one by one"
     - Label: "Move completed"
       Description: "Move completed unlinked plans to plans/completed/ directory"
     - Label: "Leave as-is"
       Description: "Just show the report, don't take any action"
   ```

   Based on selection:
   - **Organize all**: Switch to the `organize` workflow.
   - **Move completed**:
     ```bash
     commands/plan-manager/bin/pm-files archive --file "$COMPLETED_PLAN" --plans-dir "$PLANS_DIR"
     ```

7. **Output state suggestion**:

   If no state file exists but master plans were detected:
   ```
   💡 Tip: Run `/plan-manager init plans/layout-engine.md` to start tracking this plan hierarchy.
   ```

## Output Format

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
│  ├── Phase 3: ⏸️ Blocked by Phase 2
│  ├── Phase 4: ⏳ Pending
│  └── Phase 5: ⏳ Pending

ORPHANED / UNLINKED
───────────────────

⚠️  old-layout-approach.md
    Claims parent: layout-engine.md → Phase 2
    But not referenced in parent's Status Dashboard

SUMMARY
───────

Total plans: 8
├── Master plans: 1 active
├── Linked sub-plans: 2
└── Orphaned/Unlinked: 1
```
