# Command: status

## Usage

```
status [--all]
```

Display the full plan hierarchy and status.

## Default (active master only)

1. Read state file to get active master plan
2. Read master plan to extract Status Dashboard
3. For each sub-plan linked to this master, read its status
4. Display formatted output:

```
Master Plan: plans/layout-engine/layout-engine.md (ACTIVE)
Subdirectory: layout-engine/
UI layout system redesign

Phase 1: ✅ Complete
Phase 2: 🔄 In Progress
  └─ layout-fix.md (Branch - In Progress)
Phase 3: 📋 Sub-plan
  └─ api-redesign.md (Sub-plan - In Progress)
Phase 4: ⏳ Pending

Sub-plans: 2 total (1 sub-plan, 1 branch; 1 in progress, 1 completed)
```

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
  Sub-plans: 2 total (1 sub-plan, 1 branch; 1 in progress, 1 completed)

○ plans/auth-migration.md
  Flat structure
  Migration to OAuth 2.0

  Phase 1: ✅ Complete
  Phase 2: 🔄 In Progress
  ...
  Sub-plans: 1 total (1 branch; 1 in progress)
```
