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

1. **Parse arguments**:
   - Extract target (phase/step to unblock)
   - Extract optional specific blocker (if `from <blocker>` provided)
   - If target not provided, show usage error

2. **Read active master plan** to get context

3. **Validate target**:
   - If target is a number, verify phase exists in master plan
   - If target is a step (e.g., `5.2`), verify phase and step exist
   - If invalid, error: "Phase/step {target} not found in master plan"

4. **Read state file** to get current blockers

5. **Determine blockers to remove**:
   - If no specific blocker provided, remove all blockers
   - If specific blocker provided:
     - Validate blocker exists (same validation as `block` command)
     - Check if it's actually blocking the target
     - If not blocking, warn: "{blocker} is not blocking {target}"

6. **Update master plan**:
   - Find the phase section for the target
   - Update the `**BlockedBy:**` field:
     - If removing all blockers, set to `—`
     - If removing specific blocker, remove from comma-separated list
   - Update Status Dashboard:
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
     - Update the phase/step header icon based on new status (🔄 for In Progress, ⏳ for Pending)
     - Update the Description column link anchor to match the updated phase header
   - Update the phase's `### Status:` subsection accordingly (create if not present)

7. **Update state file**:
   - Remove blocker(s) from target's `blockedBy` array
   - Remove target from blocker's `blocks` array

8. **Confirm**:
   - If removed all: `✓ All blockers removed from phase {target}`
   - If removed specific: `✓ Removed {blocker} as blocker of phase {target}`

## Notes

- Use `unblock <phase-or-step>` without specifying a blocker to clear all blockers at once
- The `complete` command automatically offers to unblock phases when their blocker completes
- Use `status` or `overview` to see what's currently blocking a phase
