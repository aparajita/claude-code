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
- `block 4 by 3,5` — Mark phase 4 as blocked by phases 3 and 5

## Steps

> **Terminology:** Throughout this document, "Phase" also includes "Milestone" or "Step" when used as section headers. Detect which term the plan uses and preserve it. See SKILL.md § Terminology.

1. **Parse arguments**:
   - Extract target (phase/step to be blocked)
   - Extract blocker(s) (what's blocking it) — supports comma-separated list (e.g., `3,5` or `3, api-redesign.md`)
   - If arguments don't match expected format, show usage error

2. **Read active master plan** to get context

3. **Validate target**:
   - If target is a number (e.g., `4`), verify phase exists in master plan
   - If target is a step (e.g., `5.2`), verify phase and step exist
   - If invalid, error: "Phase/step {target} not found in master plan"

4. **Validate blocker**:
   - If blocker is a number (phase), verify it exists in master plan
   - If blocker is a step (e.g., `3.1`), verify phase and step exist
   - If blocker is a file path, verify the sub-plan exists and is linked to this master plan
   - If blocker is the same as target, error: "A phase/step cannot block itself"
   - If invalid, error: "Blocker {blocker} not found"

5. **Check for circular dependencies**:
   - Read state file to check if target already blocks the blocker (directly or transitively)
   - If circular dependency detected, error: "Circular dependency detected: {target} already blocks {blocker}"

6. **Update master plan**:
   - Find the phase section for the target
   - Update the phase/step header icon to ⏸️ (e.g., `## ⏸️ Phase 4: Testing`)
   - Update the `**BlockedBy:**` field:
     - If currently `—`, replace with blocker
     - If already has blockers, append with comma: `3, 4`
   - Update Status Dashboard:
     - Change status to `⏸️ Blocked by {blocker}`
     - Update the Description column link anchor to match the updated phase header
   - Update the phase's `### Status:` subsection to `Blocked` (create if not present)

7. **Update state file**:
   - If target is a phase, find or create entry for that phase
   - Add blocker to `blockedBy` array
   - For the blocker, add target to its `blocks` array

8. **Confirm**: `✓ {Phase|Step} {target} is now blocked by {blocker}`

## Notes

- Multiple blockers are supported - run the command multiple times or use comma-separated list
- The `unblock` command removes blockers
- The `complete` command automatically checks for and offers to unblock dependent phases
- Blocker validation ensures referenced phases/steps/sub-plans actually exist
- Circular dependency checking prevents deadlocks
