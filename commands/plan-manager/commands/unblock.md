# Command: unblock

## Usage

```
unblock <phase-or-step> [from <blocker>]
```

Remove blockers from a phase or step.

**Examples:**
- `unblock 4` — Remove all blockers from phase 4
- `unblock 4 from 3` — Remove only phase 3 as a blocker of phase 4
- `unblock 5.2 from api-redesign.md` — Remove sub-plan blocker from step 5.2

## Steps

1. **Parse arguments**: Extract target (phase/step to unblock) and optional specific blocker.

2. **Get active master and phases**:
   ```bash
   MASTER=$(commands/plan-manager/bin/pm-state get-active-master)
   commands/plan-manager/bin/pm-md extract-phases --file "$MASTER"
   ```

3. **Validate target** exists in master plan phases.

4. **Read state** to get current blockers:
   ```bash
   commands/plan-manager/bin/pm-state read | jq '.subPlans[] | select(...) | .blockedBy'
   ```

5. **Update master plan**:
   - Update BlockedBy field:
     ```bash
     # If removing all blockers:
     commands/plan-manager/bin/pm-md update-blockedby --file "$MASTER" --value "—"
     # If removing specific blocker: compute new value then set it
     commands/plan-manager/bin/pm-md update-blockedby --file "$MASTER" --value "<remaining-blockers>"
     ```
   - If no blockers remain, use **AskUserQuestion** to determine new status:
     ```
     Question: "Phase {target} is no longer blocked. What's the new status?"
     Header: "Phase status"
     Options:
       - Label: "In Progress"
         Description: "Ready to start or resume work"
       - Label: "Pending"
         Description: "Not blocked, but not ready to start yet"
     ```
   - Update phase icon accordingly:
     ```bash
     commands/plan-manager/bin/pm-md update-phase-icon --file "$MASTER" --phase <target> \
       --icon "🔄"   # or "⏳" for Pending
     ```
   - Update dashboard row:
     ```bash
     commands/plan-manager/bin/pm-md update-dashboard-row --file "$MASTER" --phase <target> \
       --status "🔄 In Progress"   # or "⏳ Pending"
     ```

6. **Update state file** (Edit `.claude/plan-manager-state.json` directly or use Read/Write):
   - Remove blocker(s) from target's `blockedBy` array.
   - Remove target from blocker's `blocks` array.

7. **Confirm**:
   - If removed all: `✓ All blockers removed from phase {target}`
   - If removed specific: `✓ Removed {blocker} as blocker of phase {target}`
