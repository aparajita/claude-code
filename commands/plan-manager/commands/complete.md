# Command: complete

## Usage

```
complete <file-or-phase-or-range> [step] [--master <path>] [--unattended]
```

Mark a sub-plan, branch, master plan phase(s), or step within a sub-plan as complete.

**Accepts:**
- Phase numbers: `3`
- Subphases: `4.1`
- Step numbers: `2`
- Substeps: `2.3`
- Phase ranges: `1-5`, `2-4`
- File paths: `plans/sub-plan.md`
- Steps within sub-plans: `plans/sub-plan.md 2` or natural language "step 2 of plans/sub-plan.md"

**Flags:**
- `--master <path>` — resolve phase numbers against this master plan instead of the active one.
- `--unattended` — run every step below without asking anything. `/execute-plan` uses it
  to record each phase it completes. See **Unattended mode**.

## Unattended mode

With `--unattended`, every **AskUserQuestion** in the steps below is answered as follows
instead of being asked:

| Question | Answer |
|----------|--------|
| Confirm completion (Section 4) | Yes — mark complete |
| All steps in the sub-plan complete — mark it complete? (Section 3, step 5) | Yes |
| All steps in the parent sub-plan complete — complete it too? (Section 2a, step 2) | Yes |
| How should the completed sub-plan/branch be integrated? (Section 2, step 3) | Just mark complete |
| What's the status of the parent phase? (Section 5, step 4) | Phase complete |
| What should happen to the completed sub-plan/branch, or to the master plan? (Section 5, steps 3 and 5) | Leave in place |
| Should a phase blocked by the completed one be unblocked? (Section 5, step 6) | Yes; if no blockers remain, its new status is ⏳ Pending |

Skip the "last phase but no others are marked complete" check in Section 5, step 3 —
an unattended caller completes phases one at a time, in order.

A plan the state file does not track still completes. Skip every state-file update, and
find the phases a completed phase blocks from the Status Dashboard's
`⏸️ Blocked by …` notation instead of the state file's `blocks` array.

## Steps

> **Terminology:** Throughout this document, "Phase" also includes "Milestone" or "Step" when used as section headers. Detect which term the plan uses and preserve it. See SKILL.md § Terminology.

### 1. Parse Input and Determine Target

1. **Parse the argument(s)**:
   - If first argument contains a dash (e.g., "1-5"), treat as a range
   - If first argument is a number/subphase (e.g., "3" or "4.1"), treat as single phase
   - If first argument is a file path AND second argument is a number, treat as step within sub-plan
   - Otherwise, treat first argument as file path

2. **For phase numbers/ranges**:
   - Read state file to find active master plan
   - Check if there's a sub-plan or branch for the phase
   - If sub-plan/branch exists: proceed with **Sub-plan/Branch Completion** (Section 2)
   - If no sub-plan/branch exists: proceed with **Direct Phase Completion** (Section 4)

3. **For file paths with step numbers**:
   - Proceed with **Sub-plan Step Completion** (Section 3)

4. **For file paths without step numbers**:
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
     - Label: "Replace with summary + link"
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

4. **Determine parent type** from the state entry:
   - Read the state entry for the completed sub-plan
   - If `parentStep` is set (parent is a sub-plan): proceed with **Nested Completion** (Section 2a)
   - If `parentPhase` is set (parent is a master): continue with **Shared Completion Steps** (Section 5)

### 2a. Nested Completion (parent is a sub-plan)

When a completed sub-plan's parent is another sub-plan (not a master):

1. **Update parent sub-plan's step**:
   - Find the step in the parent sub-plan corresponding to `parentStep`
   - Update the step's icon to ✅
   - Remove the blockquote sub-plan/branch reference if the sub-plan was deleted/archived

2. **Check if all steps in parent sub-plan are complete**:
   - Count total steps and completed steps in the parent sub-plan
   - If ALL steps are now complete, use **AskUserQuestion**:
     ```
     Question: "All steps in the parent sub-plan ({parent-name}) are now complete. Mark it as complete too?"
     Header: "Recursive completion"
     Options:
       - Label: "Yes, complete parent"
         Description: "Mark {parent-name} as Completed and propagate upward"
       - Label: "No, leave in progress"
         Description: "Keep the parent sub-plan as In Progress"
     ```
   - If "Yes, complete parent": recursively trigger **Sub-plan/Branch Completion** (Section 2) for the parent sub-plan
   - If "No, leave in progress": skip

3. **Ask about sub-plan cleanup** (same as Section 5, step 5) — only if the integration choice from Section 2 step 3 was "Just mark complete" (skip if merge was invoked, since the merge workflow handles cleanup internally)

4. **Update state file** for the completed sub-plan

### 3. Sub-plan Step Completion

Use this workflow when marking a specific step within a sub-plan as complete.

1. **Read the sub-plan file** to analyze its structure

2. **Detect step format**:
   - Look for `## Step N:` headers (structured steps with icons)
   - Look for `## Phase N:` headers (if the sub-plan has phases)
   - Look for numbered list items under a `## Plan` or similar section
   - If no recognizable step structure found, error: "No steps found in sub-plan. Use 'complete {file}' to mark the entire sub-plan complete."

3. **Validate step number**:
   - Check if the requested step number exists
   - If not, error: "Step {N} not found in {file}"

4. **Update the step**:
   - **For `## Step N:` or `## Phase N:` headers**:
     - Update the header icon to ✅ (e.g., `## ⏳ Step 2: Configure` → `## ✅ Step 2: Configure`)
     - If the sub-plan has a Status Dashboard table, update the corresponding row to `✅ Complete`
   - **For numbered list items**:
     - Prepend ✅ to the list item (e.g., `2. Configure database` → `2. ✅ Configure database`)
     - If the item already has a status icon, replace it with ✅

5. **Check if all steps are complete**:
   - Count total steps in the sub-plan
   - Count how many are marked ✅ Complete
   - If ALL steps are now complete, use **AskUserQuestion**:
     ```
     Question: "All steps in this sub-plan are now complete. Mark the entire sub-plan as complete?"
     Header: "Sub-plan completion"
     Options:
       - Label: "Yes, mark complete"
         Description: "Update sub-plan status to Completed and proceed with integration"
       - Label: "No, leave in progress"
         Description: "Keep sub-plan status as In Progress"
     ```
   - If "Yes, mark complete":
     - Update the sub-plan's **Status:** header to `Completed`
     - Proceed with **Sub-plan/Branch Completion** workflow (Section 2) starting at step 3
   - If "No, leave in progress":
     - Keep sub-plan status as is
     - Skip to step 6

6. **Confirm completion**:
   - `✓ Marked step {N} complete in {file}`
   - If sub-plan has a Status Dashboard, show progress: `({completed}/{total} steps complete)`

### 4. Direct Phase Completion

Use this workflow when marking master plan phases complete directly (no sub-plan exists).

1. **For single phase**: Use **AskUserQuestion** to confirm:
   ```
   Question: "Mark Phase {N} as complete in the master plan?"
   Header: "Confirm completion"
   Options:
     - Label: "Yes, mark complete"
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
     - Label: "Yes, mark all complete"
       Description: "Update all {count} phases to ✅ Complete"
     - Label: "No, cancel"
       Description: "Don't make any changes"
   ```
   If "No, cancel", exit without changes.

3. **Update master plan** for each phase in range:
   - Update Status Dashboard: change Status to `✅ Complete`
   - Update phase/step header icon to ✅
   - If "Sub-plan" column exists and is empty/dash, leave unchanged

4. Continue with **Shared Completion Steps** (Section 5)

### 5. Shared Completion Steps

After completing a sub-plan/branch (whose parent is a master plan) OR direct phase(s), perform these steps.

**Note:** These steps only apply when the parent is a master plan. When the parent is a sub-plan, use Section 2a instead. The "check if master plan is complete" logic (step 3) only fires when propagation reaches a master plan phase.

1. Read and update the master plan (if not already done in Section 4):
   - Update Status Dashboard: change Status to `✅ Complete` and update the Sub-plan column as needed
   - Update the Description column link anchor to match the updated phase header
   - Update phase/step header icon to ✅ if marking complete

2. Update state file

3. **Check if master plan is now complete**:
   - Count total phases/steps in master plan
   - Check how many are marked ✅ Complete
   - If this is the LAST phase/step AND no other phases are marked complete:
     - Use **AskUserQuestion**: "This is the last phase but no others are marked complete. Is the entire plan actually complete?"
     - Options: "Yes, all done" / "No, just this phase"
     - If "Yes, all done", mark ALL phases as complete
   - If ALL phases are now marked ✅ Complete, use **AskUserQuestion**:
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

4. **Determine phase status** (ONLY if completing a sub-plan/branch):
   Use **AskUserQuestion** with plan type in question:
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

6. **Check for blocked dependencies**:
   - Read state file to find all phases/steps that are blocked by the completed phase (check `blocks` array)
   - If any phases/steps are blocked by this completed phase:
     - For each blocked item, use **AskUserQuestion**:
       ```
       Question: "Phase {blocked} was blocked by {completed}. Should it be unblocked now?"
       Header: "Unblock dependency"
       Options:
         - Label: "Yes, unblock it"
           Description: "Remove blocker and allow Phase {blocked} to proceed"
         - Label: "No, keep it blocked"
           Description: "Other blockers may still exist, leave it blocked for now"
       ```
     - If "Yes, unblock it":
       - Run unblock logic (same as `unblock` command)
       - Remove blocker from the blocked phase's Status Dashboard row and its `blockedBy` array in the state file
       - If no other blockers remain, prompt for new status
       - Update Status Dashboard accordingly
     - If "No, keep it blocked", do nothing

7. **Confirm completion**:
   - If completing sub-plan/branch: `✓ Completed {type}: {path}`
   - If completing direct phase(s): `✓ Marked Phase(s) {range} as complete`
