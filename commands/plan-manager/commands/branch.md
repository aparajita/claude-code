# Command: branch

## Usage

```
branch <phase> [--master <path>]
```

Proactively create a sub-plan when you see a problem coming.

## Steps

1. Read the state file to get master plan path (use active master, or specified via --master)
2. Read the master plan to verify the phase exists
3. Ask the user for a brief description of the sub-plan topic
4. **Determine sub-plan location**:
   - Check if master plan uses subdirectory organization (from state file)
   - If master is in subdirectory (e.g., `plans/layout-engine/layout-engine.md`):
     - Create sub-plan in same subdirectory: `plans/layout-engine/{sub-plan-name}.md`
   - If master is flat (e.g., `plans/legacy-plan.md`):
     - Create sub-plan at root: `plans/{sub-plan-name}.md`
5. **Update the master plan FIRST**:
   - Update the phase header icon to 🔀 (e.g., `## Phase 2: 🔀 API Layer`)
   - Update the Status Dashboard: change phase Status to `🔀 Branch` and add the sub-plan link to the Sub-plan column (e.g., `[branch.md](./branch.md)`)
   - Keep the Description column link unchanged (e.g., `[Layout Engine](#phase-2-layout-engine)`)
   - Add sub-plan reference to the phase section
   - Use relative path for link if in same subdirectory (e.g., `[branch.md](./branch.md)`)
6. Create the sub-plan file with header:

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

7. Update state file with new sub-plan entry (set type: "branch", prePlanned: false)
8. Confirm: `✓ Created branch: {path} (branched from Phase {N})`
