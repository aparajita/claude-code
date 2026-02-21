# Plan Manager Skill

Manage hierarchical plans with linked sub-plans and branches. Maintains a single source of truth (master plan) while supporting two types of linked plans:
- **Sub-plans**: For implementing phases or steps that need substantial planning (nestable to arbitrary depth)
- **Branches**: For handling unexpected issues during execution

## Installation

Link the plan-manager directory to your global commands:

```bash
ln -s "$(pwd)/commands/plan-manager" ~/.claude/commands/plan-manager
```

## Key Features

- Track multiple master plans in parallel (for large projects with multiple initiatives)
- Initialize and track master plans with phase-based structure
- Flexible terminology: plans can use "Phase", "Milestone", or "Step" headers — all commands adapt automatically
- Create sub-plans for implementing complex phases or steps (nested to arbitrary depth)
- Branch into plans when issues arise during implementation
- Capture tangential plans created during work
- Automatically link related plans together based on content analysis
- Rename randomly-named plans to meaningful names
- Archive completed plans to keep workspace clean
- Flatten solo nested plans anywhere (plans root, completed/, category directories)
- Visualize plan hierarchies with ASCII charts
- Switch between master plans for multi-initiative projects
- Organize plans with subdirectories and category directories

## Command Reference

### Getting Started

**`init <path>`**
Initialize or add a master plan
- Options: `--nested`, `--description "text"`
- Example: `/plan-manager init plans/feature.md`

**`config`**
View/edit category organization settings
- Options: `--edit`, `--user`, `--project`
- Example: `/plan-manager config --edit`

### Working with Plans

**`branch <phase-or-step>`**
Create a branch plan for handling issues
- Options: `--master <path>`, `--parent <path>` (branch from a step in a sub-plan)
- Example: `/plan-manager branch 3`
- Example: `/plan-manager branch 2 --parent plans/layout-engine/grid-rethink.md`

**`sub-plan <phase-or-step>`**
Create a sub-plan for implementing a phase or step (also accepts `subplan`)
- Options: `--master <path>`, `--parent <path>` (nest under a sub-plan's step)
- Example: `/plan-manager sub-plan 2`
- Example: `/plan-manager sub-plan 3 --parent plans/layout-engine/grid-rethink.md`

**`capture [file]`**
Link an existing plan to a phase or step
- Options: `--phase N`, `--step N`, `--parent <path>`, `--master <path>`
- Example: `/plan-manager capture plans/fix.md --phase 2`
- Example: `/plan-manager capture plans/fix.md --step 3 --parent plans/grid-rethink.md`

**`complete <file-or-phase-or-range> [step]`**
Mark a sub-plan, phase, range, or step within a sub-plan as complete
- Example: `/plan-manager complete 3`
- Example: `/plan-manager complete plans/sub-plan.md 2`

**`merge [file]`**
Merge a plan's content into the master plan
- Example: `/plan-manager merge grid-fixes.md`

### Viewing Status

**`status`**
Show master plan hierarchy and status
- Options: `--all` (show all masters)
- Example: `/plan-manager status`

**`overview [directory]`**
Discover and visualize all plans
- Example: `/plan-manager overview`

**`list-masters`**
Show all tracked master plans
- Example: `/plan-manager list-masters`

### Organization

**`organize [directory]`**
Auto-organize, link, and clean up plans
- Options: `--nested` (skip solo nested plan flattening)
- Example: `/plan-manager organize`

**`normalize <file>`**
Normalize any plan format to standard format
- Options: `--type master|sub-plan|branch`, `--phase N`, `--step N`, `--master <path>`
- Example: `/plan-manager normalize plans/rough-plan.md`

**`rename <file> [name]`**
Rename a plan and update references
- Example: `/plan-manager rename plans/old.md new-name.md`

**`audit`**
Find orphaned plans and broken links
- Example: `/plan-manager audit`

### Multi-Master

**`switch [master]`**
Change which master plan is active
- Example: `/plan-manager switch`

## Natural Language

You can also use natural language:
- "create a sub-plan for phase 3"
- "create a sub-plan for step 2 of plans/grid-rethink.md"
- "branch from phase 2"
- "branch from step 3 of that sub-plan"
- "organize my plans"
- "capture that plan"
- "rename that plan"
- "normalize this plan"
- "what plans do we have?"
- "show plan status"

## Tips

- Run `/plan-manager` with no command for interactive menu
- Phase completion is auto-detected when you say "Phase X is complete"
- Merge branch plans back into master to consolidate updates
- Category organization keeps different plan types separated
- Subdirectories keep master plans and sub-plans together
- Sub-plans nest to arbitrary depth: steps within sub-plans can have their own sub-plans

## Recommended Enhancements

### Auto-Initialize Plans from Plan Mode

Add a PostToolUse hook to automatically convert plans created in Claude Code's plan mode into plan-manager tracked plans:

Add a PostToolUse hook that triggers on `ExitPlanMode` to automatically run `/plan-manager init` on the plan file, converting it into a tracked plan-manager plan.

This creates a seamless workflow: create a plan in plan mode, and it's automatically initialized in plan-manager when you exit, ready for phase tracking and sub-plan management.

## Documentation

- [SKILL.md](SKILL.md) — Skill definition and quick command reference
- [commands/](commands/) — Detailed command specifications
- [examples/](examples/) — Templates and workflows
- [organization.md](organization.md) — Directory structure and category organization
- [state-schema.md](state-schema.md) — State file format and schema
