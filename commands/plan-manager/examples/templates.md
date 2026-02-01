# Plan Manager Templates

This document contains all template formats used by the plan-manager skill.

## Status Dashboard Format

The Status Dashboard should be near the top of the master plan:

```markdown
## Status Dashboard

| Phase | Status | Sub-plans |
|-------|--------|-----------|
| 1     | ✅ Complete | — |
| 2     | 🔄 In Progress | [layout-fix.md](./layout-fix.md) |
| 3     | 🔀 Branch | [api-redesign.md](./api-redesign.md) |
| 4     | ⏸️ Blocked by 3 | — |
| 5     | ⏳ Pending | — |
```

### Status Icons

- ⏳ Pending — Not started
- 🔄 In Progress — Active work
- 🔀 Branch — Branch plan created for handling issues
- 📋 Sub-plan — Sub-plan created for implementing a phase
- ⏸️ Blocked — Waiting on another phase or sub-plan
- ✅ Complete — Done

## Phase Section Format

Each phase section should have a sub-plans subsection when applicable:

```markdown
## Phase 3: Layout Engine

### Status: In Progress

### Sub-plans
- [layout-fix.md](./layout-fix.md) — Addressing edge case in grid layout

### Tasks
1. Implement base layout algorithm
2. Add responsive breakpoints
...
```

## Branch Plan Template

Created when branching from a phase to handle an issue or problem:

```markdown
# Branch: {description}

**Type:** Branch
**Parent:** {master-plan-path} → Phase {N}
**Created:** {date}
**Status:** In Progress

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

**Type:** Sub-plan
**Parent:** {master-plan-path} → Phase {N}
**Created:** {date}
**Pre-planned:** {Yes/No}
**Status:** In Progress

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
**Type:** Sub-plan
**Parent:** {master-plan-path} → Phase {N}
**Captured:** {date}
**Pre-planned:** {Yes/No}
**Status:** In Progress

---

{original content}
```

## Captured Branch Header

When capturing an existing plan as a branch:

```markdown
**Type:** Branch
**Parent:** {master-plan-path} → Phase {N}
**Captured:** {date}
**Status:** In Progress

---

{original content}
```
