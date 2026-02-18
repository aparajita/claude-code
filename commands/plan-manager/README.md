# Plan Manager Skill

Manage hierarchical plans with linked sub-plans and branches. Maintains a single source of truth (master plan) while supporting two types of linked plans:
- **Sub-plans**: For implementing phases that need substantial planning
- **Branches**: For handling unexpected issues during execution

## Installation

Link the plan-manager directory to your global commands:

```bash
ln -s "$(pwd)/commands/plan-manager" ~/.claude/commands/plan-manager
```

## Key Features

- Track multiple master plans in parallel (for large projects with multiple initiatives)
- Initialize and track master plans with phase-based structure
- Create sub-plans for implementing complex phases (pre-planned or just-in-time)
- Branch into plans when issues arise during implementation
- Capture tangential plans created during work
- Automatically link related plans together based on content analysis
- Rename randomly-named plans to meaningful names
- Archive completed plans to keep workspace clean
- Visualize plan hierarchies with ASCII charts
- Switch between master plans for multi-initiative projects
- Organize plans with subdirectories and category directories

## Command Reference

### Getting Started

**`init <path>`**
Initialize or add a master plan
- Options: `--flat`, `--description "text"`
- Example: `/plan-manager init plans/feature.md`

**`config`**
View/edit category organization settings
- Options: `--edit`, `--user`, `--project`
- Example: `/plan-manager config --edit`

### Working with Plans

**`branch <phase>`**
Create a branch plan for handling issues
- Options: `--master <path>`
- Example: `/plan-manager branch 3`

**`sub-plan <phase>`**
Create a sub-plan for implementing a phase (also accepts `subplan`)
- Options: `--master <path>`, `--pre-planned`
- Example: `/plan-manager sub-plan 2`

**`capture [file]`**
Link an existing plan to a phase
- Options: `--phase N`, `--master <path>`
- Example: `/plan-manager capture plans/fix.md --phase 2`

**`complete <plan>`**
Mark a sub-plan or phase as complete
- Example: `/plan-manager complete 3`

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
- Example: `/plan-manager organize`

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
- "branch from phase 2"
- "organize my plans"
- "capture that plan"
- "rename that plan"
- "what plans do we have?"
- "show plan status"

## Tips

- Run `/plan-manager` with no command for interactive menu
- Phase completion is auto-detected when you say "Phase X is complete"
- Merge branch plans back into master to consolidate updates
- Category organization keeps different plan types separated
- Subdirectories keep master plans and sub-plans together

## Recommended Enhancements

### Auto-Initialize Plans from Plan Mode

Add a PostToolUse hook to automatically convert plans created in Claude Code's plan mode into plan-manager tracked plans:

**`~/.claude/hooks/init-plan-on-exit.md`**

```markdown
---
event: PostToolUse
matcher:
  tool: ExitPlanMode
model: sonnet
---

# Auto-initialize Plan Manager on Exit Plan Mode

This hook automatically runs `/plan-manager:commands:init` when exiting plan mode,
converting the plan into a structured plan-manager plan for tracking.

\`\`\`bash
claude /plan-manager:commands:init
\`\`\`
```

This creates a seamless workflow: create a plan in plan mode, and it's automatically initialized in plan-manager when you exit, ready for phase tracking and sub-plan management.

## Documentation

- [SKILL.md](SKILL.md) — Skill definition and quick command reference
- [commands/](commands/) — Detailed command specifications
- [examples/](examples/) — Templates and workflows
- [organization.md](organization.md) — Directory structure and category organization
- [state-schema.md](state-schema.md) — State file format and schema
