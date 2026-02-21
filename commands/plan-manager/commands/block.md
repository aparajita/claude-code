# Command: block

## Usage

```
block <phase-or-step> by <blocker>
```

Mark a phase or step as blocked by another phase, step, or sub-plan.

**Examples:**
- `block 4 by 3` — Mark phase 4 as blocked by phase 3
- `block 5.2 by 4` — Mark step 5.2 as blocked by phase 4
- `block 3 by api-redesign.md` — Mark phase 3 as blocked by a sub-plan

## Steps

1. **Parse arguments**: Extract target (phase/step to be blocked) and blocker (what's blocking it).

2. **Get active master and state**:
   ```bash
   MASTER=$(commands/plan-manager/bin/pm-state get-active-master)
   PHASES=$(commands/plan-manager/bin/pm-md extract-phases --file "$MASTER")
   ```

3. **Validate target and blocker** exist in master plan phases. Check for circular dependencies using state.

4. **Update master plan**:
   - Update phase icon to ⏸️:
     ```bash
     commands/plan-manager/bin/pm-md update-phase-icon --file "$MASTER" --phase <target> --icon "⏸️"
     ```
   - Update BlockedBy field:
     ```bash
     commands/plan-manager/bin/pm-md update-blockedby --file "$MASTER" --value "<blocker>"
     # If already has blockers, read current value and append: "<existing>, <new>"
     ```
   - Update dashboard row:
     ```bash
     commands/plan-manager/bin/pm-md update-dashboard-row --file "$MASTER" --phase <target> \
       --status "⏸️ Blocked by <blocker>"
     ```

5. **Update state file** (Edit `.claude/plan-manager-state.json` directly or use Read/Write):
   - Add blocker to target's `blockedBy` array.
   - Add target to blocker's `blocks` array.

6. **Confirm**: `✓ Phase {target} is now blocked by {blocker}`

## Notes

- Multiple blockers are supported — run the command multiple times or use comma-separated list.
- The `unblock` command removes blockers.
- The `complete` command automatically checks for and offers to unblock dependent phases.
