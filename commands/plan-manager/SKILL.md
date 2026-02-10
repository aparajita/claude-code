# Plan Manager — Maintain master plan integrity with linked sub-plans

---
name: plan-manager
description: Manage hierarchical plans with linked sub-plans and branches. Use when the user wants to initialize a master plan, create a sub-plan for implementing a phase, branch for handling issues, capture an existing tangential plan, add a plan to the project, merge branch plans back into master, mark sub-plans complete, archive completed plans, check plan status, audit for orphaned plans, get an overview of all plans, organize/link related plans together, or rename plans to meaningful names. Responds to "/plan-manager" commands and natural language like "create a sub-plan for phase 3", "create a subplan for phase 3", "branch from phase 2", "capture that plan", "add this plan", "add this to phase X", "add this to the master plan", "link this to the master plan", "merge this branch", "archive that plan", "show plan status", "audit the plans", "overview of plans", "what plans do we have", "organize my plans", "rename that plan", or "Phase X is complete". **Interactive menu**: Invoke with no arguments (`/plan-manager`) to show a menu of available commands.
argument-hint: [command] [args] — Interactive menu if no command. Commands: init, branch, sub-plan (or subplan), capture, add, complete, merge, archive, status, audit, overview, organize, rename, config [--edit], switch, list-masters, help, version
allowed-tools: Bash(git:*), Read, Glob, Write, Edit, AskUserQuestion
---

## Overview

This skill maintains a single source of truth (master plan) while supporting two types of linked plans:
- **Sub-plans**: For implementing phases that need substantial planning (either pre-planned or created during execution)
- **Branches**: For handling unexpected issues/problems discovered during execution

All sub-plans and branches are bidirectionally linked to the master plan.

## Quick Command Reference

### Viewing & Status
- **status** [--all] — Show plan hierarchy and status
- **overview** — Discover all plans and their relationships
- **list-masters** — Show all tracked master plans

### Getting Started
- **init** <file> [--flat] — Initialize a master plan
- **config** [--edit] — View/edit category organization settings

### Working with Plans
- **branch** <phase> [--master <path>] — Create a branch for handling issues
- **sub-plan** <phase> [--master <path>] [--pre-planned] — Create a sub-plan for implementing a phase
- **capture** [file] [--phase N] [--master <path>] — Link an existing plan to a master
- **add** [file] [--phase N] [--master <path>] — Context-aware: add as master plan or link to phase
- **complete** <file-or-phase> — Mark a plan/phase as complete
- **merge** [file-or-phase] — Merge a plan's content into the master
- **archive** [file-or-phase] — Archive or delete a completed plan

### Organization
- **organize** — Auto-organize, link, and clean up plans
- **rename** <old-path> <new-path> — Rename a plan and update references
- **audit** — Find orphaned plans and broken links

### Multi-Master
- **switch** <master-plan> — Change which master plan is active

### Help
- **help** — Show detailed command reference
- **version** — Show plan-manager version

## Documentation

### Command Specifications
For detailed command documentation, see `commands/<command-name>.md`:
- [init](commands/init.md), [branch](commands/branch.md), [sub-plan](commands/sub-plan.md), [capture](commands/capture.md), [add](commands/add.md)
- [complete](commands/complete.md), [merge](commands/merge.md), [archive](commands/archive.md), [status](commands/status.md)
- [audit](commands/audit.md), [overview](commands/overview.md), [organize](commands/organize.md)
- [rename](commands/rename.md), [config](commands/config.md), [switch](commands/switch.md), [list-masters](commands/list-masters.md)
- [help](commands/help.md), [version](commands/version.md)

### Reference Documentation
- **[organization.md](organization.md)** — Subdirectory structure, category directories, and completed plans
- **[state-schema.md](state-schema.md)** — State file format and schema details

### Examples and Templates
- **[examples/templates.md](examples/templates.md)** — Plan templates and format specifications
- **[examples/workflows.md](examples/workflows.md)** — Common workflow examples
- **[examples/category-organization.md](examples/category-organization.md)** — Category organization examples
- **[examples/multi-master.md](examples/multi-master.md)** — Working with multiple master plans
- **[examples/natural-language.md](examples/natural-language.md)** — Natural language triggers and quick reference

## Execution Instructions

**CRITICAL: Command Routing**

When invoked with arguments (e.g., `/plan-manager <command> [args]`):

1. **Parse the first argument as the command name**
2. **Check if a command file exists**: `commands/plan-manager/commands/<command>.md`
3. **If the command file exists**: Read it and follow its instructions exactly
4. **If the command file does not exist**: Show an error message listing valid commands

**Valid commands**: init, branch, sub-plan (subplan), capture, add, complete, merge, archive, status, audit, overview, organize, rename, block, unblock, config, switch, list-masters, help, version

**Special cases**:
- No arguments: Show the interactive menu (see commands/interactive-menu.md)
- Natural language: Match against patterns in examples/natural-language.md

## Interactive Menu

Invoke with no arguments (`/plan-manager`) to show a menu of available commands. The menu displays all commands organized by category, and you can select by number or name.

## Key Concepts

**Master Plans**: The single source of truth for a project initiative. Contains phases/steps and links to sub-plans.

**Sub-plans**: Detailed implementation plans for phases that need substantial planning. Marked with 📋 in status displays.

**Branches**: Plans for handling unexpected issues discovered during execution. Marked with 🔀 in status displays.

**State File**: Tracks master plans, sub-plans, and their relationships in `.claude/plan-manager-state.json`.

**Subdirectories**: Master plans automatically get their own subdirectory (e.g., `plans/layout-engine/`) to organize related files.

**Category Directories**: Standalone plans can be organized into category subdirectories (docs/, migrations/, designs/, etc.).
