# Plan Manager Multiple Master Plans

This document explains how to work with multiple master plans in parallel using the plan-manager skill.

## Overview

For projects with multiple parallel initiatives, you can track multiple master plans:

- Each master plan has its own phases and sub-plans
- One master plan is marked as "active" at a time
- Commands operate on the active master by default
- Use `--master <path>` flag to target a specific master
- Use `/plan-manager switch` to change the active master
- Use `/plan-manager list-masters` to see all tracked masters
- Use `/plan-manager status --all` to see all hierarchies

## Common Scenarios

- Large refactoring + bug fix initiative running in parallel
- Frontend redesign + backend API migration
- Multiple team members working on different features
- Different Claude Code sessions for different parts of the project

## Example Workflow

```
User: "I'm starting a new initiative for auth migration"
Claude: *Creates plans/auth-migration.md with 3 phases*

User: "/plan-manager init plans/auth-migration.md"
Claude: You have multiple master plans. Make this the active one?
        ┌─────────────────────────────────────────────────────────┐
        │ ○ Yes, switch to this                                   │
        │   Make this the active master plan for commands         │
        │                                                         │
        │ ○ No, keep current                                      │
        │   Add to tracking but keep current master active        │
        └─────────────────────────────────────────────────────────┘

User: *Selects "No, keep current"*
Claude: ✓ Added master plan: plans/auth-migration.md

User: "/plan-manager list-masters"
Claude: Master Plans:

        ● plans/layout-engine.md (ACTIVE)
          UI layout system redesign
          Status: 3/5 phases complete
          Sub-plans: 4 (2 in progress, 2 completed)

        ○ plans/auth-migration.md
          Migration to OAuth 2.0
          Status: 0/3 phases complete
          Sub-plans: 0

User: "switch to auth migration"
Claude: ✓ Switched to master plan: plans/auth-migration.md

User: "/plan-manager branch 1"
Claude: *Creates branch plan for auth migration Phase 1*
        ✓ Created branch: plans/oauth-setup.md (branched from Phase 1)
```

## Command Output Examples

### List Masters Command Output

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

### Status Command with --all Flag

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

## Working with Specific Masters

You can target a specific master plan using the `--master` flag without switching:

```bash
# Branch from Phase 2 of a non-active master
/plan-manager branch 2 --master plans/auth-migration.md

# Check status of a specific master
/plan-manager status --master plans/layout-engine.md

# Capture a plan to a specific master
/plan-manager capture oauth-setup.md --master plans/auth-migration.md
```
