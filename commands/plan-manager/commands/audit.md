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
3. Report findings:

```
Audit Results:

⚠️  Orphaned sub-plan: plans/old-idea.md (not linked to master)
⚠️  Broken link: plans/deleted.md (in state but file missing)
⚠️  Missing back-reference: plans/tangent.md (no Parent header)
✓  No stale phases detected

Recommendations:
- Run `/plan-manager capture plans/old-idea.md` to link orphan
- Run `/plan-manager cleanup` to remove broken links
```
