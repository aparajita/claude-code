# Command: status

## Usage

```
status [--all] [--master <path>]
```

Display the full plan hierarchy and status.

## Default (active master only)

1. Read state file to get active master plan
2. Read master plan to extract Status Dashboard
3. For each sub-plan linked to this master, read its status and blocker information
4. Display formatted output with blocker details:

```
Master Plan: plans/layout-engine/layout-engine.md (ACTIVE)
Subdirectory: layout-engine/
UI layout system redesign

Phase 1: ✅ Complete
Phase 2: 🔄 In Progress
  └─ layout-fix.md (Branch - In Progress)
Phase 3: 📋 Sub-plan
  └─ api-redesign.md (Sub-plan - In Progress)
Phase 4: ⏸️ Blocked by Phase 3
Phase 5: ⏸️ Blocked by Phase 3, api-redesign.md

Sub-plans: 2 total (1 sub-plan, 1 branch; 2 in progress)
```

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
  ...
  Sub-plans: 2 total (1 sub-plan, 1 branch; 2 in progress)

○ plans/auth-migration.md
  Flat structure
  Migration to OAuth 2.0

  Phase 1: ✅ Complete
  Phase 2: 🔄 In Progress
  Phase 3: ⏸️ Blocked by Phase 2
  ...
  Sub-plans: 1 total (1 branch; 1 in progress)
```
