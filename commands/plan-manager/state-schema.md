# State File Schema

This document describes the structure and format of the plan-manager state file.

## State File Location

State is stored in the project's `.claude/plan-manager-state.json`.

This keeps tooling metadata separate from actual plan files.

## State File Structure

```json
{
  "version": "1.0.0",
  "plansDirectory": "plans",
  "masterPlans": [
    {
      "path": "plans/layout-engine/layout-engine.md",
      "subdirectory": "layout-engine",
      "active": true,
      "created": "2026-01-30",
      "description": "UI layout system redesign"
    },
    {
      "path": "plans/auth-migration.md",
      "subdirectory": null,
      "active": false,
      "created": "2026-01-29",
      "description": "Migration to OAuth 2.0"
    }
  ],
  "subPlans": [
    {
      "path": "plans/layout-engine/sub-plan-1.md",
      "parentPlan": "plans/layout-engine/layout-engine.md",
      "parentPhase": 3,
      "status": "in_progress",
      "createdAt": "2026-01-30",
      "type": "sub-plan",
      "prePlanned": false,
      "blockedBy": [],
      "blocks": [4]
    }
  ]
}
```

## Field Descriptions

### Root Level

- **version** (string): State file schema version (currently `"1.0.0"`). Used for schema migrations and backward compatibility if the state file format evolves in future versions.
- **plansDirectory** (string): The base directory where plans are stored (e.g., `"plans"`, `"docs/plans"`)
- **masterPlans** (array): List of tracked master plans
- **subPlans** (array): List of all sub-plans and branches linked to master plans

### Master Plan Entry

- **path** (string): Full path to the master plan file (e.g., `"plans/layout-engine/layout-engine.md"`)
- **subdirectory** (string | null): Subdirectory name if using subdirectory organization (e.g., `"layout-engine"`), or `null` for flat structure
- **active** (boolean): Whether this is the currently active master plan
- **created** (string): ISO date when master plan was initialized (e.g., `"2026-01-30"`)
- **description** (string): Brief description of what this master plan covers

### Sub-Plan Entry

- **path** (string): Full path to the sub-plan/branch file (e.g., `"plans/layout-engine/api-redesign.md"`)
- **parentPlan** (string): Path to the master plan this is linked to (e.g., `"plans/layout-engine/layout-engine.md"`)
- **parentPhase** (number): Phase number in the master plan this relates to (e.g., `3`)
- **status** (string): Current status - `"in_progress"`, `"completed"`, `"blocked"`, etc.
- **createdAt** (string): ISO date when sub-plan was created (e.g., `"2026-01-30"`)
- **type** (string): Plan type - `"sub-plan"` or `"branch"`
- **prePlanned** (boolean): For sub-plans, whether created upfront (`true`) or during execution (`false`). Always `false` for branches.
- **blockedBy** (array): List of blockers that prevent this sub-plan from progressing. Each item can be:
  - Phase number (e.g., `3`) - blocked by a phase in the parent master plan
  - Step number (e.g., `2.1`) - blocked by a specific step
  - Sub-plan path (e.g., `"plans/layout-engine/api-redesign.md"`) - blocked by another sub-plan
- **blocks** (array): List of phases/steps/sub-plans that are blocked by this sub-plan. Same format as `blockedBy`.

### Optional Sub-Plan Fields

- **merged** (boolean): Set to `true` if the sub-plan has been merged into the master plan
- **mergedAt** (string): ISO date when the merge occurred (e.g., `"2026-01-31"`)

## Settings File Fields

The settings file (`plan-manager-settings.json`) can contain the following optional fields:

- **categoryDirectories** (object): Maps plan types to directory names (e.g., `{"documentation": "docs", "migration": "migrations"}`)
- **enableCategoryOrganization** (boolean): Whether to organize standalone plans by category (default: `true`)

## Plan Types

**Plan types** (`type` field):
- `"sub-plan"`: For implementing phases that need substantial planning
- `"branch"`: For handling unexpected issues/problems discovered during execution

**Pre-planned indicator** (`prePlanned` field): For sub-plans, tracks whether created upfront (`true`) or during execution (`false`). Always `false` for branches.

## Multiple Master Plans

**Multiple master plans** are supported for projects with parallel initiatives. Commands operate on the "active" master plan by default, but can target specific masters using the `--master` flag.

Only one master plan can be active at a time. Use the `switch` command to change the active master.

## Subdirectory Organization

**Subdirectory organization** is supported for better organization:
- New master plans automatically get their own subdirectory (e.g., `plans/layout-engine/`)
- Sub-plans are created in the same subdirectory as their master plan
- Flat structure (no subdirectory) is still supported for backward compatibility
- The `subdirectory` field tracks whether a master uses subdirectory organization (`null` = flat)
- **Category organization**: Standalone plans can be organized into category subdirectories (migrations/, docs/, designs/, features/, etc.)
  - Category-organized plans are not tracked in state file (they're not linked to any master)
  - Category directories are configured in `plan-manager-settings.json`

## Plans Directory Configuration

The `plansDirectory` can be configured per-project. Common locations:
- `plans/` (default)
- `docs/plans/`
- `.plans/`

The plans directory can be specified in:
1. `.claude/settings.local.json` (local override, gitignored)
2. `.claude/settings.json` (project-shared)
3. State file (persisted from initialization)

See [organization.md](organization.md) for more details on plans directory detection.

## State File Initialization

If the state file doesn't exist, the `overview` command can still scan for plans; other commands will prompt to run `init` first to create the state file.

The `init` command creates the state file and adds the first master plan.
