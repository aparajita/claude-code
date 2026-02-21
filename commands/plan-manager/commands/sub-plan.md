# Command: sub-plan

## Usage

```
sub-plan|subplan <phase> [--master <path>] [--pre-planned]
```

Create a sub-plan for implementing a phase that needs substantial planning. Both "sub-plan" and "subplan" are accepted.

## Steps

1. **Detect plans directory root**:
   - Try reading `.claude/settings.local.json` in the project root, look for `plansDirectory` field
   - If not found, try reading `.claude/settings.json` in the project root, look for `plansDirectory` field
   - If not found, try reading `.claude/plan-manager-state.json`, look for `plansDirectory` field
   - If not found, auto-detect by checking these directories (use first that exists with .md files):
     - `plans/` (relative to project root)
     - `docs/plans/` (relative to project root)
     - `.plans/` (relative to project root)
   - **CRITICAL**: All plan paths in state file and commands are relative to the project root, NOT to `~/.claude/`
   - **CRITICAL**: Never create plans in `~/.claude/plans/` - that's a fallback location only for plans mode, not for plan-manager
   - Store the detected directory (e.g., "plans", "docs/plans") for use in subsequent steps
2. Read the state file (`.claude/plan-manager-state.json`) to get master plan path (use active master, or specified via --master)
3. Read the master plan to verify the phase exists
4. Ask the user for a brief description of the sub-plan topic
5. **Ask if pre-planned** using **AskUserQuestion** (unless --pre-planned flag provided):
   ```
   Question: "Was this sub-plan pre-planned or created during execution?"
   Header: "Planning timing"
   Options:
     - Label: "During execution (Recommended)"
       Description: "Created just-in-time when starting work on this phase"
     - Label: "Pre-planned"
       Description: "Created upfront during initial planning phase"
   ```
6. **Determine sub-plan location**:
   - Use the plans directory detected in step 1 (e.g., "plans" or "docs/plans")
   - Check if master plan uses subdirectory organization by examining its state entry (`subdirectory` field)
   - If master is already in a subdirectory (e.g., `plans/smufl-rewrite/smufl-rewrite.md`):
     - Extract the subdirectory path (e.g., `smufl-rewrite`)
     - Create sub-plan in same subdirectory: `{plansDirectory}/{subdirectory}/{sub-plan-name}.md`
   - If master is flat (e.g., `plans/legacy-plan.md`, `subdirectory: null` in state):
     - **Promote master plan to subdirectory** (this is the first sub-plan, so nesting is now needed):
       - Extract base name from master filename (e.g., `legacy-plan.md` → `legacy-plan`)
       - Create subdirectory: `{plansDirectory}/legacy-plan/`
       - Move master plan into it: `{plansDirectory}/legacy-plan.md` → `{plansDirectory}/legacy-plan/legacy-plan.md`
       - Update the state file: set `path` to new location and `subdirectory` to `"legacy-plan"`
       - Update any existing links in the master plan itself to use relative paths
     - Create sub-plan in the new subdirectory: `{plansDirectory}/legacy-plan/{sub-plan-name}.md`
   - **CRITICAL**: Path must be relative to project root, never use `~/.claude/plans/`
7. **Update the master plan FIRST**:
   - Update the phase header icon to 📋 (e.g., `## 📋 Phase 3: Layout Engine`)
   - Update the Status Dashboard: change phase Status to `📋 Sub-plan` and add the sub-plan link to the Sub-plan column (e.g., `[sub-plan.md](./sub-plan.md)`)
   - Update the Description column link anchor to match the updated phase header (e.g., `[Layout Engine](#-phase-3-layout-engine)`)
   - Add sub-plan reference to the phase section
   - Use relative path for link if in same subdirectory (e.g., `[sub-plan.md](./sub-plan.md)`)
8. Create the sub-plan file with header:

```markdown
# Sub-plan: {description}

**Type:** Sub-plan  <br>
**Parent:** {master-plan-path} → Phase {N}  <br>
**Created:** {date}  <br>
**Pre-planned:** {Yes/No}  <br>
**Status:** In Progress  <br>
**BlockedBy:** —

---

## Purpose

{Brief description of what this phase aims to accomplish}

## Implementation Approach

{To be filled in - how will this phase be implemented}

## Dependencies

{Any dependencies or prerequisites}

## Plan

{Detailed implementation steps}
```

9. Update state file with new sub-plan entry (set type: "sub-plan", prePlanned: true/false based on user's answer)
10. Confirm:
    - If master was promoted from flat: `✓ Promoted master plan to subdirectory: {plansDirectory}/{baseName}/`
    - `✓ Created sub-plan: {path} (for Phase {N} implementation)`
