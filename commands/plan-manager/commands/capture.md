# Command: capture

## Usage

```
capture [file] [--phase N] [--master <path>]
```

Retroactively link an existing plan that was created during tangential discussion.

## Steps

**Context-aware mode** (no file specified):
1. Look at recent conversation context to identify the plan file that was just created.
2. If multiple candidates or none found, ask the user which file to capture.
3. Proceed to linking.

**Explicit mode** (file specified):
1. Validate the file exists.

**For both modes:**

1. **Detect plans directory and active master**:
   ```bash
   PLANS_DIR=$(commands/plan-manager/bin/pm-state get-plans-dir)
   MASTER=$(commands/plan-manager/bin/pm-state get-active-master)
   # or use --master if provided
   ```

2. **If `--phase N` not provided**, ask which phase this relates to (read phases from master via `pm-md extract-phases --file "$MASTER"`).

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
     - Label: "During execution (Recommended)"
       Description: "Created just-in-time when starting work on this phase"
     - Label: "Pre-planned"
       Description: "Created upfront during initial planning phase"
   ```

5. **Detect if plan has a random/meaningless name**:
   ```bash
   commands/plan-manager/bin/pm-md detect-random-name --filename "$(basename $FILE)"
   ```
   If `random` is true, proceed to step 6. If meaningful name, skip to step 7.

6. **Suggest meaningful rename** (only if random name detected):
   - Read the plan content to understand what it's about.
   - Analyze the phase description and title from the master plan.
   - Generate 2-3 meaningful filename suggestions.
   - Use **AskUserQuestion** to confirm:
     ```
     Question: "This plan has a random name. Suggest a better name?"
     Header: "Rename"
     Options:
       - Label: "{suggested-name-1}.md"
         Description: "Based on plan content: {brief description}"
       - Label: "{suggested-name-2}.md"
         Description: "Based on phase {N}: {phase title}"
       - Label: "Keep current name"
         Description: "Don't rename, keep {current-name}.md"
     ```
   - If user chooses to rename, store the new name for the move step.

7. **Move to subdirectory if needed**:
   - Check master's `subdirectory` field in state.
   - If master is already in a subdirectory and captured plan is not in it:
     ```bash
     commands/plan-manager/bin/pm-files move-to-subdir \
       --file "$FILE" \
       --subdirectory "$(pm-state read | jq -r '.masterPlans[] | select(.active) | .subdirectory')" \
       --plans-dir "$PLANS_DIR" \
       [--rename "new-name.md"]   # if user chose a rename
     ```
   - If master is flat — this is the first sub-plan, so promote:
     ```bash
     commands/plan-manager/bin/pm-files promote-master --master "$MASTER" --plans-dir "$PLANS_DIR"
     ```
     Then move the captured plan to the new subdirectory:
     ```bash
     commands/plan-manager/bin/pm-files move-to-subdir \
       --file "$FILE" --subdirectory "<baseName>" --plans-dir "$PLANS_DIR" [--rename "new-name.md"]
     ```
   - Update all references to old path:
     ```bash
     commands/plan-manager/bin/pm-md update-links --file "$MASTER" --old "$OLD_PATH" --new "$NEW_PATH"
     ```

8. **Add parent reference to the plan** (prepend if not present):
   ```bash
   commands/plan-manager/bin/pm-md add-parent-header \
     --file "$NEW_PATH" \
     --type "Sub-plan"   # or "Branch"
     --parent "$MASTER" \
     --phase <N> \
     [--pre-planned true]   # if sub-plan and pre-planned
   ```

9. **Update the master plan**:
   - Update phase icon:
     ```bash
     commands/plan-manager/bin/pm-md update-phase-icon --file "$MASTER" --phase <N> \
       --icon "$([ "$type" = "Sub-plan" ] && echo "📋" || echo "🔀")"
     ```
   - Update dashboard row:
     ```bash
     commands/plan-manager/bin/pm-md update-dashboard-row --file "$MASTER" --phase <N> \
       --status "$([ "$type" = "Sub-plan" ] && echo "📋 Sub-plan" || echo "🔀 Branch")" \
       --subplan-link "[$(basename $NEW_PATH)](./$filename)"
     ```
   - Add link to the plan in the phase section (Edit the file directly).

10. **Update state file**:
    ```bash
    commands/plan-manager/bin/pm-state add-subplan \
      --path "$NEW_PATH" \
      --parent-plan "$MASTER" \
      --phase <N> \
      --type "$([ "$type" = "Sub-plan" ] && echo "sub-plan" || echo "branch")" \
      [--pre-planned]   # if sub-plan and pre-planned
    ```

11. **Confirm based on type**:
    - Sub-plan (renamed): `✓ Captured and renamed {old-file} → {new-file}, linked as sub-plan to Phase {N}`
    - Sub-plan (not renamed): `✓ Captured {file} → linked as sub-plan to Phase {N}`
    - Branch (renamed): `✓ Captured and renamed {old-file} → {new-file}, linked as branch to Phase {N}`
    - Branch (not renamed): `✓ Captured {file} → linked as branch to Phase {N}`
