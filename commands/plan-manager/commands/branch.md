# Command: branch

## Usage

```
branch <phase> [--master <path>]
```

Create a branch plan for handling an unexpected issue or problem discovered during execution.

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

3. **Ask the user for a brief description** of the branch topic.

4. **Determine branch location**:
   - Check master's `subdirectory` field from state:
     ```bash
     commands/plan-manager/bin/pm-state read | jq -r '.masterPlans[] | select(.path == "'$MASTER'") | .subdirectory'
     ```
   - If master is in a subdirectory: branch goes into `{PLANS_DIR}/{subdirectory}/{slug}.md`
   - If master is flat: branch goes at `{PLANS_DIR}/{slug}.md` (branches don't trigger promotion)
   - **CRITICAL**: Path must be relative to project root, never `~/.claude/plans/`

5. **Update the master plan**:
   - Update phase icon to 🔀:
     ```bash
     commands/plan-manager/bin/pm-md update-phase-icon --file "$MASTER" --phase <N> --icon "🔀"
     ```
   - Update dashboard row:
     ```bash
     commands/plan-manager/bin/pm-md update-dashboard-row --file "$MASTER" --phase <N> \
       --status "🔀 Branch" --subplan-link "[{slug}.md](./{slug}.md)"
     ```
   - Also add a link to the branch in the phase section of the master plan (Edit the file directly).

6. **Create the branch file**:
   Write the file with header template:
   ```markdown
   # Branch: {description}

   **Type:** Branch  <br>
   **Parent:** {master-path} → Phase {N}  <br>
   **Created:** {date}  <br>
   **Status:** In Progress  <br>
   **BlockedBy:** —

   ---

   ## Context

   {Brief description of the issue/topic that led to this branch}

   ## Plan

   {To be filled in}
   ```

7. **Update state file**:
   ```bash
   commands/plan-manager/bin/pm-state add-subplan \
     --path "$BRANCH_PATH" \
     --parent-plan "$MASTER" \
     --phase <N> \
     --type "branch"
   ```

8. **Confirm**: `✓ Created branch: {path} (branched from Phase {N})`
