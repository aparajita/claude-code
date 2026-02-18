# Command: switch

## Usage

```
switch [master-plan]
```

Switch the active master plan.

## Steps

1. Read state file to get list of master plans
2. If argument provided, find matching master plan (by path or fuzzy match)
3. If no argument, use **AskUserQuestion** to select:

```
Question: "Which master plan should be active?"
Header: "Switch master"
Options:
  - Label: "layout-engine.md"
    Description: "UI layout system redesign (3/5 phases complete)"
  - Label: "auth-migration.md"
    Description: "Migration to OAuth 2.0 (1/3 phases complete)"
```

4. Update state file to mark selected master as active (others as inactive)
5. Confirm: `✓ Switched to master plan: {path}`
