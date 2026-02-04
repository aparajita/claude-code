# Plan Manager Templates

This document contains all template formats used by the plan-manager skill.

## Status Dashboard Format

The Status Dashboard should be near the top of the master plan:

```markdown
## Status Dashboard

| Phase | Description | Status | Sub-plan |
|-------|-------------|--------|----------|
| 1 | [Foundation](#phase-1-foundation) | ⏳ Pending | — |
| 2 | [Layout Engine](#phase-2-layout-engine) | 🔄 In Progress | [layout-fix.md](./layout-fix.md) |
| 3 | [API Redesign](#phase-3-api-redesign) | 🔀 Branch | [api-redesign.md](./api-redesign.md) |
| 4 | [Testing](#phase-4-testing) | ⏸️ Blocked by 3 | — |
| 5 | [Deployment](#phase-5-deployment) | ⏳ Pending | — |
```

**Important:** The Description column should contain a markdown link to the corresponding phase section. To create the anchor:
1. Take the phase heading (e.g., `## Phase 2: Layout Engine`)
2. Extract the phase title/description part (e.g., `Layout Engine`)
3. Convert the full heading to lowercase and replace spaces with hyphens (e.g., `#phase-2-layout-engine`)
4. Wrap the description in a link: `[Layout Engine](#phase-2-layout-engine)`

### Status Icons

- ⏳ Pending — Not started
- 🔄 In Progress — Active work
- 🔀 Branch — Branch plan created for handling issues
- 📋 Sub-plan — Sub-plan created for implementing a phase
- ⏸️ Blocked — Waiting on another phase or sub-plan
- ✅ Complete — Done

**CRITICAL:** When updating the Status Dashboard, ALWAYS preserve the markdown links in the Description column. Each description must link to its corresponding phase section (e.g., `[Foundation](#phase-1-foundation)`). Never write plain text descriptions without the link wrapper.

### Blocker Notation

When a phase is blocked, the Status column should include the blocker information:
- `⏸️ Blocked by 3` — Blocked by phase 3
- `⏸️ Blocked by 2.1` — Blocked by step 2.1
- `⏸️ Blocked by [api-redesign.md](./api-redesign.md)` — Blocked by a sub-plan

Multiple blockers can be comma-separated: `⏸️ Blocked by 3, 4`

This notation is synchronized with the structured `blockedBy` field in the phase section metadata and state file.

## Phase Section Format

Each phase section should have a status icon at the beginning of the header for quick visual scanning:

```markdown
## Phase 3: 🔄 Layout Engine

**Status:** In Progress  <br>
**BlockedBy:** —  <br>
**Recommended Model:** Inherit  <br>
**Testing:** TBD  <br>
**Priority:** TBD  <br>
**Estimated Lines:** TBD

### Status: In Progress

### Sub-plans
- [layout-fix.md](./layout-fix.md) — Addressing edge case in grid layout

### Tasks
1. Implement base layout algorithm
2. Add responsive breakpoints
...
```

### Phase Header Icon Sync

The status icon in the phase header must be kept synchronized with the Status Dashboard:
- When the Status Dashboard is updated, update the phase header icon accordingly
- The icon uses the same emoji as the Status Dashboard (⏳ ⏸️ 🔄 🔀 📋 ✅)
- This enables quick visual scanning when scrolling through the plan document

**Icon-to-Status Mapping:**
- `⏳ Phase N: Title` — Pending (not started)
- `🔄 Phase N: Title` — In Progress (active work)
- `⏸️ Phase N: Title` — Blocked (waiting on dependencies)
- `🔀 Phase N: Title` — Branch (branch plan created)
- `📋 Phase N: Title` — Sub-plan (sub-plan created)
- `✅ Phase N: Title` — Complete (done)

The same pattern applies to step headers (e.g., `## Step 2.1: ⏳ Configure Database`).

## Branch Plan Template

Created when branching from a phase to handle an issue or problem:

```markdown
# Branch: {description}

**Type:** Branch  <br>
**Parent:** {master-plan-path} → Phase {N}  <br>
**Created:** {date}  <br>
**Status:** In Progress  <br>
**BlockedBy:** —

---

## Context

{Brief description of the issue/topic that led to this branch}

## Plan

{To be filled in}
```

## Sub-plan Template

Created for implementing a phase that needs substantial planning:

```markdown
# Sub-plan: {description}

**Type:** Sub-plan  <br>
**Parent:** {master-plan-path} → Phase {N}  <br>
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

## Captured Sub-plan Header

When capturing an existing plan as a sub-plan:

```markdown
**Type:** Sub-plan  <br>
**Parent:** {master-plan-path} → Phase {N}  <br>
**Captured:** {date}  <br>
**Pre-planned:** {Yes/No}  <br>
**Status:** In Progress  <br>
**BlockedBy:** —

---

{original content}
```

## Captured Branch Header

When capturing an existing plan as a branch:

```markdown
**Type:** Branch  <br>
**Parent:** {master-plan-path} → Phase {N}  <br>
**Captured:** {date}  <br>
**Status:** In Progress  <br>
**BlockedBy:** —

---

{original content}
```
