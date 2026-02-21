# Command: sub-plan

## Usage

```
sub-plan|subplan <phase> [--master <path>] [--pre-planned]
```

Create a sub-plan for implementing a phase that needs substantial planning. Both "sub-plan" and "subplan" are accepted.

## Steps

1. **Detect plans directory and active master**:
   ```bash
   PLANS_DIR=$(commands/plan-manager/bin/pm-state get-plans-dir)
   MASTER=$(commands/plan-manager/bin/pm-state get-active-master)
   # or use --master if provided
   ```

2. **Verify phase exists** in the master plan:
   ```bash
   commands/plan-manager/bin/pm-md extract-phases --file "$MASTER"
   ```
   If the phase number is not in the output, error: "Phase N not found in master plan."

3. **Ask the user for a brief description** of the sub-plan topic.

4. **Ask if pre-planned** using **AskUserQuestion** (unless `--pre-planned` flag provided):
   ```
   Question: "Was this sub-plan pre-planned or created during execution?"
   Header: "Planning timing"
   Options:
     - Label: "During execution (Recommended)"
       Description: "Created just-in-time when starting work on this phase"
     - Label: "Pre-planned"
       Description: "Created upfront during initial planning phase"
   ```

5. **Determine sub-plan location**:
   - Check master's `subdirectory` field from state:
     ```bash
     commands/plan-manager/bin/pm-state read | jq -r '.masterPlans[] | select(.active) | .subdirectory'
     ```
   - **If master is flat** (subdirectory is null) — promote it first:
     ```bash
     commands/plan-manager/bin/pm-files promote-master --master "$MASTER" --plans-dir "$PLANS_DIR"
     ```
     Then update `MASTER` to the new path returned in the JSON result.
   - Sub-plan path: `{PLANS_DIR}/{subdirectory}/{slug}.md`
   - **CRITICAL**: Path must be relative to project root, never `~/.claude/plans/`

6. **Update the master plan**:
   - Update phase icon to 📋:
     ```bash
     commands/plan-manager/bin/pm-md update-phase-icon --file "$MASTER" --phase <N> --icon "📋"
     ```
   - Update dashboard row:
     ```bash
     commands/plan-manager/bin/pm-md update-dashboard-row --file "$MASTER" --phase <N> \
       --status "📋 Sub-plan" --subplan-link "[{slug}.md](./{slug}.md)"
     ```
   - Also add a link to the sub-plan in the phase section of the master plan (Edit the file directly).

7. **Create the sub-plan file**:
   Write the file with header template:
   ```markdown
   # Sub-plan: {description}

   **Type:** Sub-plan  <br>
   **Parent:** {master-path} → Phase {N}  <br>
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

8. **Update state file**:
   ```bash
   commands/plan-manager/bin/pm-state add-subplan \
     --path "$SUBPLAN_PATH" \
     --parent-plan "$MASTER" \
     --phase <N> \
     --type "sub-plan" \
     [--pre-planned]   # if pre-planned was selected
   ```

9. **Confirm**:
   - If master was promoted from flat: `✓ Promoted master plan to subdirectory: {plans-dir}/{baseName}/`
   - `✓ Created sub-plan: {path} (for Phase {N} implementation)`
