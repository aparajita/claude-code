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
1. **Detect plans directory root**:
   - Try reading `.claude/settings.local.json` in the project root, look for `plansDirectory` field
   - If not found, try reading `.claude/settings.json` in the project root, look for `plansDirectory` field
   - If not found, try reading `.claude/plan-manager-state.json`, look for `plansDirectory` field
   - If not found, auto-detect by checking these directories (use first that exists with .md files):
     - `plans/` (relative to project root)
     - `docs/plans/` (relative to project root)
     - `.plans/` (relative to project root)
   - **CRITICAL**: All plan paths are relative to the project root, NOT to `~/.claude/`
   - **CRITICAL**: Never use `~/.claude/plans/` - that's a fallback location only for plans mode, not for plan-manager
   - Store the detected directory (e.g., "plans", "docs/plans") for use in subsequent steps
2. If `--phase N` not provided, ask which phase this relates to
3. Read the state file to get master plan path (use active master, or specified via --master)
4. **Ask plan type** using **AskUserQuestion**:
   ```
   Question: "What type of plan is this?"
   Header: "Plan type"
   Options:
     - Label: "Sub-plan"
       Description: "Implements a phase that needs substantial planning"
     - Label: "Branch"
       Description: "Handles an unexpected issue or problem discovered during execution"
   ```
5. **If sub-plan type selected**, ask if pre-planned using **AskUserQuestion**:
   ```
   Question: "Was this sub-plan pre-planned or created during execution?"
   Header: "Planning timing"
   Options:
     - Label: "Pre-planned"
       Description: "Created upfront during initial planning phase"
     - Label: "During execution"
       Description: "Created just-in-time when starting work on this phase"
   ```
6. **Move to subdirectory if needed**:
   - Use the plans directory detected in step 1
   - If master plan uses subdirectory and captured plan is not in it, move the plan to the master's subdirectory
   - If master plan is flat and captured plan is in a subdirectory, ask whether to move or keep
   - **CRITICAL**: Never move plans to or from `~/.claude/plans/` - all operations should be within the project plans directory
7. **Add parent reference to the plan** (prepend if not present):

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

8. **Update the master plan**:
   - Update the phase header icon to match the plan type (📋 for sub-plan, 🔀 for branch)
   - Update Status Dashboard: change Status to `📋 Sub-plan` or `🔀 Branch` and add plan reference to the Sub-plan column
   - Update the Description column link anchor to match the updated phase header
   - Update the phase section with link to the plan
9. Update state file (set type: "sub-plan" or "branch", prePlanned: true/false for sub-plans or false for branches)
10. Confirm based on type:
   - Sub-plan: `✓ Captured {file} → linked as sub-plan to Phase {N}`
   - Branch: `✓ Captured {file} → linked as branch to Phase {N}`
