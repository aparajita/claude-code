# Command: prune

## Usage

```
prune
```

Review all completed plans and bulk-clean them by deleting, archiving, or keeping each one.

**Purpose**: Scan for completed plans across all locations — archived plans in `plans/completed/`, completed sub-plans/branches in the state file, and fully-complete master plans — then present each one for disposition. Unlike `archive` (which handles one plan at a time), `prune` lets you review and clean up all completed plans in one pass.

## Steps

> **Terminology:** Throughout this document, "Phase" also includes "Milestone" or "Step" when used as section headers. Detect which term the plan uses and preserve it. See SKILL.md § Terminology.

### 1. Scan for Completed Plans

Gather completed plans from three sources, deduplicating by file path:

1. **State file — sub-plans/branches**: All entries with `status: "completed"`
2. **State file — master plans**: Master plans where ALL phases in the file are marked ✅ Complete
3. **Filesystem — archived plans**: All `.md` files in `plans/completed/` directory (recursively)

Deduplicate: a plan may appear in both the state file and `plans/completed/`. Use the resolved file path as the dedup key.

### 2. If No Completed Plans Found

Report and exit:
```
No completed plans found. Nothing to prune.
```

### 3. Present Each Plan for Review

For each completed plan (one at a time), using **AskUserQuestion**:

1. **Read the plan file** to get its title/heading

2. **Completeness check**: Verify all phases/steps are actually marked ✅ in the file content
   - Count total phases/steps and how many are marked ✅
   - If not fully complete, include a warning in the question text

3. **Determine location**:
   - **In `plans/completed/`**: The plan is already archived
   - **In working location**: The plan is still in its original location

4. **Ask using AskUserQuestion** with options based on location:

   For plans in `plans/completed/` (already archived):
   ```
   Question: "{plan-name} (archived)\n{warning-if-applicable}\nWhat should happen to this plan?"
   Header: "Prune plan"
   Options:
     - Label: "Delete"
       Description: "Permanently remove the file"
     - Label: "Keep"
       Description: "Leave in plans/completed/"
   ```

   For plans in working locations:
   ```
   Question: "{plan-name} ({path})\n{warning-if-applicable}\nWhat should happen to this plan?"
   Header: "Prune plan"
   Options:
     - Label: "Archive"
       Description: "Move to plans/completed/ directory"
     - Label: "Delete"
       Description: "Permanently remove the file"
     - Label: "Keep"
       Description: "Leave in current location"
   ```

   Where `{warning-if-applicable}` is included only when the plan is not fully complete, e.g.:
   `"Note: This plan has 2/5 phases marked complete but is listed as Completed."`

### 4. Perform Chosen Action

For each plan, perform the action the user selected:

**Delete**:
- Remove the plan file
- If the plan is in the state file, remove or update the entry
- If the plan is a master plan with a subdirectory, warn before deleting the subdirectory
- Clean up empty directories after deletion

**Archive** (only for plans in working locations):
- Move to `plans/completed/` mirroring subdirectory structure (same logic as `archive` command):
  - If plan is in `plans/layout-engine/sub-plan.md`, move to `plans/completed/layout-engine/sub-plan.md`
  - If plan is in `plans/sub-plan.md` (flat), move to `plans/completed/sub-plan.md`
  - Create subdirectory in `plans/completed/` if needed
- If the plan is a master plan with a subdirectory, move the entire subdirectory to `plans/completed/`
- Update state file paths

**Keep**:
- No action

Track each action for the summary.

### 5. Summary

After all plans have been reviewed, report what was done:

```
Pruned {total} plans: {deleted} deleted, {archived} archived, {kept} kept
```

If no actions were taken (all kept):
```
No changes made. All {total} completed plans kept as-is.
```

## Example

```
User: "/plan-manager prune"
Claude: *Scans for completed plans, finds 4*

        api-redesign.md (plans/completed/layout-engine/api-redesign.md)
        What should happen to this plan?
        ┌─────────────────────────────────────────────────────────┐
        │ Prune plan                                              │
        │                                                         │
        │ ○ Delete                                                │
        │   Permanently remove the file                           │
        │                                                         │
        │ ○ Keep                                                  │
        │   Leave in plans/completed/                             │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Delete"*
Claude: *Presents next plan*

        old-migration.md (plans/old-migration.md)
        Note: This plan has 3/5 phases marked complete but is listed as Completed.
        What should happen to this plan?
        ┌─────────────────────────────────────────────────────────┐
        │ Prune plan                                              │
        │                                                         │
        │ ○ Archive                                               │
        │   Move to plans/completed/ directory                    │
        │                                                         │
        │ ○ Delete                                                │
        │   Permanently remove the file                           │
        │                                                         │
        │ ○ Keep                                                  │
        │   Leave in current location                             │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Archive"*
Claude: *Continues through remaining plans...*

        Pruned 4 plans: 1 deleted, 1 archived, 2 kept
```

## Notes

- Plans are presented one at a time to avoid overwhelming the user.
- The completeness check helps catch plans that were marked complete prematurely.
- Archive uses the same subdirectory-mirroring logic as the `archive` command.
- Empty directories left after deletions are cleaned up automatically.
- State file entries are updated or removed as appropriate for each action.
