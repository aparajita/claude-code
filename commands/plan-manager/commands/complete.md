# Command: complete

## Usage

```
complete <file-or-phase>
```

Mark a sub-plan as complete and sync status to master.

**Accepts:** phase numbers (3), subphases (4.1), step numbers (2), substeps (2.3), or file paths

## Steps

1. If argument is a number/subphase, find plan for that phase/step; otherwise use as file path
2. Read the plan to determine its type (from "Type:" field: "Sub-plan" or "Branch")
3. Update the plan's status header to `Completed`
4. **Ask about merge vs mark complete** using **AskUserQuestion** (use plan type in question):
   ```
   Question: "This {type} is complete. How should it be integrated?"
   Header: "Integration"
   Options:
     - Label: "Merge into master (Recommended)"
       Description: "Merge {type} content into the master plan's phase section"
     - Label: "Just mark complete"
       Description: "Update Status Dashboard only, keep {type} separate"
   ```
   Where {type} is replaced with "sub-plan" or "branch" based on the plan's Type field.
   - If "Merge into master": Run the merge workflow (see `merge` command)
   - If "Just mark complete": Continue with steps below

4. Read and update the master plan:
   - Update Status Dashboard: change sub-plan status indicator
   - Update phase/step status based on user choice

5. Update state file

6. **Check if entire plan is complete**:
   - Count total phases/steps in master plan
   - Check how many are marked ✅ Complete
   - If this is the LAST phase/step AND no other phases are marked complete:
     - Use **AskUserQuestion**: "This is the last phase but no others are marked complete. Is the entire plan actually complete?"
     - Options: "Yes, all done" / "No, just this phase"
   - If "Yes, all done", mark ALL phases as complete

7. **Ask about plan cleanup** using **AskUserQuestion** (use plan type in question):
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

8. Use **AskUserQuestion tool** to determine phase status (use plan type in question):
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

9. Confirm: `✓ Completed sub-plan: {path}`
