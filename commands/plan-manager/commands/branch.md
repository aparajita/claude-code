# Command: branch

## Usage

```
branch <phase> [--master <path>]
```

Create a branch plan for handling an unexpected issue or problem discovered during execution.

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
5. **Determine sub-plan location**:
   - Use the plans directory detected in step 1 (e.g., "plans" or "docs/plans")
   - Check if master plan uses subdirectory organization by examining its path
   - If master is in subdirectory (e.g., `plans/migrations/smufl-rewrite/smufl-rewrite.md`):
     - Extract the subdirectory path (e.g., `migrations/smufl-rewrite`)
     - Create sub-plan in same subdirectory: `{plansDirectory}/{subdirectory}/{sub-plan-name}.md`
     - Example: If plansDirectory is "plans", create at `plans/migrations/smufl-rewrite/{sub-plan-name}.md`
   - If master is flat (e.g., `plans/legacy-plan.md`):
     - Create sub-plan at root: `{plansDirectory}/{sub-plan-name}.md`
   - **CRITICAL**: Path must be relative to project root, never use `~/.claude/plans/`
6. **Update the master plan FIRST**:
   - Update the phase header icon to 🔀 (e.g., `## 🔀 Phase 2: API Layer`)
   - Update the Status Dashboard: change phase Status to `🔀 Branch` and add the sub-plan link to the Sub-plan column (e.g., `[branch.md](./branch.md)`)
   - Update the Description column link anchor to match the updated phase header (e.g., `[API Layer](#-phase-2-api-layer)`)
   - Add sub-plan reference to the phase section
   - Use relative path for link if in same subdirectory (e.g., `[branch.md](./branch.md)`)
7. Create the sub-plan file with header:

```markdown
# Branch: {description}

**Type:** Branch  <br>
**Parent:** {master-plan-path} → Phase {N}  <br>
**Created:** {date}  <br>
**Status:** In Progress

---

## Context

{Brief description of the issue/topic that led to this branch}

## Plan

{To be filled in}
```

8. Update state file with new sub-plan entry (set type: "branch", prePlanned: false)
9. Confirm: `✓ Created branch: {path} (branched from Phase {N})`
