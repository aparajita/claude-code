# Command: merge

## Usage

```
merge [file-or-phase]
```

Merge a sub-plan or branch's content into the master plan.

**Purpose**: Sub-plans and branches often contain updates, refinements, or extensions to the master plan's phase content. This command integrates that work back into the master plan. (Note: Branches are more commonly merged; sub-plans typically remain separate as detailed implementation guides.)

**Accepts:** phase numbers (3), subphases (4.1), step numbers (2), substeps (2.3), file paths, or no argument (interactive selection)

## Steps

**Without argument (interactive mode):**
1. `MASTER=$(commands/plan-manager/bin/pm-state get-active-master)`
2. `commands/plan-manager/bin/pm-state list-subplans --master "$MASTER"` — list all linked sub-plans/branches.
3. Use **AskUserQuestion** to select which plan to merge.

**With argument:**
1. If argument is a number/subphase, find plan for that phase/step from subplans list; otherwise use as file path.
2. Validate the plan exists and is linked to the active master.

**Merge workflow:**

1. **Read the plan content**.
2. **Identify the target phase** in the master plan (from the plan's Parent header).
3. **Use AskUserQuestion to confirm merge approach**:
   ```
   Question: "How should this plan's content be merged?"
   Header: "Merge strategy"
   Options:
     - Label: "Append to phase"
       Description: "Add plan content to the end of Phase {N} section"
     - Label: "Inline content (Recommended)"
       Description: "Replace Phase {N} body with plan content, then delete the sub-plan file"
     - Label: "Reference to sub-plan"
       Description: "Replace Phase {N} body with summary + link to sub-plan"
     - Label: "Manual review"
       Description: "Show me both and I'll decide what to keep"
   ```

4. **Perform the merge** (Edit the master plan file directly for content changes):
   - **Append to phase**: Extract main content, add `### Merged from {plan-name}.md` subsection.
   - **Inline content**: Replace phase section body with plan content; delete sub-plan file; update links:
     ```bash
     commands/plan-manager/bin/pm-md update-dashboard-row --file "$MASTER" --phase <N> --subplan-link "—"
     ```
   - **Reference to sub-plan**: Replace phase body with summary + link; keep sub-plan file.
   - **Manual review**: Display both contents; let user decide.

5. **Update master plan metadata**:
   - Update dashboard:
     ```bash
     commands/plan-manager/bin/pm-md update-dashboard-row --file "$MASTER" --phase <N> \
       --status "🔄 In Progress"   # or ✅ Complete based on user input
     ```
   - Add merged note to phase section (Edit the master plan directly).

6. **Update state file**:
   - For "Inline content" or "Append to phase":
     ```bash
     commands/plan-manager/bin/pm-state update-subplan --path "$PLAN" --merged
     ```
   - For "Reference to sub-plan": No change to state (plan stays active).

7. **Ask about plan cleanup** (skip if "Inline content" was selected) using **AskUserQuestion**:
   ```
   Question: "Plan merged successfully. What should happen to the plan file?"
   Header: "Plan cleanup"
   Options:
     - Label: "Delete it (Recommended)"
       Description: "Remove the file (content is now in master plan)"
     - Label: "Archive it"
       Description: "Move to plans/completed/ directory for reference"
     - Label: "Leave in place"
       Description: "Keep in current location"
   ```
   - If "Delete it": delete file; `commands/plan-manager/bin/pm-state remove-subplan --path "$PLAN"`
   - If "Archive it":
     ```bash
     PLANS_DIR=$(commands/plan-manager/bin/pm-state get-plans-dir)
     commands/plan-manager/bin/pm-files archive --file "$PLAN" --plans-dir "$PLANS_DIR"
     commands/plan-manager/bin/pm-state update-subplan --path "$PLAN" --new-path "$ARCHIVED_PATH"
     ```

8. **Ask about phase status** using **AskUserQuestion**; update icon and dashboard row accordingly:
   ```bash
   commands/plan-manager/bin/pm-md update-phase-icon --file "$MASTER" --phase <N> --icon "✅"  # or 🔄
   commands/plan-manager/bin/pm-md update-dashboard-row --file "$MASTER" --phase <N> --status "✅ Complete"
   ```

9. **Confirm**: `✓ Merged {plan-name}.md into Phase {N} of master plan`
