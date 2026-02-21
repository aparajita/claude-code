# Command: archive

## Usage

```
archive [file-or-phase]
```

Archive a completed plan that was previously left in place.

**Purpose**: After marking a plan complete, users can choose to "Leave in place" to keep the plan file for now. This command allows archiving or deleting those completed plans later without having to mark them complete again.

**Accepts:** phase numbers (3), subphases (4.1), step numbers (2), substeps (2.3), file paths, or no argument (interactive selection)

## Steps

**Without argument (interactive mode):**
1. `MASTER=$(commands/plan-manager/bin/pm-state get-active-master)`
2. `PLANS_DIR=$(commands/plan-manager/bin/pm-state get-plans-dir)`
3. Read state: `commands/plan-manager/bin/pm-state list-subplans --master "$MASTER"` — filter for completed ones.
4. Also check if master plan itself is complete (all phases ✅).
5. Use **AskUserQuestion** to select which plan to archive.

**With argument:**
1. If argument is a number/subphase, find plan for that phase/step; otherwise use as file path.
2. Validate the plan exists and is marked as completed.

**Archive workflow:**

1. **Determine plan type**: master plan or sub-plan/branch.

2. **Ask about plan disposition** using **AskUserQuestion**:

   For master plan:
   ```
   Question: "The master plan is complete. What should happen to it?"
   Header: "Master plan cleanup"
   Options:
     - Label: "Archive it"
       Description: "Move to plans/completed/ directory to keep it for reference"
     - Label: "Delete it"
       Description: "Remove the file entirely"
     - Label: "Leave in place"
       Description: "Keep in current location for now"
   ```

   For sub-plan/branch (use plan type in question):
   ```
   Question: "What should happen to the completed {type}?"
   Header: "Plan cleanup"
   Options:
     - Label: "Archive it"
       Description: "Move to plans/completed/ directory to keep it for reference"
     - Label: "Delete it"
       Description: "Remove the file entirely (content is in master plan)"
     - Label: "Leave in place"
       Description: "Keep in current location for now"
   ```

3. **Perform the action**:

   **If "Archive it"**:
   ```bash
   commands/plan-manager/bin/pm-files archive --file "$FILE" --plans-dir "$PLANS_DIR"
   # Returns JSON with newPath
   commands/plan-manager/bin/pm-state update-subplan --path "$FILE" --new-path "$NEW_PATH"
   # Or for master: update-master --path "$FILE" --new-path "$NEW_PATH"
   ```
   - For master plans with subdirectory: the entire subdirectory structure mirrors to completed/ automatically (handled by pm-files archive logic).
   - Update links in related plans:
     ```bash
     # For each related plan:
     commands/plan-manager/bin/pm-md update-links --file "$RELATED" --old "$OLD_PATH" --new "$NEW_PATH"
     ```

   **If "Delete it"**:
   - For master plans: if linked sub-plans exist, warn user and ask whether to also delete them.
   - Delete the file; update state:
     ```bash
     commands/plan-manager/bin/pm-state remove-subplan --path "$FILE"
     # Or for master, manually update state JSON to remove master entry
     ```

   **If "Leave in place"**: Do nothing.

4. **Confirm action**:
   - If archived: `✓ Archived {plan-name} to {plans-dir}/completed/{path}`
   - If deleted: `✓ Deleted {plan-name}`
   - If left in place: `Plan remains at {current-path}`

## Notes

- This command only works on completed plans. For plans still in progress, use `complete` first.
- Archiving preserves the file for reference while cleaning up the active working directory.
- Deleted plans are permanently removed — ensure content is merged or backed up first.
- When archiving a master plan with a subdirectory, the entire subdirectory structure moves to completed/.
