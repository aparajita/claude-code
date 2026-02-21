# Command: switch

## Usage

```
switch [master-plan]
```

Switch the active master plan.

## Steps

1. **List masters**:
   ```bash
   commands/plan-manager/bin/pm-state list-masters
   ```

2. **If argument provided**, find matching master plan (by path or fuzzy match on description/filename).

3. **If no argument**, use **AskUserQuestion** to select:
   ```
   Question: "Which master plan should be active?"
   Header: "Switch master"
   Options:
     - Label: "layout-engine.md"
       Description: "UI layout system redesign (current: active)"
     - Label: "auth-migration.md"
       Description: "Migration to OAuth 2.0"
   ```

4. **Switch active master**:
   ```bash
   commands/plan-manager/bin/pm-state switch-active --path "$SELECTED_PATH"
   ```

5. **Confirm**: `✓ Switched to master plan: {path}`
