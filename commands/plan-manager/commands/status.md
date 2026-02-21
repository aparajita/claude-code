# Command: status

## Usage

```
status [--all] [--master <path>]
```

Display the full plan hierarchy and status.

## Default (active master only)

1. Read state file to get active master plan
2. Read master plan to extract Status Dashboard
3. **Build a tree from state entries** by following `parentPlan` chains:
   - For each sub-plan linked to this master (directly or transitively), read its status and blocker information
   - Group sub-plans by their parent: direct children under master phases, nested children under their parent sub-plan's steps
4. **Display formatted output recursively** with increasing indentation for nested sub-plans:

```
Master Plan: plans/layout-engine/layout-engine.md (ACTIVE)
Subdirectory: layout-engine/
UI layout system redesign

Phase 1: ✅ Complete
Phase 2: 🔄 In Progress
  └─ layout-fix.md (Branch - In Progress)
Phase 3: 📋 Sub-plan
  └─ api-redesign.md (Sub-plan - In Progress)
     Step 3: 📋 Sub-plan
       └─ edge-cases.md (Sub-plan - In Progress)
Phase 4: ⏸️ Blocked by Phase 3
Phase 5: ⏸️ Blocked by Phase 3, api-redesign.md

Sub-plans: 3 total (2 sub-plans, 1 branch; 3 in progress, depth: 2)
```

**Recursive display rules:**
- Only show steps of a sub-plan that have children (do not enumerate all steps of every sub-plan)
- Each nesting level adds 2 more spaces of indentation
- The summary line includes a depth indicator when nesting depth > 1

**Blocker Display Format:**
- When a phase is blocked, show `⏸️ Blocked by` followed by the blocker(s)
- Phase blockers: `Phase 3`
- Step blockers: `Step 2.1`
- Sub-plan blockers: Use filename (e.g., `api-redesign.md`)
- Multiple blockers: Comma-separated (e.g., `Phase 3, api-redesign.md`)

## With --master flag

Show status for a specific master plan (without switching the active master):

```
/plan-manager status --master plans/auth-migration.md
```

This displays the same output as the default view, but for the specified master plan instead of the active one.

## With --all flag

Show status for all master plans:

```
Master Plans: 2

● plans/layout-engine/layout-engine.md (ACTIVE)
  Subdirectory: layout-engine/
  UI layout system redesign

  Phase 1: ✅ Complete
  Phase 2: 🔄 In Progress
    └─ layout-fix.md (Branch - In Progress)
  Phase 3: 📋 Sub-plan
    └─ api-redesign.md (Sub-plan - In Progress)
       Step 3: 📋 Sub-plan
         └─ edge-cases.md (Sub-plan - In Progress)
  ...
  Sub-plans: 3 total (2 sub-plans, 1 branch; 3 in progress, depth: 2)

○ plans/auth-migration.md
  Flat structure
  Migration to OAuth 2.0

  Phase 1: ✅ Complete
  Phase 2: 🔄 In Progress
  Phase 3: ⏸️ Blocked by Phase 2
  ...
  Sub-plans: 1 total (1 branch; 1 in progress)
```
