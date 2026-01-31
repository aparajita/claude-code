# Claude Code Commands

Shared Claude Code commands and configurations for use across projects.

## Commands

### plan-manager

Manage hierarchical plans with linked sub-plans. Maintains a single source of truth (master plan) while allowing sub-plans to branch off for handling issues discovered during execution.

**Key Features:**
- Track multiple master plans in parallel (for large projects with multiple initiatives)
- Initialize and track master plans with phase-based structure
- Branch into sub-plans when issues arise during implementation
- Capture tangential plans created during work
- Automatically link related plans together based on content analysis
- Rename randomly-named plans to meaningful names
- Archive completed plans to keep workspace clean
- Visualize plan hierarchies with ASCII charts
- Switch between master plans for multi-initiative projects

**Installation:**

Copy `commands/plan-manager.md` to your global commands directory:

```bash
cp commands/plan-manager.md ~/.claude/commands/
```

**Usage:**

- `/plan-manager init <path>` — Initialize or add a master plan
- `/plan-manager overview` — See all plans and their relationships
- `/plan-manager organize` — Auto-link related plans and clean up
- `/plan-manager capture` — Link a plan you just created
- `/plan-manager rename <file> [new-name]` — Rename a plan and update references
- `/plan-manager status [--all]` — Show plan hierarchy (active or all)
- `/plan-manager switch <master>` — Change active master plan
- `/plan-manager list-masters` — Show all tracked master plans
- `/plan-manager audit` — Find orphaned or broken plans

Or use natural language:
- "organize my plans"
- "capture that plan"
- "rename that plan"
- "what plans do we have?"

See [commands/plan-manager.md](commands/plan-manager.md) for full documentation.

## Contributing

Contributions welcome! This is a collection of useful Claude Code commands and configurations.

## License

MIT
