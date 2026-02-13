# Command: capture

## Usage

```
capture [file] [--phase N] [--master <path>]
```

Retroactively link an existing plan that was created during tangential discussion.

## Steps

**Context-aware mode** (no file specified):
1. Look at recent conversation context to identify the plan file that was just created
2. If multiple candidates or none found, ask the user which file to capture
3. Proceed to linking

**Explicit mode** (file specified):
1. Validate the file exists

**For both modes:**
1. If `--phase N` not provided, ask which phase this relates to
2. Read the state file to get master plan path (use active master, or specified via --master)
3. **Ask plan type** using **AskUserQuestion**:
   ```
   Question: "What type of plan is this?"
   Header: "Plan type"
   Options:
     - Label: "Sub-plan"
       Description: "Implements a phase that needs substantial planning"
     - Label: "Branch"
       Description: "Handles an unexpected issue or problem discovered during execution"
   ```
4. **If sub-plan type selected**, ask if pre-planned using **AskUserQuestion**:
   ```
   Question: "Was this sub-plan pre-planned or created during execution?"
   Header: "Planning timing"
   Options:
     - Label: "Pre-planned"
       Description: "Created upfront during initial planning phase"
     - Label: "During execution"
       Description: "Created just-in-time when starting work on this phase"
   ```
5. **Move to subdirectory if needed**:
   - If master plan uses subdirectory and captured plan is not in it, move the plan
   - If master plan is flat and captured plan is in a subdirectory, ask whether to move or keep
6. **Add parent reference to the plan** (prepend if not present):

**For sub-plans:**
```markdown
**Type:** Sub-plan  <br>
**Parent:** {master-plan-path} → Phase {N}  <br>
**Captured:** {date}  <br>
**Pre-planned:** {Yes/No}  <br>
**Status:** In Progress

---

{original content}
```

**For branches:**
```markdown
**Type:** Branch  <br>
**Parent:** {master-plan-path} → Phase {N}  <br>
**Captured:** {date}  <br>
**Status:** In Progress

---

{original content}
```

7. **Update the master plan**:
   - Update the phase header icon to match the plan type (📋 for sub-plan, 🔀 for branch)
   - Update Status Dashboard: change Status to `📋 Sub-plan` or `🔀 Branch` and add plan reference to the Sub-plan column
   - Update the Description column link anchor to match the updated phase header
   - Update the phase section with link to the plan
8. Update state file (set type: "sub-plan" or "branch", prePlanned: true/false for sub-plans or false for branches)
9. Confirm based on type:
   - Sub-plan: `✓ Captured {file} → linked as sub-plan to Phase {N}`
   - Branch: `✓ Captured {file} → linked as branch to Phase {N}`
