# Command: complete

## Usage

```
complete <file-or-phase-or-range>
```

Mark a sub-plan, branch, or master plan phase(s) as complete.

**Accepts:**
- Phase numbers: `3`
- Subphases: `4.1`
- Step numbers: `2`
- Substeps: `2.3`
- Phase ranges: `1-5`, `2-4`
- File paths: `plans/sub-plan.md`

## Steps

### 1. Parse Input and Determine Target

1. **Parse the argument**:
   - If it contains a dash (e.g., "1-5"), treat as a range
   - If it's a number/subphase (e.g., "3" or "4.1"), treat as single phase
   - Otherwise, treat as file path

2. **For phase numbers/ranges**:
   - Read state file to find active master plan
   - Check if there's a sub-plan or branch for the phase
   - If sub-plan/branch exists: proceed with **Sub-plan/Branch Completion** (Section 2)
   - If no sub-plan/branch exists: proceed with **Direct Phase Completion** (Section 3)

3. **For file paths**:
   - Read the plan file
   - Determine type from "Type:" field
   - Proceed with **Sub-plan/Branch Completion** (Section 2)

### 2. Sub-plan/Branch Completion

1. Read the plan to determine its type (from "Type:" field: "Sub-plan" or "Branch")
2. Update the plan's status header to `Completed`
3. **Ask about merge vs mark complete** using **AskUserQuestion** (use plan type in question):
   ```
   Question: "This {type} is complete. How should it be integrated?"
   Header: "Integration"
   Options:
     - Label: "Replace with summary + link (Recommended)"
       Description: "Replace phase body with a summary and link to the {type}"
     - Label: "Merge into master"
       Description: "Merge {type} content into the master plan's phase section"
     - Label: "Just mark complete"
       Description: "Update Status Dashboard only, keep {type} separate"
   ```
   Where {type} is replaced with "sub-plan" or "branch" based on the plan's Type field.
   - If "Replace with summary + link": Run the merge workflow with "Reference to sub-plan" mode (see `merge` command)
   - If "Merge into master": Run the merge workflow with "Inline content" mode (see `merge` command)
   - If "Just mark complete": Continue with steps below

4. Continue with **Shared Completion Steps** (Section 4)

### 3. Direct Phase Completion

Use this workflow when marking master plan phases complete directly (no sub-plan exists).

1. **For single phase**: Use **AskUserQuestion** to confirm:
   ```
   Question: "Mark Phase {N} as complete in the master plan?"
   Header: "Confirm completion"
   Options:
     - Label: "Yes, mark complete (Recommended)"
       Description: "Update Phase {N} to ✅ Complete"
     - Label: "No, cancel"
       Description: "Don't make any changes"
   ```
   If "No, cancel", exit without changes.

2. **For phase ranges**: Use **AskUserQuestion** to confirm:
   ```
   Question: "Mark Phases {start}-{end} as complete in the master plan?"
   Header: "Confirm completion"
   Options:
     - Label: "Yes, mark all complete (Recommended)"
       Description: "Update all {count} phases to ✅ Complete"
     - Label: "No, cancel"
       Description: "Don't make any changes"
   ```
   If "No, cancel", exit without changes.

3. **Update master plan** for each phase in range:
   - Update Status Dashboard: change Status to `✅ Complete`
   - Update phase/step header icon to ✅
   - If "Sub-plan" column exists and is empty/dash, leave unchanged

4. Continue with **Shared Completion Steps** (Section 4)

### 4. Shared Completion Steps

After completing a sub-plan/branch OR direct phase(s), perform these steps:

1. Read and update the master plan (if not already done in Section 3):
   - Update Status Dashboard: change Status to `✅ Complete` and update the Sub-plan column as needed
   - Update the Description column link anchor to match the updated phase header
   - Update phase/step header icon to ✅ if marking complete

2. Update state file

3. **Check if entire plan is complete**:
   - Count total phases/steps in master plan
   - Check how many are marked ✅ Complete
   - If this is the LAST phase/step AND no other phases are marked complete:
     - Use **AskUserQuestion**: "This is the last phase but no others are marked complete. Is the entire plan actually complete?"
     - Options: "Yes, all done" / "No, just this phase"
   - If "Yes, all done", mark ALL phases as complete
   - **If master plan is now complete** (all phases marked ✅ Complete), use **AskUserQuestion**:
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
     - If "Archive it", move the master plan file to `plans/completed/` (mirroring subdirectory structure if nested)
     - If "Delete it", delete the master plan file
     - If "Leave in place", do nothing
     - Update state file accordingly

4. **Check if all phases are now complete**:
   - After updating the phase status, check if ALL phases in the master plan are now marked ✅ Complete
   - If yes AND we haven't already asked about master plan disposition in step 3, use **AskUserQuestion**:
     ```
     Question: "All phases are now complete. What should happen to the master plan?"
     Header: "Master plan cleanup"
     Options:
       - Label: "Archive it"
         Description: "Move to plans/completed/ directory to keep it for reference"
       - Label: "Delete it"
         Description: "Remove the file entirely"
       - Label: "Leave in place"
         Description: "Keep in current location for now"
     ```
     - If "Archive it", move the master plan file to `plans/completed/` (mirroring subdirectory structure if nested)
     - If "Delete it", delete the master plan file
     - If "Leave in place", do nothing
     - Update state file accordingly

5. **Ask about sub-plan/branch cleanup** (ONLY if completing a sub-plan/branch):
   Use **AskUserQuestion** with plan type in question:
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
   - If "Archive it", move the file mirroring subdirectory structure:
     - If plan is in `plans/layout-engine/sub-plan.md`, move to `plans/completed/layout-engine/sub-plan.md`
     - If plan is in `plans/sub-plan.md` (flat), move to `plans/completed/sub-plan.md`
     - Create subdirectory in plans/completed/ if needed
   - If "Delete it", delete the file
   - If "Leave in place", do nothing
   - Update all references in master plan and state file

6. **Determine phase status** (ONLY if completing a sub-plan/branch):
   Use **AskUserQuestion tool** with plan type in question:
   ```
   Question: "{Type} completed. What's the status of Phase {N}?"
   Header: "Phase status"
   Options:
     - Label: "Phase complete"
       Description: "All work for Phase {N} is done, mark it ✅ Complete"
     - Label: "Still in progress"
       Description: "More work remains on Phase {N}, keep it 🔄 In Progress"
     - Label: "Blocked"
       Description: "Phase {N} is waiting on something else, mark it ⏸️ Blocked"
   ```

7. **Check for blocked dependencies**:
   - Read state file to find all phases/steps that are blocked by the completed phase (check `blocks` array)
   - If any phases/steps are blocked by this completed phase:
     - For each blocked item, use **AskUserQuestion**:
       ```
       Question: "Phase {blocked} was blocked by {completed}. Should it be unblocked now?"
       Header: "Unblock dependency"
       Options:
         - Label: "Yes, unblock it (Recommended)"
           Description: "Remove blocker and allow Phase {blocked} to proceed"
         - Label: "No, keep it blocked"
           Description: "Other blockers may still exist, leave it blocked for now"
       ```
     - If "Yes, unblock it":
       - Run unblock logic (same as `unblock` command)
       - Remove blocker from the blocked phase's `blockedBy` field in master plan and state file
       - If no other blockers remain, prompt for new status
       - Update Status Dashboard accordingly
     - If "No, keep it blocked", do nothing

8. **Confirm completion**:
   - If completing sub-plan/branch: `✓ Completed {type}: {path}`
   - If completing direct phase(s): `✓ Marked Phase(s) {range} as complete`
