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
1. Read state file to get active master plan
2. List all completed sub-plans and branches linked to the active master that have not been archived or deleted
3. Check if the master plan itself is complete (all phases marked ✅ Complete) and still in its original location
4. Use **AskUserQuestion** to select which plan to archive:
   ```
   Question: "Which completed plan do you want to archive?"
   Header: "Select plan"
   Options:
     - Label: "Master plan: {master-name}.md"
       Description: "The master plan itself (Status: Complete)"
     - Label: "{plan-1-name}.md"
       Description: "Phase {N}: {brief-description} (Type: {type}, Status: Completed)"
     - Label: "{plan-2-name}.md"
       Description: "Phase {M}: {brief-description} (Type: {type}, Status: Completed)"
     [... up to 4 total plans, use "Other" for text input if more]
   ```

**With argument:**
1. If argument is a number/subphase, find plan for that phase/step; otherwise use as file path
2. Validate the plan exists and is marked as completed
3. If the plan is a sub-plan/branch, verify it's linked to the active master

**Archive workflow:**

1. **Determine plan type**:
   - Check if this is the master plan or a sub-plan/branch
   - Read the plan to get its type (from "Type:" field if sub-plan/branch)

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
   Where {type} is replaced with "sub-plan" or "branch" based on the plan's Type field.

3. **Perform the action**:

   **If "Archive it"**:
   - For master plans:
     - Move the master plan file to `plans/completed/` (mirroring subdirectory structure if nested)
     - If master has a subdirectory (e.g., `plans/layout-engine/`), move subdirectory to `plans/completed/layout-engine/`
     - Update state file: update master plan path to new location
   - For sub-plans/branches:
     - Move the file mirroring subdirectory structure:
       - If plan is in `plans/layout-engine/sub-plan.md`, move to `plans/completed/layout-engine/sub-plan.md`
       - If plan is in `plans/sub-plan.md` (flat), move to `plans/completed/sub-plan.md`
       - Create subdirectory in plans/completed/ if needed
     - Update state file: update sub-plan path and parent plan references

   **If "Delete it"**:
   - For master plans:
     - Delete the master plan file
     - If master has a subdirectory with no other files, optionally delete the subdirectory
     - Remove master plan entry from state file
     - If there are linked sub-plans, warn user and ask whether to also delete them or orphan them
   - For sub-plans/branches:
     - Delete the file
     - Remove sub-plan entry from state file
     - Remove references from master plan's Status Dashboard

   **If "Leave in place"**:
   - Do nothing, plan remains in current location

4. **Update references**:
   - If plan was moved or deleted, update all references in related plans
   - For master plans: update sub-plan parent references in state file
   - For sub-plans: update master plan Status Dashboard links if needed

5. **Confirm action**:
   - If archived: `✓ Archived {plan-name} to plans/completed/{path}`
   - If deleted: `✓ Deleted {plan-name}`
   - If left in place: `Plan remains at {current-path}`

## Example

```
User: "/plan-manager archive"
Claude: *Reads state file and finds completed plans*

        Which completed plan do you want to archive?
        ┌─────────────────────────────────────────────────────────┐
        │ Select plan                                             │
        │                                                         │
        │ ○ Master plan: layout-engine.md                         │
        │   The master plan itself (Status: Complete)             │
        │                                                         │
        │ ○ api-redesign.md                                       │
        │   Phase 3: API redesign (Type: Sub-plan, Status: ...)  │
        │                                                         │
        │ ○ grid-fix.md                                           │
        │   Phase 2: Grid fixes (Type: Branch, Status: ...)      │
        └─────────────────────────────────────────────────────────┘

User: *Selects "api-redesign.md"*
Claude: What should happen to the completed sub-plan?
        [cleanup options...]

User: *Selects "Archive it"*
Claude: ✓ Archived api-redesign.md to plans/completed/layout-engine/api-redesign.md
```

## Notes

- This command only works on completed plans. For plans still in progress, use `complete` first.
- Archiving preserves the file for reference while cleaning up the active working directory.
- Deleted plans are permanently removed - ensure content is merged or backed up first.
- When archiving a master plan with a subdirectory, the entire subdirectory structure moves to completed/.
