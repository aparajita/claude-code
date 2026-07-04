# Plan Manager Templates

This document contains all template formats used by the plan-manager skill.

## Status Dashboard Format

The Status Dashboard should be near the top of the master plan:

```markdown
## Status Dashboard

| Phase | Description | Status | Sub-plan |
|-------|-------------|--------|----------|
<!-- Note: The "Phase" column header adapts to match the plan's term — "Milestone" or "Step" when the plan uses those headers. Anchors in the Description column also adapt (e.g., #-milestone-1-foundation). -->
| 1 | [Foundation](#-phase-1-foundation) | ⏳ Pending | — |
| 2 | [Layout Engine](#-phase-2-layout-engine) | 🔄 In Progress | [layout-fix.md](./layout-fix.md) |
| 3 | [API Redesign](#-phase-3-api-redesign) | 🔀 Branch | [api-redesign.md](./api-redesign.md) |
| 4 | [Testing](#-phase-4-testing) | ⏸️ Blocked by 3 | — |
| 5 | [Deployment](#-phase-5-deployment) | ⏳ Pending | — |
```

**Important:** The Description column should contain a markdown link to the corresponding phase section. To create the anchor:
1. Take the full phase heading (e.g., `## ⏳ Phase 2: Layout Engine`)
2. Extract the phase title/description part for the link text (e.g., `Layout Engine`)
3. Generate the anchor from the heading: lowercase, strip non-alphanumeric characters (except spaces and hyphens), replace spaces with hyphens
   - `## ⏳ Phase 2: Layout Engine` → `#-phase-2-layout-engine`
   - The leading dash comes from the status icon being stripped (the space after it remains)
   - All status icons produce the same anchor since they're all stripped to a space
4. Wrap the description in a link: `[Layout Engine](#-phase-2-layout-engine)`

**Note:** If a phase header has no status icon (e.g., `## Phase 2: Layout Engine`), the anchor has no leading dash: `#phase-2-layout-engine`. When a status icon is added, the anchor changes to `#-phase-2-layout-engine` and the Status Dashboard link must be updated to match.

### Status Icons

**REQUIRED ICONS (use these exact emojis):**
- ⏳ Pending — Not started
- 🔄 In Progress — Active work
- 🔀 Branch — Branch plan created for handling issues
- 📋 Sub-plan — Sub-plan created for implementing a phase
- ⏸️ Blocked — Waiting on another phase or sub-plan
- ✅ Complete — Done

**CRITICAL:** Always use ⏳ (hourglass) for pending status. NEVER use ⬜ (white square), ⏱ (stopwatch), or any other icon for pending states.

**CRITICAL:** When updating the Status Dashboard, ALWAYS preserve the markdown links in the Description column. Each description must link to its corresponding phase section (e.g., `[Foundation](#-phase-1-foundation)`). Never write plain text descriptions without the link wrapper. When a phase header's status icon changes (especially from no icon to having one), update the anchor in the link to match the new heading.

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
## 🔄 Phase 3: Layout Engine

**Status:** In Progress  <br>
**BlockedBy:** —  <br>
**Recommended model/effort:** {model}, {effort} — {brief rationale for the choice}

### Status: In Progress

### Sub-plans
- [layout-fix.md](./layout-fix.md) — Addressing edge case in grid layout

### Tasks
1. Implement base layout algorithm
2. Add responsive breakpoints
   ...
```

**Recommended model/effort field:** Always include. Format: `{model}, {effort level} — {brief rationale}`. Examples:
- `Sonnet 4.6, low effort — mechanical extract-method refactor; existing tests gate correctness`
- `Opus 4.7, high effort — multi-branch rewrite with interacting flags and ordering constraints`
- `Haiku 4.5 or Sonnet 4.6, low effort — small, mechanical key-binding change`

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

The same mapping applies when the plan uses "Milestone" or "Step" in place of "Phase" (e.g., `⏳ Milestone N: Title`, `⏳ Step N: Title`).

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

**Note:** `→ Phase {N}` becomes `→ Milestone {N}` or `→ Step {N}` to match the parent plan's term.

## Sub-plan Template

Created for implementing a phase that needs substantial planning:

```markdown
# Sub-plan: {description}

**Type:** Sub-plan  <br>
**Parent:** {master-plan-path} → Phase {N}  <br>
**Created:** {date}  <br>
**Status:** In Progress  <br>
**BlockedBy:** —

<!-- Note: → Phase {N} becomes → Milestone {N} or → Step {N} to match the parent plan's term. -->

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

## Nested Sub-plan Template

Created for implementing a step within a sub-plan that needs its own detailed plan:

```markdown
# Sub-plan: {description}

**Type:** Sub-plan  <br>
**Parent:** {parent-sub-plan-path} → Step {N}  <br>
**Master:** {master-plan-path}  <br>
**Created:** {date}  <br>
**Status:** In Progress  <br>
**BlockedBy:** —

---

## Purpose

{Brief description of what this step aims to accomplish}

## Implementation Approach

{To be filled in - how will this step be implemented}

## Dependencies

{Any dependencies or prerequisites}

## Plan

{Detailed implementation steps}
```

## Nested Branch Template

Created when branching from a step in a sub-plan to handle an issue:

```markdown
# Branch: {description}

**Type:** Branch  <br>
**Parent:** {parent-sub-plan-path} → Step {N}  <br>
**Master:** {master-plan-path}  <br>
**Created:** {date}  <br>
**Status:** In Progress  <br>
**BlockedBy:** —

---

## Context

{Brief description of the issue/topic that led to this branch}

## Plan

{To be filled in}
```

## Sub-plan with Children

When a sub-plan has its own child sub-plans, display them inline with the step list:

```markdown
## Plan

1. 📋 Research edge cases
   > Sub-plan: [edge-cases.md](./edge-cases.md)
2. ⏳ Implement fixes
3. ⏳ Write tests
```

The 📋 icon on a step indicates a child sub-plan exists for that step, mirroring how 📋 on a master plan phase indicates a sub-plan exists for that phase.

## Captured Sub-plan Header

When capturing an existing plan as a sub-plan:

```markdown
**Type:** Sub-plan  <br>
**Parent:** {master-plan-path} → Phase {N}  <br>
**Captured:** {date}  <br>
**Status:** In Progress  <br>
**BlockedBy:** —

---

{original content}
```

**Note:** In all captured templates, `→ Phase {N}` becomes `→ Milestone {N}` or `→ Step {N}` to match the parent plan's term.

## Captured Nested Sub-plan Header

When capturing an existing plan as a sub-plan under another sub-plan:

```markdown
**Type:** Sub-plan  <br>
**Parent:** {parent-sub-plan-path} → Step {N}  <br>
**Master:** {master-plan-path}  <br>
**Captured:** {date}  <br>
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

## Captured Nested Branch Header

When capturing an existing plan as a branch under a sub-plan:

```markdown
**Type:** Branch  <br>
**Parent:** {parent-sub-plan-path} → Step {N}  <br>
**Master:** {master-plan-path}  <br>
**Captured:** {date}  <br>
**Status:** In Progress  <br>
**BlockedBy:** —

---

{original content}
```

## SongScribe Sub-plan Conventions

The Sub-plan Template above defines the file header and top-level sections.
SongScribe sub-plans (in `plans/`) layer a consistent internal structure on top
so any single phase can be handed to an implementer or subagent without further
context. Follow these when authoring or capturing a sub-plan; they make reading
sibling sub-plans unnecessary.

### File layout

H1 is `# Sub-plan: Phase N — {Title}` (mirror the master plan's phase title),
followed by the standard Sub-plan header block, then these sections in order:

1. `## Purpose` — what this phase delivers, and what it explicitly does **not**
   (state the defer-to-later boundaries).
2. `## Implementation Approach` — the design, plus any optional subsections below.
3. `## Dependencies` — internal/external prerequisites; name the blocked-by
   relationship and any "must not regress X" constraints.
4. `## Plan` — opens with the internal Status Dashboard, then one section per
   internal phase.
5. `## Verification (whole sub-plan)` — cumulative acceptance checks.

### Optional Implementation-Approach subsections

Add these as `###` subsections when they apply — they are what let a phase be
implemented without re-deriving context:

- **Decomposition rationale** — why the internal phases are split as they are
  (typically: isolate hard conceptual work for Opus from mechanical work for
  Sonnet/Haiku, and defer tests to a dedicated phase).
- **Key code touchpoints** — the exact symbols/files the phase reads or edits
  (`path:line` where useful), plus any read-only reference code to mirror.
- **Flagged uncertainties (resolve during implementation)** — a numbered list of
  open questions, each with a recommended resolution to verify rather than block
  on.

Per-phase content (mapping tables, target-output samples, "Gaps to close",
etc.) is not a fixed convention — include it only when the phase needs it.

### Internal Status Dashboard

The first thing under `## Plan` is a dashboard for the sub-plan's **own** phases.
Same shape as the master dashboard, but the last column is **Recommended model**
instead of **Sub-plan**:

```markdown
| Phase | Description | Status | Recommended model |
|-------|-------------|--------|-------------------|
| 1 | [Mapping Table](#-phase-1-mapping-table) | ⏳ Pending | Sonnet 4.6 / Haiku 4.5, low |
| 2 | [Writer Transform](#-phase-2-writer-transform) | ⏳ Pending | Opus 4.8, high |
```

### Internal phase sections

Each internal phase mirrors the master Phase Section Format: an icon header, the
metadata block, and a numbered `### Tasks` list.

```markdown
## ⏳ Phase N: {Title}

**Status:** Pending  <br>
**BlockedBy:** {phase numbers, or —}  <br>
**Recommended model/effort:** {model}, {effort} — {rationale}

### Tasks
1. ...
```

### Authoring rules

- **≤ 7 tasks per phase.** Split any phase that would exceed this.
- **Match the model to the work.** Mechanical changes (lookup tables, test
  wiring, repetitive emission) → Sonnet 4.6 / Haiku 4.5; reversible/boundary or
  multi-branch design → Opus. The Recommended model/effort field must reflect
  this split.
- **Isolate tests.** If a complex phase needs more than a few tests, make test
  writing its own phase (usually last), blocked by the phases it tests.
- **Gate every phase.** The final task(s) of each phase run the project scripts —
  `./scripts/compile.sh`, and `./scripts/test.sh {target}` for test phases — and
  must report SUCCESS / green before the phase is considered done.
