# Command: prune

## Usage

```
prune
```

Review completed plans and bulk-clean them by deleting or keeping each one.

**Purpose**: First handle already-archived plans in `plans/completed/` (delete or keep), then optionally review active completed plans still in their working locations. Unlike `archive` (which handles one plan at a time), `prune` lets you review and clean up all completed plans in one pass.

## Steps

> **Terminology:** Throughout this document, "Phase" also includes "Milestone" or "Step" when used as section headers. Detect which term the plan uses and preserve it. See SKILL.md § Terminology.

### 1. Scan for Plans in `plans/completed/`

Scan the `plans/completed/` directory recursively for all `.md` files.

If none found, skip to Step 3.

### 2. Present Each Archived Plan for Review

For each plan in `plans/completed/` (one at a time), using **AskUserQuestion**:

1. **Read the plan file** to get its title/heading

2. **Get creation date** (if available):
   - Check the plan file for a `**Created:**` or `**Captured:**` header field
   - If not in the file, check the state file entry's `createdAt` field
   - Format as a human-readable date if found (e.g., "Created: 2026-01-15")

3. **Completeness check**: Verify all phases/steps are actually marked ✅ in the file content
   - Count total phases/steps and how many are marked ✅
   - If not fully complete, include a warning in the question text

4. **Ask using AskUserQuestion**:
   ```
   Question: "{plan-name} (archived)\n{created-date-if-available}\n{warning-if-applicable}\nWhat should happen to this plan?"
   Header: "Prune plan"
   Options:
     - Label: "Delete"
       Description: "Permanently remove the file"
     - Label: "Keep"
       Description: "Leave in plans/completed/"
   ```

   Where `{created-date-if-available}` is e.g. `"Created: 2026-01-15"` or omitted if unknown, and `{warning-if-applicable}` is included only when the plan is not fully complete, e.g.:
   `"Note: This plan has 2/5 phases marked complete but is listed as Completed."`

### 3. Offer to Prune Active Completed Plans

After finishing with archived plans (or immediately if none were found), ask:

```
Question: "Review active completed plans (still in their working location)?"
Header: "Active completed plans"
Options:
  - Label: "Yes, scan for them"
    Description: "Find completed sub-plans/branches in state file and fully-complete master plans"
  - Label: "No, stop here"
    Description: "Done pruning"
```

If "No, stop here": skip to Step 6 (Summary).

### 4. Scan for Active Completed Plans

Gather from the state file, deduplicating by file path:

1. **Sub-plans/branches**: All entries with `status: "completed"` whose file is NOT in `plans/completed/`
2. **Master plans**: Master plans where ALL phases in the file are marked ✅ Complete and the file is NOT in `plans/completed/`

If none found:
```
No active completed plans found.
```
Then skip to Step 6 (Summary).

### 5. Present Each Active Completed Plan for Review

For each active completed plan (one at a time), using **AskUserQuestion**:

1. **Read the plan file** to get its title/heading

2. **Get creation date**: same as Step 2.2 above

3. **Completeness check**: same as Step 2.3 above

4. **Ask using AskUserQuestion**:
   ```
   Question: "{plan-name} ({path})\n{created-date-if-available}\n{warning-if-applicable}\nWhat should happen to this plan?"
   Header: "Prune plan"
   Options:
     - Label: "Archive"
       Description: "Move to plans/completed/ directory"
     - Label: "Delete"
       Description: "Permanently remove the file"
     - Label: "Keep"
       Description: "Leave in current location"
   ```

### 6. Perform Chosen Actions

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

### 7. Summary

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
Claude: *Scans plans/completed/, finds 2 archived plans*

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
Claude: *Presents second archived plan, user selects "Keep"*

        *All archived plans reviewed. Now asks about active completed plans:*

        Review active completed plans (still in their working location)?
        ┌─────────────────────────────────────────────────────────┐
        │ Active completed plans                                  │
        │                                                         │
        │ ○ Yes, scan for them                                    │
        │   Find completed sub-plans/branches in state file and   │
        │   fully-complete master plans                           │
        │                                                         │
        │ ○ No, stop here                                         │
        │   Done pruning                                          │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Yes, scan for them"*
Claude: *Finds 1 active completed plan*

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
Claude: Pruned 3 plans: 1 deleted, 1 archived, 1 kept
```

## Notes

- Plans are presented one at a time to avoid overwhelming the user.
- The completeness check helps catch plans that were marked complete prematurely.
- Archive uses the same subdirectory-mirroring logic as the `archive` command.
- Empty directories left after deletions are cleaned up automatically.
- State file entries are updated or removed as appropriate for each action.
