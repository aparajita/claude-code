---
name: plan-manager
description: Manage hierarchical plans with linked sub-plans and branches, supporting arbitrary nesting depth. Use when the user wants to initialize a master plan, create a sub-plan for a phase, step or milestone (or nested under another sub-plan), branch for handling issues, capture or add an existing plan, merge a branch plan back into its parent, mark plans, phases or steps complete, archive or prune completed plans, check status, audit for orphaned plans, get an overview, organize or link related plans, normalize a plan to the standard format, or rename plans. Responds to "/plan-manager" commands and natural language like "create a sub-plan for phase 3", "branch from step 2 of grid-rethink.md", "capture that plan", "add this to the master plan", "merge this branch", "archive that plan", "show plan status", "what plans do we have", "normalize plans/foo.md", or "Phase X is complete". **Interactive menu**: Invoke with no arguments (`/plan-manager`) to show a menu of available commands.
argument-hint: [command] [args] — Interactive menu if no command. Commands: init, branch [--parent <path>], sub-plan (or subplan) [--parent <path>], capture [--step N] [--parent <path>], add, complete, merge, archive, delete (remove, rm) <file>, prune, block, unblock, status, audit, overview, organize [--nested], normalize [--step N], rename, config [--user|--project] [--edit] [--no-categories] [--categories], switch, list-masters, help, version
allowed-tools: Bash(git:*), Read, Glob, Write, Edit, AskUserQuestion
---

# Plan Manager — Maintain master plan integrity with linked sub-plans

## Overview

This skill maintains a single source of truth (master plan) while supporting two types of linked plans:
- **Sub-plans**: For implementing phases or steps that need substantial planning
- **Branches**: For handling unexpected issues/problems discovered during execution

All sub-plans and branches are bidirectionally linked to their parent plan. **Nesting is supported to arbitrary depth**: a sub-plan's step can have its own sub-plan, just as a master plan phase can. All files live flat in the master plan's subdirectory; hierarchy is tracked through metadata.

## Quick Command Reference

### Viewing & Status
- **status** [--all] [--master <path>] — Show plan hierarchy and status
- **overview** — Discover all plans and their relationships
- **list-masters** — Show all tracked master plans

### Getting Started
- **init** <file> [--nested] — Initialize a master plan
- **config** [--user|--project] [--edit] [--no-categories] [--categories] — View/edit category organization settings

### Working with Plans
- **branch** <phase-or-step> [--master <path>] [--parent <path>] — Create a branch for handling issues
- **sub-plan** <phase-or-step> [--master <path>] [--parent <path>] — Create a sub-plan for implementing a phase or step
- **capture** [file] [--phase N] [--step N] [--parent <path>] [--master <path>] — Link an existing plan to a parent
- **add** [file] [--phase N] [--master <path>] — Context-aware: add as master plan or link to phase
- **complete** <file-or-phase-or-range> [step] [--master <path>] [--unattended] — Mark a plan/phase/range as complete, or a step within a sub-plan
- **merge** [file-or-phase] — Merge a sub-plan or branch's content into the master
- **archive** [file-or-phase] — Archive or delete a completed plan
- **delete** <file> (aliases: **remove**, **rm**) — Permanently delete any plan with confirmation
- **prune** — Review completed plans and delete or archive them

### Blocking
- **block** <phase-or-step> by <blocker> — Mark a phase or step as blocked
- **unblock** <phase-or-step> [from <blocker>] — Remove blockers from a phase or step

### Organization
- **normalize** <file> [--type master|sub-plan|branch] [--phase N] [--step N] [--master <path>] — Normalize any plan format to standard
- **organize** [directory] [--nested] — Auto-organize, link, and clean up plans
- **rename** <file> [new-name] — Rename a plan and update references
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
- [complete](commands/complete.md), [merge](commands/merge.md), [archive](commands/archive.md), [delete](commands/delete.md), [prune](commands/prune.md), [status](commands/status.md)
- [audit](commands/audit.md), [overview](commands/overview.md), [organize](commands/organize.md)
- [normalize](commands/normalize.md), [rename](commands/rename.md), [config](commands/config.md), [switch](commands/switch.md), [list-masters](commands/list-masters.md)
- [block](commands/block.md), [unblock](commands/unblock.md)
- [help](commands/help.md), [version](commands/version.md)

### Reference Documentation
- **[organization.md](organization.md)** — Subdirectory structure, category directories, and completed plans
- **[state-schema.md](state-schema.md)** — State file format and schema details

### Examples and Templates
- **[~/.claude/skills/make-plan/plan-templates.md](../make-plan/plan-templates.md)** — Plan templates and format specifications
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

**Valid commands**: init, branch, sub-plan (subplan), capture, add, complete, merge, archive, delete (remove, rm), prune, status, audit, overview, organize, normalize, rename, block, unblock, config, switch, list-masters, help, version

**Special cases**:
- No arguments: Show the interactive menu (see commands/interactive-menu.md)
- Natural language: Match against patterns in examples/natural-language.md
- `remove` and `rm` are aliases for `delete` — route them to commands/delete.md

## Interactive Menu

Invoke with no arguments (`/plan-manager`) to show a menu of available commands. The menu displays all commands organized by category, and you can select by number or name.

## Key Concepts

**Master Plans**: The single source of truth for a project initiative. Contains phases (also called milestones or steps) and links to sub-plans.

**Sub-plans**: Detailed implementation plans for phases or steps that need substantial planning. Marked with 📋 in status displays. Can be nested to arbitrary depth.

**Branches**: Plans for handling unexpected issues discovered during execution. Marked with 🔀 in status displays. Can be created under master plan phases or sub-plan steps.

**Nested Sub-plans**: Sub-plans created for steps within other sub-plans. All nested files live flat in the master plan's subdirectory; hierarchy is tracked through `parentPlan`/`parentStep`/`masterPlan` metadata.

**State File**: Tracks master plans, sub-plans, and their relationships in `.claude/plan-manager-state.json`.

**Subdirectories**: Master plans automatically get their own subdirectory (e.g., `plans/layout-engine/`) to organize related files.

**Category Directories**: Standalone plans can be organized into category subdirectories (docs/, migrations/, designs/, etc.).

## Terminology: Phase, Milestone, and Step

All three terms — **Phase**, **Milestone**, and **Step** — are valid section headers in any plan file. Plans may use `## Phase N:`, `## Milestone N:`, or `## Step N:` as their section headers.

**Detection:** When reading a plan, scan its `##` headers to determine which term it uses. A plan that uses `## Milestone 1:`, `## Milestone 2:` is a "Milestone plan"; one that uses `## Phase 1:` is a "Phase plan".

**Preservation:** When modifying a plan (completing phases, updating status, adding links), preserve the term the plan already uses. If a plan uses Milestones, keep `## Milestone N:` headers.

**Normalization:** The `normalize` command is the only command that standardizes terminology — it converts to "Phase" for master plans and "Step" for sub-plans. All other commands preserve the existing term.

**State file:** The `parentPhase` field in the state file applies regardless of whether the plan uses Phase, Milestone, or Step headers.

**Command arguments:** Commands accept `milestone` as a keyword alongside `phase`. For example: `/plan-manager complete milestone 3`, `/plan-manager branch milestone 2`.

## Status Icons

**CRITICAL:** When working with plans, always use these exact emojis for status:
- ⏳ Pending (not started) — NEVER use ⬜ or other icons
- 🔄 In Progress
- ⏸️ Blocked
- ✅ Complete
- 📋 Sub-plan
- 🔀 Branch
