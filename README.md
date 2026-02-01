# Claude Code Commands

Shared Claude Code commands and configurations for use across projects.

## Commands

### plan-manager

Manage hierarchical plans with linked sub-plans and branches. Maintains a single source of truth (master plan) while supporting two types of linked plans:
- **Sub-plans**: For implementing phases that need substantial planning
- **Branches**: For handling unexpected issues during execution

**Key Features:**
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

**Installation:**

Link the plan-manager directory to your global commands:

```bash
ln -s "$(pwd)/commands/plan-manager" ~/.claude/commands/plan-manager
```

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
- Use natural language: "capture that plan", "organize my plans"
- Phase completion is auto-detected when you say "Phase X is complete"
- Merge branch plans back into master to consolidate updates
- Category organization keeps different plan types separated
- Subdirectories keep master plans and sub-plans together

## Documentation

For detailed documentation, see:
- [SKILL.md](commands/plan-manager/SKILL.md) - Quick reference and links
- [commands/](commands/plan-manager/commands/) - Detailed command specifications
- [examples/](commands/plan-manager/examples/) - Templates and workflows
- [organization.md](commands/plan-manager/organization.md) - Directory structure
- [state-schema.md](commands/plan-manager/state-schema.md) - State file format

## Contributing

Contributions welcome! This is a collection of useful Claude Code commands and configurations.

## License

MIT
