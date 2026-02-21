# Command: normalize

## Usage

```
normalize <file> [--type master|sub-plan|branch] [--phase N] [--master <path>]
```

Normalize a plan file from any format into the standard plan-manager format. Handles plans with phases, steps, milestones, tasks, numbered lists, checkboxes, or freeform sections.

## Purpose

Claude Code can produce plans in many formats depending on context. This command reads the file, detects its structure, maps it to the standard format, rewrites it in place, then optionally wires it into tracking.

## Steps

### 1. Read and Classify the File

Read the file content, then determine the plan type and structural elements.

**Detect plan type** (if `--type` not provided):
- Has `**Type:** Sub-plan` or `**Type:** Branch` header → already typed; check if normalization still needed
- Has `**Parent:**` header → sub-plan or branch
- Has multi-phase structure (3+ top-level sections that look like stages of work) → master plan
- Has a flat list of implementation steps → sub-plan (or master with only one phase worth of work)
- Ambiguous → ask user via **AskUserQuestion**:

```
Question: "What kind of plan is this?"
Header: "Plan type"
Options:
  - Label: "Master plan"
    Description: "Top-level plan with phases that may get sub-plans"
  - Label: "Sub-plan"
    Description: "Detailed implementation plan for a specific phase"
  - Label: "Branch"
    Description: "Plan for handling an unexpected issue"
  - Label: "Standalone"
    Description: "Freeform plan, not linked to any master"
```

**Detect structural elements** in the content:

| Pattern found | Maps to |
|---------------|---------|
| `## Phase N:`, `## Step N:` | Already normalized headings |
| `## Milestone N:`, `## Milestone: Title` | → `## Phase N: Title` (master) |
| `## Task N:`, `## Task: Title` | → `## Phase N:` or `## Step N:` depending on type |
| `## Stage N:`, `## Stage: Title` | → `## Phase N: Title` |
| `### N. Title`, `### Step N: Title` | → `## Step N: Title` (sub-plan) or `## Phase N:` (master) |
| `- [ ] Title`, `* [ ] Title` | → numbered step list items or `## Step N:` headings |
| `1. Title`, `2. Title` at top level | → `## Phase N:` (master) or step items (sub-plan) |
| Freeform `## Section` headings | → Claude maps each to a phase/step based on content (see below) |
| No clear structure | → single-phase master or flat sub-plan; Claude proposes structure |

**Detect existing status indicators** and map to standard icons:
- `[x]`, `✓`, `done`, `complete`, `DONE` → ✅
- `[ ]`, `todo`, `pending`, `not started` → ⏳
- `in progress`, `WIP`, `started` → 🔄
- `blocked`, `waiting` → ⏸️
- No indicator → ⏳ (pending)

**Smart freeform handling**: When a file has mixed freeform `##` sections, distinguish between supporting sections and actual phases/steps:
- Supporting sections (e.g., "Background", "Approach", "Context", "Testing Strategy", "Notes", "References") → keep as-is at `##` level, do NOT add status icons or include in Status Dashboard
- Phase/step sections (e.g., "Phase 1", "Implementation", "Migration", "Setup", numbered stages) → normalize to `## ⏳ Phase N:` or `## ⏳ Step N:` and include in dashboard

### 2. Confirm Structure (if ambiguous or complex)

If the plan has 3+ structural elements that require remapping, show a preview and confirm:

```
Question: "I'll normalize this plan. Does this mapping look right?"
Header: "Confirm structure"
Options:
  - Label: "Yes, normalize it (Recommended)"
    Description: "Milestone 1→Phase 1, Milestone 2→Phase 2, Milestone 3→Phase 3"
  - Label: "Adjust mapping"
    Description: "Tell me how to remap the sections"
  - Label: "Cancel"
    Description: "Don't change the file"
```

### 3. Normalize the File Content

Rewrite the file in place using the Write tool. Apply these transformations:

**For master plans:**

1. Ensure a single `# Title` h1 heading at the top (extract from existing title or generate from filename)
2. Remap all phase/step headings to `## ⏳ Phase N: Title` format:
   - Preserve original title text, just change the heading keyword and add icon
   - Renumber sequentially if numbering is inconsistent or absent
3. Preserve all body content under each heading verbatim
4. Remove any pre-existing status summary tables that aren't in standard format
5. Build and insert a Status Dashboard after the h1 (before the first phase heading):

   ```markdown
   ## Status Dashboard

   | Phase | Title | Status |
   |-------|-------|--------|
   | 1 | <title> | ⏳ Pending |
   | 2 | <title> | ⏳ Pending |
   ```

   Use whatever status was detected for each phase (Pending/In Progress/Complete/Blocked).

**For sub-plans / branches:**

1. Ensure a single `# Sub-plan: Title` or `# Branch: Title` h1
2. If the `**Type:**` header block is missing, prepend it before the first content section:
   ```markdown
   **Type:** Sub-plan
   **Parent:** <master-path or "unknown — update with capture">
   **Phase:** <N or "? — update with capture">

   ---
   ```
   If `--master` and `--phase` weren't provided, use placeholder values and note them in the output.
3. Remap structural headings to `## ⏳ Step N: Title` or `## ⏳ Phase N: Title` format with status icons
4. Preserve all body content verbatim
5. Ensure a `---` separator exists between the header block and body content

**For both:**
- Do NOT alter body text content, code blocks, or prose — only normalize headings and metadata
- Preserve any existing links
- If a heading already uses the correct format (e.g. `## ⏳ Phase 1:`), leave it unchanged
- Supporting sections in freeform plans are preserved as plain `##` headings without icons

### 4. Wire into Tracking (optional)

**Skip this step entirely if normalize was invoked by another command** (init, capture, add) — those commands handle tracking themselves.

After normalization, if the file isn't yet tracked and normalize was invoked directly:

**Master plan** → offer to run `init`:

```
Question: "Add this master plan to tracking?"
Header: "Track plan"
Options:
  - Label: "Yes, initialize it (Recommended)"
    Description: "Run init to add to .claude/plan-manager-state.json"
  - Label: "Not yet"
    Description: "Leave untracked for now"
```

If yes, follow the `init` command steps for this file.

**Sub-plan / branch** → if `--master` was provided or an active master exists, offer to run `capture`:

```
Question: "Link this sub-plan to the master plan?"
Header: "Link plan"
Options:
  - Label: "Yes, capture it (Recommended)"
    Description: "Run capture to link to Phase {N} of the master plan"
  - Label: "Not yet"
    Description: "Leave unlinked for now"
```

If yes, follow the `capture` command steps for this file.

### 5. Confirm

Output a summary of what was done:

```
✓ Normalized plans/rough-plan.md:
  • Remapped 4 milestones → phases (Phase 1–4)
  • Added ⏳ status icons to all phase headings
  • Added Status Dashboard (4 phases)
  • Type: Master plan
```

Or for sub-plans:

```
✓ Normalized plans/impl-notes.md:
  • Remapped 6 tasks → steps (Step 1–6)
  • Added parent header block (placeholder parent — update with capture)
  • Type: Sub-plan
```

## Examples of Input Formats

**Milestone-based (common in GitHub issues / project boards):**
```markdown
# API Redesign

## Milestone 1: Research
...

## Milestone 2: Implementation
...
```
→ `## ⏳ Phase 1: Research`, `## ⏳ Phase 2: Implementation` + Status Dashboard

**Checkbox list (common from quick planning sessions):**
```markdown
# Auth Migration Plan

- [ ] Audit current auth system
- [ ] Design new OAuth flow
- [x] Set up test environment
- [ ] Migrate users
```
→ If master: four phases (Phase 3 gets ✅). If sub-plan: four numbered steps.

**Freeform sections (common from Claude Code planning responses):**
```markdown
# Layout Engine Rewrite

## Background
...

## Approach
...

## Phase 1: Core Engine
...

## Phase 2: Integration
...

## Testing Strategy
...
```
→ Background/Approach/Testing Strategy are supporting sections (kept as plain `##`). Phase 1 and Phase 2 are normalized (icons added). Status Dashboard covers only the phases.

**Already partially normalized:**
```markdown
# Plan

## Phase 1: Foundation
...

## Phase 2: Build
...
```
→ Only missing icons and dashboard; adds `⏳` to headings and inserts Status Dashboard. No structural remapping needed.
