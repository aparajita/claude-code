# Command: list-masters

## Usage

```
list-masters
```

Show all master plans being tracked.

## Steps

1. Read state file
2. Display list with status:

```
Master Plans:

● plans/layout-engine/layout-engine.md (ACTIVE)
  Subdirectory: layout-engine/
  UI layout system redesign
  Status: 3/5 phases complete
  Sub-plans: 4 total (2 sub-plans, 2 branches; 2 in progress, 2 completed)

○ plans/auth-migration.md
  Flat structure
  Migration to OAuth 2.0
  Status: 1/3 phases complete
  Sub-plans: 1 total (1 branch; 1 in progress)
```
