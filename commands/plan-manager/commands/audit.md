# Command: audit

## Usage

```
audit
```

Find orphaned phases, broken links, and stale items.

## Steps

1. **Get plans directory and state**:
   ```bash
   PLANS_DIR=$(commands/plan-manager/bin/pm-state get-plans-dir)
   STATE=$(commands/plan-manager/bin/pm-state read)
   MASTER=$(commands/plan-manager/bin/pm-state get-active-master)
   ```

2. **Find orphaned .md files** (files not tracked in state):
   ```bash
   commands/plan-manager/bin/pm-files find-orphans --plans-dir "$PLANS_DIR"
   ```

3. **Check for broken links** (sub-plans in state that no longer exist):
   - Iterate over `$STATE | jq '.subPlans[].path'` and check each file exists.

4. **Check for missing back-references**:
   - For each tracked sub-plan file, verify it has a `**Parent:**` header.
   - Read each sub-plan file and grep for the Parent field.

5. **Check for Dashboard drift**:
   - Compare dashboard rows: `commands/plan-manager/bin/pm-md extract-dashboard --file "$MASTER"`
   - Against state: `commands/plan-manager/bin/pm-state list-subplans --master "$MASTER"`
   - Report mismatches.

6. **Report findings**:
   ```
   Audit Results:

   ⚠️  Orphaned sub-plan: plans/old-idea.md (not linked to master)
   ⚠️  Broken link: plans/deleted.md (in state but file missing)
   ⚠️  Missing back-reference: plans/tangent.md (no Parent header)
   ✓  No stale phases detected

   Recommendations:
   - Run `/plan-manager capture plans/old-idea.md` to link orphan
   - Run `/plan-manager audit` and remove broken state entry manually from .claude/plan-manager-state.json
   ```
