# Command: sub-plan

## Usage

```
sub-plan|subplan <phase> [--master <path>] [--pre-planned]
```

Create a sub-plan for implementing a phase that needs substantial planning. Both "sub-plan" and "subplan" are accepted.

## Steps

1. Read the state file to get master plan path (use active master, or specified via --master)
2. Read the master plan to verify the phase exists
3. Ask the user for a brief description of the sub-plan topic
4. **Ask if pre-planned** using **AskUserQuestion** (unless --pre-planned flag provided):
   ```
   Question: "Was this sub-plan pre-planned or created during execution?"
   Header: "Planning timing"
   Options:
     - Label: "Pre-planned"
       Description: "Created upfront during initial planning phase"
     - Label: "During execution"
       Description: "Created just-in-time when starting work on this phase"
   ```
5. **Determine sub-plan location**:
   - Check if master plan uses subdirectory organization (from state file)
   - If master is in subdirectory (e.g., `plans/layout-engine/layout-engine.md`):
     - Create sub-plan in same subdirectory: `plans/layout-engine/{sub-plan-name}.md`
   - If master is flat (e.g., `plans/legacy-plan.md`):
     - Create sub-plan at root: `plans/{sub-plan-name}.md`
6. **Update the master plan FIRST**:
   - Update the phase header icon to 📋 (e.g., `## Phase 3: 📋 Layout Engine`)
   - Update the Status Dashboard: change phase Status to `📋 Sub-plan` and add the sub-plan link to the Sub-plan column (e.g., `[sub-plan.md](./sub-plan.md)`)
   - Keep the Description column link unchanged (e.g., `[API Layer](#phase-3--api-layer)`)
   - Add sub-plan reference to the phase section
   - Use relative path for link if in same subdirectory (e.g., `[sub-plan.md](./sub-plan.md)`)
7. Create the sub-plan file with header:

```markdown
# Sub-plan: {description}

**Type:** Sub-plan  <br>
**Parent:** {master-plan-path} → Phase {N}  <br>
**Created:** {date}  <br>
**Pre-planned:** {Yes/No}  <br>
**Status:** In Progress

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

8. Update state file with new sub-plan entry (set type: "sub-plan", prePlanned: true/false based on user's answer)
9. Confirm: `✓ Created sub-plan: {path} (for Phase {N} implementation)`
