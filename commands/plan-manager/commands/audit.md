# Command: audit

## Usage

```
audit
```

Find orphaned phases, broken links, and stale items.

## Steps

1. Read state file and master plan
2. Check for issues:
   - **Orphaned sub-plans**: Files in `plans/` that look like sub-plans but aren't in state
   - **Broken links**: Sub-plans in state that no longer exist
   - **Stale phases**: Phases marked "in progress" with no recent activity
   - **Missing back-references**: Sub-plans without proper parent header
   - **Dashboard drift**: Status Dashboard doesn't match actual state
   - **Invalid `parentStep` references**: `parentStep` points to a step number that doesn't exist in the parent sub-plan
   - **Invalid `parentPlan` chain**: `parentPlan` points to a file not found in `subPlans[]` or `masterPlans[]`
   - **Orphaned nested sub-plans**: Parent sub-plan was deleted but child sub-plans remain in state
   - **Missing `**Master:**` header**: Nested sub-plans (where `parentStep` is set) that lack the `**Master:**` header in the plan file
   - **`masterPlan` field mismatch**: The `masterPlan` field in state doesn't match the actual chain (walking `parentPlan` to the root)
3. Report findings:

```
Audit Results:

⚠️  Orphaned sub-plan: plans/old-idea.md (not linked to master)
⚠️  Broken link: plans/deleted.md (in state but file missing)
⚠️  Missing back-reference: plans/tangent.md (no Parent header)
⚠️  Invalid parentStep: plans/layout-engine/edge-cases.md references Step 5 in grid-rethink.md, but grid-rethink.md only has 3 steps
⚠️  Orphaned nested: plans/layout-engine/deep-fix.md parent sub-plan (grid-rethink.md) no longer exists
⚠️  Missing Master header: plans/layout-engine/edge-cases.md is nested but has no **Master:** field
⚠️  masterPlan mismatch: plans/layout-engine/edge-cases.md state says masterPlan is "plans/other.md" but chain resolves to "plans/layout-engine/layout-engine.md"
✓  No stale phases detected

Recommendations:
- Run `/plan-manager capture plans/old-idea.md` to link orphan
- Manually remove the broken entry from `.claude/plan-manager-state.json` to clean up broken links
- Fix parentStep references by updating state or re-linking the sub-plan
- Re-link orphaned nested sub-plans to a new parent or remove them
```
