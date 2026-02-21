# Command: complete

## Usage

```
complete <file-or-phase-or-range> [step]
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

## Steps

### 1. Parse Input and Determine Target

1. **Parse the argument(s)**:
   - If first argument contains a dash (e.g., "1-5"), treat as a range.
   - If first argument is a number/subphase (e.g., "3" or "4.1"), treat as single phase.
   - If first argument is a file path AND second argument is a number, treat as step within sub-plan.
   - Otherwise, treat first argument as file path.

2. **For phase numbers/ranges**:
   - Read state: `commands/plan-manager/bin/pm-state get-active-master`
   - Check if there's a sub-plan or branch for the phase: `commands/plan-manager/bin/pm-state list-subplans --master "$MASTER"`
   - If sub-plan/branch exists: proceed with **Sub-plan/Branch Completion** (Section 2)
   - If no sub-plan/branch: proceed with **Direct Phase Completion** (Section 4)

3. **For file paths with step numbers**: Proceed with **Sub-plan Step Completion** (Section 3)

4. **For file paths without step numbers**:
   - Read the plan file to determine type from "Type:" field.
   - Proceed with **Sub-plan/Branch Completion** (Section 2)

### 2. Sub-plan/Branch Completion

1. Read the plan to determine its type (from "Type:" field: "Sub-plan" or "Branch")
2. Update the plan's status header to `Completed` (Edit the file directly).
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
   - If "Replace with summary + link" or "Merge into master": Run the merge workflow (see `merge` command)
   - If "Just mark complete": Continue with steps below

4. Continue with **Shared Completion Steps** (Section 5)

### 3. Sub-plan Step Completion

1. **Read the sub-plan file** to analyze its structure.
2. **Detect step format**: Look for `## Step N:` or `## Phase N:` headers, or numbered list items.
3. **Validate step number** exists; error if not found.
4. **Update the step**:
   - For `## Step N:` or `## Phase N:` headers: update icon to ✅ (Edit the file directly).
   - Update dashboard row if present:
     ```bash
     commands/plan-manager/bin/pm-md update-dashboard-row --file "$FILE" --phase <N> --status "✅ Complete"
     ```
   - For numbered list items: prepend ✅ to the list item (Edit the file directly).
5. **Check if all steps complete** — if so, use **AskUserQuestion** to offer marking entire sub-plan complete.
6. **Confirm**: `✓ Marked step {N} complete in {file}`

### 4. Direct Phase Completion

1. **Confirm with AskUserQuestion** (single phase or range).
2. **Update master plan** for each phase:
   ```bash
   commands/plan-manager/bin/pm-md update-phase-icon --file "$MASTER" --phase <N> --icon "✅"
   commands/plan-manager/bin/pm-md update-dashboard-row --file "$MASTER" --phase <N> --status "✅ Complete"
   ```
3. Continue with **Shared Completion Steps** (Section 5)

### 5. Shared Completion Steps

1. **Update master plan** (if not already done in Section 4):
   ```bash
   commands/plan-manager/bin/pm-md update-phase-icon --file "$MASTER" --phase <N> --icon "✅"
   commands/plan-manager/bin/pm-md update-dashboard-row --file "$MASTER" --phase <N> --status "✅ Complete"
   ```

2. **Update state file**:
   ```bash
   commands/plan-manager/bin/pm-state update-subplan --path "$SUBPLAN" --status "completed"
   ```

3. **Check if master plan is now complete**:
   - Extract phases: `commands/plan-manager/bin/pm-md extract-phases --file "$MASTER"`
   - If ALL phases marked ✅, use **AskUserQuestion**:
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
   - If "Archive it":
     ```bash
     commands/plan-manager/bin/pm-files archive --file "$MASTER" --plans-dir "$PLANS_DIR"
     ```

4. **Determine phase status** (ONLY if completing a sub-plan/branch):
   Use **AskUserQuestion** to ask whether Phase N is complete, in progress, or blocked. Then update accordingly.

5. **Ask about sub-plan/branch cleanup** (ONLY if completing a sub-plan/branch):
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
   - If "Archive it":
     ```bash
     commands/plan-manager/bin/pm-files archive --file "$SUBPLAN" --plans-dir "$PLANS_DIR"
     commands/plan-manager/bin/pm-state update-subplan --path "$SUBPLAN" --new-path "$ARCHIVED_PATH"
     ```
   - If "Delete it": delete the file; `commands/plan-manager/bin/pm-state remove-subplan --path "$SUBPLAN"`

6. **Check for blocked dependencies** in state file; for each, offer to unblock via AskUserQuestion.

7. **Confirm**:
   - Sub-plan/branch: `✓ Completed {type}: {path}`
   - Direct phase(s): `✓ Marked Phase(s) {range} as complete`
